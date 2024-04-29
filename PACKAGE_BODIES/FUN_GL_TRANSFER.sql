--------------------------------------------------------
--  DDL for Package Body FUN_GL_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_GL_TRANSFER" AS
/* $Header: FUN_GL_XFER_B.pls 120.13.12010000.4 2009/03/23 10:54:59 makansal ship $ */

FUNCTION get_conversion_type (
    p_conversion_type IN VARCHAR2) RETURN VARCHAR2
IS
    l_user_conversion_type GL_DAILY_CONVERSION_TYPES.USER_CONVERSION_TYPE%TYPE;
BEGIN

    SELECT USER_CONVERSION_TYPE
    INTO l_user_conversion_type
    from GL_DAILY_CONVERSION_TYPES
    where conversion_type = p_conversion_type;

    return l_user_conversion_type;
END get_conversion_type;

/*-----------------------------------------------------
 * FUNCTION lock_and_transfer
 * ----------------------------------------------------
 * Acquires lock and transfer.
 * ---------------------------------------------------*/

FUNCTION lock_and_transfer (
    p_trx_id        IN number,
    p_ledger_id     IN number,
    p_gl_date       IN date,
    p_currency      IN varchar2,
    p_category      IN varchar2,
    p_source        IN varchar2,
    p_desc          IN varchar2,
    p_conv_date     IN date,
    p_conv_type     IN varchar2,
    p_party_type    IN varchar2,
    p_user_env_lang IN varchar2) RETURN boolean
IS
    l_status        varchar2(15);
    l_desc          varchar2(240);
    l_batch_number  varchar2(50);
    l_batch_id      number(15,0);
BEGIN
    IF (NOT lock_transaction(p_trx_id, p_party_type)) THEN
        RETURN FALSE;
    ELSE
        SELECT status, description, batch_id
        INTO l_status, l_desc, l_batch_id
        FROM fun_trx_headers
        WHERE trx_id = p_trx_id;

-- Added so logic to get batch number required as reference4 in gl_interface

        select batch_number
        INTO l_batch_number
        from fun_trx_batches
        Where batch_id = l_batch_id;

        transfer_single(l_batch_number,p_trx_id, p_ledger_id, p_gl_date, p_currency,
                        p_category, p_source, nvl(l_desc, p_desc), p_conv_date,
                        p_conv_type, p_party_type, p_user_env_lang);

        l_status := update_status(p_trx_id, l_status, p_party_type);
    END IF;

    RETURN TRUE;
END lock_and_transfer;



/*-----------------------------------------------------
 * FUNCTION lock_transaction
 * ----------------------------------------------------
 * Lock the transaction.
 * If p_status is not null, test if it's valid still.
 * ---------------------------------------------------*/

FUNCTION lock_transaction (
    p_trx_id        IN number,
    p_party_type    IN varchar2) RETURN boolean
IS
    l_status    varchar2(15);
BEGIN
    SELECT status INTO l_status
    FROM fun_trx_headers
    WHERE trx_id = p_trx_id
    FOR UPDATE;

    IF (l_status = 'APPROVED' OR
        (p_party_type = 'I' AND l_status = 'XFER_RECI_GL') OR
        (p_party_type = 'R' AND l_status = 'XFER_INI_GL')) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END lock_transaction;



/*-----------------------------------------------------
 * FUNCTION has_conversion_rate
 * ----------------------------------------------------
 * Is there a conversion rate between the two
 * currencies?
 * ---------------------------------------------------*/

FUNCTION has_conversion_rate (
    p_from_currency IN varchar2,
    p_to_currency   IN varchar2,
    p_exchange_type IN varchar2,
    p_exchange_date IN date) RETURN number
IS
    l_rate  number;
BEGIN
    IF (p_from_currency = p_to_currency) THEN
        RETURN 1;
    END IF;

/*REPLACED BY GL_CURRENCY_API
    SELECT COUNT(conversion_rate) INTO l_has_rate
    FROM gl_daily_rates
    WHERE from_currency = p_from_currency AND
          to_currency = p_to_currency AND
          conversion_type = p_exchange_type AND
          conversion_date = p_exchange_date;

    IF (l_has_rate = 0) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
*/
   l_rate := GL_CURRENCY_API.Get_Rate_Sql(p_from_currency, p_to_currency,
                                          p_exchange_date, p_exchange_type);

   return l_rate;

