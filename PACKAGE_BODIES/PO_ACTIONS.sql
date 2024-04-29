--------------------------------------------------------
--  DDL for Package Body PO_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ACTIONS" AS
/* $Header: POXPOACB.pls 120.0.12010000.4 2014/06/20 08:26:31 jemishra ship $ */

--<DBI Req Fulfillment 11.5.11 start>
 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PO_ACTIONS';

 g_log_head  CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

 g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;

 g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;
--<DBI Req Fulfillment 11.5.11 End>

  -- Constants :
  -- This is used as a delimiter in the Debug Info String

  g_delim               CONSTANT VARCHAR2(1) := '
';


  -- Debug String

  -- bug 456040
  -- added x_max_lenth to check for the length of g_dbug
  --
  x_max_length          CONSTANT NUMBER := 32760;
  g_dbug                VARCHAR2(32767) := null;

  -- bug 572638
  -- global variable to indicate if it is called by a concurrent program

  g_conc_flag           VARCHAR2(1);

  --bug 3425540: add separate exception handlers to consolidate rollbacks
  g_return_true_exc      EXCEPTION;
  g_return_false_exc      EXCEPTION;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  FUNCTION close_auto(p_docid        IN     NUMBER,
                      p_doctyp       IN     VARCHAR2,
                      p_docsubtyp    IN     VARCHAR2,
                      p_lineid       IN     NUMBER,
                      p_shipid       IN     NUMBER,
                      p_action       IN     VARCHAR2,
                      p_calling_mode IN     VARCHAR2,
                      p_return_code  IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

/* bug 1007829: frkhan
** New parameter p_action_date has been added into function close_manual
*/

  FUNCTION close_manual(p_docid       IN     NUMBER,
                        p_doctyp      IN     VARCHAR2,
                        p_docsubtyp   IN     VARCHAR2,
                        p_lineid      IN     NUMBER,
                        p_shipid      IN     NUMBER,
                        p_action      IN     VARCHAR2,
                        p_action_date IN     DATE DEFAULT SYSDATE,
                        p_reason      IN     VARCHAR2,
                        p_conc_flag   IN     VARCHAR2,
                        -- <JFMIP:Re-open Finally Match Shipment FPI>
                        p_calling_mode IN    VARCHAR2,
                        p_return_code IN OUT NOCOPY VARCHAR2
                    -- JFMIP : PO needs to have reference to invoice
                     ,  p_origin_doc_id   IN    NUMBER
                     ) RETURN BOOLEAN;





/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Determine and Update the Close Status of Purchase Order Shipments     */
/*   and rollup if necessary                                               */
/*                                                                         */
/*   Auto Closing determines and updates the Close Status of the Shipments */
/*   and rolls up to the Lines and Headers                                 */
/*                                                                         */
/*   Manual Closing determines and updates the Close Status of Shipments,  */
/*   Lines or Headers and rolls up if required                             */
/*                                                                         */
/*   When the parameter p_auto_close is set to 'Y', Auto Closing is        */
/*   invoked; otherwise Manual Closing is invoked                          */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Parameters :

  -- p_docid : Header ID for Document

  -- p_doctyp : Document Type

  -- p_lineid : Line ID for Document

  -- p_shipid : Ship ID for Document

  -- p_action : Action to be performed

  -- p_reason : Reason for Closing. This must be entered for Manual Closing

  -- p_calling_mode : Whether being invoked from 'PO', 'RCV' or 'AP'. This
  --                  determines which of the Closed States needs to be
  --                  checked (receiving, invoicing or both). This must be
  --                  entered for Auto Closing

  -- p_conc_flag : Whether invoked from a Concurrent Process. This must be
  --               entered for Manual Closing and is used by the Funds Checker

  -- p_return_code : Return Status of PO Closing

  -- p_auto_close : Whether to invoke Auto Closing or Manual Closing

/* bug 1007829: frkhan
** New parameter p_action_date is added to function close_po()
*/

  FUNCTION close_po(p_docid        IN     NUMBER,
                    p_doctyp       IN     VARCHAR2,
                    p_docsubtyp    IN     VARCHAR2,
                    p_lineid       IN     NUMBER,
                    p_shipid       IN     NUMBER,
                    p_action       IN     VARCHAR2,
                    p_reason       IN     VARCHAR2 DEFAULT NULL,
                    p_calling_mode IN     VARCHAR2 DEFAULT 'PO',
                    p_conc_flag    IN     VARCHAR2 DEFAULT 'N',
                    p_return_code  IN OUT NOCOPY VARCHAR2,
                    p_auto_close   IN     VARCHAR2 DEFAULT 'Y',
                    p_action_date  IN     DATE DEFAULT SYSDATE,
                    -- JFMIP : PO needs to have reference to invoice
                    p_origin_doc_id IN    NUMBER DEFAULT NULL) RETURN BOOLEAN IS

  BEGIN

    -- bug 456040
    -- Initialize g_dbug and check for its length to prevent from
    -- getting bigger than the max_length allowed.

    g_dbug := 'Debug' || g_delim;

    IF LENGTH (g_dbug) < x_max_length THEN
       g_dbug := g_dbug ||
             'Starting PO Closing:' || g_delim ||
             'Auto Close:' || p_auto_close || g_delim ||
             'Hdr:' || p_docid || g_delim ||
             'Type:' || p_doctyp || g_delim ||
             'Subtype:' || p_docsubtyp || g_delim ||
             'Line:' || p_lineid || g_delim ||
             'Ship:' || p_shipid || g_delim ||
             'Action:' || p_action || g_delim ||
             'Reason:' || p_reason || g_delim ||
             'Calling Mode:' || p_calling_mode || g_delim ||
             'Conc:' || p_conc_flag || g_delim;
    END IF;

    -- bug 572638
    -- set g_conc_flag
    g_conc_flag := p_conc_flag;

    if p_auto_close = 'N' then

/* bug 1007829: frkhan
** Passing p_action_date as the value of new parameter
** p_action_date in function close_manual()
*/

      if not close_manual(p_docid => p_docid,
                          p_doctyp => p_doctyp,
                          p_docsubtyp => p_docsubtyp,
                          p_lineid => p_lineid,
                          p_shipid => p_shipid,
                          p_action => p_action,
                          p_action_date => p_action_date,
                          p_reason => p_reason,
                          p_conc_flag => p_conc_flag,
                          -- <JFMIP:Re-open Finally Match Shipment FPI>
                          p_calling_mode => p_calling_mode,
                          p_return_code => p_return_code
                        -- JFMIP: PO needs to have reference to invoice
                        ,  p_origin_doc_id => p_origin_doc_id
                        )
      then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_ACTIONS',
                               token2 => 'ERR_NUMBER',
                               value2 => '005',
                               token3 => 'SUBROUTINE',
                               value3 => 'CLOSE_PO()');
        return(FALSE);

      end if;

    else

      if not close_auto(p_docid => p_docid,
                        p_doctyp => p_doctyp,
                        p_docsubtyp => p_docsubtyp,
                        p_lineid => p_lineid,
                        p_shipid => p_shipid,
                        p_action => p_action,
                        p_calling_mode => p_calling_mode,
                        p_return_code => p_return_code) then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_ACTIONS',
                               token2 => 'ERR_NUMBER',
                               value2 => '010',
                               token3 => 'SUBROUTINE',
                               value3 => 'CLOSE_PO()');
        return(FALSE);

      end if;

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_ACTIONS',
                             location => '015',
                             error_code => SQLCODE);

      return(FALSE);

  END close_po;


