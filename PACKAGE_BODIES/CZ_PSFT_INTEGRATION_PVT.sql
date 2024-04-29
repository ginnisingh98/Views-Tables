--------------------------------------------------------
--  DDL for Package Body CZ_PSFT_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PSFT_INTEGRATION_PVT" AS
/* $Header: czpsintb.pls 120.11.12010000.2 2008/11/10 07:15:39 kksriram ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'cz_psft_integration_pvt';

-- config type, status
ROOT      CONSTANT VARCHAR2(1) := 'R';
COMPLETE  CONSTANT VARCHAR2(1) := '2';

NO_VALUE  CONSTANT NUMBER := -1;

PS_NODE_TYPE_FEATURE    CONSTANT NUMBER := 261;
PS_NODE_TYPE_OPTION     CONSTANT NUMBER := 262;
PS_NODE_TYPE_REFERENCE  CONSTANT NUMBER := 263;
PS_NODE_TYPE_CONNECTOR  CONSTANT NUMBER := 264;
PS_NODE_TYPE_TOTAL      CONSTANT NUMBER := 272;
PS_NODE_TYPE_RESOURCE   CONSTANT NUMBER := 273;

-- configratuon vocabuary and xml tags
TAG_SECTION                 CONSTANT VARCHAR2(30) := 'SECTION';
TAG_COMPONENTS              CONSTANT VARCHAR2(30) := 'COMPONENTS';
TAG_STRUCTURE               CONSTANT VARCHAR2(30) := 'STRUCTURE';
TAG_CONFIGURABLE_COMPONENT  CONSTANT VARCHAR2(30) := 'CONFIGURABLE_COMPONENT';
TAG_CONFIGURATION           CONSTANT VARCHAR2(30) := 'CONFIGURATION';
TAG_CHOICES                 CONSTANT VARCHAR2(30) := 'CHOICES';
TAG_VIOLATIONS              CONSTANT VARCHAR2(30) := 'VIOLATIONS';
TAG_EXPLANATION             CONSTANT VARCHAR2(30) := 'EXPLANATION';
TAG_NUMERIC_VALUES          CONSTANT VARCHAR2(30) := 'NUMERIC_VALUES';
TAG_ATTR                    CONSTANT VARCHAR2(30) := 'ATTR';
TAG_COMPLETE                CONSTANT VARCHAR2(30) := 'COMPLETE';  -- <COMPLETE STATUS="TRUE"/>

TAG_DELTA_INFO              CONSTANT VARCHAR2(30) := 'DELTA_INFO';
TAG_COMPONENT               CONSTANT VARCHAR2(30) := 'COMPONENT';
TAG_CONFIG_DELTA            CONSTANT VARCHAR2(30) := 'CONFIG_DELTA';
TAG_DELTA_CHOICE            CONSTANT VARCHAR2(30) := 'DELTA_CHOICE';
TAG_CHOICE_ADDS             CONSTANT VARCHAR2(30) := 'CHOICE_ADDS';
TAG_CHOICE_DELETES          CONSTANT VARCHAR2(30) := 'CHOICE_DELETES';
TAG_CHOICE_CHANGES          CONSTANT VARCHAR2(30) := 'CHOICE_CHANGES';
TAG_PREVIOUS                CONSTANT VARCHAR2(30) := 'PREVIOUS';
TAG_CH                      CONSTANT VARCHAR2(30) := 'CH';
TAG_CURRENT                 CONSTANT VARCHAR2(30) := 'CURRENT';
TAG_NUM                     CONSTANT VARCHAR2(30) := 'NUM';
TAG_EXPR_CHANGES            CONSTANT VARCHAR2(30) := 'EXPR_CHANGES';
TAG_DELTA_EXPR              CONSTANT VARCHAR2(30) := 'DELTA_EXPR';
TAG_COMPONENT_ADDS          CONSTANT VARCHAR2(30) := 'COMPONENT_ADDS';
TAG_COMPONENT_DELETES       CONSTANT VARCHAR2(30) := 'COMPONENT_DELETES';
ADD_ACTION                  CONSTANT VARCHAR2(30) := 'ADD';
CHANGE_ACTION               CONSTANT VARCHAR2(30) := 'CHANGE';
DELETE_ACTION               CONSTANT VARCHAR2(30) := 'DELETE';

v_all_psft_solutions_id_tbl t_ref;
v_all_psft_solutions_name_tbl t_name;
v_all_psft_solutions_desc_tbl t_name;
v_all_psft_solutions_prod_tbl t_name;
doc xmldom.DOMDocument;

-------------------------------------------------------------------------------

procedure load_all_solutions
AS
BEGIN
  select devl_project_id,
         name,
         desc_text,
         prj.product_key
  BULK COLLECT INTO
        v_all_psft_solutions_id_tbl,
        v_all_psft_solutions_name_tbl,
        v_all_psft_solutions_desc_tbl,
        v_all_psft_solutions_prod_tbl
  from   cz_devl_projects prj, cz_model_publications pub
  where prj.deleted_flag = '0' and prj.product_key like 'PSFT%'
  and pub.deleted_flag = '0' and pub.object_id = prj.devl_project_id and object_type = 'PRJ'
  and export_status = 'OK' and source_target_flag = 'T';
END load_all_solutions;

procedure createExpressionsInfo(solutionId IN NUMBER, parent_node IN OUT NOCOPY xmldom.DOMNode)
AS
  l_expressions_info_tbl t_name;
  l_expr_type_tbl        t_ref;
  l_expr_sub_type_tbl    t_ref;
  item_node              xmldom.DOMNode;
  numeric_node           xmldom.DOMNode;
  item_elmt              xmldom.DOMElement;
  TP                     VARCHAR2(2000);
BEGIN
  select name,
         ps_node_type,
         feature_type
  BULK COLLECT INTO
         l_expressions_info_tbl,
         l_expr_type_tbl,
         l_expr_sub_type_tbl
  from   cz_rul_typedpsn_v
  where  detailed_type_id in (272, 273, 502, 504, 505, 506)
  and    devl_project_id = component_id
  and    devl_project_id = solutionId;

  IF (l_expressions_info_tbl.COUNT > 0) THEN
    item_elmt := xmldom.createElement(doc, 'NUMERIC_VALUES');
    numeric_node := xmldom.appendChild(parent_node, xmldom.makeNode(item_elmt));
    FOR comp_ref IN l_expressions_info_tbl.FIRST ..l_expressions_info_tbl.LAST
    LOOP
      item_elmt := xmldom.createElement(doc, 'NUM');
      -- setAttributes
      xmldom.setAttribute(item_elmt, 'NM', l_expressions_info_tbl(comp_ref) );
      if ( l_expr_sub_type_tbl(comp_ref) = 1 ) then
        TP := 'INTEGER';
      elsif ( l_expr_sub_type_tbl(comp_ref) = 2 ) then
        TP := 'DOUBLE';
      elsif (l_expr_sub_type_tbl(comp_ref) = 3 or l_expr_type_tbl(comp_ref) = 272 or l_expr_type_tbl(comp_ref) = 273) then
        TP := 'STRING';
      end if;
      xmldom.setAttribute(item_elmt, 'TP', TP );
      item_node := xmldom.appendChild(numeric_node, xmldom.makeNode(item_elmt));
    END LOOP;
  END IF;
END createExpressionsInfo;

procedure get_solutions_details(solutionsXML OUT NOCOPY CLOB, x_run_id IN OUT NOCOPY NUMBER, x_pb_status IN OUT NOCOPY VARCHAR2)
AS
  -- Nodes
  main_node           xmldom.DOMNode;
  root_node           xmldom.DOMNode;
  item_node           xmldom.DOMNode;
  text_node           xmldom.DOMNode;
  solutionInfo_node   xmldom.DOMNode;

  --elements
  root_elmt           xmldom.DOMElement;
  item_elmt           xmldom.DOMElement;

  item_text           xmldom.DOMText;
  l_lob               CLOB;

  solutionCount       NUMBER;
BEGIN
  -- clear all previous arrays
  v_all_psft_solutions_id_tbl.delete;
  v_all_psft_solutions_name_tbl.delete;
  v_all_psft_solutions_desc_tbl.delete;
  load_all_solutions;
  solutionCount := v_all_psft_solutions_id_tbl.count;
  x_run_id := 1;
  x_pb_status  := 'SUCCESS';

  doc := xmldom.newDOMDocument();
  main_node := xmldom.makeNode(doc);
  -- create root element (SolutionList)
  root_elmt := xmldom.createElement(doc, 'SolutionList');
  -- set element attributes (solutions=solutionCount)
  xmldom.setAttribute(root_elmt, 'solutions', solutionCount );
  -- set top element on the document
  root_node := xmldom.appendChild(main_node, xmldom.makeNode(root_elmt));

  IF solutionCount > 0 THEN

    FOR s IN v_all_psft_solutions_id_tbl.FIRST .. v_all_psft_solutions_id_tbl.LAST
    LOOP
      -- create solutionIfo element
      item_elmt := xmldom.createElement(doc, 'SolutionInfo');
      -- setAttributes
      xmldom.setAttribute(item_elmt, 'name', v_all_psft_solutions_prod_tbl(s) );
      xmldom.setAttribute(item_elmt, 'version', '' );
      xmldom.setAttribute(item_elmt, 'compound', '' );
      xmldom.setAttribute(item_elmt, 'internal', 'false' );
      xmldom.setAttribute(item_elmt, 'allNew', 'true' );
      solutionInfo_node := xmldom.appendChild(root_node, xmldom.makeNode(item_elmt));

      -- create description element
      item_elmt := xmldom.createElement(doc, 'Description');
      item_node := xmldom.appendChild(solutionInfo_node, xmldom.makeNode(item_elmt));
      item_text := xmldom.createTextNode(doc, v_all_psft_solutions_desc_tbl(s));
      text_node := xmldom.appendChild(item_node, xmldom.makeNode(item_text));

      -- create solutionUI element
      item_elmt := xmldom.createElement(doc, 'solutionUI');
      xmldom.setAttribute(item_elmt, 'root', '');
      xmldom.setAttribute(item_elmt, 'localeLanguage', '' );
      xmldom.setAttribute(item_elmt, 'localeCountry', '' );
      xmldom.setAttribute(item_elmt, 'pageStart', '/OA_HTML/CfgOCI.jsp' );
      xmldom.setAttribute(item_elmt, 'path', '' );
      item_node := xmldom.appendChild(solutionInfo_node, xmldom.makeNode(item_elmt));

      -- create ComponentInfo element
      item_elmt := xmldom.createElement(doc, 'ComponentInfo');
      -- setAttributes
      xmldom.setAttribute(item_elmt, 'modelName', v_all_psft_solutions_name_tbl(s) );
      xmldom.setAttribute(item_elmt, 'modelVersion', '' );
      xmldom.setAttribute(item_elmt, 'restorePolicy', '' );
      item_node := xmldom.appendChild(solutionInfo_node, xmldom.makeNode(item_elmt));

      -- createReferenceTreeStructure
      --createReferenceTreeStructure(v_all_psft_solutions_id_tbl(s), solutionInfo_node);
    END LOOP;
  END IF;

  -- create output parameter
  SYS.DBMS_LOB.createtemporary(l_lob, TRUE, DBMS_LOB.SESSION);
  SYS.DBMS_LOB.OPEN(l_lob, DBMS_LOB.lob_readwrite);
  xmldom.writetoclob(doc, l_lob);
  solutionsXML := l_lob;
  SYS.DBMS_LOB.CLOSE(l_lob);
  SYS.DBMS_LOB.freetemporary(l_lob);
  xmldom.freeDocument(doc);
EXCEPTION
  WHEN OTHERS THEN
    x_run_id := 0;
    x_pb_status := 'FAILED';
    RAISE;
END get_solutions_details;

procedure get_models_details(modelsXML OUT NOCOPY CLOB, x_run_id IN OUT NOCOPY NUMBER, x_pb_status IN OUT NOCOPY VARCHAR2)
AS
  -- define arrays here to collect
  main_node        xmldom.DOMNode;
  root_node        xmldom.DOMNode;
  item_node        xmldom.DOMNode;
  text_node        xmldom.DOMNode;
  modelInfo_node   xmldom.DOMNode;

  --elements
  root_elmt        xmldom.DOMElement;
  item_elmt        xmldom.DOMElement;

  item_text        xmldom.DOMText;
  l_lob            CLOB;

  solutionCount    NUMBER;
BEGIN
  -- clear all previous arrays
  v_all_psft_solutions_id_tbl.delete;
  v_all_psft_solutions_name_tbl.delete;
  v_all_psft_solutions_desc_tbl.delete;
  load_all_solutions;
  solutionCount := v_all_psft_solutions_id_tbl.count;
  x_run_id := 1;
  x_pb_status  := 'SUCCESS';
  doc := xmldom.newDOMDocument();
  main_node := xmldom.makeNode(doc);
  -- create root element (ModelList)
  root_elmt := xmldom.createElement(doc, 'ModelList');
  -- set element attributes (solutions=solutionCount)
  xmldom.setAttribute(root_elmt, 'models', solutionCount );
  -- set top element on the document
  root_node := xmldom.appendChild(main_node, xmldom.makeNode(root_elmt));

  IF solutionCount > 0 THEN

    FOR s IN v_all_psft_solutions_id_tbl.FIRST .. v_all_psft_solutions_id_tbl.LAST
    LOOP
      -- create solutionIfo element
      item_elmt := xmldom.createElement(doc, 'ModelInfo');
      -- setAttributes
      xmldom.setAttribute(item_elmt, 'name', v_all_psft_solutions_name_tbl(s) );
      xmldom.setAttribute(item_elmt, 'version', '' );
      modelInfo_node := xmldom.appendChild(root_node, xmldom.makeNode(item_elmt));

      -- create DECISION_POINTS element
      item_elmt := xmldom.createElement(doc, 'DECISION_POINTS');
      item_node := xmldom.appendChild(modelInfo_node, xmldom.makeNode(item_elmt));

      createExpressionsInfo(v_all_psft_solutions_id_tbl(s),modelInfo_node);

      -- create EXTERN_VARS element
      item_elmt := xmldom.createElement(doc, 'EXTERN_VARS');
      item_node := xmldom.appendChild(modelInfo_node, xmldom.makeNode(item_elmt));
    END LOOP;
  END IF;

  -- create output parameter
  SYS.DBMS_LOB.createtemporary(l_lob, TRUE, DBMS_LOB.SESSION);
  SYS.DBMS_LOB.OPEN(l_lob, DBMS_LOB.lob_readwrite);
  xmldom.writetoclob(doc, l_lob);
  modelsXML := l_lob;
  SYS.DBMS_LOB.CLOSE(l_lob);
  SYS.DBMS_LOB.freetemporary(l_lob);
  xmldom.freeDocument(doc);
EXCEPTION
  WHEN OTHERS THEN
    x_run_id := 0;
    x_pb_status := 'FAILED';
    RAISE;
END get_models_details;

--------------------------------------------------------------------------------

PROCEDURE get_config_details(p_api_version             IN NUMBER
                            ,p_config_hdr_id           IN NUMBER
                            ,p_config_rev_nbr          IN NUMBER
                            ,p_product_key             IN VARCHAR2
                            ,p_application_id          IN NUMBER
                            ,p_price_info_list         IN SYSTEM.VARCHAR_TBL_TYPE
                            ,p_check_violation_flag    IN VARCHAR2
                            ,p_check_connection_flag   IN VARCHAR2
                            ,p_baseline_config_hdr_id  IN NUMBER
                            ,p_baseline_config_rev_nbr IN NUMBER
                            ,x_config_details       OUT NOCOPY CLOB
                            ,x_return_status        OUT NOCOPY VARCHAR2
                            ,x_msg_count            OUT NOCOPY NUMBER
                            ,x_msg_data             OUT NOCOPY VARCHAR2
                            )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'get_config_details';

  -- item type code
  COMPONENT  CONSTANT NUMBER := 4;
  TEXT       CONSTANT NUMBER := 2;
  CONNECTOR  CONSTANT NUMBER := 7;

  -- prop data type
  TRANSLATABLE_TEXT       CONSTANT NUMBER := 8;
  NON_TRANSLATABLE_TEXT   CONSTANT NUMBER := 4;

  -- Feature type: 0-option;1-integer;2-decimal;3-boolean;4-text
  -- BOOLEAN_FEATURE         CONSTANT NUMBER := 1;
  -- INTEGER_FEATURE         CONSTANT NUMBER := 2;
  -- DOUBLE_FEATURE          CONSTANT NUMBER := 3;
  OPTION_FEATURE          CONSTANT NUMBER := 0;
  OPTION_FEATURE_1_1      CONSTANT NUMBER := 1;
  OPTION_FEATURE_0_N      CONSTANT NUMBER := 2;
  NUM_FEATURE             CONSTANT NUMBER := 3; -- bool, int, double, total, resource
  TEXT_FEATURE            CONSTANT NUMBER := 4;

  TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE num_tbl_type_idx_vc2 IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
  TYPE v2k_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE psn_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
  TYPE prj_psn_tbl_type IS TABLE OF psn_tbl_type INDEX BY VARCHAR2(15);
  TYPE prp_rec_type IS RECORD (name cz_properties.name%TYPE, val cz_ps_prop_vals.data_value%TYPE);
  TYPE prp_tbl_type IS TABLE OF prp_rec_type INDEX BY BINARY_INTEGER;
  TYPE psn_prp_tbl_type IS TABLE OF prp_tbl_type INDEX BY VARCHAR2(15);
  TYPE prj_psn_prp_tbl_type IS TABLE OF psn_prp_tbl_type INDEX BY VARCHAR2(15);
  TYPE osr_tbl_type IS TABLE OF cz_item_masters.orig_sys_ref%TYPE INDEX BY VARCHAR2(15);
  TYPE pkg_osr_tbl_type IS TABLE OF osr_tbl_type INDEX BY VARCHAR2(15);

  TYPE cfg_msg_tbl_type IS TABLE of v2k_tbl_type INDEX BY VARCHAR2(15);--  Bug 6892148;

  TYPE conn_rec_type IS RECORD
    (id            NUMBER
    ,name          cz_config_items.name%TYPE
    ,ref           cz_config_items.name%TYPE
    ,fromCompID    NUMBER
    ,fromCompName  cz_config_items.name%TYPE
    ,fromCompType  cz_config_items.name%TYPE
    ,toCompID      NUMBER
    ,toCompName    cz_config_items.name%TYPE
    ,toCompType    cz_config_items.name%TYPE
    );
  TYPE conn_tbl_type IS TABLE OF conn_rec_type INDEX BY VARCHAR2(15);--  Bug 6892148;

  TYPE chg_rec_type IS RECORD (old_val cz_config_items.item_val%TYPE, new_val cz_config_items.item_val%TYPE);
  TYPE chg_tbl_type IS TABLE OF chg_rec_type INDEX BY BINARY_INTEGER;

  TYPE domnode_tbl_type IS TABLE OF XMLDOM.DOMNode INDEX BY VARCHAR2(15);--  Bug 6892148;

  l_delta_choice_Node XMLDOM.DOMNode;

  l_ndebug    INTEGER;
  l_log_stmt  BOOLEAN;
  l_msg       VARCHAR2(2000);
  l_count     INTEGER;

  l_config_status  cz_config_hdrs.config_status%TYPE;
  l_has_failures   cz_config_hdrs.has_failures%TYPE;
  l_model_id       NUMBER;
  l_creation_date  DATE;
  l_lookup_date    DATE;
  l_effective_date DATE;

  l_is_valid           BOOLEAN;
  l_rpt_total_price    BOOLEAN;
  l_rpt_recur_price    BOOLEAN;
  l_check_delta        BOOLEAN;
  l_is_root_comp       BOOLEAN;
  l_has_pkg_component  BOOLEAN;
  l_is_pkg_component   BOOLEAN;
  l_exists_in_baseline BOOLEAN;
  l_psn_type           INTEGER;
  l_comp_name          VARCHAR2(1000);
  l_parent_item        NUMBER;
  l_parent_name        cz_config_items.ps_node_name%TYPE;

  l_ref_node_map num_tbl_type_idx_vc2;
  l_prj_psn_type_map  prj_psn_tbl_type;
  l_prj_psn_osr_map  pkg_osr_tbl_type;
  l_prj_psn_prp_map  prj_psn_prp_tbl_type;
  l_item_prj_map   num_tbl_type_idx_vc2;--  Bug 6892148;
  l_prp_tbl   prp_tbl_type;

  l_msg_tbl      v2k_tbl_type;
  l_com_msg_tbl  v2k_tbl_type;
  l_com_att_tbl  prp_tbl_type;

  l_conn_map      conn_tbl_type;

  l_cfg_msg_map   cfg_msg_tbl_type;

  l_chg_item_map  chg_tbl_type;
  l_add_item_map  num_tbl_type;
  l_del_item_map  num_tbl_type;
  l_pkg_node_map  num_tbl_type;

  l_domnode_map  domnode_tbl_type;

  l_init_xml_str      VARCHAR2(2000);
  l_typeAttrVal       VARCHAR2(10);
  l_doc               XMLDOM.DOMDocument;
  l_docelm            XMLDOM.DOMElement;
  l_sections          XMLDOM.DOMNodeList;
  l_templateNode      XMLDOM.DOMNode;
  l_tmplNodes         XMLDOM.DOMNodeList;
  l_sectionMainNode   XMLDOM.DOMNode;
  l_componentsNode    XMLDOM.DOMNode;
  l_cfgCompNode       XMLDOM.DOMNode;
  l_configurationNode XMLDOM.DOMNode;
  l_structNode        XMLDOM.DOMNode;
  l_structCfgCompNode XMLDOM.DOMNode;
  l_connNode          XMLDOM.DOMNode;
  l_violationNode     XMLDOM.DOMNode;
  l_choicesNode       XMLDOM.DOMNode;
  l_chNode            XMLDOM.DOMNode;
  l_numericValuesNode XMLDOM.DOMNode;
  l_numNode           XMLDOM.DOMNode;
  l_attrNode          XMLDOM.DOMNode;

  l_pkgComponentsNode    XMLDOM.DOMNode;
  l_pkgCfgCompNode       XMLDOM.DOMNode;
  l_pkgConfigurationNode XMLDOM.DOMNode;
  l_pkgChoicesNode       XMLDOM.DOMNode;
  l_pkgNumericValuesNode XMLDOM.DOMNode; -- check DTD if needed
  l_pkgChNode            XMLDOM.DOMNode;
  l_pkgAttrNode          XMLDOM.DOMNode;
  l_leadAttrNodeCreated  BOOLEAN;

  l_prcNumericValuesNode XMLDOM.DOMNode;
  l_sectionDeltaNode XMLDOM.DOMNode;
  l_tempNode  XMLDOM.DOMNode;

  l_tmplCcNode   XMLDOM.DOMNode; -- configurable component
  l_tmplChNode   XMLDOM.DOMNode; -- <CH DP="OF7" DM="O13"> QTY="1.0"</CH>
  l_tmplAtNode   XMLDOM.DOMNode; -- <ATTR NM="">a1</ATTR>
  l_tmplNumNode  XMLDOM.DOMNode; -- <NUM NM="fxRecurringFrequencyCode" VL="10" TY="STRING"/>
  l_tmplXplNode  XMLDOM.DOMNode; -- <EXPLANATION>what</EXPLANATION>
  l_tmplComNode  XMLDOM.DOMNode; -- <COMPONENT id="" name="" type="" isPkgCmpnt="false"/>
  l_tmplDeNode   XMLDOM.DOMNode; -- <DELTA_EXPR NM="DF1" PREVIOUS="1" CURRENT="2"/>
  l_tmplConNode  XMLDOM.DOMNode; -- <CONNECTION id="1676995111" name="BtF" ref="FloorInBuilding" fromCompId="1676995126" fromCompName="Building-1" fromCompType="Building" toCompId="1676995128" toCompName="Floor-1" toCompType="Floor"/>

  /* *** delta_info part *** */

  TYPE cfg_item_rec_type IS RECORD
    (
    parent_config_item_id  CZ_CONFIG_ITEMS.parent_config_item_id%TYPE,
    ps_node_id             CZ_CONFIG_ITEMS.ps_node_id%TYPE,
    name                   CZ_CONFIG_ITEMS.name%TYPE,
    ps_node_name           CZ_CONFIG_ITEMS.ps_node_name%TYPE,
    comp_name              CZ_CONFIG_ITEMS.ps_node_name%TYPE,
    item_val               CZ_CONFIG_ITEMS.item_val%TYPE,
    item_num_val           CZ_CONFIG_ITEMS.item_num_val%TYPE
    );

  TYPE cfg_item_tbl_type IS TABLE OF cfg_item_rec_type INDEX BY VARCHAR2(15);--  Bug 6892148;
  TYPE vrchr_tbl_type IS TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);

  l_handled_nodes_tbl   vrchr_tbl_type;

  l_baseline_cfg_tbl          cfg_item_tbl_type;
  l_baseline_cfg_item         cfg_item_rec_type;

  l_delta_info_Node      xmldom.DOMNode;
  l_cfg_delta_Node       xmldom.DOMNode;

  l_components_Node      xmldom.DOMNode;
  l_choice_adds_Node     xmldom.DOMNode;
  l_choice_deletes_Node  xmldom.DOMNode;
  l_choice_changes_Node  xmldom.DOMNode;
  l_expr_changes_Node    xmldom.DOMNode;
  l_choice_prev_changes_Node xmldom.DOMNode;
  l_choice_curr_changes_Node xmldom.DOMNode;
  l_delta_expr_Node          xmldom.DOMNode;
  l_delta_cfgcompnode        xmldom.DOMNode;

  l_component_adds_Node       XMLDOM.DOMNode;
  l_component_deletes_Node    XMLDOM.DOMNode;
  l_tmp_Node                  XMLDOM.DOMNode;
  l_baseline_item_id          XMLDOM.DOMNode;
  l_parent_psn_type           NUMBER;
  l_changes_prev_chNode       XMLDOM.DOMNode;
  l_changes_curr_chNode       XMLDOM.DOMNode;
  l_delta_chNode              XMLDOM.DOMNode;
  l_name_xml_attr             xmldom.DOMAttr;
  l_delta_curr_numNode        XMLDOM.DOMNode;
  /* *** end of delta_info part *** */

