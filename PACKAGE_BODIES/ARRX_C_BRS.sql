--------------------------------------------------------
--  DDL for Package Body ARRX_C_BRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_BRS" AS
/* $Header: ARRXCBRB.pls 120.2 2003/10/23 23:12:51 orashid ship $ */

PROCEDURE run_report(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2, -- Reporting Level
  argument2         IN  VARCHAR2, -- Reporting Context
  argument3         IN  VARCHAR2, -- Status As of Date
  argument4         IN  VARCHAR2, -- First Status
  argument5         IN  VARCHAR2, -- Second Status
  argument6         IN  VARCHAR2, -- Third Status
  argument7         IN  VARCHAR2, -- Excluded Status
  argument8         IN  VARCHAR2, -- Transaction Type
  argument9         IN  VARCHAR2, -- Maturity Date From
  argument10        IN  VARCHAR2, -- Maturity Date To
  argument11        IN  VARCHAR2, -- Drawee Name
  argument12        IN  VARCHAR2, -- Drawee Number From
  argument13        IN  VARCHAR2, -- Drawee Number To
  argument14        IN  VARCHAR2, -- Remittance Batch Name
  argument15        IN  VARCHAR2, -- Remittance Bank Account
  argument16        IN  VARCHAR2, -- Drawee Bank Name
  argument17        IN  VARCHAR2, -- Original Amount From
  argument18        IN  VARCHAR2, -- Original Amount To
  argument19        IN  VARCHAR2, -- Transaction Issue Date From
  argument20        IN  VARCHAR2, -- Transaction Issue Date To
  argument21        IN  VARCHAR2, -- On Hold
  argument22        IN  VARCHAR2  DEFAULT  NULL,
  argument23        IN  VARCHAR2  DEFAULT  NULL,
  argument24        IN  VARCHAR2  DEFAULT  NULL,
  argument25        IN  VARCHAR2  DEFAULT  NULL,
  argument26        IN  VARCHAR2  DEFAULT  NULL,
  argument27        IN  VARCHAR2  DEFAULT  NULL,
  argument28        IN  VARCHAR2  DEFAULT  NULL,
  argument29        IN  VARCHAR2  DEFAULT  NULL,
  argument30        IN  VARCHAR2  DEFAULT  NULL,
  argument31        IN  VARCHAR2  DEFAULT  NULL,
  argument32        IN  VARCHAR2  DEFAULT  NULL,
  argument33        IN  VARCHAR2  DEFAULT  NULL,
  argument34        IN  VARCHAR2  DEFAULT  NULL,
  argument35        IN  VARCHAR2  DEFAULT  NULL,
  argument36        IN  VARCHAR2  DEFAULT  NULL,
  argument37        IN  VARCHAR2  DEFAULT  NULL,
  argument38        IN  VARCHAR2  DEFAULT  NULL,
  argument39        IN  VARCHAR2  DEFAULT  NULL,
  argument40        IN  VARCHAR2  DEFAULT  NULL,
  argument41        IN  VARCHAR2  DEFAULT  NULL,
  argument42        IN  VARCHAR2  DEFAULT  NULL,
  argument43        IN  VARCHAR2  DEFAULT  NULL,
  argument44        IN  VARCHAR2  DEFAULT  NULL,
  argument45        IN  VARCHAR2  DEFAULT  NULL,
  argument46        IN  VARCHAR2  DEFAULT  NULL,
  argument47        IN  VARCHAR2  DEFAULT  NULL,
  argument48        IN  VARCHAR2  DEFAULT  NULL,
  argument49        IN  VARCHAR2  DEFAULT  NULL,
  argument50        IN  VARCHAR2  DEFAULT  NULL,
  argument51        IN  VARCHAR2  DEFAULT  NULL,
  argument52        IN  VARCHAR2  DEFAULT  NULL,
  argument53        IN  VARCHAR2  DEFAULT  NULL,
  argument54        IN  VARCHAR2  DEFAULT  NULL,
  argument55        IN  VARCHAR2  DEFAULT  NULL,
  argument56        IN  VARCHAR2  DEFAULT  NULL,
  argument57        IN  VARCHAR2  DEFAULT  NULL,
  argument58        IN  VARCHAR2  DEFAULT  NULL,
  argument59        IN  VARCHAR2  DEFAULT  NULL,
  argument60        IN  VARCHAR2  DEFAULT  NULL,
  argument61        IN  VARCHAR2  DEFAULT  NULL,
  argument62        IN  VARCHAR2  DEFAULT  NULL,
  argument63        IN  VARCHAR2  DEFAULT  NULL,
  argument64        IN  VARCHAR2  DEFAULT  NULL,
  argument65        IN  VARCHAR2  DEFAULT  NULL,
  argument66        IN  VARCHAR2  DEFAULT  NULL,
  argument67        IN  VARCHAR2  DEFAULT  NULL,
  argument68        IN  VARCHAR2  DEFAULT  NULL,
  argument69        IN  VARCHAR2  DEFAULT  NULL,
  argument70        IN  VARCHAR2  DEFAULT  NULL,
  argument71        IN  VARCHAR2  DEFAULT  NULL,
  argument72        IN  VARCHAR2  DEFAULT  NULL,
  argument73        IN  VARCHAR2  DEFAULT  NULL,
  argument74        IN  VARCHAR2  DEFAULT  NULL,
  argument75        IN  VARCHAR2  DEFAULT  NULL,
  argument76        IN  VARCHAR2  DEFAULT  NULL,
  argument77        IN  VARCHAR2  DEFAULT  NULL,
  argument78        IN  VARCHAR2  DEFAULT  NULL,
  argument79        IN  VARCHAR2  DEFAULT  NULL,
  argument80        IN  VARCHAR2  DEFAULT  NULL,
  argument81        IN  VARCHAR2  DEFAULT  NULL,
  argument82        IN  VARCHAR2  DEFAULT  NULL,
  argument83        IN  VARCHAR2  DEFAULT  NULL,
  argument84        IN  VARCHAR2  DEFAULT  NULL,
  argument85        IN  VARCHAR2  DEFAULT  NULL,
  argument86        IN  VARCHAR2  DEFAULT  NULL,
  argument87        IN  VARCHAR2  DEFAULT  NULL,
  argument88        IN  VARCHAR2  DEFAULT  NULL,
  argument89        IN  VARCHAR2  DEFAULT  NULL,
  argument90        IN  VARCHAR2  DEFAULT  NULL,
  argument91        IN  VARCHAR2  DEFAULT  NULL,
  argument92        IN  VARCHAR2  DEFAULT  NULL,
  argument93        IN  VARCHAR2  DEFAULT  NULL,
  argument94        IN  VARCHAR2  DEFAULT  NULL,
  argument95        IN  VARCHAR2  DEFAULT  NULL,
  argument96        IN  VARCHAR2  DEFAULT  NULL,
  argument97        IN  VARCHAR2  DEFAULT  NULL,
  argument98        IN  VARCHAR2  DEFAULT  NULL,
  argument99        IN  VARCHAR2  DEFAULT  NULL,
  argument100       IN  VARCHAR2  DEFAULT  NULL)

