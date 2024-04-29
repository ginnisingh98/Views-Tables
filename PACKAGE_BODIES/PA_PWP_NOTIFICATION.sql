--------------------------------------------------------
--  DDL for Package Body PA_PWP_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PWP_NOTIFICATION" as
/* $Header: PAPWPWFB.pls 120.0.12010000.9 2009/10/08 10:49:15 atshukla noship $ */

-------------------------------------------------------------------------------
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');


-------------------------------------------------------------------------------
-- Procedure            : log_message                                         -
-- Type                 : Private                                             -
-- Purpose              : To create debug log.                                -
-- Note                 : To create debug log.                                -
-- Assumptions          : None.                                               -
-- Parameters                   Type         Required  Description and Purpose-
-- ---------------------------  ------       --------  ------------------------
-- p_log_msg                    VARCHAR2     YES       Message                -
-- debug_level                  NUMBER       YES       Debug Level            -
-------------------------------------------------------------------------------
PROCEDURE log_message (p_log_msg IN VARCHAR2, debug_level IN NUMBER)
IS
BEGIN
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write('log_message: ' || 'PA PWP Notification: ', 'log: ' || p_log_msg, debug_level);
    END IF;
        NULL;
END log_message;


-------------------------------------------------------------------------------
-- Procedure            : Receive_BE                                          -
-- Type                 : Public                                              -
-- Purpose              : Function for receiving AR Business Event            -
--                        oracle.apps.ar.applications.CashApp.apply           -
-- Note                 : To Integrate the PA Workflow with Apply             -
--                        Receipt Event in AR                                 -
-- Assumptions          : AR Business Event will always be raised upon        -
--                        applying a receipt.                                 -
-- Parameters                   Type         Required  Description and Purpose-
-- ---------------------------  ------       --------  ------------------------
-- p_subscription_guid          RAW          YES       Subscription details   -
-- p_event                      WF_EVENT_T   YES       Event Details          -
--(Refer ARU file wftype2s.sql)                                               -
-------------------------------------------------------------------------------
--
FUNCTION Receive_BE(p_subscription_guid In RAW
                   ,p_event IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2
IS
    l_org_id                        NUMBER;
    l_user_id                       NUMBER;
    l_resp_id                       NUMBER;
    l_application_id                NUMBER;
    l_security_gr_id                NUMBER;
    l_receivable_application_id     NUMBER;
    l_invoice_status                VARCHAR2(30);
    x_return_status                 VARCHAR2(30);
    l_err_code                      NUMBER := 0;
    l_err_stage                     VARCHAR2(2000);
    l_err_stack                     VARCHAR2(2000);

BEGIN
    log_message('Receive_BE: Subscription Triggered', 3);
    --Capture parameters from AR Bussiness Event
    -- Listed below are all 7 variables that we can get from AR BE, Some are commented because they are not required as of now, please uncomment, if required.
    l_receivable_application_id := p_event.GetValueForParameter('RECEIVABLE_APPLICATION_ID');
    --l_invoice_status            := p_event.GetValueForParameter('TRX_PS_STATUS');
    --l_org_id                    := p_event.GetValueForParameter('ORG_ID');
    l_user_id                   := p_event.GetValueForParameter('USER_ID');
    l_resp_id                   := p_event.GetValueForParameter('RESP_ID');
    l_application_id            := p_event.GetValueForParameter('RESP_APPL_ID');
    --l_security_gr_id            := p_event.GetValueForParameter('SECURITY_GROUP_ID');

    log_message('Receive_BE: Subscription Parameters recieved: receivable_application_id=' || l_receivable_application_id || '*', 3);

    --set the application context.
    --fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);  -- 8993957 : Commneted : As this will execute in context set by AR.

    log_message('Receive_BE: Before Calling Wf: receivable_application_id=' || l_receivable_application_id || '*', 3);

    -- Call Wf initiator...
    PA_PWP_NOTIFICATION.START_AR_NOTIFY_WF (p_receivable_application_id => l_receivable_application_id
                                           ,x_err_stack                 => l_err_stack
                                           ,x_err_stage                 => l_err_stage
                                           ,x_err_code                  => l_err_code);

    log_message('Receive_BE: After Calling Wf: l_err_code=' || l_err_code || '*', 3);

    IF l_err_code = 0 THEN
        log_message('Receive_BE: Normal Exit', 3);
        Return 'SUCCESS';
    ELSE
        RETURN 'ERROR';
    END IF;