--------------------------------------------------------------------------------
/* *** delta_info part *** */
PROCEDURE get_config_item_data
 (p_cfg_hdr_id       IN  NUMBER,
  p_cfg_rev_nbr      IN  NUMBER,
  x_cfg_tbl          OUT NOCOPY cfg_item_tbl_type) IS

BEGIN

  FOR i IN
    (SELECT config_item_id, instance_nbr, ps_node_id, name, value_type_code,
            ps_node_name, parent_config_item_id, item_val, item_num_val
       FROM cz_config_items
      START WITH config_hdr_id = p_cfg_hdr_id AND config_rev_nbr = p_cfg_rev_nbr
                 AND component_instance_type = ROOT AND deleted_flag='0'
      CONNECT BY config_hdr_id = p_cfg_hdr_id AND config_rev_nbr = p_cfg_rev_nbr
                 AND deleted_flag = '0' AND PRIOR config_item_id = parent_config_item_id)
  LOOP
    x_cfg_tbl(i.config_item_id).parent_config_item_id := i.parent_config_item_id;
    x_cfg_tbl(i.config_item_id).ps_node_id            := i.ps_node_id;
    x_cfg_tbl(i.config_item_id).name                  := i.name;
    x_cfg_tbl(i.config_item_id).ps_node_name          := i.ps_node_name;
    x_cfg_tbl(i.config_item_id).item_val              := i.item_val;
    x_cfg_tbl(i.config_item_id).item_num_val          := i.item_num_val;

    IF i.value_type_code = COMPONENT THEN

      IF i.parent_config_item_id IS NULL OR i.parent_config_item_id = NO_VALUE THEN
        x_cfg_tbl(i.config_item_id).comp_name := NVL(i.name, i.ps_node_name);
      ELSE
        x_cfg_tbl(i.config_item_id).comp_name := NVL(i.name, i.ps_node_name||'-'||TO_CHAR(i.instance_nbr));
      END IF;

    END IF;

  END LOOP;

