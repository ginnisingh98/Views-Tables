--------------------------------------------------------
--  DDL for Package Body AMW_AP_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_AP_APPROVAL_PVT" AS
/* $Header: amwvaapb.pls 120.0 2005/05/31 21:51:22 appldev noship $ */

   --  Start of Comments
   --
   -- NAME
   --   amw_AP_Approval_PVT
   --
   -- PURPOSE
   --   This package contains all transactions to be done for
   --   AP Approvals in Oracle Internal APs
   --
   -- HISTORY
   --   6/4/2003        MUMU PANDE          CREATION
   --   6/25/2003       KARTHI MUTHUSWAMY   Modified update_AP_status()
   --   7/2/2003        mpande              Updated for All Message and formatting
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'amw_AP_Approval_PVT';
   g_file_name   CONSTANT VARCHAR2 (15) := 'amwvaapb.pls';
   g_ap_mode     CONSTANT VARCHAR2 (15) := 'WORKFLOW';
   g_debug       CONSTANT BOOLEAN
              := fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_high);
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
--                      - Oracle Internal Controls Generic Apporval
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
   PROCEDURE notify_requestor_fyi (
      document_id     IN              VARCHAR2,
      display_type    IN              VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name           CONSTANT VARCHAR2 (61)
                                        := g_pkg_name || 'Notify_Requestor_FYI';
      l_ap_rev_id          NUMBER;
      l_ap_id              NUMBER;
      l_ap_name            VARCHAR2 (240);
      l_hyphen_pos1        NUMBER;
      l_fyi_notification   VARCHAR2 (10000);
      l_object_type        VARCHAR2 (30);
      l_item_type          VARCHAR2 (100);
      l_item_key           VARCHAR2 (100);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (4000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_start_date         DATE;
      l_requestor_id       NUMBER;
      l_string2            VARCHAR2 (2500);
      l_requested_amt      NUMBER;
      l_object_meaning     VARCHAR2 (80);
      l_requestor_name     VARCHAR2 (260);
      CURSOR c_ap_rec (p_ap_rev_id IN NUMBER) IS
         SELECT audit_procedure_id, NAME, creation_date, requestor_id
           FROM amw_audit_procedures_vl
          WHERE audit_procedure_rev_id = p_ap_rev_id;
   BEGIN
      IF g_debug THEN
         amw_utility_pvt.debug_message (   l_api_name
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
      l_item_type                := SUBSTR (document_id, 1, l_hyphen_pos1 - 1);
      l_item_key                 := SUBSTR (document_id, l_hyphen_pos1 + 1);
      l_object_type              :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_TYPE'
                                   );
      l_object_meaning           :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVAL_OBJECT_MEANING'
                                   );
      l_ap_rev_id                :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_ID'
                                   );
      /*7/2/2003 mpande not required
      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMW_NOTES_FROM_REQUESTOR'
            );
       */
      l_approver                 :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVER_DISPLAY_NAME'
                                   );
      OPEN c_ap_rec (l_ap_rev_id);
      FETCH c_ap_rec
       INTO l_ap_id, l_ap_name, l_start_date, l_requestor_id;
      CLOSE c_ap_rec;
      l_requestor_name           :=
                              amw_utility_pvt.get_employee_name (l_requestor_id);
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_REQUESTOR_FYI_SUB');
      fnd_message.set_token ('NAME', l_ap_name, FALSE);
      fnd_message.set_token ('OBJECT_TYPE', l_object_meaning, FALSE);
      l_string                   := SUBSTR (fnd_message.get, 1, 1000);
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'FYI_SUBJECT',
         avalue=> l_string
      );
      */
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_AP_REQ_INFO');
      fnd_message.set_token ('AP_NAME', l_ap_name, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('REQUESTOR_NAME', l_requestor_name, FALSE);
      l_string1                  := SUBSTR (fnd_message.get, 1, 2500);
        /*
        l_note := wf_engine.getitemattrtext(
                     itemtype => l_item_type
                    ,itemkey => l_item_key
                    ,aname => 'NOTE');


        l_forwarder :=
           wf_engine.getitemattrtext(
              itemtype => l_item_type
             ,itemkey => l_item_key
             ,aname => 'AMW_FORWARD_FROM_USERNAME');
      */
        --  IF (display_type = 'text/plain') THEN
      l_fyi_notification         :=
         SUBSTR (   l_string
                 || fnd_global.local_chr (10)
                 || l_string1
                 || fnd_global.local_chr (10)
                 || l_string2,
                 1,
                 10000
                );
      document                   := document || l_fyi_notification;
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
         wf_core.CONTEXT ('AMWGAPP',
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
--                      - Oracle Internal Controls Generic Apporval
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
----------------------------------------------------------------------------
   PROCEDURE notify_requestor_of_approval (
      document_id     IN              VARCHAR2,
      display_type    IN              VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name            CONSTANT VARCHAR2 (100)
                                := g_pkg_name || 'Notify_Requestor_of_approval';
      l_ap_rev_id           NUMBER;
      l_ap_id               NUMBER;
      l_ap_name             VARCHAR2 (240);
      l_hyphen_pos1         NUMBER;
      l_appr_notification   VARCHAR2 (10000);
      l_object_type         VARCHAR2 (30);
      l_item_type           VARCHAR2 (80);
      l_item_key            VARCHAR2 (80);
      l_approval_type       VARCHAR2 (30);
      l_approver            VARCHAR2 (200);
      l_note                VARCHAR2 (4000);
      l_approver_note       VARCHAR2 (4000);
      l_string              VARCHAR2 (1000);
      l_string1             VARCHAR2 (2500);
      l_start_date          DATE;
      l_requestor_name      VARCHAR2 (360);
      l_string2             VARCHAR2 (2500);
      l_object_meaning      VARCHAR2 (80);
      l_requestor_id        NUMBER;
      l_approval_date       DATE;
      CURSOR c_ap_rec (p_ap_rev_id IN NUMBER) IS
         SELECT audit_procedure_id, NAME, creation_date,
                requestor_id                             -- --s hould be a name
           FROM amw_audit_procedures_vl
          WHERE audit_procedure_rev_id = p_ap_rev_id;
   BEGIN
      IF g_debug THEN
         amw_utility_pvt.debug_message (   l_api_name
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
      l_item_type                := SUBSTR (document_id, 1, l_hyphen_pos1 - 1);
      l_item_key                 := SUBSTR (document_id, l_hyphen_pos1 + 1);
      l_object_type              :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_TYPE'
                                   );
      l_object_meaning           :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVAL_OBJECT_MEANING'
                                   );
      l_ap_rev_id                :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_ID'
                                   );
      l_note                     :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_NOTES_FROM_REQUESTOR'
                                   );
      l_approver                 :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVER_DISPLAY_NAME'
                                   );
      OPEN c_ap_rec (l_ap_rev_id);
      FETCH c_ap_rec
       INTO l_ap_id, l_ap_name, l_start_date, l_requestor_id;
      CLOSE c_ap_rec;
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_REQUESTOR_APP_SUB');
      fnd_message.set_token ('NAME', l_ap_name, FALSE);
      fnd_message.set_token ('OBJECT_TYPE', l_ap_name, FALSE);
      l_string                   := SUBSTR (fnd_message.get, 1, 1000);
      l_requestor_name           :=
                              amw_utility_pvt.get_employee_name (l_requestor_id);
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_AP_REQ_INFO');
      fnd_message.set_token ('AP_NAME', l_ap_name, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('REQUESTOR_NAME', l_requestor_name, FALSE);
      l_string1                  := SUBSTR (fnd_message.get, 1, 2500);
        /*
        l_note := wf_engine.getitemattrtext(
                     itemtype => l_item_type
                    ,itemkey => l_item_key
                    ,aname => 'NOTE');


        l_forwarder :=
           wf_engine.getitemattrtext(
              itemtype => l_item_type
             ,itemkey => l_item_key
             ,aname => 'AMW_FORWARD_FROM_USERNAME');
      */
      l_approver_note            :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'APPROVAL_NOTE'
                                   );
      SELECT SYSDATE
        INTO l_approval_date
        FROM DUAL;
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_REQUESTOR_ADDENDUM');
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('COMMENTS', l_approver_note, FALSE);
      fnd_message.set_token ('APPROVAL_DATE', l_approval_date, FALSE);
      l_string2                  := SUBSTR (fnd_message.get, 1, 2500);
      --  IF (display_type = 'text/plain') THEN
      l_appr_notification        :=
         SUBSTR (   l_string
                 || fnd_global.local_chr (10)
                 || l_string1
                 || fnd_global.local_chr (10)
                 || l_string2,
                 1,
                 10000
                );
      document                   := document || l_appr_notification;
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
         wf_core.CONTEXT ('AMWGAPP',
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
--                      - Oracle Internal Controls Generic Apporval
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
-------------------------------------------------------------------------------
   PROCEDURE notify_requestor_of_rejection (
      document_id     IN              VARCHAR2,
      display_type    IN              VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name           CONSTANT VARCHAR2 (100)
                               := g_pkg_name || 'Notify_Requestor_of_rejection';
      l_ap_rev_id          NUMBER;
      l_ap_id              NUMBER;
      l_ap_name            VARCHAR2 (240);
      l_hyphen_pos1        NUMBER;
      l_rej_notification   VARCHAR2 (10000);
      l_object_type        VARCHAR2 (30);
      l_item_type          VARCHAR2 (80);
      l_item_key           VARCHAR2 (80);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (4000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_start_date         DATE;
      l_requestor_name     VARCHAR2 (360);
      l_string2            VARCHAR2 (2500);
      l_object_meaning     VARCHAR2 (80);
      l_requestor_id       NUMBER;
      CURSOR c_ap_rec (p_ap_rev_id IN NUMBER) IS
         SELECT audit_procedure_id, NAME, creation_date, requestor_id
           FROM amw_audit_procedures_vl
          WHERE audit_procedure_rev_id = p_ap_rev_id;
   BEGIN
      IF g_debug THEN
         amw_utility_pvt.debug_message (   l_api_name
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
      l_item_type                := SUBSTR (document_id, 1, l_hyphen_pos1 - 1);
      l_item_key                 := SUBSTR (document_id, l_hyphen_pos1 + 1);
      l_object_type              :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_TYPE'
                                   );
      l_object_meaning           :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVAL_OBJECT_MEANING'
                                   );
      l_ap_rev_id                :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_ID'
                                   );
      l_note                     :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_NOTES_FROM_REQUESTOR'
                                   );
      l_approver                 :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVER'
                                   );
      /*
      l_requestor                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMW_REQUESTOR'
            );
      */
      OPEN c_ap_rec (l_ap_rev_id);
      FETCH c_ap_rec
       INTO l_ap_id, l_ap_name, l_start_date, l_requestor_id;
      CLOSE c_ap_rec;
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_REQUESTOR_REJ_SUB');
      fnd_message.set_token ('NAME', l_ap_name, FALSE);
      fnd_message.set_token ('OBJECT_TYPE', l_object_meaning, FALSE);
      l_string                   := SUBSTR (fnd_message.get, 1, 1000);
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'REJECT_SUBJECT',
         avalue=> l_string
      );
      */
      l_requestor_name           :=
                              amw_utility_pvt.get_employee_name (l_requestor_id);
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_AP_REQ_INFO');
      fnd_message.set_token ('AP_NAME', l_ap_name, FALSE);
      --fnd_message.set_token ('OWNER', l_requestor, FALSE);
      --fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('APPROVER_NAME', '-', FALSE);
      fnd_message.set_token ('REQUESTOR_NAME', '-', FALSE);
      --fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      l_string1                  := SUBSTR (fnd_message.get, 1, 2500);
        /*
        l_note := wf_engine.getitemattrtext(
                     itemtype => l_item_type
                    ,itemkey => l_item_key
                    ,aname => 'NOTE');


        l_forwarder :=
           wf_engine.getitemattrtext(
              itemtype => l_item_type
             ,itemkey => l_item_key
             ,aname => 'AMW_FORWARD_FROM_USERNAME');
      */
      l_note                     :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'APPROVAL_NOTE'
                                   );
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_APPROVER_NOTE');
      fnd_message.set_token ('NOTES_FROM_APPROVER', l_note, FALSE);
      l_string2                  := SUBSTR (fnd_message.get, 1, 2500);
      l_rej_notification         :=
         SUBSTR (   l_string
                 || fnd_global.local_chr (10)
                 || l_string1
                 || fnd_global.local_chr (10)
                 || l_string2,
                 1,
                 10000
                );
      document                   := document || l_rej_notification;
      document_type              := 'text/plain';
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.CONTEXT ('AMWGAPP',
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
--                      - Oracle Internal Controls Generic Apporval
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
   PROCEDURE notify_approval_required (
      document_id     IN              VARCHAR2,
      display_type    IN              VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              CONSTANT VARCHAR2 (100)
                                    := g_pkg_name || 'Notify_approval_required';
      l_ap_rev_id             NUMBER;
      l_ap_id                 NUMBER;
      l_ap_name               VARCHAR2 (240);
      l_hyphen_pos1           NUMBER;
      l_appreq_notification   VARCHAR2 (10000);
      l_object_type           VARCHAR2 (30);
      l_item_type             VARCHAR2 (30);
      l_item_key              VARCHAR2 (30);
      l_approval_type         VARCHAR2 (30);
      l_forwarder             VARCHAR2 (150);
      l_note                  VARCHAR2 (4000);
      l_string                VARCHAR2 (1000);
      l_string1               VARCHAR2 (2500);
      l_approver              VARCHAR2 (200);
      l_start_date            DATE;
      l_requestor_id          NUMBER;
      l_string2               VARCHAR2 (2500);
      l_approval_date         VARCHAR2 (30);
      l_lookup_meaning        VARCHAR2 (80);
      l_requestor_name        VARCHAR2 (360);
      CURSOR c_ap_rec (p_ap_rev_id IN NUMBER) IS
         SELECT audit_procedure_id, NAME, creation_date,
                requestor_id                            -- needs to be the name
           FROM amw_audit_procedures_vl
          WHERE audit_procedure_rev_id = p_ap_rev_id;
   BEGIN
      IF g_debug THEN
         amw_utility_pvt.debug_message (   l_api_name
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
      l_item_type                := SUBSTR (document_id, 1, l_hyphen_pos1 - 1);
      l_item_key                 := SUBSTR (document_id, l_hyphen_pos1 + 1);
      l_object_type              :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_TYPE'
                                   );
      l_ap_rev_id                :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_ID'
                                   );
      l_note                     :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_NOTES_FROM_REQUESTOR'
                                   );
      l_approver                 :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVER_DISPLAY_NAME'
                                   );
            /*
      l_requestor                :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMW_REQUESTOR'
            );
            */
      l_lookup_meaning           :=
                    amw_utility_pvt.get_lookup_meaning ('AMW_OBJECT_TYPE', 'AP');
      OPEN c_ap_rec (l_ap_rev_id);
      FETCH c_ap_rec
       INTO l_ap_id, l_ap_name, l_start_date, l_requestor_id;
      CLOSE c_ap_rec;
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token ('NAME', l_ap_name, FALSE);
      fnd_message.set_token ('OBJECT_TYPE', l_lookup_meaning, FALSE);
      l_string                   := SUBSTR (fnd_message.get, 1, 1000);
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'APP_SUBJECT',
         avalue=> l_string
      );
      */
      l_requestor_name           :=
                              amw_utility_pvt.get_employee_name (l_requestor_id);
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_AP_REQ_INFO');
      fnd_message.set_token ('AP_NAME', l_ap_name, FALSE);
      fnd_message.set_token ('REQUESTOR_NAME', l_requestor_name, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      --fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      l_string1                  := SUBSTR (fnd_message.get, 1, 2500);
      l_note                     :=
         NVL (wf_engine.getitemattrtext (itemtype      => l_item_type,
                                         itemkey       => l_item_key,
                                         aname         => 'AMW_PREV_APPROVER_NOTE'
                                        ),
              '-'
             );
      l_forwarder                :=
         NVL (wf_engine.getitemattrtext (itemtype      => l_item_type,
                                         itemkey       => l_item_key,
                                         aname         => 'AMW_PREV_APPROVER_DISP_NAME'
                                        ),
              '-'
             );
      l_approval_date            :=
         NVL (TO_CHAR (wf_engine.getitemattrdate (itemtype      => l_item_type,
                                                  itemkey       => l_item_key,
                                                  aname         => 'AMW_APPROVAL_DATE'
                                                 )
                      ),
              '-'
             );
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_APPROVER_ADDENDUM');
      fnd_message.set_token ('PREV_APPROVER_NAME', l_forwarder, FALSE);
      fnd_message.set_token ('APPROVAL_DATE', l_approval_date, FALSE);
      fnd_message.set_token ('COMMENTS', l_note, FALSE);
      l_string2                  := SUBSTR (fnd_message.get, 1, 2500);
      --  IF (display_type = 'text/plain') THEN
      l_appreq_notification      :=
            l_string
         || fnd_global.local_chr (10)
         || l_string1
         || fnd_global.local_chr (10)
         || l_string2;
      document                   := document || l_appreq_notification;
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
         wf_core.CONTEXT ('AMWGAPP',
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
--                      - Oracle Internal Controls Generic Apporval
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
   PROCEDURE notify_appr_req_reminder (
      document_id     IN              VARCHAR2,
      display_type    IN              VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              CONSTANT VARCHAR2 (100)
                                    := g_pkg_name || 'notify_appr_req_reminder';
      l_ap_rev_id             NUMBER;
      l_ap_id                 NUMBER;
      l_ap_name               VARCHAR2 (240);
      l_hyphen_pos1           NUMBER;
      l_apprem_notification   VARCHAR2 (10000);
      l_object_type           VARCHAR2 (30);
      l_item_type             VARCHAR2 (80);
      l_item_key              VARCHAR2 (80);
      l_approval_type         VARCHAR2 (30);
      l_approver              VARCHAR2 (200);
      l_note                  VARCHAR2 (4000);
      l_forwarder             VARCHAR2 (150);
      l_string                VARCHAR2 (1000);
      l_string1               VARCHAR2 (2500);
      l_start_date            DATE;
      l_requestor             VARCHAR2 (360);
      l_string2               VARCHAR2 (2500);
      l_approval_date         VARCHAR2 (30);
      l_object_meaning        VARCHAR2 (80);
      CURSOR c_ap_rec (p_ap_rev_id IN NUMBER) IS
         SELECT audit_procedure_id, NAME,
                creation_date requestor_id              -- needs to be the name
           FROM amw_audit_procedures_vl
          WHERE audit_procedure_rev_id = p_ap_rev_id;
   BEGIN
      IF g_debug THEN
         amw_utility_pvt.debug_message (   l_api_name
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
      l_item_type                := SUBSTR (document_id, 1, l_hyphen_pos1 - 1);
      l_item_key                 := SUBSTR (document_id, l_hyphen_pos1 + 1);
      l_object_type              :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_TYPE'
                                   );
      l_object_meaning           :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVAL_OBJECT_MEANING'
                                   );
      l_ap_rev_id                :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_OBJECT_ID'
                                   );
      l_note                     :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_NOTES_FROM_REQUESTOR'
                                   );
      l_approver                 :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_APPROVER_DISPLAY_NAME'
                                   );
      l_requestor                :=
         wf_engine.getitemattrtext (itemtype      => l_item_type,
                                    itemkey       => l_item_key,
                                    aname         => 'AMW_REQUESTOR'
                                   );
      OPEN c_ap_rec (l_ap_rev_id);
      FETCH c_ap_rec
       INTO l_ap_id, l_ap_name, l_start_date;
      CLOSE c_ap_rec;
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token ('AP_NAME', l_ap_name, FALSE);
      fnd_message.set_token ('OBJECT_TYPE', l_object_meaning, FALSE);
      l_string                   := SUBSTR (fnd_message.get, 1, 1000);
      /*
      wf_engine.setitemattrtext (
         itemtype=> l_item_type,
         itemkey=> l_item_key,
         aname => 'APP_SUBJECT',
         avalue=> l_string
      );
      */
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_AP_REQ_INFO');
      fnd_message.set_token ('AP_NAME', l_ap_name, FALSE);
      fnd_message.set_token ('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token ('REQUESTOR_NAME', l_approver, FALSE);
      --fnd_message.set_token ('DESCRIPTION', l_note, FALSE);
      l_string1                  := SUBSTR (fnd_message.get, 1, 2500);
      l_note                     :=
         NVL (wf_engine.getitemattrtext (itemtype      => l_item_type,
                                         itemkey       => l_item_key,
                                         aname         => 'AMW_PREV_APPROVER_NOTE'
                                        ),
              '-'
             );
      l_forwarder                :=
         NVL (wf_engine.getitemattrtext (itemtype      => l_item_type,
                                         itemkey       => l_item_key,
                                         aname         => 'AMW_PREV_APPROVER_DISP_NAME'
                                        ),
              '-'
             );
      l_approval_date            :=
         NVL (TO_CHAR (wf_engine.getitemattrdate (itemtype      => l_item_type,
                                                  itemkey       => l_item_key,
                                                  aname         => 'AMW_APPROVAL_DATE'
                                                 )
                      ),
              '-'
             );
      fnd_message.set_name ('AMW', 'AMW_WF_NTF_APPROVER_ADDENDUM');
      fnd_message.set_token ('PREV_APPROVER_NAME', l_forwarder, FALSE);
      fnd_message.set_token ('APPROVAL_DATE', l_approval_date, FALSE);
      fnd_message.set_token ('COMMENTS', l_note, FALSE);
      l_string2                  := SUBSTR (fnd_message.get, 1, 2500);
        /*
        l_note := wf_engine.getitemattrtext(
                     itemtype => l_item_type
                    ,itemkey => l_item_key
                    ,aname => 'NOTE');


        l_forwarder :=
           wf_engine.getitemattrtext(
              itemtype => l_item_type
             ,itemkey => l_item_key
             ,aname => 'AMW_FORWARD_FROM_USERNAME');
      */
        --  IF (display_type = 'text/plain') THEN
      l_apprem_notification      :=
            l_string
         || fnd_global.local_chr (10)
         || l_string1
         || fnd_global.local_chr (10)
         || l_string2;
      document                   := document || l_apprem_notification;
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
         wf_core.CONTEXT ('AMWGAPP',
                          'notify_appr_req_reminder',
                          l_item_type,
                          l_item_key
                         );
         RAISE;
   END notify_appr_req_reminder;
---------------------------------------------------------------------
-- PROCEDURE
--   Set_AP_OBJECT_details
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
--   6/4/2003        MUMU PANDE        CREATION
-- End of Comments
--------------------------------------------------------------------
   PROCEDURE set_ap_object_details (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS
      l_object_id        NUMBER;
      l_object_type      CONSTANT VARCHAR2 (30)   := 'AP';
      l_approval_type    CONSTANT VARCHAR2 (30)   := 'OBJECT';
      l_return_status    VARCHAR2 (1);
      l_msg_count        NUMBER;
      l_msg_data         VARCHAR2 (4000);
      l_error_msg        VARCHAR2 (4000);
      l_ap_name          VARCHAR2 (240);
      l_full_name        VARCHAR2 (60);
      l_start_date       DATE;
      l_ap_id            NUMBER;
      l_approver         VARCHAR2 (200);
      l_string           VARCHAR2 (3000);
      l_lookup_meaning   VARCHAR2 (240);
      CURSOR c_ap_rec (p_ap_rev_id IN NUMBER) IS
         SELECT audit_procedure_id, NAME, creation_date
           FROM amw_audit_procedures_vl
          WHERE audit_procedure_rev_id = p_ap_rev_id;
   BEGIN
      fnd_msg_pub.initialize;
      l_object_id                :=
         wf_engine.getitemattrnumber (itemtype      => itemtype,
                                      itemkey       => itemkey,
                                      aname         => 'AMW_OBJECT_ID'
                                     );
      IF (funcmode = 'RUN') THEN
         -- OPen cursor here and get the values
         OPEN c_ap_rec (l_object_id);
         FETCH c_ap_rec
          INTO l_ap_id, l_ap_name, l_start_date;
         CLOSE c_ap_rec;
         l_lookup_meaning           :=
                   amw_utility_pvt.get_lookup_meaning ('AMW_OBJECT_TYPE', 'AP');
         --- set all the subjects here
         fnd_message.set_name ('AMW', 'AMW_WF_NTF_REQUESTOR_FYI_SUB');
         fnd_message.set_token ('NAME', l_ap_name, FALSE);
         fnd_message.set_token ('OBJECT_TYPE', l_lookup_meaning, FALSE);
         l_string                   := SUBSTR (fnd_message.get, 1, 1000);
         wf_engine.setitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'FYI_SUBJECT',
                                    avalue        => l_string
                                   );
         fnd_message.set_name ('AMW', 'AMW_WF_NTF_REQUESTOR_APP_SUB');
         fnd_message.set_token ('NAME', l_ap_name, FALSE);
         fnd_message.set_token ('OBJECT_TYPE', l_lookup_meaning, FALSE);
         l_string                   := SUBSTR (fnd_message.get, 1, 1000);
         wf_engine.setitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'APRV_SUBJECT',
                                    avalue        => l_string
                                   );
         fnd_message.set_name ('AMW', 'AMW_WF_NTF_REQUESTOR_REJ_SUB');
         fnd_message.set_token ('NAME', l_ap_name, FALSE);
         fnd_message.set_token ('OBJECT_TYPE', l_lookup_meaning, FALSE);
         l_string                   := SUBSTR (fnd_message.get, 1, 1000);
         wf_engine.setitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'REJECT_SUBJECT',
                                    avalue        => l_string
                                   );
         fnd_message.set_name ('AMW', 'AMW_WF_NTF_APPROVER_OF_REQ_SUB');
         fnd_message.set_token ('NAME', l_ap_name, FALSE);
         fnd_message.set_token ('OBJECT_TYPE', l_lookup_meaning, FALSE);
         l_string                   := SUBSTR (fnd_message.get, 1, 1000);
         wf_engine.setitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'APP_SUBJECT',
                                    avalue        => l_string
                                   );
         wf_engine.setitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'AMW_APPROVAL_OBJECT_MEANING',
                                    avalue        => l_lookup_meaning
                                   );
         wf_engine.setitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'AMW_APPROVAL_OBJECT_NAME',
                                    avalue        => l_ap_name
                                   );
         resultout                  := 'COMPLETE:SUCCESS';
      ELSE
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => l_msg_count,
                                    p_data         => l_msg_data
                                   );
         amw_gen_approval_pvt.handle_err
                         (p_itemtype       => itemtype,
                          p_itemkey        => itemkey,
                          p_msg_count      => l_msg_count,
                                                     -- Number of error Messages
                          p_msg_data       => l_msg_data,
                          p_attr_name      => 'AMW_ERROR_MSG',
                          x_error_msg      => l_error_msg
                         );
         wf_core.CONTEXT ('amw_gen_approval_pvt',
                          'Set_OBJECT_Details',
                          itemtype,
                          itemkey,
                          actid,
                          l_error_msg
                         );
         -- RAISE FND_API.G_EXC_ERROR;
         resultout                  := 'COMPLETE:ERROR';
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
         wf_core.CONTEXT ('amw_APApproval_pvt',
                          'Set_AP_OBJECT_Details',
                          itemtype,
                          itemkey,
                          actid,
                          funcmode,
                          l_error_msg
                         );
         RAISE;
      WHEN OTHERS THEN
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => l_msg_count,
                                    p_data         => l_msg_data
                                   );
         RAISE;
   END set_ap_object_details;
