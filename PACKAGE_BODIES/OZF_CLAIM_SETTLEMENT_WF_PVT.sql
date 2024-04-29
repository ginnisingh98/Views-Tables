--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_SETTLEMENT_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_SETTLEMENT_WF_PVT" AS
/* $Header: ozfvcwfb.pls 120.2 2006/05/15 01:01 azahmed noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_CLAIM_SETTLEMENT_WF_PVT';
G_ITEMTYPE CONSTANT varchar2(30) := 'OZF_CSTL';




---------------------------------------------------------------------------------
-- PROCEDURE
--   Get_User_Role
--
-- PURPOSE
--   This Procedure will be return the User role for the userid sent Called By
--
-- NOTES
--
---------------------------------------------------------------------------------
PROCEDURE Get_User_Role(
    p_user_id               IN      NUMBER,
    x_role_name             OUT NOCOPY     VARCHAR2,
    x_role_display_name     OUT NOCOPY     VARCHAR2
)
IS
-- Modified for Bugfix 5199354
CURSOR c_resource IS
  select  ppl.person_id source_id
  from jtf_rs_resource_extns rsc , per_people_f ppl
  where rsc.category = 'EMPLOYEE' and ppl.person_id = rsc.source_id
  and trunc(sysdate) between ppl.effective_start_date and ppl.effective_end_date
  and rsc.resource_id = p_user_id;


l_person_id        NUMBER;

BEGIN
  OPEN c_resource ;
  FETCH c_resource INTO l_person_id ;
  IF c_resource%NOTFOUND THEN
    FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT', sqlerrm );
    FND_MSG_PUB.Add;
  END IF;
  CLOSE c_resource ;
    -- Pass the Employee ID to get the Role
    WF_DIRECTORY.getrolename(
         p_orig_system       => 'PER',
         p_orig_system_id    => l_person_id ,
         p_name              => x_role_name,
         p_display_name      => x_role_display_name
    );
END Get_User_Role;



--------------------------------------------------------------------------------
-- PROCEDURE
--   Prepare_Docs
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:SUCCESS'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_COMPLETE_DOC
--
-- HISTORY
--------------------------------------------------------------------------------
PROCEDURE Prepare_Docs(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS

l_setl_doc_counter     NUMBER;
l_claim_id             NUMBER;
l_msg_data             VARCHAR2(4000);
l_error_msg            VARCHAR2(4000);
l_msg_count            NUMBER;
l_return_status        VARCHAR2(1);

BEGIN

  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- Transaction Identifier

    l_setl_doc_counter := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'OZF_SETL_DOC_COUNTER'
                                                     );

    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );

    -- Customization Hint: setl_doc_counter is incremented as many times
    -- as it passes through the loop. You can use the value to create
    -- different types of payment documents
    IF l_setl_doc_counter = 1 THEN
         NULL;
    ELSIF l_setl_doc_counter = 2 THEN
         NULL;
    END IF;

    resultout := 'COMPLETE:SUCCESS';
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     OZF_AR_SETTLEMENT_PVT.Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'Prepare_Docs'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_CLAIM_SETTLEMENT_WF_PVT'
        ,'Prepare_Docs'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     resultout := 'COMPLETE:ERROR';
     RETURN;

  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Prepare_Docs',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Prepare_Docs;


------------------------------------------------------------------------------
-- PROCEDURE
--   Check_Auto_Setl_Process
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:YES'
--             - 'COMPLETE:NO'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>                    <ACTIVITY>
--   OZF_CLAIM_SETTLEMENT_WF_PVT    OZF_ADHOC_SETL_AUTOMATION
---------------------------------------------------------------------------------
PROCEDURE Check_Adhoc_Setl_Automation(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_automate_settlement VARCHAR2(1);
l_claim_class         VARCHAR2(30);
l_setl_proc_type      VARCHAR2(15);
l_setl_counter        NUMBER;

BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    l_claim_class := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'OZF_CLAIM_CLASS'
                                              );

    l_setl_proc_type := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'OZF_CSETL_TYPE'
                                                 );

    l_setl_counter := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'OZF_SETL_DOC_COUNTER'
                                               );


    -- Customization Hint: Modify condition depending on whether
    -- settlement can be automatic or requires to wait for info
    -- In our case, we will wait for document to be imported to AR
    IF l_setl_counter = 1 THEN
       resultout := 'COMPLETE:N';
    ELSE
       resultout := 'COMPLETE:Y';
    END IF;

    l_setl_counter := l_setl_counter + 1;

    WF_ENGINE.SetItemAttrText( itemtype  => itemtype
                             , itemkey   => itemkey
                             , aname     => 'OZF_SETL_DOC_COUNTER'
                             , avalue    => l_setl_counter
                             );

    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_CLAIM_SETTLEMENT_WF_PVT',
        'Check_Adhoc_Setl_Automation',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Check_Adhoc_Setl_Automation;


------------------------------------------------------------------------------
-- PROCEDURE
--   Check_Auto_Setl_Process
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:YES'
--             - 'COMPLETE:NO'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>                    <ACTIVITY>
--   OZF_CLAIM_SETTLEMENT_WF_PVT    OZF_ADHOC_SETL_RECEIVED
---------------------------------------------------------------------------------
PROCEDURE Fetch_Adhoc_Setl_Doc(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_automate_settlement VARCHAR2(1);
l_claim_class         VARCHAR2(30);
l_setl_proc_type      VARCHAR2(15);
l_claim_id            NUMBER;
l_claim_number        VARCHAR2(30);
l_setl_counter        NUMBER;

CURSOR csr_ar_settlement( cv_claim_number IN VARCHAR2) IS
  SELECT cust.customer_trx_id       --"settlement_id"
  , cust.cust_trx_type_id           --"settlement_type_id"
  , cust.trx_number                 --"settlement_number"
  , cust.trx_date                   --"settlement_date"
  , pay.amount_due_original       --"settlement_amount"
  , pay.status                      --"status_code"
  FROM ra_customer_trx cust
  , ar_payment_schedules pay
  WHERE cust.complete_flag = 'Y'
  AND cust.customer_trx_id = pay.customer_trx_id
  AND cust.interface_header_attribute1 = cv_claim_number;

  l_ar_setl_doc    csr_ar_settlement%ROWTYPE;


BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN

    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );

    l_claim_number := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'OZF_CLAIM_NUMBER'
                                               );

    -- Customization Hint: Modify cursor to fetch payment doc info
    OPEN  csr_ar_settlement( l_claim_number);
    FETCH csr_ar_settlement INTO l_ar_setl_doc;
    CLOSE csr_ar_settlement;

    IF l_ar_setl_doc.customer_trx_id IS NULL THEN
       resultout := 'COMPLETE:N';
    ELSE

       WF_ENGINE.SetItemAttrNumber( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'OZF_TRX_ID_1',
                                    avalue    => l_ar_setl_doc.customer_trx_id
                                  );
       -- Transaction Type
       WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                  itemkey   => itemkey,
                                  aname     => 'OZF_TRX_TYPE_1',
                                  avalue    => 'CM'
                                );
       -- Transaction Number
       WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                  itemkey   => itemkey,
                                  aname     => 'OZF_TRX_NUMBER_1',
                                  avalue    => l_ar_setl_doc.trx_number
                                );
       -- Transaction Date
       WF_ENGINE.SetItemAttrDate( itemtype  => itemtype,
                                  itemkey   => itemkey,
                                  aname     => 'OZF_TRX_DATE_1',
                                  avalue    => l_ar_setl_doc.trx_date
                                );
       -- Transaction Amount
       WF_ENGINE.SetItemAttrNumber( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'OZF_TRX_AMOUNT_1',
                                    avalue    => l_ar_setl_doc.amount_due_original
                                  );
       -- Transaction Status
       WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                  itemkey   => itemkey,
                                  aname     => 'OZF_TRX_STATUS_1',
                                  avalue    => l_ar_setl_doc.status
                                );

       resultout := 'COMPLETE:Y';
    END IF;

    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_CLAIM_SETTLEMENT_WF_PVT',
        'Fetch_Adhoc_Setl_Doc',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Fetch_Adhoc_Setl_Doc;


END OZF_CLAIM_SETTLEMENT_WF_PVT;

/
