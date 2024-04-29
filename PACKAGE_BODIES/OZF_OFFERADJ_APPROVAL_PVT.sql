--------------------------------------------------------
--  DDL for Package Body OZF_OFFERADJ_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFERADJ_APPROVAL_PVT" AS
/* $Header: ozfvoawb.pls 120.3.12010000.2 2009/05/04 08:13:25 kdass ship $ */

   --  Start of Comments
   --
   -- NAME
   --   OZF_OFFER_ADJUST_APPRV_PVT
   --
   -- PURPOSE
   --   This package contains all transactions to be done for
   --   Offer Adjustment Approvals in Oracle Marketing
   --
   -- HISTORY
   --   4/25/2002        mgudivak          CREATION
   -- Wed Mar 29 2006:4/45 PM  RSSHARMA New Offer Adjustment changes. If the next status is active then call close adjustment API to close/activate adjustment.
   -- else update the status to the next possible status.
   --   05/04/2009       kdass             fixed bug 8253195
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'OZF_OFFER_ADJUST_APPRV_PVT';
   g_file_name   CONSTANT VARCHAR2 (15) := 'ozfvoawb.pls';


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
--   4/25/2002        mgudivak        CREATION

   PROCEDURE notify_requestor_fyi (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS

   l_api_name            VARCHAR2(100)    := g_pkg_name || 'Notify_Requestor_FYI';
   l_hyphen_pos1         NUMBER;
   l_fyi_notification    VARCHAR2(10000);
   l_activity_type       VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_approval_type       VARCHAR2(30);
   l_approver            VARCHAR2(200);
   l_note                VARCHAR2(4000);
   l_subject             VARCHAR2(500);
   l_body                VARCHAR2(3500);
   l_requester           VARCHAR2(30);
   l_string              VARCHAR2 (1000);
   l_string1             VARCHAR2 (2500);
   l_string2             VARCHAR2 (2500);

   l_offer_adjustment_id  NUMBER;
   l_offer_name           VARCHAR2(240);
   l_offer_code           VARCHAR2(240);
   l_offer_type           VARCHAR2(240);
   l_settlement_name      VARCHAR2(240);
   l_start_date_active    DATE;
   l_end_date_active      DATE;
   l_effective_date       DATE;
   l_offer_adj_name       VARCHAR2(120);

   CURSOR c_offer_adj_info (p_offer_adjustment_id IN NUMBER) IS
     select a.name,
           substr(a.description,1,240) description,
	   lkp1.meaning offer_type,
           a.start_date_active,
           a.end_date_active,
           lkp.meaning settlement_name,
           b.effective_date,
           b.offer_adjustment_name
     from qp_list_headers a,
          ozf_offer_adjustments_vl b,
          ozf_lookups lkp,
	  ozf_lookups lkp1,
	  ozf_offers offr
     where a.list_header_id = b.list_header_id
	 and a.list_header_id = offr.qp_list_header_id
     and  b.offer_adjustment_id  = p_offer_adjustment_id
     and lkp.lookup_code = b.settlement_code
     and lkp.lookup_type = 'OZF_OFFER_LUMPSUM_PAYMENT'
	 and lkp1.lookup_code = offr.offer_type
	 and lkp1.lookup_type = 'OZF_OFFER_TYPE';


   BEGIN
      ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
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
      l_offer_adjustment_id      :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'AMS_NOTES_FROM_REQUESTOR'
            );

      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER'
            );

      OPEN c_offer_adj_info( l_offer_adjustment_id);
      FETCH c_offer_adj_info INTO
            l_offer_code,
            l_offer_name,
            l_offer_type,
            l_start_date_active,
            l_end_date_active,
            l_settlement_name,
            l_effective_date,
            l_offer_adj_name ;
      CLOSE c_offer_adj_info;


      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_FORWARD_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      l_string      := SUBSTR(fnd_message.get,1,1000);

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_FORWARD_INFO');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('OFFER_TYPE', l_offer_type, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date_active, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date_active, FALSE);
      fnd_message.set_token ('SETTLEMENT_NAME', l_settlement_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);

      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);

      l_fyi_notification         :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_fyi_notification;
      document_type              := 'text/plain';
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'OZFGAPP',
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
--   4/25/2002        mgudivak        CREATION
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
   l_hyphen_pos1         NUMBER;
   l_appr_notification    VARCHAR2(10000);
   l_activity_type       VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_approval_type       VARCHAR2(30);
   l_approver            VARCHAR2(200);
   l_note                VARCHAR2(4000);
   l_subject             VARCHAR2(500);
   l_body                VARCHAR2(3500);
   l_requester           VARCHAR2(30);
   l_string              VARCHAR2 (1000);
   l_string1             VARCHAR2 (2500);
   l_string2             VARCHAR2 (2500);

   l_offer_adjustment_id  NUMBER;
   l_offer_name           VARCHAR2(240);
   l_offer_code           VARCHAR2(240);
   l_offer_type           VARCHAR2(240);
   l_settlement_name      VARCHAR2(240);
   l_start_date_active    DATE;
   l_end_date_active      DATE;
   l_effective_date       DATE;
   l_offer_adj_name       VARCHAR2(120);

   CURSOR c_offer_adj_info (p_offer_adjustment_id IN NUMBER) IS
     select a.name,
           substr(a.description,1,240) description,
           lkp1.meaning offer_type,
           a.start_date_active,
           a.end_date_active,
           lkp.meaning settlement_name,
           b.effective_date,
           b.offer_adjustment_name
     from qp_list_headers a,
          ozf_offer_adjustments_vl b,
          ozf_lookups lkp,
          ozf_lookups lkp1,
          ozf_offers offr
     where a.list_header_id = b.list_header_id
         and a.list_header_id = offr.qp_list_header_id
     and  b.offer_adjustment_id  = p_offer_adjustment_id
     and lkp.lookup_code = b.settlement_code
     and lkp.lookup_type = 'OZF_OFFER_LUMPSUM_PAYMENT'
         and lkp1.lookup_code = offr.offer_type
         and lkp1.lookup_type = 'OZF_OFFER_TYPE';


   BEGIN
      ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
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
      l_offer_adjustment_id                  :=
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

      OPEN c_offer_adj_info( l_offer_adjustment_id);
      FETCH c_offer_adj_info INTO
            l_offer_code,
            l_offer_name,
            l_offer_type,
            l_start_date_active,
            l_end_date_active,
            l_settlement_name,
            l_effective_date,
            l_offer_adj_name;
      CLOSE c_offer_adj_info;

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPROVED_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPROVED_INFO');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('OFFER_TYPE', l_offer_type, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date_active, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date_active, FALSE);
      fnd_message.set_token ('SETTLEMENT_NAME', l_settlement_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);

      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);

      l_appr_notification        :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_appr_notification;
      document_type              := 'text/plain';
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'OZFGAPP',
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
--   4/25/2002         mgudivak        CREATION
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
   l_hyphen_pos1         NUMBER;
   l_rej_notification    VARCHAR2(10000);
   l_activity_type       VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_approval_type       VARCHAR2(30);
   l_approver            VARCHAR2(200);
   l_note                VARCHAR2(4000);
   l_subject             VARCHAR2(500);
   l_body                VARCHAR2(3500);
   l_requester           VARCHAR2(30);
   l_string              VARCHAR2 (1000);
   l_string1             VARCHAR2 (2500);
   l_string2             VARCHAR2 (2500);

   l_offer_adjustment_id  NUMBER;
   l_offer_name           VARCHAR2(240);
   l_offer_code           VARCHAR2(240);
   l_offer_type           VARCHAR2(240);
   l_settlement_name      VARCHAR2(240);
   l_start_date_active    DATE;
   l_end_date_active      DATE;
   l_effective_date       DATE;
   l_offer_adj_name       VARCHAR2(120);

   CURSOR c_offer_adj_info (p_offer_adjustment_id IN NUMBER) IS
     select a.name,
           substr(a.description,1,240) description,
           lkp1.meaning offer_type,
           a.start_date_active,
           a.end_date_active,
           lkp.meaning settlement_name,
           b.effective_date,
           b.offer_adjustment_name
     from qp_list_headers a,
          ozf_offer_adjustments_vl b,
          ozf_lookups lkp,
          ozf_lookups lkp1,
          ozf_offers offr
     where a.list_header_id = b.list_header_id
         and a.list_header_id = offr.qp_list_header_id
     and  b.offer_adjustment_id  = p_offer_adjustment_id
     and lkp.lookup_code = b.settlement_code
     and lkp.lookup_type = 'OZF_OFFER_LUMPSUM_PAYMENT'
         and lkp1.lookup_code = offr.offer_type
         and lkp1.lookup_type = 'OZF_OFFER_TYPE';


   BEGIN
      ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
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
      l_offer_adjustment_id      :=
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

      OPEN c_offer_adj_info( l_offer_adjustment_id);
      FETCH c_offer_adj_info INTO
            l_offer_code,
            l_offer_name,
            l_offer_type,
            l_start_date_active,
            l_end_date_active,
            l_settlement_name,
            l_effective_date,
            l_offer_adj_name;
      CLOSE c_offer_adj_info;

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_REJECTED_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_REJECTED_INFO');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('OFFER_TYPE', l_offer_type, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date_active, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date_active, FALSE);
      fnd_message.set_token ('SETTLEMENT_NAME', l_settlement_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      fnd_message.set_token('COMMENTS_NOTES', l_note, false);

      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);


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
            'OZFGAPP',
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
--   4/25/2002         mgudivak        CREATION


   PROCEDURE notify_approval_required (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              VARCHAR2 (100)
                                 :=    g_pkg_name
                                    || 'Notify_approval_required';

   l_hyphen_pos1         NUMBER;
   l_appreq_notification    VARCHAR2(10000);
   l_activity_type       VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_approval_type       VARCHAR2(30);
   l_approver            VARCHAR2(200);
   l_note                VARCHAR2(4000);
   l_subject             VARCHAR2(500);
   l_body                VARCHAR2(3500);
   l_requester           VARCHAR2(30);
   l_string              VARCHAR2 (1000);
   l_string1             VARCHAR2 (2500);
   l_string2             VARCHAR2 (2500);

   l_offer_adjustment_id  NUMBER;
   l_offer_name           VARCHAR2(240);
   l_offer_code           VARCHAR2(240);
   l_offer_type           VARCHAR2(240);
   l_settlement_name      VARCHAR2(240);
   l_start_date_active    DATE;
   l_end_date_active      DATE;
   l_effective_date       DATE;
   l_offer_adj_name       VARCHAR2(120);

   CURSOR c_offer_adj_info (p_offer_adjustment_id IN NUMBER) IS
     select a.name,
           substr(a.description,1,240) description,
           lkp1.meaning offer_type,
           a.start_date_active,
           a.end_date_active,
           lkp.meaning settlement_name,
           b.effective_date,
           b.offer_adjustment_name
     from qp_list_headers a,
          ozf_offer_adjustments_vl b,
          ozf_lookups lkp,
          ozf_lookups lkp1,
          ozf_offers offr
     where a.list_header_id = b.list_header_id
         and a.list_header_id = offr.qp_list_header_id
     and  b.offer_adjustment_id  = p_offer_adjustment_id
     and lkp.lookup_code = b.settlement_code
     and lkp.lookup_type = 'OZF_OFFER_LUMPSUM_PAYMENT'
         and lkp1.lookup_code = offr.offer_type
         and lkp1.lookup_type = 'OZF_OFFER_TYPE';


   BEGIN
      ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
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

      l_offer_adjustment_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_requester                :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTER'
            );

      l_note                     :=
            NVL(wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            ),'-');


      OPEN c_offer_adj_info( l_offer_adjustment_id);
      FETCH c_offer_adj_info INTO
            l_offer_code,
            l_offer_name,
            l_offer_type,
            l_start_date_active,
            l_end_date_active,
            l_settlement_name,
            l_effective_date,
            l_offer_adj_name;
      CLOSE c_offer_adj_info;

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPROVAL_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPROVAL_INFO');
      fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('OFFER_TYPE', l_offer_type, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date_active, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date_active, FALSE);
      fnd_message.set_token ('SETTLEMENT_NAME', l_settlement_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      fnd_message.set_token('COMMENTS_NOTES', l_note, false);

      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);

      l_appreq_notification      :=    l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2;
      document                   :=    document
                                    || l_appreq_notification;
      document_type              := 'text/plain';
      RETURN;

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'OZFGAPP',
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
--   4/25/2002        mgudivak        CREATION

   PROCEDURE notify_appr_req_reminder (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              VARCHAR2 (100)
                                 :=    g_pkg_name
                                    || 'notify_appr_req_reminder';
   l_hyphen_pos1         NUMBER;
   l_apprem_notification    VARCHAR2(10000);
   l_activity_type       VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_approval_type       VARCHAR2(30);
   l_approver            VARCHAR2(200);
   l_note                VARCHAR2(4000);
   l_subject             VARCHAR2(500);
   l_body                VARCHAR2(3500);
   l_requester           VARCHAR2(30);
   l_string              VARCHAR2 (1000);
   l_string1             VARCHAR2 (2500);
   l_string2             VARCHAR2 (2500);

   l_offer_adjustment_id  NUMBER;
   l_offer_name           VARCHAR2(240);
   l_offer_code           VARCHAR2(240);
   l_offer_type           VARCHAR2(240);
   l_settlement_name      VARCHAR2(240);
   l_start_date_active    DATE;
   l_end_date_active      DATE;
   l_effective_date       DATE;
   l_offer_adj_name       VARCHAR2(120);

   CURSOR c_offer_adj_info (p_offer_adjustment_id IN NUMBER) IS
     select a.name,
           substr(a.description,1,240) description,
           lkp1.meaning offer_type,
           a.start_date_active,
           a.end_date_active,
           lkp.meaning settlement_name,
           b.effective_date,
           b.offer_adjustment_name
     from qp_list_headers a,
          ozf_offer_adjustments_vl b,
          ozf_lookups lkp,
          ozf_lookups lkp1,
          ozf_offers offr
     where a.list_header_id = b.list_header_id
         and a.list_header_id = offr.qp_list_header_id
     and  b.offer_adjustment_id  = p_offer_adjustment_id
     and lkp.lookup_code = b.settlement_code
     and lkp.lookup_type = 'OZF_OFFER_LUMPSUM_PAYMENT'
         and lkp1.lookup_code = offr.offer_type
         and lkp1.lookup_type = 'OZF_OFFER_TYPE';


   BEGIN
      ozf_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
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
      l_offer_adjustment_id      :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_requester                :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_REQUESTER'
            );

      l_note                     :=
            NVL(wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            ),'-');


      OPEN c_offer_adj_info( l_offer_adjustment_id);
      FETCH c_offer_adj_info INTO
            l_offer_code,
            l_offer_name,
            l_offer_type,
            l_start_date_active,
            l_end_date_active,
            l_settlement_name,
            l_effective_date,
            l_offer_adj_name;
      CLOSE c_offer_adj_info;

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPR_REM_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPR_REM_INFO');
      fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
      fnd_message.set_token ('OFFER_TYPE', l_offer_type, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date_active, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date_active, FALSE);
      fnd_message.set_token ('SETTLEMENT_NAME', l_settlement_name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      fnd_message.set_token('COMMENTS_NOTES', l_note, false);

      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);


      l_apprem_notification      :=    l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2;
      document                   :=    document
                                    || l_apprem_notification;
      document_type              := 'text/plain';
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'OZFGAPP',
            'notify_appr_req_reminder',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_appr_req_reminder;

