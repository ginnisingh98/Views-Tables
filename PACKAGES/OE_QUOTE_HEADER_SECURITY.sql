--------------------------------------------------------
--  DDL for Package OE_QUOTE_HEADER_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_QUOTE_HEADER_SECURITY" AUTHID CURRENT_USER AS
/* $Header: asodhdss.pls 120.0 2005/05/31 11:46:18 appldev noship $ */


-- Package Globals
g_check_all_cols_constraint VARCHAR2(1) := 'Y';
g_is_caller_defaulting      VARCHAR2(1) := 'N';
-- Entity global record that is used in APIs for validation templates
-- and the generated validation packages to access attribute values
-- on the entity record
g_record				   ASO_AK_QUOTE_HEADER_V%ROWTYPE;


END OE_Quote_Header_Security;

 

/
