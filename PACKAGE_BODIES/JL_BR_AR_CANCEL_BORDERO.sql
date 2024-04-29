--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_CANCEL_BORDERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_CANCEL_BORDERO" AS
/*$Header: jlbrrcab.pls 120.4.12010000.2 2009/02/27 14:17:39 gkumares ship $*/

PROCEDURE cancel_bordero (
        param_select_control                IN        number,
        param_bordero_id                IN        number,
        param_bordero_status                IN        varchar2,
        param_select_account_id                IN        number,
        param_option                        IN        varchar2,
        param_date                        IN        date,
        param_exit                        OUT NOCOPY         number)
IS
var_document_status       VARCHAR2(30);
var_selection_status      VARCHAR2(30);
var_bordero_action        VARCHAR2(1);
var_status                VARCHAR2(30);
var_previous_status       VARCHAR2(30);
var_bordero_status        VARCHAR2(30);
var_bordero_status_chk    VARCHAR2(30);
var_selection_control_chk NUMBER;
flag                      NUMBER(1);
var_cancel_date           DATE;
var_payment_schedule      NUMBER(15);
var_document_id           NUMBER(38);
var_gl_date               DATE;
var_occurrence_id         NUMBER(38);
var_gl_date_cancel        DATE;
var_flag_post_gl          VARCHAR2(1);
var_bordero_type          VARCHAR2(30);
var_event_type_code   VARCHAR2(30);  -- SLA Uptake - Bug#4301543
var_occurrence_type   VARCHAR2(30);  -- SLA Uptake - Bug#4301543
var_occurrence_code   NUMBER(2);     -- SLA Uptake - Bug#4301543
var_cancel_event_id   NUMBER;        -- SLA Uptake - Bug#4301543
var_cash_receipt_id       NUMBER(15);
l_return_status           VARCHAR2(30);
l_msg_count               NUMBER(15);
l_msg_data                VARCHAR2(100);

        /* Cursor c1 - This cursor is used to check the bordero status */
        /*                of all borderos with the same select account id  */
        /*                and selection control id                        */
        /* Cursor c3 - This cursor is used to change the document status */
        /*                previous_doc_status, and cancellation date        */
        /*                of all documents from the same bordero that is        */
        /*                being canceled, since this document was not        */
        /*                canceled yet.                                        */
        /* Cursor c4 - This cursor is used to remittance occurrences from */
        /*                all documents of one bordero.                           */

        CURSOR  check1 IS
                SELECT  bordero_status,
                        bordero_type
                FROM    jl_br_ar_borderos
                WHERE   bordero_id = param_bordero_id
                        AND bordero_status in ('SELECTED', 'FORMATTED')
                FOR UPDATE NOWAIT;

        CURSOR  check2 IS
                SELECT  selection_control_id
                FROM    jl_br_ar_select_controls
                WHERE   selection_control_id = param_select_control
                FOR UPDATE NOWAIT;

        CURSOR        c1 IS
                SELECT        bordero_status
                FROM        jl_br_ar_borderos
                WHERE         selection_control_id = param_select_control
                AND        select_account_id = param_select_account_id;
        CURSOR        c3 IS
                SELECT        document_status,
                        payment_schedule_id,
                        document_id
                FROM        jl_br_ar_collection_docs
                WHERE        bordero_id = param_bordero_id
                AND        document_status <> 'CANCELED';
        CURSOR        c4 IS
                SELECT        gl_date,
                        occurrence_id,
                        gl_cancel_date,
                        flag_post_gl,
                        bank_occurrence_type,     -- SLA Uptake - Bug#4301543
                        bank_occurrence_code      -- SLA Uptake - Bug#4301543
                FROM        jl_br_ar_occurrence_docs
                WHERE        document_id = var_document_id
                AND        bank_occurrence_type = 'REMITTANCE_OCCURRENCE'
                AND        occurrence_status <> 'CANCELED';