---------------------------------------------------------------------
-- PROCEDURE
--   Set_OffrAdj_Activity_details
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
--   4/25/2002         mgudivak        CREATION
-- End of Comments
--------------------------------------------------------------------

   PROCEDURE Set_OffrAdj_Activity_Details (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS

  l_api_version     CONSTANT NUMBER            := 1.0;
  l_api_name        CONSTANT VARCHAR2(30)      := 'Set_OffrAdj_Activity_Details';
  l_full_name       CONSTANT VARCHAR2(60)      := g_pkg_name || '.' || l_api_name;

      l_activity_id          NUMBER;
      l_activity_type        VARCHAR2 (30);
      l_approval_type        VARCHAR2 (30)                  := 'BUDGET';
      l_object_details       ams_gen_approval_pvt.objrectyp;
      l_approval_detail_id   NUMBER;
      l_approver_seq         NUMBER;
      l_return_status        VARCHAR2 (1);

      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (4000);
      l_error_msg            VARCHAR2 (4000);

      l_approver             VARCHAR2 (200);

      l_offer_type           VARCHAR2(30);
      l_settlement_name      VARCHAR2(240);
      l_effective_date       DATE;

      l_lookup_meaning       VARCHAR2(240);

      l_orig_stat_id         NUMBER;
      l_full_name            VARCHAR2 (60);
      l_fund_number          VARCHAR2 (30);
      l_requested_amt        NUMBER;
      l_string               VARCHAR2 (3000);

      l_list_header_id       NUMBER;
      l_offer_adj_name       VARCHAR2(120);

   CURSOR c_offer_adj_info (p_offer_adjustment_id IN NUMBER) IS
     select
           description,
           effective_date,
           list_header_id,
           offer_adjustment_name
     from ozf_offer_adjustments_vl
     where offer_adjustment_id = p_offer_adjustment_id;

-- changed budget_amount to use budget_amount_tc from the hardcoded 0, so that approval rules with a range would work.
   CURSOR c_get_activity_details(p_list_header_id IN NUMBER) IS
    SELECT  qlh.description,
    '' business_unit_id,
    '' country_code,
    OFF.custom_setup_id,
    nvl(OFF.budget_amount_tc,0),
    qlh.orig_org_id  org_id, --added for bugfix 8253195
    OFF.offer_type,--'' activity_type_code, -- Changed to fix bug#2288550
    '' priority,
    qlh.start_date_active,
    qlh.end_date_active ,
    OFF.transaction_currency_code ,
    OFF.owner_id
    FROM ozf_offers OFF,
         qp_list_headers_vl qlh
    WHERE OFF.qp_list_header_id=qlh.list_header_id
    AND qlh.list_header_id=p_list_header_id;

    CURSOR c_get_budget_detail(p_list_header_id NUMBER) IS
    SELECT fund.short_name,
           fund.business_unit_id,
           fund.custom_setup_id,
           NVL(offr.budget_amount_tc,0),
           fund.org_id,
           TO_CHAR(fund.category_id),
           fund.start_date_active,
           fund.end_date_active,
           fund.currency_code_tc,
           fund.owner
    FROM   ozf_funds_all_vl fund, ozf_offers offr
    WHERE  fund.fund_number = offr.offer_code
    AND    offr.qp_list_header_id = p_list_header_id;



    CURSOR c_budget_offer_yn(p_list_header_id NUMBER) IS
    SELECT NVL(budget_offer_yn, 'N')
    FROM   ozf_offers
    WHERE  qp_list_header_id = p_list_header_id;

    l_budget_offer_yn VARCHAR2(1);

   BEGIN
      fnd_msg_pub.initialize;

    l_activity_id              :=
            wf_engine.getitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_ACTIVITY_ID'
            );

     OPEN c_offer_adj_info ( l_activity_id);
     FETCH c_offer_adj_info INTO
              l_object_details.description,
              l_effective_date,
              l_list_header_id,
              l_offer_adj_name;
     CLOSE c_offer_adj_info ;

     OPEN  c_budget_offer_yn(l_list_header_id);
     FETCH c_budget_offer_yn INTO l_budget_offer_yn;
     CLOSE c_budget_offer_yn;

     IF l_budget_offer_yn = 'N' THEN
       l_activity_type := 'OFFR';
       OPEN c_get_activity_details(l_list_header_id);
       FETCH c_get_activity_details INTO
     		l_object_details.name,
     		l_object_details.business_unit_id,
     		l_object_details.country_code,
     		l_object_details.setup_type_id,
    	 	l_object_details.total_header_amount,
     		l_object_details.org_id ,
     		l_object_details.object_type,
     		l_object_details.priority,
     		l_object_details.start_date ,
     		l_object_details.end_date,
     		l_object_details.currency,
                l_object_details.owner_id ;
       CLOSE c_get_activity_details ;
     ELSIF l_budget_offer_yn = 'Y' THEN
       l_activity_type := 'RFRQ';
       OPEN  c_get_budget_detail(l_list_header_id);
       FETCH c_get_budget_detail INTO
     		l_object_details.name,
     		l_object_details.business_unit_id,
     		l_object_details.setup_type_id,
    	 	l_object_details.total_header_amount,
     		l_object_details.org_id,
     		l_object_details.object_type,
     		l_object_details.start_date,
     		l_object_details.end_date,
     		l_object_details.currency,
                l_object_details.owner_id;
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

            --- set all the subjects here

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_FORWARD_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_object_details.name, FALSE);
      l_string      := SUBSTR(fnd_message.get,1,1000);

       wf_engine.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'FYI_SUBJECT'
         ,avalue   => l_string
       );

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPROVAL_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_object_details.name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);

       wf_engine.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'APP_SUBJECT'
         ,avalue   => l_string
       );


      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_APPROVED_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_object_details.name, FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);

       wf_engine.setitemattrtext(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'APRV_SUBJECT'
          ,avalue   => l_string
       );

      fnd_message.set_name ('OZF', 'OZF_OFFRADJ_NTF_REJECTED_SUBJ');
      fnd_message.set_token ('ADJUSTMENT_NAME', l_offer_adj_name, FALSE);
      fnd_message.set_token ('OFFER_NAME', l_object_details.name , FALSE);
      fnd_message.set_token ('EFFECTIVE_DATE', l_effective_date, FALSE);
      l_string := Substr(FND_MESSAGE.Get,1,1000);

       wf_engine.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'REJECT_SUBJECT'
         ,avalue   => l_string
       );

       -- BUG 2352621

       l_lookup_meaning := ozf_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER','OFFRADJ');

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

       -- End 2352621

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
            'OZF_FundApproval_pvt',
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
   END Set_OffrAdj_Activity_Details;


