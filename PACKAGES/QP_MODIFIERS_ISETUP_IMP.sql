--------------------------------------------------------
--  DDL for Package QP_MODIFIERS_ISETUP_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIERS_ISETUP_IMP" AUTHID CURRENT_USER AS
/* $Header: QPMODIMS.pls 120.2 2006/07/07 19:29:37 rbagri noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      QPMODIMB.pls
--
--  DESCRIPTION
--
--      Specifications of package QP_MODIFIERS_ISETUP_IMP
--
--  NOTES
--
--  HISTORY
--
--  31-DEC-01   Anupam Jain    Initial Creation
***************************************************************************/
FUNCTION get_product_code  (p_product_attr_context  varchar2,
                            p_product_attr  varchar2,
                            p_product_attr_val varchar2) RETURN VARCHAR2;


FUNCTION get_product_value  (p_product_attr_context  varchar2,
                            p_product_attr  varchar2,
                            p_product_attr_val varchar2) RETURN VARCHAR2;


FUNCTION get_qualifier_code  (p_qualifier_attr_context  varchar2,
                            p_qualifier_attr  varchar2,
                            p_qualifier_attr_val varchar2) RETURN VARCHAR2;

FUNCTION get_qualifier_value  (p_qualifier_attr_context  varchar2,
                            p_qualifier_attr  varchar2,
                            p_qualifier_attr_val varchar2) RETURN VARCHAR2;

PROCEDURE Import_Modifiers
                         (P_debug                      IN VARCHAR2 := 'N',
                          P_output_dir                 IN VARCHAR2 := NULL,
                          P_debug_filename             IN VARCHAR2 := 'QP_Modifiers_debug.log',
                          P_modifier_list_XML          IN CLOB,
                          P_modifier_list_lines_XML    IN CLOB,
                          P_pricing_attributes_XML     IN CLOB,
                          P_Qualifiers_XML             IN CLOB,
                          X_return_status              OUT NOCOPY VARCHAR2,
                          X_msg_count                  OUT NOCOPY NUMBER,
                          X_G_MSG_DATA 		       OUT NOCOPY Long);
END QP_MODIFIERS_ISETUP_IMP;

 

/
