--------------------------------------------------------
--  DDL for Package Body BEN_CWB_WF_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_WF_NTF" AS
/* $Header: bencwbfy.pkb 120.0 2005/05/28 03:58:55 appldev noship $ */
   g_package     VARCHAR2 (60) := 'BEN_CWB_WF_NTF';
   g_itemtype    VARCHAR2 (60) := 'BENCWBFY';
   g_wfprocess   VARCHAR2 (60) := 'CWBFYINTF';

   FUNCTION get_issue_bdgt_ntf_comment(p_transaction_id NUMBER)
     RETURN VARCHAR2
   IS
   l_comment VARCHAR2(2000);
   l_transaction_id VARCHAR2(200);

   CURSOR c1(v_transaction_id IN VARCHAR2) IS
       SELECT attribute40
         FROM ben_transaction
        WHERE transaction_type = 'BDGTNTF'
          AND transaction_id = to_number(v_transaction_id);
   BEGIN
   l_transaction_id := wf_engine.getitemattrtext (itemtype      => 'BENCWBFY',
                                    itemkey       => p_transaction_id,
                                    aname         => 'TRANSACTION_ID'
                                   );
   OPEN c1(l_transaction_id);
   FETCH c1 INTO l_comment;
   CLOSE c1;
   RETURN l_comment;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT (g_package,
                          'get_issue_bdgt_ntf_comment',
                          l_transaction_id,
                          'Error occured in while getting the isssue budget comments'
                         );
         RAISE;
   END;

   FUNCTION get_approve_ntf_comment(p_transaction_id NUMBER)
     RETURN VARCHAR2
   IS
   l_comment VARCHAR2(2000);
   l_transaction_id VARCHAR2(200);
   CURSOR c1(v_transaction_id IN VARCHAR2) IS
       SELECT attribute40
         FROM ben_transaction
        WHERE transaction_type = 'APPRNTF'
          AND transaction_id = to_number(v_transaction_id);
   BEGIN
   l_transaction_id := wf_engine.getitemattrtext (itemtype      => 'BENCWBFY',
                                    itemkey       => p_transaction_id,
                                    aname         => 'TRANSACTION_ID'
                                   );
   OPEN c1(l_transaction_id);
   FETCH c1 INTO l_comment;
   CLOSE c1;
   RETURN l_comment;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT (g_package,
                          'get_issue_approve_ntf_comment',
                          l_transaction_id,
                          'Error occured in while getting the approval comments'
                         );
         RAISE;
   END;

   FUNCTION get_access_ntf_comment(p_transaction_id NUMBER)
     RETURN VARCHAR2
   IS
   l_comment VARCHAR2(2000);
   l_transaction_id VARCHAR2(200);
   CURSOR c1(v_transaction_id IN VARCHAR2) IS
       SELECT attribute40
         FROM ben_transaction
        WHERE transaction_id = to_number(v_transaction_id);
   BEGIN
   l_transaction_id := wf_engine.getitemattrtext (itemtype      => 'BENCWBFY',
                                    itemkey       => p_transaction_id,
                                    aname         => 'TRANSACTION_ID'
                                   );
   OPEN c1(l_transaction_id);
   FETCH c1 INTO l_comment;
   CLOSE c1;
   RETURN l_comment;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT (g_package,
                          'get_access_ntf_comment',
                          l_transaction_id,
                          'Error occured in while getting the access comments'
                         );
         RAISE;
   END;

   FUNCTION get_profile_value (NAME VARCHAR2)
      RETURN VARCHAR2
   IS
      l_profile_value   VARCHAR2 (2000);
   BEGIN
      fnd_profile.get (NAME, l_profile_value);
      RETURN l_profile_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT (g_package,
                          'get_profile_value',
                          NAME,
                          'Error occured in while getting the profile value'
                         );
         RAISE;
   END;

   FUNCTION get_plan_name (p_group_per_in_ler_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c1
      IS
         SELECT dsgn.NAME
           FROM ben_per_in_ler pil, ben_cwb_pl_dsgn dsgn
          WHERE pil.per_in_ler_id = p_group_per_in_ler_id
            AND pil.group_pl_id = dsgn.pl_id
            AND pil.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
            AND dsgn.group_pl_id = dsgn.pl_id
            AND dsgn.group_oipl_id = -1;

      l_pl   c1%ROWTYPE;
   BEGIN
      OPEN c1;

      FETCH c1
       INTO l_pl;

      CLOSE c1;

      RETURN l_pl.NAME;
   END;

   FUNCTION get_worksheet_manager_name (p_group_per_in_ler_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c1
      IS
         SELECT per.full_name
           FROM ben_per_in_ler pil,
                per_all_people_f per
          WHERE pil.per_in_ler_id = p_group_per_in_ler_id
            AND pil.ws_mgr_id = per.person_id
            AND sysdate between per.effective_start_date and per.effective_end_date;

      l_mgr           c1%ROWTYPE;
   BEGIN
      OPEN c1;

      FETCH c1
       INTO l_mgr;
      CLOSE c1;
         RETURN l_mgr.full_name;
   END;

   FUNCTION get_person_name (p_group_per_in_ler_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c1
      IS
         SELECT info.full_name, info.brief_name
           FROM ben_cwb_person_info info
          WHERE info.group_per_in_ler_id = p_group_per_in_ler_id;

      l_info           c1%ROWTYPE;
      l_name_profile   VARCHAR (10);
   BEGIN
      OPEN c1;

      FETCH c1
       INTO l_info;

      CLOSE c1;

      l_name_profile := get_profile_value ('BEN_DISPLAY_EMPLOYEE_NAME');

      IF (l_name_profile = 'BN')
      THEN
         RETURN l_info.brief_name;
      ELSE
         RETURN l_info.full_name;
      END IF;
   END;

   FUNCTION get_for_period(p_group_per_in_ler_id IN NUMBER)
     RETURN VARCHAR2
   IS
      CURSOR c11
      IS
         SELECT nvl(dsgn.wthn_yr_start_dt,dsgn.yr_perd_start_dt)||' - '||
         nvl(dsgn.wthn_yr_end_dt,dsgn.yr_perd_end_dt) forPeriod
           FROM ben_per_in_ler pil,
                ben_cwb_pl_dsgn dsgn
          WHERE pil.per_in_ler_id = p_group_per_in_ler_id
            AND pil.group_pl_id = dsgn.group_pl_id
            AND pil.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
            AND dsgn.oipl_id = -1
            AND dsgn.group_pl_id = dsgn.pl_id
            AND dsgn.group_oipl_id = dsgn.oipl_id;
        l_info   c11%ROWTYPE;
   BEGIN
       OPEN c11;
       FETCH c11 INTO l_info;
       CLOSE c11;

       RETURN l_info.forPeriod;
    END;


   FUNCTION get_ntf_conf_value (p_message_type IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_name    VARCHAR2 (30)                                         := NULL;
      ret_val   VARCHAR2 (30)                                         := NULL;
      attr      wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type;
   BEGIN
      IF (p_message_type = 'BUDGET_ISSUED')
      THEN
         l_name := 'BDGT_ISS_NTF_CONF';
      END IF;

      IF (p_message_type = 'WS_REJECTED')
      THEN
         l_name := 'WS_REJ_NTF_CONF';
      END IF;

      IF (p_message_type = 'ACCESS')
      THEN
         l_name := 'ACCESS_NTF_CONF';
      END IF;

      IF (p_message_type = 'WS_SUBMITTED')
      THEN
         l_name := 'WS_SUB_NTF_CONF';
      END IF;

      IF l_name IS NOT NULL
      THEN
         wf_item_attributes_vl_pub.fetch_item_attributes
                                         (p_item_type                      => g_itemtype,
                                          p_name                           => l_name,
                                          p_wf_item_attributes_vl_tbl      => attr
                                         );
         ret_val := attr (1).text_default;
      END IF;

      RETURN ret_val;
   END;

   FUNCTION get_fnd_user_name (p_person_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_fnd_user_name   VARCHAR2 (2000);
      l_proc            VARCHAR2 (100)  := 'get_fnd_user_name';

      CURSOR c2
      IS
         SELECT user_name
           FROM fnd_user
          WHERE employee_id = p_person_id;
   BEGIN
      hr_utility.set_location ('Entering ' || g_package || ' : ' || l_proc,
                               3000
                              );
      hr_utility.TRACE ('p_person_id : ' || p_person_id);

      OPEN c2;

      FETCH c2
       INTO l_fnd_user_name;

      IF c2%NOTFOUND
      THEN
         hr_utility.TRACE ('fnd person does not exist ' || p_person_id);
         wf_core.RAISE ('fnd person does not exist ' || p_person_id);
      END IF;

      CLOSE c2;

      hr_utility.TRACE ('l_fnd_user_name : ' || l_fnd_user_name);
      hr_utility.set_location ('Exiting ' || g_package || ' : ' || l_proc,
                               3000
                              );
      RETURN l_fnd_user_name;
   EXCEPTION
      WHEN OTHERS
      THEN
        /* wf_core.CONTEXT (g_package,
                          'get_fnd_user_name',
                          p_person_id,
                          'Error occured in while getting the fnd_user_name'
                         );
         RAISE;*/

        return null;
   END;


--
--  get_curren_notification_id
--     This function gives the notification id for a paticular user.
--  IN
--     p_item_key      -- the item key
--     p_fnd_user_name -- fnd user name to whom the notification was sent.
--  RETURN
--     notification id
--
  FUNCTION get_current_notification_id (
    p_item_key        IN   VARCHAR2
  , p_fnd_user_name   IN   VARCHAR2
  )
    RETURN NUMBER IS
    l_notification_id   NUMBER;
    l_proc              VARCHAR2 (100) := 'get_current_notification_id';

    CURSOR c1 IS
      SELECT notification_id
        FROM wf_item_activity_statuses
       WHERE item_key = p_item_key
         AND item_type = g_itemtype
         AND assigned_user = p_fnd_user_name;
  BEGIN
    hr_utility.set_location ('Entering ' || g_package || ' : ' || l_proc, 2000);
    hr_utility.TRACE ('p_item_key : ' || p_item_key);
    hr_utility.TRACE ('p_fnd_user_name : ' || p_fnd_user_name);

    IF p_fnd_user_name IS NULL THEN
      hr_utility.TRACE ('p_fnd_user_name is null');
      wf_core.RAISE ('p_fnd_user_name is null');
    END IF;

    OPEN c1;
    FETCH c1 INTO l_notification_id;

    IF c1%NOTFOUND THEN
      hr_utility.TRACE (   'Notification id not present for the user '
                        || p_fnd_user_name
                        || 'for the item key'
                        || p_item_key);
      wf_core.RAISE (   'Notification id is not present for the user '
                     || p_fnd_user_name
                     || ' for the item key'
                     || p_item_key);
    END IF;

    CLOSE c1;
    hr_utility.TRACE ('l_notification_id : ' || l_notification_id);
    hr_utility.set_location ('Exiting ' || g_package || ' : ' || l_proc, 2000);
    RETURN l_notification_id;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT (g_package
                     , 'get_current_notification_id'
                     , p_item_key
                     , p_fnd_user_name
                     , 'Error occured in while getting the get_current_notification_id'
                      );
      RAISE;
  END;

   PROCEDURE close_ntf (
      itemtype   IN              VARCHAR2,
      itemkey    IN              VARCHAR2,
      actid      IN              NUMBER,
      funcmode   IN              VARCHAR2,
      RESULT     OUT NOCOPY      VARCHAR2
   )
   IS
      l_from_fnd_user_name   VARCHAR2 (2000);
      l_notification_id      VARCHAR2 (2000);
      l_status               VARCHAR2 (60);
   BEGIN
      l_from_fnd_user_name :=
         wf_engine.getitemattrtext (itemtype      => 'BENCWBFY',
                                    itemkey       => itemkey,
                                    aname         => 'RCVR_USER_NAME'
                                   );
      l_notification_id :=
         get_current_notification_id (p_item_key           => itemkey,
                                      p_fnd_user_name      => l_from_fnd_user_name
                                     );

      BEGIN
         SELECT n.status
           INTO l_status
           FROM wf_notifications n
          WHERE n.notification_id = l_notification_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            wf_core.token ('NID',
                           wf_notification.getsubject (l_notification_id)
                          );
            wf_core.RAISE ('WFNTF_NID');
      END;

      IF (l_status = 'OPEN')
      THEN
         wf_notification.CLOSE (nid            => l_notification_id,
                                responder      => l_from_fnd_user_name
                               );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT (g_package,
                          'ntf_closed',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RESULT := '';
         RAISE;
   END;

   PROCEDURE set_common_item_attributes (
      p_message_type          IN   VARCHAR2,
      p_item_key              IN   NUMBER,
      p_rcvr_person_id        IN   NUMBER,
      p_from_person_id        IN   NUMBER,
      p_group_per_in_ler_id   IN   NUMBER,
      p_transaction_id        IN   NUMBER
   )
   IS
      l_rcvr_fnd_user_name   VARCHAR2 (2000);
      l_from_fnd_user_name   VARCHAR2 (2000);
      l_err_name             VARCHAR2 (30);
      l_err_msg              VARCHAR2 (2000);
      l_err_stack            VARCHAR2 (32000);
      l_for_period           VARCHAR2(30);
      l_proc                 VARCHAR2 (100)   := 'set_common_item_attributes';
   BEGIN
      hr_utility.set_location ('Entering ' || g_package || ':' || l_proc,
                               100);
      l_rcvr_fnd_user_name := get_fnd_user_name (p_rcvr_person_id);
      hr_utility.TRACE ('l_rcvr_fnd_user_name ' || l_rcvr_fnd_user_name);

      l_for_period := get_for_period (p_group_per_in_ler_id);
      hr_utility.TRACE ('l_for_period ' || l_for_period);

      l_from_fnd_user_name := get_fnd_user_name (p_from_person_id);
      hr_utility.TRACE ('l_from_fnd_user_name ' || l_from_fnd_user_name);

      wf_engine.setitemattrtext (itemtype      => g_itemtype,
                                 itemkey       => p_item_key,
                                 aname         => 'MESSAGE_TYPE',
                                 avalue        => p_message_type
                                );
      hr_utility.TRACE (   ' item attribute MESSAGE_TYPE is set to '
                        || p_message_type
                       );
      wf_engine.setitemattrtext (itemtype      => g_itemtype,
                                 itemkey       => p_item_key,
                                 aname         => 'RCVR_USER_NAME',
                                 avalue        => l_rcvr_fnd_user_name
                                );
      hr_utility.TRACE (   ' item attribute RCVR_USER_NAME is set to '
                        || l_rcvr_fnd_user_name
                       );
      wf_engine.setitemattrtext (itemtype      => g_itemtype,
                                 itemkey       => p_item_key,
                                 aname         => 'RCVR_PERSON_NAME',
                                 avalue        => get_person_name
                                                        (p_group_per_in_ler_id)
                                );
      hr_utility.TRACE (   ' item attribute RCVR_PERSON_NAME is set to '
                        || l_rcvr_fnd_user_name
                       );
      wf_engine.setitemattrtext
                               (itemtype      => 'BENCWBFY',
                                itemkey       => p_item_key,
                                aname         => 'MANAGER_NAME',
                                avalue        => get_worksheet_manager_name
                                                        (p_group_per_in_ler_id)
                               );
      wf_engine.setitemattrtext
                               (itemtype      => 'BENCWBFY',
                                itemkey       => p_item_key,
                                aname         => 'PLAN_NAME',
                                avalue        => get_plan_name
                                                        (p_group_per_in_ler_id)
                               );
      wf_engine.setitemattrtext (itemtype        => 'BENCWBFY',
                                       itemkey   => p_item_key,
                                       aname     => 'FOR_PERIOD',
                                       avalue    => l_for_period
                                      );

      hr_utility.TRACE (   ' item attribute l_for_period is set to '
                              || l_for_period
                       );

      hr_utility.TRACE (' item attribute PLAN_NAME is set ');
      wf_engine.setitemattrtext (itemtype      => 'BENCWBFY',
                                 itemkey       => p_item_key,
                                 aname         => 'GROUP_PER_IN_LER_ID',
                                 avalue        => p_group_per_in_ler_id
                                );
      hr_utility.TRACE (   ' item attribute GROUP_PER_IN_LER_ID is set to '
                        || p_group_per_in_ler_id
                       );
      wf_engine.setitemattrtext (itemtype      => 'BENCWBFY',
                                 itemkey       => p_item_key,
                                 aname         => 'TRANSACTION_ID',
                                 avalue        => p_transaction_id
                                );
      hr_utility.TRACE (   ' item attribute TRANSACTION_ID is set to '
                        || p_transaction_id
                       );
      wf_engine.setitemattrtext (itemtype      => g_itemtype,
                                 itemkey       => p_item_key,
                                 aname         => 'FROM_ROLE',
                                 avalue        => l_from_fnd_user_name
                                );
      hr_utility.TRACE (   ' item attribute FROM_ROLE is set to '
                        || l_from_fnd_user_name
                       );
      hr_utility.set_location ('Exiting ' || g_package || ':' || l_proc, 100);
   END;

   PROCEDURE set_access_due_item_attributes (p_item_key IN NUMBER)
   IS
   BEGIN
      hr_utility.TRACE ('p_item_key ' || p_item_key);

      wf_engine.setitemattrtext (itemtype      => g_itemtype,
                                 itemkey       => p_item_key,
                                 aname         => 'FYI_COMMENTS',
                                 avalue        => get_access_ntf_comment(p_item_key)
                                );
   END;

   PROCEDURE set_appr_ntf_item_attribute (p_item_key IN NUMBER)
   IS
   BEGIN
      hr_utility.TRACE ('p_item_key ' || p_item_key);

      wf_engine.setitemattrtext (itemtype      => g_itemtype,
                                 itemkey       => p_item_key,
                                 aname         => 'FYI_COMMENTS',
                                 avalue        => get_approve_ntf_comment(p_item_key)
                                );
   END;

   PROCEDURE set_iss_budgt_item_attributes (p_item_key IN NUMBER)
   IS
   BEGIN
      hr_utility.TRACE ('p_item_key ' || p_item_key);

      wf_engine.setitemattrtext (itemtype      => g_itemtype,
                                 itemkey       => p_item_key,
                                 aname         => 'FYI_COMMENTS',
                                 avalue        => get_issue_bdgt_ntf_comment(p_item_key)
                                );
   END;

   PROCEDURE cwb_fyi_ntf_api (
      p_transaction_id        IN   NUMBER,
      p_message_type          IN   VARCHAR2,
      p_rcvr_person_id        IN   NUMBER,
      p_from_person_id        IN   NUMBER,
      p_group_per_in_ler_id   IN   NUMBER
   )
   IS
      l_proc             VARCHAR2 (61)    := 'cwb_fyi_ntf_api';
      l_itemkey          NUMBER;
      l_rcvr_user_name   VARCHAR2 (60);
      l_err_name         VARCHAR2 (30);
      l_err_msg          VARCHAR2 (2000);
      l_err_stack        VARCHAR2 (32000);
   BEGIN

      hr_utility.set_location ('Entering ' || g_package || ':' || l_proc, 10);

      --
      -- A unique itemkey is generated for every workflow transaction
      --
      SELECT ben_cwb_wf_ntf_s.NEXTVAL
        INTO l_itemkey
        FROM DUAL;

      hr_utility.TRACE ('l_itemkey : ' || l_itemkey);

      IF l_itemkey IS NULL
      THEN
         hr_utility.TRACE ('l_itemkey is null');
         fnd_message.set_name ('BEN', 'BEN_93399_CWB_NTF_ITEM_KEY_ERR');
         fnd_message.raise_error;
      END IF;

      IF p_rcvr_person_id IS NULL
      THEN
         hr_utility.TRACE ('p_rcvr_person_id is null');
         fnd_message.set_name ('BEN', 'BEN_93400_CWB_NTF_NO_PERSON_ID');
         fnd_message.raise_error;
      END IF;

      hr_utility.TRACE ('p_rcvr_person_id : ' || p_rcvr_person_id);

      BEGIN
         wf_engine.createprocess (itemtype      => g_itemtype,
                                  itemkey       => l_itemkey,
                                  process       => g_wfprocess
                                 );
         hr_utility.TRACE (   'Workflow process '
                           || g_wfprocess
                           || ' for itemtype '
                           || g_itemtype
                           || ' itemkey '
                           || l_itemkey
                           || ' is created'
                          );
      EXCEPTION
         WHEN OTHERS
         THEN
            wf_core.get_error (l_err_name, l_err_msg, l_err_stack);

            IF (l_err_name IS NOT NULL)
            THEN
               hr_utility.TRACE (   'Following Workflow error has occured'
                                 || l_err_msg
                                 || 'Error stack for this is '
                                 || l_err_stack
                                );
               fnd_message.set_name ('BEN', 'BEN_93401_CWB_NTF_WF_ERR');
               fnd_message.set_token ('ERR_NAME', l_err_name, FALSE);
               fnd_message.set_token ('ERR_STACK',
                                      SUBSTRB (l_err_stack, 25000),
                                      FALSE
                                     );
               wf_core.CLEAR;
               fnd_message.raise_error;
            ELSE
               hr_utility.TRACE
                  (   'A general error has occured while creating the workflow process '
                   || 'and it is not a worflow error'
                  );
               fnd_message.set_name ('BEN', 'BEN_93402_CWB_NTF_CRE_PROC_ERR');
               fnd_message.raise_error;
            END IF;
      END;

      --
       -- setting the common item attributes.
       --
      set_common_item_attributes
                              (p_message_type             => p_message_type,
                               p_item_key                 => l_itemkey,
                               p_rcvr_person_id           => p_rcvr_person_id,
                               p_from_person_id           => p_from_person_id,
                               p_group_per_in_ler_id      => p_group_per_in_ler_id,
                               p_transaction_id           => p_transaction_id
                              );
      hr_utility.TRACE ('common item attributes are set');

      --
      -- setting issued budget item attributes.
      --
      IF (   p_message_type = 'BUDGET_ISSUED'
          OR p_message_type = 'BUDGET_ISSUED_LLM'
         )
      THEN
         set_iss_budgt_item_attributes (p_item_key => l_itemkey);
         hr_utility.TRACE
                        ('issued budget item attributes are set successfully');
      END IF;

          --
      -- setting approval item attributes.
      --
      IF (p_message_type = 'WS_REJECTED')
      THEN
         set_appr_ntf_item_attribute (p_item_key => l_itemkey);
         hr_utility.TRACE ('approval item attributes are set successfully');
      END IF;

         --

         --
      IF (p_message_type = 'WS_RECALLED')
      THEN
         set_appr_ntf_item_attribute (p_item_key => l_itemkey);
         hr_utility.TRACE ('RECALLED item attributes are set successfully');
      END IF;

         --
      -- setting access and due dates item attributes.
      --
      IF (p_message_type = 'ACCESS')
      THEN
         set_access_due_item_attributes (p_item_key => l_itemkey);
         hr_utility.TRACE
                 ('access and due dates item attributes are set successfully');
      END IF;

      IF (p_message_type = 'WS_SUBMITTED')
      THEN
         set_appr_ntf_item_attribute (p_item_key => l_itemkey);
         hr_utility.TRACE
                         ('ws submitted item attributes are set successfully');
      END IF;

      BEGIN
         wf_engine.startprocess (itemtype      => g_itemtype,
                                 itemkey       => l_itemkey);
         hr_utility.TRACE (   'Workflow process '
                           || g_wfprocess
                           || ' for itemtype '
                           || g_itemtype
                           || ' itemkey '
                           || l_itemkey
                           || ' is started'
                          );
      EXCEPTION
         WHEN OTHERS
         THEN
            wf_core.get_error (l_err_name, l_err_msg, l_err_stack);

            IF (l_err_name IS NOT NULL)
            THEN
               hr_utility.TRACE (   'Following Workflow error has occured'
                                 || l_err_msg
                                 || 'Follwing is the error stack '
                                 || l_err_stack
                                );
               fnd_message.set_name ('BEN', 'BEN_93401_CWB_NTF_WF_ERR');
               fnd_message.set_token ('ERR_NAME', l_err_name, FALSE);
               fnd_message.set_token ('ERR_STACK',
                                      SUBSTRB (l_err_stack, 25000),
                                      FALSE
                                     );
               wf_core.CLEAR;
               fnd_message.raise_error;
            ELSE
               hr_utility.TRACE
                  (   'A general error has occured while starting the workflow process '
                   || 'and it is not a worflow error'
                  );
               fnd_message.set_name ('BEN', 'BEN_93404_CWB_NTF_STRT_PRC_ERR');
               fnd_message.set_token ('ITEM_KEY', l_itemkey);
               fnd_message.raise_error;
            END IF;
      END;

      hr_utility.set_location ('Exiting ' || g_package || ':' || l_proc, 10);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

--
-- cwb_plan_comp_ntf_api
--    Need to design this notification
--
   PROCEDURE cwb_plan_comp_ntf_api (
      p_transaction_id        IN   NUMBER,
      p_message_type          IN   VARCHAR2,
      p_from_person_id        IN   NUMBER,
      p_group_per_in_ler_id   IN   NUMBER
   )
   IS
      CURSOR c1
      IS
         SELECT role_id, role_name
           FROM pqh_roles
          WHERE role_type_cd = 'CWB';

      CURSOR c2 (l_role_id NUMBER)
      IS
         SELECT pei.person_id person_id, ppf.full_name person_name,
                usr.user_name user_name, usr.user_id user_id
           FROM per_people_extra_info pei,
                per_all_people_f ppf,
                fnd_user usr,
                pqh_roles rls
          WHERE information_type = 'PQH_ROLE_USERS'
            AND pei.person_id = ppf.person_id
            AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date
                                    AND ppf.effective_end_date
            AND usr.employee_id = ppf.person_id
            AND rls.role_id = TO_NUMBER (pei.pei_information3)
            AND NVL (pei.pei_information5, 'Y') = 'Y'
            AND rls.role_id = l_role_id;

      l_proc      VARCHAR2 (61) := g_package || ':' || 'plan_comp_ntf';
      l_itemkey   NUMBER;
   BEGIN
      hr_utility.set_location (l_proc || ' Entering ', 10);

      FOR i IN c1
      LOOP
         hr_utility.set_location ('checking people for role ' || i.role_name,
                                  20
                                 );

         FOR j IN c2 (i.role_id)
         LOOP
            hr_utility.set_location (   'person '
                                     || j.person_name
                                     || ' has this role ',
                                     20
                                    );
            hr_utility.set_location ('user ' || j.user_name
                                     || ' has this role ',
                                     20
                                    );
            cwb_fyi_ntf_api (p_transaction_id           => p_transaction_id,
                             p_message_type             => p_message_type,
                             p_rcvr_person_id           => j.person_id,
                             p_from_person_id           => p_from_person_id,
                             p_group_per_in_ler_id      => p_group_per_in_ler_id
                            );
         END LOOP;
      END LOOP;

      hr_utility.set_location (l_proc || ' Exiting ', 100);
   END;

   PROCEDURE which_message (
      itemtype   IN              VARCHAR2,
      itemkey    IN              VARCHAR2,
      actid      IN              NUMBER,
      funcmode   IN              VARCHAR2,
      RESULT     OUT NOCOPY      VARCHAR2
   )
   IS
      l_message_type   VARCHAR2 (60);
      l_proc           VARCHAR2 (100) := 'which_message';
   BEGIN
      hr_utility.set_location ('Entering ' || g_package || ' : ' || l_proc,
                               10000
                              );
      hr_utility.TRACE ('itemtype : ' || itemtype);
      hr_utility.TRACE ('itemkey : ' || itemkey);
      hr_utility.TRACE ('actid : ' || actid);
      hr_utility.TRACE ('funcmode : ' || funcmode);

      IF (funcmode = 'RUN')
      THEN
         l_message_type :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'MESSAGE_TYPE'
                                      );

         IF (   l_message_type = 'ACCESS'
             OR l_message_type = 'BUDGET_ISSUED'
             OR l_message_type = 'WS_SUBMITTED'
             OR l_message_type = 'WS_REJECTED'
             OR l_message_type = 'WS_RECALLED'
            )
         THEN
            RESULT := 'COMPLETE:' || l_message_type;
            RETURN;
         END IF;
      END IF;

      IF (funcmode = 'CANCEL')
      THEN
         RESULT := 'COMPLETE';
         RETURN;
      END IF;

      hr_utility.TRACE ('l_message_type : ' || l_message_type);
      RESULT := '';
      hr_utility.set_location ('Exiting ' || g_package || ' : ' || l_proc,
                               10000
                              );
      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT (g_package,
                          'which_message',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RESULT := '';
         RAISE;
   END;

   PROCEDURE is_notification_sent (
      itemtype   IN              VARCHAR2,
      itemkey    IN              VARCHAR2,
      actid      IN              NUMBER,
      funcmode   IN              VARCHAR2,
      RESULT     OUT NOCOPY      VARCHAR2
   )
   IS
      l_message_type   VARCHAR2 (60);
      l_proc           VARCHAR2 (100) := 'is_notification_sent';
   BEGIN
      l_message_type :=
         wf_engine.getitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'MESSAGE_TYPE'
                                   );
      RESULT := 'COMPLETE:' || get_ntf_conf_value (l_message_type);
      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT (g_package,
                          'is_notification_sent',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RESULT := '';
         RAISE;
   END;
END;

/
