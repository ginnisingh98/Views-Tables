--------------------------------------------------------
--  DDL for Package Body FUN_GLINT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_GLINT_WF" AS
/* $Header: FUN_GLINT_WF_B.pls 120.7.12010000.3 2009/03/23 11:02:18 makansal ship $ */



/*-----------------------------------------------------
 * FUNCTION autonomous_update_ini_complete
 * ----------------------------------------------------
 * Autonomously update the status to XFER_INI_GL in
 * the recipient's system.
 *
 * Returns the new status.
 * ---------------------------------------------------

FUNCTION autonomous_update_ini_complete (
    p_trx_id    IN number) RETURN varchar2
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_status    varchar2(15);
BEGIN
    SELECT status INTO l_status
    FROM fun_trx_headers
    WHERE trx_id = p_trx_id
    FOR UPDATE;

    l_status := fun_gl_transfer.update_status(p_trx_id, l_status);
    COMMIT;
    RETURN l_status;
END autonomous_update_ini_complete;
*/


/*-----------------------------------------------------
 * PROCEDURE get_attr_gl
 * ----------------------------------------------------
 * Get the attributes for the GL WF.
 * ---------------------------------------------------*/

PROCEDURE get_attr_gl (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_party_id  number;
    l_init_id   number;
    l_batch_id  number;
    l_trx_id    number;
    l_contact   varchar2(30);
    l_recipient_name varchar2(500);
    l_trx_amount varchar2(100);
    l_description varchar2(500);


BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        fun_recipient_wf.get_attr(itemtype, itemkey, actid, funcmode, resultout);

        l_party_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'PARTY_ID');
        l_batch_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_ID');


 -- added by rani shergill for notifications  - start

        SELECT rec.party_name
        INTO l_recipient_name
        FROM fun_trx_headers,
             hz_parties rec
        WHERE trx_id = l_trx_id
        AND    recipient_id = rec.party_id;

        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'RECIPIENT_NAME',
                                  avalue => l_recipient_name);


	-- Bug: 7139371 Changing the query to make the l_trx_amt number reginal independent

        --select ltrim(to_char(decode(nvl(h.reci_amount_cr,0),
        --        0,h.reci_amount_dr,
        --        h.reci_amount_cr),'999999999.99'))||' '||b.currency_code
        -- into l_trx_amount
        -- from fun_trx_headers h, fun_trx_batches b
        -- where b.batch_id = l_batch_id
        -- and h.trx_id = l_trx_id;

         select ltrim(to_char(decode(nvl(h.reci_amount_cr,0),
                0,h.reci_amount_dr,
                h.reci_amount_cr),'999999999D99'))||' '||b.currency_code
         into l_trx_amount
         from fun_trx_headers h, fun_trx_batches b
         where b.batch_id = l_batch_id
         and h.trx_id = l_trx_id;

	-- Bug: 7139371 END

        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_AMOUNT',
                                  avalue => l_trx_amount);

-- added by rani shergill for notifications - end


        SELECT initiator_id INTO l_init_id
        FROM fun_trx_batches
        WHERE batch_id = l_batch_id;

        IF (l_init_id = l_party_id) THEN
            wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'PARTY_TYPE',
                                  avalue => 'I');
            UPDATE fun_trx_headers
            SET init_wf_key = itemkey
            WHERE trx_id = l_trx_id;
        ELSE
            wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'PARTY_TYPE',
                                  avalue => 'R');
            UPDATE fun_trx_headers
            SET reci_wf_key = itemkey
            WHERE trx_id = l_trx_id;
        END IF;

        /* Start of changes for AME Uptake, 3671923. Bidisha S, 09 Jun 2004 */
        -- The contact will now be obtained separately within workflow
        -- as per AME rules
        -- l_contact := fun_wf_common.get_contact_role(l_party_id);
        -- wf_engine.SetItemAttrText(itemtype => itemtype,
        --                           itemkey => itemkey,
        --                           aname => 'CONTACT',
        --                           avalue => 'OPERATIONS');
        --                           -- TODO: avalue => l_contact);
        /* End of changes for AME Uptake, 3671923. Bidisha S, 09 Jun 2004 */

        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_GLINT_WF', 'GET_ATTR_GL',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END get_attr_gl;