END get_config_item_data;

/* *** end of delta_info part *** */

--------------------------------------------------------------------------------
-- <CONFIGURABLE_COMPONENT name="C1" component="C1"/>
FUNCTION newCfgComponentNode(p_name IN VARCHAR2, p_component IN VARCHAR2)
  RETURN XMLDOM.DOMNode
IS
  node   XMLDOM.DOMNode;
  attrs  XMLDOM.DOMNamedNodeMap;
BEGIN
  node := XMLDOM.cloneNode(l_tmplCcNode, FALSE);
  attrs := XMLDOM.getAttributes(node);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 0)), p_name);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 1)), p_component);
  RETURN node;
END newCfgComponentNode;

--------------------------------------------------------------------------------
/* *** delta_info part *** */
-- <COMPONENT name="C1" />
--   <CONFIG_DELTA>
--     <CHOICE_ADDS/>
--     <CHOICE_DELETES/>
--     <CHOICE_CHANGES>
--       <PREVIOUS/>
--       <CURRENT/>
--     </CHOICE_CHANGES>
--     <EXPR_CHANGES/>
--   </CONFIG_DELTA>
-- </COMPONENT>
PROCEDURE addDeltaComponentNode(p_id IN VARCHAR2, p_name IN VARCHAR2) IS

  l_name_xml_attr  xmldom.DOMAttr;
  l_tmp_xml_node   xmldom.DOMNode;