EXCEPTION
    WHEN OTHERS  THEN
        WF_CORE.CONTEXT('PA_PWP_NOTIFICATION', 'RECEIVE_BE', p_event.getEventName(), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');
        RETURN 'ERROR';

END Receive_BE;



-------------------------------------------------------------------------------
-- Procedure            : START_AR_NOTIFY_WF                                  -
-- Purpose              : Function for Invoking the Workflow.                 -
-- Note                 : To send notifiactions based on various conditions   -
-- Assumptions          : Parameter receivable_application_id will be passed  -
-- Parameters                   Type         Required  Description and Purpose-
-- ---------------------------  ------       --------  ------------------------
-- p_receivable_application_id  NUMBER       YES       Receipt application Id -
-------------------------------------------------------------------------------

PROCEDURE START_AR_NOTIFY_WF (p_receivable_application_id  IN   NUMBER,
                              x_err_stack   IN OUT NOCOPY VARCHAR2,
                              x_err_stage   IN OUT NOCOPY VARCHAR2,
                              x_err_code       OUT NOCOPY NUMBER)
IS

    CURSOR      c_invoice (l_receivable_application_id NUMBER)
    IS
        SELECT  CASH_RECEIPT_ID rcpt_id
               ,Applied_customer_trx_id inv_id
          FROM  ar_receivable_applications
         Where  receivable_application_id = l_receivable_application_id;

    CURSOR      c_ar_notify_flag (l_inv_id Number)
    IS
        SELECT  PPA.ar_rec_notify_flag ar_rec_notify_flag
          FROM  ra_customer_trx RCTRX
               ,pa_projects PPA
         WHERE  RCTRX.customer_trx_id = l_inv_id
           AND  PPA.Segment1 = RCTRX.interface_header_attribute1;

    CURSOR      c_starter_name( l_starter_user_id NUMBER )
    IS
        SELECT  user_name
          FROM  fnd_user
         WHERE  user_id = l_starter_user_id;

    CURSOR      c_starter_full_name(l_starter_user_id NUMBER )
    IS
        SELECT  e.first_name||' '||e.last_name
          FROM  fnd_user f, per_all_people_f e
         WHERE  f.user_id = l_starter_user_id
           AND  f.employee_id = e.person_id
           AND  e.effective_end_date = ( SELECT MAX(papf.effective_end_date)
                                           FROM per_all_people_f papf
                                          WHERE papf.person_id = e.person_id);

    -- Get System Date for Worflow-Started-Date
    CURSOR      c_wf_started_date
    IS
        SELECT  sysdate
          FROM  sys.dual;


    l_inv_info_rec          c_inv_info%ROWTYPE;
    l_inv_rec               c_invoice%ROWTYPE;
    l_ar_notify_flag_rec    c_ar_notify_flag%ROWTYPE;
    l_proj_info_rec         c_proj_info%ROWTYPE;


    ItemKey                         varchar2(30);
    l_wf_started_date               DATE;
    l_workflow_started_by_id        NUMBER;
    l_user_full_name                VARCHAR(400);
    l_user_name                     VARCHAR(240);
    l_resp_id                       NUMBER;
    l_err_code                      NUMBER := 0;
    l_err_stack                     VARCHAR2(2000);
    l_err_stage                     VARCHAR2(2000);
    l_content_id                    NUMBER;

    ItemType         CONSTANT        VARCHAR2(15) := 'PAPWPAR';
    l_process        CONSTANT        VARCHAR2(20) := 'PRO_AR_NOTIFICATION';


BEGIN

    l_content_id := 0;

    log_message('START_AR_NOTIFY_WF: Start: receivable_application_id=' || p_receivable_application_id || '*', 3);

    -- Fetch Receipt id and invoice_id
    OPEN c_invoice (p_receivable_application_id);
    FETCH c_invoice INTO l_inv_rec;
    IF c_invoice%NOTFOUND THEN
        x_err_code  := 10;
    END IF;
    IF c_invoice%ISOPEN THEN
        CLOSE c_invoice;
    END IF;

    --Fetch AR Receipt Notification Flag at project Level.
    OPEN c_ar_notify_flag (l_inv_rec.inv_id);
    FETCH c_ar_notify_flag INTO l_ar_notify_flag_rec;
    IF c_ar_notify_flag%NOTFOUND THEN
        x_err_code  := 10;
    END IF;
    IF c_ar_notify_flag%ISOPEN THEN
        CLOSE c_ar_notify_flag;
    END IF;


    log_message('START_AR_NOTIFY_WF: Check Project level notify flag: ar_rec_notify_flag=' || l_ar_notify_flag_rec.ar_rec_notify_flag || '*', 3);
    -- Check for AR Receipt Notification Flag at project Level.
    IF l_ar_notify_flag_rec.ar_rec_notify_flag = 'Y' THEN
        x_err_code := 0;

        --get the unique identifier for this specific workflow
        SELECT pa_workflow_itemkey_s.nextval
        INTO ItemKey
        from dual;

        -- Need this to populate the attribute information in Workflow
        l_workflow_started_by_id := FND_GLOBAL.user_id;
        l_resp_id := FND_GLOBAL.resp_id;

        -- Create a new Wf process
        wf_engine.CreateProcess( ItemType => ItemType,
                                 ItemKey  => ItemKey,
                                 process  => l_process);

        log_message('START_AR_NOTIFY_WF: Workflow Process created with ItemKey=' || ItemKey || '*', 3);

        -- Fetch all required info to populate Wf Attributes
        OPEN  c_starter_name(l_workflow_started_by_id );
        FETCH c_starter_name INTO l_user_name;
        IF c_starter_name%NOTFOUND THEN
            x_err_code := 10;
            log_message('START_AR_NOTIFY_WF: Cursor c_starter_name failed to fetch Standard WHO data', 3);
        END IF;
        IF c_starter_name%ISOPEN THEN
            CLOSE c_starter_name;
        END IF;

        OPEN  c_starter_full_name(l_workflow_started_by_id );
        FETCH c_starter_full_name INTO l_user_full_name;
        IF c_starter_full_name%NOTFOUND THEN
            x_err_code := 10;
            log_message('START_AR_NOTIFY_WF: Cursor c_starter_full_name failed to fetch Standard WHO data', 3);
        END IF;
        IF c_starter_full_name%ISOPEN THEN
            CLOSE c_starter_full_name;
        END IF;

        OPEN c_wf_started_date;
        FETCH c_wf_started_date INTO l_wf_started_date;
        IF c_wf_started_date%ISOPEN THEN
            CLOSE c_wf_started_date;
        END IF;

        OPEN c_inv_info(p_receivable_application_id);
        FETCH c_inv_info INTO l_inv_info_rec;
        IF c_inv_info%NOTFOUND THEN
            x_err_code := 10;
            log_message('START_AR_NOTIFY_WF: Cursor c_inv_info failed to fetch Invoice data', 3);
        END IF;
        IF c_inv_info%ISOPEN THEN
            CLOSE c_inv_info;
        END IF;

        OPEN  c_proj_info( l_inv_info_rec.Project_Number );
        FETCH c_proj_info INTO l_proj_info_rec;
        IF c_proj_info%NOTFOUND THEN
            x_err_code := 10;
            log_message('START_AR_NOTIFY_WF: Cursor c_proj_info failed to fetch Project data', 3);
        END IF;
        IF c_proj_info%ISOPEN THEN
            CLOSE c_proj_info;
        END IF;

        log_message('START_AR_NOTIFY_WF: Before Calling Generate_PWP_Notify_Page: x_err_code=' || x_err_code || '*', 3);
        IF x_err_code = 0 THEN
            --Generate the page
            Generate_PWP_Notify_Page(p_item_type                     => Itemtype
                                    ,p_item_Key                      => Itemkey
                                    ,p_inv_info_rec                  => l_inv_info_rec
                                    ,p_proj_info_rec                 => l_proj_info_rec
                                    ,x_content_id                    => l_content_id
            );
            log_message('START_AR_NOTIFY_WF: After Calling Generate_PWP_Notify_Page: Generation Successful.', 3);
        END IF;

        -- Set the Wf Attributes
        IF l_proj_info_rec.project_id IS NOT NULL THEN
            wf_engine.SetItemAttrNumber (itemtype     => itemtype
                                        ,itemkey      => itemKey
                                        ,aname        => 'PROJECT_ID'
                                        ,avalue       => l_proj_info_rec.project_id
            );
        END IF;

        IF l_proj_info_rec.project_number IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype     => itemtype
                                      ,itemkey      => itemkey
                                      ,aname        => 'PROJECT_NUMBER'
                                      ,avalue       => l_proj_info_rec.project_number
            );
        END IF;

        IF l_proj_info_rec.project_name IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype     => itemtype
                                      ,itemkey      => itemkey
                                      ,aname        => 'PROJECT_NAME'
                                      ,avalue       => l_proj_info_rec.project_name
            );
        END IF;

        IF l_inv_info_rec.receipt_number IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype   => itemtype
                                        ,itemkey    => itemkey
                                        ,aname      => 'RECEIPT_NUMBER'
                                        ,avalue     =>  l_inv_info_rec.receipt_number
            );
        END IF;

        IF l_inv_info_rec.receipt_currency_code IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype     => itemtype
                                      ,itemkey      => itemkey
                                      ,aname        => 'RECEIPT_CURRENCY_CODE'
                                      ,avalue       =>  l_inv_info_rec.receipt_currency_code
            );
        END IF;

        IF l_inv_info_rec.amount_applied IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype   => itemtype
                                        ,itemkey    => itemkey
                                        ,aname      => 'APPLIED_AMOUNT'
                                        ,avalue     =>  l_inv_info_rec.amount_applied
            );
        END IF;

        IF l_inv_info_rec.ar_invoice_no IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype     => itemtype
                                      ,itemkey      => itemkey
                                      ,aname        => 'AR_INVOICE_NUMBER'
                                      ,avalue       =>  l_inv_info_rec.ar_invoice_no
            );
        END IF;

        IF l_content_id IS NOT NULL THEN
            wf_engine.SetItemAttrNumber (itemtype     => itemtype
                                        ,itemkey      => itemkey
                                        ,aname        => 'CONTENT_ID'
                                        ,avalue       => l_content_id
            );
        END IF;

        --Set the standard WHO Attributes of the workflow
        IF l_workflow_started_by_id IS NOT NULL THEN
            wf_engine.SetItemAttrNumber (itemtype   => itemtype
                                        ,itemkey    => itemkey
                                        ,aname      => 'WORKFLOW_STARTED_BY_ID'
                                        ,avalue     =>  l_workflow_started_by_id
            );
        END IF;

        IF l_user_name IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype     => itemtype
                                      ,itemkey      => itemkey
                                      ,aname        => 'WORKFLOW_STARTED_BY_NAME'
                                      ,avalue       =>  l_user_name
            );
        END IF;

        IF l_user_full_name IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype     => itemtype
                                      ,itemkey      => itemkey
                                      ,aname        => 'WORKFLOW_STARTED_BY_FULL_NAME'
                                      ,avalue       =>  l_user_full_name
            );
        END IF;

        IF l_resp_id IS NOT NULL THEN
            wf_engine.SetItemAttrNumber (itemtype   => itemtype
                                        ,itemkey    => itemkey
                                        ,aname      => 'RESPONSIBILITY_ID'
                                        ,avalue     =>  l_resp_id
            );
        END IF;

        IF l_wf_started_date IS NOT NULL THEN
            wf_engine.SetItemAttrText (itemtype     => itemtype
                                      ,itemkey      => itemkey
                                      ,aname        => 'WF_STARTED_DATE'
                                      ,avalue       => l_wf_started_date
            );
        END IF;
        -- Attribute assignment done

        log_message('START_AR_NOTIFY_WF: Before starting the Wf', 3);
        -- Start the Wf
        wf_engine.StartProcess (itemtype        => itemtype
                               ,itemkey         => itemkey
        );


        IF l_err_code = 0 THEN
            log_message('START_AR_NOTIFY_WF: Wf Started, Inserting in PA_WF_PROCESSES: ItemKey=' || ItemKey || 'l_inv_rec.rcpt_id=' || l_inv_rec.rcpt_id || 'l_inv_rec.inv_id=' || l_inv_rec.inv_id || '*', 3);
            PA_WORKFLOW_UTILS.Insert_WF_Processes (p_wf_type_code        => 'PAPWPARN'
                                                  ,p_item_type           => ItemType
                                                  ,p_item_key            => ItemKey
                                                  ,p_entity_key1         => l_inv_rec.rcpt_id
                                                  ,p_description         => l_inv_rec.inv_id
                                                  ,p_err_code            => l_err_code
                                                  ,p_err_stage           => l_err_stage
                                                  ,p_err_stack           => l_err_stack
            );
        END IF;

    END IF;  /* ar_rec_notify_flag */

    log_message('START_AR_NOTIFY_WF: Normal Exit', 3);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        WF_CORE.CONTEXT('PA_PWP_NOTIFICATION ','START_AR_NOTIFY_WF');
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_err_code := SQLCODE;
        WF_CORE.CONTEXT('PA_PWP_NOTIFICATION ','START_AR_NOTIFY_WF');
        RAISE;
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        WF_CORE.CONTEXT('PA_PWP_NOTIFICATION','START_AR_NOTIFY_WF');
        RAISE;

