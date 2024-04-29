--------------------------------------------------------
--  DDL for Package Body AP_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WORKFLOW_PKG" AS
/* $Header: aphanwfb.pls 120.64.12010000.21 2010/03/02 06:42:54 anarun ship $ */
--------------------------------------------------------------
--                    Global Variables                      --
--------------------------------------------------------------
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP_WORKFLOW_PKG';
G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;

--  Public Procedure Specifications

-- Procedure Definitions
PROCEDURE insert_history_table(p_hist_rec IN AP_INV_APRVL_HIST%ROWTYPE) IS
l_api_name              CONSTANT VARCHAR2(200) := 'insert_history_table';
l_debug_info            VARCHAR2(2000);
l_hist_id               AP_INV_APRVL_HIST_ALL.APPROVAL_HISTORY_ID%TYPE;
l_iteration             NUMBER;

PRAGMA AUTONOMOUS_TRANSACTION; -- bug 8450681
BEGIN
   SELECT AP_INV_APRVL_HIST_S.nextval
   INTO l_hist_id
   FROM dual;
   --insert into the history table
   INSERT INTO  AP_INV_APRVL_HIST_ALL
     (APPROVAL_HISTORY_ID
     ,HISTORY_TYPE
     ,INVOICE_ID
     ,ITERATION
     ,RESPONSE
     ,APPROVER_ID
     ,APPROVER_NAME
     ,CREATED_BY
     ,CREATION_DATE
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_LOGIN
     ,ORG_ID
     ,AMOUNT_APPROVED
     ,HOLD_ID
     ,LINE_NUMBER
     ,APPROVER_COMMENTS
     ,NOTIFICATION_ORDER)
   VALUES (
     l_hist_id
     ,p_hist_rec.HISTORY_TYPE
     ,p_hist_rec.INVOICE_ID
     ,p_hist_rec.ITERATION
     ,p_hist_rec.RESPONSE
     ,p_hist_rec.APPROVER_ID
     ,p_hist_rec.APPROVER_NAME
     ,p_hist_rec.CREATED_BY
     ,p_hist_rec.CREATION_DATE
     ,p_hist_rec.LAST_UPDATE_DATE
     ,p_hist_rec.LAST_UPDATED_BY
     ,p_hist_rec.LAST_UPDATE_LOGIN
     ,p_hist_rec.ORG_ID
     ,p_hist_rec.AMOUNT_APPROVED
     ,p_hist_rec.HOLD_ID
     ,p_hist_rec.LINE_NUMBER
     ,p_hist_rec.APPROVER_COMMENTS
     ,p_hist_rec.NOTIFICATION_ORDER);
   l_debug_info := 'After Insert into AP_INV_APRVL_HIST_ALL';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
   END IF;
   commit;
END insert_history_table;
PROCEDURE recreate_pay_scheds(
          p_invoice_id                  IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2)

IS
  l_item_sum               ap_invoices_all.invoice_amount%TYPE;
  l_tax_sum                ap_invoices_all.invoice_amount%TYPE;
  l_misc_sum               ap_invoices_all.invoice_amount%TYPE;
  l_frt_sum                ap_invoices_all.invoice_amount%TYPE;
  l_retained_sum           ap_invoices_all.invoice_amount%TYPE;
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(500);
  l_api_name               VARCHAR2(50);
  l_hold_count             NUMBER;
  l_line_count             NUMBER;
  l_line_total             NUMBER;
  l_Sched_Hold_count       NUMBER;
  l_inv_currency_code      ap_invoices_all.invoice_currency_code%TYPE;
  l_invoice_date           ap_invoices_all.invoice_date%TYPE;


BEGIN
  -- Update the calling sequence

  l_curr_calling_sequence := 'recreate_pay_scheds <-'||P_calling_sequence;

  l_api_name := 'recreate_pay_scheds';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ISP_UTILITIES_PKG.update_invoice_header2(+)');
  END IF;

  l_debug_info := 'Step 1. update invoice amount: invoice_id = ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  BEGIN

       SELECT SUM(DECODE(line_type_lookup_code,'ITEM',NVL(amount, 0) - NVL(included_tax_amount, 0) ,0))  ITEM_SUM,
              SUM(DECODE(line_type_lookup_code,'TAX',amount,0)) + SUM(NVL(included_tax_amount, 0)) TAX_SUM,
              SUM(DECODE(line_type_lookup_code,'MISCELLANEOUS',NVL(amount, 0) - NVL(included_tax_amount, 0),0)) MISC_SUM,
              SUM(DECODE(line_type_lookup_code,'FREIGHT',NVL(amount, 0) - NVL(included_tax_amount, 0),0)) FREIGHT_SUM,
              sum(decode(line_type_lookup_code, 'ITEM', NVL(retained_amount, 0), 0)) RETAINAGE_SUM
       INTO   l_item_sum, l_tax_sum, l_misc_sum, l_frt_sum, l_retained_sum
       FROM   ap_invoice_lines_all
      WHERE  invoice_id = p_invoice_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_debug_info := 'no lines found for the invoice id = '|| p_invoice_id;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, l_debug_info);
      END IF;
  END;


    update ap_invoices_all
    set    invoice_amount = l_item_sum + l_tax_sum + l_misc_sum + l_frt_sum + l_retained_sum,
           amount_applicable_to_discount = l_item_sum + l_tax_sum + l_misc_sum + l_frt_sum + l_retained_sum,
           net_of_retainage_flag =  DECODE(l_retained_sum, 0, 'N', 'Y')
    where  invoice_id = p_invoice_id;



  l_debug_info := 'Creating Pay Schedules ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  AP_INVOICES_POST_PROCESS_PKG.insert_children (
            X_invoice_id               => p_invoice_id,
            X_Payment_Priority         => 99,
            X_Hold_count               => l_hold_count,
            X_Line_count               => l_line_count,
            X_Line_Total               => l_line_total,
            X_calling_sequence         => l_curr_calling_sequence,
            X_Sched_Hold_count         => l_Sched_Hold_count);

EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        rollback;
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_invoice_id
          ||', P_calling_sequence = ' || l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END recreate_pay_scheds;

PROCEDURE get_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_invoice_id            NUMBER;
   l_hold_id 		   NUMBER;
   l_next_approver         ame_util.approverRecord;
   l_api_name              CONSTANT VARCHAR2(200) := 'Get_Approver';
   l_debug_info            VARCHAR2(2000);
   l_org_id                NUMBER;
   l_role                  VARCHAR2(50);
   l_role_display          VARCHAR2(150);
   l_display_name          VARCHAR2(150);
   l_hist_id               AP_INV_APRVL_HIST.APPROVAL_HISTORY_ID%TYPE;
   l_name                  wf_users.name%TYPE; --bug 8620671
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;



BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');
   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   l_debug_info := l_api_name || ': get variables from workflow' ||
                ', l_invoice_id = ' || l_invoice_id ||
                ', l_hold_id = ' || l_hold_id ||
                ', l_org_id = ' || l_org_id;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
   END IF;


   --get the next approver

   AME_API.getNextApprover(applicationIdIn => 200,
                        transactionTypeIn => 'APHLD',
                        transactionIdIn => to_char(l_hold_id),
                        nextApproverOut => l_next_approver
                        );
   l_debug_info := l_api_name || ': after call to ame';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
         l_api_name,l_debug_info);
   END IF;
   IF l_next_approver.approval_status = ame_util.exceptionStatus THEN
      l_debug_info := 'Error in AME_API.getNextApprover call';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
            l_api_name,l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
   IF l_next_approver.person_id is null THEN /*no approver on the list*/
    -- added for bug 8671976
    update  ap_holds_all
    set  wf_status = 'TERMINATED'
    where hold_id = l_hold_id ;
    -- added for bug 8671976
      resultout := wf_engine.eng_completed||':'||'N';
   ELSE -- have approver
      WF_DIRECTORY.GetRoleName('PER',
                               l_next_approver.person_id,l_role,
                               l_role_display);
      WF_DIRECTORY.GetUserName('PER',
                                l_next_approver.person_id,
                                l_name,
                                l_display_name);
      WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'INTERNAL_REP_ROLE',
                        l_role);

      WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'ORIG_SYSTEM',
                                  'PER');

      WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'INTERNAL_REP_DISPLAY_NAME',
                                  l_display_name);

      WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID',
                        l_next_approver.person_id);
      --Now set the environment
      MO_GLOBAL.INIT ('SQLAP');
      MO_GLOBAL.set_policy_context('S',l_org_id);

      l_hist_rec.HISTORY_TYPE := 'HOLDAPPROVAL';
      l_hist_rec.INVOICE_ID   := l_invoice_id;
      l_hist_rec.ITERATION    := l_iteration;
      l_hist_rec.RESPONSE     := 'SENT';
      l_hist_rec.APPROVER_ID  := l_next_approver.person_id;
      l_hist_rec.APPROVER_NAME:= l_display_name;
      l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
      l_hist_rec.CREATION_DATE:= sysdate;
      l_hist_rec.LAST_UPDATE_DATE := sysdate;
      l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
      l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
      l_hist_rec.ORG_ID            := l_org_id;
      l_hist_rec.AMOUNT_APPROVED   := 0;
      l_hist_rec.HOLD_ID           := l_hold_id;
      l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;

      insert_history_table(p_hist_rec => l_hist_rec);

      resultout := wf_engine.eng_completed||':'||'Y';
   END IF;

EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','GET_APPROVER',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END get_approver;

PROCEDURE is_negotiable_flow(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_num number;
   l_debug_info            VARCHAR2(2000);
   l_api_name              CONSTANT VARCHAR2(200) := 'is_negotiable_flow';
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');
   l_debug_info := 'Before select';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   select count(1)
   into   l_num
   from   ap_invoice_lines_all ail
   where  ail.invoice_id = l_invoice_id
   and    ail.org_id = l_org_id
   and    ail.line_type_lookup_code = 'ITEM'
   and    exists (
                     (select h.line_location_id
                      from   ap_holds_all h
                      where  h.invoice_id = l_invoice_id
                      and    h.org_id = l_org_id
                      and    h.hold_id = l_hold_id
                      and    ail.po_line_location_id = h.line_location_id
                      and    h.status_flag = 'S'
                      and    h.hold_lookup_code in ('PRICE', 'QTY ORD', 'QTY REC', 'AMT ORD', 'AMT REC')));
   IF l_num > 0 THEN
      resultout := wf_engine.eng_completed||':'||'Y';
      WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'NOTF_CONTEXT',
                                  'HOLDNEGOTIABLE');
   ELSE
      WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'NOTF_CONTEXT',
                                  'HOLDNONNEGOTIABLE');
      resultout := wf_engine.eng_completed||':'||'N';
   END IF;
   l_debug_info := 'After select, reultout : ' || resultout;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','is_negotiable_flow',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END is_negotiable_flow;

PROCEDURE process_ack_pomatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_approver_id NUMBER;
   l_display_name          VARCHAR2(150);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_api_name              CONSTANT VARCHAR2(200) := 'process_ack_pomatched';
   l_debug_info            VARCHAR2(2000);
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
 -- bug 8940578
    l_comments      VARCHAR2(240);
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');

   l_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');
   l_display_name := WF_ENGINE.getItemAttrText(itemtype, itemkey,
                                       'INTERNAL_REP_DISPLAY_NAME');
     -- bug 8940578
   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');
 -- bug 8940578


   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   l_hist_rec.HISTORY_TYPE := 'HOLDAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'ACKNOWLEDGE';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := null;
   l_hist_rec.HOLD_ID           := l_hold_id;
    -- bug 8940578
    l_hist_rec.APPROVER_COMMENTS := l_comments;

   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before AME_API.updateApprovalStatus2';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_hold_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APHLD');

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','process_ack_pomatched',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END process_ack_pomatched;
PROCEDURE process_rel_pomatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_org_id                NUMBER;
   l_invoice_id            NUMBER;
   l_hold_id               NUMBER;
   l_approver_id           NUMBER;
   l_display_name          VARCHAR2(150);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_api_name              CONSTANT VARCHAR2(200) := 'process_rel_pomatched';
   l_debug_info            VARCHAR2(2000);
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
   l_comments              VARCHAR2(240);  --Bug9069200
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');

   l_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   l_display_name := WF_ENGINE.getItemAttrText(itemtype, itemkey,
                                       'INTERNAL_REP_DISPLAY_NAME');

   --Bug9069200
   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,'WF_NOTE');
   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   l_hist_rec.HISTORY_TYPE := 'HOLDAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'RELEASE';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := null;
   l_hist_rec.HOLD_ID           := l_hold_id;
   l_hist_rec.APPROVER_COMMENTS := l_comments;  --Bug9069200
   l_debug_info := 'Before ap_isp_utilities_pkg.release_hold';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   ap_isp_utilities_pkg.release_hold(p_hold_id => l_hold_id);

   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before AME_API.updateApprovalStatus2';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_hold_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APHLD');

   UPDATE ap_holds_all
   SET    wf_status = 'RELEASED'
   WHERE  hold_id = l_hold_id;

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','process_rel_pomatched',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END process_rel_pomatched;
PROCEDURE process_ack_pounmatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_org_id                NUMBER;
   l_invoice_id            NUMBER;
   l_hold_id               NUMBER;
   l_approver_id           NUMBER;
   l_display_name          VARCHAR2(150);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_api_name              CONSTANT VARCHAR2(200) := 'process_ack_pounmatched';
   l_debug_info            VARCHAR2(2000);
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
 -- bug 8940578
    l_comments      VARCHAR2(240);

BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');

   l_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   l_display_name := WF_ENGINE.getItemAttrText(itemtype, itemkey,
                                       'INTERNAL_REP_DISPLAY_NAME');
 -- bug 8940578
   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');
 -- bug 8940578

   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   l_hist_rec.HISTORY_TYPE := 'HOLDAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'ACKNOWLEDGE';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := null;
   l_hist_rec.HOLD_ID           := l_hold_id;
   l_hist_rec.APPROVER_COMMENTS := l_comments; -- bug 8940578

   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before AME_API.updateApprovalStatus2';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_hold_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APHLD');

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','process_ack_pounmatched',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END process_ack_pounmatched;
PROCEDURE process_rel_pounmatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_org_id                NUMBER;
   l_invoice_id            NUMBER;
   l_hold_id               NUMBER;
   l_approver_id           NUMBER;
   l_display_name          VARCHAR2(150);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_api_name              CONSTANT VARCHAR2(200) := 'process_rel_pounmatched';
   l_debug_info            VARCHAR2(2000);
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
   l_comments              VARCHAR2(240);  --Bug9069200
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');

   l_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   l_display_name := WF_ENGINE.getItemAttrText(itemtype, itemkey,
                                       'INTERNAL_REP_DISPLAY_NAME');

   --Bug9069200
   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,'WF_NOTE');
   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   l_hist_rec.HISTORY_TYPE := 'HOLDAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'RELEASE';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := null;
   l_hist_rec.HOLD_ID           := l_hold_id;
   l_hist_rec.APPROVER_COMMENTS := l_comments; --Bug9069200

   l_debug_info := 'Before ap_isp_utilities_pkg.release_hold';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   ap_isp_utilities_pkg.release_hold(p_hold_id => l_hold_id);

   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before AME_API.updateApprovalStatus2';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_hold_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APHLD');

   UPDATE ap_holds_all
   SET    wf_status = 'RELEASED'
   WHERE  hold_id = l_hold_id;

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','process_rel_pounmatched',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END process_rel_pounmatched;

PROCEDURE is_it_internal(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_notf_receipient_type VARCHAR2(50);
BEGIN
   l_notf_receipient_type := WF_ENGINE.getItemAttrText(itemtype, itemkey,
                                       'NOTF_RECEIPIENT_TYPE');
   IF l_notf_receipient_type = 'INTERNAL' THEN
      resultout := wf_engine.eng_completed||':'||'Y';
   ELSE
      resultout := wf_engine.eng_completed||':'||'N';
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHNE','is_it_internal',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END is_it_internal;
PROCEDURE get_supplier_contact(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

BEGIN
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHNE','get_supplier_contact',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END get_supplier_contact;

PROCEDURE process_accept_ext(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_approver_id NUMBER;
   l_internal_approver_id  NUMBER;
   l_display_name          VARCHAR2(150);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_api_name              CONSTANT VARCHAR2(200) := 'process_accept_ext';
   l_debug_info            VARCHAR2(2000);
   l_parentkey             VARCHAR2(50);
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
   l_success               BOOLEAN;
   l_error_code            VARCHAR2(4000);
   l_curr_calling_sequence VARCHAR2(2000);


BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');

   l_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'SUPPLIER_PERSON_ID');
   l_internal_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID');
   l_display_name  := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'SUPPLIER_DISPLAY_NAME');
   l_parentkey  := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'PARENT_KEY');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   l_curr_calling_sequence := 'ap_workflow_pkg.process_accept_ext';
   l_success := ap_etax_pkg.calling_etax(
                     p_invoice_id         => l_invoice_id,
                     p_calling_mode       => 'CALCULATE',
                     p_all_error_messages => 'N',
                     p_error_code         => l_error_code,
                     p_calling_sequence   => l_curr_calling_sequence);

   l_hist_rec.HISTORY_TYPE := 'HOLDNEGOTIATION';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'ACCEPT';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := null;
   l_hist_rec.HOLD_ID           := l_hold_id;

   l_debug_info := 'Before ap_isp_utilities_pkg.release_hold';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   ap_isp_utilities_pkg.release_hold(p_hold_id => l_hold_id);

   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before AME_API.updateApprovalStatus2';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_hold_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverPersonIdIn  => l_internal_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APHLD');

   l_debug_info := 'Before wf_engine.CompleteActivity';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   wf_engine.CompleteActivity(
                     itemType => 'APINVHDN',
                     itemKey  => l_parentkey,
                     activity => 'HOLD_MAIN:WAITNEGOTIABLE',
                     result   => 'NULL');

   UPDATE ap_holds_all
   SET    wf_status = 'RELEASED'
   WHERE  hold_id = l_hold_id;

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHNE','process_accept_ext',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END process_accept_ext;

PROCEDURE get_first_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

BEGIN
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHNE','get_first_approver',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END get_first_approver;

PROCEDURE process_cancel_inv_by_sup(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_approver_id NUMBER;
   l_display_name          VARCHAR2(150);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_api_name              CONSTANT VARCHAR2(200) := 'process_cancel_inv_by_sup';
   l_debug_info            VARCHAR2(2000);
   l_parentkey             VARCHAR2(50);
   l_result                BOOLEAN;
   l_last_updated_by number;
   l_last_update_login number;
   l_accounting_date date;
   l_message_name varchar2(30);
   l_invoice_amount number;
   l_base_amount number;
   l_temp_cancelled_amount number;
   l_cancelled_by number;
   l_cancelled_amount number;
   l_cancelled_date date;
   l_last_update_date date;
   l_original_prepayment_amount number;
   l_pay_curr_invoice_amount number;
   l_token varchar2(30);
   l_internal_approver_id  NUMBER;
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;


   cursor invoice is
                select  gl_date,
                        last_updated_by,
                        last_update_login
                from    ap_invoices_all
                where   invoice_id = l_invoice_id
                and     org_id = l_org_id;



BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');

   l_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'SUPPLIER_PERSON_ID');
   l_internal_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID');
   l_display_name  := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'SUPPLIER_DISPLAY_NAME');
   l_parentkey  := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'PARENT_KEY');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   l_hist_rec.HISTORY_TYPE := 'HOLDNEGOTIATION';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'CANCEL';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := null;
   l_hist_rec.HOLD_ID           := l_hold_id;
   l_debug_info := 'Before Ap_Cancel_Single_Invoice';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   open invoice;
   fetch invoice into l_accounting_date, l_last_updated_by, l_last_update_login;
   close invoice;

   l_result := ap_cancel_pkg.ap_cancel_single_invoice(
                l_invoice_id,
                l_last_updated_by,
                l_last_update_login,
                sysdate,                                -- accounting_date
                l_message_name,
                l_invoice_amount,
                l_base_amount,
                l_temp_cancelled_amount,
                l_cancelled_by,
                l_cancelled_amount,
                l_cancelled_date,
                l_last_update_date,
                l_original_prepayment_amount,
                l_pay_curr_invoice_amount,
                l_token,
                null);


   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before AME_API.updateApprovalStatus2';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_hold_id),
                                approvalStatusIn    => AME_UTIL.rejectStatus,
                                approverPersonIdIn  => l_internal_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APHLD');

   l_debug_info := 'Before wf_engine.CompleteActivity';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   wf_engine.CompleteActivity(
                     itemType => 'APINVHDN',
                     itemKey  => l_parentkey,
                     activity => 'HOLD_MAIN:WAITNEGOTIABLE',
                     result   => 'NULL');

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHNE','process_cancel_inv_by_sup',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END process_cancel_inv_by_sup;

PROCEDURE process_accept_int(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_approver_id NUMBER;
   l_display_name          VARCHAR2(150);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_api_name              CONSTANT VARCHAR2(200) := 'process_accept_int';
   l_debug_info            VARCHAR2(2000);
   l_parentkey             VARCHAR2(50);
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
   l_success               BOOLEAN;
   l_error_code            VARCHAR2(4000);
   l_curr_calling_sequence VARCHAR2(2000);
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');

   l_approver_id  := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INTERNAL_REP_PERSON_ID');
   l_display_name  := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'INTERNAL_REP_DISPLAY_NAME');
   l_parentkey  := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'PARENT_KEY');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');


   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   l_curr_calling_sequence := 'ap_workflow_pkg.process_accept_ext';
   l_success := ap_etax_pkg.calling_etax(
                     p_invoice_id         => l_invoice_id,
                     p_calling_mode       => 'CALCULATE',
                     p_all_error_messages => 'N',
                     p_error_code         => l_error_code,
                     p_calling_sequence   => l_curr_calling_sequence);
   l_hist_rec.HISTORY_TYPE := 'LINESNEGOTIATION';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'ACCEPT';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := null;
   l_hist_rec.HOLD_ID           := l_hold_id;

   l_debug_info := 'Before ap_isp_utilities_pkg.release_hold';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   ap_isp_utilities_pkg.release_hold(p_hold_id => l_hold_id);

   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before AME_API.updateApprovalStatus2';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_hold_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APHLD');

   l_debug_info := 'Before wf_engine.CompleteActivity';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   wf_engine.CompleteActivity(
                     itemType => 'APINVHDN',
                     itemKey  => l_parentkey,
                     activity => 'HOLD_MAIN:WAITNEGOTIABLE',
                     result   => 'NULL');


   UPDATE ap_holds_all
   SET    wf_status = 'RELEASED'
   WHERE  hold_id = l_hold_id;

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHNE','process_accept_int',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END process_accept_int;

/*
APINVAPR - Main Approval Process
*/


--------------------------------------------------------------
--  Public Procedures called from WF process
--------------------------------------------------------------

PROCEDURE Check_Header_Requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS

	l_result 	       ame_util.stringlist;
	l_reason 	       ame_util.stringlist;
	l_invoice_id	 NUMBER;
      l_hist_rec         AP_INV_APRVL_HIST%ROWTYPE;
	l_tr_reason	       VARCHAR2(240);
	l_api_name	       CONSTANT VARCHAR2(200) := 'Check_Header_Requirements';
	l_org_id	       NUMBER;
	l_rejected_check	 BOOLEAN  := FALSE;
	l_required_check	 BOOLEAN  := TRUE;
	l_iteration	       NUMBER;
	l_amount	       NUMBER;
	l_debug_info	 VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,
                         'AP_IAW_PKG.'|| l_api_name);
        END IF;

	l_debug_info := 'set variables from workflow';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

	l_debug_info := 'get invoice amount';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	SELECT invoice_amount
	INTO l_amount
	FROM ap_invoices_all
	WHERE invoice_id = l_invoice_id;

	l_debug_info := 'check AME if production rules should prevent approval';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
		l_api_name,l_debug_info);
        END IF;

	ame_api2.getTransactionProductions(
                applicationIdIn     => 200,
		    transactionIdIn     => to_char(l_invoice_id),
		    transactionTypeIn   => 'APINV',
		    variableNamesOut    => l_result,
		    variableValuesOut   => l_reason);

	IF l_result IS NOT NULL THEN
		l_debug_info := 'loop through production results';
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
						l_api_name,l_debug_info);
        	END IF;
		FOR i IN 1..l_result.count LOOP

			IF l_result(i) = 'NO INVOICE APPROVAL REQUIRED' THEN


				--set required flag
				l_required_check := FALSE;


				l_debug_info := 'get translation of reason';
				IF (G_LEVEL_STATEMENT >=
					G_CURRENT_RUNTIME_LEVEL) THEN
          				FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        			END IF;

				SELECT displayed_field
				into l_tr_reason
                       		FROM   ap_lookup_codes
                       		WHERE  lookup_code = l_result(i)
                       		and    lookup_type = 'NLS TRANSLATION';


				l_debug_info := 'populate history record Variables';
				IF (G_LEVEL_STATEMENT >=
					G_CURRENT_RUNTIME_LEVEL) THEN
          				FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        			END IF;

				l_hist_rec.invoice_id        := l_invoice_id;
				l_hist_rec.iteration         := l_iteration;
				l_hist_rec.response          := 'APPROVED';
				l_hist_rec.approver_comments := l_tr_reason;
				l_hist_rec.approver_id       :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_hist_rec.org_id            := l_org_id;
				l_hist_rec.created_by        :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_hist_rec.creation_date     := sysdate;
				l_hist_rec.last_update_date  := sysdate;
				l_hist_rec.last_updated_by   :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_hist_rec.last_update_login := -1;
				l_hist_rec.amount_approved   := l_amount;
                        l_hist_rec.history_type      := 'DOCUMENTAPPROVAL';

				l_debug_info := 'populate history record';
				IF (G_LEVEL_STATEMENT >=
					G_CURRENT_RUNTIME_LEVEL) THEN
          				FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        			END IF;

                        insert_history_table(p_hist_rec => l_hist_rec);

				l_debug_info := 'Set transaction statuses';
				IF (G_LEVEL_STATEMENT >=
                                                G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
                                        l_api_name,l_debug_info);
                                END IF;

				UPDATE AP_INVOICES_ALL
				SET WFApproval_Status = 'NOT REQUIRED'
				WHERE Invoice_Id = l_invoice_id
				AND WFApproval_Status = 'INITIATED';

				UPDATE AP_INVOICE_LINES_ALL
				SET WFApproval_Status = 'NOT REQUIRED'
				WHERE Invoice_Id = l_invoice_id
				AND WFApproval_Status = 'INITIATED';

				resultout := wf_engine.eng_completed||':'||'N';

				--we do not care if there are anymore
				--productions
				EXIT;

			ELSIF l_result(i) = 'INVOICE NOT READY' THEN

				--we need to know if header was rejected by
				--check
				l_rejected_check := TRUE;

				l_debug_info := 'get translated reason value';
				IF (G_LEVEL_STATEMENT >=
                                                G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
                                        l_api_name,l_debug_info);
                                END IF;

				SELECT displayed_field
                                into l_tr_reason
                                FROM   ap_lookup_codes
                                WHERE  lookup_code = l_result(i)
                                and    lookup_type = 'NLS TRANSLATION';

			END IF; --results
		END LOOP; -- production string lists

		IF l_required_check = TRUE and l_rejected_check = TRUE THEN

       			l_debug_info := 'populate history record Variables';
                        IF (G_LEVEL_STATEMENT >=
                                  G_CURRENT_RUNTIME_LEVEL) THEN
                       	            FND_LOG.STRING(G_LEVEL_STATEMENT,
						G_MODULE_NAME||
                                             l_api_name,l_debug_info);
                        END IF;
                        l_hist_rec.invoice_id         := l_invoice_id;
                        l_hist_rec.iteration          := l_iteration;
                        l_hist_rec.response           := 'REJECTED';
                        l_hist_rec.approver_comments  := l_tr_reason;
                        l_hist_rec.approver_id        :=
                                FND_PROFILE.VALUE('AP_IAW_USER');
                        l_hist_rec.org_id             := l_org_id;
			      l_hist_rec.created_by               :=
                                        FND_PROFILE.VALUE('AP_IAW_USER');
                        l_hist_rec.creation_date      := sysdate;
                        l_hist_rec.last_update_date   := sysdate;
                        l_hist_rec.last_updated_by    :=
                                        FND_PROFILE.VALUE('AP_IAW_USER');
                        l_hist_rec.last_update_login  := -1;
                        l_hist_rec.amount_approved    := l_amount;
                        l_hist_rec.history_type       := 'DOCUMENTAPPROVAL';

       			l_debug_info := 'populate history record';
                        IF (G_LEVEL_STATEMENT >=
                                  G_CURRENT_RUNTIME_LEVEL) THEN
                       	            FND_LOG.STRING(G_LEVEL_STATEMENT,
						G_MODULE_NAME||
                                             l_api_name,l_debug_info);
                        END IF;

                        insert_history_table(p_hist_rec => l_hist_rec);

                        UPDATE AP_INVOICES_ALL
                        SET WFApproval_Status = 'REJECTED'
                        WHERE Invoice_Id = l_invoice_id
                        AND WFApproval_Status = 'INITIATED';

                        UPDATE AP_INVOICE_LINES_ALL
                        SET WFApproval_Status = 'REJECTED'
                        WHERE Invoice_Id = l_invoice_id
                        AND WFApproval_Status = 'INITIATED';

			resultout := wf_engine.eng_completed||':'||'N';
		END IF; --required and rejected

	ELSE --there were no production results

		l_debug_info := 'continue with workflow';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                                               l_api_name,l_debug_info);
                END IF;
		resultout := wf_engine.eng_completed||':'||'Y';

	END IF;

	resultout := nvl(resultout, wf_engine.eng_completed||':'||'Y');

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Check_Header_Requirements',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Check_Header_Requirements;

