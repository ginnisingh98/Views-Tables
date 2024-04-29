--------------------------------------------------------
--  DDL for Package Body FUN_RECIPIENT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RECIPIENT_WF" AS
/* $Header: FUN_RECI_WF_B.pls 120.54.12010000.18 2010/04/18 11:52:56 abhaktha ship $ */


------------------------- PRIVATE METHODS ------------------------------

/*-----------------------------------------------------
 * PRIVATE FUNCTION generate_event_key
 * ----------------------------------------------------
 * Get the attributes for the recipient WF.
 * ---------------------------------------------------

function generate_event_key (
    batch_id    in number,
    trx_id      in number) return varchar2
is
    l_result    varchar2(64);
begin
    l_result := to_char(batch_id)||'_'||to_char(trx_id)||sys_guid();
    return l_result;
end generate_event_key;
*/


/*-----------------------------------------------------
 * PRIVATE PROCEDURE delete_trx_batch
 * ----------------------------------------------------
 * Lock and delete a transaction. And if that is
 * the last transaction in the batch, then delete the
 * batch too.
 * ---------------------------------------------------*/

PROCEDURE delete_trx_batch (
    p_batch_id    IN number,
    p_trx_id      IN number)
IS
    l_n_trx     number;
BEGIN
    -- Lock batch.
    SELECT batch_id INTO l_n_trx
    FROM fun_trx_batches
    WHERE batch_id = p_batch_id
    FOR UPDATE;

    SELECT COUNT(h.trx_id) INTO l_n_trx
    FROM fun_trx_batches b,
         fun_trx_headers h
    WHERE h.batch_id = b.batch_id AND
          b.batch_id = p_batch_id;

    DELETE FROM fun_dist_lines
    WHERE line_id IN
        ( SELECT line_id
          FROM fun_trx_lines
          WHERE trx_id = p_trx_id );

    DELETE FROM fun_trx_lines
    WHERE trx_id = p_trx_id;

    DELETE FROM fun_trx_headers
    WHERE trx_id = p_trx_id;

    -- Delete batch if I'm last.
    IF(l_n_trx = 1) THEN
        DELETE FROM fun_trx_batches
        WHERE batch_id = p_batch_id;
    END IF;

END delete_trx_batch;


/*-----------------------------------------------------
 * PRIVATE FUNCTION make_batch_rec
 * ----------------------------------------------------
 * Return a batch_rec_type for this batch.
 * ---------------------------------------------------*/

FUNCTION make_batch_rec (
    p_batch_id    IN number) RETURN fun_trx_pvt.batch_rec_type
IS
    l_rec       fun_trx_pvt.batch_rec_type;
BEGIN
    SELECT batch_id, batch_number, initiator_id,
           from_le_id, from_ledger_id, control_total,
           currency_code, exchange_rate_type, status,
           description, trx_type_id, trx_type_code,
           gl_date, batch_date, reject_allow_flag,
           from_recurring_batch_id
    INTO l_rec.batch_id, l_rec.batch_number, l_rec.initiator_id,
         l_rec.from_le_id, l_rec.from_ledger_id, l_rec.control_total,
         l_rec.currency_code, l_rec.exchange_rate_type, l_rec.status,
         l_rec.description, l_rec.trx_type_id, l_rec.trx_type_code,
         l_rec.gl_date, l_rec.batch_date, l_rec.reject_allowed,
         l_rec.from_recurring_batch
    FROM fun_trx_batches
    WHERE batch_id = p_batch_id;

    RETURN l_rec;
END make_batch_rec;



/*-----------------------------------------------------
 * PRIVATE FUNCTION make_trx_rec
 * ----------------------------------------------------
 * Return a trx_rec_type for this trx.
 * ---------------------------------------------------*/

FUNCTION make_trx_rec (
    p_trx_id    IN number) RETURN fun_trx_pvt.trx_rec_type
IS
    l_rec       fun_trx_pvt.trx_rec_type;
BEGIN
    SELECT trx_id, initiator_id, recipient_id,
           to_le_id, to_ledger_id, batch_id,
           status, init_amount_cr, init_amount_dr,
           reci_amount_cr, reci_amount_dr, ar_invoice_number,
           invoice_flag, approver_id, approval_date,
           original_trx_id, reversed_trx_id, from_recurring_trx_id,
           initiator_instance_flag, recipient_instance_flag
    INTO l_rec.trx_id, l_rec.initiator_id, l_rec.recipient_id,
         l_rec.to_le_id, l_rec.to_ledger_id, l_rec.batch_id,
         l_rec.status, l_rec.init_amount_cr, l_rec.init_amount_dr,
         l_rec.reci_amount_cr, l_rec.reci_amount_dr, l_rec.ar_invoice_number,
         l_rec.invoicing_rule, l_rec.approver_id, l_rec.approval_date,
         l_rec.original_trx_id, l_rec.reversed_trx_id, l_rec.from_recurring_trx_id,
         l_rec.initiator_instance, l_rec.recipient_instance
    FROM fun_trx_headers
    WHERE trx_id = p_trx_id;

    RETURN l_rec;
END make_trx_rec;



/*-----------------------------------------------------
 * PRIVATE FUNCTION make_dist_lines_tbl
 * ----------------------------------------------------
 * Return a dist_line_tbl_type for this trx.
 * ---------------------------------------------------*/

FUNCTION make_dist_lines_tbl (
    p_trx_id    IN number) RETURN fun_trx_pvt.dist_line_tbl_type
IS
    l_tbl       fun_trx_pvt.dist_line_tbl_type;
    CURSOR c_dist IS
        SELECT d.dist_id, d.line_id, d.party_id,
               d.party_type_flag, d.dist_type_flag, d.batch_dist_id,
               d.amount_cr, d.amount_dr, d.ccid
        FROM fun_dist_lines d, fun_trx_lines l
        WHERE party_type_flag = 'R' AND
              d.line_id = l.line_id AND
              l.trx_id = p_trx_id;
    i number := 1;
BEGIN
    OPEN c_dist;

    LOOP
        DECLARE
            l_rec fun_trx_pvt.dist_line_rec_type;
        BEGIN
            FETCH c_dist INTO l_rec.dist_id, l_rec.line_id, l_rec.party_id,
                              l_rec.party_type, l_rec.dist_type, l_rec.batch_dist_id,
                              l_rec.amount_cr, l_rec.amount_dr, l_rec.ccid;
            EXIT WHEN c_dist%NOTFOUND;

            --l_tbl(l_rec.dist_id) := l_rec;
            l_tbl(i) := l_rec;
            i := i + 1;
        END;
    END LOOP;

    RETURN l_tbl;
END make_dist_lines_tbl;



------------------------- PUBLIC METHODS ------------------------------

/*-----------------------------------------------------
 * PROCEDURE get_attr
 * ----------------------------------------------------
 * Get the attributes for the recipient WF.
 * ---------------------------------------------------*/