END START_AR_NOTIFY_WF;


-------------------------------------------------------------------------------
-- Procedure            : Generate_PWP_Notify_Page                            -
-- Purpose              : Function for Generating the webpage.                -
-- Note                 : To Generate the content of Notification Mail        -
-- Assumptions          : None                                                -
-- Parameters                   Type         Required  Description and Purpose-
-- ---------------------------  ------       --------  ------------------------
-- p_item_type                  VARCHAR2     YES       Itemtype for workflow  -
-- p_item_Key                   VARCHAR2     YES       ItemKey for workflow   -
-- p_inv_info_rec               c_inv_info   YES       Data to Prepare Page   -
-- p_proj_info_rec              c_proj_info  YES       Data to Prepare Page   -
-------------------------------------------------------------------------------

Procedure Generate_PWP_Notify_Page (p_item_type     IN  VARCHAR2
                                   ,p_item_Key      IN  VARCHAR2
                                   ,p_inv_info_rec  IN  c_inv_info%ROWTYPE
                                   ,p_proj_info_rec IN  c_proj_info%ROWTYPE
                                   ,x_content_id    OUT NOCOPY NUMBER)
IS

CURSOR c_linked_invoice (l_project_id    NUMBER
                        ,l_draft_inv_num NUMBER)
IS
SELECT  ap_inv.invoice_num          invoice_number
       ,to_char(NVL(linked_inv.invoice_amount,0),fnd_currency.GET_FORMAT_MASK(linked_inv.proj_currency_code, 20))   invoice_amount
       ,ap_inv.invoice_date         invoice_date
       ,po_vend.vendor_name         supplier_name