PROCEDURE check_line_requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

	CURSOR matched_lines (l_invoice_id IN VARCHAR2) IS
	   SELECT line_number, amount
	   FROM ap_invoice_lines_all
	   WHERE po_header_id is not null
	   AND invoice_id = l_invoice_id
	   AND wfapproval_status = 'INITIATED';

	l_result 	         ame_util.stringlist;
	l_reason 	         ame_util.stringlist;
	l_invoice_id	   NUMBER;
	l_l_hist	         AP_INV_APRVL_HIST%ROWTYPE;
	l_tr_reason	         VARCHAR2(240);
	l_api_name	         CONSTANT VARCHAR2(200) := 'Check_Line_Requirements';
	l_org_id	         NUMBER;
	l_required_check	   BOOLEAN  := TRUE;
	l_iteration	         NUMBER;
	l_amount	         NUMBER;
	l_debug_info	   VARCHAR2(2000);
	l_line_number        NUMBER;
      l_lines_require_approval NUMBER;

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                         l_api_name,
                         'AP_WORKFLOW_PKG.'|| l_api_name);
        END IF;

	/*
	l_debug_info := 'set variables from workflow';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

	--check AME if any production rules should prevent approval
	ame_api2.getTransactionProductions(applicationIdIn => 200,
		transactionIdIn     =>   to_char(l_invoice_id),
		transactionTypeIn   =>   'APINV',
		variableNamesOut    =>   l_result,
		variableValuesOut   =>   l_reason);


	--current hack because AME allows us to set production conditions
	--at the line level, but the production results are always at the
	--transaction level.
	--So we are looking for line level production pairs, but
	--we will still need to identify which lines apply.

	IF l_result IS NOT NULL THEN
	   --loop through production results
	   FOR i IN 1..l_result.count LOOP
		IF l_result(i) = 'NO LINE APPROVAL REQUIRED' THEN

		   IF l_reason(i) = 'LINE MATCHED' THEN

		  	l_debug_info := 'get translation';
			IF (G_LEVEL_STATEMENT >=
						G_CURRENT_RUNTIME_LEVEL) THEN
          		   FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        		END IF;

			SELECT displayed_field
			into l_tr_reason
               		FROM   ap_lookup_codes
               		WHERE  lookup_code = l_result(i)
               		and    lookup_type = 'NLS TRANSLATION';

		  	l_debug_info := 'Open Lines Cursor to Update History Tables';
			IF (G_LEVEL_STATEMENT >=
						G_CURRENT_RUNTIME_LEVEL) THEN
          		   FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        		END IF;

			OPEN matched_lines(l_invoice_id);
			LOOP

		  	   l_debug_info := 'After Open Into Fetch Lines Cursor';
			   IF (G_LEVEL_STATEMENT >=
						G_CURRENT_RUNTIME_LEVEL) THEN
          		       FND_LOG.STRING(G_LEVEL_STATEMENT,
				   	    G_MODULE_NAME||
					    l_api_name,l_debug_info);
        		   END IF;

			   FETCH matched_lines
			   INTO l_line_number, l_amount;
			   EXIT WHEN matched_lines%NOTFOUND;

		  	   l_debug_info := 'Populate History Variables';
			   IF (G_LEVEL_STATEMENT >=
						G_CURRENT_RUNTIME_LEVEL) THEN
          		       FND_LOG.STRING(G_LEVEL_STATEMENT,
				   	    G_MODULE_NAME||
					    l_api_name,l_debug_info);
        		   END IF;

				--populate history record
				l_l_hist.invoice_id           := l_invoice_id;
				l_l_hist.iteration            := l_iteration;
				l_l_hist.response             := 'APPROVED';
				l_l_hist.approver_comments    := l_tr_reason;
				l_l_hist.approver_id          :=
			        	FND_PROFILE.VALUE('AP_IAW_USER');
				l_l_hist.org_id               := l_org_id;
				l_l_hist.line_number          := l_line_number;
				l_l_hist.amount_approved      :=
						l_amount;
			 	l_l_hist.created_by           :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_l_hist.creation_date        := sysdate;
				l_l_hist.last_updated_by      :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_l_hist.last_update_date     := sysdate;
				l_l_hist.last_update_login    := -1;
				l_l_hist.item_class           := 'APINV';
				l_l_hist.item_id              := l_invoice_id;
                        l_l_hist.history_type         := 'LINEAPPROVAL';

 		  	      l_debug_info := 'Populate History';
			      IF (G_LEVEL_STATEMENT >=
				   		G_CURRENT_RUNTIME_LEVEL) THEN
          		          FND_LOG.STRING(G_LEVEL_STATEMENT,
				   	    G_MODULE_NAME||
					    l_api_name,l_debug_info);
        		      END IF;

                        insert_history_table(
                              p_hist_rec => l_l_hist);

			END LOOP; --matched lines
                        CLOSE matched_lines;

 		  	l_debug_info := 'Update Lines Approval Status';
			IF (G_LEVEL_STATEMENT >=
			     G_CURRENT_RUNTIME_LEVEL) THEN
          		     FND_LOG.STRING(G_LEVEL_STATEMENT,
				   	    G_MODULE_NAME||
					    l_api_name,l_debug_info);
        		END IF;

			--Set transaction statuses
			UPDATE AP_INVOICE_LINES_ALL
			SET WFApproval_Status = 'NOT REQUIRED'
			WHERE Invoice_Id = l_invoice_id
			AND PO_Header_Id IS NOT NULL
			AND WFApproval_Status = 'INITIATED';

			--setting counter to end because we get
			--production pairs at the transaction level
			--but are checking for line requirements
			--Therefore, once we fix all the lines above
			--we do not need to check for any other line
			--production pairs.
			EXIT;
		   END IF; --reason
		END IF; --results
	   END LOOP; -- production string lists
	END IF; --productions

      l_debug_info := 'Check if any more lines require approval';
	IF (G_LEVEL_STATEMENT >=
	     G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      SELECT count(*)
      INTO   l_lines_require_approval
      FROM   ap_invoice_lines_all
      WHERE  invoice_id = l_invoice_id
      AND WFApproval_Status = 'INITIATED';

      IF l_lines_require_approval > 0  THEN
         l_debug_info := 'Still some lines require approval';
	   IF (G_LEVEL_STATEMENT >=
	        G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
         resultout := wf_engine.eng_completed||':'||'Y';
      ELSE
         l_debug_info := 'No More Lines require approval in this invoice';
	   IF (G_LEVEL_STATEMENT >=
	        G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
         resultout := wf_engine.eng_completed||':'||'N';
      END IF;
      */
         resultout := wf_engine.eng_completed||':'||'Y';

EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','check_line_requirements',itemtype,
                        itemkey, to_char(actid), funcmode);
        IF matched_lines%ISOPEN THEN
           CLOSE matched_lines;
        END IF;
        RAISE;
END check_line_requirements;

PROCEDURE get_approvers(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

      l_invoice_id      NUMBER;
      l_complete        VARCHAR2(1);
      l_next_approvers  ame_util.approversTable2;
      l_next_approver   ame_util.approverRecord2;
      l_index           ame_util.idList;
      l_ids             ame_util.stringList;
      l_class           ame_util.stringList;
      l_source          ame_util.longStringList;
      l_line_num        NUMBER;
      l_api_name        CONSTANT VARCHAR2(200) := 'Get_Approvers';
      l_iteration       NUMBER;
      l_debug_info      VARCHAR2(2000);
      l_org_id          NUMBER;
      l_hist_rec        AP_INV_APRVL_HIST%ROWTYPE;

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME||l_api_name,
                    'AP_WORKFLOW_PKG.'|| l_api_name);
  END IF;
  l_debug_info := l_api_name ||
                  ': get variables from workflow: itemtype = ' ||
                   itemtype ||
			', itemkey = ' || itemkey;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                     l_api_name,l_debug_info);
  END IF;

  l_invoice_id := WF_ENGINE.GETITEMATTRNumber
                  (itemtype,
                   itemkey,
                   'INVOICE_ID');
  l_iteration :=  WF_ENGINE.GETITEMATTRNumber
                  (itemtype,
                   itemkey,
                   'ITERATION');
  l_org_id := WF_ENGINE.GETITEMATTRNumber
              (itemtype,
               itemkey,
               'ORG_ID');
  l_debug_info := l_api_name ||
                  ': get variables from workflow' ||
                  ', l_invoice_id = ' || l_invoice_id ||
                  ', l_iteration = ' || l_iteration ||
                  ', l_org_id = ' || l_org_id;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_api_name,
                     l_debug_info);
  END IF;

  --get the next layer (stage) of approvers
  AME_API2.getNextApprovers1
           (applicationIdIn               => 200,
            transactionTypeIn             => 'APINV',
            transactionIdIn               => to_char(l_invoice_id),
            flagApproversAsNotifiedIn     => ame_util.booleanFalse,
            approvalProcessCompleteYNOut  => l_complete,
            nextApproversOut              => l_next_approvers,
            itemIndexesOut                => l_index,
            itemIdsOut                    => l_ids,
            itemClassesOut                => l_class,
            itemSourcesOut                => l_source);

  -- More values in the approver list
  l_debug_info := l_api_name || ': after call to ame';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_api_name,
                     l_debug_info);
  END IF;

  IF l_complete = ame_util.booleanFalse THEN
     -- Loop through approvers' table returned by AME
     l_debug_info := l_api_name || ': more approvers';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME||l_api_name,
                       l_debug_info);
     END IF;
     l_debug_info := l_api_name ||
                     ': looping through approvers'||
                     ', next_approvers.count = ' ||
                     l_next_approvers.count;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME||l_api_name,
                       l_debug_info);
     END IF;
     --
     FOR l_table IN 1..l_next_approvers.count LOOP
        l_next_approver := l_next_approvers(l_table);
        IF nvl(l_next_approver.item_class,'line item') <>
           ame_util.headerItemClassName
	THEN
        l_debug_info := l_api_name || ': item_id = '|| l_next_approver.item_id;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_api_name,
                          l_debug_info);
        END IF;
        --
        --if the approver record does not have a value for item_id,
        --we need to use the item lists returned by AME to determine
        --the items associated with this approver.
        --
        IF l_next_approver.item_id IS NULL THEN
           l_debug_info := 'item_id is null';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME||l_api_name,
                             l_debug_info);
           END IF;
           FOR l_rec IN 1..l_index.count LOOP
             --l_index contains the mapping between
             --approvers and items
             l_debug_info := 'looping through l_rec';
             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,
                               G_MODULE_NAME||l_api_name,
                               l_debug_info);
             END IF;
             IF l_index(l_rec) = l_table THEN
                l_debug_info := 'check type of item class';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  G_MODULE_NAME||l_api_name,
                                  l_debug_info);
                END IF;
                --Depending on the type of item class, we need to set
                --some variables. Need correction once project/dist seeded
                IF l_class(l_rec) = ame_util.lineItemItemClassName THEN
                  l_line_num := l_ids(l_rec);
                ELSIF l_class(l_rec) = 'project code' THEN
                  -- Manoj:
                  -- Need to have an array of lines
                  --
                  /*SELECT Invoice_Line_Number
                  INTO   l_line_num
                  FROM   AP_INVOICE_DISTRIBUTIONS_ALL
                  WHERE project_id =l_ids(l_rec);*/
                  null;
                ELSIF l_class(l_rec) = ame_util.costCenterItemClassName THEN
                  -- Manoj:
                  -- Need to have an array of lines
                  --
                  /*SELECT Invoice_Line_Number
                  INTO   l_line_num
                  FROM   AP_INVOICE_DISTRIBUTIONS_ALL
                  WHERE  project_id =l_ids(l_rec);*/
                  null;
                ELSIF l_class(l_rec) <>
                      ame_util.lineItemItemClassName
                      AND l_class(l_rec) <>
                      ame_util.headerItemClassName THEN
                  SELECT Invoice_Line_Number
                  INTO   l_line_num
                  FROM   AP_INVOICE_DISTRIBUTIONS_ALL
                  WHERE  invoice_distribution_id = l_ids(l_rec);
                END IF; --l_class
/**************/
                --IF l_class(l_rec) <>
                --      ame_util.headerItemClassName THEN
                AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.notifiedStatus,
                           approverNameIn  => l_next_approver.NAME,
                           transactionTypeIn =>  'APINV',
                           itemClassIn     => l_class(l_rec),
                           itemIdIn        => l_ids(l_rec));
                --END IF;
/**************/

                --
                --Insert record into ap_apinv_approvers
                --
                INSERT INTO AP_APINV_APPROVERS(
				INVOICE_ID,
				INVOICE_ITERATION,
				INVOICE_KEY,
				LINE_NUMBER,
				NOTIFICATION_STATUS,
				ROLE_NAME,
				ORIG_SYSTEM,
				ORIG_SYSTEM_ID,
				DISPLAY_NAME,
				APPROVER_CATEGORY,
				API_INSERTION,
				AUTHORITY,
				APPROVAL_STATUS,
				ACTION_TYPE_ID,
				GROUP_OR_CHAIN_ID,
				OCCURRENCE,
				SOURCE,
				ITEM_CLASS,
				ITEM_ID,
				ITEM_CLASS_ORDER_NUMBER,
				ITEM_ORDER_NUMBER,
				SUB_LIST_ORDER_NUMBER,
				ACTION_TYPE_ORDER_NUMBER,
				GROUP_OR_CHAIN_ORDER_NUMBER,
				MEMBER_ORDER_NUMBER,
				APPROVER_ORDER_NUMBER,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				CREATED_BY,
				CREATION_DATE,
				PROGRAM_APPLICATION_ID,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID )
				VALUES(
				l_invoice_id,
				l_iteration,
				itemkey,
				l_line_num,
				'PEND',
				l_next_approver.NAME,
				l_next_approver.ORIG_SYSTEM,
				l_next_approver.ORIG_SYSTEM_ID,
				l_next_approver.DISPLAY_NAME,
				l_next_approver.APPROVER_CATEGORY,
				l_next_approver.API_INSERTION,
				l_next_approver.AUTHORITY,
				l_next_approver.APPROVAL_STATUS,
				l_next_approver.ACTION_TYPE_ID,
				l_next_approver.GROUP_OR_CHAIN_ID,
				l_next_approver.OCCURRENCE,
				l_next_approver.SOURCE,
				l_class(l_rec),
				l_ids(l_rec),
				l_next_approver.ITEM_CLASS_ORDER_NUMBER,
				l_next_approver.ITEM_ORDER_NUMBER,
				l_next_approver.SUB_LIST_ORDER_NUMBER,
				l_next_approver.ACTION_TYPE_ORDER_NUMBER,
				l_next_approver.GROUP_OR_CHAIN_ORDER_NUMBER,
				l_next_approver.MEMBER_ORDER_NUMBER,
				l_next_approver.APPROVER_ORDER_NUMBER,
				nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
								sysdate,
				nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
								-1),
				nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
				sysdate,
				200,
				0,
				sysdate,
				0);
                l_debug_info := 'after insert';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  G_MODULE_NAME||l_api_name,
                                  l_debug_info);
                END IF;
                l_debug_info := 'Before calling insert_history_table';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  G_MODULE_NAME||l_api_name,
                                  l_debug_info);
                END IF;
                l_hist_rec.HISTORY_TYPE := 'LINESAPPROVAL';
                l_hist_rec.INVOICE_ID   := l_invoice_id;
                l_hist_rec.line_number   := l_line_num;
                l_hist_rec.amount_approved := 0;

                l_hist_rec.ITERATION    := l_iteration;
                l_hist_rec.RESPONSE     := 'SENT';
                l_hist_rec.APPROVER_ID  := l_next_approver.ORIG_SYSTEM_ID;
                l_hist_rec.APPROVER_NAME:= l_next_approver.DISPLAY_NAME;
                l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
                l_hist_rec.CREATION_DATE:= sysdate;
                l_hist_rec.LAST_UPDATE_DATE := sysdate;
                l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
                l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
                l_hist_rec.ORG_ID            := l_org_id;


                insert_history_table(p_hist_rec => l_hist_rec);

                l_debug_info := 'After calling insert_history_table';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  G_MODULE_NAME||l_api_name,
                                  l_debug_info);
                END IF;
             END IF; --l_index mapping
           END LOOP; -- l_index mapping
        ELSE  --only one item_id per approver
          l_debug_info := 'only one item_id per approver';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,
                            G_MODULE_NAME||l_api_name,
                            l_debug_info);
          END IF;
          --
          --Depending on the type of item class, we need to set
          --some variables:
          --
	    IF l_next_approver.item_class =
             ame_util.lineItemItemClassName THEN
             l_line_num := l_next_approver.item_id;
          ELSIF l_next_approver.item_class = 'project code' THEN
             -- Manoj:
             -- Need to have an array of lines
             --
             /*SELECT Invoice_Line_Number
             INTO   l_line_num
             FROM   AP_INVOICE_DISTRIBUTIONS_ALL
             WHERE  project_id = l_next_approver.item_id;*/
             null;
          ELSIF l_next_approver.item_class =
                ame_util.costCenterItemClassName THEN
             -- Manoj:
             -- Need to have an array of lines
             --
             /*SELECT Invoice_Line_Number
             INTO   l_line_num
             FROM   AP_INVOICE_DISTRIBUTIONS_ALL
             WHERE  project_id = l_next_approver.item_id;*/
             null;
          ELSIF l_next_approver.item_class <>
                ame_util.lineItemItemClassName
                AND l_next_approver.item_class <>
                ame_util.headerItemClassName THEN
             SELECT Invoice_Line_Number
             INTO   l_line_num
             FROM   AP_INVOICE_DISTRIBUTIONS_ALL
             WHERE  invoice_distribution_id = l_next_approver.item_id;
          END IF; --l_class

/********/
                --IF l_next_approver.item_class <>
                --ame_util.headerItemClassName THEN
                AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.notifiedStatus,
                           approverNameIn  => l_next_approver.NAME,
                           transactionTypeIn =>  'APINV',
                           itemClassIn     => l_next_approver.item_class,
                           itemIdIn        => l_next_approver.item_id);
                --END IF;
/*********/
          --Insert record into ap_apinv_approvers
          INSERT INTO AP_APINV_APPROVERS(
				INVOICE_ID,
				INVOICE_ITERATION,
				INVOICE_KEY,
				LINE_NUMBER,
				NOTIFICATION_STATUS,
				ROLE_NAME,
				ORIG_SYSTEM,
				ORIG_SYSTEM_ID,
				DISPLAY_NAME,
				APPROVER_CATEGORY,
				API_INSERTION,
				AUTHORITY,
				APPROVAL_STATUS,
				ACTION_TYPE_ID,
				GROUP_OR_CHAIN_ID,
				OCCURRENCE,
				SOURCE,
				ITEM_CLASS,
				ITEM_ID,
				ITEM_CLASS_ORDER_NUMBER,
				ITEM_ORDER_NUMBER,
				SUB_LIST_ORDER_NUMBER,
				ACTION_TYPE_ORDER_NUMBER,
				GROUP_OR_CHAIN_ORDER_NUMBER,
				MEMBER_ORDER_NUMBER,
				APPROVER_ORDER_NUMBER,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				CREATED_BY,
				CREATION_DATE,
				PROGRAM_APPLICATION_ID,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID )
				VALUES(
				l_invoice_id,
				l_iteration,
				itemkey,
				l_line_num,
				'PEND',
				l_next_approver.NAME,
				l_next_approver.ORIG_SYSTEM,
				l_next_approver.ORIG_SYSTEM_ID,
				l_next_approver.DISPLAY_NAME,
				l_next_approver.APPROVER_CATEGORY,
				l_next_approver.API_INSERTION,
				l_next_approver.AUTHORITY,
				l_next_approver.APPROVAL_STATUS,
				l_next_approver.ACTION_TYPE_ID,
				l_next_approver.GROUP_OR_CHAIN_ID,
				l_next_approver.OCCURRENCE,
				l_next_approver.SOURCE,
				l_next_approver.item_class,
				l_next_approver.item_id,
				l_next_approver.ITEM_CLASS_ORDER_NUMBER,
				l_next_approver.ITEM_ORDER_NUMBER,
				l_next_approver.SUB_LIST_ORDER_NUMBER,
				l_next_approver.ACTION_TYPE_ORDER_NUMBER,
				l_next_approver.GROUP_OR_CHAIN_ORDER_NUMBER,
				l_next_approver.MEMBER_ORDER_NUMBER,
				l_next_approver.APPROVER_ORDER_NUMBER,
				nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
                                				sysdate,
                                nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
								-1),
                                nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
                                sysdate,
                                200,
                                0,
                                sysdate,
                                0);
           l_debug_info := 'Before calling insert_history_table';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  G_MODULE_NAME||l_api_name,
                                  l_debug_info);
           END IF;
           l_hist_rec.HISTORY_TYPE := 'LINESAPPROVAL';
           l_hist_rec.INVOICE_ID   := l_invoice_id;
           l_hist_rec.line_number   := l_line_num;
           l_hist_rec.amount_approved := 0;

           l_hist_rec.ITERATION    := l_iteration;
           l_hist_rec.RESPONSE     := 'SENT';
           l_hist_rec.APPROVER_ID  := l_next_approver.ORIG_SYSTEM_ID;
           l_hist_rec.APPROVER_NAME:= l_next_approver.DISPLAY_NAME;
           l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID
        ')),-1);
           l_hist_rec.CREATION_DATE:= sysdate;
           l_hist_rec.LAST_UPDATE_DATE := sysdate;
           l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USE
        R_ID')),-1);
           l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LO
        GIN_ID')),-1);
           l_hist_rec.ORG_ID            := l_org_id;


           insert_history_table(p_hist_rec => l_hist_rec);
           l_debug_info := 'After calling insert_history_table';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  G_MODULE_NAME||l_api_name,
                                  l_debug_info);
           END IF;
        END IF; --more than one item_id per approver
        END IF; -- end if for IF nvl(l_next_approver.item_class,
	        -- 'line item') <> ame_util.headerItemClassName
     END LOOP; --nextApprovers table
  END IF; --complete
  resultout := wf_engine.eng_completed;
