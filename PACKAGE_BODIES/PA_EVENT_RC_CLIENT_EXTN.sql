--------------------------------------------------------
--  DDL for Package Body PA_EVENT_RC_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENT_RC_CLIENT_EXTN" AS
/* $Header: PAEVTRCB.pls 120.2 2005/08/19 16:22:41 mwasowic noship $ */


   PROCEDURE override_rsob_event_amount(
             p_calling_mode                      IN    VARCHAR2,
             p_event_rec_old                     IN    event_record,
             p_event_rec_new                     IN    event_record,
             p_primary_set_of_books_id           IN    NUMBER,
             p_primary_currency_code             IN    VARCHAR2,
             p_reporting_set_of_books_id         IN    NUMBER,
             p_reporting_currency_code           IN    VARCHAR2,
             p_event_currency_code               IN    VARCHAR2,
             p_rev_conversion_type               IN    VARCHAR2,
             p_rev_conversion_date               IN    DATE,
             p_rev_exchange_rate                 IN    NUMBER,
             p_bill_conversion_type              IN    VARCHAR2,
             p_bill_conversion_date              IN    DATE,
             p_bill_exchange_rate                IN    NUMBER,
             p_rc_reval_revenue_amount           IN    NUMBER,
             x_override_rev_amt_flag             OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_rev_amt_rate_type                 OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_rev_amt_rate_date                 OUT   NOCOPY DATE, --File.Sql.39 bug 4440895
             x_rev_amt_exchange_rate             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_rc_revenue_amount                 OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_override_bill_amt_flag            OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_bill_amt_rate_type                OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_bill_amt_rate_date                OUT   NOCOPY DATE, --File.Sql.39 bug 4440895
             x_bill_amt_exchange_rate            OUT   NOCOPY NUMBER,    --File.Sql.39 bug 4440895
             x_rc_bill_amount                    OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_event_description                 OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_error_message                     OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_status                            OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
            )
IS


BEGIN


        x_status := 0;


        /*

        -- Don't Write any COMMIT or ROLLBACK inside the Client Extension.

          -----------------------------------------------------
          -- Possible Status Code Values(x_status_code)
          ------------------------------------------------------
          -- x_status = 0  or  NULL - For Success
          -- x_status > 0 - For Application Error like Validation error
          --                In this case transaction will be marked as error
                            x_error_message will be populated with error text
          -- x_status< 0  - For Oracle Error
                            In this case the calling API will raise an exception
                            and will not proceed further.
          -- x_error_message will be populated with error text
          -- If x_status <> 0 then the transaction will be marked as error



        -----------------------------------------------------------------------------------------
        -- Override the Event Revenue amount
        -----------------------------------------------------------------------------------------
        -- Setting the x_override_rev_amt_flag.
        -- If you set flag is  'Y' then set the following revenue amount conversion attributes.
        -- x_rev_amt_rate_type, x_rev_amt_rate_date
        -- If the flag is 'N' then Ignore the revenue amount conversion attributes.

        -- If you set a x_rev_amt_rate_type = 'USER' then set the rate for x_rev_amt_exchange_rate

        -- If you override the revenue amount 'x_rc_revenue_amount' then Ignore the revenue amount
        -- conversion attributes



        -----------------------------------------------------------------------------------------
        -- Override the Event Bill amount
        -----------------------------------------------------------------------------------------
        -- Setting the x_override_rev_amt_flag.
        -- Set the x_override_bill_amt_flag.
        -- If you set flag is  'Y' then set the bill amount conversion attributes.
        -- If the flag is 'N' then Ignore the bill amount conversion attributes.

        -- If you set a x_bill_amt_rate_type = 'USER' then set the rate for x_rev_bill_exchange_rate

        -- If you override the bill amount 'x_rc_bill_amount' then Ignore the bill amount
        -- conversion attributes


        -----------------------------------------------------------------------------------------
        -- Override the Event description
        -----------------------------------------------------------------------------------------
        -- Set the x_event_description. If you pass not null event description then
        -- this value will be stamp into the pa_mc_events   */



   EXCEPTION
        WHEN OTHERS THEN
             x_override_rev_amt_flag   := NULL; --NOCOPY
             x_rev_amt_rate_type       := NULL; --NOCOPY
             x_rev_amt_rate_date       := NULL; --NOCOPY
             x_rev_amt_exchange_rate   := NULL; --NOCOPY
             x_rc_revenue_amount       := NULL; --NOCOPY
             x_override_bill_amt_flag  := NULL; --NOCOPY
             x_bill_amt_rate_type     := NULL; --NOCOPY
             x_bill_amt_rate_date     := NULL; --NOCOPY
             x_bill_amt_exchange_rate  := NULL; --NOCOPY
             x_rc_bill_amount          := NULL; --NOCOPY
             x_event_description       := NULL; --NOCOPY
        -- Add your exception handler here.
        -- To raise an application error, assign a positive number to x_status.
        -- To raise an ORACLE error, assign SQLCODE to x_status.
        null;


END override_rsob_event_amount;

END pa_event_rc_client_extn;

/