---------------------------------------------------------------------
-- PROCEDURE
--  Update_OffrAdj_Status
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
--   4/25/2002         mgudivak        CREATION
-- End of Comments
-------------------------------------------------------------------

   PROCEDURE Update_OffrAdj_Status (
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
      l_error_msg               VARCHAR2 (4000);
      l_api_name       CONSTANT VARCHAR2 (30)               := 'Update_OffrAdj_Status';
      l_full_name      CONSTANT VARCHAR2 (60)               :=    g_pkg_name
                                                               || '.'
                                                               || l_api_name;

      l_next_status_code        VARCHAR2(30);
      l_approved_date           DATE;
      l_approval_status         VARCHAR2 (12);
      l_object_version_number   NUMBER;
      l_offer_adjustment_id     NUMBER;
      l_effective_date          DATE;

      CURSOR c_effective_date(p_offer_adjustment_id IN NUMBER) IS
      SELECT effective_date
      FROM   ozf_offer_adjustments_b
      WHERE  offer_adjustment_id = p_offer_adjustment_id ;

  l_user_id                  NUMBER;
  l_resp_id                  NUMBER;
  l_appl_id                  NUMBER;
  l_security_group_id        NUMBER;

BEGIN
  l_user_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                          , itemkey  => itemkey
                                          , aname    => 'USER_ID'
                                          );
  l_resp_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                          , itemkey  => itemkey
                                          , aname    => 'RESPONSIBILITY_ID'
                                          );
  l_appl_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                          , itemkey  => itemkey
                                          , aname    => 'APPLICATION_ID'
                                          );
  l_security_group_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                                    , itemkey  => itemkey
                                                    , aname    => 'SECURITY_GROUP_ID'
                                                    );

  IF funcmode = 'RUN' THEN
    l_approval_status            :=
               wf_engine.getitemattrtext (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'UPDATE_GEN_STATUS'
               );

         IF l_approval_status = 'APPROVED' THEN

            l_next_status_code := 'ACTIVE';
            ozf_utility_pvt.debug_message (   l_full_name || l_approval_status);

         ELSIF l_approval_status = 'REJECTED' THEN

            l_next_status_code := 'REJECTED';

         ELSE
            -- BUG 2352621
            l_next_status_code := 'DRAFT';

         END IF;

         l_object_version_number    :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_OBJECT_VERSION_NUMBER'
               );

         l_offer_adjustment_id      :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_ACTIVITY_ID'
               );

         OPEN c_effective_date(l_offer_adjustment_id);
         FETCH c_effective_date INTO l_effective_date;
         CLOSE c_effective_date;

         ozf_utility_pvt.debug_message ( l_full_name || l_next_status_code || l_approval_status);

         IF  ( l_next_status_code = 'ACTIVE' )
         THEN
