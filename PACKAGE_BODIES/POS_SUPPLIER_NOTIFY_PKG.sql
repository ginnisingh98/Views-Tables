--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_NOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_NOTIFY_PKG" AS
/* $Header: POSSNTFB.pls 120.0.12010000.10 2013/01/23 20:40:50 atjen noship $ */

/*Package to send the Notification message to the selected supplier contacts by invoking the wfengine*/

PROCEDURE wf_process
(   p_process     IN VARCHAR2,
    p_role        IN VARCHAR2,
    p_msg_subject IN VARCHAR2,
    p_msg_body    IN VARCHAR2,
    p_osn_message IN VARCHAR2,
    p_defer       IN BOOLEAN
)
IS

  l_itemtype   wf_items.item_type%TYPE;
  l_itemkey    wf_items.item_key%TYPE;

  l_threshold  NUMBER := WF_ENGINE.threshold;

BEGIN

  IF (p_defer) THEN
    WF_ENGINE.threshold := -1;
  END IF;

  l_itemtype := 'POSNOTIF';

  l_itemkey := 'POSNOTIF' || p_process || '_KEY_' ||
               TO_CHAR(SYSDATE, 'MMDDYYYY_HH24MISS') || '_' ||
               fnd_crypto.smallrandomnumber;

  WF_ENGINE.CreateProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          process  => p_process);

  WF_ENGINE.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => '#FROM_ROLE',
                            avalue   => fnd_global.user_name);

  WF_ENGINE.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'NOTIF_RECEIVER_ROLE',
                            avalue   => p_role);

  WF_ENGINE.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'SUPPMSGSUB',
                            avalue   => p_msg_subject);

  WF_ENGINE.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'SUPPMSGBD',
                            avalue   => p_msg_body);

  WF_ENGINE.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'SUPPADTMSG',
                            avalue   => p_osn_message);

  WF_ENGINE.StartProcess(itemtype => l_itemtype,
                         itemkey  => l_itemkey);

  WF_ENGINE.threshold := l_threshold;

EXCEPTION
  WHEN OTHERS THEN
    WF_ENGINE.threshold := l_threshold;
    RAISE;

END wf_process;

PROCEDURE supplier_notification
(   p_msg_subject   IN VARCHAR2,
    p_msg_body      IN VARCHAR2,
    p_msg_recipient IN VARCHAR2,
    p_msg_osn       IN VARCHAR2,
    p_notify_list   IN VARCHAR2
)
IS

  TYPE contact_csr_type IS REF CURSOR;

  l_contact_csr  contact_csr_type;

  l_contact_sql          VARCHAR2(4000);

  l_first_name           hz_parties.person_first_name%TYPE;
  l_last_name            hz_parties.person_last_name%TYPE;
  l_email_address        hz_contact_points.email_address%TYPE;
  l_user_name            fnd_user.user_name%TYPE;
  l_user_email_address   fnd_user.email_address%TYPE;

  l_contact_users_tbl    wf_directory.UserTable;
  l_contact_emails_tbl   wf_directory.UserTable;

  l_contact_users_role   wf_roles.name%TYPE;
  l_contact_emails_role  wf_roles.name%TYPE;

  l_adhoc_user           wf_users.name%TYPE;
  l_display_name         wf_users.display_name%TYPE;

  l_process_user         VARCHAR2(20) := 'SUPP_NOTIFY';
  l_process_email        VARCHAR2(20) := 'SUPP_NOTIFY_EMAIL';

  l_osn_message          fnd_new_messages.message_text%TYPE;

  l_defer                BOOLEAN := FALSE;
  l_request_id           NUMBER;

