--------------------------------------------------------
--  DDL for Package Body CZ_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_XML" AS
/*  $Header: czxmlb.pls 120.3 2006/09/18 19:59:30 skudryav ship $    */

  G_GEN_VERSION                 CONSTANT VARCHAR2(25)  :='11.5.20';
  G_GEN_HEADER                  CONSTANT VARCHAR2(100) :='$Header: czxmlb.pls 120.3 2006/09/18 19:59:30 skudryav ship $';
  G_NULL_VALUE                  CONSTANT VARCHAR2(100) := 'NULL';
  G_UMPERS                      CONSTANT VARCHAR2(1) := fnd_global.local_chr(38);

  G_USER_ATTRIBUTE1_NAME        CONSTANT VARCHAR2(255) := 'user:attribute1';
  G_USER_ATTRIBUTE2_NAME        CONSTANT VARCHAR2(255) := 'user:attribute2';
  G_USER_ATTRIBUTE3_NAME        CONSTANT VARCHAR2(255) := 'user:attribute3';
  G_USER_ATTRIBUTE4_NAME        CONSTANT VARCHAR2(255) := 'user:attribute4';
  G_USER_ATTRIBUTE5_NAME        CONSTANT VARCHAR2(255) := 'user:attribute5';

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
  FAILED_TO_LOCK_MODEL    EXCEPTION;
  FAILED_TO_LOCK_TEMPLATE EXCEPTION;

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
                                                   'REF_',
                                                   'CON_',
                                                   'BOMM_',
                                                   'OPT_' );

  TYPE attribute_record_type IS RECORD(
    NAME  jdr_attributes.att_name%TYPE,
    VALUE jdr_attributes.att_value%TYPE);

  TYPE attributes_tbl_type IS TABLE OF attribute_record_type INDEX BY BINARY_INTEGER;

  TYPE ui_tbl_type IS TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);

  -------------------------------------------------------------------

  PROCEDURE Initialize(x_run_id OUT NOCOPY NUMBER) IS
  BEGIN
    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO G_RUN_ID FROM dual;
    x_run_id := G_RUN_ID;
  END Initialize;

  PROCEDURE Initialize
  (x_run_id          OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY  VARCHAR2,
   x_msg_count       OUT NOCOPY  NUMBER,
   x_msg_data        OUT NOCOPY  VARCHAR2) IS

  BEGIN
    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO G_RUN_ID FROM dual;
    x_run_id := G_RUN_ID;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_msg_data      := NULL;
  END Initialize;

  PROCEDURE LOG_REPORT
  (p_caller        IN VARCHAR2,
   p_error_message IN VARCHAR2
  ) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
    l_error      BOOLEAN;
    l_status     INTEGER;
  BEGIN
    l_status:=11276;
    INSERT INTO CZ_DB_LOGS
           (RUN_ID,
            LOGTIME,
            LOGUSER,
            URGENCY,
            CALLER,
            STATUSCODE,
            MESSAGE)
    VALUES (G_RUN_ID,
            SYSDATE,
            USER,
            1,
            p_caller,
            l_status,
            p_error_message);
    COMMIT;
  END LOG_REPORT;

  --
  -- section for a different DEBUG procedures
  --
  PROCEDURE DEBUG(p_str IN VARCHAR2) IS
    l_error  BOOLEAN;
    l_run_id NUMBER;
  BEGIN
    --dbms_output.put_line(p_str);
    IF G_RUN_ID IS NULL THEN
      Initialize(l_run_id);
    END IF;
    l_error:=CZ_UTILS.LOG_REPORT(p_str,1,'CZ_XML',11276,G_RUN_ID);
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

  --
  -- add FND error message
  --
  PROCEDURE add_Error_Message(p_caller       IN VARCHAR2,
                              p_message_name IN VARCHAR2,
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

    LOG_REPORT(p_caller, p_message_name);

  END add_Error_Message;

  ---------------------------------------------------------------------
  ------------------- JDR DOC BUILDER / XML Parsing -------------------
  ---------------------------------------------------------------------

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
  -- set internal CZ attributes within "user:attribute1"
  --
  PROCEDURE set_User_Attribute(p_cz_attribute_name    IN VARCHAR2,
                               p_cz_attribute_value   IN VARCHAR2,
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

        l_st := '1';

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

          l_st := '1';
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
  PROCEDURE convert_DOM_to_JRAD(p_doc           xmldom.DOMDocument,
                                p_jrad_doc_name IN VARCHAR2) IS

    l_dom_root_node xmldom.DOMNode;
    l_topLevel      jdr_docbuilder.Element;
    l_status        PLS_INTEGER;
    l_lang          VARCHAR2(255);
  BEGIN

    g_DOC := p_doc;

    --
    -- refresh global jdr_docbuilder's structures
    --
    jdr_docbuilder.refresh;

    --
    -- get Document's root node
    --
    l_dom_root_node := xmldom.makeNode(xmldom.getDocumentElement(g_DOC));

    --
    -- remove top level xml attributes - jdrdocbuilder always adds these attributes
    -- so we don't need to have a duplicates
    --
    remove_TopLevel_Attributes(l_dom_root_node);

    l_lang := get_JRADNLS_Lang();
    --
    -- create a target JRAD document
    --
    g_JRADDOC := jdr_docbuilder.createDocument(p_jrad_doc_name, l_lang);

    --
    -- create root element of the target JRAD document
    --
    l_topLevel := createElement(xmldom.getNodeName(l_dom_root_node));

    --
    -- set top level attributes
    --
    set_Attributes(l_dom_root_node, l_topLevel);

    --
    -- set JRAD top level node
    --
    jdr_docbuilder.setTopLevelElement(g_JRADDOC, l_topLevel);

    --
    -- modify the source DOM tree and create the target JRAD document
    -- traverse_DOM_Tree() is recursive procedure
    --
    traverse_DOM_Tree(xmldom.getChildNodes(l_dom_root_node),
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
  BEGIN

    convert_DOM_to_JRAD(p_doc => p_xml_doc, p_jrad_doc_name => p_doc_name);

  END Save_Document;

  ---------------------------------------------------------------------
  ----------  end of JDR DOC BUILDER / XML Parsing Part ---------------
  ---------------------------------------------------------------------

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
        add_Error_Message(p_caller       => 'CZ_XML.Close_Parser',
                          p_message_name => 'Close_Parser() : XML Parser can not be closed : '||SQLERRM,
                          p_fatal_error  => TRUE);
        RAISE;
      END IF;
  END Close_Parser;

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
          RETURN l_attr_value;
        END IF;
      END LOOP;
    END IF;
    RETURN G_NULL_VALUE;
  END get_Attribute_Value;

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
    --
    -- here we don't need to know about hierachy of nodes
    -- so we just need to get list of all nodes of XML subtree
    --
    l_nodeslist := xmldom.getElementsByTagName(p_subtree_doc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    l_node := xmldom.makeNode(xmldom.getDocumentElement(p_subtree_doc));

    l_attribute_value := get_Attribute_Value(l_node, p_attribute_name);

    IF p_in_user_attributes='1' THEN
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

      IF p_in_user_attributes='1' THEN
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

  END parse_JRAD_Document;


  PROCEDURE handle_Doc_Bad_Attributes
  (p_doc_full_name           IN  VARCHAR2,
   p_remove_bad_attributes   IN  BOOLEAN,
   x_bad_attributes_detected OUT NOCOPY BOOLEAN) IS

    l_xmldoc          xmldom.DOMDocument;
    l_node            xmldom.DOMNode;
    l_nodeslist       xmldom.DOMNodeList;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;
    l_attribute_value VARCHAR2(32000);

 BEGIN

    x_bad_attributes_detected := FALSE;

    l_xmldoc    := parse_JRAD_Document(p_doc_full_name);

    IF xmldom.IsNull(l_xmldoc) THEN
      RETURN;
    END IF;

    l_node      := xmldom.makeNode(xmldom.getDocumentElement(l_xmldoc));
    l_nodeslist := xmldom.getElementsByTagName(l_xmldoc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    IF NOT(xmldom.IsNull(l_node)) THEN
      l_attribute_value := get_Attribute_Value(l_node, 'xmlns');
      IF NVL(l_attribute_value,'x')='x' THEN
        x_bad_attributes_detected := TRUE;
        IF p_remove_bad_attributes=FALSE THEN
          RETURN;
        END IF;
      END IF;
    END IF;

    FOR i IN 0 .. l_length - 1
    LOOP
      l_node := xmldom.item(l_nodeslist, i);
      IF NOT(xmldom.IsNull(l_node)) THEN
        l_attribute_value := get_Attribute_Value(l_node, 'xmlns');
        IF NVL(l_attribute_value,'x')='x' THEN
          x_bad_attributes_detected := TRUE;
          IF p_remove_bad_attributes THEN
            xmldom.removeAttribute(xmldom.makeElement(l_node),'xmlns');
          ELSE
            RETURN;
          END IF;
        END IF;
      END IF;
    END LOOP;

    IF p_remove_bad_attributes THEN
      Save_Document(p_xml_doc   => l_xmldoc,
                    p_doc_name  => p_doc_full_name);
    END IF;

    xmldom.freeDocument(l_xmldoc);

  END handle_Doc_Bad_Attributes;

  PROCEDURE handle_Bad_Element_Ids
  (p_doc_full_name           IN  VARCHAR2,
   p_ui_def_id               IN NUMBER,
   p_ui_page_id              IN NUMBER) IS

    l_xmldoc          xmldom.DOMDocument;
    l_node            xmldom.DOMNode;
    l_nodeslist       xmldom.DOMNodeList;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;

    l_attribute_value        VARCHAR2(32000);
    l_user_attribute3_value  VARCHAR2(32000);
    l_case_node_name         VARCHAR2(255);
    l_switcher_casename      VARCHAR2(255);

 BEGIN

    l_xmldoc    := parse_JRAD_Document(p_doc_full_name);

    IF xmldom.IsNull(l_xmldoc) THEN
      RETURN;
    END IF;

    l_node      := xmldom.makeNode(xmldom.getDocumentElement(l_xmldoc));
    l_nodeslist := xmldom.getElementsByTagName(l_xmldoc, '*');
    l_length    := xmldom.getLength(l_nodeslist);

    IF NOT(xmldom.IsNull(l_node)) THEN
      l_attribute_value := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);
      IF l_attribute_value IS NOT NULL AND l_attribute_value<>G_NULL_VALUE THEN
         set_Attribute(l_node,
                       G_ID_ATTRIBUTE,
                       REPLACE(REPLACE(l_attribute_value,'_czt','_czn'),'_czc','_czn'));
      END IF;
    END IF;

    FOR i IN 0 .. l_length - 1
    LOOP
      l_node := xmldom.item(l_nodeslist, i);
      IF NOT(xmldom.IsNull(l_node)) THEN

        l_attribute_value := get_Attribute_Value(l_node, G_ID_ATTRIBUTE);

        IF l_attribute_value IS NOT NULL AND l_attribute_value<>G_NULL_VALUE THEN
           set_Attribute(l_node,
                         G_ID_ATTRIBUTE,
                         REPLACE(REPLACE(l_attribute_value,'_czt','_czn'),'_czc','_czn'));
        END IF;

        IF xmldom.getNodeName(l_node)='ui:case' THEN
          l_case_node_name := get_Attribute_Value(l_node, 'name');
          IF l_case_node_name IS NOT NULL THEN
            set_Attribute(l_node,
                          'name',
                          REPLACE(REPLACE(l_case_node_name,'_czt','_czn'),'_czc','_czn'));
          END IF;
        END IF;

        IF xmldom.getNodeName(l_node)='oa:switcher' THEN

          l_user_attribute3_value := get_Attribute_Value(l_node, G_USER_ATTRIBUTE3_NAME);

          l_switcher_casename := get_User_Attribute(l_user_attribute3_value ,'switcherDefaultCaseName');

          l_switcher_casename := REPLACE(REPLACE(l_switcher_casename,'_czt', '_czn'),'_czc','_czn');

          set_User_Attribute(p_cz_attribute_name    => 'switcherDefaultCaseName',
                             p_cz_attribute_value   => l_switcher_casename,
                             px_xml_attribute_value => l_user_attribute3_value);

          set_Attribute(l_node,
                        G_USER_ATTRIBUTE3_NAME,
                        l_user_attribute3_value);

        END IF;

      END IF;
    END LOOP;

    Save_Document(p_xml_doc   => l_xmldoc,
                  p_doc_name  => p_doc_full_name);

    xmldom.freeDocument(l_xmldoc);

  END handle_Bad_Element_Ids;

  PROCEDURE detect_Doc_Bad_Attributes
  (p_doc_full_name           IN  VARCHAR2,
   x_bad_attributes_detected OUT NOCOPY BOOLEAN) IS

    l_xmldoc          xmldom.DOMDocument;
    l_node            xmldom.DOMNode;
    l_nodeslist       xmldom.DOMNodeList;
    l_empty_xml_node  xmldom.DOMNode;
    l_length          NUMBER;
    l_attribute_value VARCHAR2(32000);

  BEGIN
    handle_Doc_Bad_Attributes
     (p_doc_full_name           => p_doc_full_name,
      p_remove_bad_attributes   => FALSE,
      x_bad_attributes_detected => x_bad_attributes_detected);
  END detect_Doc_Bad_Attributes;

  PROCEDURE remove_Bad_Attributes_in_Doc
  (p_doc_full_name           IN  VARCHAR2) IS

    l_bad_attributes_detected BOOLEAN;

  BEGIN
    handle_Doc_Bad_Attributes
     (p_doc_full_name           => p_doc_full_name,
      p_remove_bad_attributes   => TRUE,
      x_bad_attributes_detected => l_bad_attributes_detected);
    IF l_bad_attributes_detected THEN
      DEBUG('Bad attributes have been removed...');
    END IF;
  END remove_Bad_Attributes_in_Doc;


  PROCEDURE handle_UIS_with_Bad_Attributes(p_ui_def_id IN NUMBER DEFAULT NULL,
                                           p_remove_bad_attributes IN BOOLEAN) IS
    l_bad_attributes_detected BOOLEAN;
    l_flag                    BOOLEAN;
  BEGIN
    IF p_ui_def_id IS NULL THEN
      FOR i IN(SELECT ui_def_id,NAME
                 FROM CZ_UI_DEFS
               WHERE deleted_flag='0' AND
                     ui_style=G_OA_STYLE_UI AND seeded_flag='0')
      LOOP
        l_flag := FALSE;
        FOR j IN(SELECT jrad_doc,NAME FROM CZ_UI_PAGES
                  WHERE ui_def_id=i.ui_def_id AND deleted_flag='0')
        LOOP
          handle_Doc_Bad_Attributes
           (p_doc_full_name           => j.jrad_doc,
            p_remove_bad_attributes   => p_remove_bad_attributes,
            x_bad_attributes_detected => l_bad_attributes_detected);
          IF l_bad_attributes_detected THEN
            l_flag := TRUE;
            IF l_flag THEN
              DEBUG('Corrupted UI : "'||i.NAME||'"');
              l_flag := FALSE;
            END IF;
            DEBUG(' |---> corrupted UI Page : "'||j.NAME||'"');
          END IF;
        END LOOP;
      END LOOP;

    ELSE
      FOR i IN(SELECT ui_def_id,NAME
                 FROM CZ_UI_DEFS
               WHERE ui_def_id=p_ui_def_id AND deleted_flag='0' AND
                     ui_style=G_OA_STYLE_UI AND seeded_flag='0')
      LOOP
        FOR j IN(SELECT jrad_doc,NAME FROM CZ_UI_PAGES
                  WHERE ui_def_id=i.ui_def_id AND deleted_flag='0')
        LOOP
          l_bad_attributes_detected := FALSE;
          handle_Doc_Bad_Attributes
           (p_doc_full_name           => j.jrad_doc,
            p_remove_bad_attributes   => p_remove_bad_attributes,
            x_bad_attributes_detected => l_bad_attributes_detected);
          IF l_bad_attributes_detected THEN
            DEBUG(' |---> corrupted UI Page : "'||j.NAME||'"');
          END IF;
        END LOOP;
      END LOOP;

    END IF;
  END handle_UIS_with_Bad_Attributes;


  PROCEDURE replace_Bad_Element_Ids(p_ui_def_id IN NUMBER DEFAULT NULL) IS
  BEGIN
    IF p_ui_def_id IS NULL THEN

      FOR i IN(SELECT ui_def_id,NAME
                 FROM CZ_UI_DEFS
               WHERE deleted_flag='0' AND
                     ui_style=G_OA_STYLE_UI AND seeded_flag='0')
      LOOP
        FOR j IN(SELECT jrad_doc,page_id,NAME FROM CZ_UI_PAGES
                  WHERE ui_def_id=i.ui_def_id AND deleted_flag='0')
        LOOP
          handle_Bad_Element_Ids(p_doc_full_name => j.jrad_doc,
                                 p_ui_def_id     => j.page_id,
                                 p_ui_page_id    => i.ui_def_id);
        END LOOP;

        UPDATE CZ_RULES
           SET UI_PAGE_ELEMENT_ID=REPLACE(REPLACE(UI_PAGE_ELEMENT_ID,'_czt','_czn'),'_czc','_czn')
         WHERE ui_def_id=i.ui_def_id;

        UPDATE CZ_INTL_TEXTS
           SET UI_PAGE_ELEMENT_ID=REPLACE(REPLACE(UI_PAGE_ELEMENT_ID,'_czt','_czn'),'_czc','_czn')
         WHERE ui_def_id=i.ui_def_id;

      END LOOP;

    ELSE

      FOR i IN(SELECT ui_def_id,NAME
                 FROM CZ_UI_DEFS
               WHERE ui_def_id=p_ui_def_id AND deleted_flag='0' AND
                     ui_style=G_OA_STYLE_UI AND seeded_flag='0')
      LOOP
        FOR j IN(SELECT jrad_doc,page_id,NAME FROM CZ_UI_PAGES
                  WHERE ui_def_id=i.ui_def_id AND deleted_flag='0')
        LOOP
          handle_Bad_Element_Ids(p_doc_full_name  => j.jrad_doc,
                                 p_ui_def_id      => j.page_id,
                                 p_ui_page_id     => i.ui_def_id);

        END LOOP;

        UPDATE CZ_RULES
           SET UI_PAGE_ELEMENT_ID=REPLACE(REPLACE(UI_PAGE_ELEMENT_ID,'_czt','_czn'),'_czc','_czn')
         WHERE ui_def_id=i.ui_def_id;

        UPDATE CZ_INTL_TEXTS
           SET UI_PAGE_ELEMENT_ID=REPLACE(REPLACE(UI_PAGE_ELEMENT_ID,'_czt','_czn'),'_czc','_czn')
         WHERE ui_def_id=i.ui_def_id;

      END LOOP;

   END IF;

  END replace_Bad_Element_Ids;

  PROCEDURE detect_UIS_with_Bad_Attributes
  (p_ui_def_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2) IS

  BEGIN

    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);

    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;
    Open_Parser();
    handle_UIS_with_Bad_Attributes(p_ui_def_id             => p_ui_def_id,
                                   p_remove_bad_attributes => FALSE);
    Close_Parser();

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error : '||SQLERRM;
      add_Error_Message(p_caller       => 'CZ_XML.detect_UIS_with_Bad_Attributes',
                        p_message_name => 'Close_Parser() : XML Parser can not be closed : '||SQLERRM,
                        p_fatal_error  => TRUE);

      Close_Parser();
  END detect_UIS_with_Bad_Attributes;

  PROCEDURE remove_Bad_Attributes_in_UIS
  (p_ui_def_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2) IS

  BEGIN
    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;
    Open_Parser();
    handle_UIS_with_Bad_Attributes(p_ui_def_id             => p_ui_def_id,
                                   p_remove_bad_attributes => TRUE);
    Close_Parser();
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error : '||SQLERRM;
      Close_Parser();
  END remove_Bad_Attributes_in_UIS;


  PROCEDURE handle_TMPLS_with_Bad_Attrs(p_template_id IN NUMBER DEFAULT NULL,
                                        p_remove_bad_attributes IN BOOLEAN) IS
    l_bad_attributes_detected BOOLEAN;
  BEGIN
    IF p_template_id IS NULL THEN
      FOR i IN(SELECT jrad_doc,template_name
                 FROM CZ_UI_TEMPLATES
               WHERE deleted_flag='0' AND
                     seeded_flag='0')
      LOOP
        handle_Doc_Bad_Attributes
           (p_doc_full_name           => i.jrad_doc,
            p_remove_bad_attributes   => p_remove_bad_attributes,
            x_bad_attributes_detected => l_bad_attributes_detected);
        IF l_bad_attributes_detected THEN
          DEBUG('Corrupted UI Template : "'||i.template_name||'"');
        END IF;
      END LOOP;

    ELSE
      FOR i IN(SELECT jrad_doc,template_name
                 FROM CZ_UI_TEMPLATES
               WHERE template_id=p_template_id AND
                     deleted_flag='0' AND
                     seeded_flag='0')
      LOOP
        handle_Doc_Bad_Attributes
           (p_doc_full_name           => i.jrad_doc,
            p_remove_bad_attributes   => p_remove_bad_attributes,
            x_bad_attributes_detected => l_bad_attributes_detected);
        IF l_bad_attributes_detected THEN
          DEBUG('Corrupted UI Template : "'||i.template_name||'"');
        END IF;
      END LOOP;

    END IF;
  END handle_TMPLS_with_Bad_Attrs;

  PROCEDURE detect_TMPLS_with_Bad_Attrs
  (p_template_id IN NUMBER DEFAULT NULL,
  x_run_id             OUT NOCOPY  NUMBER,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_msg_count          OUT NOCOPY  NUMBER,
  x_msg_data           OUT NOCOPY  VARCHAR2) IS

  BEGIN
    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;
    Open_Parser();
    handle_TMPLS_with_Bad_Attrs(p_template_id           => p_template_id,
                                p_remove_bad_attributes => FALSE);
    Close_Parser();

/*
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error : '||SQLERRM;
      Close_Parser();
*/
  END detect_TMPLS_with_Bad_Attrs;

  PROCEDURE remove_Bad_Attributes_in_TMPLS
 (p_template_id IN NUMBER DEFAULT NULL,
  x_run_id             OUT NOCOPY  NUMBER,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_msg_count          OUT NOCOPY  NUMBER,
  x_msg_data           OUT NOCOPY  VARCHAR2) IS
  BEGIN
    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;
    Open_Parser();
    handle_TMPLS_with_Bad_Attrs(p_template_id           => p_template_id,
                                p_remove_bad_attributes => TRUE);
    Close_Parser();
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error : '||SQLERRM;
      Close_Parser();
  END remove_Bad_Attributes_in_TMPLS;

  PROCEDURE Test_UI_Pages(p_ui_def_id IN NUMBER) IS

    l_xmldoc          xmldom.DOMDocument;
    l_node            xmldom.DOMNode;

  BEGIN
    Open_Parser();

    FOR i IN(SELECT * FROM CZ_UI_PAGES WHERE ui_def_id=p_ui_def_id AND deleted_flag='0')
    LOOP
      BEGIN
        l_xmldoc    := parse_JRAD_Document(i.jrad_doc);
        Save_Document(p_xml_doc   => l_xmldoc,
                      p_doc_name  => i.jrad_doc||'_TEST');
        xmldom.freeDocument(l_xmldoc);
        ROLLBACK;
      EXCEPTION
        WHEN OTHERS THEN
          --DBMS_OUTPUT.PUT_LINE('Fatal Error for : UI ui_def_id='||TO_CHAR(i.jrad_doc)||
          --' UI page page_id='||TO_CHAR(i.page_id));
          NULL;
      END;
    END LOOP;

    Close_Parser();

  END Test_UI_Pages;


  PROCEDURE replace_Bad_Element_Ids
  (p_ui_def_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2) IS

  BEGIN
    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;
    Open_Parser();
    replace_Bad_Element_Ids(p_ui_def_id => p_ui_def_id);
    Close_Parser();
/*
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error in CZ_XML.replace_Element_Ids() : '||SQLERRM;
      Close_Parser();
*/
  END replace_Bad_Element_Ids;



    PROCEDURE restore_Elements_Hierarchy(p_xml_doc     xmldom.DOMDocument,
                                         p_ui_def_id   NUMBER,
                                         p_page_id     NUMBER,
                                         p_element_id  VARCHAR2

) IS

    l_xml_node     xmldom.DOMNode;
    l_element_path VARCHAR2(32000);

    PROCEDURE reconstruct_Parent_Elements(p_xml_node xmldom.DOMNode) IS

      l_parent_node            xmldom.DOMNode;
      l_element_id             CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
      l_user_attribute4_value  VARCHAR2(32000);
      l_node_name              VARCHAR2(32000);

    BEGIN

      IF xmldom.isNull(p_xml_node) THEN
        RETURN;
      END IF;
      l_parent_node := xmldom.getParentNode(p_xml_node);
      l_element_id := get_Attribute_Value(l_parent_node, G_ID_ATTRIBUTE);

      IF l_element_id IS NOT NULL AND l_element_id<>G_NULL_VALUE AND xmldom.getNodeName(l_parent_node)<>'#document'THEN

        FOR n IN(SELECT element_id FROM CZ_UI_PAGE_ELEMENTS
                  WHERE ui_def_id=p_ui_def_id AND
                        page_id=p_page_id AND
                        element_id=l_element_id AND deleted_flag='0')
        LOOP
          UPDATE CZ_UI_PAGE_ELEMENTS
             SET parent_element_id=l_element_id
           WHERE ui_def_id=p_ui_def_id AND
                 page_id=p_page_id AND
                 element_id=p_element_id;
          RETURN;
        END LOOP;

      END IF;

      IF  NOT(xmldom.IsNull(p_xml_node)) THEN
        IF NOT(xmldom.IsNull(l_parent_node)) THEN
          reconstruct_Parent_Elements(l_parent_node);
        END IF;
      END IF;

    END reconstruct_Parent_Elements;

  BEGIN

    l_xml_node := find_XML_Node_By_Attribute(p_xml_doc, G_ID_ATTRIBUTE, p_element_id);

    IF NOT(xmldom.IsNull(l_xml_node)) THEN
      reconstruct_Parent_Elements(l_xml_node);
    ELSE
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET deleted_flag='1'
        WHERE ui_def_id=p_ui_def_id AND
              page_id=p_page_id AND
              element_id=p_element_id AND
              NOT(element_type=523 AND
                  ctrl_template_id IS NULL) AND
              deleted_flag='0';
    END IF;

  END restore_Elements_Hierarchy;


  PROCEDURE restore_Parent_Elements
  (p_ui_def_id          IN  NUMBER) IS

    l_xmldoc          xmldom.DOMDocument;

  BEGIN

    FOR i IN(SELECT page_id, jrad_doc FROM CZ_UI_PAGES
              WHERE ui_def_id=p_ui_def_id AND deleted_flag='0')
    LOOP

      l_xmldoc    := parse_JRAD_Document(i.jrad_doc);

      FOR j IN(SELECT element_id
               FROM cz_ui_page_elements a
              WHERE a.ui_def_id=p_ui_def_id AND a.page_id=i.page_id AND a.deleted_flag='0' AND
                    a.parent_element_id IS NOT NULL AND
                    EXISTS(SELECT NULL FROM CZ_RP_ENTRIES d
                            WHERE d.object_id IN(SELECT e.devl_project_id FROM CZ_UI_DEFS e
                                                  WHERE e.ui_def_id=p_ui_def_id AND
                                                        e.deleted_flag='0') AND d.object_type='PRJ' AND
                                                        d.deleted_flag='0') AND
                    EXISTS(SELECT NULL FROM CZ_UI_PAGES c
                            WHERE c.page_id=i.page_id AND c.ui_def_id=p_ui_def_id AND
                                  c.deleted_flag='0') AND
                    NOT EXISTS(SELECT NULL FROM cz_ui_page_elements b WHERE b.ui_def_id=p_ui_def_id AND
                               b.page_id=i.page_id AND b.element_id=NVL(a.parent_element_id,'0')))
      LOOP
        restore_Elements_Hierarchy(l_xmldoc,  p_ui_def_id, i.page_id, j.element_id);
      END LOOP;

      xmldom.freeDocument(l_xmldoc);

    END LOOP;

  END restore_Parent_Elements;

  PROCEDURE restore_Parent_Elements
  (p_ui_def_id          IN  NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2) IS

  BEGIN
    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;

    IF p_ui_def_id IS NULL THEN
      FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS WHERE ui_style='7' AND deleted_flag='0'  AND seeded_flag='0')
      LOOP
        Open_Parser();
        BEGIN
          restore_Parent_Elements(p_ui_def_id => i.ui_def_id);
        EXCEPTION
          WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE('UI '||i.ui_def_id||' can not be restored : '||SQLERRM);
            NULL;
        END;
        Close_Parser();
      END LOOP;
    ELSE
      FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS WHERE ui_style='7' AND deleted_flag='0' AND seeded_flag='0' AND
                ui_def_id IN(
                           (SELECT ref_ui_def_id
                            FROM cz_ui_refs
                            START WITH ui_def_id = p_ui_def_id
                            CONNECT by PRIOR ref_ui_def_id = ui_def_id AND
                            deleted_flag = '0')
                            UNION
                             SELECT p_ui_def_id FROM dual) )
      LOOP
        Open_Parser();
        BEGIN
          restore_Parent_Elements(p_ui_def_id => i.ui_def_id);
        EXCEPTION
          WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE('UI '||i.ui_def_id||' can not be restored : '||SQLERRM);
            NULL;
        END;
        Close_Parser();
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error in CZ_XML.restore_Parent_Elements() : '||SQLERRM;
      Close_Parser();
  END restore_Parent_Elements;

  PROCEDURE replace_UI_Rule_Ids(p_xml_node xmldom.DOMNode, p_replaced_flag OUT NOCOPY BOOLEAN) IS
    l_attribute_value       VARCHAR2(32000);
    l_user_attribute3_value VARCHAR2(32000);
  BEGIN
    p_replaced_flag := FALSE;

    l_user_attribute3_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);

    IF l_user_attribute3_value IS NULL OR l_user_attribute3_value=G_NULL_VALUE THEN
      RETURN;
    END IF;

    l_attribute_value :=  get_User_Attribute(l_user_attribute3_value, 'displayCondnId');

    IF l_attribute_value=822 THEN
        set_User_Attribute(p_cz_attribute_name    => 'displayCondnId',
                           p_cz_attribute_value   => '915',
                           px_xml_attribute_value => l_user_attribute3_value);
        set_Attribute(p_xml_node,
                      G_USER_ATTRIBUTE3_NAME,
                      l_user_attribute3_value);
        p_replaced_flag := TRUE;
    ELSIF l_attribute_value=875 THEN
        set_User_Attribute(p_cz_attribute_name    => 'displayCondnId',
                           p_cz_attribute_value   => '916',
                           px_xml_attribute_value => l_user_attribute3_value);

        set_Attribute(p_xml_node,
                      G_USER_ATTRIBUTE3_NAME,
                      l_user_attribute3_value);
        p_replaced_flag := TRUE;
    END IF;

    l_user_attribute3_value := get_Attribute_Value(p_xml_node, G_USER_ATTRIBUTE3_NAME);
    l_attribute_value :=  get_User_Attribute(l_user_attribute3_value, 'switcherCondnId');

    IF l_attribute_value=822 THEN
        set_User_Attribute(p_cz_attribute_name    => 'switcherCondnId',
                           p_cz_attribute_value   => '915',
                           px_xml_attribute_value => l_user_attribute3_value);
        set_Attribute(p_xml_node,
                      G_USER_ATTRIBUTE3_NAME,
                     l_user_attribute3_value);
        p_replaced_flag := TRUE;
    ELSIF l_attribute_value=875 THEN
        set_User_Attribute(p_cz_attribute_name    => 'switcherCondnId',
                           p_cz_attribute_value   => '916',
                           px_xml_attribute_value => l_user_attribute3_value);
        set_Attribute(p_xml_node,
                      G_USER_ATTRIBUTE3_NAME,
                      l_user_attribute3_value);
        p_replaced_flag := TRUE;
    END IF;

  END replace_UI_Rule_Ids;

  PROCEDURE restore_UI_Rule_ids
  (p_ui_def_id          IN  NUMBER,
   p_template_id        IN  NUMBER) IS

    l_xmldoc                xmldom.DOMDocument;
    l_node                  xmldom.DOMNode;
    l_nodeslist             xmldom.DOMNodeList;
    l_empty_xml_node        xmldom.DOMNode;
    l_length                NUMBER;
    l_save_doc              BOOLEAN;
    l_replaced              BOOLEAN;

  BEGIN
    IF p_template_id IS NOT NULL AND p_template_id > 0 THEN  -- UI Templates
      FOR i IN(SELECT jrad_doc FROM CZ_UI_TEMPLATES
                WHERE template_id=p_template_id AND ui_def_id IN(0,1) AND seeded_flag='0' AND deleted_flag='0')
      LOOP
        l_xmldoc    := parse_JRAD_Document(i.jrad_doc);

        l_nodeslist := xmldom.getElementsByTagName(l_xmldoc, '*');
        l_length    := xmldom.getLength(l_nodeslist);

        l_node := xmldom.makeNode(xmldom.getDocumentElement(l_xmldoc));

        l_save_doc := FALSE;

        replace_UI_Rule_Ids(l_node, l_replaced);

        IF l_replaced THEN
          l_save_doc := TRUE;
        END IF;

        --
        -- scan subtree and substitute macros "%" to real values
        --
        FOR i IN 0 .. l_length - 1
        LOOP
          l_node := xmldom.item(l_nodeslist, i);
          replace_UI_Rule_Ids(l_node, l_replaced);
          IF l_replaced THEN
            l_save_doc := TRUE;
          END IF;
        END LOOP;

        IF l_save_doc THEN
          Save_Document(p_xml_doc   => l_xmldoc,
                        p_doc_name  => i.jrad_doc);
        END IF;

        xmldom.freeDocument(l_xmldoc);

      END LOOP;

    ELSE -- UIs
      FOR i IN(SELECT jrad_doc FROM CZ_UI_PAGES
                WHERE ui_def_id=p_ui_def_id AND deleted_flag='0')
      LOOP

        l_xmldoc    := parse_JRAD_Document(i.jrad_doc);

        IF NOT(xmldom.isNull(l_xmldoc)) THEN

          l_nodeslist := xmldom.getElementsByTagName(l_xmldoc, '*');
          l_length    := xmldom.getLength(l_nodeslist);

          l_node := xmldom.makeNode(xmldom.getDocumentElement(l_xmldoc));

          l_save_doc := FALSE;

          replace_UI_Rule_Ids(l_node, l_replaced);

          IF l_replaced THEN
            l_save_doc := TRUE;
          END IF;

          --
          -- scan subtree and substitute macros "%" to real values
          --
          FOR i IN 0 .. l_length - 1
          LOOP
            l_node := xmldom.item(l_nodeslist, i);
            replace_UI_Rule_Ids(l_node,l_replaced);

            IF l_replaced THEN
              l_save_doc := TRUE;
            END IF;
          END LOOP;

          IF l_save_doc THEN
            Save_Document(p_xml_doc   => l_xmldoc,
                          p_doc_name  => i.jrad_doc);
          END IF;
        END IF;
        xmldom.freeDocument(l_xmldoc);
      END LOOP;
    END IF;
  END restore_UI_Rule_ids;


  PROCEDURE restore_UI_Rule_ids
  (p_ui_def_id          IN  NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2) IS

  BEGIN
    --dbms_output.enable(2000000);
    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;

    IF p_ui_def_id IS NULL THEN
      FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS WHERE ui_style='7' AND seeded_flag='0' AND deleted_flag='0')
      LOOP
        Open_Parser();
        BEGIN
          restore_UI_Rule_ids(p_ui_def_id => i.ui_def_id, p_template_id => NULL);
        EXCEPTION
          WHEN OTHERS THEN
             IF SQLCODE=-29532 THEN
               Close_Parser(); --release all XMLDOM objects
               Open_Parser();
               --DBMS_OUTPUT.PUT_LINE('UI Rules for UI '||i.ui_def_id||' can not be restored (XMP Parser problem) : '||SQLERRM);
             ELSE
               --DBMS_OUTPUT.PUT_LINE('UI Rules for UI '||i.ui_def_id||' can not be restored : '||SQLERRM);
               NULL;
             END IF;
        END;
        Close_Parser();
      END LOOP;
    ELSE
      FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS
                WHERE ui_def_id=p_ui_def_id AND ui_style='7' AND seeded_flag='0' AND
                      deleted_flag='0')
      LOOP
        Open_Parser();
        BEGIN
          restore_UI_Rule_ids(p_ui_def_id => i.ui_def_id, p_template_id => NULL);
        EXCEPTION
          WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE('UI Rules for UI '||i.ui_def_id||' can not be restored : '||SQLERRM);
            NULL;
        END;
        Close_Parser();
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error in CZ_XML.restore_UI_Rule_ids() : '||SQLERRM;
      Close_Parser();
  END restore_UI_Rule_ids;

  PROCEDURE restore_TMPL_Rule_ids
  (p_template_id        IN  NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2) IS

  BEGIN

    --dbms_output.enable(2000000);

    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;

    IF p_template_id IS NULL THEN
      FOR i IN(SELECT template_id FROM CZ_UI_TEMPLATES WHERE seeded_flag='0' AND deleted_flag='0')
      LOOP
        Open_Parser();
        BEGIN
          restore_UI_Rule_ids(p_ui_def_id => NULL, p_template_id => i.template_id);
        EXCEPTION
          WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE('UI Rules for UI Template '||i.template_id||' can not be restored : '||SQLERRM);
            NULL;
        END;
        Close_Parser();
      END LOOP;
    ELSE
      FOR i IN(SELECT template_id FROM CZ_UI_TEMPLATES
                WHERE template_id=p_template_id AND seeded_flag='0' AND
                      deleted_flag='0')

      LOOP
        Open_Parser();
        BEGIN
          restore_UI_Rule_ids(p_ui_def_id => NULL, p_template_id => i.template_id);
        EXCEPTION
          WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE('UI Rules for UI Template '||i.template_id||' can not be restored : '||SQLERRM);
            NULL;
        END;
        Close_Parser();
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error in CZ_XML.restore_TMPL_Rule_ids() : '||SQLERRM;
      Close_Parser();
  END restore_TMPL_Rule_ids;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

  PROCEDURE cache_UI_elements(p_ui_def_id IN NUMBER, x_ui_elements_tbl IN OUT NOCOPY ui_tbl_type) IS

    TYPE arr_tbl_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
    l_arr_tbl arr_tbl_type;
  BEGIN

    SELECT element_id BULK COLLECT INTO l_arr_tbl FROM CZ_UI_PAGE_ELEMENTS
     WHERE ui_def_id=p_ui_def_id AND  deleted_flag='0';

    IF l_arr_tbl.COUNT>0 THEN
      FOR i IN l_arr_tbl.First..l_arr_tbl.Last
      LOOP
        x_ui_elements_tbl(l_arr_tbl(i)) := l_arr_tbl(i);
      END LOOP;
    END IF;

  END cache_UI_elements;

  --------------------------------------------------------------------
  --------------------------------------------------------------------

  PROCEDURE add_Template_References
   (x_run_id             OUT NOCOPY  NUMBER,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2) IS

    l_error_message      VARCHAR2(32000);
    l_error              BOOLEAN;
    l_xmldoc             xmldom.DOMDocument;
    l_element_id         CZ_UI_PAGE_ELEMENTS.element_id%TYPE;
    l_xml_node           xmldom.DOMNode;
    l_nodeslist          xmldom.DOMNodeList;
    l_empty_xml_node     xmldom.DOMNode;
    l_length             NUMBER;
    l_attribute_value    VARCHAR2(32000);
    l_id_attribute_value VARCHAR2(32000);
    l_ui_elements_tbl    ui_tbl_type;
    l_seq_nbr            NUMBER;
    l_parent_element_id  CZ_UI_PAGE_ELEMENTS.parent_element_id%TYPE;
    l_ui_node            CZ_UI_PAGE_ELEMENTS%ROWTYPE;
    l_ui_def_id          NUMBER;

    FUNCTION find_Parent_UI_Element(p_xml_node xmldom.DOMNode) RETURN VARCHAR2 IS

       l_ui_element CZ_UI_PAGE_ELEMENTS.element_id%TYPE;

       PROCEDURE get_Parent_XML(p_check_xml_node xmldom.DOMNode) IS

         l_parent_xml_node xmldom.DOMNode;
         l_id_attr_value   VARCHAR2(32000);

       BEGIN

         l_id_attr_value := get_Attribute_Value(p_check_xml_node, G_ID_ATTRIBUTE);

         IF l_id_attr_value IS NOT NULL AND l_id_attr_value<>G_NULL_VALUE THEN

           IF l_ui_elements_tbl.EXISTS(l_id_attr_value) THEN
             l_ui_element := l_ui_elements_tbl(l_id_attr_value);
             RETURN;
           END IF;
         END IF;

         l_parent_xml_node := xmldom.getParentNode(p_check_xml_node);


         IF NOT(xmldom.isNull(l_parent_xml_node)) THEN

           l_id_attr_value := get_Attribute_Value(l_parent_xml_node , G_ID_ATTRIBUTE);


           IF l_id_attr_value IS NOT NULL AND l_id_attr_value<>G_NULL_VALUE THEN

             IF l_ui_elements_tbl.EXISTS(l_id_attr_value) THEN
               l_ui_element := l_ui_elements_tbl(l_id_attr_value);
               RETURN;
             ELSE
               get_Parent_XML(l_parent_xml_node);
             END IF;

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



  BEGIN

    Initialize(x_run_id,x_return_status,x_msg_count,x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;x_msg_count:=0;

   Open_Parser();

   FOR i IN(SELECT a.ui_def_id FROM CZ_UI_DEFS a
             WHERE a.ui_style='7' AND a.deleted_flag='0' AND
                   EXISTS(SELECT NULL FROM CZ_RP_ENTRIES b WHERE b.object_id=a.devl_project_id AND
                   b.object_type='PRJ' AND b.deleted_flag='0')
            )
   LOOP

     l_ui_def_id := i.ui_def_id;

     l_ui_elements_tbl.DELETE;
     cache_UI_elements(i.ui_def_id, l_ui_elements_tbl);

     FOR j IN(SELECT * FROM CZ_UI_PAGES WHERE ui_def_id=i.ui_def_id AND deleted_flag='0')
     LOOP
       BEGIN
         jdr_docbuilder.REFRESH;
         l_xmldoc    := parse_JRAD_Document(j.jrad_doc);

         IF xmldom.IsNull(l_xmldoc) THEN
            EXIT;
         END IF;

         l_nodeslist := xmldom.getElementsByTagName(l_xmldoc, '*');
         l_length    := xmldom.getLength(l_nodeslist);

         FOR ixml IN 0 .. l_length - 1
         LOOP
           l_xml_node := xmldom.item(l_nodeslist, ixml);

           l_attribute_value := get_Attribute_Value(l_xml_node, 'extends');

           IF l_attribute_value IS NOT NULL AND l_attribute_value <> G_NULL_VALUE THEN

             l_id_attribute_value := get_Attribute_Value(l_xml_node, G_ID_ATTRIBUTE);

             IF l_id_attribute_value IS NOT NULL AND l_id_attribute_value <> G_NULL_VALUE THEN

               l_parent_element_id := find_Parent_UI_Element(l_xml_node);

               IF l_parent_element_id <> l_id_attribute_value AND l_attribute_value IS NOT NULL AND l_attribute_value <> G_NULL_VALUE THEN

                 SELECT * INTO l_ui_node FROM CZ_UI_PAGE_ELEMENTS
                  WHERE ui_def_id=i.ui_def_id AND page_id=j.page_id AND element_id=l_parent_element_id;

                 SELECT CZ_UI_PAGE_ELEMENTS_S.NEXTVAL INTO l_element_id FROM dual;

                 FOR templ IN(SELECT template_id,template_name  FROM CZ_UI_TEMPLATES
                               WHERE ui_def_id=0 AND jrad_doc=l_attribute_value AND deleted_flag='0')
                 LOOP
                   SELECT NVL(max(seq_nbr),0)+1 INTO l_seq_nbr FROM CZ_UI_PAGE_ELEMENTS
                    WHERE ui_def_id=i.ui_def_id AND
                          page_id=j.page_id AND
                          parent_element_id=l_parent_element_id AND
                          deleted_flag='0';

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
                      i.ui_def_id
                      ,j.page_id
                      ,NULL
                      ,l_element_id
                      ,l_ui_node.parent_persistent_node_id
                      ,l_ui_node.region_persistent_node_id
                      ,l_ui_node.pagebase_persistent_node_id
                      ,templ.template_id
                      ,'0'
                      ,'0'
                      ,l_seq_nbr
                      ,'0'
                      ,0
                      ,NULL
                      ,'0'
                      ,l_parent_element_id
                      ,NULL
                      ,templ.template_name
                      ,6011
                      ,NULL
                      ,NULL
                      );

                    set_Attribute(l_xml_node, G_ID_ATTRIBUTE, l_element_id);

                 END LOOP;

               END IF; -- end of IF l_parent_element_id <> l_id_attribute_value THEN

             END IF;  -- end of IF l_id_attribute_value IS NOT NULL THEN

           END IF;

         END LOOP;

         BEGIN
           Save_Document(p_xml_doc   => l_xmldoc,
                         p_doc_name  => j.jrad_doc);
         EXCEPTION
           WHEN OTHERS THEN
             IF SQLCODE=1 THEN -- exception in JDR_DOCBUILDER
               l_error_message := 'UI with ui_def_id='||i.ui_def_id||' page_id='||j.page_id||
                      ' can not be upgraded because of some problems with its JRAD XML';
               l_error :=CZ_UTILS.REPORT(l_error_message, 1, 'czueupg.sql', 13000);
             END IF;
         END;

         xmldom.freeDocument(l_xmldoc);

       END;

     END LOOP;

   END LOOP;

  Close_Parser();

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Fatal error in add_Template_References() : '||SQLERRM;
  END add_Template_References;

END CZ_XML;

/
