--------------------------------------------------------
--  DDL for Package Body OZF_FUND_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_APPROVAL_PVT" AS
/* $Header: ozfvfapb.pls 120.3 2006/05/11 22:08:50 asylvia noship $ */
   --  Start of Comments
   --
   -- NAME
   --   OZF_Fund_Approval_PVT
   --
   -- PURPOSE
   --   This package contains all transactions to be done for
   --   Fund Request Approvals and Fund Transfer Approvals
   --   in Oracle Marketing(Funds and Budgets)
   --
   -- HISTORY
   --   03/15/2001        MUMU PANDE          CREATION
   --   11/06/2001        Mumu Pande          Updation for substring add to all message strings
   --   6/13/2002         Mumu Pande          FYI Messages were giving Numeric or Value Error / Changed the size of local varibles
   --   6/11/2002         Mumu Pande          Added Code For Enhancement/Bug#2352621 -- Revert Status Functionality
   --   08/13/2002        Ying Zhao           fix bug 2508539
   --   10/03/2002        Ying Zhao           fix bug#2577992
   --   10/01/2003        Venkat Modur        Fix for Previous Approvers Comments 2535600
   --   01/27/2003        Ying Zhao           Fix bug 2771105(same as 11.5.8 bug 2753608) APPROVAL NOTE NOT SHOWING IN APPROVAL/REJECTION EMAIL
   --   04/23/2003        Ying Zhao           Fix bug 2916480 - MKTCTR9 1159 CERT:AMS-TM:FUNDS ACCRUAL PROGRAM DOES NOT UPDATE BUDGET UTILIZATIO
   --   03-FEB-2004       julou               Bug 3389553 - added token FUND_TYPE to notification messages.
   --   12/09/2005        kdass               Bug 4870218 - SQL Repository fixes
   --   11-May-2006       asylvia             Bug 5199719 - SQL Repository fixes
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'OZF_Fund_Approval_PVT';
   g_file_name   CONSTANT VARCHAR2 (15) := 'ozfvfapb.pls';
   g_fund_mode   CONSTANT VARCHAR2 (15) := 'WORKFLOW';
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_FYI
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        MUMU PANDE        CREATION
PROCEDURE notify_requestor_fyi (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name           VARCHAR2 (61)
                                     :=    g_pkg_name
                                        || 'Notify_Requestor_FYI';
      l_fund_id            NUMBER;
      l_fund_number        VARCHAR2 (30);
      l_fund_name          VARCHAR2 (240);
      l_hyphen_pos1        NUMBER;
      l_fyi_notification   VARCHAR2 (10000);
      l_activity_type      VARCHAR2 (30);
      l_item_type          VARCHAR2 (100);
      l_item_key           VARCHAR2 (100);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (4000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_curr_code          VARCHAR2 (150);
      l_start_date         DATE;
      l_requester          VARCHAR2 (360);
      l_string2            VARCHAR2 (2500);
      l_requested_amt      NUMBER;
      l_fund_type          VARCHAR2(30)  := NULL;
      l_fund_meaning       VARCHAR2(240) := NULL;
      l_return_status      VARCHAR2(1);
      --kdass 09-DEC-2005 bug 4870218 - SQL ID# 14892720
      --asylvia 11-May-2006 bug 5199719 - SQL ID  17778754
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
        select b.fund_number , t.short_name , b.currency_code_tc , b.start_date_active , res.RESOURCE_NAME ,
	b.fund_type
	from ozf_funds_all_b b ,
	     ozf_funds_all_tl t ,
	     jtf_rs_resource_extns_tl res
	where b.fund_id = p_fund_id
	  and b.fund_id = t.fund_id
	  and res.resource_id = b.owner
	  and userenv ( 'LANG' ) =  t.language
	  and  t.language  = res.language;
      /*
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
         SELECT fund_number, short_name, currency_code_tc, start_date_active,
                owner_full_name,fund_type
           FROM ozf_fund_details_v
          WHERE fund_id = p_fund_id;
      */
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      END IF;
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_fund_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );
      l_requested_amt            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTED_AMOUNT'
            );
      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER_DISPLAY_NAME'
            );
      OPEN c_fund_rec (l_fund_id);
      FETCH c_fund_rec INTO l_fund_number,
                            l_fund_name,
                            l_curr_code,
                            l_start_date,
                            l_requester,
                            l_fund_type;
      CLOSE c_fund_rec;
      IF l_fund_type = 'QUOTA' THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'QUOTA',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'BUDGET',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      END IF;
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_REQUESTER_FYI_SUB');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      l_string      := SUBSTR(fnd_message.get,1,1000);
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'FYI_SUBJECT',
         avalue=> l_string
      );
      */
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_ROOTBUDGET_REQ_INFO');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('BUDGET_NUMBER', l_fund_number, FALSE);
      fnd_message.set_token ('OWNER', l_requester, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);
      --l_string1                  := fnd_message.get;
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');
      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */
      --  IF (display_type = 'text/plain') THEN
      l_fyi_notification         :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_fyi_notification;
      document_type              := 'text/plain';
      RETURN;
   --      END IF;
   /*      IF (display_type = 'text/html') THEN
            l_fyi_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'Notify_requestor_FYI',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_requestor_fyi;
--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of Approval
--
-- PURPOSE
--   Generate the Approval Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        MUMU PANDE        CREATION
----------------------------------------------------------------------------
   PROCEDURE notify_requestor_of_approval (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name            VARCHAR2 (100)
                             :=    g_pkg_name
                                || 'Notify_Requestor_of_approval';
      l_fund_id             NUMBER;
      l_fund_number         VARCHAR2 (30);
      l_fund_name           VARCHAR2 (240);
      l_hyphen_pos1         NUMBER;
      l_appr_notification   VARCHAR2 (10000);
      l_activity_type       VARCHAR2 (30);
      l_item_type           VARCHAR2 (80);
      l_item_key            VARCHAR2 (80);
      l_approval_type       VARCHAR2 (30);
      l_approver            VARCHAR2 (200);
      l_note                VARCHAR2 (4000);
      l_approver_note       VARCHAR2 (4000);
      l_approved_amt        NUMBER;
      l_string              VARCHAR2 (1000);
      l_string1             VARCHAR2 (2500);
      l_curr_code           VARCHAR2 (150);
      l_start_date          DATE;
      l_requester           VARCHAR2 (360);
      l_string2             VARCHAR2 (2500);
      l_requested_amt       NUMBER;
      l_fund_type           VARCHAR2(30);
      l_fund_meaning        VARCHAR2(240);
      l_return_status       VARCHAR2(1);

      --kdass 09-DEC-2005 bug 4870218 - SQL ID# 14892679
      --asylvia 11-May-2006 bug 5199719 - SQL ID  17778783
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
	select b.fund_number , t.short_name , b.currency_code_tc , b.start_date_active , res.RESOURCE_NAME ,
	b.fund_type
	from ozf_funds_all_b b ,
	     ozf_funds_all_tl t ,
	     jtf_rs_resource_extns_tl res
	where b.fund_id = p_fund_id
	  and b.fund_id = t.fund_id
	  and res.resource_id = b.owner
	  and userenv ( 'LANG' ) =  t.language
	  and  t.language  = res.language;
      /*
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
         SELECT fund_number, short_name, currency_code_tc, start_date_active,
                owner_full_name, fund_type  -- ,original_budget   01/28/2003 yzhao: requested amount is not original_budget
           FROM ozf_fund_details_v
          WHERE fund_id = p_fund_id;
      */
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      END IF;
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_fund_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );
      l_approved_amt             :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_AMOUNT'
            );
      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER'
            );
      -- yzhao: 01/28/2003 get requested amount from workflow. After approval, requested_amount may not equal orignal_budget
      l_requested_amt            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTED_AMOUNT'
            );
      OPEN c_fund_rec (l_fund_id);
      FETCH c_fund_rec INTO l_fund_number,
                            l_fund_name,
                            l_curr_code,
                            l_start_date,
                            l_requester,
                            l_fund_type;
			                -- l_requested_amt;  01/28/2003 yzhao: requested amount is not original_budget
      CLOSE c_fund_rec;
      IF l_fund_type = 'QUOTA' THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'QUOTA',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'BUDGET',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      END IF;

      fnd_message.set_name ('AMS', 'AMS_WF_NTF_REQUESTER_APP_SUB');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      --fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      --fnd_message.set_token ('AMOUNT', l_approved_amt, FALSE);
      fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_ROOTBUDGET_REQ_INFO');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('BUDGET_NUMBER', l_fund_number, FALSE);
      fnd_message.set_token ('OWNER', l_requester, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);
      --l_string1                  := fnd_message.get;
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');
      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) APPROVAL NOTE NOT SHOWING IN APPROVAL EMAIL */
      l_approver_note          :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'APPROVAL_NOTE'
            );
      fnd_message.set_name('AMS', 'AMS_WF_NTF_REQUESTER_ADDENDUM');
      fnd_message.set_token('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token('AMOUNT', l_approved_amt, FALSE);
      fnd_message.set_token('NOTES_FROM_APPROVER', l_approver_note, FALSE);
      l_string2 := fnd_message.get;
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) ends - APPROVAL NOTE NOT SHOWING IN APPROVAL EMAIL */
      --  IF (display_type = 'text/plain') THEN
      l_appr_notification        :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_appr_notification;
      document_type              := 'text/plain';
      RETURN;
   --      END IF;
   /*      IF (display_type = 'text/html') THEN
            l_appreq_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'Notify_Requestor_of_approval',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_requestor_of_approval;
--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of rejection
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        MUMU PANDE        CREATION
-------------------------------------------------------------------------------
   PROCEDURE notify_requestor_of_rejection (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name           VARCHAR2 (100)
                            :=    g_pkg_name
                               || 'Notify_Requestor_of_rejection';
      l_fund_id            NUMBER;
      l_fund_number        VARCHAR2 (30);
      l_fund_name          VARCHAR2 (240);
      l_hyphen_pos1        NUMBER;
      l_rej_notification   VARCHAR2 (10000);
      l_activity_type      VARCHAR2 (30);
      l_item_type          VARCHAR2 (80);
      l_item_key           VARCHAR2 (80);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (4000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_curr_code          VARCHAR2 (150);
      l_start_date         DATE;
      l_requester          VARCHAR2 (360);
      l_string2            VARCHAR2 (2500);
      l_requested_amt      NUMBER;
      l_fund_type          VARCHAR2(30);
      l_fund_meaning       VARCHAR2(240);
      l_return_status      VARCHAR2(1);
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
         SELECT fund_number, short_name, currency_code_tc, start_date_active, fund_type
           FROM ozf_funds_all_vl
          WHERE fund_id = p_fund_id;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      END IF;
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_fund_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );
      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER'
            );
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608): request_amount, owner not shown in reject notification */
      l_requested_amt             :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTED_AMOUNT'
            );
      l_requester                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTER'
            );
      OPEN c_fund_rec (l_fund_id);
      FETCH c_fund_rec INTO l_fund_number,
                            l_fund_name,
                            l_curr_code,
                            l_start_date,
                            l_fund_type;
      IF l_fund_type = 'QUOTA' THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'QUOTA',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'BUDGET',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      END IF;
      CLOSE c_fund_rec;
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_REQUESTER_REJ_SUB');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      -- 01/12/2001 mpande
      --fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);
      --l_string                   := fnd_message.get;
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'REJECT_SUBJECT',
         avalue=> l_string
      );
      */
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_ROOTBUDGET_REQ_INFO');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('BUDGET_NUMBER', l_fund_number, FALSE);
      fnd_message.set_token ('OWNER', l_requester, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');
      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) APPROVer's NOTE NOT SHOWING IN rejection EMAIL */
      l_note          :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'APPROVAL_NOTE'
            );
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_APPROVER_NOTE');
      fnd_message.set_token ('NOTES_FROM_APPROVER', l_note, FALSE);
      l_string2 := SUBSTR(FND_MESSAGE.Get, 1, 2500);
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) ends - APPROVer's NOTE NOT SHOWING IN rejection EMAIL */
      --  IF (display_type = 'text/plain') THEN
      l_rej_notification         :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_rej_notification;
      document_type              := 'text/plain';
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'Notify_requestor_of_rejection',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_requestor_of_rejection;
--------------------------------------------------------------------------
-- PROCEDURE
--   notify_approval_required
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        MUMU PANDE        CREATION
   PROCEDURE notify_approval_required (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              VARCHAR2 (100)
                                 :=    g_pkg_name
                                    || 'Notify_approval_required';
      l_fund_id               NUMBER;
      l_fund_number           VARCHAR2 (30);
      l_fund_name             VARCHAR2 (240);
      l_hyphen_pos1           NUMBER;
      l_appreq_notification   VARCHAR2 (10000);
      l_activity_type         VARCHAR2 (30);
      l_item_type             VARCHAR2 (30);
      l_item_key              VARCHAR2 (30);
      l_approval_type         VARCHAR2 (30);
      l_forwarder             VARCHAR2 (150);
      l_note                  VARCHAR2 (4000);
      l_requested_amt         NUMBER;
      l_string                VARCHAR2 (1000);
      l_string1               VARCHAR2 (2500);
      l_approver              VARCHAR2 (200);
      l_curr_code             VARCHAR2 (30);
      l_start_date            DATE;
      l_requester             VARCHAR2 (360);
      l_string2               VARCHAR2 (2500);
      l_approval_date         VARCHAR2(30);
      l_fund_type             VARCHAR2(30);
      l_fund_meaning          VARCHAR2(240);
      l_return_status         VARCHAR2(1);

      --kdass 09-DEC-2005 bug 4870218 - SQL ID# 14892648
      --asylvia 11-May-2006 bug 5199719 - SQL ID  17778839
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
	select b.fund_number , t.short_name , b.currency_code_tc , b.start_date_active , res.RESOURCE_NAME ,
	b.fund_type
	from ozf_funds_all_b b ,
	     ozf_funds_all_tl t ,
	     jtf_rs_resource_extns_tl res
	where b.fund_id = p_fund_id
	  and b.fund_id = t.fund_id
	  and res.resource_id = b.owner
	  and userenv ( 'LANG' ) =  t.language
	  and  t.language  = res.language;
      /*
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
         SELECT fund_number, short_name, currency_code_tc, start_date_active,
                owner_full_name, fund_type
           FROM ozf_fund_details_v
          WHERE fund_id = p_fund_id;
      */
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      END IF;
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_fund_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );
      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER_DISPLAY_NAME'
            );
      l_requested_amt            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTED_AMOUNT'
            );
      l_requester                :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTER'
            );
      OPEN c_fund_rec (l_fund_id);
      FETCH c_fund_rec INTO l_fund_number,
                            l_fund_name,
                            l_curr_code,
                            l_start_date,
                            l_requester,
                            l_fund_type;
      CLOSE c_fund_rec;
      IF l_fund_type = 'QUOTA' THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'QUOTA',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'BUDGET',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      END IF;
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
      l_string                   := SUBSTR(fnd_message.get,1,1000);
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'APP_SUBJECT',
         avalue=> l_string
      );
      */
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_ROOTBUDGET_REQ_INFO');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('BUDGET_NUMBER', l_fund_number, FALSE);
      fnd_message.set_token ('OWNER', l_requester, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);
      l_note                     :=
            NVL(wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_PREV_APPROVER_NOTE'
            ),'-');
      l_forwarder                     :=
            NVL(wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_PREV_APPROVER_DISP_NAME'
            ),'-');
      l_approval_date := NVL(to_char(wf_engine.getitemattrdate (
               itemtype => l_item_type,
	       itemkey  => l_item_key,
	       aname    => 'AMS_APPROVAL_DATE')),'-');
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_APPROVER_ADDENDUM');
      fnd_message.set_token ('PREV_APPROVER_NAME', l_forwarder, FALSE);
      fnd_message.set_token ('APPROVAL_DATE', l_approval_date, FALSE);
      fnd_message.set_token ('COMMENTS', l_note, FALSE);
      /* will set the tokens later
                fnd_message.set_token('BUDGET_NAME',l_fund_name,false);
                fnd_message.set_token('BUDGET_NUMBER',l_fund_number,false);
      */
      --      l_string2 := Substr(FND_MESSAGE.Get,1,2500);
      l_string2                  := SUBSTR(fnd_message.get,1,2500);
      --  IF (display_type = 'text/plain') THEN
      l_appreq_notification      :=    l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2;
      document                   :=    document
                                    || l_appreq_notification;
      document_type              := 'text/plain';
      RETURN;
   --      END IF;
   /*      IF (display_type = 'text/html') THEN
            l_appreq_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'notify_approval_required',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_approval_required;
--------------------------------------------------------------------------
-- PROCEDURE
--   notify_appr_req_reminder
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        MUMU PANDE        CREATION
   PROCEDURE notify_appr_req_reminder (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              VARCHAR2 (100)
                                 :=    g_pkg_name
                                    || 'notify_appr_req_reminder';
      l_fund_id               NUMBER;
      l_fund_number           VARCHAR2 (30);
      l_fund_name             VARCHAR2 (240);
      l_hyphen_pos1           NUMBER;
      l_apprem_notification   VARCHAR2 (10000);
      l_activity_type         VARCHAR2 (30);
      l_item_type             VARCHAR2 (80);
      l_item_key              VARCHAR2 (80);
      l_approval_type         VARCHAR2 (30);
      l_approver              VARCHAR2 (200);
      l_note                  VARCHAR2 (4000);
      l_forwarder             VARCHAR2 (150);
      l_string                VARCHAR2 (1000);
      l_string1               VARCHAR2 (2500);
      l_curr_code             VARCHAR2 (30);
      l_start_date            DATE;
      l_requester             VARCHAR2 (360);
      l_string2               VARCHAR2 (2500);
      l_requested_amt         NUMBER;
      l_approved_amt          NUMBER;
      l_approval_date         VARCHAR2(30);
      l_fund_type             VARCHAR2(30);
      l_fund_meaning          VARCHAR2(240);
      l_return_status         VARCHAR2(1);
      CURSOR c_fund_rec (p_fund_id IN NUMBER) IS
         SELECT fund_number, short_name, currency_code_tc, start_date_active, fund_type
           FROM ozf_funds_all_vl
          WHERE fund_id = p_fund_id;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      END IF;
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_fund_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );
      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER'
            );
      l_requested_amt            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTED_AMOUNT'
            );
      l_requester                :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTER'
            );
      OPEN c_fund_rec (l_fund_id);
      FETCH c_fund_rec INTO l_fund_number,
                            l_fund_name,
                            l_curr_code,
                            l_start_date,
                            l_fund_type;
      CLOSE c_fund_rec;
      IF l_fund_type = 'QUOTA' THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'QUOTA',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'BUDGET',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      END IF;
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
      l_string                   := SUBSTR(fnd_message.get,1,1000);
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'APP_SUBJECT',
         avalue=> l_string
      );
      */
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_ROOTBUDGET_REQ_INFO');
      fnd_message.set_token ('BUDGET_NAME', l_fund_name, FALSE);
      fnd_message.set_token ('BUDGET_NUMBER', l_fund_number, FALSE);
      fnd_message.set_token ('OWNER', l_requester, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('CURRENCY_CODE', l_curr_code, FALSE);
      fnd_message.set_token ('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
      --               l_string1 := Substr(FND_MESSAGE.Get,1,2500);
      l_note                     :=
            NVL(wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_PREV_APPROVER_NOTE'
            ),'-');
      l_forwarder                     :=
            NVL(wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_PREV_APPROVER_DISP_NAME'
            ),'-');
     l_approval_date := NVL(to_char(wf_engine.getitemattrdate (
               itemtype => l_item_type,
	       itemkey  => l_item_key,
	       aname    => 'AMS_APPROVAL_DATE')),'-');
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);
      fnd_message.set_name ('AMS', 'AMS_WF_NTF_APPROVER_ADDENDUM');
      fnd_message.set_token ('PREV_APPROVER_NAME', l_forwarder, FALSE);
      fnd_message.set_token ('APPROVAL_DATE', l_approval_date, FALSE);
      fnd_message.set_token ('COMMENTS', l_note, FALSE);
      /* will set the tokens later
                fnd_message.set_token('BUDGET_NAME',l_fund_name,false);
                fnd_message.set_token('BUDGET_NUMBER',l_fund_number,false);
      */
      --      l_string2 := Substr(FND_MESSAGE.Get,1,2500);
      l_string2                  := SUBSTR(fnd_message.get,1,2500);
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');
      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */
      --  IF (display_type = 'text/plain') THEN
      l_apprem_notification      :=    l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2;
      document                   :=    document
                                    || l_apprem_notification;
      document_type              := 'text/plain';
      RETURN;
   --      END IF;
   /*      IF (display_type = 'text/html') THEN
            l_appreq_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'notify_appr_req_reminder',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_appr_req_reminder;
---------------------------------------------------------------------
-- PROCEDURE
--   Set_ParBudget_Activity_details
--
--
-- PURPOSE
--   This Procedure will set all the item attribute details
--
--
-- IN
--
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
--
-- HISTORY
--   02/20/2001        MUMU PANDE        CREATION
-- End of Comments
--------------------------------------------------------------------
   PROCEDURE set_parbudget_activity_details (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS
      l_activity_id          NUMBER;
      -- mpande changed for activity type 8/14/2001
      l_activity_type        VARCHAR2 (30)                  := 'RFRQ';
      l_approval_type        VARCHAR2 (30)                  := 'BUDGET';
      /*
      l_activity_type        VARCHAR2 (30)                  := 'FUND';
      l_approval_type        VARCHAR2 (30)                  := 'ROOT_BUDGET';
      */
      l_object_details       ams_gen_approval_pvt.objrectyp;
      l_approval_detail_id   NUMBER;
      l_approver_seq         NUMBER;
      l_return_status        VARCHAR2 (1);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (4000);
      l_error_msg            VARCHAR2 (4000);
      l_orig_stat_id         NUMBER;
      l_full_name            VARCHAR2 (60);
      l_fund_number          VARCHAR2 (30);
      l_requested_amt        NUMBER;
      l_approver             VARCHAR2 (200);
      l_string               VARCHAR2 (3000);
      l_lookup_meaning       VARCHAR2(240);
      l_fund_type            VARCHAR2(30);
      l_fund_meaning         VARCHAR2(240);
      -- mpande 08/14/2001 changed for category id
      CURSOR c_fund_rec (p_act_id IN NUMBER) IS
         SELECT short_name, custom_setup_id, original_budget, org_id, to_char(category_id),
                start_date_active, end_date_active, owner, currency_code_tc, business_unit_id,
                fund_number, fund_type
           FROM ozf_funds_all_vl
          WHERE fund_id = p_act_id;
   BEGIN
      fnd_msg_pub.initialize;
      l_activity_id              :=
            wf_engine.getitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_ACTIVITY_ID'
            );
      OPEN c_fund_rec (l_activity_id);
      FETCH c_fund_rec INTO l_object_details.name,
                            l_object_details.setup_type_id,
                            l_object_details.total_header_amount,
                            l_object_details.org_id,
                            l_object_details.object_type,
                            l_object_details.start_date,
                            l_object_details.end_date,
                            l_object_details.owner_id,
                            l_object_details.currency,
			    l_object_details.business_unit_id,
                            l_fund_number,
                            l_fund_type;
      CLOSE c_fund_rec;

      IF l_fund_type = 'QUOTA' THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'QUOTA',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'BUDGET',
                            x_return_status => l_return_status,
                            x_meaning       => l_fund_meaning);
      END IF;

      IF (funcmode = 'RUN') THEN
         ams_gen_approval_pvt.get_approval_details (
            p_activity_id=> l_activity_id,
            p_activity_type=> l_activity_type,
            p_approval_type=> l_approval_type,
            p_object_details=> l_object_details,
            x_approval_detail_id=> l_approval_detail_id,
            x_approver_seq=> l_approver_seq,
            x_return_status=> l_return_status
         );
         IF l_return_status = fnd_api.g_ret_sts_success THEN
            /*        AMS_GEN_APPROVAL_PVT.Get_User_Name
                      ( p_user_id            => l_object_details.owner_id,
                        x_full_name          => l_full_name,
                        x_return_status      => l_return_status );
            */
            wf_engine.setitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVAL_DETAIL_ID',
               avalue=> l_approval_detail_id
            );
            wf_engine.setitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVER_SEQ',
               avalue=> l_approver_seq
            );
            wf_engine.setitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_REQUESTED_AMOUNT',
               avalue=> l_object_details.total_header_amount
            );
            --- set all the subjects here
            fnd_message.set_name ('AMS', 'AMS_WF_NTF_REQUESTER_FYI_SUB');
            fnd_message.set_token (
               'BUDGET_NAME',
               l_object_details.name,
               FALSE
            );
            fnd_message.set_token (
               'CURRENCY_CODE',
               l_object_details.currency,
               FALSE
            );
            fnd_message.set_token (
               'AMOUNT',
               l_object_details.total_header_amount,
               FALSE
            );
            fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
            fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE); -- ##
            l_string                   := fnd_message.get;
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'FYI_SUBJECT',
               avalue=> l_string
            );
            fnd_message.set_name ('AMS', 'AMS_WF_NTF_REQUESTER_APP_SUB');
            fnd_message.set_token ('BUDGET_NAME', l_object_details.name, FALSE  );
	    -- 11/06/2001 mpande commented
            --fnd_message.set_token ('CURRENCY_CODE', l_object_details.currency, FALSE  );
            --fnd_message.set_token ('AMOUNT',l_object_details.total_header_amount,  FALSE);
            fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
            fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
            l_string                   := fnd_message.get;
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'APRV_SUBJECT',
               avalue=> l_string
            );
            fnd_message.set_name ('AMS', 'AMS_WF_NTF_REQUESTER_REJ_SUB');
            fnd_message.set_token (
               'BUDGET_NAME',
               l_object_details.name,
               FALSE
            );
            fnd_message.set_token (
               'CURRENCY_CODE',
               l_object_details.currency,
               FALSE
            );
            fnd_message.set_token (
               'AMOUNT',
               l_object_details.total_header_amount,
               FALSE
            );
            fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
            fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
            -- yzhao: not a token in message fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE); -- ##
            l_string                   := fnd_message.get;
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'REJECT_SUBJECT',
               avalue=> l_string
            );
            fnd_message.set_name ('AMS', 'AMS_WF_NTF_APPROVER_OF_REQ_SUB');
            fnd_message.set_token (
               'BUDGET_NAME',
               l_object_details.name,
               FALSE
            );
            fnd_message.set_token (
               'CURRENCY_CODE',
               l_object_details.currency,
               FALSE
            );
            fnd_message.set_token (
               'AMOUNT',
               l_object_details.total_header_amount,
               FALSE
            );
            fnd_message.set_token ('REQUEST_NUMBER', '-', FALSE);
            fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
            --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
            l_string                   := fnd_message.get;
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'APP_SUBJECT',
               avalue=> l_string
            );
           /* mpande added for implementation of BUG#2352621*/
           l_lookup_meaning := ozf_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER','RFRQ');
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
            /* End of Addition for Bug#2352621*/
            resultout                  := 'COMPLETE:SUCCESS';
         ELSE
            fnd_msg_pub.count_and_get (
               p_encoded=> fnd_api.g_false,
               p_count=> l_msg_count,
               p_data=> l_msg_data
            );
            ams_gen_approval_pvt.handle_err (
               p_itemtype=> itemtype,
               p_itemkey=> itemkey,
               p_msg_count=> l_msg_count, -- Number of error Messages
               p_msg_data=> l_msg_data,
               p_attr_name=> 'AMS_ERROR_MSG',
               x_error_msg=> l_error_msg
            );
            wf_core.context (
               'ams_gen_approval_pvt',
               'Set_Activity_Details',
               itemtype,
               itemkey,
               actid,
               l_error_msg
            );
            -- RAISE FND_API.G_EXC_ERROR;
            resultout                  := 'COMPLETE:ERROR';
         END IF;
      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;
   --
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         wf_core.context (
            'AMS_FundApproval_pvt',
            'Set_ParBudget_Activity_Details',
            itemtype,
            itemkey,
            actid,
            funcmode,
            l_error_msg
         );
         RAISE;
      WHEN OTHERS THEN
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> l_msg_count,
            p_data=> l_msg_data
         );
         RAISE;
   END set_parbudget_activity_details;