--             IF (l_effective_date < SYSDATE) THEN
               -- bug 2989406. initialize as GEN_WF does not do it
               FND_GLOBAL.apps_initialize(user_id      => l_user_id
                                        , resp_id      => l_resp_id
                                        , resp_appl_id => l_appl_id
                                  --, security_group_id => l_security_group_id
                                  );
               --  Call Discounts Update API only when effective_date is less than sysdate
                    OZF_Offer_Backdate_PVT.Update_Offer_Discounts
                        (
                             p_init_msg_list => FND_API.G_FALSE
                            ,p_api_version   => l_api_version
                            ,p_commit        =>  FND_API.G_FALSE
                            ,x_return_status => l_return_status
                            ,x_msg_count     => l_msg_count
                            ,x_msg_data      => l_msg_data
                            ,p_offer_adjustment_id  => l_offer_adjustment_id
                            ) ;
--             END IF;
                            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                RAISE FND_API.G_EXC_ERROR;
                            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
                            -- for active status , call api which activates/ closes adjustment depending on effective date
                            OZF_Offer_Backdate_PVT.close_adjustment
                            (
                              p_offer_adjustment_id         => l_offer_adjustment_id
                                , x_return_status              => l_return_status
                                , x_msg_count                  => l_msg_count
                                , x_msg_data                   => l_msg_data
                            );
                            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                RAISE FND_API.G_EXC_ERROR;
                            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
    else
    -- for rejected or some other status update the status to next status code
         UPDATE ozf_offer_adjustments_b
         SET    status_code = l_next_status_code ,
