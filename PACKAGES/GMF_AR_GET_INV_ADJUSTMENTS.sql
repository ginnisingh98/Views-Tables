--------------------------------------------------------
--  DDL for Package GMF_AR_GET_INV_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_INV_ADJUSTMENTS" AUTHID CURRENT_USER as
/* $Header: gmfinvas.pls 115.2 2002/11/11 00:39:02 rseshadr ship $ */
    procedure AR_GET_INVOICE_ADJUSTMENTS (invoice_id         in out NOCOPY number,
                                          adj_id             in out NOCOPY number,
                                          start_date         in out NOCOPY date,
                                          end_date           in out NOCOPY date,
                                          adj_number         in out NOCOPY varchar2,
                                          amount             out    NOCOPY number,
                                          apply_date         out    NOCOPY date,
                                          gl_date            out    NOCOPY date,
                                          sob_id             out    NOCOPY number,
                                          coa_id             out    NOCOPY number,
                                          type               out    NOCOPY varchar2,
                                          adjustment_type    out    NOCOPY varchar2,
                                          status             out    NOCOPY varchar2,
                                          line_adjusted      out    NOCOPY number,
                                          frght_adjusted     out    NOCOPY number,
                                          tax_adjusted       out    NOCOPY number,
                                          currency           out    NOCOPY varchar2,
                                          revcharge_adj      out    NOCOPY number,
                                          receipt_id         out    NOCOPY number,
                                          chrgbck_cust_trxid out    NOCOPY number,
                                          batch_id           out    NOCOPY number,
                                          cust_trx_line_id   out    NOCOPY number,
                                          subseq_trx_id      out    NOCOPY number,
                                          paymnt_sched_id    out    NOCOPY number,
                                          receiv_trx_id      out    NOCOPY number,
                                          distrib_set_id     out    NOCOPY number,
                                          gl_posted_date     out    NOCOPY date,
                                          created_from       out    NOCOPY varchar2,
                                          reason_code        out    NOCOPY varchar2,
                                          approved_by        out    NOCOPY number,
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
                                          posting_controlid  out    NOCOPY number,
                                          acctd_amount       out    NOCOPY number,
                                          created_by         out    NOCOPY number,
                                          creation_date      out    NOCOPY date,
                                          last_update_date   out    NOCOPY date,
                                          last_updated_by    out    NOCOPY number,
                                          row_to_fetch       in out NOCOPY number,
                                          error_status       out    NOCOPY number);

END GMF_AR_GET_INV_ADJUSTMENTS;

 

/