/* ----------------------------------------------------------------------- */

  -- Update the Status of Shipments, based on the Receiving and Invoicing
  -- Closure Point Quantities, and Rollup if necessary

  -- Closure Points and Tolerance Levels are set in po_line_locations (for
  -- tolerances) and in po_system_parameters (for closed codes) respectively

  -- Since AP may call this module as a non-employee (clerk), we do not
  -- generate an error if the user_id is not an employee

  -- Since Auto Close may be invoked for any Authorization Status, we do not
  -- check the Approved Flag; however, the Shipment must not be Finally Closed

   -- <Doc Manager Rewrite 11.5.11>: Removed logic from this package; This
   -- method is now wraps PO_DOCUMENT_ACTION_PVT.auto_close_update_state.

  FUNCTION close_auto(p_docid        IN     NUMBER,
                      p_doctyp       IN     VARCHAR2,
                      p_docsubtyp    IN     VARCHAR2,
                      p_lineid       IN     NUMBER,
                      p_shipid       IN     NUMBER,
                      p_action       IN     VARCHAR2,
                      p_calling_mode IN     VARCHAR2,
                      p_return_code  IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

  l_ret_sts     VARCHAR2(1);
  l_ret_code    VARCHAR2(40);
  l_exc_msg     VARCHAR2(2000);

  l_from_conc   BOOLEAN;

  BEGIN

    -- If called for an Agreement, return now

    if p_doctyp = 'PA' then
      return(TRUE);
    end if;

    -- Check that Calling Mode is Valid

    if p_calling_mode not in ('PO', 'RCV', 'AP') then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_UNKNOWN_CODE',
                             token1 => 'FILE',
                             value1 => 'PO_ACTIONS',
                             token2 => 'ERR_NUMBER',
                             value2 => '055',
                             token3 => 'CODE',
                             value3 => 'CALL_MODE');
      return(FALSE);

    end if;

    IF (NVL(g_conc_flag, 'N') = 'Y')
    THEN
      l_from_conc := TRUE;
    ELSE
      l_from_conc := FALSE;
    END IF;

    PO_DOCUMENT_ACTION_PVT.auto_update_close_state(
       p_document_id       => p_docid
    ,  p_document_type     => p_doctyp
    ,  p_document_subtype  => p_docsubtyp
    ,  p_line_id           => p_lineid
    ,  p_shipment_id       => p_shipid
    ,  p_calling_mode      => p_calling_mode
    ,  p_called_from_conc  => l_from_conc
    ,  x_return_status     => l_ret_sts
    ,  x_exception_msg     => l_exc_msg
    ,  x_return_code       => l_ret_code
    );


    IF (l_ret_sts <> 'S')
    THEN

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_ACTIONS',
                             token2 => 'ERR_NUMBER',
                             value2 => '065',
                             token3 => 'SUBROUTINE',
                             value3 => 'CLOSE_AUTO()');
      return(FALSE);

    END IF;

    IF (l_ret_code = 'STATE_FAILED')
    THEN

      p_return_code := 'STATE_FAILED';
      return(TRUE);

    END IF;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN


      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_ACTIONS',
                             location => '080',
                             error_code => SQLCODE);

      return(FALSE);

  END close_auto;