FROM    (
            SELECT    ap_invoice_id             Invoice_id
                     ,ei.project_currency_code     proj_currency_code
                     ,SUM(ei.raw_cost)          Invoice_Amount
              FROM    pa_pwp_linked_invoices    pwp
                     ,pa_expenditure_items      ei
             WHERE    pwp.ap_invoice_id       = ei.document_header_id
               AND    pwp.project_id          = ei.project_id
               AND    pwp.project_id          = l_project_id
               AND    pwp.draft_invoice_num   = l_draft_inv_num
             GROUP BY pwp.ap_invoice_id
                     ,ei.project_currency_code
             UNION ALL
            SELECT   DISTINCT ei.document_header_id Invoice_Id
                    ,ei.project_currency_code     proj_currency_code
                    ,SUM(ei.raw_cost)               Invoice_Amount
              FROM   pa_draft_invoices              pdi
                    ,pa_draft_invoice_items         pdii
                    ,pa_cust_rev_dist_lines         crdl
                    ,pa_expenditure_items           ei
             WHERE   pdi.project_id               = pdii.project_id
               AND   pdi.draft_invoice_num        = pdii.draft_invoice_num
               AND   pdii.project_id              = crdl.project_id
               AND   pdii.draft_invoice_num       = crdl.draft_invoice_num
               AND   pdii.line_num                = crdl.draft_invoice_item_line_num
               AND   crdl.expenditure_item_id     = ei.expenditure_item_id
               AND   ei.document_header_id IS NOT NULL
               AND   ei.system_linkage_function   = 'VI'
               AND   pdi.project_id               = l_project_id
               AND   pdi.draft_invoice_num        = l_draft_inv_num
             GROUP BY ei.document_header_id
                     ,ei.project_currency_code
        ) linked_inv
        ,ap_invoices     ap_inv
        ,po_vendors      po_vend
WHERE     linked_inv.invoice_id = ap_inv.invoice_id
  AND   ap_inv.vendor_id      = po_vend.vendor_id
  AND  EXISTS (Select 1
                 from ap_holds h
                where h.invoice_id = ap_inv.invoice_id
                  and release_reason is not null
                  and hold_lookup_code in ('PO Deliverable', 'Pay When Paid')
            );

CURSOR  c_orgz_info ( p_carrying_out_organization_id NUMBER )
IS
SELECT  name   Organization_Name
  FROM  hr_organization_units
 WHERE  organization_id = p_carrying_out_organization_id;

