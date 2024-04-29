--------------------------------------------------------
--  DDL for Package Body CZ_MODEL_CONVERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_MODEL_CONVERT" AS
   /* $Header: czmdlconb.pls 120.38.12010000.5 2010/05/26 17:16:48 spitre ship $ */

  g_pkg_name constant VARCHAR2(30) := 'cz_model_convert';
  v_ndebug INTEGER := 1;
  v_model_conversion_set_id NUMBER;

  PS_TYPE_FEATURE        CONSTANT  NUMBER:= 261;
  PS_TYPE_OPTION         CONSTANT  NUMBER:= 262;
  PS_TYPE_COMPONENT      CONSTANT  NUMBER:= 259;
  PS_TYPE_TOTAL          CONSTANT  NUMBER:= 272;
  PS_TYPE_RESOURCE       CONSTANT  NUMBER:= 273;
  PS_TYPE_BOM_MODEL      CONSTANT  NUMBER:= 436;
  PS_TYPE_REFERENCE  CONSTANT  NUMBER:= 263;
  PS_TYPE_BOM_OPTION_CLASS  CONSTANT     NUMBER:= 437;
  PS_TYPE_BOM_STD_ITEM      CONSTANT     NUMBER:= 438;
  RULE_CLASS_DEFAULT        CONSTANT     NUMBER:= 1;
  RULE_CLASS_CONSTRAINT     CONSTANT     NUMBER:= 0;
  FEATURE_TYPE_INTEGER      CONSTANT     NUMBER:= 1;
  FEATURE_TYPE_FLOAT        CONSTANT     NUMBER:= 2;
  FEATURE_TYPE_BOOLEAN      CONSTANT     NUMBER:= 3;
  FEATURE_TYPE_TEXT         CONSTANT     NUMBER:= 4;
  FEATURE_TYPE_LIST_OF_OPTIONS CONSTANT  NUMBER:=0;
  NODE_INSTANTIABILITY_MULTIPLE  CONSTANT     NUMBER:=4;
  RULE_TYPE_COMPAT_TABLE         CONSTANT     NUMBER:=24;
  RULE_TYPE_DESIGN_CHART_RULE  CONSTANT     NUMBER:=30;
  RULE_TEMPLATE_FREEFORM_RULE  CONSTANT     NUMBER:=200;
  RULE_TYPE_CONFIGURATION_EXT  CONSTANT     NUMBER:=300;

  USE_BOM_DEFAULT_QTY  VARCHAR2(6):='TRUE';
  INTEGER_MIN_VAL NUMBER(10) := -2147483648;
  SOLVER_MAX_DOUBLE NUMBER := 1E125;
  INTEGER_MAX_VALUE NUMBER(10) := 2147483647;


  OPERATOR_ADDSTO        CONSTANT  NUMBER:= 712;
  OPERATOR_SUBTRACTSFROM CONSTANT  NUMBER:= 714;

  --Table to store the ID's of rows affected by an Update statement .
  TYPE t_ref IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

  TYPE t_ref_num IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;

  v_cz_num_tbl t_ref;
  v_cz_ids_tbl t_ref;
  v_cz_names_tbl t_ref_num;


  TYPE t_cz_expression_nodes IS TABLE OF cz_expression_nodes%ROWTYPE INDEX BY BINARY_INTEGER;
  v_cz_expression_nodes t_cz_expression_nodes;
  v_cz_expr_node_count NUMBER(10);

  TYPE t_cz_rules IS TABLE OF cz_rules%ROWTYPE INDEX BY BINARY_INTEGER;
  v_cz_rules  t_cz_rules ;
  v_cz_rule_count NUMBER(10);