---------------------------------------------------------------------
-- PROCEDURE
--  Get_Ntf_Rule_Values
--
-- PURPOSE
--   This Procedure will check the value apporved_amount in the
--   of the notification rule of the approver
-- IN
--    p_approver_name IN VARCHAR2,
--    p_result IN VARCHAR2 --
-- OUT
--    x_text_value OUT VARCHAR2
--    x_number_value OUT NUMBER
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   10/2/2002        MUMU PANDE        CREATION
-- End of Comments
-------------------------------------------------------------------
   PROCEDURE Get_Ntf_Rule_Values
      (p_approver_name IN VARCHAR2,
       x_text_value OUT NOCOPY VARCHAR2,
       x_number_value OUT NOCOPY NUMBER)
   IS
      CURSOR c_get_rule IS
      SELECT b.text_value, b.number_value
        FROM wf_routing_rules a, wf_routing_rule_attributes b
       WHERE a.rule_id = b.rule_id
         AND a.role = p_approver_name
         AND TRUNC(sysdate) BETWEEN TRUNC(NVL(begin_date, sysdate -1)) AND
             TRUNC(NVL(end_date,sysdate+1))
         AND a.message_name = 'AMS_APPROVAL_REQUIRED_OZF'
         AND b.name = 'AMS_AMOUNT';
   BEGIN
      x_text_value := null;
      x_number_value := null;
      OPEN c_get_rule;
      FETCH c_get_rule INTO x_text_value, x_number_value;
      IF c_get_rule%NOTFOUND THEN
          x_text_value := NULL;
          x_number_value := 0;
      END IF;
      CLOSE c_get_rule;
   EXCEPTION
     WHEN OTHERS THEN
        IF G_DEBUG THEN
           ozf_utility_pvt.debug_message ('ozf_fund_approval_pvt.get_ntf_rule_values() exception.' || SQLERRM);
        END IF;
     RAISE;
   END Get_Ntf_Rule_Values;
