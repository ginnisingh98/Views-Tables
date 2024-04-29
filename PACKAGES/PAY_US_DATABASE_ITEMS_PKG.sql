--------------------------------------------------------
--  DDL for Package PAY_US_DATABASE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_DATABASE_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: pyusdbip.pkh 115.1 99/07/17 06:42:56 porting ship  $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyusdbip.pkh
--
   DESCRIPTION
      See description in pyusdbip.pkb
--
  MODIFIED (DD-MON-YYYY)
  S Panwar  18-SEP-1995      Created
  M Reid    06-JUN-1997 40.2 Removed show errors
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
end pay_us_database_items_pkg;

 

/
