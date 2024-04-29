--------------------------------------------------------
--  DDL for Package FND_TS_MIG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TS_MIG_UTIL" AUTHID DEFINER AS
/* $Header: fndptmus.pls 120.2 2005/11/15 16:27:51 mnovakov noship $ */
 l_def_tab_tsp         VARCHAR2(30) := 'TRANSACTION_TABLES';
 l_aq_tab_tsp          VARCHAR2(30) :=  'AQ';
 l_md_tab_tsp          VARCHAR2(30) :=  'MEDIA';
 l_def_ind_tsp         VARCHAR2(30) := 'TRANSACTION_INDEXES';
 l_def_mv_tsp          VARCHAR2(30) := 'SUMMARY';
 l_unclass_tsp         VARCHAR2(30) := 'TRANSACTION_TABLES';
 l_unclass_ind_tsp     VARCHAR2(30) := 'TRANSACTION_INDEXES';


 FUNCTION get_db_version
  RETURN NUMBER;

 -- Set the TABLESPACE_NAME in gl_storage_parameters to INTERFACE.
 PROCEDURE upd_gl_storage_param (p_tablespace_type VARCHAR2);

 PROCEDURE migrate_tsp_to_local;

 FUNCTION get_tablespace_name (p_tablespace_type IN VARCHAR2)
  RETURN VARCHAR2;

 FUNCTION get_tablespace_ues (p_tablespace_name IN VARCHAR2)
  RETURN NUMBER;

 PROCEDURE chk_new_tablespaces;

 PROCEDURE chk_new_tables;

 PROCEDURE chk_product_defaults;

 PROCEDURE crt_storage_pref (p_tablespace_type IN VARCHAR2,
                             l_pref_name IN VARCHAR2);

 PROCEDURE upd_fot_username;

 PROCEDURE process_rules(p_apps_schema_name IN VARCHAR2);

 PROCEDURE set_defaults;

 PROCEDURE crt_txn_ind_pref;

END fnd_ts_mig_util;

 

/
