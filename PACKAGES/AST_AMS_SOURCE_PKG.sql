--------------------------------------------------------
--  DDL for Package AST_AMS_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_AMS_SOURCE_PKG" AUTHID CURRENT_USER as
/* $Header: astmsrcs.pls 115.2 2002/02/05 18:03:49 pkm ship      $ */
-- Start of Comments
-- Package name     : ast_ams_source_pkg
-- Purpose          : Function to provide source code name in the view AST_AMS_SOURCE_CODES_V
-- History          :
-- NOTE             :
-- End of Comments

function fetch_source_code_name (
	p_source_code_type IN VARCHAR2,
	p_source_code IN VARCHAR2)
return VARCHAR2;

END ast_ams_source_pkg;

 

/