EXCEPTION
   WHEN OTHERS THEN
        WF_CORE.CONTEXT('APINVAPR','get_approvers',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END get_approvers;

PROCEDURE identify_approvers(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
  l_invoice_id	NUMBER;
  l_iteratation	NUMBER;
  l_not_iteration	NUMBER;
  l_pend		NUMBER;
  l_sent		NUMBER;
  l_comp		NUMBER;
  l_name		VARCHAR2(320);
  l_api_name	CONSTANT VARCHAR2(200) := 'Identify_Approvers';
  l_iteration	NUMBER;
  l_debug_info	VARCHAR2(2000);

  l_org_id                      NUMBER;
  l_role                        VARCHAR2(50);
  l_orig_id                     NUMBER;
  l_invoice_type_lookup_code    ap_invoices_all.invoice_type_lookup_code%TYPE;

  CURSOR Group_Approvers IS
  SELECT distinct role_name
  FROM   ap_apinv_approvers
  WHERE  notification_status = 'PEND'
  AND    invoice_key = itemkey
  AND    line_number IS NOT NULL;

BEGIN

  l_pend := 0;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME||l_api_name,
                    'AP_WORKFLOW_PKG.'|| l_api_name);
  END IF;
  l_debug_info := l_api_name ||
                  ': get variables from workflow: itemtype = ' ||
                   itemtype ||
			', itemkey = ' || itemkey;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                     l_api_name,l_debug_info);
  END IF;

  l_invoice_id := WF_ENGINE.GETITEMATTRNumber
                  (itemtype,
                   itemkey,
                   'INVOICE_ID');
  l_iteration := WF_ENGINE.GETITEMATTRNumber
                 (itemtype,
                  itemkey,
                  'ITERATION');

  l_debug_info := l_api_name ||': invoice_id = ' ||
                  l_invoice_id ||
			', iteration = ' ||
                  l_iteration;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME||l_api_name,
                    l_debug_info);
  END IF;

  l_debug_info := 'Check for Pending Approvers to be notified';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME||l_api_name,
                    l_debug_info);
  END IF;

  l_debug_info := 'Process Group Approvers Cursor';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME||l_api_name,
                    l_debug_info);
  END IF;

  FOR Group_Approvers_Rec IN Group_Approvers LOOP

    l_debug_info := 'Inside Group Approvers Loop for Role: '||
                    Group_Approvers_Rec.role_name;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME||l_api_name,
                      l_debug_info);
    END IF;

    l_pend := 1;

    l_debug_info := 'Get Notification Iteration';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME||l_api_name,
                      l_debug_info);
    END IF;

    SELECT nvl(max(notification_iteration),0) + 1
    INTO   l_not_iteration
    FROM   ap_apinv_approvers
    WHERE  invoice_key = itemkey;

    l_debug_info := 'Notification Iteration:'||l_not_iteration;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME||l_api_name,
                      l_debug_info);
    END IF;

    l_debug_info := 'Update Iteration Value in ap_apinv_approvers';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME||l_api_name,
                      l_debug_info);
    END IF;

    UPDATE ap_apinv_approvers
    SET    notification_iteration = l_not_iteration,
           notification_key = itemkey || '_' || l_not_iteration,
           child_process_item_key = itemkey || '_' || l_not_iteration,
	   child_process_item_type = 'APINVAPR',
           item_key = itemkey || '_' || l_not_iteration,
	   item_type = 'APINVAPR'
    WHERE  role_Name = Group_Approvers_Rec.role_name
    AND    invoice_key = itemkey
    AND    line_number IS NOT NULL
    AND    notification_status = 'PEND';

  END LOOP;

  IF l_pend <> 0 THEN
    resultout := wf_engine.eng_completed||':'||'MORE';
  ELSE
    l_debug_info := 'Into the No Pending Case';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                      l_api_name,l_debug_info);
    END IF;

    BEGIN
      SELECT SUM(DECODE(notification_status, 'SENT', 1, 0)),
             SUM(DECODE(notification_status, 'COMP', 1, 0))
      INTO   l_sent,
             l_comp
      FROM   ap_apinv_approvers
      WHERE  invoice_key = itemkey
      GROUP BY invoice_key;
    EXCEPTION
      WHEN OTHERS THEN
        l_sent := 0;
        l_comp := 0;
    END;
    l_debug_info := l_api_name ||
                    ': sent = ' || l_sent ||
			  ', complete = ' || l_comp;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                      l_api_name,l_debug_info);
    END IF;

    --None sent at all
    IF l_sent = 0 and l_comp = 0 THEN

      l_debug_info := 'Into l_sent = 0 and l_comp = 0 case';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'Setting Approval Status for Line Records';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;

      /* For Invoices whose source is ISP there should always be
         an approver. So if there are no approvers we should mark
	 them as Rejected. */

      SELECT invoice_type_lookup_code
      INTO   l_invoice_type_lookup_code
      FROM   ap_invoices_all
      WHERE  invoice_id = l_invoice_id;

      UPDATE AP_INVOICE_LINES_ALL
      SET WFApproval_Status = DECODE(l_invoice_type_lookup_code
                                    ,'INVOICE REQUEST','REJECTED'
                                    ,'CREDIT MEMO REQUEST','REJECTED'
                                    ,'NOT REQUIRED')
      WHERE Invoice_Id = l_invoice_id
      AND WFApproval_Status = 'INITIATED';

      l_debug_info := 'Cleanup ap_apinv_approvers';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;


      DELETE FROM AP_APINV_APPROVERS
      WHERE Invoice_Id = l_invoice_id;


      l_debug_info := 'Set the Result to Finish';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;

      resultout := wf_engine.eng_completed||':'||'FINISH';

    ELSIF l_sent >0 THEN

      l_debug_info := 'Set the Result to Finish';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;
      resultout := wf_engine.eng_completed||':'||'WAIT';

    ELSIF l_sent = 0 AND l_comp >0 THEN

      l_debug_info := l_api_name ||': all complete but none sent';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'Set the Invoice Line Approval Status to Approved if it was part of the approval process';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;

      UPDATE   AP_INVOICE_LINES_ALL
      SET      WFApproval_Status = 'WFAPPROVED'
      WHERE    Invoice_Id = l_invoice_id
      AND      WFApproval_Status = 'INITIATED'
      AND      Line_Number IN (SELECT DISTINCT Line_Number
                               FROM   AP_APINV_APPROVERS
                               WHERE  invoice_id = l_invoice_id
                               AND    Invoice_Iteration = l_iteration
			       AND    NOTIFICATION_STATUS = 'COMP');

      l_debug_info := 'Set the Invoice Line Approval Status to Not Required if it was not part of the approval process';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;

      UPDATE AP_INVOICE_LINES_ALL
      SET WFApproval_Status = 'NOT REQUIRED'
      WHERE Invoice_Id = l_invoice_id
      AND WFApproval_Status = 'INITIATED';

      l_debug_info := 'Clear the ap_apinv_approvers';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
      END IF;


      DELETE FROM AP_APINV_APPROVERS
      WHERE Invoice_Id = l_invoice_id;



      resultout := wf_engine.eng_completed||':'||'FINISH';
    END IF; -- sent/complete checks
  END IF;

EXCEPTION

WHEN OTHERS
   THEN
       IF Group_Approvers%ISOpen THEN
         Close Group_Approvers;
       END IF;
        WF_CORE.CONTEXT('APINVAPR','identify_approvers',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END identify_approvers;

PROCEDURE launch_approval_notifications(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

  l_invoice_id number;
  l_iteration  number;
  l_rowid rowid := null;
  l_notification_key varchar2(320);
  l_org_id number;

  l_invoice_supplier_name       VARCHAR2(240);
  l_invoice_supplier_site       VARCHAR2(15);
  l_invoice_number              VARCHAR2(50);
  l_invoice_date                DATE;
  l_invoice_description         VARCHAR2(240);
  l_invoice_total               NUMBER;
  l_invoice_currency_code       VARCHAR2(15);
  l_role_name                   VARCHAR2(320);
  l_orig_system                 ap_apinv_approvers.orig_system%TYPE;
  l_orig_system_id              number(15);
  l_invoice_iteration           number;
  l_notification_iteration      number;
  l_approver_name               varchar2(360);

  CURSOR Notif_Process IS
  SELECT distinct role_name
  FROM   ap_apinv_approvers
  WHERE  notification_status = 'PEND'
  AND    invoice_key = itemKey
  AND    line_number is NOT NULL
  AND    notification_key IS NOT NULL;

  l_api_name	CONSTANT VARCHAR2(200) := 'launch_approval_notifications';
  l_debug_info		VARCHAR2(2000);

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME||l_api_name,
                    'AP_WORKFLOW_PKG.'|| l_api_name);
  END IF;
  l_debug_info := l_api_name ||
                  ': get variables from workflow: itemtype = ' ||
                   itemtype ||
			', itemkey = ' || itemkey;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                     l_api_name,l_debug_info);
  END IF;

  l_invoice_id := WF_ENGINE.GETITEMATTRNumber
                  (itemtype,
                   itemkey,
                   'INVOICE_ID');
  l_org_id := WF_ENGINE.GETITEMATTRNumber
                 (itemtype,
                  itemkey,
                  'ORG_ID');

  l_debug_info := l_api_name ||': invoice_id = ' ||
                  l_invoice_id ||
			', Org ID = ' ||
                  l_org_id;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME||l_api_name,
                    l_debug_info);
  END IF;

-- Bug5892455 added the union for 'Payment Request' type invoices
-- For payment Request type invoices the vendor is a customer whose
-- data wil be there in hz_party tables
SELECT     vendor_name,
           vendor_site_code,
           invoice_num,
           invoice_date,
           description,
           invoice_amount,
           invoice_currency_code
INTO
            l_invoice_supplier_name,
            l_invoice_supplier_site,
            l_invoice_number,
            l_invoice_date,
            l_invoice_description,
            l_invoice_total,
            l_invoice_currency_code
FROM
(SELECT
             PV.vendor_name vendor_name,
             PVS.vendor_site_code vendor_site_code,
             AI.invoice_num,
             AI.invoice_date,
             AI.description,
             NVL(AI.invoice_amount, 0) invoice_amount,
             AI.invoice_currency_code
  FROM
             ap_invoices_all AI,
             po_vendors PV,
             po_vendor_sites_all PVS
  WHERE
             AI.invoice_id = l_invoice_id AND
             AI.vendor_id = PV.vendor_id AND
             AI.invoice_type_lookup_code  <> 'PAYMENT REQUEST' AND
             AI.vendor_site_id = PVS.vendor_site_id(+)
UNION ALL
  SELECT
             HZP.party_name vendor_name,
             HZPS.party_site_name vendor_site_code,
             AI.invoice_num,
             AI.invoice_date,
             AI.description,
             NVL(AI.invoice_amount, 0) invoice_amount,
             AI.invoice_currency_code
   FROM
             ap_invoices_all AI,
             hz_parties HZP,
             hz_party_sites HZPS
   WHERE
             AI.invoice_id = l_invoice_id AND
             AI.party_id = HZP.party_id AND
             AI.invoice_type_lookup_code  = 'PAYMENT REQUEST' and
             AI.party_site_id = HZPS.party_site_id(+))
;
  l_debug_info := l_api_name ||
                  ': supplier_name ' || l_invoice_supplier_name ||
                  ', invoice_num = '|| l_invoice_number ||
                  ', invoice_total = '|| l_invoice_total;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                     l_api_name,l_debug_info);
  END IF;



  l_debug_info := 'Process Notif_Process Cursor';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                     l_api_name,l_debug_info);
  END IF;

  FOR Notif_Process_Rec IN Notif_Process LOOP


    IF Notif_Process_Rec.role_name IS NOT NULL THEN

      l_debug_info := l_api_name ||
                      ': Role Name ' || Notif_Process_Rec.role_name;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'Before: Create The Lines Sub Process';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      SELECT notification_key,
             invoice_iteration,
             notification_iteration,
             orig_system,
             orig_system_id
      INTO   l_notification_key,
             l_invoice_iteration,
             l_notification_iteration,
             l_orig_system,
             l_orig_system_id
      FROM   ap_apinv_approvers
      WHERE  role_name = Notif_Process_Rec.role_name
      AND    notification_status = 'PEND'
      AND    invoice_key = itemKey
      AND    rownum = 1;

      l_debug_info := l_api_name ||
                      ': Notification Key ' || l_notification_key;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      WF_ENGINE.createProcess('APINVAPR',
                               l_notification_key,
                               'APPROVAL_INVOICE_LINES');

      l_debug_info := 'After: Create The Lines Sub Process';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'Set the attributes';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_system_id,
                                Notif_Process_Rec.role_name,
                                l_approver_name);

      WF_ENGINE.SetItemAttrNumber('APINVAPR',
                                  l_notification_key,
                                  'ORG_ID',
                                  l_org_id);
      WF_ENGINE.SetItemAttrNumber('APINVAPR',
                                  l_notification_key,
                                  'INVOICE_ID',
                                  l_invoice_id);
      WF_ENGINE.SetItemAttrNumber('APINVAPR',
                                  l_notification_key,
                                  'INVOICE_ITERATION',
                                  l_invoice_iteration);
      WF_ENGINE.SetItemAttrNumber('APINVAPR',
                                  l_notification_key,
                                  'NOTF_ITERATION',
                                  l_notification_iteration);
      WF_ENGINE.SetItemAttrNumber('APINVAPR',
                                  l_notification_key,
                                  'APPROVER_ID',
                                  l_orig_system_id);
      WF_ENGINE.SETITEMATTRTEXT('APINVAPR',
                                l_notification_key,
                                'ROLE_NAME',
                                Notif_Process_Rec.role_name);
      WF_ENGINE.SETITEMATTRTEXT('APINVAPR',
                                 l_notification_key,
                                 'APPROVER_NAME',
                                 l_approver_name);
      WF_ENGINE.SETITEMATTRTEXT('APINVAPR',
                                l_notification_key,
                                'INVOICE_SUPPLIER_NAME',
                                l_invoice_supplier_name);
      WF_ENGINE.SETITEMATTRTEXT('APINVAPR',
                                l_notification_key,
                                'INVOICE_SUPPLIER_SITE',
                                l_invoice_supplier_site);
      WF_ENGINE.SETITEMATTRTEXT('APINVAPR',
                                l_notification_key,
                                'INVOICE_NUMBER',
                                l_invoice_number);
      WF_ENGINE.SETITEMATTRDATE('APINVAPR',
                                l_notification_key,
                                'INVOICE_DATE',
                                l_invoice_date);
      WF_ENGINE.SETITEMATTRTEXT('APINVAPR',
                                l_notification_key,
                                'INVOICE_DESCRIPTION',
                                l_invoice_description);
      WF_ENGINE.SETITEMATTRTEXT('APINVAPR',
                                l_notification_key,
                                'NOTIFICATION_KEY',
                                l_notification_key);
      WF_ENGINE.SETITEMATTRNUMBER
    		(
      		itemtype => 'APINVAPR',
      		itemkey => l_notification_key,
      		aname => 'INVOICE_TOTAL',
      		avalue => l_invoice_total
    		);
      WF_ENGINE.SETITEMATTRTEXT
    		(
      		itemtype => 'APINVAPR',
      		itemkey => l_notification_key,
      		aname => 'INVOICE_CURRENCY_CODE',
      		avalue => l_invoice_currency_code
    		);

      l_debug_info := 'Select the Role and Approver information';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;
      l_debug_info := 'Define Parent Child Association';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      WF_ENGINE.setItemParent('APINVAPR',
                              l_notification_key,
                              'APINVAPR',
                              itemKey,
                              null);

      l_debug_info := 'Start the child process';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      wf_engine.startProcess('APINVAPR', l_notification_key);

      l_debug_info := 'Update the ap_apinv_approvers notification status';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
      END IF;

      UPDATE ap_apinv_approvers
      SET    notification_status = 'SENT'
      WHERE  notification_key = l_notification_key;

    END IF;

  END LOOP;

  resultout := wf_engine.eng_completed||':'||'Y';

EXCEPTION

WHEN OTHERS
   THEN
        IF Notif_Process%ISOpen THEN
          CLOSE Notif_Process;
        END IF;
        WF_CORE.CONTEXT('APINVAPR','launch_approval_notifications',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END launch_approval_notifications;

PROCEDURE launch_neg_notifications(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

BEGIN
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','launch_neg_notifications',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END launch_neg_notifications;

PROCEDURE process_doc_rejection(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_invoice_id    NUMBER(15);
   l_iteration     NUMBER(15);
   l_comments      VARCHAR2(240);
   l_amount       ap_invoices_all.invoice_amount%TYPE;
   l_status        VARCHAR2(50);
   l_org_id        NUMBER(15);
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_api_name      CONSTANT VARCHAR2(200) := 'process_doc_rejection';
   l_debug_info    VARCHAR2(2000);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_esc_flag      VARCHAR2(1);
   l_esc_approver_name VARCHAR2(150);
   l_document_approver VARCHAR2(150);
   l_role VARCHAR2(150);
   l_esc_role_name VARCHAR2(150);
   l_esc_approver_id   NUMBER;
   l_invoice_total     NUMBER;


BEGIN

   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'INVOICE_ID');

   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   l_invoice_total := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'INVOICE_TOTAL');

   l_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'APPROVER_NAME');

   l_esc_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_ROLE_NAME');

   l_document_approver := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'DOCUMENT_APPROVER');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'APPROVER_ID');

   l_esc_flag  := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESCALATED');

   l_esc_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_APPROVER_NAME');

   l_esc_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ESC_APPROVER_ID');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');


   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_role := l_document_approver;
   ELSE
      l_role := l_esc_role_name;
   END IF;

   l_debug_info := 'Before calling AME esc_flag : ' || l_esc_flag;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API2.updateApprovalStatus2(applicationIdIn => 200,
             transactionIdIn     => to_char(l_invoice_id),
             approvalStatusIn    => AME_UTIL.rejectStatus,
             approverNameIn  => l_role,
             transactionTypeIn =>  'APINV',
             itemClassIn     => ame_util.headerItemClassName,
             itemIdIn        => to_char(l_invoice_id));

   fnd_client_info.set_org_context(l_org_id);

   l_hist_rec.HISTORY_TYPE := 'DOCUMENTAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.RESPONSE     := 'REJECT';
   l_hist_rec.APPROVER_COMMENTS     := l_comments;
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_hist_rec.APPROVER_ID  := l_approver_id;
      l_hist_rec.APPROVER_NAME:= l_approver_name;
   ELSE
      l_hist_rec.APPROVER_ID  := l_esc_approver_id;
      l_hist_rec.APPROVER_NAME:= l_esc_approver_name;
   END IF;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := l_invoice_total;

   l_debug_info := 'Before calling insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   insert_history_table(p_hist_rec => l_hist_rec);
   l_debug_info := 'Before UPDATE AP_INVOICES_ALL';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   UPDATE AP_INVOICES_ALL
   SET    wfapproval_status = 'REJECTED'
   WHERE invoice_id = l_invoice_id;

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION
WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','process_doc_rejection',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END process_doc_rejection;
PROCEDURE process_doc_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_invoice_id    NUMBER(15);
   l_comments      VARCHAR2(240);
   l_amount       ap_invoices_all.invoice_amount%TYPE;
   l_status        VARCHAR2(50);
   l_org_id        NUMBER(15);
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_api_name      CONSTANT VARCHAR2(200) := 'process_doc_approval';
   l_debug_info    VARCHAR2(2000);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_esc_flag      VARCHAR2(1);
   l_esc_approver_name  VARCHAR2(150);
   l_document_approver  VARCHAR2(150);
   l_role               VARCHAR2(150);
   l_esc_role_name      VARCHAR2(150);
   l_esc_approver_id    NUMBER;
   l_invoice_total      NUMBER;
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
-- added for the delegation enhancement
   l_role_name             VARCHAR2(50);
   l_esc_role_actual     VARCHAR2(50);




BEGIN

   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'INVOICE_ID');

   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   l_invoice_total := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'INVOICE_TOTAL');

   l_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'APPROVER_NAME');

   l_esc_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_ROLE_NAME');

   l_document_approver := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'DOCUMENT_APPROVER');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'APPROVER_ID');

   l_esc_flag  := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESCALATED');

   l_esc_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_APPROVER_NAME');

   l_esc_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ESC_APPROVER_ID');

   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');
	-- added for the delegation enhancement
	  l_role_name      :=WF_ENGINE.GetItemAttrText(itemtype,
                                    itemkey,
                                    'ROLE_ACTUAL');
   l_esc_role_actual := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'ESC_ROLE_ACTUAL');
-- added for the delegation enhancement
   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_role := l_role_name; -- added for the delegation enhancement
      --l_role := l_document_approver;
   ELSE
      l_role := l_esc_role_actual ;
      --l_role := l_esc_role_name;
   END IF;

   l_debug_info := 'Before calling AME esc_flag : ' || l_esc_flag;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   AME_API2.updateApprovalStatus2(applicationIdIn => 200,
             transactionIdIn     => to_char(l_invoice_id),
             approvalStatusIn    => AME_UTIL.approvedStatus,
             approverNameIn  => l_role,
             transactionTypeIn =>  'APINV',
             itemClassIn     => ame_util.headerItemClassName,
             itemIdIn        => to_char(l_invoice_id));

   fnd_client_info.set_org_context(l_org_id);

   l_hist_rec.HISTORY_TYPE := 'DOCUMENTAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'APPROVED';
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_hist_rec.APPROVER_ID  := l_approver_id;
      l_hist_rec.APPROVER_NAME:= l_approver_name;
   ELSE
      l_hist_rec.APPROVER_ID  := l_esc_approver_id;
      l_hist_rec.APPROVER_NAME:= l_esc_approver_name;
   END IF;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := l_invoice_total;
   l_hist_rec.APPROVER_COMMENTS := l_comments;

   l_debug_info := 'Before calling insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   insert_history_table(p_hist_rec => l_hist_rec);


-- Set WF_NOTE to null
-- 01/24/2007

  WF_ENGINE.SetItemAttrText('APINVAPR',
                        itemkey,
                        'WF_NOTE',
                        null);
-- added for the delegation enhancement

  WF_ENGINE.SetItemAttrText(itemtype,
                            itemkey,
                            'FORWARD_ROLE',
                            null);
-- added for the delegation enhancement



   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION
WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','process_doc_approval',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END process_doc_approval;

PROCEDURE process_lines_rejection(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   --Define cursor for lines affected by notification
   --Note that Invoice_Key s/b the same for all records in the cursor
   --but I want to avoid another select on the table
   CURSOR   Items_Cur(itemkey IN VARCHAR2) IS
   SELECT invap.Item_Class, invap.Item_Id, invap.Role_Name,
          invap.Invoice_Key, al.line_number, al.amount
   FROM   AP_APINV_APPROVERS invap, AP_INVOICE_LINES_ALL al
   WHERE  invap.Notification_Key = itemkey
   AND    al.line_number = invap.line_number
   AND    al.invoice_id  = invap.invoice_id;

   l_api_name      CONSTANT VARCHAR2(200) := 'process_lines_rejection';
   l_invoice_id    NUMBER;
   l_level         VARCHAR2(20);
   l_result        VARCHAR2(20);
   l_invoice_key   VARCHAR2(50);
   l_name          AP_APINV_APPROVERS.ROLE_NAME%TYPE;
   l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
   l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
   l_debug_info    VARCHAR2(2000);
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_esc_flag      VARCHAR2(1);
   l_esc_approver_name VARCHAR2(150);
   l_role_name     VARCHAR2(150);
   l_role VARCHAR2(150);
   l_esc_role_name VARCHAR2(150);
   l_esc_approver_id   NUMBER;
   l_line_total     NUMBER;
   l_iteration     NUMBER(15);
   l_comments      VARCHAR2(240);
   l_org_id        NUMBER(15);
   l_line_number   ap_invoice_lines_all.line_number%TYPE;
   l_line_amount   ap_invoice_lines_all.amount%TYPE;
   l_notf_iteration        NUMBER;



BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

   l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'ITERATION');

   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   l_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'APPROVER_NAME');

   l_esc_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_ROLE_NAME');

   l_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ROLE_NAME');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'APPROVER_ID');

   l_esc_flag  := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESCALATED');
   l_esc_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_APPROVER_NAME');

   l_esc_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ESC_APPROVER_ID');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_role := l_role_name;
   ELSE
      l_role := l_esc_role_name;
   END IF;

   l_debug_info := 'Before Update Approvers table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   --Update Approvers table
   UPDATE AP_APINV_APPROVERS
   SET Notification_status = 'COMP'
   WHERE Notification_Key = itemkey;

   fnd_client_info.set_org_context(l_org_id);

   l_hist_rec.HISTORY_TYPE := 'LINESAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.RESPONSE     := 'REJECT';
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_hist_rec.APPROVER_ID  := l_approver_id;
      l_hist_rec.APPROVER_NAME:= l_approver_name;
   ELSE
      l_hist_rec.APPROVER_ID  := l_esc_approver_id;
      l_hist_rec.APPROVER_NAME:= l_esc_approver_name;
   END IF;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   --update AME status
   --For Future  check with ame as to when updateApprovalStatuses will be
   --available so there  will not be a need to loop.
   OPEN Items_Cur(itemkey);
   LOOP

      FETCH Items_Cur INTO l_item_class, l_item_id, l_name,
                                   l_invoice_key,l_line_number, l_line_amount;
      EXIT WHEN Items_Cur%NOTFOUND OR Items_Cur%NOTFOUND IS NULL;

      --update AME with response
      AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.rejectStatus,
                           approverNameIn  => l_name,
                           transactionTypeIn =>  'APINV',
                           itemClassIn     => l_item_class,
                           itemIdIn        => l_item_id);
      l_hist_rec.line_number   := l_line_number;
      l_hist_rec.AMOUNT_APPROVED   := l_line_amount;

      l_debug_info := 'Before calling insert_history_table for Line'
                       || l_line_number;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;

      insert_history_table(p_hist_rec => l_hist_rec);
   END LOOP;
   CLOSE Items_Cur;


   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   UPDATE AP_INVOICE_LINES
   SET    wfapproval_status = 'REJECTED'
          ,Last_Update_Date = sysdate
          ,Last_Updated_By = l_user_id
          ,Last_Update_Login = l_login_id
   WHERE invoice_id = l_invoice_id
   AND wfapproval_status <> 'MANUALLY APPROVED'
   AND line_number in (SELECT line_number
                       FROM ap_apinv_approvers
                       WHERE notification_key = itemkey);
   BEGIN

      SELECT invoice_key
      INTO   l_invoice_key
      FROM   AP_APINV_APPROVERS
      WHERE  Notification_Key = itemkey
      AND    rownum = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_debug_info := 'No Data Found in SELECT from AP_APINV_APPROVERS' ;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;
      RAISE;

   END;
   l_debug_info := 'Before CompleteActivity APPROVAL_MAIN:BLOCK' ||
                   'l_invoice_key = ' || l_invoice_key;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => l_invoice_key,
                        activity => 'APPROVAL_MAIN:BLOCK',
                        result   => 'NULL');

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','process_lines_rejection',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END process_lines_rejection;
PROCEDURE process_lines_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   --Define cursor for lines affected by notification
   --Note that Invoice_Key s/b the same for all records in the cursor
   --but I want to avoid another select on the table
   CURSOR   Items_Cur(itemkey IN VARCHAR2) IS
   SELECT invap.Item_Class, invap.Item_Id, invap.Role_Name,
          invap.Invoice_Key, al.line_number, al.amount
   FROM   AP_APINV_APPROVERS invap, AP_INVOICE_LINES_ALL al
   WHERE  invap.Notification_Key = itemkey
   AND    al.line_number = invap.line_number
   AND    al.invoice_id  = invap.invoice_id;

   l_api_name      CONSTANT VARCHAR2(200) := 'process_lines_approval';
   l_invoice_id    NUMBER;
   l_level         VARCHAR2(20);
   l_result        VARCHAR2(20);
   l_invoice_key   VARCHAR2(50);
   l_name          AP_APINV_APPROVERS.ROLE_NAME%TYPE;
   l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
   l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
   l_debug_info    VARCHAR2(2000);
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_esc_flag      VARCHAR2(1);
   l_esc_approver_name VARCHAR2(150);
   l_role_name     VARCHAR2(150);
   l_role VARCHAR2(150);
   l_esc_role_name VARCHAR2(150);
   l_esc_approver_id   NUMBER;
   l_line_total     NUMBER;
   l_iteration     NUMBER(15);
   l_comments      VARCHAR2(240);
   l_org_id        NUMBER(15);
   l_line_number   ap_invoice_lines_all.line_number%TYPE;
   l_line_amount   ap_invoice_lines_all.amount%TYPE;
   l_notf_iteration        NUMBER;



BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

   l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   l_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'APPROVER_NAME');

   l_esc_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_ROLE_NAME');

   l_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ROLE_NAME');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'APPROVER_ID');

   l_esc_flag  := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESCALATED');
   l_esc_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'ESC_APPROVER_NAME');

   l_esc_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ESC_APPROVER_ID');
	/*-- added for the delegation enhancement
	  l_role_name      :=WF_ENGINE.GetItemAttrText(itemtype,
                                    itemkey,
                                    'ROLE_ACTUAL');
   l_esc_role_actual := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'ESC_ROLE_ACTUAL');
-- added for the delegation enhancement

   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_role := l_role_name; -- added for the delegation enhancement
      --l_role := l_document_approver;
   ELSE
      l_role := l_esc_role_actual ;
      --l_role := l_esc_role_name;
   END IF;  */

   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_role := l_role_name;
   ELSE
      l_role := l_esc_role_name;
   END IF;

   l_debug_info := 'Before Update Approvers table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   --Update Approvers table
   UPDATE AP_APINV_APPROVERS
   SET Notification_status = 'COMP'
   WHERE Notification_Key = itemkey;

   fnd_client_info.set_org_context(l_org_id);

   l_hist_rec.HISTORY_TYPE := 'LINESAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.RESPONSE     := 'APPROVED';
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_hist_rec.APPROVER_ID  := l_approver_id;
      l_hist_rec.APPROVER_NAME:= l_approver_name;
   ELSE
      l_hist_rec.APPROVER_ID  := l_esc_approver_id;
      l_hist_rec.APPROVER_NAME:= l_esc_approver_name;
   END IF;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   --update AME status
   --For Future  check with ame as to when updateApprovalStatuses will be
   --available so there  will not be a need to loop.
   OPEN Items_Cur(itemkey);
   LOOP

      FETCH Items_Cur INTO l_item_class, l_item_id, l_name,
                                   l_invoice_key,l_line_number, l_line_amount;
      EXIT WHEN Items_Cur%NOTFOUND OR Items_Cur%NOTFOUND IS NULL;

      --update AME with response
      AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.approvedStatus,
                           approverNameIn  => l_name,
                           transactionTypeIn =>  'APINV',
                           itemClassIn     => l_item_class,
                           itemIdIn        => l_item_id);
      l_hist_rec.line_number   := l_line_number;
      l_hist_rec.AMOUNT_APPROVED   := l_line_amount;

      l_debug_info := 'Before calling insert_history_table for Line'
                       || l_line_number;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;

      insert_history_table(p_hist_rec => l_hist_rec);
   END LOOP;
   CLOSE Items_Cur;


   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   BEGIN

      SELECT invoice_key
      INTO   l_invoice_key
      FROM   AP_APINV_APPROVERS
      WHERE  Notification_Key = itemkey
      AND    rownum = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_debug_info := 'No Data Found in SELECT from AP_APINV_APPROVERS' ;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;
      RAISE;

   END;

   l_debug_info := 'Before CompleteActivity APPROVAL_MAIN:BLOCK' ||
                   'l_invoice_key = ' || l_invoice_key;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => l_invoice_key,
                        activity => 'APPROVAL_MAIN:BLOCK',
                        result   => 'NULL');

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','process_lines_approval',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END process_lines_approval;

PROCEDURE set_document_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

BEGIN
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','set_document_approver',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END set_document_approver;

PROCEDURE set_lines_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

BEGIN
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','set_lines_approver',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END set_lines_approver;

/*
APINVNEG - AP Invoice Approval Negotiation
*/

PROCEDURE get_last_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

BEGIN
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVNEG','get_last_approver',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END get_last_approver;
PROCEDURE aprvl_get_supplier_contact(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

BEGIN
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVNEG','aprvl_get_supplier_contact',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END aprvl_get_supplier_contact;

PROCEDURE aprvl_process_accept_ext(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_api_name      CONSTANT VARCHAR2(200) := 'aprvl_process_accept_ext';
   l_invoice_id    NUMBER;
   l_level         VARCHAR2(20);
   l_result        VARCHAR2(20);
   l_invoice_key   VARCHAR2(50);
   l_name          AP_APINV_APPROVERS.ROLE_NAME%TYPE;
   l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
   l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
   l_debug_info    VARCHAR2(2000);
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_role_name     VARCHAR2(150);
   l_role VARCHAR2(150);
   l_supplier_name VARCHAR2(150);
   l_supplier_role VARCHAR2(150);
   l_supplier_person_id   NUMBER;
   l_line_total     NUMBER;
   l_iteration     NUMBER(15);
   l_comments      VARCHAR2(240);
   l_org_id        NUMBER(15);
   l_line_number   ap_invoice_lines_all.line_number%TYPE;
   l_line_amount   ap_invoice_lines_all.amount%TYPE;
   l_parent_key    VARCHAR2(150);
   l_notf_iteration        NUMBER;
   l_curr_calling_sequence  VARCHAR2(2000);
   l_invoice_type_lookup_code ap_invoices_all.invoice_type_lookup_code%TYPE;

BEGIN

   l_curr_calling_sequence
             := 'AP_WORKFLOW_PKG.aprvl_process_accept_ext';
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

   l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'ITERATION');

   l_parent_key := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'PARENT_KEY');

   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);


   l_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_DISPLAY_NAME');

   l_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_ROLE');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'INTERNAL_REP_PERSON_ID');


   l_supplier_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'SUPPLIER_DISPLAY_NAME');

   l_supplier_role := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'SUPPLIER_ROLE');

   l_supplier_person_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                             itemkey,
                             'SUPPLIER_PERSON_ID');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');


   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);


   l_hist_rec.HISTORY_TYPE := 'DOCUMENTAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.RESPONSE     := 'ACCEPT';
   l_hist_rec.APPROVER_ID  := l_supplier_person_id;
   l_hist_rec.APPROVER_NAME:= l_supplier_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   --update AME status
   --For Future  check with ame as to when updateApprovalStatuses will be
   --available so there  will not be a need to loop.

      --update AME with response
   /*
   AME_API2.updateApprovalStatus2(applicationIdIn => 200,
             transactionIdIn     => to_char(l_invoice_id),
             approvalStatusIn    => AME_UTIL.approvedStatus,
             approverNameIn  => l_role_name,
             transactionTypeIn =>  'APINV',
             itemClassIn     => ame_util.headerItemClassName,
             itemIdIn        => to_char(l_invoice_id));
   */
   l_hist_rec.AMOUNT_APPROVED   := null;

   l_debug_info := 'Before calling insert_history_table for Line'
                       || l_line_number;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);


   l_debug_info := 'Before calling recreate_pay_scheds';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   SELECT invoice_type_lookup_code
   INTO   l_invoice_type_lookup_code
   FROM   AP_INVOICES_ALL
   WHERE  invoice_id = l_invoice_id;
   IF l_invoice_type_lookup_code IN ('INVOICE REQUEST'
                                    ,'CREDIT MEMO REQUEST') THEN
      recreate_pay_scheds(l_invoice_id,l_curr_calling_sequence);
   END IF;

   wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => l_parent_key,
                        activity => 'APPROVAL_INVOICE:DOCUMENT_APPROVAL_REQUEST',
                        result   => 'APPROVED');

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVNEG','aprvl_process_accept_ext',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END aprvl_process_accept_ext;

PROCEDURE aprvl_process_accept_int(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_api_name      CONSTANT VARCHAR2(200) := 'aprvl_process_accept_int';
   l_invoice_id    NUMBER;
   l_level         VARCHAR2(20);
   l_result        VARCHAR2(20);
   l_invoice_key   VARCHAR2(50);
   l_name          AP_APINV_APPROVERS.ROLE_NAME%TYPE;
   l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
   l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
   l_debug_info    VARCHAR2(2000);
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_role_name     VARCHAR2(150);
   l_role VARCHAR2(150);
   l_supplier_name VARCHAR2(150);
   l_supplier_role VARCHAR2(150);
   l_supplier_person_id   NUMBER;
   l_line_total     NUMBER;
   l_iteration     NUMBER(15);
   l_comments      VARCHAR2(240);
   l_org_id        NUMBER(15);
   l_line_number   ap_invoice_lines_all.line_number%TYPE;
   l_line_amount   ap_invoice_lines_all.amount%TYPE;
   l_parent_key    VARCHAR2(150);
   l_notf_iteration        NUMBER;
   l_curr_calling_sequence  VARCHAR2(2000);
   l_invoice_type_lookup_code ap_invoices_all.invoice_type_lookup_code%TYPE;

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   l_curr_calling_sequence := 'AP_WORKFLOW_PKG.aprvl_process_accept_int';
   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

   l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'ITERATION');

   l_parent_key := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'PARENT_KEY');

   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);


   l_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_DISPLAY_NAME');

   l_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_ROLE');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'INTERNAL_REP_PERSON_ID');


   l_supplier_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'SUPPLIER_DISPLAY_NAME');

   l_supplier_role := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'SUPPLIER_ROLE');

   l_supplier_person_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                             itemkey,
                             'SUPPLIER_PERSON_ID');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');


   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);

   l_hist_rec.HISTORY_TYPE := 'DOCUMENTAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.RESPONSE     := 'ACCEPT';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_approver_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   --update AME status
   --For Future  check with ame as to when updateApprovalStatuses will be
   --available so there  will not be a need to loop.


   l_debug_info := 'Before calling recreate_pay_scheds';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   SELECT invoice_type_lookup_code
   INTO   l_invoice_type_lookup_code
   FROM   AP_INVOICES_ALL
   WHERE  invoice_id = l_invoice_id;
   IF l_invoice_type_lookup_code IN ('INVOICE REQUEST'
                                    ,'CREDIT MEMO REQUEST') THEN
      recreate_pay_scheds(l_invoice_id,l_curr_calling_sequence);
   END IF;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => l_parent_key,
                        activity => 'APPROVAL_INVOICE:DOCUMENT_APPROVAL_REQUEST',
                        result   => 'APPROVED');

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVNEG','aprvl_process_accept_int',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END aprvl_process_accept_int;

PROCEDURE aprvl_process_cancel_inv_sup(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   --Define cursor for lines affected by notification
   --Note that Invoice_Key s/b the same for all records in the cursor
   --but I want to avoid another select on the table
   CURSOR   Items_Cur(itemkey IN VARCHAR2) IS
   SELECT invap.Item_Class, invap.Item_Id, invap.Role_Name,
          invap.Invoice_Key, al.line_number, al.amount
   FROM   AP_APINV_APPROVERS invap, AP_INVOICE_LINES_ALL al
   WHERE  invap.child_process_item_key = itemkey
   AND    al.line_number = invap.line_number
   AND    al.invoice_id  = invap.invoice_id;
   l_api_name      CONSTANT VARCHAR2(200) := 'aprvl_process_cancel_inv_sup';
   l_invoice_id    NUMBER;
   l_level         VARCHAR2(20);
   l_invoice_key   VARCHAR2(50);
   l_name          AP_APINV_APPROVERS.ROLE_NAME%TYPE;
   l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
   l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
   l_debug_info    VARCHAR2(2000);
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_role_name     VARCHAR2(150);
   l_role VARCHAR2(150);
   l_supplier_name VARCHAR2(150);
   l_supplier_role VARCHAR2(150);
   l_supplier_person_id   NUMBER;
   l_line_total     NUMBER;
   l_iteration     NUMBER(15);
   l_comments      VARCHAR2(240);
   l_org_id        NUMBER(15);
   l_line_number   ap_invoice_lines_all.line_number%TYPE;
   l_line_amount   ap_invoice_lines_all.amount%TYPE;
   l_parent_key    VARCHAR2(150);
   l_result                BOOLEAN;
   l_last_updated_by number;
   l_last_update_login number;
   l_accounting_date date;
   l_message_name varchar2(30);
   l_invoice_amount number;
   l_base_amount number;
   l_temp_cancelled_amount number;
   l_cancelled_by number;
   l_cancelled_amount number;
   l_cancelled_date date;
   l_last_update_date date;
   l_original_prepayment_amount number;
   l_pay_curr_invoice_amount number;
   l_token varchar2(30);
   l_notf_iteration        NUMBER;

   cursor invoice is
                select  gl_date,
                        last_updated_by,
                        last_update_login
                from    ap_invoices_all
                where   invoice_id = l_invoice_id
                and     org_id = l_org_id;
BEGIN

   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

   l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'ITERATION');

   l_parent_key := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'PARENT_KEY');

   l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);


   l_approver_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_DISPLAY_NAME');

   l_role_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_ROLE');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'INTERNAL_REP_PERSON_ID');


   l_supplier_name := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_DISPLAY_NAME');

   l_supplier_role := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'INTERNAL_REP_ROLE');

   l_supplier_person_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                             itemkey,
                             'INTERNAL_REP_PERSON_ID');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');


   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);

   l_debug_info := 'Before Update Approvers table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_debug_info := 'Before Ap_Cancel_Single_Invoice';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


   l_hist_rec.HISTORY_TYPE := 'LINESNEGOTIATION';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.RESPONSE     := 'CANCEL';
   l_hist_rec.APPROVER_ID  := l_approver_id;
   l_hist_rec.APPROVER_NAME:= l_approver_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   --update AME status
   --For Future  check with ame as to when updateApprovalStatuses will be
   --available so there  will not be a need to loop.

   /* Not needed since we are completing the parent activity
   --update AME with response
   AME_API2.updateApprovalStatus2(applicationIdIn => 200,
             transactionIdIn     => to_char(l_invoice_id),
             approvalStatusIn    => AME_UTIL.rejectStatus,
             approverNameIn  => l_role_name,
             transactionTypeIn =>  'APINV',
             itemClassIn     => ame_util.headerItemClassName,
             itemIdIn        => to_char(l_invoice_id));
   */
   l_debug_info := 'Before calling insert_history_table for Line'
                       || l_line_number;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);

   open invoice;
   fetch invoice into l_accounting_date, l_last_updated_by, l_last_update_login;
   close invoice;


   l_result := ap_cancel_pkg.ap_cancel_single_invoice(
                l_invoice_id,
                l_last_updated_by,
                l_last_update_login,
                sysdate,                                -- accounting_date
                l_message_name,
                l_invoice_amount,
                l_base_amount,
                l_temp_cancelled_amount,
                l_cancelled_by,
                l_cancelled_amount,
                l_cancelled_date,
                l_last_update_date,
                l_original_prepayment_amount,
                l_pay_curr_invoice_amount,
                l_token,
                null);

   wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => l_parent_key,
                        activity => 'APPROVAL_INVOICE:DOCUMENT_APPROVAL_REQUEST',
                        result   => 'REJECTED');


   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVNEG','aprvl_process_cancel_inv_sup',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END aprvl_process_cancel_inv_sup;
PROCEDURE create_hold_neg_process(p_hold_id IN NUMBER,
                                  p_ext_contact_id IN NUMBER,
                                  parentkey IN VARCHAR2,
                                  childkey  IN VARCHAR2,
				  int_ext_indicator IN VARCHAR2,
				  newchildprocess OUT NOCOPY VARCHAR2) IS
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
CURSOR csr_ap_hold_neg_details IS
SELECT PV.vendor_name,
       AI.invoice_num,
       AI.invoice_date,
       AI.description,
       AI.org_id,
       AI.invoice_id,
       AI.approval_iteration,
       nvl(p_ext_contact_id, AI.vendor_contact_id),
       NVL(AI.invoice_amount, 0),
       ahc.hold_instruction
FROM   ap_holds_all ah,
       ap_invoices_all AI,
       po_vendors PV,
       ap_hold_codes ahc
WHERE  ah.hold_id = p_hold_id
AND    AI.invoice_id = ah.invoice_id
AND    AI.vendor_id = PV.vendor_id
AND    AH.hold_lookup_code = AHC.hold_lookup_code;
l_vendor_name po_vendors.vendor_name%TYPE;
l_invoice_num ap_invoices_all.invoice_num%TYPE;
l_invoice_date  ap_invoices_all.invoice_date%TYPE;
l_invoice_description ap_invoices_all.description%TYPE;
l_invoice_id ap_invoices_all.invoice_id%TYPE;
l_org_id ap_invoices_all.org_id%TYPE;
l_name                  wf_users.name%TYPE; --bug 8620671
l_display_name          VARCHAR2(150);
l_role                  VARCHAR2(50);
l_role_display          VARCHAR2(150);
l_new_child_ItemKey     VARCHAR2(30);
l_person_id             NUMBER(15);
l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
l_notf_receipient_type  VARCHAR2(50);
l_iteration             NUMBER;
l_notf_iteration        NUMBER;
l_ext_person_id         NUMBER(15);
l_ext_user_id           NUMBER(15);
l_hold_instr            ap_hold_codes.hold_instruction%TYPE;
l_total                 ap_invoices_all.invoice_amount%TYPE;
BEGIN
   l_notf_iteration := 1; /* For Now Hold Approval has only one round of
                             Approvers */
   SELECT AP_NEGOTIATION_HIST_S.nextval
   INTO   l_new_child_ItemKey
   FROM   dual;

   OPEN csr_ap_hold_neg_details;
   FETCH csr_ap_hold_neg_details INTO
         l_vendor_name,
	 l_invoice_num,
	 l_invoice_date,
	 l_invoice_description,
	 l_org_id,
	 l_invoice_id,
	 l_iteration,
	 l_ext_user_id,
	 l_total,
	 l_hold_instr;
   CLOSE csr_ap_hold_neg_details;

   wf_engine.createProcess('APINVHNE', l_new_child_itemkey, 'HOLD_NEGOTIATION');
   WF_ENGINE.setItemParent('APINVHNE', l_new_child_itemkey,
	                   'APINVHDN', parentkey, null);
   WF_ENGINE.SetItemAttrNumber('APINVHNE',
                        l_new_child_itemkey,
                        'HOLD_ID',
                        p_hold_id);
   WF_ENGINE.SetItemAttrNumber('APINVHNE',
                        l_new_child_itemkey,
                        'INVOICE_ID',
                        l_invoice_id);
   WF_ENGINE.SetItemAttrNumber('APINVHNE',
                        l_new_child_itemkey,
                        'ORG_ID',
                        l_org_id);
   WF_ENGINE.SetItemAttrNumber('APINVHNE',
                        l_new_child_itemkey,
                        'INVOICE_TOTAL',
                        l_total);
   WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'HOLD_INSTRUCTION',
                        l_hold_instr);
   WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'INVOICE_SUPPLIER_NAME',
                        l_vendor_name);
   WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'INVOICE_NUMBER',
                        l_invoice_num);
   WF_ENGINE.SetItemAttrDate('APINVHNE',
                        l_new_child_itemkey,
                        'INVOICE_DATE',
                        l_invoice_date);
   WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'INVOICE_DESCRIPTION',
                        l_invoice_description);
   WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'PARENT_KEY',
                        parentkey);
   WF_ENGINE.SetItemAttrText('APINVHNE',
                     l_new_child_itemkey,
                     'HOLD_TYPE',
                     WF_ENGINE.GETITEMATTRText('APINVHDN',
		     parentkey,
		     'HOLD_TYPE'));

   /* Current context is Internal or External
      If Current Context is Internal that means that the negotiation is going
      out to External supplier and if Current context is External then the
      negotiation is going out to the internal Rep. */
   IF int_ext_indicator = 'I' and l_ext_user_id IS NOT NULL THEN

      WF_DIRECTORY.GetRoleName('FND_USR',l_ext_user_id,l_role,
                               l_role_display);
      l_person_id := l_ext_user_id;
      WF_DIRECTORY.GetUserName('FND_USR',
                                l_ext_user_id,
                                l_name,
                                l_display_name);
      WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'SUPPLIER_ROLE',
                        l_role);
      WF_ENGINE.SetItemAttrText('APINVHNE',
                                  l_new_child_itemkey,
                                  'SUPPLIER_DISPLAY_NAME',
                                  l_display_name);
      WF_ENGINE.SetItemAttrNumber('APINVHNE',
                        l_new_child_itemkey,
                        'SUPPLIER_PERSON_ID',
                        l_ext_user_id);

      WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'NOTF_RECEIPIENT_TYPE',
                        'EXTERNAL');
      WF_ENGINE.SetItemAttrText('APINVHNE',
                                  l_new_child_itemkey,
                                  'INTERNAL_REP_DISPLAY_NAME',
                                  WF_ENGINE.GETITEMATTRText('APINVHDN',
				                             parentkey,
						             'INTERNAL_REP_DISPLAY_NAME'));
      WF_ENGINE.SetItemAttrNumber('APINVHNE',
                                  l_new_child_itemkey,
                                  'INTERNAL_REP_PERSON_ID',
                                  WF_ENGINE.GETITEMATTRNumber('APINVHDN',
				                             parentkey,
						             'INTERNAL_REP_PERSON_ID'));
      WF_ENGINE.SetItemAttrText('APINVHNE',
                                  l_new_child_itemkey,
                                  'ORIG_SYSTEM',
                                  WF_ENGINE.GETITEMATTRText('APINVHDN',
				                             parentkey,
						             'ORIG_SYSTEM'));
      WF_ENGINE.SetItemAttrText('APINVHNE',
                                  l_new_child_itemkey,
                                  'INTERNAL_REP_ROLE',
                                  WF_ENGINE.GETITEMATTRText('APINVHDN',
				                             parentkey,
						             'INTERNAL_REP_ROLE'));
   ELSIF int_ext_indicator = 'E' THEN

      l_role := WF_ENGINE.GETITEMATTRText('APINVHDN',
                                          parentkey,
			                  'INTERNAL_REP_ROLE');
      WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'INTERNAL_REP_ROLE',
                        l_role);
      WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'DISP_NOT_RECEIVER',
                        l_role);
      l_display_name := WF_ENGINE.GETITEMATTRText('APINVHDN',
                                          parentkey,
			                  'INTERNAL_REP_DISPLAY_NAME');
      WF_ENGINE.SetItemAttrText('APINVHNE',
                                  l_new_child_itemkey,
                                  'INTERNAL_REP_DISPLAY_NAME',
                                  l_display_name);
      l_person_id := WF_ENGINE.GETITEMATTRNumber('APINVHDN',
                                          parentkey,
			                  'INTERNAL_REP_PERSON_ID');
      WF_ENGINE.SetItemAttrNumber('APINVHNE',
                        l_new_child_itemkey,
                        'INTERNAL_REP_PERSON_ID',
                        l_person_id);
      WF_ENGINE.SetItemAttrText('APINVHNE',
                        l_new_child_itemkey,
                        'NOTF_RECEIPIENT_TYPE',
                        'INTERNAL');
      WF_ENGINE.SetItemAttrText('APINVHNE',
                                  l_new_child_itemkey,
                                  'ORIG_SYSTEM',
                                  WF_ENGINE.GETITEMATTRText('APINVHDN',
				                             parentkey,
						             'ORIG_SYSTEM'));
      WF_ENGINE.SetItemAttrText('APINVHNE',
                                  l_new_child_itemkey,
                                  'SUPPLIER_DISPLAY_NAME',
                                  WF_ENGINE.GETITEMATTRText('APINVHNE',
				                             childkey,
						             'SUPPLIER_DISPLAY_NAME'));

   END IF;
   WF_ENGINE.startProcess('APINVHNE', l_new_child_itemkey);
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   -- Complete the previous negotiation process if any.

   IF childkey IS NOT NULL THEN
      l_notf_receipient_type :=  WF_ENGINE.GetItemAttrText('APINVHNE',
                               childkey,
                               'NOTF_RECEIPIENT_TYPE');
      IF l_notf_receipient_type = 'INTERNAL' THEN

          wf_engine.CompleteActivity(
                     itemType => 'APINVHNE',
                     itemKey  => childkey,
                     activity => 'HOLD_NEGOTIATION:WAITINTERNAL',
                     result   => 'NULL');
      ELSE
          wf_engine.CompleteActivity(
                     itemType => 'APINVHNE',
                     itemKey  => childkey,
                     activity => 'HOLD_NEGOTIATION:WAITEXTERNAL',
                     result   => 'NULL');
      END IF;

   END IF;

   l_hist_rec.HISTORY_TYPE := 'HOLDNEGOTIATION';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'SENT';
   l_hist_rec.APPROVER_ID  := l_person_id;
   l_hist_rec.APPROVER_NAME:= l_display_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := 0;
   l_hist_rec.HOLD_ID           := p_hold_id;

   insert_history_table(p_hist_rec => l_hist_rec);
   newchildprocess := l_new_child_itemkey;

   UPDATE ap_holds_all
   SET    wf_status = 'NEGOTIATE'
   WHERE  hold_id = p_hold_id;

EXCEPTION

WHEN OTHERS
   THEN
        RAISE;

END create_hold_neg_process;

PROCEDURE create_hold_wf_process(p_hold_id IN NUMBER) IS
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
CURSOR csr_ap_hold_details IS
SELECT PV.vendor_name,
       AI.invoice_num,
       AI.invoice_date,
       AI.description,
       AI.org_id,
       AI.invoice_id,
       alk.displayed_field,
       NVL(AI.invoice_amount, 0),
       ahc.hold_instruction
FROM   ap_holds_all ah,
       ap_invoices_all AI,
       po_vendors PV,
       ap_lookup_codes alk,
       ap_hold_codes ahc
WHERE  ah.hold_id = p_hold_id
AND    alk.lookup_code = ah.hold_lookup_code
AND    AI.invoice_id = ah.invoice_id
AND    AI.vendor_id = PV.vendor_id
AND    AH.hold_lookup_code = AHC.hold_lookup_code;
l_vendor_name po_vendors.vendor_name%TYPE;
l_invoice_num ap_invoices_all.invoice_num%TYPE;
l_invoice_date  ap_invoices_all.invoice_date%TYPE;
l_invoice_description ap_invoices_all.description%TYPE;
l_invoice_id ap_invoices_all.invoice_id%TYPE;
l_hold_type ap_lookup_codes.displayed_field%TYPE;
l_org_id ap_invoices_all.org_id%TYPE;
l_itemkey VARCHAR2(50);
l_hold_instr            ap_hold_codes.hold_instruction%TYPE;
l_total                 ap_invoices_all.invoice_amount%TYPE;

BEGIN
   /* For the main process itemkey has to be hold_id */
   l_itemkey := p_hold_id;

   OPEN csr_ap_hold_details;
   FETCH csr_ap_hold_details INTO
         l_vendor_name,
         l_invoice_num,
         l_invoice_date,
         l_invoice_description,
         l_org_id,
         l_invoice_id,
	 l_hold_type,
         l_total,
	 l_hold_instr;

   CLOSE csr_ap_hold_details;


   wf_engine.createProcess('APINVHDN', l_itemkey, 'HOLD_MAIN');
   WF_ENGINE.SetItemAttrNumber('APINVHDN',
                        l_itemkey,
                        'INVOICE_ID',
                        l_invoice_id);
   WF_ENGINE.SetItemAttrNumber('APINVHDN',
                        l_itemkey,
                        'HOLD_ID',
                        p_hold_id);
   WF_ENGINE.SetItemAttrNumber('APINVHDN',
                        l_itemkey,
                        'ORG_ID',
                        l_org_id);
   WF_ENGINE.SetItemAttrNumber('APINVHDN',
                        l_itemkey,
                        'INVOICE_TOTAL',
                        l_total);
   WF_ENGINE.SetItemAttrText('APINVHDN',
                        l_itemkey,
                        'HOLD_INSTRUCTION',
                        l_hold_instr);
   WF_ENGINE.SetItemAttrText('APINVHDN',
                        l_itemkey,
                        'INVOICE_SUPPLIER_NAME',
                        l_vendor_name);
   WF_ENGINE.SetItemAttrText('APINVHDN',
                        l_itemkey,
                        'INVOICE_NUMBER',
                        l_invoice_num);
   WF_ENGINE.SetItemAttrDate('APINVHDN',
                        l_itemkey,
                        'INVOICE_DATE',
                        l_invoice_date);
   WF_ENGINE.SetItemAttrText('APINVHDN',
                        l_itemkey,
                        'INVOICE_DESCRIPTION',
                        l_invoice_description);
   WF_ENGINE.SetItemAttrText('APINVHDN',
                        l_itemkey,
                        'HOLD_TYPE',
                        l_hold_type);
   WF_ENGINE.SetItemAttrText('APINVHDN',
                        l_itemkey,
                        'PARENT_KEY',
                        l_itemkey);

   UPDATE ap_holds_all
   SET    wf_status = 'STARTED'
   WHERE  hold_id = p_hold_id;

   WF_ENGINE.startProcess('APINVHDN', l_itemkey);



