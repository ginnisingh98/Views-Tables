--------------------------------------------------------
--  DDL for Package PSB_DISCOVERER_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_DISCOVERER_FUNCTIONS" AUTHID CURRENT_USER as
/*$Header: PSBVDISS.pls 115.2 2002/11/22 07:38:50 pmamdaba ship $*/

  Function  ws_get_amount(p_required_stage_seq in number,
                          p_start_stage_seq in number,
                          p_current_stage_seq in number,
                          p_ytd_amount in number)
                        RETURN Number;
        pragma RESTRICT_REFERENCES(ws_get_amount, WNDS, WNPS);

  Function Get_GL_Balance(p_revision_type         IN    VARCHAR2,
                          p_balance_type          IN    VARCHAR2,
                          p_set_of_books_id       IN    NUMBER,
                          p_xbc_enabled_flag      IN    VARCHAR2,
                          p_gl_period_name        IN    VARCHAR2,
                          p_gl_budget_version_id  IN    NUMBER,
                          p_currency_code         IN    VARCHAR2,
                          p_code_combination_id   IN    NUMBER) RETURN NUMBER;
        pragma RESTRICT_REFERENCES(ws_get_amount, WNDS, WNPS);

End PSB_DISCOVERER_FUNCTIONS;

 

/
