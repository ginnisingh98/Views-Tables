--------------------------------------------------------
--  DDL for Package AST_INT_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_INT_PACKAGE" AUTHID CURRENT_USER as
/* $Header: astints.pls 115.2 2003/01/02 23:54:52 jraj noship $ */
-- Start of Comments
-- Package name     : ast_int_package
-- Purpose          : Function to provide Object details for call statistics.
-- History          :
-- NOTE             :
-- End of Comments

procedure int_context_val (
	p_sql_statement IN varchar2,
	p_object_val IN OUT NOCOPY number,
	p_object_id IN number);


END;

 

/