BEGIN

  --
  -- create tag <COMPONENTS>
  --
  l_components_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_COMPONENT));

  l_name_xml_attr := xmldom.createAttribute(l_doc, 'id');
  xmldom.setValue(l_name_xml_attr, p_id);
  l_name_xml_attr := xmldom.SetAttributeNode(xmldom.makeElement(l_components_Node),  l_name_xml_attr );

  l_name_xml_attr := xmldom.createAttribute(l_doc, 'name');
  xmldom.setValue(l_name_xml_attr, p_name);
  l_name_xml_attr := xmldom.SetAttributeNode(xmldom.makeElement(l_components_Node),  l_name_xml_attr );

  l_name_xml_attr := xmldom.createAttribute(l_doc, 'type');
  xmldom.setValue(l_name_xml_attr, '');
  l_name_xml_attr := xmldom.SetAttributeNode(xmldom.makeElement(l_components_Node),  l_name_xml_attr );

  --
  -- create tag <CONFIG_DELTA>
  --
  l_cfg_delta_Node := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_CONFIG_DELTA));

  --
  -- attach tag <CONFIG_DELTA> to tag <COMPONENTS>  :
  -- <COMPONENTS>
  --       |--- <CONFIG_DELTA>
  --
  l_tmp_xml_node := XMLDOM.appendChild(l_components_Node, l_cfg_delta_Node);

  --
  -- attach tag <CHOICE_ADDS> to tag <CONFIG_DELTA>  :
  -- <COMPONENTS>
  --       |--- <CONFIG_DELTA>
  --                 |-- <CHOICE_ADDS>
  --
  l_choice_adds_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_CHOICE_ADDS));
  l_tmp_xml_node := XMLDOM.appendChild(l_cfg_delta_Node, l_choice_adds_Node);

  --
  -- attach tag <CHOICE_DELETES> to tag <CONFIG_DELTA>  :
  -- <COMPONENTS>
  --       |--- <CONFIG_DELTA>
  --                 |-- <CHOICE_ADDS>
  --                 |-- <CHOICE_DELETES>
  --
  l_choice_deletes_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_CHOICE_DELETES));
  l_tmp_xml_node := XMLDOM.appendChild(l_cfg_delta_Node, l_choice_deletes_Node);

  --
  -- attach tag <CHOICE_CHANGES> to tag <CONFIG_DELTA>  :
  -- <COMPONENTS>
  --       |--- <CONFIG_DELTA>
  --                 |-- <CHOICE_ADDS>
  --                 |-- <CHOICE_DELETES>
  --                 |-- <CHOICE_CHANGES>
  --
  l_choice_changes_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_CHOICE_CHANGES));
  l_tmp_xml_node := XMLDOM.appendChild(l_cfg_delta_Node, l_choice_changes_Node);

  --
  -- attach tag <EXPR_CHANGES> to tag <CONFIG_DELTA>  :
  -- <COMPONENTS>
  --       |--- <CONFIG_DELTA>
  --                 |-- <CHOICE_ADDS>
  --                 |-- <CHOICE_DELETES>
  --                 |-- <CHOICE_CHANGES>
  --                           |-- <PREVIOUS>
  --                           |-- <CURRENT>
  --                 |-- <EXPR_CHANGES>
  l_expr_changes_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_EXPR_CHANGES));
  l_tmp_xml_node := XMLDOM.appendChild(l_cfg_delta_Node, l_expr_changes_Node);

  --
  -- attach tag <COMPONENT> to tag <DELTA_INFO>  :
  -- <COMPONENTS>
  l_tmp_xml_node := XMLDOM.appendChild(l_delta_info_Node, l_components_Node);

END addDeltaComponentNode;
/* *** end of delta_info part *** */

--------------------------------------------------------------------------------
-- <CH DP="OF1" DM="O2"> QTY="1.0"</CH>
FUNCTION newChoiceNode(p_optionFeature IN VARCHAR2
                      ,p_option        IN VARCHAR2
                      ,p_quantity      IN VARCHAR2)
  RETURN XMLDOM.DOMNode
IS
  node   XMLDOM.DOMNode;
  attrs  XMLDOM.DOMNamedNodeMap;
BEGIN
  node := XMLDOM.cloneNode(l_tmplChNode, FALSE);
  attrs := XMLDOM.getAttributes(node);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 0)), p_optionFeature);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 1)), p_option);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 3)), p_quantity);
  RETURN node;
END newChoiceNode;

--------------------------------------------------------------------------------
/* *** delta_info part *** */
PROCEDURE  attachPrevChoices(p_parent_config_item_id IN NUMBER, p_parent_name IN VARCHAR2, p_choice_Node xmldom.DOMNode) IS
  l_tmp_changes_chNode xmldom.DOMNode;
  l_tmp_xml_Node       xmldom.DOMNode;
BEGIN
  FOR fitm IN (SELECT ps_node_name,item_num_val FROM CZ_CONFIG_ITEMS
                WHERE config_hdr_id=p_baseline_config_hdr_id AND
                      config_rev_nbr=p_baseline_config_rev_nbr AND
                      deleted_flag='0' AND parent_config_item_id=p_parent_config_item_id AND
                       config_item_id NOT IN
                                (SELECT b.config_item_id FROM CZ_CONFIG_ITEMS b
                                  WHERE b.config_hdr_id=p_config_hdr_id AND
                                        b.config_rev_nbr=p_config_rev_nbr AND
                                        b.deleted_flag='0' AND b.parent_config_item_id=p_parent_config_item_id))
  LOOP
    l_tmp_changes_chNode := newChoiceNode(p_parent_name, fitm.ps_node_name, fitm.item_num_val);
    l_tmp_xml_Node := XMLDOM.appendChild(p_choice_Node, l_tmp_changes_chNode);
  END LOOP;
END attachPrevChoices;
/* *** end of delta_info part *** */

--------------------------------------------------------------------------------
-- <ATTR NM="">attrval</ATTR>
FUNCTION newAttributeNode(p_name  IN VARCHAR2, p_value IN VARCHAR2)
  RETURN XMLDOM.DOMNode
IS
  node   XMLDOM.DOMNode;
BEGIN
  node := XMLDOM.cloneNode(l_tmplAtNode, TRUE);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(XMLDOM.getAttributes(node), 0)), p_name);
  XMLDOM.setNodeValue(XMLDOM.getFirstChild(node), p_value);
  RETURN node;
END newAttributeNode;

--------------------------------------------------------------------------------
-- <NUM NM="fxRecurringFrequencyCode" VL="10" TY="STRING"/>
FUNCTION newNumNode(p_name  IN VARCHAR2
                   ,p_value IN VARCHAR2
                   ,p_type  IN VARCHAR2)
  RETURN XMLDOM.DOMNode
IS
  node   XMLDOM.DOMNode;
  attrs  XMLDOM.DOMNamedNodeMap;
BEGIN
  node := XMLDOM.cloneNode(l_tmplNumNode, FALSE);
  attrs := XMLDOM.getAttributes(node);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 0)), p_name);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 1)), p_value);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 2)), p_type);
  RETURN node;
END newNumNode;

--------------------------------------------------------------------------------

/* *** delta_info part *** */

PROCEDURE add_Expr_Node
(p_name      IN VARCHAR2,
 p_old_value IN VARCHAR2,
 p_new_value IN VARCHAR2,
 p_type      IN VARCHAR2) IS

  l_delta_curr_numNode xmldom.DOMNode;
  l_tempNode           xmldom.DOMNode;
  l_delta_expr_Node    xmldom.DOMNode;
  l_name_xml_attr      xmldom.DOMAttr;

BEGIN
  l_delta_curr_numNode := newNumNode(p_name, p_new_value, p_type);
  l_tempNode := XMLDOM.appendChild(l_choice_curr_changes_Node, l_delta_curr_numNode);

  l_delta_expr_Node := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_DELTA_EXPR));

  l_name_xml_attr := xmldom.createAttribute(l_doc, 'NM');
  xmldom.setValue(l_name_xml_attr, p_name);
  l_name_xml_attr := xmldom.SetAttributeNode( xmldom.makeElement(l_delta_expr_Node),  l_name_xml_attr );

  l_name_xml_attr := xmldom.createAttribute(l_doc, 'PREVIOUS');
  xmldom.setValue(l_name_xml_attr, p_old_value);
  l_name_xml_attr := xmldom.SetAttributeNode( xmldom.makeElement(l_delta_expr_Node),  l_name_xml_attr );

  l_name_xml_attr := xmldom.createAttribute(l_doc, 'CURRENT');
  xmldom.setValue(l_name_xml_attr, p_new_value);
  l_name_xml_attr := xmldom.SetAttributeNode( xmldom.makeElement(l_delta_expr_Node),  l_name_xml_attr );

  l_tempNode := XMLDOM.appendChild(l_expr_changes_Node, l_delta_expr_Node);
END add_Expr_Node;

/* *** end of delta_info part *** */

--------------------------------------------------------------------------------
-- <EXPLANATION>what</EXPLANATION>
FUNCTION newExplanationNode(p_explanation IN VARCHAR2)
  RETURN XMLDOM.DOMNode
IS
  node   XMLDOM.DOMNode;
BEGIN
  node := XMLDOM.cloneNode(l_tmplXplNode, TRUE);
  XMLDOM.setNodeValue(XMLDOM.getFirstChild(node), p_explanation);
  RETURN node;
END newExplanationNode;

--------------------------------------------------------------------------------
FUNCTION newViolationNode(p_msg_tbl v2k_tbl_type)
    RETURN XMLDOM.DOMNode
IS
  node XMLDOM.DOMNode;
  tempNode XMLDOM.DOMNode;
BEGIN
  node := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_VIOLATIONS));
  FOR i IN p_msg_tbl.FIRST .. p_msg_tbl.LAST LOOP
    tempNode := XMLDOM.appendChild(node, newExplanationNode(p_msg_tbl(i)));
  END LOOP;
  RETURN node;
END newViolationNode;

--------------------------------------------------------------------------------
-- <CONNECTION id="1676995111" name="BtF" ref="FloorInBuilding"
-- fromCompId="1676995126" fromCompName="Building-1" fromCompType="Building"
-- toCompId="1676995128" toCompName="Floor-1" toCompType="Floor"/>
FUNCTION newConnectorNode(p_conn_rec conn_rec_type)
    RETURN XMLDOM.DOMNode
IS
  node XMLDOM.DOMNode;
  attrs  XMLDOM.DOMNamedNodeMap;
BEGIN
  node := XMLDOM.cloneNode(l_tmplConNode, FALSE);
  attrs := XMLDOM.getAttributes(node);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 0)), p_conn_rec.id);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 1)), p_conn_rec.name);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 2)), p_conn_rec.ref);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 3)), p_conn_rec.fromCompID);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 4)), p_conn_rec.fromCompName);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 5)), p_conn_rec.fromCompType);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 6)), p_conn_rec.toCompID);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 7)), p_conn_rec.toCompName);
  XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(attrs, 8)), p_conn_rec.toCompType);
  RETURN node;
END newConnectorNode;

--------------------------------------------------------------------------------
PROCEDURE get_config_msg(p_hdr_id IN NUMBER, p_rev_nbr IN NUMBER)
IS
  l_msg_tbl v2k_tbl_type;
BEGIN
  FOR i IN (SELECT config_item_id, message
            FROM cz_config_messages
            WHERE config_hdr_id = p_hdr_id AND config_rev_nbr = p_rev_nbr AND deleted_flag = '0')
  LOOP
    IF l_cfg_msg_map.EXISTS(i.config_item_id) THEN
      l_cfg_msg_map(i.config_item_id)(l_cfg_msg_map(i.config_item_id).COUNT+1) := i.message;
    ELSE
      l_msg_tbl(1) := i.message;
      l_cfg_msg_map(i.config_item_id) := l_msg_tbl;
    END IF;
  END LOOP;
