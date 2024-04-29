--------------------------------------------------------
--  DDL for Package FV_PURGED_TREASURY_SYMBOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_PURGED_TREASURY_SYMBOLS" AUTHID CURRENT_USER as
/* $Header: FVXPRTSS.pls 120.1 2006/06/26 11:37:40 svaithil noship $ */
procedure MAIN(errbuf     OUT NOCOPY VARCHAR2,
	       retcode    OUT NOCOPY VARCHAR2,
	       x_run_mode IN  VARCHAR2,
	       v_treasury_symbol IN VARCHAR2 DEFAULT NULL,
               v_time_frame IN VARCHAR2 DEFAULT NULL ,
	       n_year_established IN NUMBER DEFAULT NULL  ,
	       p_sob   Gl_Ledgers_public_v.ledger_id%TYPE DEFAULT NULL,
	       d_cancellation_date IN VARCHAR2 DEFAULT NULL ,
	       new_established_year IN NUMBER,
	       p_dummy IN NUMBER,
	       prelim_req_id IN NUMBER DEFAULT NULL);
end FV_PURGED_TREASURY_SYMBOLS;

 

/
