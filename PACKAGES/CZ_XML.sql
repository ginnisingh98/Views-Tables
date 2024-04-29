--------------------------------------------------------
--  DDL for Package CZ_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_XML" AUTHID CURRENT_USER AS
/*  $Header: czxmls.pls 120.0 2006/03/17 07:31 skudryav noship $   */

  G_OA_STYLE_UI              CONSTANT VARCHAR2(255) := '7';

  G_RUN_ID                   NUMBER;

  PROCEDURE Test_UI_Pages(p_ui_def_id IN NUMBER);

  FUNCTION parse_JRAD_Document(p_doc_full_name IN VARCHAR2)
    RETURN xmldom.DOMDocument;

  PROCEDURE Save_Document(p_xml_doc  xmldom.DOMDocument,
                          p_doc_name IN VARCHAR2);

  PROCEDURE detect_Doc_Bad_Attributes
  (p_doc_full_name           IN  VARCHAR2,
   x_bad_attributes_detected OUT NOCOPY BOOLEAN);

  PROCEDURE remove_Bad_Attributes_in_Doc
   (p_doc_full_name           IN  VARCHAR2);

  PROCEDURE detect_UIS_with_Bad_Attributes
  (p_ui_def_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE remove_Bad_Attributes_in_UIS
  (p_ui_def_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE detect_TMPLS_with_Bad_Attrs
  (p_template_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE remove_Bad_Attributes_in_TMPLS
  (p_template_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE replace_Bad_Element_Ids
  (p_ui_def_id IN NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE restore_Parent_Elements
  (p_ui_def_id          IN  NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE restore_UI_Rule_ids
  (p_ui_def_id          IN  NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE restore_TMPL_Rule_ids
  (p_template_id        IN  NUMBER DEFAULT NULL,
   x_run_id             OUT NOCOPY  NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE add_Template_References
   (x_run_id             OUT NOCOPY  NUMBER,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2);

END CZ_XML;

 

/
