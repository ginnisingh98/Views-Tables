--------------------------------------------------------
--  DDL for Package Body OKL_INT_EXT_CSH_APP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INT_EXT_CSH_APP_PVT" AS
   /* $Header: OKLRIECB.pls 120.22.12010000.2 2008/09/02 09:38:23 nikshah ship $ */

   -- Start of comments
   --
   -- Function Name   : populate_error_messages
   -- Description    : populates error messages into OKL_VALIDATION_RESULTS_B and
   --                  OKL_VALIDATION_RESULTS_TL tables.
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : AKRANGAN created.
   --
   -- End of comments
   PROCEDURE populate_error_messages (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      p_error_tbl       IN              okl_vlr_pvt.vlrv_tbl_type,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   ) IS
      --local variables declaration
      l_api_name      CONSTANT VARCHAR2 (30)     := 'populate_error_messages';
      l_api_version   CONSTANT NUMBER                    := 1.0;
      l_return_status          VARCHAR2 (1);
      l_init_msg_list          VARCHAR2 (1)              := p_init_msg_list;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_error_tbl              okl_vlr_pvt.vlrv_tbl_type := p_error_tbl;
      lx_error_tbl             okl_vlr_pvt.vlrv_tbl_type;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT pop_err_msgs_pvt;
      l_msg_count := 0;
      --  Initialize API return status to success
      l_return_status :=
         okl_api.start_activity (l_api_name,
                                 g_pkg_name,
                                 l_init_msg_list,
                                 l_api_version,
                                 l_api_version,
                                 '_PVT',
                                 l_return_status
                                );

      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Step 1
      --insert all new error stack errors
      -- Call the TAPI to insert all the errored values
      okl_vlr_pvt.insert_row (p_api_version        => l_api_version,
                              p_init_msg_list      => l_init_msg_list,
                              x_return_status      => l_return_status,
                              x_msg_count          => l_msg_count,
                              x_msg_data           => l_msg_data,
                              p_vlrv_tbl           => l_error_tbl,
                              x_vlrv_tbl           => lx_error_tbl
                             );

      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Step 3
      --set output variables
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         ROLLBACK TO pop_err_msgs_pvt;
         x_return_status := okl_api.g_ret_sts_unexp_error;
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;
      WHEN okl_api.g_exception_unexpected_error THEN
         ROLLBACK TO pop_err_msgs_pvt;
         x_return_status := okl_api.g_ret_sts_error;
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;
      WHEN OTHERS THEN
         ROLLBACK TO pop_err_msgs_pvt;
         x_return_status := okl_api.g_ret_sts_unexp_error;
         okl_api.set_message (p_app_name          => 'OKL',
                              p_msg_name          => 'OKL_DB_ERROR',
                              p_token1            => 'PROG_NAME',
                              p_token1_value      => 'populate_error_messages',
                              p_token2            => 'SQLCODE',
                              p_token2_value      => SQLCODE,
                              p_token3            => 'SQLERRM',
                              p_token3_value      => SQLERRM
                             );
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;
   END populate_error_messages;

   PROCEDURE process_batch(p_batch_id IN NUMBER,
                           px_error_tbl IN OUT NOCOPY okl_vlr_pvt.vlrv_tbl_type,
                           x_trx_status_code OUT NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2)
   IS
--AKRANGAN ADDED FOR BATCH RECEIPTS CROSS CURR FUNCTIONALITY BEGIN
        --CURSOR FOR IDENTIFYING DEBIT DOC CURRENCY
	CURSOR c_deb_doc_curr( p_debit_doc_id IN NUMBER)
        IS
        SELECT CURRENCY_CODE
        from  okc_k_headers_all_b
        WHERE id = p_debit_doc_id
        UNION
        SELECT CURRENCY_CODE
        from  OKL_CNSLD_AR_HDRS_ALL_B
        WHERE id = p_debit_doc_id
        UNION
        SELECT INVOICE_CURRENCY_CODE
        FROM  RA_CUSTOMER_TRX_ALL
        WHERE CUSTOMER_TRX_ID  = p_debit_doc_id;