END get_config_msg;

--------------------------------------------------------------------------------
PROCEDURE get_connector_info(p_hdr_id IN NUMBER, p_rev_nbr IN NUMBER)
IS
  l_target_item_map v2k_tbl_type;
  l_conn_rec  conn_rec_type;
BEGIN
  FOR i IN (SELECT con.config_item_id conid, con.name conname, con.ps_node_name conpsname,
                   tgt.config_item_id tgtid, tgt.name tgtname, tgt.ps_node_name tgtpsname, tgt.instance_nbr tgtinsnbr
            FROM cz_config_items con, cz_config_items tgt
            WHERE con.config_hdr_id = p_hdr_id AND con.config_rev_nbr = p_rev_nbr AND con.deleted_flag = '0'
            AND   tgt.config_hdr_id = p_hdr_id and tgt.config_rev_nbr = p_rev_nbr AND tgt.deleted_flag = '0'
            AND   con.target_config_item_id = tgt.config_item_id
            AND   con.value_type_code = CONNECTOR)
  LOOP
    l_conn_rec.id := i.conid;
    l_conn_rec.name := i.conpsname;
    l_conn_rec.ref := NVL(i.conname, i.conpsname);
    l_conn_rec.toCompID := i.tgtid;
    l_conn_rec.toCompName := NVL(i.tgtname, i.tgtpsname||'-'||i.tgtinsnbr);
    l_conn_rec.toCompType := i.tgtpsname;
    l_conn_map(i.conid) := l_conn_rec;
  END LOOP;
END get_connector_info;

--------------------------------------------------------------------------------

PROCEDURE get_ps_nodes(p_model_id IN NUMBER)
IS
  l_type  INTEGER;
BEGIN
  FOR i IN (SELECT devl_project_id, ps_node_id, persistent_node_id, ps_node_type,
                   reference_id, feature_type, minimum, maximum, itm.orig_sys_ref osr
            FROM cz_ps_nodes psn, cz_item_masters itm
            WHERE psn.deleted_flag = '0' AND psn.devl_project_id IN
              (SELECT component_id FROM cz_model_ref_expls
               WHERE deleted_flag = '0' AND model_id = p_model_id
               AND (model_id = component_id OR ps_node_type = PS_NODE_TYPE_REFERENCE))
            AND psn.item_id = itm.item_id(+) AND '0' = itm.deleted_flag(+))
  LOOP
    l_type := i.ps_node_type;
    IF l_type = PS_NODE_TYPE_REFERENCE THEN
      l_ref_node_map(i.persistent_node_id) := i.reference_id;
    ELSIF l_type = PS_NODE_TYPE_FEATURE THEN
      IF i.feature_type = OPTION_FEATURE THEN
        IF i.minimum = 1 AND i.maximum = 1 THEN
          l_type := OPTION_FEATURE_1_1;
        ELSE
          l_type := OPTION_FEATURE_0_N;
        END IF;
      ELSIF i.feature_type = TEXT_FEATURE THEN
        l_type := TEXT_FEATURE;
      ELSE
        l_type := NUM_FEATURE;
      END IF;
    ELSIF l_type = PS_NODE_TYPE_TOTAL OR l_type = PS_NODE_TYPE_RESOURCE THEN
      l_type := NUM_FEATURE;
    END IF;

    IF i.osr IS NOT NULL AND instr(i.osr, 'PKG:') > 0 THEN
      l_prj_psn_osr_map(i.devl_project_id)(i.persistent_node_id) := substr(i.osr, 5);
      l_has_pkg_component := TRUE;
    END IF;
    l_prj_psn_type_map(i.devl_project_id)(i.persistent_node_id) := l_type;
  END LOOP;
END get_ps_nodes;

--------------------------------------------------------------------------------
PROCEDURE get_properties(p_model_id IN NUMBER)
IS
  l_val   cz_ps_prop_vals.data_value%TYPE;
  l_prp_count  INTEGER;
BEGIN
  FOR i IN (SELECT prp.property_id id, prp.name name, prp.data_type type, prp.def_value defval,
                   psp.data_value strval, prp.def_num_value defnumval, psp.data_num_value numval,
                   psn.devl_project_id project, psn.persistent_node_id persistentid
            FROM cz_ps_nodes psn, cz_ps_prop_vals psp, cz_properties prp
            WHERE psn.deleted_flag = '0' AND psn.devl_project_id IN
              (SELECT component_id FROM cz_model_ref_expls
               WHERE deleted_flag = '0' AND model_id = p_model_id
               AND (model_id = component_id OR ps_node_type = PS_NODE_TYPE_REFERENCE))
            AND psp.deleted_flag = '0' AND psp.ps_node_id = psn.ps_node_id
            AND prp.deleted_flag = '0' AND prp.property_id = psp.property_id
            AND prp.data_type <> TRANSLATABLE_TEXT
            UNION ALL
            SELECT prp.property_id id, prp.name name, prp.data_type type, deftxt.text_str defval,
                   txt.text_str strval, prp.def_num_value defnumval, psp.data_num_value numval,
                   psn.devl_project_id project, psn.persistent_node_id persistentid
            FROM cz_ps_nodes psn, cz_ps_prop_vals psp, cz_properties prp,
                 cz_intl_texts deftxt, cz_intl_texts txt
            WHERE psn.deleted_flag = '0' AND psn.devl_project_id IN
              (SELECT component_id FROM cz_model_ref_expls
               WHERE deleted_flag = '0' AND model_id = p_model_id
               AND (model_id = component_id OR ps_node_type = PS_NODE_TYPE_REFERENCE))
            AND psp.deleted_flag = '0' AND psp.ps_node_id = psn.ps_node_id
            AND prp.deleted_flag = '0' AND prp.property_id = psp.property_id
            AND prp.data_type = TRANSLATABLE_TEXT
            AND prp.def_num_value = deftxt.intl_text_id
            AND psp.data_num_value = txt.intl_text_id )
  LOOP
    IF i.type = NON_TRANSLATABLE_TEXT OR i.type = TRANSLATABLE_TEXT THEN
      l_val := NVL(i.strval, i.defval);
    ELSE
      l_val := NVL(i.numval, i.defnumval);
    END IF;

    IF l_prj_psn_prp_map.EXISTS(i.project) AND l_prj_psn_prp_map(i.project).EXISTS(i.persistentid) THEN
      l_prp_count := l_prj_psn_prp_map(i.project)(i.persistentid).COUNT + 1;
    ELSE
      l_prp_count := 1;
    END IF;
    -- l_prj_psn_prp_map(i.project)(i.persistentid)(i.id).name := i.name;
    -- l_prj_psn_prp_map(i.project)(i.persistentid)(i.id).val  := l_val;
    l_prj_psn_prp_map(i.project)(i.persistentid)(l_prp_count).name := i.name;
    l_prj_psn_prp_map(i.project)(i.persistentid)(l_prp_count).val  := l_val;
  END LOOP;
END get_properties;

--------------------------------------------------------------------------------

FUNCTION construct_init_xml(p_hdr_id        IN NUMBER
                           ,p_rev_nbr       IN NUMBER
                           ,p_product_key   IN VARCHAR2
                           ,p_is_valid      IN BOOLEAN
                           ,p_rpt_recur_prc IN BOOLEAN
                           ,p_rpt_delta     IN BOOLEAN
                           )
   RETURN VARCHAR2
IS
  l_config        VARCHAR2(30);
  l_rootComp      VARCHAR2(400);
  l_valid         VARCHAR2(50);
  l_sectionMain   VARCHAR2(1000);
  l_sectionPkg    VARCHAR2(100);
  l_sectionPrice  VARCHAR2(1000);
  l_sectionDelta  VARCHAR2(1000);
  l_xml           VARCHAR2(10000);
  l_templates     VARCHAR2(1000);
BEGIN
  l_config := to_char(p_hdr_id) || ':' || to_char(p_rev_nbr);
  l_rootComp := '<CONFIGURABLE_COMPONENT name="'||p_product_key||'" component="'||p_product_key||'">';

  l_sectionPkg := '<SECTION nm="Package Components">' || fnd_global.newline
     || '<COMPONENTS>'              || fnd_global.newline
     || '</COMPONENTS>'             || fnd_global.newline
     || '</SECTION>';

  IF p_rpt_recur_prc THEN
    l_sectionPrice := '<SECTION nm="Recurring Price">' || fnd_global.newline
       || '<COMPONENTS>' || fnd_global.newline
       || l_rootComp || fnd_global.newline
       || '<CONFIGURATION>' || fnd_global.newline
       || '<NUMERIC_VALUES>' || fnd_global.newline
     --  || '<NUM NM="fxRecurringFrequencyCode" VL="10" TY="STRING"/>' || fnd_global.newline
     --  || '<NUM NM="fxRecurringFrequencyText" VL="Monthly" TY="STRING"/>' || fnd_global.newline
     --  || '<NUM NM="exRecurringPrice" VL="52.0" TY="DOUBLE"/>' || fnd_global.newline
       || '</NUMERIC_VALUES>' || fnd_global.newline
       || '</CONFIGURATION>'  || fnd_global.newline
       || '</CONFIGURABLE_COMPONENT>' || fnd_global.newline
       || '</COMPONENTS>' || fnd_global.newline
       || '</SECTION>';
  END IF;