l_orgz_info_rec         c_orgz_info%ROWTYPE;
l_proj_manager_rec      c_proj_manager%ROWTYPE;
l_manager_rec           c_manager%ROWTYPE;
l_linked_inv_rec        c_linked_invoice%ROWTYPE;

l_clob                      clob;
l_text                      VARCHAR2(32767);
l_index                     NUMBER;
x_return_status             VARCHAR2(1);
x_msg_count                 NUMBER;
x_msg_data                  VARCHAR2(250);
l_err_code                  NUMBER:= 0;
l_err_stack                 VARCHAR2(630);
l_err_stage                 VARCHAR2(80);
l_page_content_id           Number:=0;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    log_message('Generate_PWP_Notify_Page: START (AUTONOMOUS_TRANSACTION)', 3);

    OPEN  c_orgz_info( p_proj_info_rec.Organization_Id );
    FETCH c_orgz_info INTO l_orgz_info_rec;
    IF c_orgz_info%ISOPEN THEN
        CLOSE c_orgz_info;
    END IF;

    OPEN c_proj_manager(p_proj_info_rec.project_id);
    FETCH c_proj_manager INTO l_proj_manager_rec;


    IF (c_proj_manager%FOUND)    THEN
        OPEN c_manager(  l_proj_manager_rec.manager_employee_id );
        FETCH c_manager INTO l_manager_rec;
        IF c_manager%ISOPEN THEN
            CLOSE c_manager;
        END IF;
    END IF;

    IF c_proj_manager%ISOPEN THEN
        CLOSE c_proj_manager;
    END IF;

    x_content_id := 0;

    log_message('Generate_PWP_Notify_Page: Before Calling CREATE_PAGE_CONTENTS: p_inv_info_rec.ra_id=' || p_inv_info_rec.ra_id || '*', 3);
    PA_PAGE_CONTENTS_PUB.CREATE_PAGE_CONTENTS(p_init_msg_list   => fnd_api.g_false
                                             ,p_validate_only   => fnd_api.g_false
                                             ,p_object_type     => 'PA_PWP_AR_NOTIFY'
                                             ,p_pk1_value       => p_inv_info_rec.ra_id
                                             ,p_pk2_value       => NULL
                                             ,x_page_content_id => l_page_content_id
                                             ,x_return_status   => x_return_status
                                             ,x_msg_count       => x_msg_count
                                             ,x_msg_data        => x_msg_data
    );
    log_message('Generate_PWP_Notify_Page: After Calling CREATE_PAGE_CONTENTS: x_return_status=' || x_return_status || '*', 3);

    x_content_id := l_page_content_id;

    BEGIN
        --create notification page
        SELECT page_content
          INTO l_clob
          FROM pa_page_contents
         WHERE page_content_id = l_page_content_id FOR UPDATE NOWAIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        log_message('Generate_PWP_Notify_Page: Failed to Select CLOB with: l_page_content_id=' || l_page_content_id || '*', 5);
        RAISE;
    END;

    l_text := '';

    --Starting the page content
    l_text :=  '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td>';
        APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- START : Project Information Section
    l_text :=  '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
        APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Heading
    l_text :=  '<tr><td height="12"><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);">';
    l_text := l_text || '<tr><td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
    l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Project Information</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '<tr><td height="8" bgcolor="#EAEFF5"></td></tr><tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project name
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Name</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td>';
    l_text := l_text || '</tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project Number
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_number || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Organization
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Organization</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_orgz_info_rec.organization_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --project type
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Type</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_type || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project Manager
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Manager';
    l_text := l_text || '</font></td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_manager_rec.full_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="5" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --project start date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Start Date</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.start_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project finish date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Finish Date</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_proj_info_rec.end_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- project status
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Status</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_status || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --l_text :=  '</table></td></tr></table></td></tr></table></td></tr></table>';
    l_text :=  '</table></td></tr></table></td></tr></table></td></tr><tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- END : Project Information Section

    --START : Receipt and Invoice Information Section
    l_text :=  '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Heading
    l_text :=  '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);"><tr>';
    l_text := l_text || '<td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px solid #aabed5">';
    l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Receipt and AR Invoice Details</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '<tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Receipt num
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Receipt Number</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_inv_info_rec.receipt_number || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Receipt date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Receipt Date</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_inv_info_rec.receipt_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Receipt amt
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Receipt Amount</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_inv_info_rec.receipt_amount || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Applied amt
    l_text := '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Applied Amount</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_inv_info_rec.amount_applied || '</b></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- Receipt Currency
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Receipt Currency</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_inv_info_rec.receipt_currency_code || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);


    l_text :=  '</table></td><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- Inv num
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">AR Invoice Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_inv_info_rec.ar_invoice_no || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    l_text := l_text || '<tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Inv Date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Invoice Date</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_inv_info_rec.ar_invoice_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr>';
    l_text := l_text || '<td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Inv amt
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Invoice Amount</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_inv_info_rec.ar_invoice_amount || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Inv Currency
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">AR Invoice Currency</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_inv_info_rec.ar_invoice_currency_code || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --This cell is Empty
    l_text :=  '<tr><td height="3"></td><td></td><td></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td></tr></table></td></tr></table></td></tr><tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
    --END : Receipt and Invoice Information Section

    log_message('Generate_PWP_Notify_Page: Done Generating Project and Receipt Section: l_page_content_id=' || l_page_content_id || '*', 3);

    OPEN c_linked_invoice( p_proj_info_rec.project_id, p_inv_info_rec.draft_invoice_number );
    FETCH c_linked_invoice INTO l_linked_inv_rec;
    --Check if there are linked SupplierInvoices
    IF c_linked_invoice%FOUND THEN
        -- Check if Invoice is FULLY PAID
        IF p_inv_info_rec.invoice_status = 'OP' THEN
            --START : Invoices on HOLD Section
            l_text := '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td><table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr>';
            l_text := l_text || '<td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr><tr><td>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            --heading
            l_text := '<table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);"><tr>';
            l_text := l_text || '<td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
            l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Supplier Invoices on Payment Hold</b></font></h2></td></tr></table>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '</td></tr><tr><td><div><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td height="8" bgcolor="#EAEFF5"></td></tr><tr><td>';
            l_text := l_text || '<table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5"><table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%">';
            l_text := l_text || '</td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            -- Text
            l_text := '<tr><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
            l_text := l_text || 'The following Supplier Invoices are linked to the AR Invoices given above. These Supplier Invoices are on Payment Hold due to partial payment of AR Invoice.';
            l_text := l_text || '</font></td></tr>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<tr><td height="8"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr><tr><td height="3"></td><td></td><td></td></tr><tr>';
            l_text := l_text || '<td align="center" valign="top" width="100%"><table cellpadding="0" cellspacing="0" border="0" width="75%"><tr><td><table cellpadding="1" cellspacing="0" ';
            l_text := l_text || 'border="0" width="100%" style="BORDER-COLLAPSE: collapse">';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            --Header Row of table
            l_text := '<tr><th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="left" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Supplier Name</span></b></font></th>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="left" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Invoice Number</span></b></font></th>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="left" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Invoice Date</span></b></font></th>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="right" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Invoice Amount</span></b></font></th></tr>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            WHILE c_linked_invoice%FOUND
            LOOP
                --Supplier Name
                l_text := '<tr><td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
                l_text := l_text || '<span>' || l_linked_inv_rec.supplier_name || '</span></font></td>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                --Invoice Number
                l_text := '<td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
                l_text := l_text || '<span>' || l_linked_inv_rec.invoice_number || '</span></font></td>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                -- Invoice Date
                l_text := '<td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
                l_text := l_text || '<span>' || l_linked_inv_rec.invoice_date || '</span></font></td>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                --Invoice Amount
                l_text := '<td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" align="right" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
                l_text := l_text || 'color="#000000" size="2"><span>' || l_linked_inv_rec.invoice_amount || '</span></font></td></tr>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                FETCH c_linked_invoice INTO l_linked_inv_rec;
            END LOOP;

            l_text := '</table></td></tr></table></td></tr><tr><td height="8"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr></table></td></tr></table></td></tr>';
            l_text := l_text || '</table></td></tr></table></td></tr></table></td></tr><tr><td height="8"  bgcolor="#EAEFF5"></td></tr></table>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
            --END : Invoices on HOLD Section

        ELSE

            --START : Invoices on ready for release Section
            l_text := '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td><table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr>';
            l_text := l_text || '<td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr><tr><td>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            --heading
            l_text := '<table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);"><tr>';
            l_text := l_text || '<td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
            l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Supplier Invoices Available for Payment Release</b></font></h2></td></tr></table>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '</td></tr><tr><td><div><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td>';
            l_text := l_text || '<table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5"><table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%">';
            l_text := l_text || '</td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            -- Text
            l_text := '<tr><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
            l_text := l_text || 'The following Supplier Invoices are linked to the AR Invoices given above. These Supplier Invoices can be released for Processing of Payment.';
            l_text := l_text || '</font></td></tr>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<tr><td height="8"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr><tr><td height="3"></td><td></td><td></td></tr><tr>';
            l_text := l_text || '<td align="center" valign="top" width="100%"><table cellpadding="0" cellspacing="0" border="0" width="75%"><tr><td>';
            l_text := l_text || '<table cellpadding="1" cellspacing="0" border="0" width="100%" style="BORDER-COLLAPSE: collapse">';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            --Header Row of table
            l_text := '<tr><th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="left" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Supplier Name</span></b></font></th>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="left" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Invoice Number</span></b></font></th>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="left" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Invoice Date</span></b></font></th>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            l_text := '<th style="BORDER-LEFT: #f2f2f5 1px solid" valign="bottom" align="right" bgcolor="#CFE0F1" scope="col">';
            l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b><span bgcolor="#CFE0F1">Invoice Amount</span></b></font></th></tr>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

            WHILE c_linked_invoice%FOUND
            LOOP

                --Supplier Name
                l_text := '<tr><td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
                l_text := l_text || '<span>' || l_linked_inv_rec.supplier_name || '</span></font></td>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                --Invoice Number
                l_text := '<td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
                l_text := l_text || '<span>' || l_linked_inv_rec.invoice_number || '</span></font></td>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                -- Invoice Date
                l_text := '<td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
                l_text := l_text || '<span>' || l_linked_inv_rec.invoice_date || '</span></font></td>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                --Invoice Amount
                l_text := '<td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" ';
                l_text := l_text || 'valign="baseline" align="right" nowrap="nowrap" bgcolor="#F2F2F5"><font class="OraTableCellText" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
                l_text := l_text || 'color="#000000" size="2"><span>' || l_linked_inv_rec.invoice_amount || '</span></font></td></tr>';
                APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

                FETCH c_linked_invoice INTO l_linked_inv_rec;
            END LOOP;

            l_text := '</table></td></tr></table></td></tr><tr><td height="8"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr></table></td></tr></table>';
            l_text := l_text || '</td></tr></table></td></tr><tr><td height="8" bgcolor="#EAEFF5"></td></tr></table></td></tr></table></td></tr></table>';
            APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
            --END : Invoices on ready for release Section

        END IF; -- Invoice Status
    END IF; -- Linked Invoices

    --START : References Section
    l_text := '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Header
    l_text := '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);">';
    l_text := l_text || '<tr><td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
    l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>References</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --URL Section
    l_text := '<tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td> <div><div><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr>';
    l_text := l_text || '<td bgcolor="#EAEFF5"><table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td>';
    l_text := l_text || '<td valign="top"><table border="0" cellspacing="0" cellpadding="0"><tr><td align="right" valign="top" nowrap="nowrap"><span align="right">';
    l_text := l_text || '<img src="/OA_MEDIA/fwkhp_formsfunc.gif" alt="Open Supplier Summary" width="16" height="16" border="0"></span></td><td width="12">';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
    l_text := l_text || '<a href="OA.jsp?page=/oracle/apps/pa/subcontractor/webui/SubContractSummPG&_ri=275&addBreadCrumb=RS&paProjectId=' || p_proj_info_rec.project_id || '">Open Supplier Summary </a>';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="5" /></font></td></tr><tr>';
    l_text := l_text || '<td height="3"></td><td></td><td></td></tr></table></tr></table></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text := '<tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
    --END : References Section

    --Closing the page content
    l_text :=  '</td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    log_message('Generate_PWP_Notify_Page: Page generation Done...', 3);

    COMMIT;
    l_text := '';

    log_message('Generate_PWP_Notify_Page: Normal Exit', 3);
