--------------------------------------------------------
--  DDL for Package PA_UBR_UER_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UBR_UER_SUMM_PKG" AUTHID CURRENT_USER AS
/* $Header: PABLUBRS.pls 120.1 2005/08/05 03:06:25 lveerubh noship $ */

    /** Global Variables declaration **/
    G_created_by             NUMBER := NVL(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
    G_last_update_login      NUMBER := NVL(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')), -1);
    G_last_updated_by        NUMBER := G_created_by;
    G_creation_date          DATE   := SYSDATE;
    G_last_update_date       DATE   := SYSDATE ;

    G_fetch_size             NUMBER := 1000;

    G_ccid                   NUMBER := -1;
    G_cost_seg_val           VARCHAR2(60);
    G_acct_seg_val           VARCHAR2(60);

    G_org_id_v               NUMBER;
    G_set_of_books_id        NUMBER;
    G_gl_period_name         VARCHAR2(80);
    G_gl_start_date          DATE ;
    G_gl_end_date            DATE ;

    G_p_gl_end_date          DATE ;

    G_p_from_project_number  VARCHAR2(60);
    G_p_to_project_number    VARCHAR2(60);
    G_p_gl_period_name       VARCHAR2(60);
    G_p_request_id           NUMBER;

    G_coa_id                 NUMBER;
    G_sob                    NUMBER;
    G_org_id                 NUMBER;
    G_cost_seg_num           NUMBER;
    G_acct_seg_num           NUMBER;

    G_acct_appcol_name       VARCHAR2(60);
    G_acct_seg_name          VARCHAR2(60);
    G_acct_prompt            VARCHAR2(60);
    G_acct_value_set_name    VARCHAR2(60);

    G_cost_appcol_name       VARCHAR2(60);
    G_cost_seg_name          VARCHAR2(60);
    G_cost_prompt            VARCHAR2(60);
    G_cost_value_set_name    VARCHAR2(60);

    G_p_invoice_num                NUMBER;
    G_p_ubr_code_combination_id    NUMBER;
    G_p_invoice_line_num           NUMBER;
    G_p_period_name                VARCHAR2(15);
    G_x_inv_gl_header_id           NUMBER;
    G_x_inv_gl_line_num            NUMBER;
    G_x_inv_gl_header_name         VARCHAR2(100);
    G_x_inv_gl_batch_name          VARCHAR2(100);

    G_batch_name                   VARCHAR2(80);
    G_code_combination_id          NUMBER;
    G_system_ref_3                 VARCHAR2(80);
    G_rev_period_name              VARCHAR2(15);
    G_x_rev_gl_header_id           NUMBER;
    G_x_rev_gl_line_num            NUMBER;
    G_x_rev_gl_header_name         VARCHAR2(100);
    G_x_rev_gl_batch_name          VARCHAR2(100);

PROCEDURE  Create_Ubr_Uer_Summary_Balance(
                     p_from_project_number IN VARCHAR2,
                     p_to_project_number   IN VARCHAR2,
                     p_gl_period_name      IN VARCHAR2 ,
                     p_request_id          IN NUMBER );

FUNCTION  Initialize( p_org_id  NUMBER ) RETURN BOOLEAN;

PROCEDURE  process_draft_revenues;

PROCEDURE process_ubr_uer_summary ( p_source IN VARCHAR2 , p_process_ubr_uer IN VARCHAR2 ) ;

PROCEDURE  process_draft_invoices;

FUNCTION  get_seg_val(  p_acct_appcol_name VARCHAR2,
                        p_cost_appcol_name VARCHAR2,
                        p_seg_type         VARCHAR2,
                        p_ccid             NUMBER )
RETURN VARCHAR2;

FUNCTION  get_gl_period_name( p_application_id NUMBER,
                              p_set_of_books_id NUMBER,
                              p_gl_date         DATE )
RETURN VARCHAR2;
FUNCTION  get_gl_period_name( p_org_id          NUMBER,
                              p_gl_date         DATE )
RETURN VARCHAR2;

FUNCTION  get_gl_start_date( p_application_id NUMBER,
                              p_set_of_books_id NUMBER,
                              p_gl_period_name  VARCHAR2 )
RETURN DATE;

PROCEDURE  get_gl_start_date( p_gl_period_name      IN  VARCHAR2 ,
                              p_gl_start_date       IN  DATE,
                              x_gl_start_date_chr   OUT NOCOPY VARCHAR2 );

FUNCTION  get_inv_gl_header_id_line_num(
                              p_calling_place           IN VARCHAR2,
                              p_ar_invoice_number       IN NUMBER,
                              p_invoice_line_number     IN NUMBER,
                              p_ubr_code_combination_id IN NUMBER,
                              p_period_name             IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION  get_rev_gl_header_id_line_num(
                              p_calling_place           IN VARCHAR2,
                              p_batch_name              IN VARCHAR2,
                              p_system_ref_3            IN VARCHAR2,
                              p_code_combination_id     IN NUMBER,
                              p_period_name             IN VARCHAR2 )
RETURN VARCHAR2;

END PA_UBR_UER_SUMM_PKG;

 

/
