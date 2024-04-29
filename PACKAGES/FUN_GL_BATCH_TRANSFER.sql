--------------------------------------------------------
--  DDL for Package FUN_GL_BATCH_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_GL_BATCH_TRANSFER" AUTHID CURRENT_USER AS
/* $Header: FUNGLTRS.pls 120.4.12010000.3 2008/11/02 18:20:26 ychandra ship $ */

FUNCTION has_valid_conversion_rate (
    p_from_currency IN varchar2,
    p_to_currency   IN varchar2,
    p_exchange_type IN varchar2,
    p_exchange_date IN date) RETURN NUMBER;

FUNCTION get_conversion_type(
    p_conversion_type IN varchar2) RETURN varchar2;

PROCEDURE gl_batch_transfer (
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY NUMBER,
    p_date_low                IN varchar2 DEFAULT NULL,
    p_date_high               IN varchar2 DEFAULT NULL,
    p_ledger_low              IN varchar2 DEFAULT NULL,
    p_ledger_high             IN varchar2 DEFAULT NULL,
    p_le_low                  IN varchar2 DEFAULT NULL,
    p_le_high                 IN varchar2 DEFAULT NULL,
    p_ic_org_low              IN varchar2 DEFAULT NULL,
    p_ic_org_high             IN varchar2 DEFAULT NULL,
    p_run_journal_import      IN varchar2 DEFAULT 'N',
    p_create_summary_journals IN varchar2 DEFAULT 'N'

    );

END;


/
