--------------------------------------------------------
--  DDL for Package PQP_PENS_AND_AVCS_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENS_AND_AVCS_FUNCTION" AUTHID CURRENT_USER AS
-- $Header: pqgbpafn.pkh 115.2 2003/02/14 19:19:36 tmehra noship $
-----------------------------------------------------------------------------
-- PQP_CHECK_PENS_CAP
-----------------------------------------------------------------------------
FUNCTION  pqp_check_pension_cap(    p_salary_cap          IN      NUMBER
                                   ,p_salary_prp_cap      IN      NUMBER
                                   ,p_total_contribution  IN OUT NOCOPY  NUMBER
                                   ,p_superannuable_ptd   IN      NUMBER
                                   ,p_superannuation_tot  IN      NUMBER
                                   ,p_total_pens_cont     IN      NUMBER
                                   )
RETURN CHAR;

-----------------------------------------------------------------------------
-- PQP_CHECK_NET_PAY
-----------------------------------------------------------------------------
FUNCTION  pqp_check_net_pay(p_total_contribution  IN OUT NOCOPY  NUMBER
                           ,p_net_pay_ptd         IN      NUMBER
                           )
RETURN CHAR;

-----------------------------------------------------------------------------

END pqp_pens_and_avcs_function;

 

/