-- used for getting the next rule id since rule sequence is incremented by 20 every time
  last_id_allocated  NUMBER := NULL;
  next_id_to_use     NUMBER := 0;
  CZ_SEQUENCE_INCREMENT number :=20;


  --procedure to log debug messages to conc request output file / cz_db_logs
  PROCEDURE log_msg(p_caller IN VARCHAR2,   p_ndebug IN NUMBER,   p_msg IN VARCHAR2,   p_level IN NUMBER) IS
  l_msg varchar2(2000):=NULL;
  l_api_name constant VARCHAR2(30) := 'log_msg';
  BEGIN
    IF fnd_global.conc_request_id > 0 THEN
      fnd_file.PUT_LINE(fnd_file.LOG,   p_msg);
    END IF;
    cz_utils.log_report(g_pkg_name,   p_caller,   p_ndebug,   p_msg,   p_level);
  EXCEPTION WHEN OTHERS THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END log_msg;

  --procedure to log messages to  cz_db_logs for use by the model conversion xml publisher report
  PROCEDURE displayMessage(p_urgency In NUMBER,p_model_id IN NUMBER, p_object_type IN VARCHAR2 ,p_object_id IN NUMBER
                           ,p_caller IN VARCHAR2,msg VARCHAR2
                           ,token1 IN VARCHAR2 DEFAULT NULL, value1 IN VARCHAR2 DEFAULT NULL
                           ,token2 IN VARCHAR2 DEFAULT NULL, value2 IN VARCHAR2 DEFAULT NULL
                           ,token3 IN VARCHAR2 DEFAULT NULL, value3 IN VARCHAR2 DEFAULT NULL
			   ,p_element_id IN NUMBER DEFAULT NULL
			   ,p_element_type IN NUMBER DEFAULT NULL) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_msg varchar2(2000):=NULL;
  l_api_name constant VARCHAR2(30) := 'displayMessage';
  BEGIN
    IF msg IS NOT NULL THEN
            IF token3 IS NOT NULL THEN
                    l_msg:=cz_utils.get_text(msg,token1, value1,token2, value2,token3, value3);
                    ELSE IF token2 IS NOT NULL THEN
                            l_msg:=cz_utils.get_text(msg,token1, value1,token2, value2);

                            ELSE IF token1 IS NOT NULL THEN
                                    l_msg:=cz_utils.get_text(msg,token1, value1);
                                 ELSE
                                    l_msg:=cz_utils.get_text(msg);
                            END IF;
                    END IF;
            END IF;

        INSERT INTO  CZ_DB_LOGS (LOGTIME, LOGUSER, URGENCY, CALLER  ,  MESSAGE, MODEL_ID , OBJECT_TYPE ,OBJECT_ID,MODEL_CONVERSION_SET_ID,ELEMENT_ID,ELEMENT_TYPE)
                      VALUES(SYSDATE, USER   , p_urgency, p_caller,  l_msg   , p_model_id , p_object_type ,p_object_id,v_model_conversion_set_id,p_element_id,p_element_type);

    END IF;
    /*log_msg(p_caller   ,   v_ndebug,   l_msg,   1   );*/


    COMMIT;

   EXCEPTION WHEN OTHERS THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
   END;


  FUNCTION findOrCreateRuleFolder(p_dev_project_id IN cz_devl_projects.devl_project_id%TYPE) RETURN cz_rules.rule_folder_id%TYPE AS
  p_rule_folderid cz_rules.rule_folder_id%TYPE;
  p_parent_rule_fldr cz_rules.rule_folder_id%TYPE;

  CURSOR c_rule_fld IS
  SELECT rule_folder_id
  FROM cz_rule_folders
  WHERE deleted_flag ='0'
   AND name = 'Rules Generated by Model Conversion'
   AND devl_project_id = p_dev_project_id;
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'findOrCreateRuleFolder';
  BEGIN
    OPEN c_rule_fld;
    FETCH c_rule_fld
    INTO p_rule_folderid;
    CLOSE c_rule_fld;
    IF p_rule_folderid IS NULL THEN
      --Create a rule folder with name "Rules Generated by Model Conversion"  populate  rulefolderID
      -- INSERTING into


      select rule_folder_id into p_parent_rule_fldr from cz_rule_folders where  devl_project_id=p_dev_project_id and deleted_flag='0' and parent_rule_folder_id is null;


      INSERT
      INTO cz_rule_folders(rule_folder_id,   name,   devl_project_id,   tree_seq,   deleted_flag,   folder_type,   effective_usage_mask,   persistent_rule_folder_id,   object_type,   disabled_flag , parent_rule_folder_id)
      VALUES(cz_rule_folders_s.nextval,   'Rules Generated by Model Conversion',   p_dev_project_id,   '1',   '0',   '0',   '0000000000000000',   cz_rule_folders_s.nextval,   'RFL',   '0' , p_parent_rule_fldr)
      RETURNING rule_folder_id INTO p_rule_folderid;

    END IF;
    RETURN p_rule_folderid;
  EXCEPTION WHEN OTHERS THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END findOrCreateRuleFolder;

  --  procedure to populate CZ tables with data in temporary tables v_cz_rules and v_cz_expression_nodes
  PROCEDURE populate_cz_tables (commit_all boolean default false) AS
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'populate_cz_expression_table';
  BEGIN

    IF ((v_cz_rules.LAST IS NOT NULL and v_cz_rules.LAST >20) OR commit_all ) THEN

         IF (v_cz_rules.LAST IS NOT NULL) THEN
            for v_cz_rules_count IN v_cz_rules.FIRST .. v_cz_rules.LAST  Loop
                begin
                  INSERT INTO cz_localized_texts (localized_str, intl_text_id, deleted_flag, language, source_lang, model_id, seeded_flag, persistent_intl_text_id)
                  VALUES (v_cz_rules(v_cz_rules_count).name, v_cz_rules(v_cz_rules_count).reason_id, 0, 'US', 'US', v_cz_rules(v_cz_rules_count).devl_project_id, 0, v_cz_rules(v_cz_rules_count).reason_id);
                exception when others then
                        null;
                end;
            END LOOP;
            -- use FORALL statement for bulk insert.
            forall v_cz_rules_count IN v_cz_rules.FIRST .. v_cz_rules.LAST
            INSERT INTO cz_rules
            VALUES v_cz_rules(v_cz_rules_count);
          END IF;
            -- use FORALL statement for bulk insert.
          IF (v_cz_expression_nodes.LAST IS NOT NULL) THEN
            for v_cz_expr_nodes_count IN v_cz_expression_nodes.FIRST .. v_cz_expression_nodes.LAST loop
                v_cz_expression_nodes(v_cz_expr_nodes_count).seeded_flag:=0;
                v_cz_expression_nodes(v_cz_expr_nodes_count).deleted_flag:=0;
            end loop;
            forall v_cz_expr_nodes_count IN v_cz_expression_nodes.FIRST .. v_cz_expression_nodes.LAST
            INSERT INTO cz_expression_nodes
            VALUES v_cz_expression_nodes(v_cz_expr_nodes_count);
            v_cz_expression_nodes.DELETE;
           END IF;
          IF (v_cz_rules.LAST IS NOT NULL) THEN

            FOR v_cz_rules_count IN v_cz_rules.FIRST .. v_cz_rules.LAST LOOP
                 IF v_cz_rules(v_cz_rules_count).presentation_flag=0 THEN
                      cz_rule_text_gen.parse_rules( v_cz_rules(v_cz_rules_count).devl_project_id,   v_cz_rules(v_cz_rules_count).rule_id);
                 END IF;
            END LOOP;
            v_cz_rules.DELETE;
           END IF;

            v_cz_rule_count:=0;
            v_cz_expr_node_count:=0;
    END IF;



  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END populate_cz_tables;



 PROCEDURE UPG_UI_CONT_TYPE_TMPLS(p_devl_project_id IN NUMBER) IS
  TYPE num_tbl_type IS TABLE OF NUMBER;
  l_cont_types_tbl     num_tbl_type := num_tbl_type(633,635,189,565,622, 638,636,637);
  l_template_ids_tbl   num_tbl_type := num_tbl_type(1009,1020,301,221,572, 1017,1016,1015);
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'UPG_UI_CONT_TYPE_TMPLS';
 BEGIN

  FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS
            WHERE ui_style='7' AND seeded_flag='0' AND deleted_flag='0' and devl_project_id=p_devl_project_id)
   LOOP
    FORALL j IN 1..l_cont_types_tbl.COUNT
      INSERT INTO CZ_UI_CONT_TYPE_TEMPLS
      (
       UI_DEF_ID
       ,CONTENT_TYPE
       ,TEMPLATE_ID
       ,MASTER_TEMPLATE_FLAG
       ,TEMPLATE_UI_DEF_ID
       ,WRAP_TEMPLATE_FLAG
       ,DELETED_FLAG
       ,SEEDED_FLAG
       )
      SELECT
       i.ui_def_id
       ,l_cont_types_tbl(j)
       ,l_template_ids_tbl(j)
       ,'0'
       ,0
       ,'0'
       ,'0'
       ,'0'
      FROM dual
      WHERE NOT EXISTS
      (SELECT NULL FROM CZ_UI_CONT_TYPE_TEMPLS
        WHERE ui_def_id=i.ui_def_id AND content_type=l_cont_types_tbl(j));
   END LOOP;



      --   Get the cz_ui_cont_type_templs.template_Id for content_type 543
      --   Create two records with template_id from i) and content_types 560 and 561
      --   Delete the record with content_type 543
    FOR c_ct IN(SELECT c.*
                FROM cz_ui_defs ui,
                  cz_ui_cont_type_templs c
                WHERE ui.deleted_flag = '0'
                 AND ui.devl_project_id = p_devl_project_id
                 AND c.ui_def_id = ui.ui_def_id
                 AND c.deleted_flag = '0'
                 AND content_type = 543
                 AND NOT EXISTS
                  (SELECT 1
                   FROM cz_ui_cont_type_templs
                   WHERE ui_def_id = ui.ui_def_id
                   AND content_type =560)) LOOP
        INSERT INTO cz_ui_cont_type_templs (UI_DEF_ID,CONTENT_TYPE,TEMPLATE_ID,DELETED_FLAG,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
        LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,MASTER_TEMPLATE_FLAG,SEEDED_FLAG,TEMPLATE_UI_DEF_ID,WRAP_TEMPLATE_FLAG)
        VALUES
        (
        c_ct.UI_DEF_ID,560,c_ct.TEMPLATE_ID,c_ct.DELETED_FLAG,c_ct.CREATED_BY,c_ct.CREATION_DATE,c_ct.LAST_UPDATED_BY,
        c_ct.LAST_UPDATE_DATE,c_ct.LAST_UPDATE_LOGIN,c_ct.MASTER_TEMPLATE_FLAG,c_ct.SEEDED_FLAG,c_ct.TEMPLATE_UI_DEF_ID,c_ct.WRAP_TEMPLATE_FLAG
        );

     END LOOP;

     UPDATE cz_ui_cont_type_templs uiout set content_type=561
                WHERE
                 ui_def_id  IN (select ui.ui_def_id from cz_ui_defs ui WHERE ui.deleted_flag = '0' AND ui.devl_project_id = p_devl_project_id)
                 AND deleted_flag = '0'
                 AND content_type = 543
                 AND NOT EXISTS
                (SELECT NULL FROM CZ_UI_CONT_TYPE_TEMPLS
                  WHERE ui_def_id=uiout.ui_def_id AND content_type=561) ;

  EXCEPTION WHEN OTHERS THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;

  END UPG_UI_CONT_TYPE_TMPLS;



  FUNCTION GET_UI_ELEMENT_ID(inPageElemID IN VARCHAR2) RETURN NUMBER is
  l_qualified  VARCHAR2(2000) := ' ';
  count1 number:=0;

  BEGIN
   l_qualified:=inPageElemID;
   count1:=instr(inPageElemID,'_') ;
   while (count1>0 )loop
     l_qualified:=substr(l_qualified,count1+1);
     count1:=instr(l_qualified,'_');
   end loop;


   RETURN to_number(l_qualified);

  EXCEPTION
    WHEN others THEN
    RAISE;
  END GET_UI_ELEMENT_ID;




  --This procedure removes the effectivity information from Total, Resource, Integer Feat, Decimal Feat, and Virtual Component.
  PROCEDURE processUI(p_dev_project_id IN cz_devl_projects.devl_project_id%TYPE) AS
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'processUI';
  BEGIN



   --DHTML UI's will not be supported in fusion .Mark these as deleted

    UPDATE cz_ui_defs SET deleted_flag='1' WHERE ui_style = 0
         AND deleted_flag ='0'
         AND devl_project_id =p_dev_project_id
         RETURNING ui_def_id BULK COLLECT INTO v_cz_ids_tbl;

    IF v_cz_ids_tbl.COUNT >0 THEN
     FOR i in v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
     LOOP
       displayMessage(2,p_dev_project_id , 'UI' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_WARN_DHTML_DELETE');
     END LOOP;
    v_cz_ids_tbl.DELETE;
    END IF;

--As Functional Companions are not supported in FCE models, Model Conversion should warn on detecting them.
--Bug 6489541
    FOR v_ui IN(SELECT DISTINCT a.ui_def_id
                       FROM cz_ui_nodes a,
                            cz_ui_defs ui
                       WHERE a.deleted_flag = '0'
                       AND ui.deleted_flag = '0'
                       AND a.ui_def_id = ui.ui_def_id
                       AND ui.devl_project_id = p_dev_project_id
                       AND a.func_comp_id IS NOT NULL) LOOP
          displayMessage(2,p_dev_project_id , 'UI' ,v_ui.ui_def_id,l_api_name,'CZ_CNV_WARN_FC_NOT_SUPPORTED');
    END LOOP;



   --Display message "UI will use the default Icons, Message Templates, and Utility Templates for functions specific to Fusion Engine. These can be overridden in the UI Definition."

    FOR v_ui IN
      (SELECT ui.ui_def_id
       FROM cz_ui_defs ui
       WHERE  ui.deleted_flag ='0'
       AND ui.devl_project_id = p_dev_project_id)
    LOOP

      displayMessage(3,p_dev_project_id , 'UI' ,v_ui.ui_def_id,l_api_name,'CZ_CNV_ADV_DEFAULT_UIS');
    END LOOP;

    --Update UI's to use the new content templates
    UPG_UI_CONT_TYPE_TMPLS(p_dev_project_id);



    FOR v_ui1 IN
      (
        SELECT DISTINCT * FROM(
                SELECT  text_str,
                  te.template_id,
                  'NodeUnsatisfied' lceprop,
                  'UserInputRequired' fceprop,
		  te.element_id ,
                  te.element_type
                FROM cz_ui_cont_type_templs c, cz_ui_templates t , cz_signatures s  ,cz_intl_texts text , cz_ui_template_elements te ,cz_ui_defs ui
                WHERE c.ui_def_id = ui.ui_def_id
                  AND   c.template_id = t.template_id
                  AND   c.content_type = s.signature_id
                  AND   c.deleted_flag = '0'
                  AND   t.deleted_flag = '0'
                  AND   te.deleted_flag = '0'
                  AND   te.element_type = 8  -- is a text element
                  and text.ui_page_id=t.template_id AND UPPER(text_str) LIKE '%'||fnd_global.local_chr(38)||'NODEUNSATISFIED%'
                  and text.deleted_flag='0'
                  and c.TEMPLATE_UI_DEF_ID = t.UI_DEF_ID
                  and s.signature_type IN ('SES','UCO')
                  AND t.ui_def_id=c.template_ui_def_id
                  and t.template_id=te.template_id
                  and te.element_id=text.intl_text_id
                  and ui.deleted_flag ='0'
                  and text.ui_def_id = t.ui_def_id
                  AND ui.devl_project_id = p_dev_project_id
		  AND t.ui_def_id=te.ui_def_id

                UNION ALL
                SELECT  text_str,
                  te.template_id,
                  'Unsatisfied' lceprop,
                  'UserInputRequired' fceprop,
		  te.element_id ,
                  te.element_type
                FROM cz_ui_cont_type_templs c, cz_ui_templates t , cz_signatures s  ,cz_intl_texts text, cz_ui_template_elements te , cz_ui_defs ui
                WHERE c.ui_def_id = ui.ui_def_id
                  AND   c.template_id = t.template_id
                  AND   c.content_type = s.signature_id
                  AND   c.deleted_flag = '0'
                  AND   t.deleted_flag = '0'
                  AND   te.deleted_flag = '0'
                  AND   te.element_type = 8  -- is a text element
                  and text.ui_page_id=t.template_id AND UPPER(text_str) LIKE '%'||fnd_global.local_chr(38)||'UNSATISFIED%'
                  and text.deleted_flag='0'
                  and c.TEMPLATE_UI_DEF_ID = t.UI_DEF_ID
                  and s.signature_type IN ('SES','UCO')
                  AND t.ui_def_id=c.template_ui_def_id
                  and t.template_id=te.template_id
                  and te.element_id=text.intl_text_id
                  and ui.deleted_flag ='0'
                  and text.ui_def_id = t.ui_def_id
                  AND ui.devl_project_id = p_dev_project_id
		  AND t.ui_def_id=te.ui_def_id

                UNION ALL
                SELECT  text_str,
                  te.template_id,
                  'SubtreeUnsatisfied' lceprop,
                  'UserInputRequiredInSubtree' fceprop,
		  te.element_id ,
                  te.element_type
                FROM cz_ui_cont_type_templs c, cz_ui_templates t , cz_signatures s  ,cz_intl_texts text, cz_ui_template_elements te , cz_ui_defs ui
                WHERE c.ui_def_id = ui.ui_def_id
                  AND   c.template_id = t.template_id
                  AND   c.content_type = s.signature_id
                  AND   c.deleted_flag = '0'
                  AND   t.deleted_flag = '0'
                  AND   te.deleted_flag = '0'
                  AND   te.element_type = 8  -- is a text element
                  and text.ui_page_id=t.template_id AND UPPER(text_str) LIKE '%'||fnd_global.local_chr(38)||'SUBTREEUNSATISFIED%'
                  and text.deleted_flag='0'
                  and c.TEMPLATE_UI_DEF_ID = t.UI_DEF_ID
                  and s.signature_type IN ('SES','UCO')
                  AND t.ui_def_id=c.template_ui_def_id
                  and t.template_id=te.template_id
                  and te.element_id=text.intl_text_id
                  and ui.deleted_flag ='0'
                  and text.ui_def_id = t.ui_def_id
                  AND ui.devl_project_id = p_dev_project_id
		  AND t.ui_def_id=te.ui_def_id
        )

      )
    LOOP
      --Refer TD section 4.1.5.2
      --UI Has Text Expression  that references a  System Property that was redefined for FCE(
      --Unsatisfied (session),NodeUnsatisfied,SubtreeUnsatisfied)
      --Unsatisfied becomes UserInputRequired()
      --SubtreeUnsatisfied becomes UserInputRequiredInSubtree
      --Session.Unsatisfied.UserInputRequired
       displayMessage(1,p_dev_project_id , 'TEMPLATE' ,v_ui1.template_id,l_api_name,'CZ_CNV_FAIL_REDEF_SYSPROP','LCEPROPERTYNAME',
                      v_ui1.lceprop,'EXPRESSION_OR_CONDITION' ,' Text Expression ' ,'FCEPROPERTYNAME' ,v_ui1.fceprop
                     ,v_ui1.element_id , v_ui1.element_type);
    END LOOP;



    FOR v_ui IN
      (
        SELECT DISTINCT tempel.element_id ,te.template_id,
          decode(ex.template_id,   820,   'NodeUnsatisfied',   836,   'Unsatisfied',   849,   'SubtreeUnsatisfied') lceprop,
          decode(ex.template_id,   820,   'InputRequired',   836,   'InputRequired',   849,   'InputRequiredInSubtree') fceprop,
          ru.name,
          ui.ui_def_id,
          ru.ui_page_element_id,
          tempel.element_type
        FROM cz_expression_nodes ex,
          cz_rules ru,
          cz_ui_defs ui ,
          cz_ui_cont_type_templs ct,
          cz_ui_defs ui2,
          cz_ui_templates te ,cz_ui_template_elements tempel
        WHERE ex.template_id IN(820,   836,   849)
         AND ex.deleted_flag = '0'
         AND ex.rule_id = ru.rule_id
         AND ru.deleted_flag = '0'
         AND ui.deleted_flag = '0'
         AND ui2.deleted_flag = '0'
         AND ru.ui_def_id = ui.ui_def_id
         AND ui.ui_def_id = te.ui_def_id
         and te.template_id=ct.template_id
         and ct.ui_def_id=ui2.ui_def_id
         and ui2.devl_project_id = p_dev_project_id
         and tempel.template_id=te.template_id
         AND tempel.ui_def_id = te.ui_def_id

      )
    LOOP
      --Refer TD section 4.1.5.2
      --UI Has Display Condition that references a  System Property that was redefined for FCE(
      --Unsatisfied (session),NodeUnsatisfied,SubtreeUnsatisfied)
      --Unsatisfied becomes UserInputRequired()
      --SubtreeUnsatisfied becomes UserInputRequiredInSubtree
      --Session.Unsatisfied UserInputRequired
       displayMessage(1,p_dev_project_id , 'TEMPLATE' , v_ui.template_id,l_api_name,'CZ_CNV_FAIL_REDEF_SYSPROP','LCEPROPERTYNAME',
                      v_ui.lceprop,'EXPRESSION_OR_CONDITION' , ' Display Condition ' ,'FCEPROPERTYNAME' ,v_ui.fceprop ,
                      v_ui.element_id ,v_ui.element_type );
    END LOOP;





    --for each converted UI. Conversion Advisory message is to be displayed
    --refer section 4.1.5.1


    FOR v_ui IN
      (
        SELECT text_str,
          cz_intl_texts.ui_def_id,
          'NodeUnsatisfied' lceprop,
          'UserInputRequired' fceprop
        FROM cz_intl_texts,cz_ui_defs
        WHERE UPPER(text_str) LIKE '%'||fnd_global.local_chr(38)||'NODEUNSATISFIED%'
         AND model_id = p_dev_project_id
         AND  cz_intl_texts.ui_def_id=cz_ui_defs.ui_def_id
         AND  cz_ui_defs.devl_project_id=p_dev_project_id
         AND  cz_ui_defs.deleted_flag='0'

        UNION ALL
        SELECT text_str,
          cz_intl_texts.ui_def_id,
          'Unsatisfied' lceprop,
          'UserInputRequired' fceprop
        FROM cz_intl_texts,cz_ui_defs
        WHERE UPPER(text_str) LIKE '%'||fnd_global.local_chr(38)||'UNSATISFIED%'
         AND model_id = p_dev_project_id
         AND  cz_intl_texts.ui_def_id=cz_ui_defs.ui_def_id
         AND  cz_ui_defs.devl_project_id=p_dev_project_id
         AND  cz_ui_defs.deleted_flag='0'

        UNION ALL
        SELECT text_str,
          cz_intl_texts.ui_def_id,
          'SubtreeUnsatisfied' lceprop,
          'UserInputRequiredInSubtree' fceprop
        FROM cz_intl_texts,cz_ui_defs
        WHERE UPPER(text_str) LIKE '%'||fnd_global.local_chr(38)||'SUBTREEUNSATISFIED%'
         AND model_id = p_dev_project_id
         AND  cz_intl_texts.ui_def_id=cz_ui_defs.ui_def_id
         AND  cz_ui_defs.devl_project_id=p_dev_project_id
         AND  cz_ui_defs.deleted_flag='0'

      )
    LOOP
      --Refer TD section 4.1.5.2
      --UI Has Text Expression  that references a  System Property that was redefined for FCE(
      --Unsatisfied (session),NodeUnsatisfied,SubtreeUnsatisfied)
      --Unsatisfied becomes UserInputRequired()
      --SubtreeUnsatisfied becomes UserInputRequiredInSubtree
      --Session.Unsatisfied.UserInputRequired

      --todo to do check this message and see element description .
      displayMessage(2,p_dev_project_id , 'UIE' ,v_ui.ui_def_id,l_api_name,'CZ_CNV_WARN_REDEF_SYSPROP','LCEPROPERTYNAME' , v_ui.lceprop,'EXPRESSION_OR_CONDITION' ,' Text Expression ' ,'FCEPROPERTYNAME' ,v_ui.fceprop);
    END LOOP;


    Update cz_localized_texts
      set localized_str=REPLACE(REPLACE(REPLACE(localized_str,fnd_global.local_chr(38)||'NODEUNSATISFIED',fnd_global.local_chr(38)||'USERINPUTREQUIRED'),fnd_global.local_chr(38)||'UNSATISFIED%'
                                ,fnd_global.local_chr(38)||'USERINPUTREQUIRED'),fnd_global.local_chr(38)||'SUBTREEUNSATISFIED%',fnd_global.local_chr(38)||'USERINPUTREQUIREDINSUBTREE')
        WHERE UPPER(localized_str) LIKE '%'||fnd_global.local_chr(38)||'%UNSATISFIED%'
         AND model_id = p_dev_project_id
         AND ui_def_id IN (  SELECT ui_def_id FROM cz_ui_defs
                             WHERE deleted_flag='0' AND cz_localized_texts.ui_def_id = ui_def_id
                             AND devl_project_id=p_dev_project_id
                           )
         AND deleted_flag='0';



    FOR v_ui IN
      (SELECT DISTINCT template_id , decode(template_id,820,'NodeUnsatisfied' ,836,'Unsatisfied',849,'SubtreeUnsatisfied') lceprop ,
        decode(template_id,820,'InputRequired' ,836,'InputRequired',849,'InputRequiredInSubtree')  fceprop,ru.name ,ui.ui_def_id, ru.ui_page_element_id
       FROM cz_expression_nodes ex,
         cz_rules ru,
         cz_ui_defs ui
       WHERE template_id IN(820,    836,    849)
       AND ex.deleted_flag ='0'
       AND ex.rule_id = ru.rule_id
       AND ru.deleted_flag ='0'
       AND ui.deleted_flag ='0'
       AND ru.ui_def_id = ui.ui_def_id
       AND ui.devl_project_id = p_dev_project_id
       )
    LOOP
      --Refer TD section 4.1.5.2
      --UI Has Display Condition that references a  System Property that was redefined for FCE(
      --Unsatisfied (session),NodeUnsatisfied,SubtreeUnsatisfied)
      --Unsatisfied becomes UserInputRequired()
      --SubtreeUnsatisfied becomes UserInputRequiredInSubtree
      --Session.Unsatisfied UserInputRequired
      displayMessage(2,p_dev_project_id , 'UIE' ,GET_UI_ELEMENT_ID(v_ui.ui_page_element_id),l_api_name,'CZ_CNV_WARN_REDEF_SYSPROP','LCEPROPERTYNAME' , v_ui.lceprop,'EXPRESSION_OR_CONDITION' ,' Display Condition ' ,'FCEPROPERTYNAME' ,v_ui.fceprop);
    END LOOP;


/*
Mappings Table for System Properties

OLD ID New ID OLD Property Name  New Property Name
894     979     MaxConnections  DefinitionMaxConnections
818     977     MaxInstances    DefinitionMaxInstances
812     899     MaxValue        DefinitionMaxValue
847     898     MaxValue        DefinitionMaxValue
893     978     MinConnections  DefinitionMinConnections
817     976     MinInstances    DefinitionMinInstances
811     897     MinValue        DefinitionMinValue
846     896     MinValue        DefinitionMinValue
813     971     MinQuantity     DefinitionMinQuantity
814     973     MaxQuantity     DefinitionMaxQuantity
815     974     MinSelected     DefinitionMinSelections
816     975     MaxSelected     DefinitionMaxSelections

*/


    FOR v_ui IN
      (SELECT template_id , (select name from cz_rules where rule_id=template_id) name , REPLACE(REPLACE((select 'Definition'||name from cz_rules where rule_id=template_id),'DefinitionMaxSelected','DefinitionMaxSelections')
                             ,'DefinitionMinSelected','DefinitionMinSelections') ruleName,ui.ui_def_id , ru.ui_page_element_id
       FROM cz_expression_nodes ex,
         cz_rules ru,
         cz_ui_defs ui
       WHERE template_id IN (894,818,812,847,893,817,811,846,813,814,815,816)
      AND ex.deleted_flag ='0'
       AND ex.rule_id = ru.rule_id
       AND ru.deleted_flag ='0'
       AND ui.deleted_flag ='0'
       AND ru.ui_def_id = ui.ui_def_id
       AND ui.devl_project_id = p_dev_project_id
       )
    LOOP
      --Refer TD section 4.1.5.2
      --If this ui element has a display condition / text expression which reference Min or Max system properties
      displayMessage(2,p_dev_project_id , 'UIE' ,GET_UI_ELEMENT_ID(v_ui.ui_page_element_id),l_api_name,'CZ_CNV_WARN_DIFF_SYSPROP','PROPERTYNAME_1'
                     , v_ui.name , 'EXPRESSION_OR_CONDITION', ' Display Condition ' ,'PROPERTYNAME_2', 'Definition'||v_ui.rulename);
    END LOOP;


    UPDATE cz_expression_nodes SET template_id= DECODE(template_id,894,979,818,977,812,899,847,898,893,978,817,976,811,897,846,896,813,971,814,973,815,974,816,975,template_id)
    WHERE expr_node_id IN
    (
    SELECT ex.expr_node_id
           FROM cz_expression_nodes ex,
             cz_rules ru,
             cz_ui_defs ui
           WHERE template_id IN (894,818,812,847,893,817,811,846,813,814,815,816)
          AND ex.deleted_flag ='0'
           AND ex.rule_id = ru.rule_id
           AND ru.deleted_flag ='0'
           AND ui.deleted_flag ='0'
           AND ru.ui_def_id = ui.ui_def_id
           AND ui.devl_project_id = p_dev_project_id
    );





    FOR v_ui IN
      (select intl.ui_def_id , ru.name lceprop ,   REPLACE(REPLACE('Definition'||ru.name ,'DefinitionMaxSelected','DefinitionMaxSelections'),'DefinitionMinSelected','DefinitionMinSelections') fceprop, intl.ui_page_element_id
        from cz_intl_texts intl, cz_ui_defs ui , cz_rules ru  where
        ru.rule_id in (894,818,812,893,817,811,813,814,815,816)
        and text_str like '%'||fnd_global.local_chr(38)||upper(ru.name)||'%'
        and intl.ui_def_id = ui.ui_def_id
        and intl.deleted_flag='0'
        and ui.deleted_flag='0'
        and intl.model_id =ui.devl_project_id
        and ui.devl_project_id= p_dev_project_id
      )
    LOOP
      --Refer TD section 4.1.5.2
      --If this ui element has a display condition / text expression which reference Min or Max system properties
      displayMessage(2,p_dev_project_id , 'UIE' ,GET_UI_ELEMENT_ID(v_ui.ui_page_element_id),l_api_name,'CZ_CNV_WARN_DIFF_SYSPROP','PROPERTYNAME_1' , v_ui.lceprop,'EXPRESSION_OR_CONDITION' ,' Text Expression ' ,'PROPERTYNAME_2' ,v_ui.fceprop);
    END LOOP;


        UPDATE cz_localized_texts intl SET localized_str = REPLACE(REPLACE(REPLACE(REPLACE(localized_str , ' '||fnd_global.local_chr(38)||'MIN' , ' '||fnd_global.local_chr(38)||'DEFINITIONMIN')
                                                           ,' '||fnd_global.local_chr(38)||'MAX' , ' '||fnd_global.local_chr(38)||'DEFINITIONMAX'),'DEFINITIONMAXSELECTED','DEFINITIONMAXSELECTIONS'),'DEFINITIONMINSELECTED','DEFINITIONMINSELECTIONS')
        WHERE ui_def_id IN(select ui_def_id from cz_ui_defs WHERE deleted_flag='0' AND devl_project_id= p_dev_project_id )
        AND model_id = p_dev_project_id
        AND EXISTS (
        SELECT 1 FROM cz_rules WHERE rule_id IN (894,818,812,893,817,811,813,814,815,816)
        AND localized_str LIKE '%'||fnd_global.local_chr(38)||upper(name)||'%' )
        AND deleted_flag='0';




  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END processUI;


  --This procedure removes the effectivity information from Total, Resource, Integer Feat, Decimal Feat, and Virtual Component.
  PROCEDURE removeEffectivityInfo(p_dev_project_id IN cz_devl_projects.devl_project_id%TYPE) AS
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'removeEffectivityInfo';
  BEGIN


    UPDATE cz_ps_nodes
    SET effective_usage_mask = '0000000000000000',
      effective_from = cz_utils.epoch_begin,
      effective_until = cz_utils.epoch_end,
      effectivity_set_id = NULL,
      eff_from = NULL,
      eff_to = NULL,
      eff_mask = NULL
    WHERE(ps_node_type IN(PS_TYPE_TOTAL,   PS_TYPE_RESOURCE) OR(ps_node_type = PS_TYPE_FEATURE
     AND feature_type IN(FEATURE_TYPE_INTEGER ,   FEATURE_TYPE_FLOAT)) OR(ps_node_type = PS_TYPE_COMPONENT AND virtual_flag = 1))
     AND devl_project_id = p_dev_project_id
     AND (effective_usage_mask <> '0000000000000000' or
      effective_from IS NOT NULL or
      effective_until IS NOT NULL or
      effectivity_set_id IS NOT NULL or
      eff_from IS NOT NULL or
      eff_to IS NOT NULL or
      eff_mask IS NOT NULL)
      RETURNING ps_node_id , name BULK COLLECT INTO v_cz_ids_tbl ,v_cz_names_tbl;

    IF v_cz_ids_tbl.COUNT >0 THEN
     FOR i in v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
     LOOP
      --For each of these nodes the effectivity will be removed , display appropriate message.
      displayMessage(2,p_dev_project_id , 'NODE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_WARN_EFF_REMOVED','NODETYPE',v_cz_names_tbl(i) );
     END LOOP;
     v_cz_ids_tbl.DELETE;
     v_cz_names_tbl.DELETE;
    END IF;


  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END removeEffectivityInfo;





-- function to get rule id values . As cz_rules_s sequence is incremented by 20 everytime hence we need this function
FUNCTION next_rule_id RETURN NUMBER IS
  id_to_return  NUMBER;
BEGIN
  IF((last_id_allocated IS NULL) OR
     (next_id_to_use = (NVL(last_id_allocated, 0) + CZ_SEQUENCE_INCREMENT)))THEN

    SELECT cz_rules_s.NEXTVAL INTO last_id_allocated FROM DUAL;
    next_id_to_use := last_id_allocated;
  END IF;

  id_to_return := next_id_to_use;
  next_id_to_use := next_id_to_use + 1;
 RETURN id_to_return;
END next_rule_id;



  FUNCTION createConstraintRuleRecord(p_rulefolderid IN cz_rules.rule_folder_id%TYPE,   p_ps_node_id IN cz_ps_nodes.ps_node_id%TYPE,
                                      p_devl_project_id IN cz_devl_projects.devl_project_id%TYPE , p_default_rule boolean DEFAULT FALSE) RETURN cz_rules.rule_id%TYPE AS
  l_rule_id cz_rules.rule_id%TYPE;
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'createConstraintRuleRecord';
  l_ps_node_name cz_ps_nodes.name%type;
  l_intl_text_id CZ_LOCALIZED_TEXTS.intl_text_id%type;
  initialvalue varchar2(2000);
  BEGIN

    l_rule_id:=next_rule_id;

    -- kdande; 10-Jan-2008; Bug 6730553; Changed cz_localized_texts_s to cz_intl_texts_s as cz_localized_texts_s is obsolete.
    SELECT cz_intl_texts_s.nextval INTO l_intl_text_id FROM Dual ;

    SELECT name , nvl(initial_value, initial_num_value ) INTO l_ps_node_name , initialvalue from cz_ps_nodes where ps_node_id=p_ps_node_id;

    -- INSERTING into  cz_rules
    -- BUG9176281 -
    -- If you call populate_cz_tables() after inserting the data in v_cz_rules - it will create a Rule with
    -- blank CDL as the v_cz_expression_nodes is not yet populated with required data.

        populate_cz_tables();

    -- End Fixing BUG9176281
        v_cz_rule_count:=v_cz_rule_count+1;
        V_CZ_RULES(v_cz_rule_count).rule_id:=           l_rule_id;
        V_CZ_RULES(v_cz_rule_count).reason_id:= l_intl_text_id;
        IF p_rulefolderid IS NULL THEN
                V_CZ_RULES(v_cz_rule_count).rule_folder_id:=findOrCreateRuleFolder(p_devl_project_id)   ;
        ELSE
                V_CZ_RULES(v_cz_rule_count).rule_folder_id:= p_rulefolderid     ;
        END IF;
        V_CZ_RULES(v_cz_rule_count).devl_project_id:=   p_devl_project_id;
        V_CZ_RULES(v_cz_rule_count).invalid_flag:=      '0';
	IF p_default_rule THEN
	   V_CZ_RULES(v_cz_rule_count).name:=              'Defaults-' || l_ps_node_name;
        ELSE
	   V_CZ_RULES(v_cz_rule_count).name:=              'Constraint-' || l_ps_node_name;
	END IF;
        V_CZ_RULES(v_cz_rule_count).rule_type:= '200';
        V_CZ_RULES(v_cz_rule_count).reason_type:=       '0'  ;
        V_CZ_RULES(v_cz_rule_count).disabled_flag:=     '0'  ;
        V_CZ_RULES(v_cz_rule_count).deleted_flag:=      '0'  ;
        V_CZ_RULES(v_cz_rule_count).effective_usage_mask:='0000000000000000';
        V_CZ_RULES(v_cz_rule_count).seq_nbr:=           '1';
        V_CZ_RULES(v_cz_rule_count).effective_from:=    cz_utils.epoch_begin;
        V_CZ_RULES(v_cz_rule_count).effective_until:=   cz_utils.epoch_end;
        V_CZ_RULES(v_cz_rule_count).persistent_rule_id:=l_rule_id;
        V_CZ_RULES(v_cz_rule_count).presentation_flag:= '0';
        V_CZ_RULES(v_cz_rule_count).mutable_flag:=      '0';
        V_CZ_RULES(v_cz_rule_count).seeded_flag:=       '0';

    -- INSERTING into  cz_rules -- rule folder entry
    -- Fixing BUG9176281 - Rule name for Default Rule
      INSERT INTO cz_rule_folders(rule_folder_id,   name,   devl_project_id,   tree_seq,   deleted_flag,   folder_type,   effective_usage_mask,   persistent_rule_folder_id,   object_type,   disabled_flag , parent_rule_folder_id)
      VALUES(l_rule_id,   V_CZ_RULES(v_cz_rule_count).name ,   p_devl_project_id,   '1',   '0',   '0',   '0000000000000000',   l_rule_id,   'RUL',   '0' , V_CZ_RULES(v_cz_rule_count).rule_folder_id );

      --populate_cz_tables();  moved prior to inserting data to v_cz_rules

    RETURN l_rule_id;
  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END;


  --Create implies rule for initial values on Boolean features .refer section 4..1.3.3 for Boolean features
  PROCEDURE insertImpliesRuleRecords(dev_project_id IN cz_devl_projects.devl_project_id%TYPE,   ps_node_id IN cz_ps_nodes.ps_node_id%TYPE,
            ps_node_type IN cz_ps_nodes.ps_node_type%TYPE,   l_rule_id IN cz_rules.rule_id%TYPE,   initialvalue IN cz_ps_nodes.initial_value%TYPE) AS
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'insertImpliesRuleRecords';
  l_expression_node_id cz_expression_nodes.expr_node_id%TYPE;
  l_expression_node_id1 cz_expression_nodes.expr_node_id%TYPE;
  l_mod_ref cz_expression_nodes.MODEL_REF_EXPL_ID%TYPE;
  BEGIN

    SELECT cz_expression_nodes_s.nextval
    INTO l_expression_node_id
    FROM dual;
    v_cz_expr_node_count := v_cz_expr_node_count + 1;
    --insert the implies record
    -- INSERTING into cz_expression_nodes
    v_cz_expression_nodes(v_cz_expr_node_count).expr_node_id := l_expression_node_id;
    v_cz_expression_nodes(v_cz_expr_node_count).seq_nbr := 1;
    v_cz_expression_nodes(v_cz_expr_node_count).expr_type := 200;
    v_cz_expression_nodes(v_cz_expr_node_count).token_list_seq := 8;
    v_cz_expression_nodes(v_cz_expr_node_count).rule_id := l_rule_id;
    v_cz_expression_nodes(v_cz_expr_node_count).template_id := 1;
    v_cz_expression_nodes(v_cz_expr_node_count).data_type := 0;
    v_cz_expression_nodes(v_cz_expr_node_count).collection_flag := 0;
    v_cz_expression_nodes(v_cz_expr_node_count).mutable_flag := 0;

--    v_cz_expression_nodes(v_cz_expr_node_count).source_offset := 7;
--    v_cz_expression_nodes(v_cz_expr_node_count).source_length := 7;


    v_cz_expr_node_count := v_cz_expr_node_count + 1;
    --insert initial value record
    SELECT cz_expression_nodes_s.nextval
    INTO l_expression_node_id1
    FROM dual;
    v_cz_expression_nodes(v_cz_expr_node_count).expr_node_id := l_expression_node_id1;
    v_cz_expression_nodes(v_cz_expr_node_count).seq_nbr := 1;
    v_cz_expression_nodes(v_cz_expr_node_count).expr_parent_id := l_expression_node_id;
    v_cz_expression_nodes(v_cz_expr_node_count).data_value := initialvalue;
    v_cz_expression_nodes(v_cz_expr_node_count).expr_type := 201;
    v_cz_expression_nodes(v_cz_expr_node_count).token_list_seq := 7;
    v_cz_expression_nodes(v_cz_expr_node_count).rule_id := l_rule_id;
    v_cz_expression_nodes(v_cz_expr_node_count).param_signature_id := 81;
    v_cz_expression_nodes(v_cz_expr_node_count).param_index := 1;
    v_cz_expression_nodes(v_cz_expr_node_count).data_type := 3;
    v_cz_expression_nodes(v_cz_expr_node_count).mutable_flag := 0;
--    v_cz_expression_nodes(v_cz_expr_node_count).source_offset := 1;
--    v_cz_expression_nodes(v_cz_expr_node_count).source_length := 4;

    v_cz_expr_node_count := v_cz_expr_node_count + 1;
    --insert boolean feature record
    SELECT cz_expression_nodes_s.nextval
    INTO l_expression_node_id1
    FROM dual;
    v_cz_expression_nodes(v_cz_expr_node_count).expr_node_id := l_expression_node_id1;
    v_cz_expression_nodes(v_cz_expr_node_count).seq_nbr := 2;
    v_cz_expression_nodes(v_cz_expr_node_count).ps_node_id := ps_node_id;
    v_cz_expression_nodes(v_cz_expr_node_count).expr_parent_id := l_expression_node_id;
    v_cz_expression_nodes(v_cz_expr_node_count).expr_type := 205;
    v_cz_expression_nodes(v_cz_expr_node_count).token_list_seq := 15;
    v_cz_expression_nodes(v_cz_expr_node_count).rule_id := l_rule_id;
    v_cz_expression_nodes(v_cz_expr_node_count).param_signature_id := 81;
    v_cz_expression_nodes(v_cz_expr_node_count).param_index := 2;
    v_cz_expression_nodes(v_cz_expr_node_count).data_type := 502;
    v_cz_expression_nodes(v_cz_expr_node_count).display_node_depth := 1;
    v_cz_expression_nodes(v_cz_expr_node_count).mutable_flag := '1';
--    v_cz_expression_nodes(v_cz_expr_node_count).source_offset := 15;
--    v_cz_expression_nodes(v_cz_expr_node_count).source_length := 24;

    SELECT MIN(MODEL_REF_EXPL_ID) INTO l_mod_ref FROM cz_model_ref_expls WHERE model_id=dev_project_id AND deleted_flag='0';
    v_cz_expression_nodes(v_cz_expr_node_count).model_ref_expl_id := l_mod_ref;

    --Mark the rule as a default rule
    populate_cz_tables(true);
    UPDATE cz_rules
    SET rule_class = RULE_CLASS_DEFAULT
    WHERE rule_id = l_rule_id;



  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END insertImpliesRuleRecords;


  --Procedure to create the expression tree for a contribute/consume target
  --This procedure adds an ADDTO rule for a contribute/consume rule where the initial value of target is not null

  PROCEDURE createAccumulatorRule(dev_project_id IN cz_devl_projects.devl_project_id%TYPE,   ps_node_id IN cz_ps_nodes.ps_node_id%TYPE,
                              ps_node_type IN cz_ps_nodes.ps_node_type%TYPE,   initialvalue IN cz_ps_nodes.initial_value%TYPE,   minvalue IN cz_ps_nodes.minimum%TYPE,
                              l_rule_id IN cz_rules.rule_id%TYPE  ,p_model_ref_expl_id IN cz_expression_nodes.model_ref_expl_id%TYPE,p_feature_type IN cz_ps_nodes.feature_type%TYPE) AS
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'createAccumulatorRule';
  l_expression_node_id cz_expression_nodes.expr_node_id%TYPE;
  l_expression_node_id1 cz_expression_nodes.expr_node_id%TYPE;
  l_mod_ref  cz_expression_nodes.MODEL_REF_EXPL_ID%type;
  l_ps_node_id cz_ps_nodes.ps_node_id%TYPE;
  BEGIN
    IF initialvalue IS NOT NULL THEN

        --      Insert AddTo  expression record;

        SELECT cz_expression_nodes_s.nextval   INTO l_expression_node_id FROM dual;
        v_cz_expr_node_count:=v_cz_expr_node_count+1;

        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_NODE_ID:=      l_expression_node_id         ;
        v_cz_expression_nodes(v_cz_expr_node_count).SEQ_NBR:=           '1'                          ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_TYPE:=         '200'                        ;
        v_cz_expression_nodes(v_cz_expr_node_count).TOKEN_LIST_SEQ:=    '1'                          ;
        v_cz_expression_nodes(v_cz_expr_node_count).DELETED_FLAG:=      '0'                          ;
        v_cz_expression_nodes(v_cz_expr_node_count).RULE_ID:=           l_rule_id                    ;
        v_cz_expression_nodes(v_cz_expr_node_count).TEMPLATE_ID:=       OPERATOR_ADDSTO              ;
        v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE:=         '0'                          ;
        v_cz_expression_nodes(v_cz_expr_node_count).COLLECTION_FLAG:=   '0'                          ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_OFFSET:=     '1'                          ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_LENGTH:=     '10'                         ;
        v_cz_expression_nodes(v_cz_expr_node_count).MUTABLE_FLAG:=      '0'                          ;
        --      Insert initial value record;


        SELECT cz_expression_nodes_s.nextval   INTO l_expression_node_id1 FROM dual;
        v_cz_expr_node_count:=v_cz_expr_node_count+1;



        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_NODE_ID:=      l_expression_node_id1               ;
        v_cz_expression_nodes(v_cz_expr_node_count).SEQ_NBR:=           '1'                                 ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_PARENT_ID:=    l_expression_node_id                ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_TYPE:=         '201'                               ;
        v_cz_expression_nodes(v_cz_expr_node_count).TOKEN_LIST_SEQ:=    '8'                                 ;
        v_cz_expression_nodes(v_cz_expr_node_count).DELETED_FLAG:=      '0'                                 ;
        v_cz_expression_nodes(v_cz_expr_node_count).RULE_ID:=           l_rule_id                           ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_SIGNATURE_ID:='96'                                ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_INDEX:=       '1'                                 ;

        IF p_feature_type=FEATURE_TYPE_FLOAT THEN
          v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE:=         '2'                                 ;
        ELSE
          v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE:=         '1'                                 ;
        END IF;

--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_OFFSET:=     '13'                                ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_LENGTH:=     '1'                                 ;
        v_cz_expression_nodes(v_cz_expr_node_count).MUTABLE_FLAG:=      '0'                                 ;
        v_cz_expression_nodes(v_cz_expr_node_count).DATA_NUM_VALUE:=    initialvalue                        ;
        --      Insert record for ps_node_id, ps_node_type;

        SELECT cz_expression_nodes_s.nextval   INTO l_expression_node_id1 FROM dual;
        v_cz_expr_node_count:=v_cz_expr_node_count+1;

        IF p_model_ref_expl_id IS NULL THEN
           l_ps_node_id :=ps_node_id;
           SELECT MIN(MODEL_REF_EXPL_ID) INTO l_mod_ref FROM cz_model_ref_expls WHERE model_id=dev_project_id AND deleted_flag='0' AND  component_id=(select component_id from cz_ps_nodes ps where ps.ps_node_id=l_ps_node_id)  ;
        ELSE
           l_mod_ref:=p_model_ref_expl_id;  -- use model_ref_expl_id from parent contribute / consume rule .
        END IF;



        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_NODE_ID:=      l_expression_node_id1     ;
        v_cz_expression_nodes(v_cz_expr_node_count).SEQ_NBR:=           '2'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).PS_NODE_ID:=        ps_node_id                ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_PARENT_ID:=    l_expression_node_id      ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_TYPE:=         '205'                     ;
        v_cz_expression_nodes(v_cz_expr_node_count).TOKEN_LIST_SEQ:=    '9'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).DELETED_FLAG:=      '0'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).MODEL_REF_EXPL_ID:= l_mod_ref                 ;
        v_cz_expression_nodes(v_cz_expr_node_count).RULE_ID:=           l_rule_id                 ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_SIGNATURE_ID:='96'                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_INDEX:=       '2'                       ;

        IF ps_node_type=PS_TYPE_TOTAL THEN
          v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE:=CZ_TYPES.TOTAL_TYPEID;
        ELSIF ps_node_type=PS_TYPE_RESOURCE THEN
          v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE:=CZ_TYPES.RESOURCE_TYPEID;
        ELSIF ps_node_type=PS_TYPE_FEATURE and p_feature_type=FEATURE_TYPE_FLOAT THEN
          v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE:=CZ_TYPES.DECIMAL_FEATURE_TYPEID;
        END IF;

        v_cz_expression_nodes(v_cz_expr_node_count).DISPLAY_NODE_DEPTH:='1'                       ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_OFFSET:=     '18'                      ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_LENGTH:=     '14'                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).MUTABLE_FLAG:=      '1'                       ;


    END IF;
  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END createAccumulatorRule;


  --Procedure to create accumulator rule records for contribute/consume rule initial values
  PROCEDURE createRules(p_devl_project_id IN cz_devl_projects.devl_project_id%TYPE,   p_ps_node_id IN cz_ps_nodes.ps_node_id%TYPE,
                        p_ps_node_type IN cz_ps_nodes.ps_node_type%TYPE,   feature_type IN cz_ps_nodes.feature_type%TYPE,
                        initialvalue IN cz_ps_nodes.initial_value%TYPE,   minvalue IN cz_ps_nodes.maximum%TYPE,   rulefolderid IN cz_rules.rule_folder_id%TYPE,
                        maxvalue IN cz_ps_nodes.maximum%TYPE) AS
  --cursor to find all contribute/consume sources for a given target
  CURSOR c_contrib_consume IS
  SELECT DISTINCT r.devl_project_id,
    e.template_id,
    e1.rule_id,
    r.rule_folder_id,
    ps.name,
    p.name devname,
    r.reason_id,
    e1.model_ref_expl_id
  FROM cz_rules r,
    cz_devl_projects p,
    cz_expression_nodes e,
    cz_expression_nodes e1,
    cz_ps_nodes ps
  WHERE r.deleted_flag = '0'
   AND e.deleted_flag = '0'
   AND e1.deleted_flag = '0'
   AND p.deleted_flag = '0'
   AND p.config_engine_type = 'F'
   AND e.template_id IN(708,   710 ,712 ,714)
   AND e1.ps_node_id = p_ps_node_id
   AND e1.ps_node_id = ps.ps_node_id
   AND e1.rule_id = e.rule_id
   AND r.rule_id = e.rule_id
   AND p.devl_project_id=ps.devl_project_id
   AND p.devl_project_id = p_devl_project_id
   ORDER BY r.devl_project_id , e1.model_ref_expl_id;

  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'createRules';
  l_rule_id cz_rules.rule_id%TYPE;
  l_rulefolderid cz_rules.rule_folder_id%TYPE;
  l_rule_class cz_rules.rule_class%TYPE;
  l_ps_node_name cz_ps_nodes.name%type;
  l_previous_devl_project_id cz_devl_projects.devl_project_id%type;
  l_has_mult_down_cont_cons boolean;

  l_devl_project_id cz_devl_projects.devl_project_id%type;
  l_model_ref_expl_id cz_expression_nodes.model_ref_expl_id%type;


  ACC_RULE_CREATED boolean;


  BEGIN

      ACC_RULE_CREATED:=FALSE;
      l_has_mult_down_cont_cons :=FALSE;

      FOR v_contribute_consume IN c_contrib_consume
      LOOP
        displayMessage(3,p_devl_project_id , 'RULE' ,v_contribute_consume.rule_id,l_api_name,'CZ_CNV_CONT_CONS_TO_ADD_SUB');
        IF v_contribute_consume.template_id IN (708,710) THEN
                Update cz_expression_nodes set template_id=decode(template_id,708 , OPERATOR_ADDSTO  , 710 , OPERATOR_SUBTRACTSFROM) where rule_id=v_contribute_consume.rule_id and template_id in (708,710);
                Update cz_expression_nodes set template_id=25 where rule_id=v_contribute_consume.rule_id and template_id =22;
                cz_rule_text_gen.parse_rules(v_contribute_consume.devl_project_id,   v_contribute_consume.rule_id);
        END IF;
        IF(initialvalue IS NOT NULL
         AND(p_ps_node_type IN(PS_TYPE_TOTAL,   PS_TYPE_RESOURCE) OR(p_ps_node_type = PS_TYPE_FEATURE
         AND feature_type IN(FEATURE_TYPE_INTEGER ,   FEATURE_TYPE_FLOAT)))) THEN
          IF v_contribute_consume.devl_project_id = p_devl_project_id THEN
           ACC_RULE_CREATED:=TRUE;
          END IF;

          IF ((l_devl_project_id IS NULL AND l_model_ref_expl_id IS NULL )
             OR ( l_devl_project_id<> v_contribute_consume.devl_project_id AND l_model_ref_expl_id <> v_contribute_consume.model_ref_expl_id ) )THEN

                  -- Total/resource/Num feature
                  --Create a new Rule Folder in model dev_project_id and get its id in l_rulefolderID
                  l_rulefolderid := findOrCreateRuleFolder(v_contribute_consume.devl_project_id);

                  --Create a new rule record in cz_rules in folder specified by l_rulefolderID with Name "Constraint-<<ps_node name>>" get its value in l_rule_id
                  l_rule_id := createConstraintRuleRecord(l_rulefolderid,   p_ps_node_id,   v_contribute_consume.devl_project_id);

                  l_rule_class := RULE_CLASS_CONSTRAINT;
                  -- create one additional Accumulator Rule to add the initial value to the target
                  createAccumulatorRule(v_contribute_consume.devl_project_id,   p_ps_node_id,   p_ps_node_type,   initialvalue,   minvalue,   l_rule_id , v_contribute_consume.model_ref_expl_id,feature_type);
                  IF v_contribute_consume.devl_project_id = p_devl_project_id THEN
                    displayMessage(4,p_devl_project_id , 'NODE' ,p_ps_node_id,l_api_name,'CZ_CNV_INFO_ACC_INIT_VAL' , 'RULENAME', 'Constraint-'||v_contribute_consume.name );
                  ELSE
                    displayMessage(3,p_devl_project_id , 'NODE',p_ps_node_id,l_api_name,'CZ_CNV_ADV_ACC_DESC_INIT_VAL','NODENAME',v_contribute_consume.name,'MODELNAME',v_contribute_consume.devname,'RULENAME','Constraint-'||v_contribute_consume.name);
                  END IF;

                  l_devl_project_id:= v_contribute_consume.devl_project_id;
                  l_model_ref_expl_id:= v_contribute_consume.model_ref_expl_id;
          END IF;

        END IF;

        UPDATE cz_localized_texts SET deleted_flag =1 WHERE intl_text_id=v_contribute_consume.reason_id;
        UPDATE cz_rules SET reason_id=null WHERE rule_id=v_contribute_consume.rule_id;


        IF(l_previous_devl_project_id IS NULL) THEN
          l_previous_devl_project_id := v_contribute_consume.devl_project_id;
        ELSE IF (l_previous_devl_project_id<> v_contribute_consume.devl_project_id) THEN
               l_has_mult_down_cont_cons :=TRUE;
             END IF;
        END IF;

      END LOOP;

      IF (l_has_mult_down_cont_cons ) THEN
        displayMessage(2,p_devl_project_id , 'NODE' ,p_ps_node_id,l_api_name,'CZ_CNV_WARN_NUM_INIT_DOWN_SUM');
      END IF;