PROCEDURE get_attr (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_trx_id        number;

    l_batch_num     varchar2(20);
    l_trx_num       varchar2(15);
    l_trx_amt       varchar2(20);
    l_initiator_name varchar2(360);
    l_recipient_name varchar2(360);
	l_initiator_person varchar2(360);

BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        fnd_msg_pub.initialize;

        l_batch_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_ID');

--        SELECT batch_number INTO l_batch_num
--        FROM fun_trx_batches
--        WHERE batch_id = l_batch_id;

/*
        SELECT
         b.batch_number,
         ltrim(to_char(decode(nvl(b.running_total_cr,0),
               0, b.running_total_dr,
               b.running_total_cr),'999999999.99'))||' '||b.currency_code,
         h.party_name
        INTO l_batch_num, l_trx_amt, l_initiator_name
        FROM fun_trx_batches b, hz_parties h
        WHERE batch_id = l_batch_id
        AND b.initiator_id = h.party_id;
*/
  -- added to get transaction amount not batch amount

   select b.batch_number,ltrim(to_char(decode(nvl(h.reci_amount_cr,0),
                0,h.reci_amount_dr,
                h.reci_amount_cr),'999999999.99'))||' '||b.currency_code
         into  l_batch_num, l_trx_amt
         from fun_trx_headers h, fun_trx_batches b
         where b.batch_id = l_batch_id
         and h.trx_id = l_trx_id;

 -- to get initiator name

 SELECT init.party_name
        INTO l_initiator_name
        FROM fun_trx_headers,
             hz_parties init
        WHERE trx_id = l_trx_id
        AND    initiator_id = init.party_id;

		-- to get initiator person name
		SELECT p.PARTY_NAME PERSON_NAME
		INTO l_initiator_person
		FROM  hz_parties p,
			fnd_user fu,
			fun_trx_batches b
		WHERE fu.person_party_id = p.party_id
		AND   fu.user_id =   b.created_by
		AND   b.batch_id =  l_batch_id;

        -- Modfied the query below to retrieve the recipient org name
        SELECT trx_number ,
               rec.party_name

        INTO l_trx_num, l_recipient_name
        FROM fun_trx_headers,
             hz_parties rec
        WHERE trx_id = l_trx_id
        AND    recipient_id = rec.party_id;

        UPDATE fun_trx_headers
        SET reci_wf_key = itemkey
        WHERE trx_id = l_trx_id;


        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'BATCH_NUMBER',
                                  avalue => l_batch_num);
        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_NUMBER',
                                  avalue => l_trx_num);
        Begin
          wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_AMT',
                                  avalue => l_trx_amt);
          wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'INITIATOR_NAME',
                                  avalue => l_initiator_name);

          wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'RECIPIENT_NAME',
                                  avalue => l_recipient_name);

		wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => '#FROM_ROLE',
                                  avalue => l_initiator_person);
        Exception
        When others then
             NULL;
        End;

        -- TODO: #FROM_ROLE

        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
          wf_core.context('FUN_RECIPIENT_WF', 'GET_ATTR',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END get_attr;



/*-----------------------------------------------------
 * PROCEDURE validate_trx
 * ----------------------------------------------------
 * Call the Transaction API to validate the trx.
 * ---------------------------------------------------*/

PROCEDURE validate_trx (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_batch_id      number;
    l_status        varchar2(1);
    l_msg_count     number := 0;
    l_msg_data      varchar2(1000);
    l_batch_rec     fun_trx_pvt.batch_rec_type;
    l_trx_rec       fun_trx_pvt.trx_rec_type;
    l_dist_line_tbl fun_trx_pvt.dist_line_tbl_type;
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');

        -- Beware of NO_DATA_FOUND.
        /*l_batch_rec := make_batch_rec(l_batch_id);
        l_trx_rec := make_trx_rec(l_trx_id);
        l_dist_line_tbl := make_dist_lines_tbl(l_trx_id);

        fun_trx_pvt.recipient_validate(
                        1.0, 'T', fnd_api.g_valid_level_full,
                        l_status, l_msg_count, l_msg_data,
                        l_batch_rec, l_trx_rec, l_dist_line_tbl);
        */
        -- TODO
        IF (l_msg_count = 0) THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ERROR',
                         fun_wf_common.concat_msg_stack(fnd_msg_pub.count_msg));
            resultout := wf_engine.eng_completed||':F';
        END IF;

        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'VALIDATE_TRX',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END validate_trx;



/*-----------------------------------------------------
 * PROCEDURE delete_trx
 * ----------------------------------------------------
 * Delete the transaction from the recipient's DB.
 * ---------------------------------------------------*/

PROCEDURE delete_trx (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_batch_id      number;
    l_n_trx_left    number;
BEGIN
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        delete_trx_batch(l_batch_id, l_trx_id);
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'VALIDATE_TRX',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END delete_trx;




/*-----------------------------------------------------
 * PROCEDURE is_gl_batch_mode
 * ----------------------------------------------------
 * Check whether GL transfer is in batch mode.
 * ---------------------------------------------------*/

PROCEDURE is_gl_batch_mode (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_result    boolean;
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_result := fun_system_options_pkg.is_gl_batch();
        IF (l_result) THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            resultout := wf_engine.eng_completed||':F';
        END IF;

        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'IS_GL_BATCH_MODE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END is_gl_batch_mode;


/*-----------------------------------------------------
 * PROCEDURE check_invoice_reqd
 * ----------------------------------------------------
 * Check whether this transaction requires invoice.
 * ---------------------------------------------------*/

PROCEDURE check_invoice_reqd (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id      number;
    l_result      varchar2(1);
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        SELECT invoice_flag INTO l_result
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        IF (l_result = 'Y') THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            resultout := wf_engine.eng_completed||':F';
        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'CHECK_INVOICE_REQD',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END check_invoice_reqd;


/*-----------------------------------------------------
 * PROCEDURE check_approval_result
 * ----------------------------------------------------
 * Check status: APPROVED or REJECTED.
 * ---------------------------------------------------*/

PROCEDURE check_approval_result (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id    number;
    l_status    varchar2(15);
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        SELECT status INTO l_status
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        IF(l_status = 'APPROVED') THEN
            resultout := wf_engine.eng_completed||':APPROVED';
        ELSIF(l_status = 'REJECTED') THEN
            resultout := wf_engine.eng_completed||':REJECTED';
        ELSIF(l_status = 'ERROR') THEN
            resultout := wf_engine.eng_completed||':ERROR';
        ELSE
            resultout := wf_engine.eng_error||':'||wf_engine.eng_null;
        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'check_approval_result',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END check_approval_result;


/*-----------------------------------------------------
 * PROCEDURE is_manual_approval
 * ----------------------------------------------------
 * Check whether this transaction requires manual
 * approval.
 * ---------------------------------------------------*/

PROCEDURE is_manual_approval (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_result        varchar2(1);
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
    e_gen_acct_error EXCEPTION;
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        SELECT t.manual_approve_flag INTO l_result
        FROM fun_trx_batches b, fun_trx_types_b t
        WHERE b.batch_id = l_batch_id AND
              b.trx_type_id = t.trx_type_id;

        IF (l_result = 'Y') THEN
            resultout := wf_engine.eng_completed||':T';

        ELSE

            resultout := wf_engine.eng_completed||':F';
        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
       WHEN e_gen_acct_error THEN
            wf_core.context('FUN_RECIPIENT_WF', 'UPDATE_STATUS_APPROVED',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;

        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'IS_MANUAL_APPROVAL',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END is_manual_approval;


/*-----------------------------------------------------
 * PROCEDURE abort_approval
 * ----------------------------------------------------
 * Abort the accounting and approval process
 * ---------------------------------------------------*/

PROCEDURE abort_approval (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
BEGIN
    IF (funcmode = 'RUN') THEN
        BEGIN
            wf_engine.AbortProcess
                        (itemtype => itemtype,
                         itemkey => itemkey,
                         process => 'ACCOUNTING_AND_APPROVAL');
        --exception
        --    when others then null;
        END;
    END IF;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'ABORT_APPROVAL',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END abort_approval;


/*-----------------------------------------------------
 * PROCEDURE generate_approval_doc
 * ----------------------------------------------------
 * Generate the approval document.
 * ---------------------------------------------------*/

PROCEDURE generate_approval_doc (
    document_id     IN number,
    display_type    IN varchar2,
    document        IN OUT NOCOPY varchar2,
    document_type   IN OUT NOCOPY varchar2)
IS
BEGIN
    NULL;
    -- TODO
END generate_approval_doc;


/*-----------------------------------------------------
 * PROCEDURE is_same_instance
 * ----------------------------------------------------
 * Check whether the initiator and recipient are on the
 * same instance.
 * ---------------------------------------------------*/

PROCEDURE is_same_instance (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id    number;
    l_result    varchar2(1);
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        SELECT initiator_instance_flag  INTO l_result
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        IF (l_result = 'Y') THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            resultout := wf_engine.eng_completed||':F';
        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'IS_SAME_INSTANCE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END is_same_instance;



/*-----------------------------------------------------
 * PROCEDURE get_contact
 * ----------------------------------------------------
 * Get the contact for this party.
 * ---------------------------------------------------*/

PROCEDURE get_contact (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_contact   varchar2(30);
    l_trx_id    number;
    l_party_id  number;
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        SELECT recipient_id INTO l_party_id
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        l_contact := fun_wf_common.get_contact_role(l_party_id);
        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'CONTACT',
                                  avalue => l_contact);
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'GET_CONTACT',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END get_contact;



/*-----------------------------------------------------
 * PROCEDURE check_allow_reject
 * ----------------------------------------------------
 * Check whether this transaction requires manual
 * approval.
 * ---------------------------------------------------*/

PROCEDURE check_allow_reject (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_result        varchar2(1);
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');

        SELECT reject_allow_flag INTO l_result
        FROM fun_trx_batches
        WHERE batch_id = l_batch_id;

        IF (l_result = 'Y') THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            resultout := wf_engine.eng_completed||':F';
        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'CHECK_ALLOW_REJECT',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END check_allow_reject;


/*-----------------------------------------------------
 * PROCEDURE post_approval_ntf
 * ----------------------------------------------------
 * Check whether anyone has already approved or
 * or rejected the transaction.
 * ---------------------------------------------------*/

PROCEDURE post_approval_ntf (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_nid           number;
    l_result        varchar2(30);
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
    l_reason        varchar2(240);
    l_forward_role  wf_roles.name%TYPE;
    l_valid_user    VARCHAR2(1);
    l_due_date      DATE;
    l_priority      NUMBER;
    l_message_name wf_notifications.message_name%TYPE;
    l_message_type wf_notifications.message_type%TYPE;
    l_user_role    wf_notifications.recipient_role%TYPE;
    l_ntf_status   wf_notifications.status%TYPE;

    l_approver_record	ame_util.approverRecord2;
    l_forwardee_record	ame_util.approverRecord2;
    l_user_id           fnd_user.user_id%TYPE;

    CURSOR c_get_userid (p_user_name    VARCHAR2) IS
        SELECT  usr.user_id
        FROM    fnd_user usr
        WHERE   usr.user_name = p_user_name;

BEGIN
    l_nid := wf_engine.context_nid;
    l_result := wf_notification.GetAttrText(l_nid, 'RESULT');
    l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

    IF(funcmode = 'RESPOND') THEN
        l_approver_record.name := wf_engine.context_text;
        IF l_approver_record.name IS NULL
        THEN
            -- This might happen if user has approved the transaction
            -- from the Inbound Transaction UI
            l_approver_record.name := wf_engine.GetItemAttrText
        	   (itemtype  => itemtype,
        	     itemkey  => itemkey,
        	     aname    => 'UI_ACTION_USER_NAME');

            l_user_id := wf_engine.GetItemAttrNumber
			   (itemtype  => itemtype,
			     itemkey  => itemkey,
			     aname    => 'UI_ACTION_USER_ID');

        ELSE
            -- Get the user id for the user name.
            OPEN c_get_userid ( l_approver_record.name);
            FETCH c_get_userid INTO l_user_id;
            CLOSE c_get_userid;
        END IF;

        IF(l_result = 'APPROVE') or (l_result = 'APPROVED') THEN
            l_approver_record.approval_status := AME_UTIL.approvedStatus;

            ame_api2.updateApprovalStatus(
                        applicationIdIn     => 435,
                        transactionTypeIn   => 'FUN_IC_RECI_TRX',
                        transactionIdIn     => l_trx_id,
                        approverIn          => l_approver_record);

           -- Update the approver id onto the fun_trx_headers table.
           -- approver_id will always hold the id of the last person
           -- to approve the transaction.
           UPDATE fun_trx_headers
           SET    approver_id = l_user_id,
	          approval_date = SYSDATE
           WHERE  trx_id = l_trx_id;


        ELSIF (l_result = 'REJECT') or (l_result = 'REJECTED')
        THEN
            l_reason := wf_engine.GetItemAttrText(itemtype, itemkey, 'REASON');

            fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'REJECTED');

            UPDATE fun_trx_headers
            SET reject_reason = l_reason
            WHERE trx_id = l_trx_id;

            --  Update the AME System with the 'APPROVED' status.
            l_approver_record.approval_status := AME_UTIL.rejectStatus;

            ame_api2.updateApprovalStatus(
                      applicationIdIn     => 435,
                      transactionTypeIn   => 'FUN_IC_RECI_TRX',
                      transactionIdIn     => l_trx_id,
                      approverIn          => l_approver_record);

        END IF;

        IF(l_status = fnd_api.g_ret_sts_success) THEN
            resultout := wf_engine.eng_completed||':'||l_result;
            RETURN;
        ELSE
            resultout := wf_engine.eng_error||':'||wf_engine.eng_null;
            -- TODO: Process error
            IF(l_msg_count >= 1) THEN
                wf_core.Raise(fnd_msg_pub.get);
            END IF;
        END IF;

    END IF; -- funcmode = 'RESPOND'

    IF funcmode IN ('FORWARD', 'TRANSFER')
    THEN
        l_forward_role := wf_engine.context_text;

        l_valid_user := fun_wf_common.is_user_valid_approver
                                (p_transaction_id => l_trx_id,
				 p_user_id        => NULL,
                                 p_role_name      => l_forward_role,
                                 p_org_type       => 'R',
                                 p_mode           => 'WF');

        IF l_valid_user = 'N'
        THEN
            wf_core.Raise('FUN_INVALID_USER_FORWARD');
        ELSE
            -- Get the role of the person to whom the notification was originally
            -- assigned

            wf_notification.getInfo(l_nid, l_user_role, l_message_type,
                                    l_message_name, l_priority,
                                    l_due_date, l_ntf_status);


            l_approver_record.approval_status := AME_UTIL.forwardStatus;
            l_approver_record.name            := l_user_role;
            l_forwardee_record.name           := l_forward_role;

            ame_api2.updateApprovalStatus(
                        applicationIdIn     => 435,
                        transactionTypeIn   => 'FUN_IC_RECI_TRX',
                        transactionIdIn     => l_trx_id,
                        approverIn          => l_approver_record,
                        forwardeeIn         => l_forwardee_record);

        END IF;

    END IF; -- funcmode = 'FORWARD',

    resultout := wf_engine.eng_null;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'POST_APPROVAL_NTF',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END post_approval_ntf;



/*-----------------------------------------------------
 * PROCEDURE check_ap_setup
 * ----------------------------------------------------
 * Check that AP is setup correctly with supplier and
 * open period and all that.
 * ---------------------------------------------------*/

PROCEDURE check_ap_setup (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_batch_id      number;
    l_vendor_id     number;
    l_site_id       number;
    l_gl_date       date;
    l_to_ledger_id  number;
    l_from_le_id    number;
    l_from_org_id   number;
    l_to_le_id      number;
    l_to_org_id     number;
    l_period_status varchar2(1);
    l_success       boolean := TRUE;
    x_msg_data		VARCHAR2(1000);
    l_initiator_name    varchar2(200);
    l_trx_amt           varchar2(200);
    l_batch_num         varchar2(20);
    l_trx_date          date;
    l_recipient_id  number;
    l_initiator_id  number;


BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_batch_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_ID');

        SELECT b.from_le_id, b.gl_date, h.to_le_id, h.to_ledger_id,
               fun_tca_pkg.get_ou_id(h.initiator_id),
               fun_tca_pkg.get_ou_id(h.recipient_id),
               b.batch_date, b.initiator_id, h.recipient_id
        INTO l_from_le_id, l_gl_date, l_to_le_id, l_to_ledger_id,
             l_from_org_id, l_to_org_id, l_trx_date,
             l_initiator_id,
             l_recipient_id
        FROM fun_trx_batches b,
             fun_trx_headers h
        WHERE b.batch_id = l_batch_id AND
              h.trx_id = l_trx_id AND
              h.batch_id = b.batch_id;

        fnd_msg_pub.initialize;

        -- Valid Org
        IF (l_to_org_id IS NULL) THEN
            fnd_message.set_name('FUN', 'FUN_API_INVALID_OU');
            fnd_msg_pub.add;
            l_success := FALSE;
        ELSE
            wf_engine.SetItemAttrNumber(itemtype, itemkey, 'ORG_ID', l_to_org_id);
        END IF;

        -- Valid period
        l_period_status := fun_gl_transfer.get_period_status(200, l_gl_date, l_to_ledger_id);
        IF (l_period_status NOT IN ('O', 'F')) THEN
            fnd_message.set_name('FUN', 'FUN_API_AP_PERIOD_NOT_OPEN');
            fnd_msg_pub.add;
            l_success := FALSE;
        END IF;

        -- Valid supplier
        IF (NOT fun_trading_relation.get_supplier(
                            'INTERCOMPANY',
                            l_from_le_id,
                            l_to_le_id,
                            l_from_org_id,
                            l_to_org_id,
                            l_initiator_id,
                            l_recipient_id,
                            l_trx_date,
                            x_msg_data,
                            l_vendor_id,
                            l_site_id)) THEN
            fnd_message.set_name('FUN', 'FUN_API_INVALID_SUPPLIER');
            fnd_msg_pub.add;
            l_success := FALSE;
        ELSE
            wf_engine.SetItemAttrNumber(itemtype, itemkey, 'VENDOR_ID', l_vendor_id);
            wf_engine.SetItemAttrNumber(itemtype, itemkey, 'SITE_ID', l_site_id);
        END IF;

        IF (l_success) THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE

             -- added by rani shergill for notifications - start

         select ltrim(to_char(decode(nvl(h.reci_amount_cr,0),
                0,h.reci_amount_dr,
                h.reci_amount_cr),'999999999.99'))||' '||b.currency_code
         into  l_trx_amt
         from fun_trx_headers h, fun_trx_batches b
         where b.batch_id = l_batch_id
         and h.trx_id = l_trx_id;

        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_AMOUNT',
                                  avalue => l_trx_amt);



        SELECT init.party_name
        INTO l_initiator_name
        FROM fun_trx_headers,
             hz_parties init
        WHERE trx_id = l_trx_id
        AND    initiator_id = init.party_id;

         wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'INITIATOR_NAME',
                                  avalue => l_initiator_name);


        --added by rani - end

            wf_engine.SetItemAttrText(itemtype, itemkey, 'ERROR',
                         fun_wf_common.concat_msg_stack(fnd_msg_pub.count_msg));
            resultout := wf_engine.eng_completed||':F';

        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'CHECK_AP_SETUP',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
            RAISE;
END check_ap_setup;




/*-----------------------------------------------------
 * PROCEDURE transfer_to_ap
 * ----------------------------------------------------
 * Transfer to AP. Wrapper for
 * FUN_AP_TRANSFER.LOCK_AND_TRANSFER.
 *
 * If LOCK_AND_TRANSFER returns false, it means the
 * status is incorrect, i.e. the trx is already
 * transferred. So we abort our WF process.
 * ---------------------------------------------------*/

PROCEDURE transfer_to_ap (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_vendor_id     number;
    l_site_id       number;
    l_trx_id        number;
    l_batch_id      number;
    l_batch_date    date;
    l_gl_date       date;
    l_approval_date date;
    l_org_id        number;
    l_from_org_id   number;
    l_currency      varchar2(15);
    l_invoice_num   varchar2(50);
    l_success       boolean;
    l_status        varchar2(15);
    l_exchange_rate_type fun_trx_batches.exchange_rate_type%TYPE;
BEGIN
    IF (funcmode = 'RUN') THEN
        l_vendor_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'VENDOR_ID');
        l_site_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'SITE_ID');
        l_org_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'ORG_ID');
        l_trx_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_ID');
        l_batch_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'BATCH_ID');

        SELECT batch_date, gl_date, currency_code,
               exchange_rate_type,
               fun_tca_pkg.get_ou_id(initiator_id) from_org_id
        INTO   l_batch_date, l_gl_date, l_currency,
               l_exchange_rate_type,
               l_from_org_id
        FROM fun_trx_batches
        WHERE batch_id = l_batch_id;

        SELECT ar_invoice_number INTO l_invoice_Num
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        l_success := fun_ap_transfer.lock_and_transfer(
                        l_trx_id, l_batch_date, l_vendor_id,
                        l_site_id, l_gl_date, l_currency,
                        l_exchange_rate_type,
                        'GLOBAL_INTERCOMPANY', l_approval_date,
                        l_org_id, l_invoice_num,
                        l_from_org_id);

        IF (NOT l_success) THEN
            SELECT status INTO l_status
            FROM fun_trx_headers
            WHERE trx_id = l_trx_id;

            IF (l_status <> 'XFER_AR') then
                wf_engine.AbortProcess(itemtype => itemtype,
                                       itemkey => itemkey,
                                       process => 'AP_TRANSFER');
            ELSE
                RAISE ap_transfer_failure;
            END IF;
        END IF;

        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
    END IF;

    resultout := wf_engine.eng_null;
    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'TRANSFER_TO_AP',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END transfer_to_ap;



/*-----------------------------------------------------
 * PROCEDURE raise_error
 * ----------------------------------------------------
 * Raise the error event.
 * ---------------------------------------------------*/

PROCEDURE raise_error (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_trx_id        number;
    l_event_key     varchar2(240);
    l_params        wf_parameter_list_t := wf_parameter_list_t();
BEGIN
    IF (funcmode = 'RUN') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_event_key := fun_wf_common.generate_event_key(l_batch_id, l_trx_id);

        wf_event.AddParameterToList(p_name => 'TRX_ID',
                                 p_value => TO_CHAR(l_trx_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'BATCH_ID',
                                 p_value => TO_CHAR(l_batch_id),
                                 p_parameterlist => l_params);

        wf_event.raise(
                p_event_name => 'oracle.apps.fun.manualtrx.error.send',
                p_event_key  => l_event_key,
                p_parameters => l_params);

        l_params.delete();
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'RAISE_ERROR',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END raise_error;


/*-----------------------------------------------------
 * PROCEDURE raise_received
 * ----------------------------------------------------
 * Raise the received event.
 * ---------------------------------------------------*/

PROCEDURE raise_received (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_trx_id        number;
    l_event_key     varchar2(240);
    l_resp_id       number;
    l_user_id       NUMBER;
    l_appl_id       NUMBER;
    l_params        wf_parameter_list_t := wf_parameter_list_t();
	l_user_env_lang VARCHAR2(5);
BEGIN
-- Bug 7639191
    IF (funcmode = 'RUN') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_resp_id :=   wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'RESP_ID');
        l_user_id  :=  wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'USER_ID');
        l_appl_id  :=  wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'APPL_ID');
		l_user_env_lang := wf_engine.GetItemAttrText
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'USER_LANG');

        l_event_key := fun_wf_common.generate_event_key(l_batch_id, l_trx_id);

        wf_event.AddParameterToList(p_name => 'TRX_ID',
                                 p_value => TO_CHAR(l_trx_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'BATCH_ID',
                                 p_value => TO_CHAR(l_batch_id),
                                 p_parameterlist => l_params);
        WF_EVENT.AddParameterToList(p_name=>'RESP_ID',
                                 p_value=>TO_CHAR(l_resp_id),
                                 p_parameterlist=>l_params);
        WF_EVENT.AddParameterToList(p_name=>'USER_ID',
                                    p_value=>TO_CHAR(l_user_id),
                                    p_parameterlist=>l_params);
        WF_EVENT.AddParameterToList(p_name=>'APPL_ID',
                                    p_value=>TO_CHAR(l_appl_id),
                                    p_parameterlist=>l_params);
		WF_EVENT.AddParameterToList(p_name => 'USER_LANG',
                                 p_value => TO_CHAR(l_user_env_lang),
                                 p_parameterlist => l_params);

        wf_event.raise(
                p_event_name => 'oracle.apps.fun.manualtrx.reception.send',
                p_event_key  => l_event_key,
                p_parameters => l_params);

        l_params.delete();
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'RAISE_RECEIVED',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END raise_received;



/*-----------------------------------------------------
 * PROCEDURE raise_reject
 * ----------------------------------------------------
 * Raise the rejection event.
 * ---------------------------------------------------*/

PROCEDURE raise_reject (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_trx_id        number;
    l_event_key     varchar2(240);
    l_params        wf_parameter_list_t := wf_parameter_list_t();
BEGIN
    IF (funcmode = 'RUN') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_event_key := fun_wf_common.generate_event_key(l_batch_id, l_trx_id);

        wf_event.AddParameterToList(p_name => 'TRX_ID',
                                 p_value => TO_CHAR(l_trx_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'BATCH_ID',
                                 p_value => TO_CHAR(l_batch_id),
                                 p_parameterlist => l_params);

        wf_event.raise(
                p_event_name => 'oracle.apps.fun.manualtrx.rejection.send',
                p_event_key  => l_event_key,
                p_parameters => l_params);

        l_params.delete();
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'RAISE_REJECT',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END raise_reject;


/*-----------------------------------------------------
 * PROCEDURE raise_approve
 * ----------------------------------------------------
 * Raise the approve event.
 * ---------------------------------------------------*/

PROCEDURE raise_approve (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_trx_id        number;
    l_event_key     varchar2(240);
    l_params        wf_parameter_list_t := wf_parameter_list_t();
	l_user_env_lang varchar2(5);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
		l_user_env_lang := wf_engine.GetItemAttrText
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'USER_LANG');

        l_event_key := fun_wf_common.generate_event_key(l_batch_id, l_trx_id);

        wf_event.AddParameterToList(p_name => 'TRX_ID',
                                 p_value => TO_CHAR(l_trx_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'BATCH_ID',
                                 p_value => TO_CHAR(l_batch_id),
                                 p_parameterlist => l_params);
		WF_EVENT.AddParameterToList(p_name => 'USER_LANG',
                                 p_value => TO_CHAR(l_user_env_lang),
                                 p_parameterlist => l_params);

        wf_event.raise(
                p_event_name => 'oracle.apps.fun.manualtrx.approval.send',
                p_event_key  => l_event_key,
                p_parameters => l_params);

        l_params.delete();
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'RAISE_APPROVE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END raise_approve;


/*-----------------------------------------------------
 * PROCEDURE raise_gl_transfer
 * ----------------------------------------------------
 * Raise the transfer to gl event.
 * ---------------------------------------------------*/

PROCEDURE raise_gl_transfer (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_party_id      number;
    l_batch_id      number;
    l_trx_id        number;
    l_event_key     varchar2(64);
    l_params        wf_parameter_list_t := wf_parameter_list_t();
	l_user_env_lang varchar2(5);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
		l_user_env_lang := wf_engine.GetItemAttrText
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'USER_LANG');
        l_event_key := fun_wf_common.generate_event_key(l_batch_id, l_trx_id);

        SELECT recipient_id INTO l_party_id
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        wf_event.AddParameterToList(p_name => 'TRX_ID',
                                 p_value => TO_CHAR(l_trx_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'BATCH_ID',
                                 p_value => TO_CHAR(l_batch_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'PARTY_ID',
                                 p_value => TO_CHAR(l_party_id),
                                 p_parameterlist => l_params);
		wf_event.AddParameterToList(p_name => 'USER_LANG',
                                 p_value => TO_CHAR(l_user_env_lang),
                                 p_parameterlist => l_params);

        wf_event.raise(
                p_event_name => 'oracle.apps.fun.manualtrx.gl.transfer',
                p_event_key  => l_event_key,
                p_parameters => l_params);

        l_params.delete();
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'RAISE_GL_TRANSFER',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END raise_gl_transfer;


/*-----------------------------------------------------
 * PROCEDURE update_status_error
 * ----------------------------------------------------
 * Update status to error.
 * ---------------------------------------------------

PROCEDURE update_status_error (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'ERROR');
        -- TODO: check return status
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'UPDATE_STATUS_ERROR',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END update_status_error;
*/

/*-----------------------------------------------------
 * PROCEDURE update_status_rejected
 * ----------------------------------------------------
 * Update status to rejected.
 * ---------------------------------------------------*/

PROCEDURE update_status_rejected (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'REJECTED');
        -- TODO: check return status
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'UPDATE_STATUS_REJECTED',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END update_status_rejected;


/*-----------------------------------------------------
 * PROCEDURE update_status_approved
 * ----------------------------------------------------
 * Update status to approved.
 * ---------------------------------------------------*/

PROCEDURE update_status_approved (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
    e_gen_acct_error EXCEPTION;
BEGIN
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'APPROVED');

        IF l_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            resultout := wf_engine.eng_completed||':F';
            RETURN;
        END IF;

        resultout := wf_engine.eng_completed||':'||'T';
        RETURN;
    END IF;

    resultout := wf_engine.eng_completed||':'||'T';
    RETURN;

    EXCEPTION
       WHEN e_gen_acct_error THEN
            wf_core.context('FUN_RECIPIENT_WF', 'UPDATE_STATUS_APPROVED',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;

        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'UPDATE_STATUS_APPROVED',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;

END update_status_approved;

/*-----------------------------------------------------
 * PROCEDURE approve_ntf
 * ----------------------------------------------------
 * Approve notification process from UI.
 * ---------------------------------------------------*/

procedure approve_ntf (
    p_batch_id    in varchar2,
    p_trx_id      in varchar2,
    p_eventkey    in varchar2)
IS
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
    l_result        varchar2(1);
    l_approver_record	ame_util.approverRecord2;
    l_activity_name varchar2(30);
    l_user_id       NUMBER;
    l_resp_id       NUMBER;
    l_appl_id       NUMBER;


BEGIN
    -- Bug # 9069005
    l_user_id  := fnd_global.user_id;
    l_resp_id  := fnd_global.resp_id;
    l_appl_id  := fnd_global.resp_appl_id;
    FND_GLOBAL.APPS_INITIALIZE(l_user_id,l_resp_id,l_appl_id);

    --Bug No:5897122.
    --Bug No: 6865713. Replaced l_trx_id with p_trx_id.
    create_wf_roles(p_trx_id);
     --End:    5897122.
     wf_engine.SetItemAttrText
           (itemtype => 'FUNRMAIN',
            itemkey  => p_eventkey,
            aname    => 'UI_ACTION_TYPE',
            avalue    => 'APPROVE');

     wf_engine.SetItemAttrText
           (itemtype => 'FUNRMAIN',
            itemkey  => p_eventkey,
            aname    => 'UI_ACTION_USER_NAME',
            avalue    => FND_GLOBAL.USER_NAME);

     wf_engine.SetItemAttrNumber
           (itemtype => 'FUNRMAIN',
            itemkey  => p_eventkey,
            aname    => 'UI_ACTION_USER_ID',
            avalue    => FND_GLOBAL.USER_ID);

     --get process/activity name
     SELECT WPA.ACTIVITY_NAME
     INTO l_activity_name
     from WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA
     where WIAS.ITEM_TYPE = 'FUNRMAIN'
     and WIAS.ITEM_KEY = p_eventkey
     and WIAS.ACTIVITY_STATUS = wf_engine.eng_notified
     and WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
     and ((WPA.PROCESS_NAME = 'RECIPIENT_APPROVAL'
     AND WPA.ACTIVITY_NAME IN ('FIX_ACCT_DIST_NTF',
                               'FIX_ACCT_DIST_NTF_NO_REJ')) OR
     (WPA.PROCESS_NAME = 'SEND_APPROVAL_NOTIFICATION'
     AND WPA.ACTIVITY_NAME IN ('APPROVAL_NTF', 'APPROVAL_ONLY_NTF')));

     IF l_activity_name IN ('APPROVAL_NTF', 'APPROVAL_ONLY_NTF',
                            'FIX_ACCT_DIST_NTF_NO_REJ', 'FIX_ACCT_DIST_NTF' )
     THEN
         l_approver_record.name  := FND_GLOBAL.USER_NAME;
         l_approver_record.approval_status := AME_UTIL.approvedStatus;

         ame_api2.updateApprovalStatus(
                        applicationIdIn     => 435,
                        transactionTypeIn   => 'FUN_IC_RECI_TRX',
                        transactionIdIn     => p_trx_id,
                        approverIn          => l_approver_record);

          -- Update the approver id onto the fun_trx_headers table.
          -- approver_id will always hold the id of the last person
          -- to approve the transaction.
          UPDATE fun_trx_headers
          SET    approver_id = FND_GLOBAL.USER_ID,
          approval_date = SYSDATE
          WHERE  trx_id = p_trx_id;

     END IF;

     IF l_activity_name IN ( 'FIX_ACCT_DIST_NTF', 'FIX_ACCT_DIST_NTF_NO_REJ')
     THEN
            wf_engine.CompleteActivityInternalName(
                         itemtype => 'FUNRMAIN',
                         itemkey => p_eventkey,
                         activity => 'RECIPIENT_APPROVAL:'||l_activity_name,
                         result => 'RETRY');

     ELSIF l_activity_name = 'APPROVAL_NTF' then
            wf_engine.CompleteActivityInternalName(
                         itemtype => 'FUNRMAIN',
                         itemkey => p_eventkey,
                         activity => 'SEND_APPROVAL_NOTIFICATION:'||l_activity_name,
                         result => 'APPROVED');

     ELSIF l_activity_name = 'APPROVAL_ONLY_NTF' then
            wf_engine.CompleteActivityInternalName(
                         itemtype => 'FUNRMAIN',
                         itemkey => p_eventkey,
                         activity => 'SEND_APPROVAL_NOTIFICATION:'||l_activity_name,
                         result => 'APPROVE');
     END IF;

EXCEPTION
WHEN OTHERS THEN
     UPDATE fun_trx_headers
     SET status = 'RECEIVED'
     WHERE trx_id = p_trx_id;
     RAISE;
END approve_ntf;

/*-----------------------------------------------------
 * PROCEDURE reject_ntf
 * ----------------------------------------------------
 * Reject notification process from UI.
 * ---------------------------------------------------*/

procedure reject_ntf (
    p_batch_id    in varchar2,
    p_trx_id      in varchar2,
    p_eventkey    in varchar2)
IS
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
    l_result        varchar2(1);
    l_activity_name varchar2(30);
    l_approver_record	ame_util.approverRecord2;
BEGIN
    --Bug No:5897122.
    create_wf_roles(p_trx_id);
     --End:    5897122.
     wf_engine.SetItemAttrText
           (itemtype => 'FUNRMAIN',
            itemkey  => p_eventkey,
            aname    => 'UI_ACTION_TYPE',
            avalue    => 'REJECT');

     wf_engine.SetItemAttrText
           (itemtype => 'FUNRMAIN',
            itemkey  => p_eventkey,
            aname    => 'UI_ACTION_USER_NAME',
            avalue    => FND_GLOBAL.USER_NAME);

     wf_engine.SetItemAttrNumber
           (itemtype => 'FUNRMAIN',
            itemkey  => p_eventkey,
            aname    => 'UI_ACTION_USER_ID',
            avalue    => FND_GLOBAL.USER_ID);

--check reject allowed
        SELECT reject_allow_flag INTO l_result
        FROM fun_trx_batches
        WHERE batch_id = p_batch_id;

       IF (l_result = 'Y')
       THEN

           --get process/activity name
           SELECT WPA.ACTIVITY_NAME
           INTO l_activity_name
           from WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA
           where WIAS.ITEM_TYPE = 'FUNRMAIN'
           and WIAS.ITEM_KEY = p_eventkey
           and WIAS.ACTIVITY_STATUS = wf_engine.eng_notified
           and WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
           and ((WPA.PROCESS_NAME = 'RECIPIENT_APPROVAL'
           AND WPA.ACTIVITY_NAME IN ('FIX_ACCT_DIST_NTF')) OR
           (WPA.PROCESS_NAME = 'SEND_APPROVAL_NOTIFICATION'
           AND WPA.ACTIVITY_NAME IN ('APPROVAL_NTF', 'APPROVAL_ONLY_NTF')));

           IF l_activity_name IN ('APPROVAL_NTF', 'FIX_ACCT_DIST_NTF' )
           THEN
               fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => p_trx_id,
                         p_update_status_to => 'REJECTED');

                --  Update the AME System with the 'APPROVED' status.
                l_approver_record.name  := FND_GLOBAL.USER_NAME;
                l_approver_record.approval_status := AME_UTIL.rejectStatus;

                ame_api2.updateApprovalStatus(
                      applicationIdIn     => 435,
                      transactionTypeIn   => 'FUN_IC_RECI_TRX',
                      transactionIdIn     => p_trx_id,
                      approverIn          => l_approver_record);

           END IF;

           IF l_activity_name = 'FIX_ACCT_DIST_NTF' then
                  wf_engine.CompleteActivityInternalName(
                         itemtype => 'FUNRMAIN',
                         itemkey => p_eventkey,
                         activity => 'RECIPIENT_APPROVAL:'||l_activity_name,
                         result => 'REJECT');

           ELSIF l_activity_name = 'APPROVAL_NTF' then

                  wf_engine.CompleteActivityInternalName(
                         itemtype => 'FUNRMAIN',
                         itemkey => p_eventkey,
                         activity => 'SEND_APPROVAL_NOTIFICATION:APPROVAL_NTF',
                         result => 'REJECTED');
           END IF;
       else
            --raise not allow to reject error
            null;
       end if;

EXCEPTION
WHEN OTHERS THEN
     UPDATE fun_trx_headers
     SET status = 'RECEIVED'
     WHERE trx_id = p_trx_id;
     RAISE;
END reject_ntf;

/*-----------------------------------------------------
 * PROCEDURE recipient_interco_acct
 * ----------------------------------------------------
 * Insert a default intercompany account for recipient
 * accounting to fun_dist_lines
 * ---------------------------------------------------*/

procedure recipient_interco_acct (
    itemtype    in varchar2,
    itemkey     in varchar2,
    actid       in number,
    funcmode    in varchar2,
    resultout   in OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_batch_id      number;
    l_status        varchar2(1);
    l_msg_count     number := 0;
    l_msg_data      varchar2(1000);
    l_from_le_id    number;
    l_to_le_id      number;
    l_reci_amount_cr number;
    l_reci_amount_dr number;
    l_dist_id       number;
    l_ccid          number;
    l_dist_exist    number;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'begin');
  END IF;

    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');

        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        -- Check if recipient distributions already exist
        SELECT COUNT(*)
        INTO   l_dist_exist
        FROM   fun_dist_lines d
        WHERE  d.trx_id = l_trx_id
        AND    d.dist_type_flag = 'L'
        AND    d.party_type_flag = 'R';

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'checking distributions');
  END IF;

        IF l_dist_exist > 0
        THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'recipient dist exist');
  END IF;

            resultout := wf_engine.eng_null;
            RETURN;
        END IF;


        SELECT b.from_le_id, h.to_le_id, h.reci_amount_cr, h.reci_amount_dr
        INTO l_from_le_id, l_to_le_id, l_reci_amount_cr, l_reci_amount_dr
        FROM FUN_TRX_BATCHES b, FUN_TRX_HEADERS h
        WHERE b.batch_id = l_batch_id
        AND b.batch_id = h.batch_id
        AND h.trx_id = l_trx_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'fetched details from headers');
  END IF;


        -- Get Default ccid from SLA
        fun_recipient_wf.get_default_sla_ccid (
            p_trx_id    => l_trx_id,
            x_ccid      => l_ccid,
            x_status    => l_status,
            x_msg_count => l_msg_count,
            x_msg_data  => l_msg_data);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'returned from call to get_default_sla_ccid');
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'l_ccid is '|| l_ccid);
  END IF;

        IF l_ccid > 0
        THEN


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'Inserting distribution rows');
  END IF;
	   -- Changes made for Bug # 6843857 to picks up recipient party id
           FOR crec in (SELECT
                      dl.LINE_ID,
                      --dl.PARTY_ID,
		      h.RECIPIENT_ID,
                      dl.amount_dr,
                      dl.amount_cr
                      --FUN_TRX_ENTRY_UTIL.GET_DEFAULT_CCID(l_to_le_id, l_from_le_id, 'P') CCID
                     FROM fun_dist_lines dl, fun_trx_lines l, fun_trx_headers h
                     WHERE l.trx_id = l_trx_id
		     AND dl.trx_id = h.trx_id
                     AND dl.line_id = l.line_id
                     AND dl.party_type_flag = 'I'
                     AND dl.dist_type_flag = 'L')
           LOOP



            SELECT FUN_DIST_LINES_S.nextval INTO l_dist_id FROM dual;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'Inserting distribution ' || l_dist_id);
  END IF;

            INSERT into FUN_DIST_LINES(
             DIST_ID,
             LINE_ID,
             DIST_NUMBER,
             PARTY_ID,
             PARTY_TYPE_FLAG,
             DIST_TYPE_FLAG,
             AMOUNT_CR,
             AMOUNT_DR,
             CCID,
             AUTO_GENERATE_FLAG,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             trx_id)
            VALUES(
             l_dist_id,
             crec.line_id,
             l_dist_id,
             --crec.party_id,
	     crec.recipient_id,
             'R',
             'L',
             crec.amount_dr,
             crec.amount_cr,
             l_ccid,
             'N',
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.LOGIN_ID,
             l_trx_id);

          END LOOP;

        END IF;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'Done inserting');
END IF;

        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', 'Unexpected Error');
END IF;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.recipient_interco_acct', SQLERRM);
END IF;

            wf_core.context('FUN_RECIPIENT_WF', 'RECIPIENT_INTERCO_ACCT',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END recipient_interco_acct;


/*-----------------------------------------------------
 * PROCEDURE check_acct_dist
 * ----------------------------------------------------
 * Call the Transaction API to validate account distributions
 * ---------------------------------------------------*/

PROCEDURE check_acct_dist (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_batch_id      number;
    l_status        varchar2(1);
    l_msg_count     number := 0;
    l_msg_data      varchar2(1000);
    l_batch_rec     fun_trx_pvt.batch_rec_type;
    l_trx_rec       fun_trx_pvt.trx_rec_type;
    l_dist_line_tbl fun_trx_pvt.dist_line_tbl_type;
    l_result        boolean := true;
    l_trx_status    varchar2(100);

BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');

        select status into l_trx_status
        from fun_trx_headers
        where trx_id = l_trx_id;

        -- Beware of NO_DATA_FOUND.
        l_batch_rec := make_batch_rec(l_batch_id);
        l_trx_rec := make_trx_rec(l_trx_id);
        l_dist_line_tbl := make_dist_lines_tbl(l_trx_id);

        fun_trx_pvt.recipient_validate(
                        1.0, 'T', 50,
                        l_status, l_msg_count, l_msg_data,
                        l_batch_rec, l_trx_rec, l_dist_line_tbl);

        IF (l_status = 'S') THEN

            resultout := wf_engine.eng_completed||':T';
            RETURN;
        ELSE
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ERROR_MESSAGE',
                         fun_wf_common.concat_msg_stack(fnd_msg_pub.count_msg));
			IF l_status = 'I' THEN
				wf_engine.SetItemAttrText(itemtype, itemkey, 'NOTIFICATION_SUBJECT',
							 'requires recipient accounting');
			END IF;
            resultout := wf_engine.eng_completed||':F';
            RETURN;
        END IF;

    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

EXCEPTION
WHEN others THEN
        UPDATE fun_trx_headers
        SET status = 'RECEIVED'
        WHERE trx_id = l_trx_id;

        wf_core.context('FUN_RECIPIENT_WF', 'CHECK_ACCT_DIST',
                        itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END check_acct_dist;

/* ---------------------------------------------------------------------------
Name      : check_ui_apprvl_action
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by the Recipient Main workflow
            to check if an approval action was taken in the wflow
            even before an approval notification was sent.
Parameters:
    IN    : itemtype  - Workflow Item Type
            itemkey   - Workflow Item Key
            actid     - Workflow Activity Id
            funcmode  - Workflow Function Mode
    OUT   : resultout - Result of the workflow function
Notes     : None.
Testing   : This function will be tested via workflow FUNRMAIN
------------------------------------------------------------------------------*/

PROCEDURE check_ui_apprvl_action (itemtype   IN VARCHAR2,
			    itemkey    IN VARCHAR2,
			    actid      IN NUMBER,
			    funcmode   IN VARCHAR2,
			    resultout  OUT NOCOPY VARCHAR2 ) IS

l_action_type	        VARCHAR2(20);
l_approver_record	ame_util.approverRecord2;
l_trx_id	        NUMBER;
l_user_id               fnd_user.user_id%TYPE;

l_status        varchar2(1);
l_msg_count     number;
l_msg_data      varchar2(1000);

BEGIN
    l_action_type := wf_engine.GetItemAttrText (itemtype => itemtype,
			    itemkey  => itemkey,
			    aname    => 'UI_ACTION_TYPE');

    l_approver_record.name := wf_engine.GetItemAttrText
			   (itemtype => itemtype,
			     itemkey  => itemkey,
			     aname    => 'UI_ACTION_USER_NAME');

    l_user_id     := wf_engine.GetItemAttrNumber
			   (itemtype => itemtype,
			     itemkey  => itemkey,
			     aname    => 'UI_ACTION_USER_ID');

    l_trx_id     := wf_engine.GetItemAttrNumber (itemtype => itemtype,
			    itemkey  => itemkey,
			    aname    => 'TRX_ID');

    IF  l_action_type = 'APPROVE'
    THEN

        resultout := wf_engine.eng_completed||':'||'APPROVE';

    ELSIF l_action_type = 'REJECT'
    THEN
        resultout := wf_engine.eng_completed||':'||'REJECT';

    ELSIF Nvl(l_action_type,'NONE') = 'NONE'
    THEN
        resultout := wf_engine.eng_completed||':'||'NONE';

    END IF;

END check_ui_apprvl_action;

/*-----------------------------------------------------
 * PROCEDURE generate_interco_acct
 * ----------------------------------------------------
 * Generats intercompany account distribution lines for both
 * the recipient and initiator
 * ---------------------------------------------------*/

PROCEDURE generate_interco_acct (
    p_trx_id    IN NUMBER,
    x_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count IN OUT NOCOPY NUMBER,
    x_msg_data  IN OUT NOCOPY VARCHAR2)
IS

CURSOR c_dists (p_trx_id      NUMBER,
                p_party_type  VARCHAR2) IS
    SELECT
      dist.dist_id         ,
      dist.dist_number     ,
      dist.trx_id          ,
      dist.line_id         ,
      head.initiator_id    ,
      head.recipient_id    ,
      btch.from_le_id  initiator_le_id ,
      head.to_le_id     recipient_le_id ,
      btch.gl_date         ,
      DECODE(p_party_type, 'I', btch.from_ledger_id,
                                head.to_ledger_id)  ledger_id ,
      dist.amount_cr       ,
      dist.amount_dr       ,
      dist.ccid       ,
      fun_util.get_account_segment_value (DECODE(p_party_type, 'I',
                                                   btch.from_ledger_id,
                                                   head.to_ledger_id),
                                          dist.ccid,
                                          'GL_BALANCING')  dist_bsv ,
      dist.description,
      head.init_amount_cr,
      head.init_amount_dr,
      head.reci_amount_cr,
      head.reci_amount_dr
    FROM  fun_dist_lines  dist,
          fun_trx_headers head,
          fun_trx_batches btch
    WHERE  dist.trx_id           = head.trx_id
    AND    head.batch_id         = btch.batch_id
    AND    dist.party_type_flag  = p_party_type
    AND    head.trx_id           = p_trx_id
    AND    dist.dist_type_flag   = 'L';

    l_trx_id        NUMBER;
    l_batch_id      NUMBER;
    l_status        VARCHAR2(1);
    l_msg_count     NUMBER := 0;
    l_msg_data      VARCHAR2(1000);
    l_ccid          NUMBER;
    l_reciprocal_ccid NUMBER;

    TYPE dist_line_rec_type IS RECORD (
      dist_id         NUMBER (15),
      dist_number     NUMBER (15),
      trx_id          NUMBER (15),
      line_id         NUMBER (15),
      initiator_id    NUMBER,
      recipient_id    NUMBER,
      initiator_le_id NUMBER,
      recipient_le_id NUMBER,
      gl_date         DATE,
      ledger_id       NUMBER,
      amount_cr       NUMBER,
      amount_dr       NUMBER,
      dist_ccid       NUMBER,
      dist_bsv        VARCHAR2(30),
      description     fun_dist_lines.description%TYPE,
      init_amount_cr  NUMBER,
      init_amount_dr  NUMBER,
      reci_amount_cr  NUMBER,
      reci_amount_dr  NUMBER);

    TYPE dist_summary_rec_type IS RECORD (
      trx_id          NUMBER (15),
      line_id         NUMBER (15),
      initiator_id    NUMBER,
      recipient_id    NUMBER,
      initiator_le_id NUMBER,
      recipient_le_id NUMBER,
      gl_date         DATE,
      ledger_id       NUMBER,
      amount_cr       NUMBER,
      amount_dr       NUMBER,
      dist_ccid       NUMBER,
      dist_bsv        VARCHAR2(30),
      description     fun_dist_lines.description%TYPE,
      init_amount_cr  NUMBER,
      init_amount_dr  NUMBER,
      reci_amount_cr  NUMBER,
      reci_amount_dr  NUMBER);

   TYPE new_dist_rec_type IS RECORD (
      dist_id            NUMBER (15),
      line_id            NUMBER (15),
      dist_number        NUMBER (15),
      party_id           NUMBER,
      party_type_flag    VARCHAR2 (1),
      dist_type_flag     VARCHAR2 (1),
      batch_dist_id      NUMBER,
      amount_cr          NUMBER,
      amount_dr          NUMBER,
      ccid               NUMBER (15),
      description        fun_dist_lines.description%TYPE,
      auto_generate_flag VARCHAR2(1),
      attribute1         VARCHAR2(150),
      attribute2         VARCHAR2(150),
      attribute3         VARCHAR2(150),
      attribute4         VARCHAR2(150),
      attribute5         VARCHAR2(150),
      attribute6         VARCHAR2(150),
      attribute7         VARCHAR2(150),
      attribute8         VARCHAR2(150),
      attribute9         VARCHAR2(150),
      attribute10        VARCHAR2(150),
      attribute11        VARCHAR2(150),
      attribute12        VARCHAR2(150),
      attribute13        VARCHAR2(150),
      attribute14        VARCHAR2(150),
      attribute15        VARCHAR2(150),
      attribute_category VARCHAR2(150),
      created_by        NUMBER,
      creation_date     DATE,
      last_updated_by   NUMBER,
      last_update_date  DATE,
      last_update_login NUMBER,
      trx_id            NUMBER (15));


CURSOR c_dtls IS
   SELECT  b.batch_id,
           b.initiator_id initiator_id
          ,b.from_le_id  from_le_id
          ,b.from_ledger_id from_ledger_id
          ,b.currency_code currency_code
          ,b.attribute1  bat_attribute1
          ,b.attribute2  bat_attribute2
          ,b.attribute3  bat_attribute3
          ,b.attribute4  bat_attribute4
          ,b.attribute5  bat_attribute5
          ,b.attribute6  bat_attribute6
          ,b.attribute7  bat_attribute7
          ,b.attribute8  bat_attribute8
          ,b.attribute9  bat_attribute9
          ,b.attribute10  bat_attribute10
          ,b.attribute11  bat_attribute11
          ,b.attribute12  bat_attribute12
          ,b.attribute13  bat_attribute13
          ,b.attribute14  bat_attribute14
          ,b.attribute15  bat_attribute15
          ,b.attribute_category  bat_attribute_category
          ,t.trx_id       trx_id
          ,t.recipient_id recipient_id
          ,t.to_le_id     to_le_id
          ,t.to_ledger_id to_ledger_id
          ,t.attribute1  trx_attribute1
          ,t.attribute2  trx_attribute2
          ,t.attribute3  trx_attribute3
          ,t.attribute4  trx_attribute4
          ,t.attribute5  trx_attribute5
          ,t.attribute6  trx_attribute6
          ,t.attribute7  trx_attribute7
          ,t.attribute8  trx_attribute8
          ,t.attribute9  trx_attribute9
          ,t.attribute10  trx_attribute10
          ,t.attribute11  trx_attribute11
          ,t.attribute12  trx_attribute12
          ,t.attribute13  trx_attribute13
          ,t.attribute14  trx_attribute14
          ,t.attribute15  trx_attribute15
          ,t.attribute_category  trx_attribute_category
          ,y.trx_type_id  trx_type_id
          ,y.manual_approve_flag           manual_approve_flag
          ,y.allow_invoicing_flag          allow_invoicing_flag
          ,y.vat_taxable_flag              vat_taxable_flag
          ,y.allow_interest_accrual_flag   allow_interest_accrual_flag
          ,y.attribute1  typ_attribute1
          ,y.attribute2  typ_attribute2
          ,y.attribute3  typ_attribute3
          ,y.attribute4  typ_attribute4
          ,y.attribute5  typ_attribute5
          ,y.attribute6  typ_attribute6
          ,y.attribute7  typ_attribute7
          ,y.attribute8  typ_attribute8
          ,y.attribute9  typ_attribute9
          ,y.attribute10  typ_attribute10
          ,y.attribute11  typ_attribute11
          ,y.attribute12  typ_attribute12
          ,y.attribute13  typ_attribute13
          ,y.attribute14  typ_attribute14
          ,y.attribute15  typ_attribute15
          ,y.attribute_category  typ_attribute_category
          ,l.chart_of_accounts_id  coa_id
          ,b.batch_date
          ,b.gl_date
   FROM fun_trx_batches b,
        fun_trx_headers t,
        fun_trx_types_vl y,
        gl_ledgers       l
   WHERE b.batch_id     = t.batch_id
   AND   b.trx_type_id  = y.trx_type_id
   AND   t.to_ledger_id = l.ledger_id
   AND   t.trx_id       = p_trx_id;
CURSOR c_bsv_level_summary (p_trx_id      NUMBER,
                p_party_type  VARCHAR2) IS

                SELECT
      trx_id          ,
      line_id         ,
      initiator_id    ,
      recipient_id    ,
      initiator_le_id ,
      recipient_le_id ,
      gl_date         ,
      ledger_id ,
      SUM(amount_cr) as amount_cr,
      SUM(amount_dr) as amount_dr,
      ccid       ,
      dist_bsv ,
      description,
      init_amount_cr,
      init_amount_dr,
      reci_amount_cr,
      reci_amount_dr
From(SELECT
      dist.trx_id          ,
      dist.line_id         ,
      head.initiator_id    ,
      head.recipient_id    ,
      btch.from_le_id  initiator_le_id ,
      head.to_le_id     recipient_le_id ,
      btch.gl_date         ,
      btch.from_ledger_id  ledger_id ,
            dist.amount_cr ,
             dist.amount_dr,
      NULL ccid       ,
      fun_util.get_account_segment_value (btch.from_ledger_id,
                                          dist.ccid,
                                          'GL_BALANCING')  dist_bsv ,
      dist.description,
      head.init_amount_cr,
      head.init_amount_dr,
      head.reci_amount_cr,
      head.reci_amount_dr
    FROM  fun_dist_lines  dist,
          fun_trx_headers head,
          fun_trx_batches btch
    WHERE  dist.trx_id           = head.trx_id
    AND    head.batch_id         = btch.batch_id
    AND    dist.party_type_flag  = p_party_type
    AND    head.trx_id           = p_trx_id
    AND    dist.dist_type_flag   = 'L'
)
GROUP BY trx_id          ,
      line_id         ,
      initiator_id    ,
      recipient_id    ,
      initiator_le_id ,
      recipient_le_id ,
      gl_date         ,
      ledger_id ,
      ccid       ,
      dist_bsv ,
      description,
      init_amount_cr,
      init_amount_dr,
      reci_amount_cr,
      reci_amount_dr ;

l_trx_dtl_rec    c_dtls%ROWTYPE;

CURSOR c_chk_sla (p_ledger_id    IN NUMBER) IS
  SELECT amb_context_code,
         account_definition_code
  FROM   fun_trx_acct_definitions
  WHERE  ledger_id = p_ledger_id;

CURSOR c_get_bsv(p_ledger_id    NUMBER,
                 p_le_id        NUMBER,
                 p_gl_date      DATE) IS
SELECT vals.segment_value
FROM   gl_ledger_le_bsv_specific_v vals
WHERE  vals.legal_entity_id     = p_le_id
AND    vals.ledger_id           = p_ledger_id
AND   p_gl_date BETWEEN Nvl(vals.start_date, p_gl_date) AND Nvl(vals.end_date, p_gl_date)
AND   (SELECT COUNT(*)
       FROM   gl_ledger_le_bsv_specific_v vals1
       WHERE  vals1.legal_entity_id = p_le_id
       AND    vals1.ledger_id       = p_ledger_id
       AND   p_gl_date BETWEEN Nvl(vals1.start_date, p_gl_date) AND Nvl(vals1.end_date, p_gl_date)) = 1;

l_amb_context_code         fun_trx_acct_definitions.amb_context_code%TYPE;
l_account_definition_code  fun_trx_acct_definitions.account_definition_code%TYPE;
l_initiator_bsv            gl_ledger_le_bsv_specific_v.segment_value%TYPE;
l_recipient_bsv            gl_ledger_le_bsv_specific_v.segment_value%TYPE;
-- Added for bug # 7520196
l_init_bsv                 gl_ledger_le_bsv_specific_v.segment_value%TYPE;
l_reci_bsv                 gl_ledger_le_bsv_specific_v.segment_value%TYPE;


   TYPE dist_line_tbl_type IS TABLE OF dist_line_rec_type
      INDEX BY BINARY_INTEGER;
    TYPE dist_summary_tbl_type IS TABLE OF dist_summary_rec_type
      INDEX BY BINARY_INTEGER;
   TYPE new_dist_tbl_type IS TABLE OF new_dist_rec_type
      INDEX BY BINARY_INTEGER;

   l_init_dist_tbl    dist_line_tbl_type;
   l_reci_dist_tbl    dist_line_tbl_type;
   l_new_dist_tbl     new_dist_tbl_type;
   l_init_summary_rec dist_summary_tbl_type;
   l_reci_summary_rec dist_summary_tbl_type;
   l_new_index        NUMBER;
   l_init_count       NUMBER;
   l_reci_count       NUMBER;
   l_to_bsv           VARCHAR2(30);

   l_to_coa_id        gl_ledgers.chart_of_accounts_id%TYPE;
   l_from_coa_id      gl_ledgers.chart_of_accounts_id%TYPE;
   l_invoice_flag     fun_trx_headers.invoice_flag%TYPE;

BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'begin. p_trx_id = ' || p_trx_id);
    END IF;

    x_status := FND_API.G_RET_STS_SUCCESS;

    l_trx_id := p_trx_id;
--Collect Iniator's info

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'open cursor c_dists for l_trx_id = ' || l_trx_id || 'and p_party_type = I' );
    END IF;

    OPEN c_dists (p_trx_id      => l_trx_id,
                  p_party_type  => 'I');
    FETCH c_dists BULK COLLECT INTO l_init_dist_tbl;
    CLOSE c_dists;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'open cursor c_dists for l_trx_id = ' || l_trx_id || 'and p_party_type = R' );
    END IF;

-- Collect Recipients Info
    OPEN c_dists (p_trx_id      => l_trx_id,
                  p_party_type  => 'R');
    FETCH c_dists BULK COLLECT INTO l_reci_dist_tbl;
    CLOSE c_dists;

    l_new_index  := 1;
    SELECT COUNT(*) INTO l_init_count
FROM (SELECT DISTINCT DIST_BSV FROM (SELECT
      dist.dist_id         ,
      dist.dist_number     ,
      dist.trx_id          ,
      dist.line_id         ,
      head.initiator_id    ,
      head.recipient_id    ,
      btch.from_le_id  initiator_le_id ,
      head.to_le_id     recipient_le_id ,
      btch.gl_date         ,
      btch.from_ledger_id  ledger_id ,
      dist.amount_cr       ,
      dist.amount_dr       ,
      dist.ccid       ,
      fun_util.get_account_segment_value (btch.from_ledger_id,
                                          dist.ccid,
                                          'GL_BALANCING')  dist_bsv ,
      dist.description,
      head.init_amount_cr,
      head.init_amount_dr,
      head.reci_amount_cr,
      head.reci_amount_dr
    FROM  fun_dist_lines  dist,
          fun_trx_headers head,
          fun_trx_batches btch
    WHERE  dist.trx_id           = head.trx_id
    AND    head.batch_id         = btch.batch_id
    AND    dist.party_type_flag  = 'I'
    AND    head.trx_id           = p_trx_id
    AND    dist.dist_type_flag   = 'L'));

    SELECT COUNT(*) INTO l_reci_count
FROM (SELECT DISTINCT DIST_BSV from(SELECT
      dist.dist_id         ,
      dist.dist_number     ,
      dist.trx_id          ,
      dist.line_id         ,
      head.initiator_id    ,
      head.recipient_id    ,
      btch.from_le_id  initiator_le_id ,
      head.to_le_id     recipient_le_id ,
      btch.gl_date         ,
      head.to_ledger_id  ledger_id ,
      dist.amount_cr       ,
      dist.amount_dr       ,
      dist.ccid       ,
      fun_util.get_account_segment_value (head.to_ledger_id,
                                          dist.ccid,
                                          'GL_BALANCING')  dist_bsv ,
      dist.description,
      head.init_amount_cr,
      head.init_amount_dr,
      head.reci_amount_cr,
      head.reci_amount_dr
    FROM  fun_dist_lines  dist,
          fun_trx_headers head,
          fun_trx_batches btch
    WHERE  dist.trx_id           = head.trx_id
    AND    head.batch_id         = btch.batch_id
    AND    dist.party_type_flag  = 'R'
    AND    head.trx_id           = p_trx_id
    AND    dist.dist_type_flag   = 'L'));

    l_to_bsv     := NULL;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_init_count = ' || l_init_count || 'and l_reci_count = ' || l_reci_count );
    END IF;

    IF l_init_count = 0 OR l_reci_count = 0
    THEN
        x_status := FND_API.G_RET_STS_ERROR;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'set x_status to ' || x_status );
        END IF;
    END IF;

	/*  Changes for bug 8406705 Start*/
	select NVL(invoice_flag, 'N')
  INTO l_invoice_flag
	from fun_trx_headers
	where trx_id = p_trx_id;

	-- Added for bug # 7520196
	IF  l_init_dist_tbl(1).AMOUNT_DR IS NULL
	THEN
		SELECT MIN(DIST_BSV)
		INTO l_init_bsv
		FROM   (SELECT   FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING') DIST_BSV,
				DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			FROM     FUN_DIST_LINES DIST,
					 FUN_TRX_HEADERS HEAD,
					 FUN_TRX_BATCHES BTCH
			WHERE    DIST.TRX_ID = HEAD.TRX_ID
					 AND HEAD.BATCH_ID = BTCH.BATCH_ID
					 AND HEAD.TRX_ID = p_trx_id
			GROUP BY FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING'),
					DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			HAVING   SUM(NVL(DIST.AMOUNT_DR,0.00)) <> SUM(NVL(DIST.AMOUNT_CR,0.00))
					 AND SUM(NVL(DIST.AMOUNT_CR,0.00)) <> 0.00);

		SELECT MIN(DIST_BSV)
		INTO l_reci_bsv
		FROM   (SELECT   FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING') DIST_BSV,
				DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			FROM     FUN_DIST_LINES DIST,
					 FUN_TRX_HEADERS HEAD,
					 FUN_TRX_BATCHES BTCH
			WHERE    DIST.TRX_ID = HEAD.TRX_ID
					 AND HEAD.BATCH_ID = BTCH.BATCH_ID
					 AND HEAD.TRX_ID = p_trx_id
			GROUP BY FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING'),
					DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			HAVING   SUM(NVL(DIST.AMOUNT_DR,0.00)) <> SUM(NVL(DIST.AMOUNT_CR,0.00))
					 AND SUM(NVL(DIST.AMOUNT_DR,0.00)) <> 0.00);
	ELSE
		SELECT MIN(DIST_BSV)
		INTO l_reci_bsv
		FROM   (SELECT   FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING') DIST_BSV,
				DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			FROM     FUN_DIST_LINES DIST,
					 FUN_TRX_HEADERS HEAD,
					 FUN_TRX_BATCHES BTCH
			WHERE    DIST.TRX_ID = HEAD.TRX_ID
					 AND HEAD.BATCH_ID = BTCH.BATCH_ID
					 AND HEAD.TRX_ID = p_trx_id
			GROUP BY FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING'),
					DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			HAVING   SUM(NVL(DIST.AMOUNT_DR,0.00)) <> SUM(NVL(DIST.AMOUNT_CR,0.00))
					 AND SUM(NVL(DIST.AMOUNT_CR,0.00)) <> 0.00);

		SELECT MIN(DIST_BSV)
		INTO l_init_bsv
		FROM   (SELECT   FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING') DIST_BSV,
				DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			FROM     FUN_DIST_LINES DIST,
					 FUN_TRX_HEADERS HEAD,
					 FUN_TRX_BATCHES BTCH
			WHERE    DIST.TRX_ID = HEAD.TRX_ID
					 AND HEAD.BATCH_ID = BTCH.BATCH_ID
					 AND HEAD.TRX_ID = p_trx_id
			GROUP BY FUN_UTIL.GET_ACCOUNT_SEGMENT_VALUE(DECODE(DIST.PARTY_TYPE_FLAG,'I',BTCH.FROM_LEDGER_ID,
																					HEAD.TO_LEDGER_ID),
														DIST.CCID,'GL_BALANCING'),
					DECODE(DIST.PARTY_TYPE_FLAG,'I', BTCH.FROM_LE_ID, HEAD.TO_LE_ID)
			HAVING   SUM(NVL(DIST.AMOUNT_DR,0.00)) <> SUM(NVL(DIST.AMOUNT_CR,0.00))
					 AND SUM(NVL(DIST.AMOUNT_DR,0.00)) <> 0.00);
	END IF;

	IF (l_init_bsv IS NULL AND
	    l_reci_bsv IS NULL)
	THEN
		IF ('Y' = (l_invoice_flag))
		THEN
			l_init_bsv := l_init_dist_tbl(1).dist_bsv;
			l_reci_bsv := l_reci_dist_tbl(1).dist_bsv;
		ELSE
			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'All the lines are balanced.');
			END IF;
			x_status := FND_API.G_RET_STS_SUCCESS;
			RETURN;
		END IF;
	END IF;
	/*  Changes for bug 8406705 End*/

    l_ccid   := -1;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Open Cursor c_dtls for initiator');
    END IF;

    OPEN c_dtls;
    FETCH c_dtls INTO l_trx_dtl_rec;
    CLOSE c_dtls;