/* ----------------------------------------------------------------------- */

  -- Determine the Close Status of PO Shipments and rollup to the PO Lines,
  -- Releases or Headers

/* bug 1007829: frkhan
** New parameter p_action_date has been added into function close_manual()
** and declaring variables l_override_period, open_date, X_row_exists.
** Also added cursor get_next_open_prd_sdate
*/

   -- <Doc Manager Rewrite 11.5.11>: Removed logic from this package; This
   -- method is now wraps PO_DOCUMENT_ACTION_PVT.do_manual_close.

  FUNCTION close_manual(p_docid       IN     NUMBER,
                        p_doctyp      IN     VARCHAR2,
                        p_docsubtyp   IN     VARCHAR2,
                        p_lineid      IN     NUMBER,
                        p_shipid      IN     NUMBER,
                        p_action      IN     VARCHAR2,
                        p_action_date IN     DATE DEFAULT SYSDATE,
                        p_reason      IN     VARCHAR2,
                        p_conc_flag   IN     VARCHAR2,
                        -- <JFMIP:Re-open Finally Match Shipment FPI>
                        p_calling_mode IN    VARCHAR2,
                        p_return_code IN OUT NOCOPY VARCHAR2
                     -- JFMIP : PO needs to have reference to invoice
                     ,  p_origin_doc_id   IN    NUMBER
                     ) RETURN BOOLEAN IS

  l_ret_sts            VARCHAR2(1);
  l_ret_code           VARCHAR2(40);
  l_exc_msg            VARCHAR2(2000);
  l_online_report_id   NUMBER;

  l_progress           VARCHAR2(3);

  l_from_conc          BOOLEAN;

  BEGIN

    l_progress := '010';

    IF (NVL(p_conc_flag, 'N') = 'Y')
    THEN
      l_from_conc := TRUE;
    ELSE
      l_from_conc := FALSE;
    END IF;

    PO_DOCUMENT_ACTION_PVT.do_manual_close(
       p_action           => p_action
    ,  p_document_id      => p_docid
    ,  p_document_type    => p_doctyp
    ,  p_document_subtype => p_docsubtyp
    ,  p_line_id          => p_lineid
    ,  p_shipment_id      => p_shipid
    ,  p_reason           => p_reason
    ,  p_action_date      => p_action_date
    ,  p_calling_mode     => p_calling_mode
    ,  p_origin_doc_id    => p_origin_doc_id
    ,  p_called_from_conc => l_from_conc
    ,  p_use_gl_date      => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
    ,  x_return_status    => l_ret_sts
    ,  x_exception_msg    => l_exc_msg
    ,  x_return_code      => l_ret_code
    ,  x_online_report_id => l_online_report_id
    );

    l_progress := '020';

    IF (l_ret_sts <> 'S') THEN

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_ACTIONS',
                             token2 => 'ERR_NUMBER',
                             value2 => '115',
                             token3 => 'SUBROUTINE',
                             value3 => 'CLOSE_MANUAL()');

      RAISE g_return_false_exc;

    END IF;

    IF (l_ret_code = 'STATE_FAILED') THEN

      p_return_code := 'STATE_FAILED';
      raise g_return_true_exc;

    END IF;

    IF (l_ret_code IS NOT NULL) THEN

      -- for backwards compatibility with callers,
      -- mask encumbrance return codes as submission_failed.

      p_return_code := 'SUBMISSION_FAILED';
      raise g_return_true_exc;

    END IF;

    return(TRUE);

  EXCEPTION

    WHEN g_return_true_exc THEN
      return(TRUE);

    WHEN g_return_false_exc THEN
      return(FALSE);

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_ACTIONS',
                             location => l_progress,
                             error_code => SQLCODE);

      return(FALSE);

  END close_manual;