-- Create accumulator rules for initial values
    IF initialvalue IS NOT NULL  AND NOT ACC_RULE_CREATED THEN
      IF(p_ps_node_type = PS_TYPE_FEATURE
       AND feature_type IN(FEATURE_TYPE_INTEGER ,   FEATURE_TYPE_FLOAT)) OR p_ps_node_type = PS_TYPE_TOTAL OR p_ps_node_type = PS_TYPE_RESOURCE THEN
          -- Total/resource/Num feature
            --Create a new Rule Folder in model dev_project_id and get its id in l_rulefolderID
            l_rulefolderid := findOrCreateRuleFolder(p_devl_project_id);
          --Create a new rule record in cz_rules in folder specified by l_rulefolderID with Name "Constraint-<<ps_node name>>" get its value in l_rule_id
          l_rule_id := createConstraintRuleRecord(l_rulefolderid,   p_ps_node_id,   p_devl_project_id);
          l_rule_class := RULE_CLASS_CONSTRAINT;
          --defaults
          -- create one additional Accumulator Rule to add the initial value to the target
          createAccumulatorRule(p_devl_project_id,   p_ps_node_id,   p_ps_node_type,   initialvalue,   minvalue,   l_rule_id , null, feature_type);
          select name into l_ps_node_name from cz_ps_nodes where ps_node_id =p_ps_node_id;
          displayMessage(4,p_devl_project_id , 'NODE' ,p_ps_node_id,l_api_name,'CZ_CNV_INFO_ACC_INIT_VAL' , 'RULENAME', 'Constraint-'||l_ps_node_name );
        END IF;
    END IF;

    IF initialvalue IS NOT NULL THEN
      IF(p_ps_node_type = PS_TYPE_FEATURE
       AND feature_type = FEATURE_TYPE_BOOLEAN) THEN
        -- Boolean
        --Create a new Rule Folder in model dev_project_id and get its id in l_rulefolderID
         l_rulefolderid := findOrCreateRuleFolder(p_devl_project_id);
        --Create a new rule record in cz_rules in folder specified by rulefolderID with Name "Constraint-<<ps_node name>>" get its value in l_rule_id
         l_rule_id := createConstraintRuleRecord(l_rulefolderid,   p_ps_node_id,   p_devl_project_id, true );


        --refer section 4..1.3.3 for Boolean features
        insertImpliesRuleRecords(p_devl_project_id,   p_ps_node_id,   p_ps_node_type,   l_rule_id,   initialvalue );
        IF initialvalue IS NOT NULL THEN
          select name into l_ps_node_name from cz_ps_nodes where ps_node_id =p_ps_node_id;
          displayMessage(4,p_devl_project_id , 'NODE' ,p_ps_node_id,l_api_name,'CZ_CNV_INFO_BOOL_INIT_VAL','RULENAME' , 'Constraint-'||l_ps_node_name );
        END IF;
      END IF;
    END IF;
  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END createRules;


  --  procedure to remove initial values from nodes
  PROCEDURE clearinitialvalues(p_dev_project_id IN cz_devl_projects.devl_project_id%TYPE) AS
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'ClearInitialValues';
  BEGIN
    UPDATE cz_ps_nodes
    SET initial_num_value = NULL
    WHERE devl_project_id = p_dev_project_id
     AND initial_num_value IS NOT NULL
     AND(ps_node_type IN(PS_TYPE_TOTAL,   PS_TYPE_RESOURCE)
     OR(ps_node_type = PS_TYPE_FEATURE  AND feature_type IN(FEATURE_TYPE_INTEGER ,   FEATURE_TYPE_FLOAT))
     OR(ps_node_type = PS_TYPE_FEATURE  AND feature_type = FEATURE_TYPE_BOOLEAN));
  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END clearinitialvalues;



  --procedure to fill in min/max domain range values per type where no value has been defined by the modeler
  --Reference TD section 4.1.3.2
  PROCEDURE assignDefaultMinMaxvalues(p_dev_project_id IN cz_devl_projects.devl_project_id%TYPE) AS
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'assignDefaultMinMaxvalues';
  BEGIN
    FOR c_processing IN
      (SELECT ps_node_id , feature_type
       FROM cz_ps_nodes
       WHERE devl_project_id = p_dev_project_id
       AND minimum IS NULL
       AND(ps_node_type = PS_TYPE_FEATURE
       AND feature_type IN(FEATURE_TYPE_INTEGER ,   FEATURE_TYPE_FLOAT)))
    LOOP
      IF c_processing.feature_type=   FEATURE_TYPE_INTEGER     THEN
              displayMessage(3,p_dev_project_id , 'NODE' , c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_VAL_MIN_BOUND','MINVAL', INTEGER_MIN_VAL);
      ELSE IF  c_processing.feature_type=   FEATURE_TYPE_FLOAT THEN
              displayMessage(3,p_dev_project_id , 'NODE' ,c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_VAL_MIN_BOUND','MINVAL', -SOLVER_MAX_DOUBLE);
           END IF;
      END IF;
    END LOOP;
    UPDATE cz_ps_nodes
    SET minimum = decode(feature_type,  FEATURE_TYPE_INTEGER,   INTEGER_MIN_VAL,   FEATURE_TYPE_FLOAT,   -SOLVER_MAX_DOUBLE)
    WHERE devl_project_id = p_dev_project_id
     AND minimum IS NULL
     AND(ps_node_type = PS_TYPE_FEATURE
     AND feature_type IN(FEATURE_TYPE_INTEGER , FEATURE_TYPE_FLOAT));


--

    FOR c_processing IN
      (SELECT ps_node_id
       FROM cz_ps_nodes
       WHERE devl_project_id = p_dev_project_id
             AND ps_node_type = PS_TYPE_FEATURE
             AND feature_type=FEATURE_TYPE_LIST_OF_OPTIONS
             AND counted_options_flag='1')
    LOOP
      displayMessage(3,p_dev_project_id , 'NODE' , c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_OPT_QTY_MAX','MAXVAL', INTEGER_MAX_VALUE);
    END LOOP;

    UPDATE cz_ps_nodes
    SET MAX_QTY_PER_OPTION = fnd_profile.value('CZ_DEFAULT_MAX_QTY_INT')
    WHERE devl_project_id = p_dev_project_id
          AND ps_node_type = PS_TYPE_FEATURE
          AND feature_type=FEATURE_TYPE_LIST_OF_OPTIONS
          AND counted_options_flag='1';

--

    FOR c_processing IN
      (SELECT ps_node_id, feature_type
       FROM cz_ps_nodes
       WHERE devl_project_id = p_dev_project_id
       AND maximum IS NULL
       AND(ps_node_type = PS_TYPE_FEATURE
       AND feature_type IN(FEATURE_TYPE_INTEGER , FEATURE_TYPE_FLOAT , FEATURE_TYPE_LIST_OF_OPTIONS)))
    LOOP

      IF c_processing.feature_type=   FEATURE_TYPE_INTEGER  OR c_processing.feature_type=FEATURE_TYPE_LIST_OF_OPTIONS  THEN
              displayMessage(3,p_dev_project_id , 'NODE' ,c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_VAL_MAX_BOUND','MAXVAL', INTEGER_MAX_VALUE);
      ELSE IF  c_processing.feature_type=   FEATURE_TYPE_FLOAT THEN
              displayMessage(3,p_dev_project_id , 'NODE' ,c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_VAL_MAX_BOUND','MAXVAL', SOLVER_MAX_DOUBLE);
           END IF;
      END IF;
    END LOOP;
    UPDATE cz_ps_nodes
    SET maximum = decode(feature_type,   FEATURE_TYPE_INTEGER,   INTEGER_MAX_VALUE, FEATURE_TYPE_LIST_OF_OPTIONS,  INTEGER_MAX_VALUE, FEATURE_TYPE_FLOAT,   SOLVER_MAX_DOUBLE)
    WHERE devl_project_id = p_dev_project_id
     AND maximum IS NULL
     AND(ps_node_type = PS_TYPE_FEATURE
     AND feature_type IN(FEATURE_TYPE_INTEGER , FEATURE_TYPE_FLOAT));

--
    FOR c_processing IN
      (SELECT ps_node_id ,decimal_qty_flag , decode(USE_BOM_DEFAULT_QTY,'TRUE',initial_num_value,decode(decimal_qty_flag,   1,   SOLVER_MAX_DOUBLE,   INTEGER_MAX_VALUE)) changedValue
       FROM cz_ps_nodes
       WHERE devl_project_id = p_dev_project_id
       AND ((maximum IS NULL OR maximum =-1)
       AND(ps_node_type IN(PS_TYPE_BOM_MODEL,    PS_TYPE_BOM_OPTION_CLASS,    PS_TYPE_BOM_STD_ITEM)))
       )
    LOOP
      displayMessage(3,p_dev_project_id , 'NODE' ,c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_QTY_MAX_BOUND','MAXVAL', c_processing.changedValue);
    END LOOP;

    UPDATE cz_ps_nodes
    SET maximum = decode(USE_BOM_DEFAULT_QTY,'TRUE',initial_num_value,decode(decimal_qty_flag,   1,   SOLVER_MAX_DOUBLE,   INTEGER_MAX_VALUE))
    WHERE devl_project_id = p_dev_project_id
     AND (maximum IS NULL OR maximum =-1)
     AND(ps_node_type IN(PS_TYPE_BOM_MODEL,   PS_TYPE_BOM_OPTION_CLASS,   PS_TYPE_BOM_STD_ITEM));

--- BUG 9467823 - Set maximum on non bom models - this is needed if MAX is not defined for the instantiable non-bom model
    FOR c_processing IN
      (SELECT ps_node_id ,decimal_qty_flag , INTEGER_MAX_VALUE changedValue
       FROM cz_ps_nodes
       WHERE devl_project_id = p_dev_project_id
       AND ((maximum IS NULL OR maximum =-1)
       AND instantiable_flag = NODE_INSTANTIABILITY_MULTIPLE
       AND (ps_node_type = PS_TYPE_REFERENCE OR ps_node_type = PS_TYPE_COMPONENT)
       AND item_id is null)
       )
    LOOP
      displayMessage(3,p_dev_project_id , 'NODE' ,c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_QTY_MAX_BOUND','MAXVAL', c_processing.changedValue);
    END LOOP;

    UPDATE cz_ps_nodes
    SET maximum = INTEGER_MAX_VALUE
    WHERE devl_project_id = p_dev_project_id
     AND (maximum IS NULL OR maximum =-1)
     AND instantiable_flag = NODE_INSTANTIABILITY_MULTIPLE
     AND (ps_node_type = PS_TYPE_REFERENCE OR ps_node_type = PS_TYPE_COMPONENT)
     AND item_id is null;

---Changed for bug 6737779

    UPDATE cz_ps_nodes
    SET minimum = decode(USE_BOM_DEFAULT_QTY,'TRUE',initial_num_value,decode(decimal_qty_flag, 1,0 ,1 ))
    WHERE devl_project_id = p_dev_project_id
     AND (minimum IS NULL OR minimum =0)
     AND(ps_node_type IN(PS_TYPE_BOM_MODEL,   PS_TYPE_BOM_OPTION_CLASS,   PS_TYPE_BOM_STD_ITEM))
    RETURNING ps_node_id , minimum  BULK COLLECT INTO v_cz_ids_tbl , v_cz_num_tbl;


    IF v_cz_ids_tbl.COUNT > 0 THEN
      FOR i IN v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
      LOOP
         displayMessage(3,p_dev_project_id , 'NODE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_ADV_QTY_MIN_BOUND','MINVAL', v_cz_num_tbl(i));
      END LOOP;
      v_cz_ids_tbl.DELETE;
      v_cz_num_tbl.DELETE;
    END IF;

    UPDATE cz_ps_nodes psout
    SET minimum_selected = decode(USE_BOM_DEFAULT_QTY,'TRUE',initial_num_value,decode(decimal_qty_flag, 1,0,1 ))
    WHERE devl_project_id = p_dev_project_id
     AND (minimum_selected IS NULL OR minimum_selected =0)
     AND(ps_node_type =PS_TYPE_REFERENCE)
     AND EXISTS( SELECT 1 FROM cz_ps_nodes WHERE ps_node_id= psout.component_id
                 AND ps_node_type =PS_TYPE_BOM_MODEL )
    RETURNING ps_node_id , minimum_selected  BULK COLLECT INTO v_cz_ids_tbl , v_cz_num_tbl;


    IF v_cz_ids_tbl.COUNT > 0 THEN
      FOR i IN v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
      LOOP
         displayMessage(3,p_dev_project_id , 'NODE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_ADV_QTY_MIN_BOUND','MINVAL', v_cz_num_tbl(i));
      END LOOP;
      v_cz_ids_tbl.DELETE;
      v_cz_num_tbl.DELETE;
    END IF;


--

    FOR c_processing in (   SELECT ps_node_id ,decimal_qty_flag , initial_num_value , decode(USE_BOM_DEFAULT_QTY,'TRUE',initial_num_value,decode(decimal_qty_flag,   1,   SOLVER_MAX_DOUBLE,   INTEGER_MAX_VALUE)) changedValue FROM cz_ps_nodes
                                WHERE devl_project_id = p_dev_project_id
                                AND (maximum_selected IS NULL OR maximum_selected =-1)
                                AND(ps_node_type =PS_TYPE_REFERENCE)
                                and item_id is not null
    )LOOP

              displayMessage(3,p_dev_project_id , 'NODE' ,c_processing.ps_node_id,l_api_name,'CZ_CNV_ADV_QTY_MAX_BOUND','MAXVAL', c_processing.changedValue);
    END LOOP;

    UPDATE cz_ps_nodes
    SET maximum_selected = decode(USE_BOM_DEFAULT_QTY,'TRUE',initial_num_value,decode(decimal_qty_flag,   1,   SOLVER_MAX_DOUBLE,  INTEGER_MAX_VALUE))
    WHERE devl_project_id = p_dev_project_id
     AND (maximum_selected IS NULL OR maximum_selected =-1)
     AND(ps_node_type =PS_TYPE_REFERENCE)
     and item_id is not null ;



---


    UPDATE cz_ps_nodes
    SET maximum = INTEGER_MAX_VALUE
    WHERE devl_project_id = p_dev_project_id
     AND maximum IS NULL
     AND(ps_node_type IN(232))
     RETURNING ps_node_id BULK COLLECT INTO v_cz_ids_tbl;

    IF v_cz_ids_tbl.COUNT>0 THEN
     FOR i IN v_cz_ids_tbl.FIRST.. v_cz_ids_tbl.LAST
     LOOP
       displayMessage(3,p_dev_project_id , 'NODE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_ADV_OPT_QTY_MAX','MAXVAL', INTEGER_MAX_VALUE );
     END LOOP;
     v_cz_ids_tbl.DELETE;
    END IF;



----- Update default maximum values for total and resource .

    UPDATE cz_ps_nodes
    SET maximum =  DECODE(SIGN(nvl(initial_num_value,0) - SOLVER_MAX_DOUBLE), -1 , SOLVER_MAX_DOUBLE, 0 , SOLVER_MAX_DOUBLE , 1 , initial_num_value)
    WHERE devl_project_id = p_dev_project_id
     AND maximum IS NULL
     AND ps_node_type IN(PS_TYPE_TOTAL,PS_TYPE_RESOURCE)
     RETURNING ps_node_id , maximum  BULK COLLECT INTO v_cz_ids_tbl , v_cz_num_tbl;

    IF v_cz_ids_tbl.COUNT > 0 THEN
      FOR i IN v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
      LOOP
              displayMessage(3,p_dev_project_id , 'NODE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_ADV_VAL_MAX_BOUND','MAXVAL', v_cz_num_tbl(i));
      END LOOP;
      v_cz_ids_tbl.DELETE;
      v_cz_num_tbl.DELETE;
    END IF;

----

    UPDATE cz_ps_nodes
    SET minimum = -SOLVER_MAX_DOUBLE
    WHERE devl_project_id = p_dev_project_id
     AND minimum IS NULL
     AND ps_node_type IN(PS_TYPE_TOTAL,PS_TYPE_RESOURCE)
     RETURNING ps_node_id BULK COLLECT INTO v_cz_ids_tbl;

    IF v_cz_ids_tbl.COUNT>0 THEN
      FOR i IN v_cz_ids_tbl.FIRST..v_cz_ids_tbl.LAST
      LOOP
              displayMessage(3,p_dev_project_id , 'NODE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_ADV_VAL_MIN_BOUND','MINVAL', -SOLVER_MAX_DOUBLE);
      END LOOP;
      v_cz_ids_tbl.DELETE;
    END IF;



  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END assignDefaultMinMaxvalues;


  --procedure to convert existing rules to those suitable for the FCE
  --Refer section 4.1.4 rule requirements
  PROCEDURE convertRules(p_dev_project_id IN cz_devl_projects.devl_project_id%TYPE,   p_rulefolderid IN cz_rules.rule_folder_id%TYPE) AS

  -- cursor to fetch ATAN2 rules which will be converted into ATAN
  CURSOR c_atan IS
  SELECT ex.*
  FROM cz_expression_nodes ex,
    cz_rules ru
  WHERE ru.devl_project_id = p_dev_project_id
   AND ru.rule_id = ex.rule_id
   AND ru.deleted_flag ='0'
   AND ex.template_id = 430
   AND ex.deleted_flag ='0';

  -- cursor to fetch data from rules having a numeric participant in a logic rule for a given devl_project_id
  CURSOR c_numeric_participant IS
  SELECT exp1.expr_node_id exp1id,
    exp2.expr_node_id exp2id,
    exp2.expr_parent_id exp2parentid,
    exp2.rule_id , psnode.ps_node_id
  FROM cz_expression_nodes exp1,
    cz_expression_nodes exp2,
    cz_ps_nodes psnode
  WHERE exp1.deleted_flag ='0'
   AND exp2.deleted_flag ='0'
   AND exp1.template_id IN(1,   2,   3,   4,   5)
   AND exp2.ps_node_id = psnode.ps_node_id
   AND exp1.rule_id = exp2.rule_id
   AND psnode.ps_node_type = PS_TYPE_FEATURE
   AND psnode.feature_type = FEATURE_TYPE_INTEGER
   AND psnode.minimum >= 0
   AND psnode.devl_project_id = p_dev_project_id
   AND exists (select 1 from cz_expression_nodes where
                expr_node_id=exp2.expr_parent_id
                and template_id in ( 306 ,307 ,360 ,552 ,21 )  -- All Logic operators
               );

  --cursor to fetch compatibility rule where more than one participant feature has a maximum number of selections greater than 1
  CURSOR c_compat IS
  SELECT DISTINCT cz_rules.rule_id,
    cz_rules.devl_project_id
  FROM cz_rules,
    cz_expression_nodes exp1,
    cz_expression_nodes exp2,
    cz_expression_nodes exp3
  WHERE rule_type IN(RULE_TYPE_COMPAT_TABLE,   RULE_TYPE_DESIGN_CHART_RULE,   RULE_TEMPLATE_FREEFORM_RULE)
   AND exp1.rule_id = exp2.rule_id
   AND exp1.rule_id = exp3.rule_id
   AND exp3.template_id = 23
   AND exp1.rule_id = cz_rules.rule_id
   AND exp1.expr_type = 207
   AND exp2.expr_type = 207
   AND exp1.expr_node_id <> exp2.expr_node_id
   AND EXISTS
    (SELECT 1
     FROM cz_expression_nodes expin1,
       cz_expression_nodes expin2,
       cz_ps_nodes ps1,
       cz_ps_nodes ps2
     WHERE expin1.expr_node_id = exp1.expr_parent_id
     AND expin2.expr_node_id = exp2.expr_parent_id
     AND expin2.ps_node_id = ps2.ps_node_id
     AND expin1.ps_node_id = ps1.ps_node_id
     AND ((ps1.maximum_selected > 1
          AND ps2.maximum_selected > 1
          )
          OR
          (ps1.maximum > 1
           AND ps2.maximum > 1
          )
         )
     )
  AND cz_rules.devl_project_id = p_dev_project_id
  UNION ALL
  SELECT DISTINCT  cf.rule_id ,ps.devl_project_id
  FROM cz_des_chart_features cf,
    cz_des_chart_features cf1,
    cz_ps_nodes ps,
    cz_ps_nodes ps1,
    cz_rules rule
  WHERE cf.rule_id = cf1.rule_id
   AND cf.feature_id = ps.ps_node_id
   AND cf1.feature_id = ps1.ps_node_id
   AND cf1.feature_id <> cf.feature_id
   AND ((ps.maximum_selected > 1
        AND ps1.maximum_selected > 1
        )
        OR
          (ps.maximum > 1
           AND ps1.maximum > 1
          )
        )
   AND rule.devl_project_id = p_dev_project_id
   AND rule.rule_id = cf.rule_id
   AND rule_type IN(24,   30);


  --cursor to fetch compatibility rule where one participant is a BOM Node
  CURSOR c_bom_compat IS
  SELECT DISTINCT cz_rules.rule_id,
    cz_rules.devl_project_id
  FROM cz_rules,
    cz_expression_nodes exp1,
    cz_expression_nodes exp2,
    cz_expression_nodes exp3
  WHERE rule_type IN(RULE_TYPE_COMPAT_TABLE,   RULE_TYPE_DESIGN_CHART_RULE,   RULE_TEMPLATE_FREEFORM_RULE)
   AND exp1.rule_id = exp2.rule_id
   AND exp1.rule_id = exp3.rule_id
   AND exp3.template_id = 23
   AND exp1.rule_id = cz_rules.rule_id
   AND exp1.expr_type = 207
   AND exp2.expr_type = 207
   AND exp1.expr_node_id <> exp2.expr_node_id
   AND EXISTS
    (SELECT 1
     FROM cz_expression_nodes expin1,
       cz_expression_nodes expin2,
       cz_ps_nodes ps1,
       cz_ps_nodes ps2
     WHERE expin1.expr_node_id = exp1.expr_parent_id
     AND expin2.expr_node_id = exp2.expr_parent_id
     AND expin2.ps_node_id = ps2.ps_node_id
     AND expin1.ps_node_id = ps1.ps_node_id
     AND (ps1.ps_node_type =PS_TYPE_BOM_MODEL
          OR ps2.ps_node_type =PS_TYPE_BOM_MODEL)
     )
  AND cz_rules.devl_project_id = p_dev_project_id
  UNION ALL
  SELECT DISTINCT cf.rule_id ,ps.devl_project_id
  FROM cz_des_chart_features cf,
    cz_des_chart_features cf1,
    cz_ps_nodes ps,
    cz_ps_nodes ps1,
    cz_rules rule
  WHERE cf.rule_id = cf1.rule_id
   AND cf.feature_id = ps.ps_node_id
   AND cf1.feature_id = ps1.ps_node_id
   AND cf1.feature_id <> cf.feature_id
   AND (ps.ps_node_type =PS_TYPE_BOM_MODEL  OR ps1.ps_node_type =PS_TYPE_BOM_MODEL  )
   AND rule.devl_project_id = p_dev_project_id
   AND rule.rule_id = cf.rule_id
   AND rule_type IN(24,30);

  l_atan c_atan % rowtype;
  l_expression_node_id cz_expression_nodes.expr_node_id%TYPE;
  l_api_name constant VARCHAR2(30) := 'convertRules';
  l_numeric_participant c_numeric_participant%rowtype;
  minseq  NUMBER;
  maxseq  NUMBER;
  l_expression_node_id1 cz_expression_nodes.expr_node_id%TYPE;
  l_ps_node_name cz_ps_nodes.name%type;
  l_msg VARCHAR2(2000);
  l_cz_rules_id cz_rules.rule_id%TYPE;
  BEGIN

    --Bug 6725690 , convert ZDIV operator to divide (/) operator.

    UPDATE cz_expression_nodes
    SET template_id = 408
    WHERE template_id = 404
     AND rule_id IN
      (SELECT rule_id
       FROM cz_rules
       WHERE devl_project_id = p_dev_project_id
       AND deleted_flag ='0')
    AND deleted_flag ='0'
    RETURNING rule_id BULK COLLECT INTO v_cz_ids_tbl;

    IF v_cz_ids_tbl.COUNT>0 THEN
      FOR i IN v_cz_ids_tbl.FIRST ..v_cz_ids_tbl.LAST
      LOOP
        cz_rule_text_gen.parse_rules(p_dev_project_id,   v_cz_ids_tbl(i));
      END LOOP;
      v_cz_ids_tbl.DELETE;
    END IF;


    -- DEFAULTS rules will be converted into IMPLIES, with default rule type indicator
    --Refer section 4.1.4.1.

    UPDATE cz_expression_nodes
    SET template_id = 2
    WHERE template_id = 5
     AND rule_id IN
      (SELECT rule_id
       FROM cz_rules
       WHERE devl_project_id = p_dev_project_id
       AND deleted_flag ='0')
    AND deleted_flag ='0'
    RETURNING rule_id BULK COLLECT INTO v_cz_ids_tbl;



    FORALL l_cz_rules_id IN v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
       UPDATE cz_rules SET RULE_CLASS=RULE_CLASS_DEFAULT
       WHERE rule_id=v_cz_ids_tbl(l_cz_rules_id) ;


    IF v_cz_ids_tbl.COUNT>0 THEN
      FOR i IN v_cz_ids_tbl.FIRST ..v_cz_ids_tbl.LAST
      LOOP
        --change defaults to implies
        displayMessage(2,p_dev_project_id , 'RULE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_WARN_DEFAULTS');
        --Call procedure to generate rule text from the expression tree
        populate_cz_tables(true);
        cz_rule_text_gen.parse_rules(p_dev_project_id,   v_cz_ids_tbl(i));
      END LOOP;
      v_cz_ids_tbl.DELETE;
    END IF;



---


    -- NotTrue rules will be converted into NOT.
    --Refer section 4.1.4.2

    UPDATE cz_expression_nodes
    SET template_id = 552
    WHERE template_id = 360
     AND rule_id IN
      (SELECT rule_id
       FROM cz_rules
       WHERE devl_project_id = p_dev_project_id
       AND deleted_flag ='0')
    AND deleted_flag ='0'
    RETURNING rule_id BULK COLLECT INTO v_cz_ids_tbl;

    IF v_cz_ids_tbl.COUNT>0 THEN
      FOR i IN v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
      LOOP
        --change template_id from 360 to 552
        displayMessage(2,p_dev_project_id , 'RULE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_WARN_NOTTRUE');
        populate_cz_tables(true);
        cz_rule_text_gen.parse_rules(p_dev_project_id,   v_cz_ids_tbl(i));
      END LOOP;
      v_cz_ids_tbl.DELETE;
    END IF;



    -- ATAN2 rules will be converted into ATAN.
    --Refer section 4.1.4.3
    FOR l_atan IN c_atan
    LOOP
      SELECT cz_expression_nodes_s.nextval
      INTO l_expression_node_id
      FROM dual;
      --Insert new ATAN record

        v_cz_expr_node_count:=v_cz_expr_node_count+1;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_NODE_ID:=      l_expression_node_id      ;
        v_cz_expression_nodes(v_cz_expr_node_count).SEQ_NBR:=           '1'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_PARENT_ID:=    l_atan.expr_parent_id     ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_TYPE:=         '200'                     ;
        v_cz_expression_nodes(v_cz_expr_node_count).TOKEN_LIST_SEQ:=    '8'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).RULE_ID:=           l_atan.rule_id            ;
        v_cz_expression_nodes(v_cz_expr_node_count).TEMPLATE_ID:=       '438'                     ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_SIGNATURE_ID:='91'                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_INDEX:=       '1'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE:=         '2'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).COLLECTION_FLAG:=   '0'                       ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_OFFSET:=     '12'                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_LENGTH:=     '4'                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).MUTABLE_FLAG:=      '0'                       ;


      --update Atan2 to DIV record
      UPDATE cz_expression_nodes
      SET template_id = 408,
        expr_parent_id = l_expression_node_id
      WHERE expr_node_id = l_atan.expr_node_id;
      displayMessage(2,p_dev_project_id , 'RULE' ,l_atan.rule_id,l_api_name,'CZ_CNV_WARN_ATAN2_REMOVED');
      populate_cz_tables(true);
      cz_rule_text_gen.parse_rules(p_dev_project_id,   l_atan.rule_id);
    END LOOP;
    --
    -- Logic rules may only contain logical expressions as participants.
    --Any numeric participants in existing logic rules will be mapped to "expr > 0".
    --Refer section 4.1.4.6

    ---make this logic rule a statement rule
      UPDATE CZ_RULES set presentation_flag=0 where rule_id in
      (SELECT exp2.rule_id
          FROM cz_expression_nodes exp1,
            cz_expression_nodes exp2,
            cz_ps_nodes psnode
          WHERE exp1.deleted_flag ='0'
           AND exp2.deleted_flag ='0'
           AND exp1.template_id IN(1,   2,   3,   4,   5)
           AND exp2.ps_node_id = psnode.ps_node_id
           AND exp1.rule_id = exp2.rule_id
           AND psnode.ps_node_type = PS_TYPE_FEATURE
           AND psnode.feature_type = FEATURE_TYPE_INTEGER
           AND psnode.minimum >= 0
           AND psnode.devl_project_id = p_dev_project_id);



    FOR l_numeric_participant IN c_numeric_participant
    LOOP


        FOR c_cur IN (select 1 from cz_expression_nodes czr where czr.rule_id=l_numeric_participant.rule_id and czr.template_id=21) --Just to check that this is logic rule , will loop only once
        LOOP

        --make this as a statement rule

        update cz_expression_nodes set expr_type=200 where expr_type=222 and rule_id=l_numeric_participant.rule_id;


        select min(seq_nbr) ,max(seq_nbr) into minseq, maxseq from cz_expression_nodes where rule_id= l_numeric_participant.rule_id  and template_id in (306,307);
        update cz_expression_nodes set expr_parent_id=(select expr_node_id from cz_expression_nodes where rule_id= l_numeric_participant.rule_id and seq_nbr=minseq and template_id in (306,307))
                                   where rule_id= l_numeric_participant.rule_id and seq_nbr between minseq+1 and maxseq-2 ;

        update cz_expression_nodes set expr_parent_id=(select expr_node_id from cz_expression_nodes where rule_id= l_numeric_participant.rule_id and seq_nbr=maxseq and template_id in (306,307))
                                   where rule_id= l_numeric_participant.rule_id and  seq_nbr >maxseq;


        update cz_expression_nodes set expr_parent_id=(select expr_node_id from cz_expression_nodes where rule_id= l_numeric_participant.rule_id and seq_nbr=maxseq-1 and template_id IN(1,   2,   3,   4,   5))
        where rule_id= l_numeric_participant.rule_id and  seq_nbr in (minseq,maxseq);

        update cz_expression_nodes set expr_parent_id=null , seq_nbr=1 where expr_node_id=l_numeric_participant.exp1id;
        END LOOP;

    END LOOP;



    FOR l_numeric_participant IN c_numeric_participant
    LOOP
      SELECT cz_expression_nodes_s.nextval
      INTO l_expression_node_id
      FROM dual;
      --   > record

        v_cz_expr_node_count:=v_cz_expr_node_count+1;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_NODE_ID        :=l_expression_node_id                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).SEQ_NBR             :='1'                                        ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_PARENT_ID      :=l_numeric_participant.exp2parentid         ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_TYPE           :='200'                                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).TOKEN_LIST_SEQ      :='10'                                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).RULE_ID             :=l_numeric_participant.rule_id              ;
        v_cz_expression_nodes(v_cz_expr_node_count).TEMPLATE_ID         :='350'                                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_SIGNATURE_ID  :='81'                                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_INDEX         :='1'                                        ;
        v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE           :='3'                                        ;
        v_cz_expression_nodes(v_cz_expr_node_count).COLLECTION_FLAG     :='0'                                        ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_OFFSET       :='4'                                        ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_LENGTH       :='38'                                       ;
        v_cz_expression_nodes(v_cz_expr_node_count).MUTABLE_FLAG        :='0'                                        ;




      UPDATE cz_expression_nodes
      SET expr_parent_id = l_expression_node_id,
        seq_nbr = 1
      WHERE expr_node_id = l_numeric_participant.exp2id;
      -- make count feature child of >
      SELECT cz_expression_nodes_s.nextval
      INTO l_expression_node_id1
      FROM dual;
      -- insert 0 record

        v_cz_expr_node_count:=v_cz_expr_node_count+1;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_NODE_ID        :=l_expression_node_id1                    ;
        v_cz_expression_nodes(v_cz_expr_node_count).SEQ_NBR             :='2'                                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_PARENT_ID      :=l_expression_node_id                     ;
        v_cz_expression_nodes(v_cz_expr_node_count).EXPR_TYPE           :='201'                                    ;
        v_cz_expression_nodes(v_cz_expr_node_count).TOKEN_LIST_SEQ      :='10'                                     ;
        v_cz_expression_nodes(v_cz_expr_node_count).RULE_ID             :=l_numeric_participant.rule_id            ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_SIGNATURE_ID  :='2069'                                   ;
        v_cz_expression_nodes(v_cz_expr_node_count).PARAM_INDEX         :='1'                                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).DATA_TYPE           :='1'                                      ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_OFFSET       :='4'                                      ;