-- Fetching the coa id of the initiator
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Fetch the initiator COA ID');
    END IF;

    SELECT l.chart_of_accounts_id
    INTO l_from_coa_id
    from gl_ledgers l
    WHERE l.ledger_id = l_trx_dtl_rec.from_ledger_id;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_from_coa_id = ' || l_from_coa_id);
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'open cursor c_chk_sla with ledger_id = ' || l_trx_dtl_rec.from_ledger_id);
     END IF;
IF (l_init_count <>1 AND l_reci_count <> 1) OR (l_init_count = 1 AND l_reci_count = 1)
THEN

    OPEN c_chk_sla (l_trx_dtl_rec.from_ledger_id);
    FETCH c_chk_sla INTO l_amb_context_code,
                         l_account_definition_code;
    CLOSE c_chk_sla;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_amb_context_code = ' || l_amb_context_code || ' l_account_definition_code = ' || l_account_definition_code);
    END IF;



-- If SLA TAB is set up then pull the value from there



    IF l_amb_context_code IS NOT NULL AND l_account_definition_code IS NOT NULL
     THEN


    -- trying to get it from TAB set up
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'open cursor c_get_bsv to fetch the bsv');
    END IF;

    -- Derive values to be passed for recipient and initiator BSV
    -- Pass value only if 1 bsv is assigned to the LE.
    OPEN c_get_bsv(l_trx_dtl_rec.from_ledger_id,
                   l_trx_dtl_rec.from_le_id,
                   l_trx_dtl_rec.gl_date);
    FETCH c_get_bsv INTO l_initiator_bsv;
    CLOSE c_get_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fetched initiator bsv = ' || l_initiator_bsv);
    END IF;


    OPEN c_get_bsv(l_trx_dtl_rec.to_ledger_id,
                   l_trx_dtl_rec.to_le_id,
                   l_trx_dtl_rec.gl_date);
    FETCH c_get_bsv INTO l_recipient_bsv;
    CLOSE c_get_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fetched recipient bsv = ' || l_recipient_bsv);
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'populating the PLSQL table fun_xla_tab_pkg.g_array_xla_tab(1)' );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_1 = ' ||  l_trx_dtl_rec.batch_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_2 = ' ||  l_trx_dtl_rec.trx_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_3 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_4 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_5 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'account_type_code = ' ||  'AGIS_INITIATOR_CLEAR_ACCOUNT');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute1 = ' ||  l_trx_dtl_rec.bat_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute10 = ' ||  l_trx_dtl_rec.bat_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute11 = ' ||  l_trx_dtl_rec.bat_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute12 = ' ||  l_trx_dtl_rec.bat_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute13 = ' ||  l_trx_dtl_rec.bat_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute14 = ' ||  l_trx_dtl_rec.bat_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute15 = ' ||  l_trx_dtl_rec.bat_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute2 = ' ||  l_trx_dtl_rec.bat_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute3 = ' ||  l_trx_dtl_rec.bat_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute4 = ' ||  l_trx_dtl_rec.bat_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute5 = ' ||  l_trx_dtl_rec.bat_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute6 = ' ||  l_trx_dtl_rec.bat_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute7 = ' ||  l_trx_dtl_rec.bat_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute8 = ' ||  l_trx_dtl_rec.bat_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute9 = ' ||  l_trx_dtl_rec.bat_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_category_code = ' ||  l_trx_dtl_rec.bat_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_currency_code = ' ||  l_trx_dtl_rec.currency_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_ledger_id = ' ||  l_trx_dtl_rec.from_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_le_id = ' ||  l_trx_dtl_rec.from_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_bsv  = ' ||  l_initiator_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_id  = ' ||  l_trx_dtl_rec.initiator_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute1  = ' ||  l_trx_dtl_rec.trx_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute2  = ' ||  l_trx_dtl_rec.trx_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute3  = ' ||  l_trx_dtl_rec.trx_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute4  = ' ||  l_trx_dtl_rec.trx_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute5  = ' ||  l_trx_dtl_rec.trx_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute6  = ' ||  l_trx_dtl_rec.trx_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute7  = ' ||  l_trx_dtl_rec.trx_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute8  = ' ||  l_trx_dtl_rec.trx_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute9  = ' ||  l_trx_dtl_rec.trx_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute10  = ' ||  l_trx_dtl_rec.trx_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute11  = ' ||  l_trx_dtl_rec.trx_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute12  = ' ||  l_trx_dtl_rec.trx_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute13  = ' ||  l_trx_dtl_rec.trx_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute14  = ' ||  l_trx_dtl_rec.trx_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute15  = ' ||  l_trx_dtl_rec.trx_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute_category  = ' ||  l_trx_dtl_rec.trx_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_bsv  = ' ||  l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_id  = ' ||  l_trx_dtl_rec.recipient_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_ledger_id  = ' ||  l_trx_dtl_rec.to_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_le_id  = ' ||  l_trx_dtl_rec.to_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_interest_accr_flag  = ' ||  l_trx_dtl_rec.allow_interest_accrual_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_invoicing_flag  = ' ||  l_trx_dtl_rec.allow_invoicing_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute1  = ' ||  l_trx_dtl_rec.typ_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute2  = ' ||  l_trx_dtl_rec.typ_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute3  = ' ||  l_trx_dtl_rec.typ_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute4  = ' ||  l_trx_dtl_rec.typ_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute5  = ' ||  l_trx_dtl_rec.typ_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute6  = ' ||  l_trx_dtl_rec.typ_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute7  = ' ||  l_trx_dtl_rec.typ_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute8  = ' ||  l_trx_dtl_rec.typ_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute9  = ' ||  l_trx_dtl_rec.typ_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute10  = ' ||  l_trx_dtl_rec.typ_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute11  = ' ||  l_trx_dtl_rec.typ_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute12  = ' ||  l_trx_dtl_rec.typ_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute13  = ' ||  l_trx_dtl_rec.typ_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute14  = ' ||  l_trx_dtl_rec.typ_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute15  = ' ||  l_trx_dtl_rec.typ_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute_category  = ' ||  l_trx_dtl_rec.typ_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_manual_approve_flag  = ' ||  l_trx_dtl_rec.manual_approve_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_trx_type_id  = ' ||  l_trx_dtl_rec.trx_type_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_vat_taxable_flag  = ' ||  l_trx_dtl_rec.vat_taxable_flag);
    END IF;

    -- Populate PLSQL Table
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_1       :=  l_trx_dtl_rec.batch_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_2       :=  l_trx_dtl_rec.trx_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_3       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_4       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_5       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).account_type_code                  :=  'AGIS_INITIATOR_CLEAR_ACCOUNT';
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute1                     :=  l_trx_dtl_rec.bat_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute10                    :=  l_trx_dtl_rec.bat_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute11                    :=  l_trx_dtl_rec.bat_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute12                    :=  l_trx_dtl_rec.bat_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute13                    :=  l_trx_dtl_rec.bat_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute14                    :=  l_trx_dtl_rec.bat_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute15                    :=  l_trx_dtl_rec.bat_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute2                     :=  l_trx_dtl_rec.bat_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute3                     :=  l_trx_dtl_rec.bat_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute4                     :=  l_trx_dtl_rec.bat_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute5                     :=  l_trx_dtl_rec.bat_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute6                     :=  l_trx_dtl_rec.bat_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute7                     :=  l_trx_dtl_rec.bat_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute8                     :=  l_trx_dtl_rec.bat_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute9                     :=  l_trx_dtl_rec.bat_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_category_code                  :=  l_trx_dtl_rec.bat_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_currency_code                  :=  l_trx_dtl_rec.currency_code;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_ledger_id                 :=  l_trx_dtl_rec.from_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_le_id                     :=  l_trx_dtl_rec.from_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_bsv                  :=  l_initiator_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_id                   :=  l_trx_dtl_rec.initiator_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute1                     :=  l_trx_dtl_rec.trx_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute10                    :=  l_trx_dtl_rec.trx_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute11                    :=  l_trx_dtl_rec.trx_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute12                    :=  l_trx_dtl_rec.trx_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute13                    :=  l_trx_dtl_rec.trx_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute14                    :=  l_trx_dtl_rec.trx_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute15                    :=  l_trx_dtl_rec.trx_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute2                     :=  l_trx_dtl_rec.trx_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute3                     :=  l_trx_dtl_rec.trx_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute4                     :=  l_trx_dtl_rec.trx_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute5                     :=  l_trx_dtl_rec.trx_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute6                     :=  l_trx_dtl_rec.trx_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute7                     :=  l_trx_dtl_rec.trx_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute8                     :=  l_trx_dtl_rec.trx_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute9                     :=  l_trx_dtl_rec.trx_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute_category             :=  l_trx_dtl_rec.trx_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_bsv                  :=  l_recipient_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_id                   :=  l_trx_dtl_rec.recipient_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_ledger_id                   :=  l_trx_dtl_rec.to_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_le_id                       :=  l_trx_dtl_rec.to_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_interest_accr_flag       :=  l_trx_dtl_rec.allow_interest_accrual_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_invoicing_flag           :=  l_trx_dtl_rec.allow_invoicing_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute1                     :=  l_trx_dtl_rec.typ_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute10                    :=  l_trx_dtl_rec.typ_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute11                    :=  l_trx_dtl_rec.typ_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute12                    :=  l_trx_dtl_rec.typ_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute13                    :=  l_trx_dtl_rec.typ_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute14                    :=  l_trx_dtl_rec.typ_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute15                    :=  l_trx_dtl_rec.typ_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute2                     :=  l_trx_dtl_rec.typ_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute3                     :=  l_trx_dtl_rec.typ_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute4                     :=  l_trx_dtl_rec.typ_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute5                     :=  l_trx_dtl_rec.typ_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute6                     :=  l_trx_dtl_rec.typ_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute7                     :=  l_trx_dtl_rec.typ_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute8                     :=  l_trx_dtl_rec.typ_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute9                     :=  l_trx_dtl_rec.typ_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute_category             :=  l_trx_dtl_rec.typ_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_manual_approve_flag            :=  l_trx_dtl_rec.manual_approve_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_trx_type_id                    :=  l_trx_dtl_rec.trx_type_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_vat_taxable_flag               :=  l_trx_dtl_rec.vat_taxable_flag;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Calling fun_xla_tab_pkg.run with following parameters');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_api_version = ' || '1.0');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_type_code = ' || 'C');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_code = ' || l_account_definition_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_transaction_coa_id = ' || l_from_coa_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_mode = ' || 'ONLINE');
     END IF;

    fun_xla_tab_pkg.run(
     p_api_version                      => 1.0
    ,p_account_definition_type_code     => 'C'
    ,p_account_definition_code          => l_account_definition_code
    ,p_transaction_coa_id               => l_from_coa_id
    ,p_mode                             => 'ONLINE'
    ,x_return_status                    => x_status
    ,x_msg_count                        => x_msg_count
    ,x_msg_data                         => x_msg_data );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg returns status ' || x_status );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_count = ' || x_msg_count );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_data = ' || x_msg_data );
     END IF;

     IF x_status = FND_API.G_RET_STS_SUCCESS
     THEN
        l_ccid :=  fun_xla_tab_pkg.g_array_xla_tab(1).target_ccid;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid =' || l_ccid);
        END IF;

     END IF;

      IF l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 7559411
        THEN
   	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is not success or l_ccid is -1 and return');
     	  END IF;
          x_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;

 END IF;

 IF l_amb_context_code IS NULL OR l_account_definition_code IS NULL OR l_ccid IS NULL THEN



    -- SLA TAB is not set up or their is an error fetching  CCID from TAB
    -- Trying to get the default ccid from Accouning Setups
    -- Generate 1 Liability account line (dist_type = 'P')
    -- Generate 1 Receivable account line (dist_type = 'R')
    -- irrespective of how many ever distributions (dist_type = 'L')
    -- are present.



    -- Generate Initiator Distributions
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'generate initiator distribution lines');
    END IF;

     IF l_init_dist_tbl(1).initiator_le_id <>  l_init_dist_tbl(1).recipient_le_id



     THEN

        -- p_to_ledger_id in this case is not really required as we
        -- are not interested in the reciprocal ccids.
        -- Hence passing it a dummy value
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intercompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_init_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_le = ' || l_init_dist_tbl(1).recipient_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_init_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'R');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
        END IF;

        fun_bal_utils_grp.get_intercompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_init_dist_tbl(1).ledger_id,
                        p_from_le           => l_init_dist_tbl(1).initiator_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_from_bsv          => l_init_bsv,
                        p_to_ledger_id      => l_reci_dist_tbl(1).ledger_id,
                        p_to_le             => l_init_dist_tbl(1).recipient_le_id,
                        p_to_bsv            => l_reci_bsv,
                        p_gl_date           => l_init_dist_tbl(1).gl_date,
                        p_acct_type         => 'R',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
     ELSE
		 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intracompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_init_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_dr_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_cr_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_init_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'D');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
        END IF;

		fun_bal_utils_grp.get_intracompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_init_dist_tbl(1).ledger_id,
                        p_from_le           => l_init_dist_tbl(1).initiator_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_dr_bsv            => l_init_bsv,
                        p_cr_bsv            => l_reci_bsv,
                        p_gl_date           => l_init_dist_tbl(1).gl_date,
                        p_acct_type         => 'D',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
     END IF;


 IF l_ccid IS NULL OR l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 6969506
     THEN
     	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is null or return status is not success and return');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_status = ' || x_status);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_count = ' || x_msg_count);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_data = ' || x_msg_data);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_reciprocal_ccid = ' || l_reciprocal_ccid);
     	END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     END IF;


  END IF;

 IF (l_init_dist_tbl(1).init_amount_cr IS NULL or to_number(l_init_dist_tbl(1).init_amount_cr)=0) and (l_init_dist_tbl(1).init_amount_dr is null or to_number(l_init_dist_tbl(1).init_amount_dr)=0 ) -- Bug No : 6969506, 7013314
      THEN
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

    -- Now build the new distribution record
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Build the initiator distribution lines');
    END IF;
    SELECT FUN_DIST_LINES_S.nextval
    INTO  l_new_dist_tbl(l_new_index).dist_id
    FROM dual;

    l_new_dist_tbl(l_new_index).line_id      :=  l_init_dist_tbl(1).line_id;
    l_new_dist_tbl(l_new_index).trx_id       :=  l_init_dist_tbl(1).trx_id;
    l_new_dist_tbl(l_new_index).dist_number  :=  l_new_dist_tbl(l_new_index).dist_id;
    l_new_dist_tbl(l_new_index).party_id     :=  l_init_dist_tbl(1).initiator_id;
    l_new_dist_tbl(l_new_index).party_type_flag  :=  'I';
    l_new_dist_tbl(l_new_index).dist_type_flag   :=  'R';
    l_new_dist_tbl(l_new_index).amount_cr    :=  l_init_dist_tbl(1).init_amount_cr;
    l_new_dist_tbl(l_new_index).amount_dr    :=  l_init_dist_tbl(1).init_amount_dr;
    l_new_dist_tbl(l_new_index).ccid         :=  l_ccid;
    l_new_dist_tbl(l_new_index).description  :=  l_init_dist_tbl(1).description;
    l_new_dist_tbl(l_new_index).auto_generate_flag  :=  'Y';
    l_new_dist_tbl(l_new_index).created_by        :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).creation_date     :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_updated_by   :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).last_update_date  :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_update_login :=  FND_GLOBAL.LOGIN_ID;

    l_new_index := l_new_index + 1;

    -- Generate Recipient Distributions