EXCEPTION

WHEN OTHERS
   THEN
        RAISE;

END create_hold_wf_process;
PROCEDURE get_header_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name          wf_users.name%TYPE; --bug 8620671
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(50);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_error_message               VARCHAR2(2000);
l_invoice_id    NUMBER(15);
l_iteration     NUMBER(9);
l_count         NUMBER(9);
l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
l_notf_iteration        NUMBER;
l_complete              VARCHAR2(1);
l_next_approvers        ame_util.approversTable2;
l_next_approver         ame_util.approverRecord2;
l_index                 ame_util.idList;
l_ids                   ame_util.stringList;
l_class                 ame_util.stringList;
l_source                ame_util.longStringList;
l_ampersand             varchar2(1);
Cursor C_invoice (p_invoice_id IN ap_invoices_all.invoice_id%TYPE) IS
SELECT invoice_type_lookup_code
      ,gl_date
      ,ap_utilities_pkg.get_gl_period_name(gl_date
                                          ,org_id)
FROM   ap_invoices_all
WHERE  invoice_id = p_invoice_id;
l_invoice_type_lookup_code ap_invoices_all.invoice_type_lookup_code%TYPE;
l_gl_date ap_invoices_all.gl_date%TYPE;
l_new_gl_date ap_invoices_all.gl_date%TYPE;
l_period_name ap_invoice_lines_all.period_name%TYPE;
l_new_period_name ap_invoice_lines_all.period_name%TYPE;
l_terms_id ap_invoices_all.terms_id%TYPE;
l_terms_date ap_invoices_all.terms_date%TYPE;
l_count_rejects number;
l_inv_match_type VARCHAR2(80);

BEGIN

   /* First Check if any of the lines got rejected. If so then
   Header status need to be set as Needs Reapproval and any lines
   in Initiated status need to be updated to Required. */

   l_invoice_id := substr(itemkey, 1, instr(itemkey,'_')-1);
   l_count_rejects := 0;

   SELECT count(*)
   into   l_count_rejects
   FROM   ap_invoice_lines_all
   WHERE  invoice_id = l_invoice_id
   AND    wfapproval_status = 'REJECTED';

   IF l_count_rejects = 0 THEN
   select '&'
   into   l_ampersand
   from   dual
   where  1 like 1 escape '&';
   l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   /*
   AME_API.getNextApprover(200,
                           substr(itemkey, 1, instr(itemkey,'_')-1),
                           'APINV',
                           l_next_approver);
   */
   AME_API2.getNextApprovers1(applicationIdIn => 200,
                        transactionTypeIn => 'APINV',
                        transactionIdIn => substr(itemkey, 1, instr(itemkey,'_')-1),
                        flagApproversAsNotifiedIn => ame_util.booleanFalse,
                        approvalProcessCompleteYNOut => l_complete,
                        nextApproversOut => l_next_approvers,
                        itemIndexesOut => l_index,
                        itemIdsOut => l_ids,
                        itemClassesOut => l_class,
                        itemSourcesOut => l_source
                        );



   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'ORG_ID');

   l_invoice_id := substr(itemkey, 1, instr(itemkey,'_')-1);
   l_iteration := substr(itemkey, instr(itemkey,'_')+1, length(itemkey));

   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   --IF l_complete = ame_util.booleanTrue THEN /*no approver on the list*/
   IF l_next_approvers.count < 1 THEN
           resultout := wf_engine.eng_completed||':'||'FINISH';

           --check for prior approvers
           SELECT count(*)
           INTO l_count
           FROM ap_inv_aprvl_hist
           WHERE invoice_id = l_invoice_id
           AND iteration = l_iteration
           AND RESPONSE <> 'MANUALLY APPROVED'
           AND history_type = 'DOCUMENTAPPROVAL';

           IF l_count >0 THEN
                   --update invoice header status
                   UPDATE AP_INVOICES_ALL
                   SET wfapproval_status = 'WFAPPROVED'
                   WHERE invoice_id = l_invoice_id
                   AND wfapproval_status <> 'MANUALLY APPROVED';
           ELSE
                   UPDATE AP_INVOICES_ALL
                   SET wfapproval_status = decode(invoice_type_lookup_code,
		                           'INVOICE REQUEST','REJECTED',
					   'CREDIT MEMO REQUEST','REJECTED',
					   'NOT REQUIRED')
                   WHERE invoice_id = l_invoice_id
                   AND wfapproval_status <> 'MANUALLY APPROVED';
           END IF;
           l_inv_match_type := WF_ENGINE.GetItemAttrText('APINVAPR',
                                                         itemkey,
                                                         'INV_MATCH_TYPE');
	   IF l_inv_match_type = 'UNMATCHED' THEN
              UPDATE AP_INVOICE_LINES_ALL
              SET wfapproval_status = 'NOT REQUIRED'
              WHERE invoice_id = l_invoice_id
              AND wfapproval_status <> 'MANUALLY APPROVED';
	   END IF;
           /* Logic for Converting ISP requests into Invoices */
           OPEN C_invoice(l_invoice_id);
           FETCH C_invoice
           INTO l_invoice_type_lookup_code
               ,l_gl_date
               ,l_period_name;
           CLOSE C_invoice;
           IF l_invoice_type_lookup_code IN ('INVOICE REQUEST'
                                          ,'CREDIT MEMO REQUEST')
	   AND l_count > 0 THEN

              ap_utilities_pkg.get_open_gl_date(P_Date => l_gl_date
                               ,P_Period_Name => l_new_period_name
                               ,P_GL_Date     => l_new_gl_date
                               ,P_Org_Id      => l_org_id);
              ap_isp_utilities_pkg.get_payment_terms (
                       p_invoice_id => l_invoice_id,
                       p_terms_id   => l_terms_id,
                       p_terms_date => l_terms_date,
                       p_calling_sequence =>
                             'ap_workflow_pkg.get_header_approver');


              UPDATE AP_INVOICES_ALL
              SET    invoice_type_lookup_code =
                        DECODE(invoice_type_lookup_code
                              ,'INVOICE REQUEST','STANDARD'
                              ,'CREDIT MEMO REQUEST', 'CREDIT'
                              ,invoice_type_lookup_code),
                     terms_id   = l_terms_id,
                     terms_date = l_terms_date
              WHERE  invoice_id = l_invoice_id;
              IF l_period_name <> l_new_period_name THEN

                 UPDATE AP_INVOICES_ALL
                 SET    gl_date = l_new_gl_date
                 WHERE  invoice_id = l_invoice_id;

                 UPDATE ap_invoice_lines_all
                 SET    accounting_date = l_new_gl_date
                       ,period_name     = l_new_period_name
                 WHERE  invoice_id      = l_invoice_id;

                 UPDATE ap_invoice_distributions_all
                 SET    accounting_date = l_new_gl_date
                       ,period_name     = l_new_period_name
                 WHERE  invoice_id      = l_invoice_id;

              END IF;
           END IF;

   ELSE /*have approver*/
           l_next_approver := l_next_approvers(1);
           WF_DIRECTORY.GetRoleName(l_next_approver.ORIG_SYSTEM
	    ,l_next_approver.ORIG_SYSTEM_ID,l_role,l_role_display);

           WF_DIRECTORY.GetUserName(l_next_approver.ORIG_SYSTEM,
                           l_next_approver.ORIG_SYSTEM_ID,
                           l_name,
                           l_display_name);

           WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'APPROVER_NAME',
                   l_display_name);

           WF_ENGINE.SetItemAttrNumber(itemtype,
                   itemkey,
                   'APPROVER_ID',
                   l_next_approver.ORIG_SYSTEM_ID); /****
		              POTENTIAL BUG ************/

           WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'DOCUMENT_APPROVER',
                   l_role);

           WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ORIG_SYSTEM',
                   l_next_approver.ORIG_SYSTEM);

           WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION',
                        nvl(l_notf_iteration,0) + 1);

--  bug 8450681
-- These values have to be cleared of before starting as the residue values will cause issue
-- in case of approver groups which has more than one approver and
-- the notification is escalated in the previous level
           WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ESCALATED',
                   null);
           WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'FORWARD_ROLE',
                   null);
           WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ROLE_ACTUAL',
                   null);

           WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ESC_ROLE_ACTUAL',
                   null);


--  bug 8450681
	   /*
           WF_ENGINE.SETITEMATTRTEXT
                (
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'INVOICE_ATTACHMENTS',
                 avalue   => ('FND:entity=AP_INVOICES' || l_ampersand ||
                         'pk1name=INVOICE_ID' || l_ampersand
                                              || 'pk1value=' || l_invoice_id));
	   */
           --call set attributes so that notification tokens will be correct
           --set_attribute_values(itemtype,itemkey);
      l_hist_rec.HISTORY_TYPE := 'DOCUMENTAPPROVAL';
      l_hist_rec.INVOICE_ID   := l_invoice_id;
      l_hist_rec.ITERATION    := l_iteration;
      l_hist_rec.NOTIFICATION_ORDER := nvl(l_notf_iteration,0) + 1;
      l_hist_rec.RESPONSE     := 'SENT';
      l_hist_rec.APPROVER_ID  := l_next_approver.ORIG_SYSTEM_ID;
      /********** POTENTIAL BUG ABOVE********************/
      l_hist_rec.APPROVER_NAME:= l_display_name;
      l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
      l_hist_rec.CREATION_DATE:= sysdate;
      l_hist_rec.LAST_UPDATE_DATE := sysdate;
      l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
      l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
      l_hist_rec.ORG_ID            := l_org_id;
      l_hist_rec.AMOUNT_APPROVED   := 0;

      insert_history_table(p_hist_rec => l_hist_rec);
           resultout := wf_engine.eng_completed||':'||'MORE';

   END IF;

   ELSE  /* For IF l_count_rejects = 0, so there are rejections */
      /* Should never go through following update since all lines
      should be either Rejected or approved by this time */
      UPDATE AP_INVOICE_LINES_ALL
      SET    wfapproval_status = 'REQUIRED'
      WHERE  invoice_id = l_invoice_id
      AND    wfapproval_status = 'INITIATED';

      UPDATE ap_invoices_all
      SET    wfapproval_status = 'NEEDS WFREAPPROVAL'
      WHERE  invoice_id = l_invoice_id;

      resultout := wf_engine.eng_completed||':'||'FINISH';
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','get_header_approver',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;

END get_header_approver;
PROCEDURE escalate_doc_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_esc_approver          AME_UTIL.approverRecord2;
   l_name                  wf_users.name%TYPE; --bug 8620671
   l_esc_approver_name     VARCHAR2(150);
   l_esc_approver_id       NUMBER(15);
   l_approver_id           NUMBER(15);
   l_invoice_id            NUMBER(15);
   l_hist_id               NUMBER(15);
   l_role                  VARCHAR2(50);
   l_esc_role              VARCHAR2(50);
   l_esc_role_display      VARCHAR2(150);
   l_org_id                NUMBER(15);
   l_level                 VARCHAR2(10);
   l_api_name              CONSTANT VARCHAR2(200) :=
                                   'escalate_doc_approval';
   l_debug_info            VARCHAR2(2000);
   l_iteration             NUMBER;
   l_invoice_total         NUMBER;
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_notf_iteration        NUMBER;
-- bug 8450681 begin
      l_display_name           VARCHAR2(150);
      l_next_approvers  ame_util.approversTable2;
      l_next_approver   ame_util.approverRecord2;
      l_index           ame_util.idList;
      l_ids             ame_util.stringList;
      l_class           ame_util.stringList;
      l_source          ame_util.longStringList;
      l_complete        VARCHAR2(1);
-- bug 8450681 end
BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   --Get the current approver info
   l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'APPROVER_ID');

   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'INVOICE_ID');

   l_invoice_total := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'INVOICE_TOTAL');

   l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                             itemkey,
                             'ORG_ID');

   l_role  := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'DOCUMENT_APPROVER');


   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   -- see if we have an TCA/WF Directory api for this select
   /*
   SELECT supervisor_id
   INTO l_esc_approver_id
   FROM per_employees_current_x
   WHERE employee_id = l_approver_id;
   */
 -- bug#6837841 Changes  Starts
   /*SELECT user_id
   INTO   l_esc_approver_id
   FROM   fnd_user
   WHERE  employee_id =
          (SELECT supervisor_id
	   FROM   per_employees_current_x
	   WHERE  employee_id = l_approver_id);

   WF_DIRECTORY.GetUserName('FND_USR',
                   l_esc_approver_id,
                   l_name,
                   l_esc_approver_name);
   WF_DIRECTORY.GetRoleName('FND_USR',
                   l_esc_approver_id,
                   l_esc_role,
                   l_esc_role_display);*/

   SELECT supervisor_id   INTO   l_esc_approver_id
	   FROM   per_employees_current_x
	   WHERE  employee_id = l_approver_id;

   WF_DIRECTORY.GetUserName('PER',
                   l_esc_approver_id,
                   l_name,
                   l_esc_approver_name);
   WF_DIRECTORY.GetRoleName('PER',
                   l_esc_approver_id,
                   l_esc_role,
                   l_esc_role_display);
-- bug#6837841 Changes End
   l_esc_approver.name := l_esc_role;
   l_esc_approver.api_insertion := ame_util.apiInsertion;
   l_esc_approver.authority := ame_util.authorityApprover;
   l_esc_approver.approval_status := ame_util.forwardStatus;

   --update AME
   AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                      transactionTypeIn =>  'APINV',
                      transactionIdIn     => to_char(l_invoice_id),
                      approvalStatusIn    => AME_UTIL.noResponseStatus,
                      approverNameIn  => l_role,
                      itemClassIn    => ame_util.headerItemClassName,
                      itemIdIn    => to_char(l_invoice_id),
                      forwardeeIn       => l_esc_approver);
-- bug 8450681  begins
--get the next layer (stage) of approvers
  AME_API2.getNextApprovers1
           (applicationIdIn               => 200,
            transactionTypeIn             => 'APINV',
            transactionIdIn               => to_char(l_invoice_id),
            flagApproversAsNotifiedIn     => ame_util.booleanFalse,
            approvalProcessCompleteYNOut  => l_complete,
            nextApproversOut              => l_next_approvers,
            itemIndexesOut                => l_index,
            itemIdsOut                    => l_ids,
            itemClassesOut                => l_class,
            itemSourcesOut                => l_source);
-- bug 8450681 ends

   --Set WF attributes
   WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ESC_APPROVER_NAME',
                   l_esc_approver_name);

   WF_ENGINE.SetItemAttrNumber(itemtype,
                   itemkey,
                   'ESC_APPROVER_ID',
                   l_esc_approver_id);

   WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ESC_ROLE_NAME',
                   l_esc_role);
-- bug 8450681 begins
   WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ESC_ROLE_ACTUAL',
                   l_esc_role);
-- bug 8450681  ends
   WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ESCALATED',
                   'Y');
   l_hist_rec.HISTORY_TYPE := 'DOCUMENTAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.RESPONSE     := 'ESCALATED';
   l_hist_rec.APPROVER_ID  := l_esc_approver_id;
   l_hist_rec.APPROVER_NAME:= l_esc_approver_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   l_hist_rec.AMOUNT_APPROVED   := l_invoice_total;

   l_debug_info := 'Before insert_history_table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   insert_history_table(p_hist_rec => l_hist_rec);

EXCEPTION
WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','get_header_approver',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END escalate_doc_approval;
PROCEDURE escalate_lines_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   --Define cursor for lines affected by notification
   CURSOR   Items_Cur(itemkey IN VARCHAR2) IS
   SELECT invap.Item_Class, invap.Item_Id, invap.Role_Name,
          invap.Invoice_Key, al.line_number, al.amount
   FROM   AP_APINV_APPROVERS invap, AP_INVOICE_LINES_ALL al
   WHERE  invap.Notification_Key = itemkey
   AND    al.line_number = invap.line_number
   AND    al.invoice_id  = invap.invoice_id;

   l_esc_approver       AME_UTIL.approverRecord2;
   l_name               wf_users.name%TYPE; --bug 8620671
   l_esc_approver_name  VARCHAR2(150);
   l_esc_approver_id    NUMBER(15);
   l_approver_id   	NUMBER(15);
   l_invoice_id    	NUMBER(15);
   l_hist_id       	NUMBER(15);
   l_role	        VARCHAR2(50);
   l_esc_role         	VARCHAR2(50);
   l_esc_role_display  	VARCHAR2(150);
   l_org_id        	NUMBER(15);
   l_api_name           CONSTANT VARCHAR2(200) :=
                                        'Escalate_Lines_approval';
   l_debug_info         VARCHAR2(2000);
   l_iteration          NUMBER;
   l_item_class		VARCHAR2(50);
   l_item_id		NUMBER;
   l_line_number        ap_invoice_lines_all.line_number%TYPE;
   l_line_amount        ap_invoice_lines_all.amount%TYPE;
   l_hist_rec           AP_INV_APRVL_HIST%ROWTYPE;
   l_comments           VARCHAR2(240);
   l_esc_flag           VARCHAR2(1);
   l_invoice_key        VARCHAR2(50);
   l_notf_iteration     NUMBER;


BEGIN

   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


   --Get the current approver info
   l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APPROVER_ID');

   l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

   l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ITERATION');

   l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ORG_ID');

   l_role  := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'ROLE_NAME');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'NOTF_ITERATION');

   --Now set the environment
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   --amy see if we have an TCA/WF Directory api for this select
   /*
   SELECT supervisor_id
   INTO l_esc_approver_id
   FROM per_employees_current_x
   WHERE employee_id = l_approver_id;
   */
/* -- commented for 8682244
   SELECT user_id
   INTO   l_esc_approver_id
   FROM   fnd_user
   WHERE  employee_id =
          (SELECT supervisor_id
           FROM   per_employees_current_x
           WHERE  employee_id = l_approver_id);


   WF_DIRECTORY.GetUserName('FND_USR',
                        l_esc_approver_id,
                        l_name,
                        l_esc_approver_name);

   WF_DIRECTORY.GetRoleName('FND_USR',
   			l_esc_approver_id,
   			l_esc_role,
   			l_esc_role_display);
*/
SELECT supervisor_id   INTO   l_esc_approver_id
	   FROM   per_employees_current_x
	   WHERE  employee_id = l_approver_id;

   WF_DIRECTORY.GetUserName('PER',
                   l_esc_approver_id,
                   l_name,
                   l_esc_approver_name);
   WF_DIRECTORY.GetRoleName('PER',
                   l_esc_approver_id,
                   l_esc_role,
                   l_esc_role_display);
-- modified for 8682244

   l_esc_approver.name := l_esc_role;
   l_esc_approver.api_insertion := ame_util.apiInsertion;
   l_esc_approver.authority := ame_util.authorityApprover;
   l_esc_approver.approval_status := ame_util.forwardStatus;

   l_hist_rec.HISTORY_TYPE := 'LINESAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.RESPONSE     := 'ESCALATED';
   l_hist_rec.APPROVER_ID  := l_esc_approver_id;
   l_hist_rec.APPROVER_NAME:= l_esc_approver_name;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   --update AME status
   --For Future  check with ame as to when updateApprovalStatuses will be
   --available so there  will not be a need to loop.
   OPEN Items_Cur(itemkey);
   LOOP

      FETCH Items_Cur INTO l_item_class, l_item_id, l_name,
                                   l_invoice_key,l_line_number, l_line_amount;
      EXIT WHEN Items_Cur%NOTFOUND OR Items_Cur%NOTFOUND IS NULL;

      --update AME
      AME_API2.updateApprovalStatus2(applicationIdIn => 200,
              		   transactionTypeIn =>  'APINV',
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.noResponseStatus,
                           approverNameIn  => l_role,
                           itemClassIn    => l_item_class,
                           itemIdIn    => l_item_id,
                           forwardeeIn       => l_esc_approver);

      l_hist_rec.line_number   := l_line_number;
      l_hist_rec.AMOUNT_APPROVED   := l_line_amount;

      l_debug_info := 'Before calling insert_history_table for Line'
                       || l_line_number;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;

      insert_history_table(p_hist_rec => l_hist_rec);

   END LOOP;
   CLOSE Items_Cur;

   --Set WF attributes
   WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'ESC_APPROVER_NAME',
                        l_esc_approver_name);

   WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'ESC_APPROVER_ID',
                        l_esc_approver_id);

   WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'ESC_ROLE_NAME',
                        l_esc_role);

   WF_ENGINE.SetItemAttrText(itemtype,
                   itemkey,
                   'ESCALATED',
                   'Y');

EXCEPTION
WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','get_header_approver',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END escalate_lines_approval;
PROCEDURE awake_approval_main(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_api_name           CONSTANT VARCHAR2(200) :=
                                        'awake_approval_main';
   l_debug_info         VARCHAR2(2000);
   l_invoice_key        VARCHAR2(150);

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   BEGIN

      SELECT invoice_key
      INTO   l_invoice_key
      FROM   AP_APINV_APPROVERS
      WHERE  Notification_Key = itemkey
      AND    rownum = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_debug_info := 'No Data Found in SELECT from AP_APINV_APPROVERS' ;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;
      RAISE;

   END;
   l_debug_info := 'Before CompleteActivity APPROVAL_MAIN:BLOCK' ||
                   'l_invoice_key = ' || l_invoice_key;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => l_invoice_key,
                        activity => 'APPROVAL_MAIN:BLOCK',
                        result   => 'NULL');

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


EXCEPTION
WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','awake_approval_main',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END awake_approval_main;

PROCEDURE create_lineapp_neg_process(p_invoice_id IN NUMBER,
					  p_ext_user_id IN NUMBER,
					  p_invoice_amount IN NUMBER,
                                          parentkey IN VARCHAR2,
                                          childkey  IN VARCHAR2,
					  int_ext_indicator IN VARCHAR2,
					  p_wfitemkey OUT NOCOPY VARCHAR2) IS
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
   CURSOR csr_ap_aprvl_neg_details IS
   SELECT PV.vendor_name,
          AI.invoice_num,
          AI.invoice_date,
          AI.description,
          AI.org_id,
          AI.invoice_id,
          AI.approval_iteration,
          AI.vendor_contact_id,
          NVL(AI.invoice_amount, 0)
   FROM   ap_invoices_all AI,
          po_vendors PV
   WHERE  AI.invoice_id = p_invoice_id
   AND    AI.vendor_id = PV.vendor_id;
   l_api_name      CONSTANT VARCHAR2(200) := 'create_lineapproval_neg_process';
   l_vendor_name po_vendors.vendor_name%TYPE;
   l_invoice_num ap_invoices_all.invoice_num%TYPE;
   l_invoice_date  ap_invoices_all.invoice_date%TYPE;
   l_invoice_description ap_invoices_all.description%TYPE;
   l_invoice_id ap_invoices_all.invoice_id%TYPE;
   l_org_id ap_invoices_all.org_id%TYPE;
   l_name                  wf_users.name%TYPE; --bug 8620671
   l_display_name          VARCHAR2(150);
   l_role                  VARCHAR2(50);
   l_role_display          VARCHAR2(150);
   l_new_child_ItemKey     VARCHAR2(30);
   l_person_id             NUMBER(15);
   l_hist_rec              AP_INV_APRVL_HIST%ROWTYPE;
   l_notf_receipient_type  VARCHAR2(50);
   l_iteration             NUMBER;
   l_notf_iteration        NUMBER;
   l_invoice_key   VARCHAR2(50);
   l_role_name          AP_APINV_APPROVERS.ROLE_NAME%TYPE;
   l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
   l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
   l_debug_info    VARCHAR2(2000);
   l_line_number   ap_invoice_lines_all.line_number%TYPE;
   l_line_amount   ap_invoice_lines_all.amount%TYPE;
   l_ext_person_id NUMBER(15);
   l_ext_user_id NUMBER(15);
   l_total                 ap_invoices_all.invoice_amount%TYPE;

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   SELECT AP_NEGOTIATION_HIST_S.nextval
   INTO   l_new_child_ItemKey
   FROM   dual;

   OPEN csr_ap_aprvl_neg_details;
   FETCH csr_ap_aprvl_neg_details INTO
         l_vendor_name,
	 l_invoice_num,
	 l_invoice_date,
	 l_invoice_description,
	 l_org_id,
	 l_invoice_id,
	 l_iteration,
	 l_ext_user_id,
         l_total;
   CLOSE csr_ap_aprvl_neg_details;

   l_ext_user_id := p_ext_user_id;

   wf_engine.createProcess('APINVNEG', l_new_child_itemkey,
                           'APPROVAL_NEGOTIATION');
   WF_ENGINE.setItemParent('APINVNEG', l_new_child_itemkey,
	                   'APINVAPR', parentkey, null);
   WF_ENGINE.SetItemAttrNumber('APINVNEG',
                        l_new_child_itemkey,
                        'INVOICE_ID',
                        l_invoice_id);
   WF_ENGINE.SetItemAttrNumber('APINVNEG',
                        l_new_child_itemkey,
                        'ORG_ID',
                        l_org_id);
   WF_ENGINE.SetItemAttrNumber('APINVNEG',
                        l_new_child_itemkey,
                        'INVOICE_TOTAL',
                        nvl(p_invoice_amount,l_total));
   WF_ENGINE.SetItemAttrNumber('APINVAPR',
                        parentkey,
                        'INVOICE_TOTAL',
                        nvl(p_invoice_amount,l_total));
   WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'INVOICE_SUPPLIER_NAME',
                        l_vendor_name);
   WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'INVOICE_NUMBER',
                        l_invoice_num);
   WF_ENGINE.SetItemAttrDate('APINVNEG',
                        l_new_child_itemkey,
                        'INVOICE_DATE',
                        l_invoice_date);
   WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'INVOICE_DESCRIPTION',
                        l_invoice_description);
   WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'PARENT_KEY',
                        parentkey);
   WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'NOTIFICATION_KEY',
                        l_new_child_itemkey);

   WF_ENGINE.SetItemAttrNumber('APINVNEG',
                        l_new_child_itemkey,
                        'ITERATION',
                        l_iteration);
   WF_ENGINE.SetItemAttrText('APINVNEG',
                                  l_new_child_itemkey,
                                  'ORIG_SYSTEM',
                                  WF_ENGINE.GETITEMATTRText('APINVAPR',
				                             parentkey,
						             'ORIG_SYSTEM'));
   /* Currently the sender is Internal  and sending to External*/
   IF int_ext_indicator = 'I' and l_ext_user_id IS NOT NULL THEN

      WF_DIRECTORY.GetRoleName('FND_USR',l_ext_user_id,l_role,
                               l_role_display);
      l_person_id := l_ext_user_id;
      WF_DIRECTORY.GetUserName('FND_USR',
                                l_ext_user_id,
                                l_name,
                                l_display_name);
      WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'SUPPLIER_ROLE',
                        l_role);
      WF_ENGINE.SetItemAttrText('APINVNEG',
                                  l_new_child_itemkey,
                                  'SUPPLIER_DISPLAY_NAME',
                                  l_display_name);
      WF_ENGINE.SetItemAttrNumber('APINVNEG',
                        l_new_child_itemkey,
                        'SUPPLIER_PERSON_ID',
                        l_ext_user_id);

      WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'NOTF_RECEIPIENT_TYPE',
                        'EXTERNAL');
      WF_ENGINE.SetItemAttrText('APINVNEG',
                                  l_new_child_itemkey,
                                  'INTERNAL_REP_DISPLAY_NAME',
                                  WF_ENGINE.GETITEMATTRText('APINVAPR',
                                                             parentkey,
                                                             'APPROVER_NAME'));
      WF_ENGINE.SetItemAttrText('APINVNEG',
                                  l_new_child_itemkey,
                                  'INTERNAL_REP_ROLE',
                                  WF_ENGINE.GETITEMATTRText('APINVAPR',
                                                             parentkey,
                                                             'DOCUMENT_APPROVER'));

   /* Currently the sender is external (supplier) and sending to
      Internal Rep */
   ELSIF int_ext_indicator = 'E' THEN

      l_role := WF_ENGINE.GETITEMATTRText('APINVAPR',
                                          parentkey,
			                  'DOCUMENT_APPROVER');
      WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'INTERNAL_REP_ROLE',
                        l_role);
      WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'DISP_NOT_RECEIVER',
                        l_role);
      l_display_name := WF_ENGINE.GETITEMATTRText('APINVAPR',
                                          parentkey,
			                  'APPROVER_NAME');
      WF_ENGINE.SetItemAttrText('APINVNEG',
                                  l_new_child_itemkey,
                                  'INTERNAL_REP_DISPLAY_NAME',
                                  l_display_name);
      l_person_id := WF_ENGINE.GETITEMATTRNumber('APINVAPR',
                                          parentkey,
			                  'APPROVER_ID');
      WF_ENGINE.SetItemAttrNumber('APINVNEG',
                        l_new_child_itemkey,
                        'INTERNAL_REP_PERSON_ID',
                        l_person_id);
      WF_ENGINE.SetItemAttrText('APINVNEG',
                        l_new_child_itemkey,
                        'NOTF_RECEIPIENT_TYPE',
                        'INTERNAL');
      WF_ENGINE.SetItemAttrText('APINVNEG',
                                  l_new_child_itemkey,
                                  'SUPPLIER_DISPLAY_NAME',
                                  WF_ENGINE.GETITEMATTRText('APINVNEG',
                                                             childkey,
                                                             'SUPPLIER_DISPLAY_NAME'));
      WF_ENGINE.SetItemAttrText('APINVNEG',
                                  l_new_child_itemkey,
                                  'SUPPLIER_ROLE',
                                  WF_ENGINE.GETITEMATTRText('APINVNEG',
                                                             childkey,
                                                             'SUPPLIER_ROLE'));

   END IF;
   WF_ENGINE.startProcess('APINVNEG', l_new_child_itemkey);
   MO_GLOBAL.INIT ('SQLAP');
   MO_GLOBAL.set_policy_context('S',l_org_id);

   IF childkey IS NOT NULL THEN
      l_notf_receipient_type :=  WF_ENGINE.GetItemAttrText('APINVNEG',
                                  childkey,
                                  'NOTF_RECEIPIENT_TYPE');
      IF l_notf_receipient_type = 'INTERNAL' THEN

          wf_engine.CompleteActivity(
                     itemType => 'APINVNEG',
                     itemKey  => childkey,
                     activity => 'APPROVAL_NEGOTIATION:WAITINTLINEAPRVL',
                     result   => 'NULL');
      ELSE
          wf_engine.CompleteActivity(
                     itemType => 'APINVNEG',
                     itemKey  => childkey,
                     activity => 'APPROVAL_NEGOTIATION:WAITEXTLINEAPRVL',
                     result   => 'NULL');
      END IF;

   END IF;

   p_wfitemkey := l_new_child_itemkey;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


