--------------------------------------------------------
--  DDL for Package CCT_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: cctuupgs.pls 115.18 2004/03/26 00:26:58 sradhakr ship $ */
   PROCEDURE add_column (
         schema_name     IN VARCHAR2
	    , table_name      IN VARCHAR2
         , col_name      IN VARCHAR2);
   /* Added on March 19 2003 rajayara */
   PROCEDURE add_varchar_column (
             schema_name     IN VARCHAR2
	    , table_name      IN VARCHAR2
            , col_name      IN VARCHAR2);

   PROCEDURE update_column
         (table_name     IN VARCHAR2
          , new_col_name IN VARCHAR2
          , old_col_name IN VARCHAR2
          , new_value    IN NUMBER
          , old_value    IN NUMBER);

   PROCEDURE modify_column_to_nullable  (
         schema_name     IN VARCHAR2
	 , table_name    IN VARCHAR2
         , col_name      IN VARCHAR2);

  PROCEDURE MODIFY_SEQUENCE_WITH_VALUE  (
	  schema_name  IN VARCHAR2
	  ,sequence_name    IN VARCHAR2
	  ,replacement_value IN VARCHAR2
         );

   PROCEDURE modify_new_sequence_from_old  (
		schema_name  IN VARCHAR2
		  ,sequence_name    IN VARCHAR2
	    ,old_sequence_name IN VARCHAR2
						   );

   PROCEDURE modify_sequence_with_verify  (
		schema_name  IN VARCHAR2
		,sequence_name    IN VARCHAR2
	        ,old_sequence_name IN VARCHAR2
		);

   PROCEDURE drop_column (
         schema_name     IN VARCHAR2
	    , table_name      IN VARCHAR2
         , col_name      IN VARCHAR2);
   PROCEDURE copy_all_rows (
	old_table_name   IN VARCHAR2
        , new_table_name IN VARCHAR2);

   PROCEDURE delete_fnd_lookups(
         lookupType   IN VARCHAR2
         , lookupCode IN VARCHAR2
         );

   PROCEDURE delete_fnd_lookups(
         lookupType    IN VARCHAR2
         , lookupCode  IN VARCHAR2
	 , lang        IN VARCHAR2
	    );

   Procedure upgrade_mware_values;

   Procedure change_params_in_mvalues;

   Procedure delete_prospect_aspect;

   Procedure delete_middleware_type(p_middleware_type_id IN Number);

   PROCEDURE upgrade_ao_flg_mw_values;

   Procedure update_mwparam_in_mwvalues(p_old_type IN VARCHAR2,p_old_param_name IN VARCHAR2,p_new_type IN VARCHAR2,p_new_param_name IN VARCHAR2);
   Procedure update_agparam_in_agvalues(p_old_type IN VARCHAR2, p_old_param_name in VARCHAR2, p_new_type IN VARCHAR2,p_new_param_name IN VARCHAR2);
   Procedure update_mtype_in_mware(p_middleware_id IN Number,p_old_type in VARCHAR2, p_new_type IN VARCHAR2);
   Procedure delete_middleware_value(p_middleware_type in VARCHAR2,p_param_name in VARCHAR2);
   Procedure update_agent_values(p_agent_param IN VARCHAR2,p_middleware_type_id IN VARCHAR2,p_new_agent_param_id In NUMBER);

   Procedure increment_ikey_sequence;

END cct_upgrade_pkg;

 

/
