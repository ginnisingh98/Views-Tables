--------------------------------------------------------
--  DDL for Package ARRX_BRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_BRS" AUTHID CURRENT_USER AS
/* $Header: ARRXBRS.pls 115.2 2002/11/15 03:09:04 anukumar ship $ */

  PROCEDURE arrxbrs_report(p_request_id                  IN NUMBER
                          ,p_user_id                     IN NUMBER
                          ,p_reporting_level             IN VARCHAR2
                          ,p_reporting_entity_id         IN NUMBER
                          ,p_status_as_of_date           IN DATE
                          ,p_first_status                IN VARCHAR2
                          ,p_second_status               IN VARCHAR2
                          ,p_third_status                IN VARCHAR2
                          ,p_excluded_status             IN VARCHAR2
                          ,p_transaction_type            IN VARCHAR2
                          ,p_maturity_date_from          IN DATE
                          ,p_maturity_date_to            IN DATE
                          ,p_drawee_name                 IN VARCHAR2
                          ,p_drawee_number_from          IN VARCHAR2
                          ,p_drawee_number_to            IN VARCHAR2
                          ,p_remittance_batch_name       IN VARCHAR2
                          ,p_remittance_bank_account     IN VARCHAR2
                          ,p_drawee_bank_name            IN VARCHAR2
                          ,p_original_amount_from        IN NUMBER
                          ,p_original_amount_to          IN NUMBER
                          ,p_transaction_issue_date_from IN DATE
                          ,p_transaction_issue_date_to   IN DATE
                          ,p_on_hold                     IN VARCHAR2
                          ,retcode                       OUT NOCOPY NUMBER
                          ,errbuf                        OUT NOCOPY VARCHAR2);


END arrx_brs;

 

/