EXCEPTION
    WHEN OTHERS THEN
    log_message('Generate_PWP_Notify_Page: Exit With Error', 5);
    RAISE;
END Generate_PWP_Notify_Page;



-------------------------------------------------------------------------------
-- Procedure            : Select_Project_Manager                              -
-- Purpose              : Select Project Manger, will be called from Wf.      -
-- Note                 : Select Project Manger, will be called from Wf.      -
-- Assumptions          : None                                                -
-- Parameters                   Type         Required  Description and Purpose-
-- ---------------------------  ------       --------  ------------------------
-- p_item_type                  VARCHAR2     YES       Itemtype for workflow  -
-- p_item_Key                   VARCHAR2     YES       ItemKey for workflow   -
-- actid                        NUMBER       YES       Activity Id of workflow-
-- funcmode                     VARCHAR2     YES       func call Mode of WF   -
-- resultout                    VARCHAR2     YES       Execution result for WF-
-------------------------------------------------------------------------------

PROCEDURE Select_Project_Manager (itemtype    IN VARCHAR2
                                 ,itemkey     IN VARCHAR2
                                 ,actid       IN NUMBER
                                 ,funcmode    IN VARCHAR2
                                 ,resultout   OUT NOCOPY VARCHAR2)
IS

l_err_code                  NUMBER := 0;
l_resp_id                   NUMBER;
l_project_id                NUMBER;
l_workflow_started_by_id    NUMBER;
l_manager_employee_id       NUMBER;
l_manager_user_id           NUMBER;
l_manager_user_name         VARCHAR2(240);
l_manager_full_name         VARCHAR2(400);
l_return_status             NUMBER := 0;
l_project_manager_id        NUMBER := 0;