---------------------------------------------------------------------
-- PROCEDURE
--  Update_ParBudget_Statas
--
--
-- PURPOSE
--   This Procedure will update the status
--
--
-- IN
--
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
--
-- HISTORY
--   02/20/2001        MUMU PANDE        CREATION
--   05/26/2003        niprakas          fixed the bug#2950338
-- End of Comments
-------------------------------------------------------------------
   PROCEDURE update_parbudget_status (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS
      l_status_code             VARCHAR2 (30);
      l_api_version    CONSTANT NUMBER                      := 1.0;
      l_return_status           VARCHAR2 (1)                := fnd_api.g_ret_sts_success;
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (4000);
      l_api_name       CONSTANT VARCHAR2 (30)               := 'Update_ParBudget_Status';
      l_full_name      CONSTANT VARCHAR2 (60)               :=    g_pkg_name
                                                               || '.'
                                                               || l_api_name;
      l_fund_rec                ozf_funds_pvt.fund_rec_type;
      l_next_status_id          NUMBER;
      l_approved_amount         NUMBER;
      l_update_status           VARCHAR2 (12);
      l_error_msg               VARCHAR2 (4000);
      l_object_version_number   NUMBER;
      l_fund_id                 NUMBER;
      l_validation_level        NUMBER                      := fnd_api.g_valid_level_full;
      l_approver                VARCHAR2(320);
      l_text_value              VARCHAR2(2000);
      l_number_value            NUMBER;
      l_requested_amt           NUMBER;
      l_requester_id            NUMBER;
      l_approver_id             NUMBER;
      l_user_id                  NUMBER;
      l_resp_id                  NUMBER;
      l_appl_id                  NUMBER;
      l_security_group_id        NUMBER;
      l_fund_type		 VARCHAR2(30);
      CURSOR c_get_fund_type IS
          SELECT fund_type from ozf_funds_all_b where fund_id = l_fund_id;
   BEGIN
      SAVEPOINT update_parbudget_status ;
      IF funcmode = 'RUN' THEN
         l_update_status            :=
               wf_engine.getitemattrtext (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'UPDATE_GEN_STATUS'
               );
         l_approved_amount          :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_AMOUNT'
               );
         l_approver            :=
               wf_engine.getitemattrtext (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_APPROVER'
               );
         l_approver_id            :=
               wf_engine.getitemattrtext (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_APPROVER_ID'
               );
         l_requester_id            :=
               wf_engine.getitemattrtext (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_REQUESTER_ID'
               );
         l_requested_amt :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_REQUESTED_AMOUNT'
               );
	 l_object_version_number    :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_OBJECT_VERSION_NUMBER'
               );
         l_fund_id                  :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_ACTIVITY_ID'
               );
         -- [BEGIN OF BUG 2916480 FIXING by yzhao  23-APR-2003]
         -- yzhao: initialized PL/SQL security context(especially application_id)
         --        since self service workflow didn't set application_id when approver approves.
         l_user_id := FND_GLOBAL.user_id;
         l_resp_id := FND_GLOBAL.resp_id;
         l_appl_id := FND_GLOBAL.resp_appl_id;
         l_security_group_id := FND_GLOBAL.security_group_id;
         IF (l_appl_id IS NULL OR l_appl_id = 0) THEN
             l_appl_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                                      , itemkey  => itemkey
                                                      , aname    => 'APPLICATION_ID'
                                                      );
             FND_GLOBAL.apps_initialize( user_id           => l_user_id
                                       , resp_id           => l_resp_id
                                       , resp_appl_id      => l_appl_id
                                       --, security_group_id => l_security_group_id
                                       );
         END IF;
         -- [END OF BUG 2916480 FIXING by yzhao 23-APR-2003]
         ozf_funds_pvt.init_fund_rec (x_fund_rec => l_fund_rec);
         IF l_update_status = 'APPROVED' THEN
            l_next_status_id           :=
                  wf_engine.getitemattrnumber (
                     itemtype=> itemtype,
                     itemkey=> itemkey,
                     aname => 'AMS_NEW_STAT_ID'
                  );
            /* yzhao 10/03/2002 bug#2577992   when automatic approval notification rule is set
                     if auto approval amount > request amount, then final approval amount := request amount
                     else final approval amount := auto approval amount
             */
            Get_Ntf_Rule_Values
                 (p_approver_name   => l_approver,
                  x_text_value      => l_text_value ,
                  x_number_value    => l_number_value);
            OPEN c_get_fund_type;
	    FETCH c_get_fund_type into l_fund_type;
	    CLOSE c_get_fund_type;
            IF NVL(l_number_value,0) > 0 THEN
                  IF l_number_value > l_requested_amt THEN
                     l_fund_rec.original_budget := l_requested_amt;
                  ELSE
                     l_fund_rec.original_budget := l_number_value;
                  END IF;
            -- End of addition for bug#2577792
	    -- niprakas: fix for bug#2950338 starts
	    ELSIF l_fund_type = 'FIXED' THEN
             l_fund_rec.original_budget := l_approved_amount;

	    --kvattiku Fix for bug 3584105
	    ELSIF l_fund_type = 'QUOTA' THEN
             l_fund_rec.original_budget := l_approved_amount;

	    END IF;
	    -- niprakas: fix for bug#2950338 ends
            /* Approved Amount is null in the following cases.
               a) yzhao 08/13/2002 fix bug 2508539
                       when requester and approver are the same, no approval is required and AMS_AMOUNT is not set
                       should take AMS_REQUESTED_AMOUNT
             */
            IF l_approved_amount IS NULL THEN
               IF l_approver_id = l_requester_id THEN
                  l_fund_rec.original_budget := l_requested_amt;
               END IF;
            END IF;
	      -- niprakas: fix for bug#2950338 starts
	    IF l_fund_type='FULLY_ACCRUED' THEN
             l_fund_rec.original_budget := 0;
	    END IF;
	     -- niprakas: fix for bug#2950338 ends
	     -- set approval amount to workflow so notificaiton gets the correct amount
	    wf_engine.setitemattrnumber (
                     itemtype=> itemtype,
                     itemkey=> itemkey,
                     aname => 'AMS_AMOUNT',
                     avalue=> l_fund_rec.original_budget
            );
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (   l_full_name || l_update_status);
            END IF;
         -- mpande 6/11/2002 bug#2352621
         ELSIF l_update_status = 'REJECTED' THEN
            l_next_status_id           :=
                  wf_engine.getitemattrnumber (
                     itemtype=> itemtype,
                     itemkey=> itemkey,
                     aname => 'AMS_REJECT_STAT_ID'
                  );
         -- mpande 6/11/2002 bug#2352621
         -- Status is 'ERROR' during error in wf so the status of the fund should change back to 'DRAFT'
         ELSE
            --l_next_status_id           :=
            --                  ozf_utility_pvt.get_default_user_status ( 'OZF_FUND_STATUS' ,'DRAFT');
            -- 06/28/2002 yzhao: no valiation for update so status always revert to 'DRAFT' when error occurs
            l_next_status_id := wf_engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ORIG_STAT_ID' );
            l_validation_level := fnd_api.g_valid_level_none;
         END IF;
         --   x_return_status := fnd_api.g_ret_sts_success;
         l_status_code              :=
                     ozf_utility_pvt.get_system_status_code (l_next_status_id);
         l_fund_rec.fund_id         := l_fund_id;
         l_fund_rec.user_status_id  := l_next_status_id;
         l_fund_rec.status_code     := l_status_code;
         l_fund_rec.object_version_number :=   l_object_version_number
                                             + 1;
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (
               l_full_name
            || l_status_code || ' '
            || l_approved_amount || ' '
            || l_update_status
         );
         END IF;
         ozf_funds_pvt.update_fund (
            p_api_version=> l_api_version,
            p_init_msg_list=> fnd_api.g_false,
            p_validation_level => l_validation_level,
            x_return_status=> l_return_status,
            x_msg_count=> l_msg_count,
            x_msg_data=> l_msg_data,
            p_fund_rec=> l_fund_rec,
            p_mode=> g_fund_mode
         );
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message(l_full_name || ' failed to update fund to status ' || l_status_code);
            END IF;
            ams_gen_approval_pvt.handle_err (
               p_itemtype=> itemtype,
               p_itemkey=> itemkey,
               p_msg_count=> l_msg_count, -- Number of error Messages
               p_msg_data=> l_msg_data,
               p_attr_name=> 'AMS_ERROR_MSG',
               x_error_msg=> l_error_msg
            );
            -- mpande 6/11/2002 bug#2352621
            resultout := 'COMPLETE:ERROR';
         ELSE
            resultout := 'COMPLETE:SUCCESS';
         END IF;
      END IF;
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;
      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false,
         p_count=> l_msg_count,
         p_data=> l_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_full_name
         || ': l_return_status'
         || l_return_status
      );
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         --      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO update_parbudget_status ;
      resultout := 'COMPLETE:ERROR';
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> l_msg_count,
            p_data=> l_msg_data
         );
            ams_gen_approval_pvt.handle_err (
               p_itemtype=> itemtype,
               p_itemkey=> itemkey,
               p_msg_count=> l_msg_count, -- Number of error Messages
               p_msg_data=> l_msg_data,
               p_attr_name=> 'AMS_ERROR_MSG',
               x_error_msg=> l_error_msg
            );
         --RAISE;
   END update_parbudget_status;
