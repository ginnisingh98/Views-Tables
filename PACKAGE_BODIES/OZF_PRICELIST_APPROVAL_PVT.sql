--------------------------------------------------------
--  DDL for Package Body OZF_PRICELIST_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PRICELIST_APPROVAL_PVT" AS
/* $Header: ozfvplwb.pls 120.0 2005/06/01 03:08:24 appldev noship $ */

g_pkg_name     CONSTANT VARCHAR2(30) := 'OZF_PRICELIST_APPROVAL_PVT';
g_file_name    CONSTANT VARCHAR2(15) := 'ozfvplwb.pls';

--------------------------------------------------------------------------
-- PROCEDURE
--   notify_requestor_fyi
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   08/20/2001  julou  created
--------------------------------------------------------------------------
PROCEDURE notify_requestor_fyi(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name            VARCHAR2(100)    := g_pkg_name || 'Notify_Requestor_FYI';
l_hyphen_pos1         NUMBER;
l_fyi_notification    VARCHAR2(10000);
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3500);

l_list_header_id      NUMBER;
l_name                VARCHAR2(240);
l_setup_id            NUMBER;
l_start_date          DATE;
l_end_date            DATE;
l_currency            VARCHAR2(30);
l_description         VARCHAR2(2000);
l_owner_id            NUMBER;
l_status_name         VARCHAR2(4000);
l_status_date         DATE;

CURSOR c_pricelist_rec(p_list_header_id IN NUMBER) IS
    SELECT   name
    ,        custom_setup_id
    ,        start_date_active
    ,        end_date_active
    ,        description
    ,        owner_id
    ,        currency_code
    ,        user_status_name
    ,        status_date
    FROM ozf_price_lists_v
    WHERE list_header_id = p_list_header_id;