-- Fetching the coa id of the recipient


    SELECT l.chart_of_accounts_id
    INTO l_to_coa_id
    from gl_ledgers l
    WHERE l.ledger_id = l_trx_dtl_rec.to_ledger_id;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'recipient coa id = ' || l_to_coa_id);
    END IF;

--Checking whether TAB is set up for the recipient

    OPEN c_chk_sla (l_trx_dtl_rec.to_ledger_id);
    FETCH c_chk_sla INTO l_amb_context_code,
                         l_account_definition_code;
    CLOSE c_chk_sla;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Check if TAB is setup for recipient l_amb_context_code = ' || l_amb_context_code || ' l_account_definition_code = ' || l_account_definition_code);
    END IF;


  IF l_amb_context_code IS NOT NULL AND l_account_definition_code IS NOT NULL


    THEN

    -- trying to get it from TAB set up

    -- Derive values to be passed for recipient and initiator BSV
    -- Pass value only if 1 bsv is assigned to the LE.
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Derive the Initiator and recipient BSV to be passed');
    END IF;

    OPEN c_get_bsv(l_trx_dtl_rec.from_ledger_id,
                   l_trx_dtl_rec.from_le_id,
                   l_trx_dtl_rec.gl_date);
    FETCH c_get_bsv INTO l_initiator_bsv;
    CLOSE c_get_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'initiator BSV l_initiator_bsv = ' || l_initiator_bsv);
    END IF;

    OPEN c_get_bsv(l_trx_dtl_rec.to_ledger_id,
                   l_trx_dtl_rec.to_le_id,
                   l_trx_dtl_rec.gl_date);
    FETCH c_get_bsv INTO l_recipient_bsv;
    CLOSE c_get_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'recipient BSV l_recipient_bsv = ' || l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'populating the PLSQL table fun_xla_tab_pkg.g_array_xla_tab(1)' );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_1 = ' ||  l_trx_dtl_rec.batch_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_2 = ' ||  l_trx_dtl_rec.trx_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_3 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_4 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_5 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'account_type_code = ' ||  'AGIS_RECIPIENT_CLEAR_ACCOUNT');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute1 = ' ||  l_trx_dtl_rec.bat_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute10 = ' ||  l_trx_dtl_rec.bat_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute11 = ' ||  l_trx_dtl_rec.bat_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute12 = ' ||  l_trx_dtl_rec.bat_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute13 = ' ||  l_trx_dtl_rec.bat_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute14 = ' ||  l_trx_dtl_rec.bat_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute15 = ' ||  l_trx_dtl_rec.bat_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute2 = ' ||  l_trx_dtl_rec.bat_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute3 = ' ||  l_trx_dtl_rec.bat_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute4 = ' ||  l_trx_dtl_rec.bat_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute5 = ' ||  l_trx_dtl_rec.bat_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute6 = ' ||  l_trx_dtl_rec.bat_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute7 = ' ||  l_trx_dtl_rec.bat_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute8 = ' ||  l_trx_dtl_rec.bat_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute9 = ' ||  l_trx_dtl_rec.bat_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_category_code = ' ||  l_trx_dtl_rec.bat_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_currency_code = ' ||  l_trx_dtl_rec.currency_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_ledger_id = ' ||  l_trx_dtl_rec.from_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_le_id = ' ||  l_trx_dtl_rec.from_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_bsv  = ' ||  l_initiator_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_id  = ' ||  l_trx_dtl_rec.initiator_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute1  = ' ||  l_trx_dtl_rec.trx_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute2  = ' ||  l_trx_dtl_rec.trx_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute3  = ' ||  l_trx_dtl_rec.trx_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute4  = ' ||  l_trx_dtl_rec.trx_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute5  = ' ||  l_trx_dtl_rec.trx_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute6  = ' ||  l_trx_dtl_rec.trx_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute7  = ' ||  l_trx_dtl_rec.trx_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute8  = ' ||  l_trx_dtl_rec.trx_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute9  = ' ||  l_trx_dtl_rec.trx_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute10  = ' ||  l_trx_dtl_rec.trx_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute11  = ' ||  l_trx_dtl_rec.trx_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute12  = ' ||  l_trx_dtl_rec.trx_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute13  = ' ||  l_trx_dtl_rec.trx_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute14  = ' ||  l_trx_dtl_rec.trx_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute15  = ' ||  l_trx_dtl_rec.trx_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute_category  = ' ||  l_trx_dtl_rec.trx_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_bsv  = ' ||  l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_id  = ' ||  l_trx_dtl_rec.recipient_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_ledger_id  = ' ||  l_trx_dtl_rec.to_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_le_id  = ' ||  l_trx_dtl_rec.to_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_interest_accr_flag  = ' ||  l_trx_dtl_rec.allow_interest_accrual_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_invoicing_flag  = ' ||  l_trx_dtl_rec.allow_invoicing_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute1  = ' ||  l_trx_dtl_rec.typ_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute2  = ' ||  l_trx_dtl_rec.typ_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute3  = ' ||  l_trx_dtl_rec.typ_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute4  = ' ||  l_trx_dtl_rec.typ_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute5  = ' ||  l_trx_dtl_rec.typ_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute6  = ' ||  l_trx_dtl_rec.typ_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute7  = ' ||  l_trx_dtl_rec.typ_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute8  = ' ||  l_trx_dtl_rec.typ_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute9  = ' ||  l_trx_dtl_rec.typ_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute10  = ' ||  l_trx_dtl_rec.typ_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute11  = ' ||  l_trx_dtl_rec.typ_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute12  = ' ||  l_trx_dtl_rec.typ_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute13  = ' ||  l_trx_dtl_rec.typ_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute14  = ' ||  l_trx_dtl_rec.typ_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute15  = ' ||  l_trx_dtl_rec.typ_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute_category  = ' ||  l_trx_dtl_rec.typ_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_manual_approve_flag  = ' ||  l_trx_dtl_rec.manual_approve_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_trx_type_id  = ' ||  l_trx_dtl_rec.trx_type_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_vat_taxable_flag  = ' ||  l_trx_dtl_rec.vat_taxable_flag);
    END IF;

    -- Populate PLSQL Table
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_1       :=  l_trx_dtl_rec.batch_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_2       :=  l_trx_dtl_rec.trx_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_3       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_4       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_5       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).account_type_code                  :=  'AGIS_RECIPIENT_CLEAR_ACCOUNT';
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute1                     :=  l_trx_dtl_rec.bat_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute10                    :=  l_trx_dtl_rec.bat_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute11                    :=  l_trx_dtl_rec.bat_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute12                    :=  l_trx_dtl_rec.bat_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute13                    :=  l_trx_dtl_rec.bat_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute14                    :=  l_trx_dtl_rec.bat_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute15                    :=  l_trx_dtl_rec.bat_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute2                     :=  l_trx_dtl_rec.bat_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute3                     :=  l_trx_dtl_rec.bat_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute4                     :=  l_trx_dtl_rec.bat_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute5                     :=  l_trx_dtl_rec.bat_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute6                     :=  l_trx_dtl_rec.bat_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute7                     :=  l_trx_dtl_rec.bat_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute8                     :=  l_trx_dtl_rec.bat_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute9                     :=  l_trx_dtl_rec.bat_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_category_code                  :=  l_trx_dtl_rec.bat_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_currency_code                  :=  l_trx_dtl_rec.currency_code;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_ledger_id                 :=  l_trx_dtl_rec.from_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_le_id                     :=  l_trx_dtl_rec.from_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_bsv                  :=  l_initiator_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_id                   :=  l_trx_dtl_rec.initiator_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute1                     :=  l_trx_dtl_rec.trx_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute10                    :=  l_trx_dtl_rec.trx_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute11                    :=  l_trx_dtl_rec.trx_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute12                    :=  l_trx_dtl_rec.trx_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute13                    :=  l_trx_dtl_rec.trx_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute14                    :=  l_trx_dtl_rec.trx_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute15                    :=  l_trx_dtl_rec.trx_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute2                     :=  l_trx_dtl_rec.trx_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute3                     :=  l_trx_dtl_rec.trx_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute4                     :=  l_trx_dtl_rec.trx_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute5                     :=  l_trx_dtl_rec.trx_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute6                     :=  l_trx_dtl_rec.trx_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute7                     :=  l_trx_dtl_rec.trx_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute8                     :=  l_trx_dtl_rec.trx_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute9                     :=  l_trx_dtl_rec.trx_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute_category             :=  l_trx_dtl_rec.trx_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_bsv                  :=  l_recipient_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_id                   :=  l_trx_dtl_rec.recipient_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_ledger_id                   :=  l_trx_dtl_rec.to_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_le_id                       :=  l_trx_dtl_rec.to_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_interest_accr_flag       :=  l_trx_dtl_rec.allow_interest_accrual_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_invoicing_flag           :=  l_trx_dtl_rec.allow_invoicing_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute1                     :=  l_trx_dtl_rec.typ_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute10                    :=  l_trx_dtl_rec.typ_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute11                    :=  l_trx_dtl_rec.typ_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute12                    :=  l_trx_dtl_rec.typ_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute13                    :=  l_trx_dtl_rec.typ_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute14                    :=  l_trx_dtl_rec.typ_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute15                    :=  l_trx_dtl_rec.typ_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute2                     :=  l_trx_dtl_rec.typ_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute3                     :=  l_trx_dtl_rec.typ_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute4                     :=  l_trx_dtl_rec.typ_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute5                     :=  l_trx_dtl_rec.typ_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute6                     :=  l_trx_dtl_rec.typ_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute7                     :=  l_trx_dtl_rec.typ_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute8                     :=  l_trx_dtl_rec.typ_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute9                     :=  l_trx_dtl_rec.typ_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute_category             :=  l_trx_dtl_rec.typ_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_manual_approve_flag            :=  l_trx_dtl_rec.manual_approve_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_trx_type_id                    :=  l_trx_dtl_rec.trx_type_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_vat_taxable_flag               :=  l_trx_dtl_rec.vat_taxable_flag;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Calling fun_xla_tab_pkg.run with following parameters');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_api_version = ' || '1.0');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_type_code = ' || 'C');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_code = ' || l_account_definition_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_transaction_coa_id = ' || l_to_coa_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_mode = ' || 'ONLINE');
    END IF;

    fun_xla_tab_pkg.run(
     p_api_version                      => 1.0
    ,p_account_definition_type_code     => 'C'
    ,p_account_definition_code          => l_account_definition_code
    ,p_transaction_coa_id               => l_to_coa_id
    ,p_mode                             => 'ONLINE'
    ,x_return_status                    => x_status
    ,x_msg_count                        => x_msg_count
    ,x_msg_data                         => x_msg_data );

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg returns status ' || x_status );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_count = ' || x_msg_count );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_data = ' || x_msg_data );
     END IF;


     IF x_status = FND_API.G_RET_STS_SUCCESS
     THEN
        l_ccid :=  fun_xla_tab_pkg.g_array_xla_tab(1).target_ccid;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'if fun_xla_tab_pkg returns success set ccid = ' || l_ccid);
        END IF;
     END IF;

     IF l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 7559411
       THEN
 	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is not success or l_ccid is -1 and return');
     	  END IF;
          x_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

  END IF;

  IF l_amb_context_code IS NULL OR l_account_definition_code IS NULL OR l_ccid IS NULL THEN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'If TAB is not setup or ccid could not be derived then');
    END IF;
    -- SLA TAB is not set up or the ccid could not be derived from TAB Set up
    -- Trying to get the default ccid from Accouning Setups
         IF l_reci_dist_tbl(1).initiator_le_id <>  l_reci_dist_tbl(1).recipient_le_id
          THEN

			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intercompany_account with following parameters');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_reci_dist_tbl(1).initiator_le_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
                 		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_bsv = ' || l_reci_bsv);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_le = ' || l_reci_dist_tbl(1).recipient_le_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_bsv = ' || l_init_bsv);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_reci_dist_tbl(1).gl_date);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'P');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
			END IF;

          fun_bal_utils_grp.get_intercompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_reci_dist_tbl(1).ledger_id,
                        p_from_le           => l_reci_dist_tbl(1).recipient_le_id,
			p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_from_bsv          => l_reci_bsv,
                        p_to_ledger_id      => l_init_dist_tbl(1).ledger_id,
                        p_to_le             => l_reci_dist_tbl(1).initiator_le_id,
                        p_to_bsv            => l_init_bsv,
                        p_gl_date           => l_reci_dist_tbl(1).gl_date,
                        p_acct_type         => 'P',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
        ELSE

		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intracompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_reci_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_dr_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_cr_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_reci_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'D');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
		 END IF;

        fun_bal_utils_grp.get_intracompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_reci_dist_tbl(1).ledger_id,
                        p_from_le           => l_reci_dist_tbl(1).recipient_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_dr_bsv            => l_reci_bsv,
                        p_cr_bsv            => l_init_bsv,
                        p_gl_date           => l_reci_dist_tbl(1).gl_date,
                        p_acct_type         => 'C',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
      END IF;

    IF l_ccid IS NULL OR l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 6969506
      THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is null or return status is not success and return');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_status = ' || x_status);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_count = ' || x_msg_count);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_data = ' || x_msg_data);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_reciprocal_ccid = ' || l_reciprocal_ccid);
     	END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

   END IF;