END has_conversion_rate;



/*-----------------------------------------------------
 * FUNCTION get_period_status
 * ----------------------------------------------------
 * Returns the period closing status.
 * ---------------------------------------------------*/

FUNCTION get_period_status (
    p_app_id        IN number,
    p_date          IN date,
    p_ledger_id     IN number) RETURN varchar2
IS
    l_status    varchar2(1);
BEGIN
    /*SELECT ps.closing_status
    INTO l_status
    FROM gl_periods p,
         gl_ledgers l,
         gl_period_statuses ps
    WHERE l.ledger_id = p_ledger_id AND
          p.period_set_name = l.period_set_name AND
          p_date BETWEEN p.start_date AND p.end_date AND
          ps.period_name = p.period_name AND
          ps.application_id = p_app_id AND
          ps.set_of_books_id = l.ledger_id;*/

	/* Bug 6707980 added ps.adjustment_period_flag = 'N' where claus */

    SELECT ps.closing_status
    INTO l_status
    FROM gl_period_statuses ps
    WHERE ps.ledger_id = p_ledger_id AND
          p_date BETWEEN ps.start_date AND ps.end_date AND
          ps.application_id = p_app_id AND
	  ps.adjustment_period_flag = 'N';

    RETURN l_status;
END get_period_status;



/*-----------------------------------------------------
 * FUNCTION update_status
 * ----------------------------------------------------
 * Returns the new status.
 * ---------------------------------------------------*/

FUNCTION update_status (
    p_trx_id        IN number,
    p_status        IN varchar2,
    p_party_type    IN varchar2) RETURN varchar2
IS
    l_result        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
BEGIN
    IF (p_status = 'APPROVED' AND p_party_type = 'R') THEN
        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_result,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => p_trx_id,
                         p_update_status_to => 'XFER_RECI_GL');
        RETURN 'XFER_RECI_GL';
    ELSIF (p_status = 'APPROVED' AND p_party_type = 'I') THEN
        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_result,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => p_trx_id,
                         p_update_status_to => 'XFER_INI_GL');
       RETURN 'XFER_INI_GL';
    ELSIF (p_status = 'XFER_INI_GL') THEN
       fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_result,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => p_trx_id,
                         p_update_status_to => 'COMPLETE');
        RETURN 'COMPLETE';
    ELSIF (p_status = 'XFER_RECI_GL') THEN
       fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_result,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => p_trx_id,
                         p_update_status_to => 'COMPLETE');
        RETURN 'COMPLETE';
    ELSE
        RAISE corrupted_transaction_status;
    END IF;
END update_status;




/*-----------------------------------------------------
 * PROCEDURE transfer_single
 * ----------------------------------------------------
 * Transfer a single transaction to GL interface.
 * It assumes that the caller has a lock on the
 * transaction, and will do the commit.
 * ---------------------------------------------------*/

PROCEDURE transfer_single (
    p_batch_number  IN varchar2,
    p_trx_id        IN number,
    p_ledger_id     IN number,
    p_gl_date       IN date,
    p_currency      IN varchar2,
    p_category      IN varchar2,
    p_source        IN varchar2,
    p_desc          IN varchar2,
    p_conv_date     IN date,
    p_conv_type     IN varchar2,
    p_party_type    IN varchar2,
    p_user_env_lang IN varchar2)
IS
    l_amount_cr     number;
    l_amount_dr     number;
    l_ccid          number;
    l_created_by    number;
    l_line_id       number;
    l_desc          varchar2(240);
    l_batch_id      number;
    l_trx_id        number;
    l_dist_id       number;
    l_parameter_list WF_PARAMETER_LIST_T :=wf_parameter_list_t();
    l_event_key    VARCHAR2(240);
    l_initdate     date;
    l_trans_source gl_je_sources_tl.user_je_source_name%TYPE;
    l_trans_category gl_je_categories_tl.user_je_category_name%TYPE;


    CURSOR c_dist IS
        SELECT d.amount_cr, d.amount_dr, d.ccid,
               d.created_by, d.line_id, d.description,
               h.batch_id,
               h.trx_id,
               d.dist_id
        FROM fun_dist_lines d,
             fun_trx_lines t,
             fun_trx_headers h
        WHERE t.trx_id = p_trx_id AND
              d.line_id = t.line_id AND
              h.trx_id  = t.trx_id  AND
              d.party_type_flag = p_party_type;
