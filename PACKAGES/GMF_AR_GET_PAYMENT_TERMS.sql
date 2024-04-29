--------------------------------------------------------
--  DDL for Package GMF_AR_GET_PAYMENT_TERMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_PAYMENT_TERMS" AUTHID CURRENT_USER as
/* $Header: gmfpayts.pls 115.0 99/07/16 04:22:03 porting shi $ */
    procedure AR_GET_PAYMENT_TERMS (term_name          in out varchar2,
                                    termid             in out number,
                                    start_date         in out date,
                                    end_date           in out date,
                                    credit_check       out    varchar2,
                                    cutoff_day         out    varchar2,
                                    print_lead_days    out    varchar2,
                                    description        out    varchar2,
                                    base_amount        out    varchar2,
                                    calc_discount      out    varchar2,
                                    installment_cd     out    varchar2,
                                    in_use             out    varchar2,
                                    partial_discount   out    varchar2,
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
                                    created_by         out    number,
                                    creation_date      out    date,
                                    last_update_date   out    date,
                                    last_updated_by    out    number,
                                    row_to_fetch       in out number,
                                    error_status       out    number);

END GMF_AR_GET_PAYMENT_TERMS;

 

/