IF (l_reci_dist_tbl(1).reci_amount_cr IS NULL or to_number(l_reci_dist_tbl(1).reci_amount_cr)=0) and (l_reci_dist_tbl(1).reci_amount_dr is null OR to_number(l_reci_dist_tbl(1).reci_amount_dr)=0)  -- Bug No : 6969506, 7013314
      THEN
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;


    -- Now build the new distribution record
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Build the Distribution lines');
    END IF;
    SELECT FUN_DIST_LINES_S.nextval
    INTO  l_new_dist_tbl(l_new_index).dist_id
    FROM dual;

    l_new_dist_tbl(l_new_index).line_id      :=  l_reci_dist_tbl(1).line_id;
    l_new_dist_tbl(l_new_index).trx_id       :=  l_reci_dist_tbl(1).trx_id;
    l_new_dist_tbl(l_new_index).dist_number  :=  l_new_dist_tbl(l_new_index).dist_id;
    l_new_dist_tbl(l_new_index).party_id     :=  l_reci_dist_tbl(1).recipient_id;
    l_new_dist_tbl(l_new_index).party_type_flag  :=  'R';
    l_new_dist_tbl(l_new_index).dist_type_flag   :=  'P';
    l_new_dist_tbl(l_new_index).amount_cr    :=  l_reci_dist_tbl(1).reci_amount_cr;
    l_new_dist_tbl(l_new_index).amount_dr    :=  l_reci_dist_tbl(1).reci_amount_dr;
    l_new_dist_tbl(l_new_index).ccid         :=  l_ccid;
    l_new_dist_tbl(l_new_index).description  :=  l_reci_dist_tbl(1).description;
    l_new_dist_tbl(l_new_index).auto_generate_flag  :=  'Y';
    l_new_dist_tbl(l_new_index).created_by        :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).creation_date     :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_updated_by   :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).last_update_date  :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_update_login :=  FND_GLOBAL.LOGIN_ID;

    l_new_index := l_new_index + 1;

ELSIF(l_init_count =1 AND l_reci_count <> 1)
THEN
OPEN c_bsv_level_summary (p_trx_id      => l_trx_id,
                  p_party_type  => 'R');
    FETCH c_bsv_level_summary BULK COLLECT INTO l_reci_summary_rec;
    CLOSE c_bsv_level_summary;

OPEN c_bsv_level_summary (p_trx_id      => l_trx_id,
                  p_party_type  => 'I');
    FETCH c_bsv_level_summary BULK COLLECT INTO l_init_summary_rec;
    CLOSE c_bsv_level_summary;


FOR i IN 1..l_reci_summary_rec.COUNT
LOOP
OPEN c_chk_sla (l_trx_dtl_rec.from_ledger_id);
    FETCH c_chk_sla INTO l_amb_context_code,
                         l_account_definition_code;
    CLOSE c_chk_sla;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_amb_context_code = ' || l_amb_context_code || ' l_account_definition_code = ' || l_account_definition_code);
    END IF;


-- If SLA TAB is set up then pull the value from there
    IF l_amb_context_code IS NOT NULL AND l_account_definition_code IS NOT NULL
     THEN


    -- trying to get it from TAB set up

    -- Derive values to be passed for recipient and initiator BSV
    l_initiator_bsv := l_init_summary_rec(1).dist_bsv;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fetched initiator bsv = ' || l_initiator_bsv);
    END IF;

    l_recipient_bsv := l_reci_summary_rec(i).dist_bsv;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fetched recipient bsv = ' || l_recipient_bsv);
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'populating the PLSQL table fun_xla_tab_pkg.g_array_xla_tab(1)' );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_1 = ' ||  l_trx_dtl_rec.batch_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_2 = ' ||  l_trx_dtl_rec.trx_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_3 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_4 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_5 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'account_type_code = ' ||  'AGIS_INITIATOR_CLEAR_ACCOUNT');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute1 = ' ||  l_trx_dtl_rec.bat_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute10 = ' ||  l_trx_dtl_rec.bat_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute11 = ' ||  l_trx_dtl_rec.bat_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute12 = ' ||  l_trx_dtl_rec.bat_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute13 = ' ||  l_trx_dtl_rec.bat_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute14 = ' ||  l_trx_dtl_rec.bat_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute15 = ' ||  l_trx_dtl_rec.bat_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute2 = ' ||  l_trx_dtl_rec.bat_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute3 = ' ||  l_trx_dtl_rec.bat_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute4 = ' ||  l_trx_dtl_rec.bat_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute5 = ' ||  l_trx_dtl_rec.bat_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute6 = ' ||  l_trx_dtl_rec.bat_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute7 = ' ||  l_trx_dtl_rec.bat_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute8 = ' ||  l_trx_dtl_rec.bat_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute9 = ' ||  l_trx_dtl_rec.bat_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_category_code = ' ||  l_trx_dtl_rec.bat_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_currency_code = ' ||  l_trx_dtl_rec.currency_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_ledger_id = ' ||  l_trx_dtl_rec.from_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_le_id = ' ||  l_trx_dtl_rec.from_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_bsv  = ' ||  l_initiator_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_id  = ' ||  l_trx_dtl_rec.initiator_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute1  = ' ||  l_trx_dtl_rec.trx_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute2  = ' ||  l_trx_dtl_rec.trx_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute3  = ' ||  l_trx_dtl_rec.trx_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute4  = ' ||  l_trx_dtl_rec.trx_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute5  = ' ||  l_trx_dtl_rec.trx_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute6  = ' ||  l_trx_dtl_rec.trx_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute7  = ' ||  l_trx_dtl_rec.trx_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute8  = ' ||  l_trx_dtl_rec.trx_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute9  = ' ||  l_trx_dtl_rec.trx_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute10  = ' ||  l_trx_dtl_rec.trx_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute11  = ' ||  l_trx_dtl_rec.trx_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute12  = ' ||  l_trx_dtl_rec.trx_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute13  = ' ||  l_trx_dtl_rec.trx_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute14  = ' ||  l_trx_dtl_rec.trx_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute15  = ' ||  l_trx_dtl_rec.trx_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute_category  = ' ||  l_trx_dtl_rec.trx_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_bsv  = ' ||  l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_id  = ' ||  l_trx_dtl_rec.recipient_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_ledger_id  = ' ||  l_trx_dtl_rec.to_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_le_id  = ' ||  l_trx_dtl_rec.to_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_interest_accr_flag  = ' ||  l_trx_dtl_rec.allow_interest_accrual_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_invoicing_flag  = ' ||  l_trx_dtl_rec.allow_invoicing_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute1  = ' ||  l_trx_dtl_rec.typ_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute2  = ' ||  l_trx_dtl_rec.typ_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute3  = ' ||  l_trx_dtl_rec.typ_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute4  = ' ||  l_trx_dtl_rec.typ_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute5  = ' ||  l_trx_dtl_rec.typ_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute6  = ' ||  l_trx_dtl_rec.typ_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute7  = ' ||  l_trx_dtl_rec.typ_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute8  = ' ||  l_trx_dtl_rec.typ_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute9  = ' ||  l_trx_dtl_rec.typ_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute10  = ' ||  l_trx_dtl_rec.typ_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute11  = ' ||  l_trx_dtl_rec.typ_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute12  = ' ||  l_trx_dtl_rec.typ_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute13  = ' ||  l_trx_dtl_rec.typ_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute14  = ' ||  l_trx_dtl_rec.typ_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute15  = ' ||  l_trx_dtl_rec.typ_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute_category  = ' ||  l_trx_dtl_rec.typ_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_manual_approve_flag  = ' ||  l_trx_dtl_rec.manual_approve_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_trx_type_id  = ' ||  l_trx_dtl_rec.trx_type_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_vat_taxable_flag  = ' ||  l_trx_dtl_rec.vat_taxable_flag);
    END IF;

    -- Populate PLSQL Table
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_1       :=  l_trx_dtl_rec.batch_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_2       :=  l_trx_dtl_rec.trx_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_3       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_4       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_5       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).account_type_code                  :=  'AGIS_INITIATOR_CLEAR_ACCOUNT';
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute1                     :=  l_trx_dtl_rec.bat_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute10                    :=  l_trx_dtl_rec.bat_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute11                    :=  l_trx_dtl_rec.bat_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute12                    :=  l_trx_dtl_rec.bat_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute13                    :=  l_trx_dtl_rec.bat_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute14                    :=  l_trx_dtl_rec.bat_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute15                    :=  l_trx_dtl_rec.bat_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute2                     :=  l_trx_dtl_rec.bat_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute3                     :=  l_trx_dtl_rec.bat_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute4                     :=  l_trx_dtl_rec.bat_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute5                     :=  l_trx_dtl_rec.bat_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute6                     :=  l_trx_dtl_rec.bat_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute7                     :=  l_trx_dtl_rec.bat_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute8                     :=  l_trx_dtl_rec.bat_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute9                     :=  l_trx_dtl_rec.bat_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_category_code                  :=  l_trx_dtl_rec.bat_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_currency_code                  :=  l_trx_dtl_rec.currency_code;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_ledger_id                 :=  l_trx_dtl_rec.from_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_le_id                     :=  l_trx_dtl_rec.from_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_bsv                  :=  l_initiator_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_id                   :=  l_trx_dtl_rec.initiator_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute1                     :=  l_trx_dtl_rec.trx_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute10                    :=  l_trx_dtl_rec.trx_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute11                    :=  l_trx_dtl_rec.trx_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute12                    :=  l_trx_dtl_rec.trx_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute13                    :=  l_trx_dtl_rec.trx_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute14                    :=  l_trx_dtl_rec.trx_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute15                    :=  l_trx_dtl_rec.trx_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute2                     :=  l_trx_dtl_rec.trx_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute3                     :=  l_trx_dtl_rec.trx_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute4                     :=  l_trx_dtl_rec.trx_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute5                     :=  l_trx_dtl_rec.trx_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute6                     :=  l_trx_dtl_rec.trx_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute7                     :=  l_trx_dtl_rec.trx_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute8                     :=  l_trx_dtl_rec.trx_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute9                     :=  l_trx_dtl_rec.trx_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute_category             :=  l_trx_dtl_rec.trx_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_bsv                  :=  l_recipient_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_id                   :=  l_trx_dtl_rec.recipient_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_ledger_id                   :=  l_trx_dtl_rec.to_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_le_id                       :=  l_trx_dtl_rec.to_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_interest_accr_flag       :=  l_trx_dtl_rec.allow_interest_accrual_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_invoicing_flag           :=  l_trx_dtl_rec.allow_invoicing_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute1                     :=  l_trx_dtl_rec.typ_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute10                    :=  l_trx_dtl_rec.typ_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute11                    :=  l_trx_dtl_rec.typ_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute12                    :=  l_trx_dtl_rec.typ_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute13                    :=  l_trx_dtl_rec.typ_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute14                    :=  l_trx_dtl_rec.typ_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute15                    :=  l_trx_dtl_rec.typ_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute2                     :=  l_trx_dtl_rec.typ_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute3                     :=  l_trx_dtl_rec.typ_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute4                     :=  l_trx_dtl_rec.typ_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute5                     :=  l_trx_dtl_rec.typ_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute6                     :=  l_trx_dtl_rec.typ_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute7                     :=  l_trx_dtl_rec.typ_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute8                     :=  l_trx_dtl_rec.typ_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute9                     :=  l_trx_dtl_rec.typ_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute_category             :=  l_trx_dtl_rec.typ_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_manual_approve_flag            :=  l_trx_dtl_rec.manual_approve_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_trx_type_id                    :=  l_trx_dtl_rec.trx_type_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_vat_taxable_flag               :=  l_trx_dtl_rec.vat_taxable_flag;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Calling fun_xla_tab_pkg.run with following parameters');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_api_version = ' || '1.0');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_type_code = ' || 'C');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_code = ' || l_account_definition_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_transaction_coa_id = ' || l_from_coa_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_mode = ' || 'ONLINE');
     END IF;

    fun_xla_tab_pkg.run(
     p_api_version                      => 1.0
    ,p_account_definition_type_code     => 'C'
    ,p_account_definition_code          => l_account_definition_code
    ,p_transaction_coa_id               => l_from_coa_id
    ,p_mode                             => 'ONLINE'
    ,x_return_status                    => x_status
    ,x_msg_count                        => x_msg_count
    ,x_msg_data                         => x_msg_data );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg returns status ' || x_status );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_count = ' || x_msg_count );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_data = ' || x_msg_data );
     END IF;

     IF x_status = FND_API.G_RET_STS_SUCCESS
     THEN
        l_ccid :=  fun_xla_tab_pkg.g_array_xla_tab(1).target_ccid;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid =' || l_ccid);
        END IF;

     END IF;

      IF l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 7559411
        THEN
   	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is not success or l_ccid is -1 and return');
     	  END IF;
          x_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;

 END IF;

 IF l_amb_context_code IS NULL OR l_account_definition_code IS NULL OR l_ccid IS NULL THEN



    -- SLA TAB is not set up or their is an error fetching  CCID from TAB
    -- Trying to get the default ccid from Accouning Setups
    -- Generate 1 Liability account line (dist_type = 'P')
    -- Generate 1 Receivable account line (dist_type = 'R')
    -- irrespective of how many ever distributions (dist_type = 'L')
    -- are present.

    l_init_bsv  :=l_init_summary_rec(1).dist_bsv;
    l_reci_bsv  :=l_reci_summary_rec(i).dist_bsv;
    -- Generate Initiator Distributions
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'generate initiator distribution lines');
    END IF;

     IF l_init_dist_tbl(1).initiator_le_id <>  l_init_dist_tbl(1).recipient_le_id



     THEN

        -- p_to_ledger_id in this case is not really required as we
        -- are not interested in the reciprocal ccids.
        -- Hence passing it a dummy value
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intercompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_init_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_le = ' || l_init_dist_tbl(1).recipient_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_init_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'R');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
        END IF;

        fun_bal_utils_grp.get_intercompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_init_dist_tbl(1).ledger_id,
                        p_from_le           => l_init_dist_tbl(1).initiator_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_from_bsv          => l_init_bsv,
                        p_to_ledger_id      => l_reci_dist_tbl(1).ledger_id,
                        p_to_le             => l_init_dist_tbl(1).recipient_le_id,
                        p_to_bsv            => l_reci_bsv,
                        p_gl_date           => l_init_dist_tbl(1).gl_date,
                        p_acct_type         => 'R',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
     ELSE
		 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intracompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_init_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_dr_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_cr_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_init_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'D');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
        END IF;

		fun_bal_utils_grp.get_intracompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_init_dist_tbl(1).ledger_id,
                        p_from_le           => l_init_dist_tbl(1).initiator_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_dr_bsv            => l_init_bsv,
                        p_cr_bsv            => l_reci_bsv,
                        p_gl_date           => l_init_dist_tbl(1).gl_date,
                        p_acct_type         => 'D',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
     END IF;


 IF l_ccid IS NULL OR l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 6969506
     THEN
     	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is null or return status is not success and return');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_status = ' || x_status);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_count = ' || x_msg_count);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_data = ' || x_msg_data);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_reciprocal_ccid = ' || l_reciprocal_ccid);
     	END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     END IF;


  END IF;

 IF (l_init_dist_tbl(1).init_amount_cr IS NULL or to_number(l_init_dist_tbl(1).init_amount_cr)=0) and (l_init_dist_tbl(1).init_amount_dr is null or to_number(l_init_dist_tbl(1).init_amount_dr)=0 ) -- Bug No : 6969506, 7013314
      THEN
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

    -- Now build the new distribution record
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Build the initiator distribution lines');
    END IF;
    SELECT FUN_DIST_LINES_S.nextval
    INTO  l_new_dist_tbl(l_new_index).dist_id
    FROM dual;

    l_new_dist_tbl(l_new_index).line_id      :=  l_init_dist_tbl(1).line_id;
    l_new_dist_tbl(l_new_index).trx_id       :=  l_init_dist_tbl(1).trx_id;
    l_new_dist_tbl(l_new_index).dist_number  :=  l_new_dist_tbl(l_new_index).dist_id;
    l_new_dist_tbl(l_new_index).party_id     :=  l_init_dist_tbl(1).initiator_id;
    l_new_dist_tbl(l_new_index).party_type_flag  :=  'I';
    l_new_dist_tbl(l_new_index).dist_type_flag   :=  'R';
    l_new_dist_tbl(l_new_index).amount_cr    :=  l_reci_summary_rec(i).amount_cr;
    l_new_dist_tbl(l_new_index).amount_dr    :=  l_reci_summary_rec(i).amount_dr;
    l_new_dist_tbl(l_new_index).ccid         :=  l_ccid;
    l_new_dist_tbl(l_new_index).description  :=  l_init_dist_tbl(1).description;
    l_new_dist_tbl(l_new_index).auto_generate_flag  :=  'Y';
    l_new_dist_tbl(l_new_index).created_by        :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).creation_date     :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_updated_by   :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).last_update_date  :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_update_login :=  FND_GLOBAL.LOGIN_ID;

    l_new_index := l_new_index + 1;

    -- Generate Recipient Distributions