IS

  l_request_id                  NUMBER;
  l_user_id                     NUMBER;
  l_reporting_level             FND_LOOKUPS.lookup_code%TYPE;
  l_reporting_context           GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
  l_status_as_of_date           AR_TRANSACTION_HISTORY.trx_date%TYPE;
  l_first_status                AR_LOOKUPS.lookup_code%TYPE;
  l_second_status               AR_LOOKUPS.lookup_code%TYPE;
  l_third_status                AR_LOOKUPS.lookup_code%TYPE;
  l_excluded_status             AR_LOOKUPS.lookup_code%TYPE;
  l_transaction_type            RA_CUST_TRX_TYPES.name%TYPE;
  l_maturity_date_from          RA_CUSTOMER_TRX.term_due_date%TYPE;
  l_maturity_date_to            RA_CUSTOMER_TRX.term_due_date%TYPE;
  l_drawee_name                 HZ_PARTIES.party_name%TYPE;
  l_drawee_number_from          HZ_CUST_ACCOUNTS.account_number%TYPE;
  l_drawee_number_to            HZ_CUST_ACCOUNTS.account_number%TYPE;
  l_remittance_batch_name       AR_BATCHES.name%TYPE;
  l_remittance_bank_account     ce_bank_accounts.bank_account_name%TYPE;
  l_drawee_bank_name            ce_bank_branches_v.bank_name%TYPE;
  l_original_amount_from        AR_PAYMENT_SCHEDULES.amount_due_original%TYPE;
  l_original_amount_to          AR_PAYMENT_SCHEDULES.amount_due_original%TYPE;
  l_transaction_issue_date_from RA_CUSTOMER_TRX.trx_date%TYPE;
  l_transaction_issue_date_to   RA_CUSTOMER_TRX.trx_date%TYPE;
  l_on_hold                     RA_CUSTOMER_TRX.br_on_hold_flag%TYPE;

  BEGIN

    -- Populate mandatory parameters for request_id and user_id
    l_request_id := fnd_global.conc_request_id;
    fnd_profile.get('USER_ID', l_user_id);

    -- Assign parameters to local variables doing any necessary mappings
    -- e.g. Date/Number conversions
    l_reporting_level             := argument1;
    l_reporting_context           := to_number(argument2);
    l_status_as_of_date           := to_date(argument3, 'YYYY/MM/DD HH24:MI:SS');
    l_first_status                := argument4;
    l_second_status               := argument5;
    l_third_status                := argument6;
    l_excluded_status             := argument7;
    l_transaction_type            := argument8;
    l_maturity_date_from          := to_date(argument9, 'YYYY/MM/DD HH24:MI:SS');
    l_maturity_date_to            := to_date(argument10, 'YYYY/MM/DD HH24:MI:SS');
    l_drawee_name                 := argument11;
    l_drawee_number_from          := argument12;
    l_drawee_number_to            := argument13;
    l_remittance_batch_name       := argument14;
    l_remittance_bank_account     := argument15;
    l_drawee_bank_name            := argument16;
    l_original_amount_from        := to_number(argument17);
    l_original_amount_to          := to_number(argument18);
    l_transaction_issue_date_from := to_date(argument19, 'YYYY/MM/DD HH24:MI:SS');
    l_transaction_issue_date_to   := to_date(argument20, 'YYYY/MM/DD HH24:MI:SS');
    l_on_hold                     := argument21;




    -- Call the inner report passing mandatory parameters and report specific parameters
    arrx_brs.arrxbrs_report(l_request_id
                           ,l_user_id
                           ,l_reporting_level
                           ,l_reporting_context
                           ,l_status_as_of_date
                           ,l_first_status
                           ,l_second_status
                           ,l_third_status
                           ,l_excluded_status
                           ,l_transaction_type
                           ,l_maturity_date_from
                           ,l_maturity_date_to
                           ,l_drawee_name
                           ,l_drawee_number_from
                           ,l_drawee_number_to
                           ,l_remittance_batch_name
                           ,l_remittance_bank_account
                           ,l_drawee_bank_name
                           ,l_original_amount_from
                           ,l_original_amount_to
                           ,l_transaction_issue_date_from
                           ,l_transaction_issue_date_to
                           ,l_on_hold
                           ,retcode
                           ,errbuf);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,sqlcode);
      fnd_file.put_line(fnd_file.log,sqlerrm);
      retcode := 2;
    RAISE;

  END run_report;

END arrx_c_brs;

/
