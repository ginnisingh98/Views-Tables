--------------------------------------------------------
--  DDL for Package Body CZ_UI_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_UI_GENERATOR" AS
/*	$Header: czuigenb.pls 120.5 2007/11/26 12:12:38 kdande ship $	*/

TYPE UIStructure        IS RECORD(id                   CZ_UI_NODES.ui_node_id%TYPE,
                                  ps_node_id           CZ_PS_NODES.ps_node_id%TYPE,
                                  parent_id            CZ_PS_NODES.parent_id%TYPE,
                                  name                 CZ_UI_NODES.name%TYPE,
                                  caption_name         CZ_INTL_TEXTS.text_str%TYPE,
                                  ps_node_type         CZ_PS_NODES.ps_node_type%TYPE,
                                  tree_seq             CZ_PS_NODES.tree_seq%TYPE,
                                  maximum              CZ_PS_NODES.maximum%TYPE,
                                  minimum              CZ_PS_NODES.minimum%TYPE,
                                  ui_node_ref_id       CZ_UI_NODES.ui_node_ref_id%TYPE,
                                  reference_id         CZ_PS_NODES.reference_id%TYPE,
                                  intl_text_id         CZ_PS_NODES.intl_text_id%TYPE,
                                  ui_omit              CZ_PS_NODES.ui_omit%TYPE,
                                  virtual_flag         CZ_PS_NODES.virtual_flag%TYPE);

TYPE featureStructure   IS RECORD(id                   CZ_UI_NODES.ui_node_id%TYPE,
                                  ps_node_id           CZ_PS_NODES.ps_node_id%TYPE,
                                  parent_id            CZ_PS_NODES.parent_id%TYPE,
                                  name                 CZ_UI_NODES.name%TYPE,
                                  caption_name         CZ_INTL_TEXTS.text_str%TYPE,
                                  counted_options_flag CZ_PS_NODES.counted_options_flag%TYPE,
                                  ps_node_type         CZ_PS_NODES.ps_node_type%TYPE,
                                  tree_seq             CZ_PS_NODES.tree_seq%TYPE,
                                  maximum              CZ_PS_NODES.maximum%TYPE,
                                  minimum              CZ_PS_NODES.minimum%TYPE,
                                  intl_text_id         CZ_PS_NODES.intl_text_id%TYPE,
                                  feature_type         CZ_PS_NODES.feature_type%TYPE,
                                  reference_id         CZ_PS_NODES.reference_id%TYPE,
                                  atp_flag             BOOLEAN);

TYPE optionStructure   IS RECORD( id                   CZ_UI_NODES.ui_node_id%TYPE,
                                  ps_node_id           CZ_PS_NODES.ps_node_id%TYPE,
                                  parent_id            CZ_PS_NODES.parent_id%TYPE,
                                  tree_seq             CZ_PS_NODES.tree_seq%TYPE,
                                  intl_text_id         CZ_PS_NODES.intl_text_id%TYPE,
                                  name                 CZ_UI_NODES.name%TYPE,
                                  caption_name         CZ_INTL_TEXTS.text_str%TYPE,
                                  atp_flag             BOOLEAN);

TYPE refBOMStructure    IS RECORD(ui_parent_id         CZ_UI_NODES.parent_id%TYPE,
                                  model_id             CZ_PS_NODES.devl_project_id%TYPE,
                                  ps_node_id           CZ_PS_NODES.ps_node_id%TYPE,
                                  intl_text_id         CZ_PS_NODES.intl_text_id%TYPE,
                                  maximum              CZ_PS_NODES.maximum%TYPE,
                                  minimum              CZ_PS_NODES.minimum%TYPE,
                                  virtual_flag         CZ_PS_NODES.virtual_flag%TYPE);


TYPE buttonsStructure   IS RECORD(id                   CZ_UI_NODES.ui_node_id%TYPE,
                                  ps_parent_id         CZ_PS_NODES.parent_id%TYPE,
                                  ui_parent_id         CZ_UI_NODES.parent_id%TYPE,
                                  name                 CZ_UI_NODES.name%TYPE,
                                  rel_top_pos          CZ_UI_NODES.rel_top_pos%TYPE);

TYPE pageStructure      IS RECORD(ps_node_id           CZ_PS_NODES.ps_node_id%TYPE,
                                  ui_node_id           CZ_UI_NODES.ui_node_id%TYPE,
                                  text_id              CZ_PS_NODES.intl_text_id%TYPE,
                                  label_id             CZ_UI_NODES.caption_id%TYPE,
                                  label_txt_id         CZ_UI_NODES.caption_id%TYPE,
                                  tree_label_id        CZ_UI_NODES.caption_id%TYPE,
                                  name                 CZ_UI_NODES.name%TYPE);


TYPE UIArray      IS TABLE OF UIStructure      INDEX BY VARCHAR2(15);
TYPE featureArray IS TABLE OF featureStructure INDEX BY VARCHAR2(15);
TYPE optionArray  IS TABLE OF optionStructure  INDEX BY VARCHAR2(15);
TYPE buttonsArray IS TABLE OF buttonsStructure INDEX BY VARCHAR2(15);
TYPE refbomArray  IS TABLE OF refBOMStructure  INDEX BY BINARY_INTEGER;
TYPE pageArray    IS TABLE OF pageStructure    INDEX BY BINARY_INTEGER;

news               UIArray;
boms               UIArray;
ref_boms           refbomArray;

features           featureArray;
Options            optionArray;

add_buttons        buttonsArray;
latest_buttons     buttonsArray;
footer_buttons     buttonsArray;

mINCREMENT         INTEGER:=20;
mITEMS_ON_PAGE     INTEGER:=10;
mMAX_NUMBER_PAGES  INTEGER:=100;
mWIZARD_STYLE      VARCHAR2(1):='1';
mUSE_LABELS        VARCHAR2(1);
mUI_STYLE          VARCHAR2(1);
mSHOW_ALL_NODES    VARCHAR2(1):='0';
mLOOK_AND_FEEL     VARCHAR2(40);
mCURRENT_LANG      VARCHAR2(10);
mCONCAT_SYMBOL     VARCHAR2(10):=' , ';

ERROR_CODE         VARCHAR2(50):='0000';

Project_Id         CZ_PS_NODES.devl_project_id%TYPE;
Model_Id           CZ_UI_DEFS.devl_project_id%TYPE;
UI_Product_Id      CZ_UI_DEFS.component_id%TYPE;
current_UI_DEF_ID  CZ_UI_DEFS.ui_def_id%TYPE;
currUISeqVal       CZ_UI_NODES.ui_node_id%TYPE:=0;
currentUINode      CZ_UI_NODES.ui_node_id%TYPE:=mINCREMENT;
currTXTSeqVal      CZ_INTL_TEXTS.intl_text_id%TYPE;
currentTXTNode     CZ_INTL_TEXTS.intl_text_id%TYPE;
Model_Name         CZ_PS_NODES.name%TYPE;
UI_Version         PLS_INTEGER:=1;

USABLE_WIDTH       CZ_UI_NODES.width%TYPE;
USABLE_HEIGHT      CZ_UI_NODES.height%TYPE;
CENTER_LINE        CZ_UI_NODES.width%TYPE;
SCREEN_HALF        CZ_UI_NODES.width%TYPE;

GLOBAL_FRAME_ALLOCATION    INTEGER:=-1;

CZ_EXTENTSIONS_RULE_TYPE CONSTANT NUMBER := 300;
EXPR_EVENT_BINDING       CONSTANT NUMBER := 0; -- ???
EXPR_SYS_ARGUMENT        CONSTANT NUMBER := 218;
EVENT_ON_COMMAND_SIGID   CONSTANT NUMBER := 2203;
GENERATE_OUTPUT_EVENT    CONSTANT NUMBER := 31;
RAISE_COMMAND_EVENT      CONSTANT NUMBER := 32;
GLOBAL_SCOPE             CONSTANT NUMBER := 1;

--
-- these variables are used in Applet style UI --
--

CZ_DELETE_BUTTON_CAPTION        CZ_INTL_TEXTS.text_str%TYPE:='Delete';
CZ_CONNECTOR_BUTTON_CAPTION     CZ_INTL_TEXTS.text_str%TYPE:='Choose Connection';

CZ_FIND_LABEL_CAPTION           CZ_INTL_TEXTS.text_str%TYPE:=NULL;
CZ_FIND_BUTTON_CAPTION          CZ_INTL_TEXTS.text_str%TYPE;
CZ_ORDER_QUANTITY_CAPTION       CZ_INTL_TEXTS.text_str%TYPE;
CZ_TOTAL_PRC_LABEL_CAPTION      CZ_INTL_TEXTS.text_str%TYPE;
CZ_AVAILABILITY_CAPTION         CZ_INTL_TEXTS.text_str%TYPE;
CZ_DONE_BUTTON_CAPTION          CZ_INTL_TEXTS.text_str%TYPE;
CZ_GRID_ITEM_CAPTION            CZ_INTL_TEXTS.text_str%TYPE;
CZ_GRID_DESCRIPTION_CAPTION     CZ_INTL_TEXTS.text_str%TYPE;
CZ_GRID_UOM_CAPTION             CZ_INTL_TEXTS.text_str%TYPE;
CZ_GRID_QUANTITY_CAPTION        CZ_INTL_TEXTS.text_str%TYPE;
CZ_GRID_UNIT_LIST_PRC_CAPTION   CZ_INTL_TEXTS.text_str%TYPE;
CZ_GRID_SELLING_PRC_CAPTION     CZ_INTL_TEXTS.text_str%TYPE;
CZ_GRID_EXTENDED_PRC_CAPTION    CZ_INTL_TEXTS.text_str%TYPE;
CZ_UPDATE_BUTTON_CAPTION        CZ_INTL_TEXTS.text_str%TYPE;
CZ_CANCEL_BUTTON_CAPTION        CZ_INTL_TEXTS.text_str%TYPE;



APPLET_STYLE_UI              CONSTANT VARCHAR2(1):='3';
DHTML_STYLE_UI               CONSTANT VARCHAR2(1):='0';

CZ_WARNING_URGENCY           CONSTANT INTEGER:=0;
CZ_ERROR_URGENCY             CONSTANT INTEGER:=1;

CZ_NAVIGATION_MARK           CONSTANT NUMBER:=-1;
CZ_UI_GEN_NO_BUTTONS         CONSTANT VARCHAR2(30):='CZ_UI_GEN_NO_BUTTONS';
CZ_UI_GEN_BAD_DATA           CONSTANT VARCHAR2(30):='CZ_UI_GEN_BAD_DATA';
CZ_UI_GEN_REMOVED_SCREEN     CONSTANT VARCHAR2(30):='CZ_UI_GEN_REMOVED_SCREEN';
CZ_UI_GEN_FATAL_ERR          CONSTANT VARCHAR2(30):='CZ_UI_GEN_FATAL_ERR';
CZ_UI_GEN_BOM_STYLE_FOR_IB   CONSTANT VARCHAR2(30):='CZ_UI_GEN_BOM_STYLE_FOR_IB';

TOKEN_UI_NODE                CONSTANT VARCHAR2(20):='ui_node';
TOKEN_PROC_NAME              CONSTANT VARCHAR2(20):='proc_name';
TOKEN_BUTTON_NAME            CONSTANT VARCHAR2(20):='button';
TOKEN_SQLERRM                CONSTANT VARCHAR2(20):='sqlerrm';

LEFT_MARGIN                  CONSTANT INTEGER:=45;
RIGHT_MARGIN                 CONSTANT INTEGER:=45;
TOP_LABELED_SPACE_BETWEEN    CONSTANT INTEGER:=23;
TOP_LABELED_SPACE_ABOVE      CONSTANT INTEGER:=10;
STACKED_SPACE_BETWEEN        CONSTANT INTEGER:=10;
FIRST_SPACE_LEFT_LABELED     CONSTANT INTEGER:=10;
FIRST_SPACE_TOP_LABELED      CONSTANT INTEGER:=23;

DEFAULT_CONTROL_HEIGHT       CONSTANT INTEGER:=20;
DEFAULT_HEADER_HEIGHT        CONSTANT INTEGER:=35;
DEFAULT_BUTTON_HEIGHT        CONSTANT INTEGER:=25;
DEFAULT_DIVIDER_HEIGHT       CONSTANT INTEGER:=2;
DEFAULT_BOM_HEIGHT           CONSTANT INTEGER:=28;
DEFAULT_BOM_INST_ITEM_HEIGHT CONSTANT INTEGER:=60;
DEFAULT_TREE_ALLOCATION      CONSTANT INTEGER:=30;
DEFAULT_SPACE_BETWEEN        CONSTANT INTEGER:=13;
SPACE_BETWEEN                CONSTANT INTEGER:=10;
STACKED_SPACE_BETWEEN        CONSTANT INTEGER:=10;
FIRST_SPACE_LEFT_LABELED     CONSTANT INTEGER:=10;
FIRST_SPACE_TOP_LABELED      CONSTANT INTEGER:=23;
DEFAULT_TEXT_HEIGHT          CONSTANT INTEGER:=20;
DEFAULT_TITLE_COLOR          CONSTANT INTEGER:=8421376;
DEFAULT_DIVIDER_COLOR        CONSTANT INTEGER:=10079436;

------------------------------------------------------------

RESOURCE_CONTROL_TYPE        CONSTANT INTEGER:=7;
TOTAL_CONTROL_TYPE           CONSTANT INTEGER:=8;

CONNECTOR_CONTROL_TYPE       CONSTANT INTEGER:=16;

DEFAULT_TARGET_FRAME_WIDTH   CONSTANT INTEGER:= 640;
DEFAULT_TARGET_FRAME_HEIGHT  CONSTANT INTEGER:= 480;

DEFAULT_PROD_TOP             CONSTANT INTEGER:= 41;
DEFAULT_PROD_LEFT            CONSTANT INTEGER:= 32;

DEFAULT_BACKGROUND_COLOR     CONSTANT INTEGER:= 16777215;      --0xFFFFFF; white
DEFAULT_BACKGROUND_PICTURE   CONSTANT VARCHAR2(50):= '';
TREE_TILING_BMP              CONSTANT VARCHAR2(50):= 'czyellgr.gif';

DEFAULT_TREE_FONT_BOLD       CONSTANT INTEGER:= 1;
DEFAULT_FONT_BOLD            CONSTANT INTEGER:= 0;
DEFAULT_FONT_ITALIC          CONSTANT INTEGER:= 0;
DEFAULT_FONT_COLOR           CONSTANT INTEGER:= 0;              --0x000000;  black
DEFAULT_FONT_COLOR_          CONSTANT INTEGER:=8421504;
DEFAULT_FONT_UNDERLINE       CONSTANT INTEGER:= 0;
DEFAULT_FONT_SIZE            CONSTANT INTEGER:= 10;
DEFAULT_FONT_NAME            CONSTANT VARCHAR2(50):= 'Arial';
DEFAULT_FONT_NAME_           CONSTANT VARCHAR2(50):= 'Arial Black';
DEFAULT_FONT_SIZE_           CONSTANT INTEGER:=11;
DEFAULT_CAPTION_FONT_SIZE    CONSTANT INTEGER:= 16;

DEFAULT_LOGIC_BOLD_LF        CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_BOLD_LT        CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_BOLD_UF        CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_BOLD_UN        CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_BOLD_UT        CONSTANT INTEGER:= 0;

-- need to get these values
-- this has to be in MS BGR format instead of RGB
-- (would be 0xFF0000 in RGB)

DEFAULT_LOGIC_COLOR_LF      CONSTANT INTEGER:=255;             --0x0000FF; -- red
DEFAULT_LOGIC_COLOR_LT      CONSTANT INTEGER:=32768;           --0x008000; -- green
DEFAULT_LOGIC_COLOR_UF      CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_COLOR_UN      CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_COLOR_UT      CONSTANT INTEGER:= 0;

DEFAULT_COLOR               CONSTANT INTEGER:= 12632256;

DEFAULT_LOGIC_COLOR         CONSTANT INTEGER:= 1;
DEFAULT_LOGIC_BOLD          CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_PIC           CONSTANT VARCHAR2(50):= '';

USE_NAMES                   CONSTANT VARCHAR2(10):= '0';
USE_DESCRIPTIONS            CONSTANT VARCHAR2(10):= '1';
USE_PROPERTY_DESCRIPTIONS   CONSTANT VARCHAR2(10):= '2';
USE_NAMES_AND_DESCRIPTIONS  CONSTANT VARCHAR2(10):= '3';

DEFAULT_LOGIC_LGB_LF         CONSTANT VARCHAR2(50):= 'czlgblf.gif';
DEFAULT_LOGIC_LGB_LT         CONSTANT VARCHAR2(50):= 'czlgblt.gif';
DEFAULT_LOGIC_LGB_UF         CONSTANT VARCHAR2(50):= 'czlgbuf.gif';
DEFAULT_LOGIC_LGB_UN         CONSTANT VARCHAR2(50):= 'czlgbun.gif';
DEFAULT_LOGIC_LGB_UT         CONSTANT VARCHAR2(50):= 'czlgbut.gif';

DEFAULT_LOGIC_COM_LF         CONSTANT VARCHAR2(50):= 'czcomlf.gif';
DEFAULT_LOGIC_COM_LT         CONSTANT VARCHAR2(50):= 'czcomlt.gif';
DEFAULT_LOGIC_COM_UF         CONSTANT VARCHAR2(50):= 'czcomuf.gif';
DEFAULT_LOGIC_COM_UN         CONSTANT VARCHAR2(50):= 'czcomun.gif';
DEFAULT_LOGIC_COM_UT         CONSTANT VARCHAR2(50):= 'czcomut.gif';

DEFAULT_LOGIC_BOL_LF         CONSTANT VARCHAR2(50):= 'czbollf.gif';
DEFAULT_LOGIC_BOL_LT         CONSTANT VARCHAR2(50):= 'czbollt.gif';
DEFAULT_LOGIC_BOL_UF         CONSTANT VARCHAR2(50):= 'czboluf.gif';
DEFAULT_LOGIC_BOL_UN         CONSTANT VARCHAR2(50):= 'czbolun.gif';
DEFAULT_LOGIC_BOL_UT         CONSTANT VARCHAR2(50):= 'czbolut.gif';

DEFAULT_LOGIC_OPT_LF         CONSTANT VARCHAR2(50):= 'czoptlf.gif';
DEFAULT_LOGIC_OPT_LT         CONSTANT VARCHAR2(50):= 'czoptlt.gif';
DEFAULT_LOGIC_OPT_UF         CONSTANT VARCHAR2(50):= 'czoptuf.gif';
DEFAULT_LOGIC_OPT_UN         CONSTANT VARCHAR2(50):= 'czoptun.gif';
DEFAULT_LOGIC_OPT_UT         CONSTANT VARCHAR2(50):= 'czoptut.gif';

DEFAULT_HEADER_BAR           CONSTANT VARCHAR2(50):= 'czblbar.gif';
DEFAULT_DIVIDER_BAR          CONSTANT VARCHAR2(50):= 'czdiv.jpg';

DEFAULT_LOGIC_USE_COLORS     CONSTANT INTEGER:= 0;
DEFAULT_LOGIC_USE_ICONS      CONSTANT INTEGER:= 1;

DEFAULT_LEFT_POS             CONSTANT INTEGER:=32;
DEFAULT_TOP_POS              CONSTANT INTEGER:=41;

--
-- PS Tree node Types --
--
MODEL_NODE_TYPE             CONSTANT INTEGER:=256;
PRODUCT_NODE_TYPE           CONSTANT INTEGER:=258;
COMPONENT_NODE_TYPE         CONSTANT INTEGER:=259;
FEATURE_NODE_TYPE           CONSTANT INTEGER:=261;
OPTION_NODE_TYPE            CONSTANT INTEGER:=262;
TOTAL_NODE_TYPE             CONSTANT INTEGER:=272;
RESOURCE_NODE_TYPE          CONSTANT INTEGER:=273;
REFERENCE_NODE_TYPE         CONSTANT INTEGER:=263;
CONNECTOR_NODE_TYPE         CONSTANT INTEGER:=264;
BOM_MODEL_NODE_TYPE         CONSTANT INTEGER:=436;
BOM_CLASS_NODE_TYPE         CONSTANT INTEGER:=437;
BOM_STANDART_NODE_TYPE      CONSTANT INTEGER:=438;

--
-- UI Tree node Types --
--
DEFAULT_UI_TEXT             CONSTANT INTEGER:=1;
DEFAULT_UI_BITMAP           CONSTANT INTEGER:=2;
DEFAULT_UI_FEATURE          CONSTANT INTEGER:=3;
DEFAULT_UI_OPTION           CONSTANT INTEGER:=4;

--
--Default Rel Top and Left positions and Row spaces --
--
DEFAULT_REL_TOP             CONSTANT INTEGER:=10;
DEFAULT_REL_LEFT            CONSTANT INTEGER:=60;
DEFAULT_LABEL_HEIGHT        CONSTANT INTEGER:=20;
DEFAULT_FEATURE_HEIGHT      CONSTANT INTEGER:=20;
DEFAULT_ROW_SPACE           CONSTANT INTEGER:=6;
DEFAULT_ROW_EXTRA_SPACE     CONSTANT INTEGER:=6;
DEFAULT_LEFT                CONSTANT INTEGER:=0;

--
-- enumertaion for UI property types --
--
DEF_PRODUCT_USER_IFACE      CONSTANT INTEGER:=1;
DEF_PRODUCT_SELECTION       CONSTANT INTEGER:=4;
DEF_PRODUCT_SCREEN          CONSTANT INTEGER:=11;
DEF_COMPONENT_SCREEN        CONSTANT INTEGER:=12;
DEF_COMPONENT_TREE          CONSTANT INTEGER:=5;
DEF_PRODUCT                 CONSTANT INTEGER:=10;
DEF_COMPONENT               CONSTANT INTEGER:=2;
DEF_FEATURE                 CONSTANT INTEGER:=3;
DEF_TITLE_BITMAP            CONSTANT INTEGER:=6;
DEF_TEXT_LABEL              CONSTANT INTEGER:=7;
DEF_TOTAL_ELEMENT           CONSTANT INTEGER:=13;
DEF_RESOURCE_ELEMENT        CONSTANT INTEGER:=14;
DEF_RECYCLE_BIN             CONSTANT INTEGER:=8;
DEF_LIMBO                   CONSTANT INTEGER:=9;
DEF_REFERENCE               CONSTANT INTEGER:=15;
DEF_INST_BOM                CONSTANT INTEGER:=16;
DEF_CONNECTOR_ELEMENT       CONSTANT INTEGER:=17;
DEF_DELETE_BUTTON           CONSTANT INTEGER:=100;
DEF_ADD_BUTTON              CONSTANT INTEGER:=101;
DEF_FUNC_BUTTON1            CONSTANT INTEGER:=102;
DEF_FUNC_BUTTON2            CONSTANT INTEGER:=103;
DEF_GOTO_BUTTON             CONSTANT INTEGER:=104;
DEF_HOME_SCREEN             CONSTANT INTEGER:=105;
DEF_PREV_SCREEN             CONSTANT INTEGER:=106;
DEF_NEXT_SCREEN             CONSTANT INTEGER:=107;
DEF_CONNECTOR_BUTTON        CONSTANT INTEGER:=108;

DEF_CLASS                   CONSTANT INTEGER:=1000;
DEF_CLASSES                 CONSTANT INTEGER:=1001;
DEF_STANDART                CONSTANT INTEGER:=1000;
DEF_MODEL                   CONSTANT INTEGER:=1000;
DEF_MODELBOM                CONSTANT INTEGER:=1111;
DEF_MODELBOM_TREE           CONSTANT INTEGER:=1112;
DEF_CLASSBOM_TREE           CONSTANT INTEGER:=1113;

DEF_FRAMESET                CONSTANT INTEGER:=155;
DEF_FRAME                   CONSTANT INTEGER:=156;
DEF_PANEL                   CONSTANT INTEGER:=165;
DEF_BUTTON                  CONSTANT INTEGER:=150;
DEF_FIND_CONTROL            CONSTANT INTEGER:=164;
DEF_TAGGED_VALUE            CONSTANT INTEGER:=166;
DEF_TEXT                    CONSTANT INTEGER:=152;
DEF_TEXT_CONTROL            CONSTANT INTEGER:=117;
DEF_GRID                    CONSTANT INTEGER:=159;
DEF_COLUMN                  CONSTANT INTEGER:=160;
DEF_DATASET                 CONSTANT INTEGER:=161;
DEF_MODELTREE               CONSTANT INTEGER:=157;

--
-- UI nodes types --
--
UI_ROOT_SYSTEM_TYPE         CONSTANT INTEGER:=141;
UI_PRODUCT_REF_TYPE         CONSTANT INTEGER:=144;
UI_COMPONENT_REF_TYPE       CONSTANT INTEGER:=144;
UI_PRODUCT_TYPE             CONSTANT INTEGER:=146;
UI_COMPONENT_TYPE           CONSTANT INTEGER:=146;
UI_SCREEN_TYPE              CONSTANT INTEGER:=146;
UI_FEATURE_TYPE             CONSTANT INTEGER:=148;
UI_OPTION_TYPE              CONSTANT INTEGER:=145;
UI_RESOURCE_TYPE            CONSTANT INTEGER:=149;
UI_TOTAL_TYPE               CONSTANT INTEGER:=149;
UI_CONNECTOR_TYPE           CONSTANT INTEGER:=168;
UI_SYS_TYPE                 CONSTANT INTEGER:=142;
UI_BUTTON_TYPE              CONSTANT INTEGER:=150;
UI_PICTURE_TYPE             CONSTANT INTEGER:=151;
UI_REFERENCE_REF_TYPE       CONSTANT INTEGER:=167;
UI_TEXT_LABEL_TYPE          CONSTANT INTEGER:=152;
UI_BOM_OPTION_CLASS_TYPE    CONSTANT INTEGER:=146;
UI_BOM_STANDART_TYPE        CONSTANT INTEGER:=154;
UI_BOM_INST_ITEM_TYPE       CONSTANT INTEGER:=190;
UI_APPLET_TREE_NODE_TYPE    CONSTANT INTEGER:=158;
DEFAULT_CONNECTOR_HEIGHT    CONSTANT INTEGER:=24;
STAR_SYMBOL_WIDTH           CONSTANT INTEGER:=3;

DEFAULT_TOTAL_WIDTH         CZ_UI_NODES.width%TYPE;
DEFAULT_RESOURCE_WIDTH      CZ_UI_NODES.width%TYPE;
DEFAULT_CONNECTOR_WIDTH     CZ_UI_NODES.width%TYPE;
BOOLEAN_FEATURE_WIDTH       CZ_UI_NODES.width%TYPE;
NUMERIC_FEATURE_WIDTH       CZ_UI_NODES.width%TYPE;
OPTION_FEATURE_WIDTH        CZ_UI_NODES.width%TYPE;
CONNECTOR_GAP               CZ_UI_NODES.width%TYPE;

GLOBAL_RUN_ID               INTEGER:=0;
GLOBAL_GEN_VERSION          VARCHAR2(25):='11.5.8.18.9';
GLOBAL_GEN_HEADER           VARCHAR2(100):='$Header: czuigenb.pls 120.5 2007/11/26 12:12:38 kdande ship $';

last_TOP_POS                CZ_UI_NODES.rel_top_pos%TYPE;
last_WIDTH                  CZ_UI_NODES.width%TYPE;
last_HEIGHT                 CZ_UI_NODES.height%TYPE;

DELETE_BUTTON_LEFT_POS      CZ_UI_NODES.rel_left_pos%TYPE;
DELETE_BUTTON_TOP_POS       CZ_UI_NODES.rel_top_pos%TYPE:=10;
DELETE_BUTTON_WIDTH         CZ_UI_NODES.width%TYPE:=75;

START_TOP_POS               CZ_UI_NODES.rel_top_pos%TYPE:=DEFAULT_HEADER_HEIGHT+DEFAULT_DIVIDER_HEIGHT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE LOG_REPORT
(in_caller        IN VARCHAR2,
 in_error_message IN VARCHAR2,
 in_urgency       IN INTEGER -- DEFAULT CZ_ERROR_URGENCY
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    var_error      BOOLEAN;
    var_status     INTEGER;
BEGIN
    var_status:=11276;
    INSERT INTO CZ_DB_LOGS
           (RUN_ID,
            LOGTIME,
            LOGUSER,
            URGENCY,
            CALLER,
            STATUSCODE,
            MESSAGE)
    VALUES (GLOBAL_RUN_ID,
            SYSDATE,
            USER,
            in_urgency,
            in_caller,
            var_status,
            in_error_message);
    COMMIT;
END LOG_REPORT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE FND_REPORT
(in_message_name IN VARCHAR2,
 in_token        IN VARCHAR2 DEFAULT NULL,
 in_value        IN VARCHAR2 DEFAULT NULL,
 in_urgency      IN INTEGER -- DEFAULT CZ_ERROR_URGENCY
) IS
    ret VARCHAR2(255);
BEGIN
    IF in_token IS NULL AND in_value IS NULL THEN
       ret:=CZ_UTILS.GET_TEXT(in_message_name);
    ELSE
       ret:=CZ_UTILS.GET_TEXT(in_message_name,in_token,in_value);
    END IF;
    LOG_REPORT('CZ_UI_GENERATOR',ret,in_urgency);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS THEN
         NULL;
END FND_REPORT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION getMessage(in_message IN VARCHAR2) RETURN VARCHAR IS
    var_message_text FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
BEGIN
    var_message_text:=NULL;
    SELECT MESSAGE_TEXT INTO var_message_text FROM FND_NEW_MESSAGES
    WHERE MESSAGE_NAME=in_message AND language_code=mCURRENT_LANG;
    RETURN var_message_text;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN var_message_text;
    WHEN OTHERS THEN
         RETURN var_message_text;
END getMessage;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION get_Caption
(in_name       IN VARCHAR2,
 in_label      IN VARCHAR2,
 in_use_labels IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS

    var_caption    CZ_LOCALIZED_TEXTS.LOCALIZED_STR%TYPE;
    var_use_labels VARCHAR2(3);

BEGIN
    IF in_use_labels IS NULL THEN
       var_use_labels:=mUSE_LABELS;
    ELSE
       var_use_labels:=in_use_labels;
    END IF;

    IF var_use_labels=USE_NAMES THEN
       var_caption:=in_name;
    ELSIF var_use_labels=USE_DESCRIPTIONS THEN
       IF in_label IS NULL OR in_label='' THEN
         var_caption := in_name;
       ELSE
         var_caption:=in_label;
       END IF;
    ELSIF var_use_labels=USE_NAMES_AND_DESCRIPTIONS THEN
       IF in_label IS NULL OR in_label='' THEN
         var_caption:=in_name;
       ELSE
         var_caption:=in_name||mCONCAT_SYMBOL||in_label;
       END IF;
    END IF;

    RETURN var_caption;
END get_Caption;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Translate_Labels IS

BEGIN
    IF CZ_FIND_LABEL_CAPTION IS NULL THEN

          CZ_FIND_LABEL_CAPTION           :=getMessage('CZ_FIND_LABEL_CAPTION');
          CZ_FIND_BUTTON_CAPTION          :=getMessage('CZ_FIND_BUTTON_CAPTION');
          CZ_ORDER_QUANTITY_CAPTION       :=getMessage('CZ_ORDER_QUANTITY_LABEL_CAPTION');
          CZ_TOTAL_PRC_LABEL_CAPTION      :=getMessage('CZ_TOTAL_PRICE_LABEL_CAPTION');
          CZ_AVAILABILITY_CAPTION         :=getMessage('CZ_AVAILABILITY_LABEL_CAPTION');
          CZ_DONE_BUTTON_CAPTION          :=getMessage('CZ_DONE_BUTTON_CAPTION');
          CZ_GRID_ITEM_CAPTION            :=getMessage('CZ_GRID_ITEM_CAPTION');
          CZ_GRID_DESCRIPTION_CAPTION     :=getMessage('CZ_GRID_DESCRIPTION_CAPTION');
          CZ_GRID_UOM_CAPTION             :=getMessage('CZ_GRID_UOM_CAPTION');
          CZ_GRID_QUANTITY_CAPTION        :=getMessage('CZ_GRID_QUANTITY_CAPTION');
          CZ_GRID_UNIT_LIST_PRC_CAPTION   :=getMessage('CZ_GRID_UNIT_LIST_PRICE_CAPTION') ;
          CZ_GRID_SELLING_PRC_CAPTION     :=getMessage('CZ_GRID_SELLING_PRICE_CAPTION');
          CZ_GRID_EXTENDED_PRC_CAPTION    :=getMessage('CZ_GRID_EXTENDED_PRICE_CAPTION');
          CZ_UPDATE_BUTTON_CAPTION        :=getMessage('CZ_UPDATE_BUTTON_CAPTION');
          CZ_CANCEL_BUTTON_CAPTION        :=getMessage('CZ_CANCEL_CAPTION');

          IF CZ_FIND_LABEL_CAPTION IS NULL THEN
             CZ_FIND_LABEL_CAPTION        :='Find: ' ;
          END IF;

          IF CZ_FIND_BUTTON_CAPTION IS NULL THEN
             CZ_FIND_BUTTON_CAPTION       :='Go';
          END IF;
          CZ_ORDER_QUANTITY_CAPTION       :='Order Quantity:';
          CZ_TOTAL_PRC_LABEL_CAPTION      :='Total Price:';
          CZ_AVAILABILITY_CAPTION         :='Availability:';
          CZ_DONE_BUTTON_CAPTION          :=' Done ';
          CZ_GRID_ITEM_CAPTION            :='Item';
          CZ_GRID_DESCRIPTION_CAPTION     :='Description';
          CZ_GRID_UOM_CAPTION             :='UOM';
          CZ_GRID_QUANTITY_CAPTION        :='Quantity';
          CZ_GRID_UNIT_LIST_PRC_CAPTION   :='Unit List Price' ;
          CZ_GRID_SELLING_PRC_CAPTION     :='Selling Price' ;
          CZ_GRID_EXTENDED_PRC_CAPTION    :='Extended Price';
          CZ_UPDATE_BUTTON_CAPTION        :='Update';
          CZ_CANCEL_BUTTON_CAPTION        :='Cancel';
    END IF;

END Translate_Labels;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION getUISeqVal RETURN INTEGER IS
BEGIN
       --
       -- this will be in the next build --
       --
       IF currentUINode<currUISeqVal+mINCREMENT-1 THEN
          currentUINode:=currentUINode+1;
       ELSE
          SELECT CZ_UI_NODES_S.nextval INTO currUISeqVal FROM dual;
          currentUINode:=currUISeqVal;
       END IF;
    RETURN currentUINode;
END getUISeqVal;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION set_Text_Width(in_name IN VARCHAR2) RETURN INTEGER  IS
    ret INTEGER;
BEGIN
    ret:=LENGTH(in_name)*7+3;
    IF ret IS NULL OR ret=0 THEN
       ret:=1;
    END IF;
    RETURN ret;
END set_Text_Width;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION set_Title_Width(in_name IN VARCHAR2) RETURN INTEGER  IS
    ret INTEGER;
BEGIN
    ret:=LENGTH(in_name)*14+20;
    IF ret IS NULL OR ret=0 THEN
       ret:=1;
    END IF;
    RETURN ret;
END set_Title_Width;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION getTXTSeqVal RETURN INTEGER IS
BEGIN
    IF currentTXTNode<currTXTSeqVal+mINCREMENT-1 THEN
       currentTXTNode:=currentTXTNode+1;
    ELSE
       SELECT CZ_INTL_TEXTS_S.nextval INTO currTXTSeqVal FROM dual;
       currentTXTNode:=currTXTSeqVal;
    END IF;
    RETURN currentTXTNode;
END getTXTSeqVal;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION getNextY
(in_ui_def_id IN INTEGER,
 in_parent_id IN INTEGER) RETURN INTEGER IS

    var_top_pos INTEGER;
    var_height  INTEGER;
    ret         INTEGER;

BEGIN
    SELECT NVL(MAX(rel_top_pos),50) INTO var_top_pos FROM CZ_UI_NODES
    WHERE ui_def_id=in_ui_def_id AND parent_id=in_parent_id AND
    deleted_flag=NO_FLAG;

    SELECT NVL(MAX(height),DEFAULT_CONTROL_HEIGHT)
    INTO var_height FROM CZ_UI_NODES
    WHERE ui_def_id=in_ui_def_id AND parent_id=in_parent_id
          AND rel_top_pos=var_top_pos
          AND deleted_flag=NO_FLAG;

    ret:=var_top_pos+var_height+DEFAULT_SPACE_BETWEEN;
    RETURN ret;
END getNextY;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Initialize IS
BEGIN
    news.DELETE;
    boms.DELETE;
    features.DELETE;
    Options.DELETE;
    add_buttons.DELETE;
    latest_buttons.DELETE;
    footer_buttons.DELETE;
    ref_boms.DELETE;

    SELECT CZ_UI_NODES_S.NEXTVAL INTO currentUINode FROM dual;
    currUISeqVal:=currentUINode;
    SELECT CZ_INTL_TEXTS_S.NEXTVAL INTO currTXTSeqVal FROM dual;
    currentTXTNode:=currTXTSeqVal;

    SELECT TO_NUMBER(value) INTO mINCREMENT FROM cz_db_settings
    WHERE UPPER(setting_id)=UPPER('OracleSequenceIncr') AND section_name='SCHEMA';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         mINCREMENT:=20;
    WHEN OTHERS THEN
         mINCREMENT:=20;
END Initialize;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE remove_UI_Subtree
(in_ui_node_id   IN INTEGER,
 in_ui_node_type IN INTEGER) IS
    var_start_ui_node CZ_UI_NODES.ui_node_id%TYPE;
    END_OPERATION1    EXCEPTION;
    END_OPERATION2    EXCEPTION;
BEGIN
    var_start_ui_node:=in_ui_node_id;
    IF in_ui_node_type<>UI_COMPONENT_REF_TYPE THEN
       BEGIN
           BEGIN
           SELECT ui_node_id INTO var_start_ui_node FROM CZ_UI_NODES
           WHERE ui_node_ref_id=in_ui_node_id AND ui_node_type=UI_COMPONENT_REF_TYPE;
           RAISE END_OPERATION1;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    NULL;
           END;

           FOR l IN (SELECT ui_node_id,ui_node_ref_id FROM CZ_UI_NODES
                     START WITH ui_node_id=in_ui_node_id
                     CONNECT BY PRIOR ui_node_id=parent_id)
           LOOP
              DELETE FROM CZ_UI_NODES WHERE ui_node_id=l.ui_node_id AND deleted_flag=NO_FLAG;
              DELETE FROM CZ_UI_NODES WHERE ui_node_id=l.ui_node_ref_id AND
              ui_node_type=UI_TEXT_LABEL_TYPE AND deleted_flag=NO_FLAG;
           END LOOP;
           RAISE END_OPERATION2;
       EXCEPTION
           WHEN END_OPERATION1 THEN
                NULL;
       END;
    END IF;

    --
    -- remove starting with node of UI Model Tree --
    --
    FOR i IN (SELECT ui_node_id,ui_node_ref_id FROM CZ_UI_NODES
              START WITH ui_node_id=var_start_ui_node
              CONNECT BY PRIOR ui_node_id=parent_id)
    LOOP
       FOR l IN (SELECT ui_node_id,ui_node_ref_id FROM CZ_UI_NODES
                 START WITH ui_node_id=i.ui_node_ref_id
                 CONNECT BY PRIOR ui_node_id=parent_id)
       LOOP
          DELETE FROM CZ_UI_NODES WHERE ui_node_id=l.ui_node_id AND deleted_flag=NO_FLAG;
          DELETE FROM CZ_UI_NODES WHERE ui_node_id=l.ui_node_ref_id AND
          ui_node_type=UI_TEXT_LABEL_TYPE AND deleted_flag=NO_FLAG;
       END LOOP;
       DELETE FROM CZ_UI_NODES WHERE ui_node_id=i.ui_node_id AND deleted_flag=NO_FLAG;
    END LOOP;

EXCEPTION
    WHEN END_OPERATION2 THEN
         NULL;
END remove_UI_Subtree;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
/*  NOT NULL DEFAULTS
 in_width             IN INTEGER  DEFAULT 100,
 in_height            IN INTEGER  DEFAULT 20,
 in_tree_display_flag IN VARCHAR2 DEFAULT NO_FLAG,
 in_use_default_font  IN VARCHAR2 DEFAULT YES_FLAG,
 in_use_default_pic   IN VARCHAR2 DEFAULT YES_FLAG,
 in_use_default_color IN VARCHAR2 DEFAULT YES_FLAG,
 in_tree_seq          IN INTEGER  DEFAULT -1,
 in_top_pos           IN INTEGER  DEFAULT 0,
 in_left_pos          IN INTEGER  DEFAULT 0,
 in_font_name         IN VARCHAR2 DEFAULT 'Arial',
 in_font_size         IN INTEGER  DEFAULT 9,
 in_modified_flag     IN INTEGER  DEFAULT 0,
 in_page_id           IN INTEGER  DEFAULT 1,
*/

PROCEDURE set_UI_NODES
(in_ui_node_id        IN INTEGER,
 in_parent_id         IN INTEGER,
 in_ui_def_id         IN INTEGER,
 in_ps_node_id        IN INTEGER,
 in_ui_node_ref_id    IN INTEGER,
 in_name              IN VARCHAR2,
 in_ui_node_type      IN VARCHAR2,
 in_background_color  IN INTEGER  DEFAULT NULL,
 in_component_id      IN INTEGER  DEFAULT NULL,
 in_width             IN INTEGER  DEFAULT NULL, -- 100
 in_height            IN INTEGER  DEFAULT NULL, -- 20
 in_lce_id            IN VARCHAR2 DEFAULT NULL,
 in_tree_display_flag IN VARCHAR2 DEFAULT NULL, -- NO_FLAG
 in_use_default_font  IN VARCHAR2 DEFAULT NULL, -- YES_FLAG
 in_use_default_pic   IN VARCHAR2 DEFAULT NULL, -- YES_FLAG
 in_use_default_color IN VARCHAR2 DEFAULT NULL, -- YES_FLAG
 in_tree_seq          IN INTEGER  DEFAULT NULL, -- -1
 in_top_pos           IN INTEGER  DEFAULT NULL, -- 0
 in_left_pos          IN INTEGER  DEFAULT NULL, -- 0
 in_text_label        IN VARCHAR2 DEFAULT NULL,
 in_caption           IN VARCHAR2 DEFAULT NULL,
 in_font_name         IN VARCHAR2 DEFAULT NULL, -- 'Arial'
 in_font_bold         IN VARCHAR2 DEFAULT NULL,
 in_font_color        IN INTEGER  DEFAULT NULL,
 in_font_italic       IN VARCHAR2 DEFAULT NULL,
 in_font_size         IN INTEGER  DEFAULT NULL, -- 9
 in_font_underline    IN VARCHAR2 DEFAULT NULL,
 in_bkgrnd_style      IN VARCHAR2 DEFAULT NULL,
 in_controltype       IN INTEGER  DEFAULT NULL,
 in_bkgrnd_picture    IN VARCHAR2 DEFAULT NULL,
 in_borders           IN VARCHAR2 DEFAULT NULL,
 in_picname           IN VARCHAR2 DEFAULT NULL,
 in_func_comp_id      IN INTEGER  DEFAULT NULL,
 in_intl_text_id      IN INTEGER  DEFAULT NULL,
 in_parent_name       IN VARCHAR2 DEFAULT NULL,
 in_page_number       IN VARCHAR2 DEFAULT NULL,
 in_modified_flag     IN INTEGER  DEFAULT NULL, -- 0
 in_page_id           IN INTEGER  DEFAULT NULL, -- 1
 in_model_ref_expl_id IN INTEGER  DEFAULT NULL,
 in_use_labels        IN VARCHAR2 DEFAULT NULL,
 in_cx_command_name   IN VARCHAR2 DEFAULT NULL ) IS

    var_caption_id        CZ_UI_NODES.caption_id%TYPE;
    var_tool_tip_id       CZ_UI_NODES.tool_tip_id%TYPE;
    var_use_default_color CZ_UI_NODES.default_bkgrnd_color_flag%TYPE:=YES_FLAG;
    var_background_color  CZ_UI_NODES.background_color%TYPE;
    var_font_color        CZ_UI_NODES.fontcolor%TYPE;
    var_name              CZ_INTL_TEXTS.text_str%TYPE;
    var_label             CZ_LOCALIZED_TEXTS.localized_str%TYPE;
    var_use_labels        VARCHAR2(1);
    var_insert_flag       BOOLEAN;

BEGIN

    var_caption_id:=getTXTSeqVal;
    var_tool_tip_id:=NULL;

    IF in_use_labels IS NULL THEN
       var_use_labels:=mUSE_LABELS;
    ELSE
       var_use_labels:=in_use_labels ;
    END IF;

    var_name:=in_name;
    var_insert_flag:=FALSE;
    IF in_intl_text_id IS NOT NULL THEN
       FOR i IN(SELECT INTL_TEXT_ID,LANGUAGE,LOCALIZED_STR,SOURCE_LANG FROM CZ_LOCALIZED_TEXTS
                WHERE intl_text_id=in_intl_text_id AND deleted_flag=NO_FLAG)
       LOOP
          var_label:=i.LOCALIZED_STR;
          IF (in_ps_node_id IS NOT NULL AND in_ui_node_type<>UI_BUTTON_TYPE) OR in_ui_node_type=UI_COMPONENT_REF_TYPE THEN
              var_label:=get_Caption(in_name,i.localized_str);
          END IF;
          IF (in_ui_node_type=UI_TEXT_LABEL_TYPE AND in_parent_name IS NOT NULL) THEN
              var_label:=get_Caption(in_parent_name,i.localized_str);
          END IF;

          IF in_ui_node_type=UI_BOM_STANDART_TYPE THEN
              var_label:=get_Caption(in_name,i.localized_str,var_use_labels);
          END IF;

          IF in_page_number IS NOT NULL THEN
             var_label:=var_label||' '||in_page_number;
          END IF;
          var_insert_flag:=TRUE;

          INSERT INTO CZ_LOCALIZED_TEXTS
                     (INTL_TEXT_ID,
                      LOCALIZED_STR,
                      LANGUAGE,
                      SOURCE_LANG,
                      DELETED_FLAG,
                      SECURITY_MASK,
                      checkout_user,
                      model_id,
                      ui_def_id)
           SELECT
                                  var_caption_id,
                                  var_label,
                      LANGUAGE,
                      SOURCE_LANG,
                      DELETED_FLAG,
                      SECURITY_MASK,
                      CHECKOUT_USER,
                      MODEL_ID,
                      in_ui_def_id
           FROM CZ_LOCALIZED_TEXTS
           WHERE intl_text_id=i.INTL_TEXT_ID AND
                 LANGUAGE=i.LANGUAGE AND
                 SOURCE_LANG=i.SOURCE_LANG;
       END LOOP;
    END IF;

    --
    -- if there is no Decsription for PS Node or --
    -- nothing was inserted in the previous loop --
    --
    IF (in_intl_text_id IS NULL OR var_insert_flag=FALSE) THEN
       --
       -- if there is no particular caption --
       -- then PS Node name is used         --
       --
       IF in_caption IS NULL THEN
          var_label:=var_name;
       ELSE
          var_label:=in_caption;
       END IF;

       --
       -- it is used for BOM Option Class multi pages UI --
       --
       IF in_page_number IS NOT NULL THEN
          var_label:=var_label||' '||in_page_number;
       END IF;

       --
       -- currently it is used just for Dividers --
       --
       IF in_text_label IS NOT NULL THEN
          var_label:=in_text_label;
       END IF;

       --
       -- by default label for CX button =  in_cx_command_name
       --
       IF in_cx_command_name IS NOT NULL THEN
         var_label := in_cx_command_name;
       END IF;

       INSERT INTO CZ_INTL_TEXTS(intl_text_id,text_str,ui_def_id,model_id,deleted_flag)
       VALUES(var_caption_id,var_label,in_ui_def_id,Project_Id,NO_FLAG);
    END IF;

    var_use_default_color:=in_use_default_color;
    IF var_use_default_color IS NULL THEN
      var_use_default_color := YES_FLAG;
    END IF;

    var_background_color:=in_background_color;
    var_font_color:=in_font_color;

    IF in_background_color IS NULL THEN
       var_use_default_color:=YES_FLAG;
    END IF;

    IF mLOOK_AND_FEEL='FORMS' THEN
       var_use_default_color:=YES_FLAG;
       IF in_ui_node_type=UI_ROOT_SYSTEM_TYPE THEN
          var_use_default_color:=NO_FLAG;
       END IF;
       var_background_color:=DEFAULT_BACKGROUND_COLOR;
       var_font_color:=DEFAULT_FONT_COLOR;
    END IF;

    INSERT INTO CZ_UI_NODES
    (ui_node_id,
    parent_id,
    ui_def_id,
    ps_node_id,
    ui_node_ref_id,
    name,caption_id,tool_tip_id,ui_node_type,background_color,
    component_id,width,height,lce_identifier,
    tree_display_flag,tree_seq,
    default_font_flag,default_bkgrnd_color_flag,
    default_bkgrnd_picture_flag,modified_flags,tab_order,
    rel_top_pos,rel_left_pos,
    deleted_flag,
    fontbold,fontcolor,fontunderline,fontsize,fontname,
    backgroundstyle,controltype,backgroundpicture,borders,picturename,
    func_comp_id,page_number,model_ref_expl_id,cx_command_name)
    VALUES(in_ui_node_id,in_parent_id,in_ui_def_id,in_ps_node_id,in_ui_node_ref_id,
    in_name,var_caption_id,var_tool_tip_id,in_ui_node_type,var_background_color,
    in_component_id,
    NVL(in_width, 100),
    NVL(in_height, 20),
    in_lce_id,
    NVL(in_tree_display_flag,NO_FLAG),
    NVL(in_tree_seq, -1),
    NVL(in_use_default_font, YES_FLAG),
    var_use_default_color,
    NVL(in_use_default_pic, YES_FLAG),
    NVL(in_modified_flag, 0),
    NO_FLAG,
    NVL(in_top_pos, 0),
    NVL(in_left_pos, 0),
    NO_FLAG,in_font_bold,var_font_color,in_font_underline,
    NVL(in_font_size, 9),
    NVL(in_font_name, 'Arial'),
    in_bkgrnd_style,in_controltype,in_bkgrnd_picture,
    in_borders,in_picname,in_func_comp_id,
    NVL(in_page_id, 1),
    in_model_ref_expl_id,
    in_cx_command_name);
END set_UI_NODES;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE set_UI_NODE_PROPS
(in_ui_node_id  IN INTEGER,
 in_ui_def_id   IN INTEGER,
 in_name        IN VARCHAR2,
 in_value       IN VARCHAR2,
 in_update_flag IN VARCHAR2 -- DEFAULT NO_FLAG
) IS

BEGIN
    UPDATE CZ_UI_NODE_PROPS SET value_str=in_value WHERE ui_node_id=in_ui_node_id AND key_str=in_name;
    IF SQL%ROWCOUNT=0 THEN
       INSERT INTO CZ_UI_NODE_PROPS(ui_node_id,ui_def_id,key_str,value_str,deleted_flag)
       VALUES(in_ui_node_id,in_ui_def_id,in_name,in_value,NO_FLAG);
    END IF;
END set_UI_NODE_PROPS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE set_UI_PROPERTIES
(in_ui_def_id   IN INTEGER,
 in_name        IN VARCHAR2,
 in_value       IN VARCHAR2) IS
BEGIN
    INSERT INTO CZ_UI_PROPERTIES(ui_def_id,key_str,value_str,deleted_flag)
    VALUES(in_ui_def_id,in_name,in_value,NO_FLAG);
END set_UI_PROPERTIES;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE set_UI_PROPERTIES
(in_ui_def_id  IN INTEGER,
 in_name       IN VARCHAR2,
 in_value      IN INTEGER) IS
BEGIN
    INSERT INTO CZ_UI_PROPERTIES(ui_def_id,key_str,value_str,deleted_flag)
    VALUES(in_ui_def_id,in_name,to_char(in_value),NO_FLAG);
END set_UI_PROPERTIES;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
/* non-null defaulting
 in_feature_type    IN INTEGER  DEFAULT 0,
 in_min             IN VARCHAR2 DEFAULT YES_FLAG,
 in_max             IN VARCHAR2 DEFAULT YES_FLAG,
 in_counted_options IN VARCHAR2 DEFAULT NO_FLAG,
 in_update_flag     IN VARCHAR2 DEFAULT NO_FLAG,
 in_virtual_flag    IN VARCHAR2 DEFAULT NO_FLAG,
 in_ref_ui_def_id   IN INTEGER  DEFAULT 0,
 in_align           IN VARCHAR2 DEFAULT 'left',
 in_show_all_nodes  IN VARCHAR2 DEFAULT '0'
*/

PROCEDURE generateUIProps
(in_ui_node_id      IN INTEGER,
 in_ui_def_id       IN INTEGER,
 in_ui_type         IN INTEGER,
 in_feature_type    IN INTEGER,
 in_min             IN VARCHAR2,
 in_max             IN VARCHAR2,
 in_counted_options IN VARCHAR2,
 in_update_flag     IN VARCHAR2,
 in_virtual_flag    IN VARCHAR2,
 in_ref_ui_def_id   IN INTEGER,
 in_align           IN VARCHAR2,
 in_show_all_nodes  IN VARCHAR2,
 in_ps_node_id      IN NUMBER DEFAULT NULL,
 in_rule_id         IN NUMBER DEFAULT NULL) IS

    var_ui_def_id          CZ_UI_NODE_PROPS.ui_def_id%TYPE;
    var_persistent_node_id NUMBER;
    var_feature_type       VARCHAR2(1);
    var_control_type       VARCHAR2(1);

BEGIN
    var_ui_def_id:=in_ui_def_id;
    --
    -- Generate the UiNode Properties for the User Interface --
    --
    --
    -- Product-<...> User Interface --
    --
    IF in_ui_type=DEF_PRODUCT_USER_IFACE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UiStyle',NO_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLfBold', DEFAULT_LOGIC_BOLD_LF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLfForeColor', DEFAULT_LOGIC_COLOR_LF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLfPic', DEFAULT_LOGIC_LGB_LF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboLfPic', DEFAULT_LOGIC_COM_LF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanLfPic', DEFAULT_LOGIC_BOL_LF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionLfPic', DEFAULT_LOGIC_OPT_LF,in_update_flag);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLtBold', DEFAULT_LOGIC_BOLD_LT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLtForeColor', DEFAULT_LOGIC_COLOR_LT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLtPic', DEFAULT_LOGIC_LGB_LT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboLtPic', DEFAULT_LOGIC_COM_LT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanLtPic', DEFAULT_LOGIC_BOL_LT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionLtPic', DEFAULT_LOGIC_OPT_LT,in_update_flag);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUfBold', DEFAULT_LOGIC_BOLD_UF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUfForeColor', DEFAULT_LOGIC_COLOR_UF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUfPic',DEFAULT_LOGIC_LGB_UF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboUfPic', DEFAULT_LOGIC_COM_UF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanUfPic', DEFAULT_LOGIC_BOL_UF,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionUfPic',DEFAULT_LOGIC_OPT_UF,in_update_flag);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUnBold', DEFAULT_LOGIC_BOLD_UN,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUnForeColor', DEFAULT_LOGIC_COLOR_UN,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUnPic', DEFAULT_LOGIC_LGB_UN,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboUnPic', DEFAULT_LOGIC_COM_UN,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanUnPic', DEFAULT_LOGIC_BOL_UN,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionUnPic', DEFAULT_LOGIC_OPT_UN,in_update_flag);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUtBold', DEFAULT_LOGIC_BOLD_UT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUtForeColor', DEFAULT_LOGIC_COLOR_UT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUtPic', DEFAULT_LOGIC_LGB_UT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboUtPic', DEFAULT_LOGIC_COM_UT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanUtPic',  DEFAULT_LOGIC_BOL_UT,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionUtPic', DEFAULT_LOGIC_OPT_UT,in_update_flag);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'LogicUseColors', DEFAULT_LOGIC_USE_COLORS,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'LogicUseIcons', DEFAULT_LOGIC_USE_ICONS,in_update_flag);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'PriceUpdate','2',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'PriceDisplay','1',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ShowAllNodes',in_show_all_nodes,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'MaxBOMItemsOnPage',mITEMS_ON_PAGE,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WizardStyle',mWIZARD_STYLE,in_update_flag);

       IF GLOBAL_FRAME_ALLOCATION<>-1 THEN
          set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'NavFrameAllocation',GLOBAL_FRAME_ALLOCATION,in_update_flag);
          set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'NavFrameReservation',GLOBAL_FRAME_ALLOCATION,in_update_flag);
       END IF;

       IF MODE_REFRESH=FALSE THEN
          set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UseLabels',mUSE_LABELS,in_update_flag);
       END IF;
    END IF;

    -- Reference --
    IF in_ui_type=UI_REFERENCE_REF_TYPE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'TargetUIDef',in_ref_ui_def_id,in_update_flag);
    END IF;

    -- Feature --
    IF in_ui_type=DEF_FEATURE THEN
       IF in_feature_type=0 THEN
          var_feature_type:='0';   -- Options List --
          IF in_counted_options=YES_FLAG OR in_max>1 OR in_max IS NULL THEN
             var_control_type:='2';
          ELSE
             var_control_type:=YES_FLAG;
          END IF;
       END IF;

       IF in_feature_type=3 THEN
          var_feature_type:='1';   -- True/False --
          var_control_type:='3';
       END IF;

       IF in_feature_type=1 THEN
          var_feature_type:='2';   -- Integer --
          var_control_type:='4';
       END IF;

       IF in_feature_type=2 THEN
          var_feature_type:='3';   -- Decimal --
          var_control_type:='5';
       END IF;

       IF in_feature_type=4 THEN
          var_feature_type:='4';   -- Text --
          var_control_type:='6';
       END IF;

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'SpinButtons',NO_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'LabelEachOption',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'DisplayPictures',NO_FLAG,in_update_flag);
       IF MODE_REFRESH=FALSE THEN
          set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UseLabels',mUSE_LABELS,in_update_flag);
       END IF;
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'LabelPicture',NO_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CountedOptions',in_counted_options,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'FeatureType',var_feature_type,in_update_flag);
       IF in_max IS NOT NULL THEN
          set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Max',in_max,in_update_flag);
       ELSE
          IF in_update_flag=YES_FLAG THEN
             DELETE FROM CZ_UI_NODE_PROPS WHERE ui_node_id=in_ui_node_id AND key_str='Max';
          END IF;
       END IF;
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Min',in_min,in_update_flag);
    END IF;

    --
    -- Title bitmap --
    --
    IF in_ui_type=DEF_TITLE_BITMAP THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','-1',in_update_flag);
    END IF;

    --
    -- Text label --
    --
    IF in_ui_type=DEF_TEXT_LABEL THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'HAlign',in_align,in_update_flag);
    END IF;

    --
    -- Product selection --
    --
    IF in_ui_type=DEF_PRODUCT_SELECTION THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'SectionType','2',in_update_flag);
    END IF;

    --
    -- Components tree --
    --
    IF in_ui_type=DEF_COMPONENT_TREE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UiStyle',NO_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'TreeStyle','2',in_update_flag);
    END IF;

    --
    -- Recycle Bin --
    --
    IF in_ui_type=DEF_RECYCLE_BIN THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'SectionType','3',in_update_flag);
    END IF;

    --
    -- Limbo --
    --
    IF in_ui_type=DEF_LIMBO THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'SectionType','4',in_update_flag);
    END IF;

    --
    -- Product Screen --
    --
    IF in_ui_type=DEF_PRODUCT_SCREEN THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'IsVirtual',in_virtual_flag,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Max',in_max,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Min',in_min,in_update_flag);
    END IF;

    --
    -- Reference --
    --
    IF in_ui_type=DEF_REFERENCE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'IsVirtual',in_virtual_flag,in_update_flag);
    END IF;

    --
    -- Instantiable BOM --
    --
    IF in_ui_type=DEF_INST_BOM THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','20',in_update_flag);
    END IF;



    --
    -- Component Screen --
    --
    IF in_ui_type=DEF_COMPONENT_SCREEN THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'IsVirtual',in_virtual_flag,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Max',in_max,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Min',in_min,in_update_flag);
    END IF;

    --
    -- BOM Model tree node --
    --
    IF in_ui_type=DEF_MODELBOM_TREE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'IsVirtual',in_virtual_flag,in_update_flag);
    END IF;

    --
    -- Total element --
    --
    IF in_ui_type=DEF_TOTAL_ELEMENT THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'FormatString',NULL,in_update_flag);
    END IF;

    --
    -- Resource element --
    --
    IF in_ui_type=DEF_RESOURCE_ELEMENT THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'FormatString',NULL,in_update_flag);
    END IF;

    --
    -- Delete Button  --
    --
    IF in_ui_type=DEF_DELETE_BUTTON THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','1',in_update_flag);
    END IF;

    --
    -- Add Component --
    --
    IF in_ui_type=DEF_ADD_BUTTON THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','0',in_update_flag);
    END IF;

    --
    -- Goto button --
    --
    IF in_ui_type=DEF_GOTO_BUTTON THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','3',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'MediaFile','',in_update_flag);
    END IF;

    --
    -- Connector's button --
    --
    IF in_ui_type=DEF_CONNECTOR_BUTTON THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','21',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'MediaFile','',in_update_flag);
    END IF;

    IF in_ui_type=DEF_CONNECTOR_ELEMENT THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','18',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Editable',NO_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'DisplayConnectionPath',NO_FLAG,in_update_flag);
    END IF;

    --
    -- Execute Functional Companion 1 --
    --
    IF in_ui_type=DEF_FUNC_BUTTON1 THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','6',in_update_flag);
    END IF;

    --
    -- Execute Functional Companion 2 --
    --
    IF in_ui_type=DEF_FUNC_BUTTON2 THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','5',in_update_flag);
    END IF;

    --
    -- Execute CZ extension ( GENERATE OUTPUT ) --
    --
    IF in_ui_type=GENERATE_OUTPUT_EVENT THEN
       SELECT persistent_node_id INTO var_persistent_node_id FROM CZ_PS_NODES
       WHERE devl_project_id=(select devl_project_id from CZ_UI_DEFS
       WHERE ui_def_id=in_ui_def_id) AND ps_node_id=in_ps_node_id AND deleted_flag='0';
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','31',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CxCommandNode',TO_CHAR(var_persistent_node_id),in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'RuleId',TO_CHAR(in_rule_id),in_update_flag);
    END IF;

    --
    -- Execute CZ extension ( AUTOCONFIGURE ) --
    --
    IF in_ui_type=RAISE_COMMAND_EVENT THEN

       SELECT persistent_node_id INTO var_persistent_node_id FROM CZ_PS_NODES
       WHERE devl_project_id=(select devl_project_id from CZ_UI_DEFS
       WHERE ui_def_id=in_ui_def_id) AND ps_node_id=in_ps_node_id AND deleted_flag='0';

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','32',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CxCommandNode',TO_CHAR(var_persistent_node_id),in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'RuleId',TO_CHAR(in_rule_id),in_update_flag);
   END IF;


    --
    -- Go Home Button --
    --
    IF in_ui_type=DEF_HOME_SCREEN THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','17',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WizardNavigation','1',in_update_flag);
    END IF;

    --
    -- Back button --
    --
    IF in_ui_type=DEF_PREV_SCREEN THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','16',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ButtonStyle','1',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WizardNavigation','1',in_update_flag);
    END IF;

    --
    -- Next button --
    --
    IF in_ui_type=DEF_NEXT_SCREEN THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG,in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','15',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ButtonStyle','2',in_update_flag);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WizardNavigation','1',in_update_flag);
    END IF;

    --
    -- BOM Option Class screen --
    --
    IF in_ui_type=DEF_CLASSES THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UseLabels',mUSE_LABELS,in_update_flag);
    END IF;

    --
    -- BOM Option Class screen --
    --
    IF in_ui_type=DEF_CLASS THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ActionType','3',in_update_flag);
    END IF;

END generateUIProps;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE generateBOMUIProps
(in_ui_node_id      IN INTEGER,
 in_ui_def_id       IN INTEGER,
 in_ui_type         IN INTEGER,
 in_allocations     IN VARCHAR2, -- DEFAULT  NULL,
 in_borders         IN VARCHAR2, -- DEFAULT  NO_FLAG,
 in_scrolling       IN VARCHAR2, -- DEFAULT  NO_FLAG,
 in_sizeable        IN VARCHAR2, -- DEFAULT  NO_FLAG,
 in_system_frm      IN VARCHAR2, -- DEFAULT  NO_FLAG,
 in_margin_width    IN VARCHAR2, -- DEFAULT  '10',
 in_margin_height   IN VARCHAR2, -- DEFAULT  '10',
 in_action          IN VARCHAR2, -- DEFAULT  NULL,
 in_action_type     IN VARCHAR2, -- DEFAULT  '-1',
 in_alt_color       IN VARCHAR2, -- DEFAULT  '15201271',
 in_data_tag        IN VARCHAR2, -- DEFAULT  NULL,
 in_editable        IN VARCHAR2, -- DEFAULT  NO_FLAG,
 in_control_type    IN VARCHAR2, -- DEFAULT  '-1',
 in_rowscols        IN VARCHAR2, -- DEFAULT  YES_FLAG,
 in_hierarchy       IN VARCHAR2, -- DEFAULT  NO_FLAG,
 in_align           IN VARCHAR2  -- DEFAULT  NULL
) IS

    var_ui_def_id    CZ_UI_NODE_PROPS.ui_def_id%TYPE;
    var_feature_type VARCHAR2(1);
    var_control_type VARCHAR2(1);

BEGIN
    var_ui_def_id:=in_ui_def_id;

    IF in_align IS NOT NULL THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Alignment',in_align, NO_FLAG);
    END IF;

    --
    -- Product-<...> User Interface --
    --
    IF in_ui_type=UI_ROOT_SYSTEM_TYPE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UiStyle','3', NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLfBold', DEFAULT_LOGIC_BOLD_LF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLfForeColor', 0, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLfPic', DEFAULT_LOGIC_BOL_LF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboLfPic', DEFAULT_LOGIC_COM_LF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanLfPic', DEFAULT_LOGIC_BOL_LF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionLfPic', DEFAULT_LOGIC_OPT_LF, NO_FLAG);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLtBold', DEFAULT_LOGIC_BOLD_LT, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLtForeColor', 0, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicLtPic', DEFAULT_LOGIC_BOL_LT, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboLtPic', DEFAULT_LOGIC_COM_LT, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanLtPic', DEFAULT_LOGIC_BOL_LT, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionLtPic', DEFAULT_LOGIC_OPT_LT, NO_FLAG);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUfBold', DEFAULT_LOGIC_BOLD_UF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUfForeColor', DEFAULT_LOGIC_COLOR_UF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUfPic',DEFAULT_LOGIC_BOL_UF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboUfPic', DEFAULT_LOGIC_COM_UF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanUfPic', DEFAULT_LOGIC_BOL_UF, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionUfPic',DEFAULT_LOGIC_OPT_UF, NO_FLAG);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUnBold', DEFAULT_LOGIC_BOLD_UN, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUnForeColor', DEFAULT_LOGIC_COLOR_UN, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUnPic', DEFAULT_LOGIC_BOL_UN, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboUnPic', DEFAULT_LOGIC_COM_UN, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanUnPic', DEFAULT_LOGIC_BOL_UN, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionUnPic', DEFAULT_LOGIC_OPT_UN, NO_FLAG);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUtBold', DEFAULT_LOGIC_BOLD_UT,NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUtForeColor', DEFAULT_LOGIC_COLOR_UT,NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicUtPic', DEFAULT_LOGIC_BOL_UT,NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicComboUtPic', DEFAULT_LOGIC_COM_UT,NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicBooleanUtPic', DEFAULT_LOGIC_BOL_UT,NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'CfgLogicOptionUtPic', DEFAULT_LOGIC_OPT_UT,NO_FLAG);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'LogicUseColors', DEFAULT_LOGIC_USE_COLORS,NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'LogicUseIcons', DEFAULT_LOGIC_USE_ICONS,NO_FLAG);

       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UseLabels',mUSE_LABELS, NO_FLAG);

    END IF;

    IF in_ui_type=DEF_FRAMESET THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Allocations',in_allocations, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'RowOrColumns',in_rowscols, NO_FLAG);
    END IF;

    IF in_ui_type=DEF_FRAME THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'BackgroundStyle','1', NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Borders',in_borders, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'MarginWidth',in_margin_width, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'MarginHeight',in_margin_height, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Sizeable',in_sizeable, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Scrolling',in_scrolling, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'SystemFrame',in_system_frm, NO_FLAG);
    END IF;

    IF in_ui_type=DEF_PANEL THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'AlternateRowColor',in_alt_color, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Borders',in_borders, NO_FLAG);
    END IF;

    IF in_ui_type=DEF_TAGGED_VALUE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'DataTag',in_data_tag, NO_FLAG);
    END IF;

    IF in_ui_type=DEF_BUTTON THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Action',in_action, NO_FLAG);
    END IF;

    IF in_ui_type=DEF_GRID THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'AlternateRowColor',in_alt_color, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Rowheaders',NO_FLAG, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'ColumnHeaders',YES_FLAG, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'GridLines',NO_FLAG, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Hierarchy',in_hierarchy, NO_FLAG);
    END IF;

    IF in_ui_type=DEF_COLUMN THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'Editable',in_editable, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'DataTag',in_data_tag, NO_FLAG);
    END IF;

    IF in_ui_type=DEF_MODELTREE THEN
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG, NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'TreeStyle','2', NO_FLAG);
       set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'UiStyle','3', NO_FLAG);
    END IF;

    IF in_ui_type=DEF_TEXT THEN
        set_UI_NODE_PROPS(in_ui_node_id,var_ui_def_id,'WindowDressing',YES_FLAG, NO_FLAG);
    END IF;
END generateBOMUIProps;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE generateUIProperties(in_ui_def_id IN INTEGER) IS
BEGIN
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicLfBold', DEFAULT_LOGIC_BOLD_LF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicLfForeColor', DEFAULT_LOGIC_COLOR_LF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicLfPic', DEFAULT_LOGIC_LGB_LF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicComboLfPic', DEFAULT_LOGIC_COM_LF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicBooleanLfPic', DEFAULT_LOGIC_BOL_LF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicOptionLfPic', DEFAULT_LOGIC_OPT_LF);

    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicLtBold', DEFAULT_LOGIC_BOLD_LT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicLtForeColor', DEFAULT_LOGIC_COLOR_LT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicLtPic', DEFAULT_LOGIC_LGB_LT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicComboLtPic', DEFAULT_LOGIC_COM_LT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicBooleanLtPic', DEFAULT_LOGIC_BOL_LT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicOptionLtPic', DEFAULT_LOGIC_OPT_LT);

    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUfBold', DEFAULT_LOGIC_BOLD_UF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUfForeColor', DEFAULT_LOGIC_COLOR_UF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUfPic',DEFAULT_LOGIC_LGB_UF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicComboUfPic', DEFAULT_LOGIC_COM_UF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicBooleanUfPic', DEFAULT_LOGIC_BOL_UF);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicOptionUfPic',DEFAULT_LOGIC_OPT_UF);

    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUnBold', DEFAULT_LOGIC_BOLD_UN);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUnForeColor', DEFAULT_LOGIC_COLOR_UN);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUnPic', DEFAULT_LOGIC_LGB_UN);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicComboUnPic', DEFAULT_LOGIC_COM_UN);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicBooleanUnPic', DEFAULT_LOGIC_BOL_UN);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicOptionUnPic', DEFAULT_LOGIC_OPT_UN);

    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUtBold', DEFAULT_LOGIC_BOLD_UT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUtForeColor', DEFAULT_LOGIC_COLOR_UT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicUtPic', DEFAULT_LOGIC_LGB_UT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicComboUtPic', DEFAULT_LOGIC_COM_UT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicBooleanUtPic',  DEFAULT_LOGIC_BOL_UT);
    SET_UI_PROPERTIES(in_ui_def_id,'CfgLogicOptionUtPic', DEFAULT_LOGIC_OPT_UT);

    SET_UI_PROPERTIES(in_ui_def_id,'UiVersion',TO_CHAR(UI_Version));

    SET_UI_PROPERTIES(in_ui_def_id,'NavFrameAllocation', GLOBAL_FRAME_ALLOCATION);
    SET_UI_PROPERTIES(in_ui_def_id,'NavFrameReservation', GLOBAL_FRAME_ALLOCATION);

END generateUIProperties;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- find the number of version for the next UI --
--

FUNCTION GenerateUiVersion(in_component_id IN INTEGER) RETURN INTEGER IS
    var_ui_version INTEGER:=0;
    max_ui_version INTEGER:=0;
BEGIN
    FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS WHERE COMPONENT_ID=in_component_id
             AND deleted_flag=NO_FLAG)
    LOOP
       BEGIN
           SELECT TO_NUMBER(value_str) INTO var_ui_version
           FROM CZ_UI_PROPERTIES WHERE ui_def_id=i.ui_def_id AND UPPER(KEY_STR)='UIVERSION';
           IF var_ui_version>max_ui_version THEN
              max_ui_version:=var_ui_version;
           END IF;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
       END;
    END LOOP;

    max_ui_version:=max_ui_version+1;
    RETURN max_ui_version;
END GenerateUiVersion;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- shift all non-customized buttons to the bottom of screen --
--

PROCEDURE shift_BUTTONS
(in_ui_node_id IN  INTEGER) IS

    var_parent_id   CZ_UI_NODES.parent_id%TYPE;
    var_top_pos     CZ_UI_NODES.rel_top_pos%TYPE;
    var_left_pos    CZ_UI_NODES.rel_left_pos%TYPE;
    var_left_border CZ_UI_NODES.rel_left_pos%TYPE;
    var_height      CZ_UI_NODES.height%TYPE;
    exist_Latest    BOOLEAN:=FALSE;
    END_OPERATION1  EXCEPTION;
    END_OPERATION2  EXCEPTION;

BEGIN
    --
    -- find max rel_top_pos for this particular screen   --
    -- if there are no controls on the screen then       --
    -- max = DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN --
    --
    SELECT NVL(MAX(rel_top_pos),DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN)
    INTO var_top_pos FROM CZ_UI_NODES
    WHERE parent_id=in_ui_node_id AND deleted_flag=NO_FLAG;

    --
    -- find a height of the UI control with max rel_top_pos --
    --
    SELECT NVL(MAX(height),DEFAULT_SPACE_BETWEEN) INTO var_height
    FROM CZ_UI_NODES WHERE parent_id=in_ui_node_id
    AND rel_top_pos=var_top_pos AND deleted_flag=NO_FLAG;

    last_TOP_POS:=var_top_pos+var_height+DEFAULT_SPACE_BETWEEN;
    var_left_pos:=LEFT_MARGIN;

    FOR i IN (SELECT ui_node_id,width,name FROM CZ_UI_NODES WHERE parent_id=in_ui_node_id
              AND ui_node_type=UI_BUTTON_TYPE AND name<>CZ_DELETE_BUTTON_CAPTION AND modified_flags=0 AND
              deleted_flag=NO_FLAG ORDER BY ui_node_id)
    LOOP
       var_left_border:=var_left_pos+i.width;
       IF var_left_border>LEFT_MARGIN+USABLE_WIDTH THEN
          last_TOP_POS:=last_TOP_POS+DEFAULT_BUTTON_HEIGHT+DEFAULT_SPACE_BETWEEN;
          var_left_pos:=LEFT_MARGIN;
          last_HEIGHT:=DEFAULT_BUTTON_HEIGHT;
          var_left_border:=LEFT_MARGIN+i.width;
       END IF;

       UPDATE CZ_UI_NODES SET rel_top_pos=last_TOP_POS,
                              rel_left_pos=var_left_pos
       WHERE ui_node_id=i.ui_node_id;
       var_left_pos:=var_left_border+SPACE_BETWEEN;
    END LOOP;
    last_TOP_POS:=last_TOP_POS+DEFAULT_BUTTON_HEIGHT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS THEN
         NULL;
END shift_BUTTONS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE shift_Latest_BUTTONS
(in_ui_node_id IN  INTEGER) IS

    var_parent_id   CZ_UI_NODES.parent_id%TYPE;
    var_top_pos     CZ_UI_NODES.rel_top_pos%TYPE;
    var_left_pos    CZ_UI_NODES.rel_left_pos%TYPE;
    var_left_border CZ_UI_NODES.rel_left_pos%TYPE;
    var_height      CZ_UI_NODES.height%TYPE;
    exist_Latest    BOOLEAN:=FALSE;
    END_OPERATION1  EXCEPTION;
    END_OPERATION2  EXCEPTION;

BEGIN

    IF latest_buttons.Count=0 THEN
       RAISE END_OPERATION2;
    END IF;

    SELECT NVL(MAX(rel_top_pos),DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN)
    INTO var_top_pos FROM CZ_UI_NODES
    WHERE parent_id=in_ui_node_id AND modified_flags<>CZ_NAVIGATION_MARK AND deleted_flag=NO_FLAG;

    SELECT NVL(MAX(height),DEFAULT_SPACE_BETWEEN) INTO var_height FROM CZ_UI_NODES
    WHERE parent_id=in_ui_node_id
    AND rel_top_pos=var_top_pos AND deleted_flag=NO_FLAG;

    last_TOP_POS:=var_top_pos+var_height+DEFAULT_SPACE_BETWEEN;
    var_left_pos:=LEFT_MARGIN;

    FOR i IN (SELECT ui_node_id,width FROM CZ_UI_NODES WHERE parent_id=in_ui_node_id
              AND ui_node_type=UI_BUTTON_TYPE AND name<>CZ_DELETE_BUTTON_CAPTION
              AND modified_flags=0 AND deleted_flag=NO_FLAG ORDER BY ui_node_id)
    LOOP
       BEGIN

           BEGIN
               FOR l IN latest_buttons.First..latest_buttons.Last
               LOOP
                  IF latest_buttons(l).id=i.ui_node_id THEN
                     RAISE END_OPERATION1;
                  END IF;
               END LOOP;
               RAISE END_OPERATION2;
           EXCEPTION
               WHEN END_OPERATION1 THEN
                    NULL;
           END;

           var_left_border:=var_left_pos+i.width;
           IF var_left_border>LEFT_MARGIN+USABLE_WIDTH THEN
              last_TOP_POS:=last_TOP_POS+DEFAULT_BUTTON_HEIGHT+DEFAULT_SPACE_BETWEEN;
              var_left_pos:=LEFT_MARGIN;
              last_HEIGHT:=DEFAULT_BUTTON_HEIGHT;
              var_left_border:=LEFT_MARGIN+i.width;
           END IF;
           UPDATE CZ_UI_NODES SET rel_top_pos=last_TOP_POS,
                                  rel_left_pos=var_left_pos
           WHERE ui_node_id=i.ui_node_id;
           var_left_pos:=var_left_border+SPACE_BETWEEN;

       EXCEPTION
           WHEN END_OPERATION2 THEN
                NULL;
       END;
    END LOOP;
    last_TOP_POS:=last_TOP_POS+DEFAULT_BUTTON_HEIGHT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS THEN
         NULL;
END shift_Latest_BUTTONS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_DIVIDER
(in_ui_node_id     IN INTEGER,
 in_parent_id      IN INTEGER,
 in_ui_def_id      IN INTEGER,
 in_top_pos        IN INTEGER , -- DEFAULT 37,
 in_left_pos       IN INTEGER , -- DEFAULT 45,
 in_modified_flag  IN INTEGER   -- DEFAULT 0
) IS
    var_num       INTEGER;
    END_OPERATION EXCEPTION;
BEGIN
    IF mLOOK_AND_FEEL='FORMS' THEN
       RAISE END_OPERATION;
    END IF;

    var_num:=FLOOR(USABLE_WIDTH/7);
    set_UI_NODES(in_ui_node_id       =>in_ui_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>NULL,
                 in_ui_node_ref_id   =>NULL,
                 in_name             =>'Horizontal Divider',
                 in_ui_node_type     =>UI_TEXT_LABEL_TYPE,
                 in_background_color =>DEFAULT_DIVIDER_COLOR,
                 in_component_id     =>NULL,
                 in_width            =>USABLE_WIDTH,
                 in_height           =>2,
                 in_tree_display_flag=>YES_FLAG,
                 in_use_default_font =>NO_FLAG,
                 in_top_pos          =>in_top_pos,
                 in_left_pos         =>in_left_pos,
                 in_text_label       =>lpad(' ',var_num),
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>DEFAULT_DIVIDER_COLOR,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_bkgrnd_style     =>YES_FLAG,
                 in_use_default_color=>NO_FLAG,
                 in_modified_flag    =>in_modified_flag);

    generateUIProps(in_ui_node_id,in_ui_def_id,DEF_TEXT_LABEL,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

EXCEPTION
    WHEN END_OPERATION THEN
         NULL;
END create_DIVIDER;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_TEXT_LABEL
(in_ui_node_id       IN INTEGER,
 in_parent_id        IN INTEGER,
 in_ui_def_id        IN INTEGER,
 in_node_id          IN INTEGER,
 in_top_pos          IN INTEGER,
 in_left_pos         IN INTEGER,
 in_text             IN VARCHAR2,
 in_use_default_font IN VARCHAR2, -- DEFAULT YES_FLAG,
 in_display_flag     IN VARCHAR2, -- DEFAULT NO_FLAG,
 in_font_name        IN VARCHAR2, -- DEFAULT DEFAULT_FONT_NAME,
 in_font_bold        IN VARCHAR2, -- DEFAULT NO_FLAG,
 in_font_color       IN INTEGER , -- DEFAULT DEFAULT_FONT_COLOR,
 in_font_italic      IN VARCHAR2, -- DEFAULT YES_FLAG,
 in_font_size        IN INTEGER , -- DEFAULT DEFAULT_FONT_SIZE,
 in_font_underline   IN VARCHAR2, -- DEFAULT NO_FLAG,
 in_title            IN VARCHAR2, -- DEFAULT NO_FLAG,
 in_align            IN VARCHAR2, -- DEFAULT 'right',
 in_name             IN VARCHAR2 DEFAULT NULL,
 in_intl_text_id     IN INTEGER  DEFAULT NULL,
 in_parent_name      IN VARCHAR2 DEFAULT NULL,
 in_page_number      IN VARCHAR2 DEFAULT NULL,
 in_width            IN INTEGER  DEFAULT NULL,
 in_ui_node_ref_id   IN INTEGER  DEFAULT NULL) IS

    var_text_width CZ_UI_NODES.width%TYPE;
    var_top_pos    CZ_UI_NODES.rel_top_pos%TYPE;
    var_left_pos   CZ_UI_NODES.rel_left_pos%TYPE;
    var_height     CZ_UI_NODES.height%TYPE;

BEGIN
    IF in_title=YES_FLAG THEN
       var_top_pos:=11;
       var_left_pos:=LEFT_MARGIN;
        ----var_text_width:=set_Title_Width(in_text);----
       var_text_width:=USABLE_WIDTH-DELETE_BUTTON_WIDTH;
       var_height:=26;
    ELSE
       var_top_pos:=in_top_pos;
       var_left_pos:=in_left_pos;
       IF in_width IS NOT NULL THEN
          var_text_width:=in_width;
       ELSE
          var_text_width:=set_Text_Width(in_text);
       END IF;
       var_height:=DEFAULT_TEXT_HEIGHT;
    END IF;

    set_UI_NODES(in_ui_node_id       =>in_ui_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>NULL,
                 in_ui_node_ref_id   =>in_ui_node_ref_id,
                 in_name             =>NVL(in_name,'Text-'||TO_CHAR(in_node_id)),
                 in_ui_node_type     =>UI_TEXT_LABEL_TYPE,
                 in_background_color =>DEFAULT_BACKGROUND_COLOR,
                 in_component_id     =>NULL,
                 in_width            =>var_text_width,
                 in_height           =>var_height,
                 in_tree_display_flag=>in_display_flag,
                 in_use_default_font =>in_use_default_font,
                 in_top_pos          =>var_top_pos,
                 in_left_pos         =>var_left_pos,
                 in_font_name        =>in_font_name,
                 in_font_bold        =>in_font_bold,
                 in_font_color       =>in_font_color,
                 in_font_italic      =>in_font_italic,
                 in_font_size        =>in_font_size,
                 in_font_underline   =>in_font_underline,
                 in_use_default_color=>NO_FLAG,
                 in_bkgrnd_style     =>NO_FLAG,
                 in_intl_text_id     =>in_intl_text_id,
                 in_parent_name      =>in_parent_name,
                 in_caption          =>in_text,
                 in_page_number      =>in_page_number);

    generateUIProps(in_ui_node_id,in_ui_def_id,DEF_TEXT_LABEL,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, in_align, '0');
END create_TEXT_LABEL;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_BUTTON
(in_ui_node_id     IN INTEGER,
 in_parent_id      IN INTEGER,
 in_ui_def_id      IN INTEGER,
 in_ps_node_id     IN INTEGER,
 in_text           IN VARCHAR2,
 in_top_pos        IN INTEGER,
 in_left_pos       IN INTEGER,
 in_button_type    IN INTEGER,
 in_width          IN INTEGER DEFAULT NULL,
 in_func_comp_id   IN INTEGER DEFAULT NULL,
 in_ui_node_ref_id IN INTEGER DEFAULT NULL,
 in_intl_text_id   IN INTEGER DEFAULT NULL,
 in_modified_flag  IN INTEGER, -- DEFAULT 0
 in_cx_command_name IN VARCHAR2 DEFAULT NULL,
 in_rule_id         IN NUMBER DEFAULT NULL
) IS

    var_button_width CZ_UI_NODES.width%TYPE;
    var_text_str     CZ_INTL_TEXTS.text_str%TYPE;

BEGIN
    IF in_intl_text_id IS NOT NULL THEN
       SELECT text_str INTO var_text_str FROM CZ_INTL_TEXTS
       WHERE intl_text_id=in_intl_text_id;
    ELSE
       var_text_str:=in_text;
    END IF;

    IF in_width IS NULL THEN
       var_button_width:=8*LENGTH(var_text_str)+25;
    ELSE
       var_button_width:=DELETE_BUTTON_WIDTH;
    END IF;
    set_UI_NODES(in_ui_node_id,in_parent_id,in_ui_def_id,
                 in_ps_node_id,in_ui_node_ref_id,in_text,
                 UI_BUTTON_TYPE,DEFAULT_COLOR,in_ps_node_id,
                 var_button_width,DEFAULT_BUTTON_HEIGHT,
                 in_tree_display_flag=>YES_FLAG,
                 in_use_default_color=>NO_FLAG,
                 in_top_pos          =>in_top_pos,
                 in_left_pos         =>in_left_pos,
                 in_picname          =>'',
                 in_borders          =>NO_FLAG,
                 in_bkgrnd_style     =>YES_FLAG,
                 in_func_comp_id     =>in_func_comp_id,
                 in_intl_text_id     =>in_intl_text_id,
                 in_modified_flag    =>in_modified_flag,
                 in_cx_command_name  =>in_cx_command_name);

    generateUIProps(in_ui_node_id,in_ui_def_id,in_button_type,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0',
                    in_ps_node_id => in_ps_node_id,
                    in_rule_id    => in_rule_id);

END create_BUTTON;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_ADD_BUTTONS
(in_ui_def_id IN INTEGER) IS

     var_parent_id CZ_UI_NODES.parent_id%TYPE;
     k             INTEGER;

BEGIN
    IF add_buttons.Count>0 THEN
       k:=add_buttons.First;
       LOOP
          IF k IS NULL THEN
             EXIT;
          END IF;

          SELECT ui_node_id INTO var_parent_id FROM CZ_UI_NODES WHERE
          ui_def_id=in_ui_def_id AND ps_node_id=add_buttons(k).ps_parent_id
          AND ui_node_type IN(UI_COMPONENT_TYPE,UI_PRODUCT_TYPE) AND deleted_flag=NO_FLAG;
          create_BUTTON(add_buttons(k).id,var_parent_id,in_ui_def_id,
                        k,'Add '||add_buttons(k).name,
                        in_top_pos          =>LEFT_MARGIN,
                        in_left_pos         =>LEFT_MARGIN,
                        in_button_type      =>DEF_ADD_BUTTON,
                        in_modified_flag    => 0);

          k:=add_buttons.NEXT(k);
        END LOOP;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,TO_CHAR(var_parent_id), CZ_ERROR_URGENCY);
    WHEN OTHERS THEN
         FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,TO_CHAR(var_parent_id), CZ_ERROR_URGENCY);
END create_ADD_BUTTONS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- returns action type assoaciated with CZ Extensions button
-- Parameters :
--  p_rule_id - identifies CZ Extension
--
PROCEDURE check_for_CZEXT_Button
(
p_rule_id          IN NUMBER,
x_action_type      OUT NOCOPY NUMBER,
x_cx_command_name  OUT NOCOPY VARCHAR2,
x_event_scope      OUT NOCOPY NUMBER
)IS

    var_cx_command      CZ_EXPRESSION_NODES.data_value%TYPE;
    var_genoutput_flag  VARCHAR2(1);
    var_action_type     NUMBER;

BEGIN
    FOR i IN(SELECT expr_node_id,data_value,event_execution_scope FROM CZ_EXPRESSION_NODES
             WHERE rule_id=p_rule_id AND deleted_flag='0'
                   AND argument_signature_id=EVENT_ON_COMMAND_SIGID AND data_value IS NOT NULL)
    LOOP
        x_action_type      := RAISE_COMMAND_EVENT;
        x_event_scope      := i.event_execution_scope;
        x_cx_command_name  := i.data_value;
   END LOOP;
END check_for_CZEXT_Button;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_FUNC_BUTTONS
(in_project_id IN INTEGER,
 in_ui_def_id  IN INTEGER,
 in_limbo_id   IN INTEGER) IS

    var_button_id       CZ_UI_NODES.ui_node_id%TYPE;
    var_parent_id       CZ_UI_NODES.parent_id%TYPE;
    var_cx_command_name CZ_UI_NODES.cx_command_name%TYPE;
    var_nearest_comp_id CZ_PS_NODES.ps_node_id%TYPE;
    var_event_scope     CZ_EXPRESSION_NODES.event_execution_scope%TYPE;
    var_ps_parent_id    CZ_PS_NODES.parent_id%TYPE;
    var_ps_node_type    CZ_PS_NODES.ps_node_type%TYPE;
    var_component_id    CZ_UI_NODES.ps_node_id%TYPE;
    var_button_type     INTEGER;
    ind                 INTEGER;
    var_suff            VARCHAR2(10):='';
BEGIN

    -- companion_type is 4 bits binary :
    -- AUTO-CONFIG              0001 = 1
    -- VALIDATION               0010 = 2
    -- OUTPUT                   0100 = 4
    -- EVENT_DRIVEN             1000 = 8
    --
    -- companion_type IN(1,3,4,5,6,7,9,11,12,13,14,15) <=>
    -- combinations with AUTO-CONFIG bit = 1 or OUTPUT bit = 1
    --

    FOR i IN (SELECT func_comp_id,component_id,companion_type,name FROM CZ_FUNC_COMP_SPECS a
              WHERE devl_project_id=in_project_id AND companion_type IN(1,3,4,5,6,7,9,11,12,13,14,15) AND
              NOT EXISTS(SELECT NULL FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND
              ps_node_id=a.component_id AND ui_node_type=UI_BUTTON_TYPE AND func_comp_id=a.func_comp_id
              AND parent_id<>in_limbo_id AND deleted_flag=NO_FLAG) AND deleted_flag=NO_FLAG)
    LOOP
       BEGIN
           var_button_id:=getUISeqVal;

           --
           -- if the following select fails then
           -- this means that Component( Product,BOM OC/Model ) is not visible in UI
           -- in this case we just go to the EXCEPTION part and
           --  go to the next iterration of the loop ( buttons are not generated )
           --
           SELECT ui_node_id INTO var_parent_id FROM CZ_UI_NODES WHERE
           ui_def_id=in_ui_def_id AND ps_node_id=i.component_id
           AND ui_node_type IN(UI_COMPONENT_TYPE,UI_PRODUCT_TYPE) AND deleted_flag=NO_FLAG;

           --
           -- AUTO-CONFIG =1 OUTPUT = 0 combinations :
           -- 0001 = 1
           -- 0011 = 3
           -- 1001 = 9
           -- 1011 = 11
           --
           IF i.companion_type IN(1,3,9,11) THEN     -- AUTO-CONFIG
              var_button_type:=DEF_FUNC_BUTTON1;

           --
           -- AUTO-CONFIG =0 OUTPUT = 1 combinations :
           -- 0100 = 4
           -- 0110 = 6
           -- 1100 = 12
           -- 1110 = 14
           --
           ELSIF i.companion_type IN(4,6,12,14) THEN  -- OUTPUT
              var_button_type:=DEF_FUNC_BUTTON2;

           --
           -- AUTO-CONFIG =1 OUTPUT = 1 combinations :
           -- 0101 = 5
           -- 0111 = 7
           -- 1101 = 13
           -- 1111 = 15
           --
           ELSIF i.companion_type IN(5,7,13,15) THEN -- AUTO-CONFIG + OUTPUT
              var_button_type:=DEF_FUNC_BUTTON1;
              var_suff:=' (1)';
           END IF;
           create_BUTTON(var_button_id,var_parent_id,in_ui_def_id,
                         i.component_id,i.name||var_suff,
                         in_top_pos          =>LEFT_MARGIN,
                         in_left_pos         =>LEFT_MARGIN,
                         in_button_type      =>var_button_type,
                         in_func_comp_id     =>i.func_comp_id,
                         in_modified_flag    => 0);

          IF latest_buttons.Count=0 THEN
              ind:=1;
           ELSE
              ind:=latest_buttons.Last+1;
           END IF;
           latest_buttons(ind).id:=var_button_id;

           --
           -- in this case ( both Auto-Config and Output ) we need 2 buttons --
           --
           IF i.companion_type IN(5,7,13,15) THEN
              var_button_id:=getUISeqVal;
              create_BUTTON(var_button_id,var_parent_id,in_ui_def_id,
                            i.component_id,i.name||' (2)',
                            in_top_pos          =>LEFT_MARGIN,
                            in_left_pos         =>LEFT_MARGIN,
                            in_button_type      =>DEF_FUNC_BUTTON2,
                            in_func_comp_id     =>i.func_comp_id,
                            in_modified_flag    => 0);

              IF latest_buttons.Count=0 THEN
                 ind:=1;
              ELSE
                 ind:=latest_buttons.Last+1;
              END IF;
              latest_buttons(ind).id:=var_button_id;
           END IF;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
           WHEN OTHERS THEN
                --LOG_REPORT('CZ_UI_GENERATOR.create_FUNC_BUTTONS','parent_id='||TO_CHAR(var_parent_id)||' : '||SQLERRM);
                FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,TO_CHAR(var_parent_id), CZ_ERROR_URGENCY);
       END;
   END LOOP;

   FOR i IN(SELECT rule_id,component_id,name FROM CZ_RULES
            WHERE devl_project_id=in_project_id AND
            rule_type=CZ_EXTENTSIONS_RULE_TYPE AND deleted_flag=NO_FLAG AND
            disabled_flag=NO_FLAG)
   LOOP
      check_for_CZEXT_Button(p_rule_id          => i.rule_id,
                             x_action_type      => var_button_type,
                             x_cx_command_name  => var_cx_command_name,
                             x_event_scope      => var_event_scope);

      IF var_button_type IN(GENERATE_OUTPUT_EVENT,RAISE_COMMAND_EVENT) THEN
         BEGIN

           var_button_id:=getUISeqVal;

           SELECT parent_id,ps_node_type INTO var_ps_parent_id,var_ps_node_type FROM CZ_PS_NODES
           WHERE ps_node_id=i.component_id;

           IF var_ps_node_type IN(BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE,COMPONENT_NODE_TYPE,PRODUCT_NODE_TYPE) THEN
              var_nearest_comp_id := i.component_id;
           ELSIF var_ps_node_type IN(FEATURE_NODE_TYPE,TOTAL_NODE_TYPE,RESOURCE_NODE_TYPE,REFERENCE_NODE_TYPE,CONNECTOR_NODE_TYPE) THEN
              var_nearest_comp_id := var_ps_parent_id;
           ELSE
              NULL;
           END IF;
           --
           -- if the following select fails then
           -- this means that Component( Product,BOM OC/Model ) is not visible in UI
           -- in this case we just go to the EXCEPTION part and
           --  go to the next iterration of the loop ( buttons are not generated )
           --
           SELECT ui_node_id INTO var_parent_id FROM CZ_UI_NODES WHERE
           ui_def_id=in_ui_def_id AND ps_node_id=var_nearest_comp_id
           AND ui_node_type IN(UI_COMPONENT_TYPE,UI_PRODUCT_TYPE) AND deleted_flag=NO_FLAG;

           create_BUTTON(var_button_id,var_parent_id,in_ui_def_id,
                         i.component_id,i.name,
                         in_top_pos          => LEFT_MARGIN,
                         in_left_pos         => LEFT_MARGIN,
                         in_button_type      => var_button_type,
                         in_cx_command_name  => var_cx_command_name,
                         in_modified_flag    => 0,
                         in_rule_id          => i.rule_id);
           IF latest_buttons.Count=0 THEN
              ind:=1;
           ELSE
              ind:=latest_buttons.Last+1;
           END IF;
           latest_buttons(ind).id:=var_button_id;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
           WHEN OTHERS THEN
                FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,TO_CHAR(var_parent_id), CZ_ERROR_URGENCY);
       END;
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
        NULL;
END create_FUNC_BUTTONS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- populate CZ_UI_NODES.model_ref_expl_id associated with References
--
PROCEDURE populate_RefSI(in_ui_def_id IN INTEGER) IS
    var_ui_node_ref_id   CZ_UI_NODES.ui_node_ref_id%TYPE;
    var_ref_model_id     CZ_MODEL_REF_EXPLS.component_id%TYPE;
    var_ref_root_screen  CZ_UI_NODES.ui_node_id%TYPE;
BEGIN
    FOR i IN(SELECT ps_node_id,model_ref_expl_id,ui_def_ref_id FROM CZ_UI_NODES
             WHERE ui_def_id=in_ui_def_id AND deleted_flag=NO_FLAG
             AND ui_node_type=UI_REFERENCE_REF_TYPE)
    LOOP
       FOR k IN(SELECT ui_node_id FROM CZ_UI_NODES
                WHERE ui_def_id=in_ui_def_id AND deleted_flag=NO_FLAG
                AND ps_node_id=i.ps_node_id AND ui_node_type=UI_BOM_STANDART_TYPE)
       LOOP
          var_ui_node_ref_id:=NULL;
          UPDATE CZ_UI_NODES
          SET model_ref_expl_id=i.model_ref_expl_id
          WHERE ui_def_id=in_ui_def_id AND ui_node_id=k.ui_node_id
          RETURNING ui_node_ref_id INTO var_ui_node_ref_id;

          --
          -- this block will be executed just in case
          -- when we have a corrupted data
          -- in this case it will fix it
          --
          IF var_ui_node_ref_id IS NULL THEN
             BEGIN
                 SELECT component_id INTO var_ref_model_id
                 FROM CZ_MODEL_REF_EXPLS a
                 WHERE model_id=Project_Id AND deleted_flag=NO_FLAG
                 AND referring_node_id=i.ps_node_id AND ps_node_type=REFERENCE_NODE_TYPE AND rownum<2;

                 SELECT ui_node_id INTO var_ref_root_screen FROM CZ_UI_NODES
                 WHERE ui_def_id=i.ui_def_ref_id AND ui_node_type=UI_SCREEN_TYPE
                 AND ps_node_id=var_ref_model_id AND deleted_flag=NO_FLAG AND rownum<2;

                 UPDATE CZ_UI_NODES
                 SET ui_node_ref_id=var_ref_root_screen
                 WHERE ui_def_id=in_ui_def_id
                 AND ui_node_id=k.ui_node_id AND ui_node_ref_id IS NULL;
             EXCEPTION
                 WHEN OTHERS THEN
                      NULL;
             END;
           END IF;
        END LOOP;
    END LOOP;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_Wizard_Style_Buttons
(in_ui_def_id IN INTEGER,
 in_limbo_id  IN INTEGER -- DEFAULT -1
) IS
    var_top_pos      CZ_UI_NODES.rel_top_pos%TYPE;
    var_height       CZ_UI_NODES.height%TYPE;
    var_ui_node_id   CZ_UI_NODES.ui_node_id%TYPE;
    var_screen_width CZ_UI_NODES.width%TYPE;
    var_id           CZ_UI_NODES.ui_node_id%TYPE;
BEGIN
    var_screen_width:=USABLE_WIDTH+RIGHT_MARGIN;
    IF footer_buttons.Count>0 THEN
       var_top_pos:=LEFT_MARGIN;

       FOR i IN footer_buttons.First..footer_buttons.Last
       LOOP
          var_ui_node_id:=footer_buttons(i).ui_parent_id;
          var_id:=footer_buttons(i).id;

          IF var_id>0 THEN

             create_DIVIDER(getUISeqVal,var_ui_node_id,in_ui_def_id,0,45,
                            in_modified_flag=>CZ_NAVIGATION_MARK);

             create_BUTTON(getUISeqVal,var_ui_node_id,in_ui_def_id,
                           NULL,'Home',
                           in_top_pos          =>0,
                           in_left_pos         =>var_screen_width-195,
                           in_button_type      =>DEF_HOME_SCREEN,
                           in_modified_flag    =>CZ_NAVIGATION_MARK);

             create_BUTTON(getUISeqVal,var_ui_node_id,in_ui_def_id,
                           NULL,'Back',
                           in_top_pos          =>0,
                           in_left_pos         =>var_screen_width-126,
                           in_button_type      =>DEF_PREV_SCREEN,
                           in_modified_flag    =>CZ_NAVIGATION_MARK);

             create_BUTTON(getUISeqVal,var_ui_node_id,in_ui_def_id,
                           NULL,'Next',
                           in_top_pos          =>0,
                           in_left_pos         =>var_screen_width-57,
                           in_button_type      =>DEF_NEXT_SCREEN,
                           in_modified_flag    =>CZ_NAVIGATION_MARK);
         END IF;
       END LOOP;
    END IF;

   FOR i IN(SELECT ui_node_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
            AND deleted_flag='0' AND ui_node_type=UI_COMPONENT_TYPE)
   LOOP
      SELECT NVL(MAX(rel_top_pos),0)
      INTO var_top_pos FROM CZ_UI_NODES
      WHERE parent_id=i.ui_node_id AND modified_flags<>CZ_NAVIGATION_MARK
      AND parent_id<>in_limbo_id AND deleted_flag=NO_FLAG;

      SELECT NVL(MAX(height),DEFAULT_SPACE_BETWEEN) INTO var_height FROM CZ_UI_NODES
      WHERE parent_id=i.ui_node_id
      AND rel_top_pos=var_top_pos AND modified_flags<>CZ_NAVIGATION_MARK AND
      parent_id<>in_limbo_id AND deleted_flag=NO_FLAG;

      IF var_top_pos<=DEFAULT_HEADER_HEIGHT+DEFAULT_DIVIDER_HEIGHT THEN
         var_top_pos:=DEFAULT_HEADER_HEIGHT+DEFAULT_DIVIDER_HEIGHT;
      ELSE
         var_top_pos:=var_top_pos+var_height+DEFAULT_SPACE_BETWEEN;
      END IF;

      UPDATE CZ_UI_NODES a SET rel_top_pos=var_top_pos
      WHERE ui_def_id=in_ui_def_id AND parent_id=i.ui_node_id AND ui_node_type=UI_TEXT_LABEL_TYPE AND
      modified_flags=CZ_NAVIGATION_MARK AND deleted_flag=NO_FLAG;

      var_top_pos:=var_top_pos+DEFAULT_DIVIDER_HEIGHT+DEFAULT_SPACE_BETWEEN;
      UPDATE CZ_UI_NODES a SET rel_top_pos=var_top_pos
      WHERE ui_def_id=in_ui_def_id AND parent_id=i.ui_node_id AND ui_node_type=UI_BUTTON_TYPE AND
      modified_flags=CZ_NAVIGATION_MARK AND deleted_flag=NO_FLAG;
   END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_PRODUCT
(in_node_id   IN INTEGER,
 in_parent_id IN INTEGER,
 in_ui_def_id IN INTEGER,
 in_arr       IN UIStructure) IS

    curr_label_id  CZ_UI_NODES.ui_node_id%TYPE;
    curr_bitmap_id CZ_UI_NODES.ui_node_id%TYPE;
    curr_button_id CZ_UI_NODES.ui_node_id%TYPE;
    ind            INTEGER;

BEGIN
    last_TOP_POS:=DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN;
    curr_label_id:=getUISeqVal;
    curr_bitmap_id:=getUISeqVal;

    set_UI_NODES(in_node_id,
                 in_parent_id,
                 in_ui_def_id,
                 in_arr.ps_node_id,
                 curr_label_id,
                 in_arr.name,
                 UI_PRODUCT_TYPE,
                 DEFAULT_BACKGROUND_COLOR,
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_use_default_font =>YES_FLAG,
                 in_use_default_color=>YES_FLAG,
                 in_use_default_pic  =>YES_FLAG,
                 in_top_pos          =>DEFAULT_PROD_TOP,
                 in_left_pos         =>DEFAULT_PROD_LEFT,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>9,
                 in_font_underline   =>NO_FLAG);

    --
    -- create Text Label for PRODUCT --
    --
    create_TEXT_LABEL(curr_label_id,in_node_id,in_ui_def_id,curr_label_id,
                      DEFAULT_REL_TOP,DEFAULT_REL_LEFT,in_arr.caption_name,
                      in_font_color       =>DEFAULT_TITLE_COLOR,
                      in_font_size        =>DEFAULT_CAPTION_FONT_SIZE,
                      in_display_flag     =>YES_FLAG,
                      in_use_default_font =>NO_FLAG,
                      in_title            =>YES_FLAG,
                      in_name             =>'Page Title',
                      in_align            =>'left',
                      in_intl_text_id     =>in_arr.intl_text_id,
                      in_parent_name      =>in_arr.name
                     ,in_font_name        => DEFAULT_FONT_NAME
                     ,in_font_bold        => NO_FLAG
                     ,in_font_italic      => YES_FLAG
                     ,in_font_underline   => NO_FLAG
                     );

    --
    -- create DIVIDER for PRODUCT --
    --
    create_DIVIDER(curr_bitmap_id,in_node_id,in_ui_def_id, 37, 45, 0);

    IF in_arr.virtual_flag=NO_FLAG AND in_arr.parent_id IS NOT NULL
       AND mUI_STYLE=DHTML_STYLE_UI THEN

       UPDATE CZ_UI_NODES SET component_id=in_arr.ps_node_id,ps_node_id=in_arr.ps_node_id
       WHERE ui_node_ref_id=in_node_id;

                                     -- Delete Button --
       create_BUTTON(getUISeqVal,in_node_id,in_ui_def_id,
                    in_arr.ps_node_id,CZ_DELETE_BUTTON_CAPTION,
                    in_top_pos    =>DELETE_BUTTON_TOP_POS,
                    in_left_pos   =>DELETE_BUTTON_LEFT_POS,
                    in_button_type=>DEF_DELETE_BUTTON,
                    in_width      =>DELETE_BUTTON_WIDTH,
                    in_modified_flag    => 0);

                                     -- Add Button --
        curr_button_id:=getUISeqVal;

        add_buttons(in_arr.ps_node_id).id:=curr_button_id;
        add_buttons(in_arr.ps_node_id).name:=in_arr.caption_name;
        add_buttons(in_arr.ps_node_id).ps_parent_id:=in_arr.parent_id;

        IF latest_buttons.Count=0 THEN
           ind:=1;
        ELSE
           ind:=latest_buttons.Last+1;
        END IF;
        latest_buttons(ind).id:=curr_button_id;
    END IF;

END create_PRODUCT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_PRODUCT_Model
(in_node_id     IN INTEGER,
 in_parent_id   IN INTEGER,
 in_ui_def_id   IN INTEGER,
 in_node_ref_id IN INTEGER,
 in_arr         IN UIStructure) IS
    var_ps_id CZ_UI_NODES.ps_node_id%TYPE;
BEGIN
--    IF in_arr.virtual_flag=NO_FLAG THEN
       var_ps_id:=in_arr.ps_node_id;
--    ELSE
--       var_ps_id:=NULL;
--    END IF;

    --
    -- create PRODUCT node for Model Tree --
    --
    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>var_ps_id,
                 in_ui_node_ref_id   =>in_node_ref_id,
                 in_name             =>in_arr.name,
                 in_ui_node_type     =>UI_PRODUCT_REF_TYPE,
                 in_tree_display_flag=>NO_FLAG,
                 in_component_id     =>var_ps_id,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_intl_text_id     =>in_arr.intl_text_id);

    generateUIProps(in_node_id,in_ui_def_id,DEF_PRODUCT_SCREEN,
                    0, in_arr.minimum, in_arr.maximum,
                    NO_FLAG, NO_FLAG, in_arr.virtual_flag,
                    0, 'left', '0');

END create_PRODUCT_Model;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION get_last_UI
(in_ref_id    IN INTEGER) RETURN NUMBER IS
    var_date DATE;
    ret      INTEGER:=0;
BEGIN
    BEGIN
       SELECT MAX(creation_date) INTO var_date FROM CZ_UI_DEFS
       WHERE  component_id=in_ref_id AND ui_style=mUI_STYLE AND look_and_feel=mLOOK_AND_FEEL
       AND deleted_flag=NO_FLAG;

       SELECT NVL(MAX(ui_def_id),0) INTO ret FROM CZ_UI_DEFS
       WHERE component_id=in_ref_id AND ui_style=mUI_STYLE AND look_and_feel=mLOOK_AND_FEEL
       AND creation_date=var_date  AND deleted_flag=NO_FLAG;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN OTHERS THEN
             NULL;
    END;

    RETURN ret;

END get_last_UI;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE add_BOM_MODEL_ITEM
(in_ui_parent_id IN INTEGER,
 in_ref_model_id IN INTEGER,
 in_ui_def_id    IN INTEGER,
 in_ref_ps_id    IN INTEGER,
 in_maximum      IN INTEGER  , -- DEFAULT 1,
 in_minimum      IN INTEGER  , -- DEFAULT 1,
 in_virtual_flag IN VARCHAR2 , -- DEFAULT '1',
 in_t_ref_uis    IN IntArray) IS

    var_ui_node_id        CZ_UI_NODES.ui_node_id%TYPE;
    var_ui_parent_id      CZ_UI_NODES.parent_id%TYPE;
    var_top_pos           CZ_UI_NODES.rel_top_pos%TYPE;
    var_ui_node_type      CZ_UI_NODES.ui_node_type%TYPE;
    var_width             CZ_UI_NODES.width%TYPE;
    var_text_width        CZ_UI_NODES.width%TYPE;
    var_height            CZ_UI_NODES.height%TYPE;
    var_text_label_id     CZ_UI_NODES.ui_node_id%TYPE;
    var_borders           CZ_UI_NODES.borders%TYPE:=NO_FLAG;
    var_prev_height       CZ_UI_NODES.height%TYPE;
    var_ps_node_id        CZ_PS_NODES.ps_node_id%TYPE;
    var_root_ps_type      CZ_PS_NODES.ps_node_type%TYPE;
    var_name              CZ_PS_NODES.name%TYPE;
    var_tree_seq          CZ_PS_NODES.tree_seq%TYPE;
    var_intl_text_id      CZ_PS_NODES.intl_text_id%TYPE;
    var_text_str          CZ_INTL_TEXTS.text_str%TYPE;
    var_caption_name      CZ_INTL_TEXTS.text_str%TYPE;
    var_align             CZ_UI_NODE_PROPS.value_str%TYPE;
    var_ref_root_screen   CZ_UI_NODES.ui_node_id%TYPE;
    var_model_ref_expl_id CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    var_use_labels        VARCHAR2(1);
    Top_Labeled           BOOLEAN:=FALSE;

BEGIN
    SELECT ui_node_ref_id INTO var_ui_parent_id
    FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
    AND ui_node_id=in_ui_parent_id;

    SELECT ps_node_id,name,tree_seq,intl_text_id,ps_node_type
    INTO var_ps_node_id,var_name,var_tree_seq,var_intl_text_id,var_root_ps_type
    FROM CZ_PS_NODES WHERE devl_project_id=in_ref_model_id AND parent_id IS NULL
    AND deleted_flag=NO_FLAG;

    IF var_root_ps_type=BOM_MODEL_NODE_TYPE THEN
       NULL;
    ELSIF var_root_ps_type=PRODUCT_NODE_TYPE THEN
       SELECT ps_node_id,name,tree_seq,intl_text_id
       INTO var_ps_node_id,var_name,var_tree_seq,var_intl_text_id
       FROM CZ_PS_NODES WHERE devl_project_id=in_ref_model_id AND parent_id=in_ref_model_id
       AND ps_node_type=BOM_MODEL_NODE_TYPE AND deleted_flag=NO_FLAG;
    ELSE
       RETURN;
    END IF;

    BEGIN
        SELECT MIN(model_ref_expl_id) INTO var_model_ref_expl_id
        FROM CZ_MODEL_REF_EXPLS a WHERE model_id=Project_Id AND component_id=in_ref_model_id
        AND referring_node_id=in_ref_ps_id AND ps_node_type=REFERENCE_NODE_TYPE
        AND deleted_flag=NO_FLAG;
    EXCEPTION
    WHEN OTHERS THEN
        var_model_ref_expl_id:=NULL;
    END;
    BEGIN
        SELECT text_str INTO var_text_str FROM CZ_INTL_TEXTS
        WHERE intl_text_id=var_intl_text_id;
    EXCEPTION
        WHEN OTHERS THEN
             --
             -- if there is a problem with description
             -- then use PS name instead
             --
             var_text_str:=var_name;
             var_intl_text_id:=NULL;
    END;

    SELECT MAX(rel_top_pos) INTO var_top_pos FROM CZ_UI_NODES
    WHERE ui_def_id=in_ui_def_id AND parent_id=var_ui_parent_id
    AND modified_flags<>CZ_NAVIGATION_MARK AND deleted_flag=NO_FLAG;

    SELECT NVL(max(height),DEFAULT_SPACE_BETWEEN) INTO var_prev_height FROM CZ_UI_NODES
    WHERE ui_def_id=in_ui_def_id AND parent_id=var_ui_parent_id
    AND modified_flags<>CZ_NAVIGATION_MARK AND rel_top_pos=var_top_pos AND deleted_flag=NO_FLAG;

    IF var_top_pos<=DEFAULT_HEADER_HEIGHT+DEFAULT_DIVIDER_HEIGHT THEN
       var_top_pos:=DEFAULT_HEADER_HEIGHT+DEFAULT_DIVIDER_HEIGHT+DEFAULT_SPACE_BETWEEN;
    ELSE
       var_top_pos:=var_top_pos+var_prev_height+DEFAULT_SPACE_BETWEEN;
    END IF;

    --
    -- find the value of "UseLabels" property of the screen which is
    -- a parent screen for STANDTART ITEM associated with the reference
    --
    BEGIN
        --
        -- by default global "UseLabels" property is used
        --
        var_use_labels:=mUSE_LABELS;

        --
        -- the nested SELECT statement should always return 1 record
        -- because there is just one screen that contains a STANDART ITEM
        -- associated with the given reference
        -- ( the reference and the STANDART ITEM have the same ps_node_id )
        --
        SELECT value_str INTO var_use_labels FROM CZ_UI_NODE_PROPS
        WHERE ui_node_id=var_ui_parent_id
        AND UPPER(key_str)='USELABELS' AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
    END;

    var_ui_node_id:=getUISeqVal;

    IF  in_t_ref_uis.Count>0 THEN
        BEGIN
            SELECT ui_node_id INTO var_ref_root_screen FROM CZ_UI_NODES
            WHERE ui_def_id=in_t_ref_uis(in_ref_ps_id) AND ui_node_type=UI_SCREEN_TYPE
            AND ps_node_id=in_ref_model_id AND deleted_flag=NO_FLAG AND rownum<2;
        EXCEPTION
            WHEN OTHERS THEN
                 NULL;
        END;
    END IF;

    IF NOT (in_maximum=1 AND in_minimum=1) OR in_virtual_flag=NO_FLAG THEN

       BEGIN
          SELECT text_str||' Configurations' INTO var_caption_name
          FROM CZ_INTL_TEXTS WHERE intl_text_id=var_intl_text_id;
          var_text_width:=set_Text_Width(var_caption_name);
       EXCEPTION
          WHEN OTHERS THEN
               var_text_width:=0;
       END;

       var_align:='left';
       var_text_width:=USABLE_WIDTH;
       var_text_label_id:=getUISeqVal;
       var_ref_root_screen:=var_text_label_id;
       create_TEXT_LABEL(var_text_label_id,var_ui_parent_id,in_ui_def_id,var_ui_node_id,
                       in_top_pos          =>var_top_pos,
                       in_left_pos         =>LEFT_MARGIN,
                       in_text             =>var_caption_name,
                       in_font_name        =>DEFAULT_FONT_NAME_,
                       in_font_color       =>0,
                       in_font_size        =>DEFAULT_FONT_SIZE,
                       in_align            =>var_align,
                       in_intl_text_id     =>null,
                       in_parent_name      =>var_name,
                       in_width            =>var_text_width
                      ,in_use_default_font => YES_FLAG
                      ,in_display_flag     => NO_FLAG
                      ,in_font_bold        => NO_FLAG
                      ,in_font_italic      => YES_FLAG
                      ,in_font_underline   => NO_FLAG
                      ,in_title            => NO_FLAG
                       );

       var_top_pos:=var_top_pos+DEFAULT_CONTROL_HEIGHT+DEFAULT_SPACE_BETWEEN;

       var_ui_node_type:=UI_BOM_INST_ITEM_TYPE;
       var_width:=FLOOR(USABLE_WIDTH/2);
       create_BUTTON(getUiSeqVal,var_ui_parent_id,in_ui_def_id,in_ref_ps_id,
                    ' Add ',
                    in_top_pos          => var_top_pos,
                    in_left_pos         => CENTER_LINE+DEFAULT_SPACE_BETWEEN,
                    in_button_type      => DEF_ADD_BUTTON,
                    in_modified_flag    => YES_FLAG,
                    in_ui_node_ref_id   => var_ui_node_id);

       generateUIProps(var_ui_node_id, in_ui_def_id, DEF_INST_BOM,
                       0, YES_FLAG, YES_FLAG,
                       NO_FLAG, NO_FLAG, NO_FLAG,
                       0, 'left', '0');

       var_height:=DEFAULT_BOM_INST_ITEM_HEIGHT;
       var_borders:=YES_FLAG;
    ELSE
       var_ui_node_type:=UI_BOM_STANDART_TYPE;
       var_width:=USABLE_WIDTH;
       var_height:=DEFAULT_BOM_HEIGHT;
       var_ui_node_type:=UI_BOM_STANDART_TYPE;
       generateUIProps(var_ui_node_id,in_ui_def_id,DEF_CLASS,
                       0, YES_FLAG, YES_FLAG,
                       NO_FLAG, NO_FLAG, NO_FLAG,
                       0, 'left', '0');
    END IF;

    set_UI_NODES(in_ui_node_id       =>var_ui_node_id,
                 in_parent_id        =>var_ui_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>in_ref_ps_id,
                 in_ui_node_ref_id   =>var_ref_root_screen,
                 in_name             =>var_name,
                 in_component_id     =>in_ref_ps_id,
                 in_ui_node_type     =>var_ui_node_type,
                 in_lce_id           =>'P_'||to_char(var_ps_node_id),
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>var_tree_seq*mMAX_NUMBER_PAGES,
                 in_width            =>var_width,
                 in_height           =>var_height,
                 in_top_pos          =>var_top_pos,
                 in_left_pos         =>LEFT_MARGIN,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_controltype      =>9,
                 in_bkgrnd_style     =>YES_FLAG,
                 in_intl_text_id     =>var_intl_text_id,
                 in_borders          =>var_borders,
                 in_model_ref_expl_id=>var_model_ref_expl_id,
                 in_use_labels       =>var_use_labels);
    last_TOP_POS:=var_top_pos+DEFAULT_BOM_HEIGHT+DEFAULT_SPACE_BETWEEN;
    last_HEIGHT:=DEFAULT_BOM_HEIGHT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS THEN
         LOG_REPORT('CZ_UI_GENERATOR.add_BOM_MODEL_ITEM','Procedure add_BOM_MODEL_ITEM() failed : '||SQLERRM, CZ_ERROR_URGENCY);
END add_BOM_MODEL_ITEM;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_REFERENCE_Model
(in_node_id     IN  INTEGER,
 in_parent_id   IN  INTEGER,
 in_ui_def_id   IN  INTEGER,
 in_node_ref_id IN  INTEGER,
 in_arr         IN  UIStructure,
 out_ref_ui_id  OUT NOCOPY INTEGER) IS

    curr_button_id       CZ_UI_NODES.ui_node_id%TYPE;
    var_button_width     CZ_UI_NODES.width%TYPE;
    var_top_pos          CZ_UI_NODES.rel_top_pos%TYPE;
    var_butt_pos         CZ_UI_NODES.rel_top_pos%TYPE;
    var_left_pos         CZ_UI_NODES.rel_left_pos%TYPE;
    var_ui_tempo         CZ_UI_NODES.ui_node_ref_id%TYPE;
    var_ps_id            CZ_PS_NODES.ps_node_id%TYPE;
    var_ref_id           CZ_PS_NODES.reference_id%TYPE;
    var_name             CZ_PS_NODES.name%TYPE;
    var_ref_name         CZ_PS_NODES.name%TYPE;
    var_button_name      CZ_PS_NODES.name%TYPE;
    var_ui_name          CZ_PS_NODES.name%TYPE;
    var_ps_node_type     CZ_PS_NODES.ps_node_type%TYPE;
    var_model_id         CZ_PS_NODES.devl_project_id%TYPE;
    var_expl_id          CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    var_ref_root_screen  INTEGER;
    counter              INTEGER;
    ind                  INTEGER;
    existsDeleteMe       VARCHAR2(1);
    NO_MODEL_REF_EXPL_ID EXCEPTION;

BEGIN
    BEGIN
        ERROR_CODE:='00191';
        SELECT MIN(model_ref_expl_id) INTO var_expl_id FROM CZ_MODEL_REF_EXPLS a
        WHERE referring_node_id=in_arr.ps_node_id AND model_id=Project_Id AND
        deleted_flag=NO_FLAG;
        ERROR_CODE:='00192';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             LOG_REPORT('CZ_UI_GENERATOR.create_REF_Model',
             'Reference'||'"'||in_arr.name||'" can not be created : there is no model_ref_exl_id for this reference.'||
             SQLERRM, CZ_ERROR_URGENCY);

             RAISE NO_MODEL_REF_EXPL_ID;
    END;

    SELECT name INTO var_name FROM CZ_PS_NODES
    WHERE ps_node_id=in_arr.reference_id AND deleted_flag=NO_FLAG;
    out_ref_ui_id:=get_last_UI(in_arr.reference_id);
    ERROR_CODE:='00193';

    var_ref_name:=in_arr.name;

    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>in_arr.ps_node_id,
                 in_ui_node_ref_id   =>NULL,
                 in_name             =>var_ref_name,
                 in_component_id     =>in_arr.ps_node_id,
                 in_ui_node_type     =>UI_REFERENCE_REF_TYPE,
                 in_tree_display_flag=>NO_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_intl_text_id     =>in_arr.intl_text_id);
    ERROR_CODE:='00194';

    UPDATE CZ_UI_NODES SET model_ref_expl_id=var_expl_id,ui_def_ref_id=out_ref_ui_id
    WHERE ui_node_id=in_node_id AND ui_def_id=in_ui_def_id;

    ERROR_CODE:='00195';

    generateUIProps(in_node_id,in_ui_def_id,
                    DEF_REFERENCE,
                    0, TO_CHAR(in_arr.minimum), TO_CHAR(in_arr.maximum),
                    NO_FLAG, NO_FLAG, in_arr.virtual_flag,
                    0, 'left', '0');

    ERROR_CODE:='00196';

    IF mUI_STYLE=DHTML_STYLE_UI THEN
       var_model_id:=in_arr.reference_id;

       SELECT ps_node_type INTO var_ps_node_type
       FROM CZ_PS_NODES
       WHERE devl_project_id=var_model_id
       AND parent_id IS NULL AND deleted_flag=NO_FLAG;
       ERROR_CODE:='00197';

       IF var_ps_node_type=BOM_MODEL_NODE_TYPE THEN
          counter:=ref_boms.Count+1;
          ref_boms(counter).ui_parent_id:=in_parent_id;
          ref_boms(counter).model_id:=var_model_id;
          ref_boms(counter).ps_node_id:=in_arr.ps_node_id;
          ref_boms(counter).maximum:=in_arr.maximum;
          ref_boms(counter).minimum:=in_arr.minimum;
          ref_boms(counter).virtual_flag:=in_arr.virtual_flag;
       END IF;
       ERROR_CODE:='00198';

    END IF;

    BEGIN
                                         -- Add Button --
        IF ((in_arr.virtual_flag=NO_FLAG OR NOT(in_arr.maximum=1 AND in_arr.minimum=1))
            AND var_ps_node_type<>BOM_MODEL_NODE_TYPE)
            AND mUI_STYLE=DHTML_STYLE_UI THEN

            curr_button_id:=getUISeqVal;
            var_button_name:='Add '||var_ref_name;

            var_ui_tempo:=in_node_ref_id;

            IF MODE_REFRESH THEN

               SELECT NVL(MAX(rel_top_pos),0) INTO var_butt_pos FROM CZ_UI_NODES
               WHERE parent_id=in_node_ref_id AND deleted_flag=NO_FLAG;
               ERROR_CODE:='00199';

               IF var_butt_pos=0 OR var_butt_pos<=DEFAULT_HEADER_HEIGHT+DEFAULT_DIVIDER_HEIGHT THEN
                  var_butt_pos:=START_TOP_POS;
               ELSE
                  var_butt_pos:=DEFAULT_SPACE_BETWEEN;
               END IF;
               last_HEIGHT:=DEFAULT_CONTROL_HEIGHT;
            END IF;

            create_BUTTON(curr_button_id,in_node_ref_id,in_ui_def_id,
                         in_arr.ps_node_id,var_button_name,
                         in_top_pos    =>var_butt_pos,
                         in_left_pos   =>LEFT_MARGIN,
                         in_button_type=>DEF_ADD_BUTTON,
                         in_modified_flag    => 0);
            ERROR_CODE:='00200';


            IF latest_buttons.Count=0 THEN
               ind:=1;
            ELSE
               ind:=latest_buttons.Last+1;
            END IF;
            latest_buttons(ind).id:=curr_button_id;
            ERROR_CODE:='00201';

            BEGIN
                existsDeleteMe:=NO_FLAG;
                ERROR_CODE:='00202';

                SELECT YES_FLAG INTO existsDeleteMe FROM dual
                WHERE EXISTS(SELECT 1 FROM CZ_UI_NODES
                WHERE ui_def_id=in_ui_def_id AND ps_node_id=Project_Id AND
                name=CZ_DELETE_BUTTON_CAPTION);
                ERROR_CODE:='00203';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     NULL;
            END;

            IF existsDeleteMe=NO_FLAG THEN

               ERROR_CODE:='00204';

                          -- Delete Button --
               SELECT ui_node_id,name INTO var_ui_tempo,var_ui_name FROM CZ_UI_NODES
               WHERE ui_def_id=in_ui_def_id AND ps_node_id=Project_Id AND
               ui_node_type<>UI_COMPONENT_REF_TYPE AND ui_node_ref_id IS NOT NULL;
               ERROR_CODE:='00205';

               curr_button_id:=getUISeqVal;
               create_BUTTON(curr_button_id,var_ui_tempo,in_ui_def_id,
                            Project_Id,CZ_DELETE_BUTTON_CAPTION,
                            in_top_pos    =>DELETE_BUTTON_TOP_POS,
                            in_left_pos   =>DELETE_BUTTON_LEFT_POS,
                            in_button_type=>DEF_DELETE_BUTTON,
                            in_width      =>DELETE_BUTTON_WIDTH,
                            in_modified_flag    => 0);
               ERROR_CODE:='00206';


            END IF;

            BEGIN
                existsDeleteMe:=NO_FLAG;
                ERROR_CODE:='00207';

                SELECT devl_project_id INTO var_model_id FROM CZ_UI_DEFS
                WHERE ui_def_id=out_ref_ui_id AND deleted_flag=NO_FLAG;
                ERROR_CODE:='00208';

                SELECT YES_FLAG INTO existsDeleteMe FROM dual
                WHERE EXISTS(SELECT 1 FROM CZ_UI_NODES
                WHERE ui_def_id=out_ref_ui_id AND ps_node_id=var_model_Id AND
                name=CZ_DELETE_BUTTON_CAPTION);
                ERROR_CODE:='00209';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     NULL;
            END;

            IF existsDeleteMe=NO_FLAG THEN
               BEGIN
                   ERROR_CODE:='00210';

                      -- Delete Button --
                   SELECT ui_node_id,name INTO var_ui_tempo,var_ui_name FROM CZ_UI_NODES
                   WHERE ui_def_id=out_ref_ui_id AND ps_node_id=var_model_Id AND
                   ui_node_type<>UI_COMPONENT_REF_TYPE AND ui_node_ref_id IS NOT NULL;
                   ERROR_CODE:='00211';

                   curr_button_id:=getUISeqVal;
                   create_BUTTON(curr_button_id,var_ui_tempo,out_ref_ui_id,
                                 var_model_id,CZ_DELETE_BUTTON_CAPTION,
                                 in_top_pos    =>DELETE_BUTTON_TOP_POS,
                                 in_left_pos   =>DELETE_BUTTON_LEFT_POS,
                                 in_button_type=>DEF_DELETE_BUTTON,
                                 in_width      =>DELETE_BUTTON_WIDTH,
                                 in_modified_flag    => 0);
                   ERROR_CODE:='00212';

               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        NULL;
               END;
             END IF;
    END IF;

    EXCEPTION
        WHEN NO_MODEL_REF_EXPL_ID THEN
             LOG_REPORT('CZ_UI_GENERATOR.create_REFERENCE_Model',
             'Reference'||'"'||in_arr.name||'" can not be created : there is no model_ref_exl_id for this reference.'||
             SQLERRM, CZ_ERROR_URGENCY);
        WHEN NO_DATA_FOUND THEN
             FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,var_ui_name, CZ_ERROR_URGENCY);
    END;

END create_REFERENCE_Model;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_COMPONENT
(in_node_id     IN  INTEGER,
 in_parent_id   IN  INTEGER,
 in_ui_def_id   IN  INTEGER,
 in_prod_id     IN  INTEGER,
 in_arr         IN  UIStructure) IS

    curr_label_id  CZ_UI_NODES.ui_node_id%TYPE;
    curr_bitmap_id CZ_UI_NODES.ui_node_id%TYPE;
    curr_button_id CZ_UI_NODES.ui_node_id%TYPE;
    curr_tree_seq  CZ_UI_NODES.tree_seq%TYPE;
    ind            INTEGER;

BEGIN

    last_TOP_POS:=DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN;
    curr_label_id:=getUISeqVal;
    curr_bitmap_id:=getUISeqVal;

    set_UI_NODES(in_node_id,in_parent_id,in_ui_def_id,
                 in_arr.ps_node_id,curr_label_id,
                 in_arr.name,UI_COMPONENT_TYPE,DEFAULT_BACKGROUND_COLOR,NULL,
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_use_default_font =>YES_FLAG,
                 in_use_default_color=>YES_FLAG,
                 in_use_default_pic  =>YES_FLAG,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG);

    generateUIProps(in_node_id,in_ui_def_id,
                    DEF_COMPONENT,
                    0, TO_CHAR(in_arr.minimum), TO_CHAR(in_arr.maximum),
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

    --
    -- create Text Label for COMPONENT --
    --
    create_TEXT_LABEL(curr_label_id,in_node_id,in_ui_def_id,curr_label_id,
                      in_top_pos          =>DEFAULT_REL_TOP,
                      in_left_pos         =>DEFAULT_REL_LEFT,
                      in_text             =>in_arr.caption_name,
                      in_font_size        =>DEFAULT_CAPTION_FONT_SIZE,
                      in_font_color       =>DEFAULT_TITLE_COLOR,
                      in_display_flag     =>YES_FLAG,
                      in_use_default_font =>NO_FLAG,
                      in_title            =>YES_FLAG,
                      in_name             =>'Page Title',
                      in_align            =>'left',
                      in_intl_text_id     =>in_arr.intl_text_id,
                      in_parent_name      =>in_arr.name
                     ,in_font_name        => DEFAULT_FONT_NAME
                     ,in_font_bold        => NO_FLAG
                     ,in_font_italic      => YES_FLAG
                     ,in_font_underline   => NO_FLAG
                     );

    --
    -- create DIVIDER for COMPONENT --
    --
    create_DIVIDER(curr_bitmap_id,in_node_id,in_ui_def_id, 37,45, 0);

    IF in_arr.virtual_flag=NO_FLAG
       AND mUI_STYLE=DHTML_STYLE_UI THEN

       UPDATE CZ_UI_NODES SET component_id=in_arr.ps_node_id,ps_node_id=in_arr.ps_node_id
       WHERE ui_node_ref_id=in_node_id;

                                     -- Delete Button --
       create_BUTTON(getUISeqVal,in_node_id,in_ui_def_id,
                    in_arr.ps_node_id,CZ_DELETE_BUTTON_CAPTION,
                    in_top_pos    =>DELETE_BUTTON_TOP_POS,
                    in_left_pos   =>DELETE_BUTTON_LEFT_POS,
                    in_button_type=>DEF_DELETE_BUTTON,
                    in_width      =>DELETE_BUTTON_WIDTH,
                    in_modified_flag    => 0);

                                     -- Add Button --

       curr_button_id:=getUISeqVal;
       IF in_prod_id IS NULL THEN
          add_buttons(in_arr.ps_node_id).id:=getUISeqVal;
          add_buttons(in_arr.ps_node_id).name:=in_arr.caption_name;
          add_buttons(in_arr.ps_node_id).ps_parent_id:=in_arr.parent_id;
       ELSE
          create_BUTTON(curr_button_id,in_prod_id,in_ui_def_id,
                        in_arr.ps_node_id,'Add '||in_arr.caption_name,
                        in_top_pos          =>LEFT_MARGIN,
                        in_left_pos         =>LEFT_MARGIN,
                        in_button_type      =>DEF_ADD_BUTTON,
                        in_modified_flag    => 0);

       END IF;
       IF latest_buttons.Count=0 THEN
          ind:=1;
       ELSE
          ind:=latest_buttons.Last+1;
       END IF;
       latest_buttons(ind).id:=curr_button_id;
   END IF; ---- end of Maximum>1 case ----

END create_COMPONENT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_COMPONENT_Model
(in_node_id     IN INTEGER,
 in_parent_id   IN INTEGER,
 in_ui_def_id   IN INTEGER,
 in_node_ref_id IN INTEGER,
 in_arr         IN UIStructure) IS

    var_ps_id    CZ_UI_NODES.ps_node_id%TYPE;

BEGIN

   -- IF in_arr.virtual_flag=NO_FLAG THEN
       var_ps_id:=in_arr.ps_node_id;
   -- ELSE
   --    var_ps_id:=NULL;
   -- END IF;

    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>var_ps_id,
                 in_ui_node_ref_id   =>in_node_ref_id,
                 in_name             =>in_arr.name,
                 in_component_id     =>var_ps_id,
                 in_ui_node_type     =>UI_COMPONENT_REF_TYPE,
                 in_tree_display_flag=>NO_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_intl_text_id     =>in_arr.intl_text_id);

    generateUIProps(in_node_id,in_ui_def_id,DEF_COMPONENT_SCREEN,
                    0, in_arr.minimum, in_arr.maximum,
                    NO_FLAG, NO_FLAG, in_arr.virtual_flag,
                    0, 'left', '0');

END create_COMPONENT_Model;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE createBOM_MODEL
(in_node_id     IN  INTEGER,
 in_parent_id   IN  INTEGER,
 in_ui_def_id   IN  INTEGER,
 in_arr         IN  UIStructure) IS

    curr_label_id    CZ_UI_NODES.ui_node_id%TYPE;
    curr_bitmap_id   CZ_UI_NODES.ui_node_id%TYPE;

BEGIN

    ERROR_CODE:='00300';

    last_TOP_POS:=DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN;
    curr_label_id:=getUISeqVal;
    curr_bitmap_id:=getUISeqVal;

    set_UI_NODES(in_node_id,in_parent_id,in_ui_def_id,in_arr.ps_node_id,
                 curr_label_id,in_arr.name,UI_COMPONENT_TYPE,DEFAULT_BACKGROUND_COLOR,NULL,
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_use_default_font =>YES_FLAG,
                 in_use_default_color=>YES_FLAG,
                 in_use_default_pic  =>YES_FLAG,
                 in_top_pos          =>10,
                 in_left_pos         =>32,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG);

    ERROR_CODE:='00301';

    generateUIProps(in_node_id,in_ui_def_id,DEF_MODELBOM,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

    ERROR_CODE:='00302';

    /* ************** create Text Label for BOM_MODEL ************** */
    create_TEXT_LABEL(curr_label_id,in_node_id,in_ui_def_id,curr_label_id,
                      in_top_pos          =>DEFAULT_REL_TOP,
                      in_left_pos         =>DEFAULT_REL_LEFT,
                      in_text             =>in_arr.caption_name,
                      in_font_color       =>DEFAULT_TITLE_COLOR,
                      in_font_size        =>DEFAULT_CAPTION_FONT_SIZE,
                      in_display_flag     =>YES_FLAG,
                      in_use_default_font =>NO_FLAG,
                      in_title            =>YES_FLAG,
                      in_name             =>'Page Title',
                      in_align            =>'left',
                      in_intl_text_id     =>in_arr.intl_text_id,
                      in_parent_name      =>in_arr.name
                     ,in_font_name        => DEFAULT_FONT_NAME
                     ,in_font_bold        => NO_FLAG
                     ,in_font_italic      => YES_FLAG
                     ,in_font_underline   => NO_FLAG
                     );

    ERROR_CODE:='00303';

    /* ************** create DIVIDER Bitmap for BOM_MODEL ********** */
    create_DIVIDER(curr_bitmap_id,in_node_id,in_ui_def_id, 37, 45, 0);

    ERROR_CODE:='00304';

    --
    -- set ui_node_ref_id for UI BOM STANDART ITEMS associted with BOM MODEL --
    --
    BEGIN
        UPDATE CZ_UI_NODES SET ui_node_ref_id=in_node_id
        WHERE ui_def_id=in_ui_def_id AND ui_node_id IN
        (SELECT ui_node_id FROM CZ_UI_NODES
         WHERE ui_def_id=in_ui_def_id AND ui_node_type=UI_BOM_STANDART_TYPE
         AND ps_node_id=in_arr.ps_node_id AND deleted_flag=NO_FLAG);

        ERROR_CODE:='00305';
    EXCEPTION
        WHEN OTHERS THEN
             FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.createBOM_MODEL at point '||ERROR_CODE,
                        CZ_ERROR_URGENCY);
    END;

END createBOM_MODEL;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE createBOM_MODEL_Model
(in_node_id     IN INTEGER,
 in_parent_id   IN INTEGER,
 in_ui_def_id   IN INTEGER,
 in_node_ref_id IN INTEGER,
 in_arr         IN UIStructure) IS

    curr_tree_seq CZ_UI_NODES.tree_seq%TYPE;

BEGIN

    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>in_arr.ps_node_id,
                 in_ui_node_ref_id   =>in_node_ref_id,
                 in_name             =>in_arr.name,
                 in_component_id     =>NULL,
                 in_ui_node_type     =>UI_COMPONENT_REF_TYPE,
                 in_tree_display_flag=>NO_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_intl_text_id     =>in_arr.intl_text_id);

    generateUIProps(in_node_id,in_ui_def_id,DEF_MODELBOM_TREE,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, in_arr.virtual_flag,
                    0, 'left', '0');

END createBOM_MODEL_Model;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE createBOM_CLASS
(in_node_id     IN  INTEGER,
 in_parent_id   IN  INTEGER,
 in_ui_def_id   IN  INTEGER,
 in_arr         IN  UIStructure) IS

    curr_label_id    CZ_UI_NODES.ui_node_id%TYPE;
    curr_bitmap_id   CZ_UI_NODES.ui_node_id%TYPE;
    var_screen_oc_id CZ_UI_NODES.ui_node_id%TYPE;

BEGIN

    ERROR_CODE:='00310';

    last_TOP_POS:=DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN;
    curr_label_id:=getUISeqVal;
    curr_bitmap_id:=getUISeqVal;

    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>in_arr.ps_node_id,
                 in_ui_node_ref_id   =>curr_label_id,
                 in_name             =>in_arr.name,
                 in_ui_node_type     =>UI_BOM_OPTION_CLASS_TYPE,
                 in_background_color =>DEFAULT_BACKGROUND_COLOR,
                 in_component_id     =>NULL,
                 in_width            =>384,
                 in_height           =>DEFAULT_BOM_HEIGHT,
                 in_lce_id           =>NULL,
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_use_default_font =>YES_FLAG,
                 in_use_default_color=>YES_FLAG,
                 in_use_default_pic  =>YES_FLAG,
                 in_top_pos          =>10,
                 in_left_pos         =>32,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG);

    ERROR_CODE:='00311';

    generateUIProps(in_node_id,in_ui_def_id,DEF_CLASSES,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

    ERROR_CODE:='00312';

    --
    -- create Text Label for BOM_OPTION_CLASS --
    --
    create_TEXT_LABEL(curr_label_id,in_node_id,in_ui_def_id,in_node_id,
                      in_top_pos          =>DEFAULT_REL_TOP,
                      in_left_pos         =>DEFAULT_REL_LEFT,
                      in_text             =>in_arr.caption_name,
                      in_font_name        =>DEFAULT_FONT_NAME,
                      in_font_color       =>DEFAULT_TITLE_COLOR,
                      in_font_italic      =>YES_FLAG,
                      in_font_size        =>DEFAULT_CAPTION_FONT_SIZE,
                      in_display_flag     =>YES_FLAG,
                      in_use_default_font =>NO_FLAG,
                      in_title            =>YES_FLAG,
                      in_name             =>'Page Title',
                      in_align            =>'left',
                      in_intl_text_id     =>in_arr.intl_text_id,
                      in_parent_name      =>in_arr.name
                     ,in_font_bold        => NO_FLAG
                     ,in_font_underline   => NO_FLAG
                     );

    ERROR_CODE:='00313';

    --
    -- create DIVIDER for BOM_OPTION_CLASS --
    --
    create_DIVIDER(curr_bitmap_id,in_node_id,in_ui_def_id, 37, 45, 0);

    ERROR_CODE:='00314';

    --
    -- set ui_node_ref_id for UI BOM STANDART ITEMS associted with BOM MODEL --
    --
    BEGIN
        UPDATE CZ_UI_NODES SET ui_node_ref_id=in_node_id
        WHERE ui_def_id=in_ui_def_id AND ui_node_id IN
        (SELECT ui_node_id FROM CZ_UI_NODES
         WHERE ui_def_id=in_ui_def_id AND ui_node_type=UI_BOM_STANDART_TYPE
         AND ps_node_id=in_arr.ps_node_id AND deleted_flag=NO_FLAG);

        ERROR_CODE:='00315';
    EXCEPTION
        WHEN OTHERS THEN
             FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.createBOM_CLASS at point '||ERROR_CODE,
                        CZ_ERROR_URGENCY);
    END;

END createBOM_CLASS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE createBOM_CLASS_Model
(in_node_id     IN INTEGER,
 in_parent_id   IN INTEGER,
 in_ui_def_id   IN INTEGER,
 in_node_ref_id IN INTEGER,
 in_arr         IN UIStructure) IS

BEGIN

    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>in_arr.ps_node_id,
                 in_ui_node_ref_id   =>in_node_ref_id,
                 in_name             =>in_arr.name,
                 in_component_id     =>NULL,
                 in_ui_node_type     =>UI_COMPONENT_REF_TYPE,
                 in_tree_display_flag=>NO_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_intl_text_id     =>in_arr.intl_text_id);

    --generateUIProps(in_node_id,in_ui_def_id,DEF_CLASSBOM_TREE);

END createBOM_CLASS_Model;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION generate_UI_DEF RETURN NUMBER IS
    var_ui_def_id             CZ_UI_DEFS.ui_def_id%TYPE:=-1;
    var_devl_project_id       CZ_UI_DEFS.DEVL_PROJECT_ID%TYPE;
    var_component_id          CZ_UI_DEFS.COMPONENT_ID%TYPE;
    var_ui_style              CZ_UI_DEFS.UI_STYLE%TYPE;
    var_tree_seq              CZ_UI_DEFS.TREE_SEQ%TYPE;
    CURSOR c1 IS
    SELECT ui_def_id FROM CZ_UI_DEFS
    WHERE devl_project_id=Project_Id AND component_id IS NULL;
    var_c1 INTEGER;

BEGIN

    OPEN c1;
    FETCH c1 INTO var_c1;
    IF c1%NOTFOUND THEN
       SELECT CZ_UI_DEFS_S.NEXTVAL INTO MUID FROM DUAL;

       INSERT INTO CZ_UI_DEFS(ui_def_id,name,devl_project_id,component_id,
                              ui_style,gen_version,gen_header,look_and_feel,deleted_flag)
       VALUES(MUID,'MUID',Project_Id,NULL,-1,GLOBAL_GEN_VERSION,GLOBAL_GEN_HEADER,NULL,NO_FLAG);

    END IF;
    CLOSE c1;

    SELECT CZ_UI_DEFS_S.NEXTVAL INTO var_ui_def_id FROM DUAL;

    UI_Version:=generateUIVersion(Project_id);
    IF UI_Version>1 THEN
       InterfaceName:=SUBSTR(Model_Name||' User Interface '||TO_CHAR(UI_Version),1,255);
    ELSE
       InterfaceName:=SUBSTR(Model_Name||' User Interface',1,255);
    END IF;

    BEGIN
        SELECT NVL(MAX(tree_seq),0)+1 INTO var_tree_seq FROM CZ_UI_DEFS
        WHERE component_id=Project_Id AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN OTHERS THEN
             var_tree_seq:=1;
    END;

    INSERT INTO CZ_UI_DEFS(ui_def_id,name,devl_project_id,component_id,ui_style,gen_version,
                           gen_header,look_and_feel,tree_seq,deleted_flag)
    VALUES(var_ui_def_id,InterfaceName,Project_Id,Model_Id,mUI_STYLE,GLOBAL_GEN_VERSION,
           GLOBAL_GEN_HEADER,mLOOK_AND_FEEL,var_tree_seq,NO_FLAG);

    RETURN var_ui_def_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.generate_UI_DEF',
                    CZ_ERROR_URGENCY);
    WHEN OTHERS THEN
         FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.generate_UI_DEF',
                    CZ_ERROR_URGENCY);
END generate_UI_DEF;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION create_Page
(in_ui_tree_parent_id IN INTEGER,
 in_ui_parent_id      IN INTEGER,
 in_ps_node_id        IN INTEGER,
 in_intl_text_id      IN INTEGER,
 in_tree_seq          IN INTEGER,
 in_page_name         IN VARCHAR2,
 in_ui_def_id         IN INTEGER,
 in_counter           IN INTEGER) RETURN INTEGER IS
    var_tree_node_id    CZ_UI_NODES.ui_node_id%TYPE;
    var_screen_node_id  CZ_UI_NODES.ui_node_id%TYPE:=-1;
    var_curr_label_id   CZ_UI_NODES.ui_node_id%TYPE;
    var_curr_bitmap_id  CZ_UI_NODES.ui_node_id%TYPE;
    var_page_number     VARCHAR2(50);
BEGIN
    --
    -- set suffix for the page name --
    --
    IF in_counter>1 THEN
       var_page_number:=' ('||TO_CHAR(in_counter)||')';
    ELSE
       var_page_number:=' (1)';
    END IF;
    var_tree_node_id:=getUISeqVal;
    var_screen_node_id:=getUISeqVal;

    set_UI_NODES(in_ui_node_id       =>var_tree_node_id,
                 in_parent_id        =>in_ui_tree_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>NULL,
                 in_ui_node_ref_id   =>var_screen_node_id,
                 in_name             =>in_page_name||var_page_number,
                 in_component_id     =>NULL,
                 in_ui_node_type     =>UI_COMPONENT_REF_TYPE,
                 in_tree_display_flag=>NO_FLAG,
                 in_tree_seq         =>in_tree_seq+in_counter,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_intl_text_id     =>in_intl_text_id,
                 in_page_number      =>var_page_number);

    var_curr_label_id:=getUISeqVal;
    var_curr_bitmap_id:=getUISeqVal;
    set_UI_NODES(var_screen_node_id,in_ui_parent_id,in_ui_def_id,
                 in_ps_node_id,var_curr_label_id,
                 in_page_name||var_page_number,
                 UI_COMPONENT_TYPE,DEFAULT_BACKGROUND_COLOR,NULL,
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_tree_seq+in_counter,
                 in_use_default_font =>YES_FLAG,
                 in_use_default_color=>YES_FLAG,
                 in_use_default_pic  =>YES_FLAG,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_intl_text_id     =>in_intl_text_id,
                 in_page_id          =>in_counter);

     create_TEXT_LABEL(var_curr_label_id,var_screen_node_id,
                      in_ui_def_id,var_curr_label_id,
                      in_top_pos          =>DEFAULT_REL_TOP,
                      in_left_pos         =>DEFAULT_REL_LEFT,
                      in_text             =>in_page_name,
                      in_font_size        =>DEFAULT_CAPTION_FONT_SIZE,
                      in_font_color       =>DEFAULT_TITLE_COLOR,
                      in_display_flag     =>YES_FLAG,
                      in_use_default_font =>NO_FLAG,
                      in_title            =>YES_FLAG,
                      in_name             =>'Page Title',
                      in_align            =>'left',
                      in_intl_text_id     =>in_intl_text_id,
                      in_parent_name      =>in_page_name,
                      in_page_number      =>var_page_number
                     ,in_font_name        => DEFAULT_FONT_NAME
                     ,in_font_bold        => NO_FLAG
                     ,in_font_italic      => YES_FLAG
                     ,in_font_underline   => NO_FLAG
                     );

    /* ************** create DIVIDER for COMPONENT ************ */
    create_DIVIDER(var_curr_bitmap_id,var_screen_node_id,in_ui_def_id, 37, 45, 0);

    RETURN var_screen_node_id;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_Tree_Header
(in_ui_def_id             IN  INTEGER,
 in_product_id            IN  INTEGER,
 out_component_tree_id    OUT NOCOPY INTEGER,
 out_interface_id         OUT NOCOPY INTEGER,
 in_screen_width          IN  INTEGER  , -- DEFAULT 640,
 in_screen_height         IN  INTEGER  , -- DEFAULT 480,
 in_show_all_nodes        IN  VARCHAR2   -- DEFAULT '0'
) IS

    nIface1            CZ_UI_NODES.ui_node_id%TYPE;
BEGIN
    IF MUID IS NOT NULL THEN
       nIface1:=currUISeqVal;
       set_UI_NODES(in_ui_node_id       =>nIface1,
                    in_parent_id        =>nIface1,
                    in_ui_def_id        =>MUID,
                    in_ps_node_id       =>NULL,
                    in_ui_node_ref_id   =>NULL,
                    in_name             =>'User Interfaces',
                    in_ui_node_type     =>51,
                    in_background_color =>DEFAULT_BACKGROUND_COLOR,
                    in_component_id     =>NULL,
                    in_width            =>100,
                    in_height           =>20,
                    in_tree_display_flag=>YES_FLAG,
                    in_use_default_font =>YES_FLAG,
                    in_use_default_pic  =>YES_FLAG,
                    in_use_default_color=>YES_FLAG,
                    in_tree_seq         =>-1);
   END IF;

   out_interface_id:=getUISeqVal;
   set_UI_NODES( in_ui_node_id        =>out_interface_id,
                  in_parent_id        =>out_interface_id,
                  in_ui_def_id        =>in_ui_def_id,
                  in_ps_node_id       =>in_product_id,
                  in_ui_node_ref_id   =>NULL,
                  in_name             =>InterfaceName,
                  in_ui_node_type     =>UI_ROOT_SYSTEM_TYPE,
                  in_background_color =>DEFAULT_BACKGROUND_COLOR,
                  in_component_id     =>NULL,
                  in_width            =>in_screen_width,
                  in_height           =>in_screen_height,
                  in_tree_display_flag=>YES_FLAG,
                  in_use_default_font =>NO_FLAG,
                  in_use_default_pic  =>NO_FLAG,
                  in_use_default_color=>NO_FLAG,
                  in_tree_seq         =>1,
                  in_font_name        =>DEFAULT_FONT_NAME,
                  in_font_bold        =>NO_FLAG,
                  in_font_color       =>0,
                  in_font_italic      =>NO_FLAG,
                  in_font_size        =>DEFAULT_FONT_SIZE,
                  in_font_underline   =>NO_FLAG);

    generateUIProps(out_interface_id,in_ui_def_id,DEF_PRODUCT_USER_IFACE,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', in_show_all_nodes);

    out_component_tree_id :=getUISeqVal;
    set_UI_NODES(in_ui_node_id       =>out_component_tree_id,
                 in_parent_id        =>out_interface_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>NULL,
                 in_ui_node_ref_id   =>NULL,
                 in_name             =>'Components Tree',
                 in_ui_node_type     =>143,
                 in_background_color =>DEFAULT_BACKGROUND_COLOR,
                 in_tree_display_flag=>YES_FLAG,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>YES_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_borders          =>NO_FLAG,
                 in_bkgrnd_picture   =>TREE_TILING_BMP);

    generateUIProps(out_component_tree_id,in_ui_def_id,DEF_COMPONENT_TREE,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

END create_Tree_Header;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_Footprints
(in_ui_def_id    IN INTEGER,
 in_interface_id IN INTEGER) IS

    var_ui_node CZ_UI_NODES.ui_node_id%TYPE;

BEGIN
    --
    -- create Recycle Bin --
    --
    var_ui_node:=getUISeqVal;
    set_UI_NODES(var_ui_node,in_interface_id,in_ui_def_id,NULL,NULL,
             'Recycle Bin',UI_SYS_TYPE,DEFAULT_BACKGROUND_COLOR,
             in_tree_display_flag=>NO_FLAG,
             in_font_name        =>DEFAULT_FONT_NAME,
             in_font_bold        =>NO_FLAG,
             in_font_color       =>0,
             in_font_italic      =>NO_FLAG,
             in_font_size        =>DEFAULT_FONT_SIZE,
             in_font_underline   =>NO_FLAG);
    generateUIProps(var_ui_node,in_ui_def_id,DEF_RECYCLE_BIN,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

    --
    -- create Limbo --
    --
    var_ui_node:=getUISeqVal;
    set_UI_NODES(var_ui_node,in_interface_id,in_ui_def_id,
                 NULL,NULL,'Limbo',UI_SYS_TYPE,DEFAULT_BACKGROUND_COLOR,
                 in_tree_display_flag=>NO_FLAG,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG);
    generateUIProps(var_ui_node,in_ui_def_id,DEF_LIMBO,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

END create_Footprints;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_OPTION
(in_node_id   IN INTEGER,
 in_parent_id IN INTEGER,
 in_ui_def_id IN INTEGER,
 in_arr       IN optionStructure) IS

BEGIN
    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>in_arr.ps_node_id,
                 in_ui_node_ref_id   =>NULL,
                 in_component_id     =>NULL,
                 in_name             =>in_arr.name,
                 in_ui_node_type     =>UI_OPTION_TYPE,
                 in_lce_id           =>'P_'||TO_CHAR(in_arr.ps_node_id),
                 in_tree_display_flag=>NO_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_intl_text_id     =>in_arr.intl_text_id);
END create_OPTION;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE  generate_Options
(in_parent_node_id IN   INTEGER,
 in_new_parent_id  IN   INTEGER,
 in_ui_def_id      IN   INTEGER,
 out_counter       OUT NOCOPY  INTEGER) IS

    curr_node_id CZ_UI_NODES.ui_node_id%TYPE;
    var_counter  INTEGER:=0;
    i            INTEGER;

BEGIN

    i:=Options.First;
    LOOP
       IF i IS NULL THEN
          EXIT;
       END IF;

       IF Options(i).parent_id=in_parent_node_id THEN
          curr_node_id:=getUISeqVal;
          var_counter:=var_counter+1;
          create_OPTION(curr_node_id,in_new_parent_id,in_ui_def_id,Options(i));
       END IF;
       i:=Options.NEXT(i);
    END LOOP;
    out_counter:=var_counter;

END generate_Options;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_FEATURE
(in_node_id         IN     INTEGER,
 in_parent_id       IN     INTEGER,
 in_ui_def_id       IN     INTEGER,
 in_arr             IN     featureStructure) IS

    curr_label_id         CZ_UI_NODES.ui_node_id%TYPE;
    var_width             CZ_UI_NODES.width%TYPE;
    var_height            CZ_UI_NODES.height%TYPE;
    var_control_type      CZ_UI_NODES.controltype%TYPE;
    var_label_top_pos     CZ_UI_NODES.rel_top_pos%TYPE;
    var_top_pos           CZ_UI_NODES.rel_top_pos%TYPE;
    var_label_left_pos    CZ_UI_NODES.rel_left_pos%TYPE;
    var_left_pos          CZ_UI_NODES.rel_left_pos%TYPE;
    var_text_width        CZ_UI_NODES.width%TYPE;
    var_borders           CZ_UI_NODES.borders%TYPE:=YES_FLAG;
    var_use_default_color CZ_UI_NODES.default_bkgrnd_color_flag%TYPE:=YES_FLAG;
    var_align             VARCHAR2(10);
    Top_Labeled           BOOLEAN:=FALSE;

BEGIN

    curr_label_id:=getUISeqVal;
    var_left_pos:=CENTER_LINE;
    var_text_width:=set_Text_Width(in_arr.caption_name);
    var_align:='right';

    var_height:=last_HEIGHT;
    IF in_arr.feature_type IN (1,2) THEN
       --
       --  Integer, Decimal Features --
       --
       var_height:=DEFAULT_CONTROL_HEIGHT;
       var_width:=NUMERIC_FEATURE_WIDTH;
    ELSIF in_arr.feature_type=3 THEN
       var_height:=DEFAULT_CONTROL_HEIGHT;
       var_width:=BOOLEAN_FEATURE_WIDTH;
       var_align:='left';
    ELSIF in_arr.feature_type=4 THEN
       var_height:=DEFAULT_CONTROL_HEIGHT;
       var_width:=OPTION_FEATURE_WIDTH;
    ELSE
       var_width:=OPTION_FEATURE_WIDTH;
    END IF;

    --
    -- atp_flag=TRUE means - it can be used in pricing stuff --
    --
    IF in_arr.atp_flag=TRUE THEN
       var_label_top_pos:=last_TOP_POS;
       var_top_pos:=last_TOP_POS+DEFAULT_TEXT_HEIGHT+TOP_LABELED_SPACE_ABOVE;

       var_label_left_pos:=LEFT_MARGIN;
       var_left_pos:=LEFT_MARGIN;
       var_width:=USABLE_WIDTH;
       Top_Labeled:=TRUE;
    ELSE
       IF var_text_width>CENTER_LINE-LEFT_MARGIN THEN
          var_text_width:=USABLE_WIDTH;
          var_label_top_pos:=last_TOP_POS;
          var_top_pos:=last_TOP_POS+DEFAULT_TEXT_HEIGHT+TOP_LABELED_SPACE_ABOVE;

          var_label_left_pos:=LEFT_MARGIN;
          var_left_pos:=LEFT_MARGIN;
          Top_Labeled:=TRUE;
          var_align:='left';
       ELSE
          var_text_width:=FLOOR(USABLE_WIDTH/2)-DEFAULT_SPACE_BETWEEN;
          var_left_pos:=CENTER_LINE;
          var_label_left_pos:=LEFT_MARGIN;
          -----var_label_left_pos:=var_left_pos-var_text_width-SPACE_BETWEEN;---

          var_label_top_pos:=last_TOP_POS;
          var_top_pos:=last_TOP_POS;
       END IF;
    END IF;

    var_borders:=YES_FLAG;

    IF in_arr.feature_type=0 THEN
       var_borders:=NO_FLAG;
       IF in_arr.counted_options_flag=YES_FLAG OR in_arr.maximum>1 OR in_arr.maximum IS NULL THEN
           var_borders:=YES_FLAG;
          var_control_type:=2;
       ELSE
          var_control_type:=1;
       END IF;
    END IF;

    IF in_arr.feature_type=3 THEN
       var_borders:=NO_FLAG;
       var_control_type:=3;
       var_top_pos:=last_TOP_POS;
       var_label_top_pos:=last_TOP_POS;

       var_left_pos:=CENTER_LINE;
       var_label_left_pos:=var_left_pos+BOOLEAN_FEATURE_WIDTH+SPACE_BETWEEN;
    END IF;

    IF in_arr.feature_type=1 THEN
       var_control_type:=4;
    END IF;

    IF in_arr.feature_type=2 THEN
       var_control_type:=5;
    END IF;

    IF in_arr.feature_type=4 THEN
       var_control_type:=6;
    END IF;

    IF mLOOK_AND_FEEL='BLAF' THEN
       var_use_default_color:=YES_FLAG;
    ELSE
       var_use_default_color:=NO_FLAG;
    END IF;

    set_UI_NODES(in_ui_node_id       =>in_node_id,
                 in_parent_id        =>in_parent_id,
                 in_ui_def_id        =>in_ui_def_id,
                 in_ps_node_id       =>in_arr.ps_node_id,
                 in_ui_node_ref_id   =>curr_label_id,
                 in_name             =>in_arr.name,
                 in_ui_node_type     =>UI_FEATURE_TYPE,
                 in_background_color =>DEFAULT_BACKGROUND_COLOR,
                 in_component_id     =>in_arr.parent_id,
                 in_width            =>var_width,
                 in_height           =>var_height,
                 in_lce_id           =>'P_'||TO_CHAR(in_arr.ps_node_id),
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_use_default_font =>YES_FLAG,
                 in_use_default_color=>var_use_default_color,
                 in_use_default_pic  =>YES_FLAG,
                 in_top_pos          =>var_top_pos,
                 in_left_pos         =>var_left_pos,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_controltype      =>var_control_type,
                 in_borders          =>var_borders);

    generateUIProps(in_node_id,in_ui_def_id,DEF_FEATURE,
                    in_arr.feature_type,
                    TO_CHAR(in_arr.minimum), TO_CHAR(in_arr.maximum),
                    in_arr.counted_options_flag, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

    create_TEXT_LABEL(curr_label_id,in_parent_id,in_ui_def_id,in_node_id,
                      in_top_pos     =>var_label_top_pos,
                      in_left_pos    =>var_label_left_pos,
                      in_text        =>in_arr.caption_name,
                      in_font_name   =>DEFAULT_FONT_NAME_,
                      in_font_color  =>0,
                      in_font_size   =>DEFAULT_FONT_SIZE,
                      in_align       =>var_align,
                      in_intl_text_id=>in_arr.intl_text_id,
                      in_parent_name =>in_arr.name,
                      in_width       =>var_text_width
                     ,in_use_default_font => YES_FLAG
                     ,in_display_flag     => NO_FLAG
                     ,in_font_bold        => NO_FLAG
                     ,in_font_italic      => YES_FLAG
                     ,in_font_underline   => NO_FLAG
                     ,in_title            => NO_FLAG
                     );

    last_HEIGHT:=var_height;

    IF Top_Labeled THEN
       last_TOP_POS:=last_TOP_POS+DEFAULT_CONTROL_HEIGHT+last_HEIGHT+2*DEFAULT_SPACE_BETWEEN;
    ELSE
       last_TOP_POS:=last_TOP_POS+last_HEIGHT+DEFAULT_SPACE_BETWEEN;
    END IF;

END create_FEATURE;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_TOTAL
(in_node_id        IN     INTEGER,
 in_parent_id      IN     INTEGER,
 in_ui_def_id      IN     INTEGER,
 in_arr            IN     featureStructure) IS

     curr_label_id         CZ_UI_NODES.ui_node_id%TYPE;
     var_top_pos           CZ_UI_NODES.rel_top_pos%TYPE;
     var_left_pos          CZ_UI_NODES.rel_left_pos%TYPE;
     var_left_pos_txt      CZ_UI_NODES.rel_left_pos%TYPE;
     var_text_width        CZ_UI_NODES.width%TYPE;
     var_label_top_pos     CZ_UI_NODES.rel_top_pos%TYPE;
     var_label_left_pos    CZ_UI_NODES.rel_left_pos%TYPE;
     var_use_default_color CZ_UI_NODES.default_bkgrnd_color_flag%TYPE:=YES_FLAG;
     var_borders           CZ_UI_NODES.borders%TYPE:=YES_FLAG;
     var_align             VARCHAR2(10):='right';
     Top_Labeled           BOOLEAN:=FALSE;

BEGIN

     curr_label_id:=getUISeqVal;

     var_top_pos:=last_TOP_POS;
     var_left_pos:=CENTER_LINE;
     var_text_width:=set_Text_Width(in_arr.caption_name);

     IF var_text_width>CENTER_LINE-LEFT_MARGIN THEN
        var_label_top_pos:=last_TOP_POS;
        var_top_pos:=last_TOP_POS+DEFAULT_TEXT_HEIGHT+TOP_LABELED_SPACE_ABOVE;
        var_label_left_pos:=LEFT_MARGIN;
        var_left_pos:=LEFT_MARGIN;
        Top_Labeled:=TRUE;
        var_align:='left';
        var_text_width:=USABLE_WIDTH;
     ELSE
        var_left_pos:=CENTER_LINE;
        var_label_top_pos:=last_TOP_POS;
        var_top_pos:=last_TOP_POS;
        var_text_width:=FLOOR(USABLE_WIDTH/2)-DEFAULT_SPACE_BETWEEN;
        var_label_left_pos:=LEFT_MARGIN;
     END IF;

     IF mLOOK_AND_FEEL='BLAF' THEN
        var_use_default_color:=YES_FLAG;
     ELSE
        var_use_default_color:=NO_FLAG;
     END IF;

     set_UI_NODES(in_node_id,in_parent_id,in_ui_def_id,in_arr.ps_node_id,
                  curr_label_id,in_arr.name,UI_TOTAL_TYPE,NULL,in_arr.ps_node_id,
                  DEFAULT_TOTAL_WIDTH,
                  DEFAULT_CONTROL_HEIGHT,
                  in_tree_display_flag=>YES_FLAG,
                  in_tree_seq         =>in_arr.tree_seq,
                  in_lce_id           =>'P_'||TO_CHAR(in_arr.ps_node_id),
                  in_top_pos          =>var_top_pos,
                  in_left_pos         =>var_left_pos,
                  in_font_name        =>DEFAULT_FONT_NAME,
                  in_font_bold        =>NO_FLAG,
                  in_font_color       =>0,
                  in_font_italic      =>NO_FLAG,
                  in_font_size        =>DEFAULT_FONT_SIZE,
                  in_font_underline   =>NO_FLAG,
                  in_controltype      =>TOTAL_CONTROL_TYPE,
                  in_borders          =>YES_FLAG,
                  in_use_default_color =>var_use_default_color);

     generateUIProps(in_node_id,in_ui_def_id,DEF_TOTAL_ELEMENT,
                     0, YES_FLAG, YES_FLAG,
                     NO_FLAG, NO_FLAG, NO_FLAG,
                     0, 'left', '0');

     create_TEXT_LABEL(curr_label_id,in_parent_id,in_ui_def_id,in_node_id,
                       in_top_pos          =>var_label_top_pos,
                       in_left_pos         =>var_label_left_pos,
                       in_text             =>in_arr.caption_name,
                       in_font_name        =>DEFAULT_FONT_NAME_,
                       in_font_color       =>0,
                       in_font_size        =>DEFAULT_FONT_SIZE,
                       in_align            =>var_align,
                       in_intl_text_id     =>in_arr.intl_text_id,
                       in_parent_name      =>in_arr.name,
                       in_width            =>var_text_width
                      ,in_use_default_font => YES_FLAG
                      ,in_display_flag     => NO_FLAG
                      ,in_font_bold        => NO_FLAG
                      ,in_font_italic      => YES_FLAG
                      ,in_font_underline   => NO_FLAG
                      ,in_title            => NO_FLAG
                      );

     IF Top_Labeled THEN
        last_TOP_POS:=last_TOP_POS+DEFAULT_CONTROL_HEIGHT+DEFAULT_SPACE_BETWEEN;
     END IF;

END create_TOTAL;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_RESOURCE
(in_node_id        IN     INTEGER,
 in_parent_id      IN     INTEGER,
 in_ui_def_id      IN     INTEGER,
 in_arr            IN     featureStructure) IS

    curr_label_id         CZ_UI_NODES.ui_node_id%TYPE;
    var_top_pos           CZ_UI_NODES.rel_top_pos%TYPE;
    var_left_pos          CZ_UI_NODES.rel_left_pos%TYPE;
    var_left_pos_txt      CZ_UI_NODES.rel_left_pos%TYPE;
    var_text_width        CZ_UI_NODES.width%TYPE;
    var_label_top_pos     CZ_UI_NODES.rel_top_pos%TYPE;
    var_label_left_pos    CZ_UI_NODES.rel_left_pos%TYPE;
    var_use_default_color CZ_UI_NODES.default_bkgrnd_color_flag%TYPE:=YES_FLAG;
    var_borders           CZ_UI_NODES.borders%TYPE:=YES_FLAG;
    var_align             VARCHAR2(10):='right';
    Top_Labeled           BOOLEAN:=FALSE;

BEGIN

    curr_label_id:=getUISeqVal;

    var_top_pos:=last_TOP_POS;
    var_left_pos:=CENTER_LINE;
    var_text_width:=set_Text_Width(in_arr.caption_name);

    IF var_text_width>CENTER_LINE-LEFT_MARGIN THEN
       var_label_top_pos:=last_TOP_POS;
       var_top_pos:=last_TOP_POS+DEFAULT_TEXT_HEIGHT+TOP_LABELED_SPACE_ABOVE;

       var_label_left_pos:=LEFT_MARGIN;
       var_left_pos:=LEFT_MARGIN;
       Top_Labeled:=TRUE;
       var_align:='left';
       var_text_width:=USABLE_WIDTH;
    ELSE
       var_left_pos:=CENTER_LINE;
       --var_label_left_pos:=var_left_pos-var_text_width-SPACE_BETWEEN;--
       var_label_top_pos:=last_TOP_POS;
       var_top_pos:=last_TOP_POS;
       var_text_width:=FLOOR(USABLE_WIDTH/2)-DEFAULT_SPACE_BETWEEN;
       var_label_left_pos:=LEFT_MARGIN;
    END IF;

    IF mLOOK_AND_FEEL='BLAF' THEN
       var_use_default_color:=YES_FLAG;
    ELSE
       var_use_default_color:=NO_FLAG;
    END IF;

    set_UI_NODES(in_node_id,in_parent_id,in_ui_def_id,in_arr.ps_node_id,
                 curr_label_id,in_arr.name,UI_RESOURCE_TYPE,NULL,in_arr.ps_node_id,
                 DEFAULT_RESOURCE_WIDTH,
                 DEFAULT_CONTROL_HEIGHT,
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_lce_id           =>'P_'||TO_CHAR(in_arr.ps_node_id),
                 in_top_pos          =>var_top_pos,
                 in_left_pos         =>var_left_pos,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_controltype      =>RESOURCE_CONTROL_TYPE,
                 in_borders          =>YES_FLAG,
                 in_use_default_color=>var_use_default_color);

    generateUIProps(in_node_id,in_ui_def_id,DEF_RESOURCE_ELEMENT,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

    create_TEXT_LABEL(curr_label_id,in_parent_id,in_ui_def_id,in_node_id,
                      in_top_pos     =>var_label_top_pos,
                      in_left_pos    =>var_label_left_pos,
                      in_text        =>in_arr.caption_name,
                      in_font_name   =>DEFAULT_FONT_NAME_,
                      in_font_color  =>DEFAULT_FONT_COLOR,
                      in_font_italic =>YES_FLAG,
                      in_font_size   =>DEFAULT_FONT_SIZE,
                      in_align       =>var_align,
                      in_intl_text_id=>in_arr.intl_text_id,
                      in_parent_name =>in_arr.name,
                      in_width       =>var_text_width
                     ,in_use_default_font => YES_FLAG
                     ,in_display_flag     => NO_FLAG
                     ,in_font_bold        => NO_FLAG
                     ,in_font_underline   => NO_FLAG
                     ,in_title            => NO_FLAG
                     );

    IF Top_Labeled THEN
       last_TOP_POS:=last_TOP_POS+DEFAULT_CONTROL_HEIGHT+DEFAULT_SPACE_BETWEEN;
    END IF;

END create_RESOURCE;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_CONNECTOR
(in_node_id        IN     INTEGER,
 in_parent_id      IN     INTEGER,
 in_ui_def_id      IN     INTEGER,
 in_arr            IN     featureStructure) IS

     var_curr_label_id     CZ_UI_NODES.caption_id%TYPE;
     var_top_pos           CZ_UI_NODES.rel_top_pos%TYPE;
     var_left_pos          CZ_UI_NODES.rel_left_pos%TYPE;
     var_left_pos_txt      CZ_UI_NODES.rel_left_pos%TYPE;
     var_label_top_pos     CZ_UI_NODES.rel_top_pos%TYPE;
     var_label_left_pos    CZ_UI_NODES.rel_left_pos%TYPE;
     var_txt_id            CZ_UI_NODES.caption_id%TYPE;
     var_button_name       CZ_UI_NODES.name%TYPE;
     var_button_caption    CZ_INTL_TEXTS.text_str%TYPE;
     var_ref_name          CZ_UI_NODES.name%TYPE;
     var_ref_label_id      CZ_PS_NODES.intl_text_id%TYPE;
     var_expl_id           CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
     var_ref_label         CZ_INTL_TEXTS.text_str%TYPE;
     var_text_width        CZ_UI_NODES.width%TYPE;
     var_borders           CZ_UI_NODES.borders%TYPE:=YES_FLAG;
     var_use_default_color CZ_UI_NODES.default_bkgrnd_color_flag%TYPE:=YES_FLAG;
     var_align             VARCHAR2(10):='right';
     Top_Labeled           BOOLEAN:=FALSE;

     NO_MODEL_REF_EXPL_ID  EXCEPTION;

BEGIN

    BEGIN
        SELECT MIN(model_ref_expl_id) INTO var_expl_id FROM CZ_MODEL_REF_EXPLS a
        WHERE referring_node_id=in_arr.ps_node_id AND model_id=Project_Id
        AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RAISE NO_MODEL_REF_EXPL_ID;
    END;

    var_curr_label_id:=getUISeqVal;

    var_top_pos:=last_TOP_POS;
    var_left_pos:=CENTER_LINE;
    var_text_width:=set_Text_Width(in_arr.caption_name);

    IF var_text_width>CENTER_LINE-LEFT_MARGIN THEN
       var_label_top_pos:=last_TOP_POS;
       var_top_pos:=last_TOP_POS+DEFAULT_TEXT_HEIGHT+TOP_LABELED_SPACE_ABOVE;

       var_label_left_pos:=LEFT_MARGIN;
       var_left_pos:=LEFT_MARGIN;
       Top_Labeled:=TRUE;
       var_align:='left';
       var_text_width:=USABLE_WIDTH;
    ELSE
       var_left_pos:=CENTER_LINE;
       var_label_top_pos:=last_TOP_POS;
       var_top_pos:=last_TOP_POS;
       var_text_width:=FLOOR(USABLE_WIDTH/2)-DEFAULT_SPACE_BETWEEN;
       var_label_left_pos:=LEFT_MARGIN;
    END IF;

    IF mLOOK_AND_FEEL='BLAF' THEN
       var_use_default_color:=YES_FLAG;
    ELSE
       var_use_default_color:=NO_FLAG;
    END IF;

    set_UI_NODES(in_node_id,in_parent_id,in_ui_def_id,in_arr.ps_node_id,
                 var_curr_label_id,in_arr.name,UI_CONNECTOR_TYPE,NULL,in_arr.ps_node_id,
                 DEFAULT_CONNECTOR_WIDTH,
                 DEFAULT_CONNECTOR_HEIGHT,
                 in_tree_display_flag=>YES_FLAG,
                 in_tree_seq         =>in_arr.tree_seq,
                 in_lce_id           =>'P_'||TO_CHAR(in_arr.ps_node_id),
                 in_top_pos          =>var_top_pos,
                 in_left_pos         =>var_left_pos,
                 in_font_name        =>DEFAULT_FONT_NAME,
                 in_font_bold        =>NO_FLAG,
                 in_font_color       =>0,
                 in_font_italic      =>NO_FLAG,
                 in_font_size        =>DEFAULT_FONT_SIZE,
                 in_font_underline   =>NO_FLAG,
                 in_controltype      =>CONNECTOR_CONTROL_TYPE,
                 in_borders          =>YES_FLAG,
                 in_use_default_color=>var_use_default_color,
                 in_model_ref_expl_id=>var_expl_id);

    generateUIProps(in_node_id,in_ui_def_id,DEF_CONNECTOR_ELEMENT,
                    0, YES_FLAG, YES_FLAG,
                    NO_FLAG, NO_FLAG, NO_FLAG,
                    0, 'left', '0');

    create_TEXT_LABEL(var_curr_label_id,in_parent_id,in_ui_def_id,in_node_id,
                      in_top_pos          =>var_label_top_pos,
                      in_left_pos         =>var_label_left_pos,
                      in_text             =>in_arr.caption_name,
                      in_font_name        =>DEFAULT_FONT_NAME_,
                      in_font_color       =>0,
                      in_font_size        =>DEFAULT_FONT_SIZE,
                      in_align            =>var_align,
                      in_intl_text_id     =>in_arr.intl_text_id,
                      in_parent_name      =>in_arr.name,
                      in_width            =>var_text_width
                     ,in_use_default_font => YES_FLAG
                     ,in_display_flag     => NO_FLAG
                     ,in_font_bold        => NO_FLAG
                     ,in_font_italic      => YES_FLAG
                     ,in_font_underline   => NO_FLAG
                     ,in_title            => NO_FLAG
                     );

    var_txt_id:=getTXTSeqVal;

    SELECT name,intl_text_id
    INTO var_ref_name,var_ref_label_id
    FROM CZ_PS_NODES
    WHERE ps_node_id=in_arr.reference_id AND deleted_flag=NO_FLAG;

    var_button_name:=CZ_CONNECTOR_BUTTON_CAPTION||' '||var_ref_name;

    var_button_caption:=CZ_CONNECTOR_BUTTON_CAPTION;

    INSERT INTO CZ_INTL_TEXTS(intl_text_id,text_str,ui_def_id,model_id,deleted_flag)
    VALUES(var_txt_id,var_button_caption,in_ui_def_id,Project_Id,NO_FLAG);

    create_BUTTON(getUISeqVal,in_parent_id,in_ui_def_id,
                  in_arr.ps_node_id,var_button_name,
                  in_top_pos          =>var_top_pos,
                  in_left_pos         =>var_left_pos+CONNECTOR_GAP,
                  in_button_type      =>DEF_CONNECTOR_BUTTON,
                  in_ui_node_ref_id   =>in_node_id,
                  in_modified_flag    =>YES_FLAG,
                  in_intl_text_id     =>var_txt_id);

    IF Top_Labeled THEN
       last_TOP_POS:=last_TOP_POS+DEFAULT_CONTROL_HEIGHT+DEFAULT_SPACE_BETWEEN;
    END IF;

EXCEPTION
    WHEN NO_MODEL_REF_EXPL_ID THEN
         NULL;
END create_CONNECTOR;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE generate_FTR
(in_parent_node_id IN     INTEGER,
 in_new_parent_id  IN     INTEGER,
 in_ui_def_id      IN     INTEGER) IS

    temp                featureArray;
    curr_node_id        CZ_UI_NODES.ui_node_id%TYPE;
    curr_label_id       CZ_UI_NODES.ui_node_id%TYPE;
    var_name            CZ_UI_NODES.name%TYPE;
    options_number      INTEGER;
    ind                 INTEGER;
    i                   INTEGER;
    END_OPERATION       EXCEPTION;

BEGIN

    IF Features.Count=0 THEN
       RAISE END_OPERATION;
    END IF;

    ind:=Features.First;
    LOOP
       IF ind IS NULL THEN
          EXIT;
       END IF;
       IF Features(ind).parent_id=in_parent_node_id THEN
          BEGIN
          temp(Features(ind).tree_seq):=Features(ind);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;
          END;
        END IF;
        ind:=Features.NEXT(ind);
    END LOOP;

    i:=temp.First;

    LOOP
       IF i IS NULL THEN
          EXIT;
       END IF;

       IF temp(i).parent_id=in_parent_node_id THEN
          curr_node_id:=getUISeqVal;
          curr_label_id:=getUISeqVal;
          var_name:='Text-'||TO_CHAR(curr_node_id);
          last_HEIGHT:=DEFAULT_CONTROL_HEIGHT;

          IF temp(i).ps_node_type=FEATURE_NODE_TYPE THEN
             IF temp(i).feature_type=0 THEN
                generate_Options(in_parent_node_id=>temp(i).ps_node_id,
                                 in_new_parent_id =>curr_node_id,
                                 in_ui_def_id     =>in_ui_def_id,
                                 out_counter      =>options_number);
             END IF;

             IF temp(i).counted_options_flag=YES_FLAG OR
                temp(i).maximum>1 OR temp(i).maximum IS NULL THEN
                last_HEIGHT:=DEFAULT_CONTROL_HEIGHT*options_number+DEFAULT_CONTROL_HEIGHT;
             ELSE
                last_HEIGHT:=DEFAULT_CONTROL_HEIGHT;
             END IF;

             create_FEATURE(curr_node_id,in_new_parent_id,in_ui_def_id,temp(i));

       END IF; -- for FEATURE

       IF temp(i).ps_node_type=TOTAL_NODE_TYPE THEN

          last_HEIGHT:=DEFAULT_CONTROL_HEIGHT;
          create_TOTAL(curr_node_id,in_new_parent_id,in_ui_def_id,temp(i));

          --
          -- calculate TOP POS --
          --
          last_TOP_POS:=last_TOP_POS+last_HEIGHT+DEFAULT_SPACE_BETWEEN;

       END IF; -- for TOTAL

       IF temp(i).ps_node_type=RESOURCE_NODE_TYPE THEN

          last_HEIGHT:=DEFAULT_CONTROL_HEIGHT;

          create_RESOURCE(curr_node_id,in_new_parent_id,in_ui_def_id,temp(i));

          --
          -- calculate TOP POS --
          --
          last_TOP_POS:=last_TOP_POS+last_HEIGHT+DEFAULT_SPACE_BETWEEN;

       END IF; -- for RESOURCE

       IF temp(i).ps_node_type=CONNECTOR_NODE_TYPE THEN

          last_HEIGHT:=DEFAULT_CONTROL_HEIGHT;

          create_Connector(curr_node_id,in_new_parent_id,in_ui_def_id,temp(i));

          --
          -- calculate TOP POS --
          --
          last_TOP_POS:=last_TOP_POS+last_HEIGHT+DEFAULT_SPACE_BETWEEN;

       END IF; -- for Connector

      END IF;
      i:=temp.NEXT(i);
    END LOOP;

    /* ****
    IF mUI_STYLE=DHTML_STYLE_UI THEN
       UPDATE CZ_UI_NODES SET rel_top_pos=last_TOP_POS
       WHERE ui_def_id=in_ui_def_id AND ui_node_id=in_new_parent_id;
    END IF;
    */

EXCEPTION
    WHEN END_OPERATION THEN
         NULL;
END generate_FTR;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE generate_MCS
(in_parent_node_id     IN INTEGER,
 in_new_parent_id      IN INTEGER,
 in_ui_def_id          IN INTEGER,
 in_mode               IN VARCHAR2 , -- DEFAULT NO_FLAG,
 in_ui_tree_parent_id  IN INTEGER  DEFAULT NULL ,
 in_ui_parent_id       IN INTEGER  DEFAULT NULL,
 in_parent_text_id     IN INTEGER  DEFAULT NULL,
 in_parent_name        IN VARCHAR2 DEFAULT NULL,
 in_tree_seq           IN INTEGER  DEFAULT NULL) IS

    opt_bom               UIArray;
    temp_bom              UIArray;

    curr_node_id          CZ_UI_NODES.ui_node_id%TYPE;
    var_component_id      CZ_UI_NODES.component_id%TYPE;
    var_width             CZ_UI_NODES.width%TYPE;
    var_height            CZ_UI_NODES.height%TYPE;
    var_top_pos           CZ_UI_NODES.rel_top_pos%TYPE;
    var_left_pos          CZ_UI_NODES.rel_left_pos%TYPE;
    var_new_parent_id     CZ_UI_NODES.parent_id%TYPE;
    var_prev_parent_id    CZ_UI_NODES.parent_id%TYPE;
    var_curr_parent_id    CZ_UI_NODES.parent_id%TYPE;
    var_ui_node_ref_id    CZ_UI_NODES.ui_node_ref_id%TYPE;
    var_screen_oc_id      CZ_UI_NODES.ui_node_id%TYPE;
    var_model_ref_expl_id CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    var_use_default_color CZ_UI_NODES.default_bkgrnd_color_flag%TYPE:=YES_FLAG;

    var_type              INTEGER;
    var_temp              INTEGER;
    ind                   INTEGER;
    page_counter          INTEGER:=1;
    counter               INTEGER:=0;
    ind_arr               INTEGER:=0;
    i                     INTEGER;
    var_modified_flag     INTEGER;
    var_opt_class_scr     INTEGER;
    var_suffix            VARCHAR2(50);
    EMPTY_ARRAY           EXCEPTION;
    EMPTY_ARRAY_1         EXCEPTION;
    EMPTY_ARRAY_2         EXCEPTION;

BEGIN

    IF boms.Count=0 THEN
       RAISE EMPTY_ARRAY;
    END IF;

    var_new_parent_id:=in_new_parent_id;

    ind:=boms.First;
    LOOP
       IF ind IS NULL THEN
          EXIT;
       END IF;
       IF boms(ind).parent_id=in_parent_node_id THEN
          IF  boms(ind).ps_node_type IN (BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE) THEN
              BEGIN
                  IF boms(ind).ui_omit=NO_FLAG OR mSHOW_ALL_NODES=YES_FLAG THEN
                     opt_bom(boms(ind).tree_seq):=boms(ind);
                  END IF;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       NULL;
              END;
          ELSE
              BEGIN
                  IF boms(ind).ui_omit=NO_FLAG THEN
                     temp_bom(boms(ind).tree_seq):=boms(ind);
                  END IF;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       NULL;
              END;
          END IF;
       END IF;
       ind:=boms.NEXT(ind);
    END LOOP;

    IF in_mode=NO_FLAG THEN
       var_width:=USABLE_WIDTH;
       var_height:=DEFAULT_BOM_HEIGHT;
       var_left_pos:=LEFT_MARGIN;
    ELSE
       var_width:=100;
       var_height:=20;
       var_left_pos:=0;
    END IF;

    BEGIN
        IF opt_bom.Count=0 THEN
           RAISE EMPTY_ARRAY_1;
        END IF;

        i:=opt_bom.First;
        LOOP
           IF i IS NULL THEN
              EXIT;
           END IF;

           IF in_mode=NO_FLAG THEN
              var_top_pos:=last_TOP_POS;
              var_component_id:=opt_bom(i).parent_id;
              var_type:=UI_BOM_STANDART_TYPE;
              var_width:=set_Text_Width(opt_bom(i).caption_name)+80;
              IF var_width<=USABLE_WIDTH THEN
                 var_width:=USABLE_WIDTH;
              END IF;
           ELSE
              var_top_pos:=0;
              var_component_id:=NULL;
              var_type:=163;
           END IF;

           IF mLOOK_AND_FEEL='BLAF' THEN
              var_use_default_color:=YES_FLAG;
           ELSE
              var_use_default_color:=NO_FLAG;
           END IF;

           counter:=counter+1;
           IF counter>mITEMS_ON_PAGE AND in_ui_tree_parent_id IS NOT NULL
             AND page_counter<=mMAX_NUMBER_PAGES  AND mUI_STYLE=DHTML_STYLE_UI THEN

              var_prev_parent_id:=var_new_parent_id;
              var_curr_parent_id:=var_new_parent_id;

              var_suffix:=TO_CHAR(page_counter);

              --
              -- handle first page --
              --
              IF page_counter=1 THEN
                 BEGIN
                     SELECT caption_id,modified_flags
                     INTO var_temp,var_modified_flag FROM CZ_UI_NODES
                     WHERE ui_def_id=in_ui_def_id AND ui_node_ref_id=var_new_parent_id
                     AND ui_node_type=UI_COMPONENT_REF_TYPE AND deleted_flag='0';

                     UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                     WHERE intl_text_id=var_temp AND var_modified_flag=0;

                     SELECT caption_id,ui_node_ref_id,modified_flags
                     INTO var_temp,var_ui_node_ref_id,var_modified_flag
                     FROM CZ_UI_NODES
                     WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_new_parent_id
                     AND deleted_flag='0';

                     UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                     WHERE intl_text_id=var_temp AND var_modified_flag=0;

                     SELECT caption_id,modified_flags
                     INTO var_temp,var_modified_flag FROM CZ_UI_NODES
                     WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_ui_node_ref_id
                     AND deleted_flag='0';

                     UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                     WHERE intl_text_id=var_temp AND var_modified_flag=0;
             EXCEPTION
                 WHEN OTHERS THEN
                      NULL;
             END;
          END IF;

          page_counter:=page_counter+1;
          var_new_parent_id:=create_Page(in_ui_tree_parent_id=>in_ui_tree_parent_id,
                                         in_ui_parent_id     =>in_ui_parent_id,
                                         in_ps_node_id       =>in_parent_node_id,
                                         in_intl_text_id     =>in_parent_text_id,
                                         in_tree_seq         =>in_tree_seq,
                                         in_page_name        =>in_parent_name,
                                         in_ui_def_id        =>in_ui_def_id,
                                         in_counter          =>page_counter);

          IF mWIZARD_STYLE=YES_FLAG AND mUI_STYLE=DHTML_STYLE_UI THEN
             ind_arr:=footer_buttons.Count+1;
             footer_buttons(ind_arr).id:=getUISeqVal;
             footer_buttons(ind_arr).ui_parent_id:=var_new_parent_id;
             footer_buttons(ind_arr).rel_top_pos:=last_TOP_POS;
          END IF;

          last_TOP_POS:=START_TOP_POS+DEFAULT_SPACE_BETWEEN;
          var_top_pos:=last_TOP_POS;
          counter:=0;
       END IF;

       var_opt_class_scr:=var_new_parent_id;

       curr_node_id :=getUISeqVal;

       BEGIN
           SELECT ui_node_id INTO var_screen_oc_id FROM CZ_UI_NODES
           WHERE ui_def_id=in_ui_def_id AND ui_node_type=UI_BOM_OPTION_CLASS_TYPE AND ps_node_id=opt_bom(i).ps_node_id
           AND rownum<2 AND deleted_flag=NO_FLAG;
       EXCEPTION
           WHEN OTHERS THEN
                NULL;
       END;

       BEGIN
           SELECT model_ref_expl_id INTO var_model_ref_expl_id
           FROM CZ_MODEL_REF_EXPLS WHERE model_id=Project_Id
           AND parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG;
       EXCEPTION
           WHEN OTHERS THEN
                var_model_ref_expl_id:=NULL;
       END;

       set_UI_NODES(in_ui_node_id       =>curr_node_id,
                    in_parent_id        =>var_new_parent_id,
                    in_ui_def_id        =>in_ui_def_id,
                    in_ps_node_id       =>opt_bom(i).ps_node_id,
                    in_ui_node_ref_id   =>var_screen_oc_id,
                    in_name             =>opt_bom(i).name,
                    in_component_id     =>var_component_id,
                    in_ui_node_type     =>var_type,
                    in_lce_id           =>'P_'||to_char(opt_bom(i).ps_node_id),
                    in_tree_display_flag=>YES_FLAG,
                    in_tree_seq         =>opt_bom(i).tree_seq,
                    in_width            =>var_width,
                    in_height           =>var_height,
                    in_top_pos          =>var_top_pos,
                    in_left_pos         =>var_left_pos,
                    in_font_name        =>DEFAULT_FONT_NAME,
                    in_font_bold        =>NO_FLAG,
                    in_font_color       =>0,
                    in_font_italic      =>NO_FLAG,
                    in_font_size        =>DEFAULT_FONT_SIZE,
                    in_font_underline   =>NO_FLAG,
                    in_controltype      =>9,
                    in_bkgrnd_style     =>YES_FLAG,
                    in_intl_text_id     =>opt_bom(i).intl_text_id,
                    in_use_default_color=>var_use_default_color,
                    in_model_ref_expl_id=>var_model_ref_expl_id);

        generateUIProps(curr_node_id,in_ui_def_id,DEF_CLASS,
                        0, YES_FLAG, YES_FLAG,
                        NO_FLAG, NO_FLAG, NO_FLAG,
                        0, 'left', '0');

        last_TOP_POS:=last_TOP_POS+var_height+DEFAULT_SPACE_BETWEEN;
        last_HEIGHT:=var_height;

        i:=opt_bom.NEXT(i);
    END LOOP;

EXCEPTION
    WHEN EMPTY_ARRAY_1 THEN
         NULL;
    WHEN NO_DATA_FOUND THEN
         NULL;
END;

BEGIN

    IF temp_bom.Count=0 THEN
       RAISE EMPTY_ARRAY_2;
    END IF;

    IF opt_bom.Count>0 AND in_mode=NO_FLAG THEN
       create_DIVIDER(getUISeqVal,var_new_parent_id,in_ui_def_id,
                      last_TOP_POS+DEFAULT_DIVIDER_HEIGHT,LEFT_MARGIN, 0);
       last_TOP_POS:=last_TOP_POS+DEFAULT_DIVIDER_HEIGHT+DEFAULT_SPACE_BETWEEN;
    END IF;

    i:=temp_bom.First;
    LOOP
       IF i IS NULL THEN
          EXIT;
       END IF;
       IF in_mode=NO_FLAG THEN
          var_top_pos:=last_TOP_POS;
          var_component_id:=temp_bom(i).parent_id;
          var_type:=UI_BOM_STANDART_TYPE;
          var_width:=set_Text_Width(temp_bom(i).caption_name)+80;
          IF var_width<=USABLE_WIDTH THEN
             var_width:=USABLE_WIDTH;
          END IF;
       ELSE
          var_top_pos:=0;
          var_component_id:=NULL;
          var_type:=163;
       END IF;

       IF mLOOK_AND_FEEL='BLAF' THEN
          var_use_default_color:=YES_FLAG;
       ELSE
          var_use_default_color:=NO_FLAG;
       END IF;

       counter:=counter+1;

       IF counter>mITEMS_ON_PAGE AND in_ui_tree_parent_id IS NOT NULL
          AND page_counter<=mMAX_NUMBER_PAGES  AND mUI_STYLE=DHTML_STYLE_UI THEN

          var_prev_parent_id:=var_new_parent_id;
          var_curr_parent_id:=var_new_parent_id;

          var_suffix:=' ('||TO_CHAR(page_counter)||')';

          IF page_counter=1 THEN
             BEGIN
                 SELECT caption_id,modified_flags
                 INTO var_temp,var_modified_flag FROM CZ_UI_NODES
                 WHERE ui_def_id=in_ui_def_id AND ui_node_ref_id=var_new_parent_id
                 AND ui_node_type=UI_COMPONENT_REF_TYPE AND deleted_flag='0';

                 UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                 WHERE intl_text_id=var_temp AND var_modified_flag=0;

                 UPDATE CZ_UI_NODES SET name=name||var_suffix
                 WHERE  ui_def_id=in_ui_def_id AND ui_node_id=var_new_parent_id
                        AND deleted_flag='0'
                 RETURNING caption_id,ui_node_ref_id,modified_flags
                 INTO var_temp,var_ui_node_ref_id,var_modified_flag;

                 UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                 WHERE intl_text_id=var_temp AND var_modified_flag=0;

                 SELECT caption_id,modified_flags
                 INTO var_temp,var_modified_flag FROM CZ_UI_NODES
                 WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_ui_node_ref_id
                 AND deleted_flag='0';

                 UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                 WHERE intl_text_id=var_temp AND var_modified_flag=0;

             EXCEPTION
                 WHEN OTHERS THEN
                      NULL;
             END;
          END IF;

          page_counter:=page_counter+1;

          var_new_parent_id:=create_Page(in_ui_tree_parent_id=>in_ui_tree_parent_id,
                                         in_ui_parent_id     =>in_ui_parent_id,
                                         in_ps_node_id       =>in_parent_node_id,
                                         in_intl_text_id     =>in_parent_text_id,
                                         in_tree_seq         =>in_tree_seq,
                                         in_page_name        =>in_parent_name,
                                         in_ui_def_id        =>in_ui_def_id,
                                         in_counter          =>page_counter);

          IF mWIZARD_STYLE=YES_FLAG AND mUI_STYLE=DHTML_STYLE_UI THEN
             ind_arr:=footer_buttons.Count+1;
             footer_buttons(ind_arr).id:=getUISeqVal;
             footer_buttons(ind_arr).ui_parent_id:=var_new_parent_id;
             footer_buttons(ind_arr).rel_top_pos:=last_TOP_POS;
          END IF;

          last_TOP_POS:=START_TOP_POS+DEFAULT_SPACE_BETWEEN;
          var_top_pos:=last_TOP_POS;
          counter:=1;
       END IF;

       curr_node_id :=getUISeqVal;
       set_UI_NODES(   in_ui_node_id       =>curr_node_id,
                       in_parent_id        =>var_new_parent_id,
                       in_ui_def_id        =>in_ui_def_id,
                       in_ps_node_id       =>temp_bom(i).ps_node_id,
                       in_ui_node_ref_id   =>NULL,
                       in_component_id     =>var_component_id,
                       in_name             =>temp_bom(i).name,
                       in_ui_node_type     =>var_type,
                       in_lce_id           =>'P_'||to_char(temp_bom(i).ps_node_id),
                       in_tree_display_flag=>YES_FLAG,
                       in_tree_seq         =>temp_bom(i).tree_seq,
                       in_width            =>var_width,
                       in_height           =>var_height,
                       in_top_pos          =>var_top_pos,
                       in_left_pos         =>var_left_pos,
                       in_font_name        =>DEFAULT_FONT_NAME,
                       in_font_bold        =>NO_FLAG,
                       in_font_color       =>0,
                       in_font_italic      =>NO_FLAG,
                       in_font_size        =>DEFAULT_FONT_SIZE,
                       in_font_underline   =>NO_FLAG,
                       in_controltype      =>9,
                       in_bkgrnd_style     =>YES_FLAG,
                       in_intl_text_id     =>temp_bom(i).intl_text_id,
                       in_use_default_color=>var_use_default_color);
        last_TOP_POS:=last_TOP_POS+var_height+DEFAULT_SPACE_BETWEEN;
        last_HEIGHT:=var_height;

        i:=temp_bom.NEXT(i);
    END LOOP;

    /* *** VB code needs this update for Preview              *** */
    /* *** if we add a new control then VB should add         *** */
    /* *** the control under all others control on the screen *** */
    --IF mUI_STYLE=DHTML_STYLE_UI THEN
    --   UPDATE CZ_UI_NODES SET rel_top_pos=last_TOP_POS
    --   WHERE ui_def_id=in_ui_def_id AND ui_node_id=in_new_parent_id;
    --END IF;

EXCEPTION
    WHEN EMPTY_ARRAY_2 THEN
         NULL;
    WHEN NO_DATA_FOUND THEN
         NULL;
END;

EXCEPTION
    WHEN EMPTY_ARRAY THEN
         NULL;
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS THEN
         --LOG_REPORT('CZ_UI_GENERATOR.generate_MCS','ui_def_id='||TO_CHAR(in_ui_def_id)||' : '||SQLERRM);
         FND_REPORT(CZ_UI_GEN_FATAL_ERR,TOKEN_SQLERRM,SQLERRM, CZ_ERROR_URGENCY);
END generate_MCS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_Component_Tree
(in_product_id     IN  INTEGER,
 out_ui_def_id     OUT NOCOPY INTEGER,
 in_screen_width   IN  INTEGER,  -- DEFAULT DEFAULT_TARGET_FRAME_WIDTH,
 in_screen_height  IN  INTEGER,  -- DEFAULT DEFAULT_TARGET_FRAME_HEIGHT,
 in_show_all_nodes IN  VARCHAR2, -- DEFAULT '0',
 in_use_labels     IN  VARCHAR2  -- DEFAULT '1'
) IS

t_ref_uis             IntArray;
var_ref_ui            INTEGER;
new_id                INTEGER;
new_parent            INTEGER;
new_child             INTEGER;
new_ui_def_id         INTEGER;
new_node_ref_id       INTEGER;
curr_node_id          INTEGER;
curr_label_id         INTEGER;
curr_bitmap_id        INTEGER;
curr_button_id        INTEGER;

var_comp_tree_id      INTEGER;
var_ui_root_id        INTEGER;

default_PROD_TOP      INTEGER;
default_PROD_LEFT     INTEGER;
var_component_id      INTEGER;
var_model_id          INTEGER;
var_parent_id         INTEGER;
var_prev_ps_id        INTEGER;
ind                   INTEGER;
ind_arr               INTEGER;
k                     INTEGER;

var_name              CZ_UI_NODES.name%TYPE;
var_caption_name      CZ_INTL_TEXTS.text_str%TYPE;

BEGIN

ERROR_CODE:='0000';
Initialize;
ERROR_CODE:='0001';

/* ************ Calculate usable width and height *************** */

USABLE_WIDTH:=FLOOR(in_screen_width*(100-DEFAULT_TREE_ALLOCATION)/100)-LEFT_MARGIN-RIGHT_MARGIN;
USABLE_HEIGHT:=in_screen_height;

OPTION_FEATURE_WIDTH:=FLOOR(USABLE_WIDTH/2);
CENTER_LINE:=LEFT_MARGIN+OPTION_FEATURE_WIDTH;
DELETE_BUTTON_LEFT_POS:=USABLE_WIDTH+LEFT_MARGIN-DELETE_BUTTON_WIDTH;

NUMERIC_FEATURE_WIDTH:=FLOOR(OPTION_FEATURE_WIDTH/2);
BOOLEAN_FEATURE_WIDTH:=16;
DEFAULT_TOTAL_WIDTH:=NUMERIC_FEATURE_WIDTH;
DEFAULT_RESOURCE_WIDTH:=NUMERIC_FEATURE_WIDTH;
DEFAULT_CONNECTOR_WIDTH:=NUMERIC_FEATURE_WIDTH;

CONNECTOR_GAP := DEFAULT_CONNECTOR_WIDTH+DEFAULT_SPACE_BETWEEN+STAR_SYMBOL_WIDTH+DEFAULT_SPACE_BETWEEN;
/* ************ Calculate Default Tops and Lefts  *************** */

last_TOP_POS:=START_TOP_POS;
last_HEIGHT:=0;

/* *** If in_ui_product_id is not NULL then it means ******* */
/* *** that current procedure is executed by BOM gen and *** */
/* *** in this case we use in_ui_def_id                  *** */
/* *** otherwize new ui_def is created                   *** */

ERROR_CODE:='0002';

new_ui_def_id:=generate_UI_DEF;

ERROR_CODE:='0003';

/* *** generate common properties for current UI DEF *** */
generateUIProperties(new_ui_def_id);

ERROR_CODE:='0004';

/* *** create Component Tree Header ( User Interfaces,Interface,Components Tree ) *** */
create_Tree_Header(in_ui_def_id            => new_ui_def_id,
                   in_product_id           =>in_product_id,
                   out_component_tree_id   =>var_comp_tree_id,
                   out_interface_id        =>var_ui_root_id,
                   in_screen_width         =>in_screen_width,
                   in_screen_height        =>in_screen_height,
                   in_show_all_nodes       =>in_show_all_nodes);

ERROR_CODE:='0005';

SELECT parent_id INTO var_model_id FROM CZ_PS_NODES
WHERE ps_node_id=in_product_id;

ERROR_CODE:='0006';

curr_node_id:=getUISeqVal;

news(Model_Id).id:=var_comp_tree_id;
news(Model_Id).ps_node_id:=Model_Id;
news(Model_Id).parent_id:=NULL;

FOR i IN
(SELECT ps_node_id,parent_id,name,ps_node_type,
        tree_seq,counted_options_flag,maximum,minimum,
        ui_omit,item_id,feature_type,intl_text_id,reference_id,virtual_flag,orig_sys_ref FROM CZ_PS_NODES
 WHERE devl_project_id=Project_Id AND ps_node_type
 in (PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,FEATURE_NODE_TYPE,RESOURCE_NODE_TYPE,TOTAL_NODE_TYPE,OPTION_NODE_TYPE,
     BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE,BOM_STANDART_NODE_TYPE,REFERENCE_NODE_TYPE,CONNECTOR_NODE_TYPE)
 START WITH ps_node_id=in_product_id
 CONNECT BY PRIOR ps_node_id=parent_id
 AND (ui_omit=NO_FLAG OR in_show_all_nodes=YES_FLAG) AND deleted_flag=NO_FLAG)
 LOOP
    ERROR_CODE:='0006';

    curr_node_id:=getUISeqVal;
    var_caption_name:=i.name;

    IF i.intl_text_id IS NOT NULL AND in_use_labels<>'0' THEN
       BEGIN
         SELECT RTRIM(text_str,' ') INTO var_caption_name FROM CZ_INTL_TEXTS
         WHERE intl_text_id=i.intl_text_id;

         -- if there is caption_id that does not point to CZ_INTL_TEXTS --
         -- then just ignore it and use name from PS tree               --
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           var_caption_name:=i.name;
       END;

       IF var_caption_name IS NULL OR var_caption_name='' THEN
         var_caption_name:=i.name;
       ELSE
         IF in_use_labels IN('2','3') THEN
            IF length(var_caption_name)<=length(i.name||mCONCAT_SYMBOL||var_caption_name) THEN
              var_caption_name := i.name||mCONCAT_SYMBOL||var_caption_name;
            ELSE
              var_caption_name := i.name;
            END IF;
         END IF;
       END IF;

    END IF;

    IF i.ps_node_type IN (PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,
       BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE,REFERENCE_NODE_TYPE)  THEN
       news(i.ps_node_id).id:=curr_node_id;
       news(i.ps_node_id).ps_node_id:=i.ps_node_id;
       news(i.ps_node_id).parent_id:=i.parent_id;
       news(i.ps_node_id).ps_node_type:=i.ps_node_type;
       news(i.ps_node_id).name:=i.name;
       news(i.ps_node_id).caption_name:=var_caption_name;
       news(i.ps_node_id).tree_seq:=i.tree_seq*mMAX_NUMBER_PAGES;
       news(i.ps_node_id).maximum:=i.maximum;
       news(i.ps_node_id).minimum:=i.minimum;
       news(i.ps_node_id).ui_omit:=i.ui_omit;
       news(i.ps_node_id).virtual_flag:=i.virtual_flag;
       news(i.ps_node_id).intl_text_id:=i.intl_text_id;

       IF i.ps_node_type IN(REFERENCE_NODE_TYPE) THEN
          news(i.ps_node_id).reference_id:=i.reference_id;
       END IF;
          news(i.ps_node_id).ui_node_ref_id:=getUISeqVal;
    END IF;

    IF i.ps_node_type IN (FEATURE_NODE_TYPE,RESOURCE_NODE_TYPE,TOTAL_NODE_TYPE,CONNECTOR_NODE_TYPE) THEN
       features(i.ps_node_id).id:=curr_node_id;
       features(i.ps_node_id).ps_node_id:=i.ps_node_id;
       features(i.ps_node_id).parent_id:=i.parent_id;
       features(i.ps_node_id).ps_node_type:=i.ps_node_type;
       features(i.ps_node_id).name:=i.name;
       features(i.ps_node_id).caption_name:=var_caption_name;
       features(i.ps_node_id).counted_options_flag:=i.counted_options_flag;
       features(i.ps_node_id).tree_seq:=i.tree_seq*mMAX_NUMBER_PAGES;
       features(i.ps_node_id).maximum:=i.maximum;
       features(i.ps_node_id).minimum:=i.minimum;
       features(i.ps_node_id).feature_type:=i.feature_type;
       features(i.ps_node_id).intl_text_id:=i.intl_text_id;

       IF i.ps_node_type IN(CONNECTOR_NODE_TYPE) THEN
          features(i.ps_node_id).reference_id:=i.reference_id;
       END IF;

       --
       -- atp_flag=TRUE means - it can be used in pricing stuff --
       -- atp_flag = TRUE just when it's BOM node               --
       --
       -- this is an old condition      --
       -- IF i.item_id IS NOT NULL THEN --
       --
       IF i.orig_sys_ref IS NOT NULL THEN
          features(i.ps_node_id).atp_flag:=TRUE;
       ELSE
          features(i.ps_node_id).atp_flag:=FALSE;
       END IF;
    END IF;

    IF i.ps_node_type=OPTION_NODE_TYPE THEN
       options(i.ps_node_id).id:=curr_node_id;
       options(i.ps_node_id).ps_node_id:=i.ps_node_id;
       options(i.ps_node_id).parent_id:=i.parent_id;
       options(i.ps_node_id).name:=i.name;
       options(i.ps_node_id).caption_name:=var_caption_name;
       options(i.ps_node_id).tree_seq:=i.tree_seq;
       options(i.ps_node_id).intl_text_id:=i.intl_text_id;
    END IF;

    IF i.ps_node_type IN (BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE,BOM_STANDART_NODE_TYPE) THEN
       boms(i.ps_node_id).id:=curr_node_id;
       boms(i.ps_node_id).ps_node_id:=i.ps_node_id;
       boms(i.ps_node_id).parent_id:=i.parent_id;
       boms(i.ps_node_id).ps_node_type:=i.ps_node_type;
       boms(i.ps_node_id).name:=i.name;
       boms(i.ps_node_id).caption_name:=var_caption_name;
       boms(i.ps_node_id).tree_seq:=i.tree_seq*mMAX_NUMBER_PAGES;
       boms(i.ps_node_id).maximum:=i.maximum;
       boms(i.ps_node_id).minimum:=i.minimum;
       boms(i.ps_node_id).ui_omit:=i.ui_omit;
       boms(i.ps_node_id).virtual_flag:=i.virtual_flag;
       boms(i.ps_node_id).intl_text_id:=i.intl_text_id;
       boms(i.ps_node_id).ui_node_ref_id:=getUISeqVal;
    END IF;
    ERROR_CODE:='0007';
END LOOP; -- for main LOOP

UI_Product_Id:=news(in_product_id).id;

/* *** main LOOP for UI creation *** */

k:=news.First;
LOOP
    BEGIN
    ERROR_CODE:='0007';

    IF news(k).parent_id IS NOT NULL THEN
       new_parent:=news(news(k).parent_id).id;           -- find new parent node id
    ELSE
       new_parent:=var_comp_tree_id;                     -- 1st Tree node reference to  Components Tree node
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         new_parent:=Model_Id;
    END;
    ERROR_CODE:='0008';
    new_child:=news(k).id;                               -- find new Tree node id

    curr_node_id:=getUISeqVal;

    /* ************************** create PRODUCTs ******************************* */

    IF news(k).ps_node_type=PRODUCT_NODE_TYPE  THEN
       ERROR_CODE:='0008';

       var_parent_id:=curr_node_id;
       create_PRODUCT(news(k).ui_node_ref_id,var_ui_root_id,new_ui_def_id,news(k));
       ERROR_CODE:='0009';

       /* ****** create PRODUCT node for Model Tree ****** */

       create_PRODUCT_Model(new_child,new_parent,new_ui_def_id,news(k).ui_node_ref_id,news(k));
       ERROR_CODE:='0010';

       IF mWIZARD_STYLE=YES_FLAG AND mUI_STYLE=DHTML_STYLE_UI THEN
          ind_arr:=footer_buttons.Count+1;
          footer_buttons(ind_arr).id:=getUISeqVal;
          footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
          footer_buttons(ind_arr).rel_top_pos:=0;
       END IF;

       generate_MCS(in_parent_node_id     =>news(k).ps_node_id,
                    in_new_parent_id      =>news(k).ui_node_ref_id,
                    in_ui_def_id          =>new_ui_def_id,
                    in_mode               =>'0');
       ERROR_CODE:='0011';

       generate_FTR(news(k).ps_node_id,news(k).ui_node_ref_id,new_ui_def_id);
       ERROR_CODE:='0012';

    END IF;  -- for PRODUCT

    /* ************************** create COMPONENTs ******************************* */

    IF news(k).ps_node_type=COMPONENT_NODE_TYPE THEN
       ERROR_CODE:='0013';

       IF news(k).parent_id IS NULL THEN
          var_prev_ps_id:=-1;
       ELSE
          var_prev_ps_id:=news(news(k).parent_id).ui_node_ref_id;
       END IF;
       ERROR_CODE:='0014';

       create_COMPONENT(news(k).ui_node_ref_id,var_ui_root_id,new_ui_def_id,var_prev_ps_id,news(k));
       ERROR_CODE:='0015';

       create_COMPONENT_Model(new_child,new_parent,new_ui_def_id,news(k).ui_node_ref_id,news(k));
       ERROR_CODE:='0016';

       generate_FTR(news(k).ps_node_id,news(k).ui_node_ref_id,new_ui_def_id);
       ERROR_CODE:='0017';

       IF mWIZARD_STYLE=YES_FLAG  AND mUI_STYLE=DHTML_STYLE_UI THEN
          ind_arr:=footer_buttons.Count+1;
          footer_buttons(ind_arr).id:=getUISeqVal;
          footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
          footer_buttons(ind_arr).rel_top_pos:=last_TOP_POS;
       END IF;
       ERROR_CODE:='0018';

    END IF; ---- for COMPONENT

    /* ************************** create REFERENCEs ******************************* */


    IF news(k).ps_node_type=REFERENCE_NODE_TYPE THEN
       ERROR_CODE:='0019';
       create_REFERENCE_Model(new_child,new_parent,new_ui_def_id,
                              news(news(k).parent_id).ui_node_ref_id,news(k),var_ref_ui);
       ERROR_CODE:='0020';
    END IF;

      /* ***************************************************************** */
      /* ************************* BOM section *************************** */
      /* ***************************************************************** */

    IF news(k).ps_node_type=BOM_MODEL_NODE_TYPE THEN
       ERROR_CODE:='0021';

       createBOM_MODEL(news(k).ui_node_ref_id,var_ui_root_id,new_ui_def_id,news(k));
       ERROR_CODE:='0022';

       /* *** create record for Model Tree *** */
       createBOM_MODEL_Model(new_child,new_parent,
                             new_ui_def_id,news(k).ui_node_ref_id,news(k));
       ERROR_CODE:='0023';


       /* *** create OPTION CLASSES AND STANDARTS for the screen *** */

       IF mWIZARD_STYLE=YES_FLAG  AND mUI_STYLE=DHTML_STYLE_UI THEN
          ind_arr:=footer_buttons.Count+1;
          footer_buttons(ind_arr).id:=getUISeqVal;
          footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
          footer_buttons(ind_arr).rel_top_pos:=last_TOP_POS;
       END IF;
       ERROR_CODE:='0024';

       generate_MCS(in_parent_node_id     =>news(k).ps_node_id,
                    in_new_parent_id      =>news(k).ui_node_ref_id,
                    in_ui_def_id          =>new_ui_def_id,
                    in_mode               =>'0');
       ERROR_CODE:='0025';


       /* *** create Features, Totals, Resources for the screen *** */
       generate_FTR(news(k).ps_node_id,news(k).ui_node_ref_id,new_ui_def_id);
       ERROR_CODE:='0026';

    END IF; -- for BOM_MODEL

    IF news(k).ps_node_type=BOM_CLASS_NODE_TYPE
       AND (news(k).ui_omit=NO_FLAG OR in_show_all_nodes=YES_FLAG) THEN

       ERROR_CODE:='0027';

       createBOM_CLASS(news(k).ui_node_ref_id,var_ui_root_id,new_ui_def_id,news(k));
       ERROR_CODE:='0028';

       /* *** create record for Model Tree *** */
       createBOM_CLASS_Model(new_child,new_parent,
                             new_ui_def_id,news(k).ui_node_ref_id,news(k));
       ERROR_CODE:='0029';


       /* *** create OPTION CLASSES AND STANDARTS for the screen *** */
       IF mWIZARD_STYLE=YES_FLAG  AND mUI_STYLE=DHTML_STYLE_UI THEN
          ind_arr:=footer_buttons.Count+1;
          footer_buttons(ind_arr).id:=getUISeqVal;
          footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
          footer_buttons(ind_arr).rel_top_pos:=0;
       END IF;
       ERROR_CODE:='0030';

       generate_MCS(in_parent_node_id     =>news(k).ps_node_id,
                    in_new_parent_id      =>news(k).ui_node_ref_id,
                    in_ui_def_id          =>new_ui_def_id,
                    in_mode               =>'0',
                    in_ui_tree_parent_id  =>new_parent,
                    in_ui_parent_id       =>var_ui_root_id,
                    in_parent_text_id     =>news(k).intl_text_id,
                    in_parent_name        =>news(k).name,
                    in_tree_seq           =>news(k).tree_seq);
       ERROR_CODE:='0031';

       --IF mWIZARD_STYLE=YES_FLAG  AND mUI_STYLE=DHTML_STYLE_UI THEN
       --   create_Wizard_Style_Buttons(news(k).ui_node_ref_id,new_ui_def_id);
       --END IF;

    END IF; -- for BOM classes

    k:=news.NEXT(k);
    IF k IS NULL THEN
       EXIT;
    END IF;

END LOOP;  -- main LOOP for creation


/***********************************/
IF ref_boms.Count>0 THEN
   FOR i IN ref_boms.First..ref_boms.Last LOOP
       ERROR_CODE:='0032';
       add_BOM_MODEL_ITEM(ref_boms(i).ui_parent_id,ref_boms(i).model_id,
                          new_ui_def_id,ref_boms(i).ps_node_id,
                          ref_boms(i).maximum,ref_boms(i).minimum,ref_boms(i).virtual_flag,t_ref_uis);
       ERROR_CODE:='0033';
   END LOOP;
END IF;

ERROR_CODE:='0034';

--
-- create ADD buttons for instantable Components and Products  --
--
create_ADD_BUTTONS(new_ui_def_id);

--
-- create EXECUTE buttons for Functional Companions --
--
create_FUNC_BUTTONS(Project_Id,new_ui_def_id,-1);
ERROR_CODE:='0035';
--
-- shift all ADD and EXECUTE buttons to the bottom of the screen --
--
FOR i IN (SELECT ui_node_ref_id FROM CZ_UI_NODES
          WHERE ui_def_id=new_ui_def_id AND
          ui_node_type IN (UI_PRODUCT_REF_TYPE,UI_COMPONENT_REF_TYPE) AND
          deleted_flag=NO_FLAG)
LOOP
   ERROR_CODE:='0036';
   shift_BUTTONS(i.ui_node_ref_id);
   ERROR_CODE:='0037';
END LOOP;

--
-- create "Home","Back" and "Next" buttons --
--
IF mWIZARD_STYLE=YES_FLAG AND mUI_STYLE=DHTML_STYLE_UI THEN
   ERROR_CODE:='0038';
   create_Wizard_Style_Buttons(new_ui_def_id, -1);
   ERROR_CODE:='0039';
END IF;

populate_RefSI(new_ui_def_id);

ERROR_CODE:='0040';
/* *** create Limbo and Recycle Bin *** */
create_Footprints(new_ui_def_id,var_ui_root_id);
ERROR_CODE:='0041';

/* *** OUT NOCOPY variable is ID of the generated UI *** */
UPDATE CZ_UI_NODES SET name=InterfaceName WHERE ui_node_id=parent_id AND ui_def_id=new_ui_def_id;
out_ui_def_id:=new_ui_def_id;

ERROR_CODE:='0042';

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('CZ_UI_GENERATOR.create_Component_tree','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM,
                CZ_ERROR_URGENCY);
     FND_REPORT(CZ_UI_GEN_FATAL_ERR,TOKEN_SQLERRM,SQLERRM, CZ_ERROR_URGENCY);
     RAISE;
END create_Component_Tree;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

/******************************************************************/
/*********** BOM style UI ( Applet UI )section ********************/
/******************************************************************/

PROCEDURE create_UI_element
(in_id            IN INTEGER,
 in_par_id        IN INTEGER,
 in_def_id        IN INTEGER,
 in_ui_type       IN INTEGER,
 in_tree_seq      IN INTEGER,
 in_width         IN INTEGER,
 in_height        IN INTEGER,
 in_caption       IN VARCHAR2 DEFAULT NULL,
 in_allocations   IN VARCHAR2 DEFAULT NULL,
 in_borders       IN VARCHAR2 DEFAULT NULL, -- NO_FLAG,
 in_scrolling     IN VARCHAR2 DEFAULT NULL, -- NO_FLAG,
 in_sizeable      IN VARCHAR2 DEFAULT NULL, -- YES_FLAG,
 in_system_frm    IN VARCHAR2 DEFAULT NULL, -- NO_FLAG,
 in_top_pos       IN INTEGER  DEFAULT NULL, -- 0,
 in_left_pos      IN INTEGER  DEFAULT NULL, -- 0,
 in_margin_width  IN VARCHAR2 DEFAULT NULL, -- '10',
 in_margin_height IN VARCHAR2 DEFAULT NULL, -- '10',
 in_action        IN VARCHAR2 DEFAULT NULL, -- NO_FLAG,
 in_action_type   IN VARCHAR2 DEFAULT NULL, -- '-1',
 in_alt_color     IN VARCHAR2 DEFAULT NULL, -- '15201271',
 in_data_tag      IN VARCHAR2 DEFAULT NULL,
 in_editable      IN VARCHAR2 DEFAULT NULL, -- NO_FLAG,
 in_control_type  IN VARCHAR2 DEFAULT NULL, -- '-1',
 in_rowscols      IN VARCHAR2 DEFAULT NULL, -- YES_FLAG,
 in_hierarchy     IN VARCHAR2 DEFAULT NULL, -- NO_FLAG,
 in_picture       IN VARCHAR2 DEFAULT NULL,
 in_align         IN VARCHAR2 DEFAULT NULL,
 in_bkgrnd_style  IN VARCHAR2 DEFAULT NULL  -- YES_FLAG
) IS

var_caption_id      INTEGER;
var_tool_tip_id     INTEGER;
var_name            VARCHAR2(255);
var_use_def_font    VARCHAR2(1):=YES_FLAG;
var_use_def_pic     VARCHAR2(1):=YES_FLAG;
var_use_def_color   VARCHAR2(1):=YES_FLAG;
var_font_name       CZ_UI_NODES.fontname%type;
var_font_bold       CZ_UI_NODES.fontbold%type;
var_font_color      CZ_UI_NODES.fontcolor%type;
var_font_italic     CZ_UI_NODES.fontitalic%type;
var_font_size       CZ_UI_NODES.fontsize%type;
var_font_underline  CZ_UI_NODES.fontunderline%type;
var_bkgrnd_style    CZ_UI_NODES.backgroundstyle%type;
var_borders         CZ_UI_NODES.borders%type;
var_picname         CZ_UI_NODES.picturename%type;

BEGIN

IF in_ui_type=DEF_BUTTON THEN
   var_use_def_pic:=NO_FLAG;
   var_use_def_color:=NO_FLAG;
END IF;

var_font_name:=NULL;
var_font_bold:=NULL;
var_font_color:=NULL;
var_font_italic:=NULL;
var_font_size:=NULL;
var_font_underline :=NULL;
var_bkgrnd_style:=NULL;
var_borders:=NVL(in_borders, NO_FLAG);

IF    in_ui_type=DEF_FRAMESET THEN
      var_name:='FrameSet-';
ELSIF in_ui_type=DEF_FRAME THEN
      var_name:='Frame-';
      var_bkgrnd_style:=YES_FLAG;
ELSIF in_ui_type=DEF_PANEL THEN
      var_name:='Panel-';
      var_borders:=NO_FLAG;
ELSIF in_ui_type=DEF_BUTTON THEN
      var_name:='Button-';
      var_bkgrnd_style:=YES_FLAG;
      var_borders:=NO_FLAG;
ELSIF in_ui_type=DEF_TEXT_CONTROL THEN
      var_name:='TextControl-';
ELSIF in_ui_type=DEF_TEXT THEN
      var_name:='Text-';
      var_font_name:=DEFAULT_FONT_NAME;
      var_font_bold:=NO_FLAG;
      var_font_color:=0;
      var_font_italic:=NO_FLAG;
      var_font_size:=DEFAULT_FONT_SIZE;
      var_font_underline :=NO_FLAG;
      var_bkgrnd_style:=YES_FLAG;
ELSIF in_ui_type=DEF_TAGGED_VALUE THEN
      var_name:='TaggedValueDisplay-';
ELSIF in_ui_type=DEF_FIND_CONTROL THEN
      var_name:='Find Control-';
ELSIF in_ui_type=DEF_GRID THEN
      var_name:='Grid-';
ELSIF in_ui_type=DEF_COLUMN THEN
      var_name:='Column-';
ELSIF in_ui_type=DEF_DATASET THEN
      var_name:='DataSetList-';
ELSE
      NULL;
END IF;

var_name:=var_name||TO_CHAR(in_id);
IF in_ui_type=DEF_MODELTREE THEN
      var_name:='Model Tree';
      var_font_name:=DEFAULT_FONT_NAME;
      var_font_bold:=YES_FLAG;
      var_font_color:=0;
      var_font_italic:=NO_FLAG;
      var_font_size:=DEFAULT_FONT_SIZE;
      var_font_underline :=NO_FLAG;
      var_bkgrnd_style:=YES_FLAG;
      var_borders:=NO_FLAG;
      var_picname:=TREE_TILING_BMP;
END IF;

set_UI_NODES
(in_ui_node_id       =>in_id,
 in_parent_id        =>in_par_id,
 in_ui_def_id        =>in_def_id,
 in_ps_node_id       =>NULL,
 in_ui_node_ref_id   =>NULL,
 in_name             =>var_name,
 in_ui_node_type     =>in_ui_type,
 in_background_color =>DEFAULT_BACKGROUND_COLOR,
 in_component_id     =>NULL,
 in_width            =>in_width,
 in_height           =>in_height,
 in_tree_display_flag=>NO_FLAG,
 in_use_default_font =>var_use_def_font,
 in_use_default_pic  =>var_use_def_pic,
 in_use_default_color=>var_use_def_color,
 in_tree_seq         =>in_tree_seq,
 in_top_pos          =>NVL(in_top_pos, 0),
 in_left_pos         =>NVL(in_left_pos, 0),
 in_caption          =>in_caption,
 in_picname          =>in_picture,
 in_font_name        =>DEFAULT_FONT_NAME,
 in_font_bold        =>NO_FLAG,
 in_font_color       =>0,
 in_font_italic      =>NO_FLAG,
 in_font_size        =>9,
 in_font_underline   =>NO_FLAG,
 in_controltype      =>NVL(in_control_type, '-1'),
 in_bkgrnd_style     =>NVL(in_bkgrnd_style, YES_FLAG),
 in_borders          =>NVL(in_borders, NO_FLAG));

generateBOMUIProps(in_id,in_def_id,in_ui_type,
                   in_allocations,
                   NVL(in_borders, NO_FLAG),
                   NVL(in_scrolling, NO_FLAG),
                   NVL(in_sizeable, YES_FLAG),
                   NVL(in_system_frm, NO_FLAG),
                   NVL(in_margin_width, '10'),
                   NVL(in_margin_height, '10'),
                   NVL(in_action, NO_FLAG),
                   NVL(in_action_type, '-1'),
                   NVL(in_alt_color, '15201271'),
                   in_data_tag,
                   NVL(in_editable, NO_FLAG),
                   NVL(in_control_type, '-1'),
                   NVL(in_rowscols, YES_FLAG),
                   null,
                   in_align);

/* ***
BEGIN
IF in_caption IS NOT NULL THEN
   var_caption_id:=getTXTSeqVal;
   UPDATE CZ_UI_NODES SET caption_id=var_caption_id
   WHERE ui_def_id=in_def_id AND ui_node_id=in_id;
   FOR i IN(SELECT message_text,language_code FROM FND_NEW_MESSAGES WHERE message_name=in_caption)
   LOOP
      INSERT INTO CZ_LOCALIZED_TEXTS
                 (INTL_TEXT_ID,
                  LOCALIZED_STR,
                  LANGUAGE,
                  SOURCE_LANG,
                  DELETED_FLAG,
                  SECURITY_MASK,
                  CHECKOUT_USER)
       VALUES(
                              var_caption_id,
                              i.message_text,
                              i.language_code,
                              i.language_code,
                  '0',
                  NULL,
                  NULL);

   END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
     NULL;
END;
*** */


END create_UI_element;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_OptionsGrid
(in_parent_id IN INTEGER,
 in_ui_def_id IN INTEGER) IS

    Grid_Id   CZ_UI_NODES.ui_node_id%TYPE;
    Column_Id CZ_UI_NODES.ui_node_id%TYPE;

BEGIN
    Grid_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_GRID,
                      in_id       =>Grid_Id,
                      in_par_id   =>in_parent_id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>1,
                      in_width    =>100,
                      in_height   =>20,
                      in_caption  =>'',
                      in_alt_color=>'15201271',
                      in_hierarchy=>NO_FLAG);

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_COLUMN,
                      in_id          =>Column_Id,
                      in_par_id      =>Grid_Id,
                      in_def_id      =>in_ui_def_id,
                      in_tree_seq    =>1,
                      in_width       =>25,
                      in_height      =>20,
                      in_caption     =>' ',
                      in_data_tag    =>'cfg:logic-state',
                      in_editable    =>YES_FLAG,
                      in_control_type=>'3');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>2,
                      in_width    =>120,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_ITEM_CAPTION,
                      in_data_tag    =>'cfg:name');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>3,
                      in_width    =>450,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_DESCRIPTION_CAPTION,
                      in_data_tag    =>'cfg:description');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>4,
                      in_width    =>50,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_UOM_CAPTION,
                      in_data_tag    =>'cfg:units-of-measure');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>5,
                      in_width    =>70,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_QUANTITY_CAPTION,
                      in_data_tag    =>'cfg:quantity',
                      in_control_type=>14,
                      in_editable    =>YES_FLAG);

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>6,
                      in_width    =>70,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_UNIT_LIST_PRC_CAPTION,
                      in_data_tag    =>'cfg:list-price');

END create_OptionsGrid;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_SelectionsGrid
(in_parent_id  IN INTEGER,
 in_ui_def_id  IN INTEGER) IS

    Grid_Id   CZ_UI_NODES.ui_node_id%TYPE;
    Column_Id CZ_UI_NODES.ui_node_id%TYPE;

BEGIN

    Grid_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_GRID,
                      in_id       =>Grid_Id,
                      in_par_id   =>in_parent_id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>1,
                      in_width    =>100,
                      in_height   =>20,
                      in_caption  =>'',
                      in_alt_color=>'15201271',
                      in_hierarchy=>YES_FLAG);

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>1,
                      in_width    =>120,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_ITEM_CAPTION,
                      in_data_tag =>'cfg:name');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>2,
                      in_width    =>450,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_DESCRIPTION_CAPTION,
                      in_data_tag =>'cfg:description');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_COLUMN,
                      in_id       =>Column_Id,
                      in_par_id   =>Grid_Id,
                      in_def_id   =>in_ui_def_id,
                      in_tree_seq =>3,
                      in_width    =>50,
                      in_height   =>20,
                      in_caption  =>CZ_GRID_UOM_CAPTION,
                      in_data_tag =>'cfg:units-of-measure');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_COLUMN,
                      in_id          =>Column_Id,
                      in_par_id      =>Grid_Id,
                      in_def_id      =>in_ui_def_id,
                      in_tree_seq    =>4,
                      in_width       =>70,
                      in_height      =>20,
                      in_caption     =>CZ_GRID_QUANTITY_CAPTION,
                      in_data_tag    =>'cfg:quantity',
                      in_control_type=>-1,
                      in_editable    =>NO_FLAG);

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type =>DEF_COLUMN,
                      in_id      =>Column_Id,
                      in_par_id  =>Grid_Id,
                      in_def_id  =>in_ui_def_id,
                      in_tree_seq=>5,
                      in_width   =>70,
                      in_height  =>20,
                      in_caption =>CZ_GRID_UNIT_LIST_PRC_CAPTION,
                      in_data_tag =>'cfg:list-price');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type =>DEF_COLUMN,
                      in_id      =>Column_Id,
                      in_par_id  =>Grid_Id,
                      in_def_id  =>in_ui_def_id,
                      in_tree_seq=>6,
                      in_width   =>70,
                      in_height  =>20,
                      in_caption =>CZ_GRID_SELLING_PRC_CAPTION,
                      in_data_tag =>'cfg:net-price');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type =>DEF_COLUMN,
                      in_id      =>Column_Id,
                      in_par_id  =>Grid_Id,
                      in_def_id  =>in_ui_def_id,
                      in_tree_seq=>7,
                      in_width   =>80,
                      in_height  =>20,
                      in_caption =>CZ_GRID_EXTENDED_PRC_CAPTION,
                      in_data_tag =>'cfg:ext-price');

    Column_Id:=getUISeqVal;
    create_UI_element(in_ui_type =>DEF_COLUMN,
                      in_id      =>Column_Id,
                      in_par_id  =>Grid_Id,
                      in_def_id  =>in_ui_def_id,
                      in_tree_seq=>8,
                      in_width   =>70,
                      in_height  =>20,
                      in_caption =>CZ_AVAILABILITY_CAPTION,
                      in_data_tag =>'cfg:atp-date');

END create_SelectionsGrid;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_BOM_Tree
(in_product_id         IN INTEGER,
 in_model_tree_id      IN INTEGER,
 in_dataset_tree_id    IN INTEGER,
 in_ui_def_id          IN INTEGER,
 in_show_all_nodes     IN VARCHAR2, -- DEFAULT '0',
 in_use_labels         IN VARCHAR2  -- DEFAULT '1'
) IS

     new_id                CZ_UI_NODES.ui_node_id%TYPE;
     new_parent            CZ_UI_NODES.parent_id%TYPE;
     new_child             CZ_UI_NODES.ui_node_id%TYPE;
     var_ref_ui            CZ_UI_NODES.ui_def_ref_id%TYPE;
     new_ui_def_id         CZ_UI_NODES.ui_def_id%TYPE;
     new_node_ref_id       CZ_UI_NODES.ui_node_ref_id%TYPE;
     curr_node_id          CZ_UI_NODES.ui_node_id%TYPE;
     curr_label_id         CZ_UI_NODES.ui_node_id%TYPE;
     curr_bitmap_id        CZ_UI_NODES.ui_node_id%TYPE;
     curr_button_id        CZ_UI_NODES.ui_node_id%TYPE;
     var_comp_tree_id      CZ_UI_NODES.ui_node_id%TYPE;
     var_top_pos           CZ_UI_NODES.rel_top_pos%TYPE;
     var_ui_root_id        CZ_UI_NODES.ui_node_id%TYPE;
     default_PROD_TOP      CZ_UI_NODES.rel_top_pos%TYPE;
     default_PROD_LEFT     CZ_UI_NODES.rel_left_pos%TYPE;
     var_component_id      CZ_UI_NODES.component_id%TYPE;
     var_parent_id         CZ_UI_NODES.parent_id%TYPE;
     temp_node             CZ_UI_NODES.ps_node_id%TYPE;
     var_name              CZ_UI_NODES.name%TYPE;
     var_caption_name      CZ_INTL_TEXTS.text_str%TYPE;
     ind                   INTEGER;
     k                     INTEGER;

BEGIN

     new_ui_def_id:=in_ui_def_id;

     ERROR_CODE:='2001';
     curr_node_id:=getUISeqVal;
     Model_Id:=in_product_id;

     boms(in_product_id).id:=in_model_tree_id;
     boms(in_product_id).ps_node_id:=Model_Id;
     boms(in_product_id).parent_id:=NULL;

     ERROR_CODE:='2002';

     FOR i IN
     (SELECT ps_node_id,parent_id,ps_node_type,name,counted_options_flag,tree_seq,
             maximum,minimum,ui_omit,intl_text_id,reference_id FROM CZ_PS_NODES
      WHERE devl_project_id=Project_Id AND ps_node_type
      in (BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE,BOM_STANDART_NODE_TYPE,REFERENCE_NODE_TYPE)
      START WITH ps_node_id=in_product_id
      CONNECT BY PRIOR ps_node_id=parent_id AND (ui_omit=NO_FLAG OR in_show_all_nodes=YES_FLAG)
      AND deleted_flag=NO_FLAG)
      LOOP
         ERROR_CODE:='2003';

         IF i.intl_text_id IS NOT NULL AND in_use_labels<>'0' THEN
            BEGIN
            SELECT NVL(text_str,' ') INTO var_caption_name FROM CZ_INTL_TEXTS
            WHERE intl_text_id=i.intl_text_id;
            IF in_use_labels IN('2','3') THEN
               var_caption_name:=i.name||mCONCAT_SYMBOL||var_caption_name;
            END IF;

            -- if there is caption_id that does not point to CZ_INTL_TEXTS --
            -- then just ignore it and use name from PS tree               --
            EXCEPTION
            WHEN OTHERS THEN
                 var_caption_name:=i.name;
            END;
         END IF;

         ERROR_CODE:='2004';

         curr_node_id:=getUISeqVal;
         boms(i.ps_node_id).id:=curr_node_id;
         boms(i.ps_node_id).ps_node_id:=i.ps_node_id;
         boms(i.ps_node_id).parent_id:=i.parent_id;
         boms(i.ps_node_id).ps_node_type:=i.ps_node_type;
         boms(i.ps_node_id).name:=i.name;
         boms(i.ps_node_id).caption_name:=var_caption_name;
         boms(i.ps_node_id).tree_seq:=i.tree_seq;
         boms(i.ps_node_id).maximum:=i.maximum;
         boms(i.ps_node_id).minimum:=i.minimum;
         boms(i.ps_node_id).ui_omit:=i.ui_omit;
         boms(i.ps_node_id).intl_text_id:=i.intl_text_id;

         IF i.ps_node_type=REFERENCE_NODE_TYPE THEN
            BEGIN
            SELECT ps_node_id  INTO temp_node FROM CZ_PS_NODES
            WHERE devl_project_id=i.reference_id AND ps_node_type=BOM_MODEL_NODE_TYPE AND deleted_flag='0';
            boms(i.ps_node_id).reference_id:=i.reference_id;
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      boms(i.ps_node_id).ui_omit:=YES_FLAG;
            END;
         END IF;

         ERROR_CODE:='2005';

      END LOOP; -- for main LOOP

     /* *** main LOOP for UI creation *** */

     k:=boms.First;
     LOOP
         BEGIN
              IF boms(k).parent_id IS NOT NULL THEN
                 new_parent:=boms(boms(k).parent_id).id;           -- find new parent node id
              ELSE
                 new_parent:=in_model_tree_id;                     -- 1st Tree node reference to  Components Tree node
              END IF;
         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   new_parent:=in_model_tree_id;
         END;

         new_child:=boms(k).id;                               -- find new Tree node id
         curr_node_id:=getUISeqVal;

         IF boms(k).ps_node_type=BOM_MODEL_NODE_TYPE THEN

            var_top_pos:=DEFAULT_TOP_POS;

            set_UI_NODES(curr_node_id,in_dataset_tree_id,new_ui_def_id,boms(k).ps_node_id,
            NULL,boms(k).name,162,DEFAULT_BACKGROUND_COLOR,NULL,
            in_tree_display_flag=>YES_FLAG,
            in_tree_seq=>boms(k).tree_seq,
            in_use_default_font=>YES_FLAG,
            in_use_default_color=>YES_FLAG,
            in_use_default_pic=>YES_FLAG,
            in_top_pos =>0,
            in_left_pos=>0,
            in_width   =>100,
            in_height  =>20,
            in_font_name        =>DEFAULT_FONT_NAME,
            in_font_bold        =>NO_FLAG,
            in_font_color       =>0,
            in_font_italic      =>NO_FLAG,
            in_font_size        =>DEFAULT_FONT_SIZE,
            in_font_underline   =>NO_FLAG,
            in_intl_text_id     =>boms(k).intl_text_id);

            /* *** create record for Model Tree *** */
            set_UI_NODES(in_ui_node_id       =>new_child,
                         in_parent_id        =>new_parent,
                         in_ui_def_id        =>new_ui_def_id,
                         in_ps_node_id       =>boms(k).ps_node_id,
                         in_ui_node_ref_id   =>curr_node_id,
                         in_name             =>boms(k).name,
                         in_component_id     =>NULL,
                         in_ui_node_type     =>UI_APPLET_TREE_NODE_TYPE,
                         in_tree_display_flag=>NO_FLAG,
                         in_tree_seq         =>boms(k).tree_seq,
                         in_font_name        =>DEFAULT_FONT_NAME,
                         in_font_bold        =>NO_FLAG,
                         in_font_color       =>0,
                         in_font_italic      =>NO_FLAG,
                         in_font_size        =>DEFAULT_FONT_SIZE,
                         in_font_underline   =>NO_FLAG,
                         in_intl_text_id     =>boms(k).intl_text_id);

            /* *** create OPTION CLASESSES and STANDARTS for the screen *** */
            generate_MCS(boms(k).ps_node_id,curr_node_id,new_ui_def_id,'3');

         END IF; -- for BOM_MODEL

         IF boms(k).ps_node_type=REFERENCE_NODE_TYPE AND boms(k).ui_omit=NO_FLAG THEN

            /* *** create record for Model Tree *** */

            create_REFERENCE_Model(new_child,new_parent,new_ui_def_id,curr_node_id,boms(k),var_ref_ui);

         END IF; -- for REFERENCE

         IF boms(k).ps_node_type=BOM_CLASS_NODE_TYPE  AND (boms(k).ui_omit=NO_FLAG OR in_show_all_nodes=YES_FLAG) THEN

            var_top_pos:=DEFAULT_TOP_POS;

            set_UI_NODES(in_ui_node_id       =>curr_node_id,
                         in_parent_id        =>in_dataset_tree_id,
                         in_ui_def_id        =>new_ui_def_id,
                         in_ps_node_id       =>boms(k).ps_node_id,
                         in_ui_node_ref_id   =>NULL,
                         in_name             =>boms(k).name,
                         in_ui_node_type     =>162,
                         in_background_color =>DEFAULT_BACKGROUND_COLOR,
                         in_component_id     =>NULL,
                         in_width            =>100,
                         in_height           =>20,
                         in_lce_id           =>NULL,
                         in_tree_display_flag=>YES_FLAG,
                         in_tree_seq         =>boms(k).tree_seq,
                         in_use_default_font =>YES_FLAG,
                         in_use_default_color=>YES_FLAG,
                         in_use_default_pic  =>YES_FLAG,
                         in_top_pos          =>0,
                         in_left_pos         =>0,
                         in_font_name        =>DEFAULT_FONT_NAME,
                         in_font_bold        =>NO_FLAG,
                         in_font_color       =>0,
                         in_font_italic      =>NO_FLAG,
                         in_font_size        =>DEFAULT_FONT_SIZE,
                         in_font_underline   =>NO_FLAG,
                         in_intl_text_id     =>boms(k).intl_text_id);

            /* *** create record for Model Tree *** */
            set_UI_NODES(in_ui_node_id       =>new_child,
                         in_parent_id        =>new_parent,
                         in_ui_def_id        =>new_ui_def_id,
                         in_ps_node_id       =>boms(k).ps_node_id,
                         in_ui_node_ref_id   =>curr_node_id,
                         in_name             =>boms(k).name,
                         in_component_id     =>NULL,
                         in_ui_node_type     =>UI_APPLET_TREE_NODE_TYPE,
                         in_tree_display_flag=>NO_FLAG,
                         in_tree_seq         =>boms(k).tree_seq,
                         in_font_name        =>DEFAULT_FONT_NAME,
                         in_font_bold        =>NO_FLAG,
                         in_font_color       =>0,
                         in_font_italic      =>NO_FLAG,
                         in_font_size        =>DEFAULT_FONT_SIZE,
                         in_font_underline   =>NO_FLAG,
                         in_intl_text_id     =>boms(k).intl_text_id);

             generate_MCS(boms(k).ps_node_id,curr_node_id,new_ui_def_id,'3');

          END IF; -- for BOM classes

          k:=boms.NEXT(k);
          IF k IS NULL THEN
             EXIT;
          END IF;

     END LOOP;  -- main LOOP for creation
     ERROR_CODE:='2006';

END create_BOM_Tree;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE generate_BOM_UI
(in_product_id     IN  INTEGER,
 out_ui_def_id     OUT NOCOPY INTEGER,
 in_screen_width   IN  INTEGER , -- DEFAULT DEFAULT_TARGET_FRAME_WIDTH
 in_screen_height  IN  INTEGER , -- DEFAULT DEFAULT_TARGET_FRAME_HEIGHT
 in_show_all_nodes IN  VARCHAR2, -- DEFAULT '0'
 in_use_labels     IN  VARCHAR2  -- DEFAULT '1'
) IS


ref_id            INTEGER;
new_id            INTEGER;
new_parent        INTEGER;
new_child         INTEGER;
ind               INTEGER:=1;
new_ui_def_id     INTEGER;
new_node_ref_id   INTEGER;
curr_ui_node      INTEGER;
var_ui_root_id    INTEGER;
ui_product_id     INTEGER;

    var_ui_visible    CZ_PS_NODES.ui_omit%TYPE;

    FrameSet1_Id      CZ_UI_NODES.ui_node_id%TYPE;
    FrameSet2_Id      CZ_UI_NODES.ui_node_id%TYPE;
    FrameSet3_Id      CZ_UI_NODES.ui_node_id%TYPE;
    FrameSet4_Id      CZ_UI_NODES.ui_node_id%TYPE;
    FrameSet5_Id      CZ_UI_NODES.ui_node_id%TYPE;

    Frame1_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Frame2_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Frame3_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Frame4_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Frame5_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Frame6_Id         CZ_UI_NODES.ui_node_id%TYPE;

    Panel1_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Panel2_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Panel3_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Panel4_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Panel5_Id         CZ_UI_NODES.ui_node_id%TYPE;
    Panel51_Id        CZ_UI_NODES.ui_node_id%TYPE;
    Panel52_Id        CZ_UI_NODES.ui_node_id%TYPE;
    Panel53_Id        CZ_UI_NODES.ui_node_id%TYPE;

    FindControl_Id    CZ_UI_NODES.ui_node_id%TYPE;

    Text_Id           CZ_UI_NODES.ui_node_id%TYPE;
    TextControl_Id    CZ_UI_NODES.ui_node_id%TYPE;

    Button_Id         CZ_UI_NODES.ui_node_id%TYPE;
    TaggedValue_Id    CZ_UI_NODES.ui_node_id%TYPE;

    DataSet_Id        CZ_UI_NODES.ui_node_id%TYPE;
    ModelTree_Id      CZ_UI_NODES.ui_node_id%TYPE;
    temp_node         CZ_UI_NODES.ui_node_id%TYPE;

BEGIN

    Initialize;

    new_ui_def_id:=generate_UI_DEF;

    generateUIProperties(new_ui_def_id);

    UI_Product_Id:=getUISeqVal;

    IF MUID IS NOT NULL THEN
       temp_node:=currUISeqVal;
       set_UI_NODES(in_ui_node_id       =>temp_node,
                    in_parent_id        =>temp_node,
                    in_ui_def_id        =>MUID,
                    in_ps_node_id       =>NULL,
                    in_ui_node_ref_id   =>NULL,
                    in_name             =>'User Interfaces',
                    in_ui_node_type     =>51,
                    in_background_color =>DEFAULT_BACKGROUND_COLOR,
                    in_component_id     =>NULL,
                    in_width            =>100,
                    in_height           =>20,
                    in_tree_display_flag=>YES_FLAG,
                    in_use_default_font =>YES_FLAG,
                    in_use_default_pic  =>YES_FLAG,
                    in_use_default_color=>YES_FLAG,
                    in_tree_seq         =>-1);
    END IF;

    set_UI_NODES
    (in_ui_node_id       =>UI_Product_Id,
     in_parent_id        =>UI_Product_Id,
     in_ui_def_id        =>new_ui_def_id,
     in_ps_node_id       =>Model_Id,
     in_ui_node_ref_id   =>NULL,
     in_name             =>Model_Name||' User Interface',
     in_ui_node_type     =>UI_ROOT_SYSTEM_TYPE,
     in_background_color =>DEFAULT_BACKGROUND_COLOR,
     in_component_id     =>NULL,
     in_width            =>640,
     in_height           =>480,
     in_tree_display_flag=>YES_FLAG,
     in_use_default_font =>NO_FLAG,
     in_use_default_pic  =>NO_FLAG,
     in_use_default_color=>NO_FLAG,
     in_tree_seq         =>NULL);

    generateBOMUIProps(UI_Product_Id,new_ui_def_id,UI_ROOT_SYSTEM_TYPE,
                       NULL, NO_FLAG, NO_FLAG, NO_FLAG, NO_FLAG,
                       '10', '10', NULL, '-1', '15201271',
                       NULL, NO_FLAG, '-1', YES_FLAG, NO_FLAG, NULL);

    /***** Create FrameSet1 *********/

    FrameSet1_Id :=getUISeqVal;
    create_UI_element(in_ui_type       =>DEF_FRAMESET,
                      in_id            =>FrameSet1_Id,
                      in_par_id        =>UI_Product_Id,
                      in_def_id        =>new_ui_def_id,
                      in_width         =>100,
                      in_height        =>20,
                      in_tree_seq      =>1,
                      in_allocations   =>'48,*');

    Frame1_Id :=getUISeqVal;
    create_UI_element(in_ui_type       =>DEF_FRAME,
                      in_id            =>Frame1_Id,
                      in_par_id        =>FrameSet1_Id,
                      in_def_id        =>new_ui_def_id,
                      in_width         =>640,
                      in_height        =>48,
                      in_tree_seq      =>1,
                      in_system_frm    =>NO_FLAG,
                      in_margin_width  =>'10',
                      in_margin_height =>'10',
                      in_sizeable      =>NO_FLAG,
                      in_borders       =>NO_FLAG);

    Panel1_Id :=getUISeqVal;
    create_UI_element(in_ui_type      =>DEF_PANEL,
                      in_id           =>Panel1_Id,
                      in_par_id       =>Frame1_Id,
                      in_def_id       =>new_ui_def_id,
                      in_width        =>640,
                      in_height       =>48,
                      in_tree_seq     =>1);


    /* *********** Create Find Control ***************** */

    FindControl_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_FIND_CONTROL,
                      in_id       =>FindControl_Id,
                      in_par_id   =>Panel1_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>314,
                      in_height   =>41,
                      in_tree_seq =>1,
                      in_top_pos  =>9,
                      in_left_pos =>6);

    Text_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_TEXT,
                      in_id       =>Text_Id,
                      in_par_id   =>FindControl_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>42,
                      in_height   =>20,
                      in_tree_seq =>1,
                      in_caption  =>CZ_FIND_LABEL_CAPTION,
                      in_top_pos  =>6,
                      in_left_pos =>9);

    TextControl_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>117,
                      in_id       =>TextControl_Id,
                      in_par_id   =>FindControl_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>200,
                      in_height   =>19,
                      in_tree_seq =>2,
                      in_caption  =>'',
                      in_top_pos  =>6,
                      in_left_pos =>55);

    /* ************** Create <Go> Button ******************* */

    Button_Id :=getUISeqVal;
    create_UI_element(in_ui_type    =>DEF_BUTTON,
                      in_id         =>Button_Id,
                      in_par_id     =>FindControl_Id,
                      in_def_id     =>new_ui_def_id,
                      in_width      =>42,
                      in_height     =>23,
                      in_tree_seq   =>3,
                      in_caption    =>CZ_FIND_BUTTON_CAPTION,
                      in_top_pos    =>5,
                      in_left_pos   =>263,
                      in_action_type=>'-1',
                      in_action     =>'12');

    /* ************** Create label <Order Quantity:> **** */

    Text_Id :=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_TEXT,
                      in_id          =>Text_Id,
                      in_par_id      =>Panel1_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>35,
                      in_tree_seq    =>2,
                      in_caption     =>CZ_ORDER_QUANTITY_CAPTION,
                      in_top_pos     =>8,
                      in_left_pos    =>450);

    TaggedValue_Id :=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_TAGGED_VALUE,
                      in_id          =>TaggedValue_Id,
                      in_par_id      =>Panel1_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>70,
                      in_height      =>20,
                      in_tree_seq    =>3,
                      in_top_pos     =>16,
                      in_left_pos    =>550,
                      in_data_tag    =>'cfg:bom-initial-quantity');


    FrameSet2_Id :=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_FRAMESET,
                      in_Id          =>FrameSet2_Id,
                      in_par_id      =>FrameSet1_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>2,
                      in_allocations =>'100%,*');

    FrameSet3_Id:=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_FRAMESET,
                      in_id          =>FrameSet3_Id,
                      in_par_id      =>FrameSet2_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>1,
                      in_allocations =>'*,48');

    FrameSet4_Id :=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_FRAMESET,
                      in_id          =>FrameSet4_Id,
                      in_par_id      =>FrameSet3_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>1,
                      in_allocations =>'30%,*',
                      in_rowscols    =>'2');

    Frame2_Id:=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_FRAME,
                      in_id          =>Frame2_Id,
                      in_par_id      =>FrameSet4_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>1,
                      in_system_frm    =>NO_FLAG,
                      in_margin_width  =>'10',
                      in_margin_height =>'10',
                      in_sizeable      =>YES_FLAG,
                      in_borders       =>YES_FLAG);

    Panel2_Id :=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_PANEL,
                      in_id          =>Panel2_Id,
                      in_par_id      =>Frame2_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>1);


    ModelTree_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_MODELTREE,
                      in_id       =>ModelTree_Id,
                      in_par_id   =>Panel2_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>100,
                      in_height    =>20,
                      in_tree_seq =>2);


    FrameSet5_Id:=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_FRAMESET,
                      in_id          =>FrameSet5_Id,
                      in_par_id      =>FrameSet4_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>2,
                      in_allocations =>'60%,40%',
                      in_rowscols    =>YES_FLAG);

    Frame3_Id :=getUISeqVal;
    create_UI_element(in_ui_type      =>DEF_FRAME,
                      in_id           =>Frame3_Id,
                      in_par_id       =>FrameSet5_Id,
                      in_def_id       =>new_ui_def_id,
                      in_width        =>100,
                      in_height       =>20,
                      in_tree_seq     =>1,
                      in_system_frm   =>NO_FLAG,
                      in_margin_width =>'10',
                      in_margin_height=>'10',
                      in_sizeable     =>YES_FLAG,
                      in_borders      =>YES_FLAG);

    Panel3_Id :=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_PANEL,
                      in_id          =>Panel3_Id,
                      in_par_id      =>Frame3_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>1);

    create_OptionsGrid(in_parent_id=>Panel3_Id,in_ui_def_id=>new_ui_def_id);

    Frame4_Id :=getUISeqVal;
    create_UI_element(in_ui_type      =>DEF_FRAME,
                      in_id           =>Frame4_Id,
                      in_par_id       =>FrameSet5_Id,
                      in_def_id       =>new_ui_def_id,
                      in_width        =>100,
                      in_height       =>20,
                      in_tree_seq     =>2,
                      in_system_frm   =>NO_FLAG,
                      in_margin_width =>'10',
                      in_margin_height=>'10',
                      in_sizeable     =>YES_FLAG,
                      in_borders      =>YES_FLAG,
                      in_scrolling    =>NO_FLAG);

    Panel4_Id:=getUISeqVal;
    create_UI_element(in_ui_type     =>DEF_PANEL,
                      in_id          =>Panel4_Id,
                      in_par_id      =>Frame4_Id,
                      in_def_id      =>new_ui_def_id,
                      in_width       =>100,
                      in_height      =>20,
                      in_tree_seq    =>1);

    create_SelectionsGrid(in_parent_id=>Panel4_Id,in_ui_def_id=>new_ui_def_id);

    Frame5_Id :=getUISeqVal;
    create_UI_element(in_ui_type      =>DEF_FRAME,
                      in_id           =>Frame5_Id,
                      in_par_id       =>FrameSet3_Id,
                      in_def_id       =>new_ui_def_id,
                      in_width        =>640,
                      in_height       =>48,
                      in_tree_seq     =>2,
                      in_system_frm   =>NO_FLAG,
                      in_margin_width =>'10',
                      in_margin_height=>'10',
                      in_sizeable     =>NO_FLAG,
                      in_borders      =>NO_FLAG);

    Panel5_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_PANEL,
                      in_id       =>Panel5_Id,
                      in_par_id   =>Frame5_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>640,
                      in_height   =>48,
                      in_tree_seq =>1,
                      in_alt_color=>'15201271',
                      in_borders  =>NO_FLAG);

    /* *** Additional Panels *** */

    Panel51_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_PANEL,
                      in_id       =>Panel51_Id,
                      in_par_id   =>Panel5_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>212,
                      in_height   =>40,
                      in_tree_seq =>1,
                      in_alt_color=>'15201271',
                      in_borders  =>NO_FLAG,
                      in_top_pos  =>3,
                      in_left_pos =>8,
                      in_align    =>'left');

    Panel52_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_PANEL,
                      in_id       =>Panel52_Id,
                      in_par_id   =>Panel5_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>220,
                      in_height   =>40,
                      in_tree_seq =>2,
                      in_alt_color=>'15201271',
                      in_borders  =>NO_FLAG,
                      in_top_pos  =>3,
                      in_left_pos =>248,
                      in_align    =>'center');

    Panel53_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_PANEL,
                      in_id       =>Panel53_Id,
                      in_par_id   =>Panel5_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>130,
                      in_height   =>40,
                      in_tree_seq =>3,
                      in_alt_color=>'15201271',
                      in_borders  =>NO_FLAG,
                      in_top_pos  =>3,
                      in_left_pos =>505,
                      in_align    =>'right');

/* ************************ */

    Text_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_TEXT,
                      in_id       =>Text_Id,
                      in_par_id   =>Panel51_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>65,
                      in_height   =>35,
                      in_tree_seq =>1,
                      in_top_pos  =>3,
                      in_left_pos =>10,
                      in_caption  =>CZ_TOTAL_PRC_LABEL_CAPTION);

    TaggedValue_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_TAGGED_VALUE,
                      in_id       =>TaggedValue_Id,
                      in_par_id   =>Panel51_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>80,
                      in_height   =>20,
                      in_tree_seq =>2,
                      in_top_pos  =>11,
                      in_left_pos =>80,
                      in_data_tag =>'cfg:total-price',
                      in_borders  =>YES_FLAG);

    Button_Id:=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_BUTTON,
                      in_id       =>Button_Id,
                      in_par_id   =>Panel51_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>72,
                      in_height   =>28,
                      in_tree_seq =>3,
                      in_caption  =>CZ_UPDATE_BUTTON_CAPTION,
                      in_top_pos  =>7,
                      in_left_pos =>155,
                      in_action   =>'13',
                      in_borders  =>NO_FLAG,
                      in_picture  =>'czreload.gif');

    Text_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_TEXT,
                      in_id       =>Text_Id,
                      in_par_id   =>Panel52_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>65,
                      in_height   =>35,
                      in_tree_seq =>1,
                      in_top_pos  =>3,
                      in_left_pos =>10,
                      in_caption  =>'Availability:');

    TaggedValue_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_TAGGED_VALUE,
                      in_id       =>TaggedValue_Id,
                      in_par_id   =>Panel52_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>80,
                      in_height   =>20,
                      in_tree_seq =>2,
                      in_top_pos  =>11,
                      in_left_pos =>80,
                      in_data_tag =>'cfg:atp-rollup-date',
                      in_borders  =>YES_FLAG);

    Button_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_BUTTON,
                      in_id       =>Button_Id,
                      in_par_id   =>Panel52_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>72,
                      in_height   =>28,
                      in_tree_seq =>3,
                      in_caption  =>CZ_UPDATE_BUTTON_CAPTION,
                      in_top_pos  =>7,
                      in_left_pos =>155,
                      in_action   =>'11',
                      in_borders  =>NO_FLAG,
                      in_picture  =>'czreload.gif');

    Button_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_BUTTON,
                      in_id       =>Button_Id,
                      in_par_id   =>Panel53_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>72,
                      in_height   =>35,
                      in_tree_seq =>1,
                      in_caption  =>CZ_DONE_BUTTON_CAPTION,
                      in_top_pos  =>4,
                      in_left_pos =>1,
                      in_action   =>'9',
                      in_borders  =>NO_FLAG);

    Button_Id :=getUISeqVal;
    create_UI_element (in_ui_type =>DEF_BUTTON,
                       in_id      =>Button_Id,
                       in_par_id  =>Panel53_Id,
                       in_def_id  =>new_ui_def_id,
                       in_width   =>72,
                       in_height  =>35,
                       in_tree_seq=>2,
                       in_caption =>CZ_CANCEL_BUTTON_CAPTION,
                       in_top_pos =>4,
                       in_left_pos=>60,
                       in_action  =>'10',
                       in_borders =>NO_FLAG);

    Frame6_Id :=getUISeqVal;
    create_UI_element(in_ui_type      =>DEF_FRAME,
                      in_id           =>Frame6_Id,
                      in_par_id       =>FrameSet2_Id,
                      in_def_id       =>new_ui_def_id,
                      in_width        =>100,
                      in_height       =>20,
                      in_tree_seq     =>2,
                      in_system_frm   =>YES_FLAG,
                      in_margin_width =>'10',
                      in_margin_height=>'10',
                      in_sizeable     =>NO_FLAG,
                      in_borders      =>NO_FLAG);

    DataSet_Id :=getUISeqVal;
    create_UI_element(in_ui_type  =>DEF_DATASET,
                      in_id       =>DataSet_Id,
                      in_par_id   =>UI_Product_Id,
                      in_def_id   =>new_ui_def_id,
                      in_width    =>100,
                      in_height    =>20,
                      in_tree_seq =>2);

    create_BOM_Tree(in_product_id     =>in_product_id,
                    in_model_tree_id  =>ModelTree_Id,
                    in_dataset_tree_id=>DataSet_Id,
                    in_ui_def_id      =>new_ui_def_id,
                    in_show_all_nodes =>in_show_all_nodes,
                    in_use_labels     =>in_use_labels);

    UPDATE CZ_UI_NODES SET name=InterfaceName
    WHERE ui_node_id=parent_id AND ui_def_id=new_ui_def_id;

    out_ui_def_id:=new_ui_def_id;

END generate_BOM_UI;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE createUI
(in_product_id       IN  INTEGER,
 out_ui_def_id       OUT NOCOPY INTEGER,
 out_run_id          OUT NOCOPY INTEGER,
 in_ui_style         IN  VARCHAR2 , -- DEFAULT 'COMPONENTS',
 in_frame_allocation IN  INTEGER  , -- DEFAULT 30,
 in_width            IN  INTEGER  , -- DEFAULT 640,
 in_height           IN  INTEGER  , -- DEFAULT 480,
 in_show_all_nodes   IN  VARCHAR2 , -- DEFAULT '0',
 in_use_labels       IN  VARCHAR2 , -- DEFAULT '1',
 in_look_and_feel    IN  VARCHAR2 , -- DEFAULT 'BLAF',
 in_max_bom_per_page IN  INTEGER  , -- DEFAULT 10,
 in_wizard_style     IN  VARCHAR2   -- DEFAULT '0'
) IS

    var_num_products INTEGER;
    var_ui_def_id    INTEGER;
    var_reference_id INTEGER;
    var_run_id       INTEGER;

    curr_button_id   INTEGER;
    var_ui_root_id   INTEGER;
    var_top_pos      INTEGER;
    var_button_width INTEGER;
    var_max          INTEGER;
    var_min          INTEGER;
    out_instanciable INTEGER;
    var_ref_root_screen INTEGER;

    k                INTEGER;

    existsDeleteMe   VARCHAR2(1);
    var_virt_flag    VARCHAR2(1);
    var_wizard_style VARCHAR2(1):='0';

    NO_PROJECT       EXCEPTION;

BEGIN
    out_run_id:=0;
    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;

    mSHOW_ALL_NODES:=in_show_all_nodes;
    mITEMS_ON_PAGE:=in_max_bom_per_page;
    mWIZARD_STYLE:=in_wizard_style;

    Model_id:=in_product_id;
    Project_id:=in_product_id;

    BEGIN
        SELECT name INTO Model_Name FROM CZ_DEVL_PROJECTS
        WHERE devl_project_id=in_product_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RAISE NO_PROJECT;
    END;
    MODE_REFRESH:=FALSE;
    MUID:=NULL;

    mUSE_LABELS:=in_use_labels;
    IF in_use_labels='2' THEN
       mUSE_LABELS:='3';
    END IF;

    IF in_ui_style='COMPONENTS' OR in_ui_style=DHTML_STYLE_UI THEN
       mUI_STYLE:=DHTML_STYLE_UI;
       mLOOK_AND_FEEL:=in_look_and_feel;

       GLOBAL_FRAME_ALLOCATION:=in_frame_allocation;
       create_Component_Tree(in_product_id,out_ui_def_id,in_width,in_height,
                             in_show_all_nodes,in_use_labels);
       k:=NVL(UIS.Last,0)+1;
       UIS(k):=out_ui_def_id;
    ELSE
       cz_refs.SolutionBasedModelcheck(in_product_id,out_instanciable);
       IF out_instanciable>0 THEN
          out_ui_def_id:=0;
          out_run_id:=GLOBAL_RUN_ID;
          --LOG_REPORT('CZ_UI_GENERATOR.createUI',
          --'UI can not be generated for Model that has BOM instanciable parts.');
          FND_REPORT(CZ_UI_GEN_BOM_STYLE_FOR_IB, NULL, NULL, CZ_ERROR_URGENCY);
          RETURN;
       END IF;

       mUI_STYLE:=APPLET_STYLE_UI;
       mLOOK_AND_FEEL:='APPLET';
       Translate_Labels;
       generate_BOM_UI(in_product_id,out_ui_def_id,in_width,in_height,
                       in_show_all_nodes,in_use_labels);
     END IF;

    FOR i IN (SELECT ui_node_id,component_id,ui_def_ref_id,ps_node_id FROM CZ_UI_NODES
              WHERE ui_def_id=out_ui_def_id AND ui_def_ref_id IS NOT NULL
              AND ui_node_type=UI_REFERENCE_REF_TYPE
              AND deleted_flag='0' )
    LOOP
       --
       -- find devl_project_id of referenced Model
       --
       SELECT reference_id INTO var_reference_id FROM CZ_PS_NODES
       WHERE ps_node_id=i.component_id AND deleted_flag=NO_FLAG;

       --
       -- find latest UI of reference Model with the same UI type
       --
       SELECT MAX(ui_def_id) INTO var_ui_def_id FROM CZ_UI_DEFS
       WHERE component_id=var_reference_id AND ui_style=mUI_STYLE AND
       look_and_feel=mLOOK_AND_FEEL AND deleted_flag=NO_FLAG;

       BEGIN
           SELECT value_str INTO var_wizard_style FROM CZ_UI_NODE_PROPS
           WHERE ui_def_id=var_ui_def_id AND ui_node_id=
           (SELECT ui_node_id FROM CZ_UI_NODES WHERE ui_def_id=var_ui_def_id AND
           ui_node_id=parent_id AND deleted_flag=NO_FLAG) AND key_str='WizardStyle' AND
           deleted_flag=NO_FLAG;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                var_wizard_style:='0';
       END;
       --
       -- if there are node UIs in the referenced Model then create a new UI
       --
       IF var_ui_def_id IS NULL OR var_wizard_style<>in_wizard_style THEN
          createUI
          (var_reference_id,var_ui_def_id,out_run_id,in_ui_style,
           in_frame_allocation,in_width,in_height,
           in_show_all_nodes,in_use_labels,
           in_look_and_feel,
           in_max_bom_per_page,
           in_wizard_style);
       END IF;

       IF in_ui_style=DHTML_STYLE_UI THEN
          BEGIN
              SELECT ui_node_id INTO var_ref_root_screen FROM CZ_UI_NODES
              WHERE ui_def_id=var_ui_def_id AND ui_node_type=UI_SCREEN_TYPE
              AND ps_node_id=var_reference_id AND deleted_flag=NO_FLAG AND rownum<2;

              UPDATE CZ_UI_NODES SET ui_node_ref_id=var_ref_root_screen
              WHERE ui_def_id=out_ui_def_id AND ui_node_type=UI_BOM_STANDART_TYPE AND ps_node_id=i.ps_node_id
              AND deleted_flag=NO_FLAG;
          END;
       END IF;

       --
       -- update ui_def_ref_id of UI reference
       --
       UPDATE CZ_UI_NODES SET ui_def_ref_id=var_ui_def_id
       WHERE ui_node_id=i.ui_node_id;


       IF in_ui_style=DHTML_STYLE_UI THEN
          BEGIN
          existsDeleteMe:=NO_FLAG;
          SELECT YES_FLAG INTO existsDeleteMe FROM dual
          WHERE EXISTS(SELECT 1 FROM CZ_UI_NODES
          WHERE ui_def_id=var_ui_def_id AND ps_node_id=var_reference_id
          AND ui_node_type=UI_BUTTON_TYPE AND name=CZ_DELETE_BUTTON_CAPTION);
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   NULL;
          END;

          SELECT virtual_flag INTO var_virt_flag FROM CZ_PS_NODES
          WHERE ps_node_id=i.ps_node_id AND deleted_flag=NO_FLAG;

          IF existsDeleteMe=NO_FLAG AND var_virt_flag=NO_FLAG  THEN
             SELECT ui_node_id INTO var_ui_root_id FROM CZ_UI_NODES
             WHERE ui_def_id=var_ui_def_id AND ps_node_id=var_reference_id AND
             ui_node_type<>UI_COMPONENT_REF_TYPE AND ui_node_ref_id IS NOT NULL;

             curr_button_id:=getUISeqVal;
             create_BUTTON(curr_button_id,var_ui_root_id,var_ui_def_id,
                           var_reference_id,CZ_DELETE_BUTTON_CAPTION,
                           in_top_pos    =>DELETE_BUTTON_TOP_POS,
                           in_left_pos   =>DELETE_BUTTON_LEFT_POS,
                           in_button_type=>DEF_DELETE_BUTTON,
                           in_modified_flag    => 0);
          END IF;
       END IF;
    END LOOP;

EXCEPTION
    WHEN NO_PROJECT THEN
         out_run_id:=GLOBAL_RUN_ID;
         FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.createUI', CZ_ERROR_URGENCY);
         LOG_REPORT('CZ_UI_GENERATOR.createUI','There is no project with Project_Id='||TO_CHAR(in_product_id),
                    CZ_ERROR_URGENCY);
    WHEN NO_DATA_FOUND THEN
         out_run_id:=GLOBAL_RUN_ID;
         --LOG_REPORT('CZ_UI_GENERATOR.createUI','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
         FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.createUI', CZ_ERROR_URGENCY);
    WHEN OTHERS THEN
         out_run_id:=GLOBAL_RUN_ID;
         --LOG_REPORT('CZ_UI_GENERATOR.createUI','in_product_id='||TO_CHAR(in_product_id)||' : '||SQLERRM);
         FND_REPORT(CZ_UI_GEN_FATAL_ERR,TOKEN_SQLERRM,SQLERRM, CZ_ERROR_URGENCY);
END createUI;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE create_UI
(in_product_id       IN  INTEGER,
 in_ui_style         IN  VARCHAR2, -- DEFAULT 'COMPONENTS',
 in_show_all_nodes   IN  VARCHAR2, -- DEFAULT '0',
 in_frame_allocation IN  INTEGER , -- DEFAULT 30,
 in_width            IN  INTEGER , -- DEFAULT 640,
 in_height           IN  INTEGER , -- DEFAULT 480,
 in_use_labels       IN  VARCHAR2, -- DEFAULT '1',
 in_look_and_feel    IN  VARCHAR2, -- DEFAULT 'BLAF',
 in_max_bom_per_page IN  INTEGER , -- DEFAULT 10,
 in_wizard_style     IN  VARCHAR2  -- DEFAULT '0'
) IS

    var_root_id      INTEGER;
    var_num_products INTEGER;
    out_ui_def_id    INTEGER;
    var_run_id       INTEGER;

BEGIN
     createUI(in_product_id,out_ui_def_id,var_run_id,
              in_ui_style,in_frame_allocation,in_width,in_height,
              in_show_all_nodes,in_use_labels,in_look_and_feel,
              in_max_bom_per_page,in_wizard_style);
END create_UI;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION display_in_UI(in_ps_node_id IN INTEGER,in_parent_id IN INTEGER) RETURN VARCHAR2 IS
var_parent_id    INTEGER;
var_next_id      INTEGER;
var_ui_omit      INTEGER;
var_deleted_flag INTEGER;
curr_ps_node_id  INTEGER;
Flag             VARCHAR2(1):=NO_FLAG;

BEGIN
    BEGIN
        curr_ps_node_id:=in_parent_id;
        LOOP
           SELECT ui_omit,deleted_flag,parent_id INTO var_ui_omit,var_deleted_flag,var_next_id FROM CZ_PS_NODES
           WHERE ps_node_id=curr_ps_node_id;
           IF var_ui_omit=YES_FLAG OR var_deleted_flag=YES_FLAG THEN
              Flag:=YES_FLAG;
              EXIT;
           END IF;
           curr_ps_node_id:=var_next_id;
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --LOG_REPORT('CZ_UI_GENERATOR.display_in_UI','in_ps_node_id='||TO_CHAR(in_ps_node_id)||' : '||SQLERRM);
             NULL;
    END;

    RETURN Flag;

END display_in_UI;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION is_EqualPS
(in_ui_def_id  IN INTEGER,
 in_project_id IN INTEGER) RETURN BOOLEAN IS

    var_ui_id        INTEGER;
    var_parent_id    INTEGER;
    var_ps_id        INTEGER;
    var_ref_id       INTEGER;
    var_ui_type      INTEGER;
    var_limbo_id     INTEGER;
    var_ui_ref_id    INTEGER;
    var_curr_ui_id   INTEGER;
    new_parent_id    INTEGER;
    var_id           INTEGER;
    var_curr_id      INTEGER;
    var_temp         INTEGER;
    var_top_pos      INTEGER;
    var_old_tree_seq INTEGER;
    var_choose_conn  INTEGER;
    ind              INTEGER;
    ret              BOOLEAN:=TRUE;

    TYPE DragDropStructure   IS RECORD(new_parent_id  INTEGER,
                                       ui_ref_id      INTEGER,
                                       ps_node_id     INTEGER,
                                       parent_id      INTEGER,
                                       tree_seq       INTEGER,
                                       button_id      INTEGER);
    TYPE DragDropArray       IS TABLE OF DragDropStructure INDEX BY BINARY_INTEGER;

    movedReferences  DragDropArray;
    movedComponents  DragDropArray;
    movedFeatures    DragDropArray;
    movedOptions     DragDropArray;

BEGIN

    SELECT ui_node_id INTO var_limbo_id FROM CZ_UI_NODES
    WHERE ui_def_id=in_ui_def_id AND name='Limbo' AND deleted_flag=NO_FLAG;

    FOR i IN (SELECT ps_node_id,parent_id,ps_node_type,tree_seq FROM CZ_PS_NODES
              WHERE devl_project_id=in_project_id AND deleted_flag=NO_FLAG)
    LOOP
       var_choose_conn:=NULL;
       IF i.ps_node_type=REFERENCE_NODE_TYPE THEN
          BEGIN
              SELECT ui_node_id,parent_id INTO var_curr_ui_id,var_ui_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND parent_id<>var_limbo_id
              AND ps_node_id=i.ps_node_id AND ui_node_type=UI_REFERENCE_REF_TYPE AND deleted_flag=NO_FLAG;

              SELECT ui_node_ref_id INTO var_ref_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
              AND ui_node_id=var_ui_id;

              SELECT ps_node_id INTO var_ps_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
              AND ui_node_id=var_ref_id;

              IF var_ps_id<>i.parent_id AND var_ps_id IS NOT NULL THEN
                 SELECT ui_node_id INTO var_id FROM CZ_UI_NODES
                 WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.parent_id AND parent_id<>var_limbo_id AND ui_node_type IN
                 (UI_PRODUCT_TYPE,UI_COMPONENT_TYPE,UI_BOM_OPTION_CLASS_TYPE) AND deleted_flag=NO_FLAG;

                  SELECT ui_node_id INTO new_parent_id FROM CZ_UI_NODES
                  WHERE ui_node_ref_id=var_id AND parent_id<>var_limbo_id AND ui_node_type=UI_COMPONENT_REF_TYPE AND
                  ui_def_id=in_ui_def_id AND deleted_flag=NO_FLAG;

                  movedReferences(var_curr_ui_id).new_parent_id:=new_parent_id;
                  movedReferences(var_curr_ui_id).ps_node_id:=i.ps_node_id;
              END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   NULL;
              WHEN OTHERS THEN
                   NULL;
          END;
       END IF;

       IF i.ps_node_type IN (COMPONENT_NODE_TYPE,PRODUCT_NODE_TYPE,
          BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE) THEN

          BEGIN
              SELECT ui_node_id,tree_seq
              INTO var_ui_id,var_old_tree_seq
              FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
              AND parent_id<>var_limbo_id AND ps_node_id=i.ps_node_id
              AND ui_node_type IN (UI_PRODUCT_TYPE,UI_COMPONENT_TYPE)
              AND deleted_flag=NO_FLAG;

              SELECT ui_node_id,parent_id INTO var_curr_ui_id,var_parent_id FROM CZ_UI_NODES
              WHERE ui_node_ref_id=var_ui_id AND parent_id<>var_limbo_id AND ui_node_type NOT IN(UI_BUTTON_TYPE,UI_PICTURE_TYPE) AND
              ui_def_id=in_ui_def_id AND deleted_flag=NO_FLAG;

              BEGIN
                  SELECT ui_node_type INTO var_ui_type FROM CZ_UI_NODES WHERE
                  ui_node_id=var_parent_id AND ui_def_id=in_ui_def_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       NULL;
                  WHEN OTHERS THEN
                       NULL;
              END;

           IF var_ui_type<>143 THEN
              SELECT ui_node_ref_id INTO var_ref_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND
              ui_node_id=var_parent_id;
              SELECT ps_node_id INTO var_ps_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND
              ui_node_id=var_ref_id;

              IF (var_ps_id<>i.parent_id AND var_ps_id IS NOT NULL) THEN
                  --OR (var_old_tree_seq<>i.tree_seq*mMAX_NUMBER_PAGES AND var_old_tree_seq<>i.tree_seq) THEN --

                 SELECT ui_node_id INTO var_id FROM CZ_UI_NODES
                 WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.parent_id AND parent_id<>var_limbo_id AND ui_node_type IN
                 (UI_PRODUCT_TYPE,UI_COMPONENT_TYPE,UI_BOM_OPTION_CLASS_TYPE) AND deleted_flag=NO_FLAG;

                 SELECT ui_node_id INTO new_parent_id FROM CZ_UI_NODES
                 WHERE ui_node_ref_id=var_id AND parent_id<>var_limbo_id AND ui_node_type=UI_COMPONENT_REF_TYPE AND
                 ui_def_id=in_ui_def_id AND deleted_flag=NO_FLAG;

                 movedComponents(var_curr_ui_id).new_parent_id:=new_parent_id;
                 movedComponents(var_curr_ui_id).ps_node_id:=i.ps_node_id;
                 movedComponents(var_curr_ui_id).parent_id:=var_ref_id;
                 movedComponents(var_curr_ui_id).tree_seq:=i.tree_seq;
              END IF;
           END IF;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  NULL;
              WHEN OTHERS THEN
                  NULL;
         END;

     END IF;

     IF i.ps_node_type IN (FEATURE_NODE_TYPE,RESOURCE_NODE_TYPE,TOTAL_NODE_TYPE,CONNECTOR_NODE_TYPE) THEN

        BEGIN
            SELECT ui_node_id,parent_id,ui_node_ref_id,tree_seq
            INTO var_curr_ui_id,var_ui_id,var_ui_ref_id,var_old_tree_seq FROM CZ_UI_NODES
            WHERE ui_def_id=in_ui_def_id
            AND ps_node_id=i.ps_node_id AND parent_id<>var_limbo_id AND ui_node_type IN
            (UI_FEATURE_TYPE,UI_OPTION_TYPE,UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_CONNECTOR_TYPE)
            AND deleted_flag=NO_FLAG;

            IF i.ps_node_type=CONNECTOR_NODE_TYPE THEN
               BEGIN
                   SELECT ui_node_id INTO var_choose_conn
                   FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
                   AND parent_id<>var_limbo_id AND
                   ui_node_ref_id=var_curr_ui_id AND deleted_flag=NO_FLAG;
               EXCEPTION
                   WHEN OTHERS THEN
                        NULL;
               END;
            END IF;

            SELECT ps_node_id INTO var_ps_id FROM CZ_UI_NODES
            WHERE ui_node_id=var_ui_id AND ui_def_id=in_ui_def_id  AND deleted_flag=NO_FLAG;

            IF (var_ps_id<>i.parent_id AND var_ps_id IS NOT NULL) THEN
               SELECT ui_node_id INTO new_parent_id FROM CZ_UI_NODES
               WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.parent_id AND parent_id<>var_limbo_id AND ui_node_type IN
               (UI_COMPONENT_TYPE) AND deleted_flag=NO_FLAG;

               movedFeatures(var_curr_ui_id).new_parent_id:=new_parent_id;
               movedFeatures(var_curr_ui_id).ui_ref_id:=var_ui_ref_id;
               movedFeatures(var_curr_ui_id).tree_seq:=i.tree_seq;

               IF var_choose_conn IS NOT NULL THEN
                  movedFeatures(var_curr_ui_id).button_id:=var_choose_conn;
               END IF;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 NULL;
            WHEN OTHERS THEN
                 NULL;
        END;

     END IF;

     IF i.ps_node_type IN(OPTION_NODE_TYPE) THEN
        BEGIN
            SELECT ui_node_id,parent_id,tree_seq
            INTO var_curr_ui_id,var_ui_id,var_old_tree_seq FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
            AND ps_node_id=i.ps_node_id AND parent_id<>var_limbo_id AND
            ui_node_type IN (UI_OPTION_TYPE,UI_BOM_STANDART_TYPE) AND deleted_flag=NO_FLAG;

            SELECT ps_node_id INTO var_ps_id FROM CZ_UI_NODES
            WHERE ui_node_id=var_ui_id AND ui_def_id=in_ui_def_id  AND deleted_flag=NO_FLAG;

            IF (var_ps_id<>i.parent_id AND var_ps_id IS NOT NULL) THEN
               SELECT ui_node_id INTO new_parent_id FROM CZ_UI_NODES
               WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.parent_id AND parent_id<>var_limbo_id AND ui_node_type IN
               (UI_FEATURE_TYPE) AND deleted_flag=NO_FLAG;

                movedOptions(var_curr_ui_id).new_parent_id:=new_parent_id;
                movedOptions(var_curr_ui_id).tree_seq:=i.tree_seq;
            END IF;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
           WHEN OTHERS THEN
                NULL;
       END;
     END IF;

   END LOOP;

   IF movedReferences.Count>0 THEN
      ind:=movedReferences.First;
      LOOP
         UPDATE CZ_UI_NODES SET parent_id=movedReferences(ind).new_parent_id
         WHERE ui_def_id=in_ui_def_id
         AND ui_node_id=ind AND ui_node_type=UI_REFERENCE_REF_TYPE AND
         parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

         SELECT ui_node_ref_id INTO var_id FROM CZ_UI_NODES
         WHERE ui_def_id=in_ui_def_id AND ui_node_id=movedReferences(ind).new_parent_id AND
         parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

         var_top_pos:=getNextY(in_ui_def_id,var_id);

         UPDATE CZ_UI_NODES SET parent_id=var_id,rel_top_pos=var_top_pos
         WHERE ui_def_id=in_ui_def_id
         AND ps_node_id=movedReferences(ind).ps_node_id AND ui_node_type=UI_BUTTON_TYPE
         AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

         ind:=movedReferences.NEXT(ind);
         IF ind IS NULL THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   IF movedComponents.Count>0 THEN
      ind:=movedComponents.First;
      LOOP
         UPDATE CZ_UI_NODES
         SET parent_id=movedComponents(ind).new_parent_id,
             tree_seq=movedComponents(ind).tree_seq
         WHERE ui_def_id=in_ui_def_id
         AND ui_node_id=ind AND ui_node_type=UI_COMPONENT_REF_TYPE AND
         deleted_flag=NO_FLAG;
         BEGIN
             SELECT ui_node_ref_id INTO var_id FROM CZ_UI_NODES
             WHERE ui_def_id=in_ui_def_id AND ui_node_id=movedComponents(ind).new_parent_id AND
             parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  NULL;
             WHEN OTHERS THEN
                  NULL;
         END;

         var_top_pos:=getNextY(in_ui_def_id,var_id);

         UPDATE CZ_UI_NODES SET parent_id=var_id,rel_top_pos=var_top_pos
         WHERE ui_def_id=in_ui_def_id AND parent_id=movedComponents(ind).parent_id
         AND ps_node_id=movedComponents(ind).ps_node_id AND ui_node_type=UI_BUTTON_TYPE
         AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

         ind:=movedComponents.NEXT(ind);
         IF ind IS NULL THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   IF movedFeatures.Count>0 THEN
      ind:=movedFeatures.First;
      LOOP

         var_top_pos:=getNextY(in_ui_def_id,movedFeatures(ind).new_parent_id);

         UPDATE CZ_UI_NODES
         SET parent_id=movedFeatures(ind).new_parent_id,
             rel_top_pos=var_top_pos,
             tree_seq=movedFeatures(ind).tree_seq
         WHERE ui_def_id=in_ui_def_id
         AND ui_node_id=ind AND ui_node_type IN(UI_FEATURE_TYPE,UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_CONNECTOR_TYPE) AND
         deleted_flag=NO_FLAG;

         UPDATE CZ_UI_NODES SET parent_id=movedFeatures(ind).new_parent_id,rel_top_pos=var_top_pos
         WHERE ui_def_id=in_ui_def_id
         AND ui_node_id=movedFeatures(ind).ui_ref_id AND ui_node_type=UI_TEXT_LABEL_TYPE AND
         deleted_flag=NO_FLAG;

         IF movedFeatures(ind).button_id IS NOT NULL THEN
            UPDATE CZ_UI_NODES
            SET parent_id=movedFeatures(ind).new_parent_id,
                rel_top_pos=var_top_pos
            WHERE ui_def_id=in_ui_def_id
            AND ui_node_id=movedFeatures(ind).button_id AND ui_node_type=UI_BUTTON_TYPE AND
            deleted_flag=NO_FLAG;
         END IF;

         ind:=movedFeatures.NEXT(ind);
         IF ind IS NULL THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   IF movedOptions.Count>0 THEN
      ind:=movedOptions.First;
      LOOP
         UPDATE CZ_UI_NODES
         SET parent_id=movedOptions(ind).new_parent_id,
             tree_seq=movedOptions(ind).tree_seq
         WHERE ui_def_id=in_ui_def_id
         AND ui_node_id=ind AND ui_node_type=UI_OPTION_TYPE AND
         deleted_flag=NO_FLAG;

         ind:=movedOptions.NEXT(ind);
         IF ind IS NULL THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   IF movedReferences.Count>0 OR movedComponents.Count>0 OR movedFeatures.Count>0 THEN
      ret:=FALSE;
   END IF;

   RETURN ret;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN ret;
   WHEN OTHERS THEN
        --LOG_REPORT('CZ_UI_GENERATOR.is_EqualPS','ui_def_id='||TO_CHAR(in_ui_def_id)||' : '||SQLERRM);
        RETURN ret;
END is_EqualPS;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE  clone_it
(in_old_def_id   IN  INTEGER,
 in_new_def_id   IN  INTEGER,
 in_project_id   IN  INTEGER,
 in_replace_flag IN VARCHAR2 -- DEFAULT NO_FLAG
) IS

    TYPE Map_Table IS TABLE OF CZ_UI_NODES.NAME%TYPE INDEX BY VARCHAR2(15);
    Map              Map_Table;
    new_ui_def_id    INTEGER;
    var_id           INTEGER;
    var_ui_type      INTEGER;
    var_id_          INTEGER;
    var_ui_type_     INTEGER;
    var_parent_id    INTEGER;
    var_ui_ref_id    INTEGER;
    var_new_button   INTEGER;
    var_parent_tb_id INTEGER;
    var_ps_node_id   INTEGER;
    var_err          INTEGER;
    new_ui_node_id   INTEGER;
    new_caption_id   INTEGER;
    var_old_limbo_id INTEGER;
    var_new_limbo_id INTEGER;
    var_old_id       CZ_UI_NODES%ROWTYPE;
    var_new_id       CZ_UI_NODES%ROWTYPE;
    var_header       CZ_UI_NODES%ROWTYPE;
    var_ui_name      CZ_UI_DEFS.name%TYPE;
    var_name         CZ_UI_NODES.name%TYPE;
    END_OPERATION    EXCEPTION;

BEGIN
    IF in_replace_flag=YES_FLAG THEN
       SELECT name INTO var_ui_name FROM CZ_UI_DEFS WHERE ui_def_id=in_old_def_id;
       UPDATE CZ_UI_DEFS SET deleted_flag=YES_FLAG WHERE ui_def_id=in_old_def_id;
       UPDATE CZ_UI_DEFS SET name=var_ui_name WHERE ui_def_id=in_new_def_id;
       UPDATE CZ_UI_NODES SET name=var_ui_name WHERE ui_node_id=parent_id AND ui_def_id=in_new_def_id;
       UPDATE CZ_UI_NODES SET ui_def_ref_id=in_new_def_id WHERE ui_def_ref_id=in_old_def_id;
    END IF;

    SELECT ui_node_id INTO var_old_limbo_id FROM CZ_UI_NODES
    WHERE ui_def_id=in_old_def_id AND name='Limbo' AND deleted_flag=NO_FLAG;

    SELECT ui_node_id INTO var_new_limbo_id FROM CZ_UI_NODES
    WHERE ui_def_id=in_new_def_id AND name='Limbo' AND deleted_flag=NO_FLAG;

    UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG WHERE ui_def_id=in_new_def_id
    AND ui_node_type=UI_BUTTON_TYPE;

    SELECT * INTO var_header FROM CZ_UI_NODES WHERE ui_def_id=in_old_def_id AND
    ui_node_type=UI_ROOT_SYSTEM_TYPE AND deleted_flag=NO_FLAG;
    UPDATE CZ_UI_NODES
    SET    FONTBOLD=var_header.FONTBOLD,
           FONTCOLOR=var_header.FONTCOLOR,
           FONTITALIC=var_header.FONTITALIC,
           FONTUNDERLINE=var_header.FONTUNDERLINE,
           FONTSIZE=var_header.FONTSIZE,
           FONTNAME=var_header.FONTNAME,
           BACKGROUNDSTYLE=var_header.BACKGROUNDSTYLE,
           BACKGROUNDPICTURE=var_header.BACKGROUNDPICTURE,
           DEFAULT_BKGRND_COLOR_FLAG=var_header.DEFAULT_BKGRND_COLOR_FLAG,
           DEFAULT_BKGRND_PICTURE_FLAG=var_header.DEFAULT_BKGRND_PICTURE_FLAG,
           DEFAULT_FONT_FLAG=var_header.DEFAULT_FONT_FLAG
    WHERE ui_def_id=in_new_def_id AND ui_node_type=UI_ROOT_SYSTEM_TYPE AND deleted_flag=NO_FLAG;

    FOR i IN(SELECT ui_node_id,parent_id,ps_node_id,ui_node_ref_id,ui_node_type,name
             FROM CZ_UI_NODES WHERE ui_def_id=in_old_def_id
             AND deleted_flag=NO_FLAG)
    LOOP
       IF i.parent_id=var_old_limbo_id THEN
          UPDATE CZ_UI_NODES SET parent_id=var_new_limbo_id WHERE
          ui_def_id=in_new_def_id AND ps_node_id=i.ps_node_id AND ui_node_type=i.ui_node_type
          AND deleted_flag=NO_FLAG;
       END IF;
       IF i.ui_node_type IN(UI_PRODUCT_TYPE,UI_COMPONENT_TYPE,UI_FEATURE_TYPE,UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_BOM_STANDART_TYPE)
          AND i.ps_node_id IS NOT NULL AND i.ui_node_ref_id IS NOT NULL AND i.parent_id<>var_old_limbo_id THEN

          SELECT name INTO var_name FROM CZ_UI_NODES WHERE ui_def_id=in_old_def_id
          AND ui_node_id=i.ui_node_ref_id;
          Map(i.ps_node_id):=var_name;
       END IF;
    END LOOP;

    UPDATE CZ_UI_NODES SET parent_id=var_new_limbo_id WHERE
    ui_def_id=in_new_def_id AND ui_node_ref_id IN(SELECT ui_node_id FROM CZ_UI_NODES
    WHERE ui_def_id=in_new_def_id AND parent_id=var_new_limbo_id) AND ui_node_type=UI_COMPONENT_REF_TYPE;

    FOR i IN(SELECT ps_node_id FROM CZ_PS_NODES WHERE devl_project_id=in_project_id AND
             ps_node_type IN(PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,
             BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE) AND deleted_flag=NO_FLAG)
    LOOP
       UPDATE CZ_UI_NODES SET deleted_flag='1' WHERE ui_def_id=in_new_def_id AND
       parent_id IN(SELECT ui_node_id FROM CZ_UI_NODES WHERE ps_node_id=i.ps_node_id
       AND ui_node_type IN(UI_PRODUCT_TYPE,UI_COMPONENT_TYPE) AND deleted_flag=NO_FLAG)
       AND ui_node_type NOT IN(UI_FEATURE_TYPE,UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_BOM_STANDART_TYPE)
       AND parent_id<>var_new_limbo_id;
    END LOOP;

    FOR i IN(SELECT * FROM CZ_PS_NODES WHERE devl_project_id=in_project_id AND deleted_flag=NO_FLAG)
    LOOP
       IF i.ps_node_type IN (PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,BOM_MODEL_NODE_TYPE,
          BOM_CLASS_NODE_TYPE) THEN
          BEGIN
              SELECT * INTO var_old_id FROM CZ_UI_NODES WHERE ui_def_id=in_old_def_id
              AND ps_node_id=i.ps_node_id AND ui_node_type IN(UI_PRODUCT_TYPE,UI_COMPONENT_TYPE) AND
              parent_id <> var_old_limbo_id AND deleted_flag=NO_FLAG;

              SELECT * INTO var_new_id FROM CZ_UI_NODES WHERE ui_def_id=in_new_def_id
              AND ps_node_id=i.ps_node_id AND ui_node_type IN(UI_PRODUCT_TYPE,UI_COMPONENT_TYPE) AND
              parent_id<>var_new_limbo_id AND deleted_flag=NO_FLAG;

              FOR k IN(SELECT * FROM CZ_UI_NODES WHERE ui_def_id=in_old_def_id
                       AND parent_id=var_old_id.ui_node_id AND parent_id<>var_old_limbo_id
                       AND ui_node_type NOT IN(UI_FEATURE_TYPE,UI_RESOURCE_TYPE,
                       UI_TOTAL_TYPE,UI_BOM_STANDART_TYPE) AND deleted_flag=NO_FLAG)
              LOOP
                 BEGIN
                     new_ui_node_id:=getUISeqVal;
                     new_caption_id:=getTXTSeqVal;

                     INSERT INTO CZ_INTL_TEXTS(intl_text_id,text_str,ui_def_id,model_id,deleted_flag)
                     SELECT new_caption_id,text_str,in_new_def_id,in_project_id,'0' FROM CZ_INTL_TEXTS
                     WHERE intl_text_id=(SELECT caption_id FROM CZ_UI_NODES
                     WHERE ui_def_id=in_old_def_id AND ui_node_id=k.ui_node_id);

                     INSERT INTO CZ_UI_NODES
                            (ui_node_id,
                            parent_id,
                            ui_def_id,
                            ps_node_id,
                            ui_node_ref_id,
                            name,caption_id,tool_tip_id,ui_node_type,background_color,
                            component_id,width,height,lce_identifier,
                            tree_display_flag,tree_seq,
                            default_font_flag,default_bkgrnd_color_flag,
                            default_bkgrnd_picture_flag,modified_flags,tab_order,
                            rel_top_pos,rel_left_pos,
                            deleted_flag,
                            fontbold,fontcolor,fontunderline,fontsize,fontname,
                            backgroundstyle,controltype,backgroundpicture,borders,picturename,func_comp_id)
                     SELECT new_ui_node_id,var_new_id.ui_node_id,in_new_def_id,ps_node_id,ui_node_ref_id,
                            name,new_caption_id,tool_tip_id,ui_node_type,background_color,component_id,width,height,lce_identifier,
                            tree_display_flag,tree_seq,
                            default_font_flag,default_bkgrnd_color_flag,default_bkgrnd_picture_flag,
                            NO_FLAG,NO_FLAG,rel_top_pos,rel_left_pos,NO_FLAG,
                            fontbold,fontcolor,fontunderline,fontsize,fontname,
                            backgroundstyle,controltype,backgroundpicture,borders,picturename,func_comp_id
                     FROM CZ_UI_NODES WHERE ui_def_id=in_old_def_id AND ui_node_id=k.ui_node_id;

                     INSERT INTO CZ_UI_NODE_PROPS(ui_def_id,ui_node_id,key_str,value_str,deleted_flag)
                     SELECT in_new_def_id,new_ui_node_id,key_str,value_str,'0' FROM CZ_UI_NODE_PROPS
                     WHERE ui_def_id=in_old_def_id AND ui_node_id=k.ui_node_id;

                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          NULL;
                     WHEN OTHERS THEN
                          NULL;
                 END;
              END LOOP;

              UPDATE CZ_UI_NODES
              SET
              REL_TOP_POS=var_old_id.REL_TOP_POS,
              REL_LEFT_POS=var_old_id.REL_LEFT_POS,
              CAPTION_ID=var_old_id.CAPTION_ID,
              WIDTH=var_old_id.WIDTH,
              HEIGHT=var_old_id.HEIGHT,
              FONTBOLD=var_old_id.FONTBOLD,
              FONTCOLOR=var_old_id.FONTCOLOR,
              FONTITALIC=var_old_id.FONTITALIC,
              FONTUNDERLINE=var_old_id.FONTUNDERLINE,
              FONTSIZE=var_old_id.FONTSIZE,
              FONTNAME=var_old_id.FONTNAME,
              BACKGROUNDSTYLE=var_old_id.BACKGROUNDSTYLE,
              BACKGROUNDPICTURE=var_old_id.BACKGROUNDPICTURE,
              BORDERS=var_old_id.BORDERS,
              PICTURENAME=var_old_id.PICTURENAME,
              MODIFIED_FLAGS=var_old_id.MODIFIED_FLAGS,
              DEFAULT_BKGRND_COLOR_FLAG=var_old_id.DEFAULT_BKGRND_COLOR_FLAG,
              DEFAULT_BKGRND_PICTURE_FLAG=var_old_id.DEFAULT_BKGRND_PICTURE_FLAG,
              DEFAULT_FONT_FLAG=var_old_id.DEFAULT_FONT_FLAG
              WHERE ui_node_id=var_new_id.ui_node_id;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;
          WHEN OTHERS THEN
               NULL;
          END;
       END IF;

       IF i.ps_node_type IN (FEATURE_NODE_TYPE,RESOURCE_NODE_TYPE,
          TOTAL_NODE_TYPE,BOM_MODEL_NODE_TYPE) THEN
          BEGIN
              SELECT * INTO var_old_id FROM CZ_UI_NODES WHERE ui_def_id=in_old_def_id
              AND ps_node_id=i.ps_node_id AND ui_node_type IN(UI_FEATURE_TYPE,UI_RESOURCE_TYPE,
              UI_TOTAL_TYPE,UI_BOM_STANDART_TYPE)
              AND parent_id<>var_old_limbo_id AND deleted_flag=NO_FLAG;

              SELECT * INTO var_new_id FROM CZ_UI_NODES WHERE ui_def_id=in_new_def_id
              AND ps_node_id=i.ps_node_id AND ui_node_type IN(UI_FEATURE_TYPE,UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_BOM_STANDART_TYPE)
              AND parent_id<>var_new_limbo_id AND deleted_flag=NO_FLAG;

              UPDATE CZ_UI_NODES
              SET
              REL_TOP_POS=var_old_id.REL_TOP_POS,
              REL_LEFT_POS=var_old_id.REL_LEFT_POS,
              CAPTION_ID=var_old_id.CAPTION_ID,
              WIDTH=var_old_id.WIDTH,
              HEIGHT=var_old_id.HEIGHT,
              FONTBOLD=var_old_id.FONTBOLD,
              FONTCOLOR=var_old_id.FONTCOLOR,
              FONTITALIC=var_old_id.FONTITALIC,
              FONTUNDERLINE=var_old_id.FONTUNDERLINE,
              FONTSIZE=var_old_id.FONTSIZE,
              FONTNAME=var_old_id.FONTNAME,
              BACKGROUNDSTYLE=var_old_id.BACKGROUNDSTYLE,
              BACKGROUNDPICTURE=var_old_id.BACKGROUNDPICTURE,
              BORDERS=var_old_id.BORDERS,
              PICTURENAME=var_old_id.PICTURENAME,
              MODIFIED_FLAGS=var_old_id.MODIFIED_FLAGS,
              DEFAULT_BKGRND_COLOR_FLAG=var_old_id.DEFAULT_BKGRND_COLOR_FLAG,
              DEFAULT_BKGRND_PICTURE_FLAG=var_old_id.DEFAULT_BKGRND_PICTURE_FLAG,
              DEFAULT_FONT_FLAG=var_old_id.DEFAULT_FONT_FLAG
              WHERE ui_node_id=var_new_id.ui_node_id;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;
          WHEN OTHERS THEN
               NULL;
          END;
       END IF;
    END LOOP;

    FOR i IN(SELECT ui_node_id,parent_id,ui_node_ref_id,ps_node_id,ui_node_type,name
          FROM CZ_UI_NODES WHERE ui_def_id=in_new_def_id
          AND ui_node_type IN(UI_PRODUCT_TYPE,UI_COMPONENT_TYPE,
          UI_FEATURE_TYPE,UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_BOM_STANDART_TYPE)
          AND ui_node_ref_id IS NOT NULL AND
          parent_id<>var_new_limbo_id AND deleted_flag=NO_FLAG)
    LOOP
       BEGIN
           var_name:=Map(i.ps_node_id);
           IF i.ui_node_type IN(UI_PRODUCT_TYPE,UI_COMPONENT_TYPE) THEN
              FOR n IN(SELECT ui_node_id FROM CZ_UI_NODES
                       WHERE ui_def_id=in_new_def_id AND parent_id=i.ui_node_id AND
                       name=var_name AND ui_node_type=UI_TEXT_LABEL_TYPE AND
                       parent_id<>var_new_limbo_id AND deleted_flag=NO_FLAG)
              LOOP
                 UPDATE CZ_UI_NODES
                 SET ui_node_ref_id=n.ui_node_id
                 WHERE ui_def_id=in_new_def_id
                 AND ui_node_id=i.ui_node_id;
              END LOOP;
           END IF;

           IF i.ui_node_type IN(UI_FEATURE_TYPE,UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_BOM_STANDART_TYPE) THEN
              FOR n IN(SELECT ui_node_id FROM CZ_UI_NODES
                       WHERE ui_def_id=in_new_def_id AND parent_id=i.parent_id AND
                       name=var_name AND ui_node_type=UI_TEXT_LABEL_TYPE AND
                       parent_id<>var_new_limbo_id AND deleted_flag=NO_FLAG)
              LOOP
                 UPDATE CZ_UI_NODES
                 SET ui_node_ref_id=n.ui_node_id
                 WHERE ui_def_id=in_new_def_id
                 AND ui_node_id=i.ui_node_id;
              END LOOP;
           END IF;
       EXCEPTION
          WHEN OTHERS THEN
               NULL;
       END;
   END LOOP;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        LOG_REPORT('CZ_UI_GENERATOR.clone_it','ui_def_id='||TO_CHAR(in_new_def_id)||' : '||SQLERRM,
                   CZ_ERROR_URGENCY);
        --FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.clone_it');
   WHEN OTHERS THEN
        LOG_REPORT('CZ_UI_GENERATOR.clone_it','ui_def_id='||TO_CHAR(in_new_def_id)||' : '||SQLERRM,
                   CZ_ERROR_URGENCY);
        --FND_REPORT(CZ_UI_GEN_FATAL_ERR,TOKEN_SQLERRM,SQLERRM);
END clone_it;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_UI_NODES
(in_project_id IN INTEGER,
 in_ui_def_id  IN INTEGER) IS

BEGIN

    --
    -- deleting nodes from PS Tree case --
    --
    FOR i IN (SELECT ps_node_id FROM CZ_PS_NODES
              WHERE devl_project_id=in_project_id
              AND (deleted_flag=YES_FLAG OR (ui_omit=YES_FLAG AND mSHOW_ALL_NODES='0')))
    LOOP
       --
       -- remove an associated buttons and references --
       --
       UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG WHERE
       ps_node_id=i.ps_node_id AND ui_node_type IN (UI_BUTTON_TYPE,UI_PICTURE_TYPE,UI_REFERENCE_REF_TYPE)
       AND ui_def_id=in_ui_def_id;

       --
       -- remove UI subtrees --
       --
       FOR l IN (SELECT ui_node_id,ps_node_id,ui_node_ref_id,ui_node_type FROM CZ_UI_NODES
                 WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.ps_node_id AND ui_node_type NOT IN(UI_BUTTON_TYPE,
                 UI_REFERENCE_REF_TYPE) AND deleted_flag=NO_FLAG)
       LOOP
          remove_UI_Subtree(l.ui_node_id,l.ui_node_type);
       END LOOP;
    END LOOP;

    FOR i IN(SELECT b.ui_node_id FROM CZ_PS_NODES a,CZ_UI_NODES b
             WHERE b.ui_def_id=in_ui_def_id AND a.ps_node_id=b.ps_node_id
             AND a.ps_node_type=437 AND b.ui_node_type=UI_BOM_OPTION_CLASS_TYPE AND b.page_number<>1 AND
             NOT EXISTS(SELECT NULL FROM  CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
             AND parent_id=b.ui_node_id AND ui_node_type=UI_BOM_STANDART_TYPE AND deleted_flag=NO_FLAG))
    LOOP
       UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG
       WHERE ui_def_id=in_ui_def_id AND ui_node_id=i.ui_node_id;
       UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG
       WHERE ui_def_id=in_ui_def_id AND ui_node_ref_id=i.ui_node_id;
    END LOOP;

END delete_UI_NODES;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

   FUNCTION getUseLabelsProperty(p_ui_node_id IN NUMBER ,p_property_name IN VARCHAR2) RETURN VARCHAR2 IS

       v_use_labels CZ_UI_NODE_PROPS.value_str%TYPE:='1';

   BEGIN
       SELECT value_str INTO v_use_labels FROM CZ_UI_NODE_PROPS
       WHERE ui_node_id=p_ui_node_id AND key_str=p_property_name AND deleted_flag='0';
       RETURN v_use_labels;
   EXCEPTION
       WHEN OTHERS THEN
            RETURN v_use_labels;
   END getUseLabelsProperty;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

   FUNCTION get_Property_Value(p_node_id     IN cz_ps_nodes.ps_node_id%TYPE,
                               p_property_id IN cz_properties.property_id%TYPE,
                               p_item_id     IN cz_item_masters.item_id%TYPE)
     RETURN VARCHAR2 IS
       TYPE tStringArray IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
       v_def_value       cz_properties.def_value%TYPE;
       v_tab             tStringArray;
   BEGIN

     SELECT NVL(TO_CHAR(def_num_value), def_value) INTO v_def_value
       FROM cz_properties
      WHERE property_id = p_property_id AND deleted_flag = '0';

     SELECT NVL(TO_CHAR(data_num_value), data_value) BULK COLLECT INTO v_tab
       FROM cz_ps_prop_vals
      WHERE ps_node_id = p_node_id
            AND property_id = p_property_id
            AND deleted_flag = '0';

     IF(v_tab.COUNT = 0 AND p_item_id IS NOT NULL)THEN

       SELECT NVL(TO_CHAR(property_num_value), property_value) BULK COLLECT INTO v_tab
         FROM cz_item_property_values
        WHERE property_id = p_property_id
              AND item_id = p_item_id
              AND deleted_flag = '0';

       IF(v_tab.COUNT = 0)THEN

         SELECT NULL BULK COLLECT INTO v_tab
           FROM cz_item_type_properties t, cz_item_masters m
          WHERE m.item_id = p_item_id
            AND m.deleted_flag = '0'
            AND t.deleted_flag = '0'
            AND t.property_id = p_property_id
            AND t.item_type_id = m.item_type_id;
       END IF;
     END IF;

     IF(v_tab.EXISTS(1))THEN RETURN NVL(v_tab(1), v_def_value); END IF;

     RETURN NULL;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;
   END get_Property_Value;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

   FUNCTION getTextByProperty(p_ps_node_id IN NUMBER,p_ui_node_id IN NUMBER) RETURN VARCHAR2 IS

       v_property_id    CZ_PROPERTIES.property_id%TYPE;
       v_item_id        CZ_PS_NODES.item_id%TYPE;

   BEGIN -- sselahi
       v_property_id:=TO_NUMBER(getUseLabelsProperty(p_ui_node_id,'LabelProperty'));

       SELECT item_id INTO v_item_id FROM CZ_PS_NODES
        WHERE ps_node_id=p_ps_node_id;

       RETURN  get_Property_Value(p_node_id     => p_ps_node_id,
                                  p_property_id => v_property_id,
                                  p_item_id     => v_item_id);
   END getTextByProperty;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE refreshUI
(in_ui_def_id  IN OUT NOCOPY INTEGER,
 out_run_id    OUT NOCOPY    INTEGER) IS

temp                  IntArray;
t_pages               IntArray;
t_ref_uis             IntArray;

t_ui_node_id_tbl      IntArrayIndexBinaryInt;
t_tree_seq_tbl        IntArrayIndexBinaryInt;
t_ps_node_id_tbl      IntArrayIndexBinaryInt;
t_tree_seq_delta_tbl  IntArrayIndexBinaryInt;

new_id                INTEGER;
new_parent            INTEGER;
new_child             INTEGER;
var_ref_ui            INTEGER;
var_ref_ui_id         INTEGER;
var_new_si_id         INTEGER;
ind                   INTEGER;
new_node_ref_id       INTEGER;
curr_node_id          INTEGER;
curr_label_id         INTEGER;
curr_bitmap_id        INTEGER;
curr_button_id        INTEGER;
default_PROD_TOP      INTEGER;
default_PROD_LEFT     INTEGER;
var_height            INTEGER;
var_component_id      INTEGER;
var_model_id          INTEGER;
var_root_id           INTEGER;
var_parent_id         INTEGER;
temp_node             INTEGER;
var_ui_node_id        INTEGER;
new_ui_def_id         INTEGER;
var_feature_height    INTEGER;
var_control_type      INTEGER;
var_feature_type      INTEGER;
options_number        INTEGER;
var_comp_tree_id      INTEGER;
var_limbo_id          INTEGER;
var_prod_selection    INTEGER;
var_ref_id            INTEGER;
var_temp1             INTEGER;
var_temp2             INTEGER;
var_tempo             INTEGER;
var_temp              INTEGER;
var_min               INTEGER;
var_max               INTEGER;
var_ui_root_id        INTEGER;
var_rel_top_pos       INTEGER;
temp_var              INTEGER;
var_width             INTEGER;
var_top_pos           INTEGER;
var_screen_width      INTEGER;
var_screen_height     INTEGER;
var_ref_to_id         INTEGER;
var_ref_model_id      INTEGER;
var_model_ref_id      INTEGER;
ind_                  INTEGER;
ind_arr               INTEGER;
var_err               INTEGER;
var_label_txt_id      INTEGER;
k                     INTEGER;

var_screen_ui_id      INTEGER;
var_tree_ui_id        INTEGER;
var_tree_caption_id   INTEGER;
var_tree_parent_id    INTEGER;
var_text_label_id     INTEGER;
var_ui_def_ref_id     INTEGER;
var_screen_caption_id INTEGER;
var_parent_screen_id  INTEGER;
var_option_ui_id      INTEGER;
var_option_caption_id INTEGER;
var_screen_parent_id  INTEGER;
var_button_id         INTEGER;
var_button_type       INTEGER;

var_text_label_caption_id INTEGER;

var_ui_feature_type   INTEGER;
var_ui_max            INTEGER;
var_ui_min            INTEGER;
var_out_ui_def_id     INTEGER;
var_out_run_id        INTEGER;
var_frame_allocation  INTEGER;
ind_counter           INTEGER;
deletedNodes          INTEGER:=0;
counter               INTEGER:=0;

var_caption_id         CZ_UI_NODES.caption_id%TYPE;
var_ui_node_ref_id     CZ_UI_NODES.ui_node_ref_id%TYPE;
var_modified_flag      CZ_UI_NODES.modified_flags%TYPE;
var_ui_tree_parent_id  CZ_UI_NODES.ui_node_id%TYPE;
var_ui_tree_seq        CZ_UI_NODES.tree_seq%TYPE;
var_ui_control_type    CZ_UI_NODES.controltype%TYPE;
var_parent_item_txt_id CZ_UI_NODES.caption_id%TYPE;
var_ui_parent_item_id  CZ_UI_NODES.ui_node_id%TYPE;
var_inst_node_ref_id   CZ_UI_NODES.ui_node_ref_id%TYPE;
var_inst_text_label    CZ_UI_NODES.ui_node_id%TYPE;
var_modify_ui_flag     CZ_UI_NODES.modified_flags%TYPE;
var_screen_ps_node_id  CZ_UI_NODES.ps_node_id%TYPE;
var_screen_top_pos     CZ_UI_NODES.rel_top_pos%TYPE;
var_ui_node_type       CZ_UI_NODES.ui_node_type%TYPE;
var_screen_ps_id       CZ_UI_NODES.ps_node_id%TYPE;
var_oc_standart_item   CZ_UI_NODES.ui_node_id%TYPE;
var_tree_seq           CZ_PS_NODES.tree_seq%TYPE;
var_parent_name        CZ_PS_NODES.name%TYPE;
var_curr_max           CZ_PS_NODES.maximum%TYPE;
var_curr_min           CZ_PS_NODES.minimum%TYPE;
var_ref_name           CZ_PS_NODES.name%TYPE;
var_ref_caption_id     CZ_PS_NODES.intl_text_id%TYPE;
var_inst_ui_id         CZ_UI_NODES.ui_node_id%TYPE;
var_inst_parent_id     CZ_UI_NODES.parent_id%TYPE;
var_inst_ps_id         CZ_UI_NODES.ps_node_id%TYPE;
var_inst_top_pos       CZ_UI_NODES.rel_top_pos%TYPE;
var_inst_tree_seq      CZ_UI_NODES.tree_seq%TYPE;
var_inst_caption_id    CZ_UI_NODES.caption_id%TYPE;
var_inst_name          CZ_UI_NODES.name%TYPE;
var_ref_parent_screen_id CZ_UI_NODES.ui_node_id%TYPE;
var_option_ps_id       CZ_UI_NODES.ps_node_id%TYPE;
var_caption_name       CZ_INTL_TEXTS.text_str%TYPE;
var_label              CZ_INTL_TEXTS.text_str%TYPE;
var_button_name        CZ_INTL_TEXTS.text_str%TYPE;

Flag                   BOOLEAN;
existUINode            BOOLEAN:=FALSE;
existUI                BOOLEAN:=FALSE;

var_borders            VARCHAR2(1);
var_deleted_flag       VARCHAR2(1);
var_ui_omit            VARCHAR2(1);
var_virtual_flag       VARCHAR2(1);
var_use_default_color  VARCHAR2(1);
existRefUI             VARCHAR2(1);
var_action_type        VARCHAR2(1);
existsDeleteMe         VARCHAR2(1):=NO_FLAG;
existsButton           VARCHAR2(1):=NO_FLAG;
existsSTANDART_ITEM    VARCHAR2(1):=NO_FLAG;
existsUI               VARCHAR2(1):=NO_FLAG;
UPDATE_UI_PROPS        VARCHAR2(1):=YES_FLAG;
var_use_labels         VARCHAR2(1);
var_current_lang       VARCHAR2(20);
var_suffix             VARCHAR2(40);
var_curr_virtual_flag  VARCHAR2(1);
var_ui_counted_options VARCHAR2(1);
BomType                VARCHAR2(1);
v_just_OC              VARCHAR2(1);

var_ps_node_id          CZ_PS_NODES.ps_node_id%TYPE;
var_name                CZ_PS_NODES.name%TYPE;
var_intl_text_id        CZ_PS_NODES.intl_text_id%TYPE;
var_text_str            CZ_INTL_TEXTS.text_str%TYPE;
var_option_ui_name      CZ_UI_NODES.NAME%TYPE;
var_button_label        CZ_INTL_TEXTS.TEXT_STR%TYPE;
var_screen_name         CZ_UI_NODES.NAME%TYPE;
var_ui_parent_screen_id CZ_UI_NODES.ui_node_id%TYPE;
var_modified_flags      CZ_UI_NODES.MODIFIED_FLAGS%TYPE;
var_gen_version         CZ_UI_DEFS.GEN_VERSION%TYPE;
var_ui_name             CZ_UI_DEFS.NAME%TYPE;
var_model_ref_expl_id   CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
var_ps_node_type        CZ_PS_NODES.ps_node_type%TYPE;

NEXT_ITTERATION        EXCEPTION;
NO_COMPONENT_TREE_NODE EXCEPTION;
NO_LIMBO_NODE          EXCEPTION;
KEEP_IT                EXCEPTION;
BREAK_IT               EXCEPTION;
SKIP_IT                EXCEPTION;
BUTTON_EXISTS          EXCEPTION;
WRONG_UI_VERSION       EXCEPTION;

t_news                 UIArray;
t_boms                 UIArray;
t_features             featureArray;
t_Options              optionArray;
t_add_buttons          buttonsArray;
t_footer_buttons       buttonsArray;
t_latest_buttons       buttonsArray;
t_ref_boms             refbomArray;
t_bom_pages            pageArray;

RCODE VARCHAR2(10);

BEGIN

    Initialize;

    --
    -- set Global variables --
    --
    MODE_REFRESH:=TRUE;
    MUID:=NULL;

    --
    -- Calculate usable width and height     --
    --
    SELECT ui_node_id,width,height INTO var_root_id,var_screen_width,var_screen_height FROM
    CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND ui_node_id=parent_id
    AND deleted_flag=NO_FLAG;

    USABLE_WIDTH:=FLOOR(var_screen_width*(100-DEFAULT_TREE_ALLOCATION)/100)-LEFT_MARGIN-RIGHT_MARGIN;
    USABLE_HEIGHT:=var_screen_height;

    OPTION_FEATURE_WIDTH:=FLOOR(USABLE_WIDTH/2);
    CENTER_LINE:=LEFT_MARGIN+OPTION_FEATURE_WIDTH;
    DELETE_BUTTON_LEFT_POS:=USABLE_WIDTH+LEFT_MARGIN-DELETE_BUTTON_WIDTH;

    NUMERIC_FEATURE_WIDTH:=FLOOR(OPTION_FEATURE_WIDTH/2);
    BOOLEAN_FEATURE_WIDTH:=16;
    DEFAULT_TOTAL_WIDTH:=NUMERIC_FEATURE_WIDTH;
    DEFAULT_RESOURCE_WIDTH:=NUMERIC_FEATURE_WIDTH;
    DEFAULT_CONNECTOR_WIDTH:=NUMERIC_FEATURE_WIDTH;
    CONNECTOR_GAP:=DEFAULT_CONNECTOR_WIDTH+DEFAULT_SPACE_BETWEEN+STAR_SYMBOL_WIDTH+DEFAULT_SPACE_BETWEEN;

    SCREEN_HALF:=FLOOR(USABLE_WIDTH/2)-DEFAULT_SPACE_BETWEEN;

    /* ************ Calculate Default Tops and Lefts  *************** */
    last_TOP_POS:=DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN;
    last_HEIGHT:=DEFAULT_CONTROL_HEIGHT;

    out_run_id:=0;
    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;

    SELECT look_and_feel INTO mLOOK_AND_FEEL FROM CZ_UI_DEFS
    WHERE ui_def_id=in_ui_def_id AND deleted_flag=NO_FLAG;

    BEGIN
        SELECT value_str INTO mUSE_LABELS FROM CZ_UI_NODE_PROPS
        WHERE key_str='UseLabels' AND ui_node_id=var_root_id AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --
             -- use Descriptions as Labels --
             --
             mUSE_LABELS:='1';
    END;

    BEGIN
        SELECT value_str INTO mSHOW_ALL_NODES FROM CZ_UI_NODE_PROPS
        WHERE key_str='ShowAllNodes' AND ui_node_id=var_root_id AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --
             -- don't ignore UI_OMIT flag
             --
             mSHOW_ALL_NODES:='0';
    END;

    BEGIN
        SELECT value_str INTO var_frame_allocation FROM CZ_UI_NODE_PROPS
        WHERE key_str='NavFrameAllocation' AND ui_node_id=var_root_id AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --
             -- default value
             --
             var_frame_allocation:=30;
    END;

    BEGIN
        SELECT value_str INTO mWIZARD_STYLE FROM CZ_UI_NODE_PROPS
        WHERE UPPER(key_str)='WIZARDSTYLE' AND ui_node_id=var_root_id AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             mWIZARD_STYLE:='0';
    END;

    BEGIN
        SELECT value_str INTO mITEMS_ON_PAGE FROM CZ_UI_NODE_PROPS
        WHERE UPPER(key_str)='MAXBOMITEMSONPAGE'
        AND ui_node_id=var_root_id AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             mITEMS_ON_PAGE:=10;
    END;

    UPDATE CZ_UI_DEFS SET last_update_date=SYSDATE WHERE
    ui_def_id=in_ui_def_id RETURNING
    component_id,ui_style,gen_version,name
    INTO Project_Id,mUI_STYLE,var_gen_version,var_ui_name;

    --
    -- if it's a BOM style UI then generate a new UI      --
    -- and return new_ui_def_id as in_ui_def_id parameter --
    --
    IF mUI_STYLE=APPLET_STYLE_UI THEN

       createui(in_product_id      =>Project_Id,
                out_ui_def_id      =>new_ui_def_id,
                out_run_id         =>out_run_id,
                in_ui_style        =>mUI_STYLE,
                in_frame_allocation=>var_frame_allocation,
                in_width           =>var_screen_width,
                in_height          =>var_screen_height,
                in_show_all_nodes  =>mSHOW_ALL_NODES,
                in_use_labels      =>mUSE_LABELS,
                in_look_and_feel   =>mLOOK_AND_FEEL,
                in_max_bom_per_page=>mITEMS_ON_PAGE,
                in_wizard_style    =>mWIZARD_STYLE);


       UPDATE CZ_UI_DEFS SET deleted_flag=YES_FLAG WHERE ui_def_id=in_ui_def_id;
       UPDATE CZ_UI_DEFS SET name=var_ui_name WHERE ui_def_id=new_ui_def_id;
       UPDATE CZ_UI_NODES SET name=var_ui_name WHERE ui_node_id=parent_id AND ui_def_id=new_ui_def_id;
       UPDATE CZ_UI_NODES SET ui_def_ref_id=new_ui_def_id WHERE ui_def_ref_id=in_ui_def_id;
       in_ui_def_id:=new_ui_def_id;
       RAISE BREAK_IT;
    END IF;

    BEGIN
        SELECT ui_node_id INTO var_comp_tree_id FROM CZ_UI_NODES
        WHERE ui_def_id=in_ui_def_id AND name='Components Tree' AND deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RAISE NO_COMPONENT_TREE_NODE;
    END;

    BEGIN
        SELECT ui_node_id INTO var_limbo_id FROM CZ_UI_NODES
        WHERE ui_def_id=in_ui_def_id AND name='Limbo' AND
        deleted_flag=NO_FLAG;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RAISE NO_LIMBO_NODE;
    END;

    deletedNodes:=0;

    SELECT COUNT('1') INTO deletedNodes FROM dual WHERE
    EXISTS(SELECT NULL FROM CZ_PS_NODES
               WHERE devl_project_id=Project_Id AND
              (ui_omit=YES_FLAG OR deleted_flag=YES_FLAG));

    IF deletedNodes>0 THEN
       delete_UI_Nodes(Project_Id,in_ui_def_id);
    END IF;

    --
    -- delete buttons which are associated with a deleted Functional Companions --
    --
    UPDATE CZ_UI_NODES a
       SET deleted_flag=YES_FLAG
     WHERE a.ui_def_id=in_ui_def_id AND a.ui_node_type=UI_BUTTON_TYPE AND a.func_comp_id IS NOT NULL AND
           NOT EXISTS(SELECT NULL FROM CZ_FUNC_COMP_SPECS b WHERE b.func_comp_id=a.func_comp_id AND b.deleted_flag=NO_FLAG);

    --
    -- delete buttons which are associated with a deleted CXs --
    --
    UPDATE CZ_UI_NODES u
       SET deleted_flag=YES_FLAG
     WHERE u.ui_def_id=in_ui_def_id AND u.ui_node_type=UI_BUTTON_TYPE AND
           u.deleted_flag=NO_FLAG AND
           EXISTS(SELECT NULL FROM CZ_UI_NODE_PROPS p
                   WHERE p.key_str='RuleId' AND p.ui_def_id=u.ui_def_id AND p.ui_node_id=u.ui_node_id AND p.deleted_flag=NO_FLAG AND
                         TO_NUMBER(value_str) NOT IN
                          (SELECT r.rule_id FROM CZ_RULES r WHERE r.devl_project_id=Project_id AND
                               r.rule_type=CZ_EXTENTSIONS_RULE_TYPE AND r.deleted_flag=NO_FLAG));

    /* *** remove all UI nodes associated with unexisting PS nodes *** */

   FOR i IN (SELECT ui_node_id,ui_node_type,deleted_flag FROM CZ_UI_NODES a
              WHERE  ui_def_id=in_ui_def_id AND ps_node_id IS NOT NULL AND ui_node_type<>141
              AND (NOT EXISTS(SELECT NULL FROM CZ_PS_NODES WHERE devl_project_id=Project_Id AND
              ps_node_id=a.ps_node_id AND deleted_flag=NO_FLAG) OR a.deleted_flag=YES_FLAG))
    LOOP
       BEGIN
           IF i.ui_node_type IN(UI_BUTTON_TYPE,UI_PICTURE_TYPE,UI_REFERENCE_REF_TYPE) THEN
              UPDATE CZ_UI_NODES
              SET deleted_flag=YES_FLAG
              WHERE ui_def_id=in_ui_def_id  AND ui_node_id=i.ui_node_id AND
              ui_node_type IN(UI_BUTTON_TYPE,UI_PICTURE_TYPE,UI_REFERENCE_REF_TYPE)
              AND deleted_flag=NO_FLAG;
           ELSE
              remove_UI_Subtree(i.ui_node_id,i.ui_node_type);
           END IF;

       EXCEPTION
           WHEN OTHERS THEN
                LOG_REPORT('CZ_UI_GENERATOR.delete_UI_nodes',SQLERRM, CZ_ERROR_URGENCY);
       END;
    END LOOP;



    FOR i IN (SELECT ps_node_id,parent_id,ps_node_type,reference_id,
              maximum,minimum,name,intl_text_id,counted_options_flag,virtual_flag,
              feature_type,ui_omit,tree_seq,item_id,orig_sys_ref FROM CZ_PS_NODES
              WHERE devl_project_id=Project_Id AND deleted_flag=NO_FLAG
              AND ui_omit=NO_FLAG)
    LOOP
       BEGIN
          --
          -- find ui_node_id on the screen associated with i.ps_node_id --
          --
         BEGIN
             var_text_label_id:=NULL;
             existUINode:=FALSE;

             --
             -- if parent is invisible in UI then go to the next itteration --
             --
             IF display_in_UI(i.ps_node_id,i.parent_id)='1' THEN
                RAISE NEXT_ITTERATION;
             END IF;

             -- general loop : find UI nodes associated with a given PS node --
             -- and refresh them                                             --

             var_screen_parent_id:=-1;
             ind_counter:=1;
             t_bom_pages.Delete;

             FOR  k IN(SELECT ui_node_id,parent_id,ui_node_ref_id,ui_def_ref_id,
                       caption_id,height,ui_node_type,controltype,
                       modified_flags,name,tree_seq,rel_top_pos,ps_node_id
                       FROM CZ_UI_NODES
                       WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.ps_node_id AND
                       ui_node_type IN
                       (UI_PRODUCT_TYPE,UI_COMPONENT_TYPE,
                        UI_FEATURE_TYPE,UI_OPTION_TYPE,
                        UI_RESOURCE_TYPE,UI_TOTAL_TYPE,UI_REFERENCE_REF_TYPE,
                        UI_BOM_OPTION_CLASS_TYPE,UI_BOM_STANDART_TYPE,UI_CONNECTOR_TYPE)
                        AND deleted_flag=NO_FLAG ORDER BY ui_node_id)
              LOOP
                 BEGIN

                 IF i.ps_node_type=BOM_CLASS_NODE_TYPE
                    AND k.ui_node_type=UI_BOM_OPTION_CLASS_TYPE THEN

                    BEGIN
                        SELECT caption_id INTO var_label_txt_id FROM CZ_UI_NODES
                        WHERE  ui_def_id=in_ui_def_id AND ui_node_id=k.ui_node_ref_id;

                        SELECT caption_id INTO var_tree_caption_id FROM CZ_UI_NODES
                        WHERE ui_def_id=in_ui_def_id AND ui_node_ref_id=k.ui_node_id AND
                        ui_node_type IN(UI_PRODUCT_REF_TYPE,UI_COMPONENT_REF_TYPE)
                        AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;
                    EXCEPTION
                        WHEN OTHERS THEN
                             --
                             -- this means that screen was deleted from UI in Developer
                             -- and is under <Limbo>
                             --
                             RAISE NEXT_ITTERATION;
                    END;

                    IF t_bom_pages.Last>=0 THEN
                       ind_counter:=t_bom_pages.Last+1;
                    END IF;
                    t_bom_pages(ind_counter).ps_node_id:=i.ps_node_id;
                    t_bom_pages(ind_counter).ui_node_id:=k.ui_node_id;
                    t_bom_pages(ind_counter).text_id:=k.caption_id;
                    t_bom_pages(ind_counter).label_id:=k.ui_node_ref_id;
                    t_bom_pages(ind_counter).label_txt_id:=var_label_txt_id;
                    t_bom_pages(ind_counter).name:=k.name;
                    t_bom_pages(ind_counter).tree_label_id:=var_tree_caption_id;
                  END IF;

                  var_screen_ui_id:=k.ui_node_id;
                  var_screen_parent_id:=k.parent_id;
                  var_text_label_id:=k.ui_node_ref_id;
                  var_ui_def_ref_id:=k.ui_def_ref_id;
                  var_screen_caption_id:=k.caption_id;
                  var_modify_ui_flag:=k.modified_flags;
                  var_screen_height:=k.height;
                  var_screen_name:=k.name;
                  var_ui_control_type:=k.controltype;
                  var_ui_tree_seq:=k.tree_seq;
                  var_screen_ps_node_id:=k.ps_node_id;
                  var_screen_top_pos:=k.rel_top_pos;
                  var_ui_node_type:=k.ui_node_type;
                  existUINode:=TRUE;

              EXCEPTION
                  WHEN SKIP_IT THEN
                       NULL;
              END;
        END LOOP;

        IF i.ps_node_type=REFERENCE_NODE_TYPE THEN
           BEGIN
               SELECT ui_node_ref_id INTO var_tempo FROM CZ_UI_NODES
               WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_parent_id
               AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

               SELECT ui_node_id INTO var_parent_screen_id FROM
               CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND
               ui_node_id=var_tempo AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
         END IF;

         IF var_screen_parent_id=var_limbo_id THEN
            RAISE NEXT_ITTERATION;
         END IF;

         IF i.ps_node_type IN(PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,
                              FEATURE_NODE_TYPE,TOTAL_NODE_TYPE,RESOURCE_NODE_TYPE,CONNECTOR_NODE_TYPE,
                              BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE) THEN
           SELECT caption_id,modified_flags
           INTO var_text_label_caption_id,var_modified_flags
           FROM CZ_UI_NODES
           WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_text_label_id AND
           deleted_flag=NO_FLAG;
        END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   END;

   /**************************** populate arrays for new nodes ********************************/
   IF existUINode=FALSE THEN
      curr_node_id:=getUISeqVal;
      var_use_labels:= mUSE_LABELS;
      IF i.ps_node_type IN(OPTION_NODE_TYPE,BOM_STANDART_NODE_TYPE) THEN
         BEGIN
             SELECT value_str INTO var_use_labels FROM CZ_UI_NODE_PROPS
             WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_parent_id AND UPPER(key_str)='USELABELS' AND deleted_flag=NO_FLAG;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         END;
      END IF;

      var_caption_name:=i.name;

      /* *** go through all languages and update captions of the reference *** */

      FOR l IN(SELECT intl_text_id,language,localized_str FROM CZ_LOCALIZED_TEXTS WHERE intl_text_id=i.intl_text_id)
      LOOP
         var_caption_name:=i.name;
         var_caption_name:=get_Caption(i.name,l.localized_str,var_use_labels);
      END LOOP;

      IF i.ps_node_type IN (PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,
          FEATURE_NODE_TYPE,RESOURCE_NODE_TYPE,TOTAL_NODE_TYPE,OPTION_NODE_TYPE,
          BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE,REFERENCE_NODE_TYPE,CONNECTOR_NODE_TYPE) THEN

          --
          -- BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE were exluded in current version --
          --
          news(i.ps_node_id).id:=curr_node_id;
          news(i.ps_node_id).ps_node_id:=i.ps_node_id;
          news(i.ps_node_id).parent_id:=i.parent_id;
          news(i.ps_node_id).ps_node_type:=i.ps_node_type;
          news(i.ps_node_id).name:=i.name;
          news(i.ps_node_id).caption_name:=var_caption_name;
          news(i.ps_node_id).tree_seq:=i.tree_seq*mMAX_NUMBER_PAGES;
          news(i.ps_node_id).maximum:=i.maximum;
          news(i.ps_node_id).minimum:=i.minimum;
          news(i.ps_node_id).ui_omit:=i.ui_omit;
          news(i.ps_node_id).reference_id:=i.reference_id;
          news(i.ps_node_id).virtual_flag:=i.virtual_flag;
          news(i.ps_node_id).ui_node_ref_id:=getUISeqVal;
          news(i.ps_node_id).intl_text_id:=i.intl_text_id;

          IF i.ps_node_type IN(REFERENCE_NODE_TYPE) THEN
             news(i.ps_node_id).reference_id:=i.reference_id;
          END IF;

      END IF;

      IF i.ps_node_type IN (FEATURE_NODE_TYPE,RESOURCE_NODE_TYPE,TOTAL_NODE_TYPE,CONNECTOR_NODE_TYPE)  THEN
         features(i.ps_node_id).id:=curr_node_id;
         features(i.ps_node_id).ps_node_id:=i.ps_node_id;
         features(i.ps_node_id).parent_id:=i.parent_id;
         features(i.ps_node_id).ps_node_type:=i.ps_node_type;
         features(i.ps_node_id).name:=i.name;
         features(i.ps_node_id).caption_name:=var_caption_name;
         features(i.ps_node_id).counted_options_flag:=i.counted_options_flag;
         features(i.ps_node_id).tree_seq:=i.tree_seq*mMAX_NUMBER_PAGES;
         features(i.ps_node_id).maximum:=i.maximum;
         features(i.ps_node_id).minimum:=i.minimum;
         features(i.ps_node_id).feature_type:=i.feature_type;
         features(i.ps_node_id).intl_text_id:=i.intl_text_id;

          IF i.ps_node_type IN(CONNECTOR_NODE_TYPE) THEN
             features(i.ps_node_id).reference_id:=i.reference_id;
          END IF;

         --
         -- atp_flag=TRUE means - it can be used in pricing stuff --
         -- atp_flag = TRUE just when it's BOM node               --
         --
         -- this is an old condition      --
         -- IF i.item_id IS NOT NULL THEN --
         --
         IF i.orig_sys_ref IS NOT NULL THEN
             features(i.ps_node_id).atp_flag:=TRUE;
         ELSE
             features(i.ps_node_id).atp_flag:=FALSE;
         END IF;
       END IF;

       IF i.ps_node_type=OPTION_NODE_TYPE THEN
          options(i.ps_node_id).id:=curr_node_id;
          options(i.ps_node_id).ps_node_id:=i.ps_node_id;
          options(i.ps_node_id).parent_id:=i.parent_id;
          options(i.ps_node_id).name:=i.name;
          options(i.ps_node_id).caption_name:=var_caption_name;
          options(i.ps_node_id).tree_seq:=i.tree_seq;
          options(i.ps_node_id).intl_text_id:=i.intl_text_id;
       END IF;

       IF i.ps_node_type IN (BOM_MODEL_NODE_TYPE,BOM_CLASS_NODE_TYPE,BOM_STANDART_NODE_TYPE) THEN
          boms(i.ps_node_id).id:=curr_node_id;
          boms(i.ps_node_id).ps_node_id:=i.ps_node_id;
          boms(i.ps_node_id).parent_id:=i.parent_id;
          boms(i.ps_node_id).ps_node_type:=i.ps_node_type;
          boms(i.ps_node_id).name:=i.name;
          boms(i.ps_node_id).caption_name:=var_caption_name;
          boms(i.ps_node_id).tree_seq:=i.tree_seq*mMAX_NUMBER_PAGES;
          boms(i.ps_node_id).maximum:=i.maximum;
          boms(i.ps_node_id).minimum:=i.minimum;
          boms(i.ps_node_id).ui_omit:=i.ui_omit;
          boms(i.ps_node_id).ui_node_ref_id:=getUISeqVal;
          boms(i.ps_node_id).intl_text_id:=i.intl_text_id;
      END IF;
      RAISE NEXT_ITTERATION;
   END IF;

   /*********************************end of populating ************************************/
   /* *** find ui_node_id in the Component Tree associated with the ui node = var_screen_ui_id *** */
   BEGIN
       var_tree_ui_id:=NULL;
       SELECT ui_node_id,caption_id,parent_id
       INTO var_tree_ui_id,var_tree_caption_id,var_tree_parent_id FROM CZ_UI_NODES
       WHERE ui_def_id=in_ui_def_id AND ui_node_ref_id=var_screen_ui_id AND
       ui_node_type IN (UI_PRODUCT_REF_TYPE,UI_COMPONENT_REF_TYPE)
       AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

       /* *** find a parent screen *** */
       SELECT ui_node_ref_id INTO var_parent_screen_id FROM
       CZ_UI_NODES WHERE ui_node_id=var_tree_parent_id;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;
   END;

   IF i.ps_node_type IN(PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,REFERENCE_NODE_TYPE,CONNECTOR_NODE_TYPE) THEN
      BEGIN
          IF i.ps_node_type IN(REFERENCE_NODE_TYPE,CONNECTOR_NODE_TYPE) THEN
             SELECT MIN(model_ref_expl_id) INTO var_model_ref_id FROM CZ_MODEL_REF_EXPLS a WHERE
             model_id=Project_Id  AND referring_node_id=i.ps_node_id AND deleted_flag=NO_FLAG;
          ELSE
             SELECT MIN(model_ref_expl_id) INTO var_model_ref_id FROM CZ_MODEL_REF_EXPLS a WHERE
             model_id=Project_Id  AND component_id=i.ps_node_id AND deleted_flag=NO_FLAG;
          END IF;

         /* *** refresh model_ref_expl_id-s for all Components,Products,References and UI controls *** */
         UPDATE CZ_UI_NODES SET model_ref_expl_id=var_model_ref_id WHERE ui_def_id=in_ui_def_id
         AND  model_ref_expl_id IS NOT NULL AND model_ref_expl_id<>var_model_ref_id
         AND ps_node_id=i.ps_node_id AND deleted_flag='0';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         WHEN OTHERS THEN
              NULL;
      END;
   END IF;

   /* *** REFERENCE case *** */
   IF i.ps_node_type=REFERENCE_NODE_TYPE THEN

      SELECT  ui_node_id,parent_id,ui_def_ref_id,caption_id,name,tree_seq,ps_node_id,ui_node_type
      INTO    var_screen_ui_id,var_screen_parent_id,var_ui_def_ref_id,
              var_screen_caption_id,var_screen_name,
              var_ui_tree_seq,var_screen_ps_node_id,var_ui_node_type
      FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.ps_node_id AND
      ui_node_type=UI_REFERENCE_REF_TYPE AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

      SELECT ui_node_ref_id
      INTO var_ref_parent_screen_id
      FROM CZ_UI_NODES
      WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_parent_id AND deleted_flag=NO_FLAG;

      /* *** name of the reference should be = PS node's name *** */
      IF i.name<>var_screen_name THEN
         UPDATE CZ_UI_NODES SET name=i.name
         WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_ui_id;
         IF i.intl_text_id IS NULL THEN
            UPDATE CZ_INTL_TEXTS SET text_str=i.name
            WHERE intl_text_id=var_screen_caption_id
            AND var_modified_flags=0;
         END IF;
      END IF;

      --
      -- find the value of "UseLabels" property of the screen which is
      -- a parent screen for STANDTART ITEM associated with the reference
      --
      BEGIN
          --
          -- by default global "UseLabels" property is used
          --
          var_use_labels:=mUSE_LABELS;

          --
          -- the nested SELECT statement should always return 1 record
          -- because there is just one screen that contains a STANDART ITEM
          -- associated with the given reference
          -- ( the reference and the STANDART ITEM have the same ps_node_id )
          --
          SELECT value_str INTO var_use_labels FROM CZ_UI_NODE_PROPS
          WHERE ui_node_id=(SELECT parent_id FROM CZ_UI_NODES
          WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.ps_node_id AND deleted_flag=NO_FLAG AND
          ui_node_type=UI_BOM_STANDART_TYPE AND parent_id<>var_limbo_id)
          AND UPPER(key_str)='USELABELS' AND deleted_flag=NO_FLAG;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;
          WHEN OTHERS THEN
               LOG_REPORT('CZ_UI_GENERATOR.create_REFERENCE_Model',
              'Reference'||'"'||i.name||'" may have an associated STANDART ITEM control in UI with a wrong label because of error : '||SQLERRM,
              CZ_ERROR_URGENCY);
      END;

      /* *** go through all languages and update captions of the reference *** */
      var_label:=i.name;
      var_button_label:=var_label;
      FOR l IN(SELECT intl_text_id,language,localized_str FROM CZ_LOCALIZED_TEXTS
               WHERE intl_text_id=i.intl_text_id)
      LOOP
         var_label:=i.name;
         var_label:=get_Caption(i.name,l.localized_str,var_use_labels);

         IF l.language=mCURRENT_LANG THEN
            var_button_label:=var_label;
         END IF;

         UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
         WHERE intl_text_id=var_screen_caption_id AND language=l.language;
      END LOOP;

      /* *** we use current refrenced UI ( not the latest referenced UI *** */
      --var_ref_id:=get_last_UI(i.reference_id);
      var_ref_id:=var_ui_def_ref_id;

      BEGIN
          SELECT value_str INTO var_curr_virtual_flag FROM CZ_UI_NODE_PROPS
          WHERE ui_def_id=in_ui_def_id AND
          ui_node_id=var_screen_ui_id AND key_str='IsVirtual' AND deleted_flag=NO_FLAG ;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
               var_curr_virtual_flag:=i.virtual_flag;
      END;

      BEGIN

      /* *** find Model_Id of the referenced Model *** */
      BEGIN
          SELECT devl_project_id INTO var_ref_model_id FROM CZ_UI_DEFS
          WHERE ui_def_id=var_ui_def_ref_id AND deleted_flag=NO_FLAG;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              /* *** wrong data : just skip it *** */
              var_ref_model_id:=NULL;
      END;

      BEGIN
          SELECT name,intl_text_id
          INTO var_ref_name,var_ref_caption_id FROM CZ_PS_NODES
          WHERE devl_project_id=var_ref_model_id AND parent_id IS NULL
          AND EXISTS(SELECT NULL FROM CZ_PS_NODES WHERE devl_project_id=var_ref_model_id
          AND ps_node_type=BOM_MODEL_NODE_TYPE AND deleted_flag=NO_FLAG) AND deleted_flag=NO_FLAG;
          BomType:=YES_FLAG;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              BomType:=NO_FLAG;
      END;

      IF BomType=YES_FLAG THEN
         BEGIN
             var_ui_node_type:=UI_REFERENCE_REF_TYPE;

             SELECT ui_node_id,parent_id,ui_node_type,ps_node_id,
                    rel_top_pos,tree_seq,caption_id,ui_node_ref_id,name
             INTO var_inst_ui_id,var_inst_parent_id,var_ui_node_type,var_inst_ps_id,
                  var_inst_top_pos,var_inst_tree_seq,var_inst_caption_id,var_inst_node_ref_id,var_inst_name
             FROM CZ_UI_NODES
             WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.ps_node_id AND parent_id<>var_limbo_id AND
             ui_node_type IN(UI_BOM_INST_ITEM_TYPE,UI_BOM_STANDART_TYPE) AND deleted_flag=NO_FLAG;

             --
             --  update name and caption of element associated with a Reference --
             --
             var_label:=var_ref_name;
             FOR l IN(SELECT intl_text_id,language,localized_str FROM CZ_LOCALIZED_TEXTS
                      WHERE intl_text_id=var_ref_caption_id)
             LOOP
               var_label:=var_ref_name;
               var_label:=get_Caption(var_ref_name,l.localized_str);

               IF l.language=mCURRENT_LANG THEN
                  var_button_label:=var_label;
               END IF;
               UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
               WHERE intl_text_id=var_inst_caption_id AND language=l.language;
             END LOOP;

         EXCEPTION
             WHEN OTHERS THEN
                  NULL;
         END;
      END IF;


      /* *** delete reference if UI and PS tree references are not synchronized *** */
      IF var_ref_model_id<>i.reference_id THEN
         UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG WHERE ui_def_id=in_ui_def_id
         AND ps_node_id=i.ps_node_id AND ui_node_type=UI_REFERENCE_REF_TYPE;
      END IF;

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
           WHEN OTHERS THEN
                NULL;
      END;

      IF var_curr_virtual_flag<>i.virtual_flag THEN

         --
         -- refresh 'IsVirtual' property of this reference --
         --
         UPDATE CZ_UI_NODE_PROPS SET value_str=i.virtual_flag
         WHERE ui_def_id=in_ui_def_id AND
         ui_node_id=var_screen_ui_id AND key_str='IsVirtual' AND deleted_flag=NO_FLAG ;

         --
         -- non-virtual --> virtual                            --
         -- delete an associated button                        --
         -- and change UI control if it is a reference to BOM  --
         --
         IF (i.maximum=1 AND i.minimum=1 AND i.virtual_flag=YES_FLAG) THEN
            --
            -- delete an associated buttons  ---
            --
            UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG
            WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.ps_node_id
            AND ui_node_type IN(UI_BUTTON_TYPE) AND modified_flags IN(0,1);

            IF var_ui_node_type=UI_BOM_INST_ITEM_TYPE THEN
               UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG
               WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_inst_ui_id
               AND ui_node_type=UI_BOM_INST_ITEM_TYPE AND deleted_flag=NO_FLAG;

               UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG
               WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_inst_node_ref_id
               AND ui_node_type=UI_TEXT_LABEL_TYPE AND deleted_flag=NO_FLAG;

               BEGIN
                   var_ref_ui_id:=NULL;
                   SELECT ui_node_id INTO var_ref_ui_id
                   FROM CZ_UI_NODES WHERE ui_def_id = var_ui_def_ref_id
                   AND  ps_node_id=i.reference_id AND ui_node_type=UI_SCREEN_TYPE
                   AND deleted_flag=NO_FLAG AND rownum<2;
               EXCEPTION
                  WHEN OTHERS THEN
                       NULL;
               END;

               BEGIN
                   SELECT model_ref_expl_id INTO var_model_ref_expl_id
                   FROM CZ_MODEL_REF_EXPLS WHERE model_id=Project_Id
                   AND parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG;
               EXCEPTION
                   WHEN OTHERS THEN
                        var_model_ref_expl_id:=NULL;
               END;

               BEGIN
                   SELECT model_ref_expl_id INTO var_model_ref_expl_id
                   FROM CZ_MODEL_REF_EXPLS WHERE model_id=Project_Id
                   AND parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG;
               EXCEPTION
               WHEN OTHERS THEN
                    var_model_ref_expl_id:=NULL;
               END;

               var_new_si_id:=getUISeqVal;
               set_UI_NODES (in_ui_node_id       =>var_new_si_id,
                             in_parent_id        =>var_ref_parent_screen_id,
                             in_ui_def_id        =>in_ui_def_id,
                             in_ps_node_id       =>var_inst_ps_id,
                             in_ui_node_ref_id   =>var_ref_ui_id,
                             in_name             =>var_inst_name,
                             in_component_id     =>var_inst_ps_id,
                             in_ui_node_type     =>UI_BOM_STANDART_TYPE,
                             in_lce_id           =>'P_'||to_char(var_inst_ps_id),
                             in_tree_display_flag=>YES_FLAG,
                             in_tree_seq         =>var_inst_tree_seq,
                             in_width            =>USABLE_WIDTH,
                             in_height           =>DEFAULT_BOM_HEIGHT,
                             in_top_pos          =>var_inst_top_pos,
                             in_left_pos         =>LEFT_MARGIN,
                             in_font_name        =>DEFAULT_FONT_NAME,
                             in_font_bold        =>NO_FLAG,
                             in_font_color       =>0,
                             in_font_italic      =>NO_FLAG,
                             in_font_size        =>DEFAULT_FONT_SIZE,
                             in_font_underline   =>NO_FLAG,
                             in_controltype      =>9,
                             in_bkgrnd_style     =>YES_FLAG,
                             in_intl_text_id     =>var_inst_caption_id,
                             in_borders          =>NO_FLAG,
                             in_model_ref_expl_id=>var_model_ref_expl_id);

                             IF var_ref_ui_id IS NOT NULL THEN
                                generateUIProps(var_new_si_id,in_ui_def_id,DEF_CLASS,
                                                0, YES_FLAG, YES_FLAG,
                                                NO_FLAG, NO_FLAG, NO_FLAG,
                                                0, 'left', '0');
                             END IF;
            END IF;
         END IF; -- end of non-virtual --> virtual case --

         --
         -- virtual --> non-virtual --
         --
         IF (i.virtual_flag=NO_FLAG OR NOT(i.maximum=1 AND i.minimum=1)) THEN
             BEGIN
                 IF var_ui_node_type<>UI_BOM_INST_ITEM_TYPE AND BomType=NO_FLAG THEN
                    --
                    -- check : is there a button that associated with this reference --
                    --
                    BEGIN
                        SELECT YES_FLAG INTO existsButton FROM dual WHERE
                        EXISTS(SELECT NULL FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND parent_id<>var_limbo_id
                        AND ui_node_type=UI_BUTTON_TYPE AND ps_node_id=i.ps_node_id AND
                        deleted_flag=NO_FLAG);
                        RAISE BUTTON_EXISTS;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             NULL;
                    END;

                    --
                    -- create button "Add <reference>..." under the UI node var_ui_node_ref_id --
                    -- which is screen associated with parent node of this reference           --
                    curr_button_id:=getUISeqVal;
                    create_BUTTON(curr_button_id,var_parent_screen_id,in_ui_def_id,
                                  i.ps_node_id,'Add '||var_button_label,
                                  in_top_pos    =>DEFAULT_HEADER_HEIGHT,
                                  in_left_pos   =>LEFT_MARGIN,
                                  in_button_type=>DEF_ADD_BUTTON,
                                  in_modified_flag    => 0);


                    --
                    -- add new button to latest_buttons[] array                   --
                    -- this array will be used to rearrange buttons on the screen --
                    --
                    IF latest_buttons.Count=0 THEN
                       ind_:=1;
                    ELSE
                       ind_:=latest_buttons.Last+1;
                    END IF;
                    latest_buttons(ind_).id:=curr_button_id;
                 END IF;

                 IF var_ui_node_type=UI_BOM_STANDART_TYPE AND BomType=YES_FLAG THEN

                    BEGIN
/*
                        SELECT YES_FLAG INTO existsSTANDART_ITEM FROM dual WHERE
                        EXISTS(SELECT NULL FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND parent_id<>var_limbo_id
                        AND ui_node_type=UI_BOM_INST_ITEM_TYPE AND ps_node_id=i.ps_node_id AND
                        deleted_flag=NO_FLAG);
*/
                        UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG
                        WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_inst_ui_id AND ui_node_type=UI_BOM_STANDART_TYPE;

                        var_ui_node_id:=getUISeqVal;

                        BEGIN
                            SELECT 'Instances of '||text_str INTO var_caption_name
                            FROM CZ_INTL_TEXTS WHERE intl_text_id=var_screen_caption_id;
                        EXCEPTION
                            WHEN OTHERS THEN
                                 NULL;
                        END;

                        var_inst_text_label:=getUISeqVal;
                        create_TEXT_LABEL(var_inst_text_label,var_ref_parent_screen_id,in_ui_def_id,var_ui_node_id,
                                           in_top_pos          =>var_screen_top_pos,
                                           in_left_pos         =>LEFT_MARGIN,
                                           in_text             =>var_caption_name,
                                           in_font_name        =>DEFAULT_FONT_NAME_,
                                           in_font_color       =>0,
                                           in_font_size        =>DEFAULT_FONT_SIZE,
                                           in_align            =>'left',
                                           in_intl_text_id     =>null,
                                           in_parent_name      =>var_name,
                                           in_width            =>USABLE_WIDTH,
                                           in_ui_node_ref_id   =>var_ui_node_id,
                                           in_use_default_font =>YES_FLAG,
                                           in_display_flag     =>NO_FLAG,
                                           in_font_bold        =>NO_FLAG,
                                           in_font_italic      =>YES_FLAG,
                                           in_font_underline   =>NO_FLAG,
                                           in_title            =>NO_FLAG
                                           );

                        var_screen_top_pos:=var_screen_top_pos+DEFAULT_CONTROL_HEIGHT+DEFAULT_SPACE_BETWEEN;

                        set_UI_NODES (in_ui_node_id        =>var_ui_node_id,
                                       in_parent_id        =>var_ref_parent_screen_id,
                                       in_ui_def_id        =>in_ui_def_id,
                                       in_ps_node_id       =>var_inst_ps_id,
                                       in_ui_node_ref_id   =>var_inst_text_label,
                                       in_name             =>var_screen_name,
                                       in_component_id     =>var_inst_ps_id,
                                       in_ui_node_type     =>UI_BOM_INST_ITEM_TYPE,
                                       in_lce_id           =>'P_'||to_char(var_screen_ps_id),
                                       in_tree_display_flag=>YES_FLAG,
                                       in_tree_seq         =>var_ui_tree_seq,
                                       in_width            =>FLOOR(USABLE_WIDTH/2),
                                       in_height           =>DEFAULT_BOM_INST_ITEM_HEIGHT,
                                       in_top_pos          =>var_screen_top_pos,
                                       in_left_pos         =>LEFT_MARGIN,
                                       in_font_name        =>DEFAULT_FONT_NAME,
                                       in_font_bold        =>NO_FLAG,
                                       in_font_color       =>0,
                                       in_font_italic      =>NO_FLAG,
                                       in_font_size        =>DEFAULT_FONT_SIZE,
                                       in_font_underline   =>NO_FLAG,
                                       in_controltype      =>9,
                                       in_bkgrnd_style     =>YES_FLAG,
                                       in_intl_text_id     =>var_screen_caption_id,
                                       in_borders          =>YES_FLAG);


                           create_BUTTON(getUiSeqVal,var_ref_parent_screen_id,in_ui_def_id,var_screen_ps_node_id,
                                         ' Add ',
                                         in_top_pos          => var_screen_top_pos,
                                         in_left_pos         => CENTER_LINE+DEFAULT_SPACE_BETWEEN,
                                         in_button_type      => DEF_ADD_BUTTON,
                                         in_modified_flag    => YES_FLAG,
                                         in_ui_node_ref_id   => var_ui_node_id);

                           generateUIProps(var_ui_node_id,in_ui_def_id,
                                           DEF_INST_BOM,
                                           0, YES_FLAG, YES_FLAG,
                                           NO_FLAG, NO_FLAG, NO_FLAG,
                                           0, 'left', '0');

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             NULL;
                    END;
                  END IF;

                  BEGIN
                     existsDeleteMe:=NO_FLAG;
                     --
                     -- find Model_Id of the refrenced UI --
                     --
                     SELECT devl_project_id INTO var_model_id FROM CZ_UI_DEFS
                     WHERE ui_def_id=var_ref_id AND deleted_flag=NO_FLAG;

                     --
                     -- check Is there "Delete" button under the root screen --
                     -- of the referenced UI                                 --
                     -- ActionType='1' means that this is "Delete" action    --
                     --
                     SELECT  ui_node_id  INTO var_ui_root_id FROM CZ_UI_NODES
                     WHERE ui_def_id=var_ref_id AND ps_node_id=var_model_Id AND
                     ui_node_type IN(UI_PRODUCT_TYPE,UI_COMPONENT_TYPE,UI_BOM_OPTION_CLASS_TYPE)
                     AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

                     SELECT YES_FLAG INTO existsDeleteMe FROM dual WHERE
                     EXISTS(SELECT NULL FROM CZ_UI_NODES a WHERE
                     a.ui_def_id=var_ref_id AND a.ui_node_type=UI_BUTTON_TYPE AND a.parent_id=var_ui_root_id
                     AND a.parent_id<>var_limbo_id AND a.deleted_flag=NO_FLAG AND a.modified_flags=0
                     AND EXISTS(SELECT NULL FROM CZ_UI_NODE_PROPS b
                     WHERE b.ui_def_id=var_ref_id AND b.ui_node_id=a.ui_node_id
                     AND b.key_str='ActionType' AND b.value_str='1'));

                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          NULL;
                 END;

                 IF existsDeleteMe=NO_FLAG THEN
                    --
                    -- create Delete button under the root screen of the refrenced UI --
                    --
                    curr_button_id:=getUISeqVal;
                    create_BUTTON(curr_button_id,var_ui_root_id,var_ref_id,
                                  var_model_id,CZ_DELETE_BUTTON_CAPTION,
                                  in_top_pos    =>DELETE_BUTTON_TOP_POS,
                                  in_left_pos   =>DELETE_BUTTON_LEFT_POS,
                                  in_button_type=>DEF_DELETE_BUTTON,
                                  in_width      =>DELETE_BUTTON_WIDTH,
                                  in_modified_flag    => 0);
                 END IF;

             EXCEPTION
                  WHEN BUTTON_EXISTS THEN
                       NULL;
             END;
         END IF;
      END IF; -- end of virtual --> non-virtual  case --

      END IF; -- end of  var_curr_virtual_flag<>i.virtual_flag case --

      --
      -- handle BOM Models and Option Classes --
      --
      IF i.ps_node_type IN(BOM_CLASS_NODE_TYPE,BOM_MODEL_NODE_TYPE) THEN

          ind_arr:=footer_buttons.Count+1;
          footer_buttons(ind_arr).ui_parent_id:=var_screen_ui_id;

                BEGIN
                    --
                    -- for a given BOM OPTION CLASS
                    -- find BOM STANDART ITEM on the parent screen
                    -- both VOM OPTION CLASS and BOM STANDART ITEM
                    -- have the same ps_node_id
                    --
                    SELECT ui_node_id
                    INTO var_ui_parent_item_id
                    FROM CZ_UI_NODES
                    WHERE ui_def_id=in_ui_def_id AND
                    ui_node_type=UI_BOM_STANDART_TYPE AND parent_id=
                    (SELECT ui_node_ref_id FROM CZ_UI_NODES
                     WHERE  ui_def_id=in_ui_def_id AND ui_node_id=
                    (SELECT parent_id FROM CZ_UI_NODES
                     WHERE  ui_def_id=in_ui_def_id AND ui_node_ref_id=t_bom_pages(1).ui_node_id
                     AND deleted_flag=NO_FLAG)) AND ps_node_id=t_bom_pages(1).ps_node_id;

                    UPDATE CZ_UI_NODES
                    SET name=i.name
                    WHERE  ui_def_id=in_ui_def_id AND ui_node_id=var_ui_parent_item_id
                    AND modified_flags=0 AND deleted_flag=NO_FLAG;

                    SELECT caption_id INTO var_parent_item_txt_id
                    FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_ui_parent_item_id;

                EXCEPTION
                    WHEN OTHERS THEN
                         NULL;
                END;

          IF t_bom_pages.Count=1 THEN

             /* *** name of the reference should be = PS node's name *** */
             IF i.name<>var_screen_name THEN
                UPDATE CZ_UI_NODES SET name=i.name
                WHERE ui_def_id=in_ui_def_id
                AND ui_node_id=var_screen_ui_id;

                UPDATE CZ_INTL_TEXTS SET text_str=i.name
                WHERE intl_text_id=var_screen_caption_id;

               IF i.intl_text_id IS NULL THEN
                   UPDATE CZ_INTL_TEXTS SET text_str=i.name
                   WHERE intl_text_id IN(var_label_txt_id,var_parent_item_txt_id)
                   AND var_modified_flags=0;
                END IF;
             END IF;

             FOR l IN(SELECT intl_text_id,language,localized_str
                      FROM CZ_LOCALIZED_TEXTS WHERE intl_text_id=i.intl_text_id)
             LOOP
                var_label:=i.name;
                var_label:=get_Caption(i.name,l.localized_str);
                UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
                WHERE intl_text_id IN(var_label_txt_id,var_parent_item_txt_id)
                AND language=l.language AND var_modified_flags=0;

                UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
                WHERE intl_text_id=var_tree_caption_id AND language=l.language;
             END LOOP;

             var_use_labels:=mUSE_LABELS;
             BEGIN
                 SELECT value_str INTO var_use_labels FROM CZ_UI_NODE_PROPS
                 WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_ui_id
                 AND UPPER(key_str)='USELABELS' AND deleted_flag=NO_FLAG ;
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  NULL;
             END;
             update_Labels(var_screen_ui_id,var_use_labels);
         END IF;

         --
         -- multi pages case --
         --
         IF t_bom_pages.Count>1 THEN

            FOR x IN t_bom_pages.First..t_bom_pages.Last
            LOOP
               IF x>0 THEN
                  var_suffix:=' ('||TO_CHAR(x)||')';
               ELSE
                  var_suffix:='';
               END IF;

               /* *** name of the reference should be = PS node's name *** */
               IF i.name<>t_bom_pages(x).name THEN
                  UPDATE CZ_UI_NODES SET name=i.name||var_suffix
                  WHERE ui_def_id=in_ui_def_id AND ui_node_id=t_bom_pages(x).ui_node_id;

                  UPDATE CZ_INTL_TEXTS SET text_str=i.name||var_suffix
                  WHERE intl_text_id=t_bom_pages(x).text_id;

                  IF i.intl_text_id IS NULL THEN
                     UPDATE CZ_INTL_TEXTS SET text_str=i.name||var_suffix
                     WHERE intl_text_id=t_bom_pages(x).label_txt_id
                     AND var_modified_flags=0;

                     --
                     -- do it just first page --
                     -- update label of STANDTART ITEMS on the parent screen
                     -- which correlates with current BOM Option Class
                     --
                     IF x=1 THEN
                        FOR m IN(SELECT intl_text_id,language,localized_str
                                 FROM CZ_LOCALIZED_TEXTS WHERE intl_text_id=i.intl_text_id)
                        LOOP
                           var_label:=i.name;
                           var_label:=get_Caption(i.name,m.localized_str);
                           UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
                           WHERE intl_text_id=var_parent_item_txt_id AND language=m.language;
                        END LOOP;
                     END IF;

                  END IF;
                END IF;

                FOR l IN(SELECT intl_text_id,language,localized_str
                         FROM CZ_LOCALIZED_TEXTS WHERE intl_text_id=i.intl_text_id)
                LOOP
                   var_label:=i.name;
                   var_label:=get_Caption(i.name,l.localized_str);

                   UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label||var_suffix
                   WHERE intl_text_id=t_bom_pages(x).label_txt_id AND language=l.language
                   AND var_modified_flags=0;

                   UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label||var_suffix
                   WHERE intl_text_id=t_bom_pages(x).tree_label_id AND language=l.language;

                   IF x=1 THEN
                      UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
                      WHERE intl_text_id=var_parent_item_txt_id AND language=l.language;
                   END IF;

                END LOOP;

                var_use_labels:=mUSE_LABELS;
                BEGIN
                    SELECT value_str INTO var_use_labels FROM CZ_UI_NODE_PROPS
                    WHERE ui_def_id=in_ui_def_id AND ui_node_id=t_bom_pages(x).ui_node_id
                    AND UPPER(key_str)='USELABELS' AND deleted_flag=NO_FLAG ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                   NULL;
            END;
            update_Labels(t_bom_pages(x).ui_node_id,var_use_labels);
         END LOOP;
        END IF;
      END IF;


      IF i.ps_node_type IN(COMPONENT_NODE_TYPE,PRODUCT_NODE_TYPE,BOM_MODEL_NODE_TYPE) THEN

          ind_arr:=footer_buttons.Count+1;
          footer_buttons(ind_arr).ui_parent_id:=var_screen_ui_id;

         /* *** name of the reference should be = PS node's name *** */
         IF i.name<>var_screen_name THEN
            UPDATE CZ_UI_NODES SET name=i.name
            WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_ui_id
            AND modified_flags=0;
            UPDATE CZ_INTL_TEXTS SET text_str=i.name
            WHERE intl_text_id=var_screen_caption_id AND var_modify_ui_flag=0;
            IF i.intl_text_id IS NULL THEN
               UPDATE CZ_INTL_TEXTS SET text_str=i.name
               WHERE intl_text_id=var_text_label_caption_id
               AND var_modified_flags=0;
            END IF;
         END IF;

         /* *** go through all languages and update captions of the reference *** */
         var_label:=i.name;
         var_button_label:=var_label;
         FOR l IN(SELECT intl_text_id,language,localized_str FROM CZ_LOCALIZED_TEXTS
                  WHERE intl_text_id=i.intl_text_id)
         LOOP
            var_label:=i.name;
            var_label:=get_Caption(i.name,l.localized_str);
            UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
            WHERE intl_text_id=var_text_label_caption_id AND language=l.language
            AND var_modified_flags=0;

            UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
            WHERE intl_text_id=var_tree_caption_id AND language=l.language;
            IF l.language=mCURRENT_LANG THEN
               var_button_label:=var_label;
               var_width:=set_Title_Width(var_label);
               UPDATE CZ_UI_NODES SET width=var_width
               WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_text_label_id
               AND modified_flags=0;
            END IF;
         END LOOP;

         /* *** find IsVirtual property for UI node from Component Tree which            *** */
         /* *** is associated with screen of this Component/Products/BOM Model/BOM Class *** */

         SELECT value_str INTO var_curr_virtual_flag FROM CZ_UI_NODE_PROPS WHERE
         ui_def_id=in_ui_def_id AND ui_node_id=var_tree_ui_id AND key_str='IsVirtual'
         AND deleted_flag=NO_FLAG;

         /* ***
         SELECT value_str INTO var_curr_max FROM CZ_UI_NODE_PROPS WHERE
         ui_def_id=in_ui_def_id AND ui_node_id=var_tree_ui_id AND key_str='Max'
         AND deleted_flag=NO_FLAG;

         SELECT value_str INTO var_curr_min FROM CZ_UI_NODE_PROPS WHERE
         ui_def_id=in_ui_def_id AND ui_node_id=var_tree_ui_id AND key_str='Min'
         AND deleted_flag=NO_FLAG;
         */

         IF var_curr_virtual_flag<>i.virtual_flag THEN

            /* *** synchronize virtual_flag in UI and PS tree *** */
            generateUIProps(var_tree_ui_id,in_ui_def_id,DEF_COMPONENT_SCREEN,
                            0, i.minimum, i.maximum,
                            NO_FLAG, YES_FLAG, i.virtual_flag,
                            0, 'left', '0');

            /* *** virtual --> non-virtual case *** */
            IF i.virtual_flag=NO_FLAG THEN

               /* ***  create "Delete" button under the screen for the current Component/Products/... *** */
               curr_button_id:=getUISeqVal;
               create_BUTTON(curr_button_id,var_screen_ui_id,in_ui_def_id,
                             i.ps_node_id,CZ_DELETE_BUTTON_CAPTION,
                             in_top_pos    =>DELETE_BUTTON_TOP_POS,
                             in_left_pos   =>DELETE_BUTTON_LEFT_POS,
                             in_button_type=>DEF_DELETE_BUTTON,
                             in_width      =>DELETE_BUTTON_WIDTH,
                             in_modified_flag    => 0);

               UPDATE CZ_UI_NODES SET component_id=i.ps_node_id,ps_node_id=i.ps_node_id
               WHERE ui_node_id=var_tree_ui_id AND ui_def_id=in_ui_def_id AND ui_node_type=UI_COMPONENT_REF_TYPE;

               /* *** create "Add ..." button under the parent node's screen *** */
               curr_button_id:=getUISeqVal;
               create_BUTTON(curr_button_id,var_parent_screen_id,in_ui_def_id,
                             i.ps_node_id,'Add '||var_button_label,
                             in_top_pos    =>DEFAULT_HEADER_HEIGHT,
                             in_left_pos   =>LEFT_MARGIN,
                             in_button_type=>DEF_ADD_BUTTON,
                             in_modified_flag    => 0);

               /* *** populate latest_buttons[] array that will be used     *** */
               /* *** to rearrange buttons at the second part of UI refresh *** */
               IF latest_buttons.Count=0 THEN
                  ind_:=1;
               ELSE
                  ind_:=latest_buttons.Last+1;
               END IF;
               latest_buttons(ind_).id:=curr_button_id;

            END IF; /* *** end of virtual --> non-virtual case *** */

         /* *** non-virtual --> virtual case *** */

         IF i.virtual_flag=YES_FLAG THEN
            --
            -- remove non-customized buttons which have ActionType= '0'( "Add" button ) --
            -- or ActionType= '1'( "Delete" button )                                    --
            --
            UPDATE CZ_UI_NODES a SET a.deleted_flag=YES_FLAG
            WHERE ui_def_id=in_ui_def_id AND
            ps_node_id=i.ps_node_id AND
            ui_node_type=UI_BUTTON_TYPE AND modified_flags=0 AND deleted_flag=NO_FLAG;
         END IF;  -- end of non-virtual --> virtual case --

      END IF; -- end of var_curr_virtual_flag<>i.virtual_flag case --
    END IF; -- end of COMPONENT case

   --
   -- synchronize PS names/labels and UI captions --
   --
   IF i.ps_node_type IN(RESOURCE_NODE_TYPE,TOTAL_NODE_TYPE,CONNECTOR_NODE_TYPE) THEN
      --
      -- name of the reference should be = PS node's name --
      --
      IF i.name<>var_screen_name THEN
         UPDATE CZ_UI_NODES SET name=i.name
         WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_ui_id
         AND modified_flags=0;
         UPDATE CZ_INTL_TEXTS SET text_str=i.name
         WHERE intl_text_id=var_screen_caption_id AND var_modify_ui_flag=0;
         IF i.intl_text_id IS NULL THEN
            UPDATE CZ_INTL_TEXTS SET text_str=i.name
            WHERE intl_text_id=var_text_label_caption_id
            AND var_modified_flags=0;
         END IF;
      END IF;

     /* *** go through all languages and update captions  *** */
      var_label:=i.name;
      FOR l IN(SELECT a.intl_text_id,a.language,a.localized_str FROM CZ_LOCALIZED_TEXTS a
               WHERE a.intl_text_id=i.intl_text_id)

      LOOP
         var_label:=i.name;
         var_label:=get_Caption(i.name,l.localized_str);

         UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
         WHERE intl_text_id=var_text_label_caption_id AND language=l.language
         AND var_modified_flags=0;

         IF l.language=mCURRENT_LANG THEN
            var_width:=set_Text_Width(var_label);
            IF var_width <= SCREEN_HALF THEN
               var_width:=SCREEN_HALF;
            END IF;

            UPDATE CZ_UI_NODES SET width=var_width
            WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_text_label_id
            AND modified_flags=0;
         END IF;

      END LOOP;
    END IF;

    /* ****************Update Options Labels *************** */
/*
    IF i.ps_node_type=OPTION_NODE_TYPE THEN

       IF i.name<>var_screen_name THEN
          UPDATE CZ_UI_NODES SET name=i.name
          WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_ui_id;
       END IF;

       var_use_labels:='1';
       BEGIN
           SELECT value_str INTO var_use_labels FROM CZ_UI_NODE_PROPS
           WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_parent_id AND UPPER(key_str)='USELABELS'
           AND deleted_flag=NO_FLAG ;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;
       END;

       var_label:=i.name;
       FOR l IN(SELECT a.intl_text_id,a.language,a.localized_str FROM CZ_LOCALIZED_TEXTS a
                WHERE a.intl_text_id=i.intl_text_id)
       LOOP
          var_label:=i.name;
          IF var_use_labels='0' THEN
             var_label:=i.name;
          ELSIF var_use_labels='1' THEN
             var_label:=l.localized_str;
          ELSIF var_use_labels='3' THEN
             var_label:=i.name||mCONCAT_SYMBOL||l.localized_str;
          END IF;


          UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
          WHERE intl_text_id=var_screen_caption_id AND language=l.language;

       END LOOP;

    END IF;

*** */


   /* *** Check if this is a changed feature  *** */
   IF i.ps_node_type=FEATURE_NODE_TYPE THEN

      /* *** name of the reference should be = PS node's name *** */
      IF i.name<>var_screen_name THEN
         UPDATE CZ_UI_NODES SET name=i.name
         WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_ui_id
         AND modified_flags=0 ;
         UPDATE CZ_INTL_TEXTS SET text_str=i.name
         WHERE intl_text_id=var_screen_caption_id AND var_modify_ui_flag=0;
         IF i.intl_text_id IS NULL THEN
            UPDATE CZ_INTL_TEXTS SET text_str=i.name
            WHERE intl_text_id=var_text_label_caption_id
            AND var_modified_flags=0;
         END IF;
      END IF;

     /* *** go through all languages and update captions *** */
      var_label:=i.name;
      FOR l IN(SELECT intl_text_id,language,localized_str FROM CZ_LOCALIZED_TEXTS
               WHERE intl_text_id=i.intl_text_id)
      LOOP
         var_label:=i.name;
         var_label:=get_Caption(i.name,l.localized_str);

         UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
         WHERE intl_text_id=var_text_label_caption_id AND language=l.language
         AND var_modified_flags=0;

         /* *** for now don't change width of label ***
         IF l.language=mCURRENT_LANG THEN
            var_width:=set_Text_Width(var_label);
            UPDATE CZ_UI_NODES SET width=var_width
            WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_text_label_id
            AND modified_flags=0;
         END IF;
         */

      END LOOP;

      var_borders:=YES_FLAG;
      var_width:=OPTION_FEATURE_WIDTH;

      IF i.feature_type=0 THEN
         var_feature_type:='0';   ---- Options List ----
         var_borders:=NO_FLAG;
         IF i.counted_options_flag='1' OR i.maximum>1 OR i.maximum IS NULL THEN
            var_borders:=YES_FLAG;
            var_control_type:=2;
         ELSE
            var_control_type:=1;
         END IF;

         BEGIN
             var_ui_max:=NULL;
             SELECT TO_NUMBER(value_str) INTO var_ui_max FROM CZ_UI_NODE_PROPS
             WHERE ui_node_id=var_screen_ui_id AND key_str='Max' AND deleted_flag=NO_FLAG;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         END;

         BEGIN
             var_ui_min:=NULL;
             SELECT TO_NUMBER(value_str) INTO var_ui_min FROM CZ_UI_NODE_PROPS
             WHERE ui_node_id=var_screen_ui_id AND key_str='Min' AND deleted_flag=NO_FLAG;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         END;

         BEGIN
             var_ui_counted_options:=NO_FLAG;
             SELECT value_str INTO var_ui_counted_options FROM CZ_UI_NODE_PROPS
             WHERE ui_node_id=var_screen_ui_id AND key_str='CountedOptions' AND deleted_flag=NO_FLAG;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         END;

         var_use_labels:=mUSE_LABELS;
         BEGIN
             SELECT value_str INTO var_use_labels FROM CZ_UI_NODE_PROPS
             WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_screen_ui_id AND UPPER(key_str)='USELABELS'
             AND deleted_flag=NO_FLAG;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         END;

         --
         -- Update Options Labels --
         --
         FOR m IN(SELECT ps_node_id,intl_text_id,tree_seq,name FROM CZ_PS_NODES
                  WHERE devl_project_id=Project_Id
                  AND parent_id=i.ps_node_id AND deleted_flag=NO_FLAG AND ui_omit=NO_FLAG)
         LOOP
            BEGIN
                var_label:=NULL;
                var_option_ui_id:=NULL;
                var_option_caption_id:=NULL;
                var_option_ui_name:=NULL;
                var_ui_tree_seq:=NULL;
                var_option_ps_id:=NULL;

                SELECT ui_node_id,caption_id,name,tree_seq,ps_node_id
                INTO var_option_ui_id,var_option_caption_id,
                var_option_ui_name,var_ui_tree_seq,var_option_ps_id
                FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND ps_node_id=m.ps_node_id
                AND deleted_flag=NO_FLAG AND parent_id<>var_limbo_id AND modified_flags=0;

                IF m.tree_seq<>var_ui_tree_seq THEN
                   UPDATE CZ_UI_NODES SET tree_seq=m.tree_seq
                   WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_option_ui_id;
                END IF;

                IF var_use_labels<>USE_PROPERTY_DESCRIPTIONS THEN
                   IF m.name<>var_option_ui_name THEN
                      UPDATE CZ_UI_NODES SET name=m.name
                      WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_option_ui_id;
                      var_label:=m.name;

                      IF m.intl_text_id IS NULL THEN
                         UPDATE CZ_LOCALIZED_TEXTS SET localized_str=m.name
                         WHERE intl_text_id=var_option_caption_id;
                      END IF;

                   END IF;

                   var_label:=m.name;
                   FOR l IN(SELECT a.intl_text_id,a.language,a.localized_str FROM CZ_LOCALIZED_TEXTS a
                               WHERE a.intl_text_id=m.intl_text_id)
                   LOOP
                      var_label:=get_Caption(m.name,l.localized_str,var_use_labels);
                      UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_label
                      WHERE intl_text_id=var_option_caption_id AND language=l.language;
                   END LOOP;

                ELSE
                   var_label:=getTextByProperty(var_option_ps_id,var_screen_ui_id);
                   UPDATE CZ_INTL_TEXTS SET text_str=var_label
                   WHERE intl_text_id=var_option_caption_id;
                END IF;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         NULL;
                    WHEN OTHERS THEN
                         LOG_REPORT('CZ_UI_GENERATOR.refreshUI','Update Options Labels < ui_def_id='||TO_CHAR(in_ui_def_id)||' > : '||SQLERRM,
                                    CZ_ERROR_URGENCY);
                END;
            END LOOP;

         /* ***************************************************** */

      END IF;

       IF i.feature_type=3 THEN
          var_feature_type:='1';
          var_control_type:='3';
          var_borders:=NO_FLAG;
          var_width:=BOOLEAN_FEATURE_WIDTH;
       END IF;

       IF i.feature_type=1 THEN
          var_feature_type:='2';
          var_control_type:=4;
          var_width:=NUMERIC_FEATURE_WIDTH;
       END IF;

       IF i.feature_type=2 THEN
          var_feature_type:='3';
          var_control_type:=5;
          var_width:=NUMERIC_FEATURE_WIDTH;
       END IF;

       IF i.feature_type=4 THEN
          var_feature_type:='4';
          var_control_type:=6;
       END IF;

       SELECT TO_NUMBER(value_str) INTO var_ui_feature_type FROM CZ_UI_NODE_PROPS
       WHERE ui_node_id=var_screen_ui_id AND key_str='FeatureType' AND deleted_flag=NO_FLAG;

       /* *** changed Feature type case *** */
       IF var_ui_feature_type<>var_feature_type OR
          NOT( NVL(var_ui_max,-1)=NVL(i.maximum,-1) AND NVL(var_ui_min,-1)=NVL(i.minimum,-1))
          OR var_ui_counted_options<>i.counted_options_flag  THEN

             IF var_ui_feature_type=var_feature_type AND var_feature_type='0' AND
                ((i.maximum=1 AND i.maximum=1) AND i.counted_options_flag=NO_FLAG) AND
                (NOT(var_ui_max=1 AND var_ui_min=1) OR var_ui_counted_options=YES_FLAG) THEN
                --
                -- if we update feature max from n to 1 don't update
                -- control type ( it still should be "List Of Options" )
                --
                NULL;
             ELSE
                --
                -- if we change Feature from Counted Options or max>1  to max=1
                -- and no Counted Options then don't change Control Type ( should be
                -- Selection List) otherwise update Control Type
                -- according with current Feature Type
                --
                IF NOT(i.feature_type=0 AND var_control_type=1 AND var_ui_control_type=2) THEN
                  UPDATE CZ_UI_NODES
                  SET controltype=var_control_type
                  WHERE  ui_node_id=var_screen_ui_id AND parent_id<>var_limbo_id;
                END IF;
                UPDATE CZ_UI_NODES SET width=var_width,
                                       borders=var_borders
                WHERE  ui_node_id=var_screen_ui_id AND parent_id<>var_limbo_id
                AND modified_flags=0;
             END IF;
          /* *** synchronize UI and Ps tree properties of the feature *** */
          generateUIProps(var_screen_ui_id,in_ui_def_id,DEF_FEATURE,
                          i.feature_type, i.minimum, i.maximum,
                          i.counted_options_flag,
                          YES_FLAG,
                          NO_FLAG, 0, 'left', '0');


          IF var_ui_feature_type='0' OR  i.feature_type=0 THEN

            /* *** delete OPTIONs - List Of Options *** */
            UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG WHERE ui_node_id IN
            (SELECT ui_node_id FROM CZ_UI_NODES WHERE parent_id=var_screen_ui_id
             AND ui_node_type=UI_OPTION_TYPE AND deleted_flag=NO_FLAG);

          END IF; /* *** end of var_ui_feature_type='0' OR  i.feature_type=0 case *** */

          /* *** counted/Max options case for Feature *** */

          IF i.feature_type in(1,2,3,4) THEN
             -- change height of the feature --
             UPDATE CZ_UI_NODES
             SET height=DEFAULT_CONTROL_HEIGHT
             WHERE ui_node_id=var_screen_ui_id AND modified_flags=0;
          END IF;
     END IF;
   END IF;

   EXCEPTION
      WHEN NEXT_ITTERATION THEN
           NULL;
      WHEN NO_DATA_FOUND THEN
           FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME||' for the node '||i.name,'CZ_UI_GENERATOR.refreshUI',
                      CZ_ERROR_URGENCY);
  END;
END LOOP;

/*******************************************************/
/*******************************************************/

IF news.Count>0 OR boms.Count>0 THEN

/* *** main LOOP for UI refresh *** */
k:=news.First;
LOOP
    IF k IS NULL THEN
       EXIT;
    END IF;

    BEGIN
    IF news(k).parent_id IS NOT NULL THEN
       new_parent:=news(news(k).parent_id).id;           -- find new parent node id
    ELSE
       new_parent:=var_comp_tree_id;
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         IF  news(k).ps_node_type IN (PRODUCT_NODE_TYPE,COMPONENT_NODE_TYPE,REFERENCE_NODE_TYPE,
             BOM_CLASS_NODE_TYPE,BOM_MODEL_NODE_TYPE) THEN
             SELECT MAX(ui_node_id) INTO temp_node FROM CZ_UI_NODES WHERE
             ps_node_id=news(k).parent_id AND ui_node_ref_id IS NOT NULL AND
             ui_node_type IN(UI_COMPONENT_TYPE,UI_REFERENCE_REF_TYPE,BOM_CLASS_NODE_TYPE,BOM_MODEL_NODE_TYPE)
             AND ui_def_id=in_ui_def_id AND deleted_flag=NO_FLAG;
             SELECT ui_node_id INTO new_parent FROM CZ_UI_NODES
             WHERE ui_node_ref_id=temp_node AND ui_def_id=in_ui_def_id
             AND ui_node_type=UI_COMPONENT_REF_TYPE AND deleted_flag=NO_FLAG;
         END IF;
    END;

    new_child:=news(k).id;                               -- find new Tree node id

    curr_node_id:=getUISeqVal;
    curr_label_id:=getUISeqVal;
    curr_bitmap_id:=getUISeqVal;

    var_name:='Text-'||TO_CHAR(curr_label_id);

    /* ************************** create PRODUCTs ******************************* */

    IF news(k).ps_node_type=PRODUCT_NODE_TYPE  THEN

         --
         -- find ui_node_id of the parent screen
         --
         IF news(k).virtual_flag = NO_FLAG THEN
            BEGIN
                var_parent_id:=NULL;
                SELECT ui_node_ref_id INTO var_parent_id FROM CZ_UI_NODES
                WHERE ui_def_id=in_ui_def_id AND ui_node_id=new_parent AND deleted_flag=NO_FLAG;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IF news.EXISTS(news(k).parent_id) THEN
                        var_parent_id:=news(news(k).parent_id).ui_node_ref_id;
                     ELSE
                        FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,TO_CHAR(var_parent_id),CZ_ERROR_URGENCY);
                     END IF;
            END;
         END IF;


       create_PRODUCT(news(k).ui_node_ref_id,var_root_id,in_ui_def_id,news(k));

       /* *** create PRODUCT node for Model Tree *** */
       create_PRODUCT_Model(new_child,new_parent,in_ui_def_id,news(k).ui_node_ref_id,news(k));

       /* *** create FEATUREs,TOTALs,RESORCEs *** */
       generate_FTR(news(k).ps_node_id,news(k).ui_node_ref_id,in_ui_def_id);

       IF mWIZARD_STYLE=YES_FLAG  AND mUI_STYLE=DHTML_STYLE_UI THEN
          ind_arr:=footer_buttons.Count+1;
          footer_buttons(ind_arr).id:=getUISeqVal;
          footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
          footer_buttons(ind_arr).rel_top_pos:=last_TOP_POS;
       END IF;

       /* *** create MODELs,CLASSEs,STANDARTs *** */
       generate_MCS(news(k).ps_node_id,news(k).ui_node_ref_id,in_ui_def_id,NO_FLAG);


    END IF;  -- for PRODUCT

       /* ************************** create COMPONENTs ******************************* */

       IF news(k).ps_node_type=COMPONENT_NODE_TYPE THEN

         --
         -- find ui_node_id of the parent screen
         --
         IF news(k).virtual_flag = NO_FLAG THEN
            BEGIN
                var_parent_id:=NULL;
                SELECT ui_node_ref_id INTO var_parent_id FROM CZ_UI_NODES
                WHERE ui_def_id=in_ui_def_id AND ui_node_id=new_parent AND deleted_flag=NO_FLAG;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IF news.EXISTS(news(k).parent_id) THEN
                        var_parent_id:=news(news(k).parent_id).ui_node_ref_id;
                     ELSE
                        FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,TO_CHAR(var_parent_id),CZ_ERROR_URGENCY);
                     END IF;
            END;
         END IF;

         create_COMPONENT(news(k).ui_node_ref_id,var_root_id,in_ui_def_id,
                           var_parent_id,news(k));


          /* *** create COMPONENT node for Model Tree *** */
          create_COMPONENT_Model(new_child,new_parent,in_ui_def_id,news(k).ui_node_ref_id,news(k));

          generate_FTR(news(k).ps_node_id,news(k).ui_node_ref_id,in_ui_def_id);

          IF mWIZARD_STYLE=YES_FLAG  AND mUI_STYLE=DHTML_STYLE_UI THEN
             ind_arr:=footer_buttons.Count+1;
             footer_buttons(ind_arr).id:=getUISeqVal;
             footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
             footer_buttons(ind_arr).rel_top_pos:=last_TOP_POS;
          END IF;

        END IF; ---- for COMPONENT

        IF news(k).ps_node_type=REFERENCE_NODE_TYPE THEN

           --
           -- find ui_node_id of the parent screen
           --
           IF news(k).virtual_flag = NO_FLAG THEN
              BEGIN
                  var_parent_id:=NULL;
                  SELECT ui_node_ref_id INTO var_parent_id FROM CZ_UI_NODES
                  WHERE ui_def_id=in_ui_def_id AND ui_node_id=new_parent AND deleted_flag=NO_FLAG;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       IF news.EXISTS(news(k).parent_id) THEN
                          var_parent_id:=news(news(k).parent_id).ui_node_ref_id;
                       ELSE
                          FND_REPORT(CZ_UI_GEN_NO_BUTTONS,TOKEN_UI_NODE,TO_CHAR(var_parent_id),CZ_ERROR_URGENCY);
                       END IF;
              END;
           END IF;

           BEGIN
           existRefUI:='0';
           SELECT '1' INTO existRefUI FROM dual WHERE
           EXISTS(SELECT 1 FROM CZ_UI_DEFS WHERE devl_project_id=news(k).reference_id AND ui_style=mUI_STYLE
           AND deleted_flag=NO_FLAG);
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
           END;

           IF existRefUI='0' THEN
              var_temp:=Project_Id;

              t_news:=news;
              t_boms:=boms;
              t_features:=features;
              t_Options:=Options;
              t_add_buttons:=add_buttons;
              t_footer_buttons:=footer_buttons;
              t_latest_buttons:=latest_buttons;
              t_ref_boms:=ref_boms;

              createui(in_product_id      =>news(k).reference_id,
                       out_ui_def_id      =>var_out_ui_def_id,
                       out_run_id         =>out_run_id,
                       in_ui_style        =>mUI_STYLE,
                       in_frame_allocation=>var_frame_allocation,
                       in_width           =>var_screen_width,
                       in_height          =>var_screen_height,
                       in_show_all_nodes  =>'0',
                       in_use_labels      =>mUSE_LABELS,
                       in_look_and_feel   =>mLOOK_AND_FEEL,
                       in_max_bom_per_page=>mITEMS_ON_PAGE,
                       in_wizard_style    =>mWIZARD_STYLE);

              news:=t_news;
              boms:=t_boms;
              features:=t_features;
              Options:=t_Options;
              add_buttons:=t_add_buttons;
              footer_buttons:=t_footer_buttons;
              latest_buttons:=t_latest_buttons;
              ref_boms:=t_ref_boms;

              Project_Id:=var_temp;
              t_ref_uis(news(k).ps_node_id):=var_out_ui_def_id;

           END IF;

           BEGIN
               SELECT ui_node_ref_id INTO var_ref_to_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
               AND ui_node_id=new_parent AND ui_node_type=UI_COMPONENT_REF_TYPE AND
               parent_id<>var_limbo_id AND deleted_flag=NO_FLAG;

               create_REFERENCE_Model(new_child,new_parent,in_ui_def_id,
                                      var_ref_to_id,news(k),var_ref_ui);
               t_ref_uis(news(k).ps_node_id):=var_ref_ui;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    LOG_REPORT('CZ_UI_GENERATOR.refreshUI','Reference '||news(k).name||' can not be created.',
                               CZ_ERROR_URGENCY);
           END;


        END IF; ---- for REFERENCE

      /* ***************************************************************** */
      /* ************************* BOM section *************************** */
      /* ***************************************************************** */

      IF news(k).ps_node_type=BOM_MODEL_NODE_TYPE THEN

         createBOM_MODEL(news(k).ui_node_ref_id,var_root_id,in_ui_def_id,news(k));

         /* *** create record for Model Tree *** */
         createBOM_MODEL_Model(new_child,new_parent,in_ui_def_id,news(k).ui_node_ref_id,news(k));

         IF mWIZARD_STYLE=YES_FLAG AND mUI_STYLE=DHTML_STYLE_UI THEN
            ind_arr:=footer_buttons.Count+1;
            footer_buttons(ind_arr).id:=getUISeqVal;
            footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
            footer_buttons(ind_arr).rel_top_pos:=last_TOP_POS;
         END IF;

         generate_MCS(news(k).ps_node_id,news(k).ui_node_ref_id,in_ui_def_id, NO_FLAG);

      END IF; -- for BOM_MODEL


      IF news(k).ps_node_type=BOM_CLASS_NODE_TYPE  and news(k).ui_omit=NO_FLAG THEN

         createBOM_CLASS(news(k).ui_node_ref_id,var_root_id,in_ui_def_id,news(k));

         /* *** create record for Model Tree *** */
         createBOM_CLASS_Model(new_child,new_parent,
                               in_ui_def_id,news(k).ui_node_ref_id,news(k));

         IF mWIZARD_STYLE=YES_FLAG  AND mUI_STYLE=DHTML_STYLE_UI THEN
            ind_arr:=footer_buttons.Count+1;
            footer_buttons(ind_arr).id:=getUISeqVal;
            footer_buttons(ind_arr).ui_parent_id:=news(k).ui_node_ref_id;
         END IF;

         generate_MCS(in_parent_node_id     =>news(k).ps_node_id,
                      in_new_parent_id      =>news(k).ui_node_ref_id,
                      in_ui_def_id          =>in_ui_def_id,
                      in_mode               =>'0',
                      in_ui_tree_parent_id  =>new_parent,
                      in_ui_parent_id       =>var_root_id,
                      in_parent_text_id     =>news(k).intl_text_id,
                      in_parent_name        =>news(k).name,
                      in_tree_seq           =>news(k).tree_seq);

         BEGIN

         SELECT ui_node_ref_id INTO var_temp FROM CZ_UI_NODES WHERE
         ui_def_id=in_ui_def_id AND ui_node_id=new_parent;

         SELECT MAX(rel_top_pos) INTO last_TOP_POS FROM CZ_UI_NODES
         WHERE ui_def_id=in_ui_def_id AND parent_id=var_temp AND parent_id<>var_limbo_id
         AND modified_flags<>CZ_NAVIGATION_MARK AND deleted_flag=NO_FLAG;

         var_width:=set_Text_Width(news(k).caption_name)+80;
         IF var_width<=USABLE_WIDTH THEN
            var_width:=USABLE_WIDTH;
         END IF;

         IF mLOOK_AND_FEEL='BLAF' THEN
            var_use_default_color:=YES_FLAG;
         ELSE
            var_use_default_color:=NO_FLAG;
         END IF;

         IF last_TOP_POS<=START_TOP_POS THEN
            last_TOP_POS:=START_TOP_POS+DEFAULT_SPACE_BETWEEN;
         ELSE
            last_TOP_POS:=last_TOP_POS+DEFAULT_BOM_HEIGHT+DEFAULT_SPACE_BETWEEN;
         END IF;

         BEGIN
             SELECT model_ref_expl_id INTO var_model_ref_expl_id
             FROM CZ_MODEL_REF_EXPLS WHERE model_id=Project_Id
             AND parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG;
         EXCEPTION
             WHEN OTHERS THEN
                  var_model_ref_expl_id:=NULL;
         END;

         var_oc_standart_item:=getUISeqVal;
         set_UI_NODES(in_ui_node_id    =>var_oc_standart_item,
                   in_parent_id        =>var_temp,
                   in_ui_def_id        =>in_ui_def_id,
                   in_ps_node_id       =>news(k).ps_node_id,
                   in_ui_node_ref_id   =>news(k).ui_node_ref_id,
                   in_name             =>news(k).name,
                   in_component_id     =>news(k).parent_id,
                   in_ui_node_type     =>UI_BOM_STANDART_TYPE,
                   in_lce_id           =>'P_'||to_char(news(k).ps_node_id),
                   in_tree_display_flag=>YES_FLAG,
                   in_tree_seq         =>news(k).tree_seq,
                   in_width            =>var_width,
                   in_height           =>DEFAULT_BOM_HEIGHT,
                   in_top_pos          =>last_TOP_POS,
                   in_left_pos         =>LEFT_MARGIN,
                   in_font_name        =>DEFAULT_FONT_NAME,
                   in_font_bold        =>NO_FLAG,
                   in_font_color       =>0,
                   in_font_italic      =>NO_FLAG,
                   in_font_size        =>DEFAULT_FONT_SIZE,
                   in_font_underline   =>NO_FLAG,
                   in_controltype      =>9,
                   in_bkgrnd_style     =>YES_FLAG,
                   in_intl_text_id     =>news(k).intl_text_id,
                   in_use_default_color=>var_use_default_color,
                   in_model_ref_expl_id=>var_model_ref_expl_id);

         generateUIProps(var_oc_standart_item,in_ui_def_id,DEF_CLASS,
                         0, YES_FLAG, YES_FLAG,
                         NO_FLAG, NO_FLAG, NO_FLAG,
                         0, 'left', '0');

         last_TOP_POS:=last_TOP_POS+DEFAULT_BOM_HEIGHT+DEFAULT_SPACE_BETWEEN;
         last_HEIGHT:=DEFAULT_BOM_HEIGHT;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         WHEN OTHERS THEN
              NULL;
         END;
        /*******************************************/

     END IF; -- for BOM classes

     /* ***************************************************************** */
     /* ************************* End of BOM section ******************** */
     /* ***************************************************************** */

     IF features.EXISTS(k) AND NOT(news.EXISTS(features(k).parent_id)) THEN
        BEGIN
        var_temp1:=last_TOP_POS;
        var_temp2:=last_HEIGHT;

        IF NOT(temp.EXISTS(features(k).parent_id)) THEN
           temp(features(k).parent_id):=features(k).parent_id;
        END IF;
        IF features(k).counted_options_flag=YES_FLAG OR features(k).maximum>1 OR features(k).maximum IS NULL THEN
           SELECT COUNT(ps_node_id) INTO options_number FROM CZ_PS_NODES
           WHERE parent_id=features(k).ps_node_id AND deleted_flag=NO_FLAG;
           var_feature_height:=DEFAULT_CONTROL_HEIGHT*options_number+DEFAULT_CONTROL_HEIGHT;
        ELSE
           var_feature_height:=DEFAULT_CONTROL_HEIGHT;
        END IF;
        --features(k).height:=var_feature_height;

        SELECT ui_node_id INTO new_parent FROM CZ_UI_NODES WHERE ps_node_id=features(k).parent_id
        AND ui_node_type IN (UI_PRODUCT_TYPE,UI_COMPONENT_TYPE) AND deleted_flag=NO_FLAG
        AND ui_def_id=in_ui_def_id ;

        SELECT NVL(MAX(rel_top_pos),-1) INTO last_TOP_POS
        FROM CZ_UI_NODES WHERE parent_id=new_parent AND deleted_flag=NO_FLAG;

        IF last_TOP_POS=-1 THEN
           last_TOP_POS:=DEFAULT_HEADER_HEIGHT+DEFAULT_SPACE_BETWEEN;
        ELSE
           SELECT NVL(MAX(height),0) INTO last_HEIGHT FROM CZ_UI_NODES
           WHERE parent_id=new_parent AND rel_top_pos=last_TOP_POS AND
           ui_node_type IN (UI_FEATURE_TYPE,UI_TOTAL_TYPE,UI_RESOURCE_TYPE,
           UI_BOM_OPTION_CLASS_TYPE,UI_BOM_STANDART_TYPE,UI_BUTTON_TYPE)
           AND deleted_flag=NO_FLAG;

           last_TOP_POS:=last_TOP_POS+last_HEIGHT+DEFAULT_SPACE_BETWEEN;

         END IF;

         curr_node_id:=getUISeqVal;
         IF features(k).ps_node_type=FEATURE_NODE_TYPE THEN
            last_HEIGHT:=var_feature_height;

            /* *** create new Feature *** */
            create_FEATURE(curr_node_id,new_parent,in_ui_def_id,features(k));

            /* *** if this is "List of Options" Feature the generate options *** */
            IF features(k).feature_type=0 THEN
               generate_Options(in_parent_node_id=>features(k).ps_node_id,
                                in_new_parent_id =>curr_node_id,
                                in_ui_def_id     =>in_ui_def_id,
                                out_counter      =>options_number);
            END IF;

         END IF;

         IF features(k).ps_node_type=TOTAL_NODE_TYPE THEN

            /* *** create new Total *** */
            create_TOTAL(curr_node_id,new_parent,in_ui_def_id,features(k));

         END IF; -- for TOTAL

         IF features(k).ps_node_type=RESOURCE_NODE_TYPE THEN

            /* *** create new Resource *** */
           create_RESOURCE(curr_node_id,new_parent,in_ui_def_id,features(k));

         END IF; -- for RESOURCE

         IF features(k).ps_node_type=CONNECTOR_NODE_TYPE THEN

           /* *** create new Connector *** */
           create_CONNECTOR(curr_node_id,new_parent,in_ui_def_id,features(k));

         END IF; -- for CONNECTOR

         last_TOP_POS:=var_temp1;
         last_HEIGHT:=var_temp2;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;
       END;
   END IF; -- for FEATURE

   /* *** create OPTIONS *** */
   IF options.EXISTS(k) AND NOT(news.EXISTS(options(k).parent_id)) AND NOT(features.EXISTS(options(k).parent_id)) THEN
      BEGIN
      SELECT ui_node_id INTO new_parent FROM CZ_UI_NODES
      WHERE ps_node_id=options(k).parent_id AND ui_def_id=in_ui_def_id
      AND deleted_flag=NO_FLAG;
      create_OPTION(curr_node_id,new_parent,in_ui_def_id,options(k));
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
      END;
   END IF;

   k:=news.NEXT(k);
END LOOP;


IF boms.Count>0 THEN
   k:=boms.First;
   LOOP
      IF boms(k).ps_node_type=BOM_STANDART_NODE_TYPE AND NOT(boms.EXISTS(boms(k).parent_id)) THEN
         BEGIN

            t_pages.Delete;

            SELECT ps_node_type INTO var_ps_node_type FROM CZ_PS_NODES
            WHERE  ps_node_id=boms(k).parent_id;

            /* *** use latest page for adding new STANDART ITEMS *** */
            FOR e IN(SELECT ui_node_id,ps_node_id FROM CZ_UI_NODES WHERE
                     ui_def_id=in_ui_def_id AND ps_node_id=boms(k).parent_id AND
                     ui_node_type=UI_BOM_OPTION_CLASS_TYPE AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG
                     ORDER BY ui_node_id)
            LOOP
               var_temp:=e.ui_node_id;
               IF t_pages.EXISTS(e.ps_node_id) THEN
                  t_pages(e.ps_node_id):=t_pages(e.ps_node_id)+1;
               ELSE
                  t_pages(e.ps_node_id):=1;
               END IF;
            END LOOP;

            SELECT parent_id INTO var_ui_tree_parent_id FROM CZ_UI_NODES
            WHERE ui_def_id=in_ui_def_id AND ui_node_ref_id=var_temp AND
            ui_node_type=UI_COMPONENT_REF_TYPE AND deleted_flag=NO_FLAG;

            SELECT intl_text_id,tree_seq,name
            INTO var_intl_text_id,var_tree_seq,var_parent_name
            FROM CZ_PS_NODES
            WHERE ps_node_id=boms(k).parent_id;

            var_width:=set_Text_Width(boms(k).caption_name)+80;
            IF var_width<=USABLE_WIDTH THEN
               var_width:=USABLE_WIDTH;
            END IF;

         IF mLOOK_AND_FEEL='BLAF' THEN
            var_use_default_color:=YES_FLAG;
         ELSE
            var_use_default_color:=NO_FLAG;
         END IF;

         SELECT COUNT(ui_node_id) INTO counter FROM CZ_UI_NODES
         WHERE ui_def_id=in_ui_def_id AND parent_id=var_temp
         AND ui_node_type=UI_BOM_STANDART_TYPE AND deleted_flag=NO_FLAG;

         IF counter>=mITEMS_ON_PAGE  AND mUI_STYLE=DHTML_STYLE_UI THEN
           --
           -- handle labels of first page --
           --
           IF t_pages(boms(k).parent_id)=1 AND var_ps_node_type = BOM_CLASS_NODE_TYPE THEN
              BEGIN
                  var_suffix:=' ('||TO_CHAR(t_pages(boms(k).parent_id))||')';

                  UPDATE CZ_UI_NODES SET name=name||var_suffix
                  WHERE  ui_def_id=in_ui_def_id AND ui_node_id=var_temp
                         AND deleted_flag=NO_FLAG
                  RETURNING caption_id,ui_node_ref_id,modified_flags
                  INTO var_caption_id,var_ui_node_ref_id,var_modified_flag;

                  UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                  WHERE intl_text_id=var_temp AND var_modified_flag=0;

                  SELECT caption_id,modified_flags
                  INTO var_caption_id,var_modified_flag FROM CZ_UI_NODES
                  WHERE ui_def_id=in_ui_def_id AND ui_node_id=var_ui_node_ref_id
                  AND deleted_flag=NO_FLAG;

                  UPDATE CZ_LOCALIZED_TEXTS SET localized_str=localized_str||var_suffix
                  WHERE intl_text_id=var_temp AND var_modified_flag=0;

              EXCEPTION
                  WHEN OTHERS THEN
                        NULL;
              END;
            END IF;

            IF t_pages.EXISTS(boms(k).parent_id) THEN
               t_pages(boms(k).parent_id):=t_pages(boms(k).parent_id)+1;
            ELSE
               t_pages(boms(k).parent_id):=1;
            END IF;

            IF var_ps_node_type = BOM_CLASS_NODE_TYPE THEN
               var_temp:=create_Page(in_ui_tree_parent_id=>var_ui_tree_parent_id,
                                  in_ui_parent_id     =>var_root_id,
                                  in_ps_node_id       =>boms(k).parent_id,
                                  in_intl_text_id     =>var_intl_text_id,
                                  in_tree_seq         =>var_tree_seq*mMAX_NUMBER_PAGES,
                                  in_page_name        =>var_parent_name,
                                  in_ui_def_id        =>in_ui_def_id,
                                  in_counter          =>t_pages(boms(k).parent_id));
            END IF;


           IF mWIZARD_STYLE=YES_FLAG AND mUI_STYLE=DHTML_STYLE_UI THEN
              ind_arr:=footer_buttons.Count+1;
              footer_buttons(ind_arr).id:=getUISeqVal;
              footer_buttons(ind_arr).ui_parent_id:=var_temp;
              footer_buttons(ind_arr).rel_top_pos:=0;
           END IF;
         END IF;

         SELECT NVL(MAX(rel_top_pos),START_TOP_POS) INTO last_TOP_POS FROM CZ_UI_NODES
         WHERE ui_def_id=in_ui_def_id AND parent_id=var_temp AND parent_id<>var_limbo_id
         AND modified_flags<>CZ_NAVIGATION_MARK AND deleted_flag=NO_FLAG;

         IF last_TOP_POS>START_TOP_POS THEN
            last_TOP_POS:=last_TOP_POS+DEFAULT_BOM_HEIGHT+DEFAULT_SPACE_BETWEEN;

            /***
            BEGIN
                v_just_OC:='0';

                SELECT '1' INTO v_just_OC FROM DUAL WHERE EXISTS
                      (SELECT NULL FROM CZ_UI_NODES WHERE parent_id=var_temp
                       AND ui_node_ref_id IS NOT NULL
                       AND ui_node_type=UI_BOM_STANDART_TYPE AND deleted_flag=NO_FLAG
                       AND ps_node_id NOT IN(SELECT referring_node_id FROM CZ_MODEL_REF_EXPLS
                       WHERE model_id=Project_Id AND referring_node_id IS NOT NULL AND deleted_flag=NO_FLAG))
                      AND NOT EXISTS
                      (SELECT NULL FROM CZ_UI_NODES WHERE parent_id=var_temp
                       AND ui_node_ref_id IS NULL
                       AND ui_node_type=UI_BOM_STANDART_TYPE AND deleted_flag=NO_FLAG);

               IF v_just_OC='1' THEN
                  create_DIVIDER(getUISeqVal,var_temp,in_ui_def_id,
                                 last_TOP_POS,LEFT_MARGIN, 0);
                  last_TOP_POS:=last_TOP_POS+DEFAULT_SPACE_BETWEEN;
               END IF;
               EXCEPTION
                   WHEN OTHERS THEN
                        NULL;
               END;
               */
         ELSE
            last_TOP_POS:=START_TOP_POS+DEFAULT_SPACE_BETWEEN;
         END IF;

         set_UI_NODES(in_ui_node_id       =>getUISeqVal,
                      in_parent_id        =>var_temp,
                      in_ui_def_id        =>in_ui_def_id,
                      in_ps_node_id       =>boms(k).ps_node_id,
                      in_ui_node_ref_id   =>NULL,
                      in_name             =>boms(k).name,
                      in_component_id     =>boms(k).parent_id,
                      in_ui_node_type     =>UI_BOM_STANDART_TYPE,
                      in_lce_id           =>'P_'||to_char(boms(k).ps_node_id),
                      in_tree_display_flag=>YES_FLAG,
                      in_tree_seq         =>boms(k).tree_seq,
                      in_width            =>var_width,
                      in_height           =>DEFAULT_BOM_HEIGHT,
                      in_top_pos          =>last_TOP_POS,
                      in_left_pos         =>LEFT_MARGIN,
                      in_font_name        =>DEFAULT_FONT_NAME,
                      in_font_bold        =>NO_FLAG,
                      in_font_color       =>0,
                      in_font_italic      =>NO_FLAG,
                      in_font_size        =>DEFAULT_FONT_SIZE,
                      in_font_underline   =>NO_FLAG,
                      in_controltype      =>9,
                      in_bkgrnd_style     =>YES_FLAG,
                      in_intl_text_id     =>boms(k).intl_text_id,
                      in_use_default_color=>var_use_default_color);

         last_TOP_POS:=last_TOP_POS+DEFAULT_BOM_HEIGHT+DEFAULT_SPACE_BETWEEN;
         last_HEIGHT:=DEFAULT_BOM_HEIGHT;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         WHEN OTHERS THEN
              NULL;
         END;

      END IF;
      k:=boms.NEXT(k);
      IF k IS NULL THEN
         EXIT;
      END IF;
   END LOOP;
END IF;

END IF; ---news.Count>0

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

IF ref_boms.Count>0 THEN
   FOR i IN ref_boms.First..ref_boms.Last LOOP
       add_BOM_MODEL_ITEM(ref_boms(i).ui_parent_id,ref_boms(i).model_id,
                          in_ui_def_id,ref_boms(i).ps_node_id,
                          ref_boms(i).maximum,ref_boms(i).minimum,
                          ref_boms(i).virtual_flag,t_ref_uis);
   END LOOP;

END IF;



/* *** handle Drag/Drop-ed nodes ***/
IF is_EqualPS(in_ui_def_id,Project_id)=FALSE THEN
   NULL;
END IF;

populate_RefSI(in_ui_def_id);

UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG WHERE ui_def_id=in_ui_def_id AND ui_node_type=UI_BUTTON_TYPE AND func_comp_id IN
(SELECT func_comp_id FROM CZ_FUNC_COMP_SPECS WHERE (companion_type=2 AND modified_flags=NO_FLAG)
 OR deleted_flag=YES_FLAG);

/* *** synchronize types of Functional Companions *** */
FOR h IN(SELECT a.func_comp_id,a.companion_type,
                b.ui_node_id,b.parent_id,a.component_id,b.caption_id,a.name FROM CZ_FUNC_COMP_SPECS a,CZ_UI_NODES b
         WHERE b.ui_def_id=in_ui_def_id AND b.ui_node_type=UI_BUTTON_TYPE
         AND a.func_comp_id=b.func_comp_id AND a.deleted_flag=NO_FLAG AND b.deleted_flag=NO_FLAG)
LOOP

   --
   -- AUTO-CONFIG =0 OUTPUT = 1 combinations :
   -- 0100 = 4
   -- 0110 = 6
   -- 1100 = 12
   -- 1110 = 14
   --
   IF h.companion_type IN(4,6,12,14) THEN
      UPDATE CZ_UI_NODE_PROPS SET value_str='5' WHERE ui_def_id=in_ui_def_id
                AND ui_node_id=h.ui_node_id AND key_str='ActionType';

      UPDATE CZ_UI_NODES SET name=h.name WHERE ui_def_id=in_ui_def_id  AND
      ui_node_id=h.ui_node_id AND modified_flags=NO_FLAG;
      IF SQL%ROWCOUNT>0 THEN
         UPDATE CZ_INTL_TEXTS SET text_str=h.name WHERE intl_text_id=h.caption_id;
      END IF;

      UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG WHERE ui_def_id=in_ui_def_id  AND
      func_comp_id=h.func_comp_id and ui_node_id>h.ui_node_id  AND
      ui_node_type=UI_BUTTON_TYPE AND modified_flags=NO_FLAG AND deleted_flag=NO_FLAG;
   END IF;

   --
   -- AUTO-CONFIG =1 OUTPUT = 0 combinations :
   -- 0001 = 1
   -- 0011 = 3
   -- 1001 = 9
   -- 1011 = 11
   --
   IF h.companion_type IN(1,3,9,11) THEN
      UPDATE CZ_UI_NODE_PROPS SET value_str='6' WHERE ui_def_id=in_ui_def_id
                and ui_node_id=h.ui_node_id AND key_str='ActionType';

      UPDATE CZ_UI_NODES SET name=h.name WHERE ui_def_id=in_ui_def_id  AND
      ui_node_id=h.ui_node_id AND modified_flags=NO_FLAG;
      IF SQL%ROWCOUNT>0 THEN
         UPDATE CZ_INTL_TEXTS SET text_str=h.name WHERE intl_text_id=h.caption_id;
      END IF;

      UPDATE CZ_UI_NODES SET deleted_flag=YES_FLAG WHERE ui_def_id=in_ui_def_id  AND
      func_comp_id=h.func_comp_id AND ui_node_id>h.ui_node_id  AND
                ui_node_type=UI_BUTTON_TYPE AND modified_flags=NO_FLAG AND deleted_flag=NO_FLAG;
   END IF;

   --
   -- AUTO-CONFIG =1 OUTPUT = 1 combinations :
   -- 0101 = 5
   -- 0111 = 7
   -- 1101 = 13
   -- 1111 = 15
   --
   IF h.companion_type IN(5,7,13,15) THEN
      BEGIN
      SELECT value_str INTO var_action_type FROM CZ_UI_NODE_PROPS
      WHERE ui_def_id=in_ui_def_id AND ui_node_id=h.ui_node_id AND key_str='ActionType'
      AND deleted_flag=NO_FLAG;

      var_button_id:=getUISeqVal;

      IF var_action_type='5' THEN
        var_button_type:=DEF_FUNC_BUTTON1;
      END IF;

      IF var_action_type='6' THEN
        var_button_type:=DEF_FUNC_BUTTON2;
      END IF;

      create_BUTTON(var_button_id,h.parent_id,in_ui_def_id,
                    h.component_id,h.name||' (2)',
                    in_top_pos          =>LEFT_MARGIN,
                    in_left_pos         =>LEFT_MARGIN,
                    in_button_type      =>var_button_type,
                    in_func_comp_id     =>h.func_comp_id,
                    in_modified_flag    => 0);

      UPDATE CZ_UI_NODES SET name=name||' (1)'
      WHERE ui_def_id=in_ui_def_id AND ui_node_id=h.ui_node_id AND modified_flags=NO_FLAG;

      IF latest_buttons.Count=0 THEN
         ind:=1;
      ELSE
         ind:=latest_buttons.Last+1;
      END IF;
      latest_buttons(ind).id:=var_button_id;

      var_button_id:=getUISeqVal;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
          NULL;
     WHEN OTHERS THEN
          NULL;
     END;
   END IF;

END LOOP;

FOR i IN  (SELECT ui_node_id,parent_id,ps_node_id,ui_node_ref_id,controltype,name FROM CZ_UI_NODES a
           WHERE ui_def_id=in_ui_def_id AND ui_node_type=UI_BUTTON_TYPE
           AND parent_id<>var_limbo_id AND deleted_flag=NO_FLAG)

LOOP
   FOR n IN(SELECT ui_node_id FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id AND ps_node_id=i.ps_node_id AND
            parent_id=var_limbo_id AND ui_node_type NOT IN(UI_BUTTON_TYPE,UI_PICTURE_TYPE))
   LOOP
      BEGIN
      SELECT ui_node_id INTO var_temp FROM CZ_UI_NODES WHERE ui_def_id=in_ui_def_id
      AND ui_node_id=i.parent_id AND parent_id=var_limbo_id AND deleted_flag=NO_FLAG;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           out_run_id:=GLOBAL_RUN_ID;
           FND_REPORT(CZ_UI_GEN_REMOVED_SCREEN,TOKEN_BUTTON_NAME,i.name,CZ_WARNING_URGENCY);
      WHEN OTHERS THEN
           out_run_id:=GLOBAL_RUN_ID;
           FND_REPORT(CZ_UI_GEN_REMOVED_SCREEN,TOKEN_BUTTON_NAME,i.name,CZ_WARNING_URGENCY);
      END;
   END LOOP;

   FOR n IN(SELECT ui_node_id FROM CZ_UI_NODES a WHERE ui_node_id=i.ui_node_ref_id AND
            parent_id IN(SELECT ui_node_id FROM CZ_UI_NODES b WHERE a.ui_def_id=b.ui_def_id
            AND name='Limbo' AND deleted_flag=NO_FLAG))
   LOOP
      out_run_id:=GLOBAL_RUN_ID;
      FND_REPORT(CZ_UI_GEN_REMOVED_SCREEN,TOKEN_BUTTON_NAME,i.name,CZ_WARNING_URGENCY);
   END LOOP;

END LOOP;

--
--create ADD buttons for the instantable Components and Products --
--
create_ADD_BUTTONS(in_ui_def_id);

--
-- create EXECUTE buttons for Functional Companions --
--
create_FUNC_BUTTONS(Project_Id,in_ui_def_id,var_limbo_id);

--
-- shift all ADD and EXECUTE buttons to the bottom of the screen --
--

FOR i IN (SELECT ui_node_ref_id FROM CZ_UI_NODES
          WHERE ui_def_id=in_ui_def_id AND
          ui_node_type IN (UI_PRODUCT_REF_TYPE,UI_COMPONENT_REF_TYPE) AND
          deleted_flag=NO_FLAG)
LOOP
   shift_Latest_BUTTONS(i.ui_node_ref_id);
END LOOP;

--
-- create "Home","Back" and "Next buttons --
--
IF mWIZARD_STYLE=YES_FLAG AND mUI_STYLE=DHTML_STYLE_UI THEN
   create_Wizard_Style_Buttons(in_ui_def_id,var_limbo_id);
END IF;

--
-- synchronize CZ_UI_NODES.tree_seq of Component Tree nodes
--  with CZ_PS_NODES.tree_seq
--
SELECT mMAX_NUMBER_PAGES*a.tree_seq,b.ui_node_id,b.ps_node_id,mMAX_NUMBER_PAGES*a.tree_seq-b.tree_seq
BULK COLLECT INTO t_tree_seq_tbl,t_ui_node_id_tbl,t_ps_node_id_tbl,t_tree_seq_delta_tbl
FROM CZ_PS_NODES a,CZ_UI_NODES b
WHERE b.ui_def_id=in_ui_def_id AND a.devl_project_id=Project_Id AND
a.deleted_flag=NO_FLAG AND b.deleted_flag=NO_FLAG
AND a.ps_node_id=b.ps_node_id AND b.ui_node_type IN(UI_COMPONENT_REF_TYPE,UI_REFERENCE_REF_TYPE) AND b.tree_seq <> mMAX_NUMBER_PAGES*a.tree_seq;

IF t_ui_node_id_tbl.COUNT > 0 THEN

   --
   -- update tree_seq for splitted pages
   --
   FOR i IN t_ui_node_id_tbl.First..t_ui_node_id_tbl.Last
   LOOP
      UPDATE CZ_UI_NODES a
      SET tree_seq=tree_seq+t_tree_seq_delta_tbl(i)
      WHERE a.ui_def_id=in_ui_def_id AND a.deleted_flag=NO_FLAG
           AND ps_node_id IS NULL AND ui_node_ref_id IN
          (SELECT ui_node_id FROM CZ_UI_NODES
           WHERE ui_def_id=in_ui_def_id AND a.deleted_flag=NO_FLAG AND ps_node_id=t_ps_node_id_tbl(i));
   END LOOP;

   FORALL i IN t_ui_node_id_tbl.First..t_ui_node_id_tbl.Last
    UPDATE CZ_UI_NODES
    SET tree_seq = t_tree_seq_tbl(i)
    WHERE ui_def_id=in_ui_def_id AND ui_node_id=t_ui_node_id_tbl(i);

END IF;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

EXCEPTION
    WHEN NO_COMPONENT_TREE_NODE THEN
         out_run_id:=GLOBAL_RUN_ID;
         LOG_REPORT('CZ_UI_GENERATOR.refreshUI',
         'There is no "Component Tree" node for this UI ( corrupted UI )',
         CZ_ERROR_URGENCY);
    WHEN NO_LIMBO_NODE  THEN
         out_run_id:=GLOBAL_RUN_ID;
         LOG_REPORT('CZ_UI_GENERATOR.refreshUI',
         'There is no "Limbo" node for this UI ( corrupted UI )',
         CZ_ERROR_URGENCY);
    WHEN WRONG_UI_VERSION THEN
         out_run_id:=GLOBAL_RUN_ID;
         LOG_REPORT('CZ_UI_GENERATOR.refreshUI',
         'UI Refresh can not be applied to old style UI ("'||var_ui_name||'")',
         CZ_ERROR_URGENCY);
    WHEN BREAK_IT THEN
         NULL;
    WHEN NO_DATA_FOUND THEN
         out_run_id:=GLOBAL_RUN_ID;
         --LOG_REPORT('CZ_UI_GENERATOR.refreshUI','RCODE='||RCODE||' : '||SQLERRM);
         FND_REPORT(CZ_UI_GEN_BAD_DATA,TOKEN_PROC_NAME,'CZ_UI_GENERATOR.refreshUI',
                    CZ_ERROR_URGENCY);
    WHEN OTHERS THEN
         out_run_id:=GLOBAL_RUN_ID;
         --LOG_REPORT('CZ_UI_GENERATOR.refreshUI','RCODE='||RCODE||' : '||SQLERRM);
         FND_REPORT(CZ_UI_GEN_FATAL_ERR,TOKEN_SQLERRM,SQLERRM, CZ_ERROR_URGENCY);
END refreshUI;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- this procedure is used for testing from SQL*Plus --
--
PROCEDURE refresh_UI
(in_ui_def_id   IN INTEGER) IS

    var_run_id        INTEGER;
    var_new_ui_def_id CZ_UI_DEFS.ui_def_id%TYPE;

BEGIN
    var_new_ui_def_id:=in_ui_def_id;
    refreshUI(var_new_ui_def_id,var_run_id);
END refresh_UI;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- update labels according with in_use_labels value --
-- the procedure is used by Developer               --
--
PROCEDURE update_Labels
(in_ui_node_id IN INTEGER,
 in_use_labels IN VARCHAR2) IS

    var_name    CZ_PS_NODES.name%TYPE;
    var_keep_it VARCHAR2(1):=NO_FLAG;

BEGIN
    FOR i IN (SELECT a.ui_node_id,a.ps_node_id,a.caption_id,b.name,c.localized_str,c.language
              FROM CZ_UI_NODES a,CZ_PS_NODES b, CZ_LOCALIZED_TEXTS c
              WHERE a.parent_id=in_ui_node_id AND
                    a.ui_node_type IN (UI_OPTION_TYPE,UI_BOM_STANDART_TYPE)
                    AND a.deleted_flag=NO_FLAG AND a.ps_node_id=b.ps_node_id
                    AND b.intl_text_id=c.intl_text_id)
   LOOP
      var_name:=i.name;
      var_keep_it:=NO_FLAG;
      IF in_use_labels='0' THEN
         var_name:=i.name;
      ELSIF in_use_labels='1' THEN
         var_name:=i.localized_str;
      ELSIF in_use_labels='3' THEN
         var_name:=i.name||mCONCAT_SYMBOL||i.localized_str;
      ELSIF in_use_labels='4' THEN
         var_keep_it:='1';
      END IF;
      UPDATE CZ_LOCALIZED_TEXTS SET localized_str=var_name
      WHERE intl_text_id=i.caption_id AND language=i.language AND var_keep_it='0';
   END LOOP;
END update_Labels;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

BEGIN
    --
    -- find Language Code of current session --
    --
    SELECT USERENV('LANG') INTO mCURRENT_LANG FROM dual;

    --
    -- find concatenation symbol - it is used for "Name and Decsription" UI labels --
    --
    SELECT VALUE INTO mCONCAT_SYMBOL FROM CZ_DB_SETTINGS
    WHERE UPPER(SETTING_ID)='UI_NODE_NAME_CONCAT_CHARS' AND rownum<2;
    mCONCAT_SYMBOL:=' '||mCONCAT_SYMBOL||' ';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         mCONCAT_SYMBOL:=' , ';
    WHEN OTHERS THEN
         mCONCAT_SYMBOL:=' , ';
END CZ_UI_GENERATOR;

/
