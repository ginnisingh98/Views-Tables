--------------------------------------------------------
--  DDL for Package Body PSB_DISCOVERER_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_DISCOVERER_FUNCTIONS" as
/*$Header: PSBVDISB.pls 115.2 2002/11/22 07:38:45 pmamdaba ship $*/

Function  ws_get_amount(p_required_stage_seq in number,
                        p_start_stage_seq in number,
                        p_current_stage_seq in number,
                        p_ytd_amount in number) RETURN NUMBER IS

 Begin

   if ((p_required_stage_seq >= p_start_stage_seq) AND (p_required_stage_seq <= p_current_stage_seq))
     then return(p_ytd_amount);
     else return(0);
   end if;

 End ws_get_amount;

Function Get_GL_Balance(p_revision_type         IN    VARCHAR2,
                        p_balance_type          IN    VARCHAR2,
                        p_set_of_books_id       IN    NUMBER,
                        p_xbc_enabled_flag      IN    VARCHAR2,
                        p_gl_period_name        IN    VARCHAR2,
                        p_gl_budget_version_id  IN    NUMBER,
                        p_currency_code         IN    VARCHAR2,
                        p_code_combination_id   IN    NUMBER) RETURN NUMBER IS
 Begin

   return PSB_BUDGET_REVISIONS_PVT.Get_GL_Balance(p_revision_type => p_revision_type,
                                                  p_balance_type => p_balance_type,
                                                  p_set_of_books_id => p_set_of_books_id,
                                                  p_xbc_enabled_flag => p_xbc_enabled_flag,
                                                  p_gl_period_name => p_gl_period_name,
                                                  p_gl_budget_version_id => p_gl_budget_version_id,
                                                  p_currency_code => p_currency_code,
                                                  p_code_combination_id => p_code_combination_id);
 End Get_GL_Balance;

End PSB_DISCOVERER_FUNCTIONS;

/
