--------------------------------------------------------
--  DDL for Package Body CZ_UIOA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_UIOA_PVT" AS
/*	$Header: czuioab.pls 120.78.12010000.8 2010/05/10 11:20:00 jonatara ship $		*/

  G_GEN_VERSION                 CONSTANT VARCHAR2(25)  :='11.5.20';
  G_GEN_HEADER                  CONSTANT VARCHAR2(100) :='$Header: czuioab.pls 120.78.12010000.8 2010/05/10 11:20:00 jonatara ship $';

  G_DEFAULT_MASTER_TEMPLATE_ID  CONSTANT INTEGER   := 10;

  G_PAGE_STATUS_CONTENT_TYPE    CONSTANT INTEGER   := 187;

  G_TEMPLATE_USE_COPY           CONSTANT INTEGER   := 1;
  G_TEMPLATE_USE_LOCAL_COPY     CONSTANT INTEGER   := 2;
  G_TEMPLATE_USE_BY_REFERENCE   CONSTANT INTEGER   := 3;

  G_DEFAULT_PRICE_DISPLAY       CONSTANT INTEGER   := 3;
  G_DEFAULT_PRICE_UPDATE        CONSTANT INTEGER   := 1;

  G_ONE_COL_CONTROL_LAYOUT      CONSTANT INTEGER   := 0;
  G_TWO_COL_CONTROL_LAYOUT      CONSTANT INTEGER   := 1;
  G_THREE_COL_CONTROL_LAYOUT    CONSTANT INTEGER   := 2;

  G_PRODUCT_TYPE                CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_PRODUCT;
  G_COMPONENT_TYPE              CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_COMPONENT;
  G_REFERENCE_TYPE              CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_REFERENCE;
  G_CONNECTOR_TYPE              CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_CONNECTOR;
  G_BOM_MODEL_TYPE              CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_BOM_MODEL;
  G_FEATURE_TYPE                CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_FEATURE;
  G_OPTION_TYPE                 CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_OPTION;
  G_BOM_OPTION_CLASS_TYPE       CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_BOM_OPTION_CLASS;
  G_BOM_STANDART_ITEM_TYPE      CONSTANT INTEGER   := CZ_TYPES.PS_NODE_TYPE_BOM_STANDART_ITEM;

  G_UNDEFINED_DATA_TYPE         CONSTANT INTEGER   := CZ_TYPES.DATA_TYPE_NODE;

  G_DEFAULT_CAPTION_RULE_ID     CONSTANT INTEGER   := 800;
  G_CAPTION_RULE_TOKENNAME      VARCHAR2(255);

  G_CX_BUTTON_ACTION_TYPE       CONSTANT INTEGER   := 23;

  G_OPTIONAL_INST_TYPE          CONSTANT INTEGER   := 1;
  G_MANDATORY_INST_TYPE         CONSTANT INTEGER   := 2;
  G_CONNECTOR_INST_TYPE         CONSTANT INTEGER   := 3;
  G_MINMAX_INST_TYPE            CONSTANT INTEGER   := 4;

  G_SINGLE_PAGE                 CONSTANT INTEGER   := 0;
  G_PAGE_FLOW                   CONSTANT INTEGER   := 1;
  G_SINGLE_LEVEL_MENU           CONSTANT INTEGER   := 2;
  G_MULTI_LEVEL_MENU            CONSTANT INTEGER   := 3;
  G_MODEL_TREE_MENU             CONSTANT INTEGER   := 4;
  G_SUBTABS                     CONSTANT INTEGER   := 5;

  G_SINGLE_PG_TYPE              CONSTANT NUMBER    := 0;
  G_SUBSECTIONS_PG_TYPE         CONSTANT NUMBER    := 1;
  G_NEW_PAGES_PG_TYPE           CONSTANT NUMBER    := 2;
  G_DRILLDOWN_PAGES_PG_TYPE     CONSTANT NUMBER    := 3;

  G_UI_PAGE_NODE_TYPE           CONSTANT NUMBER    := 520;
  G_UI_REGION_NODE_TYPE         CONSTANT NUMBER    := 521;
  G_UI_REGULAR_NODE_TYPE        CONSTANT NUMBER    := 522;
  G_UI_DRILLDOWN_NODE_TYPE      CONSTANT NUMBER    := 523;
  G_UI_NONBOMADDINST_NODE_TYPE  CONSTANT NUMBER    := 524;
  G_UI_BOMADDINST_NODE_TYPE     CONSTANT NUMBER    := 525;
  G_UI_DELINST_NODE_TYPE        CONSTANT NUMBER    := 526;
  G_UI_MINMAXREF_NODE_TYPE      CONSTANT NUMBER    := 527;
  G_UI_CX_BUTTON_NODE_TYPE      CONSTANT NUMBER    := 528;
  G_UI_PAGEDRILLDOWN_NODE_TYPE  CONSTANT NUMBER    := 529;
  G_UMINMAX_CONNECTOR_TYPEID    CONSTANT NUMBER    := 541;

  G_UNON_COUNT_FEATURE_TYPEID   CONSTANT INTEGER   := 537;
  G_UCOUNT_FEATURE_TYPEID       CONSTANT INTEGER   := 540;
  G_UCOUNT_FEATURE01_TYPEID     CONSTANT INTEGER   := 539;
  G_UMINMAX_FEATURE_TYPEID      CONSTANT INTEGER   := 538;

  G_ACTION_GO_TO_PAGE           CONSTANT INTEGER   := 1;
  G_ACTION_CONFIGURE_SUBCOMP    CONSTANT INTEGER   := 9;

  G_CZ_EXTENTSIONS_RULE_TYPE    CONSTANT NUMBER    := 300;
  G_EXPR_SYS_ARGUMENT           CONSTANT NUMBER    := 217;
  G_EVENT_ON_COMMAND_SIGID      CONSTANT NUMBER    := 2203;
  G_GENERATE_OUTPUT_EVENT       CONSTANT NUMBER    := 31;
  G_RAISE_COMMAND_EVENT         CONSTANT NUMBER    := 32;

  G_NEW_UI_STATUS               CONSTANT VARCHAR2(255) := 'NEW';
  G_REFRESH_UI_STATUS           CONSTANT VARCHAR2(255) := 'REFRESH';
  G_RUNNING_STATUS              CONSTANT VARCHAR2(255) := 'RUNNING';
  G_ERROR_STATUS                CONSTANT VARCHAR2(255) := 'ERROR';
  G_PROCESSED_UI_STATUS         CONSTANT VARCHAR2(255) := 'PROCESSED';

  G_CX_VALID                    CONSTANT VARCHAR2(1) :='V';
  G_CX_INVALID                  CONSTANT VARCHAR2(1) :='I';
  G_CX_MUST_BE_DELETED          CONSTANT VARCHAR2(1) :='D';

  G_GLOBAL_TEMPLATES_UI_DEF_ID  CONSTANT INTEGER   := 0;

  G_NO_FLAG                     CONSTANT VARCHAR2(1)   := '0';
  G_YES_FLAG                    CONSTANT VARCHAR2(1)   := '1';

  G_MARK_TO_ADD                 CONSTANT VARCHAR2(1)   := '2';
  G_MARK_TO_DELETE              CONSTANT VARCHAR2(1)   := '3';
  G_MARK_TO_REFRESH             CONSTANT VARCHAR2(1)   := '4';
  G_MARK_DO_NOT_REFRESH         CONSTANT VARCHAR2(1)   := '5';
  G_MARK_TO_DEASSOCIATE         CONSTANT VARCHAR2(1)   := '6';
  G_LIMBO_FLAG                  CONSTANT VARCHAR2(1)   := '7';
  G_MARK_TO_MOVE                CONSTANT VARCHAR2(1)   := '8';

  G_CREATE_ONLY_UI_STRUCTURE    CONSTANT VARCHAR2(1)   := '1';
  G_CREATE_ONLY_UI_XML          CONSTANT VARCHAR2(1)   := '2';

  G_CONTAINER_TEMPLATE_ID       INTEGER                := 1;

  G_NSTD_CONTAINER_TEMPLATE_ID  CONSTANT INTEGER       := 620;

  G_2COLS_CONTAINER_TEMPLATE_ID CONSTANT INTEGER       := 660;
  G_3COLS_CONTAINER_TEMPLATE_ID CONSTANT INTEGER      := 661;

  G_DRILLDOWN_BUTTON_TEMPLATE_ID  CONSTANT INTEGER     := 230;
  G_DRILLDOWN_IMAGE_TEMPLATE_ID   CONSTANT INTEGER     := 231;
  G_DRILLDOWN_LABEL_TEMPLATE_ID   CONSTANT INTEGER     := 232;

  G_DELETE_PAGE                   CONSTANT INTEGER     := 1;
  G_DELETE_ELEMENTS               CONSTANT INTEGER     := 2;
  G_REFRESH_PAGE                  CONSTANT INTEGER     := 3;
  G_NEW_PAGE                      CONSTANT INTEGER     := 4;

  G_LABEL_PAIR_LAYOUT_STYLE       CONSTANT INTEGER     := 1;
  G_WRAPPED_LAYOUT_STYLE          CONSTANT INTEGER     := 2;
  G_TABLE_LAYOUT_STYLE            CONSTANT INTEGER     := 3;
  G_OTHER_LAYOUT_STYLE            CONSTANT INTEGER     := 9;

  G_DELETE_MODE                   CONSTANT VARCHAR2(1) := '0';
  G_COPY_MODE                     CONSTANT VARCHAR2(1) := '0';

  G_UMPERS                        CONSTANT VARCHAR2(1) := fnd_global.local_chr(38);

  g_DRILLDOWN_TEMPLATE_ID         INTEGER              := 230;
  g_DRILLDOWN_ELEM_SIGNATURE_ID   INTEGER;
  g_DRILLDOWN_B_SIGNATURE_ID      INTEGER;

  g_suppress_refresh_flag         VARCHAR2(1)          := '0';

  G_USER_ATTRIBUTE1_NAME        CONSTANT VARCHAR2(255) := 'user:attribute1';
  G_USER_ATTRIBUTE2_NAME        CONSTANT VARCHAR2(255) := 'user:attribute2';
  G_USER_ATTRIBUTE3_NAME        CONSTANT VARCHAR2(255) := 'user:attribute3';
  G_USER_ATTRIBUTE4_NAME        CONSTANT VARCHAR2(255) := 'user:attribute4';
  G_USER_ATTRIBUTE5_NAME        CONSTANT VARCHAR2(255) := 'user:attribute5';
  G_USER_ATTRIBUTE10_NAME       CONSTANT VARCHAR2(255) := 'user:attribute10';

  G_UI_CONTENTS_TAG             CONSTANT VARCHAR2(255) := 'ui:contents';
  G_ID_ATTRIBUTE                CONSTANT VARCHAR2(255) := 'id';

  G_HEADER_TAG                  CONSTANT VARCHAR2(255) := 'oa:header';
  G_NESTED_TAG                  CONSTANT VARCHAR2(255) := 'user:nested';
  G_ROW_LAYOUT_TAG              CONSTANT VARCHAR2(255) := 'oa:rowLayout';
  G_CONTENT_CONTAINER_TAG       CONSTANT VARCHAR2(255) := 'oa:contentContainer';
  G_STACK_LAYOUT_TAG            CONSTANT VARCHAR2(255) := 'oa:stackLayout';
  G_TABLE_TAG                   CONSTANT VARCHAR2(255) := 'oa:table';
  G_SUBMIT_BUTTON_TAG           CONSTANT VARCHAR2(255) := 'oa:submitButton';
  G_MSG_CHECKBOX_TAG            CONSTANT VARCHAR2(255) := 'oa:messageCheckbox';
  G_MSG_RADIO_BUTTON_TAG        CONSTANT VARCHAR2(255) := 'oa:messageRadioButton';
  G_MSG_STYLED_TEXT_TAG         CONSTANT VARCHAR2(255) := 'oa:messageStyledText';
  G_MSG_TEXT_INPUT_TAG          CONSTANT VARCHAR2(255) := 'oa:messageTextInput';
  G_MSG_CHOICE_TAG              CONSTANT VARCHAR2(255) := 'oa:messageChoice';
  G_TABLE_LAYOUT_TAG            CONSTANT VARCHAR2(255) := 'oa:tableLayout';
  G_CELL_FORMAT_TAG             CONSTANT VARCHAR2(255) := 'oa:cellFormat';
  G_FLOW_LAYOUT_TAG             CONSTANT VARCHAR2(255) := 'oa:flowLayout';
  G_DBL_COL_LAYOUT_TAG          CONSTANT VARCHAR2(255) := 'oa:doubleColumnLayout';
  G_SUB_TAB_LAYOUT_TAG          CONSTANT VARCHAR2(255) := 'oa:subTabLayout';
  G_TEXT_TAG                    CONSTANT VARCHAR2(255) :=  'oa:staticStyledText';
  G_BUTTON_TAG                  CONSTANT VARCHAR2(255) :=  'oa:button';
  G_IMAGE_TAG                   CONSTANT VARCHAR2(255) :=  'oa:image';
  G_SPACER_TAG                  CONSTANT VARCHAR2(255) :=  'oa:spacer';
  G_TEMPLATE_INCLUDE_TAG        CONSTANT VARCHAR2(255) :=  'oa:templateInclude';
  G_RAW_TEXT_TAG                CONSTANT VARCHAR2(255) :=  'oa:rawText';
  G_SWITCHER_TAG                CONSTANT VARCHAR2(255) :=  'oa:switcher';

  G_INLINE_COPY_TMPL            CONSTANT VARCHAR2(255) :=  'TEMPLATE';
  G_INLINE_COPY_UIPAGE          CONSTANT VARCHAR2(255) :=  'PAGE';

  G_ROW_LAYOUT                    CONSTANT NUMBER := 6001;
  G_CELL_FORMAT                   CONSTANT NUMBER := 6002;
  G_FLOW_LAYOUT                   CONSTANT NUMBER := 6003;
  G_STACK_LAYOUT                  CONSTANT NUMBER := 6004;
  G_BULLETED_LIST                 CONSTANT NUMBER := 6005;
  G_TABLE_LAYOUT                  CONSTANT NUMBER := 6006;
  G_HEADER_REGION                 CONSTANT NUMBER := 6007;
  G_SWITCHER_REGION               CONSTANT NUMBER := 6008;
  G_CASE_REGION                   CONSTANT NUMBER := 6009;
  G_CONTENT_CONTAINER             CONSTANT NUMBER := 6010;
  G_UI_TEMPLATE_REFERENCE         CONSTANT NUMBER := 6011;
  G_SUMMARY_TABLE                 CONSTANT NUMBER := 6012;
  G_ITEM_SELECTION_TABLE          CONSTANT NUMBER := 6013;
  G_INSTANCE_MANAGEMENT_TABLE     CONSTANT NUMBER := 6014;
  G_INSTANCE_MANAGEMENT_CONTROL   CONSTANT NUMBER := 6015;
  G_CONNECTION_NAVIGATOR          CONSTANT NUMBER := 6016;
  G_CONNECTION_TARGETS_TABLE      CONSTANT NUMBER := 6017;
  G_STYLED_TEXT                   CONSTANT NUMBER := 6018;
  G_IMAGE                         CONSTANT NUMBER := 6019;
  G_BUTTON                        CONSTANT NUMBER := 6020;
  G_SPACER                        CONSTANT NUMBER := 6021;
  G_TEXT_INPUT                    CONSTANT NUMBER := 6022;
  G_DROPDOWN_LIST                 CONSTANT NUMBER := 6023;
  G_CHECK_BOX                     CONSTANT NUMBER := 6024;
  G_RADIO_BUTTON                  CONSTANT NUMBER := 6025;
  G_SELECTION_STATUS_INDICATOR    CONSTANT NUMBER := 6026;
  G_RAW_TEXT                      CONSTANT NUMBER := 6027;
  G_NODE_LIST_LAYOUT_REGION       CONSTANT NUMBER := 6028;
  G_NAVIGATION_BAR                CONSTANT NUMBER := 6030;
  G_LINK                          CONSTANT NUMBER := 6031;
  G_BUTTON_BAR                    CONSTANT NUMBER := 6032;
  G_RADIO_BUTTON_GROUP            CONSTANT NUMBER := 6033;
  G_SCRIPT                        CONSTANT NUMBER := 6034;
  G_SEPARATOR                     CONSTANT NUMBER := 6035;
  G_SERVLET_INCLUDE               CONSTANT NUMBER := 6036;
  G_SUBTAB_LAYOUT                 CONSTANT NUMBER := 6040;
  G_TIP                           CONSTANT NUMBER := 6041;
  G_TRAIN                         CONSTANT NUMBER := 6042;
  G_PAGE                          CONSTANT NUMBER := 6044;
  G_HIDESHOW_REGION               CONSTANT NUMBER := 6045;
  G_INSTANTIATION_CHECKBOX        CONSTANT NUMBER := 6047;
  G_ENHANCED_CHECKBOX             CONSTANT NUMBER := 6048;
  G_ENHANCED_RADIO_BUTTON         CONSTANT NUMBER := 6049;
  G_STATIC_STYLED_TEXT            CONSTANT NUMBER := 6050;
  G_FORMATTED_TEXT                CONSTANT NUMBER := 6051;
  G_EMPTY                         CONSTANT NUMBER := 6052;
  G_NODE_LIST_ROW_LAYOUT          CONSTANT NUMBER := 6053;
  G_NODE_LIST_FLOW_LAYOUT         CONSTANT NUMBER := 6055;
  G_PAGE_INCLUDE_REGION           CONSTANT NUMBER := 6068;
  G_NODE_LIST_STACK_LAYOUT        CONSTANT NUMBER := 6057;
  G_NODE_LIST_BULLETED_LIST       CONSTANT NUMBER := 6059;
  G_NODE_LIST_TABLE_LAYOUT        CONSTANT NUMBER := 6061;
  G_FORMATTED_TEXT                CONSTANT NUMBER := 6067;
  G_PAGE_INCL_REGION_SIGNATURE    CONSTANT NUMBER := 6073;

  G_ADDED_FLAG                    CONSTANT VARCHAR2(1)   := '0';
  G_REMOVED_FLAG                  CONSTANT VARCHAR2(1)   := '1';
  G_EXISTS_FLAG                   CONSTANT VARCHAR2(1)   := '3';

  G_TABLELAYOUT_TEMPLATE        VARCHAR2(255) := '/oracle/apps/cz/runtime/oa/webui/templates/regions/TableLayoutRegion';
  G_ANCHOR_TEMPLATE             VARCHAR2(255) := '/oracle/apps/cz/runtime/oa/webui/templates/regions/Anchor';
  G_LINK_TEMPLATE               VARCHAR2(255) := '/oracle/apps/cz/runtime/oa/webui/templates/Link';

  g_PAGE_STATUS_TEMPLATE_ID      NUMBER;

  G_DEFAULT_START_URL            VARCHAR2(255) := 'czContainer.jsp';
  G_DEFAULT_PAGE_LAYOUT          VARCHAR2(255) := '/oracle/apps/cz/runtime/oa/webui/pages/CZMainPage';

  G_DRILLDOWN_TEMPLATE_NAME      VARCHAR2(255);

  G_MSGTEMP_RQDMSG_OVRCTRDIC     NUMBER := 600;
  G_MSGTEMP_RQDMSG_NOVRCTRDIC    NUMBER := 601;
  G_MSGTEMP_RQDMSG_INVLDINP      NUMBER := 603;
  G_MSGTEMP_RQDMSG_FATERR        NUMBER := 613;

  G_MSGTEMP_OPTMSG_VLDNOTIF      NUMBER := 620;
  G_MSGTEMP_OPTMSG_CNFRMSAVFIN   NUMBER := 606;
  G_MSGTEMP_OPTMSG_CNFRMCANCEL   NUMBER := 608;
  G_MSGTEMP_OPTMSG_CNFRMDELINST  NUMBER := 610;
  G_MSGTEMP_OPTMSG_CNFRMLDINST   NUMBER := 628;
  G_MSGTEMP_OPTMSG_CNFRMEDINST   NUMBER := 616;
  G_MSGTEMP_OPTMSG_QRYDELINST    NUMBER := 630;

  G_UTILTEMP_BB_BASICTXN         NUMBER := 175;
  G_UTILTEMP_BB_NSTXN            NUMBER := 24;
  G_UTILTEMP_BB_2PGNVG           NUMBER := 177;
  G_UTILTEMP_BB_NPGNVG           NUMBER := 178;

  G_UTILTEMP_PAGLAY_PGSTA        NUMBER := 187;
  G_UTILTEMP_BB_PRVWPG           NUMBER := 186;
  G_UTILTEMP_UPT_CFGPRV          NUMBER := 651;
  G_UTILTEMP_UPT_CXNCHO          NUMBER := 545;

  TYPE number_tbl_type           IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE number_tbl_type_idx_vc2   IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
  --TYPE varchar_tbl_type          IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  TYPE ui_page_elements_tbl_type IS TABLE OF CZ_UI_PAGE_ELEMENTS%ROWTYPE INDEX BY VARCHAR2(15);--kdande; Bug 6875560; 12-Mar-2008

  -- fix for bug 6837809 : skudryav 28-Mar-2008
  TYPE ui_page_el_int_tbl_type IS TABLE OF CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE ui_def_nodes_tbl_type     IS TABLE OF CZ_UI_DEFS%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE ui_page_sets_tbl_type     IS TABLE OF CZ_UI_PAGE_SETS%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE ui_pages_tbl_type         IS TABLE OF CZ_UI_PAGES%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE ui_page_refs_tbl_type     IS TABLE OF CZ_UI_PAGE_REFS%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE xml_dom_elements_tbl_type IS TABLE OF xmldom.DOMNode INDEX BY BINARY_INTEGER;

  TYPE varchar2_tbl_type         IS TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);

  TYPE xml_dom_nodes_tbl_type    IS TABLE OF xmldom.DOMNode INDEX BY VARCHAR2(255);
  g_page_elements_tbl            xml_dom_nodes_tbl_type;


  TYPE nested_number_tbl_type  IS TABLE OF number_tbl_type INDEX BY BINARY_INTEGER;

  g_jrad_trans_list          jdr_utils.translationlist := jdr_utils.translationlist();
  g_ref_expls_tbl            number_tbl_type_idx_vc2;
  g_ui_def_nodes_tbl         ui_def_nodes_tbl_type;
  g_ui_page_elements_tbl     ui_page_elements_tbl_type;
  g_ui_pages_counter_tbl     number_tbl_type;
  g_ui_pages_tbl             ui_pages_tbl_type;
  g_model_nodes_tbl          model_nodes_tbl_type;
  g_ui_page_refs_tbl         ui_page_refs_tbl_type;
  g_nbr_elements_on_page_tbl number_tbl_type;
  g_ps_node_persist_id_tbl   number_tbl_type_idx_vc2;
  g_ui_action_ids_tbl        number_tbl_type;
  g_ui_refs_tbl              number_tbl_type_idx_vc2;
  g_ui_page_sets_tbl         ui_page_sets_tbl_type;
  g_template_jrad_name_tbl   varchar_tbl_type;
  g_template_id_tbl          number_tbl_type;
  g_template_ui_def_id_tbl   number_tbl_type;
  g_root_persist_id_tbl      number_tbl_type_idx_vc2;
  g_moved_content_tbl        number_tbl_type;
  g_cx_names_tbl             number_tbl_type;
  g_ref_cx_paths_tbl         varchar_tbl_type;
  g_last_seq_elem_tbl        number_tbl_type;
  g_handled_attr_id_tbl      varchar_tbl_type;
  g_local_ui_context         ui_def_nodes_tbl_type;
  g_check_boundaries_tbl     varchar_tbl_type;
  g_locked_templates_id_tbl  number_tbl_type;
  g_dom_elements_tbl         xml_dom_elements_tbl_type;
  g_elements_to_move         nested_number_tbl_type;
  g_tgt_pg_to_src_pg_map     nested_number_tbl_type; -- used for moving nodes

  g_dom_elements_to_move     xml_dom_elements_tbl_type;

  g_connector_counter      NUMBER;
  g_bomm_counter           NUMBER;
  g_mandatory_comp_counter NUMBER;
  g_mandatory_ref_counter  NUMBER;
  g_minmax_ref_counter     NUMBER;
  g_optional_ref_counter   NUMBER;
  g_of_feature_counter     NUMBER;
  g_if_feature_counter     NUMBER;
  g_df_feature_counter     NUMBER;
  g_bf_feature_counter     NUMBER;
  g_tf_feature_counter     NUMBER;
  g_tot_feature_counter    NUMBER;
  g_rsc_feature_counter    NUMBER;
  g_itot_feature_counter   NUMBER;
  g_irsc_feature_counter   NUMBER;
  g_opt_counter            NUMBER;

  g_status              VARCHAR2(255);
  g_industry            VARCHAR2(255);
  g_ret                 BOOLEAN;

  g_currentUINode       NUMBER;
  g_currUISeqVal        NUMBER;
  g_currentPageRef      NUMBER;
  g_currPageRefSeqVal   NUMBER;
  g_currentPage         NUMBER;
  g_currPageSeqVal      NUMBER;
  g_currentPageSet      NUMBER;
  g_currPageSetSeqVal   NUMBER;
  g_currentUIAction     NUMBER;
  g_currUIActionSeqVal  NUMBER;
  g_currentIntlText     NUMBER;
  g_currIntlTextSeqVal  NUMBER;

  g_IntlTextINCREMENT   NUMBER := 20;
  g_UINodeINCREMENT     NUMBER := 20;
  g_PageRefINCREMENT    NUMBER := 20;
  g_PageINCREMENT       NUMBER := 20;
  g_PageSetINCREMENT    NUMBER := 20;
  g_UIActionINCREMENT   NUMBER := 20;

  g_Elements_Per_Column  NUMBER;
  g_Num_Elements_On_Page NUMBER;

  g_Use_Cache           BOOLEAN := FALSE;
  g_REFRESH_MODEL_PATH  BOOLEAN := TRUE;

  g_UI_Context          CZ_UI_DEFS%ROWTYPE;

  g_using_new_UI_refresh BOOLEAN;

  g_ELEMENT_COUNTER     NUMBER;

  -------------- JDR DOC BUILDER/XML Parsing part -----------------

  g_DOC     xmldom.DOMDocument;
  g_JRADDOC jdr_docbuilder.Document;
  g_PARSER  xmlparser.parser;
  g_Null_Xml_Node xmldom.DOMNode;

  g_MSG_COUNT         NUMBER := 0;
  g_MSG_DATA          VARCHAR2(32000);
  g_RETURN_STATUS     VARCHAR2(10);
  g_WRONG_PS_NODE_ID  NUMBER;

  MAX_CHUNK_SIZE CONSTANT INTEGER := 32000;

  WRONG_UI_TEMPLATE       EXCEPTION;
  WRONG_UI_TO_REFRESH     EXCEPTION;
  PAGE_CANNOT_BE_SPLIT    EXCEPTION;
  WRONG_EXT_PS_TYPE       EXCEPTION;
  UNREACH_UI_NODE         EXCEPTION;
  --FAILED_TO_LOCK_MODEL    EXCEPTION;
  --FAILED_TO_LOCK_TEMPLATE EXCEPTION;

  TYPE char_tbl_type IS TABLE OF VARCHAR2(255);
  g_toplevel_attr_tbl char_tbl_type := char_tbl_type('version',
                                                     'xml:lang',
                                                     'file-version',
                                                     'xmlns:oa',
                                                     'xmlns:ui',
                                                     'xmlns:jrad',
                                                     'xmlns:user',
                                                     'FILE-version',
                                                     'file-version',
                                                     'xmlns:user',
                                                     'xmlns:USER',
                                                     'xmlns');

  g_condition_attr_tbl char_tbl_type := char_tbl_type('displayCondnId',
                                                     'enabledCondnId',
                                                     'colDisplayCondnId',
                                                     'liDisplayCondnId',
                                                     'rowDisplayCondnId',
                                                     'rowEnabledCondnId',
                                                     'switcherCondnId');

 g_caption_attr_tbl char_tbl_type := char_tbl_type('captionIntlTextId',
                                                  'rolloverIntlTextId',
                                                  'cellIntlTextId',
                                                  'urlIntlTextId',
                                                  'tableSummaryIntlTextId',
                                                  'imageSourceIntlTextId',
                                                  'addInstBtnIntlTextId');

  g_view_prefix_tbl char_tbl_type := char_tbl_type('COMP_',
                                                   'SIM_',
                                                   'CS_',
                                                   'OF_',
                                                   'IF_',
                                                   'DF_',
                                                   'BF_',
                                                   'TF_',
                                                   'TOT_',
                                                   'RSC_',
                                                   'ITOT_',
                                                   'IRSC_',
                                                   'REF_',
                                                   'CON_',
                                                   'BOMM_',
                                                   'OPT_' );

  TYPE attribute_record_type IS RECORD(
    NAME  jdr_attributes.att_name%TYPE,
    VALUE jdr_attributes.att_value%TYPE);

  TYPE attributes_tbl_type IS TABLE OF attribute_record_type INDEX BY BINARY_INTEGER;

  --vsingava IM-ER
  TYPE expl_node_persistent_id_pair IS RECORD(
    expl_node_id  NUMBER,
    persistent_node_id NUMBER);


  -------------------------------------------------------------------

  --
  -- section for a different DEBUG procedures
  --
  PROCEDURE DEBUG(p_str IN VARCHAR2) IS
  BEGIN
    --DBMS_OUTPUT.PUT_LINE(p_str);
    NULL;
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2, p_var_value IN VARCHAR2) IS
  BEGIN
    DEBUG(p_var_name || ' = ' || p_var_value);
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2, p_var_value IN NUMBER) IS
  BEGIN
    DEBUG(p_var_name || ' = ' || TO_CHAR(p_var_value));
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2, p_var_value IN DATE) IS
  BEGIN
    DEBUG(p_var_name || ' = ' ||
          TO_CHAR(p_var_value, 'DD-MM-YYYY HH24:MI:SS'));
  END DEBUG;

  PROCEDURE dump_Error_Stack(p_prefix IN VARCHAR2) IS
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_msg_index number;
  BEGIN
   DEBUG('------------ Start of '||p_prefix||' ----------------');
   l_msg_index := 1;
   l_msg_count := fnd_msg_pub.COUNT_MSG();
   DEBUG(p_prefix||' '||TO_CHAR(l_msg_count)||' error messages .');
   WHILE l_msg_count > 0 LOOP
      l_msg_data := fnd_msg_pub.GET(l_msg_index,fnd_api.g_false);
      DEBUG(p_prefix||l_msg_data);
      l_msg_index := l_msg_index + 1;
      l_msg_count := l_msg_count - 1;
   END LOOP;
   DEBUG('------------ End  of '||p_prefix||' ----------------');
  END dump_Error_Stack;

  PROCEDURE lock_Model(p_model_id            IN NUMBER,
                       p_locked_entities_tbl OUT NOCOPY cz_security_pvt.number_type_tbl) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_lock_status     VARCHAR2(255);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
  BEGIN

    cz_security_pvt.lock_model(1.0,p_model_id,FND_API.G_TRUE,FND_API.G_FALSE,
                               p_locked_entities_tbl,
                               l_lock_status,l_msg_count,l_msg_data);
    COMMIT;
    IF (l_lock_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FAILED_TO_LOCK_MODEL;
    END IF;
  END lock_Model;

  PROCEDURE unlock_Model(p_locked_entities_tbl IN cz_security_pvt.number_type_tbl) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_lock_status     VARCHAR2(255);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
  BEGIN
    cz_security_pvt.unlock_model(p_api_version      => 1.0,
                                 p_models_to_unlock => p_locked_entities_tbl,
                                 p_commit_flag      => FND_API.G_FALSE,
                                 p_init_msg_list    => FND_API.G_FALSE,
                                 x_return_status    => l_lock_status,
                                 x_msg_count        => l_msg_count,
                                 x_msg_data         => l_msg_data);
    COMMIT;
  END unlock_Model;

  FUNCTION is_Used_By_Reference(p_detailed_type_id IN NUMBER,
                                p_ctrl_template_id IN NUMBER)
    RETURN BOOLEAN IS
  BEGIN

    IF ((p_detailed_type_id IN
        (CZ_TYPES.UMANDATORY_COMPONENT_TYPEID
        ,CZ_TYPES.UOPTIONAL_COMPONENT_TYPEID
        ,CZ_TYPES.UMINMAX_COMPONENT_TYPEID
        ,CZ_TYPES.UNON_COUNT_FEATURE_TYPEID
        ,CZ_TYPES.UCOUNT_FEATURE_TYPEID
        ,CZ_TYPES.UCOUNT_FEATURE01_TYPEID
        ,CZ_TYPES.UMINMAX_FEATURE_TYPEID
        ,CZ_TYPES.UINTEGER_FEATURE_TYPEID
        ,CZ_TYPES.UDECIMAL_FEATURE_TYPEID
        ,CZ_TYPES.UBOOLEAN_FEATURE_TYPEID
        ,CZ_TYPES.UTEXT_FEATURE_TYPEID
        ,CZ_TYPES.UTOTAL_TYPEID
        ,CZ_TYPES.URESOURCE_TYPEID
        ,CZ_TYPES.UCONNECTOR_TYPEID,CZ_TYPES.UMINMAX_CONNECTOR)
         AND g_UI_Context.CTRLTEMPLUSE_NONBOM=G_TEMPLATE_USE_BY_REFERENCE)
       OR
       (p_detailed_type_id IN
        (CZ_TYPES.UMANDATORY_REF_TYPEID
        ,CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID
        ,CZ_TYPES.UMINMAX_BOM_REF_TYPEID
        ,CZ_TYPES.UBOM_NSTBOM_NQMTX_TYPEID
        ,CZ_TYPES.UBOM_NSTBOM_NQNMTX_TYPEID
        ,CZ_TYPES.UBOM_NSTBOM_QNMTX_TYPEID
        ,CZ_TYPES.UBOM_NSTBOM_QMTX_TYPEID
        ,CZ_TYPES.UBOM_STIO_NQMTX_TYPEID
        ,CZ_TYPES.UBOM_STIO_NQNMTX_TYPEID
        ,CZ_TYPES.UBOM_STIO_QNMTX_TYPEID
        ,CZ_TYPES.UBOM_STIO_QMTX_TYPEID)
        AND g_UI_Context.CTRLTEMPLUSE_BOM=G_TEMPLATE_USE_BY_REFERENCE)) AND
       p_ctrl_template_id NOT IN(G_DRILLDOWN_IMAGE_TEMPLATE_ID,G_DRILLDOWN_LABEL_TEMPLATE_ID,
         G_DRILLDOWN_BUTTON_TEMPLATE_ID) THEN
      RETURN TRUE;
    END IF;

    RETURN FALSE;

  END is_Used_By_Reference;

  PROCEDURE lock_UI_Template(p_template_id           IN NUMBER,
                             p_template_ui_def_id    IN NUMBER DEFAULT NULL,
                             px_needs_to_be_unlocked OUT NOCOPY BOOLEAN) IS
   PRAGMA AUTONOMOUS_TRANSACTION;

    l_templates_to_lock_tbl  cz_security_pvt.number_type_tbl;
    l_locked_templates_tbl   cz_security_pvt.number_type_tbl;
    l_seeded_flag            CZ_UI_TEMPLATES.seeded_flag%TYPE;
    l_lock_status            VARCHAR2(255);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);

  BEGIN
    IF p_template_ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID OR
       p_template_ui_def_id IS NULL THEN
      SELECT seeded_flag INTO l_seeded_flag FROM CZ_UI_TEMPLATES
       WHERE template_id=p_template_id AND ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID;
      IF l_seeded_flag=G_YES_FLAG THEN
        RETURN;
      END IF;
      l_templates_to_lock_tbl(1) := p_template_id;
      cz_security_pvt.lock_template(p_api_version       => 1.0,
                                         p_templates_to_lock => l_templates_to_lock_tbl,
                                         p_commit_flag       => FND_API.G_FALSE,
                                         p_init_msg_list     => FND_API.G_FALSE,
                                         x_locked_templates  => l_locked_templates_tbl,
                                         x_return_status     => l_lock_status,
                                         x_msg_count         => l_msg_count,
                                         x_msg_data          => l_msg_data);
      COMMIT;

      IF (l_lock_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FAILED_TO_LOCK_TEMPLATE;
      END IF;
      IF l_locked_templates_tbl.COUNT>0 THEN
        px_needs_to_be_unlocked := TRUE;
      ELSE
        px_needs_to_be_unlocked := FALSE;
      END IF;
    END IF;
  END lock_UI_Template;

  PROCEDURE unlock_UI_Template(p_template_id          IN NUMBER,
                               p_template_ui_def_id   IN NUMBER DEFAULT NULL,
                               p_needs_to_be_unlocked IN BOOLEAN) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_templates_to_unlock_tbl    cz_security_pvt.number_type_tbl;
    l_lock_status                VARCHAR2(255);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(4000);
  BEGIN
    IF (p_template_ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID OR
       p_template_ui_def_id IS NULL) AND p_needs_to_be_unlocked THEN
      l_templates_to_unlock_tbl(1) := p_template_id;
      cz_security_pvt.unlock_template(p_api_version            => 1.0,
                                           p_templates_to_unlock    => l_templates_to_unlock_tbl,
                                           p_commit_flag            => FND_API.G_FALSE,
                                           p_init_msg_list          => FND_API.G_FALSE,
                                           x_return_status          => l_lock_status,
                                           x_msg_count              => l_msg_count,
                                           x_msg_data               => l_msg_data);
      COMMIT;
    END IF;
  END unlock_UI_Template;

  --
  -- lock all global UI templates for a given model_id and ui_def_id
  -- array x_templates_id_tbl will contain locked UI templates
  --
  PROCEDURE lock_UI_Templates(p_model_id          IN NUMBER,
                              p_ui_def_id         IN NUMBER) IS
    l_needs_to_be_unlocked     BOOLEAN;

  l_lock_status            VARCHAR2(255);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_msg_index number;
  BEGIN
    FOR i IN(SELECT DISTINCT template_id, detailed_type_id
               FROM CZ_UITEMPLS_FOR_PSNODES_V
              WHERE devl_project_id=p_model_id AND
                    ui_def_id=p_ui_def_id AND
                    template_ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID AND
                    deleted_flag = G_NO_FLAG)
    LOOP
      IF is_Used_By_Reference(i.detailed_type_id, i.template_id)=FALSE AND
         NOT(g_locked_templates_id_tbl.EXISTS(i.template_id)) THEN

        BEGIN
          --
          -- lock current UI Template
          --
          lock_UI_Template( i.template_id, G_GLOBAL_TEMPLATES_UI_DEF_ID, l_needs_to_be_unlocked);
          --
          -- collect only those UI templates
          -- which really have been locked
          --
          IF l_needs_to_be_unlocked THEN
            g_locked_templates_id_tbl(i.template_id) := i.template_id;
          END IF;
        EXCEPTION
          WHEN FAILED_TO_LOCK_TEMPLATE THEN
            DEBUG('Failed to lock UI Template with template_id=', i.template_id);
            g_MSG_COUNT := fnd_msg_pub.COUNT_MSG();
        END;

      END IF;

    END LOOP;

  END lock_UI_Templates;

  --
  -- unlock global UI templates specified by array x_templates_id_tbl
  --
  PROCEDURE unlock_UI_Templates IS
    l_index NUMBER;
  BEGIN

    IF  g_locked_templates_id_tbl.Count>0 THEN

      l_index :=  g_locked_templates_id_tbl.First;

      LOOP
        IF l_index IS NULL THEN
          EXIT;
        END IF;

        DEBUG('UI Template to unlock : ',g_locked_templates_id_tbl(l_index));
        --
        -- unlock current UI Template
        --
        unlock_UI_Template( g_locked_templates_id_tbl(l_index), G_GLOBAL_TEMPLATES_UI_DEF_ID, TRUE);
        l_index := g_locked_templates_id_tbl.NEXT(l_index);
      END LOOP;

    END IF;

  END unlock_UI_Templates;

  --
  -- initialize sequences to use in UI Generation/UI Refresh
  --
  PROCEDURE Initialize_Sequences IS
  BEGIN

    SELECT CZ_UI_PAGE_ELEMENTS_S.nextval INTO g_currentUINode FROM dual;
    g_currUISeqVal := g_currentUINode;

    SELECT CZ_UI_PAGE_REFS_S.nextval INTO g_currentPageRef FROM dual;
    g_currPageRefSeqVal := g_currentPageRef;

    SELECT CZ_UI_PAGES_S.nextval INTO g_currentPage FROM dual;
    g_currPageSeqVal := g_currentPage;

    SELECT CZ_UI_PAGE_SETS_S.nextval INTO g_currentPageSet FROM dual;
    g_currPageSetSeqVal := g_currentPageSet;

    SELECT CZ_UI_ACTIONS_S.nextval INTO g_currentUIAction FROM dual;
    g_currUIActionSeqVal := g_currentUIAction;

  END Initialize_Sequences;

  --
  -- initialize FND variables/packages
  --
  PROCEDURE Initialize(x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
                       x_msg_data      OUT NOCOPY VARCHAR2) IS
  BEGIN
    g_MSG_COUNT := 0 ;
    fnd_msg_pub.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_msg_data      := NULL;
    Initialize_Sequences();
    g_ui_def_nodes_tbl.DELETE;
    g_ui_pages_counter_tbl.DELETE;
    g_root_persist_id_tbl.DELETE;
    g_local_ui_context.DELETE;
    g_check_boundaries_tbl.DELETE;
    g_locked_templates_id_tbl.DELETE;
    g_elements_to_move.DELETE;
    g_dom_elements_to_move.DELETE;
    g_tgt_pg_to_src_pg_map.DELETE;
  END Initialize;

  --
  -- add FND error message
  --
  PROCEDURE add_Error_Message(p_message_name IN VARCHAR2,
                              p_fatal_error  IN BOOLEAN) IS

  BEGIN
    FND_MESSAGE.SET_NAME('CZ', p_message_name);
    IF p_fatal_error THEN
      FND_MSG_PUB.ADD;
    ELSE
      fnd_msg_pub.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
    END IF;
    FND_MSG_PUB.count_and_get(p_count => g_MSG_COUNT,
                              p_data  => g_MSG_DATA);
    IF p_fatal_error OR g_RETURN_STATUS=FND_API.G_RET_STS_ERROR THEN
      g_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    ELSE
      g_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    END IF;

  END add_Error_Message;

  PROCEDURE add_Error_Message(p_message_name IN VARCHAR2,
                              p_token_name   IN VARCHAR2,
                              p_token_value  IN VARCHAR2,
                              p_fatal_error  IN BOOLEAN) IS

  BEGIN
    FND_MESSAGE.SET_NAME('CZ', p_message_name);
    IF p_token_name IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token_name, p_token_value);
    END IF;
    IF p_fatal_error THEN
      FND_MSG_PUB.ADD;
    ELSE
      fnd_msg_pub.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
    END IF;
    FND_MSG_PUB.count_and_get(p_count => g_MSG_COUNT,
                              p_data  => g_MSG_DATA);
    IF p_fatal_error OR g_RETURN_STATUS=FND_API.G_RET_STS_ERROR THEN
      g_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    ELSE
      g_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    END IF;
  END add_Error_Message;

  PROCEDURE add_Error_Message(p_message_name IN VARCHAR2,
                              p_token_name1   IN VARCHAR2,
                              p_token_value1  IN VARCHAR2,
                              p_token_name2   IN VARCHAR2,
                              p_token_value2  IN VARCHAR,
                              p_fatal_error   IN BOOLEAN) IS

  BEGIN
    FND_MESSAGE.SET_NAME('CZ', p_message_name);
    IF p_token_name1 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token_name1, p_token_value1);
    END IF;

    IF p_token_name2 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token_name2, p_token_value2);
    END IF;

    IF p_fatal_error THEN
      FND_MSG_PUB.ADD;
    ELSE
      fnd_msg_pub.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
    END IF;

    FND_MSG_PUB.count_and_get(p_count => g_MSG_COUNT,
                              p_data  => g_MSG_DATA);
    IF p_fatal_error OR g_RETURN_STATUS=FND_API.G_RET_STS_ERROR THEN
      g_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    ELSE
      g_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    END IF;
  END add_Error_Message;

  PROCEDURE add_Error_Message(p_message_name IN VARCHAR2,
                              p_token_name1   IN VARCHAR2,
                              p_token_value1  IN VARCHAR2,
                              p_token_name2   IN VARCHAR2,
                              p_token_value2  IN VARCHAR,
                              p_token_name3   IN VARCHAR2,
                              p_token_value3  IN VARCHAR,
                              p_fatal_error   IN BOOLEAN) IS

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

    IF p_fatal_error THEN
      FND_MSG_PUB.ADD;
    ELSE
      fnd_msg_pub.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
    END IF;

    FND_MSG_PUB.count_and_get(p_count => g_MSG_COUNT,
                              p_data  => g_MSG_DATA);
    IF p_fatal_error OR g_RETURN_STATUS=FND_API.G_RET_STS_ERROR THEN
      g_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    ELSE
      g_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    END IF;
  END add_Error_Message;

  PROCEDURE add_Error_Message(p_message_name IN VARCHAR2,
                              p_token_name1   IN VARCHAR2,
                              p_token_value1  IN VARCHAR2,
                              p_token_name2   IN VARCHAR2,
                              p_token_value2  IN VARCHAR,
                              p_token_name3   IN VARCHAR2,
                              p_token_value3  IN VARCHAR,
                              p_token_name4   IN VARCHAR2,
                              p_token_value4  IN VARCHAR,
                              p_token_name5   IN VARCHAR2,
                              p_token_value5  IN VARCHAR,
                              p_fatal_error   IN BOOLEAN) IS

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

    IF p_token_name4 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token_name4, p_token_value4);
    END IF;

    IF p_token_name5 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token_name5, p_token_value5);
    END IF;

    IF p_fatal_error THEN
      FND_MSG_PUB.ADD;
    ELSE
      fnd_msg_pub.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
    END IF;

    FND_MSG_PUB.count_and_get(p_count => g_MSG_COUNT,
                              p_data  => g_MSG_DATA);
    IF p_fatal_error OR g_RETURN_STATUS=FND_API.G_RET_STS_ERROR THEN
      g_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    ELSE
      g_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    END IF;
  END add_Error_Message;

  --
  -- return increment of sequence p_sequence_name which
  -- is under schema p_sequence_owner
  --
  FUNCTION get_Seq_Inc(p_sequence_name  IN VARCHAR2,
                       p_sequence_owner IN VARCHAR2) RETURN NUMBER IS
    l_seq_increment NUMBER;
  BEGIN
    SELECT increment_by INTO l_seq_increment
    FROM all_sequences
    WHERE sequence_owner=p_sequence_owner AND
          sequence_name=p_sequence_name;
    RETURN l_seq_increment;
  END get_Seq_Inc;

  --
  -- open XML parser
  --
  PROCEDURE Open_Parser IS
  BEGIN
    --
    -- create a new XML parser ( global )
    --
    g_PARSER := xmlparser.newParser;
  END Open_Parser;

  --
  -- close XML parser
  --
  PROCEDURE Close_Parser IS
  BEGIN
    --
    -- close XML parser ( global )
    --
    xmlparser.freeParser(g_PARSER);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE='-20103' THEN
        NULL;
      ELSE
        DEBUG('Close_Parser() : XML Parser can not be closed : '||SQLERRM);
        RAISE;
      END IF;
  END Close_Parser;

  FUNCTION cloneNode(p_source_xml_node xmldom.DOMNode, p_target_subtree_xml_node xmldom.DOMNode) RETURN xmldom.DOMNode IS

    l_xmldoc  xmldom.DOMDocument;

  BEGIN

    l_xmldoc := xmldom.getOwnerDocument(p_target_subtree_xml_node);

    BEGIN

      CZ_UIOA_PVT.g_temp_xmldoc := l_xmldoc;
      CZ_UIOA_PVT.g_temp_source_xml_node := p_source_xml_node;

      EXECUTE IMMEDIATE
      'BEGIN ' ||
      '  CZ_UIOA_PVT.g_temp_xml_node := XMLDOM.importNode(CZ_UIOA_PVT.g_temp_xmldoc, CZ_UIOA_PVT.g_temp_source_xml_node, TRUE); ' ||
      'END;';

      RETURN CZ_UIOA_PVT.g_temp_xml_node;

    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE=-6550 THEN -- there is no function importNode() in XMLDOM
          RETURN xmldom.cloneNode(p_source_xml_node, TRUE);
        ELSE
          RAISE;
        END IF;
    END;

  END cloneNode;

  --
  -- generate NEW ID FROM a given sequence
  --  Parameters : p_sequence_name - name of DB sequence
  --  Return     : next id from sequence
  --
  FUNCTION allocateId(p_sequence_name IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    IF p_sequence_name='CZ_UI_PAGE_ELEMENTS_S' THEN
      IF g_currentUINode<g_currUISeqVal+g_UINodeINCREMENT-1 THEN
        g_currentUINode := g_currentUINode+1;
      ELSE
        SELECT CZ_UI_PAGE_ELEMENTS_S.nextval INTO g_currUISeqVal FROM dual;
        g_currentUINode := g_currUISeqVal;
      END IF;
      RETURN g_currentUINode;
    ELSIF p_sequence_name='CZ_UI_PAGE_REFS_S' THEN
      IF g_currentPageRef<g_currPageRefSeqVal+g_PageRefINCREMENT-1 THEN
        g_currentPageRef := g_currentPageRef+1;
      ELSE
        SELECT CZ_UI_PAGE_REFS_S.nextval INTO g_currPageRefSeqVal FROM dual;
        g_currentPageRef := g_currPageRefSeqVal;
      END IF;
      RETURN g_currentPageRef;
    ELSIF p_sequence_name='CZ_UI_PAGES_S' THEN
      IF g_currentPage<g_currPageSeqVal+g_PageINCREMENT-1 THEN
        g_currentPage := g_currentPage+1;
      ELSE
        SELECT CZ_UI_PAGES_S.nextval INTO g_currPageSeqVal FROM dual;
        g_currentPage := g_currPageSeqVal;
      END IF;
      RETURN g_currentPage;
    ELSIF p_sequence_name='CZ_UI_PAGE_SETS_S' THEN
      IF g_currentPageSet<g_currPageSetSeqVal+g_PageSetINCREMENT-1 THEN
        g_currentPageSet := g_currentPageSet+1;
      ELSE
        SELECT CZ_UI_PAGE_SETS_S.nextval INTO g_currPageSetSeqVal FROM dual;
        g_currentPageSet := g_currPageSetSeqVal;
      END IF;
      RETURN g_currentPageSet;
    ELSIF p_sequence_name='CZ_UI_ACTIONS_S' THEN
      IF g_currentUIAction<g_currUIActionSeqVal+g_UIActionINCREMENT-1 THEN
        g_currentUIAction := g_currentUIAction+1;
      ELSE
        SELECT CZ_UI_ACTIONS_S.nextval INTO g_currUIActionSeqVal FROM dual;
        g_currentUIAction := g_currUIActionSeqVal;
      END IF;
      RETURN g_currentUIAction;
    ELSIF p_sequence_name='CZ_INTL_TEXTS_S' THEN
      IF g_currentIntlText<g_currIntlTextSeqVal+g_IntlTextINCREMENT-1 THEN
        g_currentIntlText := g_currentIntlText+1;
      ELSE
        SELECT CZ_INTL_TEXTS_S.nextval INTO g_currIntlTextSeqVal FROM dual;
        g_currentIntlText := g_currIntlTextSeqVal;
      END IF;
      RETURN g_currentIntlText;
    ELSE
      EXECUTE IMMEDIATE 'SELECT ' || p_sequence_name || '.NEXTVAL FROM dual' INTO l_id;
      RETURN l_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE='-2289' THEN
        DEBUG('allocateId() : sequence '||p_sequence_name||' does not exist.');
      ELSE
        DEBUG('Sequence '||p_sequence_name||' can not be handled.');
      END IF;
      RAISE;
  END allocateId;

  PROCEDURE set_Local_UI_Context(p_ui_def_id IN NUMBER) IS
  BEGIN
    IF NOT(g_local_ui_context.EXISTS(p_ui_def_id)) THEN
      SELECT * INTO g_local_ui_context(p_ui_def_id) FROM CZ_UI_DEFS
      WHERE ui_def_id=p_ui_def_id;
    END IF;
  END set_Local_UI_Context;

  FUNCTION get_Local_UI_Context(p_ui_def_id IN NUMBER) RETURN CZ_UI_DEFS%ROWTYPE IS
  BEGIN
    IF NOT(g_local_ui_context.EXISTS(p_ui_def_id)) THEN
      SELECT * INTO g_local_ui_context(p_ui_def_id)
        FROM CZ_UI_DEFS
       WHERE ui_def_id=p_ui_def_id;
    END IF;
    RETURN g_local_ui_context(p_ui_def_id);
  END get_Local_UI_Context;

  --
  -- return new element_id
  --
  FUNCTION get_Element_Id RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(allocateId('CZ_UI_PAGE_ELEMENTS_S'));
  END get_Element_Id;

  --
  -- mark UI page as deleted
  --
  PROCEDURE mark_UI_Page_As_Refreshed(p_page_id   IN NUMBER,
                                      p_ui_def_id IN NUMBER) IS
  BEGIN
    UPDATE CZ_UI_PAGES
       SET deleted_flag = DECODE(deleted_flag,G_MARK_TO_ADD,
           G_MARK_TO_ADD,G_MARK_TO_REFRESH),
           page_rev_nbr=page_rev_nbr+1
     WHERE page_id=p_page_id AND
           ui_def_id=p_ui_def_id AND
           deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD,G_MARK_TO_REFRESH);
  END mark_UI_Page_As_Refreshed;

  --
  -- mark UI page as deleted
  --
  PROCEDURE mark_UI_Page_As_Deleted(p_page_id   IN NUMBER,
                                    p_ui_def_id IN NUMBER) IS
  BEGIN
    UPDATE CZ_UI_PAGES
       SET deleted_flag = G_MARK_TO_DELETE
     WHERE page_id=p_page_id AND
           ui_def_id=p_ui_def_id;
  END mark_UI_Page_As_Deleted;

  --
  -- mark UI as UI with errors
  --
  PROCEDURE mark_UI(p_ui_def_id IN NUMBER,
                    p_ui_status IN VARCHAR2) IS
  BEGIN
    UPDATE CZ_UI_DEFS
       SET ui_status=p_ui_status
     WHERE ui_def_id=p_ui_def_id;
  END  mark_UI;

  --
  -- refresh UI node marks
  --
  PROCEDURE refresh_UI_Node_Marks(p_page_id IN NUMBER,
                                  p_hmode   IN NUMBER) IS
  BEGIN

    IF p_hmode = G_DELETE_PAGE THEN

      UPDATE CZ_UI_PAGES
         SET page_rev_nbr = page_rev_nbr + 1,
             deleted_flag = G_YES_FLAG
       WHERE page_id = p_page_id AND
             ui_def_id = g_UI_Context.ui_def_id;
      --
      -- mark elements as already deleted
      --
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id= g_UI_Context.ui_def_id AND
             page_id=p_page_id;

    ELSIF p_hmode = G_DELETE_ELEMENTS THEN
      --
      -- mark elements as already deleted
      --
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id= g_UI_Context.ui_def_id AND
             page_id=p_page_id AND
             deleted_flag IN(G_MARK_TO_DELETE);

      IF SQL%ROWCOUNT>0 THEN
        --
        -- update revision of deleted UI page
        --
        UPDATE CZ_UI_PAGES
           SET page_rev_nbr = page_rev_nbr + 1
         WHERE page_id = p_page_id AND
               ui_def_id =  g_UI_Context.ui_def_id;
      END IF;

    ELSIF p_hmode = G_REFRESH_PAGE THEN

      --
      -- update page status and page_rev_nbr
      --  page_rev_nbr=1 because this is first creation
      --
      UPDATE CZ_UI_PAGES
         SET page_rev_nbr = page_rev_nbr+1,
             deleted_flag = G_NO_FLAG
       WHERE page_id = p_page_id AND ui_def_id = g_UI_Context.ui_def_id AND
             deleted_flag IN(G_MARK_TO_ADD,G_MARK_TO_REFRESH);

      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag = G_NO_FLAG
       WHERE ui_def_id = g_UI_Context.ui_def_id AND
             page_id = p_page_id AND
             deleted_flag NOT IN(G_NO_FLAG,G_YES_FLAG,G_LIMBO_FLAG);

    ELSIF p_hmode = G_NEW_PAGE THEN

      UPDATE CZ_UI_PAGES
         SET page_rev_nbr = 1,
             deleted_flag = G_NO_FLAG
       WHERE page_id = p_page_id AND ui_def_id =  g_UI_Context.ui_def_id AND
             deleted_flag IN(G_MARK_TO_ADD,G_MARK_TO_REFRESH);

      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag = G_NO_FLAG
       WHERE ui_def_id =  g_UI_Context.ui_def_id AND
             page_id = p_page_id AND
             deleted_flag NOT IN(G_NO_FLAG,G_YES_FLAG,G_LIMBO_FLAG);
    ELSE
      NULL;
      /*
      UPDATE CZ_UI_PAGES
         SET deleted_flag = G_NO_FLAG
       WHERE page_id = p_page_id AND ui_def_id =  g_UI_Context.ui_def_id AND
             deleted_flag NOT IN(G_YES_FLAG,G_LIMBO_FLAG,G_MARK_TO_DELETE);

      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag = G_NO_FLAG
       WHERE ui_def_id =  g_UI_Context.ui_def_id AND
             page_id = p_page_id AND
             deleted_flag NOT IN(G_YES_FLAG,G_LIMBO_FLAG,G_MARK_TO_DELETE);
      */
    END IF;

  END refresh_UI_Node_Marks;


  --
  -- get and save Transalations for a given JRAD document
  --
  PROCEDURE translate_JRAD_Doc(p_jrad_doc_name IN VARCHAR2) IS
  BEGIN
    jdr_docbuilder.refresh;

    g_jrad_trans_list := jdr_utils.getTranslations(p_jrad_doc_name);

    IF g_jrad_trans_list IS NOT NULL THEN
      jdr_utils.saveTranslations(p_jrad_doc_name,g_jrad_trans_list);
    END IF;
  END translate_JRAD_Doc;

  --
  -- returns viewname given the prefix
  --
  FUNCTION get_next_view_name(p_view_name_prefix IN VARCHAR) RETURN VARCHAR2 IS

  BEGIN

    IF p_view_name_prefix='COMP' THEN
      g_mandatory_comp_counter := g_mandatory_comp_counter+1;
      RETURN p_view_name_prefix || '_' || g_mandatory_comp_counter;
    ELSIF p_view_name_prefix='SIM' THEN
      g_optional_ref_counter := g_optional_ref_counter+1;
      RETURN p_view_name_prefix || '_' || g_optional_ref_counter;
    ELSIF p_view_name_prefix='CS' THEN
      g_minmax_ref_counter := g_minmax_ref_counter+1;
      RETURN p_view_name_prefix || '_' || g_minmax_ref_counter;
    ELSIF p_view_name_prefix='OF' THEN
      g_of_feature_counter := g_of_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_of_feature_counter;
    ELSIF p_view_name_prefix='IF' THEN
      g_if_feature_counter := g_if_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_if_feature_counter;
    ELSIF p_view_name_prefix='DF' THEN
      g_df_feature_counter := g_df_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_df_feature_counter;
    ELSIF p_view_name_prefix='BF' THEN
      g_bf_feature_counter := g_bf_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_bf_feature_counter;
    ELSIF p_view_name_prefix='TF' THEN
      g_tf_feature_counter := g_tf_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_tf_feature_counter;
    ELSIF p_view_name_prefix='TOT' THEN
      g_tot_feature_counter := g_tot_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_tot_feature_counter;
    ELSIF p_view_name_prefix='RSC' THEN
      g_rsc_feature_counter := g_rsc_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_rsc_feature_counter;
    ELSIF p_view_name_prefix='ITOT' THEN
      g_itot_feature_counter := g_itot_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_itot_feature_counter;
    ELSIF p_view_name_prefix='IRSC' THEN
      g_irsc_feature_counter := g_irsc_feature_counter+1;
      RETURN p_view_name_prefix || '_' || g_irsc_feature_counter;
    ELSIF p_view_name_prefix='REF' THEN
      g_mandatory_ref_counter := g_mandatory_ref_counter+1;
      RETURN p_view_name_prefix || '_' || g_mandatory_ref_counter;
    ELSIF p_view_name_prefix='CON' THEN
      g_connector_counter := g_connector_counter+1;
      RETURN p_view_name_prefix || '_' || g_connector_counter;
    ELSIF p_view_name_prefix='BOMM' THEN
      g_bomm_counter := g_bomm_counter+1;
      RETURN p_view_name_prefix || '_' || g_bomm_counter;
    ELSIF p_view_name_prefix='OPT' THEN
      g_opt_counter := g_opt_counter+1;
      RETURN p_view_name_prefix || '_' || g_opt_counter;
    END IF;
  END get_next_view_name;

  --
  -- return name of node type
  --
  FUNCTION get_View_Name(p_ui_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                         x_has_children OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    l_view_name VARCHAR2(255);
  BEGIN
    x_has_children := G_NO_FLAG;

    IF p_ui_node.detailed_type_id IN (CZ_TYPES.UMANDATORY_COMPONENT_TYPEID) THEN

      g_mandatory_comp_counter := g_mandatory_comp_counter + 1;
      l_view_name              := 'COMP_' ||
                                  TO_CHAR(g_mandatory_comp_counter);
      x_has_children           := G_YES_FLAG;

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UOPTIONAL_COMPONENT_TYPEID) THEN

      g_optional_ref_counter := g_optional_ref_counter + 1;
      l_view_name            := 'SIM_' || TO_CHAR(g_optional_ref_counter);
      -- x_has_children         := G_YES_FLAG; -- Shantaram's requitement 08/04/2004

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UMINMAX_COMPONENT_TYPEID) THEN

      g_minmax_ref_counter := g_minmax_ref_counter + 1;
      l_view_name          := 'CS_' || TO_CHAR(g_minmax_ref_counter);
      x_has_children       := G_YES_FLAG;

    ELSIF p_ui_node.detailed_type_id IN
          (CZ_TYPES.UNON_COUNT_FEATURE_TYPEID, CZ_TYPES.UCOUNT_FEATURE_TYPEID,
           CZ_TYPES.UCOUNT_FEATURE01_TYPEID, CZ_TYPES.UMINMAX_FEATURE_TYPEID) THEN

      g_of_feature_counter := g_of_feature_counter + 1;
      l_view_name          := 'OF_' || TO_CHAR(g_of_feature_counter);
      x_has_children       := G_YES_FLAG;

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UINTEGER_FEATURE_TYPEID) THEN

      g_if_feature_counter := g_if_feature_counter + 1;
      l_view_name          := 'IF_' || TO_CHAR(g_if_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UDECIMAL_FEATURE_TYPEID) THEN

      g_df_feature_counter := g_df_feature_counter + 1;
      l_view_name          := 'DF_' || TO_CHAR(g_df_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UBOOLEAN_FEATURE_TYPEID) THEN

      g_bf_feature_counter := g_bf_feature_counter + 1;
      l_view_name          := 'BF_' || TO_CHAR(g_bf_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UTEXT_FEATURE_TYPEID) THEN

      g_tf_feature_counter := g_tf_feature_counter + 1;
      l_view_name          := 'TF_' || TO_CHAR(g_tf_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UTOTAL_TYPEID) AND p_ui_node.ps_node_type=CZ_TYPES.PS_NODE_TYPE_TOTAL THEN

      g_tot_feature_counter := g_tot_feature_counter + 1;
      l_view_name           := 'TOT_' || TO_CHAR(g_tot_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.URESOURCE_TYPEID) AND p_ui_node.ps_node_type=CZ_TYPES.PS_NODE_TYPE_RESOURCE THEN

      g_rsc_feature_counter := g_rsc_feature_counter + 1;
      l_view_name           := 'RSC_' || TO_CHAR(g_rsc_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UTOTAL_TYPEID) AND p_ui_node.ps_node_type=CZ_TYPES.PS_NODE_TYPE_INT_TOTAL THEN

      g_itot_feature_counter := g_itot_feature_counter + 1;
      l_view_name           := 'ITOT_' || TO_CHAR(g_itot_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.URESOURCE_TYPEID) AND p_ui_node.ps_node_type=CZ_TYPES.PS_NODE_TYPE_INT_RESOURCE THEN

      g_irsc_feature_counter := g_irsc_feature_counter + 1;
      l_view_name           := 'IRSC_' || TO_CHAR(g_irsc_feature_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UMANDATORY_REF_TYPEID) THEN

      g_mandatory_ref_counter := g_mandatory_ref_counter + 1;
      l_view_name             := 'REF_' || TO_CHAR(g_mandatory_ref_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID) THEN

      g_optional_ref_counter := g_optional_ref_counter + 1;
      l_view_name            := 'SIM_' || TO_CHAR(g_optional_ref_counter);
      --x_has_children         := G_YES_FLAG; -- Shantaram's requitement 09/01/2004
    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN

      g_minmax_ref_counter := g_minmax_ref_counter + 1;
      l_view_name          := 'CS_' || TO_CHAR(g_minmax_ref_counter);
      x_has_children       := G_YES_FLAG;
    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UCONNECTOR_TYPEID) THEN

      g_connector_counter := g_connector_counter + 1;
      l_view_name         := 'CON_' || TO_CHAR(g_connector_counter);

    ELSIF p_ui_node.detailed_type_id IN (CZ_TYPES.UMINMAX_CONNECTOR) THEN

      g_connector_counter := g_connector_counter + 1;
      l_view_name         := 'CON_' || TO_CHAR(g_connector_counter);
      x_has_children      := G_YES_FLAG;
    ELSIF p_ui_node.detailed_type_id IN
         (CZ_TYPES.UBOM_NSTBOM_NQMTX_TYPEID
         ,CZ_TYPES.UBOM_NSTBOM_NQNMTX_TYPEID
         ,CZ_TYPES.UBOM_NSTBOM_QNMTX_TYPEID
         ,CZ_TYPES.UBOM_NSTBOM_QMTX_TYPEID
         ,CZ_TYPES.UBOM_STIO_NQMTX_TYPEID
         ,CZ_TYPES.UBOM_STIO_NQNMTX_TYPEID
         ,CZ_TYPES.UBOM_STIO_QNMTX_TYPEID
         ,CZ_TYPES.UBOM_STIO_QMTX_TYPEID) THEN

      g_bomm_counter := g_bomm_counter + 1;
      l_view_name    := 'BOMM_' || TO_CHAR(g_bomm_counter);
      x_has_children := G_YES_FLAG;

    ELSIF p_ui_node.detailed_type_id=CZ_TYPES.UBOM_STANDART_ITEM_TYPEID THEN
      g_bomm_counter := g_bomm_counter + 1;
      l_view_name    := 'BOMM_' || TO_CHAR(g_bomm_counter);

    ELSIF p_ui_node.detailed_type_id=CZ_TYPES.UOPTION_TYPEID THEN
      g_opt_counter := g_opt_counter + 1;
      l_view_name    := 'OPT_' || TO_CHAR(g_opt_counter);

    ELSE
      NULL;
    END IF;

    RETURN l_view_name;
  END get_View_Name;

  --
  -- return COUNT ( of UI pages of a given UI) + 1
  --
  FUNCTION get_Page_Counter RETURN NUMBER IS
    l_page_counter NUMBER;
  BEGIN
    --
    -- if it is cached then get it from cache
    --
    SELECT COUNT(page_id)
      INTO l_page_counter
      FROM CZ_UI_PAGES
     WHERE ui_def_id = g_UI_Context.ui_def_id;

    RETURN l_page_counter;

  END get_Page_Counter;

  --
  -- construct JRAD Page/Region name based on ui_def_id and page_id
  --   Parameters : p_page_id - identifies UI page ( -> CZ_UI_PAGES.page_id )
  --   Return     : JRAD Page/Region name
  --
  FUNCTION generate_JRAD_Page_Name(p_page_counter IN NUMBER)
    RETURN VARCHAR2 IS

    l_jrad_doc  CZ_UI_PAGES.jrad_doc%TYPE;
    l_counter   NUMBER;

  BEGIN

    --
    -- generate Page Name based on l_master_template_node.ui_def_id ( global variable - scope is "current UI" )
    -- and g_PAGE_COUNTER ( global variable - scope is "current UI" )
    --
    l_jrad_doc := '/oracle/apps/cz/runtime/oa/webui/regions/ui' ||
      TO_CHAR(g_UI_Context.ui_def_id) || '/Page_' ||TO_CHAR(g_UI_Context.ui_def_id)||'_'||
      TO_CHAR(p_page_counter);

    SELECT COUNT(*) INTO l_counter FROM CZ_UI_PAGES
    WHERE ui_def_id=g_UI_Context.ui_def_id AND jrad_doc=l_jrad_doc;

    IF l_counter>0 THEN
      l_counter:=l_counter+1;
      l_jrad_doc := l_jrad_doc||'_'||TO_CHAR(l_counter);

      LOOP
        SELECT COUNT(*) INTO l_counter FROM CZ_UI_PAGES
        WHERE ui_def_id=g_UI_Context.ui_def_id AND jrad_doc=l_jrad_doc;
        IF l_counter=0 THEN
          EXIT;
        ELSE
          l_counter:=l_counter+1;
          l_jrad_doc := l_jrad_doc||'_'||TO_CHAR(l_counter);
        END IF;
      END LOOP;
    END IF;

    RETURN l_jrad_doc;
  END generate_JRAD_Page_Name;

  --
  -- get short JRAD name
  --
  FUNCTION get_Short_JRAD_Name(p_full_jrad_name IN VARCHAR2)
    RETURN VARCHAR2 IS
    l_str VARCHAR2(4000);
    l_num NUMBER;
  BEGIN
    l_str := p_full_jrad_name;

    LOOP
      l_num := INSTR(l_str,'/');
      IF l_num > 0 THEN
         l_str := SUBSTR(l_str,l_num+1);
         IF l_str IS NULL THEN
           EXIT;
         END IF;
      ELSE
         EXIT;
      END IF;
    END LOOP;
    RETURN l_str;
  END get_Short_JRAD_Name;

  --
  -- return CZ_UI_DEFS data of Master Template Settings
  --
  FUNCTION get_UI_Def_Node(p_ui_def_id IN NUMBER) RETURN CZ_UI_DEFS%ROWTYPE IS
  BEGIN
    --
    -- if cache contains given ui_def_id then get it from cache
    --
    IF NOT(g_ui_def_nodes_tbl.EXISTS(p_ui_def_id)) THEN
      SELECT * INTO g_ui_def_nodes_tbl(p_ui_def_id)
        FROM CZ_UI_DEFS
       WHERE ui_def_id = p_ui_def_id;
    END IF;
    RETURN g_ui_def_nodes_tbl(p_ui_def_id);
  END get_UI_Def_Node;

  --
  -- return data for model node with ps_node_id = p_ps_node_id
  -- ( private )
  -- Parameters :
  --   p_ps_node_id - identifies node in Model tree
  --
  FUNCTION get_Model_Node(p_ps_node_id IN NUMBER)
    RETURN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE IS
  BEGIN
    -- if cache is populated then get it from cache
    IF NOT(g_model_nodes_tbl.EXISTS(p_ps_node_id)) THEN
      SELECT DISTINCT *
        INTO g_model_nodes_tbl(p_ps_node_id)
        FROM CZ_UITEMPLS_FOR_PSNODES_V
       WHERE ps_node_id = p_ps_node_id AND
             ui_def_id=g_UI_Context.from_master_template_id AND
             deleted_flag = G_NO_FLAG;

---Bug6406709
      IF g_model_nodes_tbl(p_ps_node_id).ui_omit = G_YES_FLAG AND g_UI_Context.show_all_nodes_flag = G_YES_FLAG THEN
          g_model_nodes_tbl(p_ps_node_id).ui_omit := G_NO_FLAG;
      END IF;

       g_ps_node_persist_id_tbl(g_model_nodes_tbl(p_ps_node_id).persistent_node_id) := p_ps_node_id;
    END IF;
    RETURN g_model_nodes_tbl(p_ps_node_id);
  END get_Model_Node;

  --
  -- get persistent_node_id of root node
  --
  FUNCTION get_Root_Persistent_Node_Id
    RETURN NUMBER IS
  BEGIN
    -- if cache is populated then get it from cache
    IF NOT(g_root_persist_id_tbl.EXISTS(g_UI_Context.devl_project_id)) THEN
      IF g_model_nodes_tbl.EXISTS(g_UI_Context.devl_project_id) THEN
        g_root_persist_id_tbl(g_UI_Context.devl_project_id) := g_model_nodes_tbl(g_UI_Context.devl_project_id).persistent_node_id;
      ELSE
        SELECT persistent_node_id
          INTO g_root_persist_id_tbl(g_UI_Context.devl_project_id)
          FROM CZ_PS_NODES
         WHERE devl_project_id=g_UI_Context.devl_project_id AND
               parent_id IS NULL AND
               deleted_flag=G_NO_FLAG;
      END IF;
    END IF;
    RETURN g_root_persist_id_tbl(g_UI_Context.devl_project_id);
  END get_Root_Persistent_Node_Id;

  --
  -- return data for model node with a given persistent node id
  -- ( private )
  -- Parameters :
  --   p_persistent_node_id - persistent id of model node
  --   p_model_id           - identifies model
  --   p_ui_def_id          - identifies UI Master Template Setting
  --
  FUNCTION get_Model_Node_By_Persist_Id(p_persistent_node_id IN NUMBER,
                                        p_model_id           IN NUMBER)
    RETURN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE IS
    l_node       CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_ps_node_id NUMBER;
  BEGIN
    -- if cache is populated then get it from cache
    SELECT DISTINCT *
      INTO l_node
      FROM CZ_UITEMPLS_FOR_PSNODES_V
     WHERE devl_project_id = p_model_id AND
           persistent_node_id = p_persistent_node_id AND
           ui_def_id=g_UI_Context.from_master_template_id AND
           deleted_flag = G_NO_FLAG;

---Bug6406709
      IF l_node.ui_omit = G_YES_FLAG AND  g_UI_Context.show_all_nodes_flag = G_YES_FLAG THEN
          l_node.ui_omit := G_NO_FLAG;
      END IF;

     RETURN l_node;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_node;
  END get_Model_Node_By_Persist_Id;
  --vsingava IM-ER
  FUNCTION getNodeByPersistentAndExplId(p_persistent_node_id IN NUMBER,
                                        p_expl_id           IN NUMBER)
    RETURN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE IS
    l_node       CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_reference_id NUMBER;
    l_model_id NUMBER;
    l_ps_node_type NUMBER;

  BEGIN

    SELECT component_id, model_id, ps_node_type INTO l_reference_id, l_model_id, l_ps_node_type
      FROM cz_model_ref_expls
     WHERE model_ref_expl_id = p_expl_id
       AND deleted_flag = G_NO_FLAG;

    l_node := get_Model_Node_By_Persist_Id(p_persistent_node_id, l_reference_id);

    IF l_node.ps_node_id IS NULL THEN
      -- Couldn't find the node in the referenced model. The AMN could be the root
      -- node of the referenced model, in which case the persistent_node_Id could
      -- be that of the referring node. So, let's look in the model containing the
      -- this model_ref_explosion_id
      l_node := get_Model_Node_By_Persist_Id(p_persistent_node_id, l_model_id);
    END IF;

    IF ( l_node.ps_node_id IS NULL AND l_ps_node_type = G_REFERENCE_TYPE ) THEN
      -- This could be a case where Developer sets the explosion_id from the context of
      -- the model for the UI being processed, and the persistent_node_id from the context of
      -- the model containing the actual reference (263) node

      -- Let's go through the reference chain starting from this model down to the referred model
      FOR i in (SELECT model_ref_expl_id, child_model_expl_id, model_id
                  FROM cz_model_ref_expls
            START WITH model_ref_expl_Id = p_expl_id
            CONNECT BY PRIOR child_model_expl_id = model_ref_expl_Id
                   AND deleted_flag = G_NO_FLAG)
      LOOP
        l_node := get_Model_Node_By_Persist_Id(p_persistent_node_id, i.model_id);
        IF l_node.ps_node_id IS NOT NULL THEN
          RETURN l_node;
        END IF;
      END LOOP;
    END IF;

    RETURN l_node;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_node;
  END getNodeByPersistentAndExplId;

  --
  -- return data for model node with ps_node_id = p_ps_node_id
  -- ( private )
  --
  PROCEDURE  get_Child_Nodes(p_ps_node_id       IN  NUMBER,
                             p_show_all_nodes   IN  VARCHAR2 DEFAULT NULL,
                             x_seq_nodes_tbl    OUT NOCOPY ui_page_el_int_tbl_type, -- fix for bug 6837809 : skudryav 28-Mar-2008
                             x_child_nodes_tbl  OUT NOCOPY model_nodes_tbl_type,
                             x_non_deleted_child_nodes_tbl  OUT NOCOPY model_nodes_tbl_type,
                             p_include_deleted_nodes IN VARCHAR2 DEFAULT G_NO_FLAG) IS

    l_current_model_node   CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_ps_node_id           NUMBER;

  BEGIN

    IF g_Use_Cache AND g_model_nodes_tbl.EXISTS(p_ps_node_id) THEN
      l_ps_node_id := g_model_nodes_tbl.First;
      LOOP
        IF l_ps_node_id IS NULL THEN
           EXIT;
        END IF;
        l_current_model_node := g_model_nodes_tbl(l_ps_node_id);
        IF l_current_model_node.parent_id=p_ps_node_id  THEN
          IF (l_current_model_node.ui_omit=G_NO_FLAG OR p_show_all_nodes = G_YES_FLAG) THEN
            x_child_nodes_tbl(l_current_model_node.persistent_node_id) := l_current_model_node;
            x_seq_nodes_tbl(x_seq_nodes_tbl.COUNT+1) := l_current_model_node;
          END IF;
          IF l_current_model_node.deleted_flag = G_NO_FLAG THEN
            x_non_deleted_child_nodes_tbl(x_non_deleted_child_nodes_tbl.COUNT+1) := l_current_model_node;
          END IF;
        END IF;

        l_ps_node_id := g_model_nodes_tbl.NEXT(l_ps_node_id);
      END LOOP;

    ELSE  -- cache is not used

      FOR i IN (SELECT DISTINCT *
                  FROM CZ_UITEMPLS_FOR_PSNODES_V
                 WHERE ui_def_id=g_UI_Context.from_master_template_id AND
                       parent_id = p_ps_node_id AND
                       (ui_omit = G_NO_FLAG OR p_show_all_nodes = G_YES_FLAG) AND
                       (p_include_deleted_nodes = G_YES_FLAG OR deleted_flag = G_NO_FLAG)
                 ORDER BY tree_seq)
      LOOP
        IF i.deleted_flag = G_NO_FLAG AND i.detailed_type_id=G_UNDEFINED_DATA_TYPE THEN
           g_WRONG_PS_NODE_ID := i.ps_node_id;
           DEBUG('get_Child_Nodes() error message : node with ps_node_id='||TO_CHAR(i.ps_node_id)||
                 ' has undefined detailed type.');
           RAISE WRONG_EXT_PS_TYPE;
        END IF;

---Bug6406709
        IF i.ui_omit = G_YES_FLAG AND p_show_all_nodes = G_YES_FLAG THEN
            i.ui_omit := G_NO_FLAG;
        END IF;

        x_child_nodes_tbl(i.persistent_node_id) := i;
        x_seq_nodes_tbl(x_seq_nodes_tbl.COUNT+1) := i;

        IF i.deleted_flag = G_NO_FLAG THEN
          x_non_deleted_child_nodes_tbl(x_non_deleted_child_nodes_tbl.COUNT+1) := i;
        END IF;
      END LOOP;
    END IF;
  END get_Child_Nodes;

  --
  -- return expl data for model node with ps_node_id = p_ps_node_id
  -- ( private )
  --
  FUNCTION get_Expl_Id(p_model_id     IN NUMBER,
                       p_ps_node_id   IN NUMBER,
                       p_component_id IN NUMBER,
                       p_ps_node_type IN NUMBER) RETURN NUMBER IS

    l_model_ref_expl_id CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;

  BEGIN

    IF p_ps_node_id IS NOT NULL AND (p_component_id IS NULL OR p_component_id=0) THEN
      DEBUG('Wrong data in CZ_PS_NODES. Node with ps_node_id='||TO_CHAR(p_ps_node_id)||
      ' has invalid component_id='||TO_CHAR(p_component_id));
      RETURN 0;
    END IF;

    --
    -- if cache is populated then get it from cache
    --
    IF g_ref_expls_tbl.EXISTS(p_ps_node_id) THEN
      l_model_ref_expl_id := g_ref_expls_tbl(p_ps_node_id);
    ELSE

      IF p_ps_node_type NOT IN(G_REFERENCE_TYPE,G_CONNECTOR_TYPE) AND g_ref_expls_tbl.EXISTS(p_component_id) THEN
        l_model_ref_expl_id := g_ref_expls_tbl(p_component_id);
        g_ref_expls_tbl(p_ps_node_id) := l_model_ref_expl_id;
      ELSE
        IF p_ps_node_type IN (G_REFERENCE_TYPE, G_CONNECTOR_TYPE) THEN
          SELECT MIN(model_ref_expl_id)
            INTO l_model_ref_expl_id
            FROM CZ_MODEL_REF_EXPLS a
           WHERE model_id = p_model_id AND
                 referring_node_id = p_ps_node_id AND
                 deleted_flag = G_NO_FLAG;
        ELSE
          SELECT MIN(model_ref_expl_id)
            INTO l_model_ref_expl_id
            FROM CZ_MODEL_REF_EXPLS
           WHERE model_id = p_model_id AND
                 component_id = p_component_id AND
                 referring_node_id IS NULL AND
                 deleted_flag = G_NO_FLAG;
        END IF;
      END IF;

    END IF;

    RETURN l_model_ref_expl_id;

  EXCEPTION
    WHEN OTHERS THEN
      DEBUG('get_Expl_Id() node with ps_node_id='||TO_CHAR(p_ps_node_id)||
      ' can not be handled : '||SQLERRM);
      RETURN 0;
  END get_Expl_Id;

  --
  -- return UI page node
  --
  FUNCTION get_UI_Page_Node(p_page_id IN NUMBER)
    RETURN CZ_UI_PAGES%ROWTYPE IS
      l_page_node CZ_UI_PAGES%ROWTYPE;
  BEGIN
    SELECT * INTO l_page_node
      FROM CZ_UI_PAGES
     WHERE page_id=p_page_id AND
           ui_def_id=g_UI_Context.ui_def_id;
    RETURN l_page_node;
  END get_UI_Page_Node;

  --
  -- return UI element with element_id = p_element_id
  --
  FUNCTION get_UI_Element(p_element_id IN VARCHAR2,
                          p_page_id    IN NUMBER)
    RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE IS
    l_ui_node         CZ_UI_PAGE_ELEMENTS%ROWTYPE;
  BEGIN
    SELECT *
      INTO l_ui_node
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id = g_UI_Context.ui_def_id AND
           page_id=p_page_id AND
           element_id = p_element_id;
    RETURN l_ui_node;
  END get_UI_Element;

  --
  -- return UI element with element_id = p_element_id
  --
  FUNCTION get_Page_Set(p_page_set_id IN NUMBER)
    RETURN CZ_UI_PAGE_SETS%ROWTYPE IS
    l_page_set_node CZ_UI_PAGE_SETS%ROWTYPE;
  BEGIN
    SELECT *
      INTO l_page_set_node
      FROM CZ_UI_PAGE_SETS
     WHERE page_set_id = p_page_set_id AND
           ui_def_id=g_UI_Context.ui_def_id;
    RETURN l_page_set_node;
  END get_Page_Set;

  FUNCTION get_UI_Node_Name(p_page_id       IN NUMBER,
                            p_template_id   IN NUMBER,
                            p_template_name IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS

    l_counter      NUMBER;
    l_ui_node_name CZ_UI_PAGE_ELEMENTS.name%TYPE;

  BEGIN

    SELECT COUNT(element_id)+1 INTO l_counter FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          page_id=p_page_id AND
          ctrl_template_id=p_template_id AND
          deleted_flag NOT IN(G_YES_FLAG,G_LIMBO_FLAG,G_MARK_TO_DELETE);

    IF p_template_name IS NULL THEN
      BEGIN
        SELECT template_name||' - '||TO_CHAR(l_counter)
          INTO l_ui_node_name
          FROM CZ_UI_TEMPLATES
          WHERE template_id=p_template_id AND
                ui_def_id=g_UI_Context.ui_def_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT template_name||' - '||TO_CHAR(l_counter)
            INTO l_ui_node_name
            FROM CZ_UI_TEMPLATES
           WHERE template_id=p_template_id AND
                ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID;
      END;
    ELSE
      l_ui_node_name := p_template_name||' - '||TO_CHAR(l_counter);
    END IF;

    RETURN l_ui_node_name;
  END get_UI_Node_Name;

  --
  -- return full JRAD name of UI template
  --
  FUNCTION get_JRAD_Name(p_template_id        IN NUMBER,
                         p_template_ui_def_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS

  BEGIN
    --
    -- if it is in cache get it from cache
    --
    IF g_template_jrad_name_tbl.EXISTS(p_template_id) AND p_template_ui_def_id IS NOT NULL THEN
       RETURN  g_template_jrad_name_tbl(p_template_id);
    ELSE
      IF p_template_ui_def_id IS NOT NULL THEN
        SELECT jrad_doc INTO g_template_jrad_name_tbl(p_template_id)
          FROM CZ_UI_TEMPLATES
         WHERE template_id=p_template_id AND
               ui_def_id=p_template_ui_def_id;
      ELSE
        BEGIN
          SELECT jrad_doc INTO g_template_jrad_name_tbl(p_template_id)
            FROM CZ_UI_TEMPLATES
           WHERE  template_id=p_template_id AND
                  ui_def_id=g_UI_Context.ui_def_id;
        EXCEPTION
          WHEN OTHERS THEN
            SELECT jrad_doc INTO g_template_jrad_name_tbl(p_template_id)
              FROM CZ_UI_TEMPLATES
             WHERE template_id=p_template_id AND
                   ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID;
        END;
      END IF;
    END IF;
    RETURN g_template_jrad_name_tbl(p_template_id);
  END get_JRAD_Name;

  --
  -- get UI Action Id associated with a given ui node
  --
  FUNCTION get_UI_Action_Id(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE)
    RETURN NUMBER IS
   l_ui_action_id   CZ_UI_ACTIONS.ui_action_id%TYPE;
  BEGIN
    SELECT ui_action_id
      INTO l_ui_action_id
      FROM CZ_UI_ACTIONS
     WHERE ui_def_id = p_ui_node.ui_def_id AND
           source_page_id=p_ui_node.page_id AND
           element_id = p_ui_node.element_id AND
           deleted_flag=G_NO_FLAG;
    RETURN l_ui_action_id;
  END get_UI_Action_Id;

  --
  -- copy CZ_INTL_TEXTS record
  --
  FUNCTION copy_Intl_Text(p_intl_text_id     IN NUMBER,
                          p_target_ui_def_id IN NUMBER,
                          p_page_id          IN NUMBER,
                          p_element_id       IN NUMBER) RETURN NUMBER IS

    l_ui_intl_text_id NUMBER;
    l_model_id        NUMBER;
    l_seeded_flag     VARCHAR2(1);

  BEGIN

    IF p_intl_text_id IS NULL OR p_intl_text_id=0 THEN
      RETURN p_intl_text_id;
    ELSE
      SELECT seeded_flag INTO l_seeded_flag FROM CZ_INTL_TEXTS
      WHERE intl_text_id=p_intl_text_id;
    END IF;

    IF l_seeded_flag='0' OR l_seeded_flag IS NULL THEN
     IF p_target_ui_def_id IS NOT NULL AND p_target_ui_def_id<>0 THEN
       SELECT NVL(devl_project_id,0) INTO l_model_id FROM CZ_UI_DEFS
       WHERE ui_def_id=p_target_ui_def_id;
     END IF;
     l_ui_intl_text_id := allocateId('CZ_INTL_TEXTS_S');

      INSERT INTO CZ_INTL_TEXTS
           (INTL_TEXT_ID,
            TEXT_STR,
            DELETED_FLAG,
            SEEDED_FLAG,
            UI_DEF_ID,
            MODEL_ID,
            UI_PAGE_ID,
            UI_PAGE_ELEMENT_ID
            )
      SELECT
           l_ui_intl_text_id,
           text_str,
           G_NO_FLAG,
           G_NO_FLAG,
           p_target_ui_def_id,
           l_model_id,
           p_page_id,
           p_element_id
      FROM CZ_INTL_TEXTS
      WHERE intl_text_id=p_intl_text_id;
      RETURN l_ui_intl_text_id;
    ELSE
      RETURN p_intl_text_id;
    END IF;
  END copy_Intl_Text;

  --
  -- refresh UI Images in UI based on data from Master Template
  --
  PROCEDURE refresh_UI_Images(p_ui_def_id IN NUMBER, p_master_template_id IN NUMBER) IS
  BEGIN

    INSERT INTO CZ_UI_IMAGES
      (UI_DEF_ID
       ,MASTER_TEMPLATE_FLAG
       ,IMAGE_USAGE_CODE
       ,IMAGE_FILE
       ,DELETED_FLAG
       ,SEEDED_FLAG
       ,ENTITY_CODE,
       LAST_UPDATE_LOGIN)
    SELECT
       p_ui_def_id
       ,G_NO_FLAG
       ,IMAGE_USAGE_CODE
       ,IMAGE_FILE
       ,DELETED_FLAG
       ,G_NO_FLAG
       ,ENTITY_CODE
       ,-UID
     FROM CZ_UI_IMAGES a
     WHERE ui_def_id=p_master_template_id
           AND deleted_flag=G_NO_FLAG AND
           NOT EXISTS(SELECT NULL FROM CZ_UI_IMAGES
                      WHERE ui_def_id=p_ui_def_id AND
                            IMAGE_USAGE_CODE=a.IMAGE_USAGE_CODE AND
                            ENTITY_CODE=a.ENTITY_CODE AND deleted_flag=G_NO_FLAG);
    /*
    UPDATE CZ_UI_IMAGES a
       SET IMAGE_FILE=(SELECT IMAGE_FILE FROM CZ_UI_IMAGES
                       WHERE  ui_def_id=p_master_template_id AND
                            IMAGE_USAGE_CODE=a.IMAGE_USAGE_CODE AND
                            ENTITY_CODE=a.ENTITY_CODE AND deleted_flag=G_NO_FLAG )
    WHERE ui_def_id=p_ui_def_id AND deleted_flag=G_NO_FLAG;
    */
  END refresh_UI_Images;

  PROCEDURE refresh_Cont_Templs
  (p_content_type       IN NUMBER,
   p_master_template_id IN NUMBER,
   p_ui_def_id          IN NUMBER,
   p_create_cont_entry  IN BOOLEAN) IS

    l_template_ui_def_id NUMBER;

  BEGIN

    IF p_create_cont_entry THEN
      l_template_ui_def_id := g_UI_Context.ui_def_id;
    ELSE
      l_template_ui_def_id := G_GLOBAL_TEMPLATES_UI_DEF_ID;
    END IF;
    FOR h IN(SELECT * FROM CZ_UI_CONT_TYPE_TEMPLS
             WHERE ui_def_id = p_master_template_id AND
                   content_type=p_content_type AND
                   deleted_flag=G_NO_FLAG)
    LOOP
      BEGIN
        INSERT INTO CZ_UI_CONT_TYPE_TEMPLS
                (ui_def_id,
                 content_type,
                 template_id,
                 master_template_flag,
                 seeded_flag,
                 template_ui_def_id,
                 deleted_flag)
        VALUES(
                 p_ui_def_id,
                 h.content_type,
                 h.template_id,
                 G_NO_FLAG,
                 G_NO_FLAG,
                 l_template_ui_def_id,
                 G_NO_FLAG);
        --
        -- populate cache of UI Templates
        --
        g_template_id_tbl(h.content_type) := h.template_id;
        g_template_ui_def_id_tbl(h.content_type) := l_template_ui_def_id;

      EXCEPTION
        WHEN OTHERS THEN
          DEBUG(SQLERRM);
      END;
    END LOOP;
  END refresh_Cont_Templs;

  PROCEDURE save_Template_As_Local
  (p_template_id IN NUMBER,
   p_ui_def_id   IN NUMBER) IS

    l_xmldoc                 xmldom.DOMDocument;
    l_jrad_doc               VARCHAR2(4000);
    l_template_jrad_doc      CZ_UI_TEMPLATES.jrad_doc%TYPE;

  BEGIN

    l_template_jrad_doc := get_JRAD_Name(p_template_id, G_GLOBAL_TEMPLATES_UI_DEF_ID);

    l_jrad_doc := '/oracle/apps/cz/runtime/oa/webui/regions/ui' ||
                  TO_CHAR(p_ui_def_id) || '/' ||
                  get_Short_JRAD_Name(l_template_jrad_doc);
    BEGIN

      --
      -- create UI Template in JRAD repository
      --
      l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_template_jrad_doc);

      IF xmldom.isNull(l_xmldoc) THEN
         add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                           p_token_name   => 'UI_TEMPLATE',
                           p_token_value  => l_template_jrad_doc,
                           p_fatal_error  => TRUE);
         RAISE WRONG_UI_TEMPLATE;
      END IF;

      Save_Document(p_xml_doc   => l_xmldoc,
                    p_doc_name  => l_jrad_doc);

    EXCEPTION
      WHEN OTHERS THEN
         add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                           p_token_name   => 'UI_TEMPLATE',
                           p_token_value  => l_template_jrad_doc,
                           p_fatal_error  => TRUE);
         RAISE WRONG_UI_TEMPLATE;
    END;

    BEGIN
      INSERT INTO CZ_UI_TEMPLATES
      (TEMPLATE_ID,
       UI_DEF_ID,
       TEMPLATE_NAME,
       TEMPLATE_TYPE,
       TEMPLATE_DESC,
       PARENT_CONTAINER_TYPE,
       JRAD_DOC,
       BUTTON_BAR_TEMPLATE_ID,
       MESSAGE_TYPE,
       MAIN_MESSAGE_ID,
       TITLE_ID,
       SEEDED_FLAG,
       LAYOUT_UI_STYLE,
       ROOT_REGION_TYPE,
       ROOT_ELEMENT_SIGNATURE_ID,
       BUTTON_BAR_TEMPL_UIDEF_ID,
       TEMPLATE_USAGE,
       AMN_USAGE,
       DELETED_FLAG)
       SELECT
        template_id,
        g_UI_Context.ui_def_id,
        TEMPLATE_NAME,
        TEMPLATE_TYPE,
        TEMPLATE_DESC,
        PARENT_CONTAINER_TYPE,
        l_jrad_doc,
        BUTTON_BAR_TEMPLATE_ID,
        MESSAGE_TYPE,
        MAIN_MESSAGE_ID,
        TITLE_ID,
        G_NO_FLAG,
        LAYOUT_UI_STYLE,
        ROOT_REGION_TYPE,
        ROOT_ELEMENT_SIGNATURE_ID,
        BUTTON_BAR_TEMPL_UIDEF_ID,
        TEMPLATE_USAGE,
        AMN_USAGE,
        G_NO_FLAG
       FROM CZ_UI_TEMPLATES
       WHERE template_id=p_template_id AND ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID;

      g_template_jrad_name_tbl(p_template_id) := l_jrad_doc;

    EXCEPTION
      WHEN OTHERS THEN
        DEBUG('save_Template_As_Local() : '||SQLERRM);
    END;

  END save_Template_As_Local;

  --
  -- check : should new Content type record be added ?
  --
  FUNCTION must_Add_Content_Type_Record(p_content_type   IN NUMBER,
                                        p_it_is_in_model IN BOOLEAN) RETURN BOOLEAN IS

  BEGIN

    IF  p_content_type IN(CZ_TYPES.UMANDATORY_COMPONENT_TYPEID,
                            CZ_TYPES.UOPTIONAL_COMPONENT_TYPEID,
                            CZ_TYPES.UMINMAX_COMPONENT_TYPEID,
                            CZ_TYPES.UNON_COUNT_FEATURE_TYPEID,
                            CZ_TYPES.UCOUNT_FEATURE_TYPEID,
                            CZ_TYPES.UCOUNT_FEATURE01_TYPEID,
                            CZ_TYPES.UMINMAX_FEATURE_TYPEID,
                            CZ_TYPES.UINTEGER_FEATURE_TYPEID,
                            CZ_TYPES.UDECIMAL_FEATURE_TYPEID,
                            CZ_TYPES.UBOOLEAN_FEATURE_TYPEID,
                            CZ_TYPES.UTEXT_FEATURE_TYPEID,
                            CZ_TYPES.UTOTAL_TYPEID,
                            CZ_TYPES.URESOURCE_TYPEID,
                            CZ_TYPES.UMANDATORY_REF_TYPEID,
                            CZ_TYPES.UCONNECTOR_TYPEID) THEN

          IF g_UI_Context.CTRLTEMPLUSE_NONBOM = G_TEMPLATE_USE_LOCAL_COPY
             AND p_it_is_in_model THEN

              RETURN TRUE;

          ELSE

             RETURN FALSE;

          END IF;


      ELSIF p_content_type IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID
                                ,CZ_TYPES.UMINMAX_BOM_REF_TYPEID
                                ,CZ_TYPES.UBOM_NSTBOM_NQMTX_TYPEID
                                ,CZ_TYPES.UBOM_NSTBOM_NQNMTX_TYPEID
                                ,CZ_TYPES.UBOM_NSTBOM_QNMTX_TYPEID
                                ,CZ_TYPES.UBOM_NSTBOM_QMTX_TYPEID
                                ,CZ_TYPES.UBOM_STIO_NQMTX_TYPEID
                                ,CZ_TYPES.UBOM_STIO_NQNMTX_TYPEID
                                ,CZ_TYPES.UBOM_STIO_QNMTX_TYPEID
                                ,CZ_TYPES.UBOM_STIO_QMTX_TYPEID) THEN

          IF g_UI_Context.CTRLTEMPLUSE_BOM = G_TEMPLATE_USE_LOCAL_COPY
              AND p_it_is_in_model THEN

           RETURN TRUE;

          ELSE

           RETURN  FALSE;

          END IF;

      ELSIF (g_UI_Context.CTRLTEMPLUSE_REQDMSG = G_TEMPLATE_USE_LOCAL_COPY AND
              p_content_type IN(G_MSGTEMP_RQDMSG_OVRCTRDIC
                                ,G_MSGTEMP_RQDMSG_NOVRCTRDIC
                                ,G_MSGTEMP_RQDMSG_INVLDINP
                                ,G_MSGTEMP_RQDMSG_FATERR)) OR
             (g_UI_Context.CTRLTEMPLUSE_OPTMSG = G_TEMPLATE_USE_LOCAL_COPY AND
              p_content_type IN(G_MSGTEMP_OPTMSG_VLDNOTIF
                                ,G_MSGTEMP_OPTMSG_CNFRMSAVFIN
                                ,G_MSGTEMP_OPTMSG_CNFRMCANCEL
                                ,G_MSGTEMP_OPTMSG_CNFRMDELINST
                                ,G_MSGTEMP_OPTMSG_CNFRMLDINST
                                ,G_MSGTEMP_OPTMSG_CNFRMEDINST
                                ,G_MSGTEMP_OPTMSG_QRYDELINST)) OR
             (g_UI_Context.CTRLTEMPLUSE_COMMON = G_TEMPLATE_USE_LOCAL_COPY AND
              p_content_type IN(G_UTILTEMP_BB_NSTXN
                                ,G_UTILTEMP_BB_BASICTXN
                                ,G_UTILTEMP_BB_2PGNVG
                                ,G_UTILTEMP_BB_NPGNVG))  OR
             (g_UI_Context.CTRLTEMPLATEUSE_UTILITYPAGE = G_TEMPLATE_USE_LOCAL_COPY AND
              p_content_type IN(G_UTILTEMP_PAGLAY_PGSTA
                                ,G_UTILTEMP_BB_PRVWPG
                                ,G_UTILTEMP_UPT_CFGPRV
                                ,G_UTILTEMP_UPT_CXNCHO))  THEN

        RETURN  TRUE;

      END IF;

    RETURN FALSE;

  END  must_Add_Content_Type_Record;

  --
  -- create local UI templates
  --
  PROCEDURE create_Local_UI_Templates IS

    l_handled_templates_tbl  number_tbl_type;
    l_detailed_type_id_tbl   number_tbl_type;
    l_template_rec           CZ_UI_TEMPLATES%ROWTYPE;
    l_jrad_doc               VARCHAR2(4000);
    l_template_ui_def_id     NUMBER := G_GLOBAL_TEMPLATES_UI_DEF_ID;
    l_create_cont_entry      BOOLEAN := FALSE;

  BEGIN

    IF g_UI_Context.CTRLTEMPLUSE_BOM = G_TEMPLATE_USE_LOCAL_COPY OR
       g_UI_Context.CTRLTEMPLUSE_NONBOM = G_TEMPLATE_USE_LOCAL_COPY OR
       g_UI_Context.CTRLTEMPLUSE_OPTMSG = G_TEMPLATE_USE_LOCAL_COPY OR
       g_UI_Context.CTRLTEMPLUSE_COMMON = G_TEMPLATE_USE_LOCAL_COPY OR
       g_UI_Context.CTRLTEMPLUSE_REQDMSG = G_TEMPLATE_USE_LOCAL_COPY THEN

       --
       -- open XML parser
       --
       Open_Parser;
    END IF;

    --
    -- refresh UI Images in UI based on data from Master Template
    --

    refresh_UI_Images(p_ui_def_id          => g_UI_Context.ui_def_id,
                      p_master_template_id => g_UI_Context.from_master_template_id);

    IF g_UI_Context.CTRLTEMPLUSE_BOM = G_TEMPLATE_USE_LOCAL_COPY OR
       g_UI_Context.CTRLTEMPLUSE_NONBOM = G_TEMPLATE_USE_LOCAL_COPY THEN

      FOR m IN(SELECT DISTINCT detailed_type_id
               FROM CZ_UITEMPLS_FOR_PSNODES_V
               WHERE devl_project_id=g_UI_Context.devl_project_id AND
                     ui_def_id=g_UI_Context.from_master_template_id AND
                     deleted_flag=G_NO_FLAG AND ui_omit=G_NO_FLAG)
      LOOP
        l_detailed_type_id_tbl(m.detailed_type_id) := m.detailed_type_id;
      END LOOP;

    END IF;

    FOR k IN(SELECT * FROM CZ_UI_CONT_TYPE_TEMPLS
             WHERE ui_def_id = g_UI_Context.from_master_template_id AND
                   deleted_flag = G_NO_FLAG)
    LOOP

      IF k.content_type = G_PAGE_STATUS_CONTENT_TYPE THEN
         g_PAGE_STATUS_TEMPLATE_ID := k.template_id;
      END IF;

      l_create_cont_entry := must_Add_Content_Type_Record(k.content_type,
                                                          l_detailed_type_id_tbl.EXISTS(k.content_type));

      IF l_create_cont_entry THEN

        save_Template_As_Local(p_template_id => k.template_id,
                               p_ui_def_id   => g_UI_Context.ui_def_id);

        refresh_Cont_Templs(p_content_type       => k.content_type,
                            p_master_template_id => g_UI_Context.from_master_template_id,
                            p_ui_def_id          => g_UI_Context.ui_def_id,
                            p_create_cont_entry  => TRUE);

       ELSE
         IF NOT(l_detailed_type_id_tbl.EXISTS(k.content_type)) THEN
            refresh_Cont_Templs(p_content_type       => k.content_type,
                                p_master_template_id => g_UI_Context.from_master_template_id,
                                p_ui_def_id          => g_UI_Context.ui_def_id,
                                p_create_cont_entry  => FALSE);
         END IF;

       END IF;

    END LOOP;

    SELECT template_id INTO g_DRILLDOWN_TEMPLATE_ID
      FROM CZ_UI_CONT_TYPE_TEMPLS
     WHERE ui_def_id=g_UI_Context.from_master_template_id AND
           content_type=2151 AND deleted_flag=G_NO_FLAG;

    -- close XML parser
    Close_Parser;

    -- reopen XML parser
    Open_Parser;

  END create_Local_UI_Templates;

  --
  -- return page_ref node of nearest page
  --
  FUNCTION get_UI_Page_Ref_Node(p_ui_node  IN CZ_UI_PAGE_ELEMENTS%ROWTYPE)
    RETURN CZ_UI_PAGE_REFS%ROWTYPE IS

    l_page_ref_node     CZ_UI_PAGE_REFS%ROWTYPE;

  BEGIN

    IF p_ui_node.page_id IS NULL THEN
      RETURN l_page_ref_node;
    END IF;

    SELECT *
      INTO l_page_ref_node
      FROM CZ_UI_PAGE_REFS a
     WHERE ui_def_id = p_ui_node.ui_def_id AND
           (target_page_id,page_set_id) IN
           (SELECT page_id,NVL(page_set_id,a.page_set_id) FROM CZ_UI_PAGES
            WHERE page_id=p_ui_node.page_id AND ui_def_id=p_ui_node.ui_def_id AND
            deleted_flag NOT IN(G_YES_FLAG)) AND
           deleted_flag = G_NO_FLAG;

    RETURN l_page_ref_node;

  END get_UI_Page_Ref_Node;

  --
  -- the function returns a Model Path
  -- for a given persistent_node_id
  --
  FUNCTION  get_Page_Path(p_ps_node_id  IN NUMBER,
                          p_page_set_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS

    l_model_path              VARCHAR2(32000);
    l_persistent_node_id      NUMBER;
    l_parent_id               NUMBER;
    l_ps_node                 CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_page_set_node           CZ_UI_PAGE_SETS%ROWTYPE;
    l_seq_nbr                 NUMBER;
    l_node_depth              NUMBER;

  BEGIN

    IF p_page_set_id IS NOT NULL THEN

      l_page_set_node := get_Page_Set(p_page_set_id);

      IF l_page_set_node.persistent_node_id IS NOT NULL THEN
        l_persistent_node_id := l_page_set_node.persistent_node_id;
      ELSE
        BEGIN
         SELECT MIN(node_depth) INTO l_node_depth FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id=g_UI_Context.ui_def_id AND page_set_id=p_page_set_id
                AND deleted_flag=G_NO_FLAG;

         SELECT MIN(SEQ_NBR) INTO l_seq_nbr FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id=g_UI_Context.ui_def_id AND page_set_id=p_page_set_id
                AND node_depth=l_node_depth AND deleted_flag=G_NO_FLAG;

         SELECT DISTINCT target_persistent_node_id INTO l_persistent_node_id
         FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id=g_UI_Context.ui_def_id AND page_set_id=p_page_set_id
               AND seq_nbr=l_seq_nbr AND
               target_persistent_node_id NOT IN
              (SELECT  ref_persistent_node_id FROM CZ_UI_REFS WHERE
                ui_def_id=g_UI_Context.ui_def_id AND deleted_flag=G_NO_FLAG) AND
               rownum<2;
        EXCEPTION
          WHEN OTHERS THEN
            RETURN '.';
        END;
      END IF;

     l_ps_node := get_Model_Node_By_Persist_Id(l_persistent_node_id, g_UI_Context.devl_project_id);

    END IF;

    SELECT parent_id INTO l_parent_id FROM CZ_PS_NODES
    WHERE ps_node_id=p_ps_node_id;

    IF l_parent_id IS NULL THEN
       RETURN '.';
    END IF;

    IF p_page_set_id IS NULL THEN
      FOR i IN(SELECT persistent_node_id, parent_id FROM CZ_PS_NODES
               START WITH ps_node_id=p_ps_node_id AND deleted_flag=G_NO_FLAG
               CONNECT BY PRIOR parent_id=ps_node_id AND
               PRIOR deleted_flag=G_NO_FLAG AND deleted_flag=G_NO_FLAG)
      LOOP
        IF l_model_path IS NULL THEN
          l_model_path:=TO_CHAR(i.persistent_node_id);
        ELSIF i.parent_id IS NOT NULL THEN
          l_model_path:=TO_CHAR(i.persistent_node_id)||'.'||l_model_path;
        ELSE
          NULL;
        END IF;
      END LOOP;

      RETURN  l_model_path;

    ELSE

      FOR i IN(SELECT ps_node_id,persistent_node_id, parent_id FROM CZ_PS_NODES
               START WITH ps_node_id=p_ps_node_id AND deleted_flag=G_NO_FLAG
               CONNECT BY PRIOR parent_id=ps_node_id AND
               PRIOR deleted_flag=G_NO_FLAG AND deleted_flag=G_NO_FLAG)
      LOOP
        IF i.ps_node_id = l_ps_node.ps_node_id THEN
          EXIT;
        END IF;
        IF l_model_path IS NULL THEN
          l_model_path:=TO_CHAR(i.persistent_node_id);
        ELSIF i.parent_id IS NOT NULL THEN
          l_model_path:=TO_CHAR(i.persistent_node_id)||'.'||l_model_path;
        ELSE
          NULL;
        END IF;
      END LOOP;

      IF l_model_path IS NULL THEN
        l_model_path := '.';
      END IF;

      RETURN  l_model_path;


    END IF;
  END get_Page_Path;

  --
  -- the function retrurns a Model Path
  -- for a given persistent_node_id
  --
  FUNCTION get_Model_Path(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE)
    RETURN VARCHAR2 IS

    l_page_path VARCHAR2(32000) := '';
    l_parent_ui_node CZ_UI_PAGE_ELEMENTS%ROWTYPE;

    PROCEDURE construct_Path(p_current_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS
      l_ui_node CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    BEGIN

      IF p_current_ui_node.pagebase_persistent_node_id <>
         p_current_ui_node.persistent_node_id THEN

        l_ui_node := get_UI_Element(p_element_id => p_current_ui_node.parent_element_id,
                                    p_page_id    => p_current_ui_node.page_id);

        IF l_ui_node.pagebase_persistent_node_id = l_ui_node.persistent_node_id OR
           l_ui_node.parent_element_id IS NULL THEN
          RETURN;
        ELSE
          IF l_ui_node.persistent_node_id IS NOT NULL AND
             p_current_ui_node.persistent_node_id <> l_ui_node.persistent_node_id THEN

            l_page_path := TO_CHAR(l_ui_node.persistent_node_id) || '.' ||
                           l_page_path;
          END IF;
          construct_Path(l_ui_node);
        END IF;
      ELSE
        RETURN;
      END IF;
    END construct_Path;

  BEGIN

    IF p_ui_node.persistent_node_id=0 THEN
      RETURN '*';
    END IF;

    IF p_ui_node.parent_element_id IS NULL  THEN
      RETURN '.';
    ELSE

      BEGIN
        l_parent_ui_node := get_UI_Element(p_ui_node.parent_element_id, p_ui_node.page_id);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN '.';
      END;

      IF l_parent_ui_node.parent_element_id IS NULL AND
         l_parent_ui_node.persistent_node_id=p_ui_node.persistent_node_id THEN
        RETURN '.';
      END IF;

      l_page_path := TO_CHAR(p_ui_node.persistent_node_id);

      construct_Path(p_ui_node);
    END IF;
    RETURN l_page_path;
  END get_Model_Path;

  --
  -- return COUNT ( of UI page sets of a given UI) + 1
  --
  FUNCTION get_Page_Set_Counter RETURN NUMBER IS
    l_page_counter NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO l_page_counter
      FROM CZ_UI_PAGE_SETS
     WHERE ui_def_id = g_UI_Context.ui_def_id AND
           deleted_flag=G_NO_FLAG;
    RETURN l_page_counter;
  END get_Page_Set_Counter;

  --
  -- return COUNT ( of UI pages of a given UI) + 1
  --
  FUNCTION get_Last_Seq_Nbr(p_parent_element_id IN VARCHAR2) RETURN NUMBER IS
    l_seq_nbr        NUMBER;
    l_num_element_id NUMBER;
    l_parent_seq_nbr NUMBER;
  BEGIN
    SELECT NVL(MAX(seq_nbr),0)
      INTO l_seq_nbr
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           parent_element_id=p_parent_element_id AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);
    RETURN l_seq_nbr;
  END get_Last_Seq_Nbr;

  --
  -- return COUNT ( of UI pages of a given UI) + 1
  --
  FUNCTION get_Last_Split_Page_Nbr(p_page_id IN NUMBER) RETURN NUMBER IS
    l_split_seq_nbr        NUMBER;
  BEGIN
    SELECT NVL(MAX(split_seq_nbr),0)
      INTO l_split_seq_nbr
      FROM CZ_UI_PAGES
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           persistent_node_id IN
          (SELECT persistent_node_id FROM CZ_UI_PAGES
            WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id=p_page_id);
    RETURN l_split_seq_nbr;
  END get_Last_Split_Page_Nbr;

  --
  -- return COUNT ( of UI pages of a given UI) + 1
  --
  FUNCTION get_Num_Elements_On_Page(p_page_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE)
    RETURN NUMBER IS
    l_counter   NUMBER;
  BEGIN
    SELECT COUNT(element_id)
      INTO l_counter
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id=p_page_node.ui_def_id AND
           page_id=p_page_node.page_id AND ctrl_template_id IS NOT NULL AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);
    RETURN l_counter;
  END get_Num_Elements_On_Page;

  --
  -- create new Page Set
  --
  PROCEDURE create_Page_Set
  (
  p_ui_def_id          IN NUMBER,
  p_page_set_type      IN NUMBER,
  p_persistent_node_id IN NUMBER,
  p_model_ref_expl_id  IN NUMBER,
  x_page_set_id        OUT NOCOPY NUMBER
  ) IS

    l_ui_page_set_node        CZ_UI_PAGE_SETS%ROWTYPE;
    l_page_set_name           CZ_UI_PAGE_SETS.name%TYPE;
    l_root_persistent_node_id NUMBER;
    l_page_set_counter        NUMBER;

  BEGIN

    IF p_page_set_type IN(G_SINGLE_LEVEL_MENU,G_MULTI_LEVEL_MENU,
                          G_MODEL_TREE_MENU,G_PAGE_FLOW,G_SUBTABS) THEN

      SELECT COUNT(page_set_id)+1 INTO l_page_set_counter FROM CZ_UI_PAGE_SETS
      WHERE ui_def_id=p_ui_def_id AND page_set_type=p_page_set_type AND
            deleted_flag=G_NO_FLAG;
      IF p_page_set_type IN(G_PAGE_FLOW) THEN
        l_page_set_name := 'Page Flow - '|| TO_CHAR(l_page_set_counter);
      ELSIF p_page_set_type IN(G_SUBTABS) THEN
        l_page_set_name := 'Subtabs - '|| TO_CHAR(l_page_set_counter);
      ELSE
        l_page_set_name := 'Menu - '|| TO_CHAR(l_page_set_counter);
      END IF;
    ELSE
      l_page_set_counter := get_Page_Set_Counter() + 1;
      l_page_set_name := 'Page Set - ' || TO_CHAR(l_page_set_counter);
    END IF;

    x_page_set_id := allocateId('CZ_UI_PAGE_SETS_S');

    INSERT INTO CZ_UI_PAGE_SETS
        (ui_def_id,
         page_set_id,
         page_set_type,
         NAME,
         suppress_refresh_flag,
         train_jrad_doc,
         persistent_node_id,
         pagebase_expl_node_id,
         deleted_flag)
    VALUES
        (p_ui_def_id,
         x_page_set_id,
         p_page_set_type,
         l_page_set_name,
         g_suppress_refresh_flag,
         NULL,
         p_persistent_node_id,
         p_model_ref_expl_id,
         G_NO_FLAG);

    l_ui_page_set_node.ui_def_id     := p_ui_def_id;
    l_ui_page_set_node.page_set_id   := x_page_set_id;
    l_ui_page_set_node.page_set_type := p_page_set_type;
    l_ui_page_set_node.name          := l_page_set_name;
    l_ui_page_set_node.suppress_refresh_flag := g_suppress_refresh_flag;
    l_ui_page_set_node.train_jrad_doc:= NULL;
    l_ui_page_set_node.persistent_node_id    := p_persistent_node_id;
    l_ui_page_set_node.pagebase_expl_node_id := p_model_ref_expl_id;
    l_ui_page_set_node.deleted_flag  := G_NO_FLAG;

    g_ui_page_sets_tbl(x_page_set_id) := l_ui_page_set_node;

  END create_Page_Set;

  --
  -- check : is it UI Page
  --
  FUNCTION is_UI_Page(p_node      IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                      x_drilldown OUT NOCOPY BOOLEAN) RETURN BOOLEAN IS

    l_root_persistent_node_id   NUMBER;
  BEGIN

    l_root_persistent_node_id := get_Root_Persistent_Node_Id();

    x_drilldown := FALSE;

    ------- Single Page --------


    -- If the navigation style is Single_Page, and pagination style is "Subsections"
    -- or "Single Page", then create new page for all non virtual P/C/M/OC.
    -- All other UI nodes will not have their own page

    IF g_UI_Context.PRIMARY_NAVIGATION=G_SINGLE_PAGE AND
       (
       (g_UI_Context.PAGIN_NONINST IN(G_SUBSECTIONS_PG_TYPE,G_SINGLE_PG_TYPE) AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC IN(G_SUBSECTIONS_PG_TYPE,G_SINGLE_PG_TYPE) AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       )
        THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG THEN
        RETURN TRUE;
      END IF;

      RETURN FALSE;
    END IF;


    -- If the navigation style is "Single Page" and pagination type is "New Pages"
    -- then create new Pages for all P/C/M/OC but the immediate children of the root.
    -- The immediate children of the root will be created on the page for the root
    -- as subsections

    IF g_UI_Context.PRIMARY_NAVIGATION=G_SINGLE_PAGE AND
       (
       (g_UI_Context.PAGIN_NONINST = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG THEN
        RETURN TRUE;
      END IF;

      -- If this is child of the root, add it to the root page

      IF p_node.parent_persistent_node_id=l_root_persistent_node_id THEN
        RETURN FALSE;
      ELSE
        x_drilldown := TRUE;
        RETURN TRUE;
      END IF;

      RETURN FALSE;
    END IF;

    -- If the navigation style is "Single Page" and pagination is "Drilldown Pages",
    -- then create new page for all non virtual nodes and virtual nodes which are not
    -- immediate child of the root. Immediate children of the root will have their
    -- UI Nodes on the page for the root

    IF g_UI_Context.PRIMARY_NAVIGATION=G_SINGLE_PAGE AND
       (
       (g_UI_Context.PAGIN_NONINST = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG THEN
        RETURN TRUE;
      END IF;

      IF p_node.parent_persistent_node_id=l_root_persistent_node_id THEN
        RETURN FALSE;
      ELSE
        x_drilldown := TRUE;
        RETURN TRUE;
      END IF;

      RETURN FALSE;

    END IF;

    ----- Page Flow -------

    -- If the primary navigation is "Page Flow" and pagination is "Single Page",
    -- then create new page for root, non virtual nodes and direct children (P/C/M/OC)
    -- of the root. All under nodes will be created as subsections

    IF g_UI_Context.PRIMARY_NAVIGATION=G_PAGE_FLOW AND
       (
       (g_UI_Context.PAGIN_NONINST IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG OR
         p_node.parent_persistent_node_id=l_root_persistent_node_id THEN
        RETURN TRUE;
      END IF;

      RETURN FALSE;
    END IF;

    -- If the primary navigation is "Page Flow" and pagination is "New Pages", then
    -- create create new pages for all P/C/M/OC

    IF g_UI_Context.PRIMARY_NAVIGATION=G_PAGE_FLOW AND
       (
       (g_UI_Context.PAGIN_NONINST = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG THEN
        RETURN TRUE;
      END IF;

      RETURN TRUE;
    END IF;

    -- If the primary navigation is "Page Flow" and pagination is "Drilldown Pages", then
    -- create create new pages for all (P/C/M/OC)
    -- Further, drilldowns will be created for virtual P/C/M/OC that are not direct children
    -- of the root

    IF g_UI_Context.PRIMARY_NAVIGATION=G_PAGE_FLOW AND
       (
       (g_UI_Context.PAGIN_NONINST = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG OR
         p_node.parent_persistent_node_id=l_root_persistent_node_id THEN
        RETURN TRUE;
      END IF;

      IF p_node.parent_persistent_node_id<>l_root_persistent_node_id THEN
        x_drilldown := TRUE;
      END IF;

      RETURN TRUE;
    END IF;

    ----- Menu -----

    -- If the navigation style is Side Nav or Tree and pagination type is "Single Page" or
    -- "Subsections" then create new pages for root and its direct children.
    -- For all other P/C/M/OC, if the node is non virtual then create a new Page with a
    -- Drilldown to it. For all other nodes no new page

    IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_LEVEL_MENU,G_MULTI_LEVEL_MENU,G_MODEL_TREE_MENU) AND
       (
       (g_UI_Context.PAGIN_NONINST IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR
        p_node.parent_persistent_node_id=l_root_persistent_node_id  THEN
        RETURN TRUE;
      END IF;

      IF p_node.virtual_flag = G_NO_FLAG THEN
        x_drilldown := TRUE;
        RETURN TRUE;
      END IF;

      RETURN FALSE;
    END IF;

    -- If the navigation style is "Side Menu" or "Tree", and pagination style is "New Pages"
    -- then create new pages for all P/C/M/OC

    IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_LEVEL_MENU,G_MULTI_LEVEL_MENU,G_MODEL_TREE_MENU) AND
       (
       (g_UI_Context.PAGIN_NONINST = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG THEN
        RETURN TRUE;
      END IF;

      RETURN TRUE;
    END IF;

    -- If the navigation style is "Side Menu" or "Tree", and pagination is "Drilldown Pages", then
    -- create new new pages for all P/C/M/OC. Further all page for all nodes that are not
    -- direct children of the root, will have a Drilldown

    IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_LEVEL_MENU,G_MULTI_LEVEL_MENU,G_MODEL_TREE_MENU) AND
       (
       (g_UI_Context.PAGIN_NONINST = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR
        p_node.parent_persistent_node_id=l_root_persistent_node_id THEN
        RETURN TRUE;
      END IF;

      IF p_node.virtual_flag = G_NO_FLAG THEN
        x_drilldown := TRUE;
        RETURN TRUE;
      END IF;

      x_drilldown := TRUE;
      RETURN TRUE;
    END IF;

    ---- Subtabs -------

    -- If the navigation style is "Subtabs" and pagination is "Single Page" or
    -- "Subsections," then create new pages for the root, non virtual nodes and
    -- direct P/C/M/OC children of the root.

    IF g_UI_Context.PRIMARY_NAVIGATION = G_SUBTABS AND
       (
       (g_UI_Context.PAGIN_NONINST IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG OR
         p_node.parent_persistent_node_id = l_root_persistent_node_id THEN
        RETURN TRUE;
      END IF;

      RETURN FALSE;
    END IF;

    -- If navigation style is "Subtabs" and pagination is "New Pages," then create
    -- new pages for all P/C/M/OC

    IF g_UI_Context.PRIMARY_NAVIGATION = G_SUBTABS AND
       (
       (g_UI_Context.PAGIN_NONINST = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_NEW_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG THEN
        RETURN TRUE;
      END IF;

      RETURN TRUE;

    END IF;

    -- If the navigation style is "Subtabs" and pagination is "Drilldown Pages,"
    -- then create new pages for all P/C/M/OC. Node not directly under the root will
    -- also have a drilldown

    IF g_UI_Context.PRIMARY_NAVIGATION = G_SUBTABS AND
       (
       (g_UI_Context.PAGIN_NONINST = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE))
       OR
       (g_UI_Context.PAGIN_BOMOC = G_DRILLDOWN_PAGES_PG_TYPE AND
       p_node.ps_node_type IN (G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE))
       ) THEN

      IF p_node.parent_id IS NULL OR p_node.virtual_flag = G_NO_FLAG OR
        p_node.parent_persistent_node_id=l_root_persistent_node_id THEN
        RETURN TRUE;
      END IF;

      IF p_node.parent_persistent_node_id<>l_root_persistent_node_id THEN
        x_drilldown := TRUE;
      END IF;

      RETURN TRUE;
    END IF;

    -- If none of the above satisfy, then create new pages for all P/C/M/OC

    IF p_node.ps_node_type IN (G_PRODUCT_TYPE, G_COMPONENT_TYPE,
                              G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_UI_Page;

  --
  -- check - is it UI Reference or no
  --
  FUNCTION is_UI_Reference(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE)
    RETURN BOOLEAN IS
    l_ui_ref_exists VARCHAR2(1);
  BEGIN
    SELECT 'x' INTO l_ui_ref_exists
      FROM  CZ_UI_REFS
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           ref_persistent_node_id=p_ui_node.persistent_node_id AND
           deleted_flag=G_NO_FLAG AND rownum<2;
     RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END is_UI_Reference;

  --
  -- remove Instance Management Controls from CZ_UI_PAGE_ELEMENTS
  --
  PROCEDURE remove_Instance_Controls(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS

    l_changed_pages_tbl number_tbl_type;
    l_suppress_refresh_flag CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;
    l_mark_flag             CZ_UI_PAGE_ELEMENTS.deleted_flag%TYPE;

  BEGIN

     FOR i IN(SELECT page_id,element_id,parent_element_id,suppress_refresh_flag
                FROM CZ_UI_PAGE_ELEMENTS
               WHERE ui_def_id=p_ui_node.ui_def_id AND
                     persistent_node_id=p_ui_node.persistent_node_id AND
                     element_type IN(G_UI_NONBOMADDINST_NODE_TYPE,G_UI_BOMADDINST_NODE_TYPE) AND
                     deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE, G_LIMBO_FLAG))
    LOOP
      IF i.suppress_refresh_flag=G_YES_FLAG THEN
          UPDATE CZ_UI_PAGE_ELEMENTS
             SET deleted_flag=G_MARK_TO_DEASSOCIATE,
                 persistent_node_id=0
           WHERE ui_def_id=p_ui_node.ui_def_id AND
                page_id=i.page_id AND
                element_id=i.element_id;
      ELSE
        SELECT suppress_refresh_flag INTO l_suppress_refresh_flag FROM CZ_UI_PAGE_ELEMENTS
        WHERE ui_def_id=p_ui_node.ui_def_id AND page_id=i.page_id AND
              element_id=i.parent_element_id;
        IF l_suppress_refresh_flag=G_YES_FLAG THEN
          UPDATE CZ_UI_PAGE_ELEMENTS
             SET deleted_flag=G_MARK_TO_DEASSOCIATE,
                 persistent_node_id=0
           WHERE ui_def_id=p_ui_node.ui_def_id AND
                page_id=i.page_id AND
                element_id=i.element_id;
        ELSE
          UPDATE CZ_UI_PAGE_ELEMENTS
             SET deleted_flag=G_MARK_TO_DELETE
           WHERE ui_def_id=p_ui_node.ui_def_id AND
                 page_id=i.page_id AND
                 element_id=i.element_id;
        END IF;
      END IF;

      mark_UI_Page_As_Refreshed(i.page_id, p_ui_node.ui_def_id);

    END LOOP;

  END remove_Instance_Controls;

  --
  -- merge two Page Flows - parent and child Page Flows into one Page Flow
  -- p_ui_node is a first node of child Page Flow
  --
  PROCEDURE merge_Page_Flows(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS
    TYPE number_tbl_type       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_changed_target_ids_tbl   number_tbl_type;
    l_ui_page_ref_node         CZ_UI_PAGE_REFS%ROWTYPE;
    l_target_path              CZ_UI_PAGE_REFS.target_path%TYPE;
    l_model_node               CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_child_page_set_id        NUMBER;
    l_child_page_ref_id        NUMBER;
    l_parent_page_set_id       NUMBER;
    l_parent_page_ref_id       NUMBER;
    l_page_ref_type            NUMBER;

  BEGIN
    --
    -- get Page set id of UI node p_ui_node
    --
    BEGIN
      l_ui_page_ref_node := get_UI_Page_Ref_Node(p_ui_node);
      l_child_page_set_id := l_ui_page_ref_node.page_set_id;
      l_child_page_ref_id := l_ui_page_ref_node.page_ref_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN;
    END;

    --
    -- get Page set id and page_ref_id of parent Page Flow
    --
    SELECT MIN(page_ref_id)
      INTO l_parent_page_ref_id
      FROM CZ_UI_PAGE_REFS
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           target_persistent_node_id=p_ui_node.parent_persistent_node_id AND
           deleted_flag=G_NO_FLAG;

    SELECT page_set_id,page_ref_type
      INTO l_parent_page_set_id,l_page_ref_type FROM CZ_UI_PAGE_REFS
    WHERE ui_def_id=p_ui_node.ui_def_id AND page_ref_id=l_parent_page_ref_id;

    --
    -- attach child Page Flow to the parent Page Flow
    --
    UPDATE CZ_UI_PAGE_REFS
       SET parent_page_ref_id = l_parent_page_ref_id
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           page_ref_id=l_child_page_ref_id;

    UPDATE CZ_UI_PAGE_REFS
       SET page_set_id = l_parent_page_set_id
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           target_page_id IN
           (SELECT target_page_id FROM CZ_UI_PAGE_REFS
            START WITH ui_def_id=p_ui_node.ui_def_id AND
                       page_ref_id=l_child_page_ref_id
            CONNECT BY PRIOR page_ref_id=parent_page_ref_id AND
                    ui_def_id=p_ui_node.ui_def_id AND
                    page_set_id=l_child_page_set_id AND
                    PRIOR page_set_id=l_child_page_set_id AND
                    PRIOR ui_def_id=p_ui_node.ui_def_id AND
                    deleted_flag=G_NO_FLAG AND PRIOR deleted_flag=G_NO_FLAG)
     RETURNING target_persistent_node_id BULK COLLECT INTO l_changed_target_ids_tbl;

     IF l_changed_target_ids_tbl.COUNT>0 THEN
       FOR x IN l_changed_target_ids_tbl.First..l_changed_target_ids_tbl.Last
       LOOP
         UPDATE CZ_UI_PAGES
            SET page_set_id=l_parent_page_set_id
          WHERE persistent_node_id=l_changed_target_ids_tbl(x) AND
                ui_def_id=p_ui_node.ui_def_id;

     --    IF  l_page_ref_type IN(G_PAGE_FLOW,G_SUBTABS)  THEN
           l_model_node := get_Model_Node_By_Persist_Id(l_changed_target_ids_tbl(x), g_UI_Context.devl_project_id);
           l_target_path := get_Page_Path(l_model_node.ps_node_id, l_parent_page_set_id);
           UPDATE CZ_UI_PAGE_REFS
              SET target_path=l_target_path
            WHERE ui_def_id=p_ui_node.ui_def_id AND
                  page_set_id=l_parent_page_set_id AND
                  target_persistent_node_id=l_changed_target_ids_tbl(x) AND
                  target_path<>l_target_path;
      --   END IF;

       END LOOP;
     END IF;

  END merge_Page_Flows;

  --
  -- split one Page Flow into two Page Flows - parent and child
  --
  PROCEDURE split_Page_Flow(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS
    TYPE number_tbl_type       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_changed_target_ids_tbl   number_tbl_type;
    l_target_page_ids_tbl      number_tbl_type;
    l_ui_page_ref_node         CZ_UI_PAGE_REFS%ROWTYPE;
    l_target_path              CZ_UI_PAGE_REFS.target_path%TYPE;
    l_model_node               CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_page_set_type            NUMBER;
    l_initial_page_set_id      NUMBER;
    l_initial_page_ref_id      NUMBER;
    l_page_set_id              NUMBER;

  BEGIN

    --
    -- get Page set id of UI node p_ui_node
    --
    BEGIN
     l_ui_page_ref_node := get_UI_Page_Ref_Node(p_ui_node);
     l_initial_page_set_id := l_ui_page_ref_node.page_set_id;
     l_initial_page_ref_id := l_ui_page_ref_node.page_ref_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN;
    END;

    /*
    IF l_ui_page_ref_node.page_ref_type=G_SUBTABS THEN
      l_page_set_type := G_SUBTABS;
    ELSE
      l_page_set_type := G_PAGE_FLOW;
    END IF;
    */

    IF l_page_set_type IS NULL THEN
      l_page_set_type := g_UI_Context.PRIMARY_NAVIGATION;
    END IF;

    create_Page_Set(p_ui_def_id          => p_ui_node.ui_def_id,
                    p_page_set_type      => l_page_set_type,
                    p_persistent_node_id => p_ui_node.persistent_node_id,
                    p_model_ref_expl_id  => p_ui_node.model_ref_expl_id,
                    x_page_set_id        => l_page_set_id);

    UPDATE CZ_UI_PAGE_REFS
       SET target_path='.',
           parent_page_ref_id=NULL,
           node_depth=1,
           seq_nbr=1
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           page_ref_id=l_initial_page_ref_id;

    UPDATE CZ_UI_PAGE_REFS
       SET page_set_id = l_page_set_id
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           target_persistent_node_id IN
                (SELECT target_persistent_node_id FROM CZ_UI_PAGE_REFS
                 START WITH ui_def_id=p_ui_node.ui_def_id AND
                            page_ref_id=l_initial_page_ref_id
                 CONNECT BY PRIOR page_ref_id=parent_page_ref_id AND
                    ui_def_id=p_ui_node.ui_def_id AND
                    page_set_id=l_initial_page_set_id AND
                    PRIOR page_set_id=l_initial_page_set_id AND
                    PRIOR ui_def_id=p_ui_node.ui_def_id AND
                    deleted_flag=G_NO_FLAG AND PRIOR deleted_flag=G_NO_FLAG)
     RETURNING target_page_id,target_persistent_node_id
     BULK COLLECT INTO l_target_page_ids_tbl,l_changed_target_ids_tbl;

     IF l_changed_target_ids_tbl.COUNT>0 THEN
       FOR j in l_changed_target_ids_tbl.First..l_changed_target_ids_tbl.Last
       LOOP
         UPDATE CZ_UI_PAGES
            SET page_set_id=l_page_set_id
          WHERE page_id=l_target_page_ids_tbl(j) AND
                ui_def_id=p_ui_node.ui_def_id;

           l_model_node := get_Model_Node_By_Persist_Id(l_changed_target_ids_tbl(j), g_UI_Context.devl_project_id);
           l_target_path := get_Page_Path(l_model_node.ps_node_id, l_page_set_id);

           UPDATE CZ_UI_PAGE_REFS
              SET target_path=l_target_path
            WHERE ui_def_id=p_ui_node.ui_def_id AND
                  page_set_id=l_page_set_id AND
                  target_persistent_node_id=l_changed_target_ids_tbl(j) AND
                  target_path<>l_target_path;

       END LOOP;
     END IF;

  END split_Page_Flow;

  --
  -- check - is CX valid or no ?
  --
  FUNCTION get_CX_Button_Status(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE)
    RETURN VARCHAR2 IS

    l_model_node         CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_ui_cx_command_name CZ_EXPRESSION_NODES.data_value%TYPE;
    l_undeleted_exist    BOOLEAN;

  BEGIN

    l_model_node := get_Model_Node_By_Persist_Id(p_ui_node.persistent_node_id, g_UI_Context.devl_project_id);

    BEGIN
      SELECT cx_command_name
        INTO l_ui_cx_command_name
        FROM CZ_UI_ACTIONS
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             element_id=p_ui_node.element_id AND
             cx_command_name IS NOT NULL  AND-- fix for bug 3923033
             deleted_flag=G_NO_FLAG;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN G_CX_VALID;
    END;

    l_undeleted_exist := FALSE;
    FOR i IN(SELECT a.deleted_flag, a.invalid_flag, a.disabled_flag ,
                     a.INSTANTIATION_SCOPE, b.data_value, a.name
             FROM CZ_RULES a, CZ_EXPRESSION_NODES b
             WHERE a.devl_project_id=l_model_node.devl_project_id AND
                   a.component_id=l_model_node.ps_node_id AND
                   a.rule_type=G_CZ_EXTENTSIONS_RULE_TYPE AND
                   a.deleted_flag=G_NO_FLAG AND
                   b.rule_id=a.rule_id AND
                   b.deleted_flag=G_NO_FLAG AND
                   b.argument_signature_id=G_EVENT_ON_COMMAND_SIGID AND
                   data_value=l_ui_cx_command_name)
    LOOP

      IF i.deleted_flag=G_NO_FLAG THEN
         l_undeleted_exist := TRUE;
      END IF;

      IF i.invalid_flag=G_NO_FLAG AND i.disabled_flag=G_NO_FLAG AND
         i.deleted_flag=G_NO_FLAG THEN
        RETURN G_CX_VALID;
      END IF;
    END LOOP;

    IF l_model_node.ps_node_type=G_REFERENCE_TYPE THEN

      FOR i IN(SELECT a.name, a.deleted_flag, a.invalid_flag, a.disabled_flag,
                      a.INSTANTIATION_SCOPE, b.data_value
             FROM CZ_RULES a, CZ_EXPRESSION_NODES b
             WHERE a.devl_project_id=l_model_node.devl_project_id AND
                   a.component_id IN
               (SELECT ps_node_id FROM CZ_PS_NODES
                WHERE devl_project_id IN
                (SELECT DISTINCT component_id FROM CZ_MODEL_REF_EXPLS
                START WITH model_id=l_model_node.devl_project_id AND
                           referring_node_id=l_model_node.ps_node_id
                CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND
                         deleted_flag='0' AND PRIOR deleted_flag='0') AND
                deleted_flag='0') AND
                   a.rule_type=G_CZ_EXTENTSIONS_RULE_TYPE AND
                   b.rule_id=a.rule_id AND
                   b.deleted_flag=G_NO_FLAG AND
                   b.argument_signature_id=G_EVENT_ON_COMMAND_SIGID AND
                   data_value IS NOT NULL)
      LOOP

        IF l_model_node.instantiable_flag NOT IN(G_MANDATORY_INST_TYPE) AND
           i.INSTANTIATION_SCOPE=1 AND i.disabled_flag=G_NO_FLAG THEN

          add_Error_Message(p_message_name => 'CZ_CX_IS_IN_WRONG_SCOPE',
                            p_token_name1  => 'EVENT_NAME',
                            p_token_value1 => i.data_value,
                            p_token_name2  => 'RULE_NAME',
                            p_token_value2 => i.name,
                            p_fatal_error  => FALSE);


          RETURN G_CX_INVALID;
        END IF;

        IF i.deleted_flag=G_NO_FLAG THEN
           l_undeleted_exist := TRUE;
        END IF;

        IF i.invalid_flag=G_NO_FLAG AND i.disabled_flag=G_NO_FLAG AND
           i.deleted_flag=G_NO_FLAG THEN
          RETURN G_CX_VALID;
        END IF;
      END LOOP;

    END IF;

    IF l_undeleted_exist=FALSE THEN
      RETURN G_CX_MUST_BE_DELETED;
    ELSE
      RETURN G_CX_INVALID;
    END IF;
  END get_CX_Button_Status;

  --
  -- refresh expl ids in UI tables
  --
  PROCEDURE sync_Expl_Ids(p_node    IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                          p_expl_id IN NUMBER) IS

  BEGIN


    IF p_expl_id <> p_ui_node.model_ref_expl_id THEN
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET model_ref_expl_id=p_expl_id
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             page_id=p_ui_node.page_id AND
             element_id=p_ui_node.element_id;

      IF p_ui_node.parent_element_id IS NULL THEN
        UPDATE CZ_UI_PAGES
           SET pagebase_expl_node_id=p_expl_id
         WHERE page_id=p_ui_node.page_id AND
               ui_def_id=p_ui_node.ui_def_id;
         IF SQL%ROWCOUNT>0 THEN
           UPDATE CZ_UI_PAGE_SETS
              SET pagebase_expl_node_id=p_expl_id
            WHERE ui_def_id=g_UI_Context.ui_def_id
                  AND persistent_node_id=p_ui_node.persistent_node_id
                  AND deleted_flag=G_NO_FLAG;
         END IF;
      END IF;

      UPDATE CZ_UI_PAGE_REFS
         SET target_expl_node_id=p_expl_id
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             target_persistent_node_id=p_node.persistent_node_id;

    END IF;
  END sync_Expl_Ids;

  --
  -- refresh expl ids in UI tables
  --
  PROCEDURE sync_Expl_Ids(p_node    IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS
    l_model_ref_expl_id NUMBER;
  BEGIN
    l_model_ref_expl_id := get_Expl_Id(p_model_id     => p_node.devl_project_id,
                                       p_ps_node_id   => p_node.ps_node_id,
                                       p_component_id => p_node.component_id,
                                       p_ps_node_type => p_node.ps_node_type);
    sync_Expl_Ids(p_node, p_ui_node, l_model_ref_expl_id);
  END;



  --
  -- replace Template Id of UI node p_ui_node
  --
  PROCEDURE replace_Template_Id(p_ui_node          IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                p_model_node       IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

    l_element_signature_id NUMBER;
    l_counter              NUMBER;

  BEGIN

    SELECT COUNT(*)+1 INTO l_counter FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id=p_ui_node.ui_def_id AND
           page_id=p_ui_node.page_id AND
           element_signature_id=p_model_node.root_element_signature_id AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE, G_LIMBO_FLAG);

    UPDATE CZ_UI_PAGE_ELEMENTS
       SET ctrl_template_id=p_model_node.template_id,
           element_signature_id=p_model_node.root_element_signature_id,
           deleted_flag=DECODE(deleted_flag,G_MARK_TO_ADD,G_MARK_TO_ADD,G_MARK_TO_REFRESH),
           name=p_model_node.template_name||' - '||l_counter
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           page_id=p_ui_node.page_id AND
           element_id=p_ui_node.element_id;

    mark_UI_Page_As_Refreshed(p_ui_node.page_id, p_ui_node.ui_def_id);

  END replace_Template_Id;

  --
  -- remove common attributes in case when we attach template
  -- starting with DOM node p_node
  --   Parameters : p_node - identifies DOM node of subtree's root
  --
  PROCEDURE remove_TopLevel_Attributes(p_node xmldom.DOMNode) IS
    l_root_elem xmldom.DOMElement;
  BEGIN
    l_root_elem := xmldom.makeElement(p_node);
    FOR i IN g_toplevel_attr_tbl.FIRST .. g_toplevel_attr_tbl.LAST
    LOOP
      BEGIN
        xmldom.removeAttribute(l_root_elem, g_toplevel_attr_tbl(i));
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  END remove_TopLevel_Attributes;

  --
  -- remove non user attributes from a given XML node
  --
  PROCEDURE remove_Non_User_Attributes(p_node xmldom.DOMNode) IS

    l_root_elem    xmldom.DOMElement;
    l_node_map_tbl xmldom.DOMNamedNodeMap;
    l_node_attr    xmldom.DOMNode;
    l_attr_name    VARCHAR2(32000);
    l_length       NUMBER;

  BEGIN

    l_root_elem := xmldom.makeElement(p_node);

    l_node_map_tbl := xmldom.getAttributes(p_node);
    IF (xmldom.isNull(l_node_map_tbl) = FALSE) THEN
      l_length := xmldom.getLength(l_node_map_tbl);
      --
      -- loop through attributes
      --
      FOR i IN 0 .. l_length - 1
      LOOP
        l_node_attr := xmldom.item(l_node_map_tbl, i);

        IF NOT(xmldom.isNull(l_node_attr)) THEN
          l_attr_name := xmldom.getNodeName(l_node_attr);
          IF (lower(l_attr_name) not like ('user:attribute%') AND
             lower(l_attr_name) <> G_ID_ATTRIBUTE) OR
             lower(l_attr_name)=G_USER_ATTRIBUTE10_NAME  THEN
             xmldom.removeAttribute(l_root_elem, l_attr_name);
          END IF;
        END IF;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      DEBUG('remove_Non_User_Attributes() : '||SQLERRM);
  END remove_Non_User_Attributes;

  --
  -- clear the cache
  --
  PROCEDURE flash_Cache IS
  BEGIN
    g_model_nodes_tbl.DELETE;
    g_ui_page_elements_tbl.DELETE;
    g_ps_node_persist_id_tbl.DELETE;
    g_ui_pages_tbl.DELETE;
    g_ui_page_refs_tbl.DELETE;
    g_ui_refs_tbl.DELETE;
    g_ui_page_sets_tbl.DELETE;
    g_ref_expls_tbl.DELETE;
    g_ui_action_ids_tbl.DELETE;
  END flash_Cache;

  --
  -- cache Mode nodes and UI data
  --
  PROCEDURE populate_Cache IS

  BEGIN

    flash_Cache;

    FOR i IN (SELECT DISTINCT *
                FROM CZ_UITEMPLS_FOR_PSNODES_V
                WHERE ui_def_id=g_UI_Context.from_master_template_id AND
                      devl_project_id = g_UI_Context.devl_project_id)
    LOOP
      g_model_nodes_tbl(i.ps_node_id) := i;
      g_ps_node_persist_id_tbl(i.persistent_node_id) := i.ps_node_id;
    END LOOP;

    FOR i IN(SELECT model_ref_expl_id,referring_node_id,component_id
               FROM CZ_MODEL_REF_EXPLS
              WHERE model_id=g_UI_Context.devl_project_id AND
                    deleted_flag=G_NO_FLAG)
    LOOP
      IF i.referring_node_id IS NOT NULL THEN
        g_ref_expls_tbl(i.referring_node_id) := i.model_ref_expl_id;
      ELSE
        g_ref_expls_tbl(i.component_id) := i.model_ref_expl_id;
      END IF;
    END LOOP;

    FOR i IN (SELECT *
                FROM CZ_UI_PAGES
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     deleted_flag = G_NO_FLAG)
    LOOP
      g_ui_pages_tbl(i.page_id) := i;

      IF NOT(g_ui_pages_counter_tbl.EXISTS(g_UI_Context.ui_def_id)) THEN
        g_ui_pages_counter_tbl(g_UI_Context.ui_def_id) := 1;
      ELSE
        g_ui_pages_counter_tbl(g_UI_Context.ui_def_id) := g_ui_pages_counter_tbl(g_UI_Context.ui_def_id) + 1;
      END IF;
    END LOOP;

    FOR i IN (SELECT *
                FROM CZ_UI_PAGE_ELEMENTS
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     deleted_flag = G_NO_FLAG)
    LOOP
      BEGIN
        g_ui_page_elements_tbl(TO_NUMBER(i.element_id)) := i;
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- if element_id is not a number it will not be cached
          --
          NULL;
      END;
    END LOOP;

    FOR i IN (SELECT *
                FROM CZ_UI_PAGE_REFS
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     deleted_flag = G_NO_FLAG)
    LOOP
      g_ui_page_refs_tbl(i.page_ref_id) := i;
    END LOOP;

    FOR i IN (SELECT *
                FROM CZ_UI_PAGE_SETS
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     deleted_flag = G_NO_FLAG)
    LOOP
      g_ui_page_sets_tbl(i.page_set_id) := i;
    END LOOP;

    FOR i IN (SELECT ref_persistent_node_id
                FROM CZ_UI_REFS
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     deleted_flag = G_NO_FLAG)
    LOOP
      g_ui_refs_tbl(i.ref_persistent_node_id) := i.ref_persistent_node_id;
    END LOOP;

    FOR i IN (SELECT element_id, ui_action_id
                FROM CZ_UI_ACTIONS
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     deleted_flag = G_NO_FLAG)
    LOOP
      BEGIN
        g_ui_action_ids_tbl(TO_NUMBER(i.element_id)) := i.ui_action_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;

  END populate_Cache;

  ---------------------------------------------------------------------
  -------------------------XML Parsing Part ---------------------------
  ---------------------------------------------------------------------

  --
  -- returns value of a given attribute
  -- Parameters :
  --   p_node  - DOM node
  --   p_attr_name - attribute name
  -- Return : attribute value as VARCHAR2 string
  --
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

  FUNCTION attribute_Value(p_node      IN xmldom.DOMNode,
                                p_attr_name IN VARCHAR2) RETURN VARCHAR2 IS

    l_node_map_tbl xmldom.DOMNamedNodeMap;
    l_node_attr    xmldom.DOMNode;
    l_attr_value   VARCHAR2(32000);
    l_length       NUMBER;

  BEGIN
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
          IF l_attr_value IS NULL THEN
            RETURN NULL;
          ELSE
            RETURN l_attr_value;
          END IF;
        END IF;
      END LOOP;
    END IF;
    RETURN '*';
  END attribute_Value;

  --
  -- return value of specified user atribute
  --
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

  --
  -- find DOM node by persistent_node_id
  --
  FUNCTION find_XML_Node_By_Attribute(p_subtree_doc        xmldom.DOMDocument,
                                      p_attribute_name     IN VARCHAR2,
                                      p_attribute_value    IN VARCHAR2,
                                      p_in_user_attributes IN VARCHAR2 DEFAULT NULL)
    RETURN xmldom.DOMNode IS

    l_node            xmldom.DOMNode;
    l_nodeslist       xmldom.DOMNodeList;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;
    l_attribute_value VARCHAR2(32000);

  BEGIN

    IF p_attribute_name=G_ID_ATTRIBUTE AND g_page_elements_tbl.EXISTS(p_attribute_value) THEN
      RETURN g_page_elements_tbl(p_attribute_value);
    END IF;

    --
    -- here we don't need to know about hierachy of nodes
    -- so we just need to get list of all nodes of XML subtree
    --
    l_nodeslist := xmldom.getElementsByTagName(p_subtree_doc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    l_node := xmldom.makeNode(xmldom.getDocumentElement(p_subtree_doc));

    l_attribute_value := get_Attribute_Value(l_node, p_attribute_name);

    IF p_in_user_attributes=G_YES_FLAG THEN
      l_attribute_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE4_NAME);
      l_attribute_value :=  get_User_Attribute(l_attribute_value, p_attribute_name);
    ELSE
      l_attribute_value := get_Attribute_Value(l_node, p_attribute_name);
    END IF;

    IF l_attribute_value = p_attribute_value THEN
      RETURN l_node;
    END IF;

    --
    -- scan subtree and substitute macros "%" to real values
    --
    FOR i IN 0 .. l_length - 1
    LOOP
      l_node            := xmldom.item(l_nodeslist, i);

      IF p_in_user_attributes=G_YES_FLAG THEN
        l_attribute_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE4_NAME);
        l_attribute_value :=  get_User_Attribute(l_attribute_value, p_attribute_name);
      ELSE
        l_attribute_value := get_Attribute_Value(l_node, p_attribute_name);
      END IF;

      IF l_attribute_value = p_attribute_value THEN
        RETURN l_node;
      END IF;
    END LOOP;
    RETURN l_empty_xml_node;

  END find_XML_Node_By_Attribute;

  --
  -- return DOM node of top level tag <ui:contents>
  -- if node does not contain p_tag node then return the node itself ( p_node )
  -- Parameters :
  --  p_node - DOM node
  -- Return : top level DOM node with XML tag = p_tag
  --
  FUNCTION getUIContents(p_node xmldom.DOMNode,
                         p_return_empty_node VARCHAR2 DEFAULT NULL) RETURN xmldom.DOMNode IS
    l_child_nodes_tbl xmldom.DOMNodeList;
    l_child_xml_node  xmldom.DOMNode;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;
  BEGIN
    l_child_nodes_tbl := xmldom.getChildNodes(p_node);
    l_length          := xmldom.getLength(l_child_nodes_tbl);
    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      IF UPPER(xmldom.getNodeName(l_child_xml_node)) =
         UPPER(G_UI_CONTENTS_TAG) THEN
        RETURN l_child_xml_node;
      END IF;
    END LOOP;

    IF p_return_empty_node IS NULL OR p_return_empty_node=G_NO_FLAG THEN
      RETURN p_node;
    ELSE
      RETURN l_empty_xml_node;
    END IF;
  END getUIContents;

  FUNCTION findChildXMLTag(p_node    xmldom.DOMNode,
                           p_xml_tag VARCHAR2) RETURN xmldom.DOMNode IS
    l_child_nodes_tbl xmldom.DOMNodeList;
    l_child_xml_node  xmldom.DOMNode;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;
  BEGIN
    l_child_nodes_tbl := xmldom.getChildNodes(p_node);
    l_length          := xmldom.getLength(l_child_nodes_tbl);
    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      IF UPPER(xmldom.getNodeName(l_child_xml_node)) =
         UPPER(p_xml_tag) THEN
        RETURN l_child_xml_node;
      END IF;
    END LOOP;

    RETURN l_empty_xml_node;

  END findChildXMLTag;

  --
  -- return DOM node of top level tag <ui:contents>
  -- if node does not contain p_tag node then return the node itself ( p_node )
  -- Parameters :
  --  p_node - DOM node
  -- Return : top level DOM node with XML tag = p_tag
  --
  FUNCTION get_Col_UIContents(p_node       xmldom.DOMNode,
                              p_col_number NUMBER) RETURN xmldom.DOMNode IS
    l_child_nodes_tbl    xmldom.DOMNodeList;
    l_child_xml_node     xmldom.DOMNode;
    l_first_ui_contents  xmldom.DOMNode;
    l_second_ui_contents xmldom.DOMNode;
    l_rowlayout          xmldom.DOMNode;
    l_length             NUMBER;
    l_counter            NUMBER;
    l_id_attribute       VARCHAR2(255);
  BEGIN

    l_first_ui_contents := getUIContents(p_node);

    l_child_nodes_tbl := xmldom.getChildNodes(l_first_ui_contents);
    l_length          := xmldom.getLength(l_child_nodes_tbl);
    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      IF UPPER(xmldom.getNodeName(l_child_xml_node)) =
         UPPER('oa:rowLayout') THEN

    l_id_attribute := get_Attribute_Value(l_child_xml_node,
                                            G_ID_ATTRIBUTE);

        EXIT;
      END IF;
    END LOOP;

    l_second_ui_contents := getUIContents(l_child_xml_node);

    l_counter:= 0;

    l_child_nodes_tbl := xmldom.getChildNodes(l_second_ui_contents);
    l_length          := xmldom.getLength(l_child_nodes_tbl);
    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      IF UPPER(xmldom.getNodeName(l_child_xml_node)) =
         UPPER('oa:cellFormat') THEN
        l_counter := l_counter + 1;
        IF l_counter=p_col_number THEN

    l_id_attribute := get_Attribute_Value(l_child_xml_node,
                                            G_ID_ATTRIBUTE);

          RETURN getUIContents(l_child_xml_node);
        END IF;

      END IF;
    END LOOP;

    RETURN p_node;

  END get_Col_UIContents;

  --
  -- find DOM node by persistent_node_id
  --
  FUNCTION find_Table_Of_XML_Node(p_parent_xml_node xmldom.DOMNode,
                                  p_element_id      IN VARCHAR2)
    RETURN xmldom.DOMNode IS

    l_child_xml_node        xmldom.DOMNode;
    l_table_child_xml_node  xmldom.DOMNode;
    l_empty_xml_node        xmldom.DOMNode;
    l_uicont_xml_node       xmldom.DOMNode;
    l_ui_contents_xml_node  xmldom.DOMNode;
    l_child_nodes_tbl       xmldom.DOMNodeList;
    l_table_child_nodes_tbl xmldom.DOMNodeList;
    l_length                NUMBER;
    l_table_child_length    NUMBER;

  BEGIN

    IF xmldom.getNodeName(p_parent_xml_node) IN('oa:header','oa:stackLayout',
                                                'oa:flowLayout','oa:tableLayout') THEN

      l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
    ELSE
      l_ui_contents_xml_node := p_parent_xml_node;
    END IF;

    --
    -- get child nodes of DOM node : p_node
    --
    l_child_nodes_tbl := xmldom.getChildNodes(l_ui_contents_xml_node);

    --
    -- we need to get length of array of child nodes
    -- to go through the array in loop
    --
    l_length := xmldom.getLength(l_child_nodes_tbl);

    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      IF (get_Attribute_Value(l_child_xml_node, G_USER_ATTRIBUTE5_NAME) = 'TABLELAYOUT_FOR_UI_GEN') THEN

        BEGIN
          l_uicont_xml_node := getUIContents(l_child_xml_node);

          l_table_child_nodes_tbl := xmldom.getChildNodes(l_uicont_xml_node);
          l_table_child_length := xmldom.getLength(l_table_child_nodes_tbl);

          FOR m IN 0 .. l_table_child_length - 1
          LOOP
             l_table_child_xml_node := xmldom.item(l_table_child_nodes_tbl, m);

             IF get_Attribute_Value(l_table_child_xml_node, G_ID_ATTRIBUTE) = p_element_id THEN
                RETURN l_uicont_xml_node;
             END IF;
          END LOOP;
        END;
      END IF;
    END LOOP;
    RETURN l_empty_xml_node;
  EXCEPTION
    WHEN OTHERS THEN
      DEBUG('find_Table_Of_XML_Node() : '||SQLERRM);
      RETURN l_empty_xml_node;
  END find_Table_Of_XML_Node;

  --
  -- find a given xml tag up on the tree
  --
  FUNCTION find_Element_Id_Of_XMLTag(p_xml_node xmldom.DOMNode,
                                     p_tag_name VARCHAR2 ) RETURN VARCHAR2 IS
    l_node       xmldom.DOMNode;
    l_hgrid_node xmldom.DOMNode;
    PROCEDURE find_hgrid(p_node xmldom.DOMNode) IS
    BEGIN
      IF xmldom.isNull(p_node) THEN
        RETURN;
      END IF;
      l_node := xmldom.getParentNode(p_node);
      IF lower(xmldom.getNodeName(l_node))=lower(p_tag_name) THEN
        l_hgrid_node := l_node;
      ELSE
        find_hgrid(l_node);
      END IF;
    END find_hgrid;
  BEGIN
    find_hgrid(p_xml_node);
    RETURN get_Attribute_Value(l_hgrid_node,
                               G_ID_ATTRIBUTE);
  EXCEPTION
    WHEN OTHERS THEN
      DEBUG('find_Element_Id_Of_XMLTag() : '||SQLERRM);
      RETURN NULL;
  END find_Element_Id_Of_XMLTag;


  FUNCTION find_AMN_Element_Above(p_xml_node xmldom.DOMNode) RETURN VARCHAR2 IS

    l_element_id CZ_UI_PAGE_ELEMENTS.element_id%TYPE;

    PROCEDURE AMN_Element_Above(p_node xmldom.DOMNode) IS

      l_node             xmldom.DOMNode;
      l_next_node        xmldom.DOMNode;
      l_user_attribute1  VARCHAR2(32000);

    BEGIN

      l_node := xmldom.getParentNode(p_node);

      IF xmldom.isNull(l_node) THEN
        l_element_id := get_Attribute_Value(p_node, G_ID_ATTRIBUTE);
        RETURN;
      END IF;

      l_user_attribute1 := get_Attribute_Value(l_node, G_USER_ATTRIBUTE1_NAME);

      IF NOT(l_user_attribute1='model_path=%modelPath' OR l_user_attribute1 IS NULL) THEN

         l_element_id := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);
         RETURN;

      ELSE

         l_next_node := xmldom.getParentNode(l_node);

         IF xmldom.isNull(l_next_node) THEN
           l_element_id := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);
           RETURN;
         ELSE
           AMN_Element_Above(l_node);
         END IF;

      END IF;

    END AMN_Element_Above;

  BEGIN

    AMN_Element_Above(p_xml_node);

    RETURN l_element_id;

  END find_AMN_Element_Above;


  --
  -- parse or export/parse JRAD document
  -- Parameters :
  --   p_doc_full_name - full JRAD name of the document
  --
  FUNCTION parse_JRAD_Document(p_doc_full_name IN VARCHAR2)
    RETURN xmldom.DOMDocument IS

    l_buffer         VARCHAR2(32000);
    l_lob_loc        CLOB;
    l_amount         BINARY_INTEGER;
    l_position       INTEGER := 1;
    l_xmldoc         xmldom.DOMDocument;
    l_exportfinished BOOLEAN;

  BEGIN

    DBMS_LOB.CREATETEMPORARY(l_lob_loc, TRUE);
    DBMS_LOB.OPEN(l_lob_loc, DBMS_LOB.LOB_READWRITE);

    l_buffer := jdr_utils.ExportDocument(p_document       => p_doc_full_name,
                                         p_exportfinished => l_exportfinished);

    IF l_buffer IS NULL THEN
      RETURN l_xmldoc;
    END IF;

    l_amount := LENGTH(l_buffer);

    DBMS_LOB.WRITE(l_lob_loc, l_amount, l_position, l_buffer);
    l_position := l_position + l_amount;

    IF l_exportfinished=FALSE THEN
    LOOP
      l_buffer := jdr_utils.ExportDocument(p_document       => NULL,
                                           p_exportfinished => l_exportfinished);

      IF l_buffer IS NULL THEN
        EXIT;
      END IF;

      l_amount := LENGTH(l_buffer);

      DBMS_LOB.WRITE(l_lob_loc, l_amount, l_position, l_buffer);
      l_position := l_position + l_amount;

      IF l_buffer IS NULL OR l_exportfinished THEN
        EXIT;
      END IF;
    END LOOP;

    END IF;

    xmlparser.parseCLOB(g_PARSER, l_lob_loc);

    l_xmldoc := xmlparser.getDocument(g_PARSER);

    DBMS_LOB.CLOSE(l_lob_loc);
    DBMS_LOB.FREETEMPORARY(l_lob_loc);

    RETURN l_xmldoc;

  EXCEPTION
    WHEN OTHERS THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => p_doc_full_name,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
  END parse_JRAD_Document;

  --
  -- set CZ Attributes for a given DOM node
  -- Parameters : p_dom_element     - DOM Element which identifies DOM node
  --              p_attribute_name  - attribute name
  --              p_attribute_value - attribute value
  --
  PROCEDURE set_Attribute(p_dom_element     xmldom.DOMElement,
                          p_attribute_name  IN VARCHAR2,
                          p_attribute_value IN VARCHAR2) IS

  BEGIN
    xmldom.setAttribute(p_dom_element, p_attribute_name, p_attribute_value);
  END set_Attribute;

  --
  -- set CZ Attributes for a given DOM node
  -- Parameters : p_dom_element     - DOM Element which identifies DOM node
  --              p_attribute_name  - attribute name
  --              p_attribute_value - attribute value
  --
  PROCEDURE set_Attribute(p_dom_node        xmldom.DOMNode,
                          p_attribute_name  IN VARCHAR2,
                          p_attribute_value IN VARCHAR2) IS

  BEGIN
    xmldom.setAttribute(xmldom.makeElement(p_dom_node), p_attribute_name, p_attribute_value);
  END set_Attribute;

  --
  -- set internal CZ attributes within "user:attribute1"
  --
  PROCEDURE set_User_Attribute(p_cz_attribute_name    IN VARCHAR2,
                               p_cz_attribute_value   IN VARCHAR2,
                               p_add_if_not_present   IN BOOLEAN DEFAULT FALSE,
                               px_xml_attribute_value IN OUT NOCOPY VARCHAR2) IS

    l_str            VARCHAR2(4000);
    l_sub_str        VARCHAR2(4000);
    l_next_equal_ind NUMBER;
    l_next_ind       NUMBER;
    l_ind            NUMBER;

  BEGIN

    --
    -- get string of CZ user attributes
    --
    l_str := px_xml_attribute_value;
    l_ind := INSTR(l_str, p_cz_attribute_name);

    IF l_ind > 0 THEN

      l_sub_str  := SUBSTR(l_str, l_ind);
      l_next_ind := INSTR(l_sub_str, '|');

      l_next_equal_ind := INSTR(l_sub_str, '=');

      IF l_next_equal_ind > 1 THEN

        IF l_next_ind > 0 THEN
          px_xml_attribute_value := SUBSTR(l_str, 1,  l_ind + l_next_equal_ind - 1) ||
                                    p_cz_attribute_value || SUBSTR(l_sub_str, l_next_ind);
        ELSE
          px_xml_attribute_value := SUBSTR(l_str, 1,l_ind + l_next_equal_ind - 1) || p_cz_attribute_value;
        END IF;

      END IF;
    ELSE
      NULL;
    END IF;

  END set_User_Attribute;
  --vsingava IM-ER
  PROCEDURE set_user_attribute(p_xml_node xmldom.DOMNode,
                               p_jrad_attribute_name VARCHAR2,
                               p_cz_attribute_name VARCHAR2,
                               p_attribute_value VARCHAR2) IS
    l_user_attribute VARCHAR2(2000);
    l_xml_node xmldom.DOMNode;
  BEGIN

    l_user_attribute := get_Attribute_Value(p_xml_node,
                                            p_jrad_attribute_name);

		set_User_Attribute(p_cz_attribute_name    => p_cz_attribute_name,
                       p_cz_attribute_value   => p_attribute_value,
                       p_add_if_not_present   => TRUE,
                       px_xml_attribute_value => l_user_attribute);

    set_Attribute(p_xml_node,p_jrad_attribute_name, l_user_attribute);

  END set_user_attribute;

  -- Removes the indicated CZ attribute from the indicated Jrad User attribute and set the
  -- remainder back on to the node
  FUNCTION remove_user_attribute(p_xml_node xmldom.DOMNode,
                                 p_jrad_attribute_name VARCHAR2,
                                 p_cz_attribute_name VARCHAR2) RETURN VARCHAR2 IS
    l_user_attribute VARCHAR2(2000);
    l_cz_attr_val VARCHAR2(2000);
    l_substr VARCHAR2(2000);
    l_length NUMBER;
    l_ind1 NUMBER;
    l_ind2 NUMBER;
  BEGIN


    l_user_attribute := get_Attribute_Value(p_xml_node,
                                            p_jrad_attribute_name);

    l_ind1 := INSTR(l_user_attribute, p_cz_attribute_name);

    IF l_ind1 > 0 THEN
      l_length := LENGTH(p_cz_attribute_name)+LENGTH('=');
      l_substr := SUBSTR(l_user_attribute,l_ind1+l_length);
      l_ind2 := INSTR(l_substr, '|');
      IF l_ind2 > 0 THEN
        l_cz_attr_val := SUBSTR(l_substr,1,l_ind2-1);
        l_user_attribute := SUBSTR(l_user_attribute, 1, l_ind1-1) || SUBSTR(l_user_attribute, l_ind1 + l_length + l_ind2);
      ELSE
        l_cz_attr_val := l_substr;
        l_user_attribute := SUBSTR(l_user_attribute, 1, l_ind1-1);
      END IF;
    ELSE
      l_substr := NULL;
    END IF;

    IF l_substr IS NOT NULL THEN
      set_Attribute(p_xml_node,p_jrad_attribute_name, l_user_attribute);
    END IF;

    RETURN l_substr;

  END remove_user_attribute;

  --
  -- this procedure adds CZ_UI_PAGE_ELEMENTS records
  -- which correspond to first level UI template references
  --
  PROCEDURE add_Extends_Refs(p_xml_node        xmldom.DOMNode,
                             p_ui_node         IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS

    l_seq_nbr                      NUMBER;
    l_template_id                  NUMBER;
    l_template_name                CZ_UI_TEMPLATES.template_name%TYPE;
    l_id_attribute_value           CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_element_id                   CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_extend_attr_value            VARCHAR2(4000);

  BEGIN

    l_extend_attr_value  := get_Attribute_Value(p_xml_node, 'extends');

    IF l_extend_attr_value IS NULL THEN
      RETURN;
    END IF;

    l_id_attribute_value := get_Attribute_Value(p_xml_node, G_ID_ATTRIBUTE);

    IF l_id_attribute_value IS NULL THEN
      RETURN;
    END IF;

    SELECT template_id,template_name INTO l_template_id,l_template_name FROM CZ_UI_TEMPLATES
     WHERE ui_def_id=NVL(p_ui_node.ctrl_template_ui_def_id,G_GLOBAL_TEMPLATES_UI_DEF_ID) AND
           jrad_doc=l_extend_attr_value AND deleted_flag=G_NO_FLAG;

    SELECT NVL(max(seq_nbr),0)+1 INTO l_seq_nbr FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id=p_ui_node.ui_def_id AND
           page_id=p_ui_node.page_id AND
           parent_element_id=p_ui_node.element_id AND
           deleted_flag NOT IN(G_LIMBO_FLAG,G_MARK_TO_DELETE,G_YES_FLAG);

    l_element_id := get_element_Id();

    INSERT INTO CZ_UI_PAGE_ELEMENTS
      (
      UI_DEF_ID
      ,PAGE_ID
      ,PERSISTENT_NODE_ID
      ,ELEMENT_ID
      ,PARENT_PERSISTENT_NODE_ID
      ,REGION_PERSISTENT_NODE_ID
      ,PAGEBASE_PERSISTENT_NODE_ID
      ,CTRL_TEMPLATE_ID
      ,BASE_PAGE_FLAG
      ,INSTANTIABLE_FLAG
      ,SEQ_NBR
      ,DELETED_FLAG
      ,CTRL_TEMPLATE_UI_DEF_ID
      ,MODEL_REF_EXPL_ID
      ,SUPPRESS_REFRESH_FLAG
      ,PARENT_ELEMENT_ID
      ,ELEMENT_TYPE
      ,NAME
      ,ELEMENT_SIGNATURE_ID
      ,TARGET_PAGE_UI_DEF_ID
      ,TARGET_PAGE_ID
      )
    VALUES
      (
      p_ui_node.ui_def_id
      ,p_ui_node.page_id
      ,NULL
      ,l_element_id
      ,p_ui_node.parent_persistent_node_id
      ,p_ui_node.region_persistent_node_id
      ,p_ui_node.pagebase_persistent_node_id
      ,l_template_id
      ,'0'
      ,'0'
      ,l_seq_nbr
      ,G_NO_FLAG
      ,p_ui_node.ctrl_template_ui_def_id
      ,NULL
      ,'0'
      ,p_ui_node.element_id
      ,NULL
      ,l_template_name
      ,6011
      ,NULL
      ,NULL
      );

     set_Attribute(p_xml_node, G_ID_ATTRIBUTE, l_element_id);

  END add_Extends_Refs;

  FUNCTION find_Parent_UI_Element
   (p_xml_node   xmldom.DOMNode,
    p_ui_def_id  IN NUMBER,
    p_ui_page_id IN NUMBER) RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE IS

       l_ui_element CZ_UI_PAGE_ELEMENTS%ROWTYPE;

       PROCEDURE get_Parent_XML(p_check_xml_node xmldom.DOMNode) IS

         l_parent_xml_node xmldom.DOMNode;
         l_id_attr_value   VARCHAR2(32000);

       BEGIN

         l_id_attr_value := get_Attribute_Value(p_check_xml_node, G_ID_ATTRIBUTE);

         IF l_id_attr_value IS NOT NULL THEN

           BEGIN
             SELECT * INTO l_ui_element FROM CZ_UI_PAGE_ELEMENTS
              WHERE ui_def_id=p_ui_def_id AND page_id=p_ui_page_id AND
                    element_id=l_id_attr_value;
             RETURN;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               NULL;
           END;

         END IF;

         l_parent_xml_node := xmldom.getParentNode(p_check_xml_node);


         IF NOT(xmldom.isNull(l_parent_xml_node)) THEN

           l_id_attr_value := get_Attribute_Value(l_parent_xml_node , G_ID_ATTRIBUTE);


           IF l_id_attr_value IS NOT NULL THEN

           BEGIN
             SELECT * INTO l_ui_element FROM CZ_UI_PAGE_ELEMENTS
              WHERE ui_def_id=p_ui_def_id AND page_id=p_ui_page_id AND
                    element_id=l_id_attr_value;
             RETURN;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               get_Parent_XML(l_parent_xml_node);
           END;

          ELSE
               get_Parent_XML(l_parent_xml_node);
           END IF;

         ELSE
           RETURN;
         END IF;

       END get_Parent_XML;


  BEGIN

    get_Parent_XML(p_xml_node);

    RETURN l_ui_element;

  END find_Parent_UI_Element;

  --
  -- replace prefixes which are used by runtime caching
  --
  FUNCTION replace_Prefix(p_str IN VARCHAR2, p_inline_copy_mode IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_inline_copy_mode=G_INLINE_COPY_TMPL THEN
      RETURN REPLACE(p_str,'_czt','_czc');
    ELSIF p_inline_copy_mode=G_INLINE_COPY_UIPAGE THEN
      RETURN REPLACE(REPLACE(p_str,'_czt','_czn'), '_czc','_czn');
    ELSE
      RETURN p_str;
    END IF;
  END replace_Prefix;

  --
  -- handle special cases ( like "switcher case", "ancestor node" )
  --
  PROCEDURE handle_Special_XMLCases
  (p_xml_node         xmldom.DOMNode,
   p_old_xml_node_id  VARCHAR2,
   p_new_xml_node_id  VARCHAR2,
   p_jrad_doc         VARCHAR2,
   px_xml_switcher_id IN OUT NOCOPY VARCHAR2,
   p_inline_copy_mode IN VARCHAR2) IS

    l_curr_parent_xml_node  xmldom.DOMNode;
    l_ancestor_node_id      VARCHAR2(255);
    l_xml_node_name         VARCHAR2(255);
    l_parent_xml_node_name  VARCHAR2(255);
    l_hgrid_element_id      VARCHAR2(255);
    l_switcher_xml_id       VARCHAR2(255);
    l_switcher_casename     VARCHAR2(255);
    l_uicase_name           VARCHAR2(255);
    l_user_attribute3_value VARCHAR2(4000);
    l_user_attribute4_value VARCHAR2(4000);

  BEGIN

    l_curr_parent_xml_node := xmldom.getParentNode(p_xml_node);

    l_xml_node_name := xmldom.getNodeName(p_xml_node);
    l_parent_xml_node_name := xmldom.getNodeName(l_curr_parent_xml_node);

    l_ancestor_node_id := get_Attribute_Value(p_xml_node,
                                          'ancestorNode');

    IF p_old_xml_node_id IS NOT NULL THEN
      set_Attribute(p_xml_node, G_ID_ATTRIBUTE, replace_Prefix(p_new_xml_node_id, p_inline_copy_mode));
    END IF;

    IF l_ancestor_node_id IS NOT NULL THEN

      l_hgrid_element_id := find_Element_Id_Of_XMLTag(p_xml_node, 'oa:tree');

      IF NOT(xmldom.IsNull(p_xml_node)) THEN

        l_ancestor_node_id := p_jrad_doc||'.'||l_hgrid_element_id;
        set_Attribute(p_xml_node,
                      'ancestorNode',
                      l_ancestor_node_id);

      END IF; -- end of IF NOT(xmldom.IsNull(p_xml_node))

    END IF;  -- end of IF l_ancestor_node IS NOT NULL

    --
    -- set value of user attribute "switcherDefaultCaseName" to new jrad id of <oa:switcher>
    --
    IF l_xml_node_name='oa:switcher' THEN

      px_xml_switcher_id := p_old_xml_node_id;

      l_user_attribute3_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);
      l_switcher_casename := get_User_Attribute(l_user_attribute3_value, 'switcherDefaultCaseName');

      IF l_switcher_casename IS NOT NULL THEN
        l_switcher_casename := replace_Prefix(REPLACE(l_switcher_casename, px_xml_switcher_id, p_new_xml_node_id), p_inline_copy_mode);

        set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                           p_cz_attribute_value   => l_switcher_casename,
                           px_xml_attribute_value => l_user_attribute3_value);

        set_Attribute(p_xml_node,
                      G_USER_ATTRIBUTE3_NAME,
                      l_user_attribute3_value);

      END IF;

      set_Attribute(p_xml_node,
                    G_ID_ATTRIBUTE,
                     replace_Prefix(p_new_xml_node_id, p_inline_copy_mode));

    END IF;  -- end of IF l_xml_node_name='oa:switcher'

    --
    -- set value of attribute "name" of <ui:case> to id of parent <oa:switcher>
    --
    IF l_xml_node_name='ui:case' THEN
      IF l_parent_xml_node_name='oa:switcher' THEN

        l_switcher_xml_id := get_Attribute_Value(l_curr_parent_xml_node, G_ID_ATTRIBUTE);
        l_uicase_name     := get_Attribute_Value(p_xml_node, 'name');

        set_Attribute(p_xml_node,
                      'name',
                      replace_Prefix(REPLACE(l_uicase_name, px_xml_switcher_id, l_switcher_xml_id), p_inline_copy_mode));

      END IF;  -- end of IF l_parent_xml_node_name='oa:switcher'

      l_user_attribute4_value := get_Attribute_Value(p_xml_node,
                                                     G_USER_ATTRIBUTE4_NAME);

      IF l_user_attribute4_value IS NOT NULL THEN
        set_User_Attribute(p_cz_attribute_name    => 'caseId',
                           p_cz_attribute_value   => get_Element_Id(),
                           px_xml_attribute_value => l_user_attribute4_value);

        set_Attribute(p_xml_node,G_USER_ATTRIBUTE4_NAME,l_user_attribute4_value);
      END IF;  -- end of IF l_user_attribute4 IS NOT NULL

    END IF;  -- end of IF l_xml_node_name='ui:case'

    --
    -- if current tag is <oa:stackLayout>
    -- then replace old id with new one
    IF (l_xml_node_name='oa:stackLayout' AND l_parent_xml_node_name='ui:case')  THEN

      set_Attribute(p_xml_node,
                    G_ID_ATTRIBUTE,
                    replace_Prefix(get_Attribute_Value(l_curr_parent_xml_node, 'name'), p_inline_copy_mode));

    END IF;  -- end of IF (l_xml_node_name='oa:stackLayout' ...

  END handle_Special_XMLCases;

  --
  -- refresh Template Ref Counts
  --
  PROCEDURE refresh_Templ_Ref_Counts
 (p_template_xml_doc   xmldom.DOMDocument,
  p_template_ui_def_id NUMBER,
  p_template_id        NUMBER) IS

    l_xml_node                xmldom.DOMNode;
    l_child_nodes_tbl         xmldom.DOMNodeList;
    l_extends_attribute       VARCHAR2(2000);
    l_ref_tmpls_tbl           number_tbl_type;
    l_ref_tmpl_seeded_flag    varchar_tbl_type;
    l_ref_template_id         NUMBER;
    l_seeded_flag             CZ_UI_REF_TEMPLATES.ref_templ_seeded_flag%TYPE;
    l_template_id             CZ_UI_REF_TEMPLATES.template_id%TYPE;
    l_length                  NUMBER;

  BEGIN

    l_child_nodes_tbl := xmldom.getElementsByTagName(p_template_xml_doc, '*');
    l_length := xmldom.getLength(l_child_nodes_tbl);

    IF (l_length > 0) THEN
      FOR k IN 0..l_length-1
      LOOP
        l_xml_node := xmldom.item(l_child_nodes_tbl, k);
        l_extends_attribute := get_Attribute_Value(l_xml_node, 'extends');

        IF l_extends_attribute IS NOT NULL THEN


          BEGIN
            SELECT template_id, seeded_flag
              INTO l_ref_template_id, l_seeded_flag
              FROM CZ_UI_TEMPLATES
             WHERE ui_def_id=p_template_ui_def_id AND
                   jrad_doc=l_extends_attribute AND
                   deleted_flag=G_NO_FLAG;

            IF l_ref_tmpls_tbl.EXISTS(l_ref_template_id) THEN
              l_ref_tmpls_tbl(l_ref_template_id) := l_ref_tmpls_tbl(l_ref_template_id) + 1;
            ELSE
              l_ref_tmpls_tbl(l_ref_template_id) := 1;
            END IF;
            l_ref_tmpl_seeded_flag(l_ref_template_id) := l_seeded_flag;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             NULL;
         END;

        END IF;

      END LOOP;
    END IF;

    FOR k IN(SELECT ref_template_id FROM CZ_UI_REF_TEMPLATES
              WHERE template_id=p_template_id AND
                    template_ui_def_id=p_template_ui_def_id AND
                    deleted_flag=G_NO_FLAG)
    LOOP
      IF NOT(l_ref_tmpls_tbl.EXISTS(k.ref_template_id)) THEN
        DELETE FROM CZ_UI_REF_TEMPLATES
         WHERE template_id=p_template_id AND
               template_ui_def_id=p_template_ui_def_id AND
               ref_template_id=k.ref_template_id;
      END IF;
    END LOOP;

    l_template_id := l_ref_tmpls_tbl.FIRST;
    LOOP
      IF l_template_id IS NULL THEN
        EXIT;
      END IF;

      UPDATE CZ_UI_REF_TEMPLATES
         SET ref_count = l_ref_tmpls_tbl(l_template_id)
       WHERE template_id=p_template_id AND
             template_ui_def_id=p_template_ui_def_id AND
             ref_template_id=l_template_id AND
             deleted_flag=G_NO_FLAG;

      IF SQL%ROWCOUNT=0 THEN
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
          VALUES
          (
           p_template_id
          ,l_template_id
          ,G_NO_FLAG
          ,p_template_ui_def_id
          ,p_template_ui_def_id
          ,G_NO_FLAG
          ,l_ref_tmpl_seeded_flag(l_template_id)
          ,l_ref_tmpls_tbl(l_template_id)
          );
      END IF;

      l_template_id := l_ref_tmpls_tbl.NEXT(l_template_id);
    END LOOP;

  END refresh_Templ_Ref_Counts;


  --
  -- initialize nodeView counters
  --
  PROCEDURE init_Page_View_Counters IS

    l_view_counter NUMBER;

  BEGIN

    g_bomm_counter           := 1;
    g_mandatory_comp_counter := 1;

    g_connector_counter      := 0;
    g_mandatory_ref_counter  := 0;
    g_minmax_ref_counter     := 0;
    g_optional_ref_counter   := 0;
    g_of_feature_counter     := 0;
    g_if_feature_counter     := 0;
    g_df_feature_counter     := 0;
    g_bf_feature_counter     := 0;
    g_tf_feature_counter     := 0;
    g_tot_feature_counter    := 0;
    g_rsc_feature_counter    := 0;
    g_itot_feature_counter    := 0;
    g_irsc_feature_counter    := 0;
    g_opt_counter            := 0;

  END init_Page_View_Counters;


  PROCEDURE init_Page_View_Counters(p_subtree_doc  xmldom.DOMDocument) IS

    l_node            xmldom.DOMNode;
    l_nodeslist       xmldom.DOMNodeList;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;
    l_attribute_value VARCHAR2(32000);
    l_node_view       VARCHAR2(255);
  l_id_attr_value   VARCHAR2(255);

    PROCEDURE set_View_Counter(p_node_view IN VARCHAR2) IS
      l_node_view_index NUMBER;
      l_underscore_pos  NUMBER;
      l_prefix          VARCHAR2(255);
    BEGIN

      IF p_node_view IS NOT NULL THEN

        l_underscore_pos := INSTR(p_node_view, '_');
        IF (l_underscore_pos > 1) THEN
          l_prefix := SUBSTR(p_node_view,1,l_underscore_pos);
        ELSE
          RETURN;
        END IF;

        FOR i IN g_view_prefix_tbl.First..g_view_prefix_tbl.Last
        LOOP

          IF l_prefix=g_view_prefix_tbl(i) THEN

            l_node_view_index := TO_NUMBER(SUBSTR(p_node_view, l_underscore_pos+1));

            IF g_view_prefix_tbl(i)='COMP_' THEN
              IF l_node_view_index > g_mandatory_comp_counter THEN
                g_mandatory_comp_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='SIM_' THEN
              IF l_node_view_index > g_optional_ref_counter THEN
                g_optional_ref_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='CS_' THEN
              IF l_node_view_index > g_minmax_ref_counter THEN
                g_minmax_ref_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='OF_' THEN
              IF l_node_view_index > g_of_feature_counter THEN
                g_of_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='IF_' THEN
              IF l_node_view_index > g_if_feature_counter THEN
                g_if_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='DF_' THEN
              IF l_node_view_index > g_df_feature_counter THEN
                g_df_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='BF_' THEN
              IF l_node_view_index > g_bf_feature_counter THEN
                g_bf_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='TF_' THEN
              IF l_node_view_index > g_tf_feature_counter THEN
                g_tf_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='TOT_' THEN
              IF l_node_view_index > g_tot_feature_counter THEN
                g_tot_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='RSC_' THEN
              IF l_node_view_index > g_rsc_feature_counter THEN
                g_rsc_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='ITOT_' THEN
              IF l_node_view_index > g_itot_feature_counter THEN
                g_itot_feature_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='IRSC_' THEN
              IF l_node_view_index > g_irsc_feature_counter THEN
                g_irsc_feature_counter := l_node_view_index;
              END IF;


            ELSIF g_view_prefix_tbl(i)='REF_' THEN
              IF l_node_view_index > g_mandatory_ref_counter THEN
                g_mandatory_ref_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='CON_' THEN
              IF l_node_view_index > g_connector_counter THEN
                g_connector_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='BOMM_' THEN
              IF l_node_view_index > g_bomm_counter THEN
                g_bomm_counter := l_node_view_index;
              END IF;

            ELSIF g_view_prefix_tbl(i)='OPT_' THEN
              IF l_node_view_index > g_opt_counter THEN
                g_opt_counter := l_node_view_index;
              END IF;

            END IF;
          END IF;
        END LOOP;

      END IF;

    END set_View_Counter;

  BEGIN

    g_bomm_counter           := 0;
    g_mandatory_comp_counter := 0;

    g_connector_counter      := 0;
    g_mandatory_ref_counter  := 0;
    g_minmax_ref_counter     := 0;
    g_optional_ref_counter   := 0;
    g_of_feature_counter     := 0;
    g_if_feature_counter     := 0;
    g_df_feature_counter     := 0;
    g_bf_feature_counter     := 0;
    g_tf_feature_counter     := 0;
    g_tot_feature_counter    := 0;
    g_rsc_feature_counter    := 0;
    g_itot_feature_counter    := 0;
    g_irsc_feature_counter    := 0;
    g_opt_counter            := 0;

    l_nodeslist := xmldom.getElementsByTagName(p_subtree_doc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    l_node := xmldom.makeNode(xmldom.getDocumentElement(p_subtree_doc));

    l_attribute_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE3_NAME);
    l_node_view :=  get_User_Attribute(l_attribute_value, 'nodeView');

    set_View_Counter(l_node_view);

    FOR i IN 0 .. l_length - 1
    LOOP
      l_node            := xmldom.item(l_nodeslist, i);
      l_attribute_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE3_NAME);
      l_node_view       :=  get_User_Attribute(l_attribute_value, 'nodeView');
      set_View_Counter(l_node_view);

      l_id_attr_value := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);
      IF l_id_attr_value IS NOT NULL THEN
        BEGIN
          g_dom_elements_tbl(TO_NUMBER(l_id_attr_value)) := l_node;
        EXCEPTION
          WHEN OTHERS THEN
            --
            -- if element_id is not a number it will not be cached
            --
          NULL;
        END;
      END IF;
    END LOOP;

  END init_Page_View_Counters;

  PROCEDURE resolve_view_names(p_xml_node        IN xmldom.DOMNode,
                               p_ui_page_id      IN NUMBER,
                               p_counter         IN OUT NOCOPY NUMBER,
                               p_element_ids_table IN OUT NOCOPY varchar2_tbl_type) IS

      l_view_name             VARCHAR2(255);
      l_children_view_name    VARCHAR2(255);

      l_user_attribute        VARCHAR2(32000);
      l_user_attribute_value  VARCHAR2(32000);
      l_ind                   NUMBER;
      l_child_nodes_tbl       xmldom.DOMNodeList;
      l_length                NUMBER;
      l_child_xml_node        xmldom.DOMNode;
      l_element_id            VARCHAR2(255);

    BEGIN


      IF p_counter = -1 THEN
        SELECT COUNT(element_id) INTO p_counter
        FROM CZ_UI_PAGE_ELEMENTS
        WHERE ui_def_id=g_UI_Context.ui_def_id
        AND page_id=p_ui_page_id AND
        deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);
      END IF;

      l_element_id := get_Attribute_Value(p_xml_node, G_ID_ATTRIBUTE);
      IF l_element_id IS NOT NULL THEN
        p_element_ids_table(l_element_id) := l_element_id;
      END IF;

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);
      IF l_user_attribute_value IS NOT NULL THEN

        l_view_name := get_User_Attribute(l_user_attribute_value ,'nodeView');

        IF l_view_name <> '%nodeView' AND l_view_name IS NOT NULL THEN
          l_ind := INSTR(l_view_name, '_');
          l_view_name := SUBSTR(l_view_name,1,l_ind-1);
          l_view_name := get_next_view_name(l_view_name);

          set_User_Attribute(p_cz_attribute_name    => 'nodeView',
                             p_cz_attribute_value   => l_view_name,
                             px_xml_attribute_value => l_user_attribute_value);

          l_children_view_name := get_User_Attribute(l_user_attribute_value ,'nodeChildrenView');

          IF l_children_view_name <> '%nodeChildrenView' AND l_children_view_name IS NOT NULL THEN

            l_children_view_name := l_view_name || '_children';
            DEBUG('asp: New children view name = ' || l_children_view_name);

            set_User_Attribute(p_cz_attribute_name    => 'nodeChildrenView',
                               p_cz_attribute_value   => l_children_view_name,
                               px_xml_attribute_value => l_user_attribute_value);
          END IF;

          set_Attribute(p_xml_node,
                       G_USER_ATTRIBUTE3_NAME,
                       l_user_attribute_value);
        END IF;
      END IF;

      l_child_nodes_tbl := xmldom.getChildNodes(p_xml_node);
      l_length          := xmldom.getLength(l_child_nodes_tbl);

      FOR k IN 0 .. l_length - 1
      LOOP
        --
        -- get next child DOM node
        --
        l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

        resolve_view_names(p_xml_node          => l_child_xml_node,
                           p_ui_page_id        => p_ui_page_id,
                           p_counter           => p_counter,
                           p_element_ids_table => p_element_ids_table);

      END LOOP;


  END resolve_view_names;


  --
  -- set Attributes for Template
  --
  PROCEDURE set_Template_Attributes(p_xml_root_node        xmldom.DOMNode,
                                    p_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                    p_element_signature_id NUMBER DEFAULT NULL) IS

    l_xml_root_element_node xmldom.DOMElement := xmldom.makeElement(p_xml_root_node);
    l_node                  CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_ui_action_id          NUMBER;
    l_drilldown_text_id     NUMBER;

    l_view_name             VARCHAR2(255);
    l_picklist_view_name    VARCHAR2(255);
    l_has_children          VARCHAR2(1);

    l_model_path            VARCHAR2(32000);
    l_user_attribute        VARCHAR2(32000);

  BEGIN

    --
    -- get Model node by persistent_node_id and project_id
    --
    l_node := get_Model_Node_By_Persist_Id(p_ui_node.persistent_node_id,
                                           g_UI_Context.devl_project_id);

    --
    -- get a corresponding view name by detailed_type_id and
    -- also get variable has_children
    --
    IF  p_ui_node.parent_element_id IS NULL THEN
      IF l_node.ps_node_type IN(258,259) THEN
        l_view_name := 'COMP_1';
      ELSE
        l_view_name := 'BOMM_1';
        l_picklist_view_name := l_view_name || '_children';
      END IF;
    ELSE
      l_view_name := get_View_Name(l_node, l_has_children);
    END IF;

    --
    -- UI Page or CX associated with an
    -- instantiable component must have nodeView='COMP_...'
    --
    IF p_ui_node.element_type=G_UI_CX_BUTTON_NODE_TYPE OR
       p_ui_node.parent_element_id IS NULL THEN
        l_view_name := REPLACE(l_view_name,'CS_','COMP_');
    END IF;

    IF l_has_children = G_YES_FLAG THEN
      l_picklist_view_name := l_view_name || '_children';
    END IF;

    IF g_ref_cx_paths_tbl.EXISTS(TO_NUMBER(p_ui_node.element_id)) THEN
      l_model_path := g_ref_cx_paths_tbl(TO_NUMBER(p_ui_node.element_id));
    ELSE
      l_model_path := get_Model_Path(p_ui_node);
    END IF;

    --
    -- set JRAD id of element
    --
    set_Attribute(l_xml_root_element_node,
                  G_ID_ATTRIBUTE,
                  p_ui_node.element_id);

    --
    -- attribute1 is always used only for model_path
    --
    set_Attribute(l_xml_root_element_node,
                  G_USER_ATTRIBUTE1_NAME,
                  'model_path='||l_model_path);

    IF l_model_path='*' THEN
      set_Attribute(l_xml_root_element_node,
                    G_USER_ATTRIBUTE2_NAME,
                    '0');
    ELSE
      --
      -- set attribute2 to persistent_node_id :
      -- THIS ATTRIBUTE MUST BE SET ONLY BY UI GENERATION / UI REFRESH
      --
      set_Attribute(l_xml_root_element_node,
                    G_USER_ATTRIBUTE2_NAME,
                    TO_CHAR(p_ui_node.persistent_node_id));
    END IF;

    --
    -- get value of "user:attribute3"
    --
    l_user_attribute := get_Attribute_Value(p_xml_root_node,
                                            G_USER_ATTRIBUTE3_NAME);

    IF l_user_attribute IS NOT NULL THEN

      IF l_view_name IS NOT NULL THEN
        set_User_Attribute(p_cz_attribute_name    => 'nodeView',
                           p_cz_attribute_value   => l_view_name,
                           px_xml_attribute_value => l_user_attribute);
      END IF;
      IF l_picklist_view_name IS NOT NULL THEN
        set_User_Attribute(p_cz_attribute_name    => 'nodeChildrenView',
                           p_cz_attribute_value   => l_picklist_view_name,
                           px_xml_attribute_value => l_user_attribute);
      END IF;

      IF INSTR(l_user_attribute, 'actionId=')>0 THEN
        BEGIN
          l_ui_action_id := get_UI_Action_Id(p_ui_node);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        IF l_ui_action_id IS NOT NULL THEN
          set_User_Attribute(p_cz_attribute_name    => 'actionId',
                             p_cz_attribute_value   => TO_CHAR(l_ui_action_id),
                             px_xml_attribute_value => l_user_attribute);
        END IF;

      END IF;
      /* commented out according to request from 8/12/2004
      set_User_Attribute(p_cz_attribute_name    => 'blockSize',
                          p_cz_attribute_value   => TO_CHAR(g_UI_Context.ROWS_PER_TABLE),
                         px_xml_attribute_value => l_user_attribute);
      */
    END IF; -- end of setting  G_USER_ATTRIBUTE3_NAME

    IF p_ui_node.element_type IN(G_UI_PAGEDRILLDOWN_NODE_TYPE,G_UI_DRILLDOWN_NODE_TYPE) THEN
      IF  g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID IS NOT NULL THEN

        l_drilldown_text_id := copy_Intl_Text(g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID,
                                              g_UI_Context.ui_def_id,
                                              p_ui_node.page_id, p_ui_node.element_id);

        set_User_Attribute(p_cz_attribute_name    => 'captionIntlTextId',
                           p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                           px_xml_attribute_value => l_user_attribute);

        set_User_Attribute(p_cz_attribute_name    => 'rolloverIntlTextId',
                           p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                           px_xml_attribute_value => l_user_attribute);

      END IF;
      --
      -- set "source" for image associated with a drilldown
      --
      IF g_UI_Context.DRILLDOWN_IMAGE_URL IS NOT NULL THEN
        set_Attribute(l_xml_root_element_node,
                      'source',
                      g_UI_Context.DRILLDOWN_IMAGE_URL);
      END IF;
    ELSIF p_ui_node.element_type=G_UI_CX_BUTTON_NODE_TYPE THEN
      set_User_Attribute(p_cz_attribute_name    => 'captionIntlTextId',
                         p_cz_attribute_value   => TO_CHAR(g_cx_names_tbl(TO_NUMBER(p_ui_node.element_id))),
                         px_xml_attribute_value => l_user_attribute);

        set_User_Attribute(p_cz_attribute_name    => 'rolloverIntlTextId',
                           p_cz_attribute_value   => TO_CHAR(g_cx_names_tbl(TO_NUMBER(p_ui_node.element_id))),
                           px_xml_attribute_value => l_user_attribute);

    END IF;

    set_Attribute(l_xml_root_element_node,G_USER_ATTRIBUTE3_NAME,l_user_attribute);

    --
    -- get value of "user:attribute4" which is used by Oracle Configurator Developer
    --
    l_user_attribute := get_Attribute_Value(p_xml_root_node,
                                            G_USER_ATTRIBUTE4_NAME);
    IF l_user_attribute IS NOT NULL THEN

      set_User_Attribute(p_cz_attribute_name    => 'name',
                         p_cz_attribute_value   => p_ui_node.name,
                         px_xml_attribute_value => l_user_attribute);

      IF p_element_signature_id IS NOT NULL THEN
         set_User_Attribute(p_cz_attribute_name    => 'elementType',
                            p_cz_attribute_value   => TO_CHAR(p_element_signature_id),
                            px_xml_attribute_value => l_user_attribute);
      ELSE
         set_User_Attribute(p_cz_attribute_name    => 'elementType',
                            p_cz_attribute_value   => TO_CHAR(p_ui_node.element_signature_id),
                            px_xml_attribute_value => l_user_attribute);
      END IF;

    END IF;

    set_Attribute(l_xml_root_element_node,
                  G_USER_ATTRIBUTE4_NAME,
                  l_user_attribute);

    set_Attribute(l_xml_root_element_node,
                  G_USER_ATTRIBUTE5_NAME,
                  'GENERATED_BY_UI_GEN');

  END set_Template_Attributes;

  FUNCTION get_Element_XML_Path(p_xml_doc xmldom.DOMDocument,p_element_id VARCHAR2)  RETURN VARCHAR2 IS

    l_xml_node     xmldom.DOMNode;
    l_element_path VARCHAR2(32000);

    PROCEDURE construct_XML_Path(p_xml_node xmldom.DOMNode) IS

      l_parent_node            xmldom.DOMNode;
      l_element_id             CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
      l_user_attribute4_value  VARCHAR2(32000);
      l_node_name              VARCHAR2(32000);

    BEGIN

      IF xmldom.isNull(p_xml_node) THEN
        RETURN;
      END IF;
      l_parent_node := xmldom.getParentNode(p_xml_node);
      l_element_id := get_Attribute_Value(p_xml_node, G_ID_ATTRIBUTE);

      IF l_element_id IS NOT NULL AND xmldom.getNodeName(l_parent_node)<>'#document'THEN

        l_user_attribute4_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE4_NAME);
        IF l_user_attribute4_value IS NOT NULL THEN
          l_node_name := get_User_Attribute(l_user_attribute4_value ,'name');

          IF l_element_path IS NOT NULL THEN
            l_element_path := l_node_name||'.'||l_element_path;
          ELSE
            l_element_path := l_node_name;
          END IF;

        END IF;
      END IF;

        IF  NOT(xmldom.IsNull(p_xml_node)) THEN
          IF NOT(xmldom.IsNull(l_parent_node)) THEN
            construct_XML_Path(l_parent_node);
          END IF;
        END IF;

    END construct_XML_Path;

  BEGIN

    l_xml_node := find_XML_Node_By_Attribute(p_xml_doc, G_ID_ATTRIBUTE, p_element_id);

    IF NOT(xmldom.IsNull(l_xml_node)) THEN
      construct_XML_Path(l_xml_node);
    ELSE
      RETURN NULL;
    END IF;

    RETURN l_element_path;

  END get_Element_XML_Path;

  FUNCTION get_Element_XML_Path(p_xml_node xmldom.DOMNode)  RETURN VARCHAR2 IS

    l_element_path VARCHAR2(32000);

    PROCEDURE construct_XML_Path(p_xml_node xmldom.DOMNode) IS

      l_parent_node            xmldom.DOMNode;
      l_element_id             CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
      l_user_attribute4_value  VARCHAR2(32000);
      l_node_name              VARCHAR2(32000);

    BEGIN

      IF xmldom.isNull(p_xml_node) THEN
        RETURN;
      END IF;
      l_parent_node := xmldom.getParentNode(p_xml_node);
      l_element_id := get_Attribute_Value(p_xml_node, G_ID_ATTRIBUTE);

      IF l_element_id IS NOT NULL AND xmldom.getNodeName(l_parent_node)<>'#document'THEN

        l_user_attribute4_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE4_NAME);
        IF l_user_attribute4_value IS NOT NULL THEN
          l_node_name := get_User_Attribute(l_user_attribute4_value ,'name');

          IF l_element_path IS NOT NULL THEN
            l_element_path := l_node_name||'.'||l_element_path;
          ELSE
            l_element_path := l_node_name;
          END IF;

        END IF;
      END IF;

        IF  NOT(xmldom.IsNull(p_xml_node)) THEN
          IF NOT(xmldom.IsNull(l_parent_node)) THEN
            construct_XML_Path(l_parent_node);
          END IF;
        END IF;

    END construct_XML_Path;

  BEGIN

    IF NOT(xmldom.IsNull(p_xml_node)) THEN
      construct_XML_Path(p_xml_node);
    ELSE
      RETURN NULL;
    END IF;

    RETURN l_element_path;
  EXCEPTION
    WHEN OTHERS THEN
      DEBUG(SQLERRM);
      RETURN NULL;
  END get_Element_XML_Path;

  --
  -- return path for a given UI element
  --
  FUNCTION get_Element_XML_Path(p_ui_def_id  IN NUMBER,
                                p_page_id    IN NUMBER,
                                p_element_id IN VARCHAR2,
                                p_is_parser_open IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS

    l_xmldoc        xmldom.DOMDocument;
    l_page_jrad_doc CZ_UI_PAGES.jrad_doc%TYPE;
    l_ui_name       CZ_UI_DEFS.name%TYPE;
    l_page_name     CZ_UI_PAGES.name%TYPE;
    l_element_path  VARCHAR2(32000);

  BEGIN

    IF p_is_parser_open IS NULL OR p_is_parser_open='0' THEN
      Open_Parser();
    END IF;

    SELECT jrad_doc,name INTO l_page_jrad_doc,l_page_name FROM CZ_UI_PAGES
    WHERE ui_def_id=p_ui_def_id AND page_id=p_page_id;

    --
    -- create UI Template in JRAD repository
    --
    l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_page_jrad_doc);

    IF xmldom.isNull(l_xmldoc) THEN
      -- UI page is already deleted
      RETURN NULL;
    END IF;

    l_element_path := get_Element_XML_Path(l_xmldoc,p_element_id);

    IF p_is_parser_open IS NULL OR p_is_parser_open='0' THEN
      Close_Parser();
    END IF;

    SELECT name INTO l_ui_name FROM CZ_UI_DEFS
    WHERE ui_def_id=p_ui_def_id;

    IF l_element_path IS NULL OR l_element_path='.' THEN
      l_element_path := l_ui_name||'.'||'Pages'||'.'||l_page_name;
    ELSE
      l_element_path := l_ui_name||'.'||'Pages'||'.'||l_page_name||'.'||l_element_path;
    END IF;

    RETURN l_element_path;

  END get_Element_XML_Path;


  PROCEDURE copy_UI_Rule
  (
  p_rule_id       IN NUMBER,
  x_rule_id       OUT NOCOPY NUMBER,
  p_ui_def_id     IN NUMBER,
  p_ui_page_id    IN NUMBER,
  p_ui_element_id IN VARCHAR2,
  p_source_ui_def_id IN NUMBER,
  p_new_component_id IN NUMBER DEFAULT NULL, -- passed when copied rule needs to be associated to a different PS Node
  p_new_expl_node_id IN NUMBER DEFAULT NULL, -- passed when copied rule needs to be associated to a different PS Node
  p_xml_node      IN xmldom.DOMNode DEFAULT g_Null_Xml_Node
  ) IS

    l_return_status        VARCHAR2(255);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(4000);
    l_run_id               NUMBER;
    l_element_path         VARCHAR2(4000);
    l_source_ui_def_id     NUMBER;
    l_failure_flag         NUMBER;
    l_cp_rule_run_id       NUMBER;
    l_copied_rule          BOOLEAN;

  BEGIN
    IF p_rule_id IS NOT NULL THEN

      IF p_source_ui_def_id IS NULL THEN
        l_source_ui_def_id := 0;
      ELSE
        l_source_ui_def_id := p_source_ui_def_id;
      END IF;
      FOR k IN(SELECT rule_id,rule_type,seeded_flag,devl_project_id FROM CZ_RULES
               WHERE persistent_rule_id = p_rule_id AND DECODE(NVL(ui_def_id,0),0,l_source_ui_def_id,ui_def_id)=l_source_ui_def_id
                     AND deleted_flag=G_NO_FLAG)
      LOOP
        l_run_id := 0; l_cp_rule_run_id := 0;
        l_copied_rule := FALSE;

        IF NVL(k.seeded_flag,G_NO_FLAG)=G_NO_FLAG THEN
          CZ_DEVELOPER_UTILS_PVT.copy_Rule
          (p_rule_id                  => k.rule_id,
           p_init_msg_list            => FND_API.G_FALSE,
           p_ui_def_id                => p_ui_def_id,
           p_ui_page_id               => p_ui_page_id,
           p_ui_page_element_id       => p_ui_element_id,
           x_out_new_rule_id          => x_rule_id,
           x_run_id                   => l_cp_rule_run_id,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data);

           IF p_new_component_id IS NOT NULL THEN

             DEBUG('Associating copied rule to a different PS Node');
             -- This rule is being copied and associated to a different component_id
             UPDATE CZ_RULES
                SET component_id = p_new_component_id,
                    model_ref_expl_id = p_new_expl_node_id
              WHERE rule_id = x_rule_id;
           l_copied_rule := TRUE;
           END IF;
        ELSE
           x_rule_id := k.rule_id;
        END IF;

        l_failure_flag := 0;
        IF l_cp_rule_run_id > 0 THEN
          SELECT COUNT(*) INTO l_failure_flag FROM CZ_DB_LOGS WHERE run_id=l_cp_rule_run_id;
        END IF;

        IF l_failure_flag=0 AND NVL(k.devl_project_id,0) NOT IN(0,1) AND l_copied_rule THEN
          CZ_DEVELOPER_UTILS_PVT.verify_special_rule(p_rule_id => x_rule_id,
                                                     p_name    => NULL,
                                                     x_run_id  => l_run_id);
        END IF;

        IF l_run_id > 0 THEN
          IF NOT(xmldom.IsNull(p_xml_node)) THEN
            l_element_path := get_Element_XML_Path(p_xml_node   => p_xml_node);
          ELSE -- UI rule on UI page level
            SELECT name INTO l_element_path FROM CZ_UI_PAGES
            WHERE page_id=p_ui_page_id AND ui_def_id=p_ui_def_id;
          END IF;

          IF k.rule_type=33 THEN
               add_Error_Message(p_message_name => 'CZ_DISP_COND_DEL_ND_ERROR',
                                 p_token_name   => 'UIELEMENTPATH',
                                 p_token_value  => l_element_path,
                                 p_fatal_error  => TRUE);
          ELSIF k.rule_type=34 THEN
              add_Error_Message(p_message_name => 'CZ_ENABLED_CONDITION_ERROR',
                                p_token_name   => 'UIELEMENTPATH',
                                p_token_value  => l_element_path,
                                p_fatal_error  => TRUE);
          ELSE
              NULL;
          END IF;

        END IF;
      END LOOP;
    ELSE
      x_rule_id := NULL;
    END IF;
  END copy_UI_Rule;

  --vsingava IM-ER
  FUNCTION get_Runtime_Relative_Path
  (
  p_model_id                     NUMBER,
  p_base_persistent_node_Id      NUMBER,
  p_base_expl_id                 NUMBER,
  p_persistent_node_id           NUMBER,
  p_ui_node_expl_id              NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS

    l_model_path         VARCHAR2(32000);
    l_pagebase_expl_id   NUMBER;
    l_expl_id            NUMBER;
    l_expl_node_id       NUMBER;
    l_ps_node_id         NUMBER;
    l_ps_node_type       NUMBER;
    l_component_id       NUMBER;
    l_model_ref_expl_id  NUMBER;
    l_pagebase_persistent_node_id NUMBER;

  BEGIN


     BEGIN
      --
      -- does the current node with persistent_node_id=p_persistent_node_id
      -- belongs to model with devl_project_id=p_model_id ?
      --
      SELECT ps_node_id,ps_node_type,component_id
        INTO l_ps_node_id, l_ps_node_type, l_component_id  FROM CZ_PS_NODES
       WHERE devl_project_id=p_model_id AND
             persistent_node_id=p_persistent_node_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --
         -- the current node with persistent_node_id=p_persistent_node_id
         -- does not belong to model with devl_project_id=p_model_id
         -- and belongs to some referenced model
         --
         NULL;
    END;


    --
    -- AMN of UI node belongs to current model
    --
     IF l_ps_node_id IS NOT NULL THEN
      l_expl_id := get_Expl_Id(p_model_id      => p_model_id,
                               p_ps_node_id    => l_ps_node_id,
                               p_component_id  => l_component_id,
                               p_ps_node_type  => l_ps_node_type);


      l_model_path := CZ_DEVELOPER_UTILS_PVT.runtime_relative_path(p_base_expl_id => p_base_expl_id,
                                                                   p_base_pers_id => p_base_persistent_node_Id,
                                                                   p_node_expl_id => l_expl_id,
                                                                   p_node_pers_id => p_persistent_node_id);

      IF l_model_path IS NULL THEN
        l_model_path := '.';
      END IF;

      RETURN l_model_path;
    END IF;


    -- validation of expl_id
    SELECT model_ref_expl_id INTO l_model_ref_expl_id
      FROM CZ_MODEL_REF_EXPLS
     WHERE model_ref_expl_id=p_ui_node_expl_id;

    --
    -- AMN of UI node belongs to referenced model
    --


    FOR i IN(SELECT model_ref_expl_id,parent_expl_node_id,ps_node_type,
                    component_id,referring_node_id
               FROM CZ_MODEL_REF_EXPLS
              START WITH model_ref_expl_id=p_ui_node_expl_id
              CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id AND
                               deleted_flag='0')
    LOOP
      -- go up until the nearest reference or the root
      IF (i.ps_node_type IN(G_REFERENCE_TYPE,G_CONNECTOR_TYPE) OR i.parent_expl_node_id IS NULL) THEN


        -- get ps node data for AMN of UI node
        SELECT ps_node_id,ps_node_type,component_id
          INTO l_ps_node_id, l_ps_node_type,l_component_id
          FROM CZ_PS_NODES
         WHERE devl_project_id=i.component_id AND
               persistent_node_id=p_persistent_node_id AND
               deleted_flag=G_NO_FLAG;

        -- If the UI AMN found in the referenced model is not a reference or a connector or we are dealing with the
        -- reference node itself (can the second part of this condition ever be true)
        IF (l_ps_node_type NOT IN(G_REFERENCE_TYPE,G_CONNECTOR_TYPE) OR p_ui_node_expl_id=i.model_ref_expl_id) THEN


          SELECT model_ref_expl_id INTO l_expl_id FROM
            (SELECT model_ref_expl_id,referring_node_id,component_id FROM CZ_MODEL_REF_EXPLS
              START WITH model_ref_expl_id=i.model_ref_expl_id
            CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag='0') a
          WHERE (l_ps_node_type IN(G_REFERENCE_TYPE,G_CONNECTOR_TYPE) AND a.referring_node_id=l_ps_node_id) OR
                (l_ps_node_type NOT IN(G_REFERENCE_TYPE,G_CONNECTOR_TYPE) AND a.component_id=l_component_id);



          l_model_path := CZ_DEVELOPER_UTILS_PVT.runtime_relative_path(p_base_expl_id => p_base_expl_id,
                                                                       p_base_pers_id => p_base_persistent_node_id,
                                                                       p_node_expl_id => l_expl_id,
                                                                       p_node_pers_id => p_persistent_node_id);


          IF l_model_path IS NULL THEN
            l_model_path := '.';
          END IF;

          RETURN l_model_path;
        END IF;

      END IF;
    END LOOP;

  END get_Runtime_Relative_Path;


  FUNCTION get_Runtime_Relative_Path
  (
  p_model_id                     NUMBER,
  p_persistent_node_id           NUMBER,
  p_page_id                      NUMBER,
  p_ui_node_expl_id              NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS

    l_model_path         VARCHAR2(32000);
    l_pagebase_expl_id   NUMBER;
    l_expl_id            NUMBER;
    l_expl_node_id       NUMBER;
    l_ps_node_id         NUMBER;
    l_ps_node_type       NUMBER;
    l_component_id       NUMBER;
    l_model_ref_expl_id  NUMBER;
    l_pagebase_persistent_node_id NUMBER;

  BEGIN

    SELECT persistent_node_id,pagebase_expl_node_id
      INTO l_pagebase_persistent_node_id, l_pagebase_expl_id
      FROM CZ_UI_PAGES
     WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id=p_page_id;

     RETURN get_Runtime_Relative_Path(p_model_id, l_pagebase_persistent_node_id, l_pagebase_expl_id, p_persistent_node_id, p_ui_node_expl_id);

  END;

  PROCEDURE handle_User_Attributes
  (px_user_attribute_value IN OUT NOCOPY VARCHAR2,
   p_source_ui_def_id      IN NUMBER,
   p_source_ui_page_id     IN NUMBER,
   p_target_ui_def_id      IN NUMBER,
   p_target_ui_page_id     IN NUMBER,
   p_new_element_id        IN VARCHAR2,
   p_il_persistent_node_id IN NUMBER DEFAULT NULL, --  AMN of the enclosing instance list
   p_il_expl_node_id       IN NUMBER DEFAULT NULL, --  AMN of the enclosing instance list
   p_amn_persistent_node_id IN NUMBER DEFAULT NULL, -- AMN of the node (specified or inherited)
   p_amn_expl_node_id       IN NUMBER DEFAULT NULL, -- AMN of the node (specified or inherited)
   p_source_template_id    IN NUMBER DEFAULT NULL,
   p_target_template_id    IN NUMBER DEFAULT NULL,
   p_xml_node              IN xmldom.DOMNode DEFAULT g_Null_Xml_Node) IS

    l_cached_elems_tbl        number_tbl_type;
    l_cached_source_elems_tbl number_tbl_type;
    l_counter                 NUMBER := 0;

    l_id                   NUMBER;
    l_new_action_id        NUMBER;
    l_new_rule_id          NUMBER;
    l_new_intl_text_id     NUMBER;
    l_ui_def_node          CZ_UI_DEFS%ROWTYPE;
    l_prev_ui_context      CZ_UI_DEFS%ROWTYPE;
    l_new_target_node_path CZ_UI_ACTIONS.target_node_path%TYPE;
    l_base_persistent_node_id NUMBER;
    l_base_expl_node_id      NUMBER;
    l_model_node CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_component_id NUMBER;
    l_expl_node_id NUMBER;

  BEGIN

    IF px_user_attribute_value IS NULL THEN
      RETURN;
    END IF;


    l_ui_def_node := get_Local_UI_Context(p_target_ui_def_id);
    l_prev_ui_context := g_UI_Context;
    g_UI_Context := l_ui_def_node;

    BEGIN
      l_id := TO_NUMBER(get_User_Attribute(px_user_attribute_value,'actionId'));
    EXCEPTION
      WHEN OTHERS THEN
        l_id := NULL;
    END;

    IF l_id IS NOT NULL THEN

      FOR i IN(SELECT * FROM CZ_UI_ACTIONS
                WHERE ui_def_id=p_source_ui_def_id AND
                ui_action_id=l_id AND
                NVL(source_page_id,0)=NVL(p_source_ui_page_id,0)
                AND seeded_flag=G_NO_FLAG)
      LOOP

          l_new_action_id := allocateId('CZ_UI_ACTIONS_S');

          IF i.target_persistent_node_id IS NOT NULL THEN
            -- If the IL AMN is passed in, then use that else use the AMN on the page. IL AMN will be passed
            -- when the caller needs the paths in actions to start from a node different
            -- from the page base. This is needed in elements inside and Instance List Region
            IF p_il_persistent_node_id IS NOT NULL THEN

              l_base_persistent_node_id := p_il_persistent_node_id;
              l_base_expl_node_id := p_il_expl_node_id;

            ELSE
              -- base AMN is not passed, so continue using the AMN of the page as earlier
              SELECT persistent_node_id, pagebase_expl_node_id
                INTO l_base_persistent_node_id, l_base_expl_node_id
                FROM CZ_UI_PAGES
               WHERE ui_def_Id = p_target_ui_def_id
                 AND page_Id = p_target_ui_page_id;
            END IF;

            l_new_target_node_path := get_Runtime_Relative_Path(p_model_id             => l_ui_def_node.devl_project_id,
                                                                p_base_persistent_node_Id => l_base_persistent_node_id,
                                                                p_base_expl_id      => l_base_expl_node_id,
                                                                p_persistent_node_id     => i.target_persistent_node_id);
                                                                -- This does not seem right. We should pass a value for expl Id here
          ELSE
            l_new_target_node_path := NULL;
          END IF;

          INSERT INTO CZ_UI_ACTIONS
          (
          UI_ACTION_ID
          ,UI_DEF_ID
          ,SOURCE_PAGE_ID
          ,CONTEXT_COMPONENT_ID
          ,ELEMENT_ID
          ,RENDER_CONDITION_ID
          ,UI_ACTION_TYPE
          ,TARGET_UI_DEF_ID
          ,TARGET_PERSISTENT_NODE_ID
          ,TARGET_NODE_PATH
          ,TARGET_PAGE_SET_ID
          ,TARGET_PAGE_ID
          ,TARGET_URL
          ,FRAME_NAME
          ,TARGET_ANCHOR
          ,DELETED_FLAG
          ,SEEDED_FLAG
          ,CX_COMMAND_NAME
          ,WINDOW_PARAMETERS
          ,TARGET_WINDOW_TYPE
          ,TARGET_WINDOW_NAME
          ,TARGET_EXPL_NODE_ID
          ,URL_PROPERTY_ID
          ,PROC_PAGE_TEMPL_UI_DEF_ID
          ,PAGE_TITLE_TEXT_ID
          ,MAIN_MESSAGE_TEXT_ID
          ,PROCESSING_CAPTION_TEXT_ID
          ,PROCESSING_PAGE_TEMPL_ID
--Processing page ER 9656558
          ,PROCESSING_PAGE_ENABLED_FLAG
          )
          VALUES(
          l_new_action_id
          ,p_target_ui_def_id
          ,p_target_ui_page_id
          ,i.CONTEXT_COMPONENT_ID
          ,p_new_element_id
          ,i.RENDER_CONDITION_ID
          ,i.UI_ACTION_TYPE
          ,i.TARGET_UI_DEF_ID
          ,i.TARGET_PERSISTENT_NODE_ID
          ,l_new_target_node_path
          ,i.TARGET_PAGE_SET_ID
          ,i.TARGET_PAGE_ID
          ,i.TARGET_URL
          ,i.FRAME_NAME
          ,i.TARGET_ANCHOR
          ,i.DELETED_FLAG
          ,'0'
          ,i.CX_COMMAND_NAME
          ,i.WINDOW_PARAMETERS
          ,i.TARGET_WINDOW_TYPE
          ,i.TARGET_WINDOW_NAME
          ,i.TARGET_EXPL_NODE_ID
          ,i.URL_PROPERTY_ID
          ,i.PROC_PAGE_TEMPL_UI_DEF_ID
          ,i.PAGE_TITLE_TEXT_ID
          ,i.MAIN_MESSAGE_TEXT_ID
          ,i.PROCESSING_CAPTION_TEXT_ID
          ,i.PROCESSING_PAGE_TEMPL_ID
          ,i.PROCESSING_PAGE_ENABLED_FLAG
          );

          set_User_Attribute(p_cz_attribute_name    => 'actionId',
                             p_cz_attribute_value   => TO_CHAR(l_new_action_id),
                             px_xml_attribute_value => px_user_attribute_value);

          IF p_source_template_id IS NOT NULL THEN
            l_counter := l_counter + 1;
            l_cached_elems_tbl(l_counter) := l_new_action_id;
            l_cached_source_elems_tbl(l_counter) := l_id;
          END IF;

          END LOOP;

          -- set global UI context to its value before this procedure call
          g_UI_Context := l_prev_ui_context;
        END IF;
        l_component_id := NULL;
        l_expl_node_id := NULL;

        FOR i IN g_condition_attr_tbl.First..g_condition_attr_tbl.Last
        LOOP
          BEGIN
            l_id := TO_NUMBER(get_User_Attribute(px_user_attribute_value,g_condition_attr_tbl(i)));
          EXCEPTION
            WHEN OTHERS THEN
              l_id := NULL;
          END;
          IF l_id IS NOT NULL THEN

            IF p_il_persistent_node_id IS NOT NULL THEN
              -- IL AMN passed in is not NULL which means that this element is part of an Instance List
              -- Region. We need to set the Component Id as the AMN of the UI element itself
              IF p_amn_persistent_node_id IS NOT NULL THEN
                -- UI Conditions for elements inside Instance List regions are associated to the AMN of the element
                -- as opposed to the Page base like in other case. Since this node is under an Instance List, we need
                -- to update the rules component_id to be the AMN's ps_node_id
                l_model_node := getNodeByPersistentAndExplId(p_amn_persistent_node_id, p_amn_expl_node_id);
                l_component_id := l_model_node.ps_node_id;
                l_expl_node_id := p_amn_expl_node_id;
              END IF;
            END IF;
            copy_UI_Rule(l_id,
                         l_new_rule_id,
                         p_target_ui_def_id,
                         p_target_ui_page_id,
                         p_new_element_id,
                         p_source_ui_def_id,
                         l_component_id,
                         l_expl_node_id,
                         p_xml_node => p_xml_node);

            IF p_source_template_id IS NOT NULL THEN
              l_counter := l_counter + 1;
              l_cached_elems_tbl(l_counter) := l_new_rule_id;
              l_cached_source_elems_tbl(l_counter) := l_id;
            END IF;

            set_User_Attribute(p_cz_attribute_name    => g_condition_attr_tbl(i),
                               p_cz_attribute_value   => TO_CHAR(l_new_rule_id),
                               px_xml_attribute_value => px_user_attribute_value);

          END IF;
        END LOOP;

        FOR i IN g_caption_attr_tbl.First..g_caption_attr_tbl.Last
        LOOP
          BEGIN
            l_id := TO_NUMBER(get_User_Attribute(px_user_attribute_value,g_caption_attr_tbl(i)));
          EXCEPTION
            WHEN OTHERS THEN
              l_id := NULL;
          END;

          IF l_id IS NOT NULL THEN

              l_new_intl_text_id := NULL;

              FOR k IN(SELECT * FROM CZ_LOCALIZED_TEXTS
                       WHERE intl_text_id=l_id AND seeded_flag=G_NO_FLAG
                              AND deleted_flag=G_NO_FLAG)
              LOOP
                IF l_new_intl_text_id IS NULL THEN
                  l_new_intl_text_id := allocateId('CZ_INTL_TEXTS_S');
                END IF;
                INSERT INTO CZ_LOCALIZED_TEXTS
                (
                LOCALE_ID
                ,LOCALIZED_STR
                ,INTL_TEXT_ID
                ,DELETED_FLAG
                ,EFF_FROM
                ,EFF_TO
                ,SECURITY_MASK
                ,EFF_MASK
                ,CHECKOUT_USER
                ,ORIG_SYS_REF
                ,LANGUAGE
                ,SOURCE_LANG
                ,UI_DEF_ID
                ,MODEL_ID
                ,SEEDED_FLAG
                ,UI_PAGE_ID
                ,UI_PAGE_ELEMENT_ID
                )
                VALUES(
                k.LOCALE_ID
                ,k.LOCALIZED_STR
                ,l_new_intl_text_id
                ,k.DELETED_FLAG
                ,k.EFF_FROM
                ,k.EFF_TO
                ,k.SECURITY_MASK
                ,k.EFF_MASK
                ,k.CHECKOUT_USER
                ,k.ORIG_SYS_REF
                ,k.LANGUAGE
                ,k.SOURCE_LANG
                ,p_target_ui_def_id
                ,l_ui_def_node.devl_project_id
                ,'0'
                ,p_target_ui_page_id
                ,p_new_element_id
                );
              END LOOP;

              IF l_new_intl_text_id IS NOT NULL THEN
                set_User_Attribute(p_cz_attribute_name    => g_caption_attr_tbl(i),
                                   p_cz_attribute_value   => TO_CHAR(l_new_intl_text_id),
                                   px_xml_attribute_value => px_user_attribute_value);

                IF p_source_template_id IS NOT NULL THEN
                  l_counter := l_counter + 1;
                  l_cached_elems_tbl(l_counter) := l_new_intl_text_id;
                  l_cached_source_elems_tbl(l_counter) := l_id;
                END IF;
              END IF;
           ELSE -- l_id is NULL

            BEGIN
              l_id := g_cx_names_tbl(TO_NUMBER(p_new_element_id));
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;

            IF l_id IS NOT NULL THEN
                 set_User_Attribute(p_cz_attribute_name    => g_caption_attr_tbl(i),
                                    p_cz_attribute_value   => TO_CHAR(l_id),
                                    px_xml_attribute_value => px_user_attribute_value);

            ELSE
                 set_User_Attribute(p_cz_attribute_name    => g_caption_attr_tbl(i),
                                    p_cz_attribute_value   => TO_CHAR(g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID),
                                    px_xml_attribute_value => px_user_attribute_value);
            END IF;

          END IF;
        END LOOP;

    IF l_cached_elems_tbl.COUNT > 0 THEN
      FOR i IN l_cached_elems_tbl.First..l_cached_elems_tbl.Last
      LOOP

        INSERT INTO CZ_UI_TEMPLATE_ELEMENTS
        (
        TEMPLATE_ID
        ,UI_DEF_ID
        ,ELEMENT_TYPE
        ,ELEMENT_ID
        ,PERSISTENT_ELEMENT_ID
        ,DELETED_FLAG
        ,SEEDED_FLAG
        )
        SELECT
         p_target_template_id
        ,p_target_ui_def_id
        ,ELEMENT_TYPE
        ,l_cached_elems_tbl(i)
        ,l_cached_elems_tbl(i)
        ,G_NO_FLAG
        ,G_NO_FLAG
        FROM CZ_UI_TEMPLATE_ELEMENTS
        WHERE template_id=p_source_template_id AND
              ui_def_id=p_source_ui_def_id AND
              element_id=l_cached_source_elems_tbl(i) AND
              deleted_flag=G_NO_FLAG;
      END LOOP;
    END IF;

  END handle_User_Attributes;

  --
  -- handle user attributes in UI template
  --
  PROCEDURE handle_Template_Attributes
  (px_user_attribute_value IN OUT NOCOPY VARCHAR2,
   p_new_element_id        IN VARCHAR2,
   p_source_ui_def_id      IN NUMBER,
   p_source_template_id    IN NUMBER,
   p_target_ui_def_id      IN NUMBER,
   p_target_template_id    IN NUMBER,
   p_xml_node              IN xmldom.DOMNode DEFAULT g_Null_Xml_Node) IS

    l_cached_elems_tbl        number_tbl_type;
    l_cached_source_elems_tbl number_tbl_type;
    l_counter                 NUMBER := 0;

    l_id               NUMBER;
    l_new_action_id    NUMBER;
    l_new_rule_id      NUMBER;
    l_new_intl_text_id NUMBER;

  BEGIN

    IF px_user_attribute_value IS NULL THEN
      RETURN;
    END IF;

    BEGIN
      l_id := TO_NUMBER(get_User_Attribute(px_user_attribute_value,'actionId'));
    EXCEPTION
      WHEN OTHERS THEN
        l_id := NULL;
    END;

    IF l_id IS NOT NULL THEN

      FOR i IN(SELECT * FROM CZ_UI_ACTIONS
                WHERE ui_action_id=l_id AND
                      ui_def_id=p_source_ui_def_id AND
                      source_page_id=0 AND
                      seeded_flag=G_NO_FLAG)
      LOOP

          l_new_action_id := allocateId('CZ_UI_ACTIONS_S');

          INSERT INTO CZ_UI_ACTIONS
          (
          UI_ACTION_ID
          ,UI_DEF_ID
          ,SOURCE_PAGE_ID
          ,CONTEXT_COMPONENT_ID
          ,ELEMENT_ID
          ,RENDER_CONDITION_ID
          ,UI_ACTION_TYPE
          ,TARGET_UI_DEF_ID
          ,TARGET_PERSISTENT_NODE_ID
          ,TARGET_NODE_PATH
          ,TARGET_PAGE_SET_ID
          ,TARGET_PAGE_ID
          ,TARGET_URL
          ,FRAME_NAME
          ,TARGET_ANCHOR
          ,DELETED_FLAG
          ,SEEDED_FLAG
          ,CX_COMMAND_NAME
          ,WINDOW_PARAMETERS
          ,TARGET_WINDOW_TYPE
          ,TARGET_WINDOW_NAME
          ,TARGET_EXPL_NODE_ID
          ,URL_PROPERTY_ID
          ,PROC_PAGE_TEMPL_UI_DEF_ID
          ,PAGE_TITLE_TEXT_ID
          ,MAIN_MESSAGE_TEXT_ID
          ,PROCESSING_CAPTION_TEXT_ID
          ,PROCESSING_PAGE_TEMPL_ID
--Processing page ER 9656558
       		,PROCESSING_PAGE_ENABLED_FLAG
          )
          VALUES(
          l_new_action_id
          ,p_target_ui_def_id
          ,0
          ,i.CONTEXT_COMPONENT_ID
          ,p_new_element_id
          ,i.RENDER_CONDITION_ID
          ,i.UI_ACTION_TYPE
          ,i.TARGET_UI_DEF_ID
          ,i.TARGET_PERSISTENT_NODE_ID
          ,i.TARGET_NODE_PATH
          ,i.TARGET_PAGE_SET_ID
          ,i.TARGET_PAGE_ID
          ,i.TARGET_URL
          ,i.FRAME_NAME
          ,i.TARGET_ANCHOR
          ,i.DELETED_FLAG
          ,'0'
          ,i.CX_COMMAND_NAME
          ,i.WINDOW_PARAMETERS
          ,i.TARGET_WINDOW_TYPE
          ,i.TARGET_WINDOW_NAME
          ,i.TARGET_EXPL_NODE_ID
          ,i.URL_PROPERTY_ID
          ,i.PROC_PAGE_TEMPL_UI_DEF_ID
          ,i.PAGE_TITLE_TEXT_ID
          ,i.MAIN_MESSAGE_TEXT_ID
          ,i.PROCESSING_CAPTION_TEXT_ID
          ,i.PROCESSING_PAGE_TEMPL_ID
          ,i.PROCESSING_PAGE_ENABLED_FLAG
          );

          set_User_Attribute(p_cz_attribute_name    => 'actionId',
                             p_cz_attribute_value   => TO_CHAR(l_new_action_id),
                             px_xml_attribute_value => px_user_attribute_value);

          IF p_source_template_id IS NOT NULL THEN
            l_counter := l_counter + 1;
            l_cached_elems_tbl(l_counter) := l_new_action_id;
            l_cached_source_elems_tbl(l_counter) := l_id;
          END IF;

          END LOOP;
        END IF;

        FOR i IN g_condition_attr_tbl.FIRST..g_condition_attr_tbl.LAST
        LOOP
          BEGIN
            l_id := TO_NUMBER(get_User_Attribute(px_user_attribute_value,g_condition_attr_tbl(i)));
          EXCEPTION
            WHEN OTHERS THEN
              l_id := NULL;
          END;
          IF l_id IS NOT NULL THEN
            copy_UI_Rule(l_id, l_new_rule_id,0 , 0, p_new_element_id,p_source_ui_def_id, p_xml_node => p_xml_node);
            IF p_source_template_id IS NOT NULL THEN
              l_counter := l_counter + 1;
              l_cached_elems_tbl(l_counter) := l_new_rule_id;
              l_cached_source_elems_tbl(l_counter) := l_id;
            END IF;

            set_User_Attribute(p_cz_attribute_name    => g_condition_attr_tbl(i),
                               p_cz_attribute_value   => TO_CHAR(l_new_rule_id),
                               px_xml_attribute_value => px_user_attribute_value);

          END IF;
        END LOOP;

        FOR i IN g_caption_attr_tbl.FIRST..g_caption_attr_tbl.LAST
        LOOP

          BEGIN
            l_id := TO_NUMBER(get_User_Attribute(px_user_attribute_value,g_caption_attr_tbl(i)));
          EXCEPTION
            WHEN OTHERS THEN
              l_id := NULL;
          END;

          IF l_id IS NOT NULL THEN

              l_new_intl_text_id := NULL;

              FOR k IN(SELECT * FROM CZ_LOCALIZED_TEXTS
                       WHERE intl_text_id=l_id AND seeded_flag=G_NO_FLAG
                              AND deleted_flag=G_NO_FLAG)
              LOOP
                IF l_new_intl_text_id IS NULL THEN
                  l_new_intl_text_id := allocateId('CZ_INTL_TEXTS_S');
                END IF;
                INSERT INTO CZ_LOCALIZED_TEXTS
                (
                LOCALE_ID
                ,LOCALIZED_STR
                ,INTL_TEXT_ID
                ,DELETED_FLAG
                ,EFF_FROM
                ,EFF_TO
                ,SECURITY_MASK
                ,EFF_MASK
                ,CHECKOUT_USER
                ,ORIG_SYS_REF
                ,LANGUAGE
                ,SOURCE_LANG
                ,UI_DEF_ID
                ,MODEL_ID
                ,SEEDED_FLAG
                ,UI_PAGE_ID
                ,UI_PAGE_ELEMENT_ID
                )
                VALUES(
                k.LOCALE_ID
                ,k.LOCALIZED_STR
                ,l_new_intl_text_id
                ,k.DELETED_FLAG
                ,k.EFF_FROM
                ,k.EFF_TO
                ,k.SECURITY_MASK
                ,k.EFF_MASK
                ,k.CHECKOUT_USER
                ,k.ORIG_SYS_REF
                ,k.LANGUAGE
                ,k.SOURCE_LANG
                ,p_target_ui_def_id
                ,NVL(k.model_id,0)
                ,'0'
                ,0
                ,p_new_element_id
                );

              END LOOP;

              IF l_new_intl_text_id IS NOT NULL THEN
                set_User_Attribute(p_cz_attribute_name    => g_caption_attr_tbl(i),
                                   p_cz_attribute_value   => TO_CHAR(l_new_intl_text_id),
                                   px_xml_attribute_value => px_user_attribute_value);

                IF p_source_template_id IS NOT NULL THEN
                  l_counter := l_counter + 1;
                  l_cached_elems_tbl(l_counter) := l_new_intl_text_id;
                  l_cached_source_elems_tbl(l_counter) := l_id;
                END IF;
              END IF;

          END IF;
        END LOOP;

    IF l_cached_elems_tbl.COUNT > 0 THEN
      FOR i IN l_cached_elems_tbl.FIRST..l_cached_elems_tbl.LAST
      LOOP
        INSERT INTO CZ_UI_TEMPLATE_ELEMENTS
        (
        TEMPLATE_ID
        ,UI_DEF_ID
        ,ELEMENT_TYPE
        ,ELEMENT_ID
        ,PERSISTENT_ELEMENT_ID
        ,DELETED_FLAG
        ,SEEDED_FLAG
        )
        SELECT
         p_target_template_id
        ,p_target_ui_def_id
        ,ELEMENT_TYPE
        ,l_cached_elems_tbl(i)
        ,l_cached_elems_tbl(i)
        ,G_NO_FLAG
        ,G_NO_FLAG
        FROM CZ_UI_TEMPLATE_ELEMENTS
        WHERE template_id=p_source_template_id AND
              ui_def_id=p_source_ui_def_id AND
              element_id=l_cached_source_elems_tbl(i) AND
              deleted_flag=G_NO_FLAG;
      END LOOP;
    END IF;

  END handle_Template_Attributes;

   PROCEDURE copy_Node_Related_Entities(p_ui_def_id         NUMBER,
                                       p_ui_page_id        NUMBER,
                                       p_xml_node          xmldom.DOMNode,
                                       p_target_ui_def_id  NUMBER DEFAULT NULL,
                                       p_source_ui_page_id        NUMBER DEFAULT NULL,
                                       p_source_ui_def_id        NUMBER DEFAULT NULL) IS

    l_user_attribute_value VARCHAR2(4000);
    l_element_id           VARCHAR2(255);
    l_target_ui_def_id     NUMBER;
    l_source_ui_page_id     NUMBER;
    l_source_ui_def_id      Number;

  BEGIN

    IF p_target_ui_def_id IS NULL THEN
      l_target_ui_def_id := p_ui_def_id;
    ELSE
      l_target_ui_def_id := p_target_ui_def_id;
    END IF;

    IF p_source_ui_def_id IS NULL THEN
      l_source_ui_def_id := p_ui_def_id;
    ELSE
      l_source_ui_def_id := p_source_ui_def_id;
    END IF;

    if p_source_ui_page_id IS NULL THEN
      l_source_ui_page_id := p_ui_page_id;
    ELSE
      l_source_ui_page_id := p_source_ui_page_id;
    END IF;

    l_element_id := get_Attribute_Value(p_xml_node, G_ID_ATTRIBUTE);

    l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);

    IF l_user_attribute_value IS NOT NULL THEN
      handle_User_Attributes
      (px_user_attribute_value => l_user_attribute_value,
       p_source_ui_def_id      => l_source_ui_def_id,
       p_source_ui_page_id     => l_source_ui_page_id,
       p_target_ui_def_id      => l_target_ui_def_id,
       p_target_ui_page_id     => p_ui_page_id,
       p_new_element_id        => l_element_id,
       p_xml_node              => p_xml_node);

       set_Attribute(p_xml_node,
                     G_USER_ATTRIBUTE3_NAME,
                     l_user_attribute_value);
    END IF;

  END copy_Node_Related_Entities;


  PROCEDURE handle_UI_CASE_Id(p_xml_node xmldom.DOMNode) IS
    l_user_attribute4  VARCHAR2(4000);
  BEGIN
    IF xmldom.getNodeName(p_xml_node)='ui:case' THEN

      l_user_attribute4 := get_Attribute_Value(p_xml_node,
                                               G_USER_ATTRIBUTE4_NAME);
      IF l_user_attribute4 IS NOT NULL THEN
        set_User_Attribute(p_cz_attribute_name    => 'caseId',
                           p_cz_attribute_value   => get_Element_Id(),
                           px_xml_attribute_value => l_user_attribute4);

        set_Attribute(p_xml_node,G_USER_ATTRIBUTE4_NAME,l_user_attribute4);

      END IF;
    END IF;
  END handle_UI_CASE_Id;

   PROCEDURE handle_USER_ATTRIBUTE10
   (p_xml_root_node xmldom.DOMNode,
    p_ui_def_id     NUMBER,
    p_ui_page_id    NUMBER,
    p_ui_element_id VARCHAR2) IS

     l_user_attribute3_value  VARCHAR2(4000);
     l_user_attribute10_value VARCHAR2(4000);
     l_refenabledCondnId      VARCHAR2(255);
     l_refenabledCondnComp    VARCHAR2(255);
     l_refenabledCondnValue   VARCHAR2(255);
     l_new_refenabledCondnId  NUMBER;
     l_refdisplayCondnId      VARCHAR2(255);
     l_refdisplayCondnComp    VARCHAR2(255);
     l_refdisplayCondnValue   VARCHAR2(255);
     l_new_refdisplayCondnId  NUMBER;

   BEGIN

     l_user_attribute3_value := get_Attribute_Value(p_xml_root_node,
                                                    G_USER_ATTRIBUTE3_NAME);

     IF INSTR(l_user_attribute3_value,'enabledCondnId=')=0 THEN

       l_user_attribute10_value := get_Attribute_Value(p_xml_root_node, G_USER_ATTRIBUTE10_NAME);

       IF INSTR(l_user_attribute10_value,'refenabledCondnId')>0 THEN
         l_refenabledCondnId    := get_User_Attribute(l_user_attribute10_value, 'refenabledCondnId');
         l_refenabledCondnComp  := get_User_Attribute(l_user_attribute10_value, 'refenabledCondnComp');
         l_refenabledCondnValue := get_User_Attribute(l_user_attribute10_value, 'refenabledCondnValue');

         copy_UI_Rule(p_rule_id       => TO_NUMBER(l_refenabledCondnId),
                      x_rule_id       => l_new_refenabledCondnId,
                      p_ui_def_id     => p_ui_def_id,
                      p_ui_page_id    => p_ui_page_id,
                      p_ui_element_id => p_ui_element_id,
                      p_source_ui_def_id => p_ui_def_id);

         l_user_attribute3_value := l_user_attribute3_value||'|enabledCondnId='||TO_CHAR(l_new_refenabledCondnId)||
             '|enabledCondnComp=' || l_refenabledCondnComp || '|enabledCondnValue='||l_refenabledCondnValue;

         xmldom.removeAttribute(xmldom.makeElement(p_xml_root_node), G_USER_ATTRIBUTE10_NAME);
         set_Attribute(p_xml_root_node,G_USER_ATTRIBUTE3_NAME,l_user_attribute3_value);

       END IF;  -- end of IF INSTR(l_user_attribute10_value,'refenabledCondnId')>0

     END IF; -- end of IF INSTR(l_user_attribute3_value,'enabledCondnId=')=0

     IF INSTR(l_user_attribute3_value,'displayCondnId=')=0 THEN
       IF INSTR(l_user_attribute10_value,'refdisplayCondnId')>0 THEN
         l_refdisplayCondnId    := get_User_Attribute(l_user_attribute10_value, 'refdisplayCondnId');
         l_refdisplayCondnComp  := get_User_Attribute(l_user_attribute10_value, 'refdisplayCondnComp');
         l_refdisplayCondnValue := get_User_Attribute(l_user_attribute10_value, 'refdisplayCondnValue');


         copy_UI_Rule(p_rule_id          => TO_NUMBER(l_refdisplayCondnId),
                      x_rule_id          => l_new_refdisplayCondnId,
                      p_ui_def_id        => p_ui_def_id,
                      p_ui_page_id       => p_ui_page_id,
                      p_ui_element_id    => p_ui_element_id,
                      p_source_ui_def_id => p_ui_def_id);

         l_user_attribute3_value := l_user_attribute3_value||'|displayCondnId='||TO_CHAR(l_new_refdisplayCondnId)||
           '|displayCondnComp=' || l_refdisplayCondnComp || '|displayCondnValue='||l_refdisplayCondnValue;
         xmldom.removeAttribute(xmldom.makeElement(p_xml_root_node), G_USER_ATTRIBUTE10_NAME);
         set_Attribute(p_xml_root_node,G_USER_ATTRIBUTE3_NAME,l_user_attribute3_value);

       END IF;  -- end of IF INSTR(l_user_attribute10_value,'refdisplayCondnId')>0

     END IF; -- end of IF INSTR(l_user_attribute10_value,'refdisplayCondnId')>0

  END handle_USER_ATTRIBUTE10;

  PROCEDURE create_wrapper_table_layout(x_xml_table_node          OUT NOCOPY xmldom.DOMNode,
                                        x_xml_tabuicontent_node   OUT NOCOPY xmldom.DOMNode,
                                        p_target_subtree_xml_node xmldom.DOMNode) IS

    l_doc                   xmldom.DOMDocument;
    l_xml_table_node        xmldom.DOMNode;

  BEGIN
    l_doc := parse_JRAD_Document(G_TABLELAYOUT_TEMPLATE);

    l_xml_table_node :=xmldom.makeNode(xmldom.getDocumentElement(l_doc));

    remove_TopLevel_Attributes(l_xml_table_node);

    --x_xml_table_node := xmldom.cloneNode(l_xml_table_node,TRUE);
    x_xml_table_node := cloneNode(l_xml_table_node, p_target_subtree_xml_node);

    set_Attribute(xmldom.makeElement(x_xml_table_node),G_ID_ATTRIBUTE,get_Element_Id());
    set_Attribute(xmldom.makeElement(x_xml_table_node),G_USER_ATTRIBUTE5_NAME,'TABLELAYOUT_FOR_UI_GEN');

    x_xml_tabuicontent_node := getUIContents(x_xml_table_node);

  END create_wrapper_table_layout;

  FUNCTION insert_before(p_parent_xml_node  IN xmldom.DOMNode,
                         p_new_xml_node     IN xmldom.DOMNode,
             p_ref_xml_node     IN xmldom.DOMNode)
    RETURN xmldom.DOMNode IS
  l_new_xml_node xmldom.DOMNode;
  BEGIN

    IF xmldom.isNull(p_ref_xml_node) THEN
      l_new_xml_node := xmldom.appendChild(p_parent_xml_node, p_new_xml_node);
    ELSE
    l_new_xml_node := xmldom.insertBefore(p_parent_xml_node, p_new_xml_node, p_ref_xml_node);
  END IF;

    return l_new_xml_node;
  END insert_before;

  FUNCTION insert_node(p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                       p_new_xml_node        IN xmldom.DOMNode,
                       p_parent_xml_node     IN xmldom.DOMNode)
   RETURN xmldom.DOMNode IS

  l_node                  CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_doc                   xmldom.DOMDocument;
    l_anchor_doc            xmldom.DOMDocument;
    l_subtree_doc           xmldom.DOMDocument;
    l_xml_root_node         xmldom.DOMNode;
    l_new_xml_root_node     xmldom.DOMNode;
    l_out_xml_node          xmldom.DOMNode;
    l_xml_table_node        xmldom.DOMNode;
    l_new_xml_table_node    xmldom.DOMNode;
    l_xml_anchor_node       xmldom.DOMNode;
    l_new_xml_anchor_node   xmldom.DOMNode;
    l_xml_node              xmldom.DOMNode;
    l_xml_tabuicontent_node xmldom.DOMNode;
    l_ui_contents_xml_node  xmldom.DOMNode;
    l_prev_node             xmldom.DOMNode;
    l_next_node             xmldom.DOMNode;
    l_prev_node_parent      xmldom.DOMNode;
    l_next_node_parent      xmldom.DOMNode;
    l_prev_node_parent_ui_cnt    xmldom.DOMNode;
    l_next_node_parent_ui_cnt    xmldom.DOMNode;
    l_grand_parent          xmldom.DOMNode;
    l_next_sibling_of_parent xmldom.DOMNode;
    l_child_nodes_tbl       xmldom.DOMNodeList;
    l_attribute_value       VARCHAR2(4000);
    l_attribute_source      VARCHAR2(4000);
    l_user_attribute        VARCHAR2(4000);
    l_user_attribute4       VARCHAR2(4000);
    l_prev_element_id       VARCHAR2(255);
    l_next_element_id       VARCHAR2(255);
    l_prev_element_template_id NUMBER;
    l_next_element_template_id NUMBER;
    l_prev_elt_lyt_ui_style VARCHAR2(1);
    l_next_elt_lyt_ui_style VARCHAR2(1);
    l_lyt_ui_style          VARCHAR2(1);
    l_old_ui_element_id     VARCHAR2(255);
    l_new_ui_element_id     VARCHAR2(255);
    l_switcher_element_id   VARCHAR2(255);
    l_user_attribute3_value VARCHAR2(4000);
    l_switcher_casename     VARCHAR2(255);
    l_length                NUMBER;
    l_ui_action_id          NUMBER;
    l_element_signature_id  NUMBER;
    l_wrap_it               BOOLEAN;
    l_drilldown_text_id     NUMBER;
    l_wrap_with_links       BOOLEAN := FALSE;
    l_template_is_used_by_ref BOOLEAN := TRUE;

  BEGIN


    l_node := get_Model_Node_By_Persist_Id(p_ui_node.persistent_node_id,g_UI_Context.devl_project_id);
    l_new_xml_root_node := p_new_xml_node;

  --DEBUG('asp:insert_node ' || l_node.name);

    BEGIN

      SELECT element_id, ctrl_template_id INTO l_prev_element_id, l_prev_element_template_id
      FROM CZ_UI_PAGE_ELEMENTS
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            page_id = p_ui_node.page_id AND
            parent_element_id = p_ui_node.parent_element_id AND
            deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG) AND
            seq_nbr = (SELECT max(seq_nbr)
                       FROM CZ_UI_PAGE_ELEMENTS
                       WHERE ui_def_id=p_ui_node.ui_def_id AND
                             page_id = p_ui_node.page_id AND
                             parent_element_id = p_ui_node.parent_element_id AND
                             seq_nbr<p_ui_node.seq_nbr AND
                             deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG) AND
                             NOT (element_type = G_UI_DRILLDOWN_NODE_TYPE AND
                                  ctrl_template_id IS NULL) AND
                             NOT (element_signature_id IS NULL AND ctrl_template_id IS NULL))
            AND rownum < 2;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
    END;

    --DEBUG('asp:Here 1');

    BEGIN
      SELECT element_id, ctrl_template_id INTO l_next_element_id, l_next_element_template_id
      FROM CZ_UI_PAGE_ELEMENTS
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            page_id = p_ui_node.page_id AND
            parent_element_id = p_ui_node.parent_element_id AND
            deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG, G_MARK_TO_DELETE) AND
            seq_nbr = ( SELECT min(seq_nbr)
                        FROM CZ_UI_PAGE_ELEMENTS
                        WHERE ui_def_id=p_ui_node.ui_def_id AND
                              page_id = p_ui_node.page_id AND
                              parent_element_id = p_ui_node.parent_element_id AND
                              seq_nbr>p_ui_node.seq_nbr AND
                              deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG, G_MARK_TO_DELETE, G_MARK_TO_ADD, G_MARK_TO_MOVE) AND
                              NOT (element_type = G_UI_DRILLDOWN_NODE_TYPE AND
                                   ctrl_template_id IS NULL) AND
                              NOT (element_signature_id IS NULL AND ctrl_template_id IS NULL))
            AND rownum < 2;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
    END;

    --DEBUG('Here 2');

  IF l_prev_element_id IS NOT NULL THEN
    l_prev_node := g_dom_elements_tbl(TO_NUMBER(l_prev_element_id));

    l_prev_node_parent_ui_cnt := xmldom.getParentNode(l_prev_node);
    l_prev_node_parent := xmldom.getParentNode(l_prev_node_parent_ui_cnt);
    BEGIN
        SELECT layout_ui_style INTO l_prev_elt_lyt_ui_style
      FROM CZ_UI_TEMPLATES
      WHERE template_id = l_prev_element_template_id
      AND ui_def_id = 0
    AND deleted_flag = G_NO_FLAG;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL;
    END;
  END IF;

  --DEBUG('Here 3');

  IF l_next_element_id IS NOT NULL THEN
    l_next_node := g_dom_elements_tbl(TO_NUMBER(l_next_element_id));
    l_next_node_parent_ui_cnt := xmldom.getParentNode(l_next_node);
    l_next_node_parent := xmldom.getParentNode(l_next_node_parent_ui_cnt);
    BEGIN
        SELECT layout_ui_style INTO l_next_elt_lyt_ui_style
      FROM CZ_UI_TEMPLATES
      WHERE template_id = l_next_element_template_id
      AND ui_def_id = 0
    AND deleted_flag = G_NO_FLAG;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL;
    END;
  END IF;

  --DEBUG('Here 4');

  IF p_ui_node.ctrl_template_id IS NOT NULL THEN

    SELECT layout_ui_style INTO l_lyt_ui_style
  FROM CZ_UI_TEMPLATES
  WHERE template_id = p_ui_node.ctrl_template_id
    AND ui_def_id = 0
    AND deleted_flag = G_NO_FLAG;

    IF l_lyt_ui_style = G_LABEL_PAIR_LAYOUT_STYLE THEN
      l_wrap_it := TRUE;
  ELSE
    l_wrap_it := FALSE;
    END IF;
  END IF;

  --DEBUG('Here 5');

  IF l_prev_element_id IS NOT NULL
        OR l_next_element_id IS NOT NULL THEN
      IF l_wrap_it THEN
        IF l_prev_element_id IS NOT NULL AND
          NVL(l_prev_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE THEN
            l_next_node := xmldom.getNextSibling(l_prev_node);
        l_new_xml_root_node := insert_before(l_prev_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSIF l_next_element_id IS NOT NULL AND
             NVL(l_next_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE THEN
          l_new_xml_root_node := insert_before(l_next_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSE
          create_wrapper_table_layout(l_xml_table_node, l_xml_tabuicontent_node, p_parent_xml_node);
          l_new_xml_root_node := xmldom.appendChild(l_xml_tabuicontent_node, l_new_xml_root_node);
          IF l_prev_element_id IS NOT NULL THEN
            l_next_node := xmldom.getNextSibling(l_prev_node);
            l_xml_table_node := insert_before(l_prev_node_parent_ui_cnt, l_xml_table_node, l_next_node);
          ELSIF l_next_element_id IS NOT NULL THEN
            l_xml_table_node := insert_before(l_next_node_parent_ui_cnt, l_xml_table_node, l_next_node);
          ELSE
            l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
            l_xml_table_node := xmldom.appendChild(l_ui_contents_xml_node, l_xml_table_node);
          END IF;
        END IF;
      ELSE -- new element is not LABEL_DATA_PAIR

        IF l_prev_element_id IS NOT NULL AND l_next_element_id IS NOT NULL AND
        NVL(l_prev_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE AND
      NVL(l_next_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE THEN


          IF get_Attribute_Value(l_prev_node_parent, G_ID_ATTRIBUTE) = get_Attribute_Value(l_next_node_parent, G_ID_ATTRIBUTE) THEN
            IF xmldom.getNodeName(l_prev_node_parent) = 'oa:tableLayout' THEN
              l_grand_parent := xmldom.getParentNode(l_prev_node_parent);
              create_wrapper_table_layout(l_xml_table_node, l_xml_tabuicontent_node,  p_parent_xml_node);
              l_next_sibling_of_parent := xmldom.getNextSibling(l_prev_node_parent);
              l_xml_table_node := insert_before(l_grand_parent, l_xml_table_node, l_next_sibling_of_parent);
              l_next_node := xmldom.removeChild(l_prev_node_parent_ui_cnt, l_next_node);
              l_next_node := xmldom.appendChild(l_xml_tabuicontent_node, l_next_node);
              l_next_node := l_xml_table_node;
            END IF;
            l_next_node := xmldom.insertBefore(l_grand_parent, l_new_xml_root_node, l_next_node);
          ELSE
            l_grand_parent := xmldom.getParentNode(l_prev_node_parent);
            l_next_sibling_of_parent := xmldom.getNextSibling(l_prev_node_parent);
            l_new_xml_root_node := insert_before(l_grand_parent, l_new_xml_root_node, l_next_sibling_of_parent);
          END IF;
        ELSIF l_prev_element_id IS NOT NULL AND NVL(l_prev_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) <> G_LABEL_PAIR_LAYOUT_STYLE THEN
          l_next_node := xmldom.getNextSibling(l_prev_node);
          l_new_xml_root_node := insert_before(l_prev_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSIF l_next_element_id IS NOT NULL AND
          NVL(l_next_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) <> G_LABEL_PAIR_LAYOUT_STYLE THEN
          l_new_xml_root_node := insert_before(l_next_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSIF l_prev_element_id IS NOT NULL THEN
          l_grand_parent := xmldom.getParentNode(l_prev_node_parent);
          l_next_sibling_of_parent := xmldom.getNextSibling(l_prev_node_parent);
          l_new_xml_root_node := insert_before(l_grand_parent, l_new_xml_root_node, l_next_sibling_of_parent);
        ELSE
          l_grand_parent := xmldom.getParentNode(l_next_node_parent);
          l_new_xml_root_node := insert_before(l_grand_parent, l_new_xml_root_node, l_next_node_parent);
    END IF;
      END IF;
  ELSE
    -- If neither prev_element and next_element is found
    -- Insert at the end
      --DEBUG('asp:Append at the end');

   IF l_wrap_it THEN
       l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
       create_wrapper_table_layout(l_xml_table_node, l_xml_tabuicontent_node, p_parent_xml_node);
       l_xml_table_node := xmldom.appendChild(l_ui_contents_xml_node, l_xml_table_node);
       l_new_xml_root_node := xmldom.appendChild(l_xml_tabuicontent_node, l_new_xml_root_node);
     ELSE
       l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
       l_new_xml_root_node := xmldom.appendChild(l_ui_contents_xml_node, l_new_xml_root_node);
     END IF;
  END IF;

  g_dom_elements_tbl(TO_NUMBER(p_ui_node.element_id)) := l_new_xml_root_node;
  RETURN l_new_xml_root_node;

  END insert_node;

  FUNCTION pluck_XML_node(p_jrad_doc    CZ_UI_TEMPLATES.jrad_doc%TYPE,
                          p_page_id     NUMBER,
                          p_element_id  VARCHAR2)
    RETURN xmldom.DOMNode IS

  l_xml_node_to_pluck  xmldom.DOMNode;
  l_parent_xml_node    xmldom.DOMNode;
  l_subtree_doc        xmldom.DOMDocument;
  l_element_id         NUMBER;

  BEGIN

    l_element_id := TO_NUMBER(p_element_id);

    IF g_dom_elements_to_move.EXISTS(l_element_id) THEN
      l_xml_node_to_pluck := g_dom_elements_to_move(l_element_id);

    ELSE
      l_subtree_doc := parse_JRAD_Document(p_jrad_doc);

      l_xml_node_to_pluck := find_XML_Node_By_Attribute(l_subtree_doc,
                                                        G_ID_ATTRIBUTE,
                                                        p_element_id,
                                                        G_NO_FLAG);

      l_parent_xml_node := xmldom.getParentNode(l_xml_node_to_pluck);

      l_xml_node_to_pluck := xmldom.removeChild(l_parent_xml_node, l_xml_node_to_pluck);

      Save_Document(l_subtree_doc, p_jrad_doc);
    END IF;

    RETURN l_xml_node_to_pluck;

  END pluck_XML_node;


  FUNCTION move_XML_Node(p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                         p_parent_xml_node     xmldom.DOMNode)
  RETURN xmldom.DOMNode IS

  l_src_page_id        NUMBER;
  l_xml_node_to_move   xmldom.DOMNode;
    l_jrad_doc           CZ_UI_TEMPLATES.jrad_doc%TYPE;
  l_counter            NUMBER;
  l_element_ids_tbl    varchar2_tbl_type;
  l_id                 VARCHAR2(255);
  l_component_id       NUMBER;
  l_old_component_id   NUMBER;

  BEGIN

  l_src_page_id := g_tgt_pg_to_src_pg_map(p_ui_node.page_id)(TO_NUMBER(p_ui_node.element_id));

  SELECT jrad_doc INTO l_jrad_doc
    FROM CZ_UI_PAGES
    WHERE ui_def_id= g_UI_Context.ui_def_id AND
          page_id=l_src_page_id;

  l_xml_node_to_move := pluck_XML_node(l_jrad_doc, l_src_page_id, p_ui_node.element_id);
  l_xml_node_to_move := cloneNode(l_xml_node_to_move, p_parent_xml_node);

  l_counter := -1;
  resolve_view_names(l_xml_node_to_move, p_ui_node.page_id, l_counter, l_element_ids_tbl);


  SELECT ps_node_id INTO l_component_id
    FROM CZ_PS_NODES
   WHERE devl_project_id = g_UI_Context.devl_project_id
     AND persistent_node_Id = p_ui_node.pagebase_persistent_node_id;

  SELECT ps_node_id INTO l_old_component_id
    FROM CZ_PS_NODES
   WHERE devl_project_id = g_UI_Context.devl_project_id
     AND persistent_node_id = (SELECT persistent_node_id
                                 FROM CZ_UI_PAGES
                                WHERE ui_def_id = g_UI_Context.ui_Def_id
                                  AND page_id = l_src_page_id);



  FOR i in (SELECT rule_id, ui_page_element_id
              FROM CZ_RULES
             WHERE devl_project_id = g_UI_Context.devl_project_id
               AND ui_def_id = g_UI_Context.ui_def_id
               AND ui_page_id = l_src_page_id
               AND component_id = l_old_component_id
               AND deleted_flag = G_NO_FLAG)
  LOOP
    DEBUG('asp: Found rule ' || i.rule_id || ', for element ' || i.ui_page_element_Id);
    IF l_element_ids_tbl.EXISTS(i.ui_page_element_id) THEN
      DEBUG('asp: Updating rule ' || i.rule_id || ' for element_id ' || i.ui_page_element_id);
      UPDATE CZ_RULES
         SET component_id = l_component_id,
             ui_page_id = p_ui_node.page_id
       WHERE devl_project_id = g_UI_Context.devl_project_id
         AND rule_id = i.rule_id;
    END IF;
  END LOOP;

  FOR i in (SELECT intl_text_id, ui_page_element_id
              FROM CZ_INTL_TEXTS
             WHERE model_id = g_UI_Context.devl_project_id
               AND ui_def_id = g_UI_Context.ui_def_id
               AND ui_page_id = l_src_page_id
               AND deleted_flag = G_NO_FLAG)
  LOOP
    IF l_element_ids_tbl.EXISTS(i.ui_page_element_id) THEN
      DEBUG('asp: Updating intl_text ' || i.intl_text_id || ' for element_id ' || i.ui_page_element_id);
      UPDATE CZ_LOCALIZED_TEXTS
         SET ui_page_id = p_ui_node.page_id
       WHERE intl_text_id = i.intl_text_id;
    END IF;
  END LOOP;
  l_xml_node_to_move := insert_node(p_ui_node, l_xml_node_to_move, p_parent_xml_node);

  RETURN l_xml_node_to_move;

  END move_XML_Node;

  --
  -- replace numeric suffix at the end of p_jrad_id with p_root_jrad_id
  -- if there is no numeric suffix then it just adds '_'||p_root_jrad_id to p_jrad_id
  -- Ex. : if  p_jrad_id="_czabcd_100" and p_root_jrad_id="12345"
  -- then function will return "_czabcd_12345"
  --
  FUNCTION handle_JRAD_Id(p_jrad_id      IN VARCHAR2,
                          p_root_jrad_id IN VARCHAR2) RETURN VARCHAR2 IS
    l_ind      NUMBER;
    l_num      NUMBER;
    l_jrad_id  VARCHAR2(4000);
    l_next_str VARCHAR2(4000);
  BEGIN
    l_jrad_id := p_jrad_id;
    l_ind := INSTR(l_jrad_id,'_');
    LOOP
      l_next_str := SUBSTR(l_jrad_id,l_ind+1);
      l_ind := INSTR(l_next_str,'_');
      IF l_ind=0 THEN
        BEGIN
          l_num     := TO_NUMBER(l_next_str);
          l_jrad_id := REPLACE(p_jrad_id,l_next_str,p_root_jrad_id);
          RETURN l_jrad_id;
        EXCEPTION
          WHEN OTHERS THEN
            RETURN p_jrad_id||'_'||p_root_jrad_id;
        END;
      ELSE
        l_jrad_id:= l_next_str;
      END IF;
    END LOOP;
  END handle_JRAD_Id;

  FUNCTION create_UIXML_Element_new(p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                    p_parent_xml_node     xmldom.DOMNode)
    RETURN xmldom.DOMNode IS

    l_node                       CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_ctrl_template_name         CZ_UI_TEMPLATES.template_name%TYPE;
    l_doc                        xmldom.DOMDocument;
    l_anchor_doc                 xmldom.DOMDocument;
    l_subtree_doc                xmldom.DOMDocument;
    l_xml_root_node              xmldom.DOMNode;
    l_new_xml_root_node          xmldom.DOMNode;
    l_out_xml_node               xmldom.DOMNode;
    l_xml_table_node             xmldom.DOMNode;
    l_new_xml_table_node         xmldom.DOMNode;
    l_xml_anchor_node            xmldom.DOMNode;
    l_new_xml_anchor_node        xmldom.DOMNode;
    l_xml_node                   xmldom.DOMNode;
    l_xml_tabuicontent_node      xmldom.DOMNode;
    l_ui_contents_xml_node       xmldom.DOMNode;
    l_prev_node                  xmldom.DOMNode;
    l_next_node                  xmldom.DOMNode;
    l_prev_node_parent           xmldom.DOMNode;
    l_next_node_parent           xmldom.DOMNode;
    l_prev_node_parent_ui_cnt    xmldom.DOMNode;
    l_next_node_parent_ui_cnt    xmldom.DOMNode;
    l_grand_parent               xmldom.DOMNode;
    l_next_sibling_of_parent     xmldom.DOMNode;

    l_curr_parent_xml_node  xmldom.DOMNode;
    l_xml_node_name         VARCHAR2(255);
    l_new_attribute_value   VARCHAR2(255);

    l_child_nodes_tbl            xmldom.DOMNodeList;
    l_attribute_value            VARCHAR2(4000);
    l_attribute_source           VARCHAR2(4000);
    l_user_attribute             VARCHAR2(4000);
    l_user_attribute4            VARCHAR2(4000);
    l_prev_element_id            VARCHAR2(255);
    l_next_element_id            VARCHAR2(255);
    l_jrad_doc                   VARCHAR2(255);
    l_ancestor_node              VARCHAR2(255);
    l_hgrid_element_id           VARCHAR2(255);
    l_old_switcher_xml_id        VARCHAR2(255);
    l_prev_element_template_id   NUMBER;
    l_next_element_template_id   NUMBER;
    l_prev_elt_lyt_ui_style      VARCHAR2(1);
    l_next_elt_lyt_ui_style      VARCHAR2(1);
    l_old_ui_element_id          VARCHAR2(255);
    l_new_ui_element_id          VARCHAR2(255);
    l_switcher_element_id        VARCHAR2(255);
    l_user_attribute3_value      VARCHAR2(4000);
    l_switcher_casename          VARCHAR2(255);
    l_switcher_xml_id            VARCHAR2(255);
    l_uicase_name                VARCHAR2(255);
    l_length                     NUMBER;
    l_ui_action_id               NUMBER;
    l_element_signature_id       NUMBER;
    l_wrap_it                    BOOLEAN;
    l_drilldown_text_id          NUMBER;
    l_wrap_with_links            BOOLEAN := FALSE;
    l_template_is_used_by_ref    BOOLEAN := TRUE;

  BEGIN
    --DEBUG('asp:Create UI XML Element new started...');
    IF p_ui_node.ctrl_template_id IS NULL THEN
      RETURN l_xml_node;
    END IF;

    l_node := get_Model_Node_By_Persist_Id(p_ui_node.persistent_node_id,g_UI_Context.devl_project_id);

    --DEBUG('asp:Create_ui_xml_new ' || l_node.name || ', element_id ' || p_ui_node.element_id);

    l_template_is_used_by_ref := is_Used_By_Reference(l_node.detailed_type_id,p_ui_node.ctrl_template_id);

    BEGIN
      SELECT element_id, ctrl_template_id INTO l_prev_element_id, l_prev_element_template_id
      FROM CZ_UI_PAGE_ELEMENTS
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            page_id = p_ui_node.page_id AND
            parent_element_id = p_ui_node.parent_element_id AND
            deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG) AND
--jonatara:bug fix7307460
     	    NOT (element_type = G_UI_DRILLDOWN_NODE_TYPE AND ctrl_template_id IS NULL) AND
     	    NOT (element_signature_id IS NULL AND ctrl_template_id IS NULL ) AND
            seq_nbr = (SELECT max(seq_nbr)
                       FROM CZ_UI_PAGE_ELEMENTS
                       WHERE ui_def_id=p_ui_node.ui_def_id AND
                             page_id = p_ui_node.page_id AND
                             parent_element_id = p_ui_node.parent_element_id AND
                             seq_nbr<p_ui_node.seq_nbr AND
                             deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG) AND
                             NOT (element_type = G_UI_DRILLDOWN_NODE_TYPE AND
                                  ctrl_template_id IS NULL) AND
                             NOT (element_signature_id IS NULL AND ctrl_template_id IS NULL))
            AND rownum < 2;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
    END;

    BEGIN

      SELECT element_id, ctrl_template_id INTO l_next_element_id, l_next_element_template_id
      FROM CZ_UI_PAGE_ELEMENTS
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            page_id = p_ui_node.page_id AND
            parent_element_id = p_ui_node.parent_element_id AND
            deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG, G_MARK_TO_DELETE) AND
--jonatara:bug fix7307460
	    NOT (element_type = G_UI_DRILLDOWN_NODE_TYPE AND ctrl_template_id IS NULL) AND
	    NOT (element_signature_id IS NULL AND ctrl_template_id IS NULL) AND
            seq_nbr = ( SELECT min(seq_nbr)
                        FROM CZ_UI_PAGE_ELEMENTS
                        WHERE ui_def_id=p_ui_node.ui_def_id AND
                              page_id = p_ui_node.page_id AND
                              parent_element_id = p_ui_node.parent_element_id AND
                              seq_nbr>p_ui_node.seq_nbr AND
                              deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG, G_MARK_TO_DELETE, G_MARK_TO_ADD, G_MARK_TO_MOVE) AND
                              NOT (element_type = G_UI_DRILLDOWN_NODE_TYPE AND
                                   ctrl_template_id IS NULL) AND
                              NOT (element_signature_id IS NULL AND ctrl_template_id IS NULL))
            AND rownum < 2;


    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
    END;


  -- Now lets get the new element ready for insertion. Once the new node
  -- is ready, we will insert it int he appropriate place

    --
    -- drilldowns will be handled by special way ( bug #3271034 )
    --
    IF p_ui_node.ctrl_template_id IN(G_DRILLDOWN_BUTTON_TEMPLATE_ID,G_DRILLDOWN_IMAGE_TEMPLATE_ID,
       G_DRILLDOWN_LABEL_TEMPLATE_ID) THEN
       IF g_UI_Context.DRILLDOWN_IMAGE_URL IS NOT NULL THEN
         l_ctrl_template_name := get_JRAD_Name(p_template_id => G_DRILLDOWN_IMAGE_TEMPLATE_ID);
       ELSE
         l_ctrl_template_name := get_JRAD_Name(p_template_id => p_ui_node.ctrl_template_id);
       END IF;
    ELSE
       l_ctrl_template_name := get_JRAD_Name(p_template_id => p_ui_node.ctrl_template_id);
    END IF;

    --
    -- parse document(template) which is going to be nested element
    --
    l_subtree_doc := parse_JRAD_Document(l_ctrl_template_name);

    IF xmldom.isNull(l_subtree_doc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_ctrl_template_name,
                        p_fatal_error  => TRUE);

       RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- get subdocument's root node
    --
    l_xml_root_node := xmldom.makeNode(xmldom.getDocumentElement(l_subtree_doc));

    --
    -- remove common attributes of container and subtree
    --
    remove_TopLevel_Attributes(l_xml_root_node);

    IF l_template_is_used_by_ref THEN
      l_element_signature_id := 6011;
    ELSE
      l_element_signature_id := p_ui_node.element_signature_id;
    END IF;


    --
    -- set Attributes for this subtree = Template
    --
    set_Template_Attributes(p_xml_root_node        => l_xml_root_node,
                            p_ui_node              => p_ui_node,
                            p_element_signature_id => l_element_signature_id);

    --
    -- set a special attribute "blockSize" if it is Table control
    --
    /* commented out according to request from 8/12/2004
    IF  xmldom.getNodeName(l_xml_root_node) IN('oa:table') THEN
      set_Attribute(l_xml_root_node,
                    'blockSize',
                    TO_CHAR(g_UI_Context.ROWS_PER_TABLE));
    END IF;
    */

    --DEBUG('Here 7');
    IF l_template_is_used_by_ref THEN

      --
      -- returns cloned DOM subtree
      --
      --l_new_xml_root_node := xmldom.cloneNode(l_xml_root_node,TRUE);
      l_new_xml_root_node := cloneNode(l_xml_root_node, p_parent_xml_node);

      --DEBUG('asp:Adding ' || p_ui_node.element_id || ' to table');
      g_dom_elements_tbl(TO_NUMBER(p_ui_node.element_id)) := l_new_xml_root_node;
      --
      -- remove non user attributes from top tag
      --
      remove_Non_User_Attributes(l_new_xml_root_node);

      --
      -- set "extends" attribute
      --
      xmldom.setAttribute(xmldom.makeElement(l_new_xml_root_node),'extends',l_ctrl_template_name);

      --
      -- remove content of template subtree
      --
      l_child_nodes_tbl:=xmldom.getChildNodes(l_new_xml_root_node);

      --
      -- we need to get length of array of child nodes
      -- to go through the array in loop
      --
      l_length := xmldom.getLength(l_child_nodes_tbl);
      FOR k IN 0..l_length-1
      LOOP
        --
        -- get next child DOM node
        --
        l_xml_node := xmldom.item(l_child_nodes_tbl, k);
        l_out_xml_node:=xmldom.removeChild(l_new_xml_root_node,l_xml_node);
      END LOOP;

    ELSE -- use UI Template by Copy

      l_child_nodes_tbl := xmldom.getElementsByTagName(l_subtree_doc, '*');

      l_length := xmldom.getLength(l_child_nodes_tbl);
      IF (l_length > 0) THEN
        FOR k IN 0..l_length-1
        LOOP
          --
          -- get next child DOM node
          --
          l_xml_node := xmldom.item(l_child_nodes_tbl, k);

          l_curr_parent_xml_node := xmldom.getParentNode(l_xml_node);

          IF k > 0 THEN
            l_attribute_value := get_Attribute_Value(l_xml_node, G_ID_ATTRIBUTE);

            l_xml_node_name := xmldom.getNodeName(l_xml_node);

            IF l_attribute_value IS NOT NULL THEN
              l_new_attribute_value := handle_JRAD_Id(l_attribute_value,p_ui_node.element_id);
              l_new_attribute_value := REPLACE(REPLACE(l_new_attribute_value,'_czt','_czn'), '_czc','_czn');
              set_Attribute(xmldom.makeElement(l_xml_node),G_ID_ATTRIBUTE, l_new_attribute_value);
            END IF;

            l_ancestor_node := get_Attribute_Value(l_xml_node,
                                                   'ancestorNode');
            IF l_ancestor_node IS NOT NULL THEN

              SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_PAGES
              WHERE page_id=p_ui_node.page_id AND ui_def_id=p_ui_node.ui_def_id;

              l_hgrid_element_id := find_Element_Id_Of_XMLTag(l_xml_node, 'oa:tree');
              IF NOT(xmldom.IsNull(l_xml_node)) THEN
                l_ancestor_node := l_jrad_doc||'.'||l_hgrid_element_id;

                set_Attribute(l_xml_node,
                              'ancestorNode',
                              l_ancestor_node);
              END IF;
            END IF;

            --
            -- set value of user attribute "switcherDefaultCaseName" to new jrad id of <oa:switcher>
            --
            IF xmldom.getNodeName(l_xml_node)='oa:switcher' THEN
              l_old_switcher_xml_id := l_attribute_value;
              l_user_attribute3_value := get_Attribute_Value(l_xml_node, G_USER_ATTRIBUTE3_NAME);
              l_switcher_casename := get_User_Attribute(l_user_attribute3_value ,'switcherDefaultCaseName');
              l_switcher_casename := REPLACE(l_switcher_casename,l_attribute_value, l_new_attribute_value);
              l_switcher_casename := REPLACE(REPLACE(l_switcher_casename,'_czt','_czn'), '_czc','_czn');
              set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                                 p_cz_attribute_value   => l_switcher_casename,
                                 px_xml_attribute_value => l_user_attribute3_value);

              set_Attribute(l_xml_node,
                            G_USER_ATTRIBUTE3_NAME,
                            l_user_attribute3_value);
            END IF;

            --
            -- set value of attribute "name" of <ui:case> to id of parent <oa:switcher>
            --
            IF (l_xml_node_name='ui:case' AND xmldom.getNodeName(l_curr_parent_xml_node)='oa:switcher') THEN
              l_switcher_xml_id := get_Attribute_Value(l_curr_parent_xml_node, G_ID_ATTRIBUTE);
              l_uicase_name     :=  get_Attribute_Value(l_xml_node, 'name');
              set_Attribute(xmldom.makeElement(l_xml_node),
                            'name',
                            REPLACE(REPLACE(REPLACE(l_uicase_name,l_old_switcher_xml_id,l_switcher_xml_id),'_czt','_czn'), '_czc', '_czn'));
              handle_UI_CASE_Id(l_xml_node);
            END IF;

            --
            -- if current tag is <oa:stackLayout>
            -- then replace old id with new one
            --
            IF (l_xml_node_name='oa:stackLayout' AND
               xmldom.getNodeName(l_curr_parent_xml_node)='ui:case') AND l_attribute_value IS NOT NULL THEN
              set_Attribute(xmldom.makeElement(l_xml_node),
                            G_ID_ATTRIBUTE,
                           REPLACE(REPLACE(get_Attribute_Value(l_curr_parent_xml_node, 'name'),'_czt','_czn'),'_czc','_czn'));
            END IF;

            IF l_attribute_value IS NOT NULL THEN
              --
              -- create a new copies for corresponding entities ( captions, rules ,... )
              --
              copy_Node_Related_Entities(p_ui_def_id   => p_ui_node.ui_def_id,
                                         p_ui_page_id  => p_ui_node.page_id,
                                         p_xml_node    => l_xml_node);
            END IF;

            IF p_ui_node.ctrl_template_id=g_DRILLDOWN_TEMPLATE_ID THEN
              IF attribute_Value(l_xml_node, 'source') IS NULL AND
                 g_UI_Context.DRILLDOWN_IMAGE_URL IS NOT NULL THEN
                 set_Attribute(l_xml_node,
                               'source',
                                g_UI_Context.DRILLDOWN_IMAGE_URL);
              END IF;

              l_user_attribute := get_Attribute_Value(l_xml_node,
                                                     G_USER_ATTRIBUTE3_NAME);

              IF l_user_attribute IS NOT NULL THEN

                IF p_ui_node.element_type=G_UI_CX_BUTTON_NODE_TYPE THEN

                   set_User_Attribute(p_cz_attribute_name    => 'captionIntlTextId',
                                      p_cz_attribute_value   => TO_CHAR(g_cx_names_tbl(TO_NUMBER(p_ui_node.element_id))),
                                      px_xml_attribute_value => l_user_attribute);

                   set_User_Attribute(p_cz_attribute_name    => 'rolloverIntlTextId',
                                      p_cz_attribute_value   => TO_CHAR(g_cx_names_tbl(TO_NUMBER(p_ui_node.element_id))),
                                      px_xml_attribute_value => l_user_attribute);
                ELSE
                   IF  g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID IS NOT NULL THEN

                     l_drilldown_text_id := copy_Intl_Text(g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID,
                                                           g_UI_Context.ui_def_id,
                                                           p_ui_node.page_id, p_ui_node.element_id);

                     set_User_Attribute(p_cz_attribute_name    => 'captionIntlTextId',
                                        p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                                        px_xml_attribute_value => l_user_attribute);

                     set_User_Attribute(p_cz_attribute_name    => 'rolloverIntlTextId',
                                        p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                                        px_xml_attribute_value => l_user_attribute);

                   END IF;
                END IF;   -- end of p_ui_node.element_type=G_UI_CX_BUTTON_NODE_TYPE THEN

                BEGIN
                  l_ui_action_id := get_UI_Action_Id(p_ui_node);
                EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
                END;

                IF l_ui_action_id IS NOT NULL THEN

                  set_User_Attribute(p_cz_attribute_name    => 'actionId',
                                     p_cz_attribute_value   => TO_CHAR(l_ui_action_id),
                                     px_xml_attribute_value => l_user_attribute);

                END IF;

                set_Attribute(l_xml_node,G_USER_ATTRIBUTE3_NAME,l_user_attribute);

              END IF;     -- end of IF l_user_attribute IS NOT NULL

            END IF;  -- end of IF p_ui_node.ctrl_template_id=g_DRILLDOWN_TEMPLATE_ID

            --++++++ add template references ++++++
            add_Extends_Refs(p_xml_node  => l_xml_node,
                             p_ui_node   => p_ui_node);

          END IF; -- end of  IF k > 0 THEN
        END LOOP;
      END IF;

      --l_new_xml_root_node := xmldom.cloneNode(l_xml_root_node, TRUE);
      l_new_xml_root_node := cloneNode(l_xml_root_node, p_parent_xml_node);

      --DEBUG('asp:Adding ' || p_ui_node.element_id || ' to table 2');
      g_dom_elements_tbl(TO_NUMBER(p_ui_node.element_id)) := l_new_xml_root_node;
    END IF;

    -- The new element is now ready. It is
  -- l_new_xml_root_node, the root of the subtree to be added
  -- We need to add this root node to an appropriate location
  -- int the XML DOM.


  -- we have to decide if we want to add this new element
  -- after the prev element, before the next element or as the
  -- last element of the given parent region

  IF l_prev_element_id IS NOT NULL THEN
    l_prev_node := g_dom_elements_tbl(TO_NUMBER(l_prev_element_id));
    l_prev_node_parent_ui_cnt := xmldom.getParentNode(l_prev_node);
    l_prev_node_parent := xmldom.getParentNode(l_prev_node_parent_ui_cnt);
    BEGIN
        SELECT layout_ui_style INTO l_prev_elt_lyt_ui_style
      FROM CZ_UI_TEMPLATES
      WHERE template_id = l_prev_element_template_id
      AND ui_def_id = 0
    AND deleted_flag = G_NO_FLAG;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL;
    END;
  END IF;

  IF l_next_element_id IS NOT NULL THEN
    --DEBUG('Here 8.11 ' || l_next_element_id);
    IF g_dom_elements_tbl.EXISTS(TO_NUMBER(l_next_element_id)) THEN
      l_next_node := g_dom_elements_tbl(TO_NUMBER(l_next_element_id));
      --DEBUG('Here 8.12');
      l_next_node_parent_ui_cnt := xmldom.getParentNode(l_next_node);
      --DEBUG('Here 8.13');
      l_next_node_parent := xmldom.getParentNode(l_next_node_parent_ui_cnt);
      --DEBUG('Here 8.14');
      BEGIN
        SELECT layout_ui_style INTO l_next_elt_lyt_ui_style
        FROM CZ_UI_TEMPLATES
        WHERE template_id = l_next_element_template_id
        AND ui_def_id = 0
        AND deleted_flag = G_NO_FLAG;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    ELSE
      l_next_element_id := NULL;
    END IF;
  END IF;

  --DEBUG('Here 9' || l_node.detailed_type_id);
  IF l_node.detailed_type_id IN(CZ_TYPES.UNON_COUNT_FEATURE_TYPEID,
                                  CZ_TYPES.UCOUNT_FEATURE_TYPEID,
                                  CZ_TYPES.UCOUNT_FEATURE01_TYPEID,
                                  CZ_TYPES.UMINMAX_FEATURE_TYPEID,
                                  CZ_TYPES.UINTEGER_FEATURE_TYPEID,
                                  CZ_TYPES.UDECIMAL_FEATURE_TYPEID,
                                  CZ_TYPES.UBOOLEAN_FEATURE_TYPEID,
                                  CZ_TYPES.UTEXT_FEATURE_TYPEID,
                                  CZ_TYPES.UTOTAL_TYPEID,
                                  CZ_TYPES.URESOURCE_TYPEID) AND
       NVL(l_node.layout_ui_style,G_LABEL_PAIR_LAYOUT_STYLE) IN(G_LABEL_PAIR_LAYOUT_STYLE,G_WRAPPED_LAYOUT_STYLE) THEN

       --DEBUG('asp:Wrap it 1 ' || l_node.name);
       l_wrap_it  := TRUE;

  ELSIF l_node.ps_node_type IN(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) OR
          l_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN

       IF NVL(l_node.layout_ui_style,G_TABLE_LAYOUT_STYLE) = G_TABLE_LAYOUT_STYLE  OR
         l_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN
         l_wrap_it := FALSE;

       ELSIF l_node.layout_ui_style IN(G_LABEL_PAIR_LAYOUT_STYLE,G_WRAPPED_LAYOUT_STYLE) AND
         l_node.detailed_type_id NOT IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN
         l_wrap_it := TRUE;
       ELSE
         l_wrap_it := FALSE;
       END IF;

       IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_PAGE) OR
          g_UI_Context.PAGIN_BOMOC IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) THEN
         l_wrap_with_links := TRUE;
       END IF;

    ELSIF l_node.detailed_type_id IN(CZ_TYPES.UCOUNT_FEATURE01_TYPEID,
                                     CZ_TYPES.UCOUNT_FEATURE_TYPEID,
                                     CZ_TYPES.UMINMAX_FEATURE_TYPEID) THEN
      l_wrap_it         := FALSE;
    END IF;

    IF l_prev_element_id IS NOT NULL
        OR l_next_element_id IS NOT NULL THEN
      IF l_wrap_it THEN
        IF l_prev_element_id IS NOT NULL AND
          NVL(l_prev_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE THEN
            l_next_node := xmldom.getNextSibling(l_prev_node);
        l_new_xml_root_node := insert_before(l_prev_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSIF l_next_element_id IS NOT NULL AND
             NVL(l_next_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE THEN
          l_new_xml_root_node := insert_before(l_next_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSE
          create_wrapper_table_layout(l_xml_table_node, l_xml_tabuicontent_node, p_parent_xml_node);
          l_new_xml_root_node := xmldom.appendChild(l_xml_tabuicontent_node, l_new_xml_root_node);
          IF l_prev_element_id IS NOT NULL THEN
            l_next_node := xmldom.getNextSibling(l_prev_node);
            l_xml_table_node := insert_before(l_prev_node_parent_ui_cnt, l_xml_table_node, l_next_node);
          ELSIF l_next_element_id IS NOT NULL THEN
            l_xml_table_node := insert_before(l_next_node_parent_ui_cnt, l_xml_table_node, l_next_node);
          ELSE
            l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
            l_xml_table_node := xmldom.appendChild(l_ui_contents_xml_node, l_xml_table_node);
          END IF;
        END IF;
      ELSE -- new element is not LABEL_DATA_PAIR

        IF l_prev_element_id IS NOT NULL AND l_next_element_id IS NOT NULL AND
          NVL(l_prev_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE AND
          NVL(l_next_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) = G_LABEL_PAIR_LAYOUT_STYLE THEN


          IF get_Attribute_Value(l_prev_node_parent, G_ID_ATTRIBUTE) = get_Attribute_Value(l_next_node_parent, G_ID_ATTRIBUTE) THEN
            IF xmldom.getNodeName(l_prev_node_parent) = 'oa:tableLayout' THEN
              l_grand_parent := xmldom.getParentNode(l_prev_node_parent);
              create_wrapper_table_layout(l_xml_table_node, l_xml_tabuicontent_node, p_parent_xml_node);
              l_next_sibling_of_parent := xmldom.getNextSibling(l_prev_node_parent);
              l_xml_table_node := insert_before(l_grand_parent, l_xml_table_node, l_next_sibling_of_parent);
              l_next_node := xmldom.removeChild(l_prev_node_parent_ui_cnt, l_next_node);
              l_next_node := xmldom.appendChild(l_xml_tabuicontent_node, l_next_node);
              l_next_node := l_xml_table_node;
            END IF;
            l_next_node := xmldom.insertBefore(l_grand_parent, l_new_xml_root_node, l_next_node);
          ELSE
            l_grand_parent := xmldom.getParentNode(l_prev_node_parent);
            l_next_sibling_of_parent := xmldom.getNextSibling(l_prev_node_parent);
            l_new_xml_root_node := insert_before(l_grand_parent, l_new_xml_root_node, l_next_sibling_of_parent);
          END IF;
        ELSIF l_prev_element_id IS NOT NULL AND NVL(l_prev_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) <> G_LABEL_PAIR_LAYOUT_STYLE THEN
          l_next_node := xmldom.getNextSibling(l_prev_node);
          l_new_xml_root_node := insert_before(l_prev_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSIF l_next_element_id IS NOT NULL AND
          NVL(l_next_elt_lyt_ui_style, G_OTHER_LAYOUT_STYLE) <> G_LABEL_PAIR_LAYOUT_STYLE THEN
          l_new_xml_root_node := insert_before(l_next_node_parent_ui_cnt, l_new_xml_root_node, l_next_node);
        ELSIF l_prev_element_id IS NOT NULL THEN
          l_grand_parent := xmldom.getParentNode(l_prev_node_parent);
          l_next_sibling_of_parent := xmldom.getNextSibling(l_prev_node_parent);
          l_new_xml_root_node := insert_before(l_grand_parent, l_new_xml_root_node, l_next_sibling_of_parent);
        ELSE
          l_grand_parent := xmldom.getParentNode(l_next_node_parent);
          l_new_xml_root_node := insert_before(l_grand_parent, l_new_xml_root_node, l_next_node_parent);
    END IF;
      END IF;
  ELSE
    -- If neither prev_element and next_element is found
    -- Insert at the end
    --DEBUG('asp:Append at the end');

    IF l_wrap_it THEN
       --DEBUG('Append at the end. Wrapping ' || xmldom.getNodeName(p_parent_xml_node));
       l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
       --DEBUG('Append at the end. Wrapping ' || xmldom.getNodeName(l_ui_contents_xml_node));
       create_wrapper_table_layout(l_xml_table_node, l_xml_tabuicontent_node, p_parent_xml_node);
       l_xml_table_node := xmldom.appendChild(l_ui_contents_xml_node, l_xml_table_node);
       l_new_xml_root_node := xmldom.appendChild(l_xml_tabuicontent_node, l_new_xml_root_node);
    ELSE
       --DEBUG('Append at the end. Not wrapping');
       l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
       l_new_xml_root_node := xmldom.appendChild(l_ui_contents_xml_node, l_new_xml_root_node);
    END IF;
  END IF;

  RETURN l_new_xml_root_node;

  END create_UIXML_Element_new;

  --
  -- create new XML JRAD element
  --
  FUNCTION create_UIXML_Element(p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                p_parent_xml_node     xmldom.DOMNode)
    RETURN xmldom.DOMNode IS

    l_node                  CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_ctrl_template_name    CZ_UI_TEMPLATES.template_name%TYPE;
    l_doc                   xmldom.DOMDocument;
    l_anchor_doc            xmldom.DOMDocument;
    l_subtree_doc           xmldom.DOMDocument;
    l_xml_root_node         xmldom.DOMNode;
    l_new_xml_root_node     xmldom.DOMNode;
    l_out_xml_node          xmldom.DOMNode;
    l_xml_table_node        xmldom.DOMNode;
    l_new_xml_table_node    xmldom.DOMNode;
    l_xml_anchor_node       xmldom.DOMNode;
    l_new_xml_anchor_node   xmldom.DOMNode;
    l_xml_node              xmldom.DOMNode;
    l_xml_tabuicontent_node xmldom.DOMNode;
    l_ui_contents_xml_node  xmldom.DOMNode;

    l_curr_parent_xml_node  xmldom.DOMNode;
    l_xml_node_name         VARCHAR2(255);
    l_new_attribute_value   VARCHAR2(255);

    l_child_nodes_tbl       xmldom.DOMNodeList;
    l_attribute_value       VARCHAR2(4000);
    l_attribute_source      VARCHAR2(4000);
    l_user_attribute        VARCHAR2(4000);
    l_user_attribute4       VARCHAR2(4000);
    l_jrad_doc              VARCHAR2(255);
    l_ancestor_node         VARCHAR2(255);
    l_hgrid_element_id      VARCHAR2(255);
    l_prev_element_id       VARCHAR2(255);
    l_old_ui_element_id     VARCHAR2(255);
    l_new_ui_element_id     VARCHAR2(255);
    l_switcher_element_id   VARCHAR2(255);
    l_user_attribute3_value VARCHAR2(4000);
    l_switcher_casename     VARCHAR2(255);
    l_old_switcher_xml_id   VARCHAR2(255);
    l_switcher_xml_id       VARCHAR2(255);
    l_uicase_name           VARCHAR2(255);
    l_length                NUMBER;
    l_ui_action_id          NUMBER;
    l_element_signature_id  NUMBER;
    l_non_bom_content       BOOLEAN;
    l_wrap_it               BOOLEAN;
    l_drilldown_text_id     NUMBER;
    l_wrap_with_links       BOOLEAN := FALSE;
    l_template_is_used_by_ref BOOLEAN := TRUE;

  BEGIN

  IF g_using_new_UI_refresh THEN
    RETURN create_UIXML_Element_new(p_ui_node, p_parent_xml_node);
  END IF;

    IF p_ui_node.ctrl_template_id IS NULL THEN
      RETURN l_xml_node;
    END IF;

    l_node := get_Model_Node_By_Persist_Id(p_ui_node.persistent_node_id,g_UI_Context.devl_project_id);

    l_template_is_used_by_ref := is_Used_By_Reference(l_node.detailed_type_id,p_ui_node.ctrl_template_id);

    BEGIN
      SELECT element_id INTO l_prev_element_id
        FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             parent_persistent_node_id=p_ui_node.parent_persistent_node_id AND
             seq_nbr=p_ui_node.seq_nbr-1 AND
             deleted_flag<>G_YES_FLAG;

      l_xml_tabuicontent_node := find_Table_Of_XML_Node(p_parent_xml_node, l_prev_element_id);

    EXCEPTION
      WHEN OTHERS THEN
           NULL;
    END;

    --
    -- drilldowns will be handled by special way ( bug #3271034 )
    --
    IF p_ui_node.ctrl_template_id IN(G_DRILLDOWN_BUTTON_TEMPLATE_ID,G_DRILLDOWN_IMAGE_TEMPLATE_ID,
       G_DRILLDOWN_LABEL_TEMPLATE_ID) THEN
       IF g_UI_Context.DRILLDOWN_IMAGE_URL IS NOT NULL THEN
         l_ctrl_template_name := get_JRAD_Name(p_template_id => G_DRILLDOWN_IMAGE_TEMPLATE_ID);
       ELSE
         l_ctrl_template_name := get_JRAD_Name(p_template_id => p_ui_node.ctrl_template_id);
       END IF;
    ELSE
       l_ctrl_template_name := get_JRAD_Name(p_template_id => p_ui_node.ctrl_template_id);
    END IF;

    IF l_node.detailed_type_id IN(CZ_TYPES.UNON_COUNT_FEATURE_TYPEID,
                                  CZ_TYPES.UCOUNT_FEATURE_TYPEID,
                                  CZ_TYPES.UCOUNT_FEATURE01_TYPEID,
                                  CZ_TYPES.UMINMAX_FEATURE_TYPEID,
                                  CZ_TYPES.UINTEGER_FEATURE_TYPEID,
                                  CZ_TYPES.UDECIMAL_FEATURE_TYPEID,
                                  CZ_TYPES.UBOOLEAN_FEATURE_TYPEID,
                                  CZ_TYPES.UTEXT_FEATURE_TYPEID,
                                  CZ_TYPES.UTOTAL_TYPEID,
                                  CZ_TYPES.URESOURCE_TYPEID) AND
       NVL(l_node.layout_ui_style,G_LABEL_PAIR_LAYOUT_STYLE) IN(G_LABEL_PAIR_LAYOUT_STYLE,G_WRAPPED_LAYOUT_STYLE) THEN

       l_non_bom_content := TRUE;
       l_wrap_it  := TRUE;

       --
       -- add TableLayout
       --
       IF xmldom.isNull(l_xml_tabuicontent_node) THEN

         BEGIN
           l_doc := parse_JRAD_Document(G_TABLELAYOUT_TEMPLATE);

           l_xml_table_node :=xmldom.makeNode(xmldom.getDocumentElement(l_doc));

           remove_TopLevel_Attributes(l_xml_table_node);

           --l_new_xml_table_node := xmldom.cloneNode(l_xml_table_node,TRUE);
           l_new_xml_table_node := cloneNode(l_xml_table_node, p_parent_xml_node);

           set_Attribute(xmldom.makeElement(l_new_xml_table_node),G_ID_ATTRIBUTE,get_Element_Id());
           set_Attribute(xmldom.makeElement(l_new_xml_table_node),G_USER_ATTRIBUTE5_NAME,'TABLELAYOUT_FOR_UI_GEN');

           l_xml_tabuicontent_node := getUIContents(l_new_xml_table_node);

           IF xmldom.getNodeName(p_parent_xml_node) IN('oa:header','oa:stackLayout',
                                                       'oa:flowLayout','oa:tableLayout') THEN

             l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
             l_out_xml_node := xmldom.appendChild(l_ui_contents_xml_node,l_new_xml_table_node);
           ELSE
             l_out_xml_node := xmldom.appendChild(p_parent_xml_node,l_new_xml_table_node);
           END IF;

        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;

    --
    -- BOM part
    --
    ELSIF l_node.ps_node_type IN(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) OR
          l_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN

       l_non_bom_content := TRUE;

       IF NVL(l_node.layout_ui_style,G_TABLE_LAYOUT_STYLE) = G_TABLE_LAYOUT_STYLE  OR
         l_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN
         l_wrap_it := FALSE;

       ELSIF l_node.layout_ui_style IN(G_LABEL_PAIR_LAYOUT_STYLE,G_WRAPPED_LAYOUT_STYLE) AND
         l_node.detailed_type_id NOT IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN
         --
         -- add TableLayout
         --
         IF xmldom.isNull(l_xml_tabuicontent_node) THEN
           BEGIN
             l_doc := parse_JRAD_Document(G_TABLELAYOUT_TEMPLATE);

             l_xml_table_node :=xmldom.makeNode(xmldom.getDocumentElement(l_doc));

             remove_TopLevel_Attributes(l_xml_table_node);

             --l_new_xml_table_node := xmldom.cloneNode(l_xml_table_node,TRUE);
             l_new_xml_table_node := cloneNode(l_xml_table_node, p_parent_xml_node);

             set_Attribute(xmldom.makeElement(l_new_xml_table_node),G_ID_ATTRIBUTE,get_Element_Id());
             set_Attribute(xmldom.makeElement(l_new_xml_table_node),G_USER_ATTRIBUTE5_NAME,'TABLELAYOUT_FOR_UI_GEN');

             l_xml_tabuicontent_node := getUIContents(l_new_xml_table_node);

             IF xmldom.getNodeName(p_parent_xml_node) IN('oa:header','oa:stackLayout',
                                                         'oa:flowLayout','oa:tableLayout') THEN

               l_ui_contents_xml_node := getUIContents(p_parent_xml_node);

               l_out_xml_node := xmldom.appendChild(l_ui_contents_xml_node,l_new_xml_table_node);
             ELSE
               l_out_xml_node := xmldom.appendChild(p_parent_xml_node,l_new_xml_table_node);
             END IF;
           EXCEPTION
             WHEN OTHERS THEN
               DEBUG('create_UIXML_Element : '||SQLERRM);
           END;
         END IF;
         l_wrap_it := TRUE;
       ELSE
         l_wrap_it := FALSE;
       END IF;

       IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_PAGE) OR
          g_UI_Context.PAGIN_BOMOC IN(G_SINGLE_PG_TYPE,G_SUBSECTIONS_PG_TYPE) THEN
         l_wrap_with_links := TRUE;
       END IF;

    ELSIF l_node.detailed_type_id IN(CZ_TYPES.UCOUNT_FEATURE01_TYPEID,
                                     CZ_TYPES.UCOUNT_FEATURE_TYPEID,
                                     CZ_TYPES.UMINMAX_FEATURE_TYPEID) THEN
      l_non_bom_content := FALSE;
      l_wrap_it         := FALSE;
    ELSE
      l_non_bom_content := FALSE;
    END IF;

    --
    -- parse document(template) which is going to be nested element
    --
    l_subtree_doc := parse_JRAD_Document(l_ctrl_template_name);

    IF xmldom.isNull(l_subtree_doc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_ctrl_template_name,
                        p_fatal_error  => TRUE);

       RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- get subdocument's root node
    --
    l_xml_root_node := xmldom.makeNode(xmldom.getDocumentElement(l_subtree_doc));

    IF l_template_is_used_by_ref=FALSE THEN
      handle_USER_ATTRIBUTE10(p_xml_root_node => l_xml_root_node,
                              p_ui_def_id     => p_ui_node.ui_def_id,
                              p_ui_page_id    => p_ui_node.page_id,
                              p_ui_element_id => p_ui_node.element_id);
    END IF;

    --
    -- remove common attributes of container and subtree
    --
    remove_TopLevel_Attributes(l_xml_root_node);

    IF l_template_is_used_by_ref THEN
      l_element_signature_id := 6011;
    ELSE
      l_element_signature_id := p_ui_node.element_signature_id;
    END IF;

    --
    -- set Attributes for this subtree = Template
    --
    set_Template_Attributes(p_xml_root_node        => l_xml_root_node,
                            p_ui_node              => p_ui_node,
                            p_element_signature_id => l_element_signature_id);

    --
    -- set a special attribute "blockSize" if it is Table control
    --
    /* commented out according to request from 8/12/2004
    IF  xmldom.getNodeName(l_xml_root_node) IN('oa:table') THEN
      set_Attribute(l_xml_root_node,
                    'blockSize',
                    TO_CHAR(g_UI_Context.ROWS_PER_TABLE));
    END IF;
    */
    IF l_template_is_used_by_ref THEN

      --
      -- returns cloned DOM subtree
      --
      -- l_new_xml_root_node := xmldom.cloneNode(l_xml_root_node,TRUE);
      l_new_xml_root_node := cloneNode(l_xml_root_node, p_parent_xml_node);

      --
      -- remove non user attributes from top tag
      --
      remove_Non_User_Attributes(l_new_xml_root_node);

      --
      -- set "extends" attribute
      --
      xmldom.setAttribute(xmldom.makeElement(l_new_xml_root_node),'extends',l_ctrl_template_name);

      --
      -- remove content of template subtree
      --
      l_child_nodes_tbl:=xmldom.getChildNodes(l_new_xml_root_node);

      --
      -- we need to get length of array of child nodes
      -- to go through the array in loop
      --
      l_length := xmldom.getLength(l_child_nodes_tbl);
      FOR k IN 0..l_length-1
      LOOP
        --
        -- get next child DOM node
        --
        l_xml_node := xmldom.item(l_child_nodes_tbl, k);
        l_out_xml_node:=xmldom.removeChild(l_new_xml_root_node,l_xml_node);
      END LOOP;

    ELSE -- use UI Template by Copy

      l_child_nodes_tbl := xmldom.getElementsByTagName(l_subtree_doc, '*');

      l_length := xmldom.getLength(l_child_nodes_tbl);
      IF (l_length > 0) THEN
        FOR k IN 0..l_length-1
        LOOP
          --
          -- get next child DOM node
          --
          l_xml_node := xmldom.item(l_child_nodes_tbl, k);
          l_curr_parent_xml_node := xmldom.getParentNode(l_xml_node);

          IF k > 0 THEN
            l_attribute_value := get_Attribute_Value(l_xml_node, G_ID_ATTRIBUTE);

            l_xml_node_name := xmldom.getNodeName(l_xml_node);

            IF l_attribute_value IS NOT NULL THEN
              l_new_attribute_value := handle_JRAD_Id(l_attribute_value,p_ui_node.element_id);
              set_Attribute(xmldom.makeElement(l_xml_node),G_ID_ATTRIBUTE,REPLACE(REPLACE(l_new_attribute_value,'_czt','_czn'),'_czc','_czn'));
            END IF;

            l_ancestor_node := get_Attribute_Value(l_xml_node,
                                                   'ancestorNode');
            IF l_ancestor_node IS NOT NULL THEN

              SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_PAGES
              WHERE page_id=p_ui_node.page_id AND ui_def_id=p_ui_node.ui_def_id;

              l_hgrid_element_id := find_Element_Id_Of_XMLTag(l_xml_node, 'oa:tree');
              IF NOT(xmldom.IsNull(l_xml_node)) THEN
                l_ancestor_node := l_jrad_doc||'.'||l_hgrid_element_id;

                set_Attribute(l_xml_node,
                              'ancestorNode',
                              l_ancestor_node);
              END IF;
            END IF;

            --
            -- set value of user attribute "switcherDefaultCaseName" to new jrad id of <oa:switcher>
            --
            IF xmldom.getNodeName(l_xml_node)='oa:switcher' THEN
              l_old_switcher_xml_id := l_attribute_value;
              l_user_attribute3_value := get_Attribute_Value(l_xml_node, G_USER_ATTRIBUTE3_NAME);
              l_switcher_casename := get_User_Attribute(l_user_attribute3_value ,'switcherDefaultCaseName');
              l_switcher_casename := REPLACE(REPLACE(REPLACE(l_switcher_casename,l_attribute_value, l_new_attribute_value),'_czt','_czn'),'_czc','_czn');
              set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                                 p_cz_attribute_value   => l_switcher_casename,
                                 px_xml_attribute_value => l_user_attribute3_value);

              set_Attribute(l_xml_node,
                            G_USER_ATTRIBUTE3_NAME,
                            l_user_attribute3_value);
            END IF;

            --
            -- set value of attribute "name" of <ui:case> to id of parent <oa:switcher>
            --
            IF (l_xml_node_name='ui:case' AND xmldom.getNodeName(l_curr_parent_xml_node)='oa:switcher') THEN
              l_switcher_xml_id := get_Attribute_Value(l_curr_parent_xml_node, G_ID_ATTRIBUTE);
              l_uicase_name     :=  get_Attribute_Value(l_xml_node, 'name');
              set_Attribute(xmldom.makeElement(l_xml_node),
                            'name',
                            REPLACE(REPLACE(REPLACE(l_uicase_name,l_old_switcher_xml_id,l_switcher_xml_id),'_czt','_czn'),'_czc','_czn'));
              handle_UI_CASE_Id(l_xml_node);
            END IF;

            --
            -- if current tag is <oa:stackLayout>
            -- then replace old id with new one
            --
            IF (l_xml_node_name='oa:stackLayout' AND
               xmldom.getNodeName(l_curr_parent_xml_node)='ui:case') AND l_attribute_value IS NOT NULL THEN
              set_Attribute(xmldom.makeElement(l_xml_node),
                            G_ID_ATTRIBUTE,
                           REPLACE(REPLACE(get_Attribute_Value(l_curr_parent_xml_node, 'name'),'_czt','_czn'),'_czc','_czn'));
            END IF;

            IF l_attribute_value IS NOT NULL THEN
              --
              -- create a new copies for corresponding entities ( captions, rules ,... )
              --
              copy_Node_Related_Entities(p_ui_def_id   => p_ui_node.ui_def_id,
                                         p_ui_page_id  => p_ui_node.page_id,
                                         p_xml_node    => l_xml_node);
            END IF;

            IF p_ui_node.ctrl_template_id=g_DRILLDOWN_TEMPLATE_ID THEN
              IF attribute_Value(l_xml_node, 'source') IS NULL AND
                 g_UI_Context.DRILLDOWN_IMAGE_URL IS NOT NULL THEN
                 set_Attribute(l_xml_node,
                               'source',
                                g_UI_Context.DRILLDOWN_IMAGE_URL);
              END IF;

              l_user_attribute := get_Attribute_Value(l_xml_node,
                                                     G_USER_ATTRIBUTE3_NAME);

              IF l_user_attribute IS NOT NULL THEN

                IF p_ui_node.element_type=G_UI_CX_BUTTON_NODE_TYPE THEN

                   set_User_Attribute(p_cz_attribute_name    => 'captionIntlTextId',
                                      p_cz_attribute_value   => TO_CHAR(g_cx_names_tbl(TO_NUMBER(p_ui_node.element_id))),
                                      px_xml_attribute_value => l_user_attribute);

                   set_User_Attribute(p_cz_attribute_name    => 'rolloverIntlTextId',
                                      p_cz_attribute_value   => TO_CHAR(g_cx_names_tbl(TO_NUMBER(p_ui_node.element_id))),
                                      px_xml_attribute_value => l_user_attribute);
                ELSE
                   IF  g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID IS NOT NULL THEN

                     l_drilldown_text_id := copy_Intl_Text(g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID,
                                                           g_UI_Context.ui_def_id,
                                                           p_ui_node.page_id, p_ui_node.element_id);

                     set_User_Attribute(p_cz_attribute_name    => 'captionIntlTextId',
                                        p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                                        px_xml_attribute_value => l_user_attribute);

                     set_User_Attribute(p_cz_attribute_name    => 'rolloverIntlTextId',
                                        p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                                        px_xml_attribute_value => l_user_attribute);

                   END IF;
                END IF;   -- end of p_ui_node.element_type=G_UI_CX_BUTTON_NODE_TYPE THEN

                BEGIN
                  l_ui_action_id := get_UI_Action_Id(p_ui_node);
                EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
                END;

                IF l_ui_action_id IS NOT NULL THEN

                  set_User_Attribute(p_cz_attribute_name    => 'actionId',
                                     p_cz_attribute_value   => TO_CHAR(l_ui_action_id),
                                     px_xml_attribute_value => l_user_attribute);

                END IF;

                set_Attribute(l_xml_node,G_USER_ATTRIBUTE3_NAME,l_user_attribute);

              END IF;     -- end of IF l_user_attribute IS NOT NULL

            END IF;  -- end of IF p_ui_node.ctrl_template_id=g_DRILLDOWN_TEMPLATE_ID

            --++++++ add template references ++++++
            add_Extends_Refs(p_xml_node  => l_xml_node,
                             p_ui_node   => p_ui_node);

          END IF; -- end of  IF k > 0 THEN
        END LOOP;
      END IF;

      --l_new_xml_root_node := xmldom.cloneNode(l_xml_root_node, TRUE);
      l_new_xml_root_node := cloneNode(l_xml_root_node, p_parent_xml_node);

    END IF;

    IF l_wrap_it THEN

      IF l_wrap_with_links THEN

        BEGIN
          l_anchor_doc := parse_JRAD_Document(G_ANCHOR_TEMPLATE);

          l_xml_anchor_node :=xmldom.makeNode(xmldom.getDocumentElement(l_anchor_doc));

           remove_TopLevel_Attributes(l_xml_anchor_node);

           --l_new_xml_anchor_node := xmldom.cloneNode(l_xml_anchor_node,TRUE);
           l_new_xml_anchor_node := cloneNode(l_xml_anchor_node, p_parent_xml_node);

           set_Attribute(xmldom.makeElement(l_new_xml_anchor_node),G_ID_ATTRIBUTE,get_Element_Id());
           set_Attribute(xmldom.makeElement(l_new_xml_anchor_node),G_USER_ATTRIBUTE5_NAME,'ANCHOR_GENERATED_BY_UI_GEN');

           l_out_xml_node := xmldom.appendChild(l_xml_tabuicontent_node,
                                                l_new_xml_anchor_node);

           l_out_xml_node := xmldom.appendChild(l_xml_tabuicontent_node,
                                                l_new_xml_root_node);

        EXCEPTION
          WHEN OTHERS THEN
            DEBUG('create_UIXML_Element() : '||SQLERRM);
         END;

      ELSE -- don't wrap it with rowLayout+Link

        l_out_xml_node := xmldom.appendChild(l_xml_tabuicontent_node,
                                             l_new_xml_root_node);

      END IF;

      RETURN l_out_xml_node;

    ELSE -- don't wrap with TableLayout

      IF l_wrap_with_links THEN
        BEGIN
          l_anchor_doc := parse_JRAD_Document(G_LINK_TEMPLATE);

          l_xml_anchor_node :=xmldom.makeNode(xmldom.getDocumentElement(l_anchor_doc));

          remove_TopLevel_Attributes(l_xml_anchor_node);

          --l_new_xml_anchor_node := xmldom.cloneNode(l_xml_anchor_node,TRUE);
          l_new_xml_anchor_node := cloneNode(l_xml_anchor_node, p_parent_xml_node);

          set_Attribute(xmldom.makeElement(l_new_xml_anchor_node),G_ID_ATTRIBUTE,
            '_czt'||to_char(p_ui_node.persistent_node_id)); -- fix for bug #4047136
          set_Attribute(xmldom.makeElement(l_new_xml_anchor_node),G_USER_ATTRIBUTE5_NAME,'LINK_GENERATED_BY_UI_GEN');
        EXCEPTION
          WHEN OTHERS THEN
            DEBUG('create_UIXML_Element() : '||SQLERRM);
        END;
      END IF;

      IF xmldom.getNodeName(p_parent_xml_node) IN('oa:header','oa:stackLayout',
         'oa:flowLayout','oa:tableLayout') THEN


         l_ui_contents_xml_node := getUIContents(p_parent_xml_node);

         IF l_wrap_with_links THEN
           l_out_xml_node := xmldom.appendChild(l_ui_contents_xml_node,
                                                l_new_xml_anchor_node);
         END IF;
         l_out_xml_node := xmldom.appendChild(l_ui_contents_xml_node,
                                              l_new_xml_root_node);
      ELSE

         IF l_wrap_with_links THEN
           l_out_xml_node := xmldom.appendChild(p_parent_xml_node,
                                                l_new_xml_anchor_node);
         END IF;

        l_out_xml_node := xmldom.appendChild(p_parent_xml_node,
                                             l_new_xml_root_node);
      END IF;
      RETURN l_out_xml_node;
    END IF;

  END create_UIXML_Element;

  --
  -- add new XML region
  --
  FUNCTION create_UIXML_Region(p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                               p_parent_xml_node     xmldom.DOMNode)
    RETURN xmldom.DOMNode IS

    l_subtree_doc          xmldom.DOMDocument;
    l_xml_root_node        xmldom.DOMNode;
    l_new_xml_root_node    xmldom.DOMNode;
    l_out_xml_node         xmldom.DOMNode;
    l_ui_contents_xml_node xmldom.DOMNode;
    l_jrad_doc             CZ_UI_TEMPLATES.jrad_doc%TYPE;

  BEGIN

    l_jrad_doc := get_JRAD_Name(G_NSTD_CONTAINER_TEMPLATE_ID, G_GLOBAL_TEMPLATES_UI_DEF_ID);

    --
    -- parse document(template) which is going to be nested element
    --
    l_subtree_doc := parse_JRAD_Document(l_jrad_doc);

    IF xmldom.isNull(l_subtree_doc) THEN
       add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                         p_token_name   => 'UI_TEMPLATE',
                         p_token_value  => l_jrad_doc,
                         p_fatal_error  => TRUE);
       RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- get subdocument's root node
    --
    l_xml_root_node := xmldom.makeNode(xmldom.getDocumentElement(l_subtree_doc));

    --
    -- remove common attributes of container and subtree
    --
    remove_TopLevel_Attributes(l_xml_root_node);

    --
    -- set Attributes for this subtree = Template
    --
    set_Template_Attributes(p_xml_root_node => l_xml_root_node,
                            p_ui_node       => p_ui_node);

    --
    -- this is a requirement from cz runtime : controllerClass must be =NULL
    --
    set_Attribute(l_xml_root_node,'controllerClass','');

    --
    -- returns cloned DOM subtree
    --
    --l_new_xml_root_node := xmldom.cloneNode(l_xml_root_node, TRUE);
    l_new_xml_root_node := cloneNode(l_xml_root_node, p_parent_xml_node);

    g_dom_elements_tbl(TO_NUMBER(p_ui_node.element_id)) := l_new_xml_root_node;

    IF xmldom.getNodeName(p_parent_xml_node) IN('oa:header','oa:stackLayout',
      'oa:flowLayout','oa:tableLayout','oa:rowLayout') THEN

      l_ui_contents_xml_node := getUIContents(p_parent_xml_node);
      l_out_xml_node := xmldom.appendChild(l_ui_contents_xml_node,
                                           l_new_xml_root_node);
    ELSE
      l_out_xml_node := xmldom.appendChild(p_parent_xml_node,
                                           l_new_xml_root_node);
    END IF;

    RETURN l_out_xml_node;

  END create_UIXML_Region;

  --
  -- replace XML JRAD element
  --
  FUNCTION replace_UIXML_Element(p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                 p_parent_xml_node     xmldom.DOMNode,
                                 p_xml_node_to_replace xmldom.DOMNode)
    RETURN xmldom.DOMNode IS

    l_subtree_doc           xmldom.DOMDocument;
    l_xml_root_node         xmldom.DOMNode;
    l_new_xml_root_node     xmldom.DOMNode;
    l_out_xml_node          xmldom.DOMNode;
    l_tabxml_uicontens_node xmldom.DOMNode;
    l_tabxml_node           xmldom.DOMNode;
    l_xml_node              xmldom.DOMNode;
    l_parent_xml_node       xmldom.DOMNode;
    l_child_nodes_tbl       xmldom.DOMNodeList;
    l_jrad_doc              CZ_UI_TEMPLATES.jrad_doc%TYPE;
    l_node                  CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_user_attribute4       VARCHAR2(4000);
    l_user_attribute        VARCHAR2(4000);
    l_drilldown_text_id     NUMBER;
    l_ui_action_id          NUMBER;
    l_length                NUMBER;
    l_use_by_reference      BOOLEAN;
    l_curr_parent_xml_node    xmldom.DOMNode;
    l_attribute_value           VARCHAR2(32000);
    l_xml_node_name             VARCHAR2(4000);
    l_old_switcher_xml_id       VARCHAR2(4000);
    l_user_attribute3_value     VARCHAR2(32000);
    l_switcher_casename         VARCHAR2(4000);
    l_new_attribute_value       VARCHAR2(32000);
    l_switcher_xml_id           VARCHAR2(4000);
    l_uicase_name               VARCHAR2(4000);


  BEGIN

    l_node := get_Model_Node_By_Persist_Id(p_ui_node.persistent_node_id,g_UI_Context.devl_project_id);

    IF p_ui_node.ctrl_template_id IS NULL AND p_ui_node.element_type=G_UI_DRILLDOWN_NODE_TYPE THEN
      BEGIN
        l_new_xml_root_node := xmldom.removeChild(p_parent_xml_node,p_xml_node_to_replace);
      EXCEPTION
        WHEN OTHERS THEN
          l_tabxml_node := find_Table_Of_XML_Node(p_parent_xml_node, p_ui_node.element_id);
          IF NOT(xmldom.IsNull(l_tabxml_node)) THEN
            l_tabxml_uicontens_node := getUIContents(l_tabxml_node);
            l_new_xml_root_node := xmldom.removeChild(l_tabxml_uicontens_node,p_xml_node_to_replace);
          END IF;
      END;
      RETURN p_parent_xml_node;
    END IF;

    l_use_by_reference := is_Used_By_Reference(p_detailed_type_id => l_node.detailed_type_id,
                                               p_ctrl_template_id => p_ui_node.ctrl_template_id);

    l_user_attribute4 := get_Attribute_Value(p_xml_node_to_replace, G_USER_ATTRIBUTE4_NAME);
    l_user_attribute :=  get_User_Attribute(l_user_attribute4, 'elementType');

    IF l_user_attribute IS NOT NULL AND (NOT l_user_attribute = '6011') THEN
      l_use_by_reference := FALSE;
    END IF;

    l_jrad_doc := get_JRAD_Name(p_template_id => p_ui_node.ctrl_template_id);

    l_subtree_doc := parse_JRAD_Document(l_jrad_doc);

    IF xmldom.isNull(l_subtree_doc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_jrad_doc,
                        p_fatal_error  => TRUE);
       RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- get subdocument's root node
    --
    l_xml_root_node := xmldom.makeNode(xmldom.getDocumentElement(l_subtree_doc));

    --
    -- remove common attributes of container and subtree
    --
    remove_TopLevel_Attributes(l_xml_root_node);

    --
    -- set Attributes for this subtree = Template
    --
    set_Template_Attributes(p_xml_root_node => l_xml_root_node,
                            p_ui_node       => p_ui_node);

   IF l_use_by_reference  THEN
      --
      -- returns cloned DOM subtree
      --
      --l_new_xml_root_node := xmldom.cloneNode(l_xml_root_node,TRUE);
      l_new_xml_root_node := cloneNode(l_xml_root_node, p_parent_xml_node);


      --
      -- set "extends" attribute
      --
      xmldom.setAttribute(xmldom.makeElement(l_new_xml_root_node),'extends',l_jrad_doc);

      l_user_attribute4 := get_Attribute_Value(l_new_xml_root_node,
                                               G_USER_ATTRIBUTE4_NAME);
      IF l_user_attribute4 IS NOT NULL THEN
        set_User_Attribute(p_cz_attribute_name    => 'name',
                           p_cz_attribute_value   => p_ui_node.name,
                           px_xml_attribute_value => l_user_attribute4);
        IF p_ui_node.element_signature_id IS NOT NULL THEN
           set_User_Attribute(p_cz_attribute_name    => 'elementType',
                              p_cz_attribute_value   => '6011',
                              px_xml_attribute_value => l_user_attribute4);

        END IF;
        set_Attribute(l_new_xml_root_node,
                      G_USER_ATTRIBUTE4_NAME,
                      l_user_attribute4);

      END IF;

      --
      -- remove content of template subtree
      --
      l_child_nodes_tbl:=xmldom.getChildNodes(l_new_xml_root_node);

      --
      -- we need to get length of array of child nodes
      -- to go through the array in loop
      --
      l_length := xmldom.getLength(l_child_nodes_tbl);
      FOR k IN 0..l_length-1
      LOOP
        --
        -- get next child DOM node
        --
        l_xml_node := xmldom.item(l_child_nodes_tbl, k);
        l_out_xml_node:=xmldom.removeChild(l_new_xml_root_node,l_xml_node);
      END LOOP;

    ELSE  -- use by Copy
      l_child_nodes_tbl := xmldom.getElementsByTagName(xmldom.makeElement(l_xml_root_node), '*');
      l_length := xmldom.getLength(l_child_nodes_tbl);
      IF (l_length > 0) THEN
        FOR k IN 0..l_length-1
        LOOP
          --
          -- get next child DOM node
          --
          l_xml_node := xmldom.item(l_child_nodes_tbl, k);

          IF p_ui_node.ctrl_template_id=g_DRILLDOWN_TEMPLATE_ID THEN

            IF attribute_Value(l_xml_node, 'source') IS NULL AND
               g_UI_Context.DRILLDOWN_IMAGE_URL IS NOT NULL THEN
               set_Attribute(l_xml_node,
                             'source',
                              g_UI_Context.DRILLDOWN_IMAGE_URL);
            END IF;

            l_user_attribute := get_Attribute_Value(l_xml_node,
                                                   G_USER_ATTRIBUTE3_NAME);

            IF l_user_attribute IS NOT NULL THEN

              IF  g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID IS NOT NULL THEN

                 l_drilldown_text_id := copy_Intl_Text(g_UI_Context.DRILLDOWN_CONTROL_TEXT_ID,
                                                       g_UI_Context.ui_def_id,
                                                       p_ui_node.page_id, p_ui_node.element_id);

                 set_User_Attribute(p_cz_attribute_name    => 'captionIntlTextId',
                                    p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                                    px_xml_attribute_value => l_user_attribute);

                 set_User_Attribute(p_cz_attribute_name    => 'rolloverIntlTextId',
                                    p_cz_attribute_value   => TO_CHAR(l_drilldown_text_id),
                                    px_xml_attribute_value => l_user_attribute);

               END IF;


               BEGIN
                 l_ui_action_id := get_UI_Action_Id(p_ui_node);
               EXCEPTION
                 WHEN OTHERS THEN
                    NULL;
               END;

               IF l_ui_action_id IS NOT NULL THEN

                 set_User_Attribute(p_cz_attribute_name    => 'actionId',
                                    p_cz_attribute_value   => TO_CHAR(l_ui_action_id),
                                    px_xml_attribute_value => l_user_attribute);

               END IF;

               set_Attribute(l_xml_node,G_USER_ATTRIBUTE3_NAME,l_user_attribute);

             END IF;     -- end of IF l_user_attribute IS NOT NULL
          END IF;   -- end of IF p_ui_node.ctrl_template_id=g_DRILLDOWN_TEMPLATE_ID THEN

          IF k > 0 THEN

            l_curr_parent_xml_node := xmldom.getParentNode(l_xml_node);

            l_attribute_value := get_Attribute_Value(l_xml_node, G_ID_ATTRIBUTE);

            l_xml_node_name := xmldom.getNodeName(l_xml_node);

            IF l_attribute_value IS NOT NULL THEN
              l_new_attribute_value := handle_JRAD_Id(l_attribute_value,p_ui_node.element_id);
              l_new_attribute_value := REPLACE(REPLACE(l_new_attribute_value,'_czt','_czn'), '_czc','_czn');
              set_Attribute(xmldom.makeElement(l_xml_node),G_ID_ATTRIBUTE, l_new_attribute_value);
            END IF;

            --
            -- set value of user attribute "switcherDefaultCaseName" to new jrad id of <oa:switcher>
            --
            IF xmldom.getNodeName(l_xml_node)='oa:switcher' THEN
              l_old_switcher_xml_id := l_attribute_value;
              l_user_attribute3_value := get_Attribute_Value(l_xml_node, G_USER_ATTRIBUTE3_NAME);
              l_switcher_casename := get_User_Attribute(l_user_attribute3_value ,'switcherDefaultCaseName');
              l_switcher_casename := REPLACE(l_switcher_casename,l_attribute_value, l_new_attribute_value);
              l_switcher_casename := REPLACE(REPLACE(l_switcher_casename,'_czt','_czn'), '_czc','_czn');
              set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                                 p_cz_attribute_value   => l_switcher_casename,
                                 px_xml_attribute_value => l_user_attribute3_value);

              set_Attribute(l_xml_node,
                            G_USER_ATTRIBUTE3_NAME,
                            l_user_attribute3_value);
            END IF;

            --
            -- set value of attribute "name" of <ui:case> to id of parent <oa:switcher>
            --
            IF (l_xml_node_name='ui:case' AND xmldom.getNodeName(l_curr_parent_xml_node)='oa:switcher') THEN
              l_switcher_xml_id := get_Attribute_Value(l_curr_parent_xml_node, G_ID_ATTRIBUTE);
              l_uicase_name     :=  get_Attribute_Value(l_xml_node, 'name');
              set_Attribute(xmldom.makeElement(l_xml_node),
                            'name',
                            REPLACE(REPLACE(REPLACE(l_uicase_name,l_old_switcher_xml_id,l_switcher_xml_id),'_czt','_czn'), '_czc', '_czn'));
              handle_UI_CASE_Id(l_xml_node);
            END IF;

            --
            -- if current tag is <oa:stackLayout>
            -- then replace old id with new one
            --
            IF (l_xml_node_name='oa:stackLayout' AND
               xmldom.getNodeName(l_curr_parent_xml_node)='ui:case') AND l_attribute_value IS NOT NULL THEN
              set_Attribute(xmldom.makeElement(l_xml_node),
                            G_ID_ATTRIBUTE,
                           REPLACE(REPLACE(get_Attribute_Value(l_curr_parent_xml_node, 'name'),'_czt','_czn'),'_czc','_czn'));
            END IF;
          END IF; -- end of  IF k > 0 THEN

        END LOOP;
      END IF; -- end of IF (l_length > 0) THEN

      --l_new_xml_root_node := xmldom.cloneNode(l_xml_root_node, TRUE);
      l_new_xml_root_node := cloneNode(l_xml_root_node, p_parent_xml_node);


      l_user_attribute4 := get_Attribute_Value(l_new_xml_root_node,
                                               G_USER_ATTRIBUTE4_NAME);
      IF l_user_attribute4 IS NOT NULL THEN

        set_User_Attribute(p_cz_attribute_name    => 'name',
                           p_cz_attribute_value   => p_ui_node.name,
                           px_xml_attribute_value => l_user_attribute4);

        IF p_ui_node.element_signature_id IS NOT NULL THEN
           set_User_Attribute(p_cz_attribute_name    => 'elementType',
                              p_cz_attribute_value   => TO_CHAR(p_ui_node.element_signature_id),
                              px_xml_attribute_value => l_user_attribute4);

        END IF;

        set_Attribute(l_new_xml_root_node,
                      G_USER_ATTRIBUTE4_NAME,
                      l_user_attribute4);

      END IF;

    END IF; -- end of use by Copy

    l_parent_xml_node := xmldom.getParentNode(p_xml_node_to_replace);
    IF g_using_new_UI_refresh THEN
      g_dom_elements_tbl.DELETE(TO_NUMBER(p_ui_node.element_id));
      g_dom_elements_tbl(TO_NUMBER(p_ui_node.element_id)) := l_new_xml_root_node;
      l_new_xml_root_node := xmldom.replaceChild(l_parent_xml_node,l_new_xml_root_node, p_xml_node_to_replace);
    ELSE
    BEGIN
      l_new_xml_root_node := xmldom.replaceChild(p_parent_xml_node,l_new_xml_root_node, p_xml_node_to_replace);
    EXCEPTION
      WHEN OTHERS THEN
        l_tabxml_node := find_Table_Of_XML_Node(p_parent_xml_node, p_ui_node.element_id);
        IF NOT(xmldom.IsNull(l_tabxml_node)) THEN
          l_tabxml_uicontens_node := getUIContents(l_tabxml_node);
          l_new_xml_root_node := xmldom.replaceChild(l_tabxml_uicontens_node, l_new_xml_root_node, p_xml_node_to_replace);
        END IF;
    END;
    END IF;
    RETURN p_parent_xml_node;

  EXCEPTION
    WHEN OTHERS THEN
      DEBUG('replace_UIXML_Element() : '||SQLERRM);
      RETURN p_parent_xml_node;
  END replace_UIXML_Element;

  --vsingava IM-ER
  PROCEDURE change_to_basic_Layout(p_xml_node xmldom.DOMNode,
                                   p_user_attribute4 VARCHAR2,
                                   p_page_id NUMBER,
                                   p_amn_node CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS
    l_layout_region_type VARCHAR2(10);
    l_element_type VARCHAR2(10);
    l_new_element_type VARCHAR2(10);
    l_view_name VARCHAR2(255);
    l_user_attribute1 VARCHAR2(2000);
    l_temp_value VARCHAR2(255);
  BEGIN

    l_layout_region_type := get_User_Attribute(p_user_attribute4, 'layoutRegionType');
    l_element_type := get_User_Attribute(p_user_attribute4, 'elementType');

    IF l_element_type = '6079' THEN
      l_new_element_type := '6006';
    ELSIF l_element_type = '6080' THEN
      l_new_element_type := '6004';
    ELSIF l_element_type = '6081' THEN
      l_new_element_type := '6007';
    ELSIF l_element_type = '6082' THEN
      l_new_element_type := '6003';
    ELSE
      -- l_element_type = '6083'
      l_new_element_type := '6001';
    END IF;

    set_user_attribute(p_xml_node,
                       G_USER_ATTRIBUTE4_NAME,
                       'layoutRegionType',
                       '0');

    set_user_attribute(p_xml_node,
                       G_USER_ATTRIBUTE4_NAME,
                       'elementType',
                       l_new_element_type);

    l_user_attribute1 := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE1_NAME);

    IF NOT(l_user_attribute1='model_path=%modelPath' OR l_user_attribute1 IS NULL) THEN
      -- This element has an AMN. So we need to change the view names also
      l_temp_value := remove_user_attribute(p_xml_node, G_USER_ATTRIBUTE3_NAME, 'nodeChildrenView');
      l_view_name := get_View_Name(p_amn_node, l_temp_value);
      set_user_attribute(p_xml_node,
                         G_USER_ATTRIBUTE3_NAME,
                         'nodeView',
                         l_view_name);

    END IF;


  END change_to_basic_Layout;



  PROCEDURE refresh_Model_Path(p_ui_element_id       VARCHAR2,
                               p_ui_page_id          NUMBER,
                               p_base_persistent_node_id NUMBER, --vsingava IM-ER
                               p_base_expl_id NUMBER,
                               p_persistent_node_id  NUMBER,
                               p_xml_node_to_refresh xmldom.DOMNode) IS

    l_new_model_path        VARCHAR2(32000);
    l_current_model_path    VARCHAR2(32000);
    l_user_attribute3       VARCHAR2(32000);
    l_ui_node_expl_id       NUMBER;
    l_ui_action_id          NUMBER;

  BEGIN

    IF p_persistent_node_id IS NOT NULL THEN
      --
      -- get value of "user:attribute1"
      --
      l_current_model_path  := get_Attribute_Value(p_xml_node_to_refresh,
                                                 G_USER_ATTRIBUTE1_NAME);

      IF l_current_model_path IS NOT NULL THEN

        SELECT model_ref_expl_id INTO l_ui_node_expl_id FROM CZ_UI_PAGE_ELEMENTS
         WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id=p_ui_page_id AND element_id=p_ui_element_id;

        l_new_model_path := get_Runtime_Relative_Path(p_model_id             => g_UI_Context.devl_project_id,
                                                      p_base_persistent_node_id => p_base_persistent_node_id,
                                                      p_base_expl_id         => p_base_expl_id,
                                                      p_persistent_node_id   => p_persistent_node_id,
                                                      p_ui_node_expl_id      => l_ui_node_expl_id);


         IF l_new_model_path IS NOT NULL THEN
          --
          -- attribute1 is always used only for model_path
          --
          set_Attribute(p_xml_node_to_refresh,
                        G_USER_ATTRIBUTE1_NAME,
                        'model_path='||l_new_model_path);
         END IF;

      END IF; -- end of IF l_current_model_path IS NOT NULL
    END IF; -- end of IF p_persistent_node_id IS NOT NULL

    l_user_attribute3  := get_Attribute_Value(p_xml_node_to_refresh,
                                              G_USER_ATTRIBUTE3_NAME);

    IF l_user_attribute3 IS NOT NULL THEN

      BEGIN
        l_ui_action_id := TO_NUMBER(get_User_Attribute(l_user_attribute3,'actionId'));
      EXCEPTION
        WHEN OTHERS THEN
          l_ui_action_id := NULL;
      END;

      IF l_ui_action_id IS NOT NULL THEN
        FOR i IN(SELECT target_persistent_node_id,target_expl_node_id FROM CZ_UI_ACTIONS
                 WHERE ui_def_id=g_UI_Context.ui_def_id AND
                       source_page_id=p_ui_page_id AND
                       element_id=p_ui_element_id AND
                       target_node_path IS NOT NULL AND
                       deleted_flag=G_NO_FLAG)
        LOOP
          l_new_model_path := get_Runtime_Relative_Path(p_model_id             => g_UI_Context.devl_project_id,
                                                        p_base_persistent_node_id => p_base_persistent_node_id,
                                                        p_base_expl_id         => p_base_expl_id,
                                                        p_persistent_node_id   => i.target_persistent_node_id,
                                                        p_ui_node_expl_id      => i.target_expl_node_id);
          IF l_new_model_path IS NOT NULL THEN
            UPDATE CZ_UI_ACTIONS
               SET target_node_path=l_new_model_path
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   source_page_id=p_ui_page_id AND
                   element_id=p_ui_element_id AND
                   target_node_path<>l_new_model_path;
          END IF;
        END LOOP;
      END IF; -- end of IF l_action_id IS NOT NULL ...

    END IF;  -- end of IF l_user_attribute3 IS NOT NULL

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END refresh_Model_Path;

  --vsingava IM-ER
  PROCEDURE refresh_All_Model_Paths(p_xml_doc     xmldom.DOMDocument,
                                    p_page_id     NUMBER) IS

    l_root_node                   xmldom.DOMNode;
    l_pagebase_persistent_node_id NUMBER;
    l_pagebase_expl_id            NUMBER;

    PROCEDURE refresh_paths_recursive(p_xml_node                xmldom.DOMNode,
                                      p_base_persistent_node_id NUMBER,
                                      p_base_expl_id            NUMBER,
                                      p_inherited_persistent_id NUMBER,
                                      p_inherited_expl_id       NUMBER) IS

      l_node                    xmldom.DOMNode;
      l_nodeslist               xmldom.DOMNodeList;
      l_empty_xml_node          xmldom.DOMNode;
      l_length                  NUMBER;
      l_element_id              VARCHAR2(32000);
      l_base_persistent_node_Id NUMBER;
      l_base_expl_id            NUMBER;
      l_inherited_persistent_id NUMBER;
      l_inherited_expl_id       NUMBER;

      l_persistent_node_Id NUMBER;
      l_expl_id            NUMBER;

      l_user_attribute4_value   VARCHAR2(2000);
      l_layout_region_type      VARCHAR2(255);
      l_is_instance_list_layout BOOLEAN := FALSE;
      l_AMN_set                 BOOLEAN := FALSE;
      l_model_node              CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE; --vsingava IM-ER
    BEGIN



      l_nodeslist := xmldom.getChildrenByTagName(xmldom.makeElement(p_xml_node), '*');
      l_length    := xmldom.getLength(l_nodeslist);

      FOR i IN 0..l_length-1
      LOOP

          l_base_persistent_node_Id := p_base_persistent_node_Id;
          l_base_expl_id            := p_base_expl_id;
          l_inherited_persistent_id := p_inherited_persistent_id;
          l_inherited_expl_id       := p_inherited_expl_id;
          l_AMN_set := FALSE;
          l_is_instance_list_layout := FALSE;

          l_node := xmldom.item(l_nodeslist, i);
          l_element_id := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);
          IF l_element_id IS NOT NULL THEN
             BEGIN

               l_user_attribute4_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE4_NAME);
               l_layout_region_type    := get_User_Attribute(l_user_attribute4_value, 'layoutRegionType');

               IF l_layout_region_type = '6078' THEN
                 -- The node are dealing with is an Instance List Layout Region
                 l_is_instance_list_layout := TRUE;
                 DEBUG('Found an instance list layout region');
               END IF;

               BEGIN

                 SELECT persistent_node_id, model_ref_expl_id INTO l_persistent_node_id, l_expl_id
                   FROM CZ_UI_PAGE_ELEMENTS
                 WHERE ui_def_id=g_UI_Context.ui_def_id AND
                       page_id=p_page_id AND
                       element_id=l_element_id;

                 -- This element has an AMN associated to it directly
                 l_inherited_persistent_id := l_persistent_node_id;
                 l_inherited_expl_id := l_expl_id;
                 l_AMN_set := TRUE;

               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   -- This node does not have an AMN set directly. So use the inherited values
                   l_persistent_node_id := p_inherited_persistent_id;
                   l_expl_id := p_inherited_expl_id;
               END;

               IF l_is_instance_list_layout THEN
                 -- check if the AMN is still instantiable
                 l_model_node := getNodeByPersistentAndExplId(l_persistent_node_id, l_expl_id);
                 IF( l_model_node.instantiable_flag = G_MANDATORY_INST_TYPE ) THEN
                   DEBUG('Element ' || l_element_id || ' changes from instance list to basic layout');

                   -- The element should be changed from Instance List Layout to basic layout
                   change_to_basic_Layout(l_node, l_user_attribute4_value, p_page_id, l_model_node);
                 ELSE
                   -- The AMN is still instantiable. Change the base node ids for the next level of recursion.
                   l_base_persistent_node_Id := l_persistent_node_id;
                   l_base_expl_id := l_expl_id;
                 END IF;

               END IF;

               IF l_AMN_set THEN
                 refresh_Model_Path(p_ui_element_id      => l_element_id,
                                    p_ui_page_id          => p_page_id,
                                    p_base_persistent_node_id => p_base_persistent_node_Id,
                                    p_base_expl_id => p_base_expl_id,
                                    p_persistent_node_id  => l_persistent_node_id,
                                    p_xml_node_to_refresh => l_node);
               ELSE
                 refresh_Model_Path(p_ui_element_id       => l_element_id,
                                    p_ui_page_id          => p_page_id,
                                    p_base_persistent_node_id => p_base_persistent_node_Id,
                                    p_base_expl_id => p_base_expl_id,
                                    p_persistent_node_id  => NULL,
                                    p_xml_node_to_refresh => l_node);
               END IF;
             END;

          END IF;

          refresh_paths_recursive(l_node,
                                  l_base_persistent_node_Id,
                                  l_base_expl_id,
                                  l_inherited_persistent_id,
                                  l_inherited_expl_id);

      END LOOP;

    END refresh_paths_recursive;

  BEGIN

    l_root_node := xmldom.makeNode(xmldom.getDocumentElement(p_xml_doc));

    DEBUG('In refresh all model paths: ' || p_page_Id);

    SELECT persistent_node_id,pagebase_expl_node_id
      INTO l_pagebase_persistent_node_id, l_pagebase_expl_id
      FROM CZ_UI_PAGES
     WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id=p_page_id;

    refresh_paths_recursive (l_root_node,
                             l_pagebase_persistent_node_id,
                             l_pagebase_expl_id,
                             l_pagebase_persistent_node_id,
                             l_pagebase_expl_id);

  END refresh_All_Model_Paths;

  ---------------------------------------------------------------------
  ------------------- JDR DOC BUILDER / XML Parsing -------------------
  ---------------------------------------------------------------------

  --
  -- get attributes of a given DOM node
  -- Parameters : p_node - DOM node
  -- Return     : array of attributes in format of  attributes_tbl_type array
  --
  FUNCTION get_Attributes(p_node IN xmldom.DOMNode)
    RETURN attributes_tbl_type IS

    l_attr_tbl     attributes_tbl_type;
    l_node_map_tbl xmldom.DOMNamedNodeMap;
    l_node_attr    xmldom.DOMNode;
    l_index        NUMBER;
    l_length       NUMBER;

  BEGIN
    l_node_map_tbl := xmldom.getAttributes(p_node);
    IF (xmldom.isNull(l_node_map_tbl) = FALSE) THEN
      l_length := xmldom.getLength(l_node_map_tbl);
      --
      -- loop through attributes
      --
      l_index := 1;
      FOR i IN 0 .. l_length - 1
      LOOP
        l_node_attr := xmldom.item(l_node_map_tbl, i);
        l_attr_tbl(l_index).NAME := xmldom.getNodeName(l_node_attr);
        l_attr_tbl(l_index).VALUE := xmldom.getNodeValue(l_node_attr);
        l_index := l_index + 1;
      END LOOP;
    END IF;
    RETURN l_attr_tbl;
  END get_Attributes;

  --
  -- set attributes for JRAD doc builder element p_jraddoc_node
  -- to attributes of DOM node p_node
  -- so this means that we just copy all attributes from DOM Node p_node
  -- to attributes of jdr_docbuilder.Element p_jraddoc_node
  -- it is used when DOM tree is converted to JRAD document
  --  Parameters : p_node - DOM node
  --               p_jraddoc_node - JRAD doc builder element
  -- Notes : it is not used in UI Generation/UI Refresh process directly
  --
  PROCEDURE set_Attributes(p_node         xmldom.DOMNode,
                           p_jraddoc_node jdr_docbuilder.Element) IS

    l_attr_tbl attributes_tbl_type;

  BEGIN
    l_attr_tbl := get_Attributes(p_node);
    IF l_attr_tbl.COUNT > 0 THEN
      FOR l IN l_attr_tbl.FIRST .. l_attr_tbl.LAST
      LOOP
        jdr_docbuilder.setAttribute(p_jraddoc_node,
                                    l_attr_tbl(l).NAME,
                                    l_attr_tbl(l).VALUE);
      END LOOP;
      l_attr_tbl.DELETE;
    END IF;
  END set_Attributes;

  --
  -- create JRAD element based on a given VARCHAR2 string
  -- which must be in the following form :
  --  <NS>:<Tag>
  -- Example : 'oa:button'
  --
  -- Parameters : p_node_name - VARCHAR2 string which contains string
  -- described above
  --
  FUNCTION createElement(p_node_name IN VARCHAR2)
    RETURN jdr_docbuilder.Element IS

    l_ns VARCHAR2(255);
    l_el VARCHAR2(255);

  BEGIN
    l_ns := SUBSTR(p_node_name, 1, INSTR(p_node_name, ':'));
    l_el := SUBSTR(p_node_name, INSTR(p_node_name, ':') + 1);

    RETURN jdr_docbuilder.createElement(l_ns, l_el);
  END createElement;

  --
  -- recursive procedure which
  -- scans DOM tree and create a corresponding JRAD document
  -- Parameters :
  --  p_nodeList - list of DOM nodes of the current level in DOM tree
  --  p_groupingTag - identifies XML grouping tag
  --  p_parent      - identifes parent JRAD docbuilder element
  --
  PROCEDURE traverse_DOM_Tree(p_nodeList    xmldom.DOMNodeList,
                              p_groupingTag VARCHAR2,
                              p_parent      jdr_docbuilder.Element) IS

    l_next_level_tbl xmldom.DOMNodeList;
    l_node           xmldom.DOMNode;
    l_parent_xml_node xmldom.DOMNode;
    l_attr_tbl       attributes_tbl_type;
    l_child          jdr_docbuilder.Element;
    l_tag_name       VARCHAR2(255);
    l_parent_tag_name VARCHAR2(255);
    l_grouping_tag   VARCHAR2(255);
    l_ns             VARCHAR2(255);
    l_gr             VARCHAR2(255);
    l_attr_value     VARCHAR2(32000);
    l_st             VARCHAR2(1) := '';
    l_length         NUMBER;

  BEGIN

    --
    -- now we have a DOM tree of the target JRAD document
    -- and we need to populate JRAD tables by using jdr_docbuilder API
    --
    l_length := xmldom.getLength(p_nodeList);

    FOR i IN 0 .. l_length - 1
    LOOP
      l_node := xmldom.item(p_nodeList, i);

      l_tag_name := xmldom.getNodeName(l_node);

      l_parent_xml_node := xmldom.getParentNode(l_node);

      IF NOT(xmldom.isNull(l_parent_xml_node)) THEN
        l_parent_tag_name := xmldom.getNodeName(l_parent_xml_node);
      END IF;

      l_grouping_tag := '';

      l_attr_tbl     := get_Attributes(l_node);

      IF l_attr_tbl.COUNT = 0 AND l_tag_name NOT IN('ui:firePartialAction') THEN

        --
        -- this is grouping tag
        --
        l_grouping_tag := l_tag_name;

      END IF;

      l_st := NULL;

      IF p_groupingTag IS NOT NULL THEN

        l_child := createElement(l_tag_name);

        l_st := G_YES_FLAG;

        IF l_attr_tbl.COUNT > 0 THEN
          FOR l IN l_attr_tbl.FIRST .. l_attr_tbl.LAST
          LOOP
            l_attr_value := l_attr_tbl(l).VALUE;

              l_attr_value := REPLACE(l_attr_value, G_UMPERS, G_UMPERS||'amp;');
              l_attr_value := REPLACE(l_attr_value, '<', G_UMPERS||'lt;');
              l_attr_value := REPLACE(l_attr_value, '>', G_UMPERS||'gt;');
              l_attr_value := REPLACE(l_attr_value, '"', G_UMPERS||'quot;');
              l_attr_value := REPLACE(l_attr_value, '''', G_UMPERS||'apos;');

            jdr_docbuilder.setAttribute(l_child,
                                        l_attr_tbl(l).NAME,
                                        l_attr_value);
          END LOOP;
          l_attr_tbl.DELETE;
        END IF; -- end of IF l_attr_tbl.COUNT > 0 THEN

        l_ns := SUBSTR(p_groupingTag, 1, INSTR(p_groupingTag, ':'));
        l_gr := SUBSTR(p_groupingTag, INSTR(p_groupingTag, ':') + 1);

        IF l_ns IS NULL THEN
          l_ns := 'jrad:';
        END IF;
        jdr_docbuilder.addChild(p_parent, l_ns, l_gr, l_child);

        /* new jdr_docbuilder function */

      ELSE
       IF (l_tag_name='ui:case' AND
         l_parent_tag_name IN('oa:switcher')) OR
         (l_tag_name='oa:stackLayout' AND l_parent_tag_name = 'ui:case') THEN

          l_child := createElement(l_tag_name);

          l_st := G_YES_FLAG;
          IF l_attr_tbl.COUNT > 0 THEN
            FOR l IN l_attr_tbl.FIRST .. l_attr_tbl.LAST
            LOOP
              l_attr_value := l_attr_tbl(l).VALUE;

              l_attr_value := REPLACE(l_attr_value, G_UMPERS, G_UMPERS||'amp;');
              l_attr_value := REPLACE(l_attr_value, '<', G_UMPERS||'lt;');
              l_attr_value := REPLACE(l_attr_value, '>', G_UMPERS||'gt;');
              l_attr_value := REPLACE(l_attr_value, '"', G_UMPERS||'quot;');
              l_attr_value := REPLACE(l_attr_value, '''', G_UMPERS||'apos;');

              jdr_docbuilder.setAttribute(l_child,
                                          l_attr_tbl(l).NAME,
                                          l_attr_value);

            END LOOP;
            l_attr_tbl.DELETE;
          END IF;

          jdr_docbuilder.addChild(p_parent, l_child);

        END IF;

        NULL;
      END IF; -- end of IF p_groupingTag IS NOT NULL THEN

      l_next_level_tbl := xmldom.getChildNodes(l_node);
      IF NOT(xmldom.isNull(l_next_level_tbl)) AND
         xmldom.getLENGTH(l_next_level_tbl) <> 0 THEN

        IF l_st IS NULL THEN
          traverse_DOM_Tree(l_next_level_tbl,
                            l_grouping_tag,
                            p_parent);
        ELSE
          traverse_DOM_Tree(l_next_level_tbl,
                            l_grouping_tag,
                            l_child);
        END IF;
      END IF;

    END LOOP;

  END traverse_DOM_Tree;

  FUNCTION get_JRADNLS_Lang RETURN VARCHAR2 IS
    l_lang VARCHAR2(255);
  BEGIN
    SELECT ISO_LANGUAGE||'-'||
           ISO_TERRITORY
      INTO l_lang
      FROM FND_LANGUAGES_VL
     WHERE language_code=USERENV('LANG');
    RETURN l_lang;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'EN-US';
  END get_JRADNLS_Lang;

  --
  -- convert DOM Tree to JRAD record sets
  -- by ising DOM methods AND jdr_docbuilder API
  -- Parameters : p_jrad_doc_name - specifies full JRAD name of
  --              document that will be created from DOM tree
  --              which is identified by global DOM Document variable g_DOC
  --
  PROCEDURE convert_DOM_to_JRAD(p_dom_root_node xmldom.DOMNode,
                                p_jrad_doc_name IN VARCHAR2) IS

    l_topLevel      jdr_docbuilder.Element;
    l_status        PLS_INTEGER;
    l_lang          VARCHAR2(255);
  BEGIN

    --g_DOC := p_doc;

    --
    -- refresh global jdr_docbuilder's structures
    --
    jdr_docbuilder.refresh;

    --
    -- remove top level xml attributes - jdrdocbuilder always adds these attributes
    -- so we don't need to have a duplicates
    --
    remove_TopLevel_Attributes(p_dom_root_node);

    l_lang := get_JRADNLS_Lang();
    --
    -- create a target JRAD document
    --
    g_JRADDOC := jdr_docbuilder.createDocument(p_jrad_doc_name, l_lang);

    --
    -- create root element of the target JRAD document
    --
    l_topLevel := createElement(xmldom.getNodeName(p_dom_root_node));

    --
    -- set top level attributes
    --
    set_Attributes(p_dom_root_node, l_topLevel);

    --
    -- set JRAD top level node
    --
    jdr_docbuilder.setTopLevelElement(g_JRADDOC, l_topLevel);

    --
    -- modify the source DOM tree and create the target JRAD document
    -- traverse_DOM_Tree() is recursive procedure
    --
    traverse_DOM_Tree(xmldom.getChildNodes(p_dom_root_node),
                      '',
                      l_topLevel);

    --
    -- finally SAVE the target JRAD document
    --
    l_status := jdr_docbuilder.SAVE;

  END convert_DOM_to_JRAD;

  --
  -- save JRAD document
  --
  PROCEDURE Save_Document(p_xml_doc  xmldom.DOMDocument,
                          p_doc_name IN VARCHAR2) IS
    l_dom_root_node xmldom.DOMNode;
  BEGIN

    --
    -- get Document's root node
    --
    l_dom_root_node := xmldom.makeNode(xmldom.getDocumentElement(p_xml_doc));
    convert_DOM_to_JRAD(p_dom_root_node => l_dom_root_node, p_jrad_doc_name => p_doc_name);

  END Save_Document;

  --
  -- save JRAD document
  --
  PROCEDURE Save_As_Document(p_xml_root_node  xmldom.DOMNode,
                             p_doc_name IN VARCHAR2) IS
  BEGIN

    convert_DOM_to_JRAD(p_dom_root_node => p_xml_root_node, p_jrad_doc_name => p_doc_name);

  END Save_As_Document;

  ---------------------------------------------------------------------
  ----------  end of JDR DOC BUILDER / XML Parsing Part ---------------
  ---------------------------------------------------------------------

  PROCEDURE set_UI_Global_Entities IS
  BEGIN

    IF NVL(g_UI_Context.preserve_model_hierarchy,G_YES_FLAG) = G_YES_FLAG THEN
      g_suppress_refresh_flag := G_NO_FLAG;
    ELSE
      g_suppress_refresh_flag := G_YES_FLAG;
    END IF;

    SELECT root_element_signature_id
      INTO g_DRILLDOWN_ELEM_SIGNATURE_ID
      FROM CZ_UI_TEMPLATES
     WHERE template_id=g_DRILLDOWN_TEMPLATE_ID AND
           ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID AND
           deleted_flag=G_NO_FLAG;

    IF g_DRILLDOWN_TEMPLATE_ID=G_DRILLDOWN_BUTTON_TEMPLATE_ID THEN
       g_DRILLDOWN_B_SIGNATURE_ID := g_DRILLDOWN_ELEM_SIGNATURE_ID;
    ELSE
      SELECT root_element_signature_id
        INTO g_DRILLDOWN_B_SIGNATURE_ID
        FROM CZ_UI_TEMPLATES
       WHERE ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID AND
             template_id=G_DRILLDOWN_BUTTON_TEMPLATE_ID AND
             deleted_flag=G_NO_FLAG;
    END IF;

    SELECT TEMPLATE_TOKEN INTO G_CAPTION_RULE_TOKENNAME FROM CZ_RULES
    WHERE rule_id=G_DEFAULT_CAPTION_RULE_ID;

  END set_UI_Global_Entities;

  --
  -- get UI context
  --
  FUNCTION get_UI_Context(p_ui_def_id IN NUMBER) RETURN CZ_UI_DEFS%ROWTYPE IS
  BEGIN
    RETURN get_UI_Def_Node(p_ui_def_id);
  END get_UI_Context;

  --
  -- set global UI context
  --
  PROCEDURE set_UI_Context(p_ui_def_id IN NUMBER) IS
    l_ui_def_id          NUMBER;
  BEGIN
    l_ui_def_id := p_ui_def_id; -- this is to handle bug in 9i PL/SQL
    g_UI_Context := get_UI_Context(l_ui_def_id);

    IF g_UI_Context.ROWS_PER_TABLE=-1 THEN
      g_UI_Context.ROWS_PER_TABLE := 1000000;
    END IF;

    IF g_UI_CONTEXT.PAGIN_MAXCONTROLS=-1 THEN
      g_UI_CONTEXT.PAGIN_MAXCONTROLS := 1000000;
    END IF;

  END set_UI_Context;

  --
  -- set current global UI Context
  -- ( UI Generation mode )
  --
  FUNCTION create_UI_Context(p_model_id           IN NUMBER,
                             p_master_template_id IN NUMBER DEFAULT NULL,
                             p_ui_name            IN VARCHAR2 DEFAULT NULL,
                             p_description        IN VARCHAR2 DEFAULT NULL,
                             p_show_all_nodes     IN VARCHAR2 DEFAULT NULL,
                             p_create_empty_ui    IN VARCHAR2 DEFAULT NULL)
    RETURN CZ_UI_DEFS%ROWTYPE IS

    l_node                        CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_page_ui_node                CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_page_set_id                 CZ_UI_PAGE_SETS.page_set_id%TYPE;
    l_page_ref_id                 CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_page_set_type               CZ_UI_PAGE_SETS.page_set_type%TYPE;
    l_master_template_id          NUMBER;

  BEGIN
    l_master_template_id := p_master_template_id;  -- this is to handle bug in 9i PL/SQL

    --
    -- set UI context as UI Master Template Setting
    --
    set_UI_Context(l_master_template_id);
    g_UI_Context.from_master_template_id := l_master_template_id;

    IF g_UI_Context.ROWS_PER_TABLE=-1 THEN
      g_UI_Context.ROWS_PER_TABLE := 1000000;
    END IF;
    IF g_UI_CONTEXT.PAGIN_MAXCONTROLS=-1 THEN
      g_UI_CONTEXT.PAGIN_MAXCONTROLS := 1000000;
    END IF;

    --
    -- allocate a new ui_def_id for new UI
    --
    g_UI_Context.ui_def_id               := allocateId('CZ_UI_DEFS_S');
    g_UI_Context.devl_project_id         := p_model_id;
    g_UI_Context.component_id            := p_model_id;
    g_UI_Context.master_template_flag    := G_NO_FLAG;
    g_UI_Context.seeded_flag             := G_NO_FLAG;
    g_UI_Context.ui_style                := G_OA_STYLE_UI;
    g_UI_Context.from_master_template_id := NVL(l_master_template_id,G_DEFAULT_MASTER_TEMPLATE_ID);
    g_UI_Context.empty_ui_flag           := NVL(p_create_empty_ui,G_NO_FLAG);

    IF p_create_empty_ui IS NULL OR p_create_empty_ui='0' THEN
      g_UI_Context.suppress_refresh_flag   := '0';
    ELSE
      g_UI_Context.suppress_refresh_flag   := '1';
    END IF;

    g_UI_Context.persistent_ui_def_id    := g_UI_Context.ui_def_id;
    g_UI_Context.desc_text               := p_description;
    g_UI_Context.model_timestamp         := SYSDATE;
    g_UI_Context.ui_status               := G_NEW_UI_STATUS;
    g_UI_Context.show_all_nodes_flag     := NVL(p_show_all_nodes,G_NO_FLAG);

    IF g_UI_Context.start_url IS NULL THEN
      g_UI_Context.start_url := G_DEFAULT_START_URL;
    END IF;

    IF g_UI_Context.page_layout IS NULL THEN
      g_UI_Context.page_layout := G_DEFAULT_PAGE_LAYOUT;
    END IF;

    g_ui_def_nodes_tbl(g_UI_Context.ui_def_id) := g_UI_Context;

    --
    -- count number of UIs for a given model
    --
    SELECT COUNT(ui_def_id) + 1
      INTO g_UI_Context.tree_seq
      FROM CZ_UI_DEFS
     WHERE component_id = p_model_id AND
           deleted_flag = G_NO_FLAG;

    IF p_ui_name IS NULL THEN
      SELECT NAME || ' User Interface (' || TO_CHAR(g_UI_Context.tree_seq) || ')'
        INTO g_UI_Context.NAME
        FROM CZ_DEVL_PROJECTS
       WHERE devl_project_id = p_model_id;
    ELSE
      g_UI_Context.NAME      := p_ui_name;
    END IF;

    set_UI_Global_Entities();

    --
    -- create local UI Templates if they need to be created
    --
    create_Local_UI_Templates();

    INSERT INTO CZ_UI_DEFS
      (UI_DEF_ID,
       DESC_TEXT,
       NAME,
       DEVL_PROJECT_ID,
       COMPONENT_ID,
       TREE_SEQ,
       UI_STYLE,
       GEN_VERSION,
       TREENODE_DISPLAY_SOURCE,
       GEN_HEADER,
       LOOK_AND_FEEL,
       CONTROLS_PER_SCREEN,
       PRIMARY_NAVIGATION,
       PERSISTENT_UI_DEF_ID,
       MODEL_TIMESTAMP,
       UI_STATUS,
       PAGE_SET_ID,
       START_PAGE_ID,
       ERR_RUN_ID,
       START_URL,
       PAGE_LAYOUT,
       PRICE_UPDATE,
       SEEDED_FLAG,
       MASTER_TEMPLATE_FLAG,
       PRICE_DISPLAY,
       FROM_MASTER_TEMPLATE_ID,
       PAGIN_MAXCONTROLS,
       PAGIN_NONINST,
       PAGIN_NONINST_REFCOMP,
       CONTROL_LAYOUT,
       PAGIN_DRILLDOWNCTRL,
       OUTER_TEMPLATE_USAGE,
       PAGIN_BOMOC,
       BOMUI_LAYOUT,
       BOMQTYINPUTCTRLS,
       CTRLTEMPLUSE_BOM,
       CTRLTEMPLUSE_NONBOM,
       NONBOM_UILAYOUT,
       CTRLTEMPLUSE_COMMON,
       CTRLTEMPLUSE_REQDMSG,
       CTRLTEMPLUSE_OPTMSG,
       MENU_CAPTION_RULE_ID,
       PAGE_CAPTION_RULE_ID,
       PRESERVE_MODEL_HIERARCHY,
       EMPTY_UI_FLAG,
       SHOW_TRAIN,
       PAGINATION_SLOT,
       DRILLDOWN_CONTROL_TEXT_ID,
       DRILLDOWN_IMAGE_URL,
       ROWS_PER_TABLE,
       CTRLTEMPLATEUSE_BUTTONBAR,
       CTRLTEMPLATEUSE_UTILITYPAGE,
       OPTION_SORT_SELECT_FIRST,
       OPTION_SORT_ORDER,
       OPTION_SORT_METHOD,
       SHOW_ALL_NODES_FLAG,
       PAGE_STATUS_TEMPLATE_USAGE,
       suppress_refresh_flag,
       DELETED_FLAG,
       UI_TIMESTAMP_REFRESH,
       DRILLDOWN_TX_TYPE,
       CONTENT_LAST_UPDATE_DATE,
       DISABLE_AUTOOVERRIDE_FLAG
      )
      SELECT g_UI_Context.ui_def_id,
             g_UI_Context.desc_text,
             g_UI_Context.NAME,
             g_UI_Context.devl_project_id,
             g_UI_Context.component_id,
             g_UI_Context.tree_seq,
             g_UI_Context.ui_style,
             G_GEN_VERSION,
             TREENODE_DISPLAY_SOURCE,
             G_GEN_HEADER,
             LOOK_AND_FEEL,
             CONTROLS_PER_SCREEN,
             PRIMARY_NAVIGATION,
             g_UI_Context.persistent_ui_def_id,
             g_UI_Context.model_timestamp,
             g_UI_Context.ui_status,
             g_UI_Context.page_set_id,
             g_UI_Context.start_page_id,
             g_UI_Context.err_run_id,
             g_UI_Context.start_url,
             g_UI_Context.page_layout,
             G_DEFAULT_PRICE_UPDATE,
             '0',
             '0',
             G_DEFAULT_PRICE_DISPLAY,
             g_UI_Context.from_master_template_id,
             PAGIN_MAXCONTROLS,
             PAGIN_NONINST,
             PAGIN_NONINST_REFCOMP,
             CONTROL_LAYOUT,
             PAGIN_DRILLDOWNCTRL,
             OUTER_TEMPLATE_USAGE,
             PAGIN_BOMOC,
             BOMUI_LAYOUT,
             BOMQTYINPUTCTRLS,
             CTRLTEMPLUSE_BOM,
             CTRLTEMPLUSE_NONBOM,
             NONBOM_UILAYOUT,
             CTRLTEMPLUSE_COMMON,
             CTRLTEMPLUSE_REQDMSG,
             CTRLTEMPLUSE_OPTMSG,
             MENU_CAPTION_RULE_ID,
             PAGE_CAPTION_RULE_ID,
             PRESERVE_MODEL_HIERARCHY,
             NVL(p_create_empty_ui, G_NO_FLAG),
             SHOW_TRAIN,
             PAGINATION_SLOT,
             DRILLDOWN_CONTROL_TEXT_ID,
             DRILLDOWN_IMAGE_URL,
             ROWS_PER_TABLE,
             CTRLTEMPLATEUSE_BUTTONBAR,
             CTRLTEMPLATEUSE_UTILITYPAGE,
             OPTION_SORT_SELECT_FIRST,
             OPTION_SORT_ORDER,
             OPTION_SORT_METHOD,
             p_show_all_nodes,
             PAGE_STATUS_TEMPLATE_USAGE,
             g_UI_Context.suppress_refresh_flag,
             DELETED_FLAG,
             SYSDATE,
             DRILLDOWN_TX_TYPE,
             CONTENT_LAST_UPDATE_DATE,
             DISABLE_AUTOOVERRIDE_FLAG
    FROM CZ_UI_DEFS
    WHERE ui_def_id = g_UI_Context.from_master_template_id;

    --
    -- get root model node
    --
    l_node := get_Model_Node(p_model_id);

    --
    -- create root UI page
    --
    l_page_ui_node  := create_UI_Page(p_node          => l_node,
                                      x_page_set_id   => l_page_set_id,
                                      x_page_set_type => l_page_set_type,
                                      x_page_ref_id   => l_page_ref_id);

    g_UI_Context.start_page_id := l_page_ui_node.page_id;
    g_UI_Context.page_set_id   := l_page_set_id;

    UPDATE CZ_UI_DEFS
       SET start_page_id=g_UI_Context.start_page_id,
           page_set_id=g_UI_Context.page_set_id
     WHERE ui_def_id=g_UI_Context.ui_def_id;

    RETURN g_UI_Context;

  END create_UI_Context;

  --
  -- get UI context of target UI
  --
  FUNCTION get_Target_UI_Context(p_ui_def_node  IN CZ_UI_DEFS%ROWTYPE,
                                 p_reference_id IN NUMBER)
   RETURN CZ_UI_DEFS%ROWTYPE IS
    l_init_ui_def_id     NUMBER;
    l_target_ui_def_node CZ_UI_DEFS%ROWTYPE;
    l_old_context        CZ_UI_DEFS%ROWTYPE;
  BEGIN
    l_init_ui_def_id := p_ui_def_node.ui_def_id;
    l_old_context    := g_UI_Context;

    SELECT *
      INTO l_target_ui_def_node
      FROM CZ_UI_DEFS
     WHERE ui_def_id = (SELECT MAX(ui_def_id)
                          FROM CZ_UI_DEFS
                         WHERE devl_project_id = p_reference_id AND
                               ui_status IN (G_PROCESSED_UI_STATUS,G_NEW_UI_STATUS) AND
                               deleted_flag = G_NO_FLAG);

    /* ***  bug #3848809 ***
    IF g_UI_Context.PRIMARY_NAVIGATION=G_MODEL_TREE_MENU AND
       l_target_ui_def_node.PRIMARY_NAVIGATION <> G_MODEL_TREE_MENU THEN

      l_target_ui_def_node := create_UI_Context(p_model_id           => p_reference_id,
                                                p_master_template_id => p_ui_def_node.from_master_template_id,
                                                p_show_all_nodes     => p_ui_def_node.show_all_nodes_flag,
                                                p_create_empty_ui    =>  p_ui_def_node.empty_ui_flag);
      --
      -- set global UI context
      --
      set_UI_Context(l_init_ui_def_id);

      RETURN l_target_ui_def_node;

    ELSE
    */
      RETURN l_target_ui_def_node;
    -- END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      l_target_ui_def_node := create_UI_Context(p_model_id           => p_reference_id,
                                                p_master_template_id => p_ui_def_node.from_master_template_id,
                                                p_show_all_nodes     => p_ui_def_node.show_all_nodes_flag,
                                                p_create_empty_ui    => p_ui_def_node.empty_ui_flag);
      --
      -- set global UI context
      --
      --set_UI_Context(l_init_ui_def_id);
      g_UI_Context := l_old_context;

      RETURN l_target_ui_def_node;
  END get_Target_UI_Context;

  FUNCTION find_CX_On_UI_Page(p_page_id      IN NUMBER,
                              p_component_id IN NUMBER,
                              p_command_name IN VARCHAR2)
    RETURN VARCHAR2 IS

    l_page_persistent_node_id NUMBER;

  BEGIN

    SELECT persistent_node_id INTO l_page_persistent_node_id
    FROM CZ_UI_PAGES
    WHERE page_id=p_page_id AND ui_def_id=g_UI_Context.ui_def_id;

    FOR i IN (SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    page_id IN(SELECT page_id FROM CZ_UI_PAGES
                    WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    persistent_node_id=l_page_persistent_node_id AND deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE)) AND
                    element_type=G_UI_CX_BUTTON_NODE_TYPE AND
                    persistent_node_id=(SELECT persistent_node_id FROM CZ_PS_NODES
                    WHERE ps_node_id=p_component_id)
                    AND deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE))
   LOOP
     FOR k IN(SELECT ui_action_id FROM CZ_UI_ACTIONS
              WHERE ui_def_id=g_UI_Context.ui_def_id AND element_id=i.element_id AND
                    cx_command_name=p_command_name AND deleted_flag=G_NO_FLAG)
     LOOP
       RETURN i.element_id;
     END LOOP;
   END LOOP;
   -- no CX on the page
   RETURN G_NO_FLAG;
  END find_CX_On_UI_Page;

  --
  -- create new CX button
  --
  PROCEDURE add_CX_Button(p_node                IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS

    l_element_id             CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_parent_element_id      CZ_UI_PAGE_ELEMENTS.parent_element_id%TYPE;
    l_ui_action_id           CZ_UI_ACTIONS.ui_action_id%TYPE;
    l_name                   CZ_UI_PAGE_ELEMENTS.name%TYPE;
    l_page_path              VARCHAR2(32000);
    l_ui_intl_text_id        INTEGER;
    l_counter                INTEGER;
    l_new_node               BOOLEAN := FALSE;

    l_pb_model_ref_expl_id   NUMBER;
    l_pb_persistent_node_id  NUMBER;
    l_persistent_id          NUMBER;
    l_ref_model_id           NUMBER;

  BEGIN

    IF p_ui_node.suppress_refresh_flag=G_YES_FLAG THEN
      RETURN;
    END IF;

    FOR i IN(SELECT DISTINCT b.data_value, b.expr_node_id, a.INSTANTIATION_SCOPE, a.name
             FROM CZ_RULES a, CZ_EXPRESSION_NODES b
             WHERE a.devl_project_id=p_node.devl_project_id AND
                   a.component_id=p_node.ps_node_id AND
                   a.rule_type=G_CZ_EXTENTSIONS_RULE_TYPE AND
                   a.deleted_flag=G_NO_FLAG AND
                   a.disabled_flag=G_NO_FLAG AND
                   a.invalid_flag=G_NO_FLAG AND
                   b.rule_id=a.rule_id AND
                   b.deleted_flag=G_NO_FLAG AND
                   b.argument_signature_id=G_EVENT_ON_COMMAND_SIGID AND
                   data_value IS NOT NULL)
    LOOP
      -- do not create a CX for instantiable reference with
      -- instantiation_scope= INSTANCE
      IF p_node.ps_node_type=G_REFERENCE_TYPE AND
         p_node.instantiable_flag NOT IN(G_MANDATORY_INST_TYPE) AND
         i.INSTANTIATION_SCOPE=1 THEN
         add_Error_Message(p_message_name => 'CZ_CX_IS_IN_WRONG_SCOPE',
                            p_token_name1  => 'EVENT_NAME',
                            p_token_value1 => i.data_value,
                            p_token_name2  => 'RULE_NAME',
                            p_token_value2 => i.name,
                            p_fatal_error  => FALSE);
        RETURN;
      END IF;
      IF find_CX_On_UI_Page(p_ui_node.page_id, p_node.ps_node_id, i.data_value) = G_NO_FLAG THEN

        l_element_id := get_Element_Id();
        l_ui_intl_text_id := allocateId('CZ_INTL_TEXTS_S');
        INSERT INTO CZ_INTL_TEXTS
           (INTL_TEXT_ID,
            TEXT_STR,
            DELETED_FLAG,
            SEEDED_FLAG,
            UI_DEF_ID,
            MODEL_ID,
            UI_PAGE_ID,
            UI_PAGE_ELEMENT_ID
            )
        VALUES
           (l_ui_intl_text_id,
            i.data_value,
            G_NO_FLAG,
            G_NO_FLAG,
            g_UI_Context.ui_def_id,
            g_UI_Context.devl_project_id,
            p_ui_node.page_id,
            l_element_id
           );
        g_cx_names_tbl(TO_NUMBER(l_element_id)) := l_ui_intl_text_id;

        IF p_ui_node.parent_element_id IS NULL THEN
          l_parent_element_id := p_ui_node.element_id;
        ELSE
          l_parent_element_id := p_ui_node.parent_element_id;
        END IF;
        l_new_node := TRUE;

        SELECT COUNT(element_id)+1 INTO l_counter FROM CZ_UI_PAGE_ELEMENTS
        WHERE ui_def_id=g_UI_Context.ui_def_id AND
              page_id=p_ui_node.page_id AND
              ctrl_template_id=G_DRILLDOWN_BUTTON_TEMPLATE_ID AND
             deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

       l_name := G_DRILLDOWN_TEMPLATE_NAME||' - '||TO_CHAR(l_counter);

       INSERT INTO CZ_UI_PAGE_ELEMENTS
         (ui_def_id,
         persistent_node_id,
         parent_persistent_node_id,
         region_persistent_node_id,
         pagebase_persistent_node_id,
         page_id,
         base_page_flag,
         seq_nbr,
         ctrl_template_id,
         ctrl_template_ui_def_id,
         element_id,
         parent_element_id,
         element_type,
         instantiable_flag,
         model_ref_expl_id,
         element_signature_id,
         name,
         deleted_flag)
       VALUES
        (p_ui_node.ui_def_id,
         p_node.persistent_node_id,
         p_node.parent_persistent_node_id,
         p_ui_node.region_persistent_node_id,
         p_ui_node.pagebase_persistent_node_id,
         p_ui_node.page_id,
         NULL,
         p_ui_node.seq_nbr+1,
         G_DRILLDOWN_BUTTON_TEMPLATE_ID,
         G_GLOBAL_TEMPLATES_UI_DEF_ID,
         l_element_id,
         l_parent_element_id,
         G_UI_CX_BUTTON_NODE_TYPE,
         NULL,
         p_ui_node.model_ref_expl_id,
         g_DRILLDOWN_B_SIGNATURE_ID,
         l_name,
         G_MARK_TO_ADD);

         l_ui_action_id := allocateId('CZ_UI_ACTIONS_S');

         INSERT INTO CZ_UI_ACTIONS
         (
         ui_action_id
         ,ui_def_id
         ,source_page_id
         ,context_component_id
         ,element_id
         ,render_condition_id
         ,ui_action_type
         ,target_ui_def_id
         ,target_persistent_node_id
         ,target_node_path
         ,target_page_set_id
         ,target_page_id
         ,target_url
         ,frame_name
         ,target_anchor
         ,seeded_flag
         ,cx_command_name
         ,window_parameters
         ,target_window_type
         ,target_window_name
         ,target_expl_node_id
         ,deleted_flag
         )
         VALUES
         (
         l_ui_action_id
         ,p_ui_node.ui_def_id
         ,p_ui_node.page_id
         ,p_node.persistent_node_id
         ,l_element_id
         ,NULL
         ,G_CX_BUTTON_ACTION_TYPE
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,'0'
         ,i.data_value
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,G_NO_FLAG
         );

      END IF;

    END LOOP;

    IF p_node.ps_node_type=G_REFERENCE_TYPE THEN

    FOR i IN(SELECT a.model_ref_expl_id, b.data_value, a.component_id, b.expr_node_id, a.name, a.INSTANTIATION_SCOPE
             FROM CZ_RULES a, CZ_EXPRESSION_NODES b
             WHERE a.devl_project_id=p_node.devl_project_id AND
                   a.component_id IN
               (SELECT ps_node_id FROM CZ_PS_NODES
                WHERE devl_project_id IN
                (SELECT DISTINCT component_id FROM CZ_MODEL_REF_EXPLS
                START WITH model_id=p_node.devl_project_id AND
                           referring_node_id=p_node.ps_node_id AND
                           deleted_flag='0'
                CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND
                         deleted_flag='0' AND PRIOR deleted_flag='0') AND
                deleted_flag='0') AND
                   a.rule_type=G_CZ_EXTENTSIONS_RULE_TYPE AND
                   a.deleted_flag=G_NO_FLAG AND
                   a.disabled_flag=G_NO_FLAG AND
                   a.invalid_flag=G_NO_FLAG AND
                   b.rule_id=a.rule_id AND
                   b.deleted_flag=G_NO_FLAG AND
                   b.argument_signature_id=G_EVENT_ON_COMMAND_SIGID AND
                   data_value IS NOT NULL)
      LOOP

        -- do not create a CX for instantiable reference with
        -- instantiation_scope= INSTANCE
        IF p_node.ps_node_type=G_REFERENCE_TYPE AND
           p_node.instantiable_flag NOT IN(G_MANDATORY_INST_TYPE) AND
           i.INSTANTIATION_SCOPE=1 THEN
          add_Error_Message(p_message_name => 'CZ_CX_IS_IN_WRONG_SCOPE',
                            p_token_name1  => 'EVENT_NAME',
                            p_token_value1 => i.data_value,
                            p_token_name2  => 'RULE_NAME',
                            p_token_value2 => i.name,
                            p_fatal_error  => FALSE);
          RETURN;
        END IF;

        IF find_CX_On_UI_Page(p_ui_node.page_id, p_node.ps_node_id, i.data_value) = G_NO_FLAG THEN

          l_element_id := get_Element_Id();
          l_ui_intl_text_id := allocateId('CZ_INTL_TEXTS_S');
          INSERT INTO CZ_INTL_TEXTS
           (INTL_TEXT_ID,
            TEXT_STR,
            DELETED_FLAG,
            SEEDED_FLAG,
            UI_DEF_ID,
            MODEL_ID,
            UI_PAGE_ID,
            UI_PAGE_ELEMENT_ID)
          VALUES
           (l_ui_intl_text_id,
            i.data_value,
            G_NO_FLAG,
            G_NO_FLAG,
            g_UI_Context.ui_def_id,
            g_UI_Context.devl_project_id,
            p_ui_node.page_id,
            l_element_id
           );
          g_cx_names_tbl(TO_NUMBER(l_element_id)) := l_ui_intl_text_id;

          IF p_ui_node.parent_element_id IS NULL THEN
            l_parent_element_id := p_ui_node.element_id;
          ELSE
            l_parent_element_id := p_ui_node.parent_element_id;
          END IF;

          l_new_node := TRUE;

          INSERT INTO CZ_UI_PAGE_ELEMENTS
         (ui_def_id,
         persistent_node_id,
         parent_persistent_node_id,
         region_persistent_node_id,
         pagebase_persistent_node_id,
         page_id,
         base_page_flag,
         seq_nbr,
         ctrl_template_id,
         ctrl_template_ui_def_id,
         element_id,
         parent_element_id,
         element_type,
         instantiable_flag,
         model_ref_expl_id,
         element_signature_id,
         name,
         deleted_flag)
       VALUES
        (p_ui_node.ui_def_id,
         p_node.persistent_node_id,
         p_node.parent_persistent_node_id,
         p_ui_node.region_persistent_node_id,
         p_ui_node.pagebase_persistent_node_id,
         p_ui_node.page_id,
         NULL,
         p_ui_node.seq_nbr+1,
         G_DRILLDOWN_BUTTON_TEMPLATE_ID,
         G_GLOBAL_TEMPLATES_UI_DEF_ID,
         l_element_id,
         l_parent_element_id,
         G_UI_CX_BUTTON_NODE_TYPE,
         NULL,
         p_ui_node.model_ref_expl_id,
         g_DRILLDOWN_B_SIGNATURE_ID,
         'Button - '||i.data_value,
         G_MARK_TO_ADD);

         l_ui_action_id := allocateId('CZ_UI_ACTIONS_S');

         INSERT INTO CZ_UI_ACTIONS
         (
         ui_action_id
         ,ui_def_id
         ,source_page_id
         ,context_component_id
         ,element_id
         ,render_condition_id
         ,ui_action_type
         ,target_ui_def_id
         ,target_persistent_node_id
         ,target_node_path
         ,target_page_set_id
         ,target_page_id
         ,target_url
         ,frame_name
         ,target_anchor
         ,seeded_flag
         ,cx_command_name
         ,window_parameters
         ,target_window_type
         ,target_window_name
         ,target_expl_node_id
         ,deleted_flag
         )
         VALUES
         (
         l_ui_action_id
         ,p_ui_node.ui_def_id
         ,p_ui_node.page_id
         ,p_node.persistent_node_id
         ,l_element_id
         ,NULL
         ,G_CX_BUTTON_ACTION_TYPE
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,'0'
         ,i.data_value
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,G_NO_FLAG
         );

         -- find model to which model ref expl node with i.model_ref_expl_id belongs to
         FOR k IN(SELECT component_id, ps_node_type FROM CZ_MODEL_REF_EXPLS
                   START WITH model_ref_expl_id=i.model_ref_expl_id
                  CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id AND deleted_flag='0')
         LOOP
           IF k.ps_node_type = CZ_TYPES.PS_NODE_TYPE_REFERENCE THEN
             l_ref_model_id := k.component_id;
             EXIT;
           END IF;
         END LOOP;

         -- find persistent_node_id of PS node which is used in CX binding
         SELECT persistent_node_id INTO l_persistent_id FROM CZ_PS_NODES
          WHERE devl_project_id=l_ref_model_id AND ps_node_id=i.component_id;

         -- find model_ref_expl_id and persistent_node_id of pagebase
         SELECT model_ref_expl_id, persistent_node_id INTO l_pb_model_ref_expl_id, l_pb_persistent_node_id  FROM CZ_UI_PAGE_ELEMENTS
          WHERE ui_def_id=p_ui_node.ui_def_id AND page_id=p_ui_node.page_id AND
                element_id=p_ui_node.parent_element_id;

         -- save runtime relative path of CX button in associative array g_ref_cx_paths_tbl ( UI element_id <-> runtime relative path )
         g_ref_cx_paths_tbl(TO_NUMBER(l_element_id)) := CZ_DEVELOPER_UTILS_PVT.runtime_relative_path(p_base_expl_id => l_pb_model_ref_expl_id,
                                                                                                     p_base_pers_id => l_pb_persistent_node_id,
                                                                                                     p_node_expl_id => i.model_ref_expl_id,
                                                                                                     p_node_pers_id => l_persistent_id);

        END IF;

      END LOOP;

    END IF;

    --
    -- if CX button is added then mark UI page as page
    -- to refresh
    --
    IF l_new_node THEN
      --
      -- mark UI Page as refreshed
      --
      mark_UI_Page_As_Refreshed(p_ui_node.page_id, p_ui_node.ui_def_id);
    END IF;

  END add_CX_Button;

  --
  -- handle CX for those nodes which have no corresponding
  -- records in table CZ_UI_PAGE_ELEMENTS
  --
  PROCEDURE handle_CXs_For_nonUINodes IS

    l_ui_intl_text_id   CZ_INTL_TEXTS.intl_text_id%TYPE;
    l_element_id        CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_parent_element_id CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_ui_action_id      CZ_UI_ACTIONS.ui_action_id%TYPE;

  BEGIN

     FOR option_node IN(SELECT ps_node_id,persistent_node_id,
                               parent_persistent_node_id FROM CZ_UITEMPLS_FOR_PSNODES_V a
                         WHERE devl_project_id=g_UI_Context.devl_project_id AND
                               ui_def_id=g_UI_Context.from_master_template_id AND
                               ps_node_type IN(G_OPTION_TYPE, G_BOM_STANDART_ITEM_TYPE) AND
                               ui_omit=G_NO_FLAG AND deleted_flag=G_NO_FLAG AND
                               EXISTS(SELECT NULL FROM CZ_RULES
                                       WHERE devl_project_id=g_UI_Context.devl_project_id AND
                                             component_id=a.ps_node_id AND
                                             disabled_flag=G_NO_FLAG AND
                                             deleted_flag=G_NO_FLAG))
     LOOP
       FOR parent_ui_node IN(SELECT *
                               FROM CZ_UI_PAGE_ELEMENTS
                              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                                    persistent_node_id=option_node.parent_persistent_node_id AND
                                    deleted_flag NOT IN(G_YES_FLAG, G_MARK_TO_DELETE, G_LIMBO_FLAG))
       LOOP

         FOR i IN(SELECT DISTINCT b.data_value, b.expr_node_id, a.INSTANTIATION_SCOPE, a.NAME
                    FROM CZ_RULES a, CZ_EXPRESSION_NODES b
                   WHERE a.devl_project_id=g_UI_Context.devl_project_id AND
                         a.component_id=option_node.ps_node_id AND
                         a.rule_type=G_CZ_EXTENTSIONS_RULE_TYPE AND
                         a.deleted_flag=G_NO_FLAG AND
                         a.disabled_flag=G_NO_FLAG AND
                         a.invalid_flag=G_NO_FLAG AND
                         b.rule_id=a.rule_id AND
                         b.deleted_flag=G_NO_FLAG AND
                         b.argument_signature_id=G_EVENT_ON_COMMAND_SIGID AND
                         b.data_value IS NOT NULL)
         LOOP
           IF find_CX_On_UI_Page(parent_ui_node.page_id, option_node.ps_node_id, i.data_value) = G_NO_FLAG THEN
             l_element_id := get_Element_Id();

             l_ui_intl_text_id := allocateId('CZ_INTL_TEXTS_S');
             INSERT INTO CZ_INTL_TEXTS
              (INTL_TEXT_ID,
               TEXT_STR,
               DELETED_FLAG,
               SEEDED_FLAG,
               UI_DEF_ID,
               MODEL_ID,
               UI_PAGE_ID,
               UI_PAGE_ELEMENT_ID
              )
             VALUES
             (l_ui_intl_text_id,
              i.data_value,
              G_NO_FLAG,
              G_NO_FLAG,
              g_UI_Context.ui_def_id,
              g_UI_Context.devl_project_id,
              parent_ui_node.page_id,
              l_element_id
             );

            g_cx_names_tbl(TO_NUMBER(l_element_id)) := l_ui_intl_text_id;
            g_ref_cx_paths_tbl(TO_NUMBER(l_element_id)) := get_Model_Path(parent_ui_node)||
            '.'||TO_CHAR(option_node.persistent_node_id);

            IF parent_ui_node.parent_element_id IS NULL THEN
              l_parent_element_id := parent_ui_node.element_id;
            ELSE
              l_parent_element_id := parent_ui_node.parent_element_id;
            END IF;

            INSERT INTO CZ_UI_PAGE_ELEMENTS
             (ui_def_id,
             persistent_node_id,
             parent_persistent_node_id,
             region_persistent_node_id,
             pagebase_persistent_node_id,
             page_id,
             base_page_flag,
             seq_nbr,
             ctrl_template_id,
             ctrl_template_ui_def_id,
             element_id,
             parent_element_id,
             element_type,
             instantiable_flag,
             model_ref_expl_id,
             element_signature_id,
             NAME,
             deleted_flag)
            VALUES
             (g_UI_Context.ui_def_id,
             option_node.persistent_node_id,
             option_node.parent_persistent_node_id,
             parent_ui_node.region_persistent_node_id,
             parent_ui_node.pagebase_persistent_node_id,
             parent_ui_node.page_id,
             NULL,
             parent_ui_node.seq_nbr+1,
             G_DRILLDOWN_BUTTON_TEMPLATE_ID,
             G_GLOBAL_TEMPLATES_UI_DEF_ID,
             l_element_id,
             l_parent_element_id,
             G_UI_CX_BUTTON_NODE_TYPE,
             NULL,
             parent_ui_node.model_ref_expl_id,
             g_DRILLDOWN_B_SIGNATURE_ID,
             G_DRILLDOWN_TEMPLATE_NAME||' - '||l_element_id,
             G_MARK_TO_ADD);

            l_ui_action_id := allocateId('CZ_UI_ACTIONS_S');

            INSERT INTO CZ_UI_ACTIONS
            (
             ui_action_id
             ,ui_def_id
             ,source_page_id
             ,context_component_id
             ,element_id
             ,render_condition_id
             ,ui_action_type
             ,target_ui_def_id
             ,target_persistent_node_id
             ,target_node_path
             ,target_page_set_id
             ,target_page_id
             ,target_url
             ,frame_name
             ,target_anchor
             ,seeded_flag
             ,cx_command_name
             ,window_parameters
             ,target_window_type
             ,target_window_name
             ,target_expl_node_id
             ,deleted_flag
             )
             VALUES
             (
             l_ui_action_id
             ,g_UI_Context.ui_def_id
             ,parent_ui_node.page_id
             ,option_node.persistent_node_id
             ,l_element_id
             ,NULL
             ,G_CX_BUTTON_ACTION_TYPE
            ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,'0'
             ,i.data_value
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,G_NO_FLAG
             );

             mark_UI_Page_As_Refreshed(parent_ui_node.page_id, g_UI_Context.ui_def_id);
           END IF;  -- end of IF find_CX_On_UI_Page

         END LOOP; -- end of loop with index i

       END LOOP; -- end of loop with index parent_ui_node

     END LOOP; -- end of loop with index option_node

  END handle_CXs_For_nonUINodes;


  FUNCTION disabled_for_refresh(p_page_element IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) RETURN BOOLEAN
  IS
    l_dummy VARCHAR2(1);
  BEGIN

    SELECT '1' INTO l_dummy
    FROM DUAL
    WHERE '1' IN (SELECT suppress_refresh_flag
                  FROM cz_ui_page_elements
                  START WITH ui_def_Id = p_page_element.ui_def_id
                  AND page_id = p_page_element.page_id
                  AND element_id = p_page_element.element_id
                  CONNECT BY PRIOR parent_element_id IS NOT NULL
                  AND prior suppress_refresh_flag = G_NO_FLAG
                  AND ui_def_Id = p_page_element.ui_def_id
                  AND page_id = p_page_element.page_id
                  AND prior parent_element_id = element_id);
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END disabled_for_refresh;

  --
  -- handle CX for those nodes which have no corresponding
  -- records in table CZ_UI_PAGE_ELEMENTS
  --
  PROCEDURE handle_CXs IS

    l_ui_intl_text_id   CZ_INTL_TEXTS.intl_text_id%TYPE;
    l_element_id        CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_parent_element_id CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_ui_action_id      CZ_UI_ACTIONS.ui_action_id%TYPE;
    l_ps_node           CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_invalid_flag      VARCHAR2(1);

  BEGIN


     FOR i in (SELECT DISTINCT page_id
               FROM cz_ui_page_elements
               WHERE ui_def_Id = g_UI_Context.ui_def_id
               AND element_type = G_UI_CX_BUTTON_NODE_TYPE
               AND deleted_flag = G_NO_FLAG)
     LOOP
       --DEBUG('asp: Marking page ' || i.page_id || ', ' || g_UI_Context.ui_def_id || ' for refresh ');
       mark_UI_Page_As_Refreshed(i.page_id, g_UI_Context.ui_def_id);
     END LOOP;


     FOR i in (SELECT b.data_value, b.expr_node_id, a.INSTANTIATION_SCOPE, a.NAME,
                 (SELECT persistent_node_id
                  FROM CZ_PS_NODES
                  WHERE devl_project_id = g_UI_Context.devl_project_id
                  AND ps_node_id = a.component_id) persistent_node_Id
               FROM CZ_RULES a, CZ_EXPRESSION_NODES b
               WHERE a.devl_project_id=g_UI_Context.devl_project_id AND
                     a.rule_type=G_CZ_EXTENTSIONS_RULE_TYPE AND
                     b.rule_id=a.rule_id AND
                     b.argument_signature_id=G_EVENT_ON_COMMAND_SIGID AND
                     b.data_value IS NOT NULL AND
                     b.last_update_date > g_UI_Context.UI_TIMESTAMP_REFRESH)
     LOOP
       BEGIN

         SELECT e.element_id INTO l_element_id
         FROM CZ_UI_PAGE_ELEMENTS e
         WHERE ui_def_id = g_UI_Context.ui_def_id AND
               persistent_node_id = i.persistent_node_id AND
               element_type = G_UI_CX_BUTTON_NODE_TYPE AND
               deleted_flag NOT IN (G_YES_FLAG, G_MARK_TO_DELETE) AND
               EXISTS (SELECT NULL FROM CZ_UI_ACTIONS a
                       WHERE a.ui_def_id = e.ui_def_id AND
                             a.source_page_id = e.page_id AND
                             a.element_id = e.element_id AND
                             a.deleted_flag NOT IN (G_YES_FLAG, G_MARK_TO_DELETE) AND
                             a.cx_command_name = i.data_value);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           -- No button for the action; Create one
           FOR j in (SELECT *
                     FROM CZ_UI_PAGE_ELEMENTS e
                     WHERE ui_def_id = g_UI_Context.ui_def_id AND
                           persistent_node_id = i.persistent_node_id AND
                           deleted_flag NOT IN (G_YES_FLAG, G_MARK_TO_DELETE))
          LOOP
            IF NOT disabled_for_refresh(j) THEN
              l_ps_node := get_Model_Node_By_Persist_id(i.persistent_node_id, g_UI_Context.devl_project_id);
              add_CX_button(l_ps_node, j);
              EXIT;
            END IF;
          END LOOP;
       END;
     END LOOP;
  END handle_CXs;

  --
  -- create single UI element
  --
  FUNCTION create_UI_Element(p_node                 IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                             p_parent_ui_node       IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                             p_insert_index         IN NUMBER DEFAULT -1)
    RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE IS

    l_ui_node                 CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_node_exists_in_ui       VARCHAR2(1);
    l_counter                 NUMBER;
    l_parent_seq_nbr          NUMBER;
    l_max_prev_seq_nbr        NUMBER;

  BEGIN

    IF p_parent_ui_node.suppress_refresh_flag=G_YES_FLAG THEN
      RETURN l_ui_node;
    END IF;

    BEGIN
      SELECT G_YES_FLAG INTO l_node_exists_in_ui FROM dual
      WHERE EXISTS(SELECT NULL FROM CZ_UI_PAGE_ELEMENTS
      WHERE ui_def_id=g_UI_Context.ui_def_id AND
            page_id=p_parent_ui_node.page_id AND
            parent_element_id=p_parent_ui_node.element_id AND
            persistent_node_id=p_node.persistent_node_id AND
            element_type IS NULL AND deleted_flag=G_NO_FLAG);
      RETURN l_ui_node;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_ui_node.ui_def_id                   := p_parent_ui_node.ui_def_id;
    l_ui_node.persistent_node_id          := p_node.persistent_node_id;
    l_ui_node.parent_persistent_node_id   := p_node.parent_persistent_node_id;

    l_ui_node.region_persistent_node_id   := p_parent_ui_node.region_persistent_node_id;
    l_ui_node.pagebase_persistent_node_id := p_parent_ui_node.pagebase_persistent_node_id;
    l_ui_node.page_id                     := p_parent_ui_node.page_id;

    IF p_insert_index > 0 THEN
      l_max_prev_seq_nbr := p_insert_index-1;
      l_ui_node.seq_nbr := p_insert_index;
    ELSE
    SELECT NVL(MAX(seq_nbr),0) INTO l_max_prev_seq_nbr  FROM CZ_UI_PAGE_ELEMENTS
    START WITH ui_def_id=g_UI_Context.ui_def_id AND
               page_id=p_parent_ui_node.page_id AND
               element_id=p_parent_ui_node.element_id AND
               deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE)
    CONNECT BY PRIOR ui_def_id=g_UI_Context.ui_def_id AND
       ui_def_id=g_UI_Context.ui_def_id AND PRIOR page_id= p_parent_ui_node.page_id
        AND page_id=p_parent_ui_node.page_id AND PRIOR element_id=parent_element_id AND
        PRIOR deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE) AND
        deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_ui_node.seq_nbr  := l_max_prev_seq_nbr + 1;
    END IF;

    UPDATE CZ_UI_PAGE_ELEMENTS
       SET seq_nbr=seq_nbr+1
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           page_id=p_parent_ui_node.page_id AND
           seq_nbr>l_max_prev_seq_nbr AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_ui_node.element_id                  := get_Element_Id();

    l_ui_node.parent_element_id           := p_parent_ui_node.element_id;

    l_ui_node.ctrl_template_id            := p_node.template_id;
    l_ui_node.ctrl_template_ui_def_id     := p_node.template_ui_def_id;

    l_ui_node.element_type                := G_UI_REGULAR_NODE_TYPE;

    IF p_node.detailed_type_id=CZ_TYPES.UNON_COUNT_FEATURE_TYPEID THEN
      l_ui_node.element_type              := G_UNON_COUNT_FEATURE_TYPEID;
    ELSIF p_node.detailed_type_id=CZ_TYPES.UCOUNT_FEATURE_TYPEID THEN
      l_ui_node.element_type              := G_UCOUNT_FEATURE_TYPEID;
    ELSIF p_node.detailed_type_id=CZ_TYPES.UCOUNT_FEATURE01_TYPEID THEN
      l_ui_node.element_type              := G_UCOUNT_FEATURE01_TYPEID;
    ELSIF p_node.detailed_type_id=CZ_TYPES.UMINMAX_FEATURE_TYPEID THEN
      l_ui_node.element_type              := G_UMINMAX_FEATURE_TYPEID;
    ELSIF p_node.detailed_type_id=CZ_TYPES.UMINMAX_CONNECTOR THEN
      l_ui_node.element_type              := G_UMINMAX_CONNECTOR_TYPEID;
    ELSE
      l_ui_node.element_type              := G_UI_REGULAR_NODE_TYPE;
    END IF;

    l_ui_node.instantiable_flag           := p_node.instantiable_flag;

    IF p_node.detailed_type_id=CZ_TYPES.UMINMAX_CONNECTOR THEN
      IF (p_node.maximum=1 AND p_node.minimum=0) THEN
        l_ui_node.instantiable_flag := G_OPTIONAL_INST_TYPE;
      ELSE
        l_ui_node.instantiable_flag := G_MINMAX_INST_TYPE;
      END IF;
    END IF;

    l_ui_node.model_ref_expl_id           := get_Expl_Id(p_model_id     => p_node.devl_project_id,
                                                         p_ps_node_id   => p_node.ps_node_id,
                                                         p_component_id => p_node.component_id,
                                                         p_ps_node_type => p_node.ps_node_type);
    l_ui_node.element_signature_id        := p_node.root_element_signature_id;
    l_ui_node.deleted_flag                := G_MARK_TO_ADD;

    SELECT COUNT(element_id)+1 INTO l_counter FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          page_id=l_ui_node.page_id AND
          ctrl_template_id=l_ui_node.ctrl_template_id AND
          deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_ui_node.name := p_node.template_name||' - '||TO_CHAR(l_counter);

    --DEBUG('asp:Inserting ' || l_ui_node.element_id || ' at seq ' || l_ui_node.seq_nbr);

    INSERT INTO CZ_UI_PAGE_ELEMENTS
      (ui_def_id,
       persistent_node_id,
       parent_persistent_node_id,
       region_persistent_node_id,
       pagebase_persistent_node_id,
       page_id,
       seq_nbr,
       ctrl_template_id,
       element_id,
       parent_element_id,
       element_type,
       instantiable_flag,
       ctrl_template_ui_def_id,
       model_ref_expl_id,
       element_signature_id,
       name,
       deleted_flag)
    VALUES
      (l_ui_node.ui_def_id,
       l_ui_node.persistent_node_id,
       l_ui_node.parent_persistent_node_id,
       l_ui_node.region_persistent_node_id,
       l_ui_node.pagebase_persistent_node_id,
       l_ui_node.page_id,
       l_ui_node.seq_nbr,
       l_ui_node.ctrl_template_id,
       l_ui_node.element_id,
       l_ui_node.parent_element_id,
       l_ui_node.element_type,
       l_ui_node.instantiable_flag,
       l_ui_node.ctrl_template_ui_def_id,
       l_ui_node.model_ref_expl_id,
       l_ui_node.element_signature_id,
       l_ui_node.name,
       l_ui_node.deleted_flag);

    --
    -- mark UI Page as refreshed
    --
    mark_UI_Page_As_Refreshed(l_ui_node.page_id, l_ui_node.ui_def_id);
    add_CX_Button(p_node     => p_node,
                  p_ui_node  => l_ui_node);

    RETURN l_ui_node;

  END create_UI_Element;

  --
  -- add Instance Management Controls
  --
  PROCEDURE add_Instance_Controls(p_ui_node          IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                  p_parent_ui_node   IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                  p_node             IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

    l_element_id                  CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_element_type                CZ_UI_PAGE_ELEMENTS.element_type%TYPE;
    l_ui_node_name                CZ_UI_PAGE_ELEMENTS.name%TYPE;
    l_parent_seq_nbr              NUMBER;
    l_seq_nbr                     NUMBER;
    l_counter                     NUMBER;
    l_max_prev_seq_nbr            NUMBER;

  BEGIN

    IF p_parent_ui_node.suppress_refresh_flag=G_YES_FLAG THEN
      RETURN;
    END IF;

    SELECT NVL(MAX(seq_nbr),0) INTO l_max_prev_seq_nbr  FROM CZ_UI_PAGE_ELEMENTS
    START WITH ui_def_id=g_UI_Context.ui_def_id AND
               page_id=p_parent_ui_node.page_id AND
               element_id=p_parent_ui_node.element_id AND
               deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE)
    CONNECT BY PRIOR ui_def_id=g_UI_Context.ui_def_id AND
       ui_def_id=g_UI_Context.ui_def_id AND PRIOR page_id= p_parent_ui_node.page_id
        AND page_id=p_parent_ui_node.page_id AND PRIOR element_id=parent_element_id AND
        PRIOR deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE) AND
        deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_seq_nbr  := l_max_prev_seq_nbr + 1;

    UPDATE CZ_UI_PAGE_ELEMENTS
       SET seq_nbr=seq_nbr+1
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           page_id=p_parent_ui_node.page_id AND
           seq_nbr>l_max_prev_seq_nbr AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    IF p_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_COMPONENT_TYPEID,CZ_TYPES.UMINMAX_COMPONENT_TYPEID) THEN
       l_element_type := G_UI_NONBOMADDINST_NODE_TYPE;
    ELSIF p_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN
      l_element_type := G_UI_BOMADDINST_NODE_TYPE;
    ELSE
      NULL;
    END IF;

    l_element_id := get_Element_Id();

    l_ui_node_name := get_UI_Node_Name(p_page_id       => p_parent_ui_node.page_id,
                                       p_template_id   => p_node.template_id,
                                       p_template_name => p_node.template_name);

    INSERT INTO CZ_UI_PAGE_ELEMENTS
              (ui_def_id,
               persistent_node_id,
               parent_persistent_node_id,
               region_persistent_node_id,
               pagebase_persistent_node_id,
               page_id,
               seq_nbr,
               ctrl_template_id,
               element_id,
               parent_element_id,
               element_type,
               instantiable_flag,
               ctrl_template_ui_def_id,
               model_ref_expl_id,
               element_signature_id,
               name,
               deleted_flag)
       VALUES
              (p_ui_node.ui_def_id,
               p_ui_node.persistent_node_id,
               p_ui_node.parent_persistent_node_id,
               p_parent_ui_node.region_persistent_node_id,
               p_parent_ui_node.pagebase_persistent_node_id,
               p_parent_ui_node.page_id,
               l_seq_nbr,
               p_node.template_id,
               l_element_id,
               p_parent_ui_node.element_id,
               l_element_type,
               p_ui_node.instantiable_flag,
               p_node.template_ui_def_id,
               p_ui_node.model_ref_expl_id,
               p_node.root_element_signature_id,
               l_ui_node_name,
               G_MARK_DO_NOT_REFRESH);

    -- delete drilldown associated with the same persistent_node_id
    --
    UPDATE CZ_UI_PAGE_ELEMENTS
       SET deleted_flag=G_MARK_TO_DELETE
     WHERE ui_def_id = p_parent_ui_node.ui_def_id AND
           persistent_node_id=p_ui_node.persistent_node_id AND
           element_type=G_UI_PAGEDRILLDOWN_NODE_TYPE AND
           deleted_flag=G_NO_FLAG;

    mark_UI_Page_As_Refreshed(p_parent_ui_node.page_id, p_parent_ui_node.ui_def_id);

  END add_Instance_Controls;

  --
  -- create Drilldown button
  --
  PROCEDURE create_Drilldown_Button(p_parent_ui_node  IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                    p_ui_node         IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                    p_page_set_id     IN NUMBER) IS

      l_element_id              CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
      l_ui_action_id            CZ_UI_ACTIONS.ui_action_id%TYPE;
      l_seq_nbr                 CZ_UI_PAGE_ELEMENTS.seq_nbr%TYPE;
      l_ui_node_name            CZ_UI_PAGE_ELEMENTS.name%TYPE;

  BEGIN

    IF p_parent_ui_node.suppress_refresh_flag=G_YES_FLAG THEN
      RETURN;
    END IF;

    l_seq_nbr := get_Last_Seq_Nbr(p_parent_ui_node.element_id)+1;

    l_element_id := get_Element_Id();

    g_ELEMENT_COUNTER := g_ELEMENT_COUNTER + 1;

    l_ui_node_name := 'Drilldown Button - '||TO_CHAR(l_seq_nbr);

    IF g_DRILLDOWN_TEMPLATE_ID = G_DRILLDOWN_IMAGE_TEMPLATE_ID THEN
      l_ui_node_name := 'Drilldown Image - '||TO_CHAR(l_seq_nbr);
    ELSIF g_DRILLDOWN_TEMPLATE_ID = G_DRILLDOWN_LABEL_TEMPLATE_ID THEN
      l_ui_node_name := 'Drilldown Label - '||TO_CHAR(l_seq_nbr);
    ELSE
      l_ui_node_name := 'Drilldown Button - '||TO_CHAR(l_seq_nbr);
    END IF;

    INSERT INTO CZ_UI_PAGE_ELEMENTS
      (ui_def_id,
       persistent_node_id,
       parent_persistent_node_id,
       region_persistent_node_id,
       pagebase_persistent_node_id,
       page_id,
       seq_nbr,
       ctrl_template_id,
       element_id,
       parent_element_id,
       element_type,
       instantiable_flag,
       ctrl_template_ui_def_id,
       model_ref_expl_id,
       name,
       element_signature_id,
       deleted_flag)
    VALUES
      (p_parent_ui_node.ui_def_id,
       p_ui_node.persistent_node_id,
       p_ui_node.parent_persistent_node_id,
       p_parent_ui_node.region_persistent_node_id,
       p_parent_ui_node.pagebase_persistent_node_id,
       p_parent_ui_node.page_id,
       l_seq_nbr,
       g_DRILLDOWN_TEMPLATE_ID,
       l_element_id,
       p_parent_ui_node.element_id,
       G_UI_PAGEDRILLDOWN_NODE_TYPE,
       NULL,
       G_GLOBAL_TEMPLATES_UI_DEF_ID,
       NULL,
       l_ui_node_name,
       g_DRILLDOWN_ELEM_SIGNATURE_ID,
       G_MARK_TO_ADD);

    l_ui_action_id := allocateId('CZ_UI_ACTIONS_S');
    INSERT INTO CZ_UI_ACTIONS
      (ui_action_id,
       ui_def_id,
       source_page_id,
       context_component_id,
       element_id,
       ui_action_type,
       target_ui_def_id,
       target_persistent_node_id,
       target_node_path,
       target_page_set_id,
       target_page_id,
       target_expl_node_id,
       seeded_flag,
       deleted_flag)
    VALUES
      (l_ui_action_id,
       p_parent_ui_node.ui_def_id,
       p_parent_ui_node.page_id,
       p_parent_ui_node.region_persistent_node_id,
       l_element_id,
       G_ACTION_CONFIGURE_SUBCOMP,
       NULL,
       p_ui_node.persistent_node_id,
       TO_CHAR(p_ui_node.persistent_node_id),
       p_page_set_id,
       p_ui_node.page_id,
       p_ui_node.model_ref_expl_id,
       G_NO_FLAG,
       G_NO_FLAG);

    mark_UI_Page_As_Refreshed(p_parent_ui_node.page_id, p_parent_ui_node.ui_def_id);

  END create_Drilldown_Button;

  --
  -- check : does this BOM node contain child BOM nodes
  --
  FUNCTION contains_BOM_Nodes(p_ps_node_id IN NUMBER)
    RETURN BOOLEAN IS
    l_ps_node_type NUMBER;
  BEGIN

   SELECT ps_node_type INTO l_ps_node_type FROM CZ_PS_NODES
   WHERE ps_node_id=p_ps_node_id AND deleted_flag=G_NO_FLAG;

    IF l_ps_node_type=G_REFERENCE_TYPE THEN
      RETURN TRUE;
    END IF;

    FOR i IN (SELECT DISTINCT ps_node_type,reference_id FROM CZ_PS_NODES
              WHERE parent_id=p_ps_node_id AND
                    deleted_flag=G_NO_FLAG AND ui_omit=G_NO_FLAG AND
                    (ps_node_type IN(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE,G_BOM_STANDART_ITEM_TYPE) OR
                     ps_node_type=G_REFERENCE_TYPE))
    LOOP
      IF i.ps_node_type=G_REFERENCE_TYPE THEN
         SELECT ps_node_type INTO l_ps_node_type FROM CZ_PS_NODES
         WHERE ps_node_id=i.reference_id;
         IF l_ps_node_type=G_BOM_MODEL_TYPE THEN
           RETURN TRUE;
         END IF;
      ELSE
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END contains_BOM_Nodes;

  PROCEDURE add_BOM_Node
  (
  p_node                  IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
  p_page_id               IN NUMBER,
  p_pagebase_expl_node_id IN NUMBER,
  p_parent_element_id     IN VARCHAR2,
  p_pagebase_persistent_node_id IN NUMBER,
  p_check_child_bom_nodes       IN VARCHAR2 DEFAULT NULL) IS

    l_bom_element_id  CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_ui_node_name    CZ_UI_PAGE_ELEMENTS.name%TYPE;
  BEGIN

      IF p_check_child_bom_nodes IS NULL OR p_check_child_bom_nodes=G_YES_FLAG THEN
        IF NOT(contains_BOM_Nodes(p_node.ps_node_id)) THEN
          RETURN;
        END IF;
      END IF;

      l_bom_element_id := get_Element_Id();

      l_ui_node_name := p_node.template_name||' - 1';

      --DEBUG('asp:Inserting BOM Node ' || l_bom_element_id|| ' at seq ' || 1);
      --
      -- shift all UI elements down , because BOM table will have seq_nbr=1
      --
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET seq_nbr=seq_nbr+1
       WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id=p_page_id AND
             deleted_flag NOT IN(G_YES_FLAG, G_LIMBO_FLAG);


      INSERT INTO CZ_UI_PAGE_ELEMENTS
      (ui_def_id,
       persistent_node_id,
       parent_persistent_node_id,
       region_persistent_node_id,
       pagebase_persistent_node_id,
       page_id,
       seq_nbr,
       ctrl_template_id,
       element_id,
       parent_element_id,
       element_type,
       instantiable_flag,
       ctrl_template_ui_def_id,
       model_ref_expl_id,
       element_signature_id,
       name,
       deleted_flag)
      VALUES
      (g_UI_Context.ui_def_id,
       p_node.persistent_node_id,
       p_node.parent_persistent_node_id,
       p_node.persistent_node_id,
       p_pagebase_persistent_node_id,
       p_page_id,
       1,
       p_node.template_id,
       l_bom_element_id,
       p_parent_element_id,
       G_UI_BOMADDINST_NODE_TYPE,
       p_node.instantiable_flag,
       p_node.template_ui_def_id,
       p_pagebase_expl_node_id,
       p_node.root_element_signature_id,
       l_ui_node_name,
       G_MARK_TO_ADD);

    mark_UI_Page_As_Refreshed(p_page_id, g_UI_Context.ui_def_id);

  END add_BOM_Node;

  --
  -- get Parent Page Data ( page_set_id and page_id )
  --
  PROCEDURE get_Parent_Page_Data
  (
  p_parent_persistent_node_id IN NUMBER,
  p_parent_page_id            IN NUMBER,
  x_page_set_id               OUT NOCOPY NUMBER,
  x_page_id                   OUT NOCOPY NUMBER,
  x_parent_page_set_type      OUT NOCOPY NUMBER,
  x_parent_page_ref_id        OUT NOCOPY NUMBER,
  x_parent_node_depth         OUT NOCOPY NUMBER
  ) IS

  BEGIN

    IF p_parent_persistent_node_id IS NOT NULL THEN

      IF p_parent_page_id IS NULL THEN

        SELECT MIN(page_id)
          INTO x_page_id
          FROM CZ_UI_PAGES
         WHERE ui_def_id = g_UI_Context.ui_def_id AND
               persistent_node_id = p_parent_persistent_node_id AND
               NVL(split_seq_nbr,1)=1 AND
               deleted_flag IN(G_NO_FLAG,G_MARK_TO_ADD,G_MARK_TO_REFRESH);

        IF x_page_id IS NULL THEN
          NULL;
        ELSE
          SELECT page_set_id INTO x_page_set_id
            FROM CZ_UI_PAGES
           WHERE page_id=x_page_id AND
                 ui_def_id = g_UI_Context.ui_def_id;
        END IF;

      ELSE

        x_page_id := p_parent_page_id;

        SELECT page_set_id INTO x_page_set_id
          FROM CZ_UI_PAGES
         WHERE page_id=p_parent_page_id AND
               ui_def_id = g_UI_Context.ui_def_id;

      END IF;

      BEGIN

        SELECT MIN(page_ref_id)
          INTO x_parent_page_ref_id
          FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id = g_UI_Context.ui_def_id AND
               NVL(page_set_id,-1)=NVL(x_page_set_id,-1) AND
               target_page_id=x_page_id AND deleted_flag=G_NO_FLAG;

        SELECT node_depth,page_ref_type INTO x_parent_node_depth,  x_parent_page_set_type
          FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id = g_UI_Context.ui_def_id AND
               page_ref_id=x_parent_page_ref_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF x_page_set_id IS NOT NULL THEN
            SELECT page_set_type INTO x_parent_page_set_type FROM CZ_UI_PAGE_SETS
            WHERE ui_def_id = g_UI_Context.ui_def_id AND page_set_id=x_page_set_id;
          END IF;
          x_parent_node_depth := 1;
      END;

    ELSE

      x_page_set_id := NULL;
      x_page_id     := NULL;
      x_parent_page_ref_id := NULL;
      x_parent_node_depth := 1;
      x_parent_page_set_type := NULL;

    END IF;

  END get_Parent_Page_Data;


  FUNCTION get_new_page_ref_seq(p_node      IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                                p_page_set_id IN NUMBER,
                                p_parent_page_ref_id NUMBER) RETURN NUMBER IS

    l_seq_nbr                   NUMBER;

  BEGIN

    --DEBUG('asp: Getting seq_nbr for ps node ' || p_node.name);

    IF NOT g_using_new_UI_refresh THEN
      SELECT COUNT(*)+1 INTO l_seq_nbr
        FROM CZ_UI_PAGE_REFS
       WHERE ui_def_id=g_UI_Context.ui_def_id AND
             page_set_id = p_page_set_id AND
             parent_page_ref_id=p_parent_page_ref_id AND
             deleted_flag=G_NO_FLAG;

      RETURN l_seq_nbr;
    END IF;

    IF p_node.tree_seq = 1 THEN
      RETURN 1;
    ELSE
      BEGIN
        --DEBUG('asp: Getting seq_nbr for ps node ' || p_node.name || ', tree_seq ' || p_node.tree_seq);
        FOR i IN 1..p_node.tree_seq-1
        LOOP
          FOR j in (SELECT persistent_node_id
                    FROM CZ_PS_NODES
                    WHERE devl_project_id = g_UI_Context.devl_project_id
                    AND parent_id = p_node.parent_id
                    AND tree_seq = p_node.tree_seq-i
                    AND deleted_flag = G_NO_FLAG)
          LOOP
          --DEBUG('asp: predecessor persistent_node_id = ' || l_predecessor_persistent_id);

            SELECT NVL(max(seq_nbr), 0) INTO l_seq_nbr
            FROM CZ_UI_PAGE_REFS
            WHERE ui_def_id = g_UI_Context.ui_def_id
            AND page_set_id = p_page_set_id
            AND parent_page_ref_id = p_parent_page_ref_id
            AND target_persistent_node_id = j.persistent_node_id
            AND deleted_flag = G_NO_FLAG;

            --DEBUG('asp: max predecessorseq_nbr = ' || l_seq_nbr);

            IF l_seq_nbr > 0 THEN
              l_seq_nbr := l_seq_nbr + 1;
              RETURN l_seq_nbr;
            END IF;
          END LOOP;
        END LOOP;

        -- node of the predecesors found in cz_ui_page_refs
        RETURN 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- seq_nbrs in cz_ps_nodes are not correct
          SELECT NVL(count(*), 0) + 1 INTO l_seq_nbr
          FROM CZ_UI_PAGE_REFS
          WHERE ui_def_id = g_UI_Context.ui_def_Id
          AND page_set_id = p_page_set_id
          AND parent_page_ref_id = p_parent_page_ref_id
          AND deleted_flag = G_NO_FLAG;

          RETURN l_seq_nbr;
      END;
    END IF;

  END get_new_page_ref_seq;

  --
  -- create new UI page
  --
  FUNCTION create_UI_Page(p_node                  IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          x_page_set_id           OUT NOCOPY NUMBER,
                          x_page_set_type         OUT NOCOPY NUMBER,
                          x_page_ref_id           OUT NOCOPY NUMBER,
                          p_parent_page_id        IN NUMBER DEFAULT NULL)
    RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE IS

    l_page_node                 CZ_UI_PAGES%ROWTYPE;
    l_bom_element_id            CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_page_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_page_ref_id               CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_parent_page_ref_id        CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_seq_nbr                   CZ_UI_PAGE_REFS.seq_nbr%TYPE;
    l_node_depth                CZ_UI_PAGE_REFS.node_depth%TYPE;
    l_page_set_id               CZ_UI_PAGE_SETS.page_set_id%TYPE;
    l_last_page_id              CZ_UI_PAGES.page_id%TYPE;
    l_parent_page_id            CZ_UI_PAGES.page_id%TYPE;
    l_page_set_type             CZ_UI_PAGE_SETS.page_set_type%TYPE;
    l_ui_node_name              CZ_UI_PAGE_ELEMENTS.name%TYPE;
    l_ref_pagebase_path         CZ_UI_PAGE_REFS.target_path%TYPE;
    l_parent_ui_page_node       CZ_UI_PAGES%ROWTYPE;
    l_ui_page_set_node          CZ_UI_PAGE_SETS%ROWTYPE;
    l_parent_page_persistent_id NUMBER;
    l_page_counter              NUMBER;
    l_pagebase_expl_node_id     NUMBER;
    l_is_inst_node              BOOLEAN := FALSE;
    l_is_drilldown_node         BOOLEAN := FALSE;
    l_create_page_ref           BOOLEAN := TRUE;
    l_is_page                   BOOLEAN := TRUE;

  BEGIN

    l_is_page := is_UI_Page(p_node, l_is_drilldown_node);

    IF l_is_page=FALSE THEN
      RETURN l_page_ui_node ;
    END IF;

    IF g_UI_Context.control_layout=1 THEN
      G_CONTAINER_TEMPLATE_ID := G_2COLS_CONTAINER_TEMPLATE_ID;
    ELSIF g_UI_Context.control_layout=2 THEN
      G_CONTAINER_TEMPLATE_ID := G_3COLS_CONTAINER_TEMPLATE_ID;
    END IF;

    IF p_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) OR
       p_node.virtual_flag=G_NO_FLAG THEN

      l_is_inst_node := TRUE;

    END IF;

    l_pagebase_expl_node_id := get_Expl_Id(p_model_id     => p_node.devl_project_id,
                                           p_ps_node_id   => p_node.ps_node_id,
                                           p_component_id => p_node.component_id,
                                           p_ps_node_type => p_node.ps_node_type);

    -- In cases where a node is to added to a region because of
    -- max_siblings test, the parent UI node may not be bound to the parent
    -- of the new ps node. In such a case, the parent_page_id passed in
    -- may not be that of the parent_ps_node. So we pass in a NULL p_parent_page_id to
    -- get_Parent_page_data so that the right parent_page_id is found and the new
    -- page is added under the correct parent in page refs

    l_parent_page_id := p_parent_page_id;
    l_parent_page_persistent_id := p_node.parent_persistent_node_id;

    IF l_parent_page_id IS NOT NULL THEN
      BEGIN

        SELECT persistent_node_id INTO l_parent_page_persistent_id
        FROM CZ_UI_PAGES
        WHERE ui_Def_id = g_UI_Context.ui_def_id
        AND   page_id = l_parent_page_id;

        IF NOT l_parent_page_persistent_id = p_node.parent_persistent_node_id THEN
          l_parent_page_id := NULL;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_parent_page_id := NULL;
      END;
    END IF;

    get_Parent_Page_Data(p_parent_persistent_node_id => l_parent_page_persistent_id,
                         p_parent_page_id            => l_parent_page_id,
                         x_page_set_id               => l_page_set_id,
                         x_page_id                   => l_last_page_id,
                         x_parent_page_set_type      => l_page_set_type,
                         x_parent_page_ref_id        => l_parent_page_ref_id,
                         x_parent_node_depth         => l_node_depth);

    l_node_depth := l_node_depth + 1;
    IF l_page_set_type IS NULL THEN
      l_page_set_type := g_UI_Context.PRIMARY_NAVIGATION;
    END IF;

    --
    -- if it is root model node or nonvirtual model node
    -- then  create new Page Set
    --
    -- create a new Page Set
    --  List of enumerated Page Set types :
    --    1 - PAGE_FLOW
    --    2 - SINGLE_LEVEL_MENU
    --    3 - MULTI_LEVEL_MENU
    --    4 - MODEL_TREE_MENU
    --
    IF (p_node.parent_id IS NULL OR
       (p_node.virtual_flag=G_NO_FLAG AND
        g_UI_Context.PRIMARY_NAVIGATION NOT IN (G_MODEL_TREE_MENU))) AND
       g_UI_Context.PRIMARY_NAVIGATION NOT IN(G_SINGLE_PAGE)  THEN

      create_Page_Set(p_ui_def_id          => g_UI_Context.ui_def_id,
                      p_page_set_type      => l_page_set_type,
                      p_persistent_node_id => p_node.persistent_node_id,
                      p_model_ref_expl_id  => l_pagebase_expl_node_id,
                      x_page_set_id        => l_page_set_id);

     l_node_depth         := 1;
     l_seq_nbr            := 1;
     l_parent_page_ref_id := NULL;

    END IF;

    --
    -- get num of this page in this UI
    --
    l_page_counter := get_Page_Counter() + 1;

    l_page_node.page_id               := allocateId('CZ_UI_PAGES_S');
    l_page_node.ui_def_id             := g_UI_Context.ui_def_id;
    l_page_node.NAME                  := 'Page-'||TO_CHAR(l_page_counter);
    l_page_node.persistent_node_id    := p_node.persistent_node_id;
    l_page_node.jrad_doc              := generate_JRAD_Page_Name(l_page_counter);

    IF l_is_drilldown_node OR g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_PAGE)THEN
      l_page_node.page_set_id           := NULL;
    ELSE
      l_page_node.page_set_id           := l_page_set_id;
    END IF;

    l_page_node.split_seq_nbr         := 1;
    l_page_node.caption_source        := G_DEFAULT_CAPTION_RULE_ID;

    l_page_node.pagebase_path         := get_Page_Path(p_node.ps_node_id);

    l_page_node.pagebase_expl_node_id := l_pagebase_expl_node_id;
    l_page_node.seeded_flag           := G_NO_FLAG;
    l_page_node.deleted_flag          := G_MARK_TO_ADD;

    INSERT INTO CZ_UI_PAGES
      (page_id,
       ui_def_id,
       NAME,
       persistent_node_id,
       jrad_doc,
       page_set_id,
       split_seq_nbr,
       caption_source,
       pagebase_path,
       pagebase_expl_node_id,
       page_rev_nbr,
       seeded_flag,
       page_status_template_id,
       page_status_templ_uidef_id,
       caption_rule_id,
       deleted_flag)
    VALUES
      (l_page_node.page_id ,
       l_page_node.ui_def_id,
       l_page_node.NAME,
       l_page_node.persistent_node_id,
       l_page_node.jrad_doc,
       l_page_node.page_set_id,
       l_page_node.split_seq_nbr,
       l_page_node.caption_source,
       l_page_node.pagebase_path,
       l_page_node.pagebase_expl_node_id,
       1,
       l_page_node.seeded_flag,
       g_PAGE_STATUS_TEMPLATE_ID,
       G_GLOBAL_TEMPLATES_UI_DEF_ID,
       NULL,
       l_page_node.deleted_flag);

    --
    -- add new UI page to cache
    --
    g_ui_pages_tbl(l_page_node.page_id) := l_page_node;

    l_page_ui_node.ui_def_id                   := g_UI_Context.ui_def_id;
    l_page_ui_node.persistent_node_id          := p_node.persistent_node_id;
    l_page_ui_node.parent_persistent_node_id   := p_node.parent_persistent_node_id;
    l_page_ui_node.region_persistent_node_id   := p_node.persistent_node_id;
    l_page_ui_node.pagebase_persistent_node_id := p_node.persistent_node_id;
    l_page_ui_node.page_id                     := l_page_node.page_id;
    l_page_ui_node.seq_nbr                     := 0;
    l_page_ui_node.ctrl_template_id            := G_CONTAINER_TEMPLATE_ID;
    l_page_ui_node.element_id                  := get_Element_Id();
    l_page_ui_node.parent_element_id           := NULL;
    l_page_ui_node.element_type                := G_UI_PAGE_NODE_TYPE;
    l_page_ui_node.instantiable_flag           := p_node.instantiable_flag;
    l_page_ui_node.ctrl_template_ui_def_id     := G_GLOBAL_TEMPLATES_UI_DEF_ID;
    l_page_ui_node.model_ref_expl_id           := l_page_node.pagebase_expl_node_id;
    l_page_ui_node.base_page_flag              := G_YES_FLAG;

    l_page_ui_node.deleted_flag                := G_MARK_TO_ADD;

    g_ELEMENT_COUNTER   := 0;
    l_page_ui_node.name := 'Page Region - 1';

    INSERT INTO CZ_UI_PAGE_ELEMENTS
      (ui_def_id,
       persistent_node_id,
       parent_persistent_node_id,
       region_persistent_node_id,
       pagebase_persistent_node_id,
       page_id,
       seq_nbr,
       ctrl_template_id,
       element_id,
       parent_element_id,
       element_type,
       instantiable_flag,
       ctrl_template_ui_def_id,
       model_ref_expl_id,
       base_page_flag,
       element_signature_id,
       name,
       deleted_flag)
    VALUES
      (l_page_ui_node.ui_def_id,
       l_page_ui_node.persistent_node_id,
       l_page_ui_node.parent_persistent_node_id,
       l_page_ui_node.region_persistent_node_id,
       l_page_ui_node.pagebase_persistent_node_id,
       l_page_ui_node.page_id,
       l_page_ui_node.seq_nbr,
       l_page_ui_node.ctrl_template_id,
       l_page_ui_node.element_id,
       l_page_ui_node.parent_element_id,
       l_page_ui_node.element_type,
       l_page_ui_node.instantiable_flag,
       l_page_ui_node.ctrl_template_ui_def_id,
       l_page_ui_node.model_ref_expl_id,
       l_page_ui_node.base_page_flag,
       6004,
       l_page_ui_node.name,
       l_page_ui_node.deleted_flag);

    IF p_node.ps_node_type IN(G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE) AND
       NVL(g_UI_Context.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG  THEN

       --  AND contains_BOM_Nodes(p_node) THEN -- related to bug #3622010

       add_BOM_Node(p_node                  => p_node,
                    p_page_id               => l_page_ui_node.page_id,
                    p_pagebase_expl_node_id => l_page_node.pagebase_expl_node_id,
                    p_parent_element_id     => l_page_ui_node.element_id,
                    p_pagebase_persistent_node_id => l_page_ui_node.pagebase_persistent_node_id);

    END IF;

    IF NVL(g_UI_Context.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN
      add_CX_Button(p_node               => p_node,
                    p_ui_node            => l_page_ui_node);
    END IF;

    IF NVL(g_UI_Context.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN
      FOR i IN(SELECT *
                 FROM CZ_UI_PAGE_ELEMENTS
                WHERE ui_def_id=l_page_ui_node.ui_def_id AND
                      page_id=l_last_page_id AND
                      persistent_node_id=l_page_ui_node.parent_persistent_node_id AND
                      element_type IN(G_UI_PAGE_NODE_TYPE,G_UI_REGION_NODE_TYPE) AND
                      deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH))
      LOOP
        IF NVL(i.suppress_refresh_flag, G_NO_FLAG) = G_NO_FLAG THEN
          IF l_is_inst_node THEN
             add_Instance_Controls(p_ui_node          => l_page_ui_node,
                                   p_parent_ui_node   => i,
                                   p_node             => p_node);
           END IF;
           IF l_is_drilldown_node AND l_is_inst_node=FALSE THEN
              create_Drilldown_Button(p_parent_ui_node => i,
                                      p_ui_node        => l_page_ui_node,
                                      p_page_set_id    => l_page_set_id);
           END IF;
        END IF;
      END LOOP;
    END IF;
    --
    -- at this point UI page is already created ,but
    -- is not attached to any Page Sets yet
    --

   IF l_is_drilldown_node=FALSE THEN

   FOR m IN(SELECT page_set_id FROM CZ_UI_PAGE_SETS
            WHERE ui_def_id=g_UI_Context.ui_def_id AND
                  page_set_id=l_page_set_id AND
                  NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG)
   LOOP

     /******** attach new UI Page to Page Set *********************/
     BEGIN

       --
       -- create a new record for this UI page in CZ_UI_PAGE_REFS
       --
       l_page_ref_id := allocateId('CZ_UI_PAGE_REFS_S');

       l_ref_pagebase_path := get_Page_Path(p_node.ps_node_id, l_page_set_id);

       IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_LEVEL_MENU) THEN

         SELECT COUNT(*)+1 INTO l_seq_nbr
         FROM CZ_UI_PAGE_REFS WHERE ui_def_id=g_UI_Context.ui_def_id AND
              deleted_flag=G_NO_FLAG;

       ELSIF g_UI_Context.PRIMARY_NAVIGATION IN(G_MODEL_TREE_MENU) THEN


         l_seq_nbr := get_new_page_ref_seq(p_node, l_page_set_id, l_parent_page_ref_id);

         UPDATE CZ_UI_PAGE_REFS
         SET seq_nbr = seq_nbr + 1
         WHERE ui_def_id = g_UI_Context.ui_def_id
         AND page_set_id = l_page_set_id
         AND parent_page_ref_id = l_parent_page_ref_id
         AND seq_nbr >= l_seq_nbr
         AND deleted_flag = G_NO_FLAG;

       ELSE
         IF l_seq_nbr IS NULL THEN
            l_seq_nbr :=p_node.tree_seq;
         END IF;
       END IF;

      INSERT INTO CZ_UI_PAGE_REFS
      (ui_def_id,
       page_set_id,
       page_ref_id,
       parent_page_ref_id,
       seq_nbr,
       node_depth,
       condition_id,
       NAME,
       caption_source,
       target_persistent_node_id,
       target_path,
       target_ui_def_id,
       target_page_set_id,
       target_page_id,
       modified_flags,
       path_to_prev_page,
       path_to_next_page,
       page_ref_type,
       target_expl_node_id,
       caption_rule_id,
       deleted_flag)
       VALUES
      (g_UI_Context.ui_def_id,
       l_page_set_id,
       l_page_ref_id,
       l_parent_page_ref_id,
       l_seq_nbr,
       l_node_depth,
       NULL,
       p_node.name,
       G_DEFAULT_CAPTION_RULE_ID,
       p_node.persistent_node_id,
       l_ref_pagebase_path,
       NULL,
       NULL,
       l_page_ui_node.page_id,
       0,
       NULL,
       NULL,
       l_page_set_type,
       l_page_node.pagebase_expl_node_id,
       NULL,
       G_NO_FLAG);

      EXCEPTION
        WHEN OTHERS THEN
          DEBUG('create_UI_Page() : '||SQLERRM);
          NULL;
      END;

     /******** end of attaching to Page Set *********************/

       x_page_set_id   := l_page_set_id;
       x_page_set_type := l_page_set_type;
       x_page_ref_id   := l_page_ref_id;
     END LOOP;

   END IF;

   RETURN l_page_ui_node;

  END create_UI_Page;

  --
  -- create nested Region
  --
  FUNCTION create_UI_Region(p_node                 IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                            p_parent_ui_node       IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                            p_insert_index         IN NUMBER DEFAULT -1)
    RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE IS

    l_ui_node                 CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_bom_element_id          CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_ui_node_name            CZ_UI_PAGE_ELEMENTS.name%TYPE;
    l_counter                 NUMBER;
    l_parent_seq_nbr          NUMBER;
    l_last_seq_nbr            NUMBER;
    l_prev_seq_nbr            NUMBER;
    l_max_prev_seq_nbr        NUMBER;
    l_child_count             NUMBER;
    l_page_id                 NUMBER;

  BEGIN

    IF p_parent_ui_node.suppress_refresh_flag=G_YES_FLAG THEN
      RETURN l_ui_node;
    END IF;

    -- do not create UI region if already exists UI page with the same persistent_node_id
    BEGIN
      SELECT page_id INTO l_page_id FROM CZ_UI_PAGES
       WHERE ui_def_id=g_UI_CONTEXT.ui_def_id AND persistent_node_id=p_node.persistent_node_id AND
             deleted_flag NOT IN (G_YES_FLAG,G_MARK_TO_DELETE, G_LIMBO_FLAG) AND rownum<2;
       RETURN l_ui_node;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
    END;
    l_ui_node.ui_def_id                   := g_UI_Context.ui_def_id;
    l_ui_node.persistent_node_id          := p_node.persistent_node_id;
    l_ui_node.parent_persistent_node_id   := p_node.parent_persistent_node_id;
    l_ui_node.region_persistent_node_id   := p_node.persistent_node_id;
    l_ui_node.pagebase_persistent_node_id := p_parent_ui_node.persistent_node_id;
    l_ui_node.page_id                     := p_parent_ui_node.page_id;

    IF p_insert_index = -1 THEN
      SELECT NVL(MAX(seq_nbr),0) INTO l_max_prev_seq_nbr  FROM CZ_UI_PAGE_ELEMENTS
      START WITH ui_def_id=g_UI_Context.ui_def_id AND
                 page_id=p_parent_ui_node.page_id AND
                 element_id=p_parent_ui_node.element_id AND
                 deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE)
      CONNECT BY PRIOR ui_def_id=g_UI_Context.ui_def_id AND
         ui_def_id=g_UI_Context.ui_def_id AND PRIOR page_id= p_parent_ui_node.page_id
          AND page_id=p_parent_ui_node.page_id AND PRIOR element_id=parent_element_id AND
          PRIOR deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE) AND
          deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);
    ELSE
      l_max_prev_seq_nbr := p_insert_index-1;
    END IF;

    l_ui_node.seq_nbr  := l_max_prev_seq_nbr + 1;

    UPDATE CZ_UI_PAGE_ELEMENTS
       SET seq_nbr=seq_nbr+1
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           page_id=p_parent_ui_node.page_id AND
           seq_nbr>l_max_prev_seq_nbr AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_ui_node.element_id                  := get_Element_Id();

    l_ui_node.parent_element_id           := p_parent_ui_node.element_id;

    l_ui_node.element_type                := G_UI_REGION_NODE_TYPE;
    l_ui_node.instantiable_flag           := p_node.instantiable_flag;
    l_ui_node.ctrl_template_id            := G_NSTD_CONTAINER_TEMPLATE_ID;
    l_ui_node.ctrl_template_ui_def_id     := p_node.template_ui_def_id;
    l_ui_node.model_ref_expl_id           := get_Expl_Id(p_model_id       => p_node.devl_project_id,
                                                         p_ps_node_id     => p_node.ps_node_id,
                                                         p_component_id   => p_node.component_id,
                                                         p_ps_node_type   => p_node.ps_node_type);
    l_ui_node.element_signature_id        := 6007;
    l_ui_node.deleted_flag                := G_MARK_TO_ADD;

    SELECT COUNT(element_id)+1 INTO l_counter FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          page_id=l_ui_node.page_id AND
          ctrl_template_id=l_ui_node.ctrl_template_id AND
          deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_ui_node.name :='Nested Region - '||TO_CHAR(l_counter);

    INSERT INTO CZ_UI_PAGE_ELEMENTS
      (ui_def_id,
       persistent_node_id,
       parent_persistent_node_id,
       region_persistent_node_id,
       pagebase_persistent_node_id,
       page_id,
       seq_nbr,
       ctrl_template_id,
       element_id,
       parent_element_id,
       element_type,
       instantiable_flag,
       ctrl_template_ui_def_id,
       model_ref_expl_id,
       element_signature_id,
       name,
       deleted_flag)
    VALUES
      (l_ui_node.ui_def_id,
       l_ui_node.persistent_node_id,
       l_ui_node.parent_persistent_node_id,
       l_ui_node.region_persistent_node_id,
       l_ui_node.pagebase_persistent_node_id,
       l_ui_node.page_id,
       l_ui_node.seq_nbr,
       l_ui_node.ctrl_template_id,
       l_ui_node.element_id,
       l_ui_node.parent_element_id,
       l_ui_node.element_type,
       l_ui_node.instantiable_flag,
       l_ui_node.ctrl_template_ui_def_id,
       l_ui_node.model_ref_expl_id,
       l_ui_node.element_signature_id,
       l_ui_node.name,
       l_ui_node.deleted_flag);

    --
    -- add UI Elements node to cache
    --
    g_ui_page_elements_tbl(TO_NUMBER(l_ui_node.element_id)) := l_ui_node;

    IF p_node.ps_node_type IN(G_BOM_MODEL_TYPE, G_BOM_OPTION_CLASS_TYPE) THEN
       add_BOM_Node(p_node                  => p_node,
                    p_page_id               => l_ui_node.page_id,
                    p_pagebase_expl_node_id => l_ui_node.model_ref_expl_id,
                    p_parent_element_id     => l_ui_node.element_id,
                    p_pagebase_persistent_node_id => l_ui_node.pagebase_persistent_node_id);

    END IF;

    --
    -- mark UI Page as refreshed
    --
    mark_UI_Page_As_Refreshed(l_ui_node.page_id, l_ui_node.ui_def_id);
    add_CX_Button(p_node     => p_node,
                  p_ui_node  => l_ui_node);

    RETURN l_ui_node;

  END create_UI_Region;

  --
  -- create new UI Reference
  --
  FUNCTION create_UI_Reference(p_node                 IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                               p_parent_ui_node       IN CZ_UI_PAGE_ELEMENTS%ROWTYPE)
    RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE IS

    l_ui_node                       CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_page_ref_node                 CZ_UI_PAGE_REFS%ROWTYPE;
    l_target_ui_def_node            CZ_UI_DEFS%ROWTYPE;
    l_page_ref_id                   CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_ui_action_id                  CZ_UI_ACTIONS.ui_action_id%TYPE;
    l_max_seq_nbr                   CZ_UI_PAGE_ELEMENTS.seq_nbr%TYPE;
    l_ps_node_type                  CZ_PS_NODES.ps_node_type%TYPE;
    l_target_path                   CZ_UI_PAGE_REFS.target_path%TYPE;
    l_ps_node                       CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_counter                       NUMBER;
    l_persistent_node_id            NUMBER;
    l_seq_nbr                       NUMBER;
    l_max_prev_seq_nbr              NUMBER;

  BEGIN

    IF p_parent_ui_node.suppress_refresh_flag=G_YES_FLAG THEN
      RETURN l_ui_node;
    END IF;

    --
    -- get UI Def data of referenced UI
    --
    l_target_ui_def_node := get_Target_UI_Context(p_ui_def_node  => g_UI_Context,
                                                  p_reference_id => p_node.reference_id);

    l_ui_node.model_ref_expl_id := get_Expl_Id(p_model_id     => p_node.devl_project_id,
                                               p_ps_node_id   => p_node.ps_node_id,
                                               p_component_id => p_node.component_id,
                                               p_ps_node_type => p_node.ps_node_type);

    l_ui_node.ui_def_id                       := p_parent_ui_node.ui_def_id;
    l_ui_node.persistent_node_id              := p_node.persistent_node_id;
    l_ui_node.parent_persistent_node_id       := p_node.parent_persistent_node_id;
    l_ui_node.region_persistent_node_id       := p_parent_ui_node.region_persistent_node_id;
    l_ui_node.pagebase_persistent_node_id     := p_parent_ui_node.pagebase_persistent_node_id;
    l_ui_node.page_id                         := p_parent_ui_node.page_id;


    SELECT NVL(MAX(seq_nbr),0) INTO l_max_prev_seq_nbr  FROM CZ_UI_PAGE_ELEMENTS
    START WITH ui_def_id=g_UI_Context.ui_def_id AND
               page_id=p_parent_ui_node.page_id AND
               element_id=p_parent_ui_node.element_id AND
               deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE)
    CONNECT BY PRIOR ui_def_id=g_UI_Context.ui_def_id AND
       ui_def_id=g_UI_Context.ui_def_id AND PRIOR page_id= p_parent_ui_node.page_id
        AND page_id=p_parent_ui_node.page_id AND PRIOR element_id=parent_element_id AND
        PRIOR deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE) AND
        deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_ui_node.seq_nbr  := l_max_prev_seq_nbr + 1;

    UPDATE CZ_UI_PAGE_ELEMENTS
       SET seq_nbr=seq_nbr+1
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           page_id=p_parent_ui_node.page_id AND
           seq_nbr>l_max_prev_seq_nbr AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);


    l_ui_node.ctrl_template_id                := p_node.template_id;
    l_ui_node.element_id                      := get_Element_Id();
    l_ui_node.parent_element_id               := p_parent_ui_node.element_id;

    IF p_node.detailed_type_id IN(CZ_TYPES.UMANDATORY_REF_TYPEID) THEN
      l_ui_node.element_type := G_UI_DRILLDOWN_NODE_TYPE;
    ELSIF p_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_COMPONENT_TYPEID,CZ_TYPES.UMINMAX_COMPONENT_TYPEID) THEN
       l_ui_node.element_type := G_UI_NONBOMADDINST_NODE_TYPE;
    ELSIF p_node.detailed_type_id IN(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID) THEN
       l_ui_node.element_type := G_UI_BOMADDINST_NODE_TYPE;
    ELSE
       NULL;
    END IF;

    l_ui_node.instantiable_flag               := p_node.instantiable_flag;
    l_ui_node.ctrl_template_ui_def_id         := p_node.template_ui_def_id;
    l_ui_node.element_signature_id            := p_node.root_element_signature_id;
    l_ui_node.deleted_flag                    := G_MARK_TO_ADD;

    SELECT COUNT(element_id)+1 INTO l_counter FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          page_id=l_ui_node.page_id AND
          ctrl_template_id=l_ui_node.ctrl_template_id AND
          deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

    l_ui_node.name := p_node.template_name||' - '||TO_CHAR(l_counter);

    --
    -- special handling for BOM referencies
    --

    IF p_node.detailed_type_id IN(CZ_TYPES.UMANDATORY_REF_TYPEID) THEN
       BEGIN

         SELECT NVL(MAX(seq_nbr),0) INTO l_max_seq_nbr
         FROM CZ_UI_PAGE_ELEMENTS
         WHERE ui_def_id=l_ui_node.ui_def_id
         AND parent_element_id=l_ui_node.parent_element_id
         AND deleted_flag IN(G_NO_FLAG,G_MARK_TO_REFRESH,G_MARK_TO_ADD)
         AND element_type IN(G_UI_BOMADDINST_NODE_TYPE);

         SELECT persistent_node_id INTO l_persistent_node_id
           FROM CZ_UI_PAGE_ELEMENTS
          WHERE ui_def_id=l_ui_node.ui_def_id AND
                parent_element_id=l_ui_node.parent_element_id AND
                seq_nbr=l_max_seq_nbr AND
                ROWNUM<2;

         l_ps_node := get_Model_Node_By_Persist_Id(l_persistent_node_id,g_UI_COntext.devl_project_id);

         SELECT ps_node_type INTO l_ps_node_type
           FROM CZ_PS_NODES
          WHERE devl_project_id=p_node.reference_id AND
                parent_id IS NULL AND
                deleted_flag=G_NO_FLAG;

         IF l_ps_node_type IN(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) AND
            (l_ps_node.ps_node_type IN(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) OR
            l_ps_node.detailed_type_id in(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID)) THEN
           l_ui_node.ctrl_template_id := NULL;
           l_ui_node.ctrl_template_ui_def_id := NULL;
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           DEBUG('create_UI_Reference() : '||SQLERRM);
       END;
    END IF;

    --
    --  model nodes must have associated record in CZ_UI_PAGE_ELEMENTS
    --
    INSERT INTO CZ_UI_PAGE_ELEMENTS
      (ui_def_id,
       persistent_node_id,
       parent_persistent_node_id,
       region_persistent_node_id,
       pagebase_persistent_node_id,
       page_id,
       seq_nbr,
       ctrl_template_id,
       element_id,
       parent_element_id,
       element_type,
       instantiable_flag,
       ctrl_template_ui_def_id,
       model_ref_expl_id,
       element_signature_id,
       name,
       deleted_flag)
    VALUES
      (l_ui_node.ui_def_id,
       l_ui_node.persistent_node_id,
       l_ui_node.parent_persistent_node_id,
       l_ui_node.region_persistent_node_id,
       l_ui_node.pagebase_persistent_node_id,
       l_ui_node.page_id,
       l_ui_node.seq_nbr,
       l_ui_node.ctrl_template_id,
       l_ui_node.element_id,
       l_ui_node.parent_element_id,
       l_ui_node.element_type,
       l_ui_node.instantiable_flag,
       l_ui_node.ctrl_template_ui_def_id,
       l_ui_node.model_ref_expl_id,
       l_ui_node.element_signature_id,
       l_ui_node.name,
       l_ui_node.deleted_flag);

    BEGIN

      UPDATE CZ_UI_REFS
         SET deleted_flag=G_NO_FLAG
       WHERE
         ui_def_id = l_ui_node.ui_def_id AND
         ref_persistent_node_id = l_ui_node.persistent_node_id;

      IF SQL%ROWCOUNT=0 THEN
        INSERT INTO CZ_UI_REFS
        (ui_def_id,
         ref_ui_def_id,
         ref_persistent_node_id,
         model_ref_expl_id,
         deleted_flag)
        VALUES
        (l_ui_node.ui_def_id,
         l_target_ui_def_node.ui_def_id,
         l_ui_node.persistent_node_id,
         l_ui_node.model_ref_expl_id,
         G_NO_FLAG);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    l_ui_action_id := allocateId('CZ_UI_ACTIONS_S');
    INSERT INTO CZ_UI_ACTIONS
      (ui_action_id,
       ui_def_id,
       source_page_id,
       context_component_id,
       element_id,
       ui_action_type,
       target_ui_def_id,
       target_persistent_node_id,
       target_node_path,
       target_page_set_id,
       target_page_id,
       target_expl_node_id,
       seeded_flag,
       deleted_flag)
    VALUES
      (l_ui_action_id,
       l_ui_node.ui_def_id,
       l_ui_node.page_id,
       l_ui_node.region_persistent_node_id,
       l_ui_node.element_id,
       G_ACTION_CONFIGURE_SUBCOMP,
       l_target_ui_def_node.ui_def_id,
       p_node.persistent_node_id,
       TO_CHAR(p_node.persistent_node_id),
       l_target_ui_def_node.page_set_id,
       l_target_ui_def_node.start_page_id,
       l_ui_node.model_ref_expl_id,
       G_NO_FLAG,
       G_NO_FLAG);

    add_CX_Button(p_node               => p_node,
                  p_ui_node            => l_ui_node);

    --
    -- mark UI Page as refreshed
    --
    mark_UI_Page_As_Refreshed(l_ui_node.page_id, l_ui_node.ui_def_id);

    IF NOT(l_target_ui_def_node.PRIMARY_NAVIGATION=G_MODEL_TREE_MENU AND
       g_UI_Context.PRIMARY_NAVIGATION=G_MODEL_TREE_MENU) THEN
      RETURN l_ui_node;
    END IF;

    BEGIN
      l_page_ref_node := get_UI_Page_Ref_Node(p_ui_node => p_parent_ui_node);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN l_ui_node;
    END;

    FOR m IN(SELECT page_set_id FROM CZ_UI_PAGE_SETS
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    page_set_id=l_page_ref_node.page_set_id AND
                    NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG)
    LOOP

      --
      -- create a new record for this UI page in CZ_UI_PAGE_REFS
      --
      l_page_ref_id := allocateId('CZ_UI_PAGE_REFS_S');

       IF l_target_ui_def_node.start_page_id=-1 THEN

         SELECT MIN(page_id) INTO l_target_ui_def_node.start_page_id
           FROM CZ_UI_PAGES
          WHERE ui_def_id=l_target_ui_def_node.ui_def_id AND
                deleted_flag IN(G_NO_FLAG,G_MARK_TO_ADD,G_MARK_TO_REFRESH);

         SELECT MIN(page_set_id) INTO l_target_ui_def_node.page_set_id
           FROM CZ_UI_PAGE_SETS
          WHERE ui_def_id=l_target_ui_def_node.ui_def_id AND deleted_flag=G_NO_FLAG;

      END IF;

      l_target_path := get_Page_Path(p_node.ps_node_id,l_page_ref_node.page_set_id);

      IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_LEVEL_MENU) THEN
        SELECT COUNT(*)+1 INTO l_seq_nbr
        FROM CZ_UI_PAGE_REFS WHERE ui_def_id=g_UI_Context.ui_def_id AND
             deleted_flag=G_NO_FLAG;
      ELSIF g_UI_Context.PRIMARY_NAVIGATION IN(G_MODEL_TREE_MENU) THEN

        l_seq_nbr := get_new_page_ref_seq(p_node, l_page_ref_node.page_set_id, l_page_ref_node.page_ref_id);

        UPDATE CZ_UI_PAGE_REFS
        SET seq_nbr = seq_nbr + 1
        WHERE ui_def_id = g_UI_Context.ui_def_id
        AND page_set_id = l_page_ref_node.page_set_id
        AND parent_page_ref_id = l_page_ref_node.page_ref_id
        AND seq_nbr >= l_seq_nbr
        AND deleted_flag = G_NO_FLAG;
      ELSE
        l_seq_nbr :=p_node.tree_seq;
      END IF;

      INSERT INTO CZ_UI_PAGE_REFS
      (ui_def_id,
       page_set_id,
       page_ref_id,
       parent_page_ref_id,
       seq_nbr,
       node_depth,
       NAME,
       caption_source,
       target_persistent_node_id,
       target_path,
       target_ui_def_id,
       target_page_set_id,
       target_page_id,
       modified_flags,
       page_ref_type,
       target_expl_node_id,
       caption_rule_id,
       deleted_flag)
       VALUES
      (l_ui_node.ui_def_id,
       l_page_ref_node.page_set_id,
       l_page_ref_id,
       l_page_ref_node.page_ref_id,
       l_seq_nbr,
       l_page_ref_node.node_depth+1,
       p_node.NAME,
       G_DEFAULT_CAPTION_RULE_ID,
       p_node.persistent_node_id,
       l_target_path,
       l_target_ui_def_node.ui_def_id, --NULL, -- request from Alok -- old code l_target_ui_def_node.ui_def_id,
       l_target_ui_def_node.page_set_id, --NULL, -- request from Alok -- old code l_target_ui_def_node.page_set_id,
       l_target_ui_def_node.start_page_id, --NULL, -- request from Alok -- old code l_target_ui_def_node.start_page_id,
       0,
       l_page_ref_node.page_ref_type,
       l_ui_node.model_ref_expl_id,
       NULL,
       G_NO_FLAG);

    END LOOP;

    RETURN l_ui_node;

  END create_UI_Reference;

  --
  -- delete UI element recursively
  --
  PROCEDURE delete_UI_Element(p_ui_node               IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                              p_suppress_refresh_flag IN CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE DEFAULT NULL,
                              p_delete_in_model       IN BOOLEAN DEFAULT NULL) IS

    l_suppress_refresh_flag CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;
    l_del_flag              BOOLEAN := FALSE;
  BEGIN

    --
    -- get suppress_refresh_flag flag of UI region to which this element
    -- belong to
    --
    IF p_suppress_refresh_flag IS NULL THEN
       FOR i IN (SELECT persistent_node_id,region_persistent_node_id,suppress_refresh_flag
                 FROM CZ_UI_PAGE_ELEMENTS
                 START WITH ui_def_id = p_ui_node.ui_def_id AND
                          deleted_flag IN
                          (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,
                           G_MARK_TO_DELETE) AND element_id = p_ui_node.element_id
                 CONNECT BY PRIOR parent_element_id = element_id AND
                         deleted_flag IN
                         (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,
                          G_MARK_TO_DELETE) AND
                         PRIOR deleted_flag IN
                          (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,
                           G_MARK_TO_DELETE))
        LOOP
          IF i.persistent_node_id=i.region_persistent_node_id THEN
             l_suppress_refresh_flag := i.suppress_refresh_flag;
          END IF;
        END LOOP;
    ELSE
       IF p_suppress_refresh_flag=G_YES_FLAG THEN
         l_suppress_refresh_flag := p_suppress_refresh_flag;
       ELSE
         l_suppress_refresh_flag := p_ui_node.suppress_refresh_flag;
       END IF;
    END IF;

    --
    -- if suppress_refresh_flag = true (G_YES_FLAG) then
    -- node will be deleted
    -- else node will be deassiated from model node
    --
    IF NVL(l_suppress_refresh_flag,G_NO_FLAG) = G_NO_FLAG THEN

       --
       -- delete UI element
       --
       UPDATE CZ_UI_PAGE_ELEMENTS
          SET deleted_flag = G_MARK_TO_DELETE
        WHERE ui_def_id = p_ui_node.ui_def_id AND
              element_id IN
              (SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
               START WITH ui_def_id=p_ui_node.ui_def_id AND element_id=p_ui_node.element_id
               CONNECT BY PRIOR ui_def_id=p_ui_node.ui_def_id AND ui_def_id=p_ui_node.ui_def_id AND
               PRIOR element_id=parent_element_id AND
                     deleted_flag IN (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,G_MARK_TO_DELETE) AND
               PRIOR deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,G_MARK_TO_DELETE));

       l_del_flag := TRUE;

    ELSE
      IF p_delete_in_model THEN
         --
         -- deassociate UI element from model node
         --
         UPDATE CZ_UI_PAGE_ELEMENTS
            SET deleted_flag = G_MARK_TO_DEASSOCIATE,
                persistent_node_id = 0
          WHERE ui_def_id = p_ui_node.ui_def_id AND
                element_id IN
                (SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
                 START WITH ui_def_id=p_ui_node.ui_def_id AND element_id=p_ui_node.element_id
                 CONNECT BY PRIOR ui_def_id=p_ui_node.ui_def_id AND
                  PRIOR element_id=parent_element_id AND
                        deleted_flag IN (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,G_MARK_TO_DELETE) AND
                  PRIOR deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,G_MARK_TO_DELETE));
         l_del_flag := TRUE;
      END IF;
    END IF;

    IF l_del_flag THEN
      --
      -- delete UI Ref from Page Sets
      --
      UPDATE CZ_UI_PAGE_REFS
         SET deleted_flag = G_YES_FLAG
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             target_persistent_node_id=p_ui_node.persistent_node_id AND
             deleted_flag=G_NO_FLAG AND
             target_page_id NOT IN(SELECT page_id FROM CZ_UI_PAGES
             WHERE ui_def_id=g_UI_Context.ui_def_id);

      IF SQL%ROWCOUNT>0 THEN
        --
        -- delete UI Ref
        --
        UPDATE CZ_UI_REFS
           SET deleted_flag = G_YES_FLAG
         WHERE ui_def_id=p_ui_node.ui_def_id AND
               ref_persistent_node_id=p_ui_node.persistent_node_id AND
               deleted_flag=G_NO_FLAG AND NOT EXISTS
               (SELECT NULL FROM CZ_UI_PAGE_ELEMENTS
                WHERE ui_def_id=p_ui_node.ui_def_id AND
                      persistent_node_id=p_ui_node.persistent_node_id AND
                      deleted_flag IN(G_NO_FLAG,G_MARK_TO_ADD,G_MARK_TO_REFRESH));
      END IF;

    END IF;

    --
    -- mark UI Page as refreshed
    --
    mark_UI_Page_As_Refreshed(p_ui_node.page_id, p_ui_node.ui_def_id);

  END delete_UI_Element;

  --
  -- remove UI Page Ref record
  --
  PROCEDURE remove_UI_Page_Ref(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS

    l_page_ref_id             NUMBER;
    l_parent_page_ref_id      NUMBER;
    l_page_set_id             NUMBER;
    l_seq_nbr                 NUMBER;

  BEGIN

        SELECT MIN(page_ref_id) INTO l_page_ref_id
          FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id=p_ui_node.ui_def_id AND
               target_page_id=p_ui_node.page_id AND
               deleted_flag=G_NO_FLAG;

        UPDATE CZ_UI_PAGE_REFS
           SET deleted_flag = G_YES_FLAG
         WHERE ui_def_id=p_ui_node.ui_def_id AND
               page_ref_id=l_page_ref_id
            RETURNING parent_page_ref_id,page_set_id,seq_nbr
                 INTO l_parent_page_ref_id,l_page_set_id,l_seq_nbr;


        --
        -- update seq nbr to seq nbr - 1
        --
        UPDATE CZ_UI_PAGE_REFS
           SET seq_nbr = seq_nbr - 1
         WHERE ui_def_id=p_ui_node.ui_def_id AND
               page_set_id=l_page_set_id AND
               parent_page_ref_id = l_parent_page_ref_id AND
               seq_nbr > l_seq_nbr AND
               deleted_flag=G_NO_FLAG;


  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END remove_UI_Page_Ref;

  PROCEDURE delete_Related_Buttons(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS
    l_suppress_refresh_flag     CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;
  BEGIN

    FOR i IN(SELECT element_id,parent_element_id,page_id,suppress_refresh_flag
               FROM CZ_UI_PAGE_ELEMENTS a
              WHERE ui_def_id=p_ui_node.ui_def_id AND
                    persistent_node_id=p_ui_node.persistent_node_id AND
                    element_type IN(G_UI_BOMADDINST_NODE_TYPE,
                                    G_UI_NONBOMADDINST_NODE_TYPE,
                                    G_UI_PAGEDRILLDOWN_NODE_TYPE) AND
                    deleted_flag NOT IN(G_YES_FLAG, G_LIMBO_FLAG))
    LOOP

       IF i.parent_element_id IS NOT NULL THEN
         BEGIN
           l_suppress_refresh_flag := G_NO_FLAG;
           SELECT NVL(suppress_refresh_flag,G_NO_FLAG) INTO l_suppress_refresh_flag
             FROM CZ_UI_PAGE_ELEMENTS
            WHERE ui_def_id  = p_ui_node.ui_def_id AND
                  page_id = i.page_id AND
                  element_id=i.parent_element_id;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             NULL;
         END;
       END IF;

       IF l_suppress_refresh_flag=G_YES_FLAG OR i.suppress_refresh_flag=G_YES_FLAG THEN
         UPDATE CZ_UI_PAGE_ELEMENTS
            SET deleted_flag = G_MARK_TO_DEASSOCIATE,
                persistent_node_id=0
          WHERE ui_def_id  = p_ui_node.ui_def_id AND
                page_id = i.page_id AND
                element_id = i.element_id;
       ELSE
         UPDATE CZ_UI_PAGE_ELEMENTS
            SET deleted_flag = G_MARK_TO_DELETE
          WHERE ui_def_id  = p_ui_node.ui_def_id AND
                page_id = i.page_id AND
                element_id = i.element_id;
       END IF;

       mark_UI_Page_As_Refreshed(i.page_id, p_ui_node.ui_def_id);

    END LOOP;

  END delete_Related_Buttons;

  --
  -- delete UI container
  --
  PROCEDURE delete_UI_Container(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS
      TYPE number_tbl_type        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      l_element_id_tbl            varchar_tbl_type;
      l_parent_element_id_tbl     varchar_tbl_type;
      l_persistent_node_id_tbl    number_tbl_type;
      l_suppress_refresh_flag_tbl varchar_tbl_type;
      l_page_id_tbl               number_tbl_type;
      l_suppress_refresh_flag     CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;

  BEGIN

    --
    -- if it's a page remove page and corresponding UI Page ref record
    --
    IF p_ui_node.parent_element_id IS NULL THEN

      SELECT element_id, parent_element_id, persistent_node_id,page_id, NVL(suppress_refresh_flag,G_NO_FLAG)
        BULK COLLECT INTO l_element_id_tbl, l_parent_element_id_tbl, l_persistent_node_id_tbl,
                         l_page_id_tbl, l_suppress_refresh_flag_tbl
        FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             page_id=p_ui_node.page_id AND
             deleted_flag NOT IN(G_YES_FLAG);

       delete_Related_Buttons(p_ui_node);

       --
       -- mark this UI Page as deleted
       --
       mark_UI_Page_As_Deleted(p_ui_node.page_id, p_ui_node.ui_def_id);

       --
       -- remove corresponding UI page ref record
       --
       remove_UI_Page_Ref(p_ui_node);

    ELSE

      SELECT element_id,persistent_node_id,page_id, suppress_refresh_flag
        BULK COLLECT INTO  l_element_id_tbl, l_persistent_node_id_tbl,
                           l_page_id_tbl, l_suppress_refresh_flag_tbl
        FROM CZ_UI_PAGE_ELEMENTS
       START WITH ui_def_id=p_ui_node.ui_def_id AND
                  page_id=p_ui_node.page_id AND
                  element_id=p_ui_node.element_id
       CONNECT BY PRIOR element_id=parent_element_id AND
                        ui_def_id=p_ui_node.ui_def_id AND PRIOR
                        ui_def_id=p_ui_node.ui_def_id;

       mark_UI_Page_As_Refreshed(p_ui_node.page_id, p_ui_node.ui_def_id);

    END IF;

    IF l_element_id_tbl.COUNT=0 THEN
      RETURN;
    END IF;

    FOR i IN l_element_id_tbl.FIRST..l_element_id_tbl.LAST
    LOOP

      BEGIN
        l_suppress_refresh_flag := G_NO_FLAG;
        IF l_parent_element_id_tbl(i) IS NOT NULL THEN
          SELECT NVL(suppress_refresh_flag,G_NO_FLAG) INTO l_suppress_refresh_flag
            FROM CZ_UI_PAGE_ELEMENTS
           WHERE ui_def_id  = p_ui_node.ui_def_id AND
                 page_id = p_ui_node.page_id AND
                 element_id=l_parent_element_id_tbl(i);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      IF l_suppress_refresh_flag=G_YES_FLAG OR l_suppress_refresh_flag_tbl(i)=G_YES_FLAG THEN
        UPDATE CZ_UI_PAGE_ELEMENTS
           SET deleted_flag = G_MARK_TO_DEASSOCIATE,
               persistent_node_id=0
         WHERE ui_def_id  = p_ui_node.ui_def_id AND
               page_id = p_ui_node.page_id AND
               element_id = l_element_id_tbl(i);
      ELSE
        UPDATE CZ_UI_PAGE_ELEMENTS
           SET deleted_flag = G_MARK_TO_DELETE
         WHERE ui_def_id  = p_ui_node.ui_def_id AND
               page_id = p_ui_node.page_id AND
               element_id = l_element_id_tbl(i);
      END IF;

      UPDATE CZ_UI_ACTIONS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             source_page_id=p_ui_node.page_id AND
             element_id=l_element_id_tbl(i);
    END LOOP;

  END delete_UI_Container;

  PROCEDURE handle_Deleted_Nodes(p_ui_def_id IN NUMBER) IS

    l_suppress_refresh_flag CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;

  BEGIN

   -- delete UI References
    UPDATE CZ_UI_PAGE_REFS uiref
      SET deleted_flag=G_YES_FLAG
    WHERE ui_def_id=p_ui_def_id AND target_ui_def_id IS NOT NULL AND
           NOT EXISTS(SELECT NULL FROM CZ_PS_NODES a
           WHERE a.devl_project_id=(SELECT b.devl_project_id FROM CZ_UI_DEFS b
           WHERE b.ui_def_id=p_ui_def_id) AND
           persistent_node_id=uiref.target_persistent_node_id AND deleted_flag=G_NO_FLAG)
           AND deleted_flag=G_NO_FLAG;

    UPDATE CZ_UI_REFS uiref
       SET deleted_flag=G_YES_FLAG
     WHERE ui_def_id=p_ui_def_id AND
           NOT EXISTS(SELECT NULL FROM CZ_PS_NODES a
           WHERE a.devl_project_id=(SELECT b.devl_project_id FROM CZ_UI_DEFS b
           WHERE b.ui_def_id=p_ui_def_id) AND
           persistent_node_id=uiref.ref_persistent_node_id AND deleted_flag=G_NO_FLAG)
           AND deleted_flag=G_NO_FLAG;

  END handle_Deleted_Nodes;

  --
  -- delete UI page
  --
  PROCEDURE delete_UI_Page(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS

    l_page_set_id               CZ_UI_PAGE_SETS.page_set_id%TYPE;
    l_parent_page_ref_id        CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_seq_nbr                   CZ_UI_PAGE_REFS.seq_nbr%TYPE;
    l_path_to_next_page         CZ_UI_PAGE_REFS.path_to_next_page%TYPE;
    l_target_persistent_node_id CZ_UI_PAGE_REFS.target_persistent_node_id%TYPE;
    l_target_page_id            CZ_UI_PAGE_REFS.target_page_id%TYPE;
    l_ui_page_ref_node          CZ_UI_PAGE_REFS%ROWTYPE;
    l_ui_page_node              CZ_UI_PAGES%ROWTYPE;
    l_page_ref_id               CZ_UI_PAGE_REFS.page_ref_id%TYPE;


  BEGIN
    --
    -- delete all child UI nodes
    --
    delete_UI_Container(p_ui_node);

  END delete_UI_Page;

  --
  -- delete UI region
  --
  PROCEDURE delete_UI_Region(p_ui_node IN CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS
  BEGIN
    delete_UI_Container(p_ui_node);
  END delete_UI_Region;


  PROCEDURE replace_page_ref_target_path(p_node           IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                                         p_page_id        IN CZ_UI_PAGES.page_id%TYPE) IS

    l_page_set_id            CZ_UI_PAGE_REFS.page_set_id%TYPE;
    l_target_path            CZ_UI_PAGE_REFS.target_path%TYPE;
    l_page_path_from_root    CZ_UI_PAGE_REFS.target_path%TYPE;
    l_old_page_path_from_root CZ_UI_PAGE_REFS.target_path%TYPE;

  BEGIN

    SELECT page_set_id,pagebase_path INTO l_page_set_id,l_old_page_path_from_root FROM CZ_UI_PAGES
    WHERE page_id=p_page_id AND ui_def_id=g_UI_Context.ui_def_id;

    l_target_path := get_Page_Path(p_node.ps_node_id, l_page_set_id);
    l_page_path_from_root := get_Page_Path(p_node.ps_node_id, NULL);

    IF l_page_path_from_root <> l_old_page_path_from_root THEN
      UPDATE CZ_UI_PAGES
         SET pagebase_path=l_page_path_from_root,
             deleted_flag=DECODE(deleted_flag,G_MARK_TO_ADD,G_MARK_TO_ADD,G_MARK_TO_REFRESH)
       WHERE page_id=p_page_id AND
             ui_def_id=g_UI_Context.ui_def_id AND
             deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

      IF SQL%ROWCOUNT>0 THEN
          --DEBUG('asp: updating target path 3 for page ' || p_page_id || ' to ' || l_target_path);
          UPDATE CZ_UI_PAGE_REFS
            SET target_path=l_target_path
          WHERE ui_def_id=g_UI_Context.ui_def_id AND
                target_page_id=p_page_id;
      END IF;
    END IF;

  END replace_page_ref_target_path;

  PROCEDURE replace_page_ref_target_path(p_node           IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS
    l_target_path            CZ_UI_PAGE_REFS.target_path%TYPE;
  BEGIN

    IF p_node.ps_node_type = G_REFERENCE_TYPE AND
       g_UI_Context.primary_navigation = G_MODEL_TREE_MENU THEN

      FOR i in (SELECT page_set_id, page_ref_id
                FROM CZ_UI_PAGE_REFS
                WHERE ui_def_id = g_UI_Context.ui_def_id
                AND target_ui_def_id IS NOT NULL
                AND target_page_id IS NOT NULL
                AND target_persistent_node_id = p_node.persistent_node_id
                AND deleted_flag = G_NO_FLAG)

      LOOP
        l_target_path := get_Page_Path(p_node.ps_node_id, i.page_set_id);
        --DEBUG('asp: updating target path 10 for page ref ' || i.page_ref_id || ' to ' || l_target_path);
        UPDATE CZ_UI_PAGE_REFS
          SET target_path=l_target_path
        WHERE ui_def_id=g_UI_Context.ui_def_id
        AND page_set_id = i.page_set_id
        AND page_ref_id = i.page_ref_id;
      END LOOP;

    ELSE
      FOR i in (SELECT page_id
                FROM CZ_UI_PAGES
                WHERE ui_def_id = g_UI_Context.ui_def_id
                AND persistent_node_id = p_node.persistent_node_id
                AND deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG))
      LOOP
        replace_page_ref_target_path(p_node, i.page_id);
      END LOOP;
    END IF;
  END replace_page_ref_target_path;


  PROCEDURE replace_page_ref_target_path(p_ui_node        IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                         p_node           IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

    l_page_set_id            CZ_UI_PAGE_REFS.page_set_id%TYPE;
    l_target_path            CZ_UI_PAGE_REFS.target_path%TYPE;
    l_page_path_from_root    CZ_UI_PAGE_REFS.target_path%TYPE;
    l_old_page_path_from_root CZ_UI_PAGE_REFS.target_path%TYPE;

  BEGIN

    replace_page_ref_target_path(p_node, p_ui_node.page_id);

  END replace_page_ref_target_path;

  PROCEDURE move_page_ref(p_page_set_id            IN CZ_UI_PAGE_REFS.page_set_id%TYPE,
                          p_page_ref_id            IN CZ_UI_PAGE_REFS.page_ref_id%TYPE,
                          p_node                   IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          x_new_parent_page_ref_id OUT NOCOPY CZ_UI_PAGE_REFS.page_ref_id%TYPE) IS


    l_page_ref_type          CZ_UI_PAGE_REFS.page_ref_type%TYPE;
    l_new_parent_node_depth  CZ_UI_PAGE_REFS.node_depth%TYPE;
    l_node_depth             CZ_UI_PAGE_REFS.node_depth%TYPE;
    l_page_set_suppress_flag CZ_UI_PAGE_SETS.suppress_refresh_flag%TYPE;

  BEGIN

    x_new_parent_page_ref_id := NULL;


    IF p_page_set_id IS NOT NULL THEN
      SELECT suppress_refresh_flag INTO l_page_set_suppress_flag FROM CZ_UI_PAGE_SETS
      WHERE ui_def_id=g_UI_Context.ui_def_id AND page_set_id=p_page_set_id;
    END IF;

    BEGIN
      SELECT page_ref_type, node_depth
        INTO l_page_ref_type, l_node_depth
        FROM CZ_UI_PAGE_REFS
       WHERE ui_def_id=g_UI_Context.ui_def_id AND
             page_ref_id=p_page_ref_id AND
             deleted_flag=G_NO_FLAG;

      -- get new parent page ref id
      BEGIN
        SELECT MIN(page_ref_id)
          INTO x_new_parent_page_ref_id
          FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id=g_UI_Context.ui_def_id AND
               target_persistent_node_id=p_node.parent_persistent_node_id AND
               deleted_flag=G_NO_FLAG;

        SELECT node_depth
          INTO l_new_parent_node_depth
          FROM CZ_UI_PAGE_REFS
         WHERE ui_def_id=g_UI_Context.ui_def_id AND
               page_ref_id=x_new_parent_page_ref_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      IF x_new_parent_page_ref_id IS NULL THEN -- parent node does not exists in CZ_UI_PAGE_REFS

        IF l_page_ref_type IN (G_MODEL_TREE_MENU) AND p_node.parent_id IS NOT NULL THEN
          --DEBUG('asp: Deleting page_ref 5 ' || p_page_ref_id);
          UPDATE CZ_UI_PAGE_REFS
             SET deleted_flag=G_YES_FLAG
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_ref_id=p_page_ref_id AND
                 deleted_flag=G_NO_FLAG;
        END IF;

      ELSE

          g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;
          --DEBUG('asp: Setting parent_page_ref_id of page ref ' || p_page_ref_id || ' to ' || x_new_parent_page_ref_id);
          --DEBUG('asp: Setting seq_nbr of page ref ' || p_page_ref_id || ' to ' || p_node.tree_seq);
          UPDATE CZ_UI_PAGE_REFS
             SET parent_page_ref_id = x_new_parent_page_ref_id,
                 seq_nbr = p_node.tree_seq
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_ref_id=p_page_ref_id;

          UPDATE CZ_UI_PAGE_REFS
             SET node_depth = node_depth + (l_new_parent_node_depth-l_node_depth) + 1
           WHERE (ui_def_id,page_ref_id) IN
                (SELECT ui_def_id,page_ref_id FROM CZ_UI_PAGE_REFS
                 START WITH ui_def_id=g_UI_Context.ui_def_id AND page_ref_id=p_page_ref_id
                 CONNECT BY PRIOR page_ref_id=parent_page_ref_id AND
                 ui_def_id=g_UI_Context.ui_def_id AND PRIOR ui_def_id=g_UI_Context.ui_def_id AND
                 deleted_flag=G_NO_FLAG AND PRIOR deleted_flag=G_NO_FLAG);

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  END move_page_ref;


  PROCEDURE move_page_ref(p_ui_node                IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                          p_node                   IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          x_new_parent_page_ref_id OUT NOCOPY CZ_UI_PAGE_REFS.page_ref_id%TYPE) IS

    l_page_set_id            CZ_UI_PAGE_REFS.page_set_id%TYPE;
    l_page_ref_id            CZ_UI_PAGE_REFS.page_ref_id%TYPE;

  BEGIN

    BEGIN

      SELECT page_set_id INTO l_page_set_id FROM CZ_UI_PAGES
       WHERE page_id=p_ui_node.page_id AND ui_def_id=g_UI_Context.ui_def_id;

      SELECT page_ref_id, parent_page_ref_id
        INTO l_page_ref_id, x_new_parent_page_ref_id
        FROM CZ_UI_PAGE_REFS
       WHERE ui_def_id=g_UI_Context.ui_def_id AND
             page_set_id = l_page_set_id AND
             target_page_id = p_ui_node.page_id AND
             deleted_flag=G_NO_FLAG AND
             rownum < 2;

      IF p_node.parent_persistent_node_id <> p_ui_node.parent_persistent_node_id THEN
        move_page_ref(l_page_set_id, l_page_ref_id, p_node, x_new_parent_page_ref_id);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END move_page_ref;

  --
  -- change instantiability of Page
  --
  PROCEDURE check_Page_Changes(p_ui_node        IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                               p_node           IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

    l_changed_pages_tbl      number_tbl_type;
    l_persistent_node_id_tbl number_tbl_type;
    l_ps_node_id_tb          number_tbl_type;
    l_component_id_tbl       number_tbl_type;
    l_ps_node_type_tbl       number_tbl_type;
    l_page_set_id            CZ_UI_PAGE_REFS.page_set_id%TYPE;
    l_parent_ref_persist_id  CZ_UI_PAGE_REFS.target_persistent_node_id%TYPE;
    l_new_parent_page_ref_id CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_curr_target_path       CZ_UI_PAGE_REFS.target_path%TYPE;
    l_page_set_suppress_flag CZ_UI_PAGE_SETS.suppress_refresh_flag%TYPE;
    l_mark_flag              CZ_UI_PAGE_ELEMENTS.deleted_flag%TYPE;
    l_ui_node_name           CZ_UI_PAGE_ELEMENTS.name%TYPE;

  BEGIN

    SELECT page_set_id INTO l_page_set_id FROM CZ_UI_PAGES
    WHERE page_id=p_ui_node.page_id AND ui_def_id=g_UI_Context.ui_def_id;

    IF l_page_set_id IS NOT NULL THEN
      SELECT suppress_refresh_flag INTO l_page_set_suppress_flag FROM CZ_UI_PAGE_SETS
      WHERE ui_def_id=g_UI_Context.ui_def_id AND page_set_id=l_page_set_id;
    END IF;

    move_page_ref(p_ui_node, p_node, l_new_parent_page_ref_id);

    IF p_node.parent_persistent_node_id<>p_ui_node.parent_persistent_node_id AND
       p_ui_node.instantiable_flag=p_node.instantiable_flag AND
       p_ui_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE,G_MANDATORY_INST_TYPE) THEN

     FOR i IN(SELECT page_id,element_id,parent_element_id,suppress_refresh_flag FROM CZ_UI_PAGE_ELEMENTS
              WHERE ui_def_id=p_ui_node.ui_def_id AND
                    persistent_node_id=p_ui_node.parent_persistent_node_id AND
                            ((region_persistent_node_id=persistent_node_id OR
                                   pagebase_persistent_node_id=persistent_node_id) AND
                                   ctrl_template_id IN( G_CONTAINER_TEMPLATE_ID
                                                        ,G_NSTD_CONTAINER_TEMPLATE_ID
                                                        ,G_2COLS_CONTAINER_TEMPLATE_ID
                                                        ,G_3COLS_CONTAINER_TEMPLATE_ID)) AND
                                   deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE))
    LOOP
      IF i.suppress_refresh_flag=G_YES_FLAG THEN
        UPDATE CZ_UI_PAGE_ELEMENTS
           SET deleted_flag=G_MARK_TO_DEASSOCIATE,
               persistent_node_id=0
         WHERE ui_def_id=p_ui_node.ui_def_id AND
               page_id=i.page_id AND
               persistent_node_id=p_ui_node.persistent_node_id AND
               element_type IN(G_UI_NONBOMADDINST_NODE_TYPE,
                               G_UI_BOMADDINST_NODE_TYPE,
                               G_UI_PAGEDRILLDOWN_NODE_TYPE);
      ELSE
        UPDATE CZ_UI_PAGE_ELEMENTS
           SET deleted_flag=G_MARK_TO_DELETE
         WHERE ui_def_id=p_ui_node.ui_def_id AND
               page_id=i.page_id AND
               persistent_node_id=p_ui_node.persistent_node_id AND
               element_type IN(G_UI_NONBOMADDINST_NODE_TYPE,
                               G_UI_BOMADDINST_NODE_TYPE,
                               G_UI_PAGEDRILLDOWN_NODE_TYPE);
      END IF;

      mark_UI_Page_As_Refreshed(i.page_id, p_ui_node.ui_def_id);

    END LOOP;

      FOR parent_ui_node IN(SELECT * FROM CZ_UI_PAGE_ELEMENTS
                            WHERE ui_def_id=g_UI_Context.ui_def_id AND
                                  persistent_node_id=p_node.parent_persistent_node_id AND
                                  ((region_persistent_node_id=persistent_node_id OR
                                   pagebase_persistent_node_id=persistent_node_id) AND
                                   ctrl_template_id IN( G_CONTAINER_TEMPLATE_ID
                                                        ,G_NSTD_CONTAINER_TEMPLATE_ID
                                                        ,G_2COLS_CONTAINER_TEMPLATE_ID
                                                        ,G_3COLS_CONTAINER_TEMPLATE_ID)) AND
                                   deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE))
      LOOP
        IF NVL(parent_ui_node.suppress_refresh_flag, G_NO_FLAG) = G_NO_FLAG THEN
          IF p_ui_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) THEN
            --
            -- add new Instance Management COntrol to the parent UI Page
            --
            add_Instance_Controls(p_ui_node          => p_ui_node,
                                  p_parent_ui_node   => parent_ui_node,
                                  p_node             => p_node);
          ELSE -- MANDATORY
            IF l_new_parent_page_ref_id IS NULL THEN
              create_Drilldown_Button(p_parent_ui_node => parent_ui_node,
                                      p_ui_node        => p_ui_node,
                                      p_page_set_id    => l_page_set_id);
            END IF;
          END IF;
        END IF;
      END LOOP;

    END IF; -- end of IF p_node.parent_persistent_node_id<> ...

    --
    -- (n,m)/(0,1) => (1,1)
    --
    IF p_ui_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
       p_node.instantiable_flag=G_MANDATORY_INST_TYPE THEN

      g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;

      --
      -- remove all Instance Management Controls with a given
      -- persistent_node_id = p_ui_node.persistent_node_id
      --
      remove_Instance_Controls(p_ui_node);

      IF g_UI_Context.PRIMARY_NAVIGATION IN(G_SINGLE_PAGE,G_SUBTABS) OR
        l_new_parent_page_ref_id IS NULL  THEN

        FOR parent_ui_node IN(SELECT * FROM CZ_UI_PAGE_ELEMENTS
                              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                                  persistent_node_id=p_node.parent_persistent_node_id AND
                                  (region_persistent_node_id=persistent_node_id OR
                                   pagebase_persistent_node_id=persistent_node_id) AND
                                   ctrl_template_id IN( G_CONTAINER_TEMPLATE_ID
                                                        ,G_NSTD_CONTAINER_TEMPLATE_ID
                                                        ,G_2COLS_CONTAINER_TEMPLATE_ID
                                                        ,G_3COLS_CONTAINER_TEMPLATE_ID) AND
                                   deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE))
        LOOP
          IF NVL(parent_ui_node.suppress_refresh_flag, G_NO_FLAG) = G_NO_FLAG THEN
            create_Drilldown_Button(p_parent_ui_node => parent_ui_node,
                                    p_ui_node        => p_ui_node,
                                    p_page_set_id    => l_page_set_id);
          END IF;
        END LOOP;

      END IF;

      --
      -- if navigation style is not Dynamic Tree Menu then
      -- merge parent and child Page Flows
      --
      IF g_UI_Context.PRIMARY_NAVIGATION<>G_MODEL_TREE_MENU AND l_page_set_id IS NOT NULL AND
         NVL(l_page_set_suppress_flag,G_NO_FLAG)=G_NO_FLAG THEN
        merge_Page_Flows(p_ui_node);
      END IF;

    END IF;

    IF  p_ui_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
       p_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
       p_ui_node.instantiable_flag <> p_node.instantiable_flag THEN

      g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;

      --
      -- synchronize CZ_UI_PAGE_ELEMENTS.instantiable_flag with
      -- CZ_PS_NODES.instantiable_flag
      --
      FOR n IN(SELECT ui_def_id,page_id,element_id FROM CZ_UI_PAGE_ELEMENTS a
                WHERE ui_def_id=p_ui_node.ui_def_id AND
                      persistent_node_id=p_ui_node.persistent_node_id AND
                      element_type IN(G_UI_NONBOMADDINST_NODE_TYPE,G_UI_BOMADDINST_NODE_TYPE) AND
                      deleted_flag=G_NO_FLAG AND NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG AND
                      EXISTS(SELECT NULL FROM CZ_UI_PAGE_ELEMENTS
                              WHERE ui_def_id=p_ui_node.ui_def_id AND
                                    page_id=a.page_id AND
                                    element_id=a.parent_element_id AND
                                    NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG)
               )
     LOOP

      l_ui_node_name := get_UI_Node_Name(p_page_id       => n.page_id,
                                         p_template_id   => p_node.template_id,
                                         p_template_name => p_node.template_name);

      UPDATE CZ_UI_PAGE_ELEMENTS a
      SET ctrl_template_id =  p_node.template_id,
          ctrl_template_ui_def_id = p_node.template_ui_def_id,
          instantiable_flag = p_node.instantiable_flag,
          name=l_ui_node_name,
          deleted_flag=G_MARK_TO_REFRESH
      WHERE ui_def_id=n.ui_def_id AND
            page_id=n.page_id AND
            element_id=n.element_id;

       IF SQL%ROWCOUNT > 0 THEN
         l_changed_pages_tbl(l_changed_pages_tbl.COUNT+1) := n.page_id;
       END IF;
     END LOOP;

     IF l_changed_pages_tbl.COUNT>0 THEN
         FOR i IN l_changed_pages_tbl.First..l_changed_pages_tbl.Last
         LOOP
           mark_UI_Page_As_Refreshed(l_changed_pages_tbl(i), g_UI_Context.ui_def_id);
         END LOOP;
      END IF;

      FOR parent_ui_node IN(SELECT * FROM CZ_UI_PAGE_ELEMENTS a
                              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                                  persistent_node_id=p_node.parent_persistent_node_id AND
                                  (region_persistent_node_id=persistent_node_id OR
                                   pagebase_persistent_node_id=persistent_node_id) AND
                                   deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE) AND
                                   NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG AND
                                   ctrl_template_id IN( G_CONTAINER_TEMPLATE_ID
                                                        ,G_NSTD_CONTAINER_TEMPLATE_ID
                                                        ,G_2COLS_CONTAINER_TEMPLATE_ID
                                                        ,G_3COLS_CONTAINER_TEMPLATE_ID) AND
                                   NOT EXISTS(SELECT NULL FROM CZ_UI_PAGE_ELEMENTS b
                                               WHERE b.ui_def_id=g_UI_Context.ui_def_id AND
                                                     b.page_id=a.page_id AND
                                                     b.region_persistent_node_id=a.region_persistent_node_id AND
                                                     b.persistent_node_id=p_ui_node.persistent_node_id AND
                                                     b.element_type IN(G_UI_NONBOMADDINST_NODE_TYPE,G_UI_BOMADDINST_NODE_TYPE) AND
                                                     b.deleted_flag NOT IN(G_MARK_TO_DELETE,G_YES_FLAG))
                           )
      LOOP
        --
        -- add new Instance Management Control to the parent UI Page
        --
        add_Instance_Controls(p_ui_node          => p_ui_node,
                              p_parent_ui_node   => parent_ui_node,
                              p_node             => p_node);
      END LOOP;

    END IF;

    IF p_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
       p_ui_node.instantiable_flag=G_MANDATORY_INST_TYPE THEN

      g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;

      FOR parent_ui_node IN(SELECT * FROM CZ_UI_PAGE_ELEMENTS
                            WHERE ui_def_id=g_UI_Context.ui_def_id AND
                                  persistent_node_id=p_node.parent_persistent_node_id AND
                                  ((region_persistent_node_id=persistent_node_id OR
                                   pagebase_persistent_node_id=persistent_node_id) AND
                                   ctrl_template_id IN( G_CONTAINER_TEMPLATE_ID
                                                        ,G_NSTD_CONTAINER_TEMPLATE_ID
                                                        ,G_2COLS_CONTAINER_TEMPLATE_ID
                                                        ,G_3COLS_CONTAINER_TEMPLATE_ID)) AND
                                   deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE))
      LOOP
        IF NVL(parent_ui_node.suppress_refresh_flag, G_NO_FLAG) = G_NO_FLAG THEN
          --
          -- add new Instance Management COntrol to the parent UI Page
          --
          add_Instance_Controls(p_ui_node          => p_ui_node,
                                p_parent_ui_node   => parent_ui_node,
                                p_node             => p_node);
        END IF;
      END LOOP;

      IF g_UI_Context.PRIMARY_NAVIGATION NOT IN(G_MODEL_TREE_MENU) AND l_page_set_id IS NOT NULL AND
         NVL(l_page_set_suppress_flag,G_NO_FLAG)=G_NO_FLAG THEN
         split_Page_Flow(p_ui_node);
      END IF;

    END IF;

    --
    -- synchronize CZ_UI_PAGE_ELEMENTS.instantiable_flag with
    -- CZ_PS_NODES.instantiable_flag
    --
    UPDATE CZ_UI_PAGE_ELEMENTS
       SET instantiable_flag = p_node.instantiable_flag,
           parent_persistent_node_id=p_node.parent_persistent_node_id
     WHERE ui_def_id = p_ui_node.ui_def_id AND
           persistent_node_id = p_ui_node.persistent_node_id AND
           page_Id = p_ui_node.page_id;  --vsingava IM-ER


     replace_page_ref_target_path(p_ui_node, p_node);

  END check_Page_Changes;

  --
  -- change instantiability of Page
  --
  PROCEDURE check_Reference_Changes(p_ui_node        IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                    p_node           IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS
      l_refresh_ui_page    BOOLEAN:=FALSE;
      l_persistent_node_id NUMBER;
      l_max_seq_nbr        NUMBER;
      l_ps_node_type       NUMBER;
      l_ps_node            CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_target_path        CZ_UI_PAGE_REFS.target_path%TYPE;
      l_ui_node_name       CZ_UI_PAGE_ELEMENTS.name%TYPE;
      l_template_id        NUMBER;
      l_template_ui_def_id NUMBER;

  BEGIN

   IF p_ui_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
      p_node.instantiable_flag=G_MANDATORY_INST_TYPE THEN

       --jonatara:bug6439536
       g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;

       l_template_id := p_node.template_id;
       l_template_ui_def_id := p_node.template_ui_def_id;

       BEGIN

         SELECT ps_node_type INTO l_ps_node_type
           FROM CZ_PS_NODES
          WHERE devl_project_id=p_node.reference_id AND
                parent_id IS NULL AND
                deleted_flag=G_NO_FLAG;

         FOR i IN(SELECT persistent_node_id FROM CZ_UI_PAGE_ELEMENTS
                   WHERE ui_def_id=p_ui_node.ui_def_id
                         AND parent_element_id=p_ui_node.parent_element_id
                         AND persistent_node_id<>p_ui_node.persistent_node_id AND
                         deleted_flag IN(G_NO_FLAG,G_MARK_TO_REFRESH,G_MARK_TO_ADD))
         LOOP
           l_ps_node := get_Model_Node_By_Persist_Id(i.persistent_node_id,g_UI_COntext.devl_project_id);

           IF l_ps_node_type IN(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) AND
              (l_ps_node.ps_node_type IN(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) OR
              l_ps_node.detailed_type_id in(CZ_TYPES.UOPTIONAL_BOM_REF_TYPEID,CZ_TYPES.UMINMAX_BOM_REF_TYPEID)) THEN
              l_template_id := NULL;
              l_template_ui_def_id := NULL;
              EXIT;
           END IF;

         END LOOP;

       EXCEPTION
         WHEN OTHERS THEN
           DEBUG('check_Reference_Changes() : '||SQLERRM);
       END;

      l_ui_node_name := get_UI_Node_Name(p_page_id       => p_ui_node.page_id,
                                        p_template_id   => l_template_id,
                                        p_template_name => p_node.template_name);

      UPDATE CZ_UI_PAGE_ELEMENTS
      SET ctrl_template_id = l_template_id,
          ctrl_template_ui_def_id = l_template_ui_def_id,
          element_type = G_UI_DRILLDOWN_NODE_TYPE,
          instantiable_flag = p_node.instantiable_flag,
          name=l_ui_node_name,
          deleted_flag=G_MARK_TO_REFRESH
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            persistent_node_id=p_ui_node.persistent_node_id AND
            element_type IN(G_UI_NONBOMADDINST_NODE_TYPE,G_UI_BOMADDINST_NODE_TYPE) AND
            deleted_flag=G_NO_FLAG AND
            NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG;

      l_refresh_ui_page := TRUE;

   END IF;

   IF  p_ui_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
       p_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
       p_ui_node.instantiable_flag <> p_node.instantiable_flag THEN

       --jonatara:bug6439536
       g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;

      l_ui_node_name := get_UI_Node_Name(p_page_id       => p_ui_node.page_id,
                                         p_template_id   => l_template_id,
                                         p_template_name => p_node.template_name);

      --
      -- synchronize UI template with actual detailed node type
      --
      UPDATE CZ_UI_PAGE_ELEMENTS
      SET ctrl_template_id = p_node.template_id,
          ctrl_template_ui_def_id = p_node.template_ui_def_id,
          instantiable_flag = p_node.instantiable_flag,
          name=l_ui_node_name,
          deleted_flag=G_MARK_TO_REFRESH
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            persistent_node_id=p_ui_node.persistent_node_id AND
            element_type IN(G_UI_NONBOMADDINST_NODE_TYPE,G_UI_BOMADDINST_NODE_TYPE) AND
            deleted_flag=G_NO_FLAG AND
            NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG;

     IF SQL%ROWCOUNT>0 THEN
       l_refresh_ui_page := TRUE;
     END IF;

   END IF;

   IF p_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
      p_ui_node.instantiable_flag=G_MANDATORY_INST_TYPE THEN

       --jonatara:bug6439536
       g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;

      l_ui_node_name := get_UI_Node_Name(p_page_id       => p_ui_node.page_id,
                                         p_template_id   => l_template_id,
                                         p_template_name => p_node.template_name);

      --
      -- synchronize UI template with actual detailed node type
      --
      UPDATE CZ_UI_PAGE_ELEMENTS
      SET ctrl_template_id = p_node.template_id,
          ctrl_template_ui_def_id = p_node.template_ui_def_id,
          instantiable_flag = p_node.instantiable_flag,
          element_type = G_UI_NONBOMADDINST_NODE_TYPE,
          name=l_ui_node_name,
          deleted_flag=DECODE(NVL(ctrl_template_id,-1),-1,G_MARK_TO_ADD,G_MARK_TO_REFRESH)
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            page_id=p_ui_node.page_id AND
            element_id=p_ui_node.element_id AND
            NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG;
      IF SQL%ROWCOUNT>0 THEN
        l_refresh_ui_page := TRUE;
      END IF;
   END IF;

   IF l_refresh_ui_page THEN
     UPDATE CZ_UI_PAGES
        SET deleted_flag=G_MARK_TO_REFRESH,
            page_rev_nbr = page_rev_nbr + 1
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            page_id=p_ui_node.page_id;
   END IF;

   UPDATE CZ_UI_PAGE_ELEMENTS
      SET instantiable_flag = p_node.instantiable_flag
    WHERE ui_def_id = p_ui_node.ui_def_id AND
          persistent_node_id = p_ui_node.persistent_node_id AND
          instantiable_flag <> p_node.instantiable_flag;

    FOR i IN(SELECT page_set_id
               FROM CZ_UI_PAGE_REFS
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    target_persistent_node_id=p_ui_node.persistent_node_id AND
                    deleted_flag=G_NO_FLAG)
    LOOP
      l_target_path := get_Page_Path(p_node.ps_node_id, i.page_set_id);
      UPDATE CZ_UI_PAGE_REFS
         SET target_path=l_target_path
       WHERE ui_def_id=g_UI_Context.ui_def_id AND
             target_persistent_node_id=p_ui_node.persistent_node_id AND
             deleted_flag=G_NO_FLAG AND
              target_path<>l_target_path;
    END LOOP;

  END check_Reference_Changes;


  PROCEDURE check_Connector_Changes(p_ui_node        IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                    p_node           IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS
      l_refresh_ui_page    BOOLEAN:=FALSE;
      l_persistent_node_id NUMBER;
      l_max_seq_nbr        NUMBER;
      l_ps_node_type       NUMBER;
      l_ps_node            CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_target_path        CZ_UI_PAGE_REFS.target_path%TYPE;
      l_ui_node_name       CZ_UI_PAGE_ELEMENTS.name%TYPE;
      l_instantiable_flag  CZ_UI_PAGE_ELEMENTS.instantiable_flag%TYPE;
      l_template_id        NUMBER;
      l_template_ui_def_id NUMBER;

  BEGIN

   IF NVL(p_ui_node.instantiable_flag, '*') <> NVL(p_node.instantiable_flag, '*') THEN

      l_template_id := p_node.template_id;
      l_template_ui_def_id := p_node.template_ui_def_id;

      l_ui_node_name := get_UI_Node_Name(p_page_id       => p_ui_node.page_id,
                                         p_template_id   => l_template_id,
                                         p_template_name => p_node.template_name);

      IF (p_node.maximum=1 AND p_node.minimum=1) THEN
        l_instantiable_flag := G_MANDATORY_INST_TYPE;
      ELSIF (p_node.maximum=1 AND p_node.minimum=0) THEN
        l_instantiable_flag := G_OPTIONAL_INST_TYPE;
      ELSE
        l_instantiable_flag := G_MINMAX_INST_TYPE;
      END IF;

      UPDATE CZ_UI_PAGE_ELEMENTS
      SET ctrl_template_id = l_template_id,
          ctrl_template_ui_def_id = l_template_ui_def_id,
          instantiable_flag = l_instantiable_flag,
          name=l_ui_node_name,
          deleted_flag=G_MARK_TO_REFRESH
      WHERE ui_def_id=p_ui_node.ui_def_id AND
            persistent_node_id=p_ui_node.persistent_node_id AND
            deleted_flag=G_NO_FLAG AND
            NVL(suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG;

      IF SQL%ROWCOUNT > 0 THEN
        UPDATE CZ_UI_PAGES
           SET deleted_flag=G_MARK_TO_REFRESH,
              page_rev_nbr = page_rev_nbr + 1
         WHERE ui_def_id=p_ui_node.ui_def_id AND
               page_id=p_ui_node.page_id;
      END IF;

   END IF;

  END check_Connector_Changes;

  --
  -- change instantiability of UI region
  --
  PROCEDURE check_Region_Changes(p_ui_node      IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                 p_node         IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

    l_page_ui_node                CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_page_set_id                 CZ_UI_PAGE_SETS.page_set_id%TYPE;
    l_page_ref_id                 CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_page_set_type               CZ_UI_PAGE_SETS.page_set_type%TYPE;

  BEGIN

   IF (p_node.instantiable_flag IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE)
       OR p_node.virtual_flag=G_NO_FLAG) AND
      p_ui_node.instantiable_flag=G_MANDATORY_INST_TYPE
      AND NVL(p_ui_node.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN

      g_check_boundaries_tbl(g_UI_Context.ui_def_id) := G_YES_FLAG;

      l_page_ui_node := create_UI_Page(p_node           => p_node,
                                       x_page_set_id    => l_page_set_id,
                                       x_page_set_type  => l_page_set_type,
                                       x_page_ref_id    => l_page_ref_id,
                                       p_parent_page_id => p_ui_node.page_id);

      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag=G_MARK_TO_DELETE
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             page_id=p_ui_node.page_id AND
             element_id=p_ui_node.element_id;

      UPDATE CZ_UI_PAGE_ELEMENTS
         SET page_id = l_page_ui_node.page_id,
             pagebase_persistent_node_id = l_page_ui_node.persistent_node_id,
             deleted_flag=G_MARK_TO_ADD
       WHERE (ui_def_id,page_id,element_id) IN
             (SELECT ui_def_id,page_id,element_id FROM
              CZ_UI_PAGE_ELEMENTS
              START WITH ui_def_id=p_ui_node.ui_def_id AND
                         page_id=p_ui_node.page_id AND
                         element_id=p_ui_node.element_id
              CONNECT BY
                         PRIOR ui_def_id=p_ui_node.ui_def_id AND
                         PRIOR page_id=p_ui_node.page_id AND
                         PRIOR element_id=parent_element_id AND
                         PRIOR deleted_flag <> G_YES_FLAG AND
                         ui_def_id=p_ui_node.ui_def_id AND
                         page_id=p_ui_node.page_id AND
                         deleted_flag <> G_YES_FLAG)
              AND element_id <> p_ui_node.element_id;

      UPDATE CZ_UI_PAGE_ELEMENTS
         SET parent_element_id=l_page_ui_node.element_id
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             page_id=l_page_ui_node.page_id AND
             parent_element_id=p_ui_node.element_id;

   --vsingava IM-ER
   ELSIF (p_node.instantiable_flag = G_MANDATORY_INST_TYPE AND p_ui_node.instantiable_flag IN (G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE)
          AND NVL(p_ui_node.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG) THEN

     -- We have an element that is not an Instance Management Table but bound to a previously Instantiable Component
     -- This element could contain an Instance List Region. So let's refresh it.
     -- Mark the page for refresh, we will handle the Instace List while refreshing model_paths
     DEBUG('Found region ' || p_ui_node.element_id || ' that is bound to a previously instantiable node');
     mark_UI_Page_As_Refreshed(p_ui_node.page_id, p_ui_node.ui_def_id);

   END IF;

  END check_Region_Changes;

  --
  -- add new UI node
  --
  PROCEDURE add_New_UI_Node(p_ui_node               IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                            p_insert_index          IN NUMBER DEFAULT -1,
                            p_model_node            IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                            p_suppress_refresh_flag IN VARCHAR2,
                            x_new_ui_pages_tbl      IN OUT NOCOPY ui_page_elements_tbl_type,
                            x_new_ui_node           OUT NOCOPY CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS

    l_old_page_id   NUMBER;
    l_page_set_id   NUMBER;
    l_page_set_type NUMBER;
    l_page_ref_id   NUMBER;
    l_drilldown     BOOLEAN;

  BEGIN

    IF p_model_node.ui_omit=G_YES_FLAG THEN
      RETURN;
    END IF;

    -- it must be a new UI page
    IF p_model_node.ps_node_type IN(G_PRODUCT_TYPE,G_COMPONENT_TYPE,
      G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) AND
           is_UI_Page(p_node     => p_model_node,
                      x_drilldown => l_drilldown) THEN

            BEGIN
              SELECT page_id INTO l_old_page_id FROM CZ_UI_PAGES
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    persistent_node_id=p_model_node.persistent_node_id AND
                    deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH) AND
                    rownum<2;
            EXCEPTION
              WHEN OTHERS THEN
                -- create new UI page
                x_new_ui_node := create_UI_Page(p_node            => p_model_node,
                                                 x_page_set_id     => l_page_set_id,
                                                 x_page_set_type   => l_page_set_type,
                                                 x_page_ref_id     => l_page_ref_id,
                                                 p_parent_page_id  => p_ui_node.page_id);

               x_new_ui_pages_tbl(x_new_ui_pages_tbl.COUNT+1) := x_new_ui_node;
            END;

       -- it must be UI Region
       ELSIF  p_model_node.ps_node_type IN(G_PRODUCT_TYPE,G_COMPONENT_TYPE,
             G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) AND NVL(p_suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN
          x_new_ui_node := create_UI_Region(p_node              => p_model_node,
                                            p_parent_ui_node    => p_ui_node,
                                            p_insert_index      => p_insert_index);
          --
          -- it must be UI Reference
          --
        ELSIF p_model_node.ps_node_type = G_REFERENCE_TYPE AND NVL(p_suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN
          x_new_ui_node := create_UI_Reference(p_node              => p_model_node,
                                               p_parent_ui_node    => p_ui_node);
          --
          -- other UI elements
          --
        ELSE
          IF p_model_node.ps_node_type NOT IN (G_OPTION_TYPE,G_BOM_STANDART_ITEM_TYPE) AND
             NVL(p_suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN
            x_new_ui_node := create_UI_Element(p_node              => p_model_node,
                                               p_parent_ui_node    => p_ui_node,
                                               p_insert_index      => p_insert_index);
          END IF;
        END IF; -- end of IF is_UI_Page()

  END;

  --
  -- check UI Node changes
  --
  PROCEDURE check_UI_Node_Changes(p_ui_node    IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                  p_model_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

    l_ui_layout_ui_style          CZ_UI_TEMPLATES.layout_ui_style%TYPE;
    l_model_layout_ui_style       CZ_UI_TEMPLATES.layout_ui_style%TYPE;
    l_feature_element_id          CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_under_root_ui_node          CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_max_seq_nbr                 NUMBER;

    CURSOR l_ui_bom_tab_cur IS
      SELECT * FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=p_ui_node.ui_def_id AND
             parent_element_id=p_ui_node.element_id AND
             persistent_node_id=p_model_node.persistent_node_id AND
             element_type=G_UI_BOMADDINST_NODE_TYPE AND
             deleted_flag NOT IN(G_YES_FLAG);

  BEGIN
     --
     -- refresh expl ids in UI tables
     --
     sync_Expl_Ids(p_model_node,p_ui_node);

     IF p_model_node.ps_node_type in(G_BOM_MODEL_TYPE,G_BOM_OPTION_CLASS_TYPE) AND
            p_ui_node.element_type IN(G_UI_PAGE_NODE_TYPE,G_UI_BOMADDINST_NODE_TYPE) AND
        NVL(p_ui_node.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN

              IF p_ui_node.element_type IN(G_UI_PAGE_NODE_TYPE) THEN
                --
                -- check for BOM control associated with the same model node
                -- as UI page
                --
                BEGIN
                  OPEN l_ui_bom_tab_cur;

                  LOOP
                    FETCH l_ui_bom_tab_cur INTO l_under_root_ui_node;
                    EXIT WHEN l_ui_bom_tab_cur%NOTFOUND;

                    IF l_under_root_ui_node.deleted_flag <> G_LIMBO_FLAG AND
                       l_under_root_ui_node.ctrl_template_id IS NOT NULL AND
                       l_under_root_ui_node.ctrl_template_id <> p_model_node.template_id AND
                       NVL(l_under_root_ui_node.suppress_refresh_flag, G_NO_FLAG)=G_NO_FLAG THEN

                       replace_Template_Id(p_ui_node     => l_under_root_ui_node,
                                           p_model_node  => p_model_node);
                    END IF;

                  END LOOP;

                  IF l_ui_bom_tab_cur%ROWCOUNT=0 THEN
                    add_BOM_Node(p_node                        => p_model_node,
                                 p_page_id                     => p_ui_node.page_id,
                                 p_pagebase_expl_node_id       => p_ui_node.model_ref_expl_id,
                                 p_parent_element_id           => p_ui_node.element_id,
                                 p_pagebase_persistent_node_id => p_ui_node.pagebase_persistent_node_id);
                  END IF;

                  CLOSE l_ui_bom_tab_cur;

                END;

              ELSE -- else for IF p_ui_node.element_type IN(G_UI_PAGE_NODE_TYPE) THEN

                IF p_ui_node.ctrl_template_id <> p_model_node.template_id THEN
                   replace_Template_Id(p_ui_node     => p_ui_node,
                                       p_model_node  => p_model_node);
                END IF;

              END IF;

    END IF;

    IF p_ui_node.pagebase_persistent_node_id=p_ui_node.persistent_node_id THEN

            --
            -- check changes of this UI page
            --
            check_Page_Changes(p_ui_node        => p_ui_node,
                               p_node           => p_model_node);

    ELSIF p_ui_node.pagebase_persistent_node_id<>p_ui_node.persistent_node_id AND
          p_ui_node.region_persistent_node_id=p_ui_node.persistent_node_id AND
          NVL(p_ui_node.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN

            --
            -- check changes of this reference
            --
            check_Region_Changes(p_ui_node        => p_ui_node,
                                 p_node           => p_model_node);

    ELSIF p_model_node.ps_node_type=G_REFERENCE_TYPE AND
               p_model_node.persistent_node_id=p_ui_node.persistent_node_id THEN

            --
            -- check changes of this reference
            --
            check_Reference_Changes(p_ui_node        => p_ui_node,
                                    p_node           => p_model_node);

    ELSIF p_model_node.ps_node_type=G_CONNECTOR_TYPE AND
               p_model_node.persistent_node_id=p_ui_node.persistent_node_id THEN

            --
            -- check changes of this reference
            --
            check_Connector_Changes(p_ui_node        => p_ui_node,
                                    p_node           => p_model_node);

    ELSIF p_model_node.ps_node_type=G_FEATURE_TYPE AND
               p_model_node.feature_type=0 AND
               p_model_node.template_id <> p_ui_node.ctrl_template_id AND
               (g_using_new_UI_refresh OR p_model_node.detailed_type_id<>p_ui_node.element_type) AND
               p_model_node.template_id IS NOT NULL AND
               p_ui_node.ctrl_template_id IS NOT NULL AND
               NVL(p_ui_node.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN

       BEGIN

         IF g_using_new_UI_refresh THEN
           replace_Template_Id(p_ui_node          => p_ui_node,
                                   p_model_node       => p_model_node);
         ELSE
           SELECT layout_ui_style INTO l_ui_layout_ui_style
                 FROM CZ_UI_TEMPLATES
                 WHERE template_id=p_ui_node.ctrl_template_id AND
                       ui_def_id=p_ui_node.ctrl_template_ui_def_id;

                 SELECT layout_ui_style INTO l_model_layout_ui_style
                 FROM CZ_UI_TEMPLATES
                 WHERE template_id=p_model_node.template_id AND
                       ui_def_id=p_model_node.template_ui_def_id;

                 IF l_ui_layout_ui_style=l_model_layout_ui_style  THEN
                   --
                   -- replace Feature template
                   --
                   replace_Template_Id(p_ui_node          => p_ui_node,
                                       p_model_node       => p_model_node);
                 ELSE

                   BEGIN
                     SELECT NVL(MAX(seq_nbr),0)+1 INTO l_max_seq_nbr FROM CZ_UI_PAGE_ELEMENTS
                     WHERE ui_def_id=g_UI_Context.ui_def_id AND
                           page_id=p_ui_node.page_id AND
                           parent_element_id IS NOT NULL AND
                           (ctrl_template_id,ctrl_template_ui_def_id) IN
                           (SELECT ctrl_template_id,ctrl_template_ui_def_id FROM
                            CZ_UI_TEMPLATES WHERE deleted_flag=G_NO_FLAG AND
                            layout_ui_style=l_ui_layout_ui_style);
                   EXCEPTION
                     WHEN OTHERS THEN
                       l_max_seq_nbr := 1;
                   END;

                   IF l_max_seq_nbr = 1 THEN

                     --
                     -- replace Feature template
                     --
                     replace_Template_Id(p_ui_node          => p_ui_node,
                                         p_model_node       => p_model_node);

                   ELSE

                     UPDATE CZ_UI_PAGE_ELEMENTS
                        SET deleted_flag=G_MARK_TO_DELETE
                      WHERE ui_def_id=g_UI_Context.ui_def_id AND
                            page_id=p_ui_node.page_id AND
                            element_id=p_ui_node.element_id;

                     UPDATE CZ_UI_PAGES
                        SET deleted_flag=G_MARK_TO_REFRESH,
                            page_rev_nbr=page_rev_nbr+1
                      WHERE page_id=p_ui_node.page_id AND
                            ui_def_id=g_UI_Context.ui_def_id;

                      l_feature_element_id := get_Element_Id();

                      INSERT INTO CZ_UI_PAGE_ELEMENTS
                      (
                     UI_DEF_ID
                     ,PAGE_ID
                     ,PERSISTENT_NODE_ID
                     ,ELEMENT_ID
                     ,PARENT_PERSISTENT_NODE_ID
                     ,REGION_PERSISTENT_NODE_ID
                     ,PAGEBASE_PERSISTENT_NODE_ID
                     ,CTRL_TEMPLATE_ID
                     ,BASE_PAGE_FLAG
                     ,INSTANTIABLE_FLAG
                     ,SEQ_NBR
                     ,DELETED_FLAG
                     ,CTRL_TEMPLATE_UI_DEF_ID
                     ,MODEL_REF_EXPL_ID
                     ,PARENT_ELEMENT_ID
                     ,ELEMENT_TYPE
                     ,NAME
                     ,ELEMENT_SIGNATURE_ID
                     ,SUPPRESS_REFRESH_FLAG
                      )
                      SELECT
                     UI_DEF_ID
                     ,PAGE_ID
                     ,PERSISTENT_NODE_ID
                     ,l_feature_element_id
                     ,PARENT_PERSISTENT_NODE_ID
                     ,REGION_PERSISTENT_NODE_ID
                     ,PAGEBASE_PERSISTENT_NODE_ID
                     ,p_model_node.template_id
                     ,BASE_PAGE_FLAG
                     ,INSTANTIABLE_FLAG
                     ,l_max_seq_nbr
                     ,G_MARK_TO_ADD
                     ,p_model_node.template_ui_def_id
                     ,MODEL_REF_EXPL_ID
                     ,PARENT_ELEMENT_ID
                     ,ELEMENT_TYPE
                     ,NAME
                     ,ELEMENT_SIGNATURE_ID
                     ,SUPPRESS_REFRESH_FLAG
                      FROM CZ_UI_PAGE_ELEMENTS
                      WHERE ui_def_id=g_UI_Context.ui_def_id AND
                            page_id=p_ui_node.page_id AND
                            element_id=p_ui_node.element_id;

                      UPDATE CZ_UI_PAGE_ELEMENTS
                         SET parent_element_id=l_feature_element_id
                       WHERE ui_def_id=g_UI_Context.ui_def_id AND
                             page_id=p_ui_node.page_id AND
                             parent_element_id=p_ui_node.element_id;

                   END IF; -- end of IF l_max_seq_nbr = 1
                END IF;  -- end of IF l_ui_layout_ui_style=l_model_layout_ui_style
              END IF;
            END;

    ELSE  --vsingava IM-ER
      IF (p_model_node.instantiable_flag = G_MANDATORY_INST_TYPE AND p_ui_node.instantiable_flag IN (G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE)
          AND NVL(p_ui_node.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG) THEN

         -- We have an element that is not an Instance Management Table but bound to a previously Instantiable Component
         -- This element could contain an Instance List Region. So let's refresh it.
         -- Mark the page for refresh, we will handle the Instace List while refreshing model_paths
         mark_UI_Page_As_Refreshed(p_ui_node.page_id, p_ui_node.ui_def_id);
      END IF;

    END IF;  -- end of IF p_ui_node.pagebase_persistent_node_id...

    --
    -- add a new CX to an existing UI node
    -- if there is such CX
    --
    IF get_CX_Button_Status(p_ui_node)=G_CX_VALID THEN

      add_CX_Button(p_node     => p_model_node,
                    p_ui_node  => p_ui_node);
    END IF;

  END check_UI_Node_Changes;

  --
  -- create new split UI Page
  --
  FUNCTION clone_UI_Page(p_page_id  IN NUMBER)
    RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE IS

    l_element_id              CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_ui_node                 CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_split_seq_nbr           CZ_UI_PAGES.split_seq_nbr%TYPE;
    l_page_id                 CZ_UI_PAGES.page_id%TYPE;
    l_page_ref_id             CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_seq_nbr                 CZ_UI_PAGE_REFS.seq_nbr%TYPE;
    l_caption_text_id         NUMBER;
    l_caption                 CZ_INTL_TEXTS.text_str%TYPE;

  BEGIN

    --
    -- get num of this page in this UI
    --
   l_split_seq_nbr := get_Last_Split_Page_Nbr(p_page_id) + 1;


   l_caption := G_UMPERS||G_CAPTION_RULE_TOKENNAME||' ('||TO_CHAR(l_split_seq_nbr)||')';

   l_caption_text_id := allocateId('CZ_INTL_TEXTS_S');

   l_element_id := get_Element_Id();
   l_page_id := allocateId('CZ_UI_PAGES_S');

   INSERT INTO CZ_INTL_TEXTS
   (
   INTL_TEXT_ID
   ,TEXT_STR
   ,DELETED_FLAG
   ,SEEDED_FLAG
   ,UI_DEF_ID
   ,MODEL_ID
   ,UI_PAGE_ID
   ,UI_PAGE_ELEMENT_ID
    )
   VALUES
   (
   l_caption_text_id
   ,l_caption
   ,G_NO_FLAG
   ,G_NO_FLAG
   ,g_UI_Context.ui_def_id
   ,g_UI_Context.devl_project_id
   ,l_page_id
   ,NULL
    );

   INSERT INTO CZ_UI_PAGES
      (page_id,
       ui_def_id,
       NAME,
       persistent_node_id,
       jrad_doc,
       page_set_id,
       split_seq_nbr,
       caption_source,
       caption_text_id,
       PERSISTENT_CAPTION_TEXT_ID,
       pagebase_path,
       pagebase_expl_node_id,
       page_rev_nbr,
       seeded_flag,
       DESC_TEXT,
       PAGE_STATUS_TEMPLATE_ID,
       PAGE_STATUS_TEMPL_UIDEF_ID,
       CAPTION_RULE_ID,
       OUTER_TEMPLATE_USAGE,
       OUTER_PAGE_TEMPLATE_ID,
       OUTER_PAGE_TEMPL_UIDEF_ID,
       DISPLAY_CONDITION_ID,
       DISPLAY_CONDITION_COMP,
       DISPLAY_CONDITION_VALUE,
       ENABLED_CONDITION_ID,
       ENABLED_CONDITION_COMP,
       ENABLED_CONDITION_VALUE,
       EMPTY_PAGE_FLAG,
       SUPPRESS_REFRESH_FLAG,
       deleted_flag)
   SELECT
       l_page_id,
       ui_def_id,
       name||' ('||TO_CHAR(l_split_seq_nbr)||')',
       persistent_node_id,
       jrad_doc||'_'||TO_CHAR(l_split_seq_nbr),
       page_set_id,
       l_split_seq_nbr,
       caption_source,
       l_caption_text_id,
       l_caption_text_id,
       pagebase_path,
       pagebase_expl_node_id,
       1,
       seeded_flag,
       DESC_TEXT,
       PAGE_STATUS_TEMPLATE_ID,
       PAGE_STATUS_TEMPL_UIDEF_ID,
       CAPTION_RULE_ID,
       OUTER_TEMPLATE_USAGE,
       OUTER_PAGE_TEMPLATE_ID,
       OUTER_PAGE_TEMPL_UIDEF_ID,
       DISPLAY_CONDITION_ID,
       DISPLAY_CONDITION_COMP,
       DISPLAY_CONDITION_VALUE,
       ENABLED_CONDITION_ID,
       ENABLED_CONDITION_COMP,
       ENABLED_CONDITION_VALUE,
       EMPTY_PAGE_FLAG,
       SUPPRESS_REFRESH_FLAG,
       G_MARK_TO_ADD
   FROM CZ_UI_PAGES
   WHERE ui_def_id=g_UI_Context.ui_def_id AND
         page_id=p_page_id;

    SELECT * INTO l_ui_node
    FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          page_id=p_page_id AND
          parent_element_id IS NULL AND
          deleted_flag IN(G_NO_FLAG,G_MARK_TO_ADD,G_MARK_TO_REFRESH);

    l_ui_node.element_id   := l_element_id;
    l_ui_node.page_id      := l_page_id;
    l_ui_node.name         := l_ui_node.name||' - '||l_element_id;
    l_ui_node.deleted_flag := G_MARK_TO_ADD;

    INSERT INTO CZ_UI_PAGE_ELEMENTS
      (ui_def_id,
       persistent_node_id,
       parent_persistent_node_id,
       region_persistent_node_id,
       pagebase_persistent_node_id,
       page_id,
       seq_nbr,
       ctrl_template_id,
       element_id,
       parent_element_id,
       element_type,
       instantiable_flag,
       ctrl_template_ui_def_id,
       model_ref_expl_id,
       base_page_flag,
       element_signature_id,
       name,
       deleted_flag)
   VALUES
       (l_ui_node.ui_def_id,
       l_ui_node.persistent_node_id,
       l_ui_node.parent_persistent_node_id,
       l_ui_node.region_persistent_node_id,
       l_ui_node.pagebase_persistent_node_id,
       l_ui_node.page_id,
       l_ui_node.seq_nbr,
       l_ui_node.ctrl_template_id,
       l_ui_node.element_id,
       l_ui_node.parent_element_id,
       l_ui_node.element_type,
       l_ui_node.instantiable_flag,
       l_ui_node.ctrl_template_ui_def_id,
       l_ui_node.model_ref_expl_id,
       l_ui_node.base_page_flag,
       l_ui_node.element_signature_id,
       l_ui_node.name,
       l_ui_node.deleted_flag);

    SELECT NVL(MAX(seq_nbr),0) INTO l_seq_nbr
    FROM CZ_UI_PAGE_REFS
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          target_persistent_node_id=l_ui_node.persistent_node_id AND
          deleted_flag=G_NO_FLAG;

    UPDATE CZ_UI_PAGE_REFS
       SET seq_nbr=seq_nbr+1
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           parent_page_ref_id = (SELECT parent_page_ref_id
                                 FROM CZ_UI_PAGE_REFS
                                 WHERE ui_def_id=g_UI_Context.ui_def_id AND
                                       target_page_id=p_page_id AND
                                       deleted_flag=G_NO_FLAG) AND
           seq_nbr > l_seq_nbr AND
           deleted_flag=G_NO_FLAG;

    l_seq_nbr := l_seq_nbr + 1;

    l_page_ref_id := allocateId('CZ_UI_PAGE_REFS_S');
    INSERT INTO CZ_UI_PAGE_REFS
      (ui_def_id,
       page_set_id,
       page_ref_id,
       parent_page_ref_id,
       seq_nbr,
       node_depth,
       condition_id,
       NAME,
       caption_source,
       caption_text_id,
       target_persistent_node_id,
       target_path,
       target_ui_def_id,
       target_page_set_id,
       target_page_id,
       modified_flags,
       path_to_prev_page,
       path_to_next_page,
       page_ref_type,
       target_expl_node_id,
       deleted_flag)
    SELECT
       ui_def_id,
       page_set_id,
       l_page_ref_id,
       parent_page_ref_id,
       l_seq_nbr,
       node_depth,
       condition_id,
       NAME||' ('||TO_CHAR(l_split_seq_nbr)||')',
       caption_source,
       l_caption_text_id,
       target_persistent_node_id,
       target_path,
       target_ui_def_id,
       target_page_set_id,
       l_page_id,
       modified_flags,
       NULL,
       path_to_next_page,
       page_ref_type,
       target_expl_node_id,
       deleted_flag
    FROM CZ_UI_PAGE_REFS
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          target_page_id=p_page_id AND
          deleted_flag=G_NO_FLAG;

    RETURN l_ui_node;

  END clone_UI_Page;

  PROCEDURE collect_UI_Elements
  (p_ui_page_node            IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
   p_max_controls_per_page   IN NUMBER,
   x_new_pages_tbl           OUT NOCOPY number_tbl_type,
   x_elements_tbl            OUT NOCOPY ui_page_elements_tbl_type,
   x_new_parent_elements_tbl OUT NOCOPY varchar_tbl_type) IS

    l_ui_page_node         CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_counter              NUMBER:=0;

  BEGIN

    l_ui_page_node := p_ui_page_node;

    FOR k IN(SELECT page_id,TO_NUMBER(element_id) AS element_id,
             TO_NUMBER(parent_element_id) AS parent_element_id,seq_nbr
             FROM CZ_UI_PAGE_ELEMENTS
             WHERE ui_def_id = p_ui_page_node.ui_def_id AND
                   page_id = p_ui_page_node.page_id AND
                   parent_element_id IS NOT NULL AND
                   element_type <> G_UI_REGION_NODE_TYPE AND
                   ctrl_template_id IS NOT NULL
                   AND deleted_flag IN(G_MARK_TO_ADD,G_MARK_DO_NOT_REFRESH)
          ORDER BY  seq_nbr)
    LOOP
      --
      -- increase counter of nodes on the page ( initial l_counter must be 0 )
      --
      l_counter:=l_counter+1;
      --
      -- compare previous page and page created in this loop
      --
      IF (l_counter > p_max_controls_per_page) THEN
        l_ui_page_node := clone_UI_Page(k.page_id);
        l_counter := 1;
        x_new_pages_tbl(l_ui_page_node.page_id) := l_ui_page_node.pagebase_persistent_node_id;
      END IF;

      IF l_ui_page_node.page_id <> p_ui_page_node.page_id THEN
        x_elements_tbl(k.element_id) := l_ui_page_node;
        IF k.parent_element_id = p_ui_page_node.element_id THEN
          x_new_parent_elements_tbl(k.element_id) := l_ui_page_node.element_id;
        END IF;
      END IF;

    END LOOP;

  END collect_UI_Elements;

  PROCEDURE handle_Direct_Child_Nodes
  (p_ui_page_node        IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
   p_elements_tbl        IN OUT NOCOPY ui_page_elements_tbl_type,
   p_parent_elements_tbl IN OUT NOCOPY varchar_tbl_type) IS

    l_current_element_id NUMBER;

  BEGIN

    l_current_element_id := p_elements_tbl.First;
    LOOP
      IF l_current_element_id IS NULL THEN
        EXIT;
      END IF;

      UPDATE CZ_UI_PAGE_ELEMENTS
         SET page_id = p_elements_tbl(l_current_element_id).page_id
       WHERE ui_def_id =  p_ui_page_node.ui_def_id AND
             page_id = p_ui_page_node.page_id AND
             element_id = TO_CHAR(l_current_element_id);

      IF p_parent_elements_tbl.EXISTS(l_current_element_id) THEN
        UPDATE CZ_UI_PAGE_ELEMENTS
           SET parent_element_id = p_parent_elements_tbl(l_current_element_id)
         WHERE ui_def_id =  p_ui_page_node.ui_def_id AND
               page_id = p_ui_page_node.page_id AND
               element_id = TO_CHAR(l_current_element_id);
      END IF;

      UPDATE CZ_UI_ACTIONS
         SET source_page_id=p_elements_tbl(l_current_element_id).page_id
       WHERE ui_def_id=p_ui_page_node.ui_def_id AND
             source_page_id= p_ui_page_node.page_id AND
             element_id=TO_CHAR(l_current_element_id);

      l_current_element_id := p_elements_tbl.NEXT(l_current_element_id);
    END LOOP;

    l_current_element_id := p_elements_tbl.First;
    LOOP
      IF l_current_element_id IS NULL THEN
        EXIT;
      END IF;

      IF p_parent_elements_tbl.EXISTS(l_current_element_id) THEN
        UPDATE CZ_UI_PAGE_ELEMENTS
           SET parent_element_id = p_parent_elements_tbl(l_current_element_id)
         WHERE ui_def_id =  p_ui_page_node.ui_def_id AND
               page_id = p_elements_tbl(l_current_element_id).page_id  AND
               element_id = TO_CHAR(l_current_element_id);
      END IF;

      l_current_element_id := p_elements_tbl.NEXT(l_current_element_id);
    END LOOP;

  END handle_Direct_Child_Nodes;

  PROCEDURE collect_Old_Nodes
  (
  p_ui_def_id                IN NUMBER,
  p_new_page_id              IN NUMBER,
  x_nested_page_elements_tbl OUT NOCOPY varchar_tbl_type) IS

  BEGIN

    FOR i IN(SELECT DISTINCT parent_element_id FROM CZ_UI_PAGE_ELEMENTS a
             WHERE ui_def_id =  p_ui_def_id AND
                   page_id = p_new_page_id AND
                   parent_element_id IS NOT NULL AND
               NOT EXISTS(SELECT NULL FROM CZ_UI_PAGE_ELEMENTS
               WHERE  ui_def_id =  p_ui_def_id AND
                      page_id = p_new_page_id AND
                      element_id=a.parent_element_id))
      LOOP
        x_nested_page_elements_tbl(x_nested_page_elements_tbl.COUNT+1) := i.parent_element_id;
      END LOOP;

  END collect_Old_Nodes;

  PROCEDURE collect_New_Nested_Regions
  (p_ui_def_id        IN NUMBER,
   p_page_id          IN NUMBER,
   p_element_id       IN VARCHAR2,
   px_rgn_new_elements_tbl IN OUT NOCOPY varchar_tbl_type,
   px_rgn_parent_elements_tbl IN OUT NOCOPY varchar_tbl_type) IS

    l_new_element_id   VARCHAR2(255);
    l_num_element_id   NUMBER;

  BEGIN

    FOR i IN(SELECT element_id,parent_element_id,element_type FROM CZ_UI_PAGE_ELEMENTS
             START WITH ui_def_id =  p_ui_def_id AND
                        page_id= p_page_id AND
                        element_id=p_element_id
             CONNECT BY PRIOR  ui_def_id =  p_ui_def_id AND
                               ui_def_id =  p_ui_def_id AND
                     PRIOR page_id= p_page_id AND page_id= p_page_id AND
                     PRIOR parent_element_id=element_id)
    LOOP
      l_num_element_id := TO_NUMBER(i.element_id);
      IF i.parent_element_id IS NOT NULL AND i.element_type=G_UI_REGION_NODE_TYPE AND
        NOT(px_rgn_new_elements_tbl.EXISTS(l_num_element_id)) THEN
        l_new_element_id := get_Element_Id();
        px_rgn_new_elements_tbl(l_num_element_id) := l_new_element_id;
        px_rgn_parent_elements_tbl(l_num_element_id) := i.parent_element_id;
      END IF;
    END LOOP;

  END collect_New_Nested_Regions;


  PROCEDURE reconstruct_Nested_Regions
  (
  p_ui_def_id     IN NUMBER,
  p_page_id       IN NUMBER,
  p_new_pages_tbl IN number_tbl_type
  ) IS

    l_nested_rgn_elements_tbl  varchar_tbl_type;
    l_rgn_subtree_tbl          varchar_tbl_type;
    l_parent_elements_tbl      varchar_tbl_type;
    l_new_page_id              NUMBER;
    l_new_element_id           VARCHAR2(255);
    l_new_parent_element_id    VARCHAR2(255);
    l_old_element_id           NUMBER;
    l_page_root_element_id     VARCHAR2(255);

  BEGIN

    l_new_page_id := p_new_pages_tbl.First;
    LOOP
      IF l_new_page_id IS NULL THEN
        EXIT;
      END IF;

      l_nested_rgn_elements_tbl.DELETE;

      SELECT element_id INTO l_page_root_element_id FROM CZ_UI_PAGE_ELEMENTS
      WHERE ui_def_id=p_ui_def_id AND
            page_id=l_new_page_id AND
            parent_element_id IS NULL AND
            deleted_flag NOT IN(G_YES_FLAG, G_MARK_TO_DELETE);

      collect_Old_Nodes(p_ui_def_id                => p_ui_def_id,
                        p_new_page_id              => l_new_page_id,
                        x_nested_page_elements_tbl => l_nested_rgn_elements_tbl);

      IF l_nested_rgn_elements_tbl.COUNT > 0 THEN

        FOR i IN l_nested_rgn_elements_tbl.First..l_nested_rgn_elements_tbl.Last
        LOOP
          collect_New_Nested_Regions(p_ui_def_id             => p_ui_def_id,
                                     p_page_id               => p_page_id,
                                     p_element_id            => l_nested_rgn_elements_tbl(i),
                                     px_rgn_new_elements_tbl => l_rgn_subtree_tbl,
                                     px_rgn_parent_elements_tbl => l_parent_elements_tbl );
        END LOOP;

      END IF;

      IF l_rgn_subtree_tbl.COUNT > 0 THEN

        l_old_element_id := l_rgn_subtree_tbl.First;
        LOOP
          IF l_old_element_id IS NULL THEN
            EXIT;
          END IF;

          l_new_element_id := l_rgn_subtree_tbl(l_old_element_id);
          IF l_rgn_subtree_tbl.EXISTS(TO_NUMBER(l_parent_elements_tbl(l_old_element_id))) THEN
            l_new_parent_element_id := l_rgn_subtree_tbl(TO_NUMBER(l_parent_elements_tbl(l_old_element_id)));
          ELSE
            l_new_parent_element_id := l_page_root_element_id;
          END IF;
          INSERT INTO CZ_UI_PAGE_ELEMENTS
             (UI_DEF_ID
             ,PAGE_ID
             ,PERSISTENT_NODE_ID
             ,ELEMENT_ID
             ,PARENT_ELEMENT_ID
             ,PARENT_PERSISTENT_NODE_ID
             ,REGION_PERSISTENT_NODE_ID
             ,PAGEBASE_PERSISTENT_NODE_ID
             ,CTRL_TEMPLATE_ID
             ,BASE_PAGE_FLAG
             ,INSTANTIABLE_FLAG
             ,SEQ_NBR
             ,DELETED_FLAG
             ,CTRL_TEMPLATE_UI_DEF_ID
             ,MODEL_REF_EXPL_ID
             ,ELEMENT_TYPE
             ,NAME
             ,ELEMENT_SIGNATURE_ID
             ,SUPPRESS_REFRESH_FLAG)
           SELECT
              UI_DEF_ID
             ,l_new_page_id
             ,PERSISTENT_NODE_ID
             ,l_new_element_id
             ,l_new_parent_element_id
             ,PARENT_PERSISTENT_NODE_ID
             ,REGION_PERSISTENT_NODE_ID
             ,pagebase_persistent_node_id
             ,CTRL_TEMPLATE_ID
             ,BASE_PAGE_FLAG
             ,INSTANTIABLE_FLAG
             ,SEQ_NBR
             ,DELETED_FLAG
             ,CTRL_TEMPLATE_UI_DEF_ID
             ,MODEL_REF_EXPL_ID
             ,ELEMENT_TYPE
             ,NAME
             ,ELEMENT_SIGNATURE_ID
             ,SUPPRESS_REFRESH_FLAG
           FROM CZ_UI_PAGE_ELEMENTS
           WHERE ui_def_id=p_ui_def_id AND
                 page_id=p_page_id AND
                 element_id=TO_CHAR(l_old_element_id);

          UPDATE CZ_UI_PAGE_ELEMENTS
             SET parent_element_id=l_new_element_id
           WHERE ui_def_id=p_ui_def_id AND
                 page_id=l_new_page_id AND
                 parent_element_id=TO_CHAR(l_old_element_id);

          l_old_element_id := l_rgn_subtree_tbl.NEXT(l_old_element_id);
        END LOOP;

      END IF; -- end of  IF l_rgn_subtree_tbl.COUNT > 0 THEN

      l_new_page_id := p_new_pages_tbl.NEXT(l_new_page_id);

    END LOOP; -- end of loop through p_new_pages_tbl

  END reconstruct_Nested_Regions;

  --
  -- split a single Page
  -- Parameters :
  -- p_ui_node - identifies UI node of page
  --
  PROCEDURE split_Page(p_ui_page_node          IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                       p_max_controls_per_page IN NUMBER ) IS

    l_elements_tbl              ui_page_elements_tbl_type;
    l_new_pages_tbl             number_tbl_type;
    l_parent_elements_tbl       varchar_tbl_type;

  BEGIN

    IF p_ui_page_node.suppress_refresh_flag=G_YES_FLAG THEN
      RETURN;
    END IF;

    SAVEPOINT split_Page_Point;

    collect_UI_Elements(p_ui_page_node            => p_ui_page_node,
                        p_max_controls_per_page   => p_max_controls_per_page,
                        x_new_pages_tbl           => l_new_pages_tbl,
                        x_elements_tbl            => l_elements_tbl,
                        x_new_parent_elements_tbl => l_parent_elements_tbl);

    handle_Direct_Child_Nodes(p_ui_page_node        => p_ui_page_node,
                              p_elements_tbl        => l_elements_tbl,
                              p_parent_elements_tbl => l_parent_elements_tbl);

    reconstruct_Nested_Regions(p_ui_def_id     => p_ui_page_node.ui_def_id,
                               p_page_id       => p_ui_page_node.page_id,
                               p_new_pages_tbl => l_new_pages_tbl);
  EXCEPTION
    WHEN OTHERS THEN
         ROLLBACK TO split_Page_Point;
         DEBUG('split_Page() : fatal error "'||SQLERRM||'"');
  END split_Page;

  --
  -- split UI pages if they must be split
  --
  PROCEDURE split_Pages IS

    l_num_if_roots              NUMBER;
    l_target_persistent_node_id NUMBER;
    l_page_set_id               NUMBER;
    l_page_set_type             NUMBER;
    l_page_ref_id               NUMBER;
    l_max_controls_per_page     NUMBER;

  BEGIN

    IF g_UI_Context.control_layout IN(1,2) THEN
      l_max_controls_per_page := g_UI_CONTEXT.PAGIN_MAXCONTROLS*(g_UI_Context.control_layout+1);
    ELSE
      l_max_controls_per_page := g_UI_CONTEXT.PAGIN_MAXCONTROLS;
    END IF;

    --
    -- split UI Pages
    --
    FOR i IN (SELECT *
                FROM CZ_UI_PAGE_ELEMENTS
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     parent_element_id IS NULL AND
                     persistent_node_id=pagebase_persistent_node_id AND
                     NVL(suppress_refresh_flag, G_NO_FLAG) = G_NO_FLAG AND
                     deleted_flag IN (G_MARK_TO_ADD))
    LOOP
      split_Page(i, l_max_controls_per_page);
    END LOOP;

    IF g_UI_Context.PRIMARY_NAVIGATION=G_MODEL_TREE_MENU THEN
      SELECT COUNT(*) INTO l_num_if_roots FROM CZ_UI_PAGE_REFS
      WHERE ui_def_id=g_UI_Context.ui_def_id AND parent_page_ref_id IS NULL
            AND target_persistent_node_id=(SELECT persistent_node_id FROM CZ_PS_NODES
            WHERE devl_project_id=g_UI_Context.devl_project_id AND parent_id IS NULL AND
            deleted_flag=G_NO_FLAG) AND deleted_flag=G_NO_FLAG;
     IF l_num_if_roots > 1 THEN

        SELECT target_persistent_node_id,page_set_id,page_ref_type
          INTO l_target_persistent_node_id,l_page_set_id,l_page_set_type
          FROM CZ_UI_PAGE_REFS
          WHERE ui_def_id=g_UI_Context.ui_def_id AND parent_page_ref_id IS NULL
               AND target_persistent_node_id=(SELECT persistent_node_id FROM CZ_PS_NODES
               WHERE devl_project_id=g_UI_Context.devl_project_id AND parent_id IS NULL AND
               deleted_flag=G_NO_FLAG) AND deleted_flag=G_NO_FLAG AND rownum<2;

        l_page_ref_id := allocateId('CZ_UI_PAGE_REFS_S');

    INSERT INTO CZ_UI_PAGE_REFS
      (ui_def_id,
       page_set_id,
       page_ref_id,
       parent_page_ref_id,
       seq_nbr,
       node_depth,
       condition_id,
       NAME,
       caption_source,
       target_persistent_node_id,
       target_path,
       target_ui_def_id,
       target_page_set_id,
       target_page_id,
       modified_flags,
       path_to_prev_page,
       path_to_next_page,
       page_ref_type,
       target_expl_node_id,
       caption_rule_id,
       deleted_flag)
    VALUES
      (g_UI_Context.ui_def_id,
       l_page_set_id,
       l_page_ref_id,
       NULL,
       0,
       0,
       NULL,
       'Root',
       G_DEFAULT_CAPTION_RULE_ID,
        l_target_persistent_node_id,
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       NULL,
       NULL,
       l_page_set_type,
       NULL,
       NULL,
       G_NO_FLAG);

      UPDATE CZ_UI_PAGE_REFS
         SET parent_page_ref_id=l_page_ref_id
         WHERE ui_def_id=g_UI_Context.ui_def_id AND parent_page_ref_id IS NULL AND
            target_persistent_node_id=(SELECT persistent_node_id FROM CZ_PS_NODES
            WHERE devl_project_id=g_UI_Context.devl_project_id AND parent_id IS NULL AND
            deleted_flag=G_NO_FLAG) AND deleted_flag=G_NO_FLAG;

     END IF;
    END IF;

  END split_Pages;

  --
  -- reorder UI elements  on UI page in case of Single Page
  --
  PROCEDURE set_UI_Page_Elements_Order(p_page_id IN NUMBER) IS
    l_counter  NUMBER:=0;

    PROCEDURE set_UI_Order_(p_element_id IN VARCHAR2) IS
    BEGIN
       FOR i IN(SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
                WHERE ui_def_id=g_UI_Context.ui_def_id AND
                      page_id=p_page_id AND
                      parent_element_id=p_element_id AND
                      deleted_flag=G_NO_FLAG ORDER BY seq_nbr)
       LOOP
          l_counter := l_counter + 1;
          UPDATE CZ_UI_PAGE_ELEMENTS
             SET seq_nbr = l_counter
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 element_id=i.element_id;
           set_UI_Order_(i.element_id);
       END LOOP;
    END set_UI_Order_;

  BEGIN
     FOR i IN(SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    page_id=p_page_id AND
                    parent_element_id IS NULL AND
                    deleted_flag=G_NO_FLAG ORDER BY seq_nbr)
     LOOP
       set_UI_Order_(i.element_id);
     END LOOP;
  END set_UI_Page_Elements_Order;

  --
  -- set ordering for UI elements on UI pages
  --
  PROCEDURE handle_UI_Page_Elements_Order IS
  BEGIN
    FOR i IN(SELECT page_id FROM CZ_UI_PAGES a
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   page_set_id IN
                   (SELECT page_set_id FROM CZ_UI_PAGE_SETS
                    WHERE ui_def_id=g_UI_Context.ui_def_id AND
                          page_set_id=a.page_set_id AND
                          page_set_type=G_SINGLE_PAGE AND
                          deleted_flag=G_NO_FLAG) AND
                    NVL(suppress_refresh_flag, G_NO_FLAG)=G_NO_FLAG AND
                   deleted_flag=G_NO_FLAG)
    LOOP
      set_UI_Page_Elements_Order(i.page_id);
    END LOOP;
  END handle_UI_Page_Elements_Order;

  --
  -- reorder UI elements  on UI page in case of Single Page
  --
  PROCEDURE handle_Page_Flows IS

    l_xmldoc             xmldom.DOMDocument;
    l_counter            NUMBER:=0;
    l_seq_nbr            NUMBER;
    l_show_train         BOOLEAN := FALSE;
    l_target_path        CZ_UI_PAGE_REFS.target_path%TYPE;
    l_page_ref_id        NUMBER;

    PROCEDURE set_Page_Flow_(p_page_ref_id IN VARCHAR2) IS
    BEGIN
       FOR i IN(SELECT page_ref_id,target_page_id,empty_page_flag,
                        NVL(modified_flags,0) AS modified_flags FROM CZ_UI_PAGE_REFS
                WHERE ui_def_id=g_UI_Context.ui_def_id AND
                      parent_page_ref_id=p_page_ref_id AND
                      target_page_id IN
                      (SELECT page_id FROM CZ_UI_PAGES
                       WHERE ui_def_id=g_UI_Context.ui_def_id AND
                             deleted_flag IN(G_NO_FLAG,G_MARK_TO_ADD,
                             G_MARK_TO_REFRESH))
                      AND
                      deleted_flag=G_NO_FLAG ORDER BY seq_nbr)
       LOOP
          l_counter := l_counter + 1;

          IF i.modified_flags = 0 THEN
            UPDATE CZ_UI_PAGE_REFS
               SET seq_nbr = l_counter
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   page_ref_id=i.page_ref_id;
          END IF;

          set_Page_Flow_(i.page_ref_id);
       END LOOP;
    END set_Page_Flow_;

  BEGIN

    FOR n IN(SELECT page_set_id
               FROM CZ_UI_PAGE_SETS
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    page_set_type IN(G_PAGE_FLOW,G_SUBTABS) AND
                    deleted_flag=G_NO_FLAG)
    LOOP
      l_counter := 0;
      FOR m IN(SELECT page_ref_id,seq_nbr,target_page_id,empty_page_flag,
                      NVL(modified_flags,0) AS MODIFIED_FLAGS FROM CZ_UI_PAGE_REFS
               WHERE ui_def_id=g_UI_Context.ui_def_id AND
                     parent_page_ref_id IS NULL AND
                     page_set_id=n.page_set_id AND
                     target_page_id IN
                     (SELECT page_id FROM CZ_UI_PAGES
                      WHERE ui_def_id=g_UI_Context.ui_def_id AND
                            page_set_id=n.page_set_id AND
                            deleted_flag IN(G_MARK_TO_ADD,G_MARK_TO_REFRESH,
                            G_NO_FLAG)) AND
                     deleted_flag=G_NO_FLAG ORDER BY seq_nbr)
      LOOP
        -- Find the first unmodifid page ref. This is basically the first page ref
        -- generated by UiGen. Once we have this, we recursively set the seq_nbrs
        -- by traversing the page_refs structure in depth first order.
        IF m.MODIFIED_FLAGS = 0 THEN
          IF l_counter=0 THEN
            l_page_ref_id := m.page_ref_id;
          END IF;
        END IF;
        l_counter := l_counter + 1;
      END LOOP; -- loop with m index

      set_Page_Flow_(l_page_ref_id);

    END LOOP; -- loop with n index


    FOR n IN(SELECT page_set_id,persistent_node_id,pagebase_expl_node_id
               FROM CZ_UI_PAGE_SETS
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    deleted_flag=G_NO_FLAG)
    LOOP

      FOR m IN(SELECT page_ref_id,seq_nbr,target_page_id,empty_page_flag,
                      target_persistent_node_id, target_expl_node_id
               FROM CZ_UI_PAGE_REFS
               WHERE ui_def_id=g_UI_Context.ui_def_id AND
                     parent_page_ref_id IS NULL AND
                     page_set_id=n.page_set_id AND
                     target_page_id IN
                     (SELECT page_id FROM CZ_UI_PAGES
                      WHERE ui_def_id=g_UI_Context.ui_def_id AND
                            page_set_id=n.page_set_id AND
                            deleted_flag IN(G_MARK_TO_ADD,G_MARK_TO_REFRESH,
                            G_NO_FLAG)) AND
                     deleted_flag=G_NO_FLAG)
      LOOP

        l_target_path := CZ_DEVELOPER_UTILS_PVT.runtime_relative_path(p_base_expl_id => n.pagebase_expl_node_id,
                                                     p_base_pers_id => n.persistent_node_id,
                                                     p_node_expl_id => m.target_expl_node_id,
                                                     p_node_pers_id => m.target_persistent_node_id);
        IF l_target_path IS NULL THEN
           l_target_path := '.';
        END IF;

        UPDATE CZ_UI_PAGE_REFS
           SET target_path=l_target_path
         WHERE ui_def_id=g_UI_Context.ui_def_id AND
               page_set_id=n.page_set_id AND
               target_persistent_node_id=m.target_persistent_node_id AND
               target_path<>l_target_path AND
               deleted_flag=G_NO_FLAG;
      END LOOP;

    END LOOP;
  END handle_Page_Flows;

  --
  -- get child UI Nodes
  --
  PROCEDURE get_Child_UI_Nodes
  (
  p_parent_ui_node        IN CZ_UI_PAGE_ELEMENTS%ROWTYPE,
  p_child_nodes_tbl       IN OUT NOCOPY model_nodes_tbl_type,
  x_ui_nodes_tbl          OUT NOCOPY ui_page_elements_tbl_type,
  p_suppress_refresh_flag IN VARCHAR2
  ) IS
    l_delete_in_model BOOLEAN;
    l_ps_node_type    NUMBER;
  BEGIN

    IF p_parent_ui_node.parent_persistent_node_id IS NULL AND
       p_parent_ui_node.parent_element_id IS NULL AND
           NVL(p_suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN

      IF get_CX_Button_Status(p_parent_ui_node)=G_CX_VALID THEN

        add_CX_Button(p_node     => get_Model_Node_By_Persist_Id(p_parent_ui_node.persistent_node_id,
                                                                 g_UI_Context.devl_project_id),
                      p_ui_node  => p_parent_ui_node);

      END IF;

    END IF;

    FOR i IN (SELECT *
                FROM CZ_UI_PAGE_ELEMENTS
               WHERE ui_def_id = p_parent_ui_node.ui_def_id AND
                     page_id=p_parent_ui_node.page_id AND
                     parent_element_id=p_parent_ui_node.element_id AND
                     deleted_flag IN (G_NO_FLAG,
                                      G_MARK_TO_ADD,
                                      G_MARK_TO_REFRESH,
                                      G_MARK_TO_DELETE))
    LOOP
      IF  i.element_type=G_UI_CX_BUTTON_NODE_TYPE THEN
        BEGIN
          l_ps_node_type := NULL;
          SELECT ps_node_type INTO l_ps_node_type FROM CZ_PS_NODES
          WHERE devl_project_id=g_UI_Context.devl_project_id AND
                persistent_node_id=i.persistent_node_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL;
        END;
      END IF;

      l_delete_in_model := TRUE;
      FOR h IN(SELECT NULL FROM CZ_PS_NODES
               WHERE devl_project_id=g_UI_Context.devl_project_id AND
                     persistent_node_id=i.persistent_node_id AND
                     deleted_flag=G_NO_FLAG)
      LOOP
        l_delete_in_model := FALSE;
      END LOOP;

      IF NVL(i.element_type,0) NOT IN(G_UI_BOMADDINST_NODE_TYPE,
                                      G_UI_NONBOMADDINST_NODE_TYPE,
                                      G_UI_PAGEDRILLDOWN_NODE_TYPE,
                                      G_UI_CX_BUTTON_NODE_TYPE)
         OR (is_UI_Reference(i) AND NVL(i.element_type,0)<>G_UI_CX_BUTTON_NODE_TYPE) THEN
        IF i.persistent_node_id IS NOT NULL THEN
          x_ui_nodes_tbl(i.persistent_node_id) := i;
        END IF;

      END IF;

      IF NOT(p_child_nodes_tbl.EXISTS(i.persistent_node_id))
         AND i.persistent_node_id<>p_parent_ui_node.persistent_node_id AND
         NOT( NVL(i.element_type,0)=G_UI_CX_BUTTON_NODE_TYPE AND l_ps_node_type IN(G_BOM_STANDART_ITEM_TYPE,G_OPTION_TYPE))
           THEN

         IF i.pagebase_persistent_node_id=i.persistent_node_id THEN -- UI page
            --
            -- delete UI page or deassociate UI page from model nodes
            --
            delete_UI_Page(i);

         ELSIF i.region_persistent_node_id=i.persistent_node_id AND
               i.pagebase_persistent_node_id<>i.persistent_node_id THEN -- UI region
            --
            -- delete UI region or deassociate UI region from model nodes
            --
            delete_UI_Region(i);

         ELSE -- regular UI element
            --
            -- delete UI element or deassociate UI element from model nodes
            --
            delete_UI_Element(i, p_suppress_refresh_flag, l_delete_in_model);

         END IF;
      END IF;

      IF i.deleted_flag=G_MARK_TO_DELETE THEN
         p_child_nodes_tbl.DELETE(i.persistent_node_id);
      END IF;

    END LOOP;

  END get_Child_UI_Nodes;

  --
  -- delete child UI nodes
  --
  PROCEDURE delete_UI_Nodes
  (
  p_nodes_tbl             OUT NOCOPY model_nodes_tbl_type,
  px_ui_nodes_tbl         IN OUT NOCOPY ui_page_elements_tbl_type,
  p_suppress_refresh_flag IN VARCHAR2
  ) IS

    l_current_ui_index  NUMBER;
    l_current_ui_node   CZ_UI_PAGE_ELEMENTS%ROWTYPE;

  BEGIN


    IF px_ui_nodes_tbl.COUNT=0 THEN
      RETURN;
    END IF;

    l_current_ui_index := px_ui_nodes_tbl.First;
    LOOP

      IF l_current_ui_index IS NULL THEN
        EXIT;
      END IF;

      l_current_ui_node := px_ui_nodes_tbl(l_current_ui_index);

      IF l_current_ui_node.persistent_node_id IS NOT NULL AND
         NOT(p_nodes_tbl.EXISTS(l_current_ui_node.persistent_node_id)) THEN

        IF l_current_ui_node.pagebase_persistent_node_id=l_current_ui_node.persistent_node_id THEN -- UI page
          --
          -- delete UI page or deassociate UI page from model nodes
          --
          delete_UI_Page(l_current_ui_node);

        ELSIF l_current_ui_node.pagebase_persistent_node_id<>l_current_ui_node.persistent_node_id AND
              l_current_ui_node.region_persistent_node_id=l_current_ui_node.persistent_node_id THEN -- UI region
          --
          -- delete UI region or deassociate UI region from model nodes
          --
          delete_UI_Region(l_current_ui_node);

        ELSE -- regular UI element
          --
          -- delete UI element or deassociate UI element from model nodes
          --
          delete_UI_Element(l_current_ui_node, p_suppress_refresh_flag);

         END IF;

      END IF;

      IF l_current_ui_node.deleted_flag=G_MARK_TO_DELETE THEN
        px_ui_nodes_tbl.DELETE(l_current_ui_node.persistent_node_id);
      END IF;

      l_current_ui_index := px_ui_nodes_tbl.NEXT(l_current_ui_index);
    END LOOP;

  END delete_UI_Nodes;

  PROCEDURE exist_On_Split_Pages(p_current_model_node        IN  CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE, -->>>
                                 p_parent_ui_node            IN  CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                 px_page_split_seq_nbr       OUT NOCOPY NUMBER,
                                 l_exist_on_split_pages_flag OUT NOCOPY VARCHAR2) IS

    l_page_persistent_node_id NUMBER;
    l_flag                    VARCHAR2(1);

  BEGIN

    l_exist_on_split_pages_flag := G_NO_FLAG;

    SELECT persistent_node_id,split_seq_nbr
      INTO l_page_persistent_node_id, px_page_split_seq_nbr FROM CZ_UI_PAGES
     WHERE page_id=p_parent_ui_node.page_id AND ui_def_id=g_UI_Context.ui_def_id;

    IF px_page_split_seq_nbr=1 THEN
      SELECT G_YES_FLAG INTO l_exist_on_split_pages_flag FROM dual
      WHERE EXISTS
      (SELECT NULL FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id IN(SELECT page_id FROM CZ_UI_PAGES
                      WHERE ui_def_id=g_UI_Context.ui_def_id AND persistent_node_id=l_page_persistent_node_id AND
                      split_seq_nbr>1 AND deleted_flag NOT IN(G_YES_FLAG)) AND
                      persistent_node_id=p_current_model_node.persistent_node_id AND
                      deleted_flag NOT IN(G_YES_FLAG));
    ELSIF px_page_split_seq_nbr>1 THEN
      SELECT G_YES_FLAG INTO l_exist_on_split_pages_flag FROM dual
      WHERE EXISTS
      (SELECT NULL FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id IN(SELECT page_id FROM CZ_UI_PAGES
                      WHERE ui_def_id=g_UI_Context.ui_def_id AND persistent_node_id=l_page_persistent_node_id AND
                      split_seq_nbr<>px_page_split_seq_nbr AND deleted_flag NOT IN(G_YES_FLAG)) AND
                      persistent_node_id=p_current_model_node.persistent_node_id AND
                      deleted_flag NOT IN(G_YES_FLAG));
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_exist_on_split_pages_flag := G_NO_FLAG;
  END exist_On_Split_Pages;

  --
  -- refresh given UI element recursively
  --
  PROCEDURE refresh_UI_Subtree(p_element_id            IN VARCHAR2,
                               p_page_id               IN NUMBER,
                               p_suppress_refresh_flag IN VARCHAR2 DEFAULT NULL) IS

    l_nodes_tbl                   model_nodes_tbl_type;
    l_seq_nodes_tbl               ui_page_el_int_tbl_type; -- fix for bug 6837809 : skudryav 28-Mar-2008
    l_non_del_child_nodes_tbl     model_nodes_tbl_type;
    l_ui_nodes_tbl                ui_page_elements_tbl_type;
    l_next_level_ui_pages_tbl     ui_page_elements_tbl_type;
    l_next_level_ui_page_idx      VARCHAR2(15);
    TYPE number_tbl_type        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_element_id_tbl              varchar_tbl_type;
    l_page_id_tbl                 number_tbl_type;
    l_suppress_refresh_flag_tbl   varchar_tbl_type;

    l_ps_node                     CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_ui_node                     CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_new_ui_node                 CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_suppress_refresh_flag       CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;
    l_current_model_node          CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_seq_nbr                     NUMBER;
    l_max_split_nbr               NUMBER;
    l_page_split_seq_nbr          NUMBER;
    l_exist_on_split_pages_flag   VARCHAR2(1);

  BEGIN
    --
    -- get UI data of current UI element
    --
    l_ui_node := get_UI_Element(p_element_id,p_page_id);

    IF l_ui_node.persistent_node_id IS NULL THEN
      GOTO NEXT_LEVEL;
    END IF;

    --
    -- get ps_node_id of curren model node ( <-> model node associated with the current  UI element )
    --
    l_ps_node := get_Model_Node_By_Persist_Id(l_ui_node.persistent_node_id,
                                              g_UI_Context.devl_project_id);

    IF l_ps_node.deleted_flag=G_YES_FLAG OR l_ps_node.ps_node_id IS NULL OR
       l_ps_node.ui_omit=G_YES_FLAG THEN
         IF l_ui_node.pagebase_persistent_node_id=l_ui_node.persistent_node_id THEN -- UI page
            --
            -- delete UI page or deassociate UI page from model nodes
            --
            delete_UI_Page(l_ui_node);

         ELSIF l_ui_node.region_persistent_node_id=l_ui_node.persistent_node_id AND
               l_ui_node.pagebase_persistent_node_id<>l_ui_node.persistent_node_id THEN -- UI region
            --
            -- delete UI region or deassociate UI region from model nodes
            --
            delete_UI_Region(l_ui_node);

         ELSE -- regular UI element
            --
            -- delete UI element or deassociate UI element from model nodes
            --
            delete_UI_Element(l_ui_node,p_suppress_refresh_flag, TRUE);

         END IF;
         RETURN;
    END IF;

    --
    -- get child nodes of current model node
    --
    get_Child_Nodes(l_ps_node.ps_node_id,
                    g_UI_Context.show_all_nodes_flag,
                    l_seq_nodes_tbl,
                    l_nodes_tbl,
                    l_non_del_child_nodes_tbl);

    --
    -- set suppress_refresh_flag flag for current UI element
    --
    IF g_UI_Context.suppress_refresh_flag=G_YES_FLAG THEN
      l_suppress_refresh_flag := G_YES_FLAG;
    ELSE
      IF p_suppress_refresh_flag IS NULL THEN
         l_suppress_refresh_flag := l_ui_node.suppress_refresh_flag;
      ELSE
         l_suppress_refresh_flag := p_suppress_refresh_flag;
      END IF;
    END IF;

    --
    -- get child nodes of UI node l_ui_node
    --
    get_Child_UI_Nodes(p_parent_ui_node        => l_ui_node,
                       p_child_nodes_tbl       => l_nodes_tbl,
                       x_ui_nodes_tbl          => l_ui_nodes_tbl,
                       p_suppress_refresh_flag => l_suppress_refresh_flag);

    --
    -- check root of subtree
    --
    IF l_ui_node.parent_element_id IS NULL THEN
      check_UI_Node_Changes(l_ui_node, l_ps_node);
    END IF;

    l_seq_nbr := l_seq_nodes_tbl.First;
    LOOP

      IF l_seq_nbr IS NULL THEN
         EXIT;
      END IF;

      l_current_model_node := l_seq_nodes_tbl(l_seq_nbr);

      -- node does not exist in UI on the same level as in Model tree
      IF NOT(l_ui_nodes_tbl.EXISTS(l_current_model_node.persistent_node_id)) THEN

        l_max_split_nbr := get_Last_Split_Page_Nbr(p_page_id);

        IF (l_max_split_nbr > 1) THEN -- case when page was split

          exist_On_Split_Pages(l_current_model_node, l_ui_node,
                               l_page_split_seq_nbr, l_exist_on_split_pages_flag);

          IF l_exist_on_split_pages_flag=G_NO_FLAG AND
             l_page_split_seq_nbr=l_max_split_nbr THEN
            --
            -- add new UI Node
            --
            add_New_UI_Node(p_ui_node               => l_ui_node,
                            p_model_node            => l_current_model_node,
                            p_suppress_refresh_flag => l_suppress_refresh_flag,
                            x_new_ui_pages_tbl      => l_next_level_ui_pages_tbl,
                            x_new_ui_node           => l_new_ui_node);
          END IF;
        ELSE
          --
          -- add new UI Node
          --
          add_New_UI_Node(p_ui_node               => l_ui_node,
                          p_model_node            => l_current_model_node,
                          p_suppress_refresh_flag => l_suppress_refresh_flag,
                          x_new_ui_pages_tbl      => l_next_level_ui_pages_tbl,
                          x_new_ui_node           => l_new_ui_node);
        END IF;

      ELSE  -- UI element exists ,but associated model node was changed
         --
         -- check UI node changes
         --
         check_UI_Node_Changes(l_ui_nodes_tbl(l_current_model_node.persistent_node_id), l_current_model_node);

      END IF; -- end of IF NOT(l_nodes_tbl.EXISTS(i.persistent_node_id))

      l_seq_nbr := l_seq_nodes_tbl.NEXT(l_seq_nbr);

    END LOOP;

    << NEXT_LEVEL >>

    l_element_id_tbl.DELETE;
    l_page_id_tbl.DELETE;
    l_suppress_refresh_flag_tbl.DELETE;

    --
    -- handle next level of UI tree ( recursion )
    --
    SELECT element_id, page_id, suppress_refresh_flag
    BULK COLLECT INTO l_element_id_tbl, l_page_id_tbl, l_suppress_refresh_flag_tbl
    FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id = g_UI_Context.ui_def_id AND
          page_id=p_page_id AND
          parent_element_id = l_ui_node.element_id AND
          deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH) AND
          (element_type IN(G_UI_PAGE_NODE_TYPE,G_UI_REGION_NODE_TYPE));

    IF l_element_id_tbl.COUNT > 0 THEN
      FOR k IN l_element_id_tbl.First..l_element_id_tbl.Last
      LOOP
        IF g_UI_Context.suppress_refresh_flag=G_YES_FLAG THEN
          l_suppress_refresh_flag := G_YES_FLAG;
        ELSE
          l_suppress_refresh_flag := NVL(l_suppress_refresh_flag_tbl(k),l_suppress_refresh_flag);
        END IF;

        refresh_UI_Subtree(p_element_id            => l_element_id_tbl(k),
                           p_page_id               => l_page_id_tbl(k),
                           p_suppress_refresh_flag => l_suppress_refresh_flag);

      END LOOP;
    END IF;
    --kdande; Bug 6875560; 20-Mar-2008; Modified the PLSQL table FOR LOOP to
    --simple LOOP to get the indexes as the index is a VARCHAR2 column
    IF l_next_level_ui_pages_tbl.COUNT > 0 THEN
      l_next_level_ui_page_idx := l_next_level_ui_pages_tbl.FIRST;
      LOOP
        EXIT WHEN l_next_level_ui_page_idx IS NULL;
        IF g_UI_Context.suppress_refresh_flag=G_YES_FLAG THEN
          l_suppress_refresh_flag := G_YES_FLAG;
        ELSE
          l_suppress_refresh_flag := NVL(l_next_level_ui_pages_tbl(l_next_level_ui_page_idx).suppress_refresh_flag,l_suppress_refresh_flag);
        END IF;
        refresh_UI_Subtree(p_element_id            => l_next_level_ui_pages_tbl(l_next_level_ui_page_idx).element_id,
                           p_page_id               => l_next_level_ui_pages_tbl(l_next_level_ui_page_idx).page_id,
                           p_suppress_refresh_flag => l_suppress_refresh_flag);
	l_next_level_ui_page_idx := l_next_level_ui_pages_tbl.NEXT(l_next_level_ui_page_idx);
      END LOOP;
    END IF;

  END refresh_UI_Subtree;

  --
  -- return TRUE if UI page with page_id=p_page_id is empty
  -- else return FALSE
  --
  FUNCTION is_Empty_Page(p_page_id IN NUMBER)
    RETURN BOOLEAN IS
    l_flag VARCHAR2(1);
  BEGIN
    SELECT G_YES_FLAG INTO l_flag
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id=g_UI_Context.ui_def_id AND
           page_id=p_page_id AND
           parent_element_id IS NOT NULL AND
           deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE) AND
           rownum<2;
    RETURN FALSE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
  END is_Empty_Page;

  --
  -- perform a special handling for empty UI pages :
  -- set CZ_UI_PAGE_REF.target_page_id=NULL for those UI pages
  -- which are empty UI pages
  --
  PROCEDURE handle_Empty_Pages IS

    l_empty_page           BOOLEAN;

  BEGIN

    --
    -- exlude from UI Page Refs those UI pages
    -- which have no UI content in it
    --
    FOR i IN(SELECT page_ref_id,
                    target_page_id,target_persistent_node_id,
                    NVL(empty_page_flag,G_NO_FLAG) AS empty_page_flag FROM CZ_UI_PAGE_REFS
             WHERE ui_def_id=g_UI_Context.ui_def_id AND deleted_flag=G_NO_FLAG AND
                   target_page_id IN(SELECT page_id FROM CZ_UI_PAGES
                   WHERE ui_def_id=g_UI_Context.ui_def_id AND
                         NVL(suppress_refresh_flag, G_NO_FLAG)=G_NO_FLAG AND
                         deleted_flag IN(G_NO_FLAG,G_MARK_TO_REFRESH,G_MARK_TO_ADD) ))
     LOOP

       -- check page - is it empty or no ?
       l_empty_page := is_Empty_Page(i.target_page_id);

       IF NVL(i.empty_page_flag,G_NO_FLAG)=G_NO_FLAG AND l_empty_page THEN

          UPDATE CZ_UI_PAGE_REFS
             SET empty_page_flag=G_YES_FLAG
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_ref_id=i.page_ref_id AND NVL(modified_flags,0)=0;

          IF SQL%ROWCOUNT>0 THEN
            UPDATE CZ_UI_PAGES
               SET empty_page_flag=G_YES_FLAG
             WHERE page_id=i.target_page_id AND
                   ui_def_id=g_UI_Context.ui_def_id;
          END IF;

      ELSIF  i.empty_page_flag=G_YES_FLAG AND l_empty_page=FALSE THEN

          UPDATE CZ_UI_PAGE_REFS
             SET empty_page_flag=G_NO_FLAG
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_ref_id=i.page_ref_id AND NVL(modified_flags,0)=0;

          IF SQL%ROWCOUNT>0 THEN
            UPDATE CZ_UI_PAGES
               SET empty_page_flag=G_NO_FLAG
             WHERE page_id=i.target_page_id AND
                   ui_def_id=g_UI_Context.ui_def_id;
          END IF;

       END IF;

     END LOOP;

  END handle_Empty_Pages;

  PROCEDURE set_SLMenu_Order(p_page_set_id IN NUMBER) IS

    l_counter       NUMBER:=0;
    l_split_seq_nbr NUMBER;

    PROCEDURE set_Page_Ref_Order_(p_page_ref_id IN VARCHAR2) IS
    BEGIN
       FOR i IN(SELECT page_ref_id FROM CZ_UI_PAGE_REFS a
                WHERE ui_def_id=g_UI_Context.ui_def_id AND
                      parent_page_ref_id=p_page_ref_id AND
                      EXISTS
                      (SELECT NULL FROM CZ_UI_PAGES
                       WHERE page_id=a.target_page_id AND ui_def_id=g_UI_Context.ui_def_id) AND
                      deleted_flag IN(G_MARK_TO_ADD,G_MARK_TO_REFRESH,G_NO_FLAG) ORDER BY seq_nbr)
       LOOP
         l_counter := l_counter + 1;
         UPDATE CZ_UI_PAGE_REFS
            SET seq_nbr = l_counter
          WHERE ui_def_id=g_UI_Context.ui_def_id AND
                page_ref_id=i.page_ref_id;
          set_Page_Ref_Order_(i.page_ref_id);
       END LOOP;
    END set_Page_Ref_Order_;

  BEGIN
    FOR i IN(SELECT page_ref_id,target_page_id,target_persistent_node_id FROM CZ_UI_PAGE_REFS
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   page_set_id=p_page_set_id AND
                   parent_page_ref_id IS NULL AND
                   deleted_flag=G_NO_FLAG)
    LOOP
      SELECT NVL(split_seq_nbr,1) INTO l_split_seq_nbr
      FROM CZ_UI_PAGES
      WHERE page_id=i.target_page_id AND
            ui_def_id=g_UI_Context.ui_def_id;

      IF l_split_seq_nbr > 1 THEN
        UPDATE CZ_UI_PAGE_REFS
           SET seq_nbr = l_split_seq_nbr
         WHERE ui_def_id=g_UI_Context.ui_def_id AND
               page_ref_id=i.page_ref_id;
        l_counter := l_split_seq_nbr;
      ELSE
        UPDATE CZ_UI_PAGE_REFS
           SET seq_nbr = 1
         WHERE ui_def_id=g_UI_Context.ui_def_id AND
               page_ref_id=i.page_ref_id;
        SELECT MAX(split_seq_nbr) INTO l_counter FROM CZ_UI_PAGES
        WHERE ui_def_id=g_UI_Context.ui_def_id AND
              persistent_node_id=i.target_persistent_node_id AND
              deleted_flag IN (G_MARK_TO_ADD,G_MARK_TO_REFRESH,G_NO_FLAG);
      END IF;

      set_Page_Ref_Order_(i.page_ref_id);
    END LOOP;
  END set_SLMenu_Order;

  --
  -- set ordering for UI elements on UI pages
  --
  PROCEDURE handle_SLMenu_Order IS
  BEGIN
    FOR i IN(SELECT page_set_id FROM CZ_UI_PAGE_SETS
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   page_set_type=G_SINGLE_LEVEL_MENU AND
                   deleted_flag=G_NO_FLAG)
    LOOP
      set_SLMenu_Order(i.page_set_id);
    END LOOP;
  END handle_SLMenu_Order;

  --vsingava IM-ER
  -- Finds an Instance List containing the xml node passed in and returns its AMN
  -- This function also checks the node passed in itself i.e. if the node passed in is
  -- an Instance List, then the function will return its AMN
  FUNCTION getInstanceListAMN(p_ui_def_id IN CZ_UI_DEFS.ui_def_Id%TYPE,
                              p_page_id   IN CZ_UI_PAGES.page_id%TYPE,
                              p_xml_node  IN xmldom.DOMNode) RETURN expl_node_persistent_id_pair
  IS

    l_node xmldom.DOMNode;
    l_user_attribute4_value VARCHAR2(2000);
    l_user_attribute1_value VARCHAR2(2000);
    l_layout_region_type VARCHAR2(255);
    l_id_pair expl_node_persistent_id_pair;
    l_element_with_AMN CZ_UI_PAGE_ELEMENTS.element_id%TYPE;

  BEGIN

    l_node := p_xml_node;

   WHILE NOT xmldom.isNull(l_node)
   LOOP
     l_user_attribute4_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE4_NAME);
     IF l_user_attribute4_value IS NOT NULL THEN
       l_layout_region_type := get_User_Attribute(l_user_attribute4_value, 'layoutRegionType');
       IF l_layout_region_type = '6078' THEN
         -- We have a page include region
         l_user_attribute1_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE1_NAME);
         IF (l_user_attribute1_value IS NOT NULL AND l_user_attribute1_value <> 'model_path=%modelPath') THEN
           l_element_with_AMN := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);
         ELSE
           l_element_with_AMN := find_AMN_Element_Above(l_node);
         END IF;

         SELECT persistent_node_id, model_ref_expl_id
           INTO l_id_pair.persistent_node_id, l_id_pair.expl_node_id
           FROM cz_ui_page_elements
           WHERE ui_def_Id = p_ui_def_id
             AND page_Id = p_page_id
            AND element_Id = l_element_with_AMN;


         return l_id_pair;
       END IF;
     END IF;
     l_node := xmldom.getParentNode(l_node);
   END LOOP;

    RETURN l_id_pair;

  END getInstanceListAMN;

  -- Finds an Instance List enclosing the xml node passed in and returns its AMN
  -- This function does not check the node passed in itself. It starts checking from
  -- its parent
  FUNCTION getEnclosingInstanceListAMN(p_ui_element CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                       p_xml_node   xmldom.DOMNode) RETURN expl_node_persistent_id_pair
  IS

    l_node xmldom.DOMNode;
    l_user_attribute4_value VARCHAR2(2000);
    l_user_attribute1_value VARCHAR2(2000);
    l_layout_region_type VARCHAR2(255);
    l_id_pair expl_node_persistent_id_pair;
    l_element_with_AMN CZ_UI_PAGE_ELEMENTS.element_id%TYPE;

  BEGIN

   l_node := xmldom.getParentNode(p_xml_node);

   RETURN getInstanceListAMN(p_ui_element.ui_def_id, p_ui_element.page_id, l_node);

  END getEnclosingInstanceListAMN;

  PROCEDURE  check_Boundaries IS
    l_node_is_reachable NUMBER := -1;
    l_has_unreach       BOOLEAN := FALSE;
    l_xml_doc           xmldom.DOMDocument;
    l_xml_node          xmldom.DOMNode;
    l_null_xml_doc      xmldom.DOMDocument;
    l_instance_list_amn expl_node_persistent_id_pair;

  BEGIN
    FOR i IN(SELECT page_id,pagebase_expl_node_id, jrad_doc FROM CZ_UI_PAGES  --vsingava IM-ER
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   deleted_flag NOT IN(G_LIMBO_FLAG,G_MARK_TO_DELETE,G_YES_FLAG))
    LOOP

      l_xml_doc := l_null_xml_doc;

      FOR k IN(SELECT *
                 FROM CZ_UI_PAGE_ELEMENTS
                WHERE ui_def_id=g_UI_Context.ui_def_id AND
                      page_id=i.page_id AND
                      deleted_flag NOT IN(G_LIMBO_FLAG,G_MARK_TO_DELETE,G_YES_FLAG))
      LOOP
        BEGIN
          l_instance_list_amn.persistent_node_id := NULL;

          l_node_is_reachable :=CZ_DEVELOPER_UTILS_PVT.in_boundary(i.pagebase_expl_node_id,
                                                                   k.model_ref_expl_id,
                                                                   k.persistent_node_id);
          IF l_node_is_reachable=0 THEN

            IF ( xmldom.isNull(l_xml_doc) ) THEN
              l_xml_doc := parse_JRAD_Document(i.jrad_doc);
            END IF;

            l_xml_node := find_XML_Node_By_Attribute(l_xml_doc, G_ID_ATTRIBUTE, k.element_id);

            l_instance_list_amn := getEnclosingInstanceListAMN(k, l_xml_node);

            IF l_instance_list_amn.persistent_node_id IS NULL THEN
              l_has_unreach := TRUE;
              add_Error_Message(p_message_name => 'CZDEV_UI_ERR_VIR_BDR_BIND',
                                p_token_name   => 'PICKEDNODENAME',
                                p_token_value  => k.name,
                                p_fatal_error  => TRUE);
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
             NULL;
        END;
      END LOOP;
    END LOOP;

    IF l_has_unreach THEN
      RAISE UNREACH_UI_NODE;
    END IF;
  END check_Boundaries;


    -- Gets the UI Node for the parent of this PsNode
    --
    PROCEDURE get_parent_ui_node(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                                 p_ord_siblings IN  model_nodes_tbl_type,
                                 p_ps_node_index IN NUMBER,
                                 x_parent_ui_node OUT NOCOPY CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                 x_insert_index OUT NOCOPY NUMBER,
                                 x_refresh_enabled_parent_found OUT NOCOPY BOOLEAN,
                                 x_atleast_one_parent_found OUT NOCOPY BOOLEAN) IS

      l_parent_ps_node          CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_predecessor             CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_successor               CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_pred_persistent_node_id NUMBER := NULL;
      l_succ_persistent_node_id NUMBER := NULL;
      l_parent_ui_node          CZ_UI_PAGE_ELEMENTS%ROWTYPE;
      l_parent_element_id       NUMBER;
      l_page_id                 NUMBER;
      l_added                   BOOLEAN;

    BEGIN

      l_parent_ps_node := get_Model_Node( p_ps_node.parent_id );

      DEBUG('asp:Find parent ' || p_ps_node_index || 'siblings count = ' || p_ord_siblings.COUNT);

      l_added := FALSE;

      IF p_ps_node_index > 1 THEN
        l_predecessor := p_ord_siblings(p_ps_node_index-1);
        l_pred_persistent_node_id := l_predecessor.persistent_node_id;
      END IF;

      IF p_ps_node_index > 0 AND p_ps_node_index < p_ord_siblings.COUNT THEN
        FOR i in p_ps_node_index+1..p_ord_siblings.COUNT
        LOOP
          IF p_ord_siblings(i).deleted_flag = G_NO_FLAG AND p_ord_siblings(i).creation_date < g_UI_Context.ui_timestamp_refresh THEN
            l_successor := p_ord_siblings(i);
            l_succ_persistent_node_id := l_successor.persistent_node_id;
            EXIT;
          END IF;
        END LOOP;
      END IF;

      x_refresh_enabled_parent_found := FALSE;
      x_atleast_one_parent_found := FALSE;

      -- First find all regions that are bound to the parent of this PS Node and
      -- contain the predecessor and successor of this node.

      IF l_pred_persistent_node_id IS NOT NULL AND l_succ_persistent_node_id IS NOT NULL THEN
        FOR i IN (SELECT *
                  FROM CZ_UI_PAGE_ELEMENTS pe1
                  WHERE ui_def_Id = g_UI_Context.ui_def_id
                  AND region_persistent_node_id = l_parent_ps_node.persistent_node_id
                  AND persistent_node_id = l_pred_persistent_node_id
                  AND deleted_flag IN (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH)
                  AND parent_element_id IS NOT NULL
                  AND EXISTS ( SELECT 1
                               FROM CZ_UI_PAGE_ELEMENTS pe2
                               WHERE ui_def_Id = g_UI_Context.ui_def_id
                               AND pe2.page_id = pe1.page_id
                               AND pe2.parent_element_id = pe1.parent_element_id
                               AND pe2.persistent_node_id = l_succ_persistent_node_id
                               AND pe2.seq_nbr = pe1.seq_nbr + 1
                               AND deleted_flag = G_NO_FLAG
                 ))
        LOOP

          DEBUG('asp:Found parent with both siblings ' || i.parent_element_id);
          x_parent_ui_node := get_UI_Element(i.parent_element_id, i.page_id);
          x_atleast_one_parent_found := TRUE;
          IF NOT disabled_for_refresh(x_parent_ui_node) THEN
            x_insert_index := i.seq_nbr + 1;
            x_refresh_enabled_parent_found := TRUE;
            EXIT;
          END IF;
        END LOOP;
      END IF;

      -- Now find all regions that are bound to the parent of this PS Node and contain
      -- the predecessor of this node


      IF l_pred_persistent_node_id IS NOT NULL AND NOT x_refresh_enabled_parent_found THEN
        FOR i IN (SELECT *
                  FROM CZ_UI_PAGE_ELEMENTS pe1
                  WHERE ui_def_Id = g_UI_Context.ui_def_id
                  AND region_persistent_node_id = l_parent_ps_node.persistent_node_id
                  AND persistent_node_id = l_pred_persistent_node_id
                  AND deleted_flag IN (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH)
                  AND parent_element_id IS NOT NULL)
        LOOP
          DEBUG('asp:Found parent with predecessor ' || i.parent_element_id || ' page_id ' || i.page_id);
          x_parent_ui_node := get_UI_Element(i.parent_element_id, i.page_id);
          x_atleast_one_parent_found := TRUE;
          IF NOT disabled_for_refresh(x_parent_ui_node) THEN
            x_insert_index := i.seq_nbr + 1;
            x_refresh_enabled_parent_found := TRUE;
            EXIT;
          END IF;
        END LOOP;
      END IF;


      -- Now find all regions that are bound to the parent of this PS Node and contain the
      -- successor od this node

      IF l_succ_persistent_node_id IS NOT NULL AND NOT x_refresh_enabled_parent_found THEN

        FOR i IN (SELECT *
                  FROM CZ_UI_PAGE_ELEMENTS pe1
                  WHERE ui_def_Id = g_UI_Context.ui_def_id
                  AND region_persistent_node_id = l_parent_ps_node.persistent_node_id
                  AND persistent_node_id = l_succ_persistent_node_id
                  AND deleted_flag = G_NO_FLAG
                  AND parent_element_id IS NOT NULL)
        LOOP
          DEBUG('asp:Found parent with successor ' || i.parent_element_id || ' i.seq_nbr = ' || i.seq_nbr);
          x_parent_ui_node := get_UI_Element(i.parent_element_id, i.page_id);
          x_atleast_one_parent_found := TRUE;
          IF NOT disabled_for_refresh(x_parent_ui_node) THEN
            x_insert_index := i.seq_nbr;
            x_refresh_enabled_parent_found := TRUE;
            EXIT;
          END IF;
        END LOOP;

      END IF;


      -- we still haven't managed to add UI for the node. We will now look for a region
      -- containing the max number of siblings of this node

      IF NOT x_refresh_enabled_parent_found THEN

        l_parent_element_id := NULL;
        l_page_id := NULL;

        FOR i IN (SELECT parent_element_id, page_id, count(parent_element_id) max_count
                  FROM CZ_UI_PAGE_ELEMENTS pe
                  WHERE ui_def_Id = g_UI_Context.ui_def_id
                  AND parent_persistent_node_id = l_parent_ps_node.persistent_node_id
                  AND pagebase_persistent_node_id <> persistent_node_id
                  AND deleted_flag IN (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH)
                  AND parent_element_id IS NOT NULL
                  AND NOT (p_ps_node.ps_node_type <> G_BOM_OPTION_CLASS_TYPE
                           AND ((SELECT NVL(ps_node_type,G_UNDEFINED_DATA_TYPE)
                               FROM CZ_PS_NODES
                               WHERE devl_project_id = p_ps_node.devl_project_id
                                 AND persistent_node_id = pe.persistent_node_id) = G_BOM_OPTION_CLASS_TYPE))
                  GROUP BY parent_element_id, page_id
                  ORDER BY count(parent_element_id) DESC)
        LOOP
          DEBUG('asp:Found parent with max siblings ' || i.parent_element_id || ', page_id ' || i.page_id);
          x_parent_ui_node := get_UI_Element(i.parent_element_id, i.page_id);
          DEBUG('asp:Got the parent node ');
          x_atleast_one_parent_found := TRUE;
          IF NOT disabled_for_refresh(x_parent_ui_node) THEN
            x_insert_index := -1;
            x_refresh_enabled_parent_found := TRUE;
            EXIT;
          END IF;
        END LOOP;

      --DEBUG('asp:Before finding region bound to parent node ');

      END IF;

      IF NOT x_refresh_enabled_parent_found THEN

        FOR j IN (SELECT *
                  FROM CZ_UI_PAGE_ELEMENTS
                  WHERE ui_def_id = g_UI_Context.ui_def_id AND
                  persistent_node_Id = l_parent_ps_node.persistent_node_id AND
                  deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH) AND
                  element_type IN(G_UI_PAGE_NODE_TYPE,G_UI_REGION_NODE_TYPE))
        LOOP
          DEBUG('asp:Found parent with no siblings ' || j.element_id);
          x_parent_ui_node := get_UI_Element(j.element_id, j.page_id);
          x_atleast_one_parent_found := TRUE;
          IF NOT disabled_for_refresh(x_parent_ui_node) THEN
            x_insert_index := -1;
            x_refresh_enabled_parent_found := TRUE;
            EXIT;
          END IF;
        END LOOP;
      END IF;
    END get_parent_ui_node;


    -- Determines if UI should be added for this ps node.
    -- Determines the place (l_parent_ui_node) under which to
    -- add UI for this node and add the UI if required

    PROCEDURE add_ui_for_node(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                              p_ord_siblings IN  model_nodes_tbl_type,
                              p_ps_node_index IN NUMBER DEFAULT NULL,
                              x_ui_node OUT NOCOPY CZ_UI_PAGE_ELEMENTS%ROWTYPE) IS

    l_parent_ps_node              CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
    l_parent_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_temp_ui_node                CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_next_level_ui_pages_tbl     ui_page_elements_tbl_type;
    l_insert_index                NUMBER;
    l_suppress_refresh_flag       CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;
    l_parent_node_found           BOOLEAN;
    l_atleast_one_parent_found    BOOLEAN;
    l_nodes_tbl                   model_nodes_tbl_type;
    l_seq_nodes_tbl               ui_page_el_int_tbl_type; -- fix for bug 6837809 : skudryav 28-Mar-2008
    l_non_del_child_nodes_tbl     model_nodes_tbl_type;

    BEGIN

      l_parent_node_found := FALSE;

      IF p_ps_node.parent_id IS NOT NULL THEN
        -- Find the parent under which to add UI for this node
        get_parent_ui_node(p_ps_node,
                           p_ord_siblings,
                           p_ps_node_index,
                           l_parent_ui_node,
                           l_insert_index,
                           l_parent_node_found,
                           l_atleast_one_parent_found);
      END IF;


      IF l_parent_node_found OR p_ps_node.parent_id IS NULL THEN
          add_New_UI_Node(p_ui_node               => l_parent_ui_node,
                          p_insert_index          => l_insert_index,
                          p_model_node            => p_ps_node,
                          p_suppress_refresh_flag => G_NO_FLAG,
                          x_new_ui_pages_tbl      => l_next_level_ui_pages_tbl,
                          x_new_ui_node           => x_ui_node);

      ELSIF NOT l_atleast_one_parent_found THEN

        -- We did not find any parent node. So the parent was probably deleted
        -- Lets try and add the parent back and then add UI for this node.
        -- add_ui_for_ancestors_recursively(p_ps_node, l_new_ui_node);

        l_parent_ps_node := get_Model_Node( p_ps_node.parent_id );


        get_Child_Nodes(l_parent_ps_node.parent_id,
                        G_YES_FLAG,  -- get all the nodes
                        l_seq_nodes_tbl,
                        l_nodes_tbl,
                        l_non_del_child_nodes_tbl,
                        G_YES_FLAG);

        add_ui_for_node(l_parent_ps_node,
                        l_non_del_child_nodes_tbl,
                        l_parent_ps_node.tree_seq,
                        x_ui_node);

        IF x_ui_node.element_id IS NOT NULL THEN

          l_temp_ui_node := x_ui_node;

          add_New_UI_Node(p_ui_node               => l_temp_ui_node,
                          p_insert_index          => -1,
                          p_model_node            => p_ps_node,
                          p_suppress_refresh_flag => G_NO_FLAG,
                          x_new_ui_pages_tbl      => l_next_level_ui_pages_tbl,
                          x_new_ui_node           => x_ui_node);
        END IF;

      ELSE
        -- We found atleast one parent. It was probably disabled for refresh
        -- So we will not add any content for the new node
        NULL;

      END IF;

    END add_ui_for_node;


    PROCEDURE propogate_ps_node_remove(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

      l_new_parent_persistent_id    NUMBER;
      l_parent_ps_node              CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;

      l_parent_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE;
      l_insert_index                NUMBER;
      l_suppress_refresh_flag       CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;
      l_parent_node_found           BOOLEAN;

    BEGIN

      l_parent_ps_node := get_Model_Node( p_ps_node.parent_id );

      --DEBUG('asp:Deleting UI for ps node ' || p_ps_node.name);

    FOR i IN (SELECT *
                FROM CZ_UI_PAGE_ELEMENTS pe
                WHERE ui_def_Id = g_UI_Context.ui_def_id
                AND persistent_node_id = p_ps_node.persistent_node_id
                AND deleted_flag = G_NO_FLAG)
      LOOP
        IF i.pagebase_persistent_node_id=i.persistent_node_id THEN -- UI page
              --
              -- delete UI page or deassociate UI page from model nodes
              --
              delete_UI_Page(i);

        ELSIF i.region_persistent_node_id=i.persistent_node_id AND

          i.pagebase_persistent_node_id<>i.persistent_node_id THEN -- UI region
              --
              -- delete UI region or deassociate UI region from model nodes
              --
              delete_UI_Region(i);

        ELSE -- regular UI element
              --
              -- delete UI element or deassociate UI element from model nodes
              --
        l_suppress_refresh_flag := G_NO_FLAG;

        IF disabled_for_refresh(i) THEN
          l_suppress_refresh_flag := G_YES_FLAG;
        END IF;

        --DEBUG('asp:Delete element ' || i.element_id);
              delete_UI_Element(i, l_suppress_refresh_flag, TRUE);

        END IF;

    END LOOP;
    END;


    PROCEDURE propogate_ps_node_move(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                                     p_ord_siblings IN  model_nodes_tbl_type,
                                     p_ps_node_index IN NUMBER DEFAULT NULL,
                                     x_model_ref_expl_id_changed OUT NOCOPY VARCHAR2) IS

      l_new_parent_persistent_id    NUMBER;
      l_parent_ps_node              CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;

      l_parent_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE;
      l_insert_index                NUMBER;
      l_suppress_refresh_flag       CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;
      l_parent_node_found           BOOLEAN;
      l_diff                        NUMBER;
      l_max_prev_seq_nbr            NUMBER;
      l_max_src_seq_nbr             NUMBER;
      l_src_range                   NUMBER;
      l_atleast_one_parent_found    BOOLEAN;
      l_parent_page_ref_id          CZ_UI_PAGE_REFS.page_ref_id%TYPE;
      l_pagebase_expl_node_id       CZ_UI_PAGES.pagebase_expl_node_id%TYPE;
      l_node_is_reachable           NUMBER := -1;
      l_model_ref_expl_id           NUMBER;
      l_count                       NUMBER;

    BEGIN

      x_model_ref_expl_id_changed := 'U';  -- Unknown

      l_parent_ps_node := get_Model_Node( p_ps_node.parent_id );

      IF p_ps_node.ps_node_type = G_REFERENCE_TYPE AND
          g_UI_Context.primary_navigation = G_MODEL_TREE_MENU AND
           g_UI_Context.page_set_id IS NOT NULL THEN

        -- This is a reference node and it has been moved. Reference nodes will not have pages
        -- in this UI which are in the tree. So have to deal with page_refs for references
        -- explicitly
        FOR i in (SELECT *
                  FROM CZ_UI_PAGE_REFS
                  WHERE ui_def_id = g_UI_Context.ui_def_id
                  AND page_set_id = g_UI_Context.page_set_id
                  AND target_ui_def_id IS NOT NULL
                  AND target_persistent_node_id = p_ps_node.persistent_node_id)
        LOOP
          move_page_ref(i.page_set_id, i.page_ref_id, p_ps_node, l_parent_page_ref_id);
          replace_page_ref_target_path(p_ps_node);
        END LOOP;

      END IF;

      FOR i IN (SELECT *
                FROM CZ_UI_PAGE_ELEMENTS pe
                WHERE ui_def_Id = g_UI_Context.ui_def_id
                AND persistent_node_id = p_ps_node.persistent_node_id
                AND region_persistent_node_id <> l_parent_ps_node.persistent_node_id
                AND deleted_flag IN (G_NO_FLAG, G_MARK_TO_DELETE))
      LOOP

        l_model_ref_expl_id := get_Expl_Id(p_model_id     => p_ps_node.devl_project_id,
                                           p_ps_node_id   => p_ps_node.ps_node_id,
                                           p_component_id => p_ps_node.component_id,
                                           p_ps_node_type => p_ps_node.ps_node_type);

        -- This piece of code determines if the model_ref_expl_id of this page_element is
        -- different from the current explosion_id of the PS Node. If information is then
        -- used later to fix the explosion_ids
        IF x_model_ref_expl_id_changed <> G_YES_FLAG THEN
          IF i.model_ref_expl_id <> l_model_ref_expl_id THEN
            x_model_ref_expl_id_changed := G_YES_FLAG;
          ELSE
            x_model_ref_expl_id_changed := G_NO_FLAG;
          END IF;
        END IF;

        -- Developer writes element_type 521 (UI Region) for the root_region of a user created page
        -- UI Gen/ Refresh writes element_type 520 (UI Page) for the same region. So we cannot reply only
        -- on element_type to determine if the page element is for the root region of the page
        -- Hence we check for parent_element_id also
        IF ( (i.element_type IS NOT NULL AND i.element_type = G_UI_PAGE_NODE_TYPE) OR i.parent_element_id IS NULL ) THEN

          -- If the node is a page node then we dont try to move the node to another page
          -- but we do have to fix the path of the page and the associated page ref

          move_page_ref(i, p_ps_node, l_parent_page_ref_id);
          replace_page_ref_target_path(i, p_ps_node);


        ELSE
          --DEBUG('asp:Found UI for moved PS node ' || p_ps_node.name || ', element_id ' || i.element_id);
          -- Determine if this needs to be moved

          l_parent_node_found := FALSE;

          -- Find the parent under which to add UI for this node
          get_parent_ui_node(p_ps_node,
                             p_ord_siblings,
                             p_ps_node_index,
                             l_parent_ui_node,
                             l_insert_index,
                             l_parent_node_found,
                             l_atleast_one_parent_found);

          IF l_parent_node_found THEN

            g_tgt_pg_to_src_pg_map(l_parent_ui_node.page_id)(TO_NUMBER(i.element_id)) := i.page_id;
            g_elements_to_move(i.page_id)(TO_NUMBER(i.element_id)) := TO_NUMBER(i.element_id);

            IF l_insert_index > 0 THEN
              l_max_prev_seq_nbr := l_insert_index-1;
            ELSE
              SELECT NVL(MAX(seq_nbr),0) INTO l_max_prev_seq_nbr FROM CZ_UI_PAGE_ELEMENTS
              START WITH ui_def_id=g_UI_Context.ui_def_id AND
                     page_id=l_parent_ui_node.page_id AND
                     element_id=l_parent_ui_node.element_id AND
                     deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG)
              CONNECT BY PRIOR ui_def_id=g_UI_Context.ui_def_id AND
                  ui_def_id=g_UI_Context.ui_def_id AND PRIOR page_id= l_parent_ui_node.page_id AND
                  page_id=l_parent_ui_node.page_id AND PRIOR element_id=parent_element_id AND
                  PRIOR deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG) AND
                  deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG);

                  l_insert_index  := l_max_prev_seq_nbr + 1;
            END IF;

            SELECT NVL(MAX(seq_nbr),0), NVL(COUNT(seq_nbr), 0) INTO l_max_src_seq_nbr, l_count  FROM CZ_UI_PAGE_ELEMENTS
            START WITH ui_def_id=g_UI_Context.ui_def_id AND
                       page_id=i.page_id AND
                       element_id=i.element_id AND
                       deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG)
            CONNECT BY PRIOR ui_def_id=g_UI_Context.ui_def_id AND
                    ui_def_id=g_UI_Context.ui_def_id AND PRIOR page_id= i.page_id
                    AND page_id=i.page_id AND PRIOR element_id=parent_element_id AND
                    PRIOR deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG) AND
                    deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG);

            l_src_range := l_max_src_seq_nbr - i.seq_nbr + 1;

            -- move the elements after the insert point by adding the range value computed above
            UPDATE CZ_UI_PAGE_ELEMENTS
            SET seq_nbr=seq_nbr+l_src_range
            WHERE ui_def_id=g_UI_Context.ui_def_id AND
                  page_id=l_parent_ui_node.page_id AND
                  seq_nbr>l_max_prev_seq_nbr AND
                  deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG);

            l_diff := l_insert_index - i.seq_nbr;

            UPDATE CZ_UI_PAGE_ELEMENTS
            SET seq_nbr=seq_nbr + l_diff,
                page_id=l_parent_ui_node.page_id,
                pagebase_persistent_node_id=l_parent_ui_node.pagebase_persistent_node_id,
                deleted_flag=DECODE(deleted_flag, G_MARK_TO_DELETE, G_NO_FLAG, deleted_flag)
            WHERE ui_def_id=g_UI_Context.ui_def_id AND
                  page_id=i.page_id AND
                  seq_nbr >= i.seq_nbr AND
                  seq_nbr <= l_max_src_seq_nbr AND
                  deleted_flag NOT IN(G_YES_FLAG, G_LIMBO_FLAG);

            IF i.deleted_flag <> G_MARK_TO_DELETE THEN
              UPDATE CZ_UI_PAGE_ELEMENTS
              SET seq_nbr=seq_nbr - l_count
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    page_id=i.page_id AND
                    seq_nbr > l_max_src_seq_nbr AND
                    deleted_flag NOT IN(G_YES_FLAG, G_LIMBO_FLAG);
            END IF;

            UPDATE CZ_UI_PAGE_ELEMENTS
            SET parent_element_id = l_parent_ui_node.element_id,
                parent_persistent_node_id = l_parent_ps_node.persistent_node_id,
                region_persistent_node_id = l_parent_ui_node.persistent_node_id,
                deleted_flag = G_MARK_TO_MOVE
            WHERE ui_def_id = i.ui_def_id AND
                 page_Id = l_parent_ui_node.page_Id AND
                 element_id = i.element_id;


            mark_UI_Page_As_Refreshed(l_parent_ui_node.page_id, l_parent_ui_node.ui_def_id);

            -- update the page_rev_nbr of the other (source) page
            UPDATE CZ_UI_PAGES
              SET page_rev_nbr=page_rev_nbr+1
              WHERE page_id=i.page_id AND ui_def_id=i.ui_def_id;

          ELSE -- If parent_node not found
            -- We cannot move this node to another region since we have not found any such
            -- region which can hold this node
            -- So we will try and keep this node where it is. We will however have to
            -- update the model_path of this control and all controls under it.
            -- So lets just mark this node for refresh and let the second pass do the model_path
            -- update



            SELECT pagebase_expl_node_id INTO l_pagebase_expl_node_id
              FROM CZ_UI_PAGES
             WHERE ui_def_id=g_UI_Context.ui_def_id
               AND page_id = i.page_id
               AND deleted_flag NOT IN(G_LIMBO_FLAG,G_MARK_TO_DELETE,G_YES_FLAG);


            DEBUG('asp: calling in_boundary l_pagebase_expl_node_id: ' || l_pagebase_expl_node_id || ', l_model_ref_expl_id: ' || l_model_ref_expl_id || ', i.persistent_node_id' || i.persistent_node_id);

            l_node_is_reachable :=CZ_DEVELOPER_UTILS_PVT.in_boundary(l_pagebase_expl_node_id,
                                                                     l_model_ref_expl_id,
                                                                     i.persistent_node_id);

            DEBUG('asp: l_node_is_reachable = ' || l_node_is_reachable);

            IF l_node_is_reachable=0 THEN
              -- The PS node associated to this control is not reachable from the current page
              -- So we have to disassociate this UI controls from the PS Node

              DEBUG('asp: Cannot move UI for ' || p_ps_node.name || '. Disassociating from PS Node');

              UPDATE CZ_UI_PAGE_ELEMENTS
                 SET deleted_flag = G_MARK_TO_DEASSOCIATE,
                     persistent_node_id = 0
               WHERE ui_def_id = i.ui_def_id
                 AND page_id = i.page_id
                 AND element_id IN
                    (SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
                     START WITH ui_def_id=i.ui_def_id
                     AND page_id=i.page_id
                     AND element_id=i.element_id
                     CONNECT BY PRIOR ui_def_id=i.ui_def_id AND
                     page_id = i.page_id AND
                     PRIOR element_id=parent_element_id AND
                        deleted_flag IN (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH,G_MARK_TO_MOVE));
            ELSE
              -- Mark the node for G_MARK_TO_REFRESH so that the second pass will
              -- change the model_path. This may not be necessary. Marking the page for
              -- refresh might be enough.

              DEBUG('asp: Cannot move UI for ' || p_ps_node.name || '. Marking it for refresh');

              UPDATE CZ_UI_PAGE_ELEMENTS
                 SET deleted_flag = G_MARK_TO_REFRESH
               WHERE ui_def_id = i.ui_def_id
                 AND page_id = i.page_id
                 AND element_id = i.element_id
                 AND deleted_flag IN (G_NO_FLAG, G_MARK_TO_REFRESH);
            END IF;

            mark_UI_Page_As_Refreshed(i.page_id, i.ui_def_id);

          END IF;
        END IF;
      END LOOP;
    END propogate_ps_node_move;

    PROCEDURE propogate_ps_node_type_changes(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                                             x_model_ref_expl_id_changed OUT NOCOPY VARCHAR) IS

    l_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_model_ref_expl_id    NUMBER;

    BEGIN

      x_model_ref_expl_id_changed := 'U'; -- Unknown

      l_model_ref_expl_id := get_Expl_Id(p_model_id     => p_ps_node.devl_project_id,
                                         p_ps_node_id   => p_ps_node.ps_node_id,
                                         p_component_id => p_ps_node.component_id,
                                         p_ps_node_type => p_ps_node.ps_node_type);
      FOR i IN (SELECT *
                FROM CZ_UI_PAGE_ELEMENTS pe
                WHERE ui_def_Id = g_UI_Context.ui_def_id
                AND persistent_node_id = p_ps_node.persistent_node_id
                AND deleted_flag IN (G_NO_FLAG, G_MARK_TO_MOVE))
      LOOP


        -- This piece of code determines if the model_ref_expl_id of this page_element is
        -- different from the current explosion_id of the PS Node. If information is then
        -- used later to fix the explosion_ids
        IF x_model_ref_expl_id_changed <> G_YES_FLAG THEN
          IF i.model_ref_expl_id <> l_model_ref_expl_id THEN
            x_model_ref_expl_id_changed := G_YES_FLAG;
          ELSE
            x_model_ref_expl_id_changed := G_NO_FLAG;
          END IF;
        END IF;

        l_ui_node := get_UI_Element(i.element_id, i.page_id);
        check_UI_Node_Changes(l_ui_node, p_ps_node);

      END LOOP;

    END propogate_ps_node_type_changes;


    FUNCTION ui_node_exits(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) RETURN BOOLEAN IS

    l_element_id  CZ_UI_PAGE_ELEMENTS.element_id%TYPE;

    BEGIN

      SELECT element_id into l_element_id FROM CZ_UI_PAGE_ELEMENTS
                    WHERE ui_def_id=g_UI_Context.ui_def_id
            AND persistent_node_id=p_ps_node.persistent_node_id
            AND deleted_flag=G_NO_FLAG and rownum < 2;
      -- need to return the element_id instead
      RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

    END ui_node_exits;

    PROCEDURE reorder_tree_node(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE) IS

      l_page_set_id   CZ_UI_PAGE_SETS.page_set_id%TYPE;
      l_page_ref      CZ_UI_PAGE_REFS%ROWTYPE;

      l_old_seq_nbr   NUMBER;
      l_new_seq_nbr   NUMBER;
      l_count         NUMBER;
      l_diff          NUMBER;
      l_range_min     NUMBER;
      l_range_max     NUMBER;

    BEGIN

      IF g_UI_Context.primary_navigation = G_MODEL_TREE_MENU THEN
        l_page_set_id := g_UI_Context.page_set_id;

        BEGIN

          SELECT min(seq_nbr), count(*) INTO l_old_seq_nbr, l_count
          FROM CZ_UI_PAGE_REFS
          WHERE ui_def_id = g_UI_Context.ui_def_id
          AND page_set_id = l_page_set_id
          AND target_persistent_node_id = p_ps_node.persistent_node_id
          AND deleted_flag = G_NO_FLAG;

          SELECT * INTO l_page_ref
          FROM CZ_UI_PAGE_REFS
          WHERE ui_def_id = g_UI_Context.ui_def_id
          AND page_set_id = l_page_set_id
          AND target_persistent_node_id = p_ps_node.persistent_node_id
          AND deleted_flag = G_NO_FLAG
          AND seq_nbr = l_old_seq_nbr
          AND rownum < 2;

          l_new_seq_nbr := get_new_page_ref_seq(p_ps_node, l_page_ref.page_set_id, l_page_ref.parent_page_ref_id);

          --DEBUG('asp: reordering tree node ' || p_ps_node.name || ', new seq is ' || l_new_seq_nbr);

          IF l_new_seq_nbr = l_old_seq_nbr THEN
            --DEBUG('asp: new seq_nbr same as old one');
            RETURN;
          END IF;

          IF l_new_seq_nbr > l_old_seq_nbr THEN
            l_range_max := l_new_seq_nbr - 1;
            l_range_min := l_old_seq_nbr + l_count;
            l_new_seq_nbr := l_new_seq_nbr - l_count;
          ELSE
            l_count := -l_count;
            l_range_min := l_new_seq_nbr;
            l_range_max := l_old_seq_nbr -1;
          END IF;

          --DEBUG('asp: l_range_min: ' || l_range_min || ', l_range_max ' || l_range_max);

          UPDATE CZ_UI_PAGE_REFS
          SET seq_nbr = seq_nbr - l_count
          WHERE ui_def_id = g_UI_Context.ui_def_id
          AND page_set_id = l_page_set_id
          AND parent_page_ref_id = l_page_ref.parent_page_ref_id
          AND target_persistent_node_id <> p_ps_node.persistent_node_id
          AND deleted_flag = G_NO_FLAG
          AND seq_nbr between l_range_min and l_range_max;

          l_diff := l_new_seq_nbr - l_old_seq_nbr;

          UPDATE CZ_UI_PAGE_REFS
          SET seq_nbr = seq_nbr + l_diff
          WHERE ui_def_id = g_UI_Context.ui_def_id
          AND page_set_id = l_page_set_id
          AND parent_page_ref_id = l_page_ref.parent_page_ref_id
          AND target_persistent_node_id = p_ps_node.persistent_node_id
          AND deleted_flag = G_NO_FLAG;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;

      END IF;

    END reorder_tree_node;

    PROCEDURE fix_model_ref_expl_ids(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                                     x_model_ref_expl_changed OUT NOCOPY VARCHAR2) IS
      l_model_ref_expl_id NUMBER;

    BEGIN


      x_model_ref_expl_changed := 'U';

      l_model_ref_expl_id := get_Expl_Id(p_model_id     => p_ps_node.devl_project_id,
                                         p_ps_node_id   => p_ps_node.ps_node_id,
                                         p_component_id => p_ps_node.component_id,
                                         p_ps_node_type => p_ps_node.ps_node_type);

      FOR i in (SELECT *
                  FROM CZ_UI_PAGE_ELEMENTS
                 WHERE ui_def_id = g_UI_Context.ui_def_id
                   AND persistent_node_id = p_ps_node.persistent_node_id
                   AND deleted_flag NOT IN (G_YES_FLAG, G_LIMBO_FLAG))
      LOOP

        IF x_model_ref_expl_changed <> G_YES_FLAG THEN
          IF i.model_ref_expl_id <> l_model_ref_expl_id THEN
            x_model_ref_expl_changed := G_YES_FLAG;
          ELSE
            x_model_ref_expl_changed := G_NO_FLAG;
          END IF;
        END IF;

        sync_expl_ids(p_ps_node, i, l_model_ref_expl_id);

      END LOOP;

      IF x_model_ref_expl_changed = 'U' THEN
        x_model_ref_expl_changed := G_YES_FLAG;
      END IF;

    END fix_model_ref_expl_ids;

    PROCEDURE propogate_changes_to_UI(p_ps_node IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                                      p_ord_siblings IN  model_nodes_tbl_type,
                                      p_ps_node_index IN NUMBER DEFAULT NULL,
                                      p_add_remove_flag IN VARCHAR2 DEFAULT G_EXISTS_FLAG,
                                      p_add_remove_timestamp IN DATE DEFAULT NULL,
                                      p_ancestor_moved IN BOOLEAN DEFAULT FALSE,
                                      p_model_ref_expl_changed IN VARCHAR2) IS

      l_added_ui                    BOOLEAN;
      l_removed_ui                  BOOLEAN;

      l_ps_node                     CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_nodes_tbl                   model_nodes_tbl_type;
      l_seq_nodes_tbl               ui_page_el_int_tbl_type; -- fix for bug 6837809 : skudryav 28-Mar-2008
      l_non_del_child_nodes_tbl     model_nodes_tbl_type;
      l_new_ui_node                 CZ_UI_PAGE_ELEMENTS%ROWTYPE;

      l_timestamp_add               DATE;
      l_timestamp_remove            DATE;
      l_add_remove_flag             VARCHAR2(1);
      l_add_remove_timestamp        DATE;
      l_ps_node_index               NUMBER;
      l_moved_flag                  BOOLEAN;
      l_model_ref_expl_changed1     VARCHAR2(1) := 'U';
      l_model_ref_expl_changed2     VARCHAR2(1) := 'U';
      l_check_for_bom_table         BOOLEAN;

      l_bom_table_id                CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
      l_page_id                     NUMBER;

      l_bom_parent_element          CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
      l_suppress_refresh_flag       CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;

    BEGIN

      l_added_ui := FALSE;
      l_removed_ui := FALSE;

      l_add_remove_flag := G_EXISTS_FLAG;
      l_add_remove_timestamp := p_add_remove_timestamp;

      l_timestamp_add := NVL(p_ps_node.UI_TIMESTAMP_ADD, g_UI_Context.UI_TIMESTAMP_REFRESH);
      l_timestamp_remove := NVL(p_ps_node.UI_TIMESTAMP_REMOVE, g_UI_Context.UI_TIMESTAMP_REFRESH);

      IF p_add_remove_flag = G_ADDED_FLAG THEN
        IF p_add_remove_timestamp > l_timestamp_add THEN
          l_timestamp_add := p_add_remove_timestamp;
        END IF;
      ELSIF p_add_remove_flag = G_REMOVED_FLAG THEN
        IF p_add_remove_timestamp > l_timestamp_remove THEN
          l_timestamp_remove := p_add_remove_timestamp;
        END IF;
      END IF;

      IF l_timestamp_add > g_UI_Context.UI_TIMESTAMP_REFRESH
         OR l_timestamp_remove > g_UI_Context.UI_TIMESTAMP_REFRESH THEN

           --DEBUG('asp:Handling PS Node ' || p_ps_node.name);
           --DEBUG('asp:asp:UI_TIMESTAMP_ADD ' || p_ps_node.UI_TIMESTAMP_ADD);
           --DEBUG('asp:UI_TIMESTAMP_REMOVE ' || p_ps_node.UI_TIMESTAMP_REMOVE);
           --DEBUG('asp:UI_TIMESTAMP_MOVE ' || p_ps_node.UI_TIMESTAMP_MOVE);
           --DEBUG('asp:UI_TIMESTAMP_CHANGETYPE ' || p_ps_node.UI_TIMESTAMP_CHANGETYPE);
           --DEBUG('asp:');

          IF l_timestamp_add > l_timestamp_remove
            AND p_ps_node.ui_omit <> G_YES_FLAG
            AND p_ps_node.deleted_flag = G_NO_FLAG THEN
            -- We need to add UI for this if not already present
            IF NOT ui_node_exits( p_ps_node ) THEN
              add_ui_for_node(p_ps_node, p_ord_siblings, p_ps_node_index, l_new_ui_node);
              l_add_remove_flag := G_ADDED_FLAG;
              l_add_remove_timestamp := l_timestamp_add;
              l_added_ui := TRUE;
            END IF;
         ELSE
           IF l_timestamp_remove > l_timestamp_add THEN
             -- We need to delete UI structure for this if present
             IF ui_node_exits( p_ps_node ) THEN
               propogate_ps_node_remove(p_ps_node);
               l_add_remove_flag := G_REMOVED_FLAG;
               l_add_remove_timestamp := l_timestamp_remove;
               l_removed_ui := TRUE;
             END IF;
           END IF;
         END IF;

      END IF; -- end of (ADD, REMOVE) > REFRESH

      -- If the UI was added, in the above code, then it would have been added in the
      -- a place according to the latest position of the model node and with a template
      -- compatible with the latest type of the model node. Hence we dont need to process
      -- for move or changetype events
      -- If the UI was deleted in the above code, there there is nothing to move or
      -- change type of
      IF p_ps_node.deleted_flag = G_NO_FLAG AND NOT ( l_added_ui OR l_removed_ui ) THEN

        IF NVL(p_ps_node.UI_TIMESTAMP_MOVE, g_UI_Context.UI_TIMESTAMP_REFRESH) > g_UI_Context.UI_TIMESTAMP_REFRESH THEN
          propogate_ps_node_move( p_ps_node, p_ord_siblings, p_ps_node_index, l_model_ref_expl_changed1 );
          l_moved_flag := TRUE;
        ELSE
          IF p_ancestor_moved THEN
            l_moved_flag := TRUE;
            replace_page_ref_target_path( p_ps_node );
          END IF;
          IF NVL(p_ps_node.UI_TIMESTAMP_REORDER, g_UI_Context.UI_TIMESTAMP_REFRESH) > g_UI_Context.UI_TIMESTAMP_REFRESH THEN
            reorder_tree_node(p_ps_node);
          END IF;
        END IF;

        IF NVL(p_ps_node.UI_TIMESTAMP_CHANGETYPE, g_UI_Context.UI_TIMESTAMP_REFRESH) > g_UI_Context.UI_TIMESTAMP_REFRESH THEN
          propogate_ps_node_type_changes( p_ps_node, l_model_ref_expl_changed2);
        END IF;

        IF l_model_ref_expl_changed1 = G_YES_FLAG OR
           l_model_ref_expl_changed2 = G_YES_FLAG OR
          (l_model_ref_expl_changed1 = 'U' AND l_model_ref_expl_changed2 = 'U' AND p_model_ref_expl_changed = G_YES_FLAG) THEN

            fix_model_ref_expl_ids(p_ps_node, l_model_ref_expl_changed1);
        ELSE
          l_model_ref_expl_changed1 := G_NO_FLAG;
        END IF;
      END IF;

      get_Child_Nodes(p_ps_node.ps_node_id,
                      G_YES_FLAG,  -- get all the nodes
                      l_seq_nodes_tbl,
                      l_nodes_tbl,
                      l_non_del_child_nodes_tbl,
                      G_YES_FLAG);

    --DEBUG('asp:Child count ' || l_seq_nodes_tbl.COUNT);
    IF l_seq_nodes_tbl.COUNT > 0 THEN
        l_ps_node_index := 0;

        l_check_for_bom_table := FALSE;
        -- If the parent node passed in to this procedure, is an BOM OC or a BOM Model
        -- and we did not add or remove a UI element for this BOM in this session
        -- then we need to check if any if a table for this OC/Model needs to be there in the UI
        -- based on new/ deleted Std items/ OCs
        IF (l_add_remove_flag = G_EXISTS_FLAG AND (p_ps_node.ps_node_type = G_BOM_OPTION_CLASS_TYPE OR
                 p_ps_node.ps_node_type = G_BOM_MODEL_TYPE) ) THEN

          l_check_for_bom_table := TRUE;

          BEGIN
            SELECT element_id, page_Id INTO l_bom_table_id, l_page_id
              FROM cz_ui_page_elements
             WHERE ui_def_Id = g_UI_Context.ui_def_id
               AND persistent_node_id = p_ps_node.persistent_node_id
               AND deleted_flag IN (G_NO_FLAG, G_MARK_TO_REFRESH)
               AND element_type = G_UI_BOMADDINST_NODE_TYPE
               AND rownum < 2;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_bom_table_id := NULL;
          END;
        END IF;

        FOR i IN 1..l_seq_nodes_tbl.COUNT
        LOOP
          l_ps_node := l_seq_nodes_tbl(i);
          IF l_ps_node.deleted_flag = G_NO_FLAG THEN
            l_ps_node_index := l_ps_node_index + 1;
          END IF;
          IF( l_check_for_bom_table ) THEN

              -- We need to process Standard Items because we may need to add/ delete a BOM table
              -- if a Standard Item was added/ removed
              -- We go to add the table only when we have not made the decision based on a prior Standard Item/ Option Class
              -- or BOM Reference under this BOM. We also skip addition/ removal of the table if
              -- l_add_remove_flag = G_EXISTS_FLAG which implies that the BOM table for the parent was not added or removed
              -- in this refresh session. The G_EXISTS_FLAG is slightly misleading in the sense that it gives one the impression
              -- that UI Node for the Model node exists. G_EXISTS_FLAG simply means that the UI for the Model node was neither added
              -- nor removed during this refresh session
              IF( l_bom_table_id IS NOT NULL ) THEN

                IF( NVL(l_ps_node.UI_TIMESTAMP_REMOVE, g_UI_Context.UI_TIMESTAMP_REFRESH) > g_UI_Context.UI_TIMESTAMP_REFRESH) THEN

                  -- mark the flag so that we dont do the same for other children
                  l_check_for_bom_table := FALSE;

                  IF NOT(contains_BOM_Nodes(p_ps_node.ps_node_id)) THEN
                      UPDATE CZ_UI_PAGE_ELEMENTS
                         SET deleted_flag=G_MARK_TO_DELETE
                       WHERE ui_def_id=g_UI_Context.ui_def_id
                         AND page_id = l_page_id
                         AND element_Id = l_bom_table_id;

                      mark_UI_Page_As_Refreshed(l_page_id, g_UI_Context.ui_def_id);

                  END IF;
                END IF;
              ELSE
                IF( NVL(l_ps_node.UI_TIMESTAMP_ADD, g_UI_Context.UI_TIMESTAMP_REFRESH) > g_UI_Context.UI_TIMESTAMP_REFRESH) THEN
                  IF (contains_BOM_Nodes(p_ps_node.ps_node_id)) THEN
                    --
                    -- Add bom table here
                    --
                    FOR m IN(SELECT page_id, pagebase_expl_node_id FROM CZ_UI_PAGES
                              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                                    deleted_flag IN(G_NO_FLAG, G_MARK_TO_REFRESH)  AND
                                    persistent_node_id = p_ps_node.persistent_node_id)
                    LOOP
                      SELECT element_id, suppress_refresh_flag
                        INTO l_bom_parent_element, l_suppress_refresh_flag
                        FROM CZ_UI_PAGE_ELEMENTS
                       WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id=m.page_id AND
                             parent_element_id IS NULL AND persistent_node_id=p_ps_node.persistent_node_id AND
                             pagebase_persistent_node_id=region_persistent_node_id AND
                             pagebase_persistent_node_id=p_ps_node.persistent_node_id AND
                             deleted_flag=G_NO_FLAG;

                      IF NVL(l_suppress_refresh_flag, G_NO_FLAG)=G_NO_FLAG THEN
                        add_BOM_Node
                         (p_node                        => p_ps_node,
                          p_page_id                     => m.page_id,
                          p_pagebase_expl_node_id       => m.pagebase_expl_node_id,
                          p_parent_element_id           => l_bom_parent_element,
                          p_pagebase_persistent_node_id => p_ps_node.persistent_node_id,
                          p_check_child_bom_nodes       => G_NO_FLAG );
                      END IF;
                    END LOOP;

                    -- mark the flag so that we dont do the same for other children
                    l_check_for_bom_table := FALSE;
                  END IF;
                END IF;
              END IF;
          END IF;

          IF l_ps_node.ps_node_type NOT IN (G_OPTION_TYPE, G_BOM_STANDART_ITEM_TYPE) THEN
            propogate_changes_to_UI(l_ps_node, l_non_del_child_nodes_tbl, l_ps_node_index, l_add_remove_flag, l_add_remove_timestamp, l_moved_flag, l_model_ref_expl_changed1);
          END IF;
        END LOOP;
    END IF;

    END propogate_changes_to_UI;


    PROCEDURE refresh_UI_new(p_ui_timestamp_refresh IN DATE) IS

      l_root_persistent_node_id     NUMBER;
      l_nodes_tbl                   model_nodes_tbl_type;
      l_seq_nodes_tbl               ui_page_el_int_tbl_type; -- fix for bug 6837809 : skudryav 28-Mar-2008
      l_non_del_child_nodes_tbl     model_nodes_tbl_type;
      l_ui_nodes_tbl                ui_page_elements_tbl_type;
      l_next_level_ui_pages_tbl     ui_page_elements_tbl_type;

      l_ps_node                     CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_empty_siblings_tbl          model_nodes_tbl_type;

    BEGIN

      -- start with the root of the model
      l_root_persistent_node_id := get_Root_Persistent_Node_Id();
      l_ps_node := get_Model_Node_By_Persist_Id(l_root_persistent_node_id,
                                                g_UI_Context.devl_project_id);

      get_Child_Nodes(l_ps_node.ps_node_id,
                      G_YES_FLAG,  -- get all the nodes
                      l_seq_nodes_tbl,
                      l_nodes_tbl,
                      l_non_del_child_nodes_tbl,
                      G_YES_FLAG);

    --DEBUG('asp:Last UI Refresh done at ' || p_ui_timestamp_refresh);
      propogate_changes_to_UI(l_ps_node, l_empty_siblings_tbl, -1, G_EXISTS_FLAG, p_ui_timestamp_refresh, FALSE, G_NO_FLAG);


  END refresh_UI_new;

  --
  -- check for UI nodes which have AMNs from referenced models
  -- and if there are some such UI nodes then mark corresponding UI pages
  -- as MARK_TO_REFRESH
  --
  PROCEDURE check_Ref_AMNs IS

    TYPE xml_dom_docs_tbl_type  IS TABLE OF xmldom.DOMDocument INDEX BY VARCHAR2(255);
    l_doc_cache_tbl     xml_dom_docs_tbl_type;
    l_expl_id           NUMBER;
    l_node_is_reachable NUMBER := -1;
    l_has_unreach       BOOLEAN := FALSE;
    l_xml_doc           xmldom.DOMDocument;
    l_xml_node          xmldom.DOMNode;
    l_null_xml_doc      xmldom.DOMDocument;
    l_instance_list_amn expl_node_persistent_id_pair;
    l_ui_node           CZ_UI_PAGE_ELEMENTS%ROWTYPE;

  BEGIN

    FOR t IN (SELECT ps_node_id,persistent_node_id as psnode_persistent_node_id,ps_node_type,component_id
                FROM CZ_PS_NODES psnode
               START WITH psnode.devl_project_id IN
                     (SELECT refexpl.component_id FROM CZ_MODEL_REF_EXPLS refexpl
                         WHERE refexpl.model_id=g_UI_Context.devl_project_id AND
                               refexpl.ps_node_type=G_REFERENCE_TYPE AND refexpl.deleted_flag='0') AND
                       psnode.deleted_flag='0' AND
                       ( psnode.ui_timestamp_move > NVL(g_UI_Context.ui_timestamp_refresh, g_UI_Context.creation_date) OR
                         psnode.ui_timestamp_changetype > NVL(g_UI_Context.ui_timestamp_refresh, g_UI_Context.creation_date)  )
                CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag='0'
               )
    LOOP

        SELECT MIN(model_ref_expl_id) INTO l_expl_id FROM CZ_MODEL_REF_EXPLS
         WHERE model_id=g_UI_Context.devl_project_id AND deleted_flag='0' AND
              ((t.ps_node_type NOT IN(G_REFERENCE_TYPE,G_CONNECTOR_TYPE) AND component_id=t.component_id) OR
              (t.ps_node_type IN(G_REFERENCE_TYPE,G_CONNECTOR_TYPE) AND referring_node_id=t.ps_node_id));

        FOR upgel IN(SELECT b.*,a.pagebase_expl_node_id,a.jrad_doc FROM CZ_UI_PAGES a,CZ_UI_PAGE_ELEMENTS b
                      WHERE a.ui_def_id=g_UI_Context.ui_def_id AND b.ui_def_id=g_UI_Context.ui_def_id AND
                            a.deleted_flag IN(G_MARK_TO_ADD, G_MARK_TO_REFRESH, G_NO_FLAG) AND
                            a.page_id=b.page_id AND
                            b.persistent_node_id = t.psnode_persistent_node_id)
        LOOP

          UPDATE CZ_UI_PAGE_ELEMENTS
             SET model_ref_expl_id=l_expl_id
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_id=upgel.page_id AND
                 persistent_node_id=t.psnode_persistent_node_id AND
                 model_ref_expl_id<>l_expl_id;

          UPDATE CZ_UI_PAGES
             SET pagebase_expl_node_id=l_expl_id
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_id=upgel.page_id AND
                 persistent_node_id=t.psnode_persistent_node_id AND
                 pagebase_expl_node_id<>l_expl_id;

          UPDATE CZ_UI_PAGE_SETS
             SET pagebase_expl_node_id=l_expl_id
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 persistent_node_id=t.psnode_persistent_node_id AND
                 pagebase_expl_node_id<>l_expl_id;

          UPDATE CZ_UI_PAGE_REFS
             SET target_expl_node_id=l_expl_id
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 target_persistent_node_id=t.psnode_persistent_node_id AND
                 target_expl_node_id<>l_expl_id;

          UPDATE CZ_UI_ACTIONS
             SET target_expl_node_id=l_expl_id
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 target_persistent_node_id=t.psnode_persistent_node_id AND
                 target_expl_node_id<>l_expl_id;

          IF upgel.deleted_flag=G_NO_FLAG THEN
             UPDATE CZ_UI_PAGES
                SET deleted_flag=G_MARK_TO_REFRESH
              WHERE ui_def_id=g_UI_Context.ui_def_id AND
                    page_id=upgel.page_id AND
                    deleted_flag=G_NO_FLAG;
          END IF;

          l_node_is_reachable :=CZ_DEVELOPER_UTILS_PVT.in_boundary(upgel.pagebase_expl_node_id,
                                                                   l_expl_id,
                                                                   t.psnode_persistent_node_id);
          IF l_node_is_reachable=0 THEN
            IF l_doc_cache_tbl.EXISTS(upgel.jrad_doc) THEN
              l_xml_doc := l_doc_cache_tbl(upgel.jrad_doc);
            ELSE
              l_xml_doc := parse_JRAD_Document(upgel.jrad_doc);
            END IF;

            l_xml_node := find_XML_Node_By_Attribute(l_xml_doc, G_ID_ATTRIBUTE, upgel.element_id);

            SELECT * INTO l_ui_node FROM CZ_UI_PAGE_ELEMENTS
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   page_id=upgel.page_id AND
                   element_id=upgel.element_id;

            l_instance_list_amn := getEnclosingInstanceListAMN(l_ui_node, l_xml_node);

            IF l_instance_list_amn.persistent_node_id IS NULL THEN
              l_has_unreach := TRUE;
              add_Error_Message(p_message_name => 'CZDEV_UI_ERR_VIR_BDR_BIND',
                                p_token_name   => 'PICKEDNODENAME',
                                p_token_value  => upgel.name,
                                p_fatal_error  => TRUE);
            END IF;
          END IF;
        END LOOP;
      END LOOP;

      IF l_has_unreach THEN
        RAISE UNREACH_UI_NODE;
      END IF;

  END check_Ref_AMNs;

  --
  -- populate UI tables
  --
  PROCEDURE populate_UI_Structures IS
    l_num_if_roots              NUMBER;
    l_target_persistent_node_id NUMBER;
    l_page_set_id               NUMBER;
    l_page_set_type             NUMBER;
    l_page_ref_id               NUMBER;
    l_ui_timestamp_refresh      DATE;
  BEGIN

    IF NVL(g_UI_Context.suppress_refresh_flag, G_NO_FLAG)=G_YES_FLAG THEN
      RETURN;
    END IF;
/*
    FOR i IN(SELECT ps_node_id FROM CZ_PS_NODES a
             WHERE devl_project_id=g_UI_Context.devl_project_id AND
                   ps_node_type IN(258,259,436,437) AND
                   deleted_flag=G_YES_FLAG AND EXISTS(SELECT NULL
                   FROM CZ_UI_PAGE_ELEMENTS WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   persistent_node_id=a.persistent_node_id AND deleted_flag=G_NO_FLAG))
    LOOP
      UPDATE CZ_PS_NODES
         SET deleted_flag=G_YES_FLAG
       WHERE ps_node_id IN
       (SELECT ps_node_id FROM CZ_PS_NODES
        START WITH ps_node_id=i.ps_node_id
        CONNECT BY PRIOR ps_node_id=parent_id);
    END LOOP;

    FOR i IN(SELECT ps_node_id FROM CZ_PS_NODES a
             WHERE devl_project_id=g_UI_Context.devl_project_id AND
                   ps_node_type IN(258,259,436,437) AND  ui_omit=G_YES_FLAG AND
                   deleted_flag=G_NO_FLAG AND EXISTS(SELECT NULL
                   FROM CZ_UI_PAGE_ELEMENTS WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   persistent_node_id=a.persistent_node_id AND deleted_flag=G_NO_FLAG))
    LOOP
      UPDATE CZ_PS_NODES
         SET deleted_flag=G_YES_FLAG
       WHERE ps_node_id IN
       (SELECT ps_node_id FROM CZ_PS_NODES
        START WITH ps_node_id=i.ps_node_id
        CONNECT BY PRIOR ps_node_id=parent_id);
    END LOOP;
*/
    --
    -- refresh all UI elements associated with root of model tree
    --
    l_ui_timestamp_refresh := g_UI_Context.UI_TIMESTAMP_REFRESH;

    g_using_new_UI_refresh := FALSE;

    IF l_ui_timestamp_refresh IS NULL THEN

      FOR i IN (SELECT ui_def_id, element_id,page_id, suppress_refresh_flag
                  FROM CZ_UI_PAGE_ELEMENTS
                  WHERE ui_def_id = g_UI_Context.ui_def_id AND
                        parent_element_id IS NULL AND
                        deleted_flag IN (G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH))
      LOOP

        refresh_UI_Subtree(p_element_id            => i.element_id,
                           p_page_id               => i.page_id,
                           p_suppress_refresh_flag => i.suppress_refresh_flag);
      END LOOP;
      handle_CXs_For_nonUINodes();
    ELSE
      g_using_new_UI_refresh := TRUE;
      refresh_UI_new(l_ui_timestamp_refresh);
      handle_CXs();
    END IF;

    handle_Deleted_Nodes(g_UI_Context.ui_def_id);

    -- set correct order for UI elements
    handle_UI_Page_Elements_Order();

    -- split UI Pages
    split_Pages();

    -- handle empty UI Pages
    handle_Empty_Pages();

    -- set data for Page Sets
    handle_Page_Flows();

    handle_SLMenu_Order();

    IF g_check_boundaries_tbl.EXISTS(g_UI_Context.ui_def_id) THEN
      check_Boundaries();
    END IF;

    check_Ref_AMNs();
  END populate_UI_Structures;


  PROCEDURE backup_nodes_to_move(p_page_id   IN NUMBER) IS

    l_node_ids_table number_tbl_type;
    l_id             NUMBER;
    l_parent_node    xmldom.DOMNode;
    l_node           xmldom.DOMNode;

  BEGIN

    IF g_elements_to_move.EXISTS(p_page_Id) THEN
      l_node_ids_table := g_elements_to_move(p_page_Id);
      IF l_node_ids_table.COUNT > 0 THEN
        l_id := l_node_ids_table.FIRST;
        WHILE l_id IS NOT NULL
        LOOP
          DEBUG('asp: Backing up nested element_id ' || l_id || ' on page ' || l_node_ids_table(l_id));
          IF g_dom_elements_tbl.EXISTS(l_id) THEN
            l_node := g_dom_elements_tbl(l_id);
            g_dom_elements_to_move(l_id) := l_node;
            l_parent_node:=xmldom.getParentNode(l_node);
            l_node:=xmldom.removeChild(l_parent_node, l_node);
          END IF;
          -- ELSE the node has already been moved
          l_id := l_node_ids_table.NEXT(l_id);
        END LOOP;
      END IF;
    END IF;

  END backup_nodes_to_move;

  --
  -- delete UI XML elements from UI page
  --
  PROCEDURE delete_UIXML_Elements(p_page_id   IN NUMBER,
                                  p_xml_doc      xmldom.DOMDocument) IS

    l_deleted_nodes_tbl     varchar2_tbl_type;
    l_node                  xmldom.DOMNode;
    l_out_node              xmldom.DOMNode;
    l_parent_node           xmldom.DOMNode;
    l_nodeslist             xmldom.DOMNodeList;
    l_length                NUMBER;
    l_element_id            VARCHAR2(255);
    l_deleted_nodes_exist      BOOLEAN := FALSE;
    l_deassociated_nodes_exist BOOLEAN := FALSE;

  BEGIN

    backup_nodes_to_move(p_page_id);
    FOR i IN(SELECT element_id,deleted_flag FROM CZ_UI_PAGE_ELEMENTS
             WHERE ui_def_id= g_UI_Context.ui_def_id AND
                   page_id=p_page_id AND
                   deleted_flag IN(G_MARK_TO_DELETE,G_MARK_TO_DEASSOCIATE))
    LOOP
      BEGIN
        l_deleted_nodes_tbl(i.element_id) := i.deleted_flag;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;

    --
    -- here we don't need to know about hierachy of nodes
    -- so we just need to get list of all nodes of XML subtree
    --
    l_nodeslist := xmldom.getElementsByTagName(p_xml_doc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    --
    -- delete XML elements
    --
    FOR i IN 0..l_length-1
    LOOP
        l_node := xmldom.item(l_nodeslist, i);
        l_element_id := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);
        BEGIN
          IF l_deleted_nodes_tbl.EXISTS(l_element_id) THEN

             IF l_deleted_nodes_tbl(l_element_id)=G_MARK_TO_DELETE THEN
               l_parent_node:=xmldom.getParentNode(l_node);
               l_out_node:=xmldom.removeChild(l_parent_node,l_node);
               l_deleted_nodes_exist := TRUE;
             ELSE -- deassociate this node
               set_Attribute(l_node, G_USER_ATTRIBUTE1_NAME, 'model_path=*');
               set_Attribute(l_node, G_USER_ATTRIBUTE2_NAME, '0');
               l_deassociated_nodes_exist := TRUE;
             END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
               NULL;
        END;
    END LOOP;

    --
    -- mark elements as already deleted,
    -- update revision of deleted UI page
    --
    IF l_deleted_nodes_exist THEN

      refresh_UI_Node_Marks(p_page_id => p_page_id,
                            p_hmode   => G_DELETE_ELEMENTS);
    END IF;

    IF l_deassociated_nodes_exist THEN
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag=G_NO_FLAG
       WHERE ui_def_id=g_UI_Context.ui_def_id AND
             page_id=p_page_id AND
             deleted_flag=G_MARK_TO_DEASSOCIATE;
      IF SQL%ROWCOUNT>0 THEN
        UPDATE CZ_UI_PAGES
           SET page_rev_nbr=page_rev_nbr+1
         WHERE page_id=p_page_id AND
               ui_def_id=g_UI_Context.ui_def_id;
      END IF;
    END IF;
  END delete_UIXML_Elements;

  --
  -- delete UI XML page
  --
  PROCEDURE delete_UIXML_Page(p_page_id   IN NUMBER,
                              p_jrad_doc  IN VARCHAR2) IS

    l_subtree_doc           xmldom.DOMDocument;

  BEGIN
    BEGIN
      IF g_elements_to_move.EXISTS(p_page_Id) THEN
        l_subtree_doc := parse_JRAD_Document(p_jrad_doc);

        IF xmldom.isNull(l_subtree_doc) THEN
           add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                             p_token_name   => 'UI_TEMPLATE',
                             p_token_value  => p_jrad_doc,
                             p_fatal_error  => TRUE);
           RAISE WRONG_UI_TEMPLATE;
        END IF;

        init_Page_View_Counters(l_subtree_doc);
        backup_nodes_to_move(p_page_Id);
      ELSE
        l_subtree_doc := parse_JRAD_Document(p_jrad_doc);
        IF xmldom.isNull(l_subtree_doc) THEN
           add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                             p_token_name   => 'UI_TEMPLATE',
                             p_token_value  => p_jrad_doc,
                             p_fatal_error  => TRUE);
           RAISE WRONG_UI_TEMPLATE;
        ELSE
          UPDATE CZ_UI_PAGE_ELEMENTS
             SET deleted_flag=G_MARK_TO_DELETE
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_id=p_page_id AND
                 deleted_flag NOT IN(G_MARK_TO_DELETE,G_YES_FLAG);
        END IF;
        init_Page_View_Counters(l_subtree_doc);
      END IF;

      --
      -- delete JRAD XML elements that marked to be deleted
      --
      delete_UIXML_Elements(p_page_id   => p_page_id,
                            p_xml_doc   => l_subtree_doc);

    EXCEPTION
      WHEN OTHERS THEN
        DEBUG('delete_UIXML_Page() : '||SQLERRM);
    END;

    BEGIN
      jdr_docbuilder.deleteDocument(p_jrad_doc);
    EXCEPTION
      WHEN OTHERS THEN
        DEBUG('delete_UIXML_Page() : '||SQLERRM);
    END;

    --
    -- mark elements and page as already deleted,
    --
    refresh_UI_Node_Marks(p_page_id => p_page_id,
                          p_hmode   => G_DELETE_PAGE);

  END delete_UIXML_Page;

  --
  -- refresh CXs on UI Page
  --
  PROCEDURE refresh_CXs_On_UI_Page
  (p_ui_page_id     NUMBER,
   p_subtree_doc    xmldom.DOMDocument) IS

    l_node                  xmldom.DOMNode;
    l_parent_node           xmldom.DOMNode;
    l_out_node              xmldom.DOMNode;
    l_nodeslist             xmldom.DOMNodeList;
    l_length                NUMBER;
    l_element_id            NUMBER;
    l_attribute_value       VARCHAR2(32000);
    l_cx_elements_tbl       varchar_tbl_type;
    l_suppress_refresh_tbl  varchar_tbl_type;
    l_suppress_el_flag_tbl  varchar_tbl_type;
    l_delete_node           BOOLEAN := FALSE;
    l_deassociate_cx        BOOLEAN := FALSE;
    l_suppress_refresh_flag CZ_UI_PAGE_ELEMENTS.suppress_refresh_flag%TYPE;

  BEGIN
    FOR i IN(SELECT * FROM CZ_UI_PAGE_ELEMENTS
             WHERE ui_def_id=g_UI_Context.ui_def_id AND
                   page_id=p_ui_page_id AND
                   element_type=G_UI_CX_BUTTON_NODE_TYPE AND
                   deleted_flag IN(G_NO_FLAG, G_MARK_TO_REFRESH))
    LOOP
       l_element_id := TO_NUMBER(i.element_id);
       l_cx_elements_tbl(l_element_id) := get_CX_Button_Status(i);
       l_suppress_el_flag_tbl(l_element_id) := NVL(i.suppress_refresh_flag, G_NO_FLAG);
       -- check suppress_refresh_flag of its container
       l_suppress_refresh_flag := G_NO_FLAG;
       IF i.parent_element_id IS NOT NULL THEN
         BEGIN
           SELECT NVL(suppress_refresh_flag,G_NO_FLAG) INTO l_suppress_refresh_flag
             FROM CZ_UI_PAGE_ELEMENTS
            WHERE ui_def_id=g_UI_Context.ui_def_id AND
                  page_id=p_ui_page_id AND
                  element_id=i.parent_element_id;
         END;
       END IF;
       l_suppress_refresh_tbl(l_element_id) := l_suppress_refresh_flag;
    END LOOP;

    --
    -- here we don't need to know about hierachy of nodes
    -- so we just need to get list of all nodes of XML subtree
    --
    l_nodeslist := xmldom.getElementsByTagName(p_subtree_doc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    l_node := xmldom.makeNode(xmldom.getDocumentElement(p_subtree_doc));

    --
    -- scan subtree and substitute macros "%" to real values
    --
    FOR i IN 0 .. l_length - 1
    LOOP
      l_delete_node     := FALSE;
      l_deassociate_cx  := FALSE;
      l_node            := xmldom.item(l_nodeslist, i);
      l_attribute_value := get_Attribute_Value(l_node, G_ID_ATTRIBUTE );
      l_element_id := NULL;
      BEGIN
        l_element_id := TO_NUMBER(l_attribute_value);
        IF l_cx_elements_tbl.EXISTS(l_element_id) THEN

          IF l_cx_elements_tbl(l_element_id) IN (G_CX_VALID) AND
             l_suppress_refresh_tbl(l_element_id)=G_NO_FLAG AND
             l_suppress_el_flag_tbl(l_element_id)=G_NO_FLAG THEN
             set_Attribute(xmldom.makeElement(l_node), 'rendered', 'true');
          ELSIF l_cx_elements_tbl(l_element_id) IN (G_CX_INVALID) AND
             l_suppress_refresh_tbl(l_element_id)=G_NO_FLAG  AND
             l_suppress_el_flag_tbl(l_element_id)=G_NO_FLAG THEN
             set_Attribute(xmldom.makeElement(l_node), 'rendered', 'false');
          ELSIF l_cx_elements_tbl(l_element_id) IN (G_CX_MUST_BE_DELETED) THEN
             l_delete_node := TRUE;
             IF  l_suppress_refresh_tbl(l_element_id)=G_YES_FLAG  OR
                 l_suppress_el_flag_tbl(l_element_id)=G_YES_FLAG THEN
               l_deassociate_cx := TRUE;
             END IF;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF l_delete_node THEN
        IF l_deassociate_cx THEN
          set_Attribute(l_node, G_USER_ATTRIBUTE1_NAME, 'model_path=*');
          set_Attribute(l_node, G_USER_ATTRIBUTE2_NAME, '0');

          UPDATE CZ_UI_PAGE_ELEMENTS
             SET persistent_node_id=0
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_id=p_ui_page_id AND
                 element_id=l_attribute_value;
        ELSE
          l_parent_node:=xmldom.getParentNode(l_node);
          l_out_node:=xmldom.removeChild(l_parent_node,l_node);
          UPDATE CZ_UI_PAGE_ELEMENTS
             SET deleted_flag=G_YES_FLAG
           WHERE ui_def_id=g_UI_Context.ui_def_id AND
                 page_id=p_ui_page_id AND
                 element_id=l_attribute_value;
        END IF;
      END IF;

    END LOOP;

    UPDATE CZ_UI_PAGES
       SET page_rev_nbr=page_rev_nbr+1
    WHERE ui_def_id=g_UI_Context.ui_def_id AND
          page_id=p_ui_page_id;

  END refresh_CXs_On_UI_Page;

  --
  -- populate cache of xml nodes for a given XML page
  --
  PROCEDURE cache_UI_Page(p_xml_doc  xmldom.DOMDocument) IS
    l_node            xmldom.DOMNode;
    l_nodeslist       xmldom.DOMNodeList;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;
    l_attribute_value VARCHAR2(32000);

  BEGIN

    g_page_elements_tbl.DELETE;

    l_nodeslist := xmldom.getElementsByTagName(p_xml_doc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    l_node := xmldom.makeNode(xmldom.getDocumentElement(p_xml_doc));

    l_attribute_value := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);

    IF l_attribute_value IS NOT NULL THEN
      g_page_elements_tbl(l_attribute_value) := l_node;
    END IF;

    FOR i IN 0 .. l_length - 1
    LOOP
      l_node := xmldom.item(l_nodeslist, i);

      l_attribute_value := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);

      IF l_attribute_value IS NOT NULL THEN
        g_page_elements_tbl(l_attribute_value) := l_node;
      END IF;

    END LOOP;

  END cache_UI_Page;

  --
  -- refresh UI XML page
  --
  PROCEDURE refresh_UIXML_Page(p_page_id IN NUMBER) IS

    l_subtree_doc           xmldom.DOMDocument;
    l_xml_root_node         xmldom.DOMNode;
    l_xml_uicontent_node    xmldom.DOMNode;
    l_xml_node_to_refresh   xmldom.DOMNode;
    l_page_ui_node          CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_jrad_doc              CZ_UI_TEMPLATES.jrad_doc%TYPE;
    l_col_number            NUMBER := 0;

    PROCEDURE create_Next_XML_Level(p_ui_node               CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                    p_parent_xml_node    xmldom.DOMNode) IS

      l_new_xml_node         xmldom.DOMNode;
      l_new_opt_xml_node     xmldom.DOMNode;
      l_xml_node_to_replace  xmldom.DOMNode;
      l_opt_model_node       CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE;
      l_element_type         NUMBER;

    BEGIN
      --
      -- get child UI nodes
      --
      FOR i IN (SELECT *
                  FROM CZ_UI_PAGE_ELEMENTS a
                 WHERE ui_def_id =  g_UI_Context.ui_def_id AND
                       page_id = p_page_id AND
                       parent_element_id = p_ui_node.element_id
                       -- parent_persistent_node_id = p_ui_node.persistent_node_id
                 ORDER BY seq_nbr)
      LOOP
        IF i.deleted_flag IN(G_MARK_TO_ADD,G_MARK_DO_NOT_REFRESH) THEN
          IF p_ui_node.element_type IN(G_UI_PAGE_NODE_TYPE,G_UI_REGION_NODE_TYPE) AND
             NOT(NVL(p_ui_node.instantiable_flag, G_MANDATORY_INST_TYPE) IN(G_OPTIONAL_INST_TYPE,G_MINMAX_INST_TYPE) AND
                 p_ui_node.element_type=G_UI_REGION_NODE_TYPE) THEN

            IF i.element_type=G_UI_REGION_NODE_TYPE THEN -- this a region

              --
              -- create new JRAD region
              --
              l_new_xml_node := create_UIXML_Region(p_ui_node         => i,
                                                    p_parent_xml_node => p_parent_xml_node);

            ELSE -- this is regular UI element

              --
              -- create new JRAD element
              --
              l_new_xml_node := create_UIXML_Element(p_ui_node         => i,
                                                     p_parent_xml_node => p_parent_xml_node);

            END IF; -- end of  IF i.element_type=G_UI_REGION_NODE_TYPE ...

          ELSE -- p_ui_node is not a UI container
            -- CXs can be attached to Options/BOM Standart Items
            IF i.element_type=G_UI_CX_BUTTON_NODE_TYPE THEN
              l_opt_model_node := get_Model_Node_By_Persist_Id(i.persistent_node_id, g_UI_Context.devl_project_id);
              IF l_opt_model_node.ps_node_type IN(G_OPTION_TYPE) THEN
                l_new_xml_node := create_UIXML_Element(p_ui_node         => i,
                                                       p_parent_xml_node => xmldom.getParentNode(p_parent_xml_node));

              END IF;
            END IF;
          END IF; -- end of IF p_ui_node.element_type IN(G_UI_PAGE_NODE_TYPE,G_UI_REGION_NODE_TYPE) ...

       ELSIF i.deleted_flag IN(G_MARK_TO_REFRESH) THEN

          l_xml_node_to_replace := find_XML_Node_By_Attribute(p_subtree_doc     => l_subtree_doc ,
                                                              p_attribute_name  => G_ID_ATTRIBUTE,
                                                              p_attribute_value => i.element_id);

          IF NOT(xmldom.isNull(l_xml_node_to_replace)) THEN

            --
            -- create new JRAD element
            --
            l_new_xml_node := replace_UIXML_Element(p_ui_node             => i,
                                                    p_parent_xml_node     => p_parent_xml_node,
                                                    p_xml_node_to_replace => l_xml_node_to_replace);
          END IF;

       ELSIF i.deleted_flag = G_MARK_TO_MOVE THEN
         l_new_xml_node := move_XML_Node(p_ui_node         => i,
                                         p_parent_xml_node => p_parent_xml_node);

       ELSIF i.deleted_flag IN(G_YES_FLAG, G_LIMBO_FLAG) THEN
         NULL; -- do not refresh deleted UI nodes

       ELSE
         l_new_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_subtree_doc ,
                                                     p_attribute_name  => G_ID_ATTRIBUTE,
                                                     p_attribute_value => i.element_id);
       END IF;

       create_Next_XML_Level(i, l_new_xml_node);

      END LOOP;

    END create_Next_XML_Level;

    PROCEDURE refresh_UI_Node(p_page_ui_node    CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                              p_xml_parent_node xmldom.DOMNode) IS

      l_xml_node_to_replace xmldom.DOMNode;
      l_new_xml_node         xmldom.DOMNode;

    BEGIN

      FOR i IN(SELECT * FROM CZ_UI_PAGE_ELEMENTS
                WHERE ui_def_id=p_page_ui_node.ui_def_id
                      AND parent_element_id=p_page_ui_node.element_id
                      AND persistent_node_id=p_page_ui_node.persistent_node_id
                      AND (element_type IS NULL OR element_type <> G_UI_CX_BUTTON_NODE_TYPE)
                      AND deleted_flag IN(G_MARK_TO_ADD,G_MARK_TO_REFRESH))
      LOOP
        IF i.deleted_flag=G_MARK_TO_REFRESH THEN
          BEGIN
            l_xml_node_to_replace := find_XML_Node_By_Attribute(p_subtree_doc     => l_subtree_doc,
                                                                p_attribute_name  => G_ID_ATTRIBUTE,
                                                                p_attribute_value => i.element_id);


            IF NOT(xmldom.isNull(l_xml_node_to_replace)) THEN
               --
               -- create new JRAD element
               --
               l_xml_uicontent_node := replace_UIXML_Element(p_ui_node             => i,
                                                             p_parent_xml_node     => p_xml_parent_node,
                                                             p_xml_node_to_replace => l_xml_node_to_replace);
            END IF;

           EXCEPTION
            WHEN OTHERS THEN
              --
              -- this is not critical error message
              --
              DEBUG('refresh_UIXML_Page() : '||SQLERRM);
              RAISE;
          END;

         END IF;
      END LOOP;
    END refresh_UI_Node;

  BEGIN

    -- first delete the cache of dom elements
  g_dom_elements_tbl.DELETE;

    SELECT *
      INTO l_page_ui_node
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id =  g_UI_Context.ui_def_id AND
           page_id = p_page_id AND
           parent_element_id IS NULL AND
           -- element_type=G_UI_PAGE_NODE_TYPE AND
           deleted_flag IN(G_NO_FLAG, G_MARK_TO_ADD, G_MARK_TO_REFRESH);

    IF l_page_ui_node.ctrl_template_id IN(G_2COLS_CONTAINER_TEMPLATE_ID,
                                          G_3COLS_CONTAINER_TEMPLATE_ID) THEN

      IF l_page_ui_node.ctrl_template_id = G_2COLS_CONTAINER_TEMPLATE_ID THEN
        IF g_Num_Elements_On_Page <= g_Elements_Per_Column THEN
          l_col_number := 1;
        ELSE
          l_col_number :=2;
        END IF;
      END IF;

      IF l_page_ui_node.ctrl_template_id = G_3COLS_CONTAINER_TEMPLATE_ID THEN
        IF g_Num_Elements_On_Page <= g_Elements_Per_Column THEN
          l_col_number := 1;
        ELSIF g_Num_Elements_On_Page > g_Elements_Per_Column AND
              g_Num_Elements_On_Page <= 2*g_Elements_Per_Column THEN
          l_col_number := 2;
        ELSE
          l_col_number := 3;
        END IF;
      END IF;
    ELSE
      l_col_number := 0;
    END IF;

    SELECT jrad_doc INTO l_jrad_doc
      FROM CZ_UI_PAGES
     WHERE ui_def_id= g_UI_Context.ui_def_id AND
           page_id=p_page_id;

    --
    -- parse document(template) which is going to be nested element
    --
    l_subtree_doc := parse_JRAD_Document(l_jrad_doc);

    --
    -- cache xml nodes of this UI page
    --
    cache_UI_Page(l_subtree_doc);

    IF xmldom.isNull(l_subtree_doc) THEN
       add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                         p_token_name   => 'UI_TEMPLATE',
                         p_token_value  => l_jrad_doc,
                         p_fatal_error  => TRUE);
       RAISE WRONG_UI_TEMPLATE;
    END IF;

    init_Page_View_Counters(l_subtree_doc);

    --
    -- delete JRAD XML elements that marked to be deleted
    --
    delete_UIXML_Elements(p_page_id   => p_page_id,
                          p_xml_doc   => l_subtree_doc);

    --
    -- get subdocument's root node
    --
    l_xml_root_node := xmldom.makeNode(xmldom.getDocumentElement(l_subtree_doc));

    IF l_col_number = 0 THEN
      l_xml_uicontent_node := getUIContents(l_xml_root_node);
    ELSE
      l_xml_uicontent_node := get_Col_UIContents(l_xml_root_node, l_col_number);
    END IF;

    refresh_UI_Node(l_page_ui_node, l_xml_uicontent_node);

    create_Next_XML_Level(l_page_ui_node,
                          l_xml_uicontent_node);
    --
    -- refresh CXs on the current UI page
    --
    refresh_CXs_On_UI_Page(p_ui_page_id   => p_page_id ,
                           p_subtree_doc  => l_subtree_doc);

    refresh_All_Model_Paths(l_subtree_doc, p_page_id);

    --
    -- save XML page in JRAD repository
    --
    Save_Document(l_subtree_doc, l_jrad_doc);

    --
    -- mark elements and page as already refreshed
    --
    refresh_UI_Node_Marks(p_page_id => p_page_id,
                          p_hmode   => G_REFRESH_PAGE);

  END refresh_UIXML_Page;

  --
  -- create UI XML page
  --
  PROCEDURE create_UIXML_Page(p_page_id   IN NUMBER,
                              p_jrad_doc  IN VARCHAR2) IS

    l_subtree_doc        xmldom.DOMDocument;
    l_xml_root_node      xmldom.DOMNode;
    l_xml_uicontent_node xmldom.DOMNode;
    l_page_ui_node       CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_jrad_doc           CZ_UI_TEMPLATES.jrad_doc%TYPE;
    l_sub_element_id     CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_curr_element_id    CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_child_nodes_tbl    xmldom.DOMNodeList;
    l_xml_node           xmldom.DOMNode;
    l_length             NUMBER;
    l_col_number         NUMBER;

    PROCEDURE create_Next_XML_Level(p_element_id         NUMBER,
                                    p_parent_xml_node    xmldom.DOMNode) IS
      l_new_xml_node  xmldom.DOMNode;
    BEGIN

      --
      -- get child UI nodes
      --
      FOR i IN (SELECT *
                  FROM CZ_UI_PAGE_ELEMENTS
                 WHERE ui_def_id =  g_UI_Context.ui_def_id AND
                       page_id = p_page_id AND
                       parent_element_id = p_element_id AND
                       ctrl_template_id IS NOT NULL AND
                       deleted_flag IN(G_MARK_TO_ADD,G_MARK_DO_NOT_REFRESH,G_MARK_TO_MOVE)
                 ORDER BY seq_nbr)
      LOOP
        IF i.deleted_Flag = G_MARK_TO_MOVE THEN
          l_new_xml_node := move_XML_Node(p_ui_node         => i,
                                          p_parent_xml_node => p_parent_xml_node);
        ELSE
          IF i.element_type=G_UI_REGION_NODE_TYPE THEN -- this a region

            IF g_UI_Context.control_layout=1 THEN
              IF i.seq_nbr <= g_Elements_Per_Column THEN
                l_col_number := 1;
              ELSE
                l_col_number := 2;
              END IF;
            END IF;

            IF g_UI_Context.control_layout=2 THEN
              IF i.seq_nbr <= g_Elements_Per_Column THEN
                l_col_number := 1;
              ELSIF i.seq_nbr > g_Elements_Per_Column AND
                    i.seq_nbr <= 2*g_Elements_Per_Column THEN
                l_col_number := 2;
              ELSE
                l_col_number := 3;
              END IF;
            END IF;

            IF i.parent_element_id=l_page_ui_node.element_id AND l_col_number>1 THEN
              l_new_xml_node := create_UIXML_Region(p_ui_node         => i,
                                                    p_parent_xml_node => get_Col_UIContents(l_xml_root_node, l_col_number));
            ELSE
              l_new_xml_node := create_UIXML_Region(p_ui_node         => i,
                                                    p_parent_xml_node => p_parent_xml_node);
            END IF;

          ELSE -- this is regular UI element

            IF g_UI_Context.control_layout=1 THEN
              IF i.seq_nbr <= g_Elements_Per_Column THEN
                l_col_number := 1;
              ELSE
                l_col_number :=2;
              END IF;
            END IF;

            IF g_UI_Context.control_layout=2 THEN
              IF i.seq_nbr <= g_Elements_Per_Column THEN
                l_col_number := 1;
              ELSIF i.seq_nbr > g_Elements_Per_Column AND
                    i.seq_nbr <= 2*g_Elements_Per_Column THEN
                l_col_number := 2;
              ELSE
                l_col_number := 3;
              END IF;
            END IF;

             IF i.parent_element_id=l_page_ui_node.element_id AND l_col_number>1 THEN

               l_new_xml_node := create_UIXML_Element(p_ui_node         => i,
                                                      p_parent_xml_node => get_Col_UIContents(l_xml_root_node, l_col_number));
             ELSE

               l_new_xml_node := create_UIXML_Element(p_ui_node         => i,
                                                      p_parent_xml_node => p_parent_xml_node);
             END IF;
          END IF;
        END IF;

        create_Next_XML_Level(i.element_id, l_new_xml_node);

      END LOOP;

    END create_Next_XML_Level;

  BEGIN

    init_Page_View_Counters();

    l_col_number := 0;

    IF g_UI_Context.control_layout IN(1,2) THEN
      l_col_number := 1;
    END IF;

    SELECT *
      INTO l_page_ui_node
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id =  g_UI_Context.ui_def_id AND
           page_id = p_page_id AND
           persistent_node_id = pagebase_persistent_node_id AND
           parent_element_id IS NULL AND
           element_type=G_UI_PAGE_NODE_TYPE AND
           deleted_flag = G_MARK_TO_ADD;

    l_jrad_doc := get_JRAD_Name(p_template_id => l_page_ui_node.ctrl_template_id);

    --
    -- parse document(template) which is going to be nested element
    --
    l_subtree_doc := parse_JRAD_Document(l_jrad_doc);

    IF xmldom.isNull(l_subtree_doc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_jrad_doc,
                        p_fatal_error  => TRUE);
       RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- get subdocument's root node
    --
    l_xml_root_node := xmldom.makeNode(xmldom.getDocumentElement(l_subtree_doc));

    --
    -- remove common attributes of container and subtree
    --
    remove_TopLevel_Attributes(l_xml_root_node);

    --
    -- set Attributes for this subtree = Template
    --
    set_Template_Attributes(p_xml_root_node => l_xml_root_node,
                            p_ui_node       => l_page_ui_node);

    IF g_UI_Context.control_layout=0 THEN
      l_xml_uicontent_node := getUIContents(l_xml_root_node);
    ELSE
      l_xml_uicontent_node := get_Col_UIContents(l_xml_root_node, 1);
    END IF;

    l_child_nodes_tbl := xmldom.getElementsByTagName(l_subtree_doc, '*');

    --
    -- we need to get length of array of child nodes
    -- to go through the array in loop
    --
    l_length := xmldom.getLength(l_child_nodes_tbl);
    FOR k IN 0..l_length-1
    LOOP
      l_xml_node := xmldom.item(l_child_nodes_tbl, k);

      l_curr_element_id := get_Attribute_Value(l_xml_node,
                                               G_ID_ATTRIBUTE);
      IF l_curr_element_id IS NOT NULL AND k > 0 THEN
        l_sub_element_id := get_Element_Id();

        --
        -- set JRAD id of element
        --
        set_Attribute(l_xml_node,
                    G_ID_ATTRIBUTE,
                    REPLACE(REPLACE(l_curr_element_id||'_'||l_sub_element_id,'_czt','_czn'),'_czc','_czn'));
       END IF;
    END LOOP;

    create_Next_XML_Level(l_page_ui_node.element_id,
                          l_xml_uicontent_node);

    --
    -- save XML page in JRAD repository
    --
    Save_Document(l_subtree_doc, p_jrad_doc);

    --
    -- update page status and page_rev_nbr
    -- page_rev_nbr=1 because this is first creation
    -- mark elements and page as already refreshed
    --
    refresh_UI_Node_Marks(p_page_id => p_page_id,
                          p_hmode   => G_NEW_PAGE);

  END create_UIXML_Page;

  --
  -- handle UI XML pages of given UI
  -- handle_JRAD_Pages() is called from procedure construct_Single_UI()
  --
  PROCEDURE handle_JRAD_Page(p_page_id       IN NUMBER,
                             p_page_jrad_doc IN VARCHAR2,
                             p_page_status   IN VARCHAR2) IS

    l_num_elements_on_page NUMBER;

  BEGIN

    IF g_UI_Context.control_layout IN(1,2) THEN
      SELECT COUNT(element_id) INTO g_Num_Elements_On_Page
      FROM CZ_UI_PAGE_ELEMENTS
      WHERE ui_def_id=g_UI_Context.ui_def_id AND
            page_id=p_page_id AND
            (element_type IS NULL OR ctrl_template_id IS NOT NULL) AND
            deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);
     g_Elements_Per_Column := FLOOR(g_Num_Elements_On_Page/(g_UI_Context.control_layout+1));
    END IF;

    --
    -- delete JRAD document associated with the page
    --
    IF p_page_status = G_MARK_TO_DELETE THEN
      delete_UIXML_Page(p_page_id, p_page_jrad_doc);
    END IF;

    --
    -- create JRAD page
    --
    IF p_page_status = G_MARK_TO_ADD THEN
      create_UIXML_Page(p_page_id, p_page_jrad_doc);
      --
      -- translate the current JRAD page
      --
      translate_JRAD_Doc(p_page_jrad_doc);
    END IF;

    --
    -- refresh JRAD page
    --
    IF p_page_status = G_MARK_TO_REFRESH THEN

      refresh_UIXML_Page(p_page_id);
      --
      -- translate the current JRAD page
      --
      translate_JRAD_Doc(p_page_jrad_doc);
    END IF;

  END handle_JRAD_Page;

  --
  -- handle UI XML pages of given UI
  -- handle_JRAD_Pages() is called from procedure construct_Single_UI()
  --
  PROCEDURE handle_JRAD_Pages IS
  BEGIN
    FOR i IN (SELECT page_id, jrad_doc, deleted_flag
                FROM CZ_UI_PAGES
               WHERE ui_def_id = g_UI_Context.ui_def_id AND
                     deleted_flag <> G_YES_FLAG)
    LOOP
      IF i.deleted_flag IN(G_MARK_TO_DELETE,G_MARK_TO_ADD,
                           G_MARK_TO_REFRESH,G_MARK_TO_DEASSOCIATE) THEN
        --
        -- handle the current JRAD page
        --
        handle_JRAD_Page(p_page_id       => i.page_id,
                         p_page_jrad_doc => i.jrad_doc,
                         p_page_status   => i.deleted_flag);
      ELSE
        FOR n IN(SELECT G_YES_FLAG FROM CZ_UI_PAGE_ELEMENTS
                 WHERE ui_def_id=g_UI_Context.ui_def_id AND page_id=i.page_id AND
                       element_type=G_UI_CX_BUTTON_NODE_TYPE AND
                       deleted_flag=G_NO_FLAG AND rownum<2)
        LOOP
          --
          -- handle the current JRAD page
          --
          handle_JRAD_Page(p_page_id       => i.page_id,
                           p_page_jrad_doc => i.jrad_doc,
                           p_page_status   => G_MARK_TO_REFRESH);

         END LOOP;
      END IF;
    END LOOP;
  END handle_JRAD_Pages;

  -- Check if a PIR's target page reachable
  -- p_pagebase_expl_id,p_node_expl_id and p_node_persistent_id are a PIR element's
  -- pagebase_expl_id, model_ref_expl_id and persistent_node_id
  -- p_ui_def_id parent ui if the PIR's AMN is the child model's root node, child ui otherwise
  FUNCTION target_page_reachable(p_base_expl_id IN NUMBER,
                                 p_node_expl_id IN NUMBER,
                                 p_node_persistent_id IN NUMBER,
                                 p_ui_def_id IN NUMBER)
      RETURN BOOLEAN
  IS
    l_instantiable_flag cz_ps_nodes.INSTANTIABLE_FLAG%TYPE;
  BEGIN
    IF CZ_DEVELOPER_UTILS_PVT.in_boundary
          (p_base_expl_id, p_node_expl_id, p_node_persistent_id) = 0 THEN
      RETURN FALSE;
    ELSE
      SELECT instantiable_flag INTO l_instantiable_flag
      FROM cz_ps_nodes
      WHERE devl_project_id = (SELECT devl_project_id FROM cz_ui_defs
                               WHERE ui_def_id = p_ui_def_id) AND
                                     persistent_node_id = p_node_persistent_id;
      RETURN (l_instantiable_flag IS NULL OR
              l_instantiable_flag NOT IN (G_OPTIONAL_INST_TYPE, G_MINMAX_INST_TYPE));
    END IF;
  END target_page_reachable;

  FUNCTION get_page_name(p_ui_def_id IN NUMBER, p_page_id IN NUMBER)
        RETURN VARCHAR2
  IS
    l_name CZ_UI_PAGES.NAME%TYPE;
  BEGIN
    SELECT NVL(name, to_char(page_id)) INTO l_name
    FROM cz_ui_pages
    WHERE ui_def_id = p_ui_def_id AND page_id = p_page_id;
    RETURN l_name;
  END get_page_name;

  PROCEDURE handle_page_include_regions
  IS
    l_ui_def_map             number_tbl_type;
    l_ui_def_id              NUMBER;
    l_pagebase_expl_id       NUMBER;
    l_xmldoc                 xmldom.DOMDocument;
    l_dom_node               xmldom.DOMNode;
    l_current_relative_path  VARCHAR2(32000);
    l_new_relative_path      VARCHAR2(32000);
    l_flag                   INTEGER;
    l_resave_doc_flag        INTEGER;
    l_target_persistent_node_id  NUMBER;

    FUNCTION get_ui_name(p_ui_def_id IN NUMBER)
        RETURN VARCHAR2 IS
      l_name CZ_UI_DEFS.NAME%TYPE;
    BEGIN
      SELECT name INTO l_name
      FROM cz_ui_defs
      WHERE ui_def_id = p_ui_def_id;
      RETURN l_name;
    END;

    FUNCTION get_model_name(p_ui_def_id IN NUMBER)
        RETURN VARCHAR2 IS
      l_name CZ_DEVL_PROJECTS.NAME%TYPE;
    BEGIN
      SELECT name INTO l_name
      FROM cz_devl_projects
      WHERE devl_project_id = (SELECT devl_project_id FROM cz_ui_defs
                               WHERE ui_def_id = p_ui_def_id);
      RETURN l_name;
    END;

    PROCEDURE remove_target_page(p_ui_def_id IN NUMBER
                                ,p_page_id IN NUMBER
                                ,p_element_id IN VARCHAR2)
    IS
    BEGIN
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET target_page_ui_def_id = NULL, target_page_id = NULL
       WHERE ui_def_id = p_ui_def_id AND
             page_id = p_page_id AND element_id = p_element_id;

      UPDATE CZ_UI_PAGES
         SET page_rev_nbr = page_rev_nbr + 1
       WHERE ui_def_id = p_ui_def_id AND page_id = p_page_id;
    END remove_target_page;
    --vsingava IM-ER
    PROCEDURE handle_page_include_region(p_element CZ_UI_PAGE_ELEMENTS%ROWTYPE,
                                         p_base_persistent_node_Id NUMBER,
                                         p_base_expl_Id NUMBER)
    IS

      l_target_persistent_node_id NUMBER;
      l_name CZ_UI_PAGES.name%TYPE;
      l_page_Id CZ_UI_PAGES.page_Id%TYPE;
      l_ui_def_id NUMBER;
      l_instance_list_amn expl_node_persistent_id_pair;
      l_reachable BOOLEAN;
      l_base_expl_id NUMBER;
      l_base_persistent_node_id NUMBER;

    BEGIN
        DEBUG('Now processing PIR ' || p_element.NAME);
        --RETURN;
        DEBUG('After return Now processing PIR ' || p_element.NAME);
        l_target_persistent_node_id := NULL;
        l_base_expl_id := p_base_expl_Id;
        l_base_persistent_node_id := p_base_persistent_node_Id;

        BEGIN
          SELECT persistent_node_id, name, page_Id INTO l_target_persistent_node_id, l_name, l_page_Id
          FROM   cz_ui_pages
          WHERE  ui_def_id = p_element.target_page_ui_def_id AND
                 page_id = p_element.target_page_id AND deleted_flag <> '1';
        EXCEPTION
          -- target page not exist
          WHEN NO_DATA_FOUND THEN
            -- l_target_persistent_node_id := NULL;
            remove_target_page(p_element.ui_def_id, p_element.page_id, p_element.element_id);

            DEBUG('Removing PIR ' || p_element.NAME || ' because target page is deleted.');

            IF p_element.ui_Def_Id = g_ui_context.ui_def_Id THEN
              add_Error_Message(p_message_name => 'CZ_UIGEN_TARGET_PAGE_NOT_EXIST',
                                p_token_name1  => 'REGION_NAME',
                                p_token_value1 => NVL(p_element.NAME, p_element.element_id),
                                p_token_name2  => 'PAGE_NAME',
                                p_token_value2 => get_page_name(p_element.ui_def_id,p_element.page_id),
                                p_fatal_error  => FALSE);
              RETURN;
            ELSE
              add_Error_Message(p_message_name => 'CZ_UIGEN_DEL_PAGEINCL_TARGET',
                            p_token_name1  => 'PAGE_NAME',
                            p_token_value1 => NVL(l_name, l_page_id),
                            p_token_name2  => 'ELEMENT_NAME',
                            p_token_value2 => p_element.name,
                            p_token_name3  => 'REF_PAGE_NAME',
                            p_token_value3 => get_page_name(p_element.ui_def_id,p_element.page_id),
                            p_token_name4  => 'MODEL_NAME',
                            p_token_value4 => get_model_name(p_element.ui_def_id),
                            p_token_name5  => 'UI_NAME',
                            p_token_value5 => get_ui_name(p_element.ui_def_id),
                            p_fatal_error  => FALSE);
              RETURN;
            END IF;
        END;

        -- target page exists. is it reachable ?
        IF l_target_persistent_node_id IS NOT NULL THEN

          IF p_element.persistent_node_id = l_target_persistent_node_id THEN
            l_ui_def_id := p_element.target_page_ui_def_id;
          ELSE
            l_ui_def_id := p_element.ui_def_id; -- AMN is the root node of child model
          END IF;

          IF NOT target_page_reachable(p_base_expl_Id,
                                       p_element.model_ref_expl_id,
                                       p_element.persistent_node_id,
                                       l_ui_def_id) THEN
            DEBUG('PIR ' || p_element.NAME || ' not reachable from page base');
            l_reachable := FALSE;
            l_dom_node := find_XML_Node_By_Attribute(l_xmldoc, G_ID_ATTRIBUTE, p_element.element_id);

            DEBUG('before l_base_expl_id= ' || l_base_expl_id);
            DEBUG('before l_base_persistent_node_id= ' || l_base_persistent_node_id);

            l_instance_list_amn := getEnclosingInstanceListAMN(p_element, l_dom_node);



            IF l_instance_list_amn.persistent_node_Id IS NOT NULL THEN
              DEBUG('PIR ' || p_element.NAME || ' enclosed in an Instance List');

              l_base_expl_id := l_instance_list_amn.expl_node_id;
              l_base_persistent_node_id := l_instance_list_amn.persistent_node_id;

              DEBUG('after l_base_expl_id= ' || l_base_expl_id);
              DEBUG('after l_base_persistent_node_id= ' || l_base_persistent_node_id);

              DEBUG('Enclosing Instance List AMN = (' || l_base_expl_id || ', ' || l_base_persistent_node_id || ')');

              -- The PIR is under and Instance list region. So the PIR could still be reachable
              IF target_page_reachable(l_base_expl_id,
                                       p_element.model_ref_expl_id,
                                       p_element.persistent_node_id,
                                       l_ui_def_id) THEN
                DEBUG('PIR ' || p_element.NAME || ' reachable from instance list AMN');
                l_reachable := TRUE;
              END IF;
            END IF;

            IF NOT l_reachable THEN
              DEBUG('Removing PIR ' || p_element.NAME || ' because target page is not reachable.');
              remove_target_page(p_element.ui_def_id, p_element.page_id, p_element.element_id);


              IF p_element.ui_Def_Id = g_ui_context.ui_def_Id THEN

                add_Error_Message(p_message_name => 'CZ_UIGEN_TARGET_PAGE_REACH',
                                  p_token_name1  => 'REGION_NAME',
                                  p_token_value1 => NVL(p_element.NAME, p_element.element_id),
                                  p_token_name2  => 'PAGE_NAME',
                                  p_token_value2 => get_page_name(p_element.ui_def_id,p_element.page_id),
                                  p_fatal_error  => FALSE);
                RETURN;
              ELSE
                add_Error_Message(p_message_name => 'CZ_UIGEN_REFUI_TARGET_PG_REACH',
                                p_token_name1  => 'PAGE_NAME',  -- name of the target page
                                p_token_value1 => NVL(l_name, l_page_id),
                                p_token_name2  => 'ELEMENT_NAME',  -- name of the PIR element
                                p_token_value2 => p_element.name,
                                p_token_name3  => 'REF_PAGE_NAME', -- page that contains the PIR
                                p_token_value3 => get_page_name(p_element.ui_def_id, p_element.page_id),
                                p_token_name4  => 'UI_NAME',
                                p_token_value4 => get_ui_name(p_element.ui_def_id),
                                p_token_name5  => 'MODEL_NAME',
                                p_token_value5 => get_model_name(p_element.ui_def_id),
                                p_fatal_error  => FALSE);
                RETURN;
              END IF;
            END IF; -- not reachable
          END IF;
        END IF;

        l_dom_node := find_XML_Node_By_Attribute(l_xmldoc, G_ID_ATTRIBUTE, p_element.element_id);

        l_current_relative_path := get_attribute_value(l_dom_node, G_USER_ATTRIBUTE1_NAME);
        DEBUG('Current Relative path=' || l_current_relative_path);
        DEBUG('l_base_expl_id= ' || l_base_expl_id);
        DEBUG('l_base_persistent_node_id= ' || l_base_persistent_node_id);
        DEBUG('p_element.model_ref_expl_id= ' || p_element.model_ref_expl_id);
        DEBUG('p_element.persistent_node_id= ' || p_element.persistent_node_id);

        l_new_relative_path := 'model_path=' || CZ_DEVELOPER_UTILS_PVT.runtime_relative_path
                 (l_base_expl_id,
                  l_base_persistent_node_id,
                  p_element.model_ref_expl_id,
                  p_element.persistent_node_id);
        DEBUG('New Relative path=' || l_new_relative_path);
        IF l_current_relative_path <> l_new_relative_path THEN
          IF l_ui_def_id = g_UI_Context.ui_def_id THEN
            set_attribute(l_dom_node,
                          G_USER_ATTRIBUTE1_NAME,
                          l_new_relative_path);
            l_resave_doc_flag := 1; -- save doc
          ELSE
            UPDATE cz_ui_defs
            SET ui_status = 'NEED_REFRESH'
            WHERE ui_def_id = l_ui_def_id;
            l_flag := 0; -- goto next ui
          END IF;
        END IF;

    END handle_page_include_region;

  BEGIN


    l_ui_def_map(g_UI_Context.ui_def_id) := g_UI_Context.ui_def_id;

    --
    -- Find all Page Include Regions which point to UI pages in the current UI
    --
    FOR i IN (SELECT a.deleted_flag AS page_deleted_flag, a.page_id AS page_id,
                     a.name AS name, a.persistent_node_id AS target_persistent_node_id,
                     b.ui_def_id AS ref_ui_def_id, b.page_id AS ref_page_id,
                     b.name AS ref_element_name, b.element_id AS ref_element_id,
                     b.persistent_node_id as persistent_node_id,
                     b.model_ref_expl_id as expl_node_id
              FROM CZ_UI_PAGES a, CZ_UI_PAGE_ELEMENTS b
              WHERE a.ui_def_id = g_UI_Context.ui_def_id AND
                    b.element_signature_id = G_PAGE_INCL_REGION_SIGNATURE AND
                    b.deleted_flag = G_NO_FLAG AND
                    a.ui_def_id = b.target_page_ui_def_id AND
                    a.page_id = b.target_page_id)
    LOOP
      l_ui_def_map(i.ref_ui_def_id) := i.ref_ui_def_id;
    END LOOP;

    -- Recalculate relative paths for Page Include Regions. If the newly calculated path
    -- of a PIR element is different from the current one in xml doc, update the path
    -- in xml doc if the UI is the one in processing, mark the UI as must be refreshed
    -- if it is not the UI in refreshing.
    l_ui_def_id := l_ui_def_map.FIRST;
    WHILE l_ui_def_id IS NOT NULL
    LOOP
      l_flag := 1;
      FOR i IN (SELECT page_id, jrad_doc, pagebase_expl_node_id, persistent_node_id
                FROM CZ_UI_PAGES pg
                WHERE ui_def_id = l_ui_def_id AND deleted_flag = '0'
                AND   EXISTS (SELECT NULL FROM CZ_UI_PAGE_ELEMENTS
                              WHERE ui_def_id = pg.ui_def_id AND page_id = pg.page_id AND
                                    element_signature_id = G_PAGE_INCL_REGION_SIGNATURE AND
                                    target_page_ui_def_id IS NOT NULL AND
                                    target_page_id IS NOT NULL AND deleted_flag='0'))
      LOOP
        EXIT WHEN l_flag = 0;
        l_xmldoc := parse_JRAD_Document(i.jrad_doc);
        l_resave_doc_flag := 0;

        FOR j IN (SELECT * FROM CZ_UI_PAGE_ELEMENTS
                  WHERE ui_def_id = l_ui_def_id AND page_id = i.page_id AND
                        element_signature_id = G_PAGE_INCL_REGION_SIGNATURE AND
                        deleted_flag='0')
        LOOP
          EXIT WHEN l_flag <> 1;
          handle_page_include_region(j, i.persistent_node_id, i.pagebase_expl_node_id);
        END LOOP;

        IF l_resave_doc_flag = 1 THEN
          UPDATE CZ_UI_PAGES
          SET page_rev_nbr = page_rev_nbr + 1
          WHERE ui_def_id = l_ui_def_id AND page_id = i.page_id;

          save_document(l_xmldoc, i.jrad_doc);
        END IF;
      END LOOP;

      l_ui_def_id := l_ui_def_map.NEXT(l_ui_def_id);
    END LOOP;
  END handle_page_include_regions;

  --
  -- main internal procedure to create/refresh UI
  --
  PROCEDURE construct_Single_UI(p_ui_def_id     IN NUMBER,
                                p_handling_mode IN VARCHAR2 DEFAULT NULL) IS
    l_locked_entities_tbl cz_security_pvt.number_type_tbl;
    l_templates_id_tbl    number_tbl_type;
  BEGIN

    --
    -- set current UI context
    --
    set_UI_Context(p_ui_def_id);

    --
    -- lock global UI Templates which are used by inline copy
    --
    lock_UI_Templates(p_model_id          => g_UI_Context.devl_project_id,
                      p_ui_def_id         => g_UI_Context.from_master_template_id);

    IF p_handling_mode IS NULL OR p_handling_mode = G_CREATE_ONLY_UI_STRUCTURE THEN

      set_UI_Global_Entities();

      IF NVL(g_UI_Context.suppress_refresh_flag,G_NO_FLAG)=G_NO_FLAG THEN

        -- populate cache
        populate_Cache;

    -- update the UI_TIMESTAMP_REFRESH date on the UI
    UPDATE cz_ui_defs
    SET UI_TIMESTAMP_REFRESH = SYSDATE
    WHERE ui_def_id = p_ui_def_id;

        -- populate CZ UI structures first
        populate_UI_Structures();

      END IF;

    END IF;

    IF p_handling_mode IS NULL OR p_handling_mode = G_CREATE_ONLY_UI_XML THEN
      --
      -- generate/refresh UI Pages of current UI
      --
      handle_JRAD_Pages();
    END IF;

    unlock_UI_Templates();

    --
    -- mark UI as processed
    --
    mark_UI(p_ui_def_id, G_PROCESSED_UI_STATUS);

    EXCEPTION
      WHEN OTHERS THEN
        DEBUG(SQLERRM);
        --
        -- unlock global UI Templates which are used by inline copy
        --
        unlock_UI_Templates();
        RAISE;
  END construct_Single_UI;

  --
  -- internal procedure to create/refresh UI
  --
  PROCEDURE handle_UIs(p_ui_def_id     IN NUMBER,
                       p_handling_mode IN VARCHAR2 DEFAULT NULL) IS
    l_target_ui_def_node     CZ_UI_DEFS%ROWTYPE;
    l_ui_def_id              NUMBER;
    l_ref_persistent_node_id NUMBER;
    l_init_ui_def_id         NUMBER;
  BEGIN

    DEBUG('construct Single UI : ',p_ui_def_id);

    --
    -- handle root UI
    --
    construct_Single_UI(p_ui_def_id, p_handling_mode);

    validate_UI_Conditions(p_ui_def_id      => p_ui_def_id,
                           p_is_parser_open => G_YES_FLAG);

    IF NVL(g_UI_Context.suppress_refresh_flag,G_NO_FLAG)=G_YES_FLAG
       OR NVL(g_UI_Context.empty_ui_flag,G_NO_FLAG)=G_YES_FLAG THEN

      FOR i IN(SELECT * FROM CZ_MODEL_REF_EXPLS
               WHERE model_id=g_UI_Context.devl_project_id AND
                     ps_node_type=G_REFERENCE_TYPE AND deleted_flag='0')
      LOOP
        BEGIN
          SELECT NVL(MAX(ui_def_id),0) INTO l_ui_def_id
            FROM CZ_UI_DEFS
           WHERE devl_project_id=i.component_id AND
                 ui_style=G_OA_STYLE_UI AND
                 deleted_flag='0';

          IF l_ui_def_id=0 THEN
            l_init_ui_def_id := g_UI_Context.ui_def_id;
            l_target_ui_def_node := create_UI_Context(p_model_id           => i.component_id,
                                                      p_master_template_id => g_UI_Context.from_master_template_id,
                                                      p_show_all_nodes     => g_UI_Context.show_all_nodes_flag,
                                                      p_create_empty_ui    => '1');
            l_ui_def_id := l_target_ui_def_node.ui_def_id;
            set_UI_Context(l_init_ui_def_id);
          END IF;

          SELECT persistent_node_id INTO l_ref_persistent_node_id
            FROM CZ_PS_NODES
           WHERE devl_project_id=g_UI_Context.devl_project_id AND
                 ps_node_id=i.referring_node_id AND
                 deleted_flag=G_NO_FLAG;

          BEGIN
            INSERT INTO CZ_UI_REFS
             (ui_def_id,
              ref_ui_def_id,
              ref_persistent_node_id,
              model_ref_expl_id,
              deleted_flag)
             VALUES
             (g_UI_Context.ui_def_id,
              l_ui_def_id,
              l_ref_persistent_node_id,
              i.model_ref_expl_id,
              G_NO_FLAG);
          EXCEPTION
            WHEN OTHERS THEN
                NULL;
          END;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;

    END IF;

    --
    -- table CZ_UI_REFS is populated in procedure construct_Single_UI()
    -- ( in this approach UI can have a more referenced UIs than Model Tree )
    --
    FOR i IN (SELECT DISTINCT ref_ui_def_id
                FROM CZ_UI_REFS
               WHERE ui_def_id = p_ui_def_id AND
                     deleted_flag = G_NO_FLAG)
    LOOP
      --
      -- construct UIs of referenced models
      --
      handle_UIs(i.ref_ui_def_id, p_handling_mode);
    END LOOP;

  END handle_UIs;

  --
  -- main internal procedure to create/refresh UI
  -- this procedure is invoked only once during UI Generation/UI Refresh
  --
  PROCEDURE construct_UI(p_ui_def_id     IN NUMBER,
                         p_handling_mode IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --
    -- initialize XML parser
    --
    OPEN_Parser();
    --
    -- handle root UI and all referenced UIs
    --
    handle_UIs(p_ui_def_id, p_handling_mode);
    --
    -- close XML parser
    --
    CLOSE_Parser();

    set_UI_Context(p_ui_def_id);

    OPEN_Parser();
    handle_page_include_regions;
    CLOSE_Parser();
  END construct_UI;

  --
  -- create a new UI for a given model
  -- Parameters :
  --   p_model_id           - identifies Model
  --   p_master_template_id - identifies UI Master Template
  --   px_ui_def_id         - Id of a new UI
  --   x_return_status      - status string
  --   x_msg_count          - number of error messages
  --   x_msg_data           - string which contains error messages
  --
  PROCEDURE create_UI(p_model_id           IN NUMBER, -- identifies Model
                      p_master_template_id IN NUMBER DEFAULT NULL, -- identifies UI Master Template
                      p_ui_name            IN VARCHAR2 DEFAULT NULL,
                      p_description        IN VARCHAR2 DEFAULT NULL,
                      p_show_all_nodes     IN VARCHAR2 DEFAULT NULL,
                      p_create_empty_ui    IN VARCHAR2 DEFAULT NULL,
                      x_ui_def_id          OUT NOCOPY NUMBER, -- Id of a new UI
                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_msg_count          OUT NOCOPY NUMBER,
                      x_msg_data           OUT NOCOPY VARCHAR2) IS

    l_ui_context CZ_UI_DEFS%ROWTYPE;
    l_locked_models      cz_security_pvt.number_type_tbl;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- get UI context
    -- ( * also function get_UI_Context() inserts data for new UI into CZ_UI_DEFS table )
    --
    l_ui_context := create_UI_Context(p_model_id           => p_model_id,
                                      p_master_template_id => p_master_template_id,
                                      p_ui_name            => p_ui_name,
                                      p_description        => p_description,
                                      p_show_all_nodes     => p_show_all_nodes,
                                      p_create_empty_ui    => p_create_empty_ui);
    --
    -- set ui_def_id of root UI ( UI that is generated for model with model_id=p_model_id )
    --
    x_ui_def_id := l_ui_context.ui_def_id;

    lock_Model(p_model_id, l_locked_models);

    --
    -- generate a new UI for the current UI context
    --
    construct_UI(l_ui_context.ui_def_id);

    IF p_create_empty_ui IS NOT NULL AND p_create_empty_ui = '1' THEN

      UPDATE CZ_UI_DEFS
      SET suppress_refresh_flag = G_NO_FLAG
      WHERE ui_def_id = x_ui_def_id and deleted_flag = G_NO_FLAG;

      UPDATE CZ_UI_DEFS
      SET suppress_refresh_flag = G_NO_FLAG
      WHERE ui_def_Id IN (
         SELECT ref_ui_def_Id
         FROM CZ_UI_REFS
         START WITH ui_def_id = x_ui_def_id
         AND deleted_flag = G_NO_FLAG
         CONNECT BY PRIOR ref_ui_def_id = ui_def_id AND deleted_flag = G_NO_FLAG)
      AND deleted_flag = G_NO_FLAG;
    END IF;

    IF g_MSG_COUNT>0 THEN
      x_return_status := G_RETURN_STATUS;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
    END IF;

    unlock_model(l_locked_models);

  EXCEPTION
    WHEN FAILED_TO_LOCK_MODEL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN WRONG_EXT_PS_TYPE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     :=  1;
      x_msg_data      :=  'Internal Error : extended ps node type of node with ps_node_id='||
                          TO_CHAR(g_WRONG_PS_NODE_ID)||' is not defined.';
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'create_UI', x_msg_data);
      DEBUG(x_msg_data);
    WHEN UNREACH_UI_NODE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := g_MSG_COUNT;
      IF g_MSG_COUNT>0 THEN
         x_msg_count := g_MSG_COUNT;
         x_msg_data  := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      ELSE
         x_msg_count := 1;
         x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      END IF;
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'create_UI', x_msg_data);
      DEBUG(x_msg_data);
  END create_UI;

  --
  -- refresh a given UI
  -- Parameters :
  --   p_ui_def_id          - identifies UI
  --   x_return_status      - status string
  --   x_msg_count          - number of error messages
  --   x_msg_data           - string which contains error messages
  --
  PROCEDURE refresh_UI(p_ui_def_id     IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
                       x_msg_data      OUT NOCOPY VARCHAR2) IS

    l_ui_context CZ_UI_DEFS%ROWTYPE;
  BEGIN
    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- get UI context
    --
    l_ui_context := get_UI_Context(p_ui_def_id => p_ui_def_id);

    --
    -- if p_create_empty_ui = G_NO_FLAG ( ='1') then do generate/refresh UI
    --
    IF NVL(l_ui_context.suppress_refresh_flag,G_NO_FLAG) = G_NO_FLAG THEN

      -- refresh model_path for all nodes on refreshed UI page
      g_REFRESH_MODEL_PATH := TRUE;

      --
      -- refresh UI
      --
      construct_UI(p_ui_def_id);
    END IF;

    IF g_MSG_COUNT>0 THEN
      x_return_status := G_RETURN_STATUS;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
    END IF;

  EXCEPTION
    WHEN FAILED_TO_LOCK_MODEL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN WRONG_UI_TO_REFRESH THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Internal Error : Wrong UI to refresh.';
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'refresh_UI', x_msg_data);
      DEBUG(x_msg_data);
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN WRONG_EXT_PS_TYPE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     :=  1;
      x_msg_data      :=  'Internal Error : extended ps node type of node with ps_node_id='||
                          TO_CHAR(g_WRONG_PS_NODE_ID)||' is not defined.';
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'create_UI', x_msg_data);
      DEBUG(x_msg_data);
    WHEN UNREACH_UI_NODE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := g_MSG_COUNT;
      IF g_MSG_COUNT>0 THEN
         x_msg_count := g_MSG_COUNT;
         x_msg_data  := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      ELSE
         x_msg_count := 1;
         x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      END IF;
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'refresh_UI', x_msg_data);
      DEBUG(x_msg_data);
  END refresh_UI;

  --
  -- delete records which correspond with user attributes
  --
  PROCEDURE delete_User_Attr_For_Node(p_xml_node           xmldom.DOMNode,
                                      p_ui_def_id          NUMBER,
                                      p_template_id        NUMBER DEFAULT NULL,
                                      p_template_ui_def_id NUMBER DEFAULT NULL) IS

    l_user_attribute_value VARCHAR2(4000);
    l_persistent_id        NUMBER;

  BEGIN

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);
      IF l_user_attribute_value IS NOT NULL THEN

        l_persistent_id := TO_NUMBER(get_User_Attribute(l_user_attribute_value,'actionId'));
        IF l_persistent_id IS NOT NULL THEN
          UPDATE CZ_UI_ACTIONS
             SET deleted_flag=G_YES_FLAG
           WHERE ui_def_id=p_ui_def_id AND
                 ui_action_id=l_persistent_id AND
                 seeded_flag=G_NO_FLAG;

            IF p_template_id IS NOT NULL THEN
              UPDATE CZ_UI_TEMPLATE_ELEMENTS
                 SET deleted_flag=G_YES_FLAG
               WHERE template_id=p_template_id AND
                     ui_def_id=p_template_ui_def_id AND
                     element_id=l_persistent_id AND
                     element_type IN(552) AND
                     seeded_flag=G_NO_FLAG AND
                     deleted_flag=G_NO_FLAG;
            END IF;
        END IF;

        FOR i IN g_condition_attr_tbl.First..g_condition_attr_tbl.Last
        LOOP
          l_persistent_id := TO_NUMBER(get_User_Attribute(l_user_attribute_value,g_condition_attr_tbl(i)));
          IF l_persistent_id IS NOT NULL THEN
            UPDATE CZ_RULES
               SET deleted_flag = G_YES_FLAG
             WHERE persistent_rule_id = l_persistent_id
               AND ui_def_id = p_ui_def_id
               AND seeded_flag = G_NO_FLAG;

            IF p_template_id IS NOT NULL THEN
              UPDATE CZ_UI_TEMPLATE_ELEMENTS
                 SET deleted_flag=G_YES_FLAG
               WHERE template_id=p_template_id AND
                     ui_def_id=p_template_ui_def_id AND
                     element_id=l_persistent_id AND
                     element_type IN(33,34) AND
                     seeded_flag=G_NO_FLAG AND
                     deleted_flag=G_NO_FLAG;
            END IF;
          END IF;
        END LOOP;

        FOR i IN g_caption_attr_tbl.First..g_caption_attr_tbl.Last
        LOOP
          l_persistent_id := TO_NUMBER(get_User_Attribute(l_user_attribute_value,g_caption_attr_tbl(i)));
          IF l_persistent_id IS NOT NULL THEN
            UPDATE CZ_LOCALIZED_TEXTS
               SET deleted_flag=G_YES_FLAG
             WHERE persistent_intl_text_id=l_persistent_id AND
                   ui_def_id=p_ui_def_id AND
                   seeded_flag=G_NO_FLAG;

            IF p_template_id IS NOT NULL THEN
              UPDATE CZ_UI_TEMPLATE_ELEMENTS
                 SET deleted_flag=G_YES_FLAG
               WHERE template_id=p_template_id AND
                     ui_def_id=p_template_ui_def_id AND
                     element_id=l_persistent_id AND
                     element_type IN(8) AND
                     seeded_flag=G_NO_FLAG AND
                     deleted_flag=G_NO_FLAG;
            END IF;
          END IF;
        END LOOP;

      END IF;
  END delete_User_Attr_For_Node;

  PROCEDURE copy_User_Attr_For_Node(p_xml_node               xmldom.DOMNode,
                                    p_source_ui_def_id       NUMBER,
                                    p_target_ui_def_id       NUMBER,
                                    p_source_ui_page_id      NUMBER,
                                    p_target_ui_page_id      NUMBER,
                                    p_target_model_path      VARCHAR2,
                                    p_new_element_id_arr_tbl IN OUT NOCOPY number_tbl_type) IS

    l_user_attribute_value VARCHAR2(4000);
    l_new_element_id       VARCHAR2(255);
    l_target_model_path    VARCHAR2(4000);
    l_name                 VARCHAR2(4000);
    l_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_model_ref_expl_id    NUMBER;
    l_num_copy             NUMBER;
    l_id                   NUMBER;

  BEGIN

      set_UI_Context(p_target_ui_def_id);

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_ID_ATTRIBUTE);

      IF l_user_attribute_value IS NOT NULL THEN
        BEGIN
          l_id := TO_NUMBER(l_user_attribute_value);

          l_new_element_id := p_new_element_id_arr_tbl(l_id);

          set_Attribute(p_xml_node,
                        G_ID_ATTRIBUTE,
                        l_new_element_id);

          g_handled_attr_id_tbl(l_new_element_id) := l_id;

        EXCEPTION
          WHEN OTHERS THEN
            DEBUG('copy_User_Attr_For_Node() : '||SQLERRM);
            IF NOT(g_handled_attr_id_tbl.EXISTS(l_id)) THEN
              set_Attribute(p_xml_node,
                            G_ID_ATTRIBUTE,
                            l_user_attribute_value||'_'||get_Element_Id());
            END IF;
        END;

      END IF;

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE1_NAME);

      IF l_user_attribute_value IS NOT NULL AND l_new_element_id IS NOT NULL THEN

        SELECT * INTO l_ui_node FROM CZ_UI_PAGE_ELEMENTS
         WHERE ui_def_id=p_target_ui_def_id AND
               page_id=p_target_ui_page_id AND
               element_id=l_new_element_id;
        SELECT model_ref_expl_id INTO l_model_ref_expl_id FROM CZ_UI_PAGE_ELEMENTS
        WHERE ui_def_id=l_ui_node.ui_def_id AND page_id=l_ui_node.page_id AND
             parent_element_id IS NULL AND deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);
       l_target_model_path := CZ_DEVELOPER_UTILS_PVT.runtime_relative_path(p_base_expl_id => l_model_ref_expl_id,
                                                     p_base_pers_id => l_ui_node.pagebase_persistent_node_id,
                                                     p_node_expl_id => l_ui_node.model_ref_expl_id,
                                                     p_node_pers_id => l_ui_node.persistent_node_id);
        IF l_target_model_path IS NULL THEN
           l_target_model_path := '.';
        END IF;

        set_Attribute(p_xml_node,
                      G_USER_ATTRIBUTE1_NAME,
                      'model_path='||l_target_model_path);

      END IF;

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);

      IF l_user_attribute_value IS NOT NULL AND l_new_element_id IS NOT NULL  THEN

        handle_User_Attributes
        (px_user_attribute_value => l_user_attribute_value,
         p_source_ui_def_id      => p_source_ui_def_id,
         p_source_ui_page_id     => p_source_ui_page_id,
         p_target_ui_def_id      => p_target_ui_def_id,
         p_target_ui_page_id     => p_target_ui_page_id,
         p_new_element_id        => l_new_element_id,
         p_xml_node              => p_xml_node);

         set_Attribute(p_xml_node,
                       G_USER_ATTRIBUTE3_NAME,
                       l_user_attribute_value);
     END IF;

     l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE4_NAME);

     IF l_user_attribute_value IS NOT NULL THEN

       l_name := get_User_Attribute(l_user_attribute_value ,'name');

       SELECT COUNT(*)+1 INTO l_num_copy FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=p_target_ui_def_id AND page_id=p_target_ui_page_id AND
             name like l_name||'%' AND deleted_flag=G_NO_FLAG;

       l_name := l_name||' ('||TO_CHAR(l_num_copy)||')';

       set_User_Attribute(p_cz_attribute_name    => 'name',
                          p_cz_attribute_value   => l_name,
                          px_xml_attribute_value => l_user_attribute_value);

       set_Attribute(p_xml_node,
                     G_USER_ATTRIBUTE4_NAME,
                     l_user_attribute_value);
     END IF;

     IF l_new_element_id IS NOT NULL THEN
       UPDATE CZ_UI_PAGE_ELEMENTS
          SET name=l_name
        WHERE ui_def_id=p_target_ui_def_id AND page_id=p_target_ui_page_id AND
              element_id = l_new_element_id;
     END IF;

  END copy_User_Attr_For_Node;

  --
  -- copy records which correspond to user attributes
  --
  PROCEDURE copy_User_Attr_For_Node(p_xml_node               xmldom.DOMNode,
                                    p_source_ui_def_id       NUMBER,
                                    p_target_ui_def_id       NUMBER,
                                    p_source_template_id     NUMBER DEFAULT NULL,
                                    p_target_template_id     NUMBER DEFAULT NULL) IS

    l_user_attribute_value VARCHAR2(4000);
    l_new_element_id       VARCHAR2(255);
    l_id                   NUMBER;
    l_name                 VARCHAR2(4000);
    l_num_copy             NUMBER;

  BEGIN

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_ID_ATTRIBUTE);

      IF l_user_attribute_value IS NOT NULL THEN

         l_new_element_id := '_czc'||get_Element_Id(); -- fix for bug #3975276
         set_Attribute(p_xml_node,
                       G_ID_ATTRIBUTE,
                       l_new_element_id);

      END IF;

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);

      IF l_user_attribute_value IS NOT NULL THEN
        handle_User_Attributes
        (px_user_attribute_value => l_user_attribute_value,
         p_source_ui_def_id      => p_source_ui_def_id,
         p_source_ui_page_id     => 0,  -- fix for bug #3975276
         p_target_ui_def_id      => p_target_ui_def_id,
         p_target_ui_page_id     => 0,  -- fix for bug #3975276
         p_new_element_id        => l_new_element_id,
         p_source_template_id    => p_source_template_id,
         p_target_template_id    => p_target_template_id,
         p_xml_node              => p_xml_node);

         set_Attribute(p_xml_node,
                       G_USER_ATTRIBUTE3_NAME,
                       l_user_attribute_value);
      END IF;

     l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE4_NAME);

     IF l_user_attribute_value IS NOT NULL THEN

       l_name := get_User_Attribute(l_user_attribute_value ,'name');

       IF l_new_element_id IS NOT NULL THEN
         l_name := l_name||' - '||l_new_element_id;
       END IF;

       set_User_Attribute(p_cz_attribute_name    => 'name',
                          p_cz_attribute_value   => l_name,
                          px_xml_attribute_value => l_user_attribute_value);

       set_Attribute(p_xml_node,
                     G_USER_ATTRIBUTE4_NAME,
                     l_user_attribute_value);
     END IF;

  END copy_User_Attr_For_Node;

  --
  -- delete records which corresponds with user attributes
  --
  PROCEDURE delete_User_Attributes(p_xml_node  xmldom.DOMNode,
                                   p_ui_def_id NUMBER,
                                   p_template_id        NUMBER DEFAULT NULL,
                                   p_template_ui_def_id NUMBER DEFAULT NULL) IS


    l_child_nodes_tbl xmldom.DOMNodeList;
    l_child_xml_node  xmldom.DOMNode;
    l_length          NUMBER;

  BEGIN

    IF xmldom.IsNull(p_xml_node) THEN
      RETURN;
    END IF;

    delete_User_Attr_For_Node(p_xml_node,p_ui_def_id,
                              p_template_id, p_template_ui_def_id);

    l_child_nodes_tbl := xmldom.getChildNodes(p_xml_node);
    l_length          := xmldom.getLength(l_child_nodes_tbl);

    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      delete_User_Attr_For_Node(l_child_xml_node,p_ui_def_id,
                                p_template_id, p_template_ui_def_id);

      delete_User_Attributes(l_child_xml_node,p_ui_def_id,
                             p_template_id, p_template_ui_def_id);

    END LOOP;

  END delete_User_Attributes;

  --
  -- copy records which corresponds with user attributes
  --
  PROCEDURE copy_User_Attributes(p_xml_node               xmldom.DOMNode,
                                 p_source_ui_def_id       NUMBER,
                                 p_target_ui_def_id       NUMBER,
                                 p_source_ui_page_id      NUMBER,
                                 p_target_ui_page_id      NUMBER,
                                 p_target_model_path      VARCHAR2,
                                 p_new_element_id_arr_tbl IN OUT NOCOPY number_tbl_type) IS

    l_child_nodes_tbl xmldom.DOMNodeList;
    l_child_xml_node  xmldom.DOMNode;
    l_length          NUMBER;

  BEGIN

     copy_User_Attr_For_Node(p_xml_node          => p_xml_node,
                            p_source_ui_def_id  => p_source_ui_def_id,
                            p_target_ui_def_id  => p_target_ui_def_id,
                            p_source_ui_page_id => p_source_ui_page_id,
                            p_target_ui_page_id => p_target_ui_page_id,
                            p_target_model_path => p_target_model_path,
                            p_new_element_id_arr_tbl => p_new_element_id_arr_tbl);

    l_child_nodes_tbl := xmldom.getChildNodes(p_xml_node);
    l_length          := xmldom.getLength(l_child_nodes_tbl);

    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      copy_User_Attr_For_Node(p_xml_node          => l_child_xml_node,
                              p_source_ui_def_id  => p_source_ui_def_id,
                              p_target_ui_def_id  => p_target_ui_def_id,
                              p_source_ui_page_id => p_source_ui_page_id,
                              p_target_ui_page_id => p_target_ui_page_id,
                              p_target_model_path => p_target_model_path,
                              p_new_element_id_arr_tbl => p_new_element_id_arr_tbl);

      copy_User_Attributes(p_xml_node          => l_child_xml_node,
                           p_source_ui_def_id  => p_source_ui_def_id,
                           p_target_ui_def_id  => p_target_ui_def_id,
                           p_source_ui_page_id => p_source_ui_page_id,
                           p_target_ui_page_id => p_target_ui_page_id,
                           p_target_model_path => p_target_model_path,
                           p_new_element_id_arr_tbl => p_new_element_id_arr_tbl);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      DEBUG('copy_User_Attributes() : '||SQLERRM);

  END copy_User_Attributes;

 PROCEDURE validate_Copied_PIR(p_ui_def_id IN NUMBER, p_page_id IN NUMBER) IS
    TYPE number_tbl_type        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_element_id_tbl            varchar_tbl_type;
    l_name_tbl                  varchar_tbl_type;
    l_target_page_ui_def_id_tbl number_tbl_type;
    l_target_page_id_tbl        number_tbl_type;
    l_ui_name                   CZ_UI_DEFS.name%TYPE;
    l_page_name                 CZ_UI_PAGES.name%TYPE;
    l_pagebase_expl_id          NUMBER;
    l_ui_def_id                 NUMBER;
    l_target_persistent_node_id NUMBER;

  BEGIN

    UPDATE CZ_UI_PAGE_ELEMENTS
       SET target_page_ui_def_id=NULL,
           target_page_id=NULL
     WHERE ui_def_id=p_ui_def_id AND
           page_id=p_page_id AND
           element_signature_id = G_PAGE_INCL_REGION_SIGNATURE AND
           deleted_flag='0' AND target_page_ui_def_id IS NOT NULL AND
           target_page_id IS NOT NULL AND
           target_page_ui_def_id NOT IN (SELECT ref_ui_def_id FROM CZ_UI_REFS WHERE ui_def_id=p_ui_def_id AND
           deleted_flag='0')
    RETURNING element_id,name,target_page_id,target_page_ui_def_id
    BULK COLLECT INTO l_element_id_tbl,l_name_tbl,l_target_page_id_tbl,l_target_page_ui_def_id_tbl;

    IF l_name_tbl.COUNT>0 THEN
      FOR i IN l_name_tbl.First..l_name_tbl.Last
      LOOP
        SELECT name INTO l_page_name FROM CZ_UI_PAGES
        WHERE page_id=l_target_page_id_tbl(i) AND ui_def_id=l_target_page_ui_def_id_tbl(i);
        SELECT name INTO l_ui_name FROM CZ_UI_DEFS WHERE ui_def_id=l_target_page_ui_def_id_tbl(i);
        add_Error_Message(p_message_name => 'CZ_CP_PIR_REF_UI_NOT_IN_CHAIN',
                          p_token_name1  => 'RGNNAME',
	                  p_token_value1 => NVL(l_name_tbl(i), l_element_id_tbl(i)),
	                  p_token_name2  => 'PAGENAME',
                          p_token_value2 => l_page_name,
	                  p_token_name3  => 'UINAME',
                          p_token_value3 => l_ui_name,
                          p_fatal_error  => FALSE);
      END LOOP;
    END IF;

    --
    -- Find all Page Include Regions of current UI
    --
    FOR i IN (SELECT page_id, element_id, target_page_ui_def_id, target_page_id,
                     model_ref_expl_id, persistent_node_id, name
              FROM CZ_UI_PAGE_ELEMENTS
              WHERE ui_def_id = p_ui_def_id AND page_id=p_page_id AND
                    element_signature_id = G_PAGE_INCL_REGION_SIGNATURE AND
                    target_page_ui_def_id IS NOT NULL AND target_page_id IS NOT NULL AND
                    deleted_flag = '0')
    LOOP
      -- target page exists?
      l_target_persistent_node_id := NULL;
      BEGIN
        SELECT persistent_node_id INTO l_target_persistent_node_id
        FROM   cz_ui_pages
        WHERE  ui_def_id = i.target_page_ui_def_id AND
               page_id = i.target_page_id AND deleted_flag <> '1';
      EXCEPTION
        -- target page not exist
        WHEN NO_DATA_FOUND THEN
          -- l_target_persistent_node_id := NULL;
          UPDATE CZ_UI_PAGE_ELEMENTS
          SET    target_page_ui_def_id = NULL, target_page_id = NULL
          WHERE  ui_def_id = p_ui_def_id AND
                 page_id = i.page_id AND element_id = i.element_id;

          add_Error_Message(p_message_name => 'CZ_UIGEN_TARGET_PAGE_NOT_EXIST',
	                    p_token_name1  => 'REGION_NAME',
	                    p_token_value1 => NVL(i.NAME, i.element_id),
	                    p_token_name2  => 'PAGE_NAME',
	                    p_token_value2 => get_page_name(p_ui_def_id,i.page_id),
                            p_fatal_error  => FALSE);
      END;

      -- target page exists. check if reachable
      IF l_target_persistent_node_id IS NOT NULL THEN
        SELECT pagebase_expl_node_id INTO l_pagebase_expl_id
        FROM   cz_ui_pages
        WHERE  ui_def_id = p_ui_def_id AND
               page_id = i.page_id;

        IF i.persistent_node_id = l_target_persistent_node_id THEN
          l_ui_def_id := i.target_page_ui_def_id;
        ELSE
          l_ui_def_id := p_ui_def_id;
        END IF;

        IF NOT target_page_reachable(l_pagebase_expl_id,
                                     i.model_ref_expl_id,
                                     i.persistent_node_id,
                                     l_ui_def_id) THEN
          add_Error_Message(p_message_name => 'CZ_UIGEN_TARGET_PAGE_REACH',
	                    p_token_name1  => 'REGION_NAME',
	                    p_token_value1 => NVL(i.NAME, i.element_id),
	                    p_token_name2  => 'PAGE_NAME',
	                    p_token_value2 => get_page_name(p_ui_def_id,i.page_id),
                            p_fatal_error  => FALSE);
          UPDATE CZ_UI_PAGE_ELEMENTS
          SET    target_page_ui_def_id = NULL, target_page_id = NULL
          WHERE  ui_def_id = p_ui_def_id AND
                 page_id = i.page_id AND element_id = i.element_id;
        END IF;
      END IF;
    END LOOP;

  END validate_Copied_PIR;

  PROCEDURE copy_Tree_Level(p_xml_node                    xmldom.DOMNode,
                            p_source_ui_def_id            NUMBER,
                            p_target_ui_def_id            NUMBER,
                            p_source_ui_page_id           NUMBER,
                            p_target_ui_page_id           NUMBER,
                            p_parent_element_id           VARCHAR2,
                            p_target_parent_element_id    VARCHAR2,
                            p_pagebase_persistent_node_id NUMBER,
                            p_base_persistent_node_Id     NUMBER,
                            p_base_expl_node_id           NUMBER,
                            x_new_element_id              IN OUT NOCOPY VARCHAR2,
                            p_copy_as_ui_page             IN BOOLEAN,
                            p_source_jrad_doc             IN VARCHAR2,
                            p_target_jrad_doc             IN VARCHAR2,
                            p_amn_parent_element_id       IN VARCHAR2,
                            p_is_instance_list_child      IN BOOLEAN DEFAULT FALSE) IS

    l_child_nodes_tbl      xmldom.DOMNodeList;
    l_child_xml_node       xmldom.DOMNode;
    l_parent_xml_node      xmldom.DOMNode;
    l_ui_node              CZ_UI_PAGE_ELEMENTS%ROWTYPE;

    l_user_attribute_value  VARCHAR2(4000);
    l_user_attribute3_value VARCHAR2(4000);

    l_switcher_casename    VARCHAR2(255);

    l_target_model_path    VARCHAR2(255);
    l_current_element_id   VARCHAR2(255);
    l_amn_parent_element_id VARCHAR2(255);
    l_new_element_id       VARCHAR2(255);
    l_parent_element_id    VARCHAR2(255);
    l_name                 VARCHAR2(255);
    l_view_name            VARCHAR2(255);
    l_children_view_name   VARCHAR2(255);
    l_ancestor_node        VARCHAR2(255);
    l_hgrid_element_id     VARCHAR2(255);
    l_case_node_id         VARCHAR2(255);
    l_case_node_name       VARCHAR2(255);
    l_switcher_element_id  VARCHAR2(255);
    l_case_new_node_id     VARCHAR2(255);
    l_case_new_node_name   VARCHAR2(255);
    l_old_ui_switcher_id   VARCHAR2(255);
    l_layout_node_id       VARCHAR2(255);
    l_layout_node_name     VARCHAR2(255);
    l_layout_new_node_id   VARCHAR2(255);
    l_layout_new_node_name VARCHAR2(255);
    l_temp_str             VARCHAR2(255);
    l_instr_ind            NUMBER;
    l_view_counter         NUMBER;
    l_num_copy             NUMBER;
    l_ui_action_id         NUMBER;
    l_length               NUMBER;
    l_ind                  NUMBER;
    l_id                   NUMBER;
    l_temp_ind             NUMBER;
    l_ui_page_elements_exists BOOLEAN := FALSE;
    l_base_expl_node_id        NUMBER;
    l_base_persistent_node_id  NUMBER;
    l_amn_expl_node_id NUMBER;
    l_amn_persistent_node_id NUMBER;
    l_layout_region_type VARCHAR2(20);

  BEGIN

    l_base_expl_node_id        := p_base_expl_node_id;
    l_base_persistent_node_id  := p_base_persistent_node_Id;

    l_ancestor_node := get_Attribute_Value(p_xml_node,
                                           'ancestorNode');
    IF l_ancestor_node IS NOT NULL THEN

      l_hgrid_element_id := find_Element_Id_Of_XMLTag(p_xml_node, 'oa:tree');
      IF NOT(xmldom.IsNull(p_xml_node)) THEN
        l_ancestor_node := p_target_jrad_doc||'.'||l_hgrid_element_id;

        set_Attribute(p_xml_node,
                      'ancestorNode',
                      l_ancestor_node);
      END IF;
    END IF;

    IF xmldom.getNodeName(p_xml_node)='ui:case' THEN

      handle_UI_CASE_Id(p_xml_node);

      l_switcher_element_id := find_Element_Id_Of_XMLTag(p_xml_node, 'oa:switcher');

      l_case_node_id := get_Attribute_Value(p_xml_node,
                                            'name');


      l_instr_ind := 0;

      FOR i IN 1..LENGTH(l_case_node_id)
      LOOP
        IF SUBSTR(l_case_node_id,i,1)='_' THEN
          l_instr_ind := i;
        END IF;
      END LOOP;

      IF l_case_node_id IS NOT NULL THEN
        l_old_ui_switcher_id := SUBSTR(l_case_node_id,1,l_instr_ind-1);
        l_case_new_node_id := REPLACE(l_case_node_id,
          l_old_ui_switcher_id,
          l_switcher_element_id);
        set_Attribute(p_xml_node,
                      'name',
                      l_case_new_node_id);
      END IF;

    END IF;

    IF xmldom.getNodeName(p_xml_node)='oa:stackLayout' THEN

      l_parent_xml_node := xmldom.getParentNode(p_xml_node);

      IF NOT(xmldom.IsNull(l_parent_xml_node)) THEN

        IF xmldom.getNodeName(l_parent_xml_node)='ui:case' THEN

          l_layout_new_node_id := get_Attribute_Value(l_parent_xml_node,'name');
          set_Attribute(p_xml_node,
                        G_ID_ATTRIBUTE,
                        l_layout_new_node_id);

        END IF; -- end of IF xmldom.getNodeName(l_parent_xml_node)='ui:case'

      END IF; -- end of IF NOT(xmldom.IsNull(l_parent_xml_node))

    END IF;  -- end of IF xmldom.getNodeName(p_xml_node)='oa:stackLayout'

    IF l_layout_new_node_id IS NULL THEN
      l_current_element_id := get_Attribute_Value(p_xml_node,
                                                  G_ID_ATTRIBUTE);

      IF l_current_element_id IS NOT NULL THEN
        l_new_element_id := get_Element_Id();
      END IF;

    END IF;

    FOR i IN(SELECT parent_element_id FROM CZ_UI_PAGE_ELEMENTS
             WHERE ui_def_id=p_source_ui_def_id AND
                   page_id=p_source_ui_page_id AND
                   element_id=l_current_element_id)
    LOOP
      l_ui_page_elements_exists := TRUE;
      IF x_new_element_id IS NULL THEN
        x_new_element_id := l_new_element_id;
      END IF;
    END LOOP;

    l_amn_parent_element_id := p_amn_parent_element_id;
    IF  l_ui_page_elements_exists THEN
      l_parent_element_id := l_amn_parent_element_id;
      l_amn_parent_element_id := l_new_element_id;
    ELSIF p_parent_element_id IS NULL THEN
      l_parent_element_id := p_target_parent_element_id;
    ELSE
      l_parent_element_id := p_parent_element_id;
    END IF;

    IF l_ui_page_elements_exists THEN
        INSERT INTO CZ_UI_PAGE_ELEMENTS
        (ui_def_id,
         persistent_node_id,
         parent_persistent_node_id,
         region_persistent_node_id,
         pagebase_persistent_node_id,
         page_id,
         seq_nbr,
         ctrl_template_id,
         element_id,
         parent_element_id,
         element_type,
         instantiable_flag,
         ctrl_template_ui_def_id,
         model_ref_expl_id,
         element_signature_id,
         name,
         suppress_refresh_flag,
         deleted_flag,
         target_page_ui_def_id,
         target_page_id)
         SELECT
           p_target_ui_def_id,
         persistent_node_id,
         parent_persistent_node_id,
         region_persistent_node_id,
         p_pagebase_persistent_node_id,
         p_target_ui_page_id,
           seq_nbr,
         ctrl_template_id,
            l_new_element_id,
            l_parent_element_id,
         element_type,
         instantiable_flag,
         ctrl_template_ui_def_id,
         model_ref_expl_id,
         element_signature_id,
         name,
         suppress_refresh_flag,
         deleted_flag,
         target_page_ui_def_id,
         target_page_id
        FROM CZ_UI_PAGE_ELEMENTS
        WHERE ui_def_id=p_source_ui_def_id AND
              page_id=p_source_ui_page_id AND
              element_id=l_current_element_id;

        -- set JRAD Id of current XML node to new value
        set_Attribute(p_xml_node,
                      G_ID_ATTRIBUTE,
                      l_new_element_id);
        g_handled_attr_id_tbl(TO_NUMBER(l_new_element_id)) := l_current_element_id;

     END IF;

    -----------------------------------------------------

      IF l_current_element_id IS NOT NULL THEN
        -- set JRAD Id of current XML node to new value
        set_Attribute(p_xml_node,
                      G_ID_ATTRIBUTE,
                      l_new_element_id);
        g_handled_attr_id_tbl(TO_NUMBER(l_new_element_id)) := l_current_element_id;

        IF x_new_element_id IS NULL THEN
          x_new_element_id := l_new_element_id;
        END IF;

        IF xmldom.getNodeName(p_xml_node)='oa:switcher' THEN

          l_user_attribute3_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);

          l_switcher_casename := get_User_Attribute(l_user_attribute3_value ,'switcherDefaultCaseName');

          l_switcher_casename := REPLACE(l_switcher_casename,l_current_element_id, l_new_element_id);
          set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                             p_cz_attribute_value   => l_switcher_casename,
                             px_xml_attribute_value => l_user_attribute3_value);

          set_Attribute(p_xml_node,
                        G_USER_ATTRIBUTE3_NAME,
                        l_user_attribute3_value);
        END IF;

      END IF;

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);

      IF l_user_attribute_value IS NOT NULL THEN

        l_amn_expl_node_id := NULL;
        l_amn_persistent_node_id := NULL;

        IF p_copy_as_ui_page=FALSE AND p_is_instance_list_child THEN

          -- This is a child if an Instance List. We need to pass the AMN of the Instance List
          -- and the AMN of the UI Element to handle_User_attributes so that actions and conditions
          -- will have correct paths

          SELECT persistent_node_id, model_ref_expl_id
            INTO l_amn_persistent_node_id, l_amn_expl_node_id
            FROM cz_ui_page_elements
           WHERE ui_Def_id = p_target_ui_def_id
             AND page_Id = p_target_ui_page_id
             AND element_id = l_amn_parent_element_id;

          handle_User_Attributes
            (px_user_attribute_value  => l_user_attribute_value,
             p_source_ui_def_id       => p_source_ui_def_id,
             p_source_ui_page_id      => p_source_ui_page_id,
             p_target_ui_def_id       => p_target_ui_def_id,
             p_target_ui_page_id      => p_target_ui_page_id,
             p_new_element_id         => l_new_element_id,
             p_il_persistent_node_id  => l_base_persistent_node_id,
             p_il_expl_node_id        => l_base_expl_node_id,
             p_amn_persistent_node_id => l_amn_persistent_node_id,
             p_amn_expl_node_id       => l_amn_expl_node_id,
             p_xml_node               => p_xml_node);

        ELSE
          handle_User_Attributes
            (px_user_attribute_value => l_user_attribute_value,
             p_source_ui_def_id      => p_source_ui_def_id,
             p_source_ui_page_id     => p_source_ui_page_id,
             p_target_ui_def_id      => p_target_ui_def_id,
             p_target_ui_page_id     => p_target_ui_page_id,
             p_new_element_id        => l_new_element_id,
             p_xml_node              => p_xml_node);
        END IF;



         set_Attribute(p_xml_node,
                       G_USER_ATTRIBUTE3_NAME,
                       l_user_attribute_value);

     END IF;

   IF p_copy_as_ui_page=FALSE THEN

      l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE1_NAME);

      IF l_user_attribute_value IS NOT NULL AND l_ui_page_elements_exists THEN

        SELECT * INTO l_ui_node FROM CZ_UI_PAGE_ELEMENTS
         WHERE ui_def_id=p_target_ui_def_id AND
               page_id=p_target_ui_page_id AND
               element_id=l_new_element_id;

         l_target_model_path := CZ_DEVELOPER_UTILS_PVT.runtime_relative_path(p_base_expl_id => l_base_expl_node_id,
                                                     p_base_pers_id => l_base_persistent_node_id,
                                                     p_node_expl_id => l_ui_node.model_ref_expl_id,
                                                     p_node_pers_id => l_ui_node.persistent_node_id);

        IF l_target_model_path IS NULL THEN
           l_target_model_path := '.';
        END IF;

        set_Attribute(p_xml_node,
                      G_USER_ATTRIBUTE1_NAME,
                      'model_path='||l_target_model_path);

      END IF;

     l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);

     IF l_user_attribute_value IS NOT NULL THEN

       SELECT COUNT(element_id) INTO l_view_counter
       FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=p_target_ui_def_id AND page_id=p_target_ui_page_id AND
       deleted_flag NOT IN(G_YES_FLAG,G_MARK_TO_DELETE);

       l_view_name := get_User_Attribute(l_user_attribute_value ,'nodeView');

       IF l_view_name <> '%nodeView' AND l_view_name IS NOT NULL THEN
         l_ind := INSTR(l_view_name, '_');
         l_view_name := SUBSTR(l_view_name,1,l_ind-1)||'_'||TO_CHAR(l_view_counter);
         set_User_Attribute(p_cz_attribute_name    => 'nodeView',
                            p_cz_attribute_value   => l_view_name,
                            px_xml_attribute_value => l_user_attribute_value);

         l_children_view_name := get_User_Attribute(l_user_attribute_value ,'nodeChildrenView');
         IF l_children_view_name <> '%nodeChildrenView' AND l_children_view_name IS NOT NULL THEN

           l_ind := INSTR(l_children_view_name, '_');
           l_children_view_name := SUBSTR(l_children_view_name,1,l_ind-1)||'_'||TO_CHAR(l_view_counter)||'_children';

           set_User_Attribute(p_cz_attribute_name    => 'nodeChildrenView',
                              p_cz_attribute_value   => l_children_view_name,
                              px_xml_attribute_value => l_user_attribute_value);
         END IF;
         set_Attribute(p_xml_node,
                       G_USER_ATTRIBUTE3_NAME,
                       l_user_attribute_value);
       END IF;
     END IF;

     l_user_attribute_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE4_NAME);

     IF l_user_attribute_value IS NOT NULL THEN

         -- Check if this element is an Instance List, if it is then we need to alter the base AMN
         -- for other nodes in its subtree
         l_layout_region_type := get_User_Attribute(l_user_attribute_value, 'layoutRegionType');
         IF l_layout_region_type = '6078' THEN
           -- This node is an instance list. So we need to use the AMN of the Instance List as the base AMN
           -- for computing paths for elements within this subtree

           SELECT persistent_node_id, model_ref_expl_id
             INTO l_base_persistent_node_id, l_base_expl_node_id
             FROM cz_ui_page_elements
            WHERE ui_Def_id = p_target_ui_Def_id
              AND page_Id = p_target_ui_page_id
              AND element_Id = l_amn_parent_element_id;
         END IF;

       l_name := get_User_Attribute(l_user_attribute_value ,'name');

       SELECT COUNT(*)+1 INTO l_num_copy FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=p_target_ui_def_id AND page_id=p_target_ui_page_id AND
             name like l_name||'%' AND deleted_flag=G_NO_FLAG;

       l_name := l_name||' ('||TO_CHAR(l_num_copy)||')';

       set_User_Attribute(p_cz_attribute_name    => 'name',
                          p_cz_attribute_value   => l_name,
                          px_xml_attribute_value => l_user_attribute_value);

       set_Attribute(p_xml_node,
                     G_USER_ATTRIBUTE4_NAME,
                     l_user_attribute_value);
     END IF;

     IF l_new_element_id IS NOT NULL THEN
       UPDATE CZ_UI_PAGE_ELEMENTS
          SET name=l_name
        WHERE ui_def_id=p_target_ui_def_id AND page_id=p_target_ui_page_id AND
              element_id = l_new_element_id;
     END IF;

     END IF;  -- end of IF p_copy_as_ui_page=FALSE

    -----------------------------------------------------

    IF l_current_element_id IS NULL THEN
      l_current_element_id := p_parent_element_id;
    END IF;

    l_child_nodes_tbl := xmldom.getChildNodes(p_xml_node);
    l_length          := xmldom.getLength(l_child_nodes_tbl);

    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      copy_Tree_Level(p_xml_node                    => l_child_xml_node,
                      p_source_ui_def_id            => p_source_ui_def_id,
                      p_target_ui_def_id            => p_target_ui_def_id,
                      p_source_ui_page_id           => p_source_ui_page_id,
                      p_target_ui_page_id           => p_target_ui_page_id,
                      p_parent_element_id           => l_current_element_id,
                      p_target_parent_element_id    => p_target_parent_element_id,
                      p_pagebase_persistent_node_id => p_pagebase_persistent_node_id,
                      p_base_persistent_node_id     => l_base_persistent_node_id,
                      p_base_expl_node_id           => l_base_expl_node_id,
                      x_new_element_id              => x_new_element_id,
                      p_copy_as_ui_page             => p_copy_as_ui_page,
                      p_source_jrad_doc             => p_source_jrad_doc,
                      p_target_jrad_doc             => p_target_jrad_doc,
                      p_amn_parent_element_id       => l_amn_parent_element_id,
                      p_is_instance_list_child      => p_is_instance_list_child);

    END LOOP;

  END copy_Tree_Level;

  --
  -- copy records which corresponds with user attributes
  --
  PROCEDURE copy_User_Attributes(p_xml_node               xmldom.DOMNode,
                                 p_source_ui_def_id       NUMBER,
                                 p_target_ui_def_id       NUMBER,
                                 p_source_template_id     NUMBER DEFAULT NULL,
                                 p_target_template_id     NUMBER DEFAULT NULL) IS

    l_child_nodes_tbl xmldom.DOMNodeList;
    l_child_xml_node  xmldom.DOMNode;
    l_length          NUMBER;

  BEGIN
    copy_User_Attr_For_Node(p_xml_node          => p_xml_node,
                            p_source_ui_def_id  => p_source_ui_def_id,
                            p_target_ui_def_id  => p_target_ui_def_id,
                            p_source_template_id=> p_source_template_id,
                            p_target_template_id=> p_target_template_id);

    l_child_nodes_tbl := xmldom.getChildNodes(p_xml_node);
    l_length          := xmldom.getLength(l_child_nodes_tbl);

    FOR k IN 0 .. l_length - 1
    LOOP
      --
      -- get next child DOM node
      --
      l_child_xml_node := xmldom.item(l_child_nodes_tbl, k);

      copy_User_Attr_For_Node(p_xml_node          => l_child_xml_node,
                              p_source_ui_def_id  => p_source_ui_def_id,
                              p_target_ui_def_id  => p_target_ui_def_id,
                              p_source_template_id=> p_source_template_id,
                              p_target_template_id=> p_target_template_id);

      copy_User_Attributes(p_xml_node          => l_child_xml_node,
                           p_source_ui_def_id  => p_source_ui_def_id,
                           p_target_ui_def_id  => p_target_ui_def_id,
                           p_source_template_id=> p_source_template_id,
                           p_target_template_id=> p_target_template_id);
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      DEBUG('copy_User_Attributes() : '||SQLERRM);
  END copy_User_Attributes;

  --
  -- This procedure sets/propogates deleted_flag='1' from a given UI element to its subtree in CZ_UI_PAGE_ELEMENTS table.
  -- Also the procedure parses the corresponding XML to collect all caption intl_text_ids, UI condtion rules ids of
  -- deleted UI elements and then performs a soft delete ( set deleted_flag='1' ) of corresponding records
  -- in tables CZ_LOCALIZED_TEXTS and CZ_RULES which have seeded_flag='0'.
  -- If  parameter p_delete_xml = '1' then it also deletes a corresponding XML elements.
  --
  PROCEDURE delete_UI_Subtree(p_ui_def_id      IN NUMBER,
                              p_ui_page_id     IN NUMBER,
                              p_element_id     IN VARCHAR2,
                              p_delete_xml     IN VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2) IS

   l_xmldoc                   xmldom.DOMDocument;
   l_xml_node                 xmldom.DOMNode;
   l_element_id_tbl           varchar_tbl_type;
   l_out_node                 xmldom.DOMNode;
   l_parent_node              xmldom.DOMNode;
   l_page_ref_id              CZ_UI_PAGE_REFS.page_ref_id%TYPE;
   l_parent_element_id        CZ_UI_PAGE_ELEMENTS.parent_element_id%TYPE;
   l_jrad_doc                 CZ_UI_PAGES.jrad_doc%TYPE;
   l_page_ref_type            CZ_UI_PAGE_REFS.page_ref_type%TYPE;
   l_ui_context               CZ_UI_DEFS%ROWTYPE;
   l_condition_id             NUMBER;
   l_caption_text_id          NUMBER;
   l_caption_rule_id          NUMBER;
   l_display_condition_id     NUMBER;
   l_enabled_condition_id     NUMBER;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- get UI context
    --
    g_ui_def_nodes_tbl.DELETE;
    l_ui_context := get_UI_Context(p_ui_def_id => p_ui_def_id);

    --
    -- propogate deleted_flag in UI subtree
    --
    UPDATE CZ_UI_PAGE_ELEMENTS
       SET deleted_flag=G_LIMBO_FLAG
     WHERE (ui_def_id,page_id,element_id) IN
     (SELECT ui_def_id,page_id,element_id FROM CZ_UI_PAGE_ELEMENTS
      START WITH ui_def_id=p_ui_def_id AND page_id=p_ui_page_id AND element_id=p_element_id
      CONNECT BY PRIOR ui_def_id=p_ui_def_id AND
                       PRIOR page_id=p_ui_page_id AND page_id=p_ui_page_id AND
                       PRIOR element_id=parent_element_id AND
                       PRIOR ui_def_id=p_ui_def_id AND ui_def_id=p_ui_def_id AND
                       PRIOR deleted_flag=G_NO_FLAG AND deleted_flag=G_NO_FLAG)
    RETURNING element_id
    BULK COLLECT INTO l_element_id_tbl;

    IF l_element_id_tbl.COUNT=0 THEN
      RETURN;
    END IF;

    SELECT parent_element_id
     INTO l_parent_element_id
     FROM CZ_UI_PAGE_ELEMENTS
    WHERE ui_def_id=p_ui_def_id AND
          page_id=p_ui_page_id AND
          element_id=p_element_id;

    SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_PAGES
    WHERE page_id=p_ui_page_id AND ui_def_id=p_ui_def_id;

    IF  l_parent_element_id IS NULL OR p_element_id=G_NO_FLAG THEN  -- this is UI page ( and it should be deleted )

      FOR i IN(SELECT page_ref_id,page_ref_type,page_set_id,condition_id,caption_text_id,caption_rule_id
                 FROM CZ_UI_PAGE_REFS
                WHERE ui_def_id=p_ui_def_id AND target_page_id=p_ui_page_id AND deleted_flag=G_NO_FLAG)
      LOOP

        UPDATE CZ_LOCALIZED_TEXTS
           SET deleted_flag=G_YES_FLAG
         WHERE persistent_intl_text_id=i.caption_text_id AND
               ui_def_id=p_ui_def_id AND seeded_flag=G_NO_FLAG;

        UPDATE CZ_RULES
           SET deleted_flag=G_YES_FLAG
         WHERE persistent_rule_id IN(i.condition_id,i.caption_rule_id) AND
               ui_def_id=p_ui_def_id AND seeded_flag=G_NO_FLAG;

        IF l_page_ref_type IN( G_MODEL_TREE_MENU, G_MULTI_LEVEL_MENU) THEN
          UPDATE CZ_UI_PAGE_REFS
             SET deleted_flag=G_YES_FLAG
           WHERE ui_def_id=p_ui_def_id
                 AND deleted_flag=G_NO_FLAG
                 AND (ui_def_id,page_ref_id,page_set_id) IN
                 (SELECT a.ui_def_id,a.page_ref_id,a.page_set_id FROM CZ_UI_PAGE_REFS a
                   START WITH a.ui_def_id=p_ui_def_id AND
                              a.page_ref_id=i.page_ref_id
                   CONNECT BY PRIOR a.page_ref_id=a.parent_page_ref_id AND
                                    a.deleted_flag='0' AND a.ui_def_id=p_ui_def_id AND
                              PRIOR a.ui_def_id=p_ui_def_id AND
                                    a.page_set_id=i.page_set_id AND
                              PRIOR a.page_set_id=i.page_set_id);
        ELSE
          UPDATE CZ_UI_PAGE_REFS
             SET deleted_flag=G_YES_FLAG
           WHERE ui_def_id=p_ui_def_id AND page_ref_id=i.page_ref_id;
        END IF;

      END LOOP;

      --
      -- set data for Page Sets
      --
      handle_Page_Flows();

      UPDATE CZ_UI_PAGES
         SET deleted_flag=G_YES_FLAG
       WHERE page_id=p_ui_page_id AND ui_def_id=p_ui_def_id AND seeded_flag=G_NO_FLAG
      RETURNING caption_text_id,caption_rule_id,display_condition_id,enabled_condition_id
      INTO l_caption_text_id,l_caption_rule_id,l_display_condition_id,l_enabled_condition_id;

      UPDATE CZ_LOCALIZED_TEXTS
         SET deleted_flag=G_YES_FLAG
       WHERE intl_text_id=l_caption_text_id AND ui_def_id=p_ui_def_id AND seeded_flag=G_NO_FLAG;

      UPDATE CZ_RULES
         SET deleted_flag=G_YES_FLAG
       WHERE rule_id IN(l_display_condition_id,l_caption_rule_id,l_enabled_condition_id)
         AND seeded_flag=G_NO_FLAG;

    END IF;

    FORALL i IN l_element_id_tbl.First..l_element_id_tbl.Last
      UPDATE CZ_UI_ACTIONS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id=p_ui_def_id AND
             source_page_id=p_ui_page_id AND
             element_id=l_element_id_tbl(i) AND deleted_flag=G_NO_FLAG AND seeded_flag=G_NO_FLAG;

    FORALL i IN l_element_id_tbl.First..l_element_id_tbl.Last
      UPDATE CZ_RULES
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id=p_ui_def_id AND
             ui_page_id=p_ui_page_id AND
             ui_page_element_id=l_element_id_tbl(i) AND
             deleted_flag=G_NO_FLAG AND seeded_flag=G_NO_FLAG;

    FORALL i IN l_element_id_tbl.First..l_element_id_tbl.Last
      UPDATE CZ_LOCALIZED_TEXTS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id=p_ui_def_id AND
             ui_page_id=p_ui_page_id AND
             ui_page_element_id=l_element_id_tbl(i) AND
             deleted_flag=G_NO_FLAG AND seeded_flag=G_NO_FLAG;

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_jrad_doc);

    IF xmldom.isNull(l_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_xmldoc,
                                             p_attribute_name  => G_ID_ATTRIBUTE,
                                             p_attribute_value => p_element_id);
    --
    -- delete user attributes from the list of attrributes to delete
    --
    delete_User_Attributes(l_xml_node, p_ui_def_id);

    IF p_delete_xml=G_YES_FLAG THEN
      IF l_parent_element_id IS NULL OR p_element_id=G_NO_FLAG THEN
        jdr_docbuilder.deleteDocument(l_jrad_doc);
      ELSE
        l_parent_node:=xmldom.getParentNode(l_xml_node);
        l_out_node:=xmldom.removeChild(l_parent_node,l_xml_node);
        Save_Document(p_xml_doc   => l_xmldoc,
                      p_doc_name  => l_jrad_doc);
      END IF;

      UPDATE CZ_UI_PAGES
         SET page_rev_nbr=page_rev_nbr+1
       WHERE ui_def_id=p_ui_def_id AND
             page_id=p_ui_page_id;

    END IF;

    --
    -- close XML parser
    --
    Close_Parser();


  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      --DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SQLERRM;
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'delete_UI_Subtree', x_msg_data);
      --DEBUG(x_msg_data);
  END delete_UI_Subtree;

  --
  -- This procedure sets/propogates deleted_flag='1' from a given UI page to all related UI entities which belong to this page,
  -- parses the corresponding XML to collect all caption intl_text_ids, UI condtion rules ids of
  -- deleted UI elements and then performs a soft delete ( set deleted_flag='1' ) of corresponding records
  -- in tables CZ_LOCALIZED_TEXTS and CZ_RULES which have seeded_flag='0'  and deletes the corresponding XML/JRAD document.
  --
  PROCEDURE delete_UI_Page(p_ui_def_id      IN NUMBER,         -- ui_def_id of UI
                            p_ui_page_id    IN NUMBER,        -- page_id of
                                                                -- UI page which needs
                                                                -- to be deleted.
                            x_return_status  OUT NOCOPY VARCHAR2,-- status string
                            x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                            x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                            ) IS

    l_element_id CZ_UI_PAGE_ELEMENTS.element_id%TYPE;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- get element_id of root element of UI page
    --
    FOR i IN(SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
              WHERE ui_def_id=p_ui_def_id AND page_id=p_ui_page_id AND
                    parent_element_id IS NULL AND deleted_flag=G_NO_FLAG)
    LOOP
      --
      -- delete UI elements of this UI page starting with
      -- the root element
      --
      delete_UI_Subtree(p_ui_def_id      => p_ui_def_id,
                        p_ui_page_id     => p_ui_page_id,
                        p_element_id     => i.element_id,
                        p_delete_xml     => G_YES_FLAG,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data);
    END LOOP;

    -- handle page include region
    UPDATE cz_ui_page_elements
    SET target_page_ui_def_id = NULL, target_page_id = NULL
    WHERE target_page_ui_def_id = p_ui_def_id AND target_page_id = p_ui_page_id AND
          deleted_flag = '0' AND element_signature_id = G_PAGE_INCL_REGION_SIGNATURE;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'delete_UI_Page', x_msg_data);
      DEBUG(x_msg_data);
  END delete_UI_Page;

  --
  -- This procedure sets/propogates deleted_flag='1' from a given Page Ref record specified by parameter p_page_ref_id.
  -- a target UI pages are not deleted.
  --
  PROCEDURE delete_UI_Page_Ref(p_ui_def_id      IN NUMBER,          -- ui_def_id of UI
                                p_page_ref_id   IN NUMBER,          -- page_ref_id of
                                                                    -- Menu/Page Flow link which needs
                                                                    -- to be deleted.
                                x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                ) IS

   l_parent_page_ref_id   CZ_UI_PAGE_REFS.parent_page_ref_id%TYPE;
   l_ui_context           CZ_UI_DEFS%ROWTYPE;
   l_page_id              CZ_UI_PAGES.page_id%TYPE;
   l_page_set_id          CZ_UI_PAGES.page_set_id%TYPE;
   l_page_ref_type        CZ_UI_PAGE_REFS.page_ref_type%TYPE;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    g_ui_def_nodes_tbl.DELETE;

    --
    -- get UI context
    --
    l_ui_context := get_UI_Context(p_ui_def_id => p_ui_def_id);

    SELECT page_set_id, page_ref_type
      INTO l_page_set_id, l_page_ref_type
      FROM CZ_UI_PAGE_REFS
     WHERE ui_def_id=p_ui_def_id AND page_ref_id=p_page_ref_id
           AND deleted_flag=G_NO_FLAG;

    IF l_page_ref_type IN( G_MODEL_TREE_MENU, G_MULTI_LEVEL_MENU) THEN
      UPDATE CZ_UI_PAGE_REFS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id=p_ui_def_id
             AND deleted_flag=G_NO_FLAG
             AND (ui_def_id,page_ref_id,page_set_id) IN
             (SELECT a.ui_def_id,a.page_ref_id,a.page_set_id FROM CZ_UI_PAGE_REFS a
             START WITH a.ui_def_id=p_ui_def_id AND
             a.page_ref_id=p_page_ref_id
             CONNECT BY PRIOR a.page_ref_id=a.parent_page_ref_id AND
             a.deleted_flag='0' AND a.ui_def_id=p_ui_def_id AND
             PRIOR a.ui_def_id=p_ui_def_id AND
             a.page_set_id=l_page_set_id AND
             PRIOR a.page_set_id=l_page_set_id);
    ELSE
      UPDATE CZ_UI_PAGE_REFS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id=p_ui_def_id
             AND page_ref_id=p_page_ref_id;
    END IF;

    --
    -- null out CZ_UI_PAGES.page_set_id for those UI pages in this UI
    -- which have no corresponding records in CZ_UI_PAGE_REFS
    --
    UPDATE CZ_UI_PAGES a
       SET page_set_id=NULL
     WHERE ui_def_id=p_ui_def_id AND page_set_id IS NOT NULL AND
           NOT EXISTS(SELECT NULL FROM CZ_UI_PAGE_REFS b
           WHERE b.ui_def_id=p_ui_def_id AND target_page_id=a.page_id AND
           deleted_flag='0');

    IF l_page_ref_type IN( G_PAGE_FLOW, G_SUBTABS) THEN
      --
      -- set data for Page Sets
      --
      handle_Page_Flows();
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'delete_UI_Page_Ref', x_msg_data);
      DEBUG(x_msg_data);
  END delete_UI_Page_Ref;

  --
  -- For a given Local Template specified by parameters p_template_id and p_ui_def_id this procedure performs a soft deletion
  -- ( sets deleted_flag='1' ) of corresponding CZ_UI_TEMPLATES record and deletes the corresponding JRAD/XML document.
	-- It parses the corresponding XML to collect all caption intl_text_ids and UI Condition Ids and performs soft
  -- Delete of corresponding records in CZ_LOCALIZED_TEXTS
  -- and CZ_RULES which have seeded_flag='0'
  --
  PROCEDURE delete_Local_Template(p_template_ui_def_id  IN NUMBER,     -- ui_def_id of UI
                                  p_template_id         IN NUMBER,     -- template_id of
                                                                       -- Local UI Template which needs
                                                                       -- to be deleted.
                                  x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                  x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                  x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                  ) IS

   l_xmldoc                   xmldom.DOMDocument;
   l_jrad_doc                 CZ_UI_PAGES.jrad_doc%TYPE;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    FOR i IN(SELECT 'x' FROM CZ_MODEL_PUBLICATIONS
             WHERE object_id=p_template_id AND object_type='UIT' AND
                   deleted_flag='0' AND rownum<2)
    LOOP
      RETURN;
    END LOOP;

    --
    -- get full JRAD path of the given UI template
    --
    SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_template_ui_def_id AND template_id=p_template_id;

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_jrad_doc);

    IF xmldom.isNull(l_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- delete user attributes from the list of attrributes to delete
    --
    delete_User_Attributes(xmldom.makeNode(l_xmldoc),p_template_ui_def_id,
                           p_template_id, p_template_ui_def_id);

    jdr_docbuilder.deleteDocument(l_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    DELETE FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_template_ui_def_id AND template_id=p_template_id
          AND seeded_flag=G_NO_FLAG;

    DELETE FROM CZ_UI_REF_TEMPLATES
    WHERE template_ui_def_id=p_template_ui_def_id AND template_id=p_template_id;

    UPDATE CZ_UI_TEMPLATE_ELEMENTS
       SET deleted_flag=G_YES_FLAG
     WHERE template_id=p_template_ui_def_id AND
           deleted_flag=G_NO_FLAG;

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'delete_Local_Template', x_msg_data);
      DEBUG('delete_Local_Template() : '||x_msg_data);
  END delete_Local_Template;

  --
  -- This procedure deletes subtree  identified by p_element_id  of UI Local Template.
  -- Follows the same rules as deleting an element in a page.
  --
  PROCEDURE delete_Local_Template_Elem(p_template_ui_def_id  IN NUMBER, -- ui_def_id of UI
                                       p_template_id         IN NUMBER,        -- template_id of
                                       p_element_id          IN VARCHAR2,        -- element_id of Element to delete
                                       x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                       x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                       x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                       ) IS

    l_xmldoc                   xmldom.DOMDocument;
    l_out_node                 xmldom.DOMNode;
    l_parent_node              xmldom.DOMNode;
    l_xml_node                 xmldom.DOMNode;
    l_jrad_doc                 CZ_UI_PAGES.jrad_doc%TYPE;
    l_needs_to_be_unlocked     BOOLEAN;

  BEGIN

    --
    -- lock source UI Template
    --
    lock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- get full JRAD path of the given UI template
    --
    SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_template_ui_def_id AND template_id=p_template_id;

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_jrad_doc);

    IF xmldom.isNull(l_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_xmldoc,
                                             p_attribute_name  => G_ID_ATTRIBUTE,
                                             p_attribute_value => p_element_id);

    IF xmldom.isNull(l_xml_node) THEN
      l_xml_node := find_XML_Node_By_Attribute(p_subtree_doc        => l_xmldoc,
                                               p_attribute_name     => 'caseId',
                                               p_attribute_value    => p_element_id,
                                               p_in_user_attributes => G_YES_FLAG  );

      IF xmldom.isNull(l_xml_node) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
        x_msg_data  := 'Element with element_id="'||p_element_id||'" does exist.';
        fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'delete_Local_Template_Elem', 'Element with element_id="'||
        p_element_id||'" does exist.');
        DEBUG('delete_Local_Template_Elem() : '||'Element with element_id="'||
        p_element_id||'" does exist.');
        RETURN;
      END IF;
    END IF;

    --
    -- delete user attributes from the list of attrributes to delete
    --
    delete_User_Attributes(l_xml_node, p_template_ui_def_id,
                           p_template_id, p_template_ui_def_id);

    --
    -- remove XML subtree
    --
    l_parent_node:=xmldom.getParentNode(l_xml_node);
    l_out_node:=xmldom.removeChild(l_parent_node,l_xml_node);


    refresh_Templ_Ref_Counts(l_xmldoc, p_template_ui_def_id, p_template_id);

    --
    -- save XML in JRAD repository
    --
    Save_Document(p_xml_doc   => l_xmldoc,
                  p_doc_name  => l_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    /* *** changes for build 21p *** */

    UPDATE CZ_UI_TEMPLATES
       SET template_rev_nbr=NVL(template_rev_nbr,0)+1
     WHERE ui_def_id=p_template_ui_def_id AND template_id=p_template_id;

    --
    -- unlock source UI Template
    --
    unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

  EXCEPTION
      WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'delete_Local_Template_Elem', x_msg_data);
      DEBUG('delete_Local_Template_Elem() : '||x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

  END delete_Local_Template_Elem;

  --
  -- This procedure copies a UI element and its subtree specified by parameters p_element_id, p_page_id and p_ui_def_id to
  -- to a new location specified by paremeters p_new_parent_element_id - new parent UI element  and p_target_ui_def_id.
  -- For all caption intl_text_ids, UI condtion rules ids  from the source page a new copies will be created for use in the copied page.
  -- Action records associated to the UI Elements will also be copied, pointing to the same action as the source Element.
  PROCEDURE copy_UI_Subtree(p_source_ui_def_id      IN NUMBER,    -- ui_def_id of source UI
                            p_source_element_id     IN VARCHAR2,  -- element_id of
                                                                  -- UI element which needs
                                                                  -- to be copied ( source element )
                            p_source_ui_page_id IN NUMBER,        -- page_id of UI page to which source element belongs to
                            p_target_ui_def_id  IN NUMBER, -- ui_def_id of target UI
                            p_target_ui_page_id IN NUMBER,        -- page_id of target UI page
                            p_target_parent_element_id IN VARCHAR2,  -- element_id of
                                                                         -- new parent UI element
                            p_source_xml_node xmldom.DOMNode,
                            p_target_xml_node xmldom.DOMNode,
                            p_target_xmldoc xmldom.DOMDocument,
                            x_new_element_id OUT NOCOPY VARCHAR2,    -- element_id of copied UI element
                            x_new_xml_node OUT NOCOPY xmldom.DOMNode
                            ) IS

    l_target_xmldoc               xmldom.DOMDocument;
    l_new_xml_root_node           xmldom.DOMNode;
    l_target_uicont_xml_node      xmldom.DOMNode;
    l_stacklayout_node            xmldom.DOMNode;
    l_stacklayout_uicont_xml_node xmldom.DOMNode;
    l_xml_uicont_node             xmldom.DOMNode;
    l_xml_new_node                xmldom.DOMNode;
    l_amn_parent_element_id       CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_source_jrad_doc             CZ_UI_PAGES.jrad_doc%TYPE;
    l_target_jrad_doc             CZ_UI_PAGES.jrad_doc%TYPE;
    l_pagebase_persistent_node_id NUMBER;
    l_pagebase_expl_node_id       NUMBER;
    l_length                      NUMBER;
    l_base_persistent_node_id     NUMBER;
    l_base_expl_node_id                NUMBER;
    l_instance_list_AMN     expl_node_persistent_id_pair;
    l_is_instance_list_child BOOLEAN := FALSE;
    l_xml_temp_node               xmldom.DOMNode;

  BEGIN


    g_handled_attr_id_tbl.DELETE;

    --
    -- get jrad_doc of source UI page to which this UI element belongs to
    --
    SELECT jrad_doc
      INTO l_source_jrad_doc FROM CZ_UI_PAGES
    WHERE page_id=p_source_ui_page_id AND
          ui_def_id=p_source_ui_def_id;

    SELECT jrad_doc, persistent_node_id, pagebase_expl_node_id
      INTO l_target_jrad_doc, l_pagebase_persistent_node_id, l_pagebase_expl_node_id
      FROM CZ_UI_PAGES
     WHERE page_id=p_target_ui_page_id AND
           ui_def_id=p_target_ui_def_id;


    BEGIN
      SELECT element_id INTO l_amn_parent_element_id
        FROM CZ_UI_PAGE_ELEMENTS
       WHERE ui_def_id=p_target_ui_def_id AND
             page_id=p_target_ui_page_id AND
             element_id=p_target_parent_element_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_amn_parent_element_id := find_AMN_Element_Above(p_target_xml_node);
    END;

    l_target_uicont_xml_node := getUIContents(p_target_xml_node, G_YES_FLAG);
    IF xmldom.IsNull(l_target_uicont_xml_node) THEN
      l_xml_temp_node := xmldom.makeNode(xmldom.createElement(l_target_xmldoc, 'ui:contents'));
      l_target_uicont_xml_node := xmldom.appendChild(p_target_xml_node,
                                                     l_xml_temp_node);
    END IF;

    --
    -- returns cloned DOM subtree
    --
    --l_new_xml_root_node := xmldom.cloneNode(p_source_xml_node, TRUE);
    l_new_xml_root_node := cloneNode(p_source_xml_node, l_target_uicont_xml_node);

    l_base_persistent_node_id := l_pagebase_persistent_node_id;
    l_base_expl_node_Id := l_pagebase_expl_node_id;

    l_instance_list_AMN := getInstanceListAMN(p_target_ui_def_id, p_target_ui_page_id, p_target_xml_node);


    IF l_instance_list_AMN.persistent_node_id IS NOT NULL THEN
      -- There is an Instance List containing this element. We need to use the AMN of the Instance List
      -- as the base AMN for the the subtree being copied
      DEBUG('Target node is contained in an Instance List. So passing the AMN of the Instance List as the base AMN');
      l_base_persistent_node_id := l_instance_list_AMN.persistent_node_id;
      l_base_expl_node_Id := l_instance_list_AMN.expl_node_id;
      l_is_instance_list_child := TRUE;
    END IF;

    copy_Tree_Level(p_xml_node                    => l_new_xml_root_node,
                    p_source_ui_def_id            => p_source_ui_def_id,
                    p_target_ui_def_id            => p_target_ui_def_id,
                    p_source_ui_page_id           => p_source_ui_page_id,
                    p_target_ui_page_id           => p_target_ui_page_id,
                    p_parent_element_id           => NULL,
                    p_target_parent_element_id    => p_target_parent_element_id,
                    p_pagebase_persistent_node_id => l_pagebase_persistent_node_id,
                    p_base_persistent_node_id     => l_base_persistent_node_id,
                    p_base_expl_node_id           => l_base_expl_node_Id,
                    x_new_element_id              => x_new_element_id,
                    p_copy_as_ui_page             => FALSE,
                    p_source_jrad_doc             => l_source_jrad_doc,
                    p_target_jrad_doc             => l_target_jrad_doc,
                    p_amn_parent_element_id       => l_amn_parent_element_id,
                    p_is_instance_list_child      => l_is_instance_list_child);

    validate_Copied_PIR(p_target_ui_def_id, p_target_ui_page_id);

    IF xmldom.getNodeName(p_source_xml_node)='ui:case' AND xmldom.getNodeName(p_target_xml_node)='oa:switcher' THEN

      x_new_xml_node := xmldom.appendChild(p_target_xml_node,
                                           l_new_xml_root_node);

    ELSIF xmldom.IsNull(l_target_uicont_xml_node) AND xmldom.getNodeName(p_target_xml_node)<>'ui:case' THEN
      l_xml_new_node := xmldom.makeNode(xmldom.createElement(p_target_xmldoc, 'ui:contents'));

      l_xml_uicont_node := xmldom.appendChild(p_target_xml_node,
                                              l_xml_new_node);
      x_new_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                           l_new_xml_root_node);
    ELSIF xmldom.IsNull(l_target_uicont_xml_node) AND  xmldom.getNodeName(p_target_xml_node)='ui:case' THEN

      l_stacklayout_node := findChildXMLTag(p_target_xml_node, 'oa:stackLayout');
      l_stacklayout_uicont_xml_node := getUIContents(l_stacklayout_node, G_YES_FLAG);

      IF xmldom.IsNull(l_stacklayout_uicont_xml_node) THEN

        l_xml_new_node := xmldom.makeNode(xmldom.createElement(p_target_xmldoc, 'ui:contents'));
        l_xml_uicont_node := xmldom.appendChild(l_stacklayout_node,
                                              l_xml_new_node);
        x_new_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                             l_new_xml_root_node);

      ELSE

        x_new_xml_node := xmldom.appendChild(l_stacklayout_uicont_xml_node,
                                             l_new_xml_root_node);
      END IF;
    ELSE
      x_new_xml_node := xmldom.appendChild(l_target_uicont_xml_node,
                                           l_new_xml_root_node);
    END IF;

    Save_Document(p_xml_doc   => p_target_xmldoc,
                  p_doc_name  => l_target_jrad_doc);

    UPDATE CZ_UI_PAGES
       SET page_rev_nbr=page_rev_nbr+1,
           empty_page_flag = G_NO_FLAG
     WHERE page_id=p_target_ui_page_id AND
           ui_def_id=p_target_ui_def_id;

    UPDATE CZ_UI_PAGE_REFS
       SET empty_page_flag = G_NO_FLAG
     WHERE target_page_id=p_target_ui_page_id AND
           ui_def_id=p_target_ui_def_id AND
           deleted_flag = G_NO_FLAG AND
           empty_page_flag = G_YES_FLAG;


  END copy_UI_Subtree;

  --
  -- This procedure copies a UI element and its subtree specified by parameters p_element_id, p_page_id and p_ui_def_id to
  -- to a new location specified by paremeters p_new_parent_element_id - new parent UI element  and p_target_ui_def_id.
  -- For all caption intl_text_ids, UI condtion rules ids  from the source page a new copies will be created for use in the copied page.
  -- Action records associated to the UI Elements will also be copied, pointing to the same action as the source Element.
  PROCEDURE copy_UI_Subtree(p_source_ui_def_id      IN NUMBER,    -- ui_def_id of source UI
                            p_source_element_id     IN VARCHAR2,  -- element_id of
                                                                  -- UI element which needs
                                                                  -- to be copied ( source element )
                            p_source_ui_page_id IN NUMBER,        -- page_id of UI page to which source element belongs to
                            p_target_ui_def_id  IN NUMBER, -- ui_def_id of target UI
                            p_target_ui_page_id IN NUMBER,        -- page_id of target UI page
                            p_target_parent_element_id     IN VARCHAR2,  -- element_id of
                                                                         -- new parent UI element
                            x_new_element_id OUT NOCOPY VARCHAR2,     -- element_id of copied UI element
                            x_return_status  OUT NOCOPY VARCHAR2,-- status string
                            x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                            x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                            ) IS

    l_source_xmldoc               xmldom.DOMDocument;
    l_target_xmldoc               xmldom.DOMDocument;
    l_source_xml_node             xmldom.DOMNode;
    l_target_xml_node             xmldom.DOMNode;
    l_new_xml_root_node           xmldom.DOMNode;
    l_new_xml_node                xmldom.DOMNode;
    l_out_xml_node                xmldom.DOMNode;
    l_target_uicont_xml_node      xmldom.DOMNode;
    l_stacklayout_node            xmldom.DOMNode;
    l_stacklayout_uicont_xml_node xmldom.DOMNode;
    l_source_jrad_doc             CZ_UI_PAGES.jrad_doc%TYPE;
    l_target_jrad_doc             CZ_UI_PAGES.jrad_doc%TYPE;
    l_xml_uicont_node             xmldom.DOMNode;
    l_xml_new_node                xmldom.DOMNode;
    l_amn_parent_element_id       CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_new_element_id              CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_pagebase_persistent_node_id NUMBER;
    l_length                      NUMBER;
    l_caseid_to_copy              BOOLEAN;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    set_Local_UI_Context(p_target_ui_def_id);

    --
    -- get jrad_doc of source UI page to which this UI element belongs to
    --
    SELECT jrad_doc
      INTO l_source_jrad_doc FROM CZ_UI_PAGES
    WHERE page_id=p_source_ui_page_id AND
          ui_def_id=p_source_ui_def_id;

    --
    -- get jrad_doc of source UI page to which this UI element belongs to
    --
    SELECT jrad_doc,persistent_node_id
      INTO l_target_jrad_doc, l_pagebase_persistent_node_id
      FROM CZ_UI_PAGES
     WHERE  page_id=p_target_ui_page_id AND
            ui_def_id=p_target_ui_def_id;

    --
    -- open XML parser
    --
    Open_Parser();

    l_source_xmldoc := parse_JRAD_Document(p_doc_full_name => l_source_jrad_doc);

    IF xmldom.isNull(l_source_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_source_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- create UI Template in JRAD repository
    --
    l_target_xmldoc := parse_JRAD_Document(p_doc_full_name => l_target_jrad_doc);

    IF xmldom.isNull(l_target_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_target_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_source_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_source_xmldoc,
                                                    p_attribute_name  => G_ID_ATTRIBUTE,
                                                    p_attribute_value => p_source_element_id);

    IF xmldom.IsNull(l_source_xml_node) THEN
      l_source_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_source_xmldoc,
                                                      p_attribute_name  => 'caseId',
                                                      p_attribute_value => p_source_element_id,
                                                      p_in_user_attributes => G_YES_FLAG);
      l_caseid_to_copy := TRUE;
    END IF;

    l_target_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_target_xmldoc,
                                                    p_attribute_name  => G_ID_ATTRIBUTE,
                                                    p_attribute_value => p_target_parent_element_id);
    IF xmldom.IsNull(l_target_xml_node) THEN
      l_target_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_target_xmldoc,
                                                      p_attribute_name  => 'caseId',
                                                      p_attribute_value => p_target_parent_element_id,
                                                      p_in_user_attributes => G_YES_FLAG);
    END IF;


    copy_UI_Subtree(p_source_ui_def_id => p_source_ui_def_id,
                    p_source_element_id => p_source_element_id,
                    p_source_ui_page_id => p_source_ui_page_id,
                    p_target_ui_def_id => p_target_ui_def_id,
                    p_target_ui_page_id => p_target_ui_page_id,
                    p_target_parent_element_id => p_target_parent_element_id,
                    p_source_xml_node => l_source_xml_node,
                    p_target_xml_node => l_target_xml_node,
                    p_target_xmldoc => l_target_xmldoc,
                    x_new_element_id => l_new_element_id,
                    x_new_xml_node => l_new_xml_node);

    x_new_element_id := l_new_element_id;
    --
    -- close XML parser
    --
    Close_Parser();


    IF g_MSG_COUNT>0 THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
    END IF;


  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'copy_UI_Subtree', x_msg_data);
      DEBUG('copy_UI_Subtree() : '||x_msg_data);
  END copy_UI_Subtree;

  --
  --
  -- This procedure copies a UI page specified by parameter p_page_id - it creates a new copies for UI entities corresponding to
  -- a source UI page except corresponding UI Page Refs records.
  -- For all caption intl_text_ids, UI condtion rules ids from the source page which have seeded_flag='0', a new copies will be created for use in the copied page.
  --
  PROCEDURE copy_UI_Page (p_source_ui_def_id      IN NUMBER,   -- ui_def_id of UI
                          p_source_ui_page_id     IN NUMBER, -- page_id of
                                                               -- UI page which needs
                                                               -- to be copied
                          p_target_ui_def_id      IN NUMBER,        -- ui_def_id of target UI
                          p_source_xmldoc         xmldom.DOMDocument,
                          x_new_ui_page_id        OUT NOCOPY NUMBER,-- page_id of copied UI page
                          x_new_jrad_doc          OUT NOCOPY VARCHAR2
                          ) IS

    l_source_xml_node            xmldom.DOMNode;
    l_source_jrad_doc            CZ_UI_PAGES.jrad_doc%TYPE;
    l_target_jrad_doc            CZ_UI_PAGES.jrad_doc%TYPE;
    l_element_id_tbl             number_tbl_type;
    l_parent_element_id_tbl      number_tbl_type;
    l_element_id_arr_tbl         number_tbl_type;
    l_new_element_id_arr_tbl     number_tbl_type;
    l_seq_nbr_tbl                number_tbl_type;
    l_seq_nbr_arr_tbl            number_tbl_type;
    l_source_element_id          VARCHAR2(255);
    l_new_element_id             VARCHAR2(255);
    l_caption_text_id            NUMBER;
    l_ui_action_id               NUMBER;
    l_display_condition_id       NUMBER;
    l_enabled_condition_id       NUMBER;
    l_current_element_id         NUMBER;
    l_persistent_node_id         NUMBER;
    l_pagebase_expl_node_id      NUMBER;
    l_caption_rule_id            NUMBER;
    l_new_parent_element_id      NUMBER;
    l_copy_nbr                   NUMBER;

  BEGIN

    SELECT element_id INTO l_source_element_id
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id=p_source_ui_def_id AND page_id=p_source_ui_page_id AND
           parent_element_id IS NULL AND deleted_flag=G_NO_FLAG;

    --
    -- get jrad_doc of source UI page to which this UI element belongs to
    --
    SELECT jrad_doc,persistent_node_id, pagebase_expl_node_id
      INTO l_source_jrad_doc,l_persistent_node_id, l_pagebase_expl_node_id
      FROM CZ_UI_PAGES
     WHERE ui_def_id=p_source_ui_def_id AND
           page_id=p_source_ui_page_id;

    SELECT COUNT(*) INTO l_copy_nbr FROM CZ_UI_PAGES
    WHERE ui_def_id=p_target_ui_def_id AND
          persistent_node_id=l_persistent_node_id;

    l_target_jrad_doc := '/oracle/apps/cz/runtime/oa/webui/regions/ui' ||
                         TO_CHAR(p_target_ui_def_id) || '/' ||
                         get_Short_JRAD_Name(l_source_jrad_doc)||'_'||TO_CHAR(l_copy_nbr);

    l_target_jrad_doc := REPLACE(l_target_jrad_doc,'_'||TO_CHAR(p_source_ui_def_id)||'_',
                                 '_'||TO_CHAR(p_target_ui_def_id)||'_');

    x_new_jrad_doc := l_target_jrad_doc;

    FOR i IN(SELECT * FROM CZ_UI_PAGES
             WHERE ui_def_id=p_source_ui_def_id AND
                   page_id=p_source_ui_page_id)
    LOOP

      x_new_ui_page_id := allocateId('CZ_UI_PAGES_S');

      l_caption_text_id := copy_Intl_Text(i.caption_text_id, p_target_ui_def_id, NULL, NULL);

      copy_UI_Rule( i.caption_rule_id, l_caption_rule_id,
                    p_target_ui_def_id,x_new_ui_page_id,NULL,p_source_ui_def_id);

      copy_UI_Rule( i.display_condition_id, l_display_condition_id,
                    p_target_ui_def_id,x_new_ui_page_id,NULL,p_source_ui_def_id);

      copy_UI_Rule( i.enabled_condition_id, l_enabled_condition_id,
                    p_target_ui_def_id,x_new_ui_page_id,NULL,p_source_ui_def_id);

      INSERT INTO CZ_UI_PAGES
      (
      PAGE_ID
      ,UI_DEF_ID
      ,PERSISTENT_NODE_ID
      ,JRAD_DOC
      ,PAGEBASE_PATH
      ,PAGE_SET_ID
      ,SPLIT_SEQ_NBR
      ,CAPTION_SOURCE
      ,CAPTION_TEXT_ID
      ,PERSISTENT_CAPTION_TEXT_ID
      ,PROPERTY_ID
      ,DELETED_FLAG
      ,SEEDED_FLAG
      ,PAGEBASE_EXPL_NODE_ID
      ,suppress_refresh_flag
      ,PAGE_REV_NBR
      ,NAME
      ,DESC_TEXT
      ,PAGE_STATUS_TEMPLATE_ID
      ,PAGE_STATUS_TEMPL_UIDEF_ID
      ,CAPTION_RULE_ID
      ,PAGE_STATUS_TEMPLATE_USAGE
      ,OUTER_TEMPLATE_USAGE
      ,OUTER_PAGE_TEMPLATE_ID
      ,OUTER_PAGE_TEMPL_UIDEF_ID
      ,DISPLAY_CONDITION_ID
      ,DISPLAY_CONDITION_COMP
      ,DISPLAY_CONDITION_VALUE
      ,ENABLED_CONDITION_ID
      ,ENABLED_CONDITION_COMP
      ,ENABLED_CONDITION_VALUE
      )
      VALUES
      (
      x_new_ui_page_id
      ,p_target_ui_def_id
      ,i.PERSISTENT_NODE_ID
      ,l_target_jrad_doc
      ,i.PAGEBASE_PATH
      ,NULL
      ,1
      ,i.CAPTION_SOURCE
      ,l_caption_text_id
      ,i.PERSISTENT_CAPTION_TEXT_ID
      ,i.PROPERTY_ID
      ,i.DELETED_FLAG
      ,i.SEEDED_FLAG
      ,i.PAGEBASE_EXPL_NODE_ID
      ,i.suppress_refresh_flag
      ,0
      ,i.NAME||'_'||TO_CHAR(l_copy_nbr)
      ,i.DESC_TEXT
      ,i.PAGE_STATUS_TEMPLATE_ID
      ,i.PAGE_STATUS_TEMPL_UIDEF_ID
      ,l_caption_rule_id
      ,i.PAGE_STATUS_TEMPLATE_USAGE
      ,i.OUTER_TEMPLATE_USAGE
      ,i.OUTER_PAGE_TEMPLATE_ID
      ,i.OUTER_PAGE_TEMPL_UIDEF_ID
      ,l_display_condition_id
      ,i.DISPLAY_CONDITION_COMP
      ,i.DISPLAY_CONDITION_VALUE
      ,l_enabled_condition_id
      ,i.ENABLED_CONDITION_COMP
      ,i.ENABLED_CONDITION_VALUE
      );
    END LOOP;

    l_source_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => p_source_xmldoc,
                                                    p_attribute_name  => G_ID_ATTRIBUTE,
                                                    p_attribute_value => l_source_element_id);

    l_source_xml_node := xmldom.cloneNode(l_source_xml_node, TRUE);

    -- We are copying an entire page. We start off with the pagebase as the base AMN
    -- for computing paths (p_base_persistent_node_id, p_base_expl_node_id)
    -- If while copying the tree, we encounter an Instance List Region, we will change
    -- the base AMN to the AMN of the Instance List for nodes under the Instance List
    copy_Tree_Level(p_xml_node                    => l_source_xml_node,
                    p_source_ui_def_id            => p_source_ui_def_id,
                    p_target_ui_def_id            => p_target_ui_def_id,
                    p_source_ui_page_id           => p_source_ui_page_id,
                    p_target_ui_page_id           => x_new_ui_page_id,
                    p_parent_element_id           => NULL,
                    p_target_parent_element_id    => NULL,
                    p_pagebase_persistent_node_id => l_persistent_node_id,
                    p_base_persistent_node_id     => l_persistent_node_id,  -- see comment above
                    p_base_expl_node_id           => l_pagebase_expl_node_id, -- see comment above
                    x_new_element_id              => l_new_element_id,
                    p_copy_as_ui_page             => TRUE,
                    p_source_jrad_doc             => l_source_jrad_doc,
                    p_target_jrad_doc             => l_target_jrad_doc,
                    p_amn_parent_element_id       => NULL);

    validate_Copied_PIR(p_target_ui_def_id, x_new_ui_page_id);

    Save_As_Document(p_xml_root_node => l_source_xml_node,
                     p_doc_name      => l_target_jrad_doc);

  END copy_UI_Page;


  --
  --
  -- This procedure copies a UI page specified by parameter p_page_id - it creates a new copies for UI entities corresponding to
  -- a source UI page except corresponding UI Page Refs records.
  -- For all caption intl_text_ids, UI condtion rules ids from the source page which have seeded_flag='0', a new copies will be created for use in the copied page.
  --
  PROCEDURE copy_UI_Page (p_source_ui_def_id      IN NUMBER,   -- ui_def_id of UI
                          p_source_ui_page_id     IN NUMBER, -- page_id of
                                                               -- UI page which needs
                                                               -- to be copied
                          p_target_ui_def_id      IN NUMBER,        -- ui_def_id of target UI
                          x_new_ui_page_id        OUT NOCOPY NUMBER,-- page_id of copied UI page
                          x_return_status  OUT NOCOPY VARCHAR2,-- status string
                          x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                          x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                          ) IS

    l_source_xmldoc              xmldom.DOMDocument;
    l_source_xml_node            xmldom.DOMNode;
    l_source_jrad_doc            CZ_UI_PAGES.jrad_doc%TYPE;
    l_target_jrad_doc            CZ_UI_PAGES.jrad_doc%TYPE;
    l_element_id_tbl             number_tbl_type;
    l_parent_element_id_tbl      number_tbl_type;
    l_element_id_arr_tbl         number_tbl_type;
    l_new_element_id_arr_tbl     number_tbl_type;
    l_seq_nbr_tbl                number_tbl_type;
    l_seq_nbr_arr_tbl            number_tbl_type;
    l_source_element_id          VARCHAR2(255);
    l_new_element_id             VARCHAR2(255);
    l_new_ui_page_id             NUMBER;
    l_caption_text_id            NUMBER;
    l_ui_action_id               NUMBER;
    l_display_condition_id       NUMBER;
    l_enabled_condition_id       NUMBER;
    l_current_element_id         NUMBER;
    l_persistent_node_id         NUMBER;
    l_caption_rule_id            NUMBER;
    l_new_parent_element_id      NUMBER;
    l_copy_nbr                   NUMBER;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    g_handled_attr_id_tbl.DELETE;

    set_Local_UI_Context(p_target_ui_def_id);

    SELECT element_id INTO l_source_element_id
      FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id=p_source_ui_def_id AND page_id=p_source_ui_page_id AND
           parent_element_id IS NULL AND deleted_flag=G_NO_FLAG;

    --
    -- get jrad_doc of source UI page to which this UI element belongs to
    --
    SELECT jrad_doc,persistent_node_id
      INTO l_source_jrad_doc,l_persistent_node_id
      FROM CZ_UI_PAGES
     WHERE ui_def_id=p_source_ui_def_id AND
           page_id=p_source_ui_page_id;

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_source_xmldoc := parse_JRAD_Document(p_doc_full_name => l_source_jrad_doc);

    IF xmldom.isNull(l_source_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_source_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    copy_UI_Page (p_source_ui_def_id => p_source_ui_def_id,
                  p_source_ui_page_id => p_source_ui_page_id,
                  p_target_ui_def_id => p_target_ui_def_id,
                  p_source_xmldoc => l_source_xmldoc,
                  x_new_ui_page_id => l_new_ui_page_id,
                  x_new_jrad_doc => l_target_jrad_doc);

    x_new_ui_page_id := l_new_ui_page_id;

    translate_JRAD_Doc(l_target_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    IF g_MSG_COUNT>0 THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
    END IF;

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'copy_UI_Page', x_msg_data);
      DEBUG('copy_UI_Page() : '||x_msg_data);

  END copy_UI_Page;

  --
  -- This procedure sets/propogates deleted_flag='1' from a given
  -- Page Ref record specified by parameter p_page_ref_id.
  -- target UI pages are not deleted.
  --
  PROCEDURE copy_UI_Page_Ref(p_source_ui_def_id      IN NUMBER,    -- ui_def_id of UI
                             p_source_page_ref_id    IN NUMBER,  -- page_ref_id of
                                                                   -- Menu/Page Flow link which needs
                                                                   -- to be deleted.
                             p_target_ui_def_id       IN NUMBER,   -- ui_def_id of target UI
                             p_target_parent_page_ref_id IN NUMBER,-- new parent page ref id
                             x_page_ref_id OUT NOCOPY NUMBER,    -- template_id of
                                                                   -- Local UI Template which needs
                                                                   -- to be copied
                             x_return_status  OUT NOCOPY VARCHAR2, -- status string
                             x_msg_count      OUT NOCOPY NUMBER,   -- number of error messages
                             x_msg_data       OUT NOCOPY VARCHAR2  -- string which contains error messages
                             ) IS
    TYPE number_tbl_type        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_page_ref_id_tbl           number_tbl_type;
    l_parent_page_ref_id_tbl    number_tbl_type;
    l_node_depth_tbl            number_tbl_type;
    l_seq_nbr_tbl               number_tbl_type;
    l_page_ref_arr_tbl          number_tbl_type;
    l_new_page_ref_arr_tbl      number_tbl_type;
    l_seq_nbr_arr_tbl           number_tbl_type;
    l_node_depth_arr_tbl        number_tbl_type;
    l_target_page_set_id        NUMBER;
    l_current_page_ref_id       NUMBER;
    l_new_page_ref_id           NUMBER;
    l_new_parent_page_ref_id    NUMBER;

    l_condition_id              NUMBER;
    l_caption_rule_id           NUMBER;
    l_target_max_seq_nbr        NUMBER;
    l_target_node_depth         NUMBER;
    l_caption_text_id           NUMBER;
    l_seq_nbr                   NUMBER;
    l_node_depth                NUMBER;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    SELECT page_set_id,node_depth INTO l_target_page_set_id,l_target_node_depth
    FROM CZ_UI_PAGE_REFS
    WHERE ui_def_id=p_target_ui_def_id AND page_ref_id=p_target_parent_page_ref_id;

    SELECT NVL(MAX(seq_nbr),0) INTO l_target_max_seq_nbr FROM CZ_UI_PAGE_REFS
    WHERE ui_def_id=p_target_ui_def_id AND deleted_flag=G_NO_FLAG;

    SELECT page_ref_id,parent_page_ref_id,node_depth,seq_nbr
    BULK COLLECT INTO l_page_ref_id_tbl,l_parent_page_ref_id_tbl,l_node_depth_tbl,l_seq_nbr_tbl
    FROM CZ_UI_PAGE_REFS
    START WITH ui_def_id=p_source_ui_def_id AND page_ref_id=p_source_page_ref_id
    CONNECT BY PRIOR ui_def_id=p_source_ui_def_id AND
               ui_def_id=p_source_ui_def_id AND
               PRIOR page_ref_id=parent_page_ref_id AND
               PRIOR deleted_flag=G_NO_FLAG AND deleted_flag=G_NO_FLAG;

    IF l_page_ref_id_tbl.Count>0 THEN
      FOR i IN l_page_ref_id_tbl.First..l_page_ref_id_tbl.Last
      LOOP
        l_page_ref_arr_tbl(l_page_ref_id_tbl(i))     := l_parent_page_ref_id_tbl(i);
        l_new_page_ref_arr_tbl(l_page_ref_id_tbl(i)) := get_Element_Id();
        l_seq_nbr_arr_tbl(l_page_ref_id_tbl(i))      := l_seq_nbr_tbl(i);
        l_node_depth_arr_tbl(l_page_ref_id_tbl(i))   := l_node_depth_tbl(i);
      END LOOP;
    END IF;

    l_current_page_ref_id := l_page_ref_arr_tbl.First;
    LOOP
      IF l_current_page_ref_id IS NULL THEN
        EXIT;
      END IF;

      l_new_page_ref_id := l_page_ref_arr_tbl(l_current_page_ref_id);

      IF l_new_page_ref_arr_tbl.EXISTS(l_new_page_ref_id) THEN
        l_new_parent_page_ref_id := l_new_page_ref_arr_tbl(l_new_page_ref_id);
      ELSE
        l_new_parent_page_ref_id := p_target_parent_page_ref_id;
        x_page_ref_id := l_new_page_ref_id;
      END IF;

      FOR i IN(SELECT * FROM CZ_UI_PAGE_REFS
               WHERE ui_def_id=p_source_ui_def_id AND
                     page_ref_id=l_current_page_ref_id AND
                     deleted_flag=G_NO_FLAG)
      LOOP

        l_seq_nbr := l_target_max_seq_nbr + i.SEQ_NBR;
        l_node_depth := l_target_node_depth - l_node_depth_tbl(1) + 1;

        copy_UI_Rule(i.condition_id, l_condition_id,
                     p_target_ui_def_id, i.target_page_id, NULL,p_source_ui_def_id);

        copy_UI_Rule(i.caption_rule_id, l_caption_rule_id,
                     p_target_ui_def_id, i.target_page_id, NULL,p_source_ui_def_id);

        l_caption_text_id := copy_Intl_Text(l_caption_text_id, p_target_ui_def_id,
                                            NULL, NULL);

        INSERT INTO CZ_UI_PAGE_REFS
      (
      PAGE_SET_ID
      ,UI_DEF_ID
      ,PAGE_REF_ID
      ,PARENT_PAGE_REF_ID
      ,SEQ_NBR
      ,NODE_DEPTH
      ,PAGE_REF_TYPE
      ,CONDITION_ID
      ,NAME
      ,CAPTION_SOURCE
      ,CAPTION_TEXT_ID
      ,PERSISTENT_CAPTION_TEXT_ID
      ,PROPERTY_ID
      ,TARGET_PERSISTENT_NODE_ID
      ,TARGET_PATH
      ,TARGET_UI_DEF_ID
      ,TARGET_PAGE_SET_ID
      ,TARGET_PAGE_ID
      ,MODIFIED_FLAGS
      ,PATH_TO_PREV_PAGE
      ,PATH_TO_NEXT_PAGE
      ,DELETED_FLAG
      ,CAPTION_RULE_ID
      ,TARGET_EXPL_NODE_ID
      )
       VALUES
      (
      l_target_page_set_id
      ,p_target_ui_def_id
      ,l_new_page_ref_id
      ,l_new_parent_page_ref_id
      ,l_seq_nbr
      ,l_node_depth
      ,i.PAGE_REF_TYPE
      ,l_condition_id
      ,i.NAME
      ,i.CAPTION_SOURCE
      ,l_caption_text_id
      ,i.PERSISTENT_CAPTION_TEXT_ID
      ,i.PROPERTY_ID
      ,i.TARGET_PERSISTENT_NODE_ID
      ,i.TARGET_PATH
      ,i.TARGET_UI_DEF_ID
      ,i.TARGET_PAGE_SET_ID
      ,i.TARGET_PAGE_ID
      ,i.MODIFIED_FLAGS
      ,i.PATH_TO_PREV_PAGE
      ,i.PATH_TO_NEXT_PAGE
      ,i.DELETED_FLAG
      ,l_caption_rule_id
      ,i.TARGET_EXPL_NODE_ID
      );

     END LOOP;

     l_current_page_ref_id := l_page_ref_arr_tbl.NEXT(l_current_page_ref_id);
   END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'delete_UI_Subtree', x_msg_data);
      DEBUG('copy_UI_Page_Ref() : '||x_msg_data);
  END copy_UI_Page_Ref;

  --
	-- This procedure creates copies of the Local Template record and its corresponding XML Jrad document.  In addition, it also
	-- parses the source jrad document for any caption intl_text_ids or condition rule Ids and creates copies
  -- the Intl_text and Rule records which have seeded_flag='0'.
	-- the UI Elements.  The Elements could also have Associated with them which need to be copied and refered in the new copy.
  --
  PROCEDURE copy_Local_Template(p_source_ui_def_id       IN NUMBER,   -- ui_def_id of UI
                                p_source_template_id     IN NUMBER,   -- template_id of
                                                                      -- Local UI Template which needs
                                                                      -- to be copied
                                p_target_ui_def_id       IN NUMBER,           -- ui_def_id of target UI
                                x_new_template_id        OUT NOCOPY NUMBER, -- template_id of
                                                                              -- Local UI Template which needs
                                                                              -- to be copied
                                x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                ) IS
    l_source_template_xmldoc  xmldom.DOMDocument;
    l_template_root_xml_node  xmldom.DOMNode;
    l_xml_node                xmldom.DOMNode;
    l_child_nodes_tbl         xmldom.DOMNodeList;
    l_source_jrad_doc         CZ_UI_PAGES.jrad_doc%TYPE;
    l_target_jrad_doc         CZ_UI_PAGES.jrad_doc%TYPE;
    l_length                  NUMBER;
    l_needs_to_be_unlocked    BOOLEAN;

  BEGIN

    --
    -- lock source UI Template
    --
    lock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    SELECT jrad_doc INTO l_source_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_source_ui_def_id AND template_id=p_source_template_id;

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_source_template_xmldoc := parse_JRAD_Document(p_doc_full_name => l_source_jrad_doc);

    IF xmldom.isNull(l_source_template_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_source_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_template_root_xml_node :=xmldom.makeNode(xmldom.getDocumentElement(l_source_template_xmldoc));

    l_child_nodes_tbl := xmldom.getElementsByTagName(l_source_template_xmldoc, '*');
    l_length := xmldom.getLength(l_child_nodes_tbl);
    IF (l_length > 0) THEN
        FOR k IN 0..l_length-1
        LOOP
          --
          -- get next child DOM node
          --
          l_xml_node := xmldom.item(l_child_nodes_tbl, k);
          IF k > 0 THEN
             --
             -- create a new copies for corresponding entities ( captions, rules ,... )
             --
             copy_Node_Related_Entities(p_ui_def_id        => p_source_ui_def_id,
                                        p_ui_page_id       => NULL,
                                        p_xml_node         => l_xml_node,
                                        p_target_ui_def_id => p_target_ui_def_id);
          END IF;
        END LOOP;
    END IF;

    l_target_jrad_doc := '/oracle/apps/cz/runtime/oa/webui/regions/ui' ||
                         TO_CHAR(p_target_ui_def_id) || '/' ||
                         get_Short_JRAD_Name(l_source_jrad_doc);

    Save_Document(p_xml_doc   => l_source_template_xmldoc,
                  p_doc_name  => l_target_jrad_doc);

    translate_JRAD_Doc(l_target_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    x_new_template_id := allocateId('CZ_UI_TEMPLATES_S');

    INSERT INTO CZ_UI_TEMPLATES
              (TEMPLATE_ID,
               UI_DEF_ID,
               TEMPLATE_NAME,
               TEMPLATE_TYPE,
               TEMPLATE_DESC,
               PARENT_CONTAINER_TYPE,
               JRAD_DOC,
               BUTTON_BAR_TEMPLATE_ID,
               MESSAGE_TYPE,
               MAIN_MESSAGE_ID,
               TITLE_ID,
               SEEDED_FLAG,
               LAYOUT_UI_STYLE,
               ROOT_REGION_TYPE,
               ROOT_ELEMENT_SIGNATURE_ID,
               TEMPLATE_REV_NBR,
               TEMPLATE_USAGE,
               AMN_USAGE,
               DELETED_FLAG)
     SELECT
               x_new_template_id ,
               p_target_ui_def_id,
               TEMPLATE_NAME,
               TEMPLATE_TYPE,
               TEMPLATE_DESC,
               PARENT_CONTAINER_TYPE,
               l_target_jrad_doc,
               BUTTON_BAR_TEMPLATE_ID,
               MESSAGE_TYPE,
               MAIN_MESSAGE_ID,
               TITLE_ID,
               G_NO_FLAG,
               LAYOUT_UI_STYLE,
               ROOT_REGION_TYPE,
               ROOT_ELEMENT_SIGNATURE_ID,
               TEMPLATE_REV_NBR,
               TEMPLATE_USAGE,
               AMN_USAGE,
               G_NO_FLAG
      FROM CZ_UI_TEMPLATES
     WHERE ui_def_id=p_source_ui_def_id AND
           template_id=p_source_template_id;

    INSERT INTO CZ_UI_REF_TEMPLATES
      (
      TEMPLATE_ID
      ,REF_TEMPLATE_ID
      ,DELETED_FLAG
      ,TEMPLATE_UI_DEF_ID
      ,REF_TEMPLATE_UI_DEF_ID
      )
    SELECT
      x_new_template_id
      ,REF_TEMPLATE_ID
      ,DELETED_FLAG
      ,p_target_ui_def_id
      ,REF_TEMPLATE_UI_DEF_ID
    FROM CZ_UI_REF_TEMPLATES
    WHERE template_id=p_source_template_id AND
          template_ui_def_id=p_source_ui_def_id AND
          deleted_flag=G_NO_FLAG;

    --
    -- unlock source UI Template
    --
    unlock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'copy_Local_Template', x_msg_data);
      DEBUG('copy_Local_Template() : '||x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );
  END copy_Local_Template;

  --
  -- This procedure creates a new copy of JRAD document specified by parameter p_source_jrad_doc
  -- new copy will have full JRAD path = p_target_jrad_doc
  --
  PROCEDURE copy_JRAD_Document(p_source_jrad_doc    IN VARCHAR2,   -- specify source JRAD document that will be copied
                               p_target_jrad_doc     IN VARCHAR2, -- specify full JRAD path of new copy
                               x_return_status  OUT NOCOPY VARCHAR2,-- status string
                               x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                               x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                               ) IS

    l_source_xmldoc  xmldom.DOMDocument;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_source_xmldoc := parse_JRAD_Document(p_doc_full_name => p_source_jrad_doc);

    IF xmldom.isNull(l_source_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => p_source_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    Save_Document(p_xml_doc   => l_source_xmldoc,
                  p_doc_name  => p_target_jrad_doc);

    translate_JRAD_Doc(p_target_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'copy_JRAD_Document', x_msg_data);
      DEBUG('copy_JRAD_Document() : '||x_msg_data);
  END copy_JRAD_Document;

  --
  --vsingava bug8688987 24th Jul '09
  -- This procedure moves the JRAD document specified by parameter p_source_jrad_doc
  -- from p_source_ui_def_id to p_target_ui_def_id
  --

  PROCEDURE move_JRAD_Document (p_source_jrad_doc IN VARCHAR2,      -- jrad_doc of a ui page to be moved
                          p_source_page_id         IN  NUMBER,      -- ui page_id of the page being moved
                          p_source_ui_def_id       IN NUMBER,         -- ui_def_id of UI
                          p_target_ui_def_id  IN NUMBER,        -- ui_def_id of target UI
                          x_new_jrad_doc    OUT NOCOPY VARCHAR2,-- jrad_doc of moved UI page doc
                          x_return_status  OUT NOCOPY VARCHAR2,-- status string
                          x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                          x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                          ) IS
  BEGIN
  x_new_jrad_doc := SUBSTR(p_source_jrad_doc, 1, INSTR(p_source_jrad_doc, 'ui' || p_source_ui_def_id ) + 2 + LENGTH(p_source_ui_def_id ));
  x_new_jrad_doc := REPLACE(x_new_jrad_doc, to_char(p_source_ui_def_id), to_char(p_target_ui_def_id))  || 'Page_' || TO_CHAR(p_source_page_id);
  copy_JRAD_Document(p_source_jrad_doc, x_new_jrad_doc, x_return_status, x_msg_count, x_msg_data);
  --delete the original document
    BEGIN
      jdr_docbuilder.deleteDocument(p_source_jrad_doc);
      NULL;
    EXCEPTION
      WHEN OTHERS THEN
        DEBUG('delete_UIXML_Page() : '||SQLERRM);
    END;
  END move_JRAD_Document;

  --
  -- This procedure copies subtree of Local UI Template identified by ui_def_id=p_source_ui_def_id,
  -- template_id=p_source_template_id and element_id=p_source_element_id to a new place identified by
  -- ui_def_id=p_target_ui_def_id, template_id=p_target_template_id and
  -- parent_element_id=p_target_parent_element_id.
  --
  PROCEDURE copy_Local_Template_Elem(p_source_ui_def_id       IN NUMBER,         -- ui_def_id of UI
                                     p_source_template_id    IN NUMBER,          -- template_id of
                                                                                 -- Local UI Template which needs
                                                                                 -- to be copied
                                     p_source_element_id     IN VARCHAR2,
                                     p_target_ui_def_id      IN NUMBER,          -- ui_def_id of UI
                                     p_target_template_id    IN NUMBER,          -- template_id of
                                                                                 -- Local UI Template which needs
                                                                                 -- to be copied
                                     p_target_parent_element_id IN VARCHAR2,
                                     x_new_element_id OUT NOCOPY VARCHAR2,       -- template_id of
                                                                                 -- Local UI Template which needs
                                                                                 -- to be copied
                                     x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                     x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                     x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                     ) IS

    l_source_xmldoc            xmldom.DOMDocument;
    l_target_xmldoc            xmldom.DOMDocument;
    l_source_xml_node          xmldom.DOMNode;
    l_xml_uicont_node          xmldom.DOMNode;
    l_xml_new_node             xmldom.DOMNode;
    l_target_xml_node          xmldom.DOMNode;
    l_new_xml_root_node        xmldom.DOMNode;
    l_out_xml_node             xmldom.DOMNode;
    l_target_uicont_xml_node   xmldom.DOMNode;
    l_xml_temp_node            xmldom.DOMNode;
    l_stacklayout_node            xmldom.DOMNode;
    l_stacklayout_uicont_xml_node xmldom.DOMNode;
    l_source_jrad_doc          CZ_UI_PAGES.jrad_doc%TYPE;
    l_target_jrad_doc          CZ_UI_PAGES.jrad_doc%TYPE;
    l_needs_to_be_unlocked     BOOLEAN;
  BEGIN

    --
    -- lock source UI Template
    --
    lock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    SELECT jrad_doc INTO l_source_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_source_ui_def_id AND
          template_id=p_source_template_id;

    SELECT jrad_doc INTO l_target_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_target_ui_def_id AND
          template_id=p_target_template_id;

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_source_xmldoc := parse_JRAD_Document(p_doc_full_name => l_source_jrad_doc);

    IF xmldom.isNull(l_source_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_source_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    --
    -- create UI Template in JRAD repository
    --
    l_target_xmldoc := parse_JRAD_Document(p_doc_full_name => l_target_jrad_doc);

    IF xmldom.isNull(l_target_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_target_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_source_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_source_xmldoc,
                                                    p_attribute_name  => G_ID_ATTRIBUTE,
                                                    p_attribute_value => p_source_element_id);

    IF p_target_parent_element_id IS NULL THEN
      l_target_xml_node := xmldom.makeNode(xmldom.getDocumentElement(l_target_xmldoc));
    ELSE
      l_target_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_target_xmldoc,
                                                      p_attribute_name  => G_ID_ATTRIBUTE,
                                                      p_attribute_value => p_target_parent_element_id);
    END IF;

    l_target_uicont_xml_node := getUIContents(l_target_xml_node, G_YES_FLAG);

    IF xmldom.IsNull(l_target_uicont_xml_node) THEN
      l_xml_temp_node := xmldom.makeNode(xmldom.createElement(l_target_xmldoc, 'ui:contents'));
      l_target_uicont_xml_node := xmldom.appendChild(l_target_xml_node,
                                                     l_xml_temp_node);
    END IF;

    --
    -- returns cloned DOM subtree
    --
    -- l_new_xml_root_node := xmldom.cloneNode(l_source_xml_node, TRUE);
    l_new_xml_root_node := cloneNode(l_source_xml_node, l_target_uicont_xml_node);

    x_new_element_id := get_Element_Id();

    set_Attribute(l_new_xml_root_node,
                  G_ID_ATTRIBUTE,
                  x_new_element_id);

    copy_User_Attributes(p_xml_node               => l_new_xml_root_node,
                         p_source_ui_def_id       => p_source_ui_def_id,
                         p_target_ui_def_id       => p_target_ui_def_id,
                         p_source_template_id     => p_source_template_id,
                         p_target_template_id     => p_target_template_id);

    IF xmldom.IsNull(l_target_uicont_xml_node) AND xmldom.getNodeName(l_target_xml_node)<>'ui:case' THEN
      l_xml_new_node := xmldom.makeNode(xmldom.createElement(l_target_xmldoc, 'ui:contents'));

      l_xml_uicont_node := xmldom.appendChild(l_target_xml_node,
                                              l_xml_new_node);

      l_out_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                           l_new_xml_root_node);

    ELSIF xmldom.IsNull(l_target_uicont_xml_node) AND  xmldom.getNodeName(l_target_xml_node)='ui:case' THEN
      l_stacklayout_node := findChildXMLTag(l_target_xml_node, 'oa:stackLayout');
      l_stacklayout_uicont_xml_node := getUIContents(l_stacklayout_node, G_YES_FLAG);
      IF xmldom.IsNull(l_stacklayout_uicont_xml_node) THEN

        l_xml_new_node := xmldom.makeNode(xmldom.createElement(l_target_xmldoc, 'ui:contents'));
        l_xml_uicont_node := xmldom.appendChild(l_stacklayout_node,
                                              l_xml_new_node);

        l_out_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                             l_new_xml_root_node);

      ELSE
        l_out_xml_node := xmldom.appendChild(l_stacklayout_uicont_xml_node,
                                             l_new_xml_root_node);
      END IF;

    ELSE
      l_out_xml_node := xmldom.appendChild(l_target_uicont_xml_node,
                                           l_new_xml_root_node);

    END IF;

    refresh_Templ_Ref_Counts(l_target_xmldoc, p_target_ui_def_id, p_target_template_id);

    Save_Document(p_xml_doc   => l_target_xmldoc,
                  p_doc_name  => l_target_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    /* *** changes for build 21p *** */

    UPDATE CZ_UI_TEMPLATES
       SET template_rev_nbr=NVL(template_rev_nbr,0)+1
     WHERE ui_def_id=p_target_ui_def_id AND template_id=p_target_template_id;

    --
    -- unlock source UI Template
    --
    unlock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'copy_Local_Template_Elem', x_msg_data);
      DEBUG('copy_Local_Template_Elem() : '||x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_source_template_id, p_source_ui_def_id, l_needs_to_be_unlocked );

  END copy_Local_Template_Elem;

  --
  -- create UI Region from Template
  --
  PROCEDURE create_Region_From_Template (p_ui_def_id       IN NUMBER,   -- ui_def_id of UI
                                         p_template_id     IN NUMBER,   -- template_id of
                                                                        -- Local UI Template which needs
                                                                        -- to be copied
                                         p_template_ui_def_id    IN NUMBER,
                                         p_ui_page_id            IN NUMBER,
                                         p_parent_element_id     IN VARCHAR2,          -- ui_def_id of target UI
                                         x_new_element_id        OUT NOCOPY VARCHAR2, -- element_id of new UI region
                                         x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                         x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                         x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                         ) IS

    l_template_xmldoc         xmldom.DOMDocument;
    l_xmldoc                  xmldom.DOMDocument;
    l_template_root_xml_node  xmldom.DOMNode;
    l_parent_xml_node         xmldom.DOMNode;
    l_out_xml_node            xmldom.DOMNode;
    l_target_uicont_xml_node  xmldom.DOMNode;
    l_new_xml_root_node       xmldom.DOMNode;
    l_xml_node                xmldom.DOMNode;

    l_source_xml_node          xmldom.DOMNode;
    l_xml_uicont_node          xmldom.DOMNode;
    l_xml_new_node             xmldom.DOMNode;
    l_target_xml_node          xmldom.DOMNode;
    l_stacklayout_node            xmldom.DOMNode;
    l_stacklayout_uicont_xml_node xmldom.DOMNode;

    l_switcher_element_id     VARCHAR2(255);
    l_old_ui_element_id       VARCHAR2(255);
    l_new_ui_element_id       VARCHAR2(255);
    l_old_switcher_xml_id     VARCHAR2(255);
    l_user_attribute3_value   VARCHAR2(4000);
    l_switcher_casename       VARCHAR2(255);
    l_switcher_xml_id         VARCHAR2(255);
    l_uicase_name             VARCHAR2(255);
    l_child_nodes_tbl         xmldom.DOMNodeList;
    l_template_jrad_doc       CZ_UI_PAGES.jrad_doc%TYPE;
    l_jrad_doc                CZ_UI_PAGES.jrad_doc%TYPE;
    l_ui_node                 CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_attribute_value         VARCHAR2(255);
    l_length                  NUMBER;
    l_needs_to_be_unlocked    BOOLEAN;

  BEGIN

    --
    -- lock source UI Template
    --
    lock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    set_Local_UI_Context(p_ui_def_id);

    --
    -- get full JRAD path of the given UI template
    --
    SELECT jrad_doc INTO l_template_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_template_ui_def_id AND template_id=p_template_id;

    SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_PAGES a
    WHERE ui_def_id=p_ui_def_id AND page_id=p_ui_page_id;


    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_template_xmldoc := parse_JRAD_Document(p_doc_full_name => l_template_jrad_doc);

    IF xmldom.isNull(l_template_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_template_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_jrad_doc);

    IF xmldom.isNull(l_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_parent_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_xmldoc,
                                                    p_attribute_name  => G_ID_ATTRIBUTE,
                                                    p_attribute_value => p_parent_element_id);

    l_ui_node := find_Parent_UI_Element(p_xml_node   => l_parent_xml_node,
                                        p_ui_def_id  => p_ui_def_id,
                                        p_ui_page_id => p_ui_page_id);

    l_target_uicont_xml_node := getUIContents(l_parent_xml_node);

    l_template_root_xml_node :=xmldom.makeNode(xmldom.getDocumentElement(l_template_xmldoc));

    x_new_element_id := get_Element_Id();

    set_Attribute(l_template_root_xml_node,
                  G_ID_ATTRIBUTE,
                  x_new_element_id);

    handle_USER_ATTRIBUTE10(p_xml_root_node => l_template_root_xml_node,
                            p_ui_def_id     => p_ui_def_id,
                            p_ui_page_id    => p_ui_page_id,
                            p_ui_element_id => x_new_element_id);

    l_child_nodes_tbl := xmldom.getElementsByTagName(l_template_xmldoc, '*');
    l_length := xmldom.getLength(l_child_nodes_tbl);
    IF (l_length > 0) THEN
        FOR k IN 0..l_length-1
        LOOP
          --
          -- get next child DOM node
          --
          l_xml_node := xmldom.item(l_child_nodes_tbl, k);

          handle_UI_CASE_Id(l_xml_node);

          IF k > 0 THEN
            l_attribute_value := get_Attribute_Value(l_xml_node, G_ID_ATTRIBUTE);

            /*
            IF l_attribute_value IS NOT NULL THEN
              set_Attribute(xmldom.makeElement(l_xml_node),G_ID_ATTRIBUTE,l_attribute_value||'_'||x_new_element_id);
              --
              -- create a new copies for corresponding entities ( captions, rules ,... )
              --
              copy_Node_Related_Entities(p_ui_def_id   => p_ui_def_id,
                                         p_ui_page_id  => p_ui_page_id,
                                         p_xml_node    => l_xml_node);
            */
	    l_parent_xml_node := xmldom.getParentNode(l_xml_node);
            IF l_attribute_value IS NOT NULL THEN
              --l_parent_xml_node := xmldom.getParentNode(l_xml_node);

              IF xmldom.getNodeName(l_xml_node)='ui:case' OR
                 ( NOT(xmldom.isNull(l_parent_xml_node)) AND xmldom.getNodeName(l_xml_node)='oa:stackLayout' AND
                   xmldom.getNodeName(l_parent_xml_node)='ui:case') THEN

                l_switcher_element_id := find_Element_Id_Of_XMLTag(l_xml_node, 'oa:switcher');

                l_old_ui_element_id := SUBSTR(l_attribute_value,1,INSTR(l_attribute_value, '_')-1);

                l_new_ui_element_id := REPLACE(REPLACE(REPLACE(l_attribute_value,
                                               l_old_ui_element_id,
                                               l_switcher_element_id),'_czt','_czn'),'_czc','_czn');
                  set_Attribute(xmldom.makeElement(l_xml_node),
                                G_ID_ATTRIBUTE,
                                l_new_ui_element_id);

                IF xmldom.getNodeName(l_parent_xml_node)='oa:switcher' THEN
                  l_switcher_xml_id := get_Attribute_Value(l_parent_xml_node, G_ID_ATTRIBUTE);
                  l_uicase_name     := get_Attribute_Value(l_xml_node, 'name');
                  set_Attribute(xmldom.makeElement(l_xml_node),
                                 'name',
                                  REPLACE(REPLACE(REPLACE(l_uicase_name,l_old_switcher_xml_id,l_switcher_xml_id),'_czt','_czn'),'_czc','_czn'));
                END IF;
	    --
            -- if current tag is <oa:stackLayout>
            -- then replace old id with new one
            --

		IF (xmldom.getNodeName(l_xml_node)='oa:stackLayout' AND
		    xmldom.getNodeName(l_parent_xml_node)='ui:case') AND l_attribute_value IS NOT NULL
		THEN
                 set_Attribute(xmldom.makeElement(l_xml_node),
                            G_ID_ATTRIBUTE,
                           REPLACE(REPLACE(get_Attribute_Value(l_parent_xml_node, 'name'),'_czt','_czn'),'_czc','_czn'));
                END IF;
              ELSE
                set_Attribute(xmldom.makeElement(l_xml_node),G_ID_ATTRIBUTE,REPLACE(REPLACE(l_attribute_value,'_czt','_czn'),'_czc','_czn')||'_'||x_new_element_id);
                IF xmldom.getNodeName(l_xml_node)='oa:switcher' THEN
                  l_old_switcher_xml_id := l_attribute_value;
                  l_user_attribute3_value := get_Attribute_Value(l_xml_node, G_USER_ATTRIBUTE3_NAME);
                  l_switcher_casename := get_User_Attribute(l_user_attribute3_value ,'switcherDefaultCaseName');
                  l_switcher_casename := REPLACE(l_switcher_casename,l_attribute_value, REPLACE(REPLACE(l_attribute_value,'_czt','_czn'),'_czc','_czn')||'_'||x_new_element_id);
                  set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                                     p_cz_attribute_value   => l_switcher_casename,
                                     px_xml_attribute_value => l_user_attribute3_value);

                  set_Attribute(l_xml_node,
                                G_USER_ATTRIBUTE3_NAME,
                                l_user_attribute3_value);
                END IF; -- end of IF xmldom.getNodeName(l_xml_node)='oa:switcher'
              END IF; -- end of IF xmldom.getNodeName(l_xml_node)='ui:case'
              --
              -- create a new copies for corresponding entities ( captions, rules ,... )
              --
              copy_Node_Related_Entities(p_ui_def_id   => p_ui_def_id,
                                         p_ui_page_id  => p_ui_page_id,
                                         p_xml_node    => l_xml_node,
                                         p_source_ui_page_id =>0,
                                         p_source_ui_def_id =>p_template_ui_def_id);

         ELSE --of IF l_attribute_value IS NOT NULL

            --
            -- set value of user attribute "switcherDefaultCaseName" to new jrad id of <oa:switcher>
            --

             IF (xmldom.getNodeName(l_xml_node)='ui:case' AND xmldom.getNodeName(l_parent_xml_node)='oa:switcher')
	     THEN
              l_switcher_xml_id := get_Attribute_Value(l_parent_xml_node, G_ID_ATTRIBUTE);
              l_uicase_name     :=  get_Attribute_Value(l_xml_node, 'name');
              set_Attribute(xmldom.makeElement(l_xml_node),
                            'name',
                            REPLACE(REPLACE(REPLACE(l_uicase_name,l_old_switcher_xml_id,l_switcher_xml_id),'_czt','_czn'),'_czc','_czn'));

              handle_UI_CASE_Id(l_xml_node);
            END IF;

            END IF; -- end of IF l_attribute_value IS NOT NULL

            --++++++ add template references ++++++
            add_Extends_Refs(p_xml_node  => l_xml_node,
                             p_ui_node   => l_ui_node);

          END IF; -- end  of IF k > 0
        END LOOP;
    END IF;

    --
    -- returns cloned DOM subtree
    --
    -- l_new_xml_root_node := xmldom.cloneNode(l_template_root_xml_node, TRUE);
    l_new_xml_root_node := cloneNode(l_template_root_xml_node, l_target_uicont_xml_node);


    IF xmldom.IsNull(l_target_uicont_xml_node) AND xmldom.getNodeName(l_parent_xml_node)<>'ui:case' THEN
      l_xml_new_node := xmldom.makeNode(xmldom.createElement(l_xmldoc, 'ui:contents'));
      l_xml_uicont_node := xmldom.appendChild(l_parent_xml_node,
                                              l_xml_new_node);
      l_out_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                           l_new_xml_root_node);

    ELSIF xmldom.IsNull(l_target_uicont_xml_node) AND  xmldom.getNodeName(l_parent_xml_node)='ui:case' THEN

      l_stacklayout_node := findChildXMLTag(l_parent_xml_node, 'oa:stackLayout');
      l_stacklayout_uicont_xml_node := getUIContents(l_stacklayout_node, G_YES_FLAG);
      IF xmldom.IsNull(l_stacklayout_uicont_xml_node) THEN

        l_xml_new_node := xmldom.makeNode(xmldom.createElement(l_xmldoc, 'ui:contents'));
        l_xml_uicont_node := xmldom.appendChild(l_stacklayout_node,
                                              l_xml_new_node);
        l_out_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                             l_new_xml_root_node);

      ELSE
        l_out_xml_node := xmldom.appendChild(l_stacklayout_uicont_xml_node,
                                             l_new_xml_root_node);
      END IF;

    ELSE
      l_out_xml_node := xmldom.appendChild(l_target_uicont_xml_node,
                                           l_new_xml_root_node);

    END IF;

    Save_Document(p_xml_doc   => l_xmldoc,
                  p_doc_name  => l_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    UPDATE CZ_UI_PAGES
       SET page_rev_nbr=page_rev_nbr+1
     WHERE ui_def_id=p_ui_def_id AND
           page_id=p_ui_page_id;

    --
    -- unlock source UI Template
    --
    unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'create_Region_From_Template', x_msg_data);
      DEBUG('create_Region_From_Template() : '||x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

  END create_Region_From_Template;

  PROCEDURE add_Template_To_Template (p_template_id                 IN NUMBER,
                                      p_template_ui_def_id          IN NUMBER,
                                      p_target_template_id          IN NUMBER,
                                      p_target_template_ui_def_id   IN NUMBER,
                                      p_parent_element_id           IN VARCHAR2,          -- ui_def_id of target UI
                                      x_new_element_id        OUT NOCOPY VARCHAR2, -- element_id of new UI region
                                      x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                      x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                      x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                      ) IS

    l_template_xmldoc         xmldom.DOMDocument;
    l_xmldoc                  xmldom.DOMDocument;
    l_template_root_xml_node  xmldom.DOMNode;
    l_parent_xml_node         xmldom.DOMNode;
    l_temp_parent_xml_node    xmldom.DOMNode;
    l_out_xml_node            xmldom.DOMNode;
    l_target_uicont_xml_node  xmldom.DOMNode;
    l_new_xml_root_node       xmldom.DOMNode;
    l_xml_node                xmldom.DOMNode;
    l_stacklayout_node        xmldom.DOMNode;
    l_xml_new_node            xmldom.DOMNode;
    l_xml_uicont_node         xmldom.DOMNode;
    l_stacklayout_uicont_xml_node xmldom.DOMNode;
    l_xml_switcher_id         VARCHAR2(255);
    l_switcher_element_id     VARCHAR2(255);
    l_old_ui_element_id       VARCHAR2(255);
    l_new_ui_element_id       VARCHAR2(255);
    l_user_attribute3_value   VARCHAR2(4000);
    l_switcher_casename       VARCHAR2(255);
    l_child_nodes_tbl         xmldom.DOMNodeList;
    l_template_jrad_doc        CZ_UI_PAGES.jrad_doc%TYPE;
    l_target_template_jrad_doc CZ_UI_PAGES.jrad_doc%TYPE;
    l_attribute_value         VARCHAR2(255);
    l_length                  NUMBER;
    l_needs_to_be_unlocked    BOOLEAN;
  BEGIN

    --
    -- lock source UI Template
    --
    lock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- get full JRAD path of the given UI template
    --
    SELECT jrad_doc INTO l_template_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_template_ui_def_id AND template_id=p_template_id;

    SELECT jrad_doc INTO l_target_template_jrad_doc FROM CZ_UI_TEMPLATES
    WHERE ui_def_id=p_target_template_ui_def_id AND template_id=p_target_template_id;

    --
    -- open XML parser
    --
    Open_Parser();

    --
    -- create UI Template in JRAD repository
    --
    l_template_xmldoc := parse_JRAD_Document(p_doc_full_name => l_template_jrad_doc);

    IF xmldom.isNull(l_template_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_template_jrad_doc,
                        p_fatal_error  => TRUE);

      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_target_template_jrad_doc);

    IF xmldom.isNull(l_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_template_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    IF p_parent_element_id IS NULL THEN
      l_parent_xml_node := xmldom.makeNode(xmldom.getDocumentElement(l_xmldoc));
    ELSE
      l_parent_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_xmldoc,
                                                      p_attribute_name  => G_ID_ATTRIBUTE,
                                                      p_attribute_value => p_parent_element_id);
    END IF;

    l_target_uicont_xml_node := getUIContents(l_parent_xml_node,G_YES_FLAG);

    l_template_root_xml_node := xmldom.makeNode(xmldom.getDocumentElement(l_template_xmldoc));

    x_new_element_id := get_Element_Id();

    l_new_ui_element_id := x_new_element_id;

    set_Attribute(l_template_root_xml_node,
                  G_ID_ATTRIBUTE,
                  x_new_element_id);

    l_child_nodes_tbl := xmldom.getElementsByTagName(l_template_xmldoc, '*');
    l_length := xmldom.getLength(l_child_nodes_tbl);
    IF (l_length > 0) THEN
        FOR k IN 0..l_length-1
        LOOP
          --
          -- get next child DOM node
          --
          l_xml_node := xmldom.item(l_child_nodes_tbl, k);

          l_attribute_value := get_Attribute_Value(l_xml_node, G_ID_ATTRIBUTE);
          l_new_ui_element_id := l_attribute_value||'_'||x_new_element_id;

          handle_Special_XMLCases(p_xml_node         => l_xml_node,
                                  p_old_xml_node_id  => l_attribute_value,
                                  p_new_xml_node_id  => l_new_ui_element_id,
                                  p_jrad_doc         => l_template_jrad_doc,
                                  px_xml_switcher_id => l_xml_switcher_id,
                                  p_inline_copy_mode => G_INLINE_COPY_TMPL);


          IF k > 0 THEN

            l_user_attribute3_value := get_Attribute_Value(l_xml_node, G_USER_ATTRIBUTE3_NAME);

            IF l_user_attribute3_value IS NOT NULL THEN

              handle_Template_Attributes
                  (px_user_attribute_value => l_user_attribute3_value,
                   p_new_element_id        => l_new_ui_element_id,
                   p_source_ui_def_id      => p_template_ui_def_id,
                   p_source_template_id    => p_template_id,
                   p_target_ui_def_id      => p_target_template_ui_def_id,
                   p_target_template_id    => p_target_template_id,
                   p_xml_node              => l_xml_node);

                 set_Attribute(l_xml_node,
                               G_USER_ATTRIBUTE3_NAME,
                               l_user_attribute3_value);

            END IF; -- end of IF l_attribute_value IS NOT NULL

          END IF; -- end  of IF k > 0
        END LOOP;
    END IF;

    --
    -- remove common attributes of container and subtree
    --
    remove_TopLevel_Attributes(l_template_root_xml_node);


    --
    -- returns cloned DOM subtree
    --
    -- l_new_xml_root_node := xmldom.cloneNode(l_template_root_xml_node, TRUE);
    l_new_xml_root_node := cloneNode(l_template_root_xml_node, l_parent_xml_node);


    IF xmldom.IsNull(l_target_uicont_xml_node) AND xmldom.getNodeName(l_parent_xml_node)<>'ui:case' THEN
      l_xml_new_node := xmldom.makeNode(xmldom.createElement(l_xmldoc, 'ui:contents'));
      l_xml_uicont_node := xmldom.appendChild(l_parent_xml_node,
                                              l_xml_new_node);
      l_out_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                           l_new_xml_root_node);
    ELSIF xmldom.IsNull(l_target_uicont_xml_node) AND  xmldom.getNodeName(l_parent_xml_node)='ui:case' THEN
      l_stacklayout_node := findChildXMLTag(l_parent_xml_node, 'oa:stackLayout');
      l_stacklayout_uicont_xml_node := getUIContents(l_stacklayout_node, G_YES_FLAG);
      IF xmldom.IsNull(l_stacklayout_uicont_xml_node) THEN

        l_xml_new_node := xmldom.makeNode(xmldom.createElement(l_xmldoc, 'ui:contents'));
        l_xml_uicont_node := xmldom.appendChild(l_stacklayout_node,
                                              l_xml_new_node);
        l_out_xml_node := xmldom.appendChild(l_xml_uicont_node,
                                             l_new_xml_root_node);

      ELSE
        l_out_xml_node := xmldom.appendChild(l_stacklayout_uicont_xml_node,
                                             l_new_xml_root_node);
      END IF;

    ELSE
      l_out_xml_node := xmldom.appendChild(l_target_uicont_xml_node,
                                           l_new_xml_root_node);
    END IF;

    refresh_Templ_Ref_Counts(l_xmldoc, p_target_template_ui_def_id, p_target_template_id);

    Save_Document(p_xml_doc   => l_xmldoc,
                  p_doc_name  => l_target_template_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    UPDATE CZ_UI_TEMPLATES
       SET template_rev_nbr=template_rev_nbr+1
     WHERE template_id=p_target_template_id AND
           ui_def_id=p_target_template_ui_def_id;

    --
    -- unlock source UI Template
    --
    unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'add_Template_To_Template', x_msg_data);
      DEBUG('create_Region_From_Template() : '||x_msg_data);
      --
      -- unlock source UI Template
      --
      unlock_UI_Template( p_template_id, p_template_ui_def_id, l_needs_to_be_unlocked );

  END add_Template_To_Template;

  --
  -- create UI Region from Template
  -- This procedure works for both UI pages and UI templates
  -- Developer calls this procedure for converting UI template reference
  -- within either UI page or UI template
  -- If p_ui_def_id = 0 then this is a template case and template_id is passed to p_ui_page_id
  -- interface needs to be changed if we implement local UI templates, since the code uses ui_def_id = 0
  -- to tell when it is working with templates
  --
  PROCEDURE convert_Template_Reference  (p_ui_def_id      IN NUMBER,
                                         p_ui_page_id     IN NUMBER,
                                         p_element_id     IN VARCHAR2,
                                         x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                         x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                         x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                         ) IS

    l_template_xmldoc         xmldom.DOMDocument;
    l_xmldoc                  xmldom.DOMDocument;
    l_template_root_xml_node  xmldom.DOMNode;
    l_out_xml_node            xmldom.DOMNode;
    l_curr_parent_xml_node    xmldom.DOMNode;
    l_new_xml_root_node       xmldom.DOMNode;
    l_xml_node                xmldom.DOMNode;
    l_root_xml_node           xmldom.DOMNode;
    l_parent_xml_node         xmldom.DOMNode;
    l_child_nodes_tbl         xmldom.DOMNodeList;
    l_template_jrad_doc       CZ_UI_PAGES.jrad_doc%TYPE;
    l_jrad_doc                CZ_UI_PAGES.jrad_doc%TYPE;
    l_ui_node                 CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_node_map_tbl            xmldom.DOMNamedNodeMap;
    l_node_attr               xmldom.DOMNode;
    l_prev_xml_node           xmldom.DOMNode;
    l_root_attr_names_tbl     varchar_tbl_type;
    l_root_attr_values_tbl    varchar_tbl_type;

    l_root_element_signature_id NUMBER;
    l_attr_value                VARCHAR2(32000);
    l_attribute_value           VARCHAR2(32000);
    l_user4_attribute_value     VARCHAR2(32000);
    l_new_id_attribute          VARCHAR2(32000);
    l_new_attribute_value       VARCHAR2(32000);
    l_switcher_element_id       VARCHAR2(4000);
    l_old_ui_element_id         VARCHAR2(4000);
    l_new_ui_element_id         VARCHAR2(4000);
    l_old_switcher_xml_id       VARCHAR2(4000);
    l_switcher_casename         VARCHAR2(4000);
    l_xml_node_name             VARCHAR2(4000);
    l_switcher_xml_id           VARCHAR2(4000);
    l_uicase_name               VARCHAR2(4000);
    l_hgrid_element_id          VARCHAR2(4000);
    l_ancestor_node             VARCHAR2(4000);
    l_user_attribute3_value     VARCHAR2(32000);
    l_extends_attribute         VARCHAR2(255);
    l_id_attribute              VARCHAR2(255);
    l_ref_template_id           NUMBER;
    l_target_ref_count          NUMBER;
    l_ref_count                 NUMBER;
    l_length                    NUMBER;
    l_index                     NUMBER;

  BEGIN

    set_Local_UI_Context(p_ui_def_id);

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    IF (p_ui_def_id=0) THEN
      SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_TEMPLATES
      WHERE template_id=p_ui_page_id AND ui_def_id=p_ui_def_id;
    ELSE
      SELECT jrad_doc INTO l_jrad_doc FROM CZ_UI_PAGES
      WHERE page_id=p_ui_page_id AND ui_def_id=p_ui_def_id;

    END IF;

    --
    -- open XML parser
    --
    Open_Parser();

    l_xmldoc := parse_JRAD_Document(p_doc_full_name => l_jrad_doc);

    IF xmldom.isNull(l_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_root_xml_node := find_XML_Node_By_Attribute(p_subtree_doc     => l_xmldoc,
                                                  p_attribute_name  => G_ID_ATTRIBUTE,
                                                  p_attribute_value => p_element_id);

    l_id_attribute      := get_Attribute_Value(l_root_xml_node,
                                               G_ID_ATTRIBUTE);

    IF p_ui_def_id<>0 THEN

      l_ui_node := find_Parent_UI_Element(p_xml_node   => l_root_xml_node,
                                          p_ui_def_id  => p_ui_def_id,
                                          p_ui_page_id => p_ui_page_id);

      IF l_ui_node.persistent_node_id IS NULL OR l_ui_node.persistent_node_id=0 THEN
        l_ui_node.element_id := l_ui_node.parent_element_id;
        UPDATE CZ_UI_PAGE_ELEMENTS
           SET deleted_flag=G_YES_FLAG
         WHERE ui_def_id=p_ui_def_id AND page_id=p_ui_page_id AND
               element_id=p_element_id;
      ELSE
        l_ui_node.element_id := p_element_id;
      END IF;

    END IF;

    l_new_id_attribute  := get_Element_Id();

    l_extends_attribute := get_Attribute_Value(l_root_xml_node,
                                               'extends');
    BEGIN
      SELECT template_id, jrad_doc, root_element_signature_id
        INTO l_ref_template_id, l_template_jrad_doc, l_root_element_signature_id
        FROM CZ_UI_TEMPLATES
      WHERE ui_def_id=p_ui_def_id AND jrad_doc=l_extends_attribute AND
            deleted_flag=G_NO_FLAG;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT template_id, jrad_doc, root_element_signature_id
          INTO l_ref_template_id, l_template_jrad_doc, l_root_element_signature_id FROM CZ_UI_TEMPLATES
        WHERE ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID AND
              jrad_doc=l_extends_attribute AND
              deleted_flag=G_NO_FLAG;
    END;


    IF p_ui_def_id = 0 THEN
      SELECT ref_count
        INTO l_ref_count
        FROM CZ_UI_REF_TEMPLATES
      WHERE template_id=p_ui_page_id AND
            ref_template_id=l_ref_template_id AND
            deleted_flag=G_NO_FLAG;

      IF l_ref_count=1 THEN
        DELETE FROM CZ_UI_REF_TEMPLATES
         WHERE template_id=p_ui_page_id AND
               ref_template_id=l_ref_template_id AND
               deleted_flag=G_NO_FLAG;
      ELSIF l_ref_count>1 THEN
        UPDATE CZ_UI_REF_TEMPLATES
           SET ref_count = ref_count-1
         WHERE template_id=p_ui_page_id AND
               ref_template_id=l_ref_template_id AND
               deleted_flag=G_NO_FLAG;
      END IF;

      FOR reft IN (SELECT * FROM CZ_UI_REF_TEMPLATES
                    WHERE template_id=l_ref_template_id AND
                          deleted_flag=G_NO_FLAG)
      LOOP

        SELECT NVL(MAX(ref_count),0) INTO l_target_ref_count FROM CZ_UI_REF_TEMPLATES
         WHERE template_id=p_ui_page_id AND
               ref_template_id=reft.ref_template_id AND
               deleted_flag=G_NO_FLAG;

        IF l_target_ref_count=0 THEN

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
          VALUES
          (
           p_ui_page_id
          ,reft.ref_template_id
          ,G_NO_FLAG
          ,p_ui_def_id
          ,reft.REF_TEMPLATE_UI_DEF_ID
          ,G_NO_FLAG
          ,reft.REF_TEMPL_SEEDED_FLAG
          ,reft.ref_count
          );

        ELSE

          UPDATE CZ_UI_REF_TEMPLATES
             SET ref_count=ref_count+l_target_ref_count
           WHERE template_id=p_ui_page_id AND
                 ref_template_id=reft.ref_template_id AND
                 deleted_flag=G_NO_FLAG;

        END IF;

      END LOOP;

    END IF;


    l_template_xmldoc := parse_JRAD_Document(p_doc_full_name => l_template_jrad_doc);

    IF xmldom.isNull(l_template_xmldoc) THEN
      add_Error_Message(p_message_name => 'CZ_WRONG_UI_TEMPLATE',
                        p_token_name   => 'UI_TEMPLATE',
                        p_token_value  => l_template_jrad_doc,
                        p_fatal_error  => TRUE);
      RAISE WRONG_UI_TEMPLATE;
    END IF;

    l_parent_xml_node := xmldom.getParentNode(l_root_xml_node);
    l_prev_xml_node := xmldom.getNextSibling(l_root_xml_node);

    l_template_root_xml_node :=xmldom.makeNode(xmldom.getDocumentElement(l_template_xmldoc));

    l_node_map_tbl := xmldom.getAttributes(l_root_xml_node);
    IF (xmldom.isNull(l_node_map_tbl) = FALSE) THEN
      l_length := xmldom.getLength(l_node_map_tbl);
      --
      -- loop through attributes
      --
      FOR i IN 0 .. l_length - 1
      LOOP
        l_node_attr := xmldom.item(l_node_map_tbl, i);
        IF xmldom.getNodeName(l_node_attr) <> 'extends' THEN
          l_index := l_root_attr_names_tbl.COUNT + 1;
          l_root_attr_names_tbl(l_index) := xmldom.getNodeName(l_node_attr);
          l_root_attr_values_tbl(l_index):= xmldom.getNodeValue(l_node_attr);
        END IF;
      END LOOP;
    END IF;

    l_child_nodes_tbl := xmldom.getElementsByTagName(l_template_xmldoc, '*');
    l_length := xmldom.getLength(l_child_nodes_tbl);
    IF (l_length > 0) THEN
        FOR k IN 0..l_length-1
        LOOP
          --
          -- get next child DOM node
          --
          l_xml_node := xmldom.item(l_child_nodes_tbl, k);
          l_curr_parent_xml_node := xmldom.getParentNode(l_xml_node);

          IF k > 0 THEN

            l_xml_node_name := xmldom.getNodeName(l_xml_node);

            l_attribute_value := get_Attribute_Value(l_xml_node, G_ID_ATTRIBUTE);

            IF l_attribute_value IS NOT NULL THEN --???
              l_new_attribute_value := handle_JRAD_Id(l_attribute_value,l_new_id_attribute);
              set_Attribute(xmldom.makeElement(l_xml_node),G_ID_ATTRIBUTE,REPLACE(REPLACE(l_new_attribute_value,'_czt','_czn'),'_czc','_czn'));
            END IF;

            l_ancestor_node := get_Attribute_Value(l_xml_node,
                                                   'ancestorNode');
            IF l_ancestor_node IS NOT NULL THEN

              l_hgrid_element_id := find_Element_Id_Of_XMLTag(l_xml_node, 'oa:tree');
              IF NOT(xmldom.IsNull(l_xml_node)) THEN
                l_ancestor_node := l_jrad_doc||'.'||l_hgrid_element_id;

                set_Attribute(l_xml_node,
                              'ancestorNode',
                              l_ancestor_node);
              END IF;
            END IF;

            --
            -- set value of user attribute "switcherDefaultCaseName" to new jrad id of <oa:switcher>
            --
            IF xmldom.getNodeName(l_xml_node)='oa:switcher' THEN
              l_old_switcher_xml_id := l_attribute_value;
              l_user_attribute3_value := get_Attribute_Value(l_xml_node, G_USER_ATTRIBUTE3_NAME);
              l_switcher_casename := get_User_Attribute(l_user_attribute3_value ,'switcherDefaultCaseName');
              l_switcher_casename := REPLACE(REPLACE(REPLACE(l_switcher_casename,l_attribute_value, l_new_attribute_value),'_czt','_czn'),'_czc','_czn');
              set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                                 p_cz_attribute_value   => l_switcher_casename,
                                 px_xml_attribute_value => l_user_attribute3_value);

              set_Attribute(l_xml_node,
                            G_USER_ATTRIBUTE3_NAME,
                            l_user_attribute3_value);
            END IF;

            --
            -- set value of attribute "name" of <ui:case> to id of parent <oa:switcher>
            --
            IF (l_xml_node_name='ui:case' AND xmldom.getNodeName(l_curr_parent_xml_node)='oa:switcher') THEN
              l_switcher_xml_id := get_Attribute_Value(l_curr_parent_xml_node, G_ID_ATTRIBUTE);
              l_uicase_name     :=  get_Attribute_Value(l_xml_node, 'name');
              set_Attribute(xmldom.makeElement(l_xml_node),
                            'name',
                            REPLACE(REPLACE(REPLACE(l_uicase_name,l_old_switcher_xml_id,l_switcher_xml_id),'_czt','_czn'),'_czc','_czn'));
              handle_UI_CASE_Id(l_xml_node);
            END IF;

            --
            -- if current tag is <oa:stackLayout>
            -- then replace old id with new one
            --
            IF (l_xml_node_name='oa:stackLayout' AND
               xmldom.getNodeName(l_curr_parent_xml_node)='ui:case') AND l_attribute_value IS NOT NULL THEN
              set_Attribute(xmldom.makeElement(l_xml_node),
                            G_ID_ATTRIBUTE,
                           REPLACE(REPLACE(get_Attribute_Value(l_curr_parent_xml_node, 'name'),'_czt','_czn'),'_czc','_czn'));
            END IF;

            IF l_attribute_value IS NOT NULL THEN
              --
              -- create a new copies for corresponding entities ( captions, rules ,... )
              --
              copy_Node_Related_Entities(p_ui_def_id   => p_ui_def_id,
                                         p_ui_page_id  => p_ui_page_id,
                                         p_xml_node    => l_xml_node,
                                         p_source_ui_page_id =>0,
                                         p_source_ui_def_id =>0);
            END IF;

            IF p_ui_def_id <> 0 THEN
              --++++++ add template references ++++++
              add_Extends_Refs(p_xml_node  => l_xml_node,
                               p_ui_node   => l_ui_node);
            END IF;

          END IF;  -- end of IF k > 0 THEN
        END LOOP;  -- end of FOR k IN 0..l_length-1
    END IF; -- end of IF (l_length > 0) THEN

    l_out_xml_node:=xmldom.removeChild(l_parent_xml_node,l_root_xml_node);

    --
    -- remove common attributes of container and subtree
    --
    remove_TopLevel_Attributes(l_template_root_xml_node);

    --
    -- returns cloned DOM subtree
    --
    --l_new_xml_root_node := xmldom.cloneNode(l_template_root_xml_node, TRUE);
    l_new_xml_root_node := cloneNode(l_template_root_xml_node, l_root_xml_node);

    l_out_xml_node := insert_before(l_parent_xml_node,l_new_xml_root_node,l_prev_xml_node);


    IF l_root_attr_names_tbl.COUNT > 0 THEN
      FOR i IN l_root_attr_names_tbl.First..l_root_attr_names_tbl.Last
      LOOP
        IF l_root_attr_names_tbl(i)=G_USER_ATTRIBUTE4_NAME THEN
           l_user4_attribute_value := l_root_attr_values_tbl(i);
           set_User_Attribute(p_cz_attribute_name    => 'elementType',
                              p_cz_attribute_value   => l_root_element_signature_id,
                              px_xml_attribute_value => l_user4_attribute_value);
           set_Attribute(l_out_xml_node, G_USER_ATTRIBUTE4_NAME, l_user4_attribute_value);
        ELSE
           set_Attribute(l_out_xml_node, l_root_attr_names_tbl(i), l_root_attr_values_tbl(i));
        END IF;

      END LOOP;
    END IF;

    handle_USER_ATTRIBUTE10(p_xml_root_node => l_out_xml_node,
                            p_ui_def_id     => p_ui_def_id,
                            p_ui_page_id    => p_ui_page_id,
                            p_ui_element_id => p_element_id);


    IF p_ui_def_id=0 THEN
      refresh_Templ_Ref_Counts(l_xmldoc, 0, p_ui_page_id);
    END IF;

    Save_Document(p_xml_doc   => l_xmldoc,
                  p_doc_name  => l_jrad_doc);

    --
    -- close XML parser
    --
    Close_Parser();

    if (p_ui_def_id=0)
    then
    UPDATE CZ_UI_TEMPLATES
       SET TEMPLATE_REV_NBR=TEMPLATE_REV_NBR+1
     WHERE ui_def_id=p_ui_def_id AND
           template_id=p_ui_page_id;
    else
    UPDATE CZ_UI_PAGES
       SET page_rev_nbr=page_rev_nbr+1
     WHERE ui_def_id=p_ui_def_id AND
           page_id=p_ui_page_id;
    end if;

  EXCEPTION
    WHEN WRONG_UI_TEMPLATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := g_MSG_COUNT;
      x_msg_data      := fnd_msg_pub.GET(g_MSG_COUNT,fnd_api.g_false);
      DEBUG(x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'convert_Template_Reference', x_msg_data);
      DEBUG('convert_Template_Reference() : '||x_msg_data);
  END convert_Template_Reference;

  --
  -- check UI condition
  --
  PROCEDURE validate_UI_Condition(p_ui_def_id      IN NUMBER,
                                  p_rule_id        IN NUMBER,
                                  p_rule_type      IN NUMBER,
                                  p_page_id        IN NUMBER,
                                  p_element_id     IN VARCHAR2,
                                  p_is_parser_open IN VARCHAR2 DEFAULT NULL) IS

    l_element_path  VARCHAR2(32000);
    l_run_id        NUMBER;

  BEGIN

    CZ_DEVELOPER_UTILS_PVT.verify_special_rule(p_rule_id => p_rule_id,
                                               p_name    => NULL,
                                               x_run_id  => l_run_id);

    IF l_run_id > 0 THEN
      l_element_path := get_Element_XML_Path(p_ui_def_id      => p_ui_def_id,
                                             p_page_id        => p_page_id,
                                             p_element_id     => p_element_id,
                                             p_is_parser_open => p_is_parser_open);

      IF p_rule_type=33 AND l_element_path IS NOT NULL THEN
        add_Error_Message(p_message_name => 'CZ_DISP_COND_DEL_ND_ERROR',
                          p_token_name   => 'UIELEMENTPATH',
                          p_token_value  => l_element_path,
                          p_fatal_error  => TRUE);
      ELSIF p_rule_type=34 AND l_element_path IS NOT NULL THEN
        add_Error_Message(p_message_name => 'CZ_ENABLED_CONDITION_ERROR',
                          p_token_name   => 'UIELEMENTPATH',
                          p_token_value  => l_element_path,
                          p_fatal_error  => TRUE);
      ELSE
        NULL;
      END IF;

    END IF;

  END validate_UI_Condition;

  --
  -- check UI conditions
  --
  PROCEDURE validate_UI_Conditions(p_ui_def_id      IN NUMBER,
                                   p_is_parser_open IN VARCHAR2 DEFAULT NULL) IS

    l_element_id  CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_page_id     CZ_UI_PAGES.page_id%TYPE;

  BEGIN
    FOR i IN(SELECT rule_id,ui_page_id,ui_page_element_id,rule_type FROM CZ_RULES a
              WHERE ui_def_id=p_ui_def_id AND
                    deleted_flag=G_NO_FLAG AND disabled_flag=G_NO_FLAG)
    LOOP

      BEGIN

        IF i.ui_page_element_id IS NOT NULL AND i.ui_page_element_id<>'0' THEN
          SELECT element_id INTO l_element_id FROM CZ_UI_PAGE_ELEMENTS
           WHERE ui_def_id=p_ui_def_id AND page_id=i.ui_page_id AND
                 element_id=i.ui_page_element_id AND deleted_flag NOT IN(G_YES_FLAG,G_LIMBO_FLAG,G_MARK_TO_DELETE);
        ELSIF (i.ui_page_element_id IS NULL OR i.ui_page_element_id='0') AND
             (i.ui_page_id IS NOT NULL AND i.ui_page_id<>0) THEN
          SELECT element_id INTO l_element_id FROM CZ_UI_PAGE_ELEMENTS
           WHERE ui_def_id=p_ui_def_id AND page_id=i.ui_page_id AND
                 parent_element_id IS NULL AND deleted_flag NOT IN(G_YES_FLAG,G_LIMBO_FLAG,G_MARK_TO_DELETE) AND rownum<2;
          SELECT page_id INTO l_page_id FROM CZ_UI_PAGES
           WHERE page_id=i.ui_page_id AND ui_def_id=p_ui_def_id AND deleted_flag NOT IN(G_YES_FLAG,G_LIMBO_FLAG,G_MARK_TO_DELETE);
        END IF;

        validate_UI_Condition(p_ui_def_id,i.rule_id,i.rule_type, i.ui_page_id,i.ui_page_element_id, p_is_parser_open);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL; -- ignore corrupted UI rules
      END;
    END LOOP;
  END validate_UI_Conditions;

  --
  -- update UI Reference when target ui_def_id is changed
  -- ( it is called by Developer )
  --
  PROCEDURE update_UI_Reference
  (
   p_ui_def_id              IN NUMBER,
   p_ref_persistent_node_id IN NUMBER,
   p_new_target_ui_def_id   IN NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,-- status string
   x_msg_count              OUT NOCOPY NUMBER,  -- number of error messages
   x_msg_data               OUT NOCOPY VARCHAR2 -- string which contains error messages
  ) IS

    l_target_primary_navigation  CZ_UI_DEFS.primary_navigation%TYPE;
    l_target_page_set_id         CZ_UI_DEFS.page_set_id%TYPE;
    l_page_ref_id                CZ_UI_PAGE_REFS.page_ref_id%TYPE;
    l_ref_pagebase_path          CZ_UI_PAGE_REFS.target_path%TYPE;
    l_seq_nbr                    CZ_UI_PAGE_REFS.seq_nbr%TYPE;
    l_reference_name             CZ_UI_PAGE_REFS.name%TYPE;
    l_ref_parent_persist_node_id NUMBER;
    l_ref_ps_node_id             NUMBER;
    l_ref_parent_id              NUMBER;
    l_page_set_type              NUMBER;
    l_expl_node_id               NUMBER;
    l_node_depth                 NUMBER;
    l_old_child_ui_def_id        NUMBER;

  BEGIN

    --
    -- initialize FND variables/packages
    --
    Initialize(x_return_status,x_msg_count,x_msg_data);

    --
    -- get primary_navigation, page_set_id of target UI
    --
    SELECT primary_navigation, page_set_id
      INTO l_target_primary_navigation, l_target_page_set_id
      FROM CZ_UI_DEFS
     WHERE ui_def_id=p_new_target_ui_def_id;

    IF l_target_primary_navigation <> G_MODEL_TREE_MENU THEN

      --
      -- if target primary_navigation <> G_MODEL_TREE_MENU ( Dynamic Tree Menu )
      -- then delete a corresponding CZ_UI_PAGE_REFS record from source UI
      -- ( CZ_UI_PAGE_REFS.target_persistent_node_id=p_ref_persistent_node_id )
      --
      UPDATE CZ_UI_PAGE_REFS
         SET deleted_flag=G_YES_FLAG
       WHERE ui_def_id=p_ui_def_id AND
             target_persistent_node_id=p_ref_persistent_node_id AND
             deleted_flag=G_NO_FLAG;

    ELSE -- if target primary_navigation = G_MODEL_TREE_MENU

      set_UI_Context(p_ui_def_id);

      SELECT ps_node_id,parent_id,name
        INTO l_ref_ps_node_id,l_ref_parent_id,l_reference_name
        FROM CZ_PS_NODES
       WHERE devl_project_id=g_UI_Context.devl_project_id AND
             persistent_node_id=p_ref_persistent_node_id AND
             deleted_flag=G_NO_FLAG;

      SELECT persistent_node_id
        INTO l_ref_parent_persist_node_id
        FROM CZ_PS_NODES
       WHERE ps_node_id=l_ref_parent_id AND
             deleted_flag=G_NO_FLAG;

      FOR i IN(SELECT page_ref_id,node_depth,page_set_id,page_ref_type, seq_nbr
                 FROM CZ_UI_PAGE_REFS
                WHERE ui_def_id=p_ui_def_id AND
                      target_persistent_node_id=l_ref_parent_persist_node_id AND
                      page_ref_type=G_MODEL_TREE_MENU AND
                      deleted_flag=G_NO_FLAG)
      LOOP
	-- skip this block for Root record in split pages case to avoid data corruption
 	IF (i.node_depth <> 0 AND i.seq_nbr <> 0) THEN
          --
          -- update target_ui_def_id and target_page_set_id
          --
          UPDATE CZ_UI_PAGE_REFS
             SET target_ui_def_id=p_new_target_ui_def_id,
                 target_page_set_id=l_target_page_set_id
           WHERE ui_def_id=p_ui_def_id AND
                 parent_page_ref_id=i.page_ref_id AND
                 target_persistent_node_id=p_ref_persistent_node_id AND
                 deleted_flag=G_NO_FLAG;

          IF SQL%ROWCOUNT=0 THEN

            l_page_ref_id := allocateId('CZ_UI_PAGE_REFS_S');

            l_ref_pagebase_path := get_Page_Path(l_ref_ps_node_id, i.page_set_id);

            SELECT NVL(MAX(seq_nbr),0)+1 INTO l_seq_nbr
              FROM CZ_UI_PAGE_REFS
             WHERE ui_def_id=p_ui_def_id AND
                   parent_page_ref_id=i.page_ref_id AND
                   deleted_flag=G_NO_FLAG;

           SELECT MIN(model_ref_expl_id) INTO l_expl_node_id FROM CZ_MODEL_REF_EXPLS
            WHERE model_id=g_UI_Context.devl_project_id AND
                  referring_node_id=p_ref_persistent_node_id AND
                  deleted_flag=G_NO_FLAG;

            INSERT INTO CZ_UI_PAGE_REFS
              (ui_def_id,
               page_set_id,
               page_ref_id,
               parent_page_ref_id,
               seq_nbr,
               node_depth,
               condition_id,
               NAME,
               caption_source,
               target_persistent_node_id,
               target_path,
               target_ui_def_id,
               target_page_set_id,
               target_page_id,
               modified_flags,
               path_to_prev_page,
               path_to_next_page,
               page_ref_type,
               target_expl_node_id,
               caption_rule_id,
               deleted_flag)
             VALUES
               (p_ui_def_id,
               i.page_set_id,
               l_page_ref_id,
               i.page_ref_id,
               l_seq_nbr,
               i.node_depth+1,
               NULL,
               l_reference_name,
               G_DEFAULT_CAPTION_RULE_ID,
               p_ref_persistent_node_id,
               l_ref_pagebase_path,
               p_new_target_ui_def_id,
               l_target_page_set_id,
               NULL,
               0,
               NULL,
               NULL,
               i.page_ref_type,
               l_expl_node_id,
               NULL,
               G_NO_FLAG);
          END IF; --  end of IF SQL%ROWCOUNT=0
        END IF; -- end of IF i.node_depth<>0 and i.seq_nbr<>0
      END LOOP;

    END IF; -- end of IF l_target_primary_navigation <> G_MODEL_TREE_MENU

    -- handle page include region
    -- Note the link to the old target child ui is still there at this point
    SELECT ref_ui_def_id INTO l_old_child_ui_def_id
    FROM cz_ui_refs
    WHERE ui_def_id = p_ui_def_id AND ref_persistent_node_id = p_ref_persistent_node_id;

    UPDATE cz_ui_page_elements
    SET target_page_ui_def_id = NULL, target_page_id = NULL
    WHERE deleted_flag = '0' AND target_page_ui_def_id = l_old_child_ui_def_id AND
          target_page_id IN (SELECT page_id FROM cz_ui_pages
                             WHERE ui_def_id = l_old_child_ui_def_id AND deleted_flag = '0') AND
          element_signature_id = G_PAGE_INCL_REGION_SIGNATURE;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data  := SUBSTR(DBMS_UTILITY.format_error_backtrace,1,4000);
      fnd_msg_pub.add_exc_msg('CZ_UIOA_PVT', 'update_UI_Reference', x_msg_data);
      DEBUG('update_UI_Reference() : '||x_msg_data);

  END update_UI_Reference;

  ------------------------------------------------------------------------------
  ------------- some procedures for fast access to UI Generation ---------------
  ------------------------------------------------------------------------------

  PROCEDURE cui(p_model_id           IN NUMBER,
                p_master_template_id IN NUMBER DEFAULT NULL,
                p_ui_name            IN VARCHAR2 DEFAULT NULL,
                p_description        IN VARCHAR2 DEFAULT NULL,
                p_show_all_nodes     IN VARCHAR2 DEFAULT NULL,
                p_create_empty_ui    IN VARCHAR2 DEFAULT NULL,
                p_handling_mode      IN VARCHAR2 DEFAULT NULL) IS

    l_ui_context    CZ_UI_DEFS%ROWTYPE;
    l_return_status VARCHAR2(255);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(255);

  BEGIN

    Initialize(l_return_status,l_msg_count,l_msg_data);

    g_Use_Cache := FALSE;

    --
    -- get UI context
    -- ( * also function get_UI_Context() inserts data for new UI into CZ_UI_DEFS table )
    --
    l_ui_context := create_UI_Context(p_model_id           => p_model_id,
                                      p_master_template_id => p_master_template_id,
                                      p_ui_name            => p_ui_name,
                                      p_description        => p_description,
                                      p_show_all_nodes     => p_show_all_nodes,
                                      p_create_empty_ui    => p_create_empty_ui);

    --
    -- generate a new UI for the current UI context
    --
    construct_UI(l_ui_context.ui_def_id, p_handling_mode);

    DEBUG('New UI has been generated : ui_def_id = '||TO_CHAR(l_ui_context.ui_def_id));

  END cui;

  PROCEDURE rui(p_ui_def_id     IN NUMBER,
                p_handling_mode IN VARCHAR2 DEFAULT NULL) IS

    l_ui_context      CZ_UI_DEFS%ROWTYPE;
    l_return_status   VARCHAR2(255);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(255);

  BEGIN

    Initialize(l_return_status,l_msg_count,l_msg_data);

    --
    -- get UI context
    --
    l_ui_context := get_UI_Context(p_ui_def_id => p_ui_def_id);

    --
    -- refresh UI
    --
    construct_UI(p_ui_def_id, p_handling_mode);

    DEBUG('UI has been refreshed ...');

  END rui;

BEGIN
  DECLARE
    l_status            VARCHAR2(255);
    l_industry          VARCHAR2(255);
    l_oracle_schema     VARCHAR2(255);
    l_ret               BOOLEAN;
  BEGIN
    l_ret := FND_INSTALLATION.GET_APP_INFO(APPLICATION_SHORT_NAME => 'CZ',
                                           STATUS                 => l_status,
                                           INDUSTRY               => l_industry,
                                           ORACLE_SCHEMA          => l_oracle_schema);

    g_UINodeINCREMENT   := get_Seq_Inc('CZ_UI_PAGE_ELEMENTS_S', l_oracle_schema);
    g_PageRefINCREMENT  := get_Seq_Inc('CZ_UI_PAGE_REFS_S', l_oracle_schema);
    g_PageINCREMENT     := get_Seq_Inc('CZ_UI_PAGES_S', l_oracle_schema);
    g_PageSetINCREMENT  := get_Seq_Inc('CZ_UI_PAGE_SETS_S', l_oracle_schema);
    g_UIActionINCREMENT := get_Seq_Inc('CZ_UI_ACTIONS_S', l_oracle_schema);

    SELECT template_name
      INTO G_DRILLDOWN_TEMPLATE_NAME
      FROM CZ_UI_TEMPLATES
     WHERE template_id=G_DRILLDOWN_BUTTON_TEMPLATE_ID AND
           ui_def_id=G_GLOBAL_TEMPLATES_UI_DEF_ID;
  END;

END CZ_UIOA_PVT;

/