EXCEPTION

WHEN OTHERS
   THEN
        RAISE;

END create_lineapp_neg_process;

PROCEDURE create_invapp_process(p_invoice_id IN NUMBER
                       ,p_approval_iteration IN NUMBER DEFAULT NULL
                       ,p_wfitemkey OUT NOCOPY VARCHAR2) IS
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
-- Bug5892455 added the union for 'Payment Request' type invoices
-- For payment Request type invoices the vendor is a customer whose
-- data wil be there in hz_party tables
CURSOR csr_ap_inv_details IS
SELECT PV.vendor_name,
       AI.invoice_num,
       AI.invoice_date,
       AI.description,
       AI.org_id,
       AI.invoice_id,
       NVL(AI.invoice_amount, 0)
FROM   ap_invoices_all AI,
       ap_suppliers PV
WHERE  AI.invoice_id = p_invoice_id
AND    AI.invoice_type_lookup_code <> 'PAYMENT REQUEST'
AND    AI.vendor_id = PV.vendor_id
UNION ALL
SELECT HZP.party_name,
       AI.invoice_num,
       AI.invoice_date,
       AI.description,
       AI.org_id,
       AI.invoice_id,
       NVL(AI.invoice_amount, 0)
FROM   ap_invoices_all AI,
       hz_parties HZP
WHERE  AI.invoice_id = p_invoice_id
AND    AI.invoice_type_lookup_code = 'PAYMENT REQUEST'
AND    AI.party_id = HZP.party_id;

l_vendor_name po_vendors.vendor_name%TYPE;
l_invoice_num ap_invoices_all.invoice_num%TYPE;
l_invoice_date  ap_invoices_all.invoice_date%TYPE;
l_invoice_description ap_invoices_all.description%TYPE;
l_invoice_id ap_invoices_all.invoice_id%TYPE;
l_org_id ap_invoices_all.org_id%TYPE;
l_itemkey VARCHAR2(50);
l_iteration AP_INVOICES_ALL.APPROVAL_ITERATION%TYPE;
l_api_name      CONSTANT VARCHAR2(200) := 'create_invapp_process';
l_debug_info    VARCHAR2(2000);
l_total                 ap_invoices_all.invoice_amount%TYPE;
l_calling_sequence      VARCHAR2(2000);
l_num NUMBER;



BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   l_debug_info := 'Before UPDATE AP_INVOICES_ALL';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   l_calling_sequence := l_api_name;
   UPDATE AP_INVOICES_ALL
   SET    WFAPPROVAL_STATUS = 'INITIATED'
   WHERE  invoice_id = p_invoice_id;
   /*
   UPDATE AP_INVOICE_LINES_ALL
   SET    WFAPPROVAL_STATUS = 'INITIATED'
   where  invoice_id = p_invoice_id;
   */

   l_debug_info := 'Before ame_api2.clearAllApprovals';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   ame_api2.clearAllApprovals(
                              applicationidin => 200,
                              transactiontypein => 'APINV',
                              transactionidin => p_invoice_id);
   OPEN csr_ap_inv_details;
   FETCH csr_ap_inv_details INTO
         l_vendor_name,
         l_invoice_num,
         l_invoice_date,
         l_invoice_description,
         l_org_id,
         l_invoice_id,
         l_total;
   CLOSE csr_ap_inv_details;
   l_iteration := nvl(p_approval_iteration,1);
   l_itemkey := to_char(p_invoice_id) || '_' || to_char(l_iteration);

   l_debug_info := 'Before Calling WF_ENGINE.createProcess(APINVAPR,'
                   || l_itemkey || ',APPROVAL_MAIN);';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   wf_engine.createProcess('APINVAPR', l_itemkey, 'APPROVAL_MAIN');
   l_debug_info := 'Before setting item attributes' ;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   WF_ENGINE.SetItemAttrNumber('APINVAPR',
                        l_itemkey,
                        'INVOICE_ID',
                        l_invoice_id);
   WF_ENGINE.SetItemAttrNumber('APINVAPR',
                        l_itemkey,
                        'ORG_ID',
                        l_org_id);
   WF_ENGINE.SetItemAttrNumber('APINVAPR',
                        l_itemkey,
                        'INVOICE_TOTAL',
                        l_total);
   WF_ENGINE.SetItemAttrText('APINVAPR',
                        l_itemkey,
                        'INVOICE_SUPPLIER_NAME',
                        l_vendor_name);
   WF_ENGINE.SetItemAttrText('APINVAPR',
                        l_itemkey,
                        'INVOICE_NUMBER',
                        l_invoice_num);
   WF_ENGINE.SetItemAttrDate('APINVAPR',
                        l_itemkey,
                        'INVOICE_DATE',
                        l_invoice_date);
   WF_ENGINE.SetItemAttrText('APINVAPR',
                        l_itemkey,
                        'INVOICE_DESCRIPTION',
                        l_invoice_description);
   WF_ENGINE.SetItemAttrNumber('APINVAPR',
                        l_itemkey,
                        'ITERATION',
                        l_iteration);
   WF_ENGINE.SetItemAttrText('APINVAPR',
                        l_itemkey,
                        'NOTIFICATION_KEY',
                        l_itemkey);
   /* Set wfapproval status at the line level so that AME doesnt return
      any Line levcel approvers for the matched case even if the rules
      have been so set up. */
   l_debug_info := 'Before UPDATE AP_INVOICE_LINES_ALL';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   SELECT COUNT(*)
     INTO l_num
     FROM ap_invoice_lines_all
    WHERE po_header_id IS NOT NULL
      AND invoice_id = l_invoice_id;

   IF l_num > 0 THEN
      WF_ENGINE.SetItemAttrText('APINVAPR',
                                  l_itemkey,
                                  'INV_MATCH_TYPE',
                                  'MATCHED');
      UPDATE AP_INVOICE_LINES_ALL
      SET    WFAPPROVAL_STATUS = 'INITIATED'
      where  invoice_id = p_invoice_id;
   ELSE
      WF_ENGINE.SetItemAttrText('APINVAPR',
                                  l_itemkey,
                                  'INV_MATCH_TYPE',
                                  'UNMATCHED');
      UPDATE AP_INVOICE_LINES_ALL
      SET    WFAPPROVAL_STATUS = 'NOT REQUIRED'
      where  invoice_id = p_invoice_id;
   END IF;

   l_debug_info := 'Before Calling WF_ENGINE.startProcess(APINVAPR,'
                   || l_itemkey || ');';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   WF_ENGINE.startProcess('APINVAPR', l_itemkey);
   l_debug_info := 'After Calling WF_ENGINE.startProcess' ;
   p_wfitemkey := l_itemkey;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


EXCEPTION

WHEN OTHERS
   THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END create_invapp_process;

FUNCTION Stop_Approval(
                        p_invoice_id IN NUMBER,
			p_line_number IN NUMBER,
			p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS

	--Define cursor for wf and ame records that need to be stopped
	CURSOR   Item_Cur IS
	SELECT Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
	FROM AP_APINV_APPROVERS
	WHERE Invoice_ID = p_invoice_id
	AND NOTIFICATION_STATUS = 'SENT'
	GROUP BY Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
	ORDER BY Notification_Key;

	CURSOR   Line_Item_Cur IS
        SELECT Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
        FROM AP_APINV_APPROVERS
        WHERE Invoice_ID = p_invoice_id
	AND Line_Number = p_line_number
        AND NOTIFICATION_STATUS = 'SENT'
        GROUP BY Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
        ORDER BY Notification_Key;

	l_api_name      CONSTANT VARCHAR2(200) := 'Stop_Approval';
        l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
        l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
	l_invoice_id	NUMBER;
	l_invoice_key   AP_APINV_APPROVERS.INVOICE_KEY%TYPE;
        l_not_key       AP_APINV_APPROVERS.NOTIFICATION_KEY%TYPE;
	l_old_not_key   AP_APINV_APPROVERS.NOTIFICATION_KEY%TYPE;
	l_name	        AP_APINV_APPROVERS.ROLE_NAME%TYPE;
        l_debug_info    VARCHAR2(2000);
        l_wf_exist      BOOLEAN;
        l_approval_iteration AP_INVOICES.approval_iteration%type;
        l_end_date      DATE;
        l_calling_sequence      VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := l_api_name || ' <-' || p_calling_sequence;

        /*Bug4926114  Added the following part to check of code
                      to check whether workflow is active or not */
        select approval_iteration
        into   l_approval_iteration
        from   ap_invoices
        where  invoice_id=p_invoice_id;

        l_invoice_key := p_invoice_id||'_'||l_approval_iteration;

        BEGIN
          SELECT  end_date
          INTO    l_end_date
          FROM    wf_items
          WHERE   item_type = 'APINVAPR'
          AND     item_key  = l_invoice_key;

          l_wf_exist  := TRUE;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_wf_exist  := FALSE;
       END;

       If not (l_wf_exist) OR l_end_date is NOT NULL then
              return TRUE;
       end if;

	IF p_line_number IS NULL THEN
	   --End WF processes
	   WF_Engine.abortProcess(
		itemType => 'APINVAPR',
		itemKey  => l_invoice_key,
		process => 'APPROVAL_MAIN');

	   l_debug_info := 'opening item cursor';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
           END IF;

           OPEN Item_Cur;
           LOOP

                FETCH Item_Cur INTO l_item_class, l_item_id, l_name,
					l_invoice_key, l_not_key;
                EXIT WHEN Item_Cur%NOTFOUND;

		-- Bug 7710828. Now passing p_invoice_id instead of l_invoice_id.
		AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(p_invoice_id),
                                approvalStatusIn    => AME_UTIL.nullStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
                                itemClassIn     => l_item_class,
                                itemIdIn        => l_item_id);

		IF l_not_key <> nvl(l_old_not_key, 'dummy') THEN

			WF_Engine.abortProcess(
			itemType => 'APINVAPR',
			itemKey  => l_not_key,
			process => 'APPROVAL_INVOICE_LINES');

			l_old_not_key := l_not_key;
		END IF;

           END LOOP;
           CLOSE Item_Cur;

	ELSE --just a line

           l_debug_info := 'opening line item cursor';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
           END IF;

           OPEN Line_Item_Cur;
           LOOP

                FETCH Line_Item_Cur INTO l_item_class, l_item_id, l_name,
                                        l_invoice_key, l_not_key;
                EXIT WHEN Line_Item_Cur%NOTFOUND;

                -- Bug 7710828. Now passing p_invoice_id instead of l_invoice_id.
                AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(p_invoice_id),
                                approvalStatusIn    => AME_UTIL.nullStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
                                itemClassIn     => l_item_class,
                                itemIdIn        => l_item_id);

                IF l_not_key <> nvl(l_old_not_key, 'dummy') THEN

                        WF_Engine.abortProcess(
                        itemType => 'APINVAPR',
                        itemKey  => l_not_key,
                        process => 'APPROVAL_INVOICE_LINES');

                        l_old_not_key := l_not_key;
                END IF;

           END LOOP;
           CLOSE Line_Item_Cur;
	END IF; --just a line

	return true;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Stop_Approval;
PROCEDURE process_single_line_response(p_invoice_id IN NUMBER,
                                       p_line_number IN NUMBER,
                                       p_response IN VARCHAR2,
                                       p_itemkey  IN VARCHAR2,
                                       p_comments IN VARCHAR2) IS
   --Define cursor for lines affected by notification
   --Note that Invoice_Key s/b the same for all records in the cursor
   --but I want to avoid another select on the table
   CURSOR   Items_Cur IS
   SELECT invap.Item_Class, invap.Item_Id, invap.Role_Name,
          invap.Invoice_Key, al.line_number, al.amount
   FROM   AP_APINV_APPROVERS invap, AP_INVOICE_LINES_ALL al
   WHERE  invap.child_process_item_key = p_itemkey
   AND    invap.line_number = p_line_number
   AND    invap.invoice_id = p_invoice_id
   AND    al.line_number = invap.line_number
   AND    al.invoice_id  = invap.invoice_id;

   l_api_name      CONSTANT VARCHAR2(200) := 'process_single_line_response';
   l_debug_info    VARCHAR2(2000);
   l_parentkey     VARCHAR2(150);
   l_invoice_id    NUMBER;
   l_level         VARCHAR2(20);
   l_result        VARCHAR2(20);
   l_invoice_key   VARCHAR2(50);
   l_name          AP_APINV_APPROVERS.ROLE_NAME%TYPE;
   l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
   l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
   l_user_id       NUMBER(15);
   l_login_id      NUMBER(15);
   l_hist_rec      AP_INV_APRVL_HIST%ROWTYPE;
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_esc_flag      VARCHAR2(1);
   l_esc_approver_name VARCHAR2(150);
   l_role_name     VARCHAR2(150);
   l_role VARCHAR2(150);
   l_esc_role_name VARCHAR2(150);
   l_esc_approver_id   NUMBER;
   l_line_total     NUMBER;
   l_iteration     NUMBER(15);
   l_comments      VARCHAR2(240);
   l_org_id        NUMBER(15);
   l_line_number   ap_invoice_lines_all.line_number%TYPE;
   l_line_amount   ap_invoice_lines_all.amount%TYPE;
   l_notf_iteration        NUMBER;
   l_response      ap_inv_aprvl_hist_all.response%TYPE;
   l_sent           NUMBER;
BEGIN
   l_debug_info := 'Start';
   l_sent := 0;
   IF p_response = 'APPROVE'
   THEN l_response := 'APPROVED';
   ELSIF p_response = 'REJECT'
   THEN l_response := 'REJECTED';
   ELSE l_response := p_response;
   END IF;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_invoice_id := WF_ENGINE.GetItemAttrNumber('APINVAPR',
                                  p_itemkey,
                                  'INVOICE_ID');

   l_iteration := WF_ENGINE.GetItemAttrNumber('APINVAPR',
                             p_itemkey,
                             'ITERATION');

   l_notf_iteration := WF_ENGINE.GETITEMATTRNumber('APINVAPR',
                        p_itemkey,
                        'NOTF_ITERATION');

   l_comments := WF_ENGINE.GetItemAttrText('APINVAPR',
                             p_itemkey,
                             'WF_NOTE');

   l_org_id := WF_ENGINE.GETITEMATTRNumber('APINVAPR',
                   p_itemkey,
                   'ORG_ID');

   l_approver_name := WF_ENGINE.GetItemAttrText('APINVAPR',
                             p_itemkey,
                             'APPROVER_NAME');

   l_esc_role_name := WF_ENGINE.GetItemAttrText('APINVAPR',
                             p_itemkey,
                             'ESC_ROLE_NAME');

   l_role_name := WF_ENGINE.GetItemAttrText('APINVAPR',
                             p_itemkey,
                             'ROLE_NAME');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber('APINVAPR',
                   p_itemkey,
                   'APPROVER_ID');

   l_esc_flag  := WF_ENGINE.GetItemAttrText('APINVAPR',
                             p_itemkey,
                             'ESCALATED');
   l_esc_approver_name := WF_ENGINE.GetItemAttrText('APINVAPR',
                             p_itemkey,
                             'ESC_APPROVER_NAME');

   l_esc_approver_id := WF_ENGINE.GETITEMATTRNumber('APINVAPR',
                   p_itemkey,
                   'ESC_APPROVER_ID');

   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_role := l_role_name;
   ELSE
      l_role := l_esc_role_name;
   END IF;

   l_debug_info := 'Before Update Approvers table';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   --Update Approvers table
   IF l_response in ('APPROVED','REJECTED','ACCEPT') THEN
      UPDATE AP_APINV_APPROVERS
      SET Notification_status = 'COMP'
      WHERE CHILD_PROCESS_ITEM_KEY = p_itemkey
      AND   INVOICE_ID = p_invoice_id
      AND   LINE_NUMBER = p_line_number;
   END IF;

   fnd_client_info.set_org_context(l_org_id);

   l_hist_rec.HISTORY_TYPE := 'LINESAPPROVAL';
   l_hist_rec.INVOICE_ID   := l_invoice_id;
   l_hist_rec.ITERATION    := l_iteration;
   l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
   l_hist_rec.APPROVER_COMMENTS := l_comments;
   l_hist_rec.RESPONSE     := l_response;
   IF nvl(l_esc_flag,'N') = 'N' THEN
      l_hist_rec.APPROVER_ID  := l_approver_id;
      l_hist_rec.APPROVER_NAME:= l_approver_name;
   ELSE
      l_hist_rec.APPROVER_ID  := l_esc_approver_id;
      l_hist_rec.APPROVER_NAME:= l_esc_approver_name;
   END IF;
   l_hist_rec.CREATED_BY   := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.CREATION_DATE:= sysdate;
   l_hist_rec.LAST_UPDATE_DATE := sysdate;
   l_hist_rec.LAST_UPDATED_BY  := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   l_hist_rec.LAST_UPDATE_LOGIN := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
   l_hist_rec.ORG_ID            := l_org_id;
   --update AME status
   --For Future  check with ame as to when updateApprovalStatuses will be
   --available so there  will not be a need to loop.
   OPEN Items_Cur;

   FETCH Items_Cur INTO l_item_class, l_item_id, l_name,
                                l_invoice_key,l_line_number, l_line_amount;
   --update AME with response
   IF l_response IN ('APPROVED','ACCEPT') THEN
      AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.approvedStatus,
                           approverNameIn  => l_name,
                           transactionTypeIn =>  'APINV',
                           itemClassIn     => l_item_class,
                           itemIdIn        => l_item_id);
   ELSIF l_response = 'REJECTED' THEN
      AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.rejectStatus,
                           approverNameIn  => l_name,
                           transactionTypeIn =>  'APINV',
                           itemClassIn     => l_item_class,
                           itemIdIn        => l_item_id);
   END IF;
   l_hist_rec.line_number   := l_line_number;
   l_hist_rec.AMOUNT_APPROVED   := l_line_amount;

   l_debug_info := 'Before calling insert_history_table for Line'
                    || l_line_number;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   insert_history_table(p_hist_rec => l_hist_rec);
   CLOSE Items_Cur;


   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
   l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);

   IF l_response = 'REJECTED' THEN
      UPDATE AP_INVOICE_LINES_ALL
      SET    wfapproval_status = 'REJECTED'
             ,Last_Update_Date = sysdate
             ,Last_Updated_By = l_user_id
             ,Last_Update_Login = l_login_id
      WHERE invoice_id = p_invoice_id
      AND wfapproval_status <> 'MANUALLY APPROVED'
      AND line_number = p_line_number;
   END IF;

   BEGIN

      SELECT invoice_key
      INTO   l_invoice_key
      FROM   AP_APINV_APPROVERS
      WHERE  invoice_id = p_invoice_id
      AND    line_number = p_line_number
      AND    child_process_item_key = p_itemkey
      AND    rownum = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_debug_info := 'No Data Found in SELECT from AP_APINV_APPROVERS' ;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;
      RAISE;

   END;

   /* The following is being called from OA layer after
   Initial Commit. so commenting it out here.

   SELECT count(*)
   INTO  l_sent
   FROM  AP_APINV_APPROVERS
   WHERE Notification_status = 'SENT'
   AND   child_process_item_key = p_itemkey
   AND   INVOICE_ID = p_invoice_id
   AND   LINE_NUMBER = p_line_number;
   IF l_sent = 0 THEN
      BEGIN
         wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => p_itemkey,
                        activity => 'APPROVAL_INVOICE_LINES:WAITLINEAPRVL',
                        result   => 'NULL');

      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
   END IF;
   */
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
END process_single_line_response;

/*get_attribute_value is called by AME when determining the value for more
complicated attributes.  It can be called at the header or line level, and
the p_attribute_name is used to determine what the return value should be.
p_context is currently a miscellaneous parameter to be used as necessary in
the future.  The goal with this function is to avoid adding a new function
for each new AME attribute.*/

FUNCTION Get_Attribute_Value(p_invoice_id IN NUMBER,
                   p_sub_class_id IN NUMBER DEFAULT NULL,
                   p_attribute_name IN VARCHAR2,
                   p_context IN VARCHAR2 DEFAULT NULL)
                                 RETURN VARCHAR2 IS

        l_debug_info    VARCHAR2(2000);
        l_return_val    VARCHAR2(2000);
        l_count_pa_rel  NUMBER;
        l_sum_matched   NUMBER;
        l_sum_calc      NUMBER;
        l_line_count    NUMBER;
        l_item_count    NUMBER;
        l_api_name      CONSTANT VARCHAR2(200) := 'Get_Attribute_Value';

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        IF p_context = 'header' THEN
                --dealing with a header level attribute
                IF p_attribute_name =
                        'SUPPLIER_INVOICE_EXPENDITURE_ORGANIZATION_NAME' THEN

                  SELECT organization
                    INTO l_return_val
                    FROM PA_EXP_ORGS_IT
                   WHERE organization_id=(SELECT expenditure_organization_id
                                       FROM ap_invoices_all
                                       WHERE invoice_id = p_invoice_id);

                ELSIF p_attribute_name= 'SUPPLIER_INVOICE_PROJECT_RELATED' THEN

                        SELECT count(invoice_distribution_id)
                        INTO l_count_pa_rel
                        FROM ap_invoice_distributions_all
                        WHERE invoice_id = p_invoice_id
                        AND project_id is not null;

                        IF l_count_pa_rel >0 THEN
                                l_return_val := 'Y';
                        ELSE
                                l_return_val := 'N';
                        END IF;

                ELSIF p_attribute_name= 'SUPPLIER_INVOICE_MATCHED' THEN
                        --an invoice is considered matched if all item
                        --lines are matched

                        SELECT sum(decode(po_header_id, null, 0, 1)),
                                        count(line_number)
                        INTO l_sum_matched, l_item_count
                        FROM ap_invoice_lines_all
                        WHERE invoice_id = p_invoice_id
                        AND line_type_lookup_code = 'ITEM';

                        IF l_sum_matched >0
                                and l_sum_matched = l_item_count THEN
                                l_return_val := 'Y';
                        ELSE
                                l_return_val := 'N';
                        END IF;
                ELSIF  p_attribute_name= 'SUPPLIER_INVOICE_TAX_CALCULATED' THEN

                        SELECT sum(decode(tax_already_calculated_flag, 'Y',
                                        1, 0)), count(line_number)
                        INTO l_sum_calc, l_line_count
                        FROM ap_invoice_lines_all
                        WHERE invoice_id = p_invoice_id
                        AND line_type_lookup_code not in ('TAX','AWT');

                        IF l_sum_calc >0 and l_sum_matched = l_line_count THEN
                                l_return_val := 'Y';
                        ELSE
                                l_return_val := 'N';
                        END IF;

                END IF;

        ELSIF p_context = 'distribution' THEN
                IF p_attribute_name =
                        'SUPPLIER_INVOICE_DISTRIBUTION_PO_BUYER_EMP_NUM' THEN

                   SELECT employee_number
                     INTO l_return_val
                     FROM per_all_people_f pap
                    WHERE person_id = (SELECT ph.agent_id
                           FROM ap_invoice_distributions_all aid,
                                po_distributions_all pd,
                                po_headers_all ph
                           WHERE pd.po_distribution_id =
                                aid.po_distribution_id
                           AND  pd.po_header_id = ph.po_header_id
                           AND aid.invoice_distribution_id =
                                                p_sub_class_id
                           AND pd.creation_date >= pap.effective_start_date
                           AND pd.creation_date <=
                                      nvl(pap.effective_end_date,sysdate));

                ELSIF p_attribute_name =
                  'SUPPLIER_INVOICE_DISTRIBUTION_PO_REQUESTER_EMP_NUM' THEN

                  SELECT employee_number
                    INTO l_return_val
                    FROM per_all_people_f pap
                   WHERE person_id = (
                        SELECT pd.deliver_to_person_id
                          FROM ap_invoice_distributions_all aid,
                               po_distributions_all pd
                         WHERE pd.po_distribution_id =
                               aid.po_distribution_id
                           AND aid.invoice_distribution_id =
                                      p_sub_class_id
                           AND pd.creation_date >= pap.effective_start_date
                           AND pd.creation_date <=
                                      nvl(pap.effective_end_date,sysdate));
                END IF;
        ELSIF p_context = 'line item' THEN

                IF p_attribute_name = 'SUPPLIER_INVOICE_LINE_MATCHED' THEN
                        SELECT decode(po_header_id, null, 'N', 'Y')
                        INTO l_return_val
                        FROM ap_invoice_lines_all
                        WHERE invoice_id = p_invoice_id
                        AND line_number = p_sub_class_id;

                END IF;
        END IF;

        return l_return_val;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('APINVLDP', 'get_attribute_value',
                    p_invoice_id , p_sub_class_id, p_attribute_name,
                                l_debug_info);
    raise;

