--------------------------------------------------------
--  DDL for Package Body AST_INT_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_INT_PACKAGE" AS
/* $Header: astintb.pls 120.0 2005/05/31 02:04:07 appldev noship $ */
-- Start of Comment
-- Package name     : ast_int_package
-- Purpose          : Function to provide object details for call statistics
-- History          :
-- NOTE             :
-- End of Comments

procedure int_context_val (
	p_sql_statement IN varchar2,
	p_object_val IN OUT NOCOPY number,
	p_object_id IN number) is
BEGIN
	EXECUTE IMMEDIATE p_sql_statement INTO p_object_val USING p_object_id;
EXCEPTION WHEN OTHERS THEN
    null;
END int_context_val;

END ast_int_package;

/
