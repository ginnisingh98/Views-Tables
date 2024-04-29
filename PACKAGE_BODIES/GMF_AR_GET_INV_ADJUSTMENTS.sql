--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_INV_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_INV_ADJUSTMENTS" as
/* $Header: gmfinvab.pls 115.4 2002/11/11 00:38:53 rseshadr ship $ */
          cursor cur_ar_get_invoice_adjustments(start_date  date,
                                                end_date    date,
                                                invoice_id  number,
                                                adj_id      number,
                                                adj_number  varchar2) is
             select ADJ.CUSTOMER_TRX_ID,         ADJ.ADJUSTMENT_NUMBER,
                    ADJ.AMOUNT,                  ADJ.APPLY_DATE,
                    ADJ.GL_DATE,                 ADJ.SET_OF_BOOKS_ID,
                    ADJ.CODE_COMBINATION_ID,     ADJ.TYPE,
                    ADJ.ADJUSTMENT_TYPE,         ADJ.STATUS,
                    ADJ.LINE_ADJUSTED,           ADJ.FREIGHT_ADJUSTED,
                    ADJ.TAX_ADJUSTED,            TRX.INVOICE_CURRENCY_CODE,
                    ADJ.RECEIVABLES_CHARGES_ADJUSTED,
                    ADJ.ASSOCIATED_CASH_RECEIPT_ID,
                    ADJ.CHARGEBACK_CUSTOMER_TRX_ID,
                    ADJ.BATCH_ID,                ADJ.CUSTOMER_TRX_LINE_ID,
                    ADJ.SUBSEQUENT_TRX_ID,       ADJ.PAYMENT_SCHEDULE_ID,
                    ADJ.RECEIVABLES_TRX_ID,      ADJ.DISTRIBUTION_SET_ID,
                    ADJ.GL_POSTED_DATE,          ADJ.CREATED_FROM,
                    ADJ.REASON_CODE,             ADJ.APPROVED_BY,
                    ADJ.ATTRIBUTE_CATEGORY,      ADJ.ATTRIBUTE1,
                    ADJ.ATTRIBUTE2,              ADJ.ATTRIBUTE3,
                    ADJ.ATTRIBUTE4,              ADJ.ATTRIBUTE5,
                    ADJ.ATTRIBUTE6,              ADJ.ATTRIBUTE7,
                    ADJ.ATTRIBUTE8,              ADJ.ATTRIBUTE9,
                    ADJ.ATTRIBUTE10,             ADJ.ATTRIBUTE11,
                    ADJ.ATTRIBUTE12,             ADJ.ATTRIBUTE13,
                    ADJ.ATTRIBUTE14,             ADJ.ATTRIBUTE15,
                    ADJ.POSTING_CONTROL_ID,      ADJ.ACCTD_AMOUNT,
                    ADJ.CREATED_BY,              ADJ.CREATION_DATE,
                    ADJ.LAST_UPDATE_DATE,        ADJ.LAST_UPDATED_BY
             from   RA_CUSTOMER_TRX_ALL TRX,
                    AR_ADJUSTMENTS_ALL ADJ
             where  ADJ.customer_trx_id = invoice_id
               and  ADJ.adjustment_id = nvl(adj_id, ADJ.adjustment_id)
               and  TRX.customer_trx_id = ADJ.customer_trx_id
               and  ADJ.last_update_date between
                                         nvl(start_date, ADJ.last_update_date)
                                     and nvl(end_date, ADJ.last_update_date);

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
                                          error_status       out    NOCOPY number) is

    begin

         if NOT cur_ar_get_invoice_adjustments%ISOPEN then
            open cur_ar_get_invoice_adjustments(start_date, end_date,
                                                invoice_id, adj_id,
                                                adj_number);
         end if;

         fetch cur_ar_get_invoice_adjustments
         into  invoice_id,          adj_number,          amount,
               apply_date,          gl_date,             sob_id,
               coa_id,              type,                adjustment_type,
               status,              line_adjusted,       frght_adjusted,
               tax_adjusted,        currency,            revcharge_adj,
               receipt_id,          chrgbck_cust_trxid,  batch_id,
               cust_trx_line_id,    subseq_trx_id,       paymnt_sched_id,
               receiv_trx_id,       distrib_set_id,      gl_posted_date,
               created_from,        reason_code,         approved_by,
               attr_category,       att1,                att2,
               att3,                att4,                att5,
               att6,                att7,                att8,
               att9,                att10,               att11,
               att12,               att13,               att14,
               att15,               posting_controlid,   acctd_amount,
               created_by,          creation_date,       last_update_date,
               last_updated_by;

        if cur_ar_get_invoice_adjustments%NOTFOUND then
           error_status := 100;
           close cur_ar_get_invoice_adjustments;
        end if;
        if row_to_fetch = 1 and cur_ar_get_invoice_adjustments%ISOPEN then
           close cur_ar_get_invoice_adjustments;
        end if;

      exception

          when others then
               error_status := SQLCODE;

  end AR_GET_INVOICE_ADJUSTMENTS;
END GMF_AR_GET_INV_ADJUSTMENTS;

/