--        v_cz_expression_nodes(v_cz_expr_node_count).SOURCE_LENGTH       :='38'                                     ;
        v_cz_expression_nodes(v_cz_expr_node_count).MUTABLE_FLAG        :='0'                                      ;
        v_cz_expression_nodes(v_cz_expr_node_count).DATA_NUM_VALUE      :='0'                                      ;


      -- insert record for const 0 under > record
      SELECT name INTO l_ps_node_name from cz_ps_nodes where ps_node_id=l_numeric_participant.ps_node_id;
      displayMessage(3,p_dev_project_id , 'RULE' ,l_numeric_participant.rule_id ,l_api_name,'CZ_CNV_ADV_NUM_IN_LOGIC','NODENAME1', l_ps_node_name,'NODENAME2', l_ps_node_name);
      DELETE FROM cz_expression_nodes where rule_id= l_numeric_participant.rule_id and template_id=21;
      populate_cz_tables(true);
      cz_rule_text_gen.parse_rules(p_dev_project_id,   l_numeric_participant.rule_id);
    END LOOP;

    -- display warning for compatibility rules  design chart /property based /explicit compatibility
    FOR l_compat IN c_compat
    LOOP
      displayMessage(1,p_dev_project_id , 'RULE' ,l_compat.rule_id,l_api_name,'CZ_CNV_FAIL_COMPAT_MAXSEL');
    END LOOP;



    -- LCE supported the use of BOM Models as participants in compatibility rules,
    -- however FCE will not support this.  Model Conversion should fail any
    -- compatibility rule (explicit, property-based, design chart, or CDL
    -- equivalent) that has a BOM Model node as a participant. Ref bug 6488867

    FOR l_compat IN c_bom_compat
    LOOP
      displayMessage(1,p_dev_project_id , 'RULE' ,l_compat.rule_id,l_api_name,'CZ_CNV_FAIL_BOM_NODE_COMPAT');
    END LOOP;


    -- Remove binding for onValidateEligibleTarget event
    -- Refer section 4.1.4.7


  --fetch Event bindings bound to the onValidateEligibleTarget event

    UPDATE cz_expression_nodes
    SET deleted_flag = '1'
    WHERE expr_node_id
    IN (
        SELECT expr_node_id
          FROM cz_rules czrules ,cz_expression_nodes EXP
          WHERE rule_type = RULE_TYPE_CONFIGURATION_EXT
          and  expr_type = 216
             AND EXP.rule_id = czrules.rule_id
             AND EXP.argument_signature_id = 2204
             AND czrules.deleted_flag ='0'
          AND exp.deleted_flag ='0'
          AND devl_project_id=p_dev_project_id
    )
    RETURNING rule_id BULK COLLECT INTO v_cz_ids_tbl ;
    --mark this binding as deleted

    IF v_cz_ids_tbl.COUNT >0 THEN
      FOR i IN v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
      LOOP
        displayMessage(2,p_dev_project_id , 'RULE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_WARN_ON_VALIDATE_REM');
      END LOOP;
      v_cz_ids_tbl.DELETE;
    END IF;

  --Arguments to Configurator Extension event bindings now require the use of new Java interfaces.

     SELECT DISTINCT czrules.rule_id
     BULK COLLECT INTO v_cz_ids_tbl
     FROM cz_rules czrules,
          cz_expression_nodes exp
     WHERE rule_type = RULE_TYPE_CONFIGURATION_EXT
     AND expr_type = 216
     AND exp.rule_id = czrules.rule_id
     AND czrules.deleted_flag = '0'
     AND exp.deleted_flag = '0'
     AND devl_project_id = p_dev_project_id;


    IF v_cz_ids_tbl.COUNT >0 THEN
      FOR i IN v_cz_ids_tbl.FIRST .. v_cz_ids_tbl.LAST
      LOOP
        displayMessage(1,p_dev_project_id , 'RULE' ,v_cz_ids_tbl(i),l_api_name,'CZ_CNV_ERR_BIND_EVT');
      END LOOP;
      v_cz_ids_tbl.DELETE;
    END IF;

    --Display warning  For each Configurator Extension bound to an event that can occur during search.
    --Refer section 4.1.4.8



  -- fetch records for Configurator Extension bound to an event that can occur during search.


      FOR v_rule_ids IN (
          SELECT czrules.rule_id,
            expout.expr_node_id
          FROM cz_rules czrules,
            cz_expression_nodes expout
          WHERE czrules.rule_type = RULE_TYPE_CONFIGURATION_EXT
           AND czrules.rule_id = expout.rule_id
           AND EXISTS
            (SELECT 1
             FROM cz_expression_nodes EXP
             WHERE EXP.expr_type = 216
             AND EXP.rule_id = czrules.rule_id
             AND EXP.argument_signature_id IN(2209,    --postInstanceAdd
            2210,    --postInstanceDelete
            2215,    --postConnect
            2216,    --postDisconnect
            2217 --postValueChange
            --todo  to do find values for 'onValueBound'--'preInstanceDelete',--'preInstanceAdd',
            )
             AND EXP.deleted_flag ='0')
          AND expout.deleted_flag ='0'
           AND czrules.deleted_flag ='0'
           AND devl_project_id = p_dev_project_id
          )
        LOOP
         displayMessage(3,p_dev_project_id , 'RULE' ,v_rule_ids.rule_id,l_api_name,'CZ_CNV_ADV_CX_AUTOCOMPLETE');
      END LOOP;

  EXCEPTION
  WHEN others THEN
    l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
    log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
    RAISE;
  END convertRules;


  --This procedure removes effectivity info and displays messages for conversion of total and resources to float and
  -- also messages for contribute/consume rule conversion.
  PROCEDURE processModel(p_dev_project_id IN cz_devl_projects.devl_project_id%TYPE,   p_rule_folderid cz_rules.rule_folder_id%TYPE) AS
  --Cursor to fetch Multi-Instantiable BOM Model Reference
  CURSOR c_bom_minmax IS
  SELECT ps_node_id
  FROM cz_ps_nodes psout
  WHERE ps_node_type = PS_TYPE_REFERENCE
   AND devl_project_id = p_dev_project_id
   AND instantiable_flag = NODE_INSTANTIABILITY_MULTIPLE
   AND component_id IN
    (SELECT ps_node_id
     FROM cz_ps_nodes psin
     WHERE ps_node_type = PS_TYPE_BOM_MODEL)
  ;
  l_msg VARCHAR2(2000);
  l_api_name constant VARCHAR2(30) := 'processModel';
  BEGIN

    FOR v_ps_node IN
      (SELECT ps_node_id,
         ps_node_type,
         feature_type,
         nvl(initial_value,initial_num_value ) initial_value,
         minimum,
         maximum,
         virtual_flag,name, ROWID
       FROM cz_ps_nodes
       WHERE(ps_node_type IN(PS_TYPE_FEATURE,    PS_TYPE_TOTAL,    PS_TYPE_RESOURCE,    PS_TYPE_BOM_MODEL,    PS_TYPE_BOM_OPTION_CLASS,    PS_TYPE_BOM_STD_ITEM,    PS_TYPE_OPTION)
            OR(ps_node_type = PS_TYPE_COMPONENT       AND virtual_flag = 1)) AND devl_project_id = p_dev_project_id)
    LOOP
      -- kdande; 09-Jan-2008; Bug 6722494
      IF ((v_ps_node.minimum IS NOT NULL) AND (v_ps_node.ps_node_type = PS_TYPE_FEATURE) AND (v_ps_node.feature_type = FEATURE_TYPE_TEXT)) THEN
        UPDATE cz_ps_nodes
        SET    user_input_required_flag = DECODE (v_ps_node.minimum, 1, '1', '0')
        WHERE  ROWID = v_ps_node.ROWID;
      END IF;

      createRules(p_dev_project_id,   v_ps_node.ps_node_id,   v_ps_node.ps_node_type,   v_ps_node.feature_type,   v_ps_node.initial_value,   v_ps_node.minimum,   p_rule_folderid,   v_ps_node.maximum);
        -- Totals and Resources will be converted to float Totals and Resources.
        --Reference section 4.1.3.4
        IF v_ps_node.ps_node_type IN(PS_TYPE_TOTAL,   PS_TYPE_RESOURCE) THEN
          IF v_ps_node.ps_node_type = PS_TYPE_TOTAL THEN
                  displayMessage(3,p_dev_project_id , 'NODE' ,v_ps_node.ps_node_id,l_api_name,'CZ_CNV_ADV_MAP_TO_DECIMAL');
          ELSE
                  displayMessage(3,p_dev_project_id , 'NODE' ,v_ps_node.ps_node_id,l_api_name,'CZ_CNV_ADV_RES_TO_DECIMAL');
          END IF;
        END IF;
    END LOOP;


    -- Effectivity is no longer supported on model node types Total, Resource, Integer Feat,
    -- Decimal Feature, and Virtual Component.  All Effectivity-related information should be
    -- cleared  for nodes of these types  .Reference TD section 4.1.3.1.
    removeEffectivityInfo(p_dev_project_id);
    -- Settings for Initial Minimum and Maximum Instances removed; BOM Maximum Quantity setting now defines the
    --total Quantity allowed across all Instances.

    UPDATE cz_ps_nodes psout
    SET maximum = NULL,
      minimum = NULL
    WHERE ps_node_type = PS_TYPE_REFERENCE
     AND devl_project_id = p_dev_project_id
     AND instantiable_flag = NODE_INSTANTIABILITY_MULTIPLE
     AND component_id IN (SELECT ps_node_id
                             FROM cz_ps_nodes psin
                             WHERE ps_node_type = PS_TYPE_BOM_MODEL);

    FOR v_ps_node_id IN c_bom_minmax
    LOOP
      displayMessage(2,p_dev_project_id , 'NODE' ,v_ps_node_id.ps_node_id,l_api_name,'CZ_CNV_WARN_BOM_INIT_VAL_REM');
    END LOOP;
    --Assign Default domain values as per section 4.1.3.2
    assignDefaultMinMaxvalues(p_dev_project_id);


    EXCEPTION
    WHEN others THEN
      l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
      log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
      RAISE;
    END processModel;


    --Note this procedure is called from model conversion concurrent program
    PROCEDURE convertModels(p_model_conversion_set_id IN NUMBER) AS
    l_rule_folderid cz_rule_folders.rule_folder_id%TYPE;
    l_msg VARCHAR2(2000);
    l_api_name constant VARCHAR2(30) := 'convertModels';
    l_run_id  NUMBER;
    BEGIN


      v_cz_expr_node_count := 0;
      v_cz_expression_nodes.DELETE;

      v_cz_rule_count := 0;
      V_CZ_RULES.DELETE;

      v_model_conversion_set_id:=p_model_conversion_set_id;
      FOR v_models IN
        (    SELECT remote_model_id
             FROM cz_model_publications p , cz_pb_model_exports z
             WHERE p.export_status IN('OK')
             AND p.server_id = 0
             AND p.publication_mode = 'M'
             AND p.migration_group_id = p_model_conversion_set_id
             AND z.publication_id = p.publication_id
             AND z.model_id = p.object_id
             AND z.server_id = 0
             AND z.status = 'OK'
             and p.source_target_flag='S'
             AND p.deleted_flag='0'
        )
      LOOP

        displayMessage(0,v_models.remote_model_id , NULL ,v_models.remote_model_id,l_api_name, 'Model record');


        --mark this model as a fusion model
        --Bug 9176281
          EXECUTE IMMEDIATE ' BEGIN '
                            ||' UPDATE cz_devl_projects'
                            ||' SET config_engine_type = ''F'','
                            ||' post_migr_change_flag = NULL'
                            ||' WHERE devl_project_id = :1;'
                            ||' COMMIT;'
                            ||' END;' USING v_models.remote_model_id;

        l_rule_folderid := findOrCreateRuleFolder(v_models.remote_model_id);
        --Handle model conversion
        processModel(v_models.remote_model_id,   l_rule_folderid);
        --Handle UI conversion
        processUI(v_models.remote_model_id);
        convertRules(v_models.remote_model_id,   l_rule_folderid);


      END LOOP;

        --Dump rules data for newly created rules to the database tables .
        populate_cz_tables(true);
        --Mark rule_class=0 and config_engine_type='F' for all rules having null values for these fields
        UPDATE cz_rules
        SET config_engine_type = 'F' , rule_class=nvl(rule_class,0)
        WHERE deleted_flag='0'
         AND devl_project_id IN( SELECT remote_model_id
             FROM cz_model_publications p , cz_pb_model_exports z
             WHERE p.export_status IN('OK')
             AND p.server_id = 0
             AND p.publication_mode = 'M'
             AND p.migration_group_id = p_model_conversion_set_id
             AND z.publication_id = p.publication_id
             AND z.model_id = p.object_id
             AND z.server_id = 0
             AND z.status = 'OK'
             and p.source_target_flag='S'
             AND p.deleted_flag='0');


      -- Clearing Initial values need to be done at last for all models
      -- as some models may have a downward contribute/consume and hence may require the initial values for accumulator rule creation
      FOR v_models IN
        (    SELECT remote_model_id
             FROM cz_model_publications p , cz_pb_model_exports z
             WHERE p.export_status IN('OK')
             AND p.server_id = 0
             AND p.publication_mode = 'M'
             AND p.migration_group_id = p_model_conversion_set_id
             AND z.publication_id = p.publication_id
             AND z.model_id = p.object_id
             AND z.server_id = 0
             AND z.status = 'OK'
             and p.source_target_flag='S'
             AND p.deleted_flag='0'
        )
      LOOP
        --Clear Initial values for certain node types
        clearinitialvalues(v_models.remote_model_id);

        /************** For now donot call logicgen
	--After processing rules and when done with conversion process for this model run logicgen .
        l_run_id:=0;
        BEGIN
	  cz_fce_compile.compile_logic(v_models.remote_model_id,l_run_id);
        EXCEPTION WHEN OTHERS THEN
	  NULL;  -- we donot want conversion to fail if logicgen reported an error .
        END;
       ***************/
      END LOOP;
      --Do Cleanup
      v_cz_expr_node_count := 0;
      v_cz_expression_nodes.DELETE;
      v_cz_rule_count := 0;
      V_CZ_RULES.DELETE;
      v_model_conversion_set_id:=NULL;
    EXCEPTION
    WHEN others THEN
      v_cz_expr_node_count := 0;
      v_cz_expression_nodes.DELETE;
      v_cz_rule_count := 0;
      V_CZ_RULES.DELETE;
      l_msg := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
      log_msg(l_api_name,   v_ndebug,   l_msg,   fnd_log.level_unexpected);
      v_model_conversion_set_id:=NULL;
      RAISE;
    END convertModels;