/* ----------------------------------------------------------------------- */
--<DBI Req Fulfillment 11.5.11 Start >
  -------------------------------------------------------------------------------
  --Start of Comments
  --Name:get_closure_dates
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  -- This function returns the closure date for a line_location_id
  -- depending upon the call mode
  -- INVOICE CLOSE:  maximum invoice date from the ap_invoices_all
  -- RECEIVE CLOSE:  maximum transaction date from the rcv_transactions
  -- CLOSE: maximum of the invoice_date and receving transaction date
  --Parameters:
  --IN:
  --p_call_mode
  -- Valid values are 'CLOSE','INVOICE CLOSE', or 'RECEIVE CLOSE'.
  -- It determines the type of closure date to be determined
  --p_line_location_id
  --  Line Location id  for Document
  --IN OUT:
  --N/A
  --Testing:
  -- Refer the Technical Design for 'DBI requisition Fulfillment'
  --End of Comments
-----------------------------------------------------------------------------

FUNCTION get_closure_dates(p_call_mode  IN VARCHAR2,
                         p_line_location_id IN NUMBER
                         ) RETURN DATE
IS
     l_closed_date  po_line_locations_all.closed_date%type;
     l_progress       VARCHAR2(3);
     l_log_head CONSTANT VARCHAR2(100) := g_log_head || 'GET_CLOSURE_DATES';

BEGIN
      l_progress := '001';
      l_closed_date := NULL;

if   p_call_mode = 'CLOSE' then
                      select  max(action_date)
                      into l_closed_date
                      from
                            ( select  RT.transaction_date action_date
                                      from     rcv_transactions RT
                                      where    RT.TRANSACTION_TYPE IN ('RECEIVE','ACCEPT','CORRECT','MATCH')
                                      and      RT.po_line_location_id = p_line_location_id
                              union
                               select   AD.accounting_date action_date  --Bug#18424728 FIX
                                        from     ap_invoice_distributions_all AD,
                                                 ap_invoices_all AP,
                                                 po_distributions_all POD
                                       where    AD.invoice_id = AP.invoice_id
                                       and      AD.po_distribution_id = POD.po_distribution_id
                                       and      POD.line_location_id = p_line_location_id
                                       and      nvl(AD.reversal_flag,'N') NOT IN ('Y')
                            );
      l_progress := '010';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_stmt(l_log_head,
                          l_progress,
                          'End of CLOSE mode call');
    END IF;
elsif  p_call_mode = 'INVOICE CLOSE' then
                     select   max(AD.accounting_date)  --Bug#18424728 FIX
                     into     l_closed_date
                     from     ap_invoice_distributions_all AD,
                              ap_invoices_all AP,
                              po_distributions_all POD
                     where    AD.invoice_id = AP.invoice_id
                     and      AD.po_distribution_id = POD.po_distribution_id
                     and      POD.line_location_id = p_line_location_id
                     and      nvl(AD.reversal_flag,'N') NOT IN ('Y');

      l_progress := '020';
      IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,
                          l_progress,
                          'End of INVOICE CLOSE mode call');
       END IF;
else  --  call_mode = 'RECEIVE CLOSE'
                     select   max(RT.transaction_date)
                     into     l_closed_date
                     from     rcv_transactions RT
                     where    RT.TRANSACTION_TYPE IN ('RECEIVE','ACCEPT','CORRECT','MATCH')
                     and      RT.po_line_location_id = p_line_location_id;
      l_progress := '030';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,
                          l_progress,
                          'End of RECEIVE CLOSE mode call');
      PO_DEBUG.debug_end(l_log_head);
    END IF;
end if;

return(l_closed_date);

    EXCEPTION
     WHEN OTHERS THEN
       IF g_debug_unexp THEN
         PO_DEBUG.debug_exc(l_log_head, l_progress);
       END IF;
       raise;


END get_closure_dates;




END PO_ACTIONS;


/
