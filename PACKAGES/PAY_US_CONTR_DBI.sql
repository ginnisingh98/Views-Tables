--------------------------------------------------------
--  DDL for Package PAY_US_CONTR_DBI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_CONTR_DBI" AUTHID CURRENT_USER as
/* $Header: pyuscont.pkh 120.0 2005/05/29 09:19:46 appldev noship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyuscont.pkh
--
   DESCRIPTION
   Procedures required to create the startup data for US Benefit Contribution
   Database Items, and procedures required to create the Database Items
   Dynamically on creation of Input Values.

   These procedures create the following objects

   Routes
   ------
   COVERAGE_VALUES
   CONTRIBUTION_VALUES

   Database Items
   --------------
   <ENTITY_NAME>_COVERAGE_VALUE
   <ENTITY_NAME>_EE_CONTR_VALUE
   <ENTITY_NAME>_ER_CONTR_VALUE

Name       Date          Change Details
--------   ----------    -----------------------------------------------
JRhodes    20-OCT-1993   Created
RFine      05-OCT-1994   Prepended 'PAY_' to package name as per standards
RFine      15-MAY-1995   Changed 'show errors' from package body to package.

*/
--
PROCEDURE create_usdbi_startup;
--
PROCEDURE create_contr_items
(p_input_value_id    IN NUMBER
,p_effective_date    IN DATE
,p_start_string      IN VARCHAR2
,p_end_string        IN VARCHAR2
,p_data_type         IN VARCHAR2
);
--
END pay_us_contr_dbi;

 

/
