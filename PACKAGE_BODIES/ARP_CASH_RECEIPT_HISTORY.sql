--------------------------------------------------------
--  DDL for Package Body ARP_CASH_RECEIPT_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CASH_RECEIPT_HISTORY" AS
/* $Header: ARPLCRHB.pls 120.2 2005/06/14 18:47:37 vcrisost ship $ */

--
    FUNCTION GetCurrentId( p_CashReceiptId IN NUMBER ) RETURN NUMBER IS
        l_CashReceiptHistoryId   NUMBER(15);
    BEGIN
        SELECT  cash_receipt_history_id
        INTO    l_CashReceiptHistoryId
        FROM    ar_cash_receipt_history
        WHERE   cash_receipt_id      = p_CashReceiptId
        AND     current_record_flag  = 'Y';
--
        RETURN l_CashReceiptHistoryId;
    EXCEPTION
-- handle NO_DATA_FOUND explicitly, because of bug 169136
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR( -20000, 'Create Cash Receipt History Record before Application - consult support' );
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_receipt_history.GetCurrentId' );
            arp_standard.debug( 'l_CashReceiptHistoryId:'||l_CashReceiptHistoryId );
            RAISE;
    END;
--
    FUNCTION InsertRecord(amount                        NUMBER,
                           acctd_amount                  NUMBER,
                           cash_receipt_id               NUMBER,
                           factor_flag                   VARCHAR2,
                           first_posted_record_flag      VARCHAR2,
                           gl_date                       DATE,
                           postable_flag                 VARCHAR2,
                           status                        VARCHAR2,
                           trx_date                      DATE,
                           acctd_factor_discount_amount  NUMBER,
                           account_code_combination_id   NUMBER,
                           bank_charge_account_ccid      NUMBER,
                           batch_id                      NUMBER,
                           current_record_flag           VARCHAR2,
                           exchange_date                 DATE,
                           exchange_rate                 NUMBER,
                           exchange_rate_type            VARCHAR2,
                           factor_discount_amount        NUMBER,
                           gl_posted_date                DATE,
                           posting_control_id            NUMBER,
                           reversal_cash_rec_hist_id     NUMBER,
                           reversal_gl_date              DATE,
                           reversal_gl_posted_date       DATE,
                           reversal_posting_control_id   NUMBER,
                           request_id                    NUMBER,
                           program_application_id        NUMBER,
                           program_id                    NUMBER,
                           program_update_date           DATE,
                           created_by                    NUMBER,
                           creation_date                 DATE,
                           last_updated_by               NUMBER,
                           last_update_date              DATE,
                           last_update_login             NUMBER,
                           prv_stat_cash_rec_hist_id     NUMBER,
                           created_from                  VARCHAR2,
                           reversal_created_from         VARCHAR2)  RETURN NUMBER IS

        CURSOR get_crh_id IS
        SELECT  ar_cash_receipt_history_s.NEXTVAL
        FROM    dual;
--
        crh_id    ar_cash_receipt_history.cash_receipt_history_id%TYPE;
--
    BEGIN

    /*---------------------------------*
     | Get the Cash Receipt History Id |
     *---------------------------------*/
--
        OPEN get_crh_id;
        FETCH get_crh_id
        INTO  crh_id;
        CLOSE get_crh_id;
--
    /*-----------------------*
     | Insert the new record |
     *-----------------------*/
--
        INSERT INTO AR_CASH_RECEIPT_HISTORY(CASH_RECEIPT_HISTORY_ID,
                                        AMOUNT,
                                        ACCTD_AMOUNT,
                                        CASH_RECEIPT_ID,
                                        FACTOR_FLAG,
                                        FIRST_POSTED_RECORD_FLAG,
                                        GL_DATE,
                                        POSTABLE_FLAG,
                                        STATUS,
                                        TRX_DATE,
                                        ACCTD_FACTOR_DISCOUNT_AMOUNT,
                                        ACCOUNT_CODE_COMBINATION_ID,
                                        BANK_CHARGE_ACCOUNT_CCID,
                                        BATCH_ID,
                                        CURRENT_RECORD_FLAG,
                                        EXCHANGE_DATE,
                                        EXCHANGE_RATE,
                                        EXCHANGE_RATE_TYPE,
                                        FACTOR_DISCOUNT_AMOUNT,
                                        GL_POSTED_DATE,
                                        POSTING_CONTROL_ID,
                                        REVERSAL_CASH_RECEIPT_HIST_ID,
                                        REVERSAL_GL_DATE,
                                        REVERSAL_GL_POSTED_DATE,
                                        REVERSAL_POSTING_CONTROL_ID,
                                        REQUEST_ID,
                                        PROGRAM_APPLICATION_ID,
                                        PROGRAM_ID,
                                        PROGRAM_UPDATE_DATE,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATE_LOGIN,
                                        PRV_STAT_CASH_RECEIPT_HIST_ID,
                                        CREATED_FROM,
                                        REVERSAL_CREATED_FROM,
                                        ORG_ID)
        VALUES(crh_id,
           amount,
           acctd_amount,
           cash_receipt_id,
           factor_flag,
           first_posted_record_flag,
           gl_date,
           postable_flag,
           status,
           trx_date,
           acctd_factor_discount_amount,
           account_code_combination_id,
           bank_charge_account_ccid,
           batch_id,
           current_record_flag,
           exchange_date,
           exchange_rate,
           exchange_rate_type,
           factor_discount_amount,
           gl_posted_date,
           posting_control_id,
           reversal_cash_rec_hist_id,
           reversal_gl_date,
           reversal_gl_posted_date,
           reversal_posting_control_id,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           prv_stat_cash_rec_hist_id,
           created_from,
           reversal_created_from,
           arp_standard.sysparm.org_id);

       /*-------------------------------------------+
        | Call central MRC library for insertion    |
        | into MRC tables                           |
        +-------------------------------------------*/

        ar_mrc_engine.maintain_mrc_data(
                     p_event_mode         => 'INSERT',
                     p_table_name         => 'AR_CASH_RECEIPT_HISTORY',
                     p_mode               => 'SINGLE',
                     p_key_value          => crh_id);


        RETURN(crh_id);