END Get_Attribute_Value;

/* This function is called from AME in order to provide the relevant segment
of the account fexfield to the calling AME attribute usage*/
FUNCTION AP_Dist_Accounting_Flex(p_seg_name IN VARCHAR2,
                                 p_dist_id IN NUMBER) RETURN VARCHAR2 IS

        l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
        l_result                        BOOLEAN;
        l_chart_of_accounts_id          NUMBER;
        l_num_segments                  NUMBER;
        l_segment_num                   NUMBER;
        l_reason_flex                   VARCHAR2(2000):='';
        l_segment_delimiter             VARCHAR2(1);
        l_seg_val                       VARCHAR2(50);
        l_ccid                          NUMBER;
        l_sob                           NUMBER;
        l_debug_info                    VARCHAR2(2000);
        l_api_name      CONSTANT VARCHAR2(200) := 'AP_Dist_Accounting_Flex';

BEGIN
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        SELECT dist_code_combination_id,set_of_books_id
        INTO l_ccid,l_sob
        FROM ap_invoice_distributions_all
        WHERE invoice_distribution_id=p_dist_id;

        SELECT chart_of_accounts_id
        INTO l_chart_of_accounts_id
        FROM gl_sets_of_books
       WHERE set_of_books_id = l_sob;

        l_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                                'SQLGL',
                                                'GL#',
                                                l_chart_of_accounts_id);
        IF (NOT l_result) THEN
            l_reason_flex := FND_MESSAGE.GET;
        END IF;

        l_result := FND_FLEX_EXT.GET_SEGMENTS(
                                      'SQLGL',
                                      'GL#',
                                      l_chart_of_accounts_id,
                                      l_ccid,
                                      l_num_segments,
                                      l_segments);

        IF (NOT l_result) THEN
            l_reason_flex := FND_MESSAGE.GET;
        END IF;

        l_result := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                    101,
                                    'GL#',
                                    l_chart_of_accounts_id,
                                    p_seg_name,
                                    l_segment_num);
        IF (NOT l_result) THEN
            l_reason_flex := FND_MESSAGE.GET;
        END IF;

        l_seg_val := l_segments(l_segment_num);

        return l_seg_val;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('APINVLDP', 'p_dist_accounting_flex',
             p_seg_name , p_dist_id, l_debug_info);
    raise;
END AP_Dist_Accounting_Flex;

PROCEDURE continue_hold_workflow(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_num number;
   l_hold_release_code     ap_holds_all.release_lookup_code%TYPE;
   l_debug_info            VARCHAR2(2000);
   l_api_name              CONSTANT VARCHAR2(200) := 'continue_hold_workflow';
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');
   l_debug_info := 'Before select';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   select aha.release_lookup_code
   into   l_hold_release_code
   from   ap_holds_all aha,
          ap_hold_codes ahc
   where  aha.invoice_id = l_invoice_id
   and    aha.org_id = l_org_id
   and    aha.hold_lookup_code = ahc.hold_lookup_code
   and    aha.hold_id = l_hold_id;
   IF l_hold_release_code IS NULL  THEN
      resultout := wf_engine.eng_completed||':'||'Y';
   ELSE
      resultout := wf_engine.eng_completed||':'||'N';
   END IF;
   l_debug_info := 'After select, reultout : ' || resultout;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','continue_hold_workflow',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END continue_hold_workflow;

PROCEDURE exists_initial_wait(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_num number;
   l_wait_time             NUMBER;
   l_debug_info            VARCHAR2(2000);
   l_api_name              CONSTANT VARCHAR2(200) := 'exists_initial_wait';
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');
   l_debug_info := 'Before select';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   select nvl(ahc.wait_before_notify_days,0)*24*60
   into   l_wait_time
   from   ap_holds_all aha,
          ap_hold_codes ahc
   where  aha.invoice_id = l_invoice_id
   and    aha.org_id = l_org_id
   and    aha.hold_lookup_code = ahc.hold_lookup_code
   and    aha.hold_id = l_hold_id;
   IF l_wait_time  > 0 THEN
      WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'INITIAL_WAIT_TIME',
                        l_wait_time);

      resultout := wf_engine.eng_completed||':'||'Y';
   ELSE
      resultout := wf_engine.eng_completed||':'||'N';
   END IF;
   l_debug_info := 'After select, reultout : ' || resultout;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','exists_initial_wait',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END exists_initial_wait;

PROCEDURE is_hold_released(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

   l_org_id NUMBER;
   l_invoice_id NUMBER;
   l_hold_id NUMBER;
   l_num number;
   l_hold_release_code     ap_holds_all.release_lookup_code%TYPE;
   l_wait_time             NUMBER;
   l_debug_info            VARCHAR2(2000);
   l_api_name              CONSTANT VARCHAR2(200) := 'is_hold_released';
BEGIN
   l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

   l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

   l_hold_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'HOLD_ID');
   l_debug_info := 'Before select';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   select aha.release_lookup_code,
          nvl(ahc.reminder_days,0)*24*60	--Bug8839774
   into   l_hold_release_code,
          l_wait_time
   from   ap_holds_all aha,
          ap_hold_codes ahc
   where  aha.invoice_id = l_invoice_id
   and    aha.org_id = l_org_id
   and    aha.hold_lookup_code = ahc.hold_lookup_code
   and    aha.hold_id = l_hold_id;
   IF l_hold_release_code IS NOT NULL
   OR l_wait_time = 0 THEN
      resultout := wf_engine.eng_completed||':'||'Y';
   ELSE
      WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'REMINDER_WAIT_TIME',
                        l_wait_time);
      resultout := wf_engine.eng_completed||':'||'N';
   END IF;
   l_debug_info := 'After select, reultout : ' || resultout;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVHDN','is_hold_released',itemtype, itemkey,
                        to_char(actid), funcmode);
        RAISE;
END is_hold_released;

PROCEDURE abort_holds_workflow(p_hold_id IN NUMBER) IS
   l_api_name      CONSTANT VARCHAR2(200) := 'abort_holds_workflow';
   l_debug_info    VARCHAR2(2000);
   l_status        VARCHAR2(15) ; -- Bug 8266290
   l_result        VARCHAR2(40) ; -- Bug 8266290
   l_success       BOOLEAN      ; -- Bug 9402921
BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   BEGIN
      -- Bug 8266290 : Added the below WF_Engine call and if condition
      WF_Engine.ItemStatus ( itemType => 'APINVHDN',
	  		     itemKey  => to_char(p_hold_id),
            		     status   => l_status,
                             result   => l_result ) ;
      -- Bug 9402921 : Added l_success logic
      l_success := TRUE ;

      l_debug_info := 'WF_Engine call successful';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
        l_success := FALSE ;
        l_debug_info := 'WF_Engine call failed' ;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                               l_api_name,l_debug_info);
        END IF;
   END ;

   If ( NVL( l_status, 'N' ) <> 'COMPLETE' ) THEN --  Bug 9402921  : Added NVL
	   UPDATE ap_holds_all
	   SET    wf_status = 'MANUALLYRELEASED'
	   WHERE  hold_id = p_hold_id;

       IF l_success THEN -- Bug 9402921 : Added if-end if
	   -- Bug 7693776 begin
	   WF_Engine.abortProcess( itemType => 'APINVHDN',
      				   itemKey  => to_char(p_hold_id) );

	   AME_API2.clearAllApprovals( applicationIdIn   => 200,
        	                       transactionIdIn   => to_char(p_hold_id),
                	               transactionTypeIn => 'APHLD' );
	   -- Bug 7693776 end
       END IF ;
   End If;

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
END;

FUNCTION IS_INV_NEGOTIATED(
                 p_invoice_id IN ap_invoice_lines_all.invoice_id%TYPE
		,p_org_id IN ap_invoice_lines_all.org_id%TYPE)
		RETURN BOOLEAN IS
   l_num_lines_under_neg NUMBER;
   l_num_holds_under_neg NUMBER;
   l_debug_info       VARCHAR2(2000);
   l_api_name         CONSTANT VARCHAR2(200) := 'IS_INV_NEGOTIATED';

BEGIN
   l_num_holds_under_neg := 0;
   l_num_lines_under_neg := 0;

   l_debug_info := 'Before select for l_num_holds_under_neg';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   SELECT count(*)
   INTO   l_num_holds_under_neg
   FROM   ap_holds_all aha
   WHERE  aha.invoice_id = p_invoice_id
   AND    aha.org_id = p_org_id
   AND    aha.wf_status = 'NEGOTIATE';

   l_debug_info := 'After select for l_num_holds_under_neg, l_num_holds_under_neg = ' || l_num_holds_under_neg;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   IF l_num_holds_under_neg > 0 THEN
      RETURN(TRUE);
   END IF;

   l_debug_info := 'Before select for l_num_lines_under_neg';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   SELECT COUNT(*)
   INTO   l_num_lines_under_neg
   FROM   ap_invoice_lines_all ail, ap_apinv_approvers aaa
   WHERE  ail.invoice_id = p_invoice_id
   AND    ail.org_id = p_org_id
   AND    aaa.invoice_id = ail.invoice_id
   AND    aaa.line_number = ail.line_number
   AND    aaa.approval_status = 'NEGOTIATE';

   l_debug_info := 'After select for l_num_lines_under_neg, l_num_lines_under_neg = ' || l_num_lines_under_neg;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   IF l_num_lines_under_neg > 0 THEN
      RETURN(TRUE);
   END IF;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END IS_INV_NEGOTIATED;

/* Bug 5590138. Bring to from old apiawleb.pls */

/*This procedure gets a table of approvers and their associated items, for
the application history forms.*/

PROCEDURE Get_All_Approvers(p_invoice_id IN NUMBER,
                        p_calling_sequence IN VARCHAR2) IS

        l_invoice_id            NUMBER;
        l_complete              VARCHAR2(1);
        l_next_approvers        ame_util.approversTable2;
        l_next_approver         ame_util.approverRecord2;
        l_index                 ame_util.idList;
        l_ids                   ame_util.stringList;
        l_class                 ame_util.stringList;
        l_source                ame_util.longStringList;
        l_line_num              NUMBER;
        l_api_name              CONSTANT VARCHAR2(200) := 'Get_All_Approvers';
        l_iteration             NUMBER;
        l_debug_info            VARCHAR2(2000);
        l_org_id                NUMBER;
        l_calling_sequence      VARCHAR2(2000);
        l_wfapproval_status     varchar2(30);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := 'AP_WORLFLOW_PKG.'||l_api_name || ' <-' || p_calling_sequence;

        l_debug_info := 'set variables from workflow';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
        END IF;

        l_invoice_id := p_invoice_id;
        BEGIN
          SELECT NVL(wfapproval_status, 'NOT REQUIRED')
          INTO l_wfapproval_status
          FROM   ap_invoices_all
          WHERE  invoice_id = l_invoice_id;
        END;


        -- Bug 5590138. Add the PLSQL Block

        IF l_wfapproval_status IN ('REQUIRED', 'INITIATED',
                                   'STOPPED',  'NEEDS WFREAPPROVAL') THEN
          BEGIN
           --get all of the approvers
            AME_API2.getAllApprovers1(applicationIdIn => 200,
                        transactionTypeIn => 'APINV',
                        transactionIdIn => to_char(l_invoice_id),
                        approvalProcessCompleteYNOut => l_complete,
                        approversOut => l_next_approvers,
                        itemIndexesOut => l_index,
                        itemIdsOut => l_ids,
                        itemClassesOut => l_class,
                        itemSourcesOut => l_source
                        );
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
              APP_EXCEPTION.RAISE_EXCEPTION;
          END;

        END IF;


        --More values in the approver list
        l_debug_info := 'after call to ame';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;
        IF l_complete = ame_util.booleanFalse THEN
           --Loop through approvers' table returned by AME
           l_debug_info := 'more approvers';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
           END IF;

           FOR l_table IN
                nvl(l_next_approvers.First,0)..nvl(l_next_Approvers.Last,-1)
                                                                         LOOP
                l_debug_info := 'looping through approvers';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
                END IF;
                --set the record variable
                l_next_approver := l_next_approvers(l_table);

                --if the approver record does not have a value for item_id,
                --we need to
                --use the item lists returned by AME to determine
                --the items associated
                --with this approver.
                IF l_next_approver.item_id IS NULL THEN
                   l_debug_info := 'item_id is null';
                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
                   END IF;

                   FOR l_rec IN 1..l_index.count LOOP
                        --l_index contains the mapping between
                        --approvers and items
                        l_debug_info := 'looping through l_rec';
                        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                                l_api_name,l_debug_info);
                        END IF;
                        IF l_index(l_rec) = l_table THEN
                           l_debug_info := 'check type of item class';
                           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                                l_api_name,l_debug_info);
                           END IF;
                           --Depending on the type of item class, we need to set
                           --some variables
                           --amy need correction once project/dist seeded
                           IF l_class(l_rec) =
                                ame_util.lineItemItemClassName THEN
                                l_line_num := l_ids(l_rec);
                           ELSIF l_class(l_rec) = 'project code' THEN

                                SELECT Invoice_Line_Number
                                INTO l_line_num
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL
                                WHERE project_id =l_ids(l_rec);
                           ELSIF l_class(l_rec) =
                                ame_util.costCenterItemClassName THEN

                                SELECT Invoice_Line_Number
                                INTO l_line_num
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL
                                WHERE project_id =l_ids(l_rec);
                           --distributions
                           ELSIF l_class(l_rec) <>
                                        ame_util.lineItemItemClassName
                                AND l_class(l_rec) <>
                                        ame_util.headerItemClassName THEN

                                SELECT Invoice_Line_Number
                                INTO l_line_num
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL
                                WHERE invoice_distribution_id = l_ids(l_rec);

                           END IF; --l_class

                           --Insert record into ap_approvers_list_gt
                           INSERT INTO AP_APPROVERS_LIST_GT(
                                TRANSACTION_ID,  -- Bug 5624200
                                LINE_NUMBER,
                                ROLE_NAME,
                                ORIG_SYSTEM,
                                ORIG_SYSTEM_ID,
                                DISPLAY_NAME,
                                APPROVER_CATEGORY,
                                API_INSERTION,
                                AUTHORITY,
                                APPROVAL_STATUS,
                                ITEM_CLASS,
                                ITEM_ID,
                                APPROVER_ORDER_NUMBER)
                                VALUES(
                                p_invoice_id,
                                decode( l_class(l_rec),
				       'header',null,
				       l_line_num),
                                l_next_approver.NAME,
                                l_next_approver.ORIG_SYSTEM,
                                l_next_approver.ORIG_SYSTEM_ID,
                                l_next_approver.DISPLAY_NAME,
                                l_next_approver.APPROVER_CATEGORY,
                                l_next_approver.API_INSERTION,
                                l_next_approver.AUTHORITY,
                                l_next_approver.APPROVAL_STATUS,
                                l_class(l_rec),
				l_ids(l_rec),
                                l_next_approver.APPROVER_ORDER_NUMBER);

                                l_debug_info := 'after insert';
                                IF (G_LEVEL_STATEMENT >=
                                        G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING(G_LEVEL_STATEMENT,
                                                        G_MODULE_NAME||
                                                l_api_name,l_debug_info);
                                END IF;
                        END IF; --l_index mapping
                   END LOOP; -- l_index mapping

                ELSE  --only one item_id per approver

                    l_debug_info := 'only one item_id per approver';
                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
                   END IF;
                   --Depending on the type of item class, we need to set
                   --some variables:
                   IF l_next_approver.item_class =
                                ame_util.lineItemItemClassName THEN
                        l_line_num := l_next_approver.item_id;
                   ELSIF l_next_approver.item_class = 'project code' THEN

                        SELECT Invoice_Line_Number
                        INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE project_id = l_next_approver.item_id;
                   ELSIF l_next_approver.item_class =
                                ame_util.costCenterItemClassName THEN

                        SELECT Invoice_Line_Number
                        INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE project_id = l_next_approver.item_id;
                   --distributions
                   ELSIF l_next_approver.item_class <>
                                        ame_util.lineItemItemClassName
                         AND l_next_approver.item_class <>
                                        ame_util.headerItemClassName THEN

                        SELECT Invoice_Line_Number
                        INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE invoice_distribution_id = l_next_approver.item_id;

                   END IF; --l_class
                        -- Bug 5590138. Modified table to AP_APPROVERS_LIST_GT
                        -- from AP_APINV_APPROVERS
                        --Insert record into ap_approvers_list_gt
                        INSERT INTO AP_APPROVERS_LIST_GT(
                               TRANSACTION_ID,  -- Bug 5624200
                               LINE_NUMBER,
                                ROLE_NAME,
                                ORIG_SYSTEM,
                                ORIG_SYSTEM_ID,
                                DISPLAY_NAME,
                                APPROVER_CATEGORY,
                                API_INSERTION,
                                AUTHORITY,
                                 APPROVAL_STATUS,
                                ITEM_CLASS,
                                ITEM_ID,
                                APPROVER_ORDER_NUMBER)
                                VALUES(
                                p_invoice_id,
                                decode(l_next_approver.item_class,
				       'header',null,
				       l_line_num),
                                l_next_approver.NAME,
                                l_next_approver.ORIG_SYSTEM,
                                l_next_approver.ORIG_SYSTEM_ID,
                                l_next_approver.DISPLAY_NAME,
                                l_next_approver.APPROVER_CATEGORY,
                                l_next_approver.API_INSERTION,
                                l_next_approver.AUTHORITY,
                                l_next_approver.APPROVAL_STATUS,
                                l_next_approver.item_class,
				l_next_approver.item_id,
                                l_next_approver.APPROVER_ORDER_NUMBER);

                END IF; --more than one item_id per approver

           END LOOP; --nextApprovers table

        END IF; --complete

EXCEPTION
WHEN OTHERS
        THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Get_All_Approvers;

/*This function terminates any invoice approval workflow processes
 when a user turns off the 'Use Invoice Approval Workflow' payables
option. */

PROCEDURE Terminate_Approval(
			errbuf OUT NOCOPY VARCHAR2,
                        retcode           OUT NOCOPY NUMBER) IS

	--Define cursor for wf and ame records that need to be terminated
	/* Order by Logic is needed since there is a parent/child
	   relationship and Child process has to be aborted before
	   the parent. */
	CURSOR   key_cur IS
        SELECT   item_key, item_type,root_activity,
	         SUBSTR(item_key,1,INSTR(item_key,'_')-1) invoice_id
	FROM     wf_items
	WHERE    item_type IN ('APINVAPR','APINVNEG')
	AND      end_date is NOT NULL
	ORDER BY decode(root_activity,'APPROVAL_MAIN','3'
	                             ,'APPROVAL_INVOICE_LINES','2'
				     ,'APPROVAL_NEGOTIATION', '1') asc;

	l_api_name      CONSTANT VARCHAR2(200) := 'Terminate_Approval';
	l_item_key      wf_items.item_key%TYPE;
	l_item_type     wf_items.item_type%TYPE;
	l_process       wf_items.root_activity%TYPE;
	l_invoice_id	NUMBER;
        l_debug_info    VARCHAR2(2000);
        l_calling_sequence      VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := l_api_name;

	l_debug_info := 'opening key cursor';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
        END IF;

        OPEN key_Cur;
        LOOP

           FETCH key_Cur INTO l_item_key, l_item_type,
		                   l_process, l_invoice_id;

           EXIT WHEN key_Cur%NOTFOUND OR key_Cur%NOTFOUND IS NULL;

	   WF_Engine.abortProcess(
			itemType => l_item_type,
			itemKey  => l_item_key,
			process => l_process);

	   --we only need to clear for main process
	   IF l_process = 'APPROVAL_MAIN' THEN

	      AME_API2.clearAllApprovals(applicationIdIn => 200,
                       transactionIdIn     => to_char(l_invoice_id),
                       transactionTypeIn =>  'APINV');

           END IF;

        END LOOP;
        CLOSE key_Cur;

	--Clear all iaw processing records

	DELETE FROM AP_APINV_APPROVERS;


	--Set the lines status
	UPDATE  ap_invoice_lines_all
    	SET  wfapproval_status = 'NOT REQUIRED'
  	WHERE  wfapproval_status in ('INITIATED','REQUIRED'
	                            ,'REJECTED','NEEDS WFREAPPROVAL'
				    ,'STOPPED');

	--Set the header status
	UPDATE  ap_invoices_all
    	SET  wfapproval_status = 'NOT REQUIRED'
  	WHERE  wfapproval_status in ('INITIATED','REQUIRED'
	                            ,'REJECTED','NEEDS WFREAPPROVAL'
				    ,'STOPPED');

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Terminate_Approval;
PROCEDURE wakeup_lineapproval_process( p_invoice_id IN NUMBER,
                                       p_itemkey  IN VARCHAR2) IS
l_sent          NUMBER;
l_invoice_key   VARCHAR2(50);
l_api_name      CONSTANT VARCHAR2(200) := 'wakeup_lineapproval_process';
l_debug_info    VARCHAR2(2000);

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   SELECT count(*)
   INTO  l_sent
   FROM  AP_APINV_APPROVERS
   WHERE Notification_status = 'SENT'
   AND   child_process_item_key = p_itemkey
   AND   invoice_id = p_invoice_id;
   IF l_sent = 0 THEN
      wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => p_itemkey,
                        activity => 'APPROVAL_INVOICE_LINES:WAITLINEAPRVL',
                        result   => 'NULL');
   ELSE

      BEGIN

         SELECT invoice_key
         INTO   l_invoice_key
         FROM   AP_APINV_APPROVERS
         WHERE  Notification_Key = p_itemkey
         AND    invoice_id = p_invoice_id
         AND    rownum = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_debug_info := 'No Data Found in SELECT from AP_APINV_APPROVERS' ;
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                               l_api_name,l_debug_info);
         END IF;
         RAISE;

      END;
      l_debug_info := 'Before CompleteActivity APPROVAL_MAIN:BLOCK' ||
                      'l_invoice_key = ' || l_invoice_key;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                            l_api_name,l_debug_info);
      END IF;
      BEGIN
         wf_engine.CompleteActivity(
                           itemType => 'APINVAPR',
                           itemKey  => l_invoice_key,
                           activity => 'APPROVAL_MAIN:BLOCK',
                           result   => 'NULL');
      EXCEPTION
      WHEN OTHERS THEN NULL;
      END;
   END IF;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION
   WHEN OTHERS THEN NULL;
END wakeup_lineapproval_process;

PROCEDURE is_invoice_matched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_match_type VARCHAR2(80);
   l_debug_info            VARCHAR2(2000);
   l_api_name              CONSTANT VARCHAR2(200) := 'is_invoice_matched';
BEGIN
   l_match_type := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'INV_MATCH_TYPE');


   IF l_match_type = 'MATCHED' THEN
      resultout := wf_engine.eng_completed||':'||'Y';
   ELSE
      resultout := wf_engine.eng_completed||':'||'N';
   END IF;
   l_debug_info := 'resultout : ' || resultout;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','is_invoice_matched',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END is_invoice_matched;

