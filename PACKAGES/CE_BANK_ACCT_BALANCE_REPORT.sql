--------------------------------------------------------
--  DDL for Package CE_BANK_ACCT_BALANCE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANK_ACCT_BALANCE_REPORT" AUTHID CURRENT_USER AS
/*  $Header: cexmlbrs.pls 120.2 2005/10/27 23:03:38 shawang noship $	*/

procedure single_day_balance_report
  (errbuf OUT NOCOPY      VARCHAR2,
   retcode OUT NOCOPY     NUMBER,
   p_branch_party_id      varchar2,
   p_bank_acct_id        varchar2,
   p_bank_acct_currency   VARCHAR2,
   p_legal_entity_id         number,
   p_as_of_date           varchar2,
   p_reporting_currency   varchar2,
   p_exchange_rate_type   varchar2,
   p_exchange_rate_date   varchar2
  );

procedure range_day_balance_report
  (errbuf OUT NOCOPY      VARCHAR2,
   retcode OUT NOCOPY     NUMBER,
   p_branch_party_id      varchar2,
   p_bank_acct_id         varchar2,
   p_bank_acct_currency   VARCHAR2,
   p_legal_entity_id      varchar2,
   p_from_date            varchar2,
   p_to_date              varchar2,
   p_reporting_currency   varchar2,
   p_exchange_rate_type   varchar2,
   p_exchange_rate_date   varchar2
  );

procedure act_proj_balance_report
  (errbuf OUT NOCOPY      VARCHAR2,
   retcode OUT NOCOPY     NUMBER,
   p_branch_party_id      varchar2,
   p_bank_acct_id         varchar2,
   p_bank_acct_currency   VARCHAR2,
   p_legal_entity_id      varchar2,
   p_from_date            varchar2,
   p_to_date              varchar2,
   p_actual_balance_type  varchar2
  );

END CE_BANK_ACCT_BALANCE_REPORT;

 

/
