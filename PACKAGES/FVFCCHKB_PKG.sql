--------------------------------------------------------
--  DDL for Package FVFCCHKB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FVFCCHKB_PKG" AUTHID CURRENT_USER AS
--$Header: FVFCCHKS.pls 115.8 2002/03/06 14:13:10 pkm ship   $

 procedure perform_edit_checks (errbuf out varchar2,
				retcode out number,
                                p_treasury_symbol_id IN number,
				p_facts_run_quarter  IN number,
				p_rep_fiscal_yr      IN NUMBER);

end FVFCCHKB_PKG;

 

/