PROCEDURE aprvl_process_reject_int(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_api_name      CONSTANT VARCHAR2(200) := 'aprvl_process_reject_int';
   l_debug_info    VARCHAR2(2000);
   l_parent_key    VARCHAR2(150);
BEGIN
   l_parent_key := WF_ENGINE.GetItemAttrText(itemtype,
                             itemkey,
                             'PARENT_KEY');

   wf_engine.CompleteActivity(
                        itemType => 'APINVAPR',
                        itemKey  => l_parent_key,
                        activity => 'APPROVAL_INVOICE:DOCUMENT_APPROVAL_REQUEST',
                        result   => 'REJECTED');
   resultout := wf_engine.eng_completed||':'||'Y';
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVNEG','aprvl_process_reject_int',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END aprvl_process_reject_int;

-- Bug 8462325. Added parameter p_process_instance_label.
PROCEDURE approve_button( p_itemkey  IN VARCHAR2,
                          p_process_instance_label IN VARCHAR2) IS
l_api_name      CONSTANT VARCHAR2(200) := 'approve_button';
l_debug_info    VARCHAR2(2000);
l_invoice_id    NUMBER(15); -- Bug 6845397
-- Bug 8462325.
l_activity      VARCHAR2(100) := 'APPROVAL_INVOICE:' || p_process_instance_label ;

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   -- Bug 6845397. Getting invoice id.
   l_invoice_id := substr(p_itemkey, 1, instr(p_itemkey,'_')-1);
   BEGIN
      wf_engine.CompleteActivity(
                           itemType => 'APINVAPR',
                           itemKey  => p_itemkey,
                           activity => l_activity, -- Bug 8462325.
                           result   => 'APPROVED');
   EXCEPTION
   WHEN OTHERS THEN NULL;
   END;
   -- Bug 6845397.
   -- Added code to set the generate_dists flag of invoice lines to D, if the line has
   -- atleast one invoice distribution.

   l_debug_info := 'Updating the generate_dists of ap_invoice_lines. Invoice_id = ' || l_invoice_id;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   update ap_invoice_lines_all ail
   set generate_dists = decode(ail.generate_dists, 'Y', 'D', ail.generate_dists)
   where ail.invoice_id = l_invoice_id
     and exists( select 1 from ap_invoice_distributions_all aid
                 where aid.invoice_id = l_invoice_id
                   and aid.invoice_line_number = ail.line_number) ;

   -- End bug 6845397
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
   l_debug_info := 'Exception during update.';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF ;
   APP_EXCEPTION.RAISE_EXCEPTION;
END approve_button;

--Bug 8689391. Added parameter processInstanceLabel  to procedure rejectButton.
PROCEDURE reject_button( p_itemkey  IN VARCHAR2,
                         p_process_instance_label IN VARCHAR2) IS
l_api_name      CONSTANT VARCHAR2(200) := 'reject_button';
l_debug_info    VARCHAR2(2000);
--for Bug 8689391
l_activity      VARCHAR2(100) := 'APPROVAL_INVOICE:' || p_process_instance_label ;
BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   BEGIN
      wf_engine.CompleteActivity(
                           itemType => 'APINVAPR',
                           itemKey  => p_itemkey,
                           activity => l_activity, -- for Bug 8689391
                           result   => 'REJECTED');
   EXCEPTION
   WHEN OTHERS THEN NULL;
   END;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION
      WHEN OTHERS THEN NULL;
END reject_button;

PROCEDURE accept_invoice_button( p_itemkey  IN VARCHAR2) IS
l_api_name      CONSTANT VARCHAR2(200) := 'accept_invoice_button';
l_debug_info    VARCHAR2(2000);

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   BEGIN
      wf_engine.CompleteActivity(
                          itemType => 'APINVNEG',
                          itemKey  => p_itemkey,
                          activity => 'APPROVAL_NEGOTIATION:NOTIFY_SUP_NEGOTIATION',
                          result   => 'ACCEPT');
   EXCEPTION
      WHEN OTHERS THEN NULL;
   END;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION
   WHEN OTHERS THEN NULL;
END accept_invoice_button;
PROCEDURE accept_invoice_int_button( p_itemkey  IN VARCHAR2) IS
l_api_name      CONSTANT VARCHAR2(200) := 'accept_invoice_int_button';
l_debug_info    VARCHAR2(2000);

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   BEGIN
      wf_engine.CompleteActivity(
                          itemType => 'APINVNEG',
                          itemKey  => p_itemkey,
                          activity => 'APPROVAL_NEGOTIATION:NOTIFY_INT_NEGOTIATION',
                          result   => 'ACCEPT');
   EXCEPTION
      WHEN OTHERS THEN NULL;
   END;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION
   WHEN OTHERS THEN NULL;
END accept_invoice_int_button;

PROCEDURE cancel_invoice_aprvl_button( p_itemkey  IN VARCHAR2) IS
l_api_name      CONSTANT VARCHAR2(200) := 'cancel_invoice_aprvl_button';
l_debug_info    VARCHAR2(2000);

BEGIN
   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
   BEGIN
      wf_engine.CompleteActivity(
                          itemType => 'APINVNEG',
                          itemKey  => p_itemkey,
                          activity => 'APPROVAL_NEGOTIATION:NOTIFY_SUP_NEGOTIATION',
                          result   => 'CANCELINVOICE');
   EXCEPTION
      WHEN OTHERS THEN NULL;
   END;
   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION
   WHEN OTHERS THEN NULL;
END cancel_invoice_aprvl_button;

PROCEDURE set_comments( p_itemkey  IN VARCHAR2,  p_notif_id IN VARCHAR2,  p_notes in VARCHAR2) IS
l_api_name      CONSTANT VARCHAR2(200) := 'set_comments';
l_debug_info    VARCHAR2(2000);
BEGIN

   l_debug_info := 'Start';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   WF_ENGINE.SetItemAttrText('APINVAPR',
                        p_itemkey,
                        'WF_NOTE',
                        p_notes);

   l_debug_info := 'Inserting wf_notes for approval from product page';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

-- Save approval comments in wf_notification_attributes
-- when approval action is triggered from product page (Inv Details)

   if p_notes is not null then
    WF_NOTIFICATION.setAttrText(	to_number(p_notif_id),
				'WF_NOTE',
				p_notes);
   end if;

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

EXCEPTION
   WHEN OTHERS THEN NULL;
END;

PROCEDURE is_payment_request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
   l_invoice_id ap_invoices_all.invoice_id%TYPE;
   l_inv_type ap_invoices_all.invoice_type_lookup_code%TYPE;
   l_debug_info            VARCHAR2(2000);
   l_api_name              CONSTANT VARCHAR2(200) := 'is_payment_request';
BEGIN
   l_invoice_id := WF_ENGINE.GETITEMATTRNumber
                  (itemtype,
                   itemkey,
                   'INVOICE_ID');
   SELECT ai.invoice_type_lookup_code
   INTO   l_inv_type
   FROM   ap_invoices_all ai
   WHERE  invoice_id = l_invoice_id;

   IF l_inv_type = 'PAYMENT REQUEST' THEN
      resultout := wf_engine.eng_completed||':'||'Y';
   ELSE
      resultout := wf_engine.eng_completed||':'||'N';
   END IF;
   l_debug_info := 'resultout : ' || resultout;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINVAPR','is_payment_request',itemtype,
                        itemkey, to_char(actid), funcmode);
        RAISE;
END is_payment_request;
-- ANSETHUR 18-APR-2008
/*
PROCEDURE NAME : notification_handler
PROJECT : R12 - Workflow Delegation enhancement
PURPOSE : This procedure is attached to the notifications in order
          to populate the forward to role attribute during the delegation
          and to create history entries.Also the throws error when the
          notification ownership is transfered.
*/
PROCEDURE notification_handler( itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2 ) IS
l_invoice_id               NUMBER(15);
l_iteration                NUMBER;
l_status	                 VARCHAR2(50);
l_response                 VARCHAR2(50);
l_nid                      number;
l_forward_to_person_id     number;
l_result                   varchar2(100);
l_orig_system              WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id              WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_role                     VARCHAR2(50);
l_role_display             VARCHAR2(150);
l_org_id                   NUMBER(15);
l_name                     wf_users.name%TYPE; --bug 8620671
l_display_name             VARCHAR2(150);
l_forward_to_user_id       WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver             AME_UTIL.approverRecord;
l_rec_role                 VARCHAR2(50);
l_comments                 VARCHAR2(240);
l_hist_id                  NUMBER(15);
l_amount                   ap_invoices_all.invoice_amount%TYPE;
l_user_id                  NUMBER(15);
l_login_id                 NUMBER(15);
l_hist_rec                 AP_INV_APRVL_HIST%ROWTYPE;
l_notf_iteration           NUMBER;
l_role_name                VARCHAR2(50);
l_esc_flag                 VARCHAR2(1);
l_esc_role                 VARCHAR2(50);
l_esc_role_actual          VARCHAR2(50);
l_role_actual              VARCHAR2(50);
l_fwd_role                 VARCHAR2(50);
l_invoice_total            NUMBER;

CURSOR c_get_user ( p_rec_role IN VARCHAR2 ) IS
  SELECT user_id,employee_id
  FROM   FND_USER
  WHERE  USER_NAME=p_rec_role;

CURSOR c_get_response ( p_invoice_id IN NUMBER) IS
  Select response
  From   ap_inv_aprvl_hist
  WHERE  approval_history_id=(select max(approval_history_id)from ap_inv_aprvl_hist
		                         where invoice_id= p_invoice_id);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                                itemkey,
                                                'INVOICE_ID');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(  itemtype,
                                              itemkey,
                                              'ORG_ID');

    l_iteration := WF_ENGINE.GetItemAttrNumber( itemtype,
                                                itemkey,
                                                'ITERATION');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'WF_NOTE');
    l_notf_iteration := WF_ENGINE.GetItemAttrnumber(itemtype,
                                                    itemkey,
                                                    'NOTF_ITERATION');
-- bug # 8244218  begins
    l_esc_flag := WF_ENGINE.GetItemAttrnumber(itemtype,
                                                    itemkey,
                                                    'ESCALATED');
     /*WF_ENGINE.GetItemAttrnumber(itemtype,
                                                    itemkey,
                                                    'ESCALATED'); */
-- bug # 8244218  ends
    l_role_actual := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'ROLE_ACTUAL');
    l_esc_role_actual := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'ESC_ROLE_ACTUAL');
    l_fwd_role := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'FORWARD_ROLE');
   l_invoice_total := WF_ENGINE.GETITEMATTRNumber(itemtype,
                   itemkey,
                   'INVOICE_TOTAL');
-- getting approver in the document_approver and setting in the ROLE_ACTUAL attribute
-- So even if the notification is delegated the ame will be updated in the for the actual approver
-- the further level of approval will be done by the owners supervisors and also the same
-- notification won't be sent to  this approver again
         IF ((nvl(l_esc_flag,'N') = 'N')and (l_fwd_role is null) ) THEN
          l_role_name :=WF_ENGINE.GetItemAttrText(itemtype,
                                    itemkey,
                                    'DOCUMENT_APPROVER');
          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'ROLE_ACTUAL',
                                    l_role_name);

          elsif ((nvl(l_esc_flag,'N') = 'Y')and (l_esc_role_actual is null) ) THEN
          l_esc_role :=WF_ENGINE.GetItemAttrText( itemtype,
                                                  itemkey,
                                                  'ESC_ROLE_NAME');
          WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'ESC_ROLE_ACTUAL',
                                     l_esc_role);

          end if ;
-- end


  IF (funcmode ='FORWARD') then
         l_rec_role :=WF_ENGINE.context_text;
         l_status:='DELEGATED';

         --fnd_client_info.set_org_context(l_org_id);
          --Now set the environment
         MO_GLOBAL.INIT ('SQLAP');
         MO_GLOBAL.set_policy_context('S',l_org_id);


         /*insert_history(      l_invoice_id,
                              l_iteration,
                              l_org_id,
                              l_status);*/



          OPEN  c_get_user ( l_rec_role);
          FETCH c_get_user INTO l_forward_to_user_id,l_forward_to_person_id;
          CLOSE c_get_user;

          IF l_forward_to_person_id is not NULL then
                     l_orig_system := 'PER';
                     l_orig_sys_id := l_forward_to_person_id;
          ELSE
                     l_orig_system := 'FND_USR';
                     l_orig_sys_id := l_forward_to_user_id;
          END IF;
          WF_DIRECTORY.GetRoleName( l_orig_system,
                                    l_orig_sys_id,
                                    l_role,
                                    l_role_display);

          WF_DIRECTORY.GetUserName( l_orig_system,
                                    l_orig_sys_id,
                                    l_name,
                                    l_display_name);


          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'FORWARD_ROLE',
                                    l_role);
        IF nvl(l_esc_flag,'N') = 'N' THEN


          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'DOCUMENT_APPROVER',
                                    l_role);
          WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'APPROVER_NAME',
                                     l_display_name);

           WF_ENGINE.SetItemAttrNumber(itemtype,
                                       itemkey,
                                       'APPROVER_ID',
                                       l_orig_sys_id);
       /* WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'ORIG_SYSTEM',
                                     l_orig_system);     */

        else
          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'ESC_ROLE_NAME',
                                    l_role);
          WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'ESC_APPROVER_NAME',
                                     l_display_name);

           WF_ENGINE.SetItemAttrNumber(itemtype,
                                       itemkey,
                                       'ESC_APPROVER_ID',
                                       l_orig_sys_id);

        end if ;

          l_comments                    := nvl(l_comments,'None');
          l_comments                    :='To: '||l_display_name||' '||'    With Comment:'||l_comments;

          l_hist_rec.HISTORY_TYPE       := 'DOCUMENTAPPROVAL';
          l_hist_rec.INVOICE_ID         := l_invoice_id;
          l_hist_rec.ITERATION          := l_iteration;
          l_hist_rec.RESPONSE           := l_status;

          l_hist_rec.APPROVER_ID        := l_orig_sys_id;
          l_hist_rec.APPROVER_NAME      := l_display_name;

          l_hist_rec.CREATED_BY         := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
          l_hist_rec.CREATION_DATE      := sysdate;
          l_hist_rec.LAST_UPDATE_DATE   := sysdate;
          l_hist_rec.LAST_UPDATED_BY    := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
          l_hist_rec.LAST_UPDATE_LOGIN  := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
          l_hist_rec.ORG_ID             := l_org_id;
          l_hist_rec.AMOUNT_APPROVED    := l_invoice_total;--0;
          l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
          l_hist_rec.APPROVER_COMMENTS  := l_comments;

          insert_history_table(p_hist_rec => l_hist_rec);

           /*--Bug6406901, added the approver_name to the update cmd to populate correct value in AP_INV_APRVL_HLIST
           UPDATE AP_INV_APRVL_HIST
           set   APPROVER_COMMENTS = l_comments, approver_name = l_display_name
           WHERE APPROVAL_HISTORY_ID =(select max(APPROVAL_HISTORY_ID) from AP_INV_APRVL_HIST
                                        where invoice_id=l_invoice_id);*/
           resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
           return;
   End if;

      /* BEGIN
           Select response into l_response
           From   ap_inv_aprvl_hist
           WHERE  approval_history_id=(select max(approval_history_id)from ap_inv_aprvl_hist
    			                             where invoice_id=l_invoice_id);
       EXCEPTION
         WHEN OTHERS THEN
          NULL;
       END; */
          OPEN  c_get_response ( l_invoice_id);
          FETCH c_get_response INTO l_response;
          CLOSE c_get_response;

	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            /*l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;


            insert_history(l_invoice_id,
                        l_iteration,
                        l_org_id,
                        l_result);


          WF_ENGINE.SetItemAttrText(  itemtype,
                                      itemkey,
                                      'FORWARD_ROLE',
                                      NULL);-- */

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
  End if;


  -- Don't allow transfer
  if ( funcmode = 'TRANSFER' ) then
       resultout := 'ERROR:WFSRV_NO_DELEGATE';
       return;
  end if;

return;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('AP_WF',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END;
/*
PROCEDURE NAME : forward_check
PROJECT : R12 - Workflow Delegation enhancement
PURPOSE : This procedure is attached to the check_forward node.
          This procedure checks before escalation whether the notification
          is forwarded when there is a time out. If the result is N
          (i.e when the notification is not a forwarded one) ,
          then the escalation notification is sent.If the result is Y, then the
          document is rejected.
*/
PROCEDURE forward_check(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_forward_role_name   varchar2(50);
l_current_role_name   varchar2(50);
l_temp_invoice_id     NUMBER(15);     -- Bug 5037108
l_error_message       VARCHAR2(2000); -- Bug 5037108
l_debug_info 	        VARCHAR2(50);   -- Bug 5037108

BEGIN
  l_forward_role_name :=     WF_ENGINE.GetItemAttrText(itemtype,
                              itemkey,
                              'FORWARD_ROLE');
  l_current_role_name :=     WF_ENGINE.GetItemAttrText(itemtype,
                              itemkey,
                              'DOCUMENT_APPROVER');

  IF  l_forward_role_name is NULL or l_forward_role_name=' ' THEN
            resultout := wf_engine.eng_completed||':'||'N';
  ELSE
        IF(nvl(l_forward_role_name,'') = nvl(l_current_role_name,'')) then
            resultout := wf_engine.eng_completed||':'||'Y';
       /* -- Bug 5037108 starts
             BEGIN
                SELECT invoice_id
                INTO l_temp_invoice_id
                FROM ap_invoices
                WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1)
  	            AND  wfapproval_status <> 'MANUALLY APPROVED'
                FOR UPDATE NOWAIT;

              EXCEPTION
               WHEN OTHERS THEN
                l_debug_info := 'Invoice is in lock. Please try later';
                FND_MESSAGE.Set_Name('SQLAP', 'AP_CARD_VERIFY_LOCK_FAILED');
                l_error_message := FND_MESSAGE.Get;
                APP_EXCEPTION.RAISE_EXCEPTION;
              END;
        -- Bug 5037108 Ends

                UPDATE AP_INVOICES
                SET wfapproval_status = 'REJECTED'
                WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1)
                AND wfapproval_status <> 'MANUALLY APPROVED'; */
        ELSE
              resultout := wf_engine.eng_completed||':'||'N';
        END If;

  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR
        THEN
          WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
          WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END;
/*
PROCEDURE NAME : notification_handler_lines
PROJECT : R12 - Workflow Delegation enhancement
PURPOSE : This procedure is attached to the notifications in the lines Approval
          in order to populate the forward to role attribute during the delegation
          and to create history entries.Also the throws error when the
          notification ownership is transfered.
*/
PROCEDURE notification_handler_lines( itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2 ) IS
l_invoice_id               NUMBER(15);
l_iteration                NUMBER;
l_status	                 VARCHAR2(50);
l_response                 VARCHAR2(50);
l_nid                      number;
l_forward_to_person_id     number;
l_result                   varchar2(100);
l_orig_system              WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id              WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_role                     VARCHAR2(50);
l_role_display             VARCHAR2(150);
l_org_id                   NUMBER(15);
l_name                     wf_users.name%TYPE; --bug 8620671
l_display_name             VARCHAR2(150);
l_forward_to_user_id       WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver             AME_UTIL.approverRecord;
l_rec_role                 VARCHAR2(50);
l_comments                 VARCHAR2(240);
l_hist_id                  NUMBER(15);
l_amount                   ap_invoices_all.invoice_amount%TYPE;
l_user_id                  NUMBER(15);
l_login_id                 NUMBER(15);
l_hist_rec                 AP_INV_APRVL_HIST%ROWTYPE;
l_notf_iteration           NUMBER;
l_line_number              ap_invoice_lines_all.line_number%TYPE;
l_line_amount              ap_invoice_lines_all.amount%TYPE;
l_role_name                varchar2(50);
l_esc_flag                 varchar2(1);
l_esc_role                 varchar2(50);


CURSOR c_get_user ( p_rec_role IN VARCHAR2 ) IS
  SELECT user_id,employee_id
  FROM   FND_USER
  WHERE  USER_NAME=p_rec_role;

CURSOR c_get_response ( p_invoice_id IN NUMBER) IS
  Select response
  From   ap_inv_aprvl_hist
  WHERE  approval_history_id=(select max(approval_history_id)from ap_inv_aprvl_hist
		                         where invoice_id= p_invoice_id);


   CURSOR   Items_Cur(itemkey IN VARCHAR2) IS
   SELECT  al.line_number, al.amount
   FROM   AP_APINV_APPROVERS invap, AP_INVOICE_LINES_ALL al
   WHERE  invap.Notification_Key = itemkey
   AND    al.line_number = invap.line_number
   AND    al.invoice_id  = invap.invoice_id;
BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                                itemkey,
                                                'INVOICE_ID');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(  itemtype,
                                              itemkey,
                                              'ORG_ID');

    l_iteration := WF_ENGINE.GetItemAttrNumber( itemtype,
                                                itemkey,
                                                'ITERATION');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'WF_NOTE');
    l_notf_iteration := WF_ENGINE.GetItemAttrnumber(itemtype,
                                                    itemkey,
                                                    'NOTF_ITERATION');
    l_esc_flag := WF_ENGINE.GetItemAttrText(itemtype,
                                            itemkey,
                                            'ESCALATED');

-- getting approver in the ROLE_NAME and setting in the ROLE_ACTUAL attribute
-- on case of escalated notifications getting the approver from ESC_ROLE_NAME and setting it to ESC_ROLE_ACTUAL
-- So even if the notification is delegated the ame will be updated in the for the actual approver
-- the further level of approval will be done by the owners supervisors and also the same
-- notification won't be sent to  this approver again
        IF nvl(l_esc_flag,'N') = 'N' THEN
          l_role_name :=WF_ENGINE.GetItemAttrText(itemtype,
                                    itemkey,
                                    'ROLE_NAME');

          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'ROLE_ACTUAL',
                                    l_role_name);

        elsif nvl(l_esc_flag,'N') = 'Y' THEN
          l_esc_role :=WF_ENGINE.GetItemAttrText( itemtype,
                                                  itemkey,
                                                  'ESC_ROLE_NAME');
          WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'ESC_ROLE_ACTUAL',
                                     l_esc_role);

        end if ;
-- end
  IF (funcmode ='FORWARD') then
         l_rec_role :=WF_ENGINE.context_text;
         l_status:='DELEGATED';

         --fnd_client_info.set_org_context(l_org_id);
          --Now set the environment
         MO_GLOBAL.INIT ('SQLAP');
         MO_GLOBAL.set_policy_context('S',l_org_id);


         /*insert_history(      l_invoice_id,
                              l_iteration,
                              l_org_id,
                              l_status);*/



          OPEN  c_get_user ( l_rec_role);
          FETCH c_get_user INTO l_forward_to_user_id,l_forward_to_person_id;
          CLOSE c_get_user;

          IF l_forward_to_person_id is not NULL then
                     l_orig_system := 'PER';
                     l_orig_sys_id := l_forward_to_person_id;
          ELSE
                     l_orig_system := 'FND_USR';
                     l_orig_sys_id := l_forward_to_user_id;
          END IF;
          WF_DIRECTORY.GetRoleName( l_orig_system,
                                    l_orig_sys_id,
                                    l_role,
                                    l_role_display);

          WF_DIRECTORY.GetUserName( l_orig_system,
                                    l_orig_sys_id,
                                    l_name,
                                    l_display_name);

          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'FORWARD_ROLE_LINES',
                                    l_role);


     IF nvl(l_esc_flag,'N') = 'N' THEN


          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'ROLE_NAME',
                                    l_role);
          WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'APPROVER_NAME',
                                     l_display_name);

           WF_ENGINE.SetItemAttrNumber(itemtype,
                                       itemkey,
                                       'APPROVER_ID',
                                       l_orig_sys_id);
       /* WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'ORIG_SYSTEM',
                                     l_orig_system);     */

        else
          WF_ENGINE.SetItemAttrText(itemtype,
                                    itemkey,
                                    'ESC_ROLE_NAME',
                                    l_role);
          WF_ENGINE.SetItemAttrText( itemtype,
                                     itemkey,
                                     'ESC_APPROVER_NAME',
                                     l_display_name);

           WF_ENGINE.SetItemAttrNumber(itemtype,
                                       itemkey,
                                       'ESC_APPROVER_ID',
                                       l_orig_sys_id);

        end if ;

          l_comments                    := nvl(l_comments,'None');
          l_comments                    :='To: '||l_display_name||' '||'    With Comment:'||l_comments;

          l_hist_rec.HISTORY_TYPE       := 'LINESAPPROVAL';
          l_hist_rec.INVOICE_ID         := l_invoice_id;
          l_hist_rec.ITERATION          := l_iteration;
          l_hist_rec.RESPONSE           := l_status;
          l_hist_rec.APPROVER_ID        := l_orig_sys_id;
          l_hist_rec.APPROVER_NAME      := l_display_name;
          l_hist_rec.CREATED_BY         := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
          l_hist_rec.CREATION_DATE      := sysdate;
          l_hist_rec.LAST_UPDATE_DATE   := sysdate;
          l_hist_rec.LAST_UPDATED_BY    := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
          l_hist_rec.LAST_UPDATE_LOGIN  := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
          l_hist_rec.ORG_ID             := l_org_id;
          l_hist_rec.AMOUNT_APPROVED    := 0;
          l_hist_rec.NOTIFICATION_ORDER := l_notf_iteration;
          l_hist_rec.APPROVER_COMMENTS  := l_comments;
          /*l_hist_rec.line_number        := l_line_number;
          l_hist_rec.AMOUNT_APPROVED    := l_line_amount;

          insert_history_table(p_hist_rec => l_hist_rec);*/

           OPEN Items_Cur(itemkey);
           LOOP

              FETCH Items_Cur INTO l_line_number, l_line_amount;
              EXIT WHEN Items_Cur%NOTFOUND OR Items_Cur%NOTFOUND IS NULL;


              l_hist_rec.line_number   := l_line_number;
              l_hist_rec.AMOUNT_APPROVED   := l_line_amount;

              insert_history_table(p_hist_rec => l_hist_rec);
           END LOOP;
           CLOSE Items_Cur;
           /*--Bug6406901, added the approver_name to the update cmd to populate correct value in AP_INV_APRVL_HLIST
           UPDATE AP_INV_APRVL_HIST
           set   APPROVER_COMMENTS = l_comments, approver_name = l_display_name
           WHERE APPROVAL_HISTORY_ID =(select max(APPROVAL_HISTORY_ID) from AP_INV_APRVL_HIST
                                        where invoice_id=l_invoice_id);*/
           resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
           return;
   End if;

      /* BEGIN
           Select response into l_response
           From   ap_inv_aprvl_hist
           WHERE  approval_history_id=(select max(approval_history_id)from ap_inv_aprvl_hist
    			                             where invoice_id=l_invoice_id);
       EXCEPTION
         WHEN OTHERS THEN
          NULL;
       END; */

        /*  OPEN  c_get_response ( l_invoice_id);
          FETCH c_get_response INTO l_response;
          CLOSE c_get_response;

	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;


            insert_history(l_invoice_id,
                        l_iteration,
                        l_org_id,
                        l_result);


          WF_ENGINE.SetItemAttrText(  itemtype,
                                      itemkey,
                                      'FORWARD_ROLE',
                                      NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
  End if;*/
  -- Don't allow transfer
  if ( funcmode = 'TRANSFER' ) then
       resultout := 'ERROR:WFSRV_NO_DELEGATE';
       return;
  end if;

return;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('AP_WF',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END;
/*
PROCEDURE NAME : forward_check_lines
PROJECT : R12 - Workflow Delegation enhancement
PURPOSE : This procedure is attached to the check_forward_lines node.
          This procedure checks before escalation whether the notification
          is forwarded when there is a time out. If the result is N
          (i.e when the notification is not a forwarded one) ,
          then the escalation notification is sent.If the result is Y, then the
          document is rejected.
*/
PROCEDURE forward_check_lines(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_forward_role_name   varchar2(50);
l_current_role_name   varchar2(50);
l_temp_invoice_id     NUMBER(15);
l_error_message       VARCHAR2(2000);
l_debug_info 	        VARCHAR2(50);

BEGIN
  l_forward_role_name :=     WF_ENGINE.GetItemAttrText(itemtype,
                              itemkey,
                              'FORWARD_ROLE_LINES');
  l_current_role_name :=     WF_ENGINE.GetItemAttrText(itemtype,
                              itemkey,
                              'ROLE_NAME');

  IF  l_forward_role_name is NULL or l_forward_role_name=' ' THEN
            resultout := wf_engine.eng_completed||':'||'N';
  ELSE
        IF(nvl(l_forward_role_name,'') = nvl(l_current_role_name,'')) then
            resultout := wf_engine.eng_completed||':'||'Y';
       /* -- Bug 5037108 starts
             BEGIN
                SELECT invoice_id
                INTO l_temp_invoice_id
                FROM ap_invoices
                WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1)
  	            AND  wfapproval_status <> 'MANUALLY APPROVED'
                FOR UPDATE NOWAIT;

              EXCEPTION
               WHEN OTHERS THEN
                l_debug_info := 'Invoice is in lock. Please try later';
                FND_MESSAGE.Set_Name('SQLAP', 'AP_CARD_VERIFY_LOCK_FAILED');
                l_error_message := FND_MESSAGE.Get;
                APP_EXCEPTION.RAISE_EXCEPTION;
              END;
        -- Bug 5037108 Ends

                UPDATE AP_INVOICES
                SET wfapproval_status = 'REJECTED'
                WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1)
                AND wfapproval_status <> 'MANUALLY APPROVED'; */
        ELSE
              resultout := wf_engine.eng_completed||':'||'N';
        END If;

  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR
        THEN
          WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
          WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END;
END AP_WORKFLOW_PKG;

/