BEGIN

  l_contact_sql :=
    'SELECT DISTINCT ' ||
    '       hp.person_first_name, ' ||
    '       hp.person_last_name, ' ||
    '       hcpe.email_address, ' ||
    '       fu.user_name, ' ||
    '       fu.email_address ' ||
    'FROM hz_parties hp, ' ||
    '     hz_relationships hzr, ' ||
    '     hz_party_usg_assignments hpua, ' ||
    '     hz_contact_points hcpe, ' ||
    '     fnd_user fu, ' ||
    '     ap_suppliers aps ' ||
    'WHERE hp.party_id = hzr.subject_id ' ||
    '  AND hzr.object_id = aps.party_id ' ||
    '  AND hzr.relationship_type = ''CONTACT'' ' ||
    '  AND hzr.relationship_code = ''CONTACT_OF'' ' ||
    '  AND hzr.subject_type = ''PERSON'' ' ||
    '  AND hzr.object_type = ''ORGANIZATION'' ' ||
    '  AND hzr.status = ''A'' ' ||
    '  AND NVL(hzr.end_date, SYSDATE) >= SYSDATE ' ||
    '  AND hpua.party_id = hp.party_id ' ||
    '  AND hpua.status_flag = ''A'' ' ||
    '  AND hpua.party_usage_code = ''SUPPLIER_CONTACT'' ' ||
    '  AND NVL(hpua.effective_end_date, SYSDATE) >= SYSDATE ' ||
    '  AND hcpe.owner_table_name(+) = ''HZ_PARTIES'' ' ||
    '  AND hcpe.owner_table_id(+) = hzr.party_id ' ||
    '  AND hcpe.contact_point_type(+) = ''EMAIL'' ' ||
    '  AND hcpe.primary_flag(+) = ''Y'' ' ||
    '  AND NVL(hcpe.status, ''A'') = ''A'' ' ||
    '  AND fu.person_party_id(+) = hp.party_id ' ||
    '  AND NVL(fu.end_date, SYSDATE) >= SYSDATE ';

  IF p_notify_list <> 'ALL_SUPPLIERS' THEN
    l_contact_sql := l_contact_sql ||
                     '  AND aps.vendor_id IN (' || p_notify_list || ') ';
  END IF;

  OPEN l_contact_csr FOR l_contact_sql;
  LOOP
    FETCH l_contact_csr INTO l_first_name,
                             l_last_name,
                             l_email_address,
                             l_user_name,
                             l_user_email_address;
    EXIT WHEN l_contact_csr%NOTFOUND;

    IF (l_user_name IS NOT NULL AND
        l_user_email_address IS NOT NULL) THEN

      l_contact_users_tbl(l_contact_users_tbl.COUNT + 1) := l_user_name;

    ELSIF (UPPER(p_msg_recipient) = 'ALL CONTACTS' AND
           l_user_name IS NULL AND
           l_email_address IS NOT NULL) THEN

      l_adhoc_user := 'ADHOC_USER_' || l_first_name || '_' ||
                      TO_CHAR(SYSDATE, 'MMDDYYYY_HH24MISS') ||
                      fnd_crypto.smallrandomnumber;
      l_display_name := l_last_name || ',' || l_first_name;

      WF_DIRECTORY.CreateAdHocUser(name => l_adhoc_user,
                                   display_name => l_display_name,
                                   notification_preference => 'MAILTEXT',
                                   email_address => l_email_address);

      l_contact_emails_tbl(l_contact_emails_tbl.COUNT + 1) := l_adhoc_user;

    END IF;

  END LOOP;
  CLOSE l_contact_csr;

  IF (p_msg_osn = 'Y') THEN
    l_osn_message := pos_spm_wf_pkg1.get_osn_message();
  END IF;

  IF p_notify_list = 'ALL_SUPPLIERS' THEN
    l_defer := TRUE;
  END IF;

  IF (l_contact_users_tbl.COUNT > 0) THEN

    l_contact_users_role := 'POS_' || l_process_user || '_USERROLE' ||
                            TO_CHAR(SYSDATE, 'MMDDYYYY_HH24MISS') || '_' ||
                            fnd_crypto.smallrandomnumber;

    WF_DIRECTORY.CreateAdHocRole(role_name => l_contact_users_role,
                                 role_display_name => l_contact_users_role,
                                 expiration_date => SYSDATE + 1);

    WF_DIRECTORY.AddUsersToAdHocRole2(role_name => l_contact_users_role,
                                      role_users => l_contact_users_tbl);

    wf_process(p_process => 'SUPP_NOTIFY',
               p_role => l_contact_users_role,
               p_msg_subject => p_msg_subject,
               p_msg_body => p_msg_body,
               p_osn_message => l_osn_message,
               p_defer => l_defer);

  END IF;

  IF (l_contact_emails_tbl.COUNT > 0) THEN

    l_contact_emails_role := 'POS_' || l_process_email || '_EMAILROLE' ||
                             TO_CHAR(SYSDATE, 'MMDDYYYY_HH24MISS') || '_' ||
                             fnd_crypto.smallrandomnumber;

    WF_DIRECTORY.CreateAdHocRole(role_name => l_contact_emails_role,
                                 role_display_name => l_contact_emails_role,
                                 expiration_date => SYSDATE + 1);

    WF_DIRECTORY.AddUsersToAdHocRole2(role_name => l_contact_emails_role,
                                      role_users => l_contact_emails_tbl);

    wf_process(p_process => 'SUPP_NOTIFY_EMAIL',
               p_role => l_contact_emails_role,
               p_msg_subject => p_msg_subject,
               p_msg_body => p_msg_body,
               p_osn_message => l_osn_message,
               p_defer => l_defer);

  END IF;

  COMMIT;

  IF (l_defer AND
      (l_contact_users_tbl.COUNT > 0 OR l_contact_emails_tbl.COUNT > 0)) THEN

    l_request_id := fnd_request.submit_request('FND',
                                               'FNDWFBG',
                                               NULL,
                                               NULL,
                                               FALSE,
                                               'POSNOTIF');

    COMMIT;

  END IF;

END supplier_notification;

END POS_SUPPLIER_NOTIFY_PKG;

/