/* --
6/11/2002 MPande COmmented after bug#2352621 was implemented
   PROCEDURE revert_parbudget_status (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS
      l_status_code             VARCHAR2 (30);
      l_api_version    CONSTANT NUMBER                      := 1.0;
      l_return_status           VARCHAR2 (1)           := fnd_api.g_ret_sts_success;
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (4000);
      l_api_name       CONSTANT VARCHAR2 (30)               := 'Update_ParBudget_Status';
      l_full_name      CONSTANT VARCHAR2 (60)               :=    g_pkg_name
                                                               || '.'
                                                               || l_api_name;
      l_fund_rec                ozf_funds_pvt.fund_rec_type;
      l_next_status_id          NUMBER;
      l_approved_amount         NUMBER;
      l_update_status           VARCHAR2 (12);
      l_error_msg               VARCHAR2 (4000);
      l_object_version_number   NUMBER;
      l_fund_id                 NUMBER;
   BEGIN
      IF funcmode = 'RUN' THEN
         l_object_version_number    :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_OBJECT_VERSION_NUMBER'
               );
         l_fund_id                  :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_ACTIVITY_ID'
               );
         --   x_return_status := fnd_api.g_ret_sts_success;
         l_status_code              :=
                                ozf_utility_pvt.get_system_status_code (2100);
         ozf_funds_pvt.init_fund_rec (x_fund_rec => l_fund_rec);
         l_fund_rec.fund_id         := l_fund_id;
         l_fund_rec.user_status_id  := 2100;
         l_fund_rec.status_code     := l_status_code;
         l_fund_rec.object_version_number :=   l_object_version_number
                                             + 1;
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (
               l_full_name
            || l_status_code
            || l_approved_amount
            || l_update_status
         );
         END IF;
         ozf_funds_pvt.update_fund (
            p_api_version=> l_api_version,
            p_init_msg_list=> fnd_api.g_false,
            x_return_status=> l_return_status,
            x_msg_count=> l_msg_count,
            x_msg_data=> l_msg_data,
            p_fund_rec=> l_fund_rec,
            p_mode=> g_fund_mode
         );
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            ams_gen_approval_pvt.handle_err (
               p_itemtype=> itemtype,
               p_itemkey=> itemkey,
               p_msg_count=> l_msg_count, -- Number of error Messages
               p_msg_data=> l_msg_data,
               p_attr_name=> 'AMS_ERROR_MSG',
               x_error_msg=> l_error_msg
            );
         END IF;
      END IF;
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;
      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false,
         p_count=> l_msg_count,
         p_data=> l_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_full_name
         || ': l_return_status'
         || l_return_status
      );
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         --      x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> l_msg_count,
            p_data=> l_msg_data
         );
         RAISE;
   END revert_parbudget_status;
   */
