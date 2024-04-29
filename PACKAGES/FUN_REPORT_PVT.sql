--------------------------------------------------------
--  DDL for Package FUN_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_REPORT_PVT" AUTHID CURRENT_USER AS
/*  $Header: FUNVRPTS.pls 120.2 2005/04/03 13:39:36 apbalakr noship $ */

TYPE summaryreport_para_rec_type IS RECORD(
    batch_type         FND_LOOKUPS.lookup_code%TYPE,
    initiator_id       FUN_TRX_BATCHES.initiator_id%TYPE,
    recipient_id       FUN_TRX_HEADERS.recipient_id%TYPE,
    batch_number_from  FUN_TRX_BATCHES.batch_number%TYPE,
    batch_number_to    FUN_TRX_BATCHES.batch_number%TYPE,
    gl_date_from       VARCHAR2(30),
    gl_date_to         VARCHAR2(30),
    batch_date_from    VARCHAR2(30),
    batch_date_to      VARCHAR2(30),
    batch_status       FUN_TRX_BATCHES.status%TYPE,
    transaction_status FUN_TRX_HEADERS.status%TYPE,
    trx_type_id        FUN_TRX_BATCHES.trx_type_id%TYPE,
    currency_code      FUN_TRX_BATCHES.currency_code%TYPE,
    invoice_flag       FUN_TRX_HEADERS.invoice_flag%TYPE,
    ar_invoice_number  FUN_TRX_HEADERS.ar_invoice_number%TYPE
);


TYPE accountreport_para_rec_type IS RECORD(
     initiator_from   HZ_PARTIES.PARTY_NAME%TYPE,
     initiator_to     HZ_PARTIES.PARTY_NAME%TYPE,
     transact_le      hz_parties.party_name%type,
     transact_ledger    gl_ledgers.ledger_id%type,
     recipient_from     hz_parties.party_name%type,
     recipient_to       hz_parties.party_name%type,
     trading_le         hz_parties.party_name%type,
     trading_ledger     gl_ledgers.ledger_id%type,
     gl_date_from       VARCHAR2(30),
     gl_date_to         VARCHAR2(30),
     batch_type         FND_LOOKUPS.lookup_code%TYPE,
     batch_number_from  FUN_TRX_BATCHES.batch_number%TYPE,
     batch_number_to    FUN_TRX_BATCHES.batch_number%TYPE,
     batch_status       FUN_TRX_BATCHES.status%TYPE,
     transaction_status FUN_TRX_HEADERS.status%TYPE,
     trx_type_id        FUN_TRX_BATCHES.trx_type_id%TYPE,
     currency_code      FUN_TRX_BATCHES.currency_code%TYPE,
     account_type       FND_LOOKUPS.lookup_code%TYPE,
     rec_account_from   varchar2(100),
     rec_account_to     varchar2(100),
     pay_account_from   varchar2(100),
     pay_account_to     varchar2(100),
     init_dist_acc_from varchar2(100),
     init_dist_acc_to   varchar2(100),
     rec_dist_acc_from  varchar2(100),
     rec_dist_acc_to    varchar2(100),
     coa_initiator      gl_ledgers.chart_of_accounts_id%TYPE,
     coa_recipient      gl_ledgers.chart_of_accounts_id%TYPE,
     ar_invoice_number  FUN_TRX_HEADERS.ar_invoice_number%TYPE
);


PROCEDURE build_summary_outquery(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_para_rec         IN FUN_REPORT_PVT.summaryreport_para_rec_type,
    x_outbound_query   OUT NOCOPY VARCHAR2
);

PROCEDURE build_summary_inquery(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_para_rec         IN FUN_REPORT_PVT.summaryreport_para_rec_type,
    x_inbound_query    OUT NOCOPY VARCHAR2
);

PROCEDURE build_account_outquery(
   x_return_status  OUT NOCOPY VARCHAR2,
   p_para_rec       IN  FUN_REPORT_PVT.accountreport_para_rec_type,
   x_outbound_query OUT NOCOPY VARCHAR2
);
PROCEDURE build_account_inquery(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_para_rec         IN FUN_REPORT_PVT.accountreport_para_rec_type,
    x_inbound_query    OUT NOCOPY VARCHAR2
);



