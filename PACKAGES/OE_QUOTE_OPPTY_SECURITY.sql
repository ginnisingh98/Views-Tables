--------------------------------------------------------
--  DDL for Package OE_QUOTE_OPPTY_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_QUOTE_OPPTY_SECURITY" AUTHID CURRENT_USER AS
/* $Header: asodhoss.pls 120.0 2005/05/31 12:45:52 appldev noship $ */


-- Package Globals
g_check_all_cols_constraint VARCHAR2(1) := 'Y';
g_is_caller_defaulting      VARCHAR2(1) := 'N';
-- Entity global record that is used in APIs for validation templates
-- and the generated validation packages to access attribute values
-- on the entity record
g_record				   ASO_AK_QUOTE_OPPTY_V%ROWTYPE;


END OE_Quote_Oppty_Security;

 

/
