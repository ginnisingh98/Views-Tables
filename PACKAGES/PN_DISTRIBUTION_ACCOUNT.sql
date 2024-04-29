--------------------------------------------------------
--  DDL for Package PN_DISTRIBUTION_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_DISTRIBUTION_ACCOUNT" AUTHID CURRENT_USER as
  -- $Header: PNUPGACS.pls 115.2 2002/11/11 23:47:50 stripath ship $

  PROCEDURE create_accounts (
    errbuf                  out NOCOPY             varchar2   ,
    retcode                 out NOCOPY             varchar2   ,
    p_chart_of_accounts_id  in              number     ,
    p_lease_class           in              varchar2   ,
    p_lease_num_from        in              varchar2   ,
    p_lease_num_to          in              varchar2   ,
    p_locn_code_from        in              varchar2   ,
    p_locn_code_to          in              varchar2   ,
    p_rec_ccid              in              number     ,
    p_accr_asset_ccid       in              number     ,
    p_lia_ccid              in              number     ,
    p_accr_liab_ccid        in              number
  );


  PROCEDURE create_accnt_dist (
    p_payment_term_id       in              number   ,
    p_accnt_class           in              varchar2   ,
    p_accnt_ccid            in              number     ,
    p_percent               in              number     ,
    p_org_id                in              number     ,
    p_accnt_exists          out NOCOPY             varchar2
  );


END pn_distribution_account;

 

/