BEGIN
    --
    -- Return if WF Not Running
    --
    IF (funcmode <> wf_engine.eng_run) THEN
        resultout := wf_engine.eng_null;
        RETURN;
    END IF;

    l_resp_id                  := wf_engine.GetItemAttrNumber(itemtype   => itemtype
                                                           ,Itemkey    => itemkey
                                                           ,aname      => 'RESPONSIBILITY_ID' );

    l_project_id              := wf_engine.GetItemAttrNumber(itemtype    => itemtype
                                                           ,itemkey     => itemkey
                                                           ,aname       => 'PROJECT_ID' );

    l_workflow_started_by_id := wf_engine.GetItemAttrNumber(itemtype      => itemtype
                                                           ,itemkey      => itemkey
                                                           ,aname         => 'WORKFLOW_STARTED_BY_ID' );

    -- Based on the Responsibility, Intialize the Application
    PA_WORKFLOW_UTILS.Set_Global_Attr (p_item_type => itemtype
                                      ,p_item_key  => itemkey
                                      ,p_err_code  => l_err_code);


    PA_CE_AR_NOTIFY_WF.Select_Project_Manager (p_project_id               => l_project_id
                                              ,p_project_manager_id       => l_manager_employee_id
                                              ,p_return_status            => l_return_status);

    IF ( l_return_status = 0 ) THEN
        OPEN  c_proj_manager(l_project_id);
        FETCH c_proj_manager INTO l_manager_employee_id;
        IF c_proj_manager%ISOPEN THEN
            CLOSE c_proj_manager;
        END IF;
    END IF;


    IF (l_manager_employee_id IS NOT NULL )    THEN

        OPEN c_manager( l_manager_employee_id );
        FETCH c_manager INTO l_manager_user_id
                            ,l_manager_user_name
                            ,l_manager_full_name;

        IF (c_manager%FOUND) THEN
            IF c_manager%ISOPEN THEN
                CLOSE c_manager;
            END IF;
            wf_engine.SetItemAttrNumber (itemtype => itemtype
                                        ,itemkey  => itemkey
                                        ,aname    => 'PROJECT_MANAGER_ID'
                                        ,avalue   => l_manager_user_id );
            wf_engine.SetItemAttrText  (itemtype  => itemtype
                                       ,itemkey   => itemkey
                                       ,aname     => 'PROJECT_MANAGER_NAME'
                                       ,avalue    =>  l_manager_user_name);
            wf_engine.SetItemAttrText  (itemtype  => itemtype
                                       ,itemkey   => itemkey
                                       ,aname     => 'PROJECT_MANAGER_FULL_NAME'
                                       ,avalue    =>  l_manager_full_name);

            resultout := wf_engine.eng_completed||':'||'T';
        ELSE
            IF c_manager%ISOPEN THEN
                CLOSE c_manager;
            END IF;
            resultout := wf_engine.eng_completed||':'||'F';
        END IF;
    ELSE
        resultout := wf_engine.eng_completed||':'||'F';
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_PWP_NOTIFICATION','SELECT_PROJECT_MANAGER',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_PWP_NOTIFICATION','SELECT_PROJECT_MANAGER',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_PWP_NOTIFICATION','SELECT_PROJECT_MANAGER',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
END Select_Project_Manager;


