--------------------------------------------------------
--  DDL for Package JTF_BRM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_BRM_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvbuts.pls 115.8 2002/02/14 13:18:32 pkm ship     $ */

FUNCTION Attribute_Format
/************************************************************
** This function is used in the JTF_BRM_ATTR_VALUES_V view
** to retriev and format the workflow attribute value so
** it can be queried as a text item in the JTFBRWKB form
************************************************************/
( p_attribute_type       IN VARCHAR2
, p_text_value           IN VARCHAR2
, p_number_value         IN NUMBER
, p_date_value           IN DATE
, p_format               IN VARCHAR2
)RETURN VARCHAR2;

FUNCTION Attribute_Code
/************************************************************
** - If an attribute lookup value is specified for the rule
**   the LOOKUP_CODE will be returned.
** - If no attribute lookup value is specified for the rule
**   the default value will be returned
************************************************************/
(p_rule_id               IN VARCHAR2
,p_wf_item_type          IN VARCHAR2
,p_wf_process_name       IN VARCHAR2
,p_wf_attribute_name     IN VARCHAR2
)RETURN VARCHAR2;

FUNCTION Attribute_Meaning
/************************************************************
** - If an attribute lookup value is specified for the rule
**   the Meaning will be returned.
** - If no attribute lookup value is specified for the rule
**   the default value will be returned
************************************************************/
(p_rule_id               IN VARCHAR2
,p_wf_item_type          IN VARCHAR2
,p_wf_process_name       IN VARCHAR2
,p_wf_attribute_name     IN VARCHAR2
)RETURN VARCHAR2;

END JTF_BRM_UTILITY_PVT;

 

/
