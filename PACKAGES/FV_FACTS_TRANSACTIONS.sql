--------------------------------------------------------
--  DDL for Package FV_FACTS_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS_TRANSACTIONS" AUTHID CURRENT_USER AS
 /* $Header: FVFCPROS.pls 120.10.12010000.3 2010/03/31 12:21:34 yanasing ship $ */

PROCEDURE submit(errbuf OUT NOCOPY varchar2,
                 retcode out NOCOPY number,
                 p_ledger_id IN NUMBER);

Procedure MAIN
(
    errbuf              OUT NOCOPY  VARCHAR2,
    retcode             OUT NOCOPY  NUMBER,
    p_ledger_id         NUMBER,
    treasury_symbol   VARCHAR2,
    report_fiscal_yr  NUMBER  ,
    report_period_num NUMBER,
    run_mode          VARCHAR2,
    contact_fname     VARCHAR2,
    contact_lname     VARCHAR2,
    contact_phone     NUMBER  ,
    contact_extn      NUMBER  ,
    contact_email     VARCHAR2,
    contact_fax       NUMBER,
    contact_maiden    VARCHAR2,
    supervisor_name   VARCHAR2,
    supervisor_phone  NUMBER  ,
    supervisor_extn   NUMBER  ,
    agency_name_1     VARCHAR2,
    agency_name_2     VARCHAR2,
    address_1         VARCHAR2,
    address_2         VARCHAR2,
    city              VARCHAR2,
    state             VARCHAR2,
    zip               VARCHAR2,
    currency_code     VARCHAR2,
    p_facts_rep_show  IN VARCHAR2 DEFAULT 'Y'
);

PROCEDURE create_bulk_file(errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_ledger_id IN NUMBER);

v_g_edit_check_code     NUMBER(15); --sf133 to detect hard edit failure

END;

/