/*-----------------------------------------------------
 * PROCEDURE check_gl_setup
 * ----------------------------------------------------
 * Check whether there exists conversion between the
 * transaction currency and the GL currency.
 * Check whether the GL period is open.
 * ---------------------------------------------------*/

PROCEDURE check_gl_setup (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_success       boolean := TRUE;
    l_party_type    varchar2(1);
    l_batch_id      number;
    l_trx_id        number;
    l_ledger_id     number;
    l_gl_date       date;
    l_conv_date     date;
    l_trx_currency  varchar2(15);
    l_gl_currency   varchar2(15);
    l_conv_type     varchar2(30);
    l_has_rate      number;
    l_period_status varchar2(1);
    l_rate          number;
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_batch_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'BATCH_ID');
        l_party_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'PARTY_TYPE');

        SELECT currency_code, from_ledger_id, gl_date, batch_date,
               exchange_rate_type
          INTO l_trx_currency, l_ledger_id, l_gl_date, l_conv_date,
               l_conv_type
        FROM fun_trx_batches
        WHERE batch_id = l_batch_id;

        IF (l_party_type = 'R') THEN
            l_trx_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'TRX_ID');
            SELECT to_ledger_id INTO l_ledger_id
            FROM fun_trx_headers
            WHERE trx_id = l_trx_id;
        END IF;

        fnd_msg_pub.initialize;

        -- Check GL period.
        l_period_status := fun_gl_transfer.get_period_status(101, l_gl_date, l_ledger_id);
        IF (l_period_status NOT IN ('O', 'F')) THEN
            fnd_message.set_name('FUN', 'GL_PERIOD_NOT_OPEN');
            fnd_msg_pub.add;
            l_success := FALSE;
        END IF;

        -- Check GL currency conversion.
        SELECT currency_code INTO l_gl_currency
        FROM gl_ledgers
        WHERE ledger_id = l_ledger_id;

        l_rate := fun_gl_transfer.has_conversion_rate(l_trx_currency, l_gl_currency,
                                    l_conv_type, l_conv_date);
        IF l_rate = -1 THEN
            fnd_message.set_name('FUN', 'FUN_API_CONV_RATE_NOT_FOUND');
            fnd_msg_pub.add;
            l_success := FALSE;
        ELSIF l_rate = -2 THEN
            fnd_message.set_name('FUN', 'FUN_API_INVALID_CURRENCY');
            fnd_msg_pub.add;
            l_success := FALSE;
        END IF;


        IF (l_success) THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ERROR',
                         fun_wf_common.concat_msg_stack(fnd_msg_pub.count_msg));
            resultout := wf_engine.eng_completed||':F';
        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_GLINT_WF', 'CHECK_GL_SETUP',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END check_gl_setup;



/*-----------------------------------------------------
 * PROCEDURE transfer_to_gl
 * ----------------------------------------------------
 * Transfer to GL. Wrapper for
 * FUN_GL_TRANSFER.AUTONOMOUS_TRANSFER.
 *
 * If AUTONOMOUS_TRANSFER returns false, it means the
 * status is incorrect, i.e. the trx is already
 * transferred. So we abort our WF process.
 * ---------------------------------------------------*/