--AKRANGAN ADDED FOR BATCH RECEIPTS CROSS CURR FUNCTIONALITY END

      -- retrieve all receipts for each batch at status 'SUBMITTED'
      CURSOR c_get_batch_receipts (cp_btc_id IN NUMBER) IS
         SELECT rct.ID,
                rca.ID,
                rct.ile_id,
                btc.irm_id,
                rct.check_number,
                rct.currency_code,
                btc.currency_conversion_type,
                btc.currency_conversion_rate,
                btc.currency_conversion_date,
                rct.amount,
                btc.date_entered,
                rca.cnr_id,
                rca.khr_id,
                rca.ar_invoice_id,
                rca.org_id,
                btc.date_gl_requested, --modified by akrangan for bug#6642533
                rct.date_effective,
                btc.remit_bank_id,
                rct.attribute_category,
                rct.attribute1,
                rct.attribute2,
                rct.attribute3,
                rct.attribute4,
                rct.attribute5,
                rct.attribute6,
                rct.attribute7,
                rct.attribute8,
                rct.attribute9,
                rct.attribute10,
                rct.attribute11,
                rct.attribute12,
                rct.attribute13,
                rct.attribute14,
                rct.attribute15
           FROM okl_trx_csh_batch_v btc,
                okl_trx_csh_receipt_v rct,
                okl_txl_rcpt_apps_v rca
          WHERE btc.ID = rct.btc_id
            AND rct.ID = rca.rct_id_details
            AND rct.btc_id = cp_btc_id;

      -- get customer account number
      CURSOR c_get_cust_acct_num (c_acct_id IN NUMBER) IS
         SELECT account_number
           FROM hz_cust_accounts
          WHERE cust_account_id = c_acct_id;

      i                         NUMBER                                   := 0;

      l_amount                  okl_trx_csh_receipt_v.amount%TYPE
                                                                 DEFAULT NULL;
      l_api_version             NUMBER                            DEFAULT 1.0;
      l_appl_tbl                okl_receipts_pvt.appl_tbl_type;
      l_ar_inv_id               okl_txl_rcpt_apps_v.ar_invoice_id%TYPE
                                                                 DEFAULT NULL;
      l_attribute_category      okl_trx_csh_receipt_v.attribute_category%TYPE
                                                                 DEFAULT NULL;
      l_attribute1              okl_trx_csh_receipt_v.attribute1%TYPE
                                                                 DEFAULT NULL;
      l_attribute2              okl_trx_csh_receipt_v.attribute2%TYPE
                                                                 DEFAULT NULL;
      l_attribute3              okl_trx_csh_receipt_v.attribute3%TYPE
                                                                 DEFAULT NULL;
      l_attribute4              okl_trx_csh_receipt_v.attribute4%TYPE
                                                                 DEFAULT NULL;
      l_attribute5              okl_trx_csh_receipt_v.attribute5%TYPE
                                                                 DEFAULT NULL;
      l_attribute6              okl_trx_csh_receipt_v.attribute6%TYPE
                                                                 DEFAULT NULL;
      l_attribute7              okl_trx_csh_receipt_v.attribute7%TYPE
                                                                 DEFAULT NULL;
      l_attribute8              okl_trx_csh_receipt_v.attribute8%TYPE
                                                                 DEFAULT NULL;
      l_attribute9              okl_trx_csh_receipt_v.attribute9%TYPE
                                                                 DEFAULT NULL;
      l_attribute10             okl_trx_csh_receipt_v.attribute10%TYPE
                                                                 DEFAULT NULL;
      l_attribute11             okl_trx_csh_receipt_v.attribute11%TYPE
                                                                 DEFAULT NULL;
      l_attribute12             okl_trx_csh_receipt_v.attribute12%TYPE
                                                                 DEFAULT NULL;
      l_attribute13             okl_trx_csh_receipt_v.attribute13%TYPE
                                                                 DEFAULT NULL;
      l_attribute14             okl_trx_csh_receipt_v.attribute14%TYPE
                                                                 DEFAULT NULL;
      l_attribute15             okl_trx_csh_receipt_v.attribute15%TYPE
                                                                 DEFAULT NULL;
      l_btc_id                  okl_trx_csh_batch_v.ID%TYPE      DEFAULT NULL;
      l_cash_receipt_id         ar_cash_receipts_all.cash_receipt_id%TYPE;
      l_check_number            okl_trx_csh_receipt_v.check_number%TYPE
                                                                 DEFAULT NULL;
      l_cnr_id                  okl_txl_rcpt_apps_v.cnr_id%TYPE  DEFAULT NULL;
      l_conversion_rate         NUMBER;
      l_counter                 NUMBER;
      l_currency_code           okl_trx_csh_receipt_v.currency_code%TYPE
                                                                 DEFAULT NULL;
      l_cust_num                ar_cash_receipts_all.pay_from_customer%TYPE
                                                                 DEFAULT NULL;
      l_date_effective          okl_trx_csh_receipt_v.date_effective%TYPE
                                                                 DEFAULT NULL;
      l_debit_doc_id                 NUMBER;
      l_error                   VARCHAR2 (2)                     DEFAULT NULL;
      l_exchange_rate_type     VARCHAR2(30);
      l_currency_conv_type      okl_trx_csh_receipt_v.exchange_rate_type%TYPE
                                                                 DEFAULT NULL;
      l_currency_conv_date      okl_trx_csh_receipt_v.exchange_rate_date%TYPE
                                                                 DEFAULT NULL;
      l_currency_conv_rate      okl_trx_csh_receipt_v.exchange_rate%TYPE
                                                                 DEFAULT NULL;
      l_gl_date                 okl_trx_csh_receipt_v.gl_date%TYPE
                                                                 DEFAULT NULL;
      l_ile_id                  okl_trx_csh_receipt_v.ile_id%TYPE
                                                                 DEFAULT NULL;
      l_init_msg_list           VARCHAR2 (1);
      l_inv_tot                 NUMBER                              DEFAULT 0;
      l_invoice_currency_code           okl_trx_csh_receipt_v.currency_code%TYPE
                                                                 DEFAULT NULL;
      l_irm_id                  okl_trx_csh_receipt_v.irm_id%TYPE
                                                                 DEFAULT NULL;
      l_khr_id                  okl_txl_rcpt_apps_v.khr_id%TYPE  DEFAULT NULL;
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (2000);
      l_msg_index_out           NUMBER;
      l_org_id                  okl_txl_rcpt_apps_v.org_id%TYPE  DEFAULT NULL;
      l_rca_id                  okl_txl_rcpt_apps_v.ID%TYPE      DEFAULT NULL;
      l_rcpt_rec                okl_receipts_pvt.rcpt_rec_type;
      l_rcpt_status_code        okl_trx_csh_receipt_v.rcpt_status_code%TYPE;
      l_rct_id                  okl_trx_csh_receipt_v.ID%TYPE    DEFAULT NULL;
      l_receipt_currency           okl_trx_csh_receipt_v.currency_code%TYPE
                                                                 DEFAULT NULL;
      l_remit_bank_id           NUMBER;
      l_return_status           VARCHAR2 (1);
      l_trx_status_code         okl_trx_csh_batch_v.trx_status_code%TYPE := 'PROCESSED';
      l_validation_text         VARCHAR2 (2000);

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT process_batch_pvt;
      l_btc_id := p_batch_id;
      IF px_error_tbl.COUNT > 0 THEN
        i := px_error_tbl.LAST;
      ELSE
	    i := 0;
	  END IF;

      OPEN c_get_batch_receipts (l_btc_id);
      LOOP
        -- loop through batch receipts
        FETCH c_get_batch_receipts
             INTO l_rct_id,
                  l_rca_id,
                  l_ile_id,
                  l_irm_id,
                  l_check_number,
                  l_currency_code,
                  l_currency_conv_type,
                  l_currency_conv_rate,
                  l_currency_conv_date,
                  l_amount,
                  l_date_effective,
                  l_cnr_id,
                  l_khr_id,
                  l_ar_inv_id,
                  l_org_id,
                  l_gl_date,
                  l_date_effective,
                  l_remit_bank_id,
                  l_attribute_category,
                  l_attribute1,
                  l_attribute2,
                  l_attribute3,
                  l_attribute4,
                  l_attribute5,
                  l_attribute6,
                  l_attribute7,
                  l_attribute8,
                  l_attribute9,
                  l_attribute10,
                  l_attribute11,
                  l_attribute12,
                  l_attribute13,
                  l_attribute14,
                  l_attribute15;

        IF c_get_batch_receipts%NOTFOUND THEN
           -- No Internal Batch Payment Transactions Found for batch l_batch_name
           okc_api.set_message (p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_BPD_NO_INT_RCPTS'
                                );
           EXIT;                      -- exit out with nothing to process.
        END IF;

        LOOP
          -- only one receipt record
          IF   l_ile_id IS NULL
            OR l_check_number IS NULL
            OR l_currency_code IS NULL
            OR l_amount IS NULL
            OR l_amount = 0
            OR l_irm_id IS NULL
            OR (    l_cnr_id IS NULL
                AND l_khr_id IS NULL
                AND l_ar_inv_id IS NULL ) THEN
            -- Missing mandatory fields for batch cash application process
            fnd_file.put_line
              (fnd_file.LOG,
               'Some of the mandatory fields are missing - Batch'
               );
             fnd_file.put_line (fnd_file.LOG, 'ILE_ID  = ' || l_ile_id);
             fnd_file.put_line (fnd_file.LOG,
                                     'CHECK_NUMBER = ' || l_check_number
                                    );
             fnd_file.put_line (fnd_file.LOG,
                                     'CURRENCY_CODE = ' || l_currency_code
                                    );
             fnd_file.put_line (fnd_file.LOG, 'AMOUNT = ' || l_amount);
             fnd_file.put_line (fnd_file.LOG, 'CNR_ID = ' || l_cnr_id);
             fnd_file.put_line (fnd_file.LOG, 'KHR_ID = ' || l_khr_id);
             fnd_file.put_line (fnd_file.LOG, 'IRM_ID = ' || l_irm_id);
                  /*               okc_api.set_message
                  (p_app_name          => g_app_name,
                   p_msg_name          => 'OKL_BPD_MAND_CASH_APP_FLDS',
                   p_token1            => 'ILE_ID',
                   p_token1_value      => l_ile_id,
                   p_token2            => 'CHECK_NUMBER',
                   p_token2_value      => l_check_number,
                   p_token3            => 'CURRENCY_CODE',
                   p_token3_value      => l_currency_code,
                   p_token4            => 'AMOUNT',
                   p_token4_value      => l_amount,
                   p_token5            => 'CNR_ID',
                   p_token5_value      => l_cnr_id,
                   p_token6            => 'KHR_ID',
                   p_token6_value      => l_khr_id,
                   p_token7            => 'IRM_ID',
                   p_token7_value      => l_irm_id
                  );*/
             l_error := 'E';

             IF (fnd_msg_pub.count_msg > 0) THEN
               FOR l_counter IN 1 .. fnd_msg_pub.count_msg
               LOOP
                 i := i + 1;
                 px_error_tbl (i).parent_object_code /* RECEIPT_BATCH*/
                                                          := 'RECEIPT_BATCH';
                 px_error_tbl (i).parent_object_id        /* BATCH_ID*/
                                                        := l_btc_id;
                 px_error_tbl (i).validation_id         /* RECEIPT_ID*/
                                                     := l_rct_id;
                 px_error_tbl (i).result_code               /* ERROR */
                                                   := 'ERROR';
                 fnd_msg_pub.get (p_msg_index          => l_counter,
                                  p_encoded            => 'F',
                                  p_data               => l_validation_text,
                                  p_msg_index_out      => l_msg_index_out
                                  );
                 px_error_tbl (i).validation_text := l_validation_text;
               END LOOP;
             END IF;

             l_rcpt_status_code := 'FAILED';
             l_trx_status_code := 'ERROR';
             EXIT;
           END IF;

           -- populate the header and the table records to call Handle receipts method
           OPEN c_get_cust_acct_num (l_ile_id);

           FETCH c_get_cust_acct_num
              INTO l_cust_num;

           CLOSE c_get_cust_acct_num;

               /*  OPEN c_get_rem_bank(l_irm_id,l_currency_code);
               FETCH c_get_rem_bank INTO l_remit_bank_id;
               CLOSE c_get_rem_bank;*/

   --akrangan modification for cross currency begin
           --find out debit doc currency
           IF l_khr_id IS NOT NULL  THEN
             l_debit_doc_id := l_khr_id;
           ELSIF l_cnr_id IS NOT NULL  THEN
             l_debit_doc_id := l_cnr_id;
           ELSIF l_ar_inv_id IS NOT NULL  THEN
             l_debit_doc_id := l_khr_id;
           END IF;

           OPEN c_deb_doc_curr (l_debit_doc_id);
           FETCH c_deb_doc_curr INTO l_invoice_currency_code;
           CLOSE c_deb_doc_curr;

           l_receipt_currency := l_currency_code ;
           --recipt to invoice currency conversion code
           IF l_invoice_currency_code <> l_receipt_currency THEN
             l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(l_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
             IF l_exchange_rate_type IS  NULL THEN
               OKL_API.set_message( p_app_name      => G_APP_NAME
                                 ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                 );
             IF (fnd_msg_pub.count_msg > 0) THEN
                 FOR l_counter IN 1 .. fnd_msg_pub.count_msg
                 LOOP
                   i := i + 1;
                   px_error_tbl (i).parent_object_code /* RECEIPT_BATCH*/
                                                          := 'RECEIPT_BATCH';
                   px_error_tbl (i).parent_object_id        /* BATCH_ID*/
                                                        := l_btc_id;
                   px_error_tbl (i).validation_id         /* RECEIPT_ID*/
                                                     := l_rct_id;
                   px_error_tbl (i).result_code               /* ERROR */
                                                   := 'ERROR';
                   fnd_msg_pub.get (p_msg_index          => l_counter,
                                  p_encoded            => 'F',
                                  p_data               => l_validation_text,
                                  p_msg_index_out      => l_msg_index_out
                                  );
                   px_error_tbl (i).validation_text := l_validation_text;
                 END LOOP;
               END IF;
               RAISE G_EXCEPTION_HALT_VALIDATION;
             ELSE
               l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_invoice_currency_code
                                                                          ,l_receipt_currency
                                                                          ,l_date_effective
                                                                          ,l_exchange_rate_type
                                                                          );
               IF l_conversion_rate IN (0,-1) THEN
                 -- Message Text: No exchange rate defined
                 x_return_status := okl_api.G_RET_STS_ERROR;
                 okl_api.set_message( p_app_name      => G_APP_NAME,
                                      p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                 IF (fnd_msg_pub.count_msg > 0) THEN
                   FOR l_counter IN 1 .. fnd_msg_pub.count_msg
                   LOOP
                     i := i + 1;
                     px_error_tbl (i).parent_object_code /* RECEIPT_BATCH*/
                                                          := 'RECEIPT_BATCH';
                     px_error_tbl (i).parent_object_id        /* BATCH_ID*/
                                                        := l_btc_id;
                     px_error_tbl (i).validation_id         /* RECEIPT_ID*/
                                                     := l_rct_id;
                     px_error_tbl (i).result_code               /* ERROR */
                                                   := 'ERROR';
                     fnd_msg_pub.get (p_msg_index          => l_counter,
                                  p_encoded            => 'F',
                                  p_data               => l_validation_text,
                                  p_msg_index_out      => l_msg_index_out
                                  );
                     px_error_tbl (i).validation_text := l_validation_text;
                   END LOOP;
                 END IF;
                 RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
             END IF;
             l_inv_tot := l_amount * l_conversion_rate;
           END IF;

           l_rcpt_rec.cash_receipt_id := NULL;
           l_rcpt_rec.amount := l_amount ;
           l_rcpt_rec.currency_code := l_currency_code;
           l_rcpt_rec.customer_number := l_cust_num;    --cust acct number
               --               l_rcpt_rec.CUSTOMER_ID := l_ile_id; --cust acct id -- Commented for Regression in Customer Bank Account
           l_rcpt_rec.receipt_number := l_check_number;
           l_rcpt_rec.receipt_date := l_date_effective;
           l_rcpt_rec.exchange_rate_type := l_currency_conv_type;
           l_rcpt_rec.exchange_rate := l_currency_conv_rate;
           l_rcpt_rec.exchange_date := l_currency_conv_date;
           l_rcpt_rec.remittance_bank_account_id := l_remit_bank_id;
           l_rcpt_rec.receipt_method_id := l_irm_id;
           l_rcpt_rec.org_id := l_org_id;
           l_rcpt_rec.gl_date := l_gl_date;
           l_rcpt_rec.create_mode := 'UNAPPLIED';
           l_rcpt_rec.create_mode := 'UNAPPLIED';
           l_rcpt_rec.dff_attribute_category := l_attribute_category;
           l_rcpt_rec.dff_attribute1 := l_attribute1;
           l_rcpt_rec.dff_attribute2 := l_attribute2;
           l_rcpt_rec.dff_attribute3 := l_attribute3;
           l_rcpt_rec.dff_attribute4 := l_attribute4;
           l_rcpt_rec.dff_attribute5 := l_attribute5;
           l_rcpt_rec.dff_attribute6 := l_attribute6;
           l_rcpt_rec.dff_attribute7 := l_attribute7;
           l_rcpt_rec.dff_attribute8 := l_attribute8;
           l_rcpt_rec.dff_attribute9 := l_attribute9;
           l_rcpt_rec.dff_attribute10 := l_attribute10;
           l_rcpt_rec.dff_attribute11 := l_attribute11;
           l_rcpt_rec.dff_attribute12 := l_attribute12;
           l_rcpt_rec.dff_attribute13 := l_attribute13;
           l_rcpt_rec.dff_attribute14 := l_attribute14;
           l_rcpt_rec.dff_attribute15 := l_attribute15;
           l_rcpt_rec.customer_bank_account_id := NULL;
           -- Included for Customer Bank Account Regression
           l_appl_tbl (0).ar_inv_id := l_ar_inv_id;
           l_appl_tbl (0).con_inv_id := l_cnr_id;
           l_appl_tbl (0).contract_id := l_khr_id;
           l_appl_tbl (0).amount_to_apply := l_inv_tot;
           l_appl_tbl (0).amount_applied_from  := l_amount;

           --akrangan modification for cross currency end
           -- call handle receipts
           okl_receipts_pvt.handle_receipt
                         (p_api_version          => l_api_version,
                          p_init_msg_list        => l_init_msg_list,
                          x_return_status        => l_return_status,
                          x_msg_count            => l_msg_count,
                          x_msg_data             => l_msg_data,
                          p_rcpt_rec             => l_rcpt_rec,
                          p_appl_tbl             => l_appl_tbl,
                          x_cash_receipt_id      => l_cash_receipt_id
                          );

           IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  okl_api.set_message
                                   (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKL_DB_ERROR',
                                    p_token1            => 'PROG_NAME',
                                    p_token1_value      => 'int_ext_csh_app',
                                    p_token2            => 'SQLCODE',
                                    p_token2_value      => SQLCODE,
                                    p_token3            => 'SQLERRM',
                                    p_token3_value      => SQLERRM
                                   );

             IF (fnd_msg_pub.count_msg > 0) THEN
               FOR l_counter IN 1 .. fnd_msg_pub.count_msg
               LOOP
                 i := i + 1;
                 px_error_tbl (i).parent_object_code /* RECEIPT_BATCH*/
                                                          := 'RECEIPT_BATCH';
                 px_error_tbl (i).parent_object_id        /* BATCH_ID*/
                                                        := l_btc_id;
                 px_error_tbl (i).validation_id         /* RECEIPT_ID*/
                                                     := l_rct_id;
                 px_error_tbl (i).result_code               /* ERROR */
                                                   := 'ERROR';
                 fnd_msg_pub.get
                                   (p_msg_index          => l_counter,
                                    p_encoded            => 'F',
                                    p_data               => px_error_tbl (i).validation_text,
                                    p_msg_index_out      => l_msg_index_out
                                   );
               END LOOP;
             END IF;
             l_rcpt_status_code := 'FAILED';
             l_trx_status_code := 'ERROR';
             EXIT;

           END IF;

           IF (l_return_status = okl_api.g_ret_sts_error) THEN
                  /*     okc_api.set_message (p_app_name          => g_app_name,
                   p_msg_name          => 'OKL_BPD_CASH_APP_FAIL',
                   p_token1            => 'CUSTOMER_NUM',
                   p_token1_value      => l_cust_num,
                   p_token2            => 'CONS_BILL_NUM',
                   p_token2_value      => l_cnr_id,
                   p_token3            => 'CONTRACT_NUM',
                   p_token3_value      => l_khr_id
                  );*/
                  l_error := 'E';
                  l_rcpt_status_code := 'FAILED';
                  l_trx_status_code := 'ERROR';

                  IF (fnd_msg_pub.count_msg > 0) THEN
                     FOR l_counter IN 1 .. fnd_msg_pub.count_msg
                     LOOP
                        i := i + 1;
                        px_error_tbl (i).parent_object_code /* RECEIPT_BATCH*/
                                                          := 'RECEIPT_BATCH';
                        px_error_tbl (i).parent_object_id        /* BATCH_ID*/
                                                        := l_btc_id;
                        px_error_tbl (i).validation_id         /* RECEIPT_ID*/
                                                     := l_rct_id;
                        px_error_tbl (i).result_code               /* ERROR */
                                                   := 'ERROR';
                        fnd_msg_pub.get
                                   (p_msg_index          => l_counter,
                                    p_encoded            => 'F',
                                    p_data               => px_error_tbl (i).validation_text,
                                    p_msg_index_out      => l_msg_index_out
                                   );
                     END LOOP;
                  END IF;

                  EXIT;
               END IF;

               -- enter into log file that cash app was sucessful for this batch customer/contract/cons bill
               -- and update receipt status.
               /*             okc_api.set_message (p_app_name          => g_app_name,
                p_msg_name          => 'OKL_BPD_CASH_APP_SUCC',
                p_token1            => 'CUSTOMER_NUM',
                p_token1_value      => l_cust_num,
                p_token2            => 'CONS_BILL_NUM',
                p_token2_value      => l_cnr_id,
                p_token3            => 'CONTRACT_NUM',
                p_token3_value      => l_khr_id
               );*/
               l_rcpt_status_code := 'PROCESSED';
               EXIT;
            END LOOP;                           -- end only one receipt record

            --  update  transaction receipt status ...
            UPDATE okl_trx_csh_receipt_b
               SET rcpt_status_code = l_rcpt_status_code
             WHERE ID = l_rct_id;

            -- Update Ar receipt Id , if it successfully created
            IF (l_return_status = okl_api.g_ret_sts_success) THEN
               UPDATE okl_trx_csh_receipt_b
                  SET ID = l_cash_receipt_id
                WHERE ID = l_rct_id;

               UPDATE okl_trx_csh_receipt_tl
                  SET ID = l_cash_receipt_id
                WHERE ID = l_rct_id;

               UPDATE okl_txl_rcpt_apps_b
                  SET rct_id_details = l_cash_receipt_id
                WHERE rct_id_details = l_rct_id;
            END IF;
         END LOOP;                                     -- end looping receipts
         CLOSE c_get_batch_receipts;
         IF l_trx_status_code = 'ERROR' THEN
           ROLLBACK TO process_batch_pvt;
         END IF;
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
         x_trx_status_code := l_trx_status_code;
   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO process_batch_pvt;
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       x_trx_status_code := 'ERROR';
   END process_batch;

---------------------------------------------------------------------------
-- PROCEDURE int_ext_csh_app
---------------------------------------------------------------------------
   PROCEDURE int_ext_csh_app (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   ) IS
------------------------------
-- DECLARE Local variables
------------------------------
      l_api_version             NUMBER                            DEFAULT 1.0;
      l_init_msg_list           VARCHAR2 (1);
      l_return_status           VARCHAR2 (1);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (2000);
      l_trx_status_code         okl_trx_csh_batch_v.trx_status_code%TYPE;
      l_rcpt_status_code        okl_trx_csh_receipt_v.rcpt_status_code%TYPE;
      l_btc_id                  okl_trx_csh_batch_v.ID%TYPE      DEFAULT NULL;
      l_btc_name                okl_trx_csh_batch_v.NAME%TYPE    DEFAULT NULL;
      l_rct_id                  okl_trx_csh_receipt_v.ID%TYPE    DEFAULT NULL;
      l_rca_id                  okl_txl_rcpt_apps_v.ID%TYPE      DEFAULT NULL;
      l_ile_id                  okl_trx_csh_receipt_v.ile_id%TYPE
                                                                 DEFAULT NULL;
      l_irm_id                  okl_trx_csh_receipt_v.irm_id%TYPE
                                                                 DEFAULT NULL;
      l_check_number            okl_trx_csh_receipt_v.check_number%TYPE
                                                                 DEFAULT NULL;
      l_currency_code           okl_trx_csh_receipt_v.currency_code%TYPE
                                                                 DEFAULT NULL;
      l_currency_conv_type      okl_trx_csh_receipt_v.exchange_rate_type%TYPE
                                                                 DEFAULT NULL;
      l_currency_conv_date      okl_trx_csh_receipt_v.exchange_rate_date%TYPE
                                                                 DEFAULT NULL;
      l_currency_conv_rate      okl_trx_csh_receipt_v.exchange_rate%TYPE
                                                                 DEFAULT NULL;
      l_amount                  okl_trx_csh_receipt_v.amount%TYPE
                                                                 DEFAULT NULL;
      l_date_effective          okl_trx_csh_receipt_v.date_effective%TYPE
                                                                 DEFAULT NULL;
      l_gl_date                 okl_trx_csh_receipt_v.gl_date%TYPE
                                                                 DEFAULT NULL;
      l_cnr_id                  okl_txl_rcpt_apps_v.cnr_id%TYPE  DEFAULT NULL;
      l_khr_id                  okl_txl_rcpt_apps_v.khr_id%TYPE  DEFAULT NULL;
      l_ar_inv_id               okl_txl_rcpt_apps_v.ar_invoice_id%TYPE
                                                                 DEFAULT NULL;
      l_cash_receipt_id         ar_cash_receipts_all.cash_receipt_id%TYPE;
      l_org_id                  okl_txl_rcpt_apps_v.org_id%TYPE  DEFAULT NULL;
      l_cust_num                ar_cash_receipts_all.pay_from_customer%TYPE
                                                                 DEFAULT NULL;
      l_remit_bank_id           NUMBER;
      l_curr_con_type           okl_trx_csh_batch_v.currency_conversion_type%TYPE
                                                                 DEFAULT NULL;
      l_curr_con_rate           okl_trx_csh_batch_v.currency_conversion_rate%TYPE
                                                                 DEFAULT NULL;
      l_curr_con_date           okl_trx_csh_batch_v.currency_conversion_date%TYPE
                                                                 DEFAULT NULL;
      l_customer_num            ar_cash_receipts_all.pay_from_customer%TYPE
                                                                 DEFAULT NULL;
      l_cons_bill_num           okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE
                                                                 DEFAULT NULL;
      l_cons_bill_num_log       okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE
                                                                 DEFAULT NULL;
      l_contract_num            okc_k_headers_v.contract_number%TYPE
                                                                 DEFAULT NULL;
      l_contract_num_log        okc_k_headers_v.contract_number%TYPE
                                                                 DEFAULT NULL;
      l_comments                okl_trx_csh_receipt_tl.description%TYPE
                                                                 DEFAULT NULL;
      l_amount_due_remaining    ar_payment_schedules_all.amount_due_remaining%TYPE
                                                                 DEFAULT NULL;
      l_bank_account_id         okl_trx_csh_receipt_v.iba_id%TYPE
                                                                 DEFAULT NULL;
      l_tolerance               okl_cash_allctn_rls.amount_tolerance_percent%TYPE;
      l_days_past_quote_valid   okl_cash_allctn_rls.days_past_quote_valid_toleranc%TYPE;
      l_months_to_bill_ahead    okl_cash_allctn_rls.months_to_bill_ahead%TYPE;
      l_under_payment           okl_cash_allctn_rls.under_payment_allocation_code%TYPE;
      l_over_payment            okl_cash_allctn_rls.over_payment_allocation_code%TYPE;
      l_receipt_msmtch          okl_cash_allctn_rls.receipt_msmtch_allocation_code%TYPE;
      l_attribute_category      okl_trx_csh_receipt_v.attribute_category%TYPE
                                                                 DEFAULT NULL;
      l_attribute1              okl_trx_csh_receipt_v.attribute1%TYPE
                                                                 DEFAULT NULL;
      l_attribute2              okl_trx_csh_receipt_v.attribute2%TYPE
                                                                 DEFAULT NULL;
      l_attribute3              okl_trx_csh_receipt_v.attribute3%TYPE
                                                                 DEFAULT NULL;
      l_attribute4              okl_trx_csh_receipt_v.attribute4%TYPE
                                                                 DEFAULT NULL;
      l_attribute5              okl_trx_csh_receipt_v.attribute5%TYPE
                                                                 DEFAULT NULL;
      l_attribute6              okl_trx_csh_receipt_v.attribute6%TYPE
                                                                 DEFAULT NULL;
      l_attribute7              okl_trx_csh_receipt_v.attribute7%TYPE
                                                                 DEFAULT NULL;
      l_attribute8              okl_trx_csh_receipt_v.attribute8%TYPE
                                                                 DEFAULT NULL;
      l_attribute9              okl_trx_csh_receipt_v.attribute9%TYPE
                                                                 DEFAULT NULL;
      l_attribute10             okl_trx_csh_receipt_v.attribute10%TYPE
                                                                 DEFAULT NULL;
      l_attribute11             okl_trx_csh_receipt_v.attribute11%TYPE
                                                                 DEFAULT NULL;
      l_attribute12             okl_trx_csh_receipt_v.attribute12%TYPE
                                                                 DEFAULT NULL;
      l_attribute13             okl_trx_csh_receipt_v.attribute13%TYPE
                                                                 DEFAULT NULL;
      l_attribute14             okl_trx_csh_receipt_v.attribute14%TYPE
                                                                 DEFAULT NULL;
      l_attribute15             okl_trx_csh_receipt_v.attribute15%TYPE
                                                                 DEFAULT NULL;
      l_inv_tot                 NUMBER                              DEFAULT 0;
      l_error                   VARCHAR2 (2)                     DEFAULT NULL;
      l_create_receipt_flag     VARCHAR2 (2)                     DEFAULT 'YC';
-- indicates create ar receipt and concurrent
-- process for cash application routine.
------------------------------
-- DECLARE Record/Table Types
------------------------------
      l_btcv_rec                okl_btc_pvt.btcv_rec_type;
      l_btcv_tbl                okl_btc_pvt.btcv_tbl_type;
      x_btcv_rec                okl_btc_pvt.btcv_rec_type;
      x_btcv_tbl                okl_btc_pvt.btcv_tbl_type;
      l_rctv_rec                okl_rct_pvt.rctv_rec_type;
      l_rctv_tbl                okl_rct_pvt.rctv_tbl_type;
      x_rctv_rec                okl_rct_pvt.rctv_rec_type;
      x_rctv_tbl                okl_rct_pvt.rctv_tbl_type;
      l_rcav_rec                okl_rca_pvt.rcav_rec_type;
      l_rcav_tbl                okl_rca_pvt.rcav_tbl_type;
      x_rcav_rec                okl_rca_pvt.rcav_rec_type;
      x_rcav_tbl                okl_rca_pvt.rcav_tbl_type;
      l_rcpt_rec                okl_receipts_pvt.rcpt_rec_type;
      l_appl_tbl                okl_receipts_pvt.appl_tbl_type;
      --error message table declaration
      --added by akrangan start
      i                         NUMBER                                   := 0;
      l_error_tbl               okl_vlr_pvt.vlrv_tbl_type;
      l_msg_index_out           NUMBER;

      l_counter                 NUMBER;
      --added by akrangan end
      l_old_error_tbl           okl_vlr_pvt.vlrv_tbl_type;

-----------------------------
-- DECLARE Exceptions
------------------------------

      ------------------------------
-- DECLARE Cursors
------------------------------

      -- get internal payment transaction records that have no external
      -- These payments are not attached to a batch, meaning the internal
      -- transaction table was populated directly.
      CURSOR c_get_int_recs IS
         SELECT rct.ID,
                rca.ID,
                rct.ile_id,
                rct.irm_id,
                rct.check_number,
                rct.currency_code,
                rct.exchange_rate,
                rct.exchange_rate_date,
                rct.exchange_rate_type,
                rct.amount,
                rct.date_effective,
                rca.cnr_id,
                rca.khr_id,
                rca.ar_invoice_id,
                rca.org_id,
                rct.gl_date,
                rct.date_effective
           FROM okl_trx_csh_receipt_v rct, okl_txl_rcpt_apps_v rca
          WHERE rct.ID = rca.rct_id_details
            AND rct.btc_id IS NULL
            AND rct.btc_id = -1;             --to be reviewed and tested later

      -- sosharma changed

      ----------

      -- retrieve all batches at status 'SUBMITTED'
      CURSOR c_get_batches IS
         SELECT btc.ID,
                btc.currency_conversion_type,
                btc.currency_conversion_rate,
                btc.currency_conversion_date
           FROM okl_trx_csh_batch_v btc
          WHERE btc.trx_status_code IN ('SUBMITTED', 'RESUBMITTED');

      --akrangan added resubmitted sts chk

      ----------

      -- get redundant batches, i.e. batches with no receipt headers
      CURSOR c_get_redund_batch IS
         SELECT btc.ID, btc.NAME
           FROM okl_trx_csh_batch_v btc
          WHERE creation_date < (SYSDATE - 7)
            AND btc.trx_status_code IN
                                   ('WORKING', 'RESUBMITTED') --akrangan added
            AND btc.ID NOT IN (SELECT btc_id
                                 FROM okl_trx_csh_receipt_v
                                WHERE btc_id = btc.ID);

-- get remittance bank
      CURSOR c_get_rem_bank (
         c_rcpt_method_id   IN   NUMBER,
         c_curr_code        IN   VARCHAR2
      ) IS
         SELECT bank_account_id
           FROM okl_bpd_rcpt_mthds_uv rcpt
          WHERE rcpt.currency_code = c_curr_code
            AND rcpt.receipt_method_id = c_rcpt_method_id;

      -- get customer account number
      CURSOR c_get_cust_acct_num (c_acct_id IN NUMBER) IS
         SELECT account_number
           FROM hz_cust_accounts
          WHERE cust_account_id = c_acct_id;

-----------------
--cursor for getting old messages
      CURSOR c_get_previous_errors (p_batch_id IN NUMBER) IS
         SELECT vb.ID,
                vb.object_version_number,
                vb.attribute_category,
                vb.attribute1,
                vb.attribute2,
                vb.attribute3,
                vb.attribute4,
                vb.attribute5,
                vb.attribute6,
                vb.attribute7,
                vb.attribute8,
                vb.attribute9,
                vb.attribute10,
                vb.attribute11,
                vb.attribute12,
                vb.attribute13,
                vb.attribute14,
                vb.attribute15,
                vb.parent_object_code,
                vb.parent_object_id,
                vb.validation_id,
                vb.result_code,
                vl.validation_text
           FROM okl_validation_results_b vb,
                okl_validation_results_tl vl,
                okl_trx_csh_batch_v btc
          WHERE vb.ID = vl.ID
            AND vl.LANGUAGE = USERENV ('LANG')
            AND vb.parent_object_code = 'RECEIPT_BATCH'
            AND vb.parent_object_id = btc.ID
            AND btc.ID = p_batch_id;

--AKRANGAN ADDED FOR BATCH RECEIPTS CROSS CURR FUNCTIONALITY BEGIN
        --CURSOR FOR IDENTIFYING DEBIT DOC CURRENCY
	CURSOR c_deb_doc_curr( p_debit_doc_id IN NUMBER)
        IS
        SELECT CURRENCY_CODE
        from  okc_k_headers_all_b
        WHERE id = p_debit_doc_id
        UNION
        SELECT CURRENCY_CODE
        from  OKL_CNSLD_AR_HDRS_ALL_B
        WHERE id = p_debit_doc_id
        UNION
        SELECT INVOICE_CURRENCY_CODE
        FROM  RA_CUSTOMER_TRX_ALL
        WHERE CUSTOMER_TRX_ID  = p_debit_doc_id;
        --NEW LOCAL VARIABLES ADDED FOR PROVIDING CROSS CURR FUNCTIONALITY
        l_receipt_currency VARCHAR2(100);
        l_invoice_currency_code VARCHAR2(100);
        l_receipt_date DATE;
        l_exchange_rate_type VARCHAR2(100);
        l_conversion_rate   NUMBER;
        l_debit_doc_id     NUMBER;
--AKRANGAN ADDED FOR BATCH RECEIPTS CROSS CURR FUNCTIONALITY END

   BEGIN
--------------------------------------------------------------------
-- Start by processing receipts that are not attached to a batch ....
--------------------------------------------------------------------
      OPEN c_get_int_recs;

      LOOP
         FETCH c_get_int_recs
          INTO l_rct_id,
               l_rca_id,
               l_ile_id,
               l_irm_id,
               l_check_number,
               l_currency_code,
               l_currency_conv_rate,
               l_currency_conv_date,
               l_currency_conv_type,
               l_amount,
               l_date_effective,
               l_cnr_id,
               l_khr_id,
               l_ar_inv_id,
               l_org_id,
               l_gl_date,
               l_date_effective;

         IF c_get_int_recs%NOTFOUND THEN
            -- No Internal Payment Transactions Found
            /*            okc_api.set_message (p_app_name      => g_app_name,
             p_msg_name      => 'OKL_BPD_NO_INT_RCPTS'
            );*/
            fnd_file.put_line (fnd_file.LOG,
                               'No Internal Payment Transactions Found'
                              );
            EXIT;                         -- exit out with nothing to process.
         END IF;

         LOOP
            IF    l_ile_id IS NULL
               OR l_check_number IS NULL
               OR l_currency_code IS NULL
               OR l_amount IS NULL
               OR l_amount = 0
               OR l_irm_id IS NULL
               OR (l_cnr_id IS NULL AND l_khr_id IS NULL
                   AND l_ar_inv_id IS NULL
                  ) THEN
               -- Missing mandatory fields for cash application process
               fnd_file.put_line (fnd_file.LOG,
                                  'Some of the mandatory fields are missing.'
                                 );
               fnd_file.put_line (fnd_file.LOG, 'ILE_ID  = ' || l_ile_id);
               fnd_file.put_line (fnd_file.LOG,
                                  'CHECK_NUMBER = ' || l_check_number
                                 );
               fnd_file.put_line (fnd_file.LOG,
                                  'CURRENCY_CODE = ' || l_currency_code
                                 );
               fnd_file.put_line (fnd_file.LOG, 'AMOUNT = ' || l_amount);
               fnd_file.put_line (fnd_file.LOG, 'CNR_ID = ' || l_cnr_id);
               fnd_file.put_line (fnd_file.LOG, 'KHR_ID = ' || l_khr_id);
               fnd_file.put_line (fnd_file.LOG, 'IRM_ID = ' || l_irm_id);
               /*               okc_api.set_message
               (p_app_name          => g_app_name,
                p_msg_name          => 'OKL_BPD_MAND_CASH_APP_FLDS',
                p_token1            => 'ILE_ID',
                p_token1_value      => l_ile_id,
                p_token2            => 'CHECK_NUMBER',
                p_token2_value      => l_check_number,
                p_token3            => 'CURRENCY_CODE',
                p_token3_value      => l_currency_code,
                p_token4            => 'AMOUNT',
                p_token4_value      => l_amount,
                p_token5            => 'CNR_ID',
                p_token5_value      => l_cnr_id,
                p_token6            => 'KHR_ID',
                p_token6_value      => l_khr_id,
                p_token7            => 'IRM_ID',
                p_token7_value      => l_irm_id
               );*/
               l_error := 'E';
               EXIT;
            END IF;

            -- populate the header and the table records to call Handle receipts method
            OPEN c_get_cust_acct_num (l_ile_id);

            FETCH c_get_cust_acct_num
             INTO l_cust_num;

            CLOSE c_get_cust_acct_num;

            OPEN c_get_rem_bank (l_irm_id, l_currency_code);

            FETCH c_get_rem_bank
             INTO l_remit_bank_id;

            CLOSE c_get_rem_bank;


   --akrangan modification for cross currency begin
          --find out debit doc currency
          IF l_khr_id IS NOT NULL  THEN
             l_debit_doc_id := l_khr_id;
          ELSIF l_cnr_id IS NOT NULL  THEN
             l_debit_doc_id := l_cnr_id;
          ELSIF l_ar_inv_id IS NOT NULL  THEN
             l_debit_doc_id := l_khr_id;
          END IF;
          OPEN c_deb_doc_curr (l_debit_doc_id);
          FETCH c_deb_doc_curr
           INTO l_invoice_currency_code;
          CLOSE c_deb_doc_curr;
          l_receipt_currency := l_currency_code ;
          --recipt to invoice currency conversion code
               IF l_invoice_currency_code <> l_receipt_currency THEN
                  l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(l_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                  IF l_exchange_rate_type IS  NULL THEN
                    OKL_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                       );
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                  ELSE
                    l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_invoice_currency_code
                                                                               ,l_receipt_currency
                                                                               ,l_date_effective
                                                                               ,l_exchange_rate_type
                                                                              );
                    IF l_conversion_rate IN (0,-1) THEN
                      -- Message Text: No exchange rate defined
                      x_return_status := okl_api.G_RET_STS_ERROR;
                      okl_api.set_message( p_app_name      => G_APP_NAME,
                                           p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                      RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
                  END IF;
                  l_inv_tot := l_amount * l_conversion_rate;
                END IF;
               l_rcpt_rec.cash_receipt_id := NULL;
               l_rcpt_rec.amount := l_amount ;
               l_rcpt_rec.currency_code := l_currency_code;
               l_rcpt_rec.customer_number := l_cust_num;    --cust acct number
               --               l_rcpt_rec.CUSTOMER_ID := l_ile_id; --cust acct id -- Commented for Regression in Customer Bank Account
               l_rcpt_rec.receipt_number := l_check_number;
               l_rcpt_rec.receipt_date := l_date_effective;
               l_rcpt_rec.exchange_rate_type := l_currency_conv_type;
               l_rcpt_rec.exchange_rate := l_currency_conv_rate;
               l_rcpt_rec.exchange_date := l_currency_conv_date;
               l_rcpt_rec.remittance_bank_account_id := l_remit_bank_id;
               l_rcpt_rec.receipt_method_id := l_irm_id;
               l_rcpt_rec.org_id := l_org_id;
               l_rcpt_rec.gl_date := l_gl_date;
               l_rcpt_rec.create_mode := 'UNAPPLIED';
               l_rcpt_rec.create_mode := 'UNAPPLIED';
               l_rcpt_rec.dff_attribute_category := l_attribute_category;
               l_rcpt_rec.dff_attribute1 := l_attribute1;
               l_rcpt_rec.dff_attribute2 := l_attribute2;
               l_rcpt_rec.dff_attribute3 := l_attribute3;
               l_rcpt_rec.dff_attribute4 := l_attribute4;
               l_rcpt_rec.dff_attribute5 := l_attribute5;
               l_rcpt_rec.dff_attribute6 := l_attribute6;
               l_rcpt_rec.dff_attribute7 := l_attribute7;
               l_rcpt_rec.dff_attribute8 := l_attribute8;
               l_rcpt_rec.dff_attribute9 := l_attribute9;
               l_rcpt_rec.dff_attribute10 := l_attribute10;
               l_rcpt_rec.dff_attribute11 := l_attribute11;
               l_rcpt_rec.dff_attribute12 := l_attribute12;
               l_rcpt_rec.dff_attribute13 := l_attribute13;
               l_rcpt_rec.dff_attribute14 := l_attribute14;
               l_rcpt_rec.dff_attribute15 := l_attribute15;
               l_rcpt_rec.customer_bank_account_id := NULL;
               -- Included for Customer Bank Account Regression
               l_appl_tbl (0).ar_inv_id := l_ar_inv_id;
               l_appl_tbl (0).con_inv_id := l_cnr_id;
               l_appl_tbl (0).contract_id := l_khr_id;
               l_appl_tbl (0).amount_to_apply := l_inv_tot;
               l_appl_tbl (0).amount_applied_from  := l_amount;
  --akrangan modification for cross currency end


            -- call handle receipts
            okl_receipts_pvt.handle_receipt
                                       (p_api_version          => l_api_version,
                                        p_init_msg_list        => l_init_msg_list,
                                        x_return_status        => l_return_status,
                                        x_msg_count            => l_msg_count,
                                        x_msg_data             => l_msg_data,
                                        p_rcpt_rec             => l_rcpt_rec,
                                        p_appl_tbl             => l_appl_tbl,
                                        x_cash_receipt_id      => l_cash_receipt_id
                                       );

            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
               /*           okc_api.set_message (p_app_name          => g_app_name,
                p_msg_name          => 'OKL_BPD_CASH_APP_FAIL',
                p_token1            => 'CUSTOMER_NUM',
                p_token1_value      => l_cust_num,
                p_token2            => 'CONS_BILL_NUM',
                p_token2_value      => l_cnr_id,
                p_token3            => 'CONTRACT_NUM',
                p_token3_value      => l_khr_id
               );*/
               l_error := 'E';
               EXIT;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
               /*               okc_api.set_message (p_app_name          => g_app_name,
                p_msg_name          => 'OKL_BPD_CASH_APP_FAIL',
                p_token1            => 'CUSTOMER_NUM',
                p_token1_value      => l_cust_num,
                p_token2            => 'CONS_BILL_NUM',
                p_token2_value      => l_cnr_id,
                p_token3            => 'CONTRACT_NUM',
                p_token3_value      => l_khr_id
               );*/
               l_error := 'E';
               EXIT;
            END IF;

            -- enter into log file that cash app was sucessful for this customer/contract/cons bill
            /*   okc_api.set_message (p_app_name          => g_app_name,
             p_msg_name          => 'OKL_BPD_CASH_APP_SUCC',
             p_token1            => 'CUSTOMER_NUM',
             p_token1_value      => l_cust_num,
             p_token2            => 'CONS_BILL_NUM',
             p_token2_value      => l_cnr_id,
             p_token3            => 'CONTRACT_NUM',
             p_token3_value      => l_khr_id
            );*/
            EXIT;
         END LOOP;
      END LOOP;

      CLOSE c_get_int_recs;

---------------------------------------
-- End manual receipt creation process .
---------------------------------------
-------------------------------
-- process 'SUBMITTED' batches.
-------------------------------
      OPEN c_get_batches;

      LOOP
         -- loop through batches
         FETCH c_get_batches
          INTO l_btc_id,
               l_currency_conv_type,
               l_currency_conv_rate,
               l_currency_conv_date;

         IF c_get_batches%NOTFOUND THEN
            -- No 'SUBMITTED' batches to process.
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_BPD_NO_BATCH_PRO'
                                );
            EXIT;                                -- exit loop and close cursor
         END IF;

         /*
             IF l_currency_conv_type = 'User' THEN
                 l_currency_conv_type := 'USER';
             ELSIF l_currency_conv_type = 'Spot' THEN
                 l_currency_conv_type := 'SPOT';
             ELSIF l_currency_conv_type = 'Corporate' THEN
                 l_currency_conv_type := 'CORPORATE';
             END IF;

         */
         l_trx_status_code := 'PROCESSED';          -- initialize batch status
         l_return_status := 'S';

         process_batch(p_batch_id => l_btc_id,
                       px_error_tbl => l_error_tbl,
                       x_trx_status_code => l_trx_status_code,
                       x_return_status => l_return_status);
         --Step 1
         --delete all old messages
         l_old_error_tbl.DELETE;

         OPEN c_get_previous_errors (l_btc_id);

         FETCH c_get_previous_errors
         BULK COLLECT INTO l_old_error_tbl;

         CLOSE c_get_previous_errors;

         IF l_old_error_tbl.COUNT > 0 THEN
            -- Call the TAPI to delete all the old errored values
            okl_vlr_pvt.delete_row (p_api_version        => l_api_version,
                                    p_init_msg_list      => l_init_msg_list,
                                    x_return_status      => l_return_status,
                                    x_msg_count          => l_msg_count,
                                    x_msg_data           => l_msg_data,
                                    p_vlrv_tbl           => l_old_error_tbl
                                   );

            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;

         l_btcv_rec.ID := l_btc_id;
         l_btcv_rec.trx_status_code := l_trx_status_code;
         okl_trx_csh_batch_pub.update_trx_csh_batch (l_api_version,
                                                     l_init_msg_list,
                                                     l_return_status,
                                                     l_msg_count,
                                                     l_msg_data,
                                                     l_btcv_rec,
                                                     x_btcv_rec
                                                    );

         IF l_error_tbl.COUNT > 0 THEN
           i := l_error_tbl.LAST;
         END IF;
         IF    (l_return_status = okl_api.g_ret_sts_unexp_error)
            OR (l_return_status = okl_api.g_ret_sts_error) THEN
            IF (fnd_msg_pub.count_msg > 0) THEN
               FOR l_counter IN 1 .. fnd_msg_pub.count_msg
               LOOP
                  i := i + 1;
                  l_error_tbl (i).parent_object_code       /* RECEIPT_BATCH*/
                                                    := 'RECEIPT_BATCH';
                  l_error_tbl (i).parent_object_id              /* BATCH_ID*/
                                                  := l_btc_id;
                  l_error_tbl (i).validation_id               /* RECEIPT_ID*/
                                               := l_rct_id;
                  l_error_tbl (i).result_code                     /* ERROR */
                                             := 'ERROR';
                  fnd_msg_pub.get (p_msg_index          => l_counter,
                                   p_encoded            => 'F',
                                   p_data               => l_error_tbl (i).validation_text,
                                   p_msg_index_out      => l_msg_index_out
                                  );
               END LOOP;
            END IF;
         END IF;
         COMMIT;
      --  update batch status ...
      END LOOP;                                         -- end looping batches

      CLOSE c_get_batches;

