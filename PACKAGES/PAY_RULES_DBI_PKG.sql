--------------------------------------------------------
--  DDL for Package PAY_RULES_DBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RULES_DBI_PKG" AUTHID CURRENT_USER as
/* $Header: pywatdbi.pkh 115.1 99/07/17 06:49:44 porting ship  $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pywatdbi.pkh
--
   DESCRIPTION
      See description in pywatdbi.pkb
--
  MODIFIED (DD-MON-YYYY)
  H Parichabutr  14-NOV-1995      Created
rem    110.1   19 jun 99        i harding       added ; to exit

*/
--
-- Procedures
--
PROCEDURE create_db_item(p_name                    VARCHAR2,
                         p_description             VARCHAR2 DEFAULT NULL,
                         p_data_type               VARCHAR2,
                         p_null_allowed            VARCHAR2,
			 p_definition_text         VARCHAR2,
                         p_user_entity_name        VARCHAR2,
			 p_user_entity_description VARCHAR2 DEFAULT NULL,
                         p_route_name              VARCHAR2,
                         p_param_value1            VARCHAR2 DEFAULT NULL,
			 p_param_value2            VARCHAR2 DEFAULT NULL,
                         p_route_description       VARCHAR2 DEFAULT NULL,
			 p_route_text              VARCHAR2 DEFAULT NULL,
			 p_context_name1           VARCHAR2 DEFAULT NULL,
			 p_context_name2           VARCHAR2 DEFAULT NULL,
			 p_context_name3           VARCHAR2 DEFAULT NULL,
			 p_context_name4           VARCHAR2 DEFAULT NULL,
                         p_param_name1             VARCHAR2 DEFAULT NULL,
			 p_param_type1             VARCHAR2 DEFAULT NULL,
			 p_param_name2             VARCHAR2 DEFAULT NULL,
                         p_param_type2             VARCHAR2 DEFAULT NULL);
--

PROCEDURE create_table_column_dbi (	p_table_name		VARCHAR2,
					p_table_short_name	VARCHAR2,
					p_route_sql		VARCHAR2,
					p_key_context1		VARCHAR2,
					p_key_context2		VARCHAR2,
					p_key_context3		VARCHAR2,
					p_key_context4		VARCHAR2);

PROCEDURE create_garntab_dbi;

end pay_rules_dbi_pkg;

 

/
