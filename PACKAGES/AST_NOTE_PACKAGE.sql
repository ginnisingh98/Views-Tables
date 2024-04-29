--------------------------------------------------------
--  DDL for Package AST_NOTE_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_NOTE_PACKAGE" AUTHID CURRENT_USER as
/* $Header: astnotes.pls 120.1 2005/06/01 03:39:16 appldev  $ */
-- Start of Comments
-- Package name     : ast_note_package
-- Purpose          : Function to provide Object details in the view AST_NOTE_CONTEXTS_V
-- History          :
-- NOTE             :
-- End of Comments

procedure note_context_info (
	p_sql_statement IN varchar2,
	p_object_info IN OUT NOCOPY /* file.sql.39 change */ varchar2,
	p_object_id IN number);

function note_context_info (
	p_select_id VARCHAR2,
	p_select_name VARCHAR2,
	p_select_details VARCHAR2,
	p_from_table VARCHAR2,
	p_where_clause VARCHAR2,
	p_object_id NUMBER)
return VARCHAR2;

function party_type_info (
	p_object_id NUMBER)
return VARCHAR2;

function read_clob (
	p_clob CLOB)
return VARCHAR2;

function read_clob (
	p_note_id NUMBER)
return VARCHAR2;

END;

 

/
