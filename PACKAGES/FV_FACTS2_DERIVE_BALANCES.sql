--------------------------------------------------------
--  DDL for Package FV_FACTS2_DERIVE_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS2_DERIVE_BALANCES" AUTHID CURRENT_USER AS
/* $Header: FVFCT2BS.pls 120.0.12000000.2 2007/02/23 12:17:29 bnarang noship $*/
  PROCEDURE derive_balances
  (
    p_errbuff         OUT NOCOPY  VARCHAR2,
    p_retcode         OUT NOCOPY  NUMBER,
    p_ledger_id       IN NUMBER,
    p_fiscal_year     IN NUMBER
  );

END fv_facts2_derive_balances;

 

/