-- Fetching the coa id of the recipient


    SELECT l.chart_of_accounts_id
    INTO l_to_coa_id
    from gl_ledgers l
    WHERE l.ledger_id = l_trx_dtl_rec.to_ledger_id;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'recipient coa id = ' || l_to_coa_id);
    END IF;

--Checking whether TAB is set up for the recipient

    OPEN c_chk_sla (l_trx_dtl_rec.to_ledger_id);
    FETCH c_chk_sla INTO l_amb_context_code,
                         l_account_definition_code;
    CLOSE c_chk_sla;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Check if TAB is setup for recipient l_amb_context_code = ' || l_amb_context_code || ' l_account_definition_code = ' || l_account_definition_code);
    END IF;


  IF l_amb_context_code IS NOT NULL AND l_account_definition_code IS NOT NULL


    THEN

    -- trying to get it from TAB set up

    -- Derive values to be passed for recipient and initiator BSV
    -- Pass value only if 1 bsv is assigned to the LE.
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Derive the Initiator and recipient BSV to be passed');
    END IF;

    l_initiator_bsv := l_init_summary_rec(1).dist_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'initiator BSV l_initiator_bsv = ' || l_initiator_bsv);
    END IF;

    l_recipient_bsv := l_reci_summary_rec(i).dist_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'recipient BSV l_recipient_bsv = ' || l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'populating the PLSQL table fun_xla_tab_pkg.g_array_xla_tab(1)' );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_1 = ' ||  l_trx_dtl_rec.batch_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_2 = ' ||  l_trx_dtl_rec.trx_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_3 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_4 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_5 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'account_type_code = ' ||  'AGIS_RECIPIENT_CLEAR_ACCOUNT');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute1 = ' ||  l_trx_dtl_rec.bat_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute10 = ' ||  l_trx_dtl_rec.bat_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute11 = ' ||  l_trx_dtl_rec.bat_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute12 = ' ||  l_trx_dtl_rec.bat_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute13 = ' ||  l_trx_dtl_rec.bat_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute14 = ' ||  l_trx_dtl_rec.bat_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute15 = ' ||  l_trx_dtl_rec.bat_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute2 = ' ||  l_trx_dtl_rec.bat_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute3 = ' ||  l_trx_dtl_rec.bat_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute4 = ' ||  l_trx_dtl_rec.bat_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute5 = ' ||  l_trx_dtl_rec.bat_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute6 = ' ||  l_trx_dtl_rec.bat_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute7 = ' ||  l_trx_dtl_rec.bat_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute8 = ' ||  l_trx_dtl_rec.bat_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute9 = ' ||  l_trx_dtl_rec.bat_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_category_code = ' ||  l_trx_dtl_rec.bat_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_currency_code = ' ||  l_trx_dtl_rec.currency_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_ledger_id = ' ||  l_trx_dtl_rec.from_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_le_id = ' ||  l_trx_dtl_rec.from_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_bsv  = ' ||  l_initiator_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_id  = ' ||  l_trx_dtl_rec.initiator_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute1  = ' ||  l_trx_dtl_rec.trx_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute2  = ' ||  l_trx_dtl_rec.trx_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute3  = ' ||  l_trx_dtl_rec.trx_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute4  = ' ||  l_trx_dtl_rec.trx_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute5  = ' ||  l_trx_dtl_rec.trx_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute6  = ' ||  l_trx_dtl_rec.trx_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute7  = ' ||  l_trx_dtl_rec.trx_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute8  = ' ||  l_trx_dtl_rec.trx_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute9  = ' ||  l_trx_dtl_rec.trx_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute10  = ' ||  l_trx_dtl_rec.trx_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute11  = ' ||  l_trx_dtl_rec.trx_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute12  = ' ||  l_trx_dtl_rec.trx_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute13  = ' ||  l_trx_dtl_rec.trx_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute14  = ' ||  l_trx_dtl_rec.trx_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute15  = ' ||  l_trx_dtl_rec.trx_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute_category  = ' ||  l_trx_dtl_rec.trx_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_bsv  = ' ||  l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_id  = ' ||  l_trx_dtl_rec.recipient_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_ledger_id  = ' ||  l_trx_dtl_rec.to_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_le_id  = ' ||  l_trx_dtl_rec.to_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_interest_accr_flag  = ' ||  l_trx_dtl_rec.allow_interest_accrual_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_invoicing_flag  = ' ||  l_trx_dtl_rec.allow_invoicing_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute1  = ' ||  l_trx_dtl_rec.typ_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute2  = ' ||  l_trx_dtl_rec.typ_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute3  = ' ||  l_trx_dtl_rec.typ_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute4  = ' ||  l_trx_dtl_rec.typ_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute5  = ' ||  l_trx_dtl_rec.typ_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute6  = ' ||  l_trx_dtl_rec.typ_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute7  = ' ||  l_trx_dtl_rec.typ_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute8  = ' ||  l_trx_dtl_rec.typ_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute9  = ' ||  l_trx_dtl_rec.typ_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute10  = ' ||  l_trx_dtl_rec.typ_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute11  = ' ||  l_trx_dtl_rec.typ_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute12  = ' ||  l_trx_dtl_rec.typ_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute13  = ' ||  l_trx_dtl_rec.typ_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute14  = ' ||  l_trx_dtl_rec.typ_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute15  = ' ||  l_trx_dtl_rec.typ_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute_category  = ' ||  l_trx_dtl_rec.typ_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_manual_approve_flag  = ' ||  l_trx_dtl_rec.manual_approve_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_trx_type_id  = ' ||  l_trx_dtl_rec.trx_type_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_vat_taxable_flag  = ' ||  l_trx_dtl_rec.vat_taxable_flag);
    END IF;

    -- Populate PLSQL Table
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_1       :=  l_trx_dtl_rec.batch_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_2       :=  l_trx_dtl_rec.trx_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_3       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_4       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_5       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).account_type_code                  :=  'AGIS_RECIPIENT_CLEAR_ACCOUNT';
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute1                     :=  l_trx_dtl_rec.bat_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute10                    :=  l_trx_dtl_rec.bat_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute11                    :=  l_trx_dtl_rec.bat_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute12                    :=  l_trx_dtl_rec.bat_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute13                    :=  l_trx_dtl_rec.bat_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute14                    :=  l_trx_dtl_rec.bat_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute15                    :=  l_trx_dtl_rec.bat_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute2                     :=  l_trx_dtl_rec.bat_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute3                     :=  l_trx_dtl_rec.bat_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute4                     :=  l_trx_dtl_rec.bat_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute5                     :=  l_trx_dtl_rec.bat_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute6                     :=  l_trx_dtl_rec.bat_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute7                     :=  l_trx_dtl_rec.bat_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute8                     :=  l_trx_dtl_rec.bat_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute9                     :=  l_trx_dtl_rec.bat_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_category_code                  :=  l_trx_dtl_rec.bat_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_currency_code                  :=  l_trx_dtl_rec.currency_code;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_ledger_id                 :=  l_trx_dtl_rec.from_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_le_id                     :=  l_trx_dtl_rec.from_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_bsv                  :=  l_initiator_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_id                   :=  l_trx_dtl_rec.initiator_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute1                     :=  l_trx_dtl_rec.trx_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute10                    :=  l_trx_dtl_rec.trx_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute11                    :=  l_trx_dtl_rec.trx_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute12                    :=  l_trx_dtl_rec.trx_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute13                    :=  l_trx_dtl_rec.trx_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute14                    :=  l_trx_dtl_rec.trx_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute15                    :=  l_trx_dtl_rec.trx_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute2                     :=  l_trx_dtl_rec.trx_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute3                     :=  l_trx_dtl_rec.trx_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute4                     :=  l_trx_dtl_rec.trx_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute5                     :=  l_trx_dtl_rec.trx_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute6                     :=  l_trx_dtl_rec.trx_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute7                     :=  l_trx_dtl_rec.trx_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute8                     :=  l_trx_dtl_rec.trx_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute9                     :=  l_trx_dtl_rec.trx_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute_category             :=  l_trx_dtl_rec.trx_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_bsv                  :=  l_recipient_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_id                   :=  l_trx_dtl_rec.recipient_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_ledger_id                   :=  l_trx_dtl_rec.to_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_le_id                       :=  l_trx_dtl_rec.to_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_interest_accr_flag       :=  l_trx_dtl_rec.allow_interest_accrual_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_invoicing_flag           :=  l_trx_dtl_rec.allow_invoicing_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute1                     :=  l_trx_dtl_rec.typ_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute10                    :=  l_trx_dtl_rec.typ_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute11                    :=  l_trx_dtl_rec.typ_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute12                    :=  l_trx_dtl_rec.typ_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute13                    :=  l_trx_dtl_rec.typ_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute14                    :=  l_trx_dtl_rec.typ_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute15                    :=  l_trx_dtl_rec.typ_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute2                     :=  l_trx_dtl_rec.typ_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute3                     :=  l_trx_dtl_rec.typ_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute4                     :=  l_trx_dtl_rec.typ_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute5                     :=  l_trx_dtl_rec.typ_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute6                     :=  l_trx_dtl_rec.typ_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute7                     :=  l_trx_dtl_rec.typ_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute8                     :=  l_trx_dtl_rec.typ_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute9                     :=  l_trx_dtl_rec.typ_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute_category             :=  l_trx_dtl_rec.typ_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_manual_approve_flag            :=  l_trx_dtl_rec.manual_approve_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_trx_type_id                    :=  l_trx_dtl_rec.trx_type_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_vat_taxable_flag               :=  l_trx_dtl_rec.vat_taxable_flag;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Calling fun_xla_tab_pkg.run with following parameters');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_api_version = ' || '1.0');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_type_code = ' || 'C');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_code = ' || l_account_definition_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_transaction_coa_id = ' || l_to_coa_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_mode = ' || 'ONLINE');
    END IF;

    fun_xla_tab_pkg.run(
     p_api_version                      => 1.0
    ,p_account_definition_type_code     => 'C'
    ,p_account_definition_code          => l_account_definition_code
    ,p_transaction_coa_id               => l_to_coa_id
    ,p_mode                             => 'ONLINE'
    ,x_return_status                    => x_status
    ,x_msg_count                        => x_msg_count
    ,x_msg_data                         => x_msg_data );

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg returns status ' || x_status );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_count = ' || x_msg_count );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_data = ' || x_msg_data );
     END IF;


     IF x_status = FND_API.G_RET_STS_SUCCESS
     THEN
        l_ccid :=  fun_xla_tab_pkg.g_array_xla_tab(1).target_ccid;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'if fun_xla_tab_pkg returns success set ccid = ' || l_ccid);
        END IF;
     END IF;

     IF l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 7559411
       THEN
 	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is not success or l_ccid is -1 and return');
     	  END IF;
          x_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

  END IF;

  IF l_amb_context_code IS NULL OR l_account_definition_code IS NULL OR l_ccid IS NULL THEN
    l_init_bsv  :=l_init_summary_rec(1).dist_bsv;
    l_reci_bsv  :=l_reci_summary_rec(i).dist_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'If TAB is not setup or ccid could not be derived then');
    END IF;
    -- SLA TAB is not set up or the ccid could not be derived from TAB Set up
    -- Trying to get the default ccid from Accouning Setups
         IF l_reci_dist_tbl(1).initiator_le_id <>  l_reci_dist_tbl(1).recipient_le_id
          THEN

			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intercompany_account with following parameters');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_reci_dist_tbl(1).initiator_le_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
                 		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_bsv = ' || l_reci_bsv);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_le = ' || l_reci_dist_tbl(1).recipient_le_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_bsv = ' || l_init_bsv);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_reci_dist_tbl(1).gl_date);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'P');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
			END IF;

          fun_bal_utils_grp.get_intercompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_reci_dist_tbl(1).ledger_id,
                        p_from_le           => l_reci_dist_tbl(1).recipient_le_id,
			                  p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_from_bsv          => l_reci_bsv,
                        p_to_ledger_id      => l_init_dist_tbl(1).ledger_id,
                        p_to_le             => l_reci_dist_tbl(1).initiator_le_id,
                        p_to_bsv            => l_init_bsv,
                        p_gl_date           => l_reci_dist_tbl(1).gl_date,
                        p_acct_type         => 'P',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
        ELSE

		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intracompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_reci_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_dr_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_cr_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_reci_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'D');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
		 END IF;

        fun_bal_utils_grp.get_intracompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_reci_dist_tbl(1).ledger_id,
                        p_from_le           => l_reci_dist_tbl(1).recipient_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_dr_bsv            => l_reci_bsv,
                        p_cr_bsv            => l_init_bsv,
                        p_gl_date           => l_reci_dist_tbl(1).gl_date,
                        p_acct_type         => 'C',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
      END IF;

    IF l_ccid IS NULL OR l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 6969506
      THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is null or return status is not success and return');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_status = ' || x_status);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_count = ' || x_msg_count);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_data = ' || x_msg_data);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_reciprocal_ccid = ' || l_reciprocal_ccid);
     	END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

   END IF;

IF (l_reci_dist_tbl(1).reci_amount_cr IS NULL or to_number(l_reci_dist_tbl(1).reci_amount_cr)=0) and (l_reci_dist_tbl(1).reci_amount_dr is null OR to_number(l_reci_dist_tbl(1).reci_amount_dr)=0)  -- Bug No : 6969506, 7013314
      THEN
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;


    -- Now build the new distribution record
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Build the Distribution lines');
    END IF;
    SELECT FUN_DIST_LINES_S.nextval
    INTO  l_new_dist_tbl(l_new_index).dist_id
    FROM dual;

    l_new_dist_tbl(l_new_index).line_id      :=  l_reci_dist_tbl(1).line_id;
    l_new_dist_tbl(l_new_index).trx_id       :=  l_reci_dist_tbl(1).trx_id;
    l_new_dist_tbl(l_new_index).dist_number  :=  l_new_dist_tbl(l_new_index).dist_id;
    l_new_dist_tbl(l_new_index).party_id     :=  l_reci_dist_tbl(1).recipient_id;
    l_new_dist_tbl(l_new_index).party_type_flag  :=  'R';
    l_new_dist_tbl(l_new_index).dist_type_flag   :=  'P';
    l_new_dist_tbl(l_new_index).amount_cr    :=  l_reci_summary_rec(i).amount_dr;
    l_new_dist_tbl(l_new_index).amount_dr    :=  l_reci_summary_rec(i).amount_cr;
    l_new_dist_tbl(l_new_index).ccid         :=  l_ccid;
    l_new_dist_tbl(l_new_index).description  :=  l_reci_dist_tbl(1).description;
    l_new_dist_tbl(l_new_index).auto_generate_flag  :=  'Y';
    l_new_dist_tbl(l_new_index).created_by        :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).creation_date     :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_updated_by   :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).last_update_date  :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_update_login :=  FND_GLOBAL.LOGIN_ID;

    l_new_index := l_new_index + 1;
END LOOP;
ELSIF(l_init_count <> 1 AND l_reci_count = 1)
THEN
OPEN c_bsv_level_summary (p_trx_id      => l_trx_id,
                  p_party_type  => 'R');
    FETCH c_bsv_level_summary BULK COLLECT INTO l_reci_summary_rec;
    CLOSE c_bsv_level_summary;

OPEN c_bsv_level_summary (p_trx_id      => l_trx_id,
                  p_party_type  => 'I');
    FETCH c_bsv_level_summary BULK COLLECT INTO l_init_summary_rec;
    CLOSE c_bsv_level_summary;


FOR i IN 1..l_init_summary_rec.COUNT
LOOP

OPEN c_chk_sla (l_trx_dtl_rec.from_ledger_id);
    FETCH c_chk_sla INTO l_amb_context_code,
                         l_account_definition_code;
    CLOSE c_chk_sla;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_amb_context_code = ' || l_amb_context_code || ' l_account_definition_code = ' || l_account_definition_code);
    END IF;


