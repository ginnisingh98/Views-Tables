--------------------------------------------------------
--  DDL for Package FV_FACTS_EDIT_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS_EDIT_CHECK" AUTHID CURRENT_USER AS
--$Header: FVFCCHKS.pls 120.4.12010000.2 2009/06/01 15:17:37 amaddula ship $

 procedure perform_edit_checks (errbuf OUT NOCOPY varchar2,
				retcode OUT NOCOPY number,
        p_treasury_symbol_id IN number,
				p_facts_run_quarter  IN number,
				p_rep_fiscal_yr      IN NUMBER,
        p_period_num         IN NUMBER,
        p_ledger_id          IN NUMBER);

end fv_facts_edit_check;

/
