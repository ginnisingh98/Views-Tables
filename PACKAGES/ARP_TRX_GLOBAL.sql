--------------------------------------------------------
--  DDL for Package ARP_TRX_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: ARTUGBLS.pls 120.3 2006/05/31 18:12:31 mraymond noship $ */

-- This record holds general information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
TYPE system_info_rec_type IS RECORD
(
    system_parameters     arp_global.sysparam%type,
    chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%type,
    period_set_name       gl_sets_of_books.period_set_name%type,
    base_currency         fnd_currencies.currency_code%type,
    base_precision        fnd_currencies.precision%type,
    base_min_acc_unit     fnd_currencies.minimum_accountable_unit%type,
    rev_based_on_salesrep               BOOLEAN,
    tax_based_on_salesrep               BOOLEAN,
    unbill_based_on_salesrep            BOOLEAN,
    unearn_based_on_salesrep            BOOLEAN,
    suspense_based_on_salesrep          BOOLEAN,
    msg_level				BINARY_INTEGER
);

system_info system_info_rec_type;

--
-- This record holds profile information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
TYPE profile_rec_type IS RECORD
(
    application_id              BINARY_INTEGER,
    conc_login_id               BINARY_INTEGER,
    conc_program_id             BINARY_INTEGER,
    user_id                     BINARY_INTEGER,
    request_id			BINARY_INTEGER,
    use_inv_acct_for_cm_flag    VARCHAR2(240),
    so_organization_id          VARCHAR2(240)
);

profile_info profile_rec_type;

--
-- This record holds accounting flexfield information used by
-- autoaccounting and the credit memo module.  Passed as argument to
-- most functions/procs.
--
TYPE acct_flex_info_rec_type IS RECORD
(
    number_segments     BINARY_INTEGER,
    delim               VARCHAR2(1)
);

flex_info acct_flex_info_rec_type;
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
Procedure init;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
--end anuj

END arp_trx_global;

 

/
