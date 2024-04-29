--------------------------------------------------------
--  DDL for Package PAY_DATABASE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATABASE_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: pycadbis.pkh 120.0 2005/05/29 03:28:52 appldev noship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pycadbip.pkh
--
   DESCRIPTION
      See description in pycadbip.pkb
--
  MODIFIED (DD-MON-YYYY)
  RThirlby  20_JUL-1999      Created (Copy of pyusdbip.pkh, but with
                             new legislation_code parameter.
  RThirlby  29-FEB-2000      No changes for 11i upport.
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
                         p_param_type2             VARCHAR2 DEFAULT NULL,
                         p_legislation_code        VARCHAR2 );
--
end pay_database_items_pkg;

 

/