---------------------------------------------------------------------------------------
/*
 * Copy Model For Conversionprocedure.
 * @param errbuf       Standard Oracle Concurrent Program output parameters.
 * @param retcode      Standard Oracle Concurrent Program output parameters.
 * @param p_request_id This is the CZ_MODEL_PUBLICATIONS, MIGRATION_GROUP_ID of the migration request.
 *                     Migration request is created by Developer and contains the list of all models selected
 *                     for Migration from the source's Configurator Repository, target Instance name and
 *                     target Repository Folder.
 */

PROCEDURE copy_model_for_conversion(errbuf       OUT NOCOPY VARCHAR2,
                            retcode      OUT NOCOPY NUMBER,
                            p_request_id IN  NUMBER
                           ) IS
  l_status         VARCHAR2(3);
  l_publication_id NUMBER;
  l_run_id         NUMBER := 0;
  l_mig_group_found BOOLEAN :=FALSE;
  l_api_name        CONSTANT VARCHAR2(30) := 'copy_model_for_conversion';
  PUB_ERROR        EXCEPTION;
BEGIN

  retcode:=0;
  cz_pb_mgr.GLOBAL_EXPORT_RETCODE := 0;

  FOR c_pub IN (SELECT publication_id ,max(node_depth) mdepth FROM cz_model_publications mp ,cz_model_ref_expls mr
                 WHERE mp.migration_group_id = p_request_id AND mp.deleted_flag = '0' and mr.deleted_flag = '0'
                 AND mp.publication_mode='M'
                 and mr.model_id    =mp.object_id
                 group by   publication_id
                 order by mdepth asc
                )LOOP

    l_mig_group_found :=TRUE;
    cz_pb_mgr.publish_model(c_pub.publication_id, l_run_id, l_status);
    IF l_status = cz_pb_mgr.PUBLICATION_ERROR THEN
        RAISE PUB_ERROR;
    END IF;

    errbuf := NULL;
    IF(cz_pb_mgr.GLOBAL_EXPORT_RETCODE = 1)THEN
      errbuf := CZ_UTILS.GET_TEXT('CZ_MM_WARNING');
    ELSIF(cz_pb_mgr.GLOBAL_EXPORT_RETCODE = 2) THEN
      errbuf := CZ_UTILS.GET_TEXT('CZ_MM_FAILURE');
    END IF;
  END LOOP;

  IF NOT l_mig_group_found THEN
     errbuf := cz_utils.get_text('CZ_INVALID_MIGR_GROUP_NUMBER', 'MIGRGRP', p_request_id);
     log_msg(l_api_name, v_ndebug, errbuf , FND_LOG.LEVEL_PROCEDURE);
     raise_application_error('-20020', 'INVALID_MIGRATION_GROUP');
  END IF;

  retcode := cz_pb_mgr.GLOBAL_EXPORT_RETCODE;

EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    log_msg(l_api_name,   v_ndebug,   errbuf,   fnd_log.level_unexpected);
    errbuf := CZ_UTILS.GET_TEXT('CZ_MM_UNEXPECTED');
    RAISE;
END;


Procedure  Model_Convert_CP(errbuf out nocopy varchar2,
        Retcode out nocopy number,
        P_request_id in number default null)   is
req_data varchar2(10);
r number;
i number;
b boolean;
noofreports number:=0;

call_status boolean;
rphase varchar2(80);
rstatus varchar2(80);
dphase varchar2(30);
dstatus varchar2(30);
message varchar2(240);
L_API_NAME        CONSTANT VARCHAR2(30) := 'Model_Convert_CP';
L_RETURN_STATUS   VARCHAR2(100)   ;
L_MSG_COUNT       NUMBER          ;
L_MSG_DATA        VARCHAR2(2000)  ;
ERR_PROFILE       EXCEPTION;
l_migration_group_id cz_model_publications.migration_group_id%TYPE;
L_ERROR_IN_CP     BOOLEAN;

Begin

fnd_msg_pub.initialize;
cz_model_convert.CONVERT_MODEL:=TRUE;
L_ERROR_IN_CP :=FALSE;

        IF fnd_profile.value('CZ_BOM_DEFAULT_QTY_DOMN')='Y' THEN
                USE_BOM_DEFAULT_QTY:='TRUE';
        ELSE
                USE_BOM_DEFAULT_QTY:='FALSE';
        END IF;


       --get integer and decimal max values from profiles


       INTEGER_MAX_VALUE   := fnd_profile.value('CZ_DEFAULT_MAX_QTY_INT');
       SOLVER_MAX_DOUBLE := fnd_profile.value('CZ_DEFAULT_MAX_QTY_DEC');

       IF (INTEGER_MAX_VALUE IS NULL OR SOLVER_MAX_DOUBLE IS NULL) THEN
              log_msg('Model_Convert_CP', 0,  cz_utils.get_text('CZ_CNV_ERR_PROFILE_NOT_SET')  ,   fnd_log.level_unexpected);
              RAISE ERR_PROFILE;
       END IF;


       INTEGER_MIN_VAL := INTEGER_MAX_VALUE * -1;



        SELECT COUNT(*)
        INTO noofreports
        FROM
          (SELECT DISTINCT migration_group_id
           FROM cz_model_publications
           WHERE deleted_flag ='0'
           AND publication_mode = 'M'
           AND(migration_group_id = p_request_id OR(p_request_id IS NULL AND migration_group_id IS NOT NULL))
           AND export_status = 'PEN'
           AND server_id = 0);

        IF(noofreports=0  and fnd_conc_global.request_data IS NULL ) THEN
                log_msg('Model_Convert_CP', 0,   'No pending request with the supplied Conversion Set ID',   fnd_log.level_unexpected);
                errbuf := 'Error in model conversion!';
                retcode :=  2;
                raise ERR_PROFILE;

        END IF;

        For  c_model_conv IN (
                SELECT DISTINCT migration_group_id
                FROM cz_model_publications mp
                WHERE deleted_flag ='0' and
                publication_mode='M'
                AND server_id = 0
                AND export_status = 'PEN'
                AND (migration_group_id = p_request_id
                OR(P_request_id is null AND migration_group_id IS NOT NULL   ))
        ) LOOP


        BEGIN

        l_migration_group_id:=c_model_conv.migration_group_id;
        --
        -- Read the value from REQUEST_DATA. If this is the PL/SQL APIs for Concurrent Processing
        -- first run of the program, then this value will be
        -- null.
        -- Otherwise, this will be the value that we passed to
        -- SET_REQ_GLOBALS on the previous run.
        --
        req_data := fnd_conc_global.request_data;

        -- If this is the first run, well set i = 1.
        -- Otherwise we will set i = request_data + 1, and we will
        -- exit if we are done.
        --
        IF (req_data is not null) then
                i := to_number(req_data);
                i := i + 1;
                IF (i < noofreports+1 ) THEN
                        errbuf := 'Done!';
                        retcode := 0 ;
                        return;
                END IF;
        ELSE
        i := 1;
        END IF;
        --this procedures creates copy of the existing model
        copy_model_for_conversion(errbuf, Retcode, c_model_conv.migration_group_id);
        commit;
        UPDATE cz_model_publications set export_status='OK' where export_status='PEN' and migration_group_id=c_model_conv.migration_group_id;
        --this procedure converts the copied LCE models to FCE standard
        convertModels(c_model_conv.migration_group_id);
        commit;
        --
        -- Submit the child request. The sub_request parameter
        -- must be set to 'Y'.
        --
        b:=fnd_request.ADD_LAYOUT (
         TEMPLATE_APPL_NAME             =>  'CZ',
         TEMPLATE_CODE                  =>  'CZ_MDLCONV',
         TEMPLATE_LANGUAGE              =>  'EN',
         TEMPLATE_TERRITORY             =>  'US',
         OUTPUT_FORMAT                  =>  'PDF'
         );

        --Submit a new sub request for generating a XML publisher report
        r := fnd_request.submit_request('CZ','CZ_MDLCONV', 'Model Conversion Report - Conversion Set '|| c_model_conv.migration_group_id, NULL ,TRUE, c_model_conv.migration_group_id);

        IF r = 0 THEN
                --
                -- If request submission failed, exit with error.
                --
                errbuf := fnd_message.get;
                retcode := 2;
        ELSE
                --
                log_msg('Model_Convert_CP', 0 ,
                   'Model Conversion Report Generation has been submitted as a Concurrent Request with ID '||r||'.  Please review the output of the Concurrent Process for important messages about the conversion.', fnd_log.level_unexpected);
                errbuf := 'Request submitted!';
                retcode := 0 ;
        END IF;

        COMMIT;
        EXCEPTION WHEN OTHERS THEN
              L_ERROR_IN_CP := TRUE;
              retcode := 2;
              errbuf := cz_utils.get_text('CZ_CNV_UNEXPECTED');
              log_msg('Model_Convert_CP', 0,   'Error submitting request for report generation.',   fnd_log.level_unexpected);
              cz_model_convert.CONVERT_MODEL:=FALSE;
              BEGIN
                     call_status :=  FND_CONCURRENT.GET_REQUEST_STATUS(r, '', '',    rphase,rstatus,dphase,dstatus, message);
                     IF dphase<>'COMPLETE' THEN
                              fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => to_char(i));
                      END IF;
                      --no need to pause if child completed
                      EXCEPTION WHEN OTHERS THEN
                              NULL;
              END;

              raise;
        END;
        END LOOP;

        cz_model_convert.CONVERT_MODEL:=FALSE;
        BEGIN
               call_status :=  FND_CONCURRENT.GET_REQUEST_STATUS(r, '', '',    rphase,rstatus,dphase,dstatus, message);
               IF dphase<>'COMPLETE' THEN
                        fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => to_char(i));
                END IF;
                --no need to pause if child completed
                EXCEPTION WHEN OTHERS THEN
                        NULL;
        END;


        IF(L_ERROR_IN_CP)THEN
              retcode :=2;
              errbuf := cz_utils.get_text('CZ_CNV_UNEXPECTED');
        END IF;
