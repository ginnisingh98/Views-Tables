--------------------------------------------------------
--  DDL for Package GMF_AR_GET_CUST_BANK_ACCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_CUST_BANK_ACCOUNTS" AUTHID CURRENT_USER as
/* $Header: gmfbanks.pls 115.0 99/07/16 04:14:50 porting shi $ */
    procedure AR_GET_CUST_BANK_ACCOUNTS (cust_id            in out number,
                                         siteuseid          in out number,
                                         start_date         in out date,
                                         end_date           in out date,
                                         primary_flag       out    varchar2,
                                         start_date_active  out    date,
                                         end_date_active    out    date,
                                         account_number     out    varchar2,
                                         account_name       out    varchar2,
                                         currency_code      out    varchar2,
                                         description        out    varchar2,
                                         max_check_amount   out    number,
                                         min_check_amount   out    number,
                                         inactive_date      out    date,
                                         asset_ccid         out    number,
                                         gain_ccid          out    number,
                                         loss_ccid          out    number,
                                         bank_account_type  out    varchar2,
                                         max_outlay         out    varchar2,
                                         multi_curr_flag    out    varchar2,
                                         account_type       out    varchar2,
                                         pooled_flag        out    varchar2,
                                         zero_amt_allowed   out    varchar2,
                                         attr_category      out    varchar2,
                                         att1               out    varchar2,
                                         att2               out    varchar2,
                                         att3               out    varchar2,
                                         att4               out    varchar2,
                                         att5               out    varchar2,
                                         att6               out    varchar2,
                                         att7               out    varchar2,
                                         att8               out    varchar2,
                                         att9               out    varchar2,
                                         att10              out    varchar2,
                                         att11              out    varchar2,
                                         att12              out    varchar2,
                                         att13              out    varchar2,
                                         att14              out    varchar2,
                                         att15              out    varchar2,
                                         created_by         out    varchar2,
                                         creation_date      out    date,
                                         last_update_date   out    date,
                                         last_updated_by    out    varchar2,
                                         row_to_fetch       in out number,
                                         error_status       out    number);

END GMF_AR_GET_CUST_BANK_ACCOUNTS;

 

/
