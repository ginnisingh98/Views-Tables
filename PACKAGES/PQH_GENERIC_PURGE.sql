--------------------------------------------------------
--  DDL for Package PQH_GENERIC_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GENERIC_PURGE" AUTHID CURRENT_USER AS
/* $Header: pqgenpur.pkh 115.3 2002/12/06 18:06:34 rpasapul noship $ */
--Main procedure that calls the rest

  PROCEDURE pqh_gen_purge
        (errbuf       OUT NOCOPY varchar2,
         retcode      OUT NOCOPY number,
         p_alias      IN pqh_table_route.table_alias%TYPE,
         paramname1   IN pqh_attributes.column_name%TYPE DEFAULT NULL,
         paramvalue1  IN VARCHAR2 DEFAULT NULL,
         paramname2   IN pqh_attributes.column_name%TYPE DEFAULT NULL,
         paramvalue2  IN VARCHAR2 DEFAULT NULL,
         paramname3   IN pqh_attributes.column_name%TYPE DEFAULT NULL,
         paramvalue3  IN VARCHAR2 DEFAULT NULL,
         paramname4   IN pqh_attributes.column_name%TYPE DEFAULT NULL,
         paramvalue4  IN VARCHAR2 DEFAULT NULL,
         paramname5   IN pqh_attributes.column_name%TYPE DEFAULT NULL,
         paramvalue5  IN VARCHAR2 DEFAULT NULL,
         p_effective_date IN DATE DEFAULT SYSDATE);

   --To Populate the Pl/SQL table to be used in procedure 'replace_where_params'

  PROCEDURE populate_pltable
        (l_master_tab_route_id IN pqh_table_route.table_ROUTE_ID%TYPE,
         paramname1   IN pqh_attributes.column_name%TYPE,
         paramvalue1  IN VARCHAR2,
         paramname2   IN pqh_attributes.column_name%TYPE,
         paramvalue2  IN VARCHAR2,
         paramname3   IN pqh_attributes.column_name%TYPE,
         paramvalue3  IN VARCHAR2,
         paramname4   IN pqh_attributes.column_name%TYPE,
         paramvalue4  IN VARCHAR2,
         paramname5   IN pqh_attributes.column_name%TYPE,
         paramvalue5  IN VARCHAR2);

    -- To identify child table records for the parent txn


  PROCEDURE del_child_records
        (p_alias_name           IN pqh_table_route.table_alias%TYPE,
         p_parent_pk_value      IN NUMBER);

 -- To handle the final purge of records

 PROCEDURE call_delete_api
       (p_tab_route_id            IN pqh_table_route.table_route_id%TYPE,
        p_pk_value                IN NUMBER,
        p_from_clause_txn         IN pqh_table_route.from_clause%TYPE,
        p_pk_col_name             IN pqh_attributes.column_name%TYPE);
--
-- To enter data into conc log file

 PROCEDURE enter_conc_log(p_pk_value 		IN NUMBER,
			  tab_rou_id 		IN NUMBER,
 			  p_from_clause_txn     IN pqh_table_route.from_clause%TYPE,
			  p_pk_col_name   	IN pqh_attributes.column_name%TYPE);

  FUNCTION get_col_type
        (p_column_name IN pqh_attributes.column_name%TYPE,
         l_master_table_route_id   IN pqh_table_route.table_route_id%TYPE)
  RETURN VARCHAR2;

END pqh_generic_purge;

 

/