-------------------------------------------------------------------------------
-- Procedure            : SHOW_PWP_NOTIFY_PREVIEW                             -
-- Purpose              : Fetch the mail document, will be called from Wf.    -
-- Note                 : Fetch the mail document, will be called from Wf.    -
-- Assumptions          : None                                                -
-- Parameters                   Type         Required  Description and Purpose-
-- ---------------------------  ------       --------  ------------------------
-- document_id                  VARCHAR2     YES       Document Id            -
-- display_type                 VARCHAR2     YES       Display type text/html -
-- document                     CLOB         YES       Document Content       -
-- document_type                VARCHAR2     YES       Document type text/html-
-------------------------------------------------------------------------------

PROCEDURE SHOW_PWP_NOTIFY_PREVIEW(document_id      IN VARCHAR2
                                 ,display_type     IN VARCHAR2
                                 ,document         IN OUT NOCOPY CLOB
                                 ,document_type    IN OUT NOCOPY VARCHAR2)
IS

l_content CLOB;

CURSOR c_pwp_preview_info IS
SELECT page_content
  FROM PA_PAGE_CONTENTS
 WHERE page_content_id = document_id
   AND object_type = 'PA_PWP_AR_NOTIFY'
   AND pk2_value IS NULL;

l_size             number;
l_chunk_size      PLS_INTEGER:=10000;
l_copy_size     INT;
l_pos             INT := 0;
l_line             VARCHAR2(30000) := '';
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);


BEGIN

OPEN c_pwp_preview_info;
FETCH c_pwp_preview_info INTO l_content;
IF (c_pwp_preview_info%FOUND) THEN
    IF c_pwp_preview_info%ISOPEN THEN
        CLOSE c_pwp_preview_info;
    END IF;
    l_size := dbms_lob.getlength(l_content);
    l_pos := 1;
    l_copy_size := 0;
    WHILE (l_copy_size < l_size) LOOP
        dbms_lob.READ(l_content,l_chunk_size,l_pos,l_line);
        dbms_lob.WRITE(document,l_chunk_size,l_pos,l_line);
        l_copy_size := l_copy_size + l_chunk_size;
        l_pos := l_pos + l_chunk_size;
    END LOOP;

    pa_workflow_utils.modify_wf_clob_content(p_document       =>  document
                                            ,x_return_status  =>  l_return_status
                                            ,x_msg_count      =>  l_msg_count
                                            ,x_msg_data       =>  l_msg_data);

    IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
        WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
        dbms_lob.writeappend(document, 255, SUBSTR(SQLERRM, 255));
    END IF;
ELSE
    IF c_pwp_preview_info%ISOPEN THEN
        CLOSE c_pwp_preview_info;
    END IF;
END IF;

document_type := 'text/html';

EXCEPTION
    WHEN OTHERS THEN
      WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
      dbms_lob.writeappend(document, 255, substrb(Sqlerrm, 255));
    NULL;
END SHOW_PWP_NOTIFY_PREVIEW;



-------------------------------------------------------------------------------
-- Procedure            : APPEND_VARCHAR_TO_CLOB                              -
-- Purpose              : Append generated content to CLOB                    -
-- Note                 : Append generated content to CLOB                    -
-- Assumptions          : None                                                -
-- Parameters                   Type         Required  Description and Purpose-
-- ---------------------------  ------       --------  ------------------------
-- p_varchar                    VARCHAR2     YES       Content to append      -
-- p_clob                       CLOB         YES       CLOB                   -
-------------------------------------------------------------------------------

PROCEDURE APPEND_VARCHAR_TO_CLOB(p_varchar IN varchar2
                                ,p_clob    IN OUT NOCOPY CLOB)
IS
l_chunkSize   INTEGER;
v_offset      INTEGER := 0;
l_clob        clob;
l_length      INTEGER;

v_size        NUMBER;
v_text        VARCHAR2(3000);
BEGIN
l_chunksize := length(p_varchar);
l_length := dbms_lob.getlength(p_clob);

dbms_lob.write(p_clob
              ,l_chunksize
              ,l_length+1
              ,p_varchar);
v_size := 1000;
dbms_lob.read(p_clob, v_size, 1, v_text);
END APPEND_VARCHAR_TO_CLOB;
------------------------------

END PA_PWP_NOTIFICATION;

/