---------------------------------------------------------------------
-- PROCEDURE
--  Update_AP_Status
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
--   6/4/2003        MUMU PANDE        CREATION
--   6/17/2003        KARTHI MUTHUSWAMY Added code to update AP based on approval status
--   6/25/2003        KARTHI MUTHUSWAMY Fixed funcmode = 'RUN' logic not returning resultout
-- End of Comments
-------------------------------------------------------------------
   PROCEDURE update_ap_status (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS
      l_status_code             VARCHAR2 (30);
      l_return_status           VARCHAR2 (1);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (4000);
      l_api_name       CONSTANT VARCHAR2 (30)   := 'Update_AP_Status';
      l_full_name      CONSTANT VARCHAR2 (60)
                                             := g_pkg_name || '.' || l_api_name;
      l_update_status           VARCHAR2 (12);
      l_error_msg               VARCHAR2 (4000);
      l_object_version_number   NUMBER;
      l_ap_rev_id               NUMBER;
      l_validation_level        NUMBER;
      l_approver                VARCHAR2 (320);
      l_requestor_id            NUMBER;
      l_approver_id             NUMBER;
      l_old_appr_ap_rev_id      NUMBER;
      l_approval_date           DATE;
      l_ap_id                   NUMBER;
      CURSOR c_old_appr_ap (p_ap_rev_id IN NUMBER) IS
         SELECT ap2.audit_procedure_rev_id
           FROM amw_audit_procedures_b ap1, amw_audit_procedures_b ap2
          WHERE ap1.audit_procedure_id = ap2.audit_procedure_id
            AND ap1.audit_procedure_rev_id = p_ap_rev_id
            AND ap2.curr_approved_flag = 'Y'
            AND ap2.latest_revision_flag = 'N';
   BEGIN
      SAVEPOINT update_ap_status;
      l_return_status     := fnd_api.g_ret_sts_success;
      l_validation_level        := fnd_api.g_valid_level_full;
      IF (funcmode = 'RUN') THEN
           -- Item attribute UPDATE_GEN_STATUS will be'set to APPROVED'if the Object is approved
         -- and 'REJECTED' if the object is rejected.
         l_update_status            :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'UPDATE_GEN_STATUS'
                                      );
         l_approver                 :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'AMW_APPROVER'
                                      );
         l_approver_id              :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'AMW_APPROVER_ID'
                                      );
         l_requestor_id             :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'AMW_REQUESTOR_ID'
                                      );
         l_object_version_number    :=
            wf_engine.getitemattrnumber (itemtype      => itemtype,
                                         itemkey       => itemkey,
                                         aname         => 'AMW_OBJECT_VERSION_NUMBER'
                                        );
         l_ap_rev_id                :=
            wf_engine.getitemattrnumber (itemtype      => itemtype,
                                         itemkey       => itemkey,
                                         aname         => 'AMW_OBJECT_ID'
                                        );
         OPEN c_old_appr_ap (l_ap_rev_id);
         FETCH c_old_appr_ap
         INTO l_old_appr_ap_rev_id;
         CLOSE c_old_appr_ap;

         IF (l_update_status = 'APPROVED') THEN
            -- Update the status of the AP object to 'A' -- Approved
            l_approval_date := SYSDATE;
            UPDATE amw_audit_procedures_b
               SET approval_status = 'A',
                   object_version_number = object_version_number + 1,
                   curr_approved_flag = 'Y',
                   latest_revision_flag = 'Y',
                   approval_date = l_approval_date
             WHERE audit_procedure_rev_id = l_ap_rev_id
               AND object_version_number = l_object_version_number;
            IF l_old_appr_ap_rev_id IS NOT NULL THEN
               UPDATE amw_audit_procedures_b
                  SET object_version_number = object_version_number + 1,
                      curr_approved_flag = 'N',
                      latest_revision_flag = 'N',
                      end_date = l_approval_date
                WHERE audit_procedure_rev_id = l_old_appr_ap_rev_id;
            END IF;
            -- AMW.D Update the control associations (set approval_date)
            select audit_procedure_id into l_ap_id
            from amw_audit_procedures_b
            where audit_procedure_rev_id = l_ap_rev_id;
            update amw_ap_associations
                set approval_date = l_approval_date
                where audit_procedure_id = l_ap_id
                 and object_type = 'CTRL'
                 and approval_date is null;

                update amw_ap_associations
                set deletion_approval_date = l_approval_date
                where audit_procedure_id = l_ap_id
                 and object_type = 'CTRL'
                 and deletion_date is not null
                 and deletion_approval_date is null;
         ELSIF (l_update_status = 'REJECTED') THEN
            -- Update the status of the AP object to 'R' -- Rejected
             IF l_old_appr_ap_rev_id IS NOT NULL THEN
               UPDATE amw_audit_procedures_b
                  SET object_version_number = object_version_number + 1,
                      latest_revision_flag = 'Y'
                WHERE audit_procedure_rev_id = l_old_appr_ap_rev_id;
               UPDATE amw_audit_procedures_b
                  SET approval_status = 'R',
                      object_version_number = object_version_number + 1,
                      curr_approved_flag = 'N',
                      latest_revision_flag = 'N',
                      end_date = SYSDATE
                WHERE audit_procedure_rev_id = l_ap_rev_id
                  AND object_version_number = l_object_version_number;
            ELSE
               UPDATE amw_audit_procedures_b
                  SET approval_status = 'R',
                      object_version_number = object_version_number + 1,
                      curr_approved_flag = 'N',
                      latest_revision_flag = 'Y',
                      end_date = SYSDATE
                WHERE audit_procedure_rev_id = l_ap_rev_id
                  AND object_version_number = l_object_version_number;
            END IF;
         ELSE
            -- Update the status of the AP object to 'D' -- Draft
            UPDATE amw_audit_procedures_b
               SET approval_status = 'D',
                   object_version_number = object_version_number + 1
             --curr_approved_flag   = 'N',
             --latest_revision_flag ='Y'
            WHERE  audit_procedure_rev_id = l_ap_rev_id
               AND object_version_number = l_object_version_number;
         END IF;