BEGIN
  flag := 0;
  var_selection_status := 'CANCELED';
  param_exit := 0;

  OPEN check1;
  LOOP
    FETCH check1 INTO var_bordero_status_chk,var_bordero_type;
    EXIT WHEN check1%NOTFOUND;

    IF param_option = 'Reverse Bordero' AND
         var_bordero_status_chk <> 'FORMATTED' THEN
          param_exit := -1;
          EXIT;
    END IF;

    OPEN check2;
    LOOP
      FETCH check2 INTO var_selection_control_chk;
      EXIT WHEN check2%NOTFOUND;

        /* Reverse Bordero status to SELECTED        */
        IF        param_option = 'Reverse Bordero'        THEN
                var_document_status := 'SELECTED';
                var_bordero_action := 'Y';
                var_status := 'SELECTED';
                var_cancel_date := NULL;
        /* Change Bordero status to CANCELED        */
        ELSIF        param_option = 'Cancel Bordero'        THEN
                        var_document_status := 'CANCELED';
                        var_bordero_action := NULL;
                        var_status := 'CANCELED';
                        var_cancel_date := sysdate;
        END        IF;

        UPDATE        jl_br_ar_borderos SET
        bordero_status = var_status,
        cancellation_date = var_cancel_date
        WHERE        bordero_id = param_bordero_id;
        --commit;

        OPEN        c3;
        LOOP
                FETCH c3 INTO var_previous_status, var_payment_schedule,var_document_id;
                EXIT WHEN c3%NOTFOUND;

          IF var_bordero_type = 'FACTORING' THEN

           Ar_receipt_api_pub.reverse(
             p_api_version => 1.0,
             p_init_msg_list => FND_API.G_FALSE,
             x_return_status => l_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data,
             p_cash_receipt_id => var_cash_receipt_id,
             p_reversal_category_code => 'REV',
             p_reversal_category_name => 'Reverse Payment',
             p_reversal_gl_date => sysdate,
             p_reversal_date => sysdate,
             p_called_from => 'Factoring'
             );

          END IF;

                UPDATE        jl_br_ar_collection_docs SET
                previous_doc_status = var_previous_status,
                document_status = var_document_status,
                cancellation_date = var_cancel_date
                WHERE        bordero_id = param_bordero_id
                AND        payment_schedule_id = var_payment_schedule
                AND        document_id = var_document_id;

                IF        var_bordero_action = 'Y' THEN
                        UPDATE        AR_PAYMENT_SCHEDULES        SET
                        global_attribute11 = 'N'
                        WHERE payment_schedule_id = var_payment_schedule;
                ELSE
                        UPDATE        AR_PAYMENT_SCHEDULES        SET
                        selected_for_receipt_batch_id = NULL,
                        global_attribute11 = 'N'
                        WHERE payment_schedule_id = var_payment_schedule;
                END IF;

                IF        param_bordero_status = 'FORMATTED'        THEN
                        OPEN        c4;
                        LOOP
                                FETCH c4 INTO var_gl_date,
                                                var_occurrence_id,
                                                var_gl_date_cancel,
                                                var_flag_post_gl,
                                                var_occurrence_type,     -- SLA Uptake - Bug#4301543
                                                var_occurrence_code;     -- SLA Uptake - Bug#4301543

                                EXIT WHEN c4%NOTFOUND;
                                var_gl_date_cancel := param_date;
                                IF var_flag_post_gl = 'Y' THEN
                                        var_flag_post_gl := 'N';
                                        var_gl_date := param_date;
                                END IF;

                                -- SLA Uptake - Bug#4301543
                                if var_bordero_type = 'FACTORING' then
                                   var_event_type_code := 'CANCEL_FACT_DOC';
                                else
                                   var_event_type_code := 'CANCEL_COLL_DOC';
                                end if;
                                JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists (
                                      p_event_type_code       => var_event_type_code            ,
                                      p_event_date            => NVL(var_cancel_date,SYSDATE)   ,
                                      p_document_id           => var_document_id                ,
                                      p_gl_date               => var_gl_date                    ,
                                      p_occurrence_id         => var_occurrence_id              ,
                                      p_bank_occurrence_type  => var_occurrence_type            ,
                                      p_bank_occurrence_code  => var_occurrence_code            ,
                                      p_std_occurrence_code   => 'REMITTANCE'                   ,
                                      p_bordero_type          => var_bordero_type               ,
                                      p_endorsement_amt       => NULL                           ,
                                      p_bank_charges_amt      => NULL                           ,
                                      p_factoring_charges_amt => NULL                           ,
                                      p_event_id              => var_cancel_event_id
                                      );

                                -- End SLA Uptake - Bug#4301543

                                UPDATE jl_br_ar_occurrence_docs SET
                                occurrence_status= 'CANCELED',
                                gl_date                = var_gl_date,
                                gl_cancel_date        = var_gl_date_cancel,
                                flag_post_gl        = var_flag_post_gl,
                                cancel_event_id   = var_cancel_event_id   -- SLA Uptake - Bug#4301543
                                WHERE document_id = var_document_id
                                AND occurrence_id = var_occurrence_id;
                                --commit;
                        END        LOOP;
                        CLOSE        c4;
                END IF;
                --commit;
        END        LOOP;
        CLOSE        c3;

        var_cancel_date := sysdate;

        OPEN        c1;
        LOOP
                FETCH c1 INTO var_bordero_status;
                EXIT WHEN c1%NOTFOUND;

                IF var_bordero_status <> 'CANCELED' THEN
                        IF        var_bordero_status <> 'SELECTED'        THEN
                                flag := 2;
                        ELSE
                                flag := 1;
                                var_selection_status := 'SELECTED';
                                var_cancel_date := NULL;
                        END        IF;
                END IF;
        END LOOP;
        CLOSE c1;

        IF        flag = 0 OR flag = 1        THEN
                UPDATE        jl_br_ar_select_accounts        SET
                cancellation_date = var_cancel_date
                WHERE selection_control_id = param_select_control
                AND select_account_id = param_select_account_id;

                UPDATE        jl_br_ar_select_controls        SET
                selection_status = var_selection_status,
                cancellation_date = var_cancel_date
                WHERE selection_control_id = param_select_control;
        --commit;
        END        IF;

        param_exit := 1;

    END LOOP;
    CLOSE check2;

  END LOOP;
  CLOSE check1;

  commit;

END     cancel_bordero;

END     JL_BR_AR_CANCEL_BORDERO;

/
