--------------------------------------------------------
--  DDL for Package GMF_AR_GET_CUST_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_CUST_PROFILE" AUTHID CURRENT_USER as
/* $Header: gmfcuprs.pls 115.2 2002/11/11 00:36:42 rseshadr ship $ */
    procedure AR_GET_CUST_PROFILE (cust_id            in out NOCOPY number,
                                   siteuseid          in out NOCOPY number,
                                   start_date         in out NOCOPY date,
                                   end_date           in out NOCOPY date,
                                   prof_status        in out NOCOPY varchar2,
                                   credit_check       out    NOCOPY varchar2,
                                   tolerance          out    NOCOPY number,
                                   discounts          out    NOCOPY varchar2,
                                   dunning_letters    out    NOCOPY varchar2,
                                   interest_charges   out    NOCOPY varchar2,
                                   statements         out    NOCOPY varchar2,
                                   credbal_stat       out    NOCOPY varchar2,
                                   credit_hold        out    NOCOPY varchar2,
                                   credit_rating      out    NOCOPY varchar2,
                                   risk_code          out    NOCOPY varchar2,
                                   payment_term_id    out    NOCOPY number,
                                   payment_term_cd    out    NOCOPY varchar2,
                                   override_terms     out    NOCOPY varchar2,
                                   interest_days      out    NOCOPY number,
                                   payment_days       out    NOCOPY number,
                                   discount_days      out    NOCOPY number,
                                   account_status     out    NOCOPY varchar2,
                                   percent_collect    out    NOCOPY number,
                                   incl_disputed      out    NOCOPY varchar2,
                                   tax_print_option   out    NOCOPY varchar2,
                                   finance_charge     out    NOCOPY varchar2,
                                   attr_category      out    NOCOPY varchar2,
                                   att1               out    NOCOPY varchar2,
                                   att2               out    NOCOPY varchar2,
                                   att3               out    NOCOPY varchar2,
                                   att4               out    NOCOPY varchar2,
                                   att5               out    NOCOPY varchar2,
                                   att6               out    NOCOPY varchar2,
                                   att7               out    NOCOPY varchar2,
                                   att8               out    NOCOPY varchar2,
                                   att9               out    NOCOPY varchar2,
                                   att10              out    NOCOPY varchar2,
                                   att11              out    NOCOPY varchar2,
                                   att12              out    NOCOPY varchar2,
                                   att13              out    NOCOPY varchar2,
                                   att14              out    NOCOPY varchar2,
                                   att15              out    NOCOPY varchar2,
                                   created_by         out    NOCOPY number,
                                   creation_date      out    NOCOPY date,
                                   last_update_date   out    NOCOPY date,
                                   last_updated_by    out    NOCOPY number,
                                   row_to_fetch       in out NOCOPY number,
                                   error_status       out    NOCOPY number);
END GMF_AR_GET_CUST_PROFILE;

 

/