/**************************IS THIS REQUIRED********************/
/*
        --amw_APs_pkg.update_AP (
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF G_DEBUG THEN
               amw_utility_pvt.debug_message(l_full_name || ' failed to update AP to status ' || l_status_code);
            END IF;
            amw_gen_approval_pvt.handle_err (
               p_itemtype=> itemtype,
               p_itemkey=> itemkey,
               p_msg_count=> l_msg_count, -- Number of error Messages
               p_msg_data=> l_msg_data,
               p_attr_name=> 'AMW_ERROR_MSG',
               x_error_msg=> l_error_msg
            );
            resultout := 'COMPLETE:ERROR';
         ELSE
            resultout := 'COMPLETE:SUCCESS';
         END IF;
*/
/**************************IS THIS REQUIRED********************/
         resultout                  := 'COMPLETE:SUCCESS';
         RETURN;
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
/*
      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false,
         p_count=> l_msg_count,
         p_data=> l_msg_data
      );
      IF G_DEBUG THEN
         amw_utility_pvt.debug_message (
            l_full_name
         || ': l_return_status'
         || l_return_status
      );
      END IF;
*/
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO update_ap_status;
         resultout                  := 'COMPLETE:ERROR';
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => l_msg_count,
                                    p_data         => l_msg_data
                                   );
         amw_gen_approval_pvt.handle_err
                         (p_itemtype       => itemtype,
                          p_itemkey        => itemkey,
                          p_msg_count      => l_msg_count,
                                                     -- Number of error Messages
                          p_msg_data       => l_msg_data,
                          p_attr_name      => 'AMW_ERROR_MSG',
                          x_error_msg      => l_error_msg
                         );
   --RAISE;
   END update_ap_status;
END amw_ap_approval_pvt;

/
