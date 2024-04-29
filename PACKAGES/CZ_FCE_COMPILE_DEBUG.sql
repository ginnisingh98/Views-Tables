--------------------------------------------------------
--  DDL for Package CZ_FCE_COMPILE_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_FCE_COMPILE_DEBUG" AUTHID CURRENT_USER AS
/*	$Header: czfcedbs.pls 120.3 2007/08/14 21:49:21 asiaston ship $		*/
---------------------------------------------------------------------------------------
FUNCTION get_constant_value( ConstantPool IN BLOB
                           , p_ptr IN PLS_INTEGER
                           )
  RETURN VARCHAR2;
---------------------------------------------------------------------------------------
PROCEDURE dump_code_memory( CodeMemory IN BLOB, ConstantPool IN BLOB, p_run_id IN NUMBER );
---------------------------------------------------------------------------------------
PROCEDURE dump_constant_pool( ConstantPool IN BLOB, p_run_id IN NUMBER );
---------------------------------------------------------------------------------------
PROCEDURE dump_logic ( p_fce_file IN BLOB, p_run_id IN NUMBER );
---------------------------------------------------------------------------------------
PROCEDURE dump_logic ( p_model_id IN NUMBER, p_run_id IN NUMBER );
---------------------------------------------------------------------------------------
END;

/