/*
  IF p_rpt_delta THEN
    l_sectionDelta := '<DELTA_INFO>' || fnd_global.newline
      || '<COMPONENT id="" name="" type="" isPkgCmpnt="false">' || fnd_global.newline
      || '<CONFIG_DELTA>'  || fnd_global.newline
      || '</CONFIG_DELTA>' || fnd_global.newline
      || '</COMPONENT>'    || fnd_global.newline
      || '</DELTA_INFO>';
  END IF;
 */

  IF p_is_valid THEN
    l_valid := 'hasViolations="false" isValid="true"';
  ELSE
    l_valid := 'hasViolations="true" isValid="false"';
  END IF;
  l_sectionMain := '<SECTION nm="Main">' || fnd_global.newline
      || '<COMPONENTS>'  || fnd_global.newline
   --   || l_rootComp || fnd_global.newline
   --   || '<CONFIGURATION><CHOICES/></CONFIGURATION>' || fnd_global.newline
   --   || '</CONFIGURABLE_COMPONENT>'||fnd_global.newline
      || '</COMPONENTS>'            || fnd_global.newline
      || '<STRUCTURE>'              || fnd_global.newline
   --   || l_rootComp                || fnd_global.newline
   --   || '</CONFIGURABLE_COMPONENT>' || fnd_global.newline
      || '</STRUCTURE>'             || fnd_global.newline
      || '</SECTION>';

  l_templates := '<templates>' || fnd_global.newline
      || '<CONFIGURABLE_COMPONENT name="" component=""></CONFIGURABLE_COMPONENT>' || fnd_global.newline
      || '<CH DP="" DM="" ST="66" QTY=""/>' || fnd_global.newline
      || '<ATTR NM="">a</ATTR>'             || fnd_global.newline
      || '<NUM NM="" VL="" TY=""/>' || fnd_global.newline
      || '<EXPLANATION>Whatever</EXPLANATION>' || fnd_global.newline
      || '<COMPONENT id="" name="" type="" isPkgCmpnt="false"/>' || fnd_global.newline
      || '<DELTA_EXPR NM="" PREVIOUS="" CURRENT=""/>' || fnd_global.newline
      || '<CONNECTION id="" name="" ref="" fromCompId="" fromCompName="" fromCompType="" toCompId="" toCompName="" toCompType=""/>' || fnd_global.newline
      || '</templates>';

  l_xml := '<CONFIG_DETAILS configId="' || l_config ||'" solutionId="'||p_product_key||'" '
      || l_valid || ' TOTAL_PRICE="">' || fnd_global.newline
      || l_templates                   || fnd_global.newline
      || l_sectionMain                 || fnd_global.newline
      || l_sectionPkg;
  IF l_sectionPrice IS NOT NULL THEN
    l_xml := l_xml || fnd_global.newline || l_sectionPrice;
  END IF;

/*
  IF l_sectionDelta IS NOT NULL THEN
    l_xml := l_xml || fnd_global.newline || l_sectionDelta;
  END IF;
*/

  l_xml := l_xml || fnd_global.newline || '</CONFIG_DETAILS>';
  RETURN l_xml;