-- If SLA TAB is set up then pull the value from there
    IF l_amb_context_code IS NOT NULL AND l_account_definition_code IS NOT NULL
     THEN


    -- trying to get it from TAB set up

    -- Derive values to be passed for recipient and initiator BSV
    l_initiator_bsv := l_init_summary_rec(i).dist_bsv;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fetched initiator bsv = ' || l_initiator_bsv);
    END IF;

    l_recipient_bsv := l_reci_summary_rec(1).dist_bsv;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fetched recipient bsv = ' || l_recipient_bsv);
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'populating the PLSQL table fun_xla_tab_pkg.g_array_xla_tab(1)' );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_1 = ' ||  l_trx_dtl_rec.batch_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_2 = ' ||  l_trx_dtl_rec.trx_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_3 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_4 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_5 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'account_type_code = ' ||  'AGIS_INITIATOR_CLEAR_ACCOUNT');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute1 = ' ||  l_trx_dtl_rec.bat_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute10 = ' ||  l_trx_dtl_rec.bat_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute11 = ' ||  l_trx_dtl_rec.bat_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute12 = ' ||  l_trx_dtl_rec.bat_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute13 = ' ||  l_trx_dtl_rec.bat_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute14 = ' ||  l_trx_dtl_rec.bat_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute15 = ' ||  l_trx_dtl_rec.bat_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute2 = ' ||  l_trx_dtl_rec.bat_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute3 = ' ||  l_trx_dtl_rec.bat_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute4 = ' ||  l_trx_dtl_rec.bat_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute5 = ' ||  l_trx_dtl_rec.bat_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute6 = ' ||  l_trx_dtl_rec.bat_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute7 = ' ||  l_trx_dtl_rec.bat_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute8 = ' ||  l_trx_dtl_rec.bat_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute9 = ' ||  l_trx_dtl_rec.bat_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_category_code = ' ||  l_trx_dtl_rec.bat_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_currency_code = ' ||  l_trx_dtl_rec.currency_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_ledger_id = ' ||  l_trx_dtl_rec.from_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_le_id = ' ||  l_trx_dtl_rec.from_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_bsv  = ' ||  l_initiator_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_id  = ' ||  l_trx_dtl_rec.initiator_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute1  = ' ||  l_trx_dtl_rec.trx_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute2  = ' ||  l_trx_dtl_rec.trx_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute3  = ' ||  l_trx_dtl_rec.trx_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute4  = ' ||  l_trx_dtl_rec.trx_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute5  = ' ||  l_trx_dtl_rec.trx_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute6  = ' ||  l_trx_dtl_rec.trx_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute7  = ' ||  l_trx_dtl_rec.trx_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute8  = ' ||  l_trx_dtl_rec.trx_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute9  = ' ||  l_trx_dtl_rec.trx_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute10  = ' ||  l_trx_dtl_rec.trx_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute11  = ' ||  l_trx_dtl_rec.trx_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute12  = ' ||  l_trx_dtl_rec.trx_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute13  = ' ||  l_trx_dtl_rec.trx_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute14  = ' ||  l_trx_dtl_rec.trx_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute15  = ' ||  l_trx_dtl_rec.trx_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute_category  = ' ||  l_trx_dtl_rec.trx_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_bsv  = ' ||  l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_id  = ' ||  l_trx_dtl_rec.recipient_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_ledger_id  = ' ||  l_trx_dtl_rec.to_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_le_id  = ' ||  l_trx_dtl_rec.to_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_interest_accr_flag  = ' ||  l_trx_dtl_rec.allow_interest_accrual_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_invoicing_flag  = ' ||  l_trx_dtl_rec.allow_invoicing_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute1  = ' ||  l_trx_dtl_rec.typ_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute2  = ' ||  l_trx_dtl_rec.typ_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute3  = ' ||  l_trx_dtl_rec.typ_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute4  = ' ||  l_trx_dtl_rec.typ_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute5  = ' ||  l_trx_dtl_rec.typ_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute6  = ' ||  l_trx_dtl_rec.typ_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute7  = ' ||  l_trx_dtl_rec.typ_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute8  = ' ||  l_trx_dtl_rec.typ_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute9  = ' ||  l_trx_dtl_rec.typ_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute10  = ' ||  l_trx_dtl_rec.typ_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute11  = ' ||  l_trx_dtl_rec.typ_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute12  = ' ||  l_trx_dtl_rec.typ_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute13  = ' ||  l_trx_dtl_rec.typ_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute14  = ' ||  l_trx_dtl_rec.typ_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute15  = ' ||  l_trx_dtl_rec.typ_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute_category  = ' ||  l_trx_dtl_rec.typ_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_manual_approve_flag  = ' ||  l_trx_dtl_rec.manual_approve_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_trx_type_id  = ' ||  l_trx_dtl_rec.trx_type_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_vat_taxable_flag  = ' ||  l_trx_dtl_rec.vat_taxable_flag);
    END IF;

    -- Populate PLSQL Table
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_1       :=  l_trx_dtl_rec.batch_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_2       :=  l_trx_dtl_rec.trx_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_3       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_4       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_5       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).account_type_code                  :=  'AGIS_INITIATOR_CLEAR_ACCOUNT';
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute1                     :=  l_trx_dtl_rec.bat_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute10                    :=  l_trx_dtl_rec.bat_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute11                    :=  l_trx_dtl_rec.bat_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute12                    :=  l_trx_dtl_rec.bat_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute13                    :=  l_trx_dtl_rec.bat_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute14                    :=  l_trx_dtl_rec.bat_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute15                    :=  l_trx_dtl_rec.bat_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute2                     :=  l_trx_dtl_rec.bat_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute3                     :=  l_trx_dtl_rec.bat_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute4                     :=  l_trx_dtl_rec.bat_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute5                     :=  l_trx_dtl_rec.bat_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute6                     :=  l_trx_dtl_rec.bat_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute7                     :=  l_trx_dtl_rec.bat_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute8                     :=  l_trx_dtl_rec.bat_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute9                     :=  l_trx_dtl_rec.bat_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_category_code                  :=  l_trx_dtl_rec.bat_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_currency_code                  :=  l_trx_dtl_rec.currency_code;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_ledger_id                 :=  l_trx_dtl_rec.from_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_le_id                     :=  l_trx_dtl_rec.from_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_bsv                  :=  l_initiator_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_id                   :=  l_trx_dtl_rec.initiator_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute1                     :=  l_trx_dtl_rec.trx_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute10                    :=  l_trx_dtl_rec.trx_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute11                    :=  l_trx_dtl_rec.trx_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute12                    :=  l_trx_dtl_rec.trx_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute13                    :=  l_trx_dtl_rec.trx_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute14                    :=  l_trx_dtl_rec.trx_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute15                    :=  l_trx_dtl_rec.trx_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute2                     :=  l_trx_dtl_rec.trx_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute3                     :=  l_trx_dtl_rec.trx_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute4                     :=  l_trx_dtl_rec.trx_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute5                     :=  l_trx_dtl_rec.trx_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute6                     :=  l_trx_dtl_rec.trx_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute7                     :=  l_trx_dtl_rec.trx_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute8                     :=  l_trx_dtl_rec.trx_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute9                     :=  l_trx_dtl_rec.trx_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute_category             :=  l_trx_dtl_rec.trx_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_bsv                  :=  l_recipient_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_id                   :=  l_trx_dtl_rec.recipient_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_ledger_id                   :=  l_trx_dtl_rec.to_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_le_id                       :=  l_trx_dtl_rec.to_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_interest_accr_flag       :=  l_trx_dtl_rec.allow_interest_accrual_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_invoicing_flag           :=  l_trx_dtl_rec.allow_invoicing_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute1                     :=  l_trx_dtl_rec.typ_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute10                    :=  l_trx_dtl_rec.typ_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute11                    :=  l_trx_dtl_rec.typ_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute12                    :=  l_trx_dtl_rec.typ_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute13                    :=  l_trx_dtl_rec.typ_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute14                    :=  l_trx_dtl_rec.typ_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute15                    :=  l_trx_dtl_rec.typ_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute2                     :=  l_trx_dtl_rec.typ_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute3                     :=  l_trx_dtl_rec.typ_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute4                     :=  l_trx_dtl_rec.typ_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute5                     :=  l_trx_dtl_rec.typ_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute6                     :=  l_trx_dtl_rec.typ_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute7                     :=  l_trx_dtl_rec.typ_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute8                     :=  l_trx_dtl_rec.typ_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute9                     :=  l_trx_dtl_rec.typ_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute_category             :=  l_trx_dtl_rec.typ_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_manual_approve_flag            :=  l_trx_dtl_rec.manual_approve_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_trx_type_id                    :=  l_trx_dtl_rec.trx_type_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_vat_taxable_flag               :=  l_trx_dtl_rec.vat_taxable_flag;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Calling fun_xla_tab_pkg.run with following parameters');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_api_version = ' || '1.0');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_type_code = ' || 'C');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_code = ' || l_account_definition_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_transaction_coa_id = ' || l_from_coa_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_mode = ' || 'ONLINE');
     END IF;

    fun_xla_tab_pkg.run(
     p_api_version                      => 1.0
    ,p_account_definition_type_code     => 'C'
    ,p_account_definition_code          => l_account_definition_code
    ,p_transaction_coa_id               => l_from_coa_id
    ,p_mode                             => 'ONLINE'
    ,x_return_status                    => x_status
    ,x_msg_count                        => x_msg_count
    ,x_msg_data                         => x_msg_data );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg returns status ' || x_status );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_count = ' || x_msg_count );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_data = ' || x_msg_data );
     END IF;

     IF x_status = FND_API.G_RET_STS_SUCCESS
     THEN
        l_ccid :=  fun_xla_tab_pkg.g_array_xla_tab(1).target_ccid;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid =' || l_ccid);
        END IF;

     END IF;

      IF l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 7559411
        THEN
   	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is not success or l_ccid is -1 and return');
     	  END IF;
          x_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;

 END IF;

 IF l_amb_context_code IS NULL OR l_account_definition_code IS NULL OR l_ccid IS NULL THEN



    -- SLA TAB is not set up or their is an error fetching  CCID from TAB
    -- Trying to get the default ccid from Accouning Setups
    -- Generate 1 Liability account line (dist_type = 'P')
    -- Generate 1 Receivable account line (dist_type = 'R')
    -- irrespective of how many ever distributions (dist_type = 'L')
    -- are present.

    l_init_bsv  :=l_init_summary_rec(i).dist_bsv;
    l_reci_bsv  :=l_reci_summary_rec(1).dist_bsv;
    -- Generate Initiator Distributions
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'generate initiator distribution lines');
    END IF;

     IF l_init_dist_tbl(1).initiator_le_id <>  l_init_dist_tbl(1).recipient_le_id



     THEN

        -- p_to_ledger_id in this case is not really required as we
        -- are not interested in the reciprocal ccids.
        -- Hence passing it a dummy value
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intercompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_init_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_le = ' || l_init_dist_tbl(1).recipient_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_init_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'R');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
        END IF;

        fun_bal_utils_grp.get_intercompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_init_dist_tbl(1).ledger_id,
                        p_from_le           => l_init_dist_tbl(1).initiator_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_from_bsv          => l_init_bsv,
                        p_to_ledger_id      => l_reci_dist_tbl(1).ledger_id,
                        p_to_le             => l_init_dist_tbl(1).recipient_le_id,
                        p_to_bsv            => l_reci_bsv,
                        p_gl_date           => l_init_dist_tbl(1).gl_date,
                        p_acct_type         => 'R',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
     ELSE
		 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intracompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_init_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_dr_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_cr_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_init_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'D');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
        END IF;

		fun_bal_utils_grp.get_intracompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_init_dist_tbl(1).ledger_id,
                        p_from_le           => l_init_dist_tbl(1).initiator_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_dr_bsv            => l_init_bsv,
                        p_cr_bsv            => l_reci_bsv,
                        p_gl_date           => l_init_dist_tbl(1).gl_date,
                        p_acct_type         => 'D',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
     END IF;


 IF l_ccid IS NULL OR l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 6969506
     THEN
     	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is null or return status is not success and return');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_status = ' || x_status);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_count = ' || x_msg_count);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_data = ' || x_msg_data);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_reciprocal_ccid = ' || l_reciprocal_ccid);
     	END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     END IF;


  END IF;

 IF (l_init_dist_tbl(1).init_amount_cr IS NULL or to_number(l_init_dist_tbl(1).init_amount_cr)=0) and (l_init_dist_tbl(1).init_amount_dr is null or to_number(l_init_dist_tbl(1).init_amount_dr)=0 ) -- Bug No : 6969506, 7013314
      THEN
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

    -- Now build the new distribution record
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Build the initiator distribution lines');
    END IF;
    SELECT FUN_DIST_LINES_S.nextval
    INTO  l_new_dist_tbl(l_new_index).dist_id
    FROM dual;

    l_new_dist_tbl(l_new_index).line_id      :=  l_init_dist_tbl(1).line_id;
    l_new_dist_tbl(l_new_index).trx_id       :=  l_init_dist_tbl(1).trx_id;
    l_new_dist_tbl(l_new_index).dist_number  :=  l_new_dist_tbl(l_new_index).dist_id;
    l_new_dist_tbl(l_new_index).party_id     :=  l_init_dist_tbl(1).initiator_id;
    l_new_dist_tbl(l_new_index).party_type_flag  :=  'I';
    l_new_dist_tbl(l_new_index).dist_type_flag   :=  'R';
    l_new_dist_tbl(l_new_index).amount_cr    :=  l_init_summary_rec(i).amount_dr;
    l_new_dist_tbl(l_new_index).amount_dr    :=  l_init_summary_rec(i).amount_cr;
    l_new_dist_tbl(l_new_index).ccid         :=  l_ccid;
    l_new_dist_tbl(l_new_index).description  :=  l_init_dist_tbl(1).description;
    l_new_dist_tbl(l_new_index).auto_generate_flag  :=  'Y';
    l_new_dist_tbl(l_new_index).created_by        :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).creation_date     :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_updated_by   :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).last_update_date  :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_update_login :=  FND_GLOBAL.LOGIN_ID;

    l_new_index := l_new_index + 1;

    -- Generate Recipient Distributions


-- Fetching the coa id of the recipient


    SELECT l.chart_of_accounts_id
    INTO l_to_coa_id
    from gl_ledgers l
    WHERE l.ledger_id = l_trx_dtl_rec.to_ledger_id;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'recipient coa id = ' || l_to_coa_id);
    END IF;

--Checking whether TAB is set up for the recipient

    OPEN c_chk_sla (l_trx_dtl_rec.to_ledger_id);
    FETCH c_chk_sla INTO l_amb_context_code,
                         l_account_definition_code;
    CLOSE c_chk_sla;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Check if TAB is setup for recipient l_amb_context_code = ' || l_amb_context_code || ' l_account_definition_code = ' || l_account_definition_code);
    END IF;


  IF l_amb_context_code IS NOT NULL AND l_account_definition_code IS NOT NULL


    THEN

    -- trying to get it from TAB set up

    -- Derive values to be passed for recipient and initiator BSV
    -- Pass value only if 1 bsv is assigned to the LE.
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Derive the Initiator and recipient BSV to be passed');
    END IF;

    l_initiator_bsv := l_init_summary_rec(i).dist_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'initiator BSV l_initiator_bsv = ' || l_initiator_bsv);
    END IF;

    l_recipient_bsv := l_reci_summary_rec(1).dist_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'recipient BSV l_recipient_bsv = ' || l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'populating the PLSQL table fun_xla_tab_pkg.g_array_xla_tab(1)' );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_1 = ' ||  l_trx_dtl_rec.batch_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_2 = ' ||  l_trx_dtl_rec.trx_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_3 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_4 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'source_distribution_id_num_5 = ' ||  NULL);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'account_type_code = ' ||  'AGIS_RECIPIENT_CLEAR_ACCOUNT');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute1 = ' ||  l_trx_dtl_rec.bat_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute10 = ' ||  l_trx_dtl_rec.bat_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute11 = ' ||  l_trx_dtl_rec.bat_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute12 = ' ||  l_trx_dtl_rec.bat_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute13 = ' ||  l_trx_dtl_rec.bat_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute14 = ' ||  l_trx_dtl_rec.bat_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute15 = ' ||  l_trx_dtl_rec.bat_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute2 = ' ||  l_trx_dtl_rec.bat_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute3 = ' ||  l_trx_dtl_rec.bat_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute4 = ' ||  l_trx_dtl_rec.bat_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute5 = ' ||  l_trx_dtl_rec.bat_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute6 = ' ||  l_trx_dtl_rec.bat_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute7 = ' ||  l_trx_dtl_rec.bat_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute8 = ' ||  l_trx_dtl_rec.bat_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_attribute9 = ' ||  l_trx_dtl_rec.bat_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_category_code = ' ||  l_trx_dtl_rec.bat_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_currency_code = ' ||  l_trx_dtl_rec.currency_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_ledger_id = ' ||  l_trx_dtl_rec.from_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_from_le_id = ' ||  l_trx_dtl_rec.from_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_bsv  = ' ||  l_initiator_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftb_initiator_id  = ' ||  l_trx_dtl_rec.initiator_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute1  = ' ||  l_trx_dtl_rec.trx_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute2  = ' ||  l_trx_dtl_rec.trx_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute3  = ' ||  l_trx_dtl_rec.trx_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute4  = ' ||  l_trx_dtl_rec.trx_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute5  = ' ||  l_trx_dtl_rec.trx_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute6  = ' ||  l_trx_dtl_rec.trx_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute7  = ' ||  l_trx_dtl_rec.trx_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute8  = ' ||  l_trx_dtl_rec.trx_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute9  = ' ||  l_trx_dtl_rec.trx_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute10  = ' ||  l_trx_dtl_rec.trx_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute11  = ' ||  l_trx_dtl_rec.trx_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute12  = ' ||  l_trx_dtl_rec.trx_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute13  = ' ||  l_trx_dtl_rec.trx_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute14  = ' ||  l_trx_dtl_rec.trx_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute15  = ' ||  l_trx_dtl_rec.trx_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_attribute_category  = ' ||  l_trx_dtl_rec.trx_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_bsv  = ' ||  l_recipient_bsv);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_recipient_id  = ' ||  l_trx_dtl_rec.recipient_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_ledger_id  = ' ||  l_trx_dtl_rec.to_ledger_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fth_to_le_id  = ' ||  l_trx_dtl_rec.to_le_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_interest_accr_flag  = ' ||  l_trx_dtl_rec.allow_interest_accrual_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_allow_invoicing_flag  = ' ||  l_trx_dtl_rec.allow_invoicing_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute1  = ' ||  l_trx_dtl_rec.typ_attribute1);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute2  = ' ||  l_trx_dtl_rec.typ_attribute2);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute3  = ' ||  l_trx_dtl_rec.typ_attribute3);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute4  = ' ||  l_trx_dtl_rec.typ_attribute4);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute5  = ' ||  l_trx_dtl_rec.typ_attribute5);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute6  = ' ||  l_trx_dtl_rec.typ_attribute6);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute7  = ' ||  l_trx_dtl_rec.typ_attribute7);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute8  = ' ||  l_trx_dtl_rec.typ_attribute8);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute9  = ' ||  l_trx_dtl_rec.typ_attribute9);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute10  = ' ||  l_trx_dtl_rec.typ_attribute10);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute11  = ' ||  l_trx_dtl_rec.typ_attribute11);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute12  = ' ||  l_trx_dtl_rec.typ_attribute12);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute13  = ' ||  l_trx_dtl_rec.typ_attribute13);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute14  = ' ||  l_trx_dtl_rec.typ_attribute14);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute15  = ' ||  l_trx_dtl_rec.typ_attribute15);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_attribute_category  = ' ||  l_trx_dtl_rec.typ_attribute_category);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_manual_approve_flag  = ' ||  l_trx_dtl_rec.manual_approve_flag);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_trx_type_id  = ' ||  l_trx_dtl_rec.trx_type_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'ftt_vat_taxable_flag  = ' ||  l_trx_dtl_rec.vat_taxable_flag);
    END IF;

    -- Populate PLSQL Table
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_1       :=  l_trx_dtl_rec.batch_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_2       :=  l_trx_dtl_rec.trx_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_3       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_4       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_5       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).account_type_code                  :=  'AGIS_RECIPIENT_CLEAR_ACCOUNT';
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute1                     :=  l_trx_dtl_rec.bat_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute10                    :=  l_trx_dtl_rec.bat_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute11                    :=  l_trx_dtl_rec.bat_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute12                    :=  l_trx_dtl_rec.bat_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute13                    :=  l_trx_dtl_rec.bat_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute14                    :=  l_trx_dtl_rec.bat_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute15                    :=  l_trx_dtl_rec.bat_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute2                     :=  l_trx_dtl_rec.bat_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute3                     :=  l_trx_dtl_rec.bat_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute4                     :=  l_trx_dtl_rec.bat_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute5                     :=  l_trx_dtl_rec.bat_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute6                     :=  l_trx_dtl_rec.bat_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute7                     :=  l_trx_dtl_rec.bat_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute8                     :=  l_trx_dtl_rec.bat_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute9                     :=  l_trx_dtl_rec.bat_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_category_code                  :=  l_trx_dtl_rec.bat_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_currency_code                  :=  l_trx_dtl_rec.currency_code;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_ledger_id                 :=  l_trx_dtl_rec.from_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_le_id                     :=  l_trx_dtl_rec.from_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_bsv                  :=  l_initiator_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_id                   :=  l_trx_dtl_rec.initiator_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute1                     :=  l_trx_dtl_rec.trx_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute10                    :=  l_trx_dtl_rec.trx_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute11                    :=  l_trx_dtl_rec.trx_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute12                    :=  l_trx_dtl_rec.trx_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute13                    :=  l_trx_dtl_rec.trx_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute14                    :=  l_trx_dtl_rec.trx_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute15                    :=  l_trx_dtl_rec.trx_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute2                     :=  l_trx_dtl_rec.trx_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute3                     :=  l_trx_dtl_rec.trx_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute4                     :=  l_trx_dtl_rec.trx_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute5                     :=  l_trx_dtl_rec.trx_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute6                     :=  l_trx_dtl_rec.trx_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute7                     :=  l_trx_dtl_rec.trx_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute8                     :=  l_trx_dtl_rec.trx_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute9                     :=  l_trx_dtl_rec.trx_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute_category             :=  l_trx_dtl_rec.trx_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_bsv                  :=  l_recipient_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_id                   :=  l_trx_dtl_rec.recipient_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_ledger_id                   :=  l_trx_dtl_rec.to_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_le_id                       :=  l_trx_dtl_rec.to_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_interest_accr_flag       :=  l_trx_dtl_rec.allow_interest_accrual_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_invoicing_flag           :=  l_trx_dtl_rec.allow_invoicing_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute1                     :=  l_trx_dtl_rec.typ_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute10                    :=  l_trx_dtl_rec.typ_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute11                    :=  l_trx_dtl_rec.typ_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute12                    :=  l_trx_dtl_rec.typ_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute13                    :=  l_trx_dtl_rec.typ_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute14                    :=  l_trx_dtl_rec.typ_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute15                    :=  l_trx_dtl_rec.typ_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute2                     :=  l_trx_dtl_rec.typ_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute3                     :=  l_trx_dtl_rec.typ_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute4                     :=  l_trx_dtl_rec.typ_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute5                     :=  l_trx_dtl_rec.typ_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute6                     :=  l_trx_dtl_rec.typ_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute7                     :=  l_trx_dtl_rec.typ_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute8                     :=  l_trx_dtl_rec.typ_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute9                     :=  l_trx_dtl_rec.typ_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute_category             :=  l_trx_dtl_rec.typ_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_manual_approve_flag            :=  l_trx_dtl_rec.manual_approve_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_trx_type_id                    :=  l_trx_dtl_rec.trx_type_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_vat_taxable_flag               :=  l_trx_dtl_rec.vat_taxable_flag;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Calling fun_xla_tab_pkg.run with following parameters');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_api_version = ' || '1.0');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_type_code = ' || 'C');
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_account_definition_code = ' || l_account_definition_code);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_transaction_coa_id = ' || l_to_coa_id);
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct','p_mode = ' || 'ONLINE');
    END IF;

    fun_xla_tab_pkg.run(
     p_api_version                      => 1.0
    ,p_account_definition_type_code     => 'C'
    ,p_account_definition_code          => l_account_definition_code
    ,p_transaction_coa_id               => l_to_coa_id
    ,p_mode                             => 'ONLINE'
    ,x_return_status                    => x_status
    ,x_msg_count                        => x_msg_count
    ,x_msg_data                         => x_msg_data );

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg returns status ' || x_status );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_count = ' || x_msg_count );
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'fun_xla_tab_pkg x_msg_data = ' || x_msg_data );
     END IF;


     IF x_status = FND_API.G_RET_STS_SUCCESS
     THEN
        l_ccid :=  fun_xla_tab_pkg.g_array_xla_tab(1).target_ccid;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'if fun_xla_tab_pkg returns success set ccid = ' || l_ccid);
        END IF;
     END IF;

     IF l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 7559411
       THEN
 	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is not success or l_ccid is -1 and return');
     	  END IF;
          x_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

  END IF;

  IF l_amb_context_code IS NULL OR l_account_definition_code IS NULL OR l_ccid IS NULL THEN
    l_init_bsv  :=l_init_summary_rec(i).dist_bsv;
    l_reci_bsv  :=l_reci_summary_rec(1).dist_bsv;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'If TAB is not setup or ccid could not be derived then');
    END IF;
    -- SLA TAB is not set up or the ccid could not be derived from TAB Set up
    -- Trying to get the default ccid from Accouning Setups
         IF l_reci_dist_tbl(1).initiator_le_id <>  l_reci_dist_tbl(1).recipient_le_id
          THEN

			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intercompany_account with following parameters');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_reci_dist_tbl(1).initiator_le_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
                 		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_bsv = ' || l_reci_bsv);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_ledger_id = ' || l_init_dist_tbl(1).ledger_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_le = ' || l_reci_dist_tbl(1).recipient_le_id);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_to_bsv = ' || l_init_bsv);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_reci_dist_tbl(1).gl_date);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'P');
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
			END IF;

          fun_bal_utils_grp.get_intercompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_reci_dist_tbl(1).ledger_id,
                        p_from_le           => l_reci_dist_tbl(1).recipient_le_id,
			                  p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_from_bsv          => l_reci_bsv,
                        p_to_ledger_id      => l_init_dist_tbl(1).ledger_id,
                        p_to_le             => l_reci_dist_tbl(1).initiator_le_id,
                        p_to_bsv            => l_init_bsv,
                        p_gl_date           => l_reci_dist_tbl(1).gl_date,
                        p_acct_type         => 'P',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
        ELSE

		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'calling fun_bal_utils_grp.get_intracompany_account with following parameters');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_api_version = ' ||'1.0');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_init_msg_list = ' || FND_API.G_TRUE);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_ledger_id = ' || l_reci_dist_tbl(1).ledger_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_from_le = ' || l_reci_dist_tbl(1).initiator_le_id);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_source = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_category = ' || 'Global Intercompany');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_dr_bsv = ' || l_reci_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_cr_bsv = ' || l_init_bsv);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_gl_date = ' || l_reci_dist_tbl(1).gl_date);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'p_acct_type = ' || 'D');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_reciprocal_ccid = ' || l_reciprocal_ccid);
		 END IF;

        fun_bal_utils_grp.get_intracompany_account
                       (p_api_version       => 1.0,
                        p_init_msg_list     => FND_API.G_TRUE,
                        p_ledger_id         => l_reci_dist_tbl(1).ledger_id,
                        p_from_le           => l_reci_dist_tbl(1).recipient_le_id,
                        p_source            => 'Global Intercompany',
                        p_category          => 'Global Intercompany',
                        p_dr_bsv            => l_reci_bsv,
                        p_cr_bsv            => l_init_bsv,
                        p_gl_date           => l_reci_dist_tbl(1).gl_date,
                        p_acct_type         => 'C',
                        x_status            => x_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_ccid              => l_ccid,
                        x_reciprocal_ccid   => l_reciprocal_ccid);
      END IF;

    IF l_ccid IS NULL OR l_ccid <=0 OR x_status <>  FND_API.G_RET_STS_SUCCESS -- Bug No : 6969506
      THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Error if l_ccid is null or return status is not success and return');
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_status = ' || x_status);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_count = ' || x_msg_count);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'x_msg_data = ' || x_msg_data);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_ccid = ' || l_ccid);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'l_reciprocal_ccid = ' || l_reciprocal_ccid);
     	END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

   END IF;

