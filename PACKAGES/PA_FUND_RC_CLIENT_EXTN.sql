--------------------------------------------------------
--  DDL for Package PA_FUND_RC_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUND_RC_CLIENT_EXTN" AUTHID CURRENT_USER as
/* $Header: PAFUNDCS.pls 120.1 2005/08/05 00:08:19 rgandhi noship $ */

  PROCEDURE Override_Rob_Conv_attributes(
                              p_calling_mode               IN     VARCHAR2  ,
                              p_funding_line_rec_old       IN     PA_MC_FUNDINGS_PKG.FundingLineRecord,
                              p_funding_line_rec_new       IN     PA_MC_FUNDINGS_PKG.FundingLineRecord,
                              p_primary_set_of_books_id    IN     NUMBER ,
                              p_primary_currency_code      IN     VARCHAR2 ,
                              p_reporting_set_of_books_id  IN     NUMBER ,
                              p_reporting_currency_code    IN     VARCHAR2 ,
                              p_funding_currency_code      IN     VARCHAR2 ,
                              p_conversion_type            IN     VARCHAR2 ,
                              p_conversion_date            IN     DATE ,
                              p_exchange_rate              IN     NUMBER,
                              p_project_id                 IN     NUMBER,
                              p_agreement_id               IN     NUMBER,
                              p_task_id                    IN     NUMBER,
                              p_project_funding_id         IN     NUMBER,     /* Added for Funding Reval */
                              p_rc_realized_gains_amt      IN     NUMBER,     /* Added for Funding Reval */
                              p_rc_realized_losses_amt     IN     NUMBER,     /* Added for Funding Reval */
                              p_rc_inv_applied_amount      IN     NUMBER,     /* Added for Funding Reval */
                              p_rc_inv_due_amount          IN     NUMBER,     /* Added for Funding Reval */
                              p_rc_backlog_amount          IN     NUMBER,     /* Added for Funding Reval */
                              p_rc_reval_amount            IN     NUMBER,     /* Added for Funding Reval */
                              p_rc_revalued_amount         IN     NUMBER,     /* Added for Funding Reval */
                              x_rate_type                  OUT    NOCOPY VARCHAR2,/*File.sql.39*/
                              x_rate_date                  OUT    NOCOPY DATE, /*File.sql.39*/
                              x_exchange_rate              OUT    NOCOPY NUMBER, /*File.sql.39*/
                              x_rc_funding_amount          OUT    NOCOPY NUMBER, /*File.sql.39*/
                          /*  x_accpt_calc_reval_amt_flag  OUT VARCHAR2,       Added for Funding Reval,
                                commented for bug 2562551 */
                              x_error_message              OUT    NOCOPY VARCHAR2, /*File.sql.39*/
                              x_status                     OUT    NOCOPY NUMBER  /*File.sql.39*/
                              );

END PA_FUND_RC_CLIENT_EXTN;

 

/