PROCEDURE transfer_to_gl (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_success       boolean := FALSE;
    l_party_type    varchar2(1);
    l_trx_id        number;
    l_batch_id      number;
    l_ledger_id     number;
    l_gl_date       date;
    l_trx_currency  varchar2(15);
    l_desc          varchar2(240);
    l_conv_date     date;
    l_conv_type     varchar2(30);
    l_status        varchar2(15);
    l_user_env_lang VARCHAR2(5);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_party_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'PARTY_TYPE');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');

		l_user_env_lang := wf_engine.GetItemAttrText
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'USER_LANG');

        SELECT b.from_ledger_id, b.gl_date, b.currency_code,
               b.exchange_rate_type, b.batch_date, b.description
        INTO l_ledger_id, l_gl_date, l_trx_currency,
             l_conv_type, l_conv_date, l_desc
        FROM fun_trx_batches b
        WHERE b.batch_id = l_batch_id;

        IF (l_party_type = 'R') THEN
            SELECT to_ledger_id, description INTO l_ledger_id, l_desc
            FROM fun_trx_headers
            WHERE trx_id = l_trx_id;
        END IF;

        l_success := fun_gl_transfer.lock_and_transfer(
                                l_trx_id, l_ledger_id, l_gl_date,
                                l_trx_currency, 'Global Intercompany',
                                'Global Intercompany', l_desc, l_conv_date,
                                l_conv_type, l_party_type, l_user_env_lang);

        IF (NOT l_success) THEN
            SELECT status INTO l_status
            FROM fun_trx_headers
            WHERE trx_id = l_trx_id;

            IF ((l_status = 'XFER_INI_GL' AND l_party_type = 'I') OR
                (l_status = 'XFER_RECI_GL' AND l_party_type = 'R') OR
                (l_status = 'COMPLETE')) THEN
                wf_engine.AbortProcess
                        (itemtype => itemtype,
                         itemkey => itemkey,
                         process => 'GL_TRANSFER');
            ELSE
                RAISE gl_transfer_failure;
            END IF;
        END IF;

        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
    END IF;

    resultout := wf_engine.eng_null;
    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_GLINT_WF', 'TRANSFER_TO_GL',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END transfer_to_gl;


/*-----------------------------------------------------
 * PROCEDURE check_signal_initiator
 * ----------------------------------------------------
 * Check whether we raise an event to the initiator.
 * ---------------------------------------------------*/

PROCEDURE check_signal_initiator (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id    number;
    l_status    varchar2(15);
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANcEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        SELECT status INTO l_status
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        IF (l_status = 'XFER_RECI_GL') THEN
            resultout := wf_engine.eng_completed||':F';
        ELSIF (l_status = 'COMPLETE') THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            wf_core.Raise('Internal error: check signal (initiator) found status'||
                          l_status);
        END IF;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_GLINT_WF', 'CHECK_SIGNAL_INITIATOR',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END check_signal_initiator;


/*-----------------------------------------------------
 * PROCEDURE raise_gl_complete
 * ----------------------------------------------------
 * Raise the (initiator) GL complete event.
 * ---------------------------------------------------*/

PROCEDURE raise_gl_complete (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_status        varchar2(15);
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
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;

        SELECT status INTO l_status
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id;

        IF (l_status <> 'XFER_INI_GL') THEN
            RETURN;
        END IF;

        l_event_key := fun_wf_common.generate_event_key(l_batch_id, l_trx_id);

        wf_event.AddParameterToList(p_name => 'TRX_ID',
                                 p_value => TO_CHAR(l_trx_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'BATCH_ID',
                                 p_value => TO_CHAR(l_batch_id),
                                 p_parameterlist => l_params);

        wf_event.raise(
                p_event_name => 'oracle.apps.fun.manualtrx.glcomplete.send',
                p_event_key  => l_event_key,
                p_parameters => l_params);

        l_params.delete();

        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_GLINT_WF', 'RAISE_GL_COMPLETE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END raise_gl_complete;


/*-----------------------------------------------------
 * PROCEDURE update_ini_complete
 * ----------------------------------------------------
 * Update the status to XFER_INI_GL.
 * ---------------------------------------------------*/

PROCEDURE update_ini_complete (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_party_type    varchar2(1);
    l_trx_id        number;
    l_status        varchar2(15);
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_party_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'PARTY_TYPE');

        SELECT status INTO l_status
        FROM fun_trx_headers
        WHERE trx_id = l_trx_id
        FOR UPDATE;

        l_status := fun_gl_transfer.update_status(l_trx_id, l_status, l_party_type);

        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'STATUS',
                                  avalue => l_status);

        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_GLINT_WF', 'UPDATE_INI_COMPLETE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END update_ini_complete;



END;

/