PROCEDURE get_xml(
    x_return_status OUT NOCOPY VARCHAR2,
    p_query         IN VARCHAR2,
    p_rowset_tag    IN VARCHAR2 DEFAULT NULL,
    p_row_tag       IN VARCHAR2 DEFAULT NULL,
    x_xml           OUT NOCOPY CLOB
);

PROCEDURE construct_output(
    x_return_status OUT NOCOPY VARCHAR2,
    p_para_rec      IN FUN_REPORT_PVT.summaryreport_para_rec_type,
    p_outbound_trxs IN CLOB,
    p_inbound_trxs  IN CLOB
);
PROCEDURE construct_account_output(
   x_return_status  OUT NOCOPY VARCHAR2,
   p_para_rec       IN  FUN_REPORT_PVT.accountreport_para_rec_type,
   p_trxs   IN CLOB
);

PROCEDURE save_xml(
    x_return_status OUT NOCOPY VARCHAR2,
    p_trxs          IN CLOB,
    p_offset        IN INTEGER DEFAULT 1
);

PROCEDURE create_summaryreport(
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY NUMBER,
    p_batch_type         IN VARCHAR2,
    p_initiator_id       IN NUMBER DEFAULT NULL,
    p_recipient_id       IN NUMBER DEFAULT NULL,
    p_batch_number_from  IN VARCHAR2 DEFAULT NULL,
    p_batch_number_to    IN VARCHAR2 DEFAULT NULL,
    p_gl_date_from       IN VARCHAR2 DEFAULT NULL,
    p_gl_date_to         IN VARCHAR2 DEFAULT NULL,
    p_batch_date_from    IN VARCHAR2 DEFAULT NULL,
    p_batch_date_to      IN VARCHAR2 DEFAULT NULL,
    p_batch_status       IN VARCHAR2 DEFAULT NULL,
    p_transaction_status IN VARCHAR2 DEFAULT NULL,
    p_trx_type_id        IN NUMBER DEFAULT NULL,
    p_currency_code      IN VARCHAR2 DEFAULT NULL,
    p_invoice_flag       IN VARCHAR2 DEFAULT NULL,
    p_ar_invoice_number  IN VARCHAR2 DEFAULT NULL
);


PROCEDURE create_accountreport(
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY NUMBER,
    p_initiator_from     IN VARCHAR2 DEFAULT NULL,
    p_initiator_to       IN VARCHAR2 DEFAULT NULL,
    p_transact_le        IN VARCHAR2 DEFAULT NULL,
    p_transact_ledger_id          IN NUMBER   DEFAULT NULL,
    p_recipient_from     IN VARCHAR2 DEFAULT NULL,
    p_recipient_to       IN VARCHAR2 DEFAULT NULL,
    p_trading_le         IN VARCHAR2 DEFAULT NULL,
    p_trading_ledger_id  IN NUMBER   DEFAULT NULL,
    p_gl_date_from       IN VARCHAR2 DEFAULT NULL,
    p_gl_date_to         IN VARCHAR2 DEFAULT NULL,
    p_batch_type         IN VARCHAR2,
    p_batch_number_from  IN VARCHAR2 DEFAULT NULL,
    p_batch_number_to    IN VARCHAR2 DEFAULT NULL,
    p_batch_status       IN VARCHAR2 DEFAULT NULL,
    p_transaction_status IN VARCHAR2 DEFAULT NULL,
    p_trx_type_id        IN NUMBER DEFAULT NULL,
    p_currency_code      IN VARCHAR2 DEFAULT NULL,
    p_acc_type           IN VARCHAR2 DEFAULT NULL,
    p_coa_initiator      IN NUMBER DEFAULT NULL,
    p_coa_recipient      IN NUMBER DEFAULT NULL,
    p_rec_account_from   IN VARCHAR2 DEFAULT NULL,
    p_rec_account_to     IN VARCHAR2 DEFAULT NULL,
    p_pay_account_from   IN VARCHAR2 DEFAULT NULL,
    p_pay_account_to     IN VARCHAR2 DEFAULT NULL,
    p_init_d_account_from IN VARCHAR2 DEFAULT NULL,
    p_init_d_account_to  IN VARCHAR2 DEFAULT NULL,
    p_recip_d_account_from IN VARCHAR2 DEFAULT NULL,
    p_recip_d_account_to  IN VARCHAR2 DEFAULT NULL,
    p_ar_invoice_number  IN VARCHAR2 DEFAULT NULL
);




END FUN_REPORT_PVT;


 

/
