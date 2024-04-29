--------------------------------------------------------
--  DDL for Package FEM_UNDO_UI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_UNDO_UI_PKG" AUTHID CURRENT_USER AS
/* $Header: FEMUNDOUIS.pls 120.1 2006/06/30 08:41:29 asadadek noship $ */

 FUNCTION get_user_name(p_user_id NUMBER) RETURN VARCHAR2 ;

 FUNCTION get_undo_status(p_object_id NUMBER,p_request_id NUMBER) RETURN VARCHAR2;

 FUNCTION is_ledger_table(p_table_name VARCHAR2) RETURN VARCHAR2;

 FUNCTION is_undo_valid(p_ud_session_id NUMBER,p_object_id NUMBER,p_request_id NUMBER) RETURN VARCHAR2;

 END  fem_undo_ui_pkg;

 

/