--------------------------------------
-- End processing 'SUBMITTED' batches.
--------------------------------------

      -- While we're here, clear up delinquent batch's i.e. batch's without receipt headers/lines ...
      OPEN c_get_redund_batch;

      LOOP
         FETCH c_get_redund_batch
          INTO l_btc_id, l_btc_name;

         IF c_get_redund_batch%NOTFOUND THEN
            -- No delinquent batches to delete.
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_BPD_NO_BATCH_DEL'
                                );
            EXIT;                                -- exit loop and close cursor
         END IF;

         l_btcv_rec.ID := l_btc_id;
         okl_trx_csh_batch_pub.delete_trx_csh_batch (l_api_version,
                                                     l_init_msg_list,
                                                     l_return_status,
                                                     l_msg_count,
                                                     l_msg_data,
                                                     l_btcv_rec
                                                    );

         IF    (l_return_status = okl_api.g_ret_sts_unexp_error)
            OR (l_return_status = okl_api.g_ret_sts_error) THEN
            -- problems deleting delinquent batches.
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_BPD_BATCH_FAIL_DEL',
                                 p_token1            => 'BATCH_NAME',
                                 p_token1_value      => l_btcv_rec.NAME
                                );
            l_error := 'E';
         ELSE
            -- delinquent batch deleted sucessfully.
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_BPD_BATCH_SUCC',
                                 p_token1            => 'BATCH_NAME',
                                 p_token1_value      => l_btcv_rec.NAME
                                );
         END IF;
      END LOOP;

      CLOSE c_get_redund_batch;

      --populate all the stacked messages into the table
      IF l_error_tbl.COUNT > 0 THEN
         populate_error_messages (p_api_version        => l_api_version,
                                  p_init_msg_list      => l_init_msg_list,
                                  p_error_tbl          => l_error_tbl,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data
                                 );
      END IF;

      IF l_error = 'E' THEN
         okc_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_CONTRACTS_UNEXPECTED_ERROR'
                             );
      ELSE
         okc_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_CONFIRM_PROCESS'
                             );
      END IF;

      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := okl_api.g_ret_sts_unexp_error;
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;
   END int_ext_csh_app;
END okl_int_ext_csh_app_pvt;

/