BEGIN
     WF_EVENT.AddParameterToList(p_name=>'TRX_ID',
                                            p_value=>TO_CHAR(p_trx_id),
                                            p_parameterlist =>l_parameter_list
                        );
     select sysdate into l_initdate from dual;

    WF_EVENT.AddParameterToList(p_name=>'INIT_SYS_DATE',
                                             p_value=>TO_CHAR(l_initdate),
                                             p_parameterlist=>l_parameter_list
                         );

 WF_EVENT.AddParameterToList(p_name=>'TRX_TYPE',
                                             p_value=>'Intercompany Transaction',
                                             p_parameterlist=>l_parameter_list
                         );

/* made changes for 7350856 */
 select user_je_source_name into l_trans_source from gl_je_sources_tl where
je_source_name = p_source and language = p_user_env_lang;

select user_je_category_name into l_trans_category from gl_je_categories_tl  where
je_category_name = p_category and language = p_user_env_lang;
/* changes for 7350856 ends */

    OPEN c_dist;

    LOOP
        FETCH c_dist INTO l_amount_cr, l_amount_dr, l_ccid,
                          l_created_by, l_line_id, l_desc,
                          l_batch_id,   l_trx_id, l_dist_id;
        EXIT WHEN c_dist%NOTFOUND;

        INSERT INTO gl_interface
            (status, set_of_books_id, accounting_date,
            currency_code, date_created, created_by,
            actual_flag, user_je_category_name, user_je_source_name,
            currency_conversion_date, user_currency_conversion_type, entered_dr,
            entered_cr, reference10,reference4,
            code_combination_id, group_id,ledger_id,
            reference21, reference22, reference23, reference24, reference25)
        VALUES
            ('NEW', p_ledger_id, p_gl_date,
            p_currency, SYSDATE, l_created_by,
            'A', l_trans_category, l_trans_source,
            p_conv_date, FUN_GL_TRANSFER.GET_CONVERSION_TYPE(p_conv_type), l_amount_dr,
            l_amount_cr, nvl(l_desc,p_desc),p_batch_number,
            l_ccid, p_ledger_id ,p_ledger_id,
            'Intercompany Transaction',
            l_batch_id,
            l_trx_id,
            l_line_id,
            l_dist_id
            );
    END LOOP;

    l_event_key:=FUN_INITIATOR_WF_PKG.GENERATE_KEY(p_batch_id=>l_batch_id,
                                                   p_trx_id =>p_trx_id);

    WF_EVENT.RAISE(p_event_name =>'oracle.apps.fun.single.gl.transfer',
                                              p_event_key  =>l_event_key,
                                              p_parameters =>l_parameter_list);
    l_parameter_list.delete();


END transfer_single;



PROCEDURE transfer_batch (
    p_request_id    IN number,
    p_source        IN varchar2,
    p_category      IN varchar2,
    p_date_low      IN date DEFAULT NULL,
    p_date_high     IN date DEFAULT NULL,
    p_ledger_low    IN varchar2 DEFAULT NULL,
    p_ledger_high   IN varchar2 DEFAULT NULL,
    p_le_low        IN varchar2 DEFAULT NULL,
    p_le_high       IN varchar2 DEFAULT NULL,
    p_ic_org_low    IN varchar2 DEFAULT NULL,
    p_ic_org_high   IN varchar2 DEFAULT NULL,
    p_commit_freq   IN number DEFAULT 100)
IS
BEGIN
 --
 -- This procedure is obsolete and should never be called
 -- Batch process has been written as a speperate conc program.

     NULL;

END transfer_batch;

END;

/