BEGIN
  ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_list_header_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_APPROVER'
                );

  OPEN c_pricelist_rec(l_list_header_id);
  FETCH c_pricelist_rec INTO l_name
                       , l_setup_id
                       , l_start_date
                       , l_end_date
                       , l_description
                       , l_owner_id
                       , l_currency
                       , l_status_name
                       , l_status_date;
  CLOSE c_pricelist_rec;

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_FORWARD_SUBJ');
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'FYI_SUBJECT'
    ,avalue   => l_subject
  );

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_FORWARD_INFO');
  fnd_message.set_token('APPROVER_NAME', l_approver, false);
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  fnd_message.set_token('START_DATE', l_start_date, false);
  fnd_message.set_token('END_DATE', l_end_date, false);
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('DESCRIPTION', l_description, false);

  l_body := fnd_message.get;
  l_fyi_notification := l_body;
  document := document || l_fyi_notification;
  document_type := 'text/plain';
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
     wf_core.context( 'OZFGAPP'
                    , 'Notify_requestor_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_requestor_fyi;


--------------------------------------------------------------------------
-- PROCEDURE
--   notify_approval_required
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
--
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE notify_approval_required(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name            VARCHAR2(100)   := g_pkg_name || 'notify_approval_required';
l_hyphen_pos1         NUMBER;
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3500);
l_requester           VARCHAR2(30);

l_list_header_id      NUMBER;
l_name                VARCHAR2(240);
l_setup_id            NUMBER;
l_start_date          DATE;
l_end_date            DATE;
l_currency            VARCHAR2(30);
l_description         VARCHAR2(2000);
l_owner_id            NUMBER;
l_status_name         VARCHAR2(4000);
l_status_date         DATE;

CURSOR c_pricelist_rec(p_list_header_id IN NUMBER) IS
    SELECT   name
    ,        custom_setup_id
    ,        start_date_active
    ,        end_date_active
    ,        description
    ,        owner_id
    ,        currency_code
    ,        user_status_name
    ,        status_date
    FROM ozf_price_lists_v
    WHERE list_header_id = p_list_header_id;

BEGIN
  ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);
  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_list_header_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_requester := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey => l_item_key
                   ,aname => 'AMS_REQUESTER'
                 );

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_APPROVER'
                );

  OPEN c_pricelist_rec(l_list_header_id);
  FETCH c_pricelist_rec INTO l_name
                       , l_setup_id
                       , l_start_date
                       , l_end_date
                       , l_description
                       , l_owner_id
                       , l_currency
                       , l_status_name
                       , l_status_date;
  CLOSE c_pricelist_rec;

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPROVAL_SUBJ');
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'APP_SUBJECT'
    ,avalue   => l_subject
  );

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPROVAL_INFO');
  fnd_message.set_token('REQUESTER', l_requester, false);
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  fnd_message.set_token('START_DATE', l_start_date, false);
  fnd_message.set_token('END_DATE', l_end_date, false);
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('DESCRIPTION', l_description, false);
  l_body := fnd_message.get;

  document := document || l_body;
  document_type := 'text/plain';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
     wf_core.context( 'OZFGAPP'
                    , 'Notify_requestor_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_approval_required;


--------------------------------------------------------------------------
-- PROCEDURE
--   notify_appr_req_reminder
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE notify_appr_req_reminder(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name               VARCHAR2(100)   := g_pkg_name || 'notify_appr_req_reminder';
l_hyphen_pos1         NUMBER;
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3500);
l_requester           VARCHAR2(30);

l_list_header_id      NUMBER;
l_name                VARCHAR2(240);
l_setup_id            NUMBER;
l_start_date          DATE;
l_end_date            DATE;
l_currency            VARCHAR2(30);
l_description         VARCHAR2(2000);
l_owner_id            NUMBER;
l_status_name         VARCHAR2(4000);
l_status_date         DATE;

CURSOR c_pricelist_rec(p_list_header_id IN NUMBER) IS
    SELECT   name
    ,        custom_setup_id
    ,        start_date_active
    ,        end_date_active
    ,        description
    ,        owner_id
    ,        currency_code
    ,        user_status_name
    ,        status_date
    FROM ozf_price_lists_v
    WHERE list_header_id = p_list_header_id;

BEGIN
  ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_list_header_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_requester := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey => l_item_key
                   ,aname => 'AMS_REQUESTER'
                 );

  OPEN c_pricelist_rec(l_list_header_id);
  FETCH c_pricelist_rec INTO l_name
                       , l_setup_id
                       , l_start_date
                       , l_end_date
                       , l_description
                       , l_owner_id
                       , l_currency
                       , l_status_name
                       , l_status_date;
  CLOSE c_pricelist_rec;

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPR_REM_SUBJ');
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'APP_SUBJECT'
    ,avalue   => l_subject
  );

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPR_REM_INFO');
  fnd_message.set_token('REQUESTER', l_requester, false);
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  fnd_message.set_token('START_DATE', l_start_date, false);
  fnd_message.set_token('END_DATE', l_end_date, false);
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('DESCRIPTION', l_description, false);
  l_body := fnd_message.get;

  document := document || l_body;
  document_type := 'text/plain';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
     wf_core.context( 'OZFGAPP'
                    , 'notify_appr_req_reminder'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_appr_req_reminder;


--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of Approval
--
-- PURPOSE
--   Generate the Approval Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   08/20/2001  julou  created
----------------------------------------------------------------------------
PROCEDURE notify_requestor_of_approval(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name            VARCHAR2(100)   := g_pkg_name || 'Notify_Requestor_of_approval';
l_hyphen_pos1         NUMBER;
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3500);
l_requester           VARCHAR2(30);

l_list_header_id      NUMBER;
l_name                VARCHAR2(240);
l_setup_id            NUMBER;
l_start_date          DATE;
l_end_date            DATE;
l_currency            VARCHAR2(30);
l_description         VARCHAR2(2000);
l_owner_id            NUMBER;
l_status_name         VARCHAR2(4000);
l_status_date         DATE;

CURSOR c_pricelist_rec(p_list_header_id IN NUMBER) IS
    SELECT   name
    ,        custom_setup_id
    ,        start_date_active
    ,        end_date_active
    ,        description
    ,        owner_id
    ,        currency_code
    ,        user_status_name
    ,        status_date
    FROM ozf_price_lists_v
    WHERE list_header_id = p_list_header_id;

BEGIN
  ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                         itemtype => l_item_type
                        ,itemkey  => l_item_key
                        ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_list_header_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_approver := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey  => l_item_key
                   ,aname    => 'AMS_APPROVER'
                );

  OPEN c_pricelist_rec(l_list_header_id);
  FETCH c_pricelist_rec INTO l_name
                       , l_setup_id
                       , l_start_date
                       , l_end_date
                       , l_description
                       , l_owner_id
                       , l_currency
                       , l_status_name
                       , l_status_date;
  CLOSE c_pricelist_rec;

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPROVED_SUBJ');
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
      itemtype => l_item_type
     ,itemkey  => l_item_key
     ,aname    => 'APRV_SUBJECT'
     ,avalue   => l_subject
  );

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPROVED_INFO');
  fnd_message.set_token('APPROVER_NAME', l_approver, false);
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  fnd_message.set_token('START_DATE', l_start_date, false);
  fnd_message.set_token('END_DATE', l_end_date, false);
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('DESCRIPTION', l_description, false);
  l_body := fnd_message.get;

  document := document || l_body;
  document_type := 'text/plain';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
     wf_core.context( 'OZFGAPP'
                    , 'notify_requestor_of_approval'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_requestor_of_approval;


--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of rejection
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE notify_requestor_of_rejection(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name            VARCHAR2(100)   := g_pkg_name || 'Notify_Requestor_of_rejection';
l_hyphen_pos1         NUMBER;
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3500);
l_requester           VARCHAR2(30);

l_list_header_id      NUMBER;
l_name                VARCHAR2(240);
l_setup_id            NUMBER;
l_start_date          DATE;
l_end_date            DATE;
l_currency            VARCHAR2(30);
l_description         VARCHAR2(2000);
l_owner_id            NUMBER;
l_status_name         VARCHAR2(4000);
l_status_date         DATE;

CURSOR c_pricelist_rec(p_list_header_id IN NUMBER) IS
    SELECT   name
    ,        custom_setup_id
    ,        start_date_active
    ,        end_date_active
    ,        description
    ,        owner_id
    ,        currency_code
    ,        user_status_name
    ,        status_date
    FROM ozf_price_lists_v
    WHERE list_header_id = p_list_header_id;

BEGIN
  ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_list_header_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_approver := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey => l_item_key
                   ,aname => 'AMS_APPROVER'
                );

  OPEN c_pricelist_rec(l_list_header_id);
  FETCH c_pricelist_rec INTO l_name
                       , l_setup_id
                       , l_start_date
                       , l_end_date
                       , l_description
                       , l_owner_id
                       , l_currency
                       , l_status_name
                       , l_status_date;
  CLOSE c_pricelist_rec;

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_REJECTED_SUBJ');
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'REJECT_SUBJECT'
    ,avalue   => l_subject
  );

  fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_REJECTED_INFO');
  fnd_message.set_token('APPROVER_NAME', l_approver, false);
  fnd_message.set_token('PRICELIST_NAME', l_name, false);
  fnd_message.set_token('START_DATE', l_start_date, false);
  fnd_message.set_token('END_DATE', l_end_date, false);
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('DESCRIPTION', l_description, false);
  l_body := fnd_message.get;

  document := document || l_body;
  document_type := 'text/plain';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
     wf_core.context( 'OZFGAPP'
                    , 'notify_requestor_of_rejection'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_requestor_of_rejection;

---------------------------------------------------------------------
-- PROCEDURE
--   Set_PriceList_Activity_Details
--
-- PURPOSE
--   This Procedure will set all the item attribute details
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE Set_PriceList_Activity_Details(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
)
IS
  l_api_version     CONSTANT NUMBER            := 1.0;
  l_api_name        CONSTANT VARCHAR2(30)      := 'Set_PriceList_Activity_Details';
  l_full_name       CONSTANT VARCHAR2(60)      := g_pkg_name || '.' || l_api_name;

  l_activity_id         NUMBER;
  l_activity_type       VARCHAR2(30)    := 'PRIC';
  l_approval_type       VARCHAR2(30)    := 'CONCEPT';
  l_object_details      ams_gen_approval_pvt.ObjRecTyp;
  l_approval_detail_id  NUMBER;
  l_approver_seq        NUMBER;
  l_return_status       VARCHAR2(1);

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_error_msg           VARCHAR2(4000);
  l_approver            VARCHAR2(30);
  l_subject             VARCHAR2(500);
  l_status_date         DATE;
  l_status_name         VARCHAR2(4000);
  l_lookup_meaning      VARCHAR2(240);

  CURSOR c_pricelist_obj(p_act_id IN NUMBER) IS
    SELECT   name
    ,        custom_setup_id
    ,        'PRIC'
    ,        start_date_active
    ,        end_date_active
    ,        description
    ,        owner_id
    ,        currency_code
    ,        user_status_name
    ,        status_date
    FROM ozf_price_lists_v
    WHERE list_header_id = p_act_id;

BEGIN
  fnd_msg_pub.initialize;

  l_activity_id := wf_engine.getitemattrnumber(
                      itemtype => itemtype
                     ,itemkey  => itemkey
                     ,aname    => 'AMS_ACTIVITY_ID'
                   );

  OPEN c_pricelist_obj(l_activity_id);
  FETCH c_pricelist_obj INTO l_object_details.name
                       , l_object_details.setup_type_id
                       , l_object_details.object_type
                       , l_object_details.start_date
                       , l_object_details.end_date
                       , l_object_details.description
                       , l_object_details.owner_id
                       , l_object_details.currency
                       , l_status_name
                       , l_status_date;
  CLOSE c_pricelist_obj;

  IF (funcmode = 'RUN') THEN
     ams_gen_approval_pvt.get_approval_details(
        p_activity_id        => l_activity_id
       ,p_activity_type      => l_activity_type
       ,p_approval_type      => l_approval_type
       ,p_object_details     => l_object_details
       ,x_approval_detail_id => l_approval_detail_id
       ,x_approver_seq       => l_approver_seq
       ,x_return_status      => l_return_status
     );

     IF l_return_status = fnd_api.g_ret_sts_success THEN
        wf_engine.setitemattrnumber(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMS_APPROVAL_DETAIL_ID'
          ,avalue   => l_approval_detail_id
        );
        wf_engine.setitemattrnumber(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMS_APPROVER_SEQ'
          ,avalue   => l_approver_seq
        );

       fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_FORWARD_SUBJ');
       fnd_message.set_token('PRICELIST_NAME', l_object_details.name, false);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'FYI_SUBJECT'
         ,avalue   => l_subject
       );

       fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPROVAL_SUBJ');
       fnd_message.set_token('PRICELIST_NAME', l_object_details.name, false);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'APP_SUBJECT'
         ,avalue   => l_subject
       );

       fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_APPROVED_SUBJ');
       fnd_message.set_token('PRICELIST_NAME', l_object_details.name, false);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'APRV_SUBJECT'
          ,avalue   => l_subject
       );

       fnd_message.set_name('OZF', 'OZF_PRICLST_NTF_REJECTED_SUBJ');
       fnd_message.set_token('PRICELIST_NAME', l_object_details.name, false);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'REJECT_SUBJECT'
         ,avalue   => l_subject
       );
       -- julou  07/02/2002 added for implementation of BUG 2352621
       l_lookup_meaning := ozf_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER','PRIC');
       wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVAL_OBJECT_MEANING',
               avalue=> l_lookup_meaning
       );

       wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVAL_OBJECT_NAME',
               avalue=> l_object_details.name
       );
       -- End of Addition for Bug 2352621

       resultout := 'COMPLETE:SUCCESS';
     ELSE
        fnd_msg_pub.count_and_get(
           p_encoded   => fnd_api.g_false
          ,p_count     => l_msg_count
          ,p_data      => l_msg_data
        );

        ams_gen_approval_pvt.handle_err(
           p_itemtype  => itemtype
          ,p_itemkey   => itemkey
          ,p_msg_count => l_msg_count
          ,p_msg_data  => l_msg_data
          ,p_attr_name => 'AMS_ERROR_MSG'
          ,x_error_msg => l_error_msg
        );

        wf_core.context(
           'ams_gen_approval_pvt'
          ,'Set_Activity_Details'
          ,itemtype
          ,itemkey
          ,actid
          ,l_error_msg
        );
        -- RAISE FND_API.G_EXC_ERROR;
        resultout := 'COMPLETE:ERROR';
     END IF;
  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;
