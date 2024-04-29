--------------------------------------------------------
--  DDL for Package FUN_RECON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RECON_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: funrecrpts.pls 120.5 2006/06/16 09:09:09 bsilveir noship $ */

PROCEDURE run_fun_report
       (p_errbuf                          OUT NOCOPY VARCHAR2
       ,p_retcode                         OUT NOCOPY NUMBER
       ,p_trans_ledger_id                 IN NUMBER
       ,p_trans_legal_entity_id           IN NUMBER
       ,p_trans_gl_period                 IN VARCHAR2
       ,p_tp_ledger_id                    IN NUMBER
       ,p_tp_legal_entity_id              IN NUMBER
       ,p_tp_gl_period                    IN VARCHAR2
       ,p_currency                        IN VARCHAR2
       ,p_rate_type                       IN VARCHAR2
       ,p_rate_date                       IN VARCHAR2);

Function match_ap_ar_invoice(p_trans_le_id        in       number,
                             p_trans_ledger_id    in       number,
                             p_trans_gl_period    in       varchar2,
                             p_trad_le_id         in       number,
                             p_trad_ledger_id     in       number,
                             p_trad_gl_period     in       varchar2,
                             p_account_type       in       varchar2, -- this will be 'R', or 'P'
                             p_entity_code        in       varchar2,
                             p_ap_ar_invoice_id   in       number) return varchar2;

Function get_balance(p_balance_type        varchar2,
                     p_column_name         varchar2,
                     p_trans_ledger_id     number,
                     p_trans_le_id         number,
                     p_trans_gl_period     varchar2,
                     p_trad_ledger_id      number,
                     p_trad_le_id          number,
                     p_trad_gl_period      varchar2,
                     p_currency            varchar2) return number;


--------------------------------------------------------------------------------
-- Function to Return Ledger Name from LE_ID
--------------------------------------------------------------------------------
FUNCTION get_legal_entity
      (p_le_id   IN NUMBER
      )RETURN VARCHAR2;

--------------------------------------------------------------------------------
-- Procedure to write CLOB contents to file
--------------------------------------------------------------------------------
PROCEDURE clob_to_file
        (p_xml_clob           IN CLOB);

END FUN_RECON_RPT_PKG;

 

/