IF (l_reci_dist_tbl(1).reci_amount_cr IS NULL or to_number(l_reci_dist_tbl(1).reci_amount_cr)=0) and (l_reci_dist_tbl(1).reci_amount_dr is null OR to_number(l_reci_dist_tbl(1).reci_amount_dr)=0)  -- Bug No : 6969506, 7013314
      THEN
        x_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;


    -- Now build the new distribution record
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'Build the Distribution lines');
    END IF;
    SELECT FUN_DIST_LINES_S.nextval
    INTO  l_new_dist_tbl(l_new_index).dist_id
    FROM dual;

    l_new_dist_tbl(l_new_index).line_id      :=  l_reci_dist_tbl(1).line_id;
    l_new_dist_tbl(l_new_index).trx_id       :=  l_reci_dist_tbl(1).trx_id;
    l_new_dist_tbl(l_new_index).dist_number  :=  l_new_dist_tbl(l_new_index).dist_id;
    l_new_dist_tbl(l_new_index).party_id     :=  l_reci_dist_tbl(1).recipient_id;
    l_new_dist_tbl(l_new_index).party_type_flag  :=  'R';
    l_new_dist_tbl(l_new_index).dist_type_flag   :=  'P';
    l_new_dist_tbl(l_new_index).amount_cr    :=  l_init_summary_rec(i).amount_cr;
    l_new_dist_tbl(l_new_index).amount_dr    :=  l_init_summary_rec(i).amount_dr;
    l_new_dist_tbl(l_new_index).ccid         :=  l_ccid;
    l_new_dist_tbl(l_new_index).description  :=  l_reci_dist_tbl(1).description;
    l_new_dist_tbl(l_new_index).auto_generate_flag  :=  'Y';
    l_new_dist_tbl(l_new_index).created_by        :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).creation_date     :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_updated_by   :=  FND_GLOBAL.USER_ID;
    l_new_dist_tbl(l_new_index).last_update_date  :=  SYSDATE;
    l_new_dist_tbl(l_new_index).last_update_login :=  FND_GLOBAL.LOGIN_ID;

    l_new_index := l_new_index + 1;
END LOOP;
END IF;

    IF x_status = FND_API.G_RET_STS_SUCCESS

    THEN
        -- Delete existing intercompany account distribution lines if exists.
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_interco_acct', 'If Sucessful Delete existing lines and insert.');
        END IF;
        DELETE fun_dist_lines
        WHERE  trx_id  = l_trx_id
        AND    dist_type_flag IN ('R','P');



        FORALL i IN 1..l_new_dist_tbl.COUNT
            INSERT into FUN_DIST_LINES
            VALUES l_new_dist_tbl(i);

    END IF;


    EXCEPTION
        WHEN others THEN
	x_status := FND_API.G_RET_STS_ERROR;
END generate_interco_acct;

/* ---------------------------------------------------------------------------
Name      : get_default_sla_ccid
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by recipient_interco_acct
            to get the default ccid from SLA
Parameters:
    IN    : p_trx_id  -- fun_trx_headers.trx_id
    OUT   : x_status  -- FND_API.G_RET_STS_SUCCESS, ..UNEXP,..ERROR
            x_msg_count -- Number of messages
            x_msg_data  -- Message data
            x_ccid      -- CCID
Notes     : None.
Testing   : This function will be tested via workflow FUNRMAIN
------------------------------------------------------------------------------*/
PROCEDURE get_default_sla_ccid (
    p_trx_id    IN NUMBER,
    x_ccid      IN OUT NOCOPY NUMBER,
    x_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count IN OUT NOCOPY NUMBER,
    x_msg_data  IN OUT NOCOPY VARCHAR2)
IS

CURSOR c_dtls IS
   SELECT  b.batch_id,
           b.initiator_id initiator_id
          ,b.from_le_id  from_le_id
          ,b.from_ledger_id from_ledger_id
          ,b.currency_code currency_code
          ,b.attribute1  bat_attribute1
          ,b.attribute2  bat_attribute2
          ,b.attribute3  bat_attribute3
          ,b.attribute4  bat_attribute4
          ,b.attribute5  bat_attribute5
          ,b.attribute6  bat_attribute6
          ,b.attribute7  bat_attribute7
          ,b.attribute8  bat_attribute8
          ,b.attribute9  bat_attribute9
          ,b.attribute10  bat_attribute10
          ,b.attribute11  bat_attribute11
          ,b.attribute12  bat_attribute12
          ,b.attribute13  bat_attribute13
          ,b.attribute14  bat_attribute14
          ,b.attribute15  bat_attribute15
          ,b.attribute_category  bat_attribute_category
          ,t.trx_id       trx_id
          ,t.recipient_id recipient_id
          ,t.to_le_id     to_le_id
          ,t.to_ledger_id to_ledger_id
          ,t.attribute1  trx_attribute1
          ,t.attribute2  trx_attribute2
          ,t.attribute3  trx_attribute3
          ,t.attribute4  trx_attribute4
          ,t.attribute5  trx_attribute5
          ,t.attribute6  trx_attribute6
          ,t.attribute7  trx_attribute7
          ,t.attribute8  trx_attribute8
          ,t.attribute9  trx_attribute9
          ,t.attribute10  trx_attribute10
          ,t.attribute11  trx_attribute11
          ,t.attribute12  trx_attribute12
          ,t.attribute13  trx_attribute13
          ,t.attribute14  trx_attribute14
          ,t.attribute15  trx_attribute15
          ,t.attribute_category  trx_attribute_category
          ,y.trx_type_id  trx_type_id
          ,y.manual_approve_flag           manual_approve_flag
          ,y.allow_invoicing_flag          allow_invoicing_flag
          ,y.vat_taxable_flag              vat_taxable_flag
          ,y.allow_interest_accrual_flag   allow_interest_accrual_flag
          ,y.attribute1  typ_attribute1
          ,y.attribute2  typ_attribute2
          ,y.attribute3  typ_attribute3
          ,y.attribute4  typ_attribute4
          ,y.attribute5  typ_attribute5
          ,y.attribute6  typ_attribute6
          ,y.attribute7  typ_attribute7
          ,y.attribute8  typ_attribute8
          ,y.attribute9  typ_attribute9
          ,y.attribute10  typ_attribute10
          ,y.attribute11  typ_attribute11
          ,y.attribute12  typ_attribute12
          ,y.attribute13  typ_attribute13
          ,y.attribute14  typ_attribute14
          ,y.attribute15  typ_attribute15
          ,y.attribute_category  typ_attribute_category
          ,l.chart_of_accounts_id  coa_id
          ,b.batch_date
          ,b.gl_date
   FROM fun_trx_batches b,
        fun_trx_headers t,
        fun_trx_types_vl y,
        gl_ledgers       l
   WHERE b.batch_id     = t.batch_id
   AND   b.trx_type_id  = y.trx_type_id
   AND   t.to_ledger_id = l.ledger_id
   AND   t.trx_id       = p_trx_id;

l_trx_dtl_rec    c_dtls%ROWTYPE;

CURSOR c_chk_sla (p_ledger_id    IN NUMBER) IS
  SELECT amb_context_code,
         account_definition_code
  FROM   fun_trx_acct_definitions
  WHERE  ledger_id = p_ledger_id;

CURSOR c_get_bsv(p_ledger_id    NUMBER,
                 p_le_id        NUMBER,
                 p_gl_date      DATE) IS
SELECT vals.segment_value
FROM   gl_ledger_le_bsv_specific_v vals
WHERE  vals.legal_entity_id     = p_le_id
AND    vals.ledger_id           = p_ledger_id
AND   p_gl_date BETWEEN Nvl(vals.start_date, p_gl_date) AND Nvl(vals.end_date, p_gl_date)
AND   (SELECT COUNT(*)
       FROM   gl_ledger_le_bsv_specific_v vals1
       WHERE  vals1.legal_entity_id = p_le_id
       AND    vals1.ledger_id       = p_ledger_id
       AND   p_gl_date BETWEEN Nvl(vals1.start_date, p_gl_date) AND Nvl(vals1.end_date, p_gl_date)) = 1;

l_amb_context_code         fun_trx_acct_definitions.amb_context_code%TYPE;
l_account_definition_code  fun_trx_acct_definitions.account_definition_code%TYPE;
l_initiator_bsv            gl_ledger_le_bsv_specific_v.segment_value%TYPE;
l_recipient_bsv            gl_ledger_le_bsv_specific_v.segment_value%TYPE;

BEGIN
    x_status := FND_API.G_RET_STS_SUCCESS;
    x_ccid   := -1;

    OPEN c_dtls;
    FETCH c_dtls INTO l_trx_dtl_rec;
    CLOSE c_dtls;

    OPEN c_chk_sla (l_trx_dtl_rec.to_ledger_id);
    FETCH c_chk_sla INTO l_amb_context_code,
                         l_account_definition_code;
    CLOSE c_chk_sla;

    IF l_amb_context_code IS NULL OR l_account_definition_code IS NULL
    THEN
        -- SLA TAB is not set up hence unable to get
        -- default ccid
        RETURN;
    END IF;

    -- Derive values to be passed for recipient and initiator BSV
    -- Pass value only if 1 bsv is assigned to the LE.
    OPEN c_get_bsv(l_trx_dtl_rec.from_ledger_id,
                   l_trx_dtl_rec.from_le_id,
                   l_trx_dtl_rec.gl_date);
    FETCH c_get_bsv INTO l_initiator_bsv;
    CLOSE c_get_bsv;

    OPEN c_get_bsv(l_trx_dtl_rec.to_ledger_id,
                   l_trx_dtl_rec.to_le_id,
                   l_trx_dtl_rec.gl_date);
    FETCH c_get_bsv INTO l_recipient_bsv;
    CLOSE c_get_bsv;

    -- Populate PLSQL Table
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_1       :=  l_trx_dtl_rec.batch_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_2       :=  l_trx_dtl_rec.trx_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_3       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_4       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).source_distribution_id_num_5       :=  NULL;
    fun_xla_tab_pkg.g_array_xla_tab(1).account_type_code                  :=  'AGIS_RECIPIENT_DIST_ACCOUNT';
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute1                     :=  l_trx_dtl_rec.bat_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute10                    :=  l_trx_dtl_rec.bat_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute11                    :=  l_trx_dtl_rec.bat_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute12                    :=  l_trx_dtl_rec.bat_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute13                    :=  l_trx_dtl_rec.bat_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute14                    :=  l_trx_dtl_rec.bat_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute15                    :=  l_trx_dtl_rec.bat_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute2                     :=  l_trx_dtl_rec.bat_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute3                     :=  l_trx_dtl_rec.bat_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute4                     :=  l_trx_dtl_rec.bat_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute5                     :=  l_trx_dtl_rec.bat_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute6                     :=  l_trx_dtl_rec.bat_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute7                     :=  l_trx_dtl_rec.bat_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute8                     :=  l_trx_dtl_rec.bat_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_attribute9                     :=  l_trx_dtl_rec.bat_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_category_code                  :=  l_trx_dtl_rec.bat_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_currency_code                  :=  l_trx_dtl_rec.currency_code;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_ledger_id                 :=  l_trx_dtl_rec.from_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_from_le_id                     :=  l_trx_dtl_rec.from_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_bsv                  :=  l_initiator_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftb_initiator_id                   :=  l_trx_dtl_rec.initiator_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute1                     :=  l_trx_dtl_rec.trx_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute10                    :=  l_trx_dtl_rec.trx_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute11                    :=  l_trx_dtl_rec.trx_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute12                    :=  l_trx_dtl_rec.trx_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute13                    :=  l_trx_dtl_rec.trx_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute14                    :=  l_trx_dtl_rec.trx_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute15                    :=  l_trx_dtl_rec.trx_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute2                     :=  l_trx_dtl_rec.trx_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute3                     :=  l_trx_dtl_rec.trx_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute4                     :=  l_trx_dtl_rec.trx_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute5                     :=  l_trx_dtl_rec.trx_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute6                     :=  l_trx_dtl_rec.trx_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute7                     :=  l_trx_dtl_rec.trx_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute8                     :=  l_trx_dtl_rec.trx_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute9                     :=  l_trx_dtl_rec.trx_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_attribute_category             :=  l_trx_dtl_rec.trx_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_bsv                  :=  l_recipient_bsv;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_recipient_id                   :=  l_trx_dtl_rec.recipient_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_ledger_id                   :=  l_trx_dtl_rec.to_ledger_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).fth_to_le_id                       :=  l_trx_dtl_rec.to_le_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_interest_accr_flag       :=  l_trx_dtl_rec.allow_interest_accrual_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_allow_invoicing_flag           :=  l_trx_dtl_rec.allow_invoicing_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute1                     :=  l_trx_dtl_rec.typ_attribute1;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute10                    :=  l_trx_dtl_rec.typ_attribute10;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute11                    :=  l_trx_dtl_rec.typ_attribute11;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute12                    :=  l_trx_dtl_rec.typ_attribute12;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute13                    :=  l_trx_dtl_rec.typ_attribute13;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute14                    :=  l_trx_dtl_rec.typ_attribute14;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute15                    :=  l_trx_dtl_rec.typ_attribute15;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute2                     :=  l_trx_dtl_rec.typ_attribute2;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute3                     :=  l_trx_dtl_rec.typ_attribute3;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute4                     :=  l_trx_dtl_rec.typ_attribute4;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute5                     :=  l_trx_dtl_rec.typ_attribute5;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute6                     :=  l_trx_dtl_rec.typ_attribute6;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute7                     :=  l_trx_dtl_rec.typ_attribute7;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute8                     :=  l_trx_dtl_rec.typ_attribute8;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute9                     :=  l_trx_dtl_rec.typ_attribute9;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_attribute_category             :=  l_trx_dtl_rec.typ_attribute_category;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_manual_approve_flag            :=  l_trx_dtl_rec.manual_approve_flag;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_trx_type_id                    :=  l_trx_dtl_rec.trx_type_id;
    fun_xla_tab_pkg.g_array_xla_tab(1).ftt_vat_taxable_flag               :=  l_trx_dtl_rec.vat_taxable_flag;


    fun_xla_tab_pkg.run(
     p_api_version                      => 1.0
    ,p_account_definition_type_code     => 'C'
    ,p_account_definition_code          => l_account_definition_code
    ,p_transaction_coa_id               => l_trx_dtl_rec.coa_id
    ,p_mode                             => 'ONLINE'
    ,x_return_status                    => x_status
    ,x_msg_count                        => x_msg_count
    ,x_msg_data                         => x_msg_data );

    IF x_status = FND_API.G_RET_STS_SUCCESS
    THEN
        x_ccid :=  fun_xla_tab_pkg.g_array_xla_tab(1).target_ccid;
    END IF;

END get_default_sla_ccid;

/*-----------------------------------------------------
 * PROCEDURE generate_acct_lines
 * ----------------------------------------------------
 * Generate intercompany accounting lines
 * ---------------------------------------------------*/

PROCEDURE generate_acct_lines (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
    l_error         varchar2(2000);
    l_user_id       NUMBER;
    l_resp_id       NUMBER;
    l_appl_id       NUMBER;
BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_acct_lines', 'Begin. itemtype = ' || itemtype || ' itemkey = ' || itemkey || ' actid = ' || actid || ' funcmode = ' || funcmode);
    END IF;
	-- Bug: 7639191
  /* l_resp_id :=   wf_engine.GetItemAttrNumber
                 --- Bug # 9069005
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'RESP_ID');
    l_user_id  :=  wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'USER_ID');
    l_appl_id  :=  wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'APPL_ID'); */
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
--    FND_GLOBAL.APPS_INITIALIZE(l_user_id,l_resp_id,l_appl_id);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_acct_lines', 'l_trx_id = ' || l_trx_id);
    END IF;

        -- Generate the intercompany account distributions
        generate_interco_acct (
                      p_trx_id    => l_trx_id,
                      x_status    => l_status,
                      x_msg_count => l_msg_count,
                      x_msg_data  => l_msg_data);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_acct_lines', 'after generate_interco_acct l_status = ' || l_status);
    END IF;

        IF l_status <> FND_API.G_RET_STS_SUCCESS
        THEN

            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_acct_lines', 'if l_status not equal to ' || FND_API.G_RET_STS_SUCCESS);
            END IF;

            resultout := wf_engine.eng_completed||':F';
            fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'ERROR');


            FOR i IN 1..l_msg_count
            LOOP
                l_error  := l_error ||fnd_msg_pub.get(i, 'F') ||' ';
            END LOOP;

            wf_engine.SetItemAttrText(itemtype => itemtype,
		  itemkey => itemkey,
		  aname   => 'ERROR_MESSAGE',
		  avalue  => l_error);
            RETURN;
        END IF;

        resultout := wf_engine.eng_completed||':'||'T';
        RETURN;
    END IF;

    resultout := wf_engine.eng_completed||':'||'T';
    RETURN;

    EXCEPTION
        WHEN others THEN

            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_recipient_wf.generate_acct_lines', 'WHEN OTHERS EXCEPTION');
            END IF;
            wf_core.context('FUN_RECIPIENT_WF', 'generate_acct_lines',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
       -- RAISE;

END generate_acct_lines;

-- Bug No:5897122. This cursor will fetch the user names to whom the Notification options is not active and
    -- having access to approve the transaction.
procedure create_wf_roles (
    trx_id      in varchar2)
IS
    c_user_name varchar2(100);
   -- l_userTable     WF_DIRECTORY.UserTable;

    CURSOR get_user_names IS
              select 'X'
        from WF_USER_ROLE_ASSIGNMENTS role
        where role.role_name = 'FUN_ADHOC_RECI_'||trx_id
        and role.user_name = FND_GLOBAL.USER_NAME;
        BEGIN
  OPEN get_user_names;
        FETCH get_user_names INTO c_user_name;

        IF get_user_names%NOTFOUND
        THEN
            CLOSE get_user_names;

            --Bug NO:6526807 Using wf_directory.AddUsersToAdHocRole2 api instead of
	    --wf_directory.AddUsersToAdHocRole so that the application can handle
	    -- spaces in user name

	   -- wf_directory.AddUsersToAdHocRole(
	   --			role_name => 'FUN_ADHOC_RECI_'||trx_id, role_users => c_user_name);

	--   l_userTable(0)  := c_user_name;
	--   wf_directory.AddUsersToAdHocRole2(
	--		role_name => 'FUN_ADHOC_RECI_'||trx_id, role_users => l_userTable);

	  wf_directory.AddUsersToAdHocRole(
					role_name => 'FUN_ADHOC_RECI_'||trx_id, role_users => c_user_name);

        END IF;

END create_wf_roles;
END;

/