--
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_receipt_history.InsertRecord' );
            arp_standard.debug( 'crh_id:'||crh_id );
            RAISE;
    END;
--
--
--
    PROCEDURE Reverse(p_reversal_cash_rec_hist_id     NUMBER,
                      p_reversal_gl_date              DATE,
                      p_cash_receipt_history_id       NUMBER,
		      p_last_updated_by	  	      NUMBER,
		      p_last_update_date	      DATE,
	              p_last_update_login             NUMBER) IS
    BEGIN
        UPDATE  ar_cash_receipt_history
        SET     current_record_flag            = '',
                reversal_cash_receipt_hist_id  = p_reversal_cash_rec_hist_id,
                reversal_posting_control_id    = -3,
                reversal_gl_date               = p_reversal_gl_date,
                reversal_created_from          = 'RATE ADJUSTMENT TRIGGER',
		last_updated_by = p_last_updated_by,
		last_update_date = p_last_update_date,
		last_update_login = p_last_update_login
        WHERE   cash_receipt_history_id        = p_cash_receipt_history_id;

   /*----------------------------------------------------+
    |  Call central MRC library for the generic update   |
    |  made above.                                       |
    +----------------------------------------------------*/

    ar_mrc_engine.maintain_mrc_data(
                  p_event_mode       => 'UPDATE',
                  p_table_name       => 'AR_CASH_RECEIPT_HISTORY',
                  p_mode             => 'SINGLE',
                  p_key_value        => p_cash_receipt_history_id
                                   );


    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_receipt_history.Reverse' );
            RAISE;
    END;
--
--
    PROCEDURE UpdateAcctdFactor (cr_id         NUMBER,
                                acctd_fd_amt  NUMBER) IS

   l_rec_hist_key_value_list  gl_ca_utility_pkg.r_key_value_arr;


    BEGIN
        UPDATE  ar_cash_receipt_history
        SET     acctd_factor_discount_amount = acctd_fd_amt
        WHERE   cash_receipt_id              = cr_id
        AND     current_record_flag          = 'Y'
        RETURNING cash_receipt_history_id
        BULK COLLECT INTO l_rec_hist_key_value_list;

            /*---------------------------------+
            | Calling central MRC library     |
            | for MRC Integration             |
            +---------------------------------*/

            ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'UPDATE',
                        p_table_name        => 'AR_CASH_RECEIPT_HISTORY',
                        p_mode              => 'BULK',
                        p_key_value_list    => l_rec_hist_key_value_list);



    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_receipt_history.UpdateAcctdFactor' );
            RAISE;
    END;
--
--
--
    PROCEDURE UpdateAcctdAmount (cr_id         NUMBER,
                                 acctd_amt     NUMBER) IS

    l_rec_hist_key_value_list  gl_ca_utility_pkg.r_key_value_arr;

    BEGIN
        UPDATE  ar_cash_receipt_history
        SET     acctd_amount         = acctd_amt
        WHERE   cash_receipt_id      = cr_id
        AND     current_record_flag  = 'Y'
        RETURNING cash_receipt_history_id
        BULK COLLECT INTO l_rec_hist_key_value_list;

            /*---------------------------------+
            | Calling central MRC library     |
            | for MRC Integration             |
            +---------------------------------*/

            ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'UPDATE',
                        p_table_name        => 'AR_CASH_RECEIPT_HISTORY',
                        p_mode              => 'BULK',
                        p_key_value_list    => l_rec_hist_key_value_list);



    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_cash_receipt_history.UpdateAcctdAmount' );
            RAISE;
    END;
--
END ARP_CASH_RECEIPT_HISTORY;

/