END construct_init_xml;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- begin get_config_details
BEGIN
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_ndebug:=0;
  l_log_stmt := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF l_log_stmt THEN
    l_msg := 'inputs: hdr=' || p_config_hdr_id ||':' || p_config_rev_nbr
          ||       ', prd=' || p_product_key || ', appl=' || p_application_id;
  END IF;

  BEGIN
    SELECT component_id, config_status, has_failures
      INTO l_model_id, l_config_status, l_has_failures
    FROM cz_config_hdrs
    WHERE config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
    AND deleted_flag = '0' AND component_instance_type = ROOT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('CZ', 'CZ_NO_CFG_HDR');
      fnd_message.set_token('id', p_config_hdr_id);
      fnd_message.set_token('rev', p_config_rev_nbr);
      fnd_message.set_token('type', 'R');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  l_ndebug:=10;
  -- check if config source model as well as all its child models is available
  BEGIN
    SELECT devl_project_id INTO l_model_id
    FROM cz_devl_projects
    WHERE devl_project_id = l_model_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_model_id := NULL;
  END;

  IF l_model_id IS NOT NULL THEN
    BEGIN
      SELECT NULL INTO l_model_id
      FROM cz_model_ref_expls re
      WHERE deleted_flag = '0' AND model_id = l_model_id
      AND ps_node_type = PS_NODE_TYPE_REFERENCE
      AND NOT EXISTS (SELECT 1 FROM cz_devl_projects
                      WHERE deleted_flag = '0' AND devl_project_id = re.component_id)
      AND ROWNUM < 2;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

  l_ndebug:=20;
  IF l_model_id IS NULL THEN
    l_msg := 'Perform publication lookup';
    cz_cf_api.default_restored_cfg_dates(p_config_hdr_id  => p_config_hdr_id
                                        ,p_config_rev_nbr => p_config_rev_nbr
                                        ,p_creation_date  => l_creation_date
                                        ,p_lookup_date    => l_lookup_date
                                        ,p_effective_date => l_effective_date);
    l_model_id := cz_cf_api.config_model_for_product(product_key            => p_product_key
                                                    ,config_lookup_date     => l_lookup_date
                                                    ,calling_application_id => p_application_id
                                                    ,usage_name             => NULL);
    IF l_model_id IS NULL THEN
      fnd_message.set_name('CZ', 'CZ_NO_PUB_MODEL');
      fnd_message.set_token('PRDKEY', p_product_key);
      fnd_message.set_token('APPLID', p_application_id);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  l_ndebug:=30;
  l_has_pkg_component := FALSE;
  get_ps_nodes(l_model_id);
  -- print_refnode_map(l_ref_node_map);
  -- print_psnode_map(l_prj_psn_type_map);
  -- print_psnode_map(l_prj_psn_osr_map);

  l_ndebug:=40;
  get_properties(l_model_id);
  -- print_prp_map(l_prj_psn_prp_map);

  l_ndebug:=50;
  l_is_valid := l_config_status = COMPLETE AND l_has_failures = '0';

  IF p_check_violation_flag = FND_API.G_TRUE AND l_has_failures <> '0' THEN
    get_config_msg(p_config_hdr_id, p_config_rev_nbr);
    -- print_msg_map;
  END IF;

  l_ndebug:=60;
  IF p_check_connection_flag = FND_API.G_TRUE THEN
    get_connector_info(p_config_hdr_id, p_config_rev_nbr);
  END IF;

  l_ndebug:=70;
  l_check_delta := FALSE;
  IF p_baseline_config_hdr_id IS NOT NULL AND p_baseline_config_rev_nbr IS NOT NULL THEN
    l_check_delta := TRUE;
    BEGIN
      SELECT 1 INTO l_count
      FROM cz_config_hdrs
      WHERE config_hdr_id = p_baseline_config_hdr_id AND config_rev_nbr = p_baseline_config_rev_nbr
      AND deleted_flag = '0' AND component_instance_type = ROOT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('CZ', 'CZ_NO_BASE_CFG_HDR');
        fnd_message.set_token('id', p_config_hdr_id);
        fnd_message.set_token('rev', p_config_rev_nbr);
        fnd_message.set_token('type', 'R');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END;

  END IF;

  l_ndebug:=80;
  l_rpt_total_price := FALSE;
  l_rpt_recur_price := FALSE;
  IF p_price_info_list IS NOT NULL AND p_price_info_list.COUNT > 0 THEN
    IF p_price_info_list(1) IS NOT NULL THEN
      l_rpt_total_price := TRUE;
    END IF;

    IF p_price_info_list.COUNT > 1 AND p_price_info_list(2) IS NOT NULL THEN
      l_rpt_recur_price := TRUE;
    END IF;
  END IF;

  l_init_xml_str := construct_init_xml(p_config_hdr_id
                                      ,p_config_rev_nbr
                                      ,p_product_key
                                      ,l_is_valid
                                      ,l_rpt_recur_price
                                      ,l_check_delta
                                      );

  l_ndebug:=90;
  l_doc := XMLDOM.newDomDocument(XMLType(l_init_xml_str));
  l_docelm := XMLDOM.getDocumentElement(l_doc);
  l_sections := XMLDOM.getChildNodes(XMLDOM.makeNode(l_docelm));

  l_templateNode := XMLDOM.item(l_sections, 0);
  l_tmplNodes   := XMLDOM.getChildNodes(l_templateNode);
  l_tmplCcNode  := xmldom.item(l_tmplNodes, 0);
  l_tmplChNode  := xmldom.item(l_tmplNodes, 1);
  l_tmplAtNode  := xmldom.item(l_tmplNodes, 2);
  l_tmplNumNode := xmldom.item(l_tmplNodes, 3);
  l_tmplXplNode := xmldom.item(l_tmplNodes, 4);
  l_tmplComNode := xmldom.item(l_tmplNodes, 5);
  l_tmplDeNode  := xmldom.item(l_tmplNodes, 6);
  l_tmplConNode := xmldom.item(l_tmplNodes, 7);

  l_sectionMainNode := XMLDOM.item(l_sections, 1);             -- <SECTION nm="Main">
  l_componentsNode := XMLDOM.getFirstChild(l_sectionMainNode); --   <COMPONENTS>
  l_structNode := XMLDOM.getNextSibling(l_componentsNode);     --   <STRUCTURE>

  IF l_has_pkg_component THEN
    l_pkgComponentsNode := XMLDOM.getFirstChild(XMLDOM.item(l_sections, 2));
  END IF;

  IF l_rpt_recur_price THEN                         -- <SECTION nm="Recurring Price">
    IF l_has_pkg_component THEN
      l_prcNumericValuesNode := XMLDOM.getFirstChild(XMLDOM.getFirstChild(XMLDOM.getFirstChild(XMLDOM.getFirstChild(XMLDOM.item(l_sections, 3)))));
    ELSE
      l_prcNumericValuesNode := XMLDOM.getFirstChild(XMLDOM.getFirstChild(XMLDOM.getFirstChild(XMLDOM.getFirstChild(XMLDOM.item(l_sections, 2)))));
    END IF;
  END IF;

  /* *** delta_info part *** */
  IF l_check_delta THEN
    l_delta_info_Node := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_DELTA_INFO));

    l_component_adds_Node := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_COMPONENT_ADDS));

    l_component_deletes_Node := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_COMPONENT_DELETES));

    l_tmp_Node := XMLDOM.appendChild(l_delta_info_Node, l_component_adds_Node);

    l_tmp_Node := XMLDOM.appendChild(l_delta_info_Node, l_component_deletes_Node);

    l_tmp_Node := XMLDOM.appendChild(xmldom.makeNode(l_docelm), l_delta_info_Node);

    get_config_item_data(p_baseline_config_hdr_id, p_baseline_config_rev_nbr, l_baseline_cfg_tbl);

    FOR itm IN(SELECT parent_config_item_id,name,ps_node_name,instance_nbr FROM CZ_CONFIG_ITEMS
                WHERE config_hdr_id=p_baseline_config_hdr_id AND
                      config_rev_nbr=p_baseline_config_rev_nbr AND
                      value_type_code = COMPONENT AND
                      deleted_flag='0' AND
                      (config_item_id,item_num_val) NOT IN
                      (SELECT a.config_item_id,a.item_num_val FROM CZ_CONFIG_ITEMS a
                        WHERE a.config_hdr_id=p_config_hdr_id AND
                              a.config_rev_nbr=p_config_rev_nbr AND
                              a.value_type_code = COMPONENT AND
                              a.deleted_flag='0')
               )
    LOOP
      IF itm.parent_config_item_id IS NULL OR itm.parent_config_item_id = NO_VALUE THEN
        l_comp_name := NVL(itm.name, itm.ps_node_name);
      ELSE
        l_comp_name := NVL(itm.name, itm.ps_node_name||'-'||itm.instance_nbr);
      END IF;

      l_delta_cfgCompNode := newCfgComponentNode(l_comp_name, itm.ps_node_name);
      l_tmp_Node := XMLDOM.appendChild(l_component_deletes_Node, l_delta_cfgCompNode);
    END LOOP;

  END IF;
  /* *** end of delta_info part *** */

  l_ndebug:=100;
  -- Todo: may be we can use a single query for both i and j
  FOR i IN
    (SELECT config_item_id, instance_nbr, ps_node_id, name, ps_node_name, parent_config_item_id
     FROM cz_config_items
     WHERE deleted_flag = '0' AND value_type_code = COMPONENT
     START WITH config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
       AND component_instance_type = ROOT
     CONNECT BY config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
       AND deleted_flag = '0' AND PRIOR config_item_id = parent_config_item_id)
  LOOP
    l_configurationNode := NULL;
    l_choicesNode := NULL;
    l_numericValuesNode := NULL;
    l_is_root_comp := FALSE;
    IF i.parent_config_item_id IS NULL OR i.parent_config_item_id = NO_VALUE THEN
      l_is_root_comp := TRUE;
    END IF;

    -- create comp node for components and structure
    IF l_is_root_comp THEN
      l_comp_name := NVL(i.name, i.ps_node_name);
    ELSE
      l_model_id := l_item_prj_map(i.parent_config_item_id);
      l_comp_name := NVL(i.name, i.ps_node_name||'-'||i.instance_nbr);
    END IF;
    l_cfgCompNode := newCfgComponentNode(l_comp_name, i.ps_node_name);
    l_tempNode := XMLDOM.appendChild(l_componentsNode, l_cfgCompNode);
    l_structCfgCompNode := XMLDOM.cloneNode(l_cfgCompNode, TRUE);
    l_domnode_map(i.config_item_id) := l_structCfgCompNode;
    IF l_is_root_comp THEN
      l_tempNode := XMLDOM.appendChild(l_structNode, l_structCfgCompNode);
    ELSE
      l_tempNode := XMLDOM.appendChild(l_domnode_map(i.parent_config_item_id), l_structCfgCompNode);
    END IF;

    l_pkgConfigurationNode := NULL;
    l_pkgCfgCompNode := NULL;
    l_is_pkg_component := l_prj_psn_osr_map.EXISTS(l_model_id) AND l_prj_psn_osr_map(l_model_id).EXISTS(i.ps_node_id);
    IF l_is_pkg_component THEN
      l_pkgCfgCompNode := XMLDOM.cloneNode(l_cfgCompNode, TRUE);
      l_tempnode := XMLDOM.appendChild(l_pkgComponentsNode, l_pkgCfgCompNode);
    END IF;

    l_com_msg_tbl.DELETE;
    IF l_cfg_msg_map.EXISTS(i.config_item_id) THEN
      l_com_msg_tbl := l_cfg_msg_map(i.config_item_id);
    END IF;

    -- Could non-option node (e.g., features) have attribute?
    -- If no, we can check attrs for this component here
    -- Else need to do the check at the end of processing this subtree

    IF l_ref_node_map.EXISTS(i.ps_node_id) THEN
      l_model_id := l_ref_node_map(i.ps_node_id);
    END IF;
    l_item_prj_map(i.config_item_id) := l_model_id;

    /* *** delta_info part *** */
    IF l_check_delta THEN

      IF NOT(l_baseline_cfg_tbl.EXISTS(i.config_item_id)) THEN
        l_delta_cfgCompNode := newCfgComponentNode(l_comp_name, i.ps_node_name);
        l_tmp_Node := XMLDOM.appendChild(l_component_adds_Node, l_delta_cfgCompNode);
      ELSE
        addDeltaComponentNode(TO_CHAR(i.config_item_id), l_comp_name);
      END IF;
    END IF;
    /* *** end of delta_info part *** */

    l_ndebug:=200;
    l_parent_item := NULL;
    l_parent_name := NULL;

    l_handled_nodes_tbl.DELETE;

    FOR j IN
      (SELECT config_item_id, parent_config_item_id, ps_node_id, ps_node_name, item_num_val, item_val
       FROM cz_config_items
       WHERE deleted_flag = '0'
       START WITH config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
         AND parent_config_item_id = i.config_item_id AND value_type_code <> COMPONENT
         -- AND config_item_id = i.config_item_id
       CONNECT BY config_hdr_id = p_config_hdr_id and config_rev_nbr = p_config_rev_nbr
         AND deleted_flag = '0' AND value_type_code <> COMPONENT
         AND PRIOR config_item_id = parent_config_item_id)
    LOOP

      l_exists_in_baseline := l_baseline_cfg_tbl.EXISTS(j.config_item_id);

      l_chNode := NULL;
      l_numNode := NULL;
      l_connNode := NULL;
      l_pkgChNode := NULL;
      IF l_is_root_comp THEN
        IF l_rpt_total_price AND j.ps_node_name = p_price_info_list(1) THEN
          XMLDOM.setValue(XMLDOM.makeAttr(XMLDOM.item(XMLDOM.getAttributes(XMLDOM.makeNode(l_docelm)), 4)), j.item_num_val);
        ELSIF l_rpt_recur_price AND
          (p_price_info_list.COUNT > 1 AND j.ps_node_name = p_price_info_list(2) OR
           p_price_info_list.COUNT > 2 AND j.ps_node_name = p_price_info_list(3) OR
           p_price_info_list.COUNT > 3 AND j.ps_node_name = p_price_info_list(4)) THEN
          l_typeAttrVal := 'STRING';
          IF j.item_val IS NULL AND j.item_num_val IS NOT NULL THEN
            l_typeAttrVal := 'DOUBLE';
          END IF;
          l_tempnode := XMLDOM.appendChild(l_prcNumericValuesNode,
              newNumNode(j.ps_node_name, nvl(j.item_val, to_char(j.item_num_val)), l_typeAttrVal));
        END IF;
      END IF;

      l_ndebug:=210;
      l_is_pkg_component := l_prj_psn_osr_map.EXISTS(l_model_id) AND
                            l_prj_psn_osr_map(l_model_id).EXISTS(j.ps_node_id);
      l_psn_type := l_prj_psn_type_map(l_model_id)(j.ps_node_id);

      IF l_psn_type = OPTION_FEATURE_1_1 OR l_psn_type = OPTION_FEATURE_0_N THEN
        l_parent_item := j.config_item_id;
        l_parent_name := j.ps_node_name;
        l_parent_psn_type := l_psn_type;
      ELSIF l_psn_type = PS_NODE_TYPE_OPTION THEN
        IF XMLDOM.isNull(l_configurationNode) THEN
          l_configurationNode := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_CONFIGURATION));
          l_tempNode := XMLDOM.appendChild(l_cfgCompNode, l_configurationNode);
        END IF;

        IF XMLDOM.isNull(l_choicesNode) THEN
          l_choicesNode := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_CHOICES));
          l_tempNode := XMLDOM.appendChild(l_configurationNode, l_choicesNode);
        END IF;

        l_chNode := newChoiceNode(l_parent_name, j.ps_node_name, j.item_num_val);
        l_tempNode := XMLDOM.appendChild(l_choicesNode, l_chNode);

        /* *** delta_info part *** */
        IF l_check_delta AND l_exists_in_baseline=FALSE THEN

          IF l_parent_psn_type=OPTION_FEATURE_1_1 THEN

            l_delta_choice_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_DELTA_CHOICE));
            l_tempNode := XMLDOM.appendChild(l_choice_changes_Node, l_delta_choice_Node);
            xmldom.setAttribute(xmldom.makeElement(l_delta_choice_Node), 'DP', l_parent_name);

            l_choice_prev_changes_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_PREVIOUS));
            l_tempNode := XMLDOM.appendChild(l_delta_choice_Node, l_choice_prev_changes_Node);

            l_choice_curr_changes_Node := XMLDOM.makeNode(xmldom.createElement(l_doc, TAG_CURRENT));
            l_tempNode := XMLDOM.appendChild(l_delta_choice_Node, l_choice_curr_changes_Node);

            l_changes_curr_chNode := newChoiceNode(l_parent_name, j.ps_node_name, j.item_num_val);
            l_tempNode := XMLDOM.appendChild(l_choice_curr_changes_Node, l_changes_curr_chNode);

            IF NOT(l_handled_nodes_tbl.EXISTS(l_parent_name)) THEN

              attachPrevChoices(j.parent_config_item_id,l_parent_name,l_choice_prev_changes_Node);
              l_handled_nodes_tbl(l_parent_name) := l_parent_name;
            END IF;

          ELSIF l_parent_psn_type=OPTION_FEATURE_0_N THEN

            l_delta_chNode := newChoiceNode(l_parent_name,
                                            j.ps_node_name,
                                            j.item_num_val);
            l_tempNode := XMLDOM.appendChild(l_choice_adds_Node, l_delta_chNode);

            IF NOT(l_handled_nodes_tbl.EXISTS(l_parent_name)) THEN
              attachPrevChoices(j.parent_config_item_id,l_parent_name,l_choice_deletes_Node);
              l_handled_nodes_tbl(l_parent_name) := l_parent_name;
            END IF;

          END IF;

        END IF;
        /* *** end of delta_info part *** */

        IF l_is_pkg_component THEN
          IF XMLDOM.isNull(l_pkgCfgCompNode) THEN
            l_pkgCfgCompNode := newCfgComponentNode(NVL(i.name, i.ps_node_name||'-'||i.instance_nbr), i.ps_node_name);
            l_tempnode := XMLDOM.appendChild(l_pkgComponentsNode, l_pkgCfgCompNode);
          END IF;
          IF XMLDOM.isNull(l_pkgConfigurationNode) THEN
            l_pkgConfigurationNode := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_CONFIGURATION));
            l_tempNode := XMLDOM.appendChild(l_pkgCfgCompNode, l_pkgConfigurationNode);
          END IF;
          IF XMLDOM.isNull(l_pkgChoicesNode) THEN
            l_pkgChoicesNode := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_CHOICES));
            l_tempNode := XMLDOM.appendChild(l_pkgConfigurationNode, l_pkgChoicesNode);
          END IF;
          l_pkgChNode := XMLDOM.cloneNode(l_chNode, true);
          l_tempNode := XMLDOM.appendChild(l_pkgChoicesNode, l_pkgChNode);
        END IF;
      ELSIF l_psn_type = PS_NODE_TYPE_CONNECTOR THEN -- l_conn_map.EXISTS(j.config_item_id)
        l_conn_map(j.config_item_id).fromCompID := i.config_item_id;
        l_conn_map(j.config_item_id).fromCompName := NVL(i.name, i.ps_node_name||'-'||i.instance_nbr);
        l_conn_map(j.config_item_id).fromCompType := i.ps_node_name;
        l_connNode := newConnectorNode(l_conn_map(j.config_item_id));
        l_tempNode := XMLDOM.appendChild(l_CfgCompNode, l_connNode);
        l_tempNode := XMLDOM.appendChild(l_structCfgCompNode, XMLDOM.cloneNode(l_connNode, FALSE));
      ELSE

        IF XMLDOM.isNull(l_configurationNode) THEN
          l_configurationNode := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_CONFIGURATION));
          l_tempNode := XMLDOM.appendChild(l_cfgCompNode, l_configurationNode);
        END IF;
        IF XMLDOM.isNull(l_numericValuesNode) THEN
          l_numericValuesNode := XMLDOM.makeNode(XMLDOM.createElement(l_doc, TAG_NUMERIC_VALUES));
          l_tempNode := XMLDOM.appendChild(XMLDOM.getFirstChild(l_cfgCompNode), l_numericValuesNode);
        END IF;
        IF l_prj_psn_type_map(l_model_id)(j.ps_node_id) = TEXT_FEATURE THEN
          l_numNode := newNumNode(j.ps_node_name, j.item_val, 'String');

          /* *** delta_info part *** */
         IF l_check_delta AND l_exists_in_baseline THEN

           IF l_baseline_cfg_tbl(j.config_item_id).item_val<>j.item_val THEN

             add_Expr_Node(p_name      => j.ps_node_name,
                           p_old_value => l_baseline_cfg_tbl(j.config_item_id).item_val,
                           p_new_value => j.item_val,
                           p_type      => 'STRING');

           END IF;

         END IF;
         /* *** end of delta_info part *** */

        ELSE
          l_numNode := newNumNode(j.ps_node_name, j.item_num_val, 'Double');

         /* *** delta_info part *** */
         IF l_check_delta AND l_exists_in_baseline THEN

           IF l_baseline_cfg_tbl(j.config_item_id).item_num_val<>j.item_num_val THEN

             add_Expr_Node(p_name      => j.ps_node_name,
                           p_old_value => TO_CHAR(l_baseline_cfg_tbl(j.config_item_id).item_num_val),
                           p_new_value => TO_CHAR(j.item_num_val),
                           p_type      => 'DOUBLE');

           END IF;

         END IF;
         /* *** end of delta_info part *** */

        END IF;
        l_tempNode := XMLDOM.appendChild(l_numericValuesNode, l_numNode);
      END IF;

      l_ndebug:=220;
      l_msg_tbl.DELETE;
      IF l_cfg_msg_map.EXISTS(j.config_item_id) THEN
        l_msg_tbl := l_cfg_msg_map(j.config_item_id);
        IF l_psn_type IN (PS_NODE_TYPE_OPTION,NUM_FEATURE,TEXT_FEATURE,PS_NODE_TYPE_CONNECTOR) THEN
          l_violationNode := newViolationNode(l_msg_tbl);
        END IF;
        IF l_psn_type = PS_NODE_TYPE_OPTION THEN
          l_tempnode := XMLDOM.appendChild(l_chNode, l_violationNode);
        ELSIF l_psn_type = NUM_FEATURE OR l_psn_type = TEXT_FEATURE THEN
          l_tempNode := XMLDOM.appendChild(l_numNode, l_violationNode);
        ELSIF l_psn_type = PS_NODE_TYPE_CONNECTOR THEN
          l_tempNode := XMLDOM.appendChild(l_connNode, l_violationNode);
        ELSE
          l_count := l_com_msg_tbl.COUNT;
          FOR m IN l_msg_tbl.FIRST .. l_msg_tbl.LAST LOOP
            l_count := l_count + 1;
            l_com_msg_tbl(l_count) := l_msg_tbl(m);
          END LOOP;
        END IF;
      END IF;

      l_ndebug:=230;
      IF l_prj_psn_prp_map.EXISTS(l_model_id) AND l_prj_psn_prp_map(l_model_id).EXISTS(j.ps_node_id) THEN
        l_prp_tbl := l_prj_psn_prp_map(l_model_id)(j.ps_node_id);
        l_count := l_com_att_tbl.COUNT;
        l_leadAttrNodeCreated := FALSE;
        FOR n IN l_prp_tbl.FIRST .. l_prp_tbl.LAST LOOP
          IF l_psn_type IN (PS_NODE_TYPE_OPTION,NUM_FEATURE,TEXT_FEATURE,PS_NODE_TYPE_CONNECTOR) THEN
            l_attrNode := newAttributeNode(l_prp_tbl(n).name, l_prp_tbl(n).val);
          END IF;
          IF l_psn_type = PS_NODE_TYPE_OPTION THEN
            l_tempnode := XMLDOM.appendChild(l_chNode, l_attrNode);
            IF l_is_pkg_component THEN
              IF NOT l_leadAttrNodeCreated THEN
                l_pkgAttrNode := newAttributeNode('0101', l_prj_psn_osr_map(l_model_id)(j.ps_node_id));
                l_tempnode := XMLDOM.appendChild(l_pkgChNode, l_pkgAttrNode);
                l_leadAttrNodeCreated := TRUE;
              END IF;
              l_tempnode := XMLDOM.appendChild(l_pkgChNode, XMLDOM.cloneNode(l_attrNode, true));
            END IF;
          ELSIF l_psn_type = NUM_FEATURE OR l_psn_type = TEXT_FEATURE THEN
            l_tempNode := XMLDOM.appendChild(l_numNode, l_attrNode);
          ELSIF l_psn_type = PS_NODE_TYPE_CONNECTOR THEN
            l_tempNode := XMLDOM.appendChild(l_connNode, l_attrNode);
          ELSIF l_psn_type <> OPTION_FEATURE_1_1 AND l_psn_type <> OPTION_FEATURE_0_N THEN
            l_count := l_count + 1;
            l_com_att_tbl(l_count) := l_prp_tbl(n);
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    IF l_is_root_comp AND l_config_status <> COMPLETE THEN
      l_com_msg_tbl(0):=cz_utils.get_text('CZ_CFG_INCOMPLETE', 'id', p_config_hdr_id, 'rev', p_config_rev_nbr);
    END IF;

    IF l_com_msg_tbl.COUNT > 0 THEN
      l_violationNode := newViolationNode(l_com_msg_tbl);
      l_tempnode := XMLDOM.appendChild(XMLDOM.getFirstChild(l_cfgCompNode), l_violationNode);
    END IF;

    IF l_prj_psn_prp_map.EXISTS(l_model_id) AND l_prj_psn_prp_map(l_model_id).EXISTS(i.ps_node_id) THEN
      l_prp_tbl := l_prj_psn_prp_map(l_model_id)(i.ps_node_id);
      l_count := l_com_att_tbl.COUNT;
      FOR k IN l_prp_tbl.FIRST .. l_prp_tbl.LAST LOOP
        l_count := l_count + 1;
        l_com_att_tbl(l_count) := l_prp_tbl(k);
      END LOOP;

      -- IF l_com_att_tbl IS NOT NULL THEN
      FOR k IN l_com_att_tbl.FIRST .. l_com_att_tbl.LAST LOOP
        l_attrNode := newAttributeNode(l_com_att_tbl(k).name, l_com_att_tbl(k).val);
        l_tempnode := XMLDOM.appendChild(l_cfgCompNode, l_attrNode);
      END LOOP;
    END IF;

    /* *** delta_info part *** */
    IF l_check_delta THEN
      IF NOT(xmldom.hasChildNodes(l_components_Node)) THEN
        l_tempNode := xmldom.removeChild(l_delta_info_Node, l_components_Node);
      END IF;

      IF NOT(xmldom.hasChildNodes(l_choice_adds_Node)) THEN
        l_tempNode := xmldom.removeChild(l_cfg_delta_Node, l_choice_adds_Node);
      END IF;

      IF NOT(xmldom.hasChildNodes(l_choice_deletes_Node)) THEN
        l_tempNode := xmldom.removeChild(l_cfg_delta_Node, l_choice_deletes_Node);
      END IF;

      IF NOT(xmldom.hasChildNodes(l_choice_changes_Node)) THEN
        l_tempNode := xmldom.removeChild(l_cfg_delta_Node, l_choice_changes_Node);
      END IF;

      IF NOT(xmldom.hasChildNodes(l_expr_changes_Node)) THEN
        l_tempNode := xmldom.removeChild(l_cfg_delta_Node, l_expr_changes_Node);
      END IF;

    END IF;
    /* *** end of delta_info part *** */

  END LOOP;

  /* *** delta_info part *** */
  IF l_check_delta THEN
    IF NOT(xmldom.hasChildNodes(l_component_adds_Node)) THEN
      l_tempNode := xmldom.removeChild(l_delta_info_Node, l_component_adds_Node);
    END IF;
    IF NOT(xmldom.hasChildNodes(l_component_deletes_Node)) THEN
      l_tempNode := xmldom.removeChild(l_delta_info_Node, l_component_deletes_Node);
    END IF;
  END IF;
  /* *** end of delta_info part *** */

  l_ndebug:=250;
  l_tempNode := xmldom.removeChild(xmldom.makeNode(l_docelm), l_templateNode);

  x_config_details := ' ';
  XMLDOM.writeToClob(l_doc, x_config_details);
  XMLDOM.freeDocument(l_doc);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    XMLDOM.freeDocument(l_doc);
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    XMLDOM.freeDocument(l_doc);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    XMLDOM.freeDocument(l_doc);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name||'.'||l_ndebug);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END get_config_details;

END cz_psft_integration_pvt;

/
