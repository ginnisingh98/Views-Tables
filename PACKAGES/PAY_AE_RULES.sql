--------------------------------------------------------
--  DDL for Package PAY_AE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_RULES" AUTHID CURRENT_USER AS
/* $Header: pyaerule.pkh 120.0 2006/01/17 01:06 adevanat noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< PAY_AE_RULES >--------------------------------|
-- ----------------------------------------------------------------------------
--

  PROCEDURE add_custom_xml
    (p_assignment_action_id NUMBER
    ,p_action_information_category VARCHAR2
    ,p_document_type VARCHAR2) ;

  PROCEDURE load_xml
    (p_node_type     VARCHAR2
    ,p_context_code  VARCHAR2
    ,p_node          VARCHAR2
    ,p_data          VARCHAR2) ;

  FUNCTION flex_seg_enabled
    (p_context_code              VARCHAR2
    ,p_application_column_name   VARCHAR2) RETURN BOOLEAN ;

  PROCEDURE element_template_post_process
    (p_template_id       IN NUMBER);

END PAY_AE_RULES ;

 

/