EXCEPTION WHEN ERR_PROFILE THEN
 IF(errbuf <> cz_utils.get_text('CZ_CNV_UNEXPECTED'))THEN
	 log_msg(l_api_name,   v_ndebug,   errbuf,   fnd_log.level_unexpected);
 END IF;
 cz_model_convert.CONVERT_MODEL:=FALSE;
 retcode := 2;
 errbuf := cz_utils.get_text('CZ_CNV_UNEXPECTED');
 commit;
WHEN OTHERS THEN
 IF(errbuf <> cz_utils.get_text('CZ_CNV_UNEXPECTED'))THEN
	 log_msg(l_api_name,   v_ndebug,   errbuf,   fnd_log.level_unexpected);
 END IF;
 cz_model_convert.CONVERT_MODEL:=FALSE;
 -- rollback model copy operation when there is an error
 --If  "cz_model_migration_pvt .migrate_models_cp" call not completed successfully then         Mark the migrated models as deleted .

 retcode := 2;
 errbuf := cz_utils.get_text('CZ_CNV_UNEXPECTED');

 FOR c_process IN (

             SELECT remote_model_id
             FROM cz_model_publications p , cz_pb_model_exports z
             WHERE p.export_status IN('OK')
             AND p.server_id = 0
             AND p.publication_mode = 'M'
             AND p.migration_group_id = P_request_id
             AND z.publication_id = p.publication_id
             AND z.model_id = p.object_id
             AND z.server_id = 0
             AND z.status = 'OK'
             and p.source_target_flag='S'
             AND p.deleted_flag='0'
            )LOOP
          BEGIN
                  cz_developer_utils_pvt.delete_model(c_process.remote_model_id,L_RETURN_STATUS,L_MSG_COUNT,L_MSG_DATA);
          EXCEPTION WHEN OTHERS THEN
	    errbuf := 'Fatal error in ' || l_api_name || '.' || v_ndebug || ': ' || SUBSTR(sqlerrm,   1,   900);
	    log_msg(l_api_name,   v_ndebug,   errbuf,   fnd_log.level_unexpected);
          END;

  END LOOP;

   --an error has occured update status to reflect this
 UPDATE cz_model_publications SET export_status='ERR' WHERE migration_group_id = l_migration_group_id  and server_id=0 ;


  commit;
End Model_Convert_CP;


FUNCTION GET_UI_PATH(inParent_id IN NUMBER) RETURN VARCHAR2 is
l_qualified  VARCHAR2(2000) := ' ';
BEGIN

        IF inParent_id IS  NOT NULL THEN
          select name INTO l_qualified from cz_ui_defs where ui_def_id = (select max(ui_def_id) from cz_ui_page_elements  where element_id = to_char(inParent_id));
          l_qualified:=l_qualified||'.Pages';
          FOR parent_node IN (SELECT distinct(name) , element_id FROM cz_ui_page_elements
                           WHERE deleted_flag = '0'
                           START WITH element_id = to_char(inParent_id)
                           CONNECT BY PRIOR parent_element_id=element_id
                           order by element_id ) LOOP

                    IF(LENGTH(parent_node.name) + LENGTH(l_qualified) + 1 < 2000)  THEN
                          l_qualified := l_qualified||'.' || parent_node.name ;
                    ELSE
                          EXIT;
                    END IF;
          END LOOP;
        END IF;
 RETURN l_qualified;
END GET_UI_PATH;



END CZ_MODEL_CONVERT;

/