---------------------------------------------------------------------
-- PROCEDURE
--  get_fund_parent_owner
--
--
-- PURPOSE
--   This Procedure is a seeded function .
--
--
-- IN
--
--
-- OUT
--
-- Used By Activities
--
-- NOTES
-- if there is notparen tfund it will default to the fund owner
--
--
-- HISTORY
--   05/29/2001        MUMU PANDE        CREATION
-- End of Comments
-------------------------------------------------------------------
   PROCEDURE get_fund_parent_owner (
      itemtype          IN       VARCHAR2,
      itemkey           IN       VARCHAR2,
      x_approver_id     OUT NOCOPY      NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR c_parent_fund_owner (p_fund_id IN NUMBER) IS
         SELECT ozf2.owner, ozf1.owner
           FROM ozf_funds_all_b ozf2, ozf_funds_all_b ozf1
          WHERE ozf2.fund_id = ozf1.parent_fund_id
            AND ozf1.fund_id = p_fund_id;
      l_fund_id         NUMBER;
      l_fund_owner_id   NUMBER;
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      l_fund_id                  :=
            wf_engine.getitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_ACTIVITY_ID'
            );
      OPEN c_parent_fund_owner (l_fund_id);
      FETCH c_parent_fund_owner INTO x_approver_id, l_fund_owner_id;
      CLOSE c_parent_fund_owner;
      IF x_approver_id IS NULL THEN
         x_approver_id              := l_fund_owner_id;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         RAISE;
   END get_fund_parent_owner;
END ozf_fund_approval_pvt;

/