--                approved_date = sysdate ,
                object_version_number = l_object_version_number+1
         WHERE offer_adjustment_id = l_offer_adjustment_id;
         END IF;
-- Changes done by mthumu
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        resultout := 'COMPLETE:SUCCESS';
      ELSE
        RAISE FND_API.G_EXC_ERROR;
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
      ozf_utility_pvt.debug_message (
            l_full_name
         || ': l_return_status'
         || l_return_status
      );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count => l_msg_count,
           p_data  => l_msg_data);

      ams_gen_approval_pvt.Handle_Err(
           p_itemtype  => itemtype   ,
           p_itemkey   => itemkey    ,
           p_msg_count => l_msg_count, -- Number of error Messages
           p_msg_data  => l_msg_data ,
           p_attr_name => 'AMS_ERROR_MSG',
           x_error_msg => l_error_msg);

      wf_core.context('ozf_offeradj_approval_pvt',
                     'Update_OffrAdj_Status',
                     itemtype, itemkey,to_char(actid),l_error_msg);

      resultout := 'COMPLETE:ERROR';

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

      wf_core.context('ozf_offeradj_approval_pvt',
                      'Update_OffrAdj_Status',
                      itemtype, itemkey,to_char(actid),l_error_msg);

      resultout := 'COMPLETE:ERROR';

END Update_OffrAdj_Status;


END ozf_offeradj_approval_pvt;

/