--

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
     wf_core.context(
        'OZF_PriceList_Approval_PVT'
       ,'Set_PriceList_Activity_Details'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,l_error_msg
     );
     RAISE;
  WHEN OTHERS THEN
     fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false
       ,p_count   => l_msg_count
       ,p_data    => l_msg_data
     );
     RAISE;
END Set_PriceList_Activity_Details;


---------------------------------------------------------------------
-- PROCEDURE
--  Update_PriceList_Status
--
-- PURPOSE
--   This Procedure will update the status
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE Update_PriceList_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
)
IS
  l_api_version     CONSTANT NUMBER            := 1.0;
  l_api_name        CONSTANT VARCHAR2(30)      := 'Update_PriceList_Status';
  l_full_name       CONSTANT VARCHAR2(60)      := g_pkg_name || '.' || l_api_name;
  l_return_status            VARCHAR2(1)       := fnd_api.g_ret_sts_success;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(4000);
  l_error_msg                VARCHAR2(4000);

  l_status_code              VARCHAR2(30);
  l_next_status_id           NUMBER;
  l_approval_status          VARCHAR2(12);
  l_object_version_number    NUMBER;
  l_list_header_id           NUMBER;

BEGIN
  IF funcmode = 'RUN' THEN
    l_approval_status := wf_engine.getitemattrtext(
                           itemtype => itemtype
                          ,itemkey  => itemkey
                          ,aname    => 'UPDATE_GEN_STATUS'
                       );

    IF l_approval_status = 'APPROVED' THEN
      l_next_status_id := wf_engine.getitemattrnumber(
                               itemtype => itemtype
                              ,itemkey  => itemkey
                              ,aname    => 'AMS_NEW_STAT_ID'
                          );
    ELSIF l_approval_status = 'REJECTED' THEN
      l_next_status_id := wf_engine.getitemattrnumber(
                               itemtype => itemtype
                              ,itemkey => itemkey
                              ,aname => 'AMS_REJECT_STAT_ID'
                          );
    -- julou added 07/02/2002 for bug 2352621
    -- if Workflow status is ERROR revert status of price list to original status
    ELSE
      l_next_status_id := wf_engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ORIG_STAT_ID' );
    END IF;

    l_object_version_number := wf_engine.getitemattrnumber(
                                   itemtype => itemtype
                                  ,itemkey => itemkey
                                  ,aname => 'AMS_OBJECT_VERSION_NUMBER'
                            );
    l_list_header_id := wf_engine.getitemattrnumber(
                     itemtype => itemtype
                    ,itemkey  => itemkey
                    ,aname    => 'AMS_ACTIVITY_ID'
                 );

    l_status_code := ozf_utility_pvt.get_system_status_code(l_next_status_id);

    ozf_utility_pvt.debug_message(l_full_name || ' ' || l_status_code || ' ' || l_approval_status);

    UPDATE ozf_price_list_attributes
       SET user_status_id = l_next_status_id,
           status_code = l_status_code,
           status_date = SYSDATE,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.conc_login_id,
           object_version_number = object_version_number + 1
     WHERE qp_list_header_id = l_list_header_id;

    -- bug 3835674 make price list active in QP only when approval is passed
    IF l_status_code = 'ACTIVE' THEN
      UPDATE qp_list_headers_b
      SET    active_flag = 'Y',
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.conc_login_id
      WHERE  list_header_id = l_list_header_id;
    END IF;
    -- bug 3835674 end

    --COMMIT;

    resultout := 'COMPLETE:SUCCESS';
    RETURN;
  END IF;

  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  fnd_msg_pub.count_and_get(
     p_encoded => fnd_api.g_false
    ,p_count   => l_msg_count
    ,p_data    => l_msg_data
  );

EXCEPTION
  WHEN OTHERS THEN
      FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count => l_msg_count,
           p_data  => l_msg_data);

      ams_gen_approval_pvt.Handle_Err(
           p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);

      wf_core.context('OZF_PRICELIST_APPROVAL_PVT',
                      'UPDATE_PRICELIST_STATUS',
                      itemtype, itemkey,to_char(actid),l_error_msg);

      resultout := 'COMPLETE:ERROR';
END Update_PriceList_Status;

END OZF_PriceList_Approval_PVT;

/
