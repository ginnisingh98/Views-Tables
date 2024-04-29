--------------------------------------------------------
--  DDL for Package PQP_EXPREPLOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXPREPLOD_PKG" AUTHID CURRENT_USER AS
/* $Header: pqexrpld.pkh 120.0 2005/05/29 01:46:57 appldev noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed to run Multi-Threaded Proc
--

*/
PROCEDURE load_data
(
   actid                   IN     NUMBER,
   p_effective_date       IN     DATE
       );
PROCEDURE upd_payroll_actions (pactid                  IN NUMBER,
                               p_payroll_id            IN NUMBER,
                               p_consolidation_set_id  IN NUMBER,
                               p_effective_date        IN DATE);
PROCEDURE run_preprocess      (actid                   IN     NUMBER,
                               p_effective_date        IN DATE);

FUNCTION get_offset_date ( p_payroll_id         IN NUMBER
          ,p_consolidation_id   IN NUMBER
          ,p_effective_date     IN  DATE   )
 RETURN NUMBER ;

-- =============================================================================
-- Get_Tax_Start_Date	:Used to get the Financial Tax Year
-- =============================================================================
FUNCTION Get_Tax_Start_Date
         (p_legislation_code     IN  VARCHAR2
         ,p_effective_date       IN  Date
	 ,p_dimension_type_id    IN  pay_balance_dimensions.balance_dimension_id%TYPE
         ) RETURN DATE ;
-- =============================================================================
-- Get_Previous_Year_Tax_Date :Used to get the Previous tax year based on
-- Financial Tax year
-- =============================================================================
FUNCTION Get_Previous_Year_Tax_Date
         (p_tax_year_start_date  IN  Date
         ,p_effective_date       IN  Date ) RETURN DATE;
-- =============================================================================
-- Get_Previous_Quarter_Tax_Date :Used to get the Previous quater date based on
-- Financial Tax year
-- =============================================================================
FUNCTION Get_Previous_Quarter_Tax_Date
         (p_tax_year_start_date  IN  Date
         ,p_effective_date       IN  Date
	 ,p_count                IN  NUMBER) RETURN DATE;




END;


 

/
