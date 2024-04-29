--------------------------------------------------------
--  DDL for Package Body PON_EVAL_TEAM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_EVAL_TEAM_UTIL_PVT" AS
/* $Header: PONVETUB.pls 120.0.12010000.10 2014/09/04 13:17:40 spapana noship $ */


PROCEDURE send_mng_eval_teams_notif(p_auction_header_id IN NUMBER);

PROCEDURE send_eval_team_update_notif(p_auction_header_id IN NUMBER,
                                      p_member_user_id    IN NUMBER);

--
-- LOGGING FEATURE
--
-- global variables used for logging
--
g_fnd_debug     CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name      CONSTANT VARCHAR2(50) := 'PON_EVAL_TEAM_UTIL_PVT';
g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';
--
--private helper procedure for logging
PROCEDURE print_log(p_module   IN    VARCHAR2,
                   p_message  IN    VARCHAR2)
IS
BEGIN

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
  FND_LOG.string(log_level => FND_LOG.level_statement,
                 module  =>  g_module_prefix || p_module,
                 message  => p_message);
  END IF;
END;
FUNCTION get_display_name_for_user(p_user_id IN NUMBER)
RETURN VARCHAR2
IS

  l_party_id  NUMBER;

BEGIN

  SELECT person_party_id
  INTO l_party_id
  FROM fnd_user
  WHERE user_id = p_user_id;

  RETURN pon_locale_pkg.get_party_display_name(l_party_id);

END get_display_name_for_user;


-- Procedure to store the current setting of evaluation teams
PROCEDURE init_mng_eval_teams(p_auction_header_id IN NUMBER)
IS
BEGIN

  DELETE FROM pon_mng_eval_team_members
  WHERE auction_header_id = p_auction_header_id;

  DELETE FROM pon_mng_eval_team_sections
  WHERE auction_header_id = p_auction_header_id;


  INSERT INTO pon_mng_eval_team_members
  (
      auction_header_id,
      team_id,
      user_id,
      status_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  )
  SELECT auction_header_id,
         team_id,
         user_id,
         'C',
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.login_id
  FROM pon_evaluation_team_members
  WHERE auction_header_id = p_auction_header_id;

  INSERT INTO pon_mng_eval_team_sections
  (
      auction_header_id,
      team_id,
      team_name,
      section_id,
      status_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  )
  SELECT pets.auction_header_id,
         pets.team_id,
         pet.team_name,
         pets.section_id,
         'C',
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.login_id
  FROM pon_evaluation_team_sections pets,
       pon_evaluation_teams pet
  WHERE pets.auction_header_id = p_auction_header_id
    AND pet.auction_header_id = p_auction_header_id
    AND pet.team_id = pets.team_id;

END init_mng_eval_teams;


-- Procedure to track changes after Manage Evaluation Teams
PROCEDURE process_mng_eval_teams(p_auction_header_id IN NUMBER)
IS
BEGIN

  -- 1. Track sections to be excluded from evaluations

  MERGE INTO pon_mng_eval_bid_sections pmebs
  USING (SELECT pbh.bid_number,
                pmets.section_id
         FROM pon_mng_eval_team_members pmetm,
              pon_mng_eval_team_sections pmets,
              pon_bid_headers pbh,
              fnd_user fu
         WHERE pmetm.auction_header_id = p_auction_header_id
           AND pmets.auction_header_id = p_auction_header_id
           AND pmetm.team_id = pmets.team_id
           AND (pmetm.user_id, pmets.section_id) NOT IN
               (SELECT petm.user_id,
                       pets.section_id
                FROM pon_evaluation_team_members petm,
                     pon_evaluation_team_sections pets
                WHERE petm.auction_header_id = p_auction_header_id
                  AND pets.auction_header_id = p_auction_header_id
                  AND petm.team_id = pets.team_id
               )
           AND pbh.auction_header_id = p_auction_header_id
           AND pbh.bid_status IN ('ACTIVE', 'DRAFT')
           AND pbh.evaluation_flag = 'Y'
           AND pbh.evaluator_id = fu.person_party_id
           AND fu.user_id = pmetm.user_id
        ) bs_deleted
  ON (pmebs.auction_header_id = p_auction_header_id AND
      pmebs.bid_number = bs_deleted.bid_number AND
      pmebs.section_id = bs_deleted.section_id
     )
  WHEN MATCHED THEN
    UPDATE SET status_code = 'X' WHERE status_code = 'A'
    DELETE WHERE status_code = 'X'
  WHEN NOT MATCHED THEN
    INSERT (auction_header_id,
            bid_number,
            section_id,
            status_code,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
           )
    VALUES (p_auction_header_id,
            bs_deleted.bid_number,
            bs_deleted.section_id,
            'D',
            fnd_global.user_id,
            SYSDATE,
            fnd_global.user_id,
            SYSDATE,
            fnd_global.login_id
           );


  -- 2. Track new sections for the evaluations

  MERGE INTO pon_mng_eval_bid_sections pmebs
  USING (SELECT pbh.bid_number,
                pets.section_id
         FROM pon_evaluation_team_members petm,
              pon_evaluation_team_sections pets,
              pon_bid_headers pbh,
              fnd_user fu
         WHERE petm.auction_header_id = p_auction_header_id
           AND pets.auction_header_id = p_auction_header_id
           AND petm.team_id = pets.team_id
           AND (petm.user_id, pets.section_id) NOT IN
               (SELECT pmetm.user_id,
                       pmets.section_id
                FROM pon_mng_eval_team_members pmetm,
                     pon_mng_eval_team_sections pmets
                WHERE pmetm.auction_header_id = p_auction_header_id
                  AND pmets.auction_header_id = p_auction_header_id
                  AND pmetm.team_id = pmets.team_id
               )
           AND pbh.auction_header_id = p_auction_header_id
           AND bid_status IN ('ACTIVE', 'DRAFT')
           AND pbh.evaluation_flag = 'Y'
           AND pbh.evaluator_id = fu.person_party_id
           AND fu.user_id = petm.user_id
        ) bs_added
  ON (pmebs.auction_header_id = p_auction_header_id AND
      pmebs.bid_number = bs_added.bid_number AND
      pmebs.section_id = bs_added.section_id
     )
  WHEN MATCHED THEN
    UPDATE SET status_code = 'A' WHERE status_code = 'D'
  WHEN NOT MATCHED THEN
    INSERT (auction_header_id,
            bid_number,
            section_id,
            status_code,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
           )
    VALUES (p_auction_header_id,
            bs_added.bid_number,
            bs_added.section_id,
            'A',
            fnd_global.user_id,
            SYSDATE,
            fnd_global.user_id,
            SYSDATE,
            fnd_global.login_id
           );


  -- 3. Track changes in team members

  UPDATE pon_mng_eval_team_members
  SET status_code = 'D'
  WHERE auction_header_id = p_auction_header_id
    AND (team_id, user_id) NOT IN
        (SELECT team_id,
                user_id
         FROM pon_evaluation_team_members
         WHERE auction_header_id = p_auction_header_id
        );

  INSERT INTO pon_mng_eval_team_members
  (
      auction_header_id,
      team_id,
      user_id,
      status_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  )
  SELECT auction_header_id,
         team_id,
         user_id,
         'A',
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.login_id
  FROM pon_evaluation_team_members
  WHERE auction_header_id = p_auction_header_id
    AND (team_id, user_id) NOT IN
        (SELECT team_id,
                user_id
         FROM pon_mng_eval_team_members
         WHERE auction_header_id = p_auction_header_id
        );


  -- 4. Track changes in team sections assignment

  UPDATE pon_mng_eval_team_sections
  SET status_code = 'D'
  WHERE auction_header_id = p_auction_header_id
    AND (team_id, section_id) NOT IN
        (SELECT team_id,
                section_id
         FROM pon_evaluation_team_sections
         WHERE auction_header_id = p_auction_header_id
        );

  INSERT INTO pon_mng_eval_team_sections
  (
      auction_header_id,
      team_id,
      team_name,
      section_id,
      status_code,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  )
  SELECT pets.auction_header_id,
         pets.team_id,
         pet.team_name,
         pets.section_id,
         'A',
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.login_id
  FROM pon_evaluation_team_sections pets,
       pon_evaluation_teams pet
  WHERE pets.auction_header_id = p_auction_header_id
    AND pet.auction_header_id = p_auction_header_id
    AND pet.team_id = pets.team_id
    AND (pets.team_id, pets.section_id) NOT IN
        (SELECT team_id,
                section_id
         FROM pon_mng_eval_team_sections
         WHERE auction_header_id = p_auction_header_id
        );


  -- 5. Clear the evaluation scores

  UPDATE pon_team_member_attr_scores
  SET score = NULL
  WHERE auction_header_id = p_auction_header_id
    AND (bid_number, section_id) IN
        (SELECT bid_number,
                section_id
         FROM pon_mng_eval_bid_sections
         WHERE auction_header_id = p_auction_header_id
           AND status_code = 'D'
        );

  UPDATE pon_bid_attribute_values
  SET score = NULL,
      weighted_score = NULL
  WHERE auction_header_id = p_auction_header_id
    AND auction_line_number = -1
    AND (bid_number, attr_group_seq_number) IN
        (SELECT pmebs.bid_number,
                pas.attr_group_seq_number
         FROM pon_mng_eval_bid_sections pmebs,
              pon_auction_sections pas
         WHERE pmebs.auction_header_id = p_auction_header_id
           AND pmebs.status_code = 'D'
           AND pas.auction_header_id = p_auction_header_id
           AND pas.section_id = pmebs.section_id
        );


  -- 6. Send notifications

  send_mng_eval_teams_notif(p_auction_header_id);

END process_mng_eval_teams;

-- Procedure to send notifications after Manage Evaluation Teams
PROCEDURE send_mng_eval_teams_notif(p_auction_header_id IN NUMBER)
IS

  CURSOR c_notify_members
  IS
    SELECT user_id
    FROM pon_neg_team_members
    WHERE auction_header_id = p_auction_header_id
      AND (user_id IN (SELECT pmetm.user_id
                       FROM pon_mng_eval_team_members pmetm,
                            pon_mng_eval_team_sections pmets
                       WHERE pmetm.auction_header_id = p_auction_header_id
                         AND pmets.auction_header_id = p_auction_header_id
                         AND pmets.team_id = pmetm.team_id
                         AND ((pmetm.status_code = 'A' AND
                               pmets.status_code IN ('A', 'C'))
                              OR
                              (pmetm.status_code = 'D' AND
                               pmets.status_code IN ('C', 'D'))
                              OR
                              (pmetm.status_code = 'C' AND
                               pmets.status_code IN ('A', 'D'))
                             )
                      )
           OR
           menu_name = 'PON_SOURCING_EDITNEG'
          );

  TYPE notify_member_tbl_type IS TABLE OF c_notify_members%ROWTYPE;

  l_notify_members_tbl  notify_member_tbl_type;

BEGIN

  OPEN c_notify_members;
  FETCH c_notify_members BULK COLLECT INTO l_notify_members_tbl;
  CLOSE c_notify_members;

  FOR i IN 1..l_notify_members_tbl.COUNT LOOP
    send_eval_team_update_notif(p_auction_header_id,
                                l_notify_members_tbl(i).user_id);
  END LOOP;

END send_mng_eval_teams_notif;

-- Procedure to notify member of evaluation team updates
PROCEDURE send_eval_team_update_notif(p_auction_header_id IN NUMBER,
                                      p_member_user_id    IN NUMBER)
IS

  CURSOR c_auction_details
  IS
    SELECT pah.document_number,
           pah.auction_title,
           hz.party_name preparer_tp_name,
           pad.message_suffix
    FROM pon_auction_headers_all pah,
         pon_auc_doctypes pad,
         hz_parties hz
    WHERE pah.auction_header_id = p_auction_header_id
      AND pad.doctype_id = pah.doctype_id
      AND hz.party_id = pah.trading_partner_id;

  l_language_code      VARCHAR2(3);
  l_doc_number         pon_auction_headers_all.document_number%TYPE;
  l_auction_title      pon_auction_headers_all.auction_title%TYPE;
  l_preparer_tp_name   hz_parties.party_name%TYPE;
  l_msg_suffix         pon_auc_doctypes.message_suffix%TYPE;
  l_doc_type           VARCHAR2(50);
  l_member_user_name   fnd_user.user_name%TYPE;
  l_et_update_subject  VARCHAR2(2000);
  l_neg_summary_url    VARCHAR2(2000);

  l_sequence           NUMBER;
  l_itemtype           VARCHAR2(8) := 'PONAUCT';
  l_itemkey            VARCHAR2(240);

BEGIN

  pon_profile_util_pkg.get_wf_language(p_member_user_id, l_language_code);
  pon_auction_pkg.set_session_language(NULL, l_language_code);


  OPEN c_auction_details;
  FETCH c_auction_details
  INTO l_doc_number, l_auction_title, l_preparer_tp_name, l_msg_suffix;
  CLOSE c_auction_details;

  --SLM UI Enhancement
  IF PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id) = 'Y' THEN

    l_msg_suffix := 'Z';

  END IF;

  l_doc_type := pon_auction_pkg.getMessage('PON_AUCTION', '_' || l_msg_suffix);

  SELECT user_name
  INTO l_member_user_name
  FROM fnd_user
  WHERE user_id = p_member_user_id;

  fnd_message.set_name('PON', 'PON_SM_ET_UPDATE_SUB');
  fnd_message.set_token('DOC_TYPE', l_doc_type);
  fnd_message.set_token('DOC_NUMBER', l_doc_number);
  fnd_message.set_token('AUCTION_TITLE', l_auction_title);
  l_et_update_subject := fnd_message.get;

  l_neg_summary_url := pon_wf_utl_pkg.get_dest_page_url
                       (   p_dest_func        => 'PON_NEG_SUMMARY',
                           p_notif_performer  => 'BUYER'
                       );


  SELECT pon_auction_wf_s.nextval
  INTO l_sequence
  FROM dual;

  l_itemkey := p_auction_header_id || '-' || l_sequence;

  wf_engine.CreateProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          process  => 'MNG_EVAL_TEAM_UPDATE');


  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'AUCTION_ID',
                            avalue   => p_auction_header_id);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'MEMBER_USER_ID',
                            avalue   => p_member_user_id);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'DOC_TYPE',
                            avalue   => l_doc_type);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'DOC_NUMBER',
                            avalue   => l_doc_number);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'AUCTION_TITLE',
                            avalue   => l_auction_title);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'PREPARER_TP_NAME',
                            avalue   => l_preparer_tp_name);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'ORIGIN_USER_NAME',
                            avalue   => fnd_global.user_name);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'RECIPIENT_ROLE',
                            avalue   => l_member_user_name);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'MNG_EVAL_TEAM_UPDATE_SUBJECT',
                            avalue   => l_et_update_subject);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'MNG_EVAL_TEAM_UPDATE_BODY',
                            avalue   => 'plsqlclob:' ||
                                        'pon_eval_team_util_pvt.' ||
                                        'gen_eval_team_update_body/' ||
                                        l_itemtype || ':' ||
                                        l_itemkey);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'NEG_SUMMARY_URL',
                            avalue   => l_neg_summary_url);


  wf_engine.SetItemOwner(itemtype => l_itemtype,
                         itemkey  => l_itemkey,
                         owner    => fnd_global.user_name);

  wf_engine.StartProcess(itemtype => l_itemtype,
                         itemkey  => l_itemkey);


  pon_auction_pkg.unset_session_language;

END send_eval_team_update_notif;


PROCEDURE gen_eval_team_update_body(p_document_id   IN VARCHAR2,
                                    p_display_type  IN VARCHAR2,
                                    x_document      IN OUT NOCOPY CLOB,
                                    x_document_type IN OUT NOCOPY VARCHAR2)
IS

  CURSOR c_changed_team_members(p_auction_header_id IN NUMBER,
                                p_member_user_id    IN NUMBER)
  IS
    SELECT pmetm.user_id,
           pmets.team_name,
           pas.section_name,
           pmetm.status_code
    FROM pon_mng_eval_team_members pmetm,
         pon_mng_eval_team_sections pmets,
         pon_auction_sections pas
    WHERE pmetm.auction_header_id = p_auction_header_id
      AND pmets.auction_header_id = p_auction_header_id
      AND pas.auction_header_id = p_auction_header_id
      AND pmets.team_id = pmetm.team_id
      AND pas.section_id = pmets.section_id
      AND ((pmetm.status_code = 'A' AND
            pmets.status_code IN ('A', 'C'))
           OR
           (pmetm.status_code = 'D' AND
            pmets.status_code IN ('C', 'D'))
          )
      AND pmetm.user_id = NVL(p_member_user_id, pmetm.user_id)
    ORDER BY pmetm.status_code,
             pmetm.user_id,
             pmets.team_name,
             pas.attr_group_seq_number;

  CURSOR c_changed_team_sections(p_auction_header_id IN NUMBER,
                                 p_member_user_id    IN NUMBER)
  IS
    SELECT pmets.team_name,
           pas.section_name,
           pmets.status_code
    FROM pon_mng_eval_team_members pmetm,
         pon_mng_eval_team_sections pmets,
         pon_auction_sections pas
    WHERE pmetm.auction_header_id = p_auction_header_id
      AND pmets.auction_header_id = p_auction_header_id
      AND pas.auction_header_id = p_auction_header_id
      AND pmets.team_id = pmetm.team_id
      AND pas.section_id = pmets.section_id
      AND pmetm.status_code = 'C'
      AND pmets.status_code IN ('A', 'D')
      AND pmetm.user_id = p_member_user_id
    ORDER BY pmets.status_code,
             pmets.team_name,
             pas.attr_group_seq_number;

  CURSOR c_changed_team_sections_all(p_auction_header_id IN NUMBER)
  IS
    SELECT pmets.team_name,
           pas.section_name,
           pmets.status_code
    FROM pon_mng_eval_team_sections pmets,
         pon_auction_sections pas
    WHERE pmets.auction_header_id = p_auction_header_id
      AND pas.auction_header_id = p_auction_header_id
      AND pas.section_id = pmets.section_id
      AND pmets.status_code IN ('A', 'D')
    ORDER BY pmets.status_code,
             pmets.team_name,
             pas.attr_group_seq_number;

  CURSOR c_notification_id(p_itemtype IN VARCHAR2,
                           p_itemkey  IN VARCHAR2)
  IS
    SELECT notification_id
    FROM wf_item_activity_statuses
    WHERE item_type = p_itemtype
      AND item_key = p_itemkey
      AND assigned_user IS NOT NULL;

  CURSOR c_has_full_access(p_auction_header_id IN NUMBER,
                           p_member_user_id IN NUMBER)
  IS
    SELECT 'Y'
    FROM pon_neg_team_members
    WHERE auction_header_id = p_auction_header_id
      AND user_id = p_member_user_id
      AND menu_name = 'PON_SOURCING_EDITNEG';

  TYPE team_members_rec_type IS RECORD
  (   user_id     NUMBER,
      team_name   VARCHAR2(80),
      sections    VARCHAR2(4000),
      status_code VARCHAR2(1)
  );

  TYPE team_sections_rec_type IS RECORD
  (   team_name   VARCHAR2(80),
      sections    VARCHAR2(4000),
      status_code VARCHAR2(1)
  );

  TYPE team_members_tbl_type IS TABLE OF team_members_rec_type;
  TYPE team_sections_tbl_type IS TABLE OF team_sections_rec_type;

  l_team_members_tbl   team_members_tbl_type := team_members_tbl_type();
  l_team_sections_tbl  team_sections_tbl_type := team_sections_tbl_type();

  l_team_members_rec   team_members_rec_type;
  l_team_sections_rec  team_sections_rec_type;

  l_user_id            NUMBER;
  l_team_name          pon_evaluation_teams.team_name%TYPE;
  l_section_name       pon_auction_sections.section_name%TYPE;
  l_status_code        VARCHAR2(1);

  l_itemtype           VARCHAR2(8);
  l_itemkey            VARCHAR2(240);

  l_auction_header_id  pon_auction_headers_all.auction_header_id%TYPE;
  l_member_user_id     fnd_user.user_id%TYPE;
  l_doc_type           VARCHAR2(50);
  l_doc_number         pon_auction_headers_all.document_number%TYPE;
  l_neg_summary_url    VARCHAR2(2000);
  l_notification_id    NUMBER;
  l_has_full_access    VARCHAR2(1);

  l_language_code      VARCHAR2(3);
  l_msg_name           VARCHAR2(30);
  l_document           VARCHAR2(32000) := fnd_global.newline;

BEGIN

  l_itemtype := SUBSTR(p_document_id, 1, INSTR(p_document_id, ':') - 1);
  l_itemkey := SUBSTR(p_document_id, INSTR(p_document_id, ':') + 1,
                      LENGTH(p_document_id));

  l_auction_header_id := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                                   itemkey  => l_itemkey,
                                                   aname    => 'AUCTION_ID');

  l_member_user_id := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                                itemkey  => l_itemkey,
                                                aname    => 'MEMBER_USER_ID');

  l_doc_type := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                          itemkey  => l_itemkey,
                                          aname    => 'DOC_TYPE');

  l_doc_number := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                            itemkey  => l_itemkey,
                                            aname    => 'DOC_NUMBER');

  l_neg_summary_url := wf_engine.GetItemAttrText
                       (   itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           aname    => 'NEG_SUMMARY_URL'
                       );

  OPEN c_notification_id(l_itemtype, l_itemkey);
  FETCH c_notification_id INTO l_notification_id;
  CLOSE c_notification_id;

  IF (l_notification_id IS NOT NULL) THEN
    l_neg_summary_url := REPLACE(l_neg_summary_url,
                                 '&#NID', l_notification_id);
  END IF;

  OPEN c_has_full_access(l_auction_header_id, l_member_user_id);
  FETCH c_has_full_access INTO l_has_full_access;
  CLOSE c_has_full_access;


  -- 1. Get list of changed team members and their section assigments

  IF (l_has_full_access = 'Y') THEN
    OPEN c_changed_team_members(l_auction_header_id, NULL);
  ELSE
    OPEN c_changed_team_members(l_auction_header_id, l_member_user_id);
  END IF;

  LOOP
    FETCH c_changed_team_members
    INTO l_user_id, l_team_name, l_section_name, l_status_code;

    EXIT WHEN c_changed_team_members%NOTFOUND;

    IF (l_team_members_rec.user_id = l_user_id AND
        l_team_members_rec.team_name = l_team_name AND
        l_team_members_rec.status_code = l_status_code)
    THEN
      l_team_members_rec.sections := l_team_members_rec.sections || ', ' ||
                                     l_section_name;
    ELSE
      IF (l_team_members_rec.user_id IS NOT NULL) THEN
        l_team_members_tbl.EXTEND();
        l_team_members_tbl(l_team_members_tbl.LAST) := l_team_members_rec;
      END IF;

      l_team_members_rec.user_id     := l_user_id;
      l_team_members_rec.team_name   := l_team_name;
      l_team_members_rec.sections    := l_section_name;
      l_team_members_rec.status_code := l_status_code;
    END IF;

  END LOOP;

  IF (l_team_members_rec.user_id IS NOT NULL) THEN
    l_team_members_tbl.EXTEND();
    l_team_members_tbl(l_team_members_tbl.LAST) := l_team_members_rec;
  END IF;

  CLOSE c_changed_team_members;


  -- 2. Get list of changed team sections assignment

  IF (l_has_full_access = 'Y') THEN

    OPEN c_changed_team_sections_all(l_auction_header_id);

    LOOP
      FETCH c_changed_team_sections_all
      INTO l_team_name, l_section_name, l_status_code;

      EXIT WHEN c_changed_team_sections_all%NOTFOUND;

      IF (l_team_sections_rec.team_name = l_team_name AND
          l_team_sections_rec.status_code = l_status_code)
      THEN
        l_team_sections_rec.sections := l_team_sections_rec.sections || ', ' ||
                                        l_section_name;
      ELSE
        IF (l_team_sections_rec.team_name IS NOT NULL) THEN
          l_team_sections_tbl.EXTEND();
          l_team_sections_tbl(l_team_sections_tbl.LAST) := l_team_sections_rec;
        END IF;

        l_team_sections_rec.team_name   := l_team_name;
        l_team_sections_rec.sections    := l_section_name;
        l_team_sections_rec.status_code := l_status_code;
      END IF;

    END LOOP;

    IF (l_team_sections_rec.team_name IS NOT NULL) THEN
      l_team_sections_tbl.EXTEND();
      l_team_sections_tbl(l_team_sections_tbl.LAST) := l_team_sections_rec;
    END IF;

    CLOSE c_changed_team_sections_all;

  ELSE

    OPEN c_changed_team_sections(l_auction_header_id, l_member_user_id);

    LOOP
      FETCH c_changed_team_sections
      INTO l_team_name, l_section_name, l_status_code;

      EXIT WHEN c_changed_team_sections%NOTFOUND;

      IF (l_team_sections_rec.team_name = l_team_name AND
          l_team_sections_rec.status_code = l_status_code)
      THEN
        l_team_sections_rec.sections := l_team_sections_rec.sections || ', ' ||
                                        l_section_name;
      ELSE
        IF (l_team_sections_rec.team_name IS NOT NULL) THEN
          l_team_sections_tbl.EXTEND();
          l_team_sections_tbl(l_team_sections_tbl.LAST) := l_team_sections_rec;
        END IF;

        l_team_sections_rec.team_name   := l_team_name;
        l_team_sections_rec.sections    := l_section_name;
        l_team_sections_rec.status_code := l_status_code;
      END IF;

    END LOOP;

    IF (l_team_sections_rec.team_name IS NOT NULL) THEN
      l_team_sections_tbl.EXTEND();
      l_team_sections_tbl(l_team_sections_tbl.LAST) := l_team_sections_rec;
    END IF;

    CLOSE c_changed_team_sections;

  END IF;


  -- 3. Construct the message body based on the above 2 lists

  pon_profile_util_pkg.get_wf_language(l_member_user_id, l_language_code);
  pon_auction_pkg.set_session_language(NULL, l_language_code);

  FOR i IN 1..l_team_members_tbl.COUNT LOOP

    l_team_members_rec := l_team_members_tbl(i);

    IF (l_team_members_rec.status_code = 'A') THEN
      l_msg_name := 'PON_SM_ET_MEMBER_ADDED';
    ELSE
      l_msg_name := 'PON_SM_ET_MEMBER_REMOVED';
    END IF;

    IF (p_display_type = 'text/html') THEN
      l_msg_name := l_msg_name || '_HB';
    ELSE
      l_msg_name := l_msg_name || '_TB';
    END IF;

    fnd_message.set_name('PON', l_msg_name);
    fnd_message.set_token
    (   'TEAM_MEMBER',
        get_display_name_for_user(l_team_members_rec.user_id)
    );
    fnd_message.set_token('DOC_TYPE', l_doc_type);
    fnd_message.set_token('DOC_NUMBER', l_doc_number);
    fnd_message.set_token('TEAM_NAME', l_team_members_rec.team_name);
    fnd_message.set_token('SECTIONS', l_team_members_rec.sections);

    IF (p_display_type = 'text/html') THEN
      fnd_message.set_token('NEG_SUMMARY_URL', l_neg_summary_url);
    END IF;

    l_document := l_document || fnd_message.get;

  END LOOP;

  FOR i IN 1..l_team_sections_tbl.COUNT LOOP

    l_team_sections_rec := l_team_sections_tbl(i);

    IF (l_team_sections_rec.status_code = 'A') THEN
      l_msg_name := 'PON_SM_ET_SECTION_ADDED';
    ELSE
      l_msg_name := 'PON_SM_ET_SECTION_REMOVED';
    END IF;

    IF (p_display_type = 'text/html') THEN
      l_msg_name := l_msg_name || '_HB';
    ELSE
      l_msg_name := l_msg_name || '_TB';
    END IF;

    fnd_message.set_name('PON', l_msg_name);

    fnd_message.set_token('TEAM_NAME', l_team_sections_rec.team_name);
    fnd_message.set_token('SECTIONS', l_team_sections_rec.sections);
    fnd_message.set_token('DOC_TYPE', l_doc_type);
    fnd_message.set_token('DOC_NUMBER', l_doc_number);

    IF (p_display_type = 'text/html') THEN
      fnd_message.set_token('NEG_SUMMARY_URL', l_neg_summary_url);
    END IF;

    l_document := l_document || fnd_message.get;

  END LOOP;

  wf_notification.WriteToClob(x_document, l_document);

  pon_auction_pkg.unset_session_language;

END gen_eval_team_update_body;


PROCEDURE send_eval_update_scorer_notif(params IN VARCHAR2)
IS

  CURSOR c_auction_details(p_bid_number number)
  IS
    SELECT pah.document_number,
           pah.auction_header_id,
           pah.auction_title,
           hz.party_name preparer_tp_name,
           pad.message_suffix,
           nvl2(scoring_lock_date, 'Y', 'N') is_score_locked
    FROM pon_bid_headers pbh,
         pon_auction_headers_all pah,
         pon_auc_doctypes pad,
         hz_parties hz
    WHERE pbh.bid_number = p_bid_number
      AND pah.auction_header_id = pbh.auction_header_id
      AND pad.doctype_id = pah.doctype_id
      AND hz.party_id = pah.trading_partner_id;

  CURSOR c_notify_scorer(p_bid_number number)
  IS
    SELECT DISTINCT
           fus.user_name scorer_user_name,
           pon_locale_pkg.get_party_display_name(pbh.evaluator_id)
             AS evaluator_name
    FROM pon_bid_headers pbh,
         fnd_user fue,
         pon_evaluation_team_members petm,
         pon_evaluation_team_sections pets,
         pon_scoring_team_members pstm,
         pon_scoring_team_sections psts,
         fnd_user fus
    WHERE pbh.bid_number = p_bid_number
      AND pbh.evaluation_flag = 'Y'
      AND pbh.evaluator_id = fue.person_party_id
      AND petm.user_id = fue.user_id
      AND petm.auction_header_id = pbh.auction_header_id
      AND pets.auction_header_id = pbh.auction_header_id
      AND pets.team_id = petm.team_id
      AND fus.user_id = pstm.user_id
      AND pstm.auction_header_id = pbh.auction_header_id
      AND psts.auction_header_id = pbh.auction_header_id
      AND psts.team_id = pstm.team_id
      AND psts.section_id = pets.section_id
      AND psts.section_id IN
          (SELECT pas.section_id
           FROM pon_auction_sections pas,
                pon_auction_attributes paa
           WHERE pas.auction_header_id = pbh.auction_header_id
             AND paa.auction_header_id = pbh.auction_header_id
             AND paa.attr_group_seq_number = pas.attr_group_seq_number
             AND paa.line_number= -1
             AND paa.internal_attr_flag = 'Y'
             AND paa.scoring_method = 'MANUAL'
          );
   -- Bug 18517926: Update Evaluation ER : Send notif to buyer also about evaluation enter/update
   CURSOR c_notify_buyer(p_bid_number number)
   IS
       SELECT  fnd.user_name buyer_user_name,
               pon_locale_pkg.get_party_display_name(pbh.evaluator_id) AS evaluator_name
          FROM
            pon_auction_headers_all pon,
            PON_BID_HEADERS pbh,
            fnd_user fnd
          WHERE pbh.bid_number = p_bid_number
            AND pon.auction_header_id = pbh.auction_header_id
            AND pon.trading_partner_contact_name = fnd.user_name;

  TYPE notify_tbl_type IS TABLE OF c_notify_scorer%ROWTYPE;

  l_notify_tbl         notify_tbl_type;

  l_doc_number         pon_auction_headers_all.document_number%TYPE;
  l_auction_header_id  pon_auction_headers_all.auction_header_id%TYPE;
  l_auction_title      pon_auction_headers_all.auction_title%TYPE;
  l_preparer_tp_name   hz_parties.party_name%TYPE;
  l_msg_suffix         pon_auc_doctypes.message_suffix%TYPE;
  l_language_code      VARCHAR2(3);
  l_doc_type           VARCHAR2(50);
  l_eval_update_sub    VARCHAR2(2000);
  l_neg_summary_url    VARCHAR2(2000);
  l_score_locked       char;

  l_sequence           NUMBER;
  l_itemtype           VARCHAR2(8) := 'PONAUCT';
  l_itemkey            VARCHAR2(240);
  l_require_manual_score  CHAR;
  l_rebid              CHAR;
  l_buyerName          fnd_user.user_name%TYPE;
  l_evalName           varchar2(4000);
  p_bid_number         NUMBER;
  l_api_name CONSTANT VARCHAR2(400) := 'send_eval_update_scorer_notif';

BEGIN

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, 'Entered - Params ' || params);

  END IF;

  p_bid_number := SUBSTR(params, 1, INSTR(params, ':') - 1);

  -- Bug 18517926: Update Evaluation ER
  -- Unlike sourcing bidding, in SLM evaluation update, we UPDATE same response
  -- For ex: If reponse XX is submitted and now evaluator wants to update it, we dont create new response/bid,
  -- we use same response to update it.
  -- Hence if publish_date is null, then we say response is entered for the first time. Here we got this flag to change the
  -- notification message to scorer/buyer when response is entered/updated.
  l_rebid      := SUBSTR(params, INSTR(params, ':') + 1,  length(params));

  OPEN c_notify_scorer(p_bid_number);
  FETCH c_notify_scorer BULK COLLECT INTO l_notify_tbl;
  CLOSE c_notify_scorer;
   -- Bug 18517926: Update Evaluation ER : send diff notif message to buyer based on fact that reponse updated/enetred and require manual score
  IF (l_notify_tbl.COUNT = 0) THEN
    --RETURN;
    -- No scorer found as there are no requirements which requires manual scores
    l_require_manual_score := 'N';
  ELSE
    l_require_manual_score := 'Y';
  END IF;

  OPEN c_notify_buyer(p_bid_number);
  FETCH c_notify_buyer INTO l_buyerName,
                            l_evalName;

  CLOSE c_notify_buyer;

  -- Bug 18517926: Update Evaluation ER : Send notif to buyer also about evaluation enter/update
  l_notify_tbl.extend();
  l_notify_tbl(l_notify_tbl.last).scorer_user_name := l_buyerName;
  l_notify_tbl(l_notify_tbl.last).evaluator_name := l_evalName;

  OPEN c_auction_details(p_bid_number);
  FETCH c_auction_details INTO l_doc_number,
                               l_auction_header_id,
                               l_auction_title,
                               l_preparer_tp_name,
                               l_msg_suffix,
                               l_score_locked;
  CLOSE c_auction_details;

  --SLM UI Enhancement
  IF PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(l_auction_header_id) = 'Y' THEN

    l_msg_suffix := 'Z';

  END IF;

  l_doc_type := pon_auction_pkg.getMessage('PON_AUCTION', '_'||l_msg_suffix);


  FOR i IN 1..l_notify_tbl.COUNT LOOP

    pon_profile_util_pkg.get_wf_language(l_notify_tbl(i).scorer_user_name,
                                         l_language_code);
    pon_auction_pkg.set_session_language(NULL, l_language_code);


    l_doc_type := pon_auction_pkg.getMessage('PON_AUCTION', '_'||l_msg_suffix);

    fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_SUB');
    fnd_message.set_token('DOC_TYPE', l_doc_type);
    fnd_message.set_token('DOC_NUMBER', l_doc_number);
    fnd_message.set_token('AUCTION_TITLE', l_auction_title);
    l_eval_update_sub := fnd_message.get;

    l_neg_summary_url := pon_wf_utl_pkg.get_dest_page_url
                         (   p_dest_func        => 'PON_NEG_SUMMARY',
                             p_notif_performer  => 'BUYER'
                         );


    SELECT pon_auction_wf_s.nextval
    INTO l_sequence
    FROM dual;

    l_itemkey := l_auction_header_id || '-' || l_sequence;

    wf_engine.CreateProcess(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            process  => 'NOTIFY_SCORER_EVAL_UPDATE');

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'AUCTION_ID',
                              avalue   => l_auction_header_id);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'DOC_TYPE',
                              avalue   => l_doc_type);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'DOC_NUMBER',
                              avalue   => l_doc_number);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'AUCTION_TITLE',
                              avalue   => l_auction_title);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'PREPARER_TP_NAME',
                              avalue   => l_preparer_tp_name);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'ORIGIN_USER_NAME',
                              avalue   => fnd_global.user_name);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'RECIPIENT_ROLE',
                              avalue   => l_notify_tbl(i).scorer_user_name);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'TEAM_MEMBER',
                              avalue   => l_notify_tbl(i).evaluator_name);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'EVAL_UPDATE_SCORER_SUBJECT',
                            avalue   => l_eval_update_sub);

  wf_engine.SetItemAttrText(itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'EVAL_UPDATE_SCORER_BODY',
                            avalue   => 'plsqlclob:' ||
                                        'pon_eval_team_util_pvt.' ||
                                        'gen_eval_update_scorer_body/' ||
                                        l_itemtype || ':' ||
                                        l_itemkey || ':' ||
                                        l_score_locked || ':' ||
                                        p_bid_number || ':' ||
                                        l_require_manual_score || ':' ||
                                        l_rebid);

    wf_engine.SetItemAttrText(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'NEG_SUMMARY_URL',
                              avalue   => l_neg_summary_url);


    wf_engine.SetItemOwner(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           owner    => fnd_global.user_name);

    wf_engine.StartProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey);


    pon_auction_pkg.unset_session_language;

  END LOOP;

END send_eval_update_scorer_notif;


PROCEDURE gen_eval_update_scorer_body(p_document_id   IN VARCHAR2,
                                      p_display_type  IN VARCHAR2,
                                      x_document      IN OUT NOCOPY CLOB,
                                      x_document_type IN OUT NOCOPY VARCHAR2)
IS

  CURSOR c_notification_id(p_itemtype IN VARCHAR2,
                           p_itemkey  IN VARCHAR2)
  IS
    SELECT notification_id
    FROM wf_item_activity_statuses
    WHERE item_type = p_itemtype
      AND item_key = p_itemkey
      AND assigned_user IS NOT NULL;

  l_itemtype           VARCHAR2(8);
  l_itemkey            VARCHAR2(240);

  l_team_member        VARCHAR2(240);
  l_neg_summary_url    VARCHAR2(2000);
  l_doc_type           VARCHAR2(50);
  l_doc_number         pon_auction_headers_all.document_number%TYPE;
  l_auction_title      pon_auction_headers_all.auction_title%TYPE;
  l_scorer_user_name   fnd_user.user_name%TYPE;
  l_notification_id    NUMBER;

  l_language_code      VARCHAR2(3);
  l_document           VARCHAR2(32000);
  l_scored_locked      CHAR;
  l_bid_number         pon_bid_headers.bid_number%TYPE;
  l_require_manual_score  CHAR;
  l_rebid              CHAR;
  l_api_name CONSTANT VARCHAR2(400) := 'gen_eval_update_scorer_body';

BEGIN
  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, 'p_document_id is : ' || p_document_id);
  END IF;

  l_itemtype                := SUBSTR(p_document_id, 1, INSTR(p_document_id, ':', 1) - 1);
  l_itemkey                 := SUBSTR(p_document_id, INSTR(p_document_id, ':', 1, 1) + 1, (INSTR(p_document_id, ':', 1, 2) - INSTR(p_document_id, ':', 1, 1)) - 1);
  l_scored_locked           := SUBSTR(p_document_id, INSTR(p_document_id, ':', 1, 2) + 1, (INSTR(p_document_id, ':', 1, 3) - INSTR(p_document_id, ':', 1, 2)) - 1);
  l_bid_number              := SUBSTR(p_document_id, INSTR(p_document_id, ':', 1, 3) + 1, (INSTR(p_document_id, ':', 1, 4) - INSTR(p_document_id, ':', 1, 3)) - 1);
  l_require_manual_score    := SUBSTR(p_document_id, INSTR(p_document_id, ':', 1, 4) + 1, (INSTR(p_document_id, ':', 1, 5) - INSTR(p_document_id, ':', 1, 4)) - 1);
  l_rebid                   := SUBSTR(p_document_id, INSTR(p_document_id, ':', 1, 5) + 1,  length(p_document_id));

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, 'l_itemtype is : '      || l_itemtype);
    print_log(l_api_name, 'l_itemkey is : '       || l_itemkey);
    print_log(l_api_name, 'l_scored_locked is : ' || l_scored_locked);
    print_log(l_api_name, 'l_bid_number is : '    || l_bid_number);
    print_log(l_api_name, 'l_require_manual_score is : ' || l_require_manual_score);
    print_log(l_api_name, 'l_rebid is : '         || l_rebid);
  END IF;

  l_team_member := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                             itemkey  => l_itemkey,
                                             aname    => 'TEAM_MEMBER');

  l_doc_type := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                          itemkey  => l_itemkey,
                                          aname    => 'DOC_TYPE');

  l_doc_number := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                            itemkey  => l_itemkey,
                                            aname    => 'DOC_NUMBER');

  l_auction_title := wf_engine.GetItemAttrText(itemtype => l_itemtype,
                                               itemkey  => l_itemkey,
                                               aname    => 'AUCTION_TITLE');

  l_scorer_user_name := wf_engine.GetItemAttrText
                        (   itemtype => l_itemtype,
                            itemkey  => l_itemkey,
                            aname    => 'RECIPIENT_ROLE'
                        );

  l_neg_summary_url := wf_engine.GetItemAttrText
                       (   itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           aname    => 'NEG_SUMMARY_URL'
                       );

  OPEN c_notification_id(l_itemtype, l_itemkey);
  FETCH c_notification_id INTO l_notification_id;
  CLOSE c_notification_id;

  IF (l_notification_id IS NOT NULL) THEN
    l_neg_summary_url := REPLACE(l_neg_summary_url,
                                 '&#NID', l_notification_id);
  END IF;


  pon_profile_util_pkg.get_wf_language(l_scorer_user_name, l_language_code);
  pon_auction_pkg.set_session_language(NULL, l_language_code);

  IF (p_display_type = 'text/html') THEN
    IF l_require_manual_score = 'Y' THEN
    IF l_scored_locked = 'Y' THEN
      fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_L_HB');
    ELSE
        IF l_rebid = 'Y' THEN -- in case of ACTIVE evaluation is updated, send notification message as evaluation updated
    fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_HB');
        ELSE -- in case of evaluation is enteretd and published for the first time, send notification message as evaluation entered
          fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_F_HB');
        END IF;
      END IF;
    ELSE
      -- Automatic score message will be sent only to buyer
      IF l_rebid = 'Y' THEN -- in case of ACTIVE evaluation is updated, send notification message as evaluation updated
          fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_A_HB');
      ELSE -- in case of evaluation is enteretd and published for the first time, send notification message as evaluation entered
          fnd_message.set_name('PON', 'PON_SM_EVAL_UPDTE_SCORER_AF_HB');
      END IF;
    END IF;
  ELSE
    IF l_require_manual_score = 'Y' THEN
    IF l_scored_locked = 'Y' THEN
      fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_L_TB');
    ELSE
        IF l_rebid = 'Y' THEN -- in case of ACTIVE evaluation is updated, send notification message as evaluation updated
    	  fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_TB');
        ELSE -- in case of evaluation is enteretd and published for the first time, send notification message as evaluation entered
          fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_F_TB');
        END IF;
      END IF;
    ELSE
      -- Automatic score message will be sent only to buyer
      IF l_rebid = 'Y' THEN -- in case of ACTIVE evaluation is updated, send notification message as evaluation updated
          fnd_message.set_name('PON', 'PON_SM_EVAL_UPDATE_SCORER_A_TB');
      ELSE -- in case of evaluation is enteretd and published for the first time, send notification message as evaluation entered
          fnd_message.set_name('PON', 'PON_SM_EVAL_UPDTE_SCORER_AF_TB');
      END IF;
    END IF;
  END IF;

  fnd_message.set_token('TEAM_MEMBER', l_team_member);
  fnd_message.set_token('BID_NUM', l_bid_number );
  fnd_message.set_token('DOC_TYPE', l_doc_type);
  fnd_message.set_token('DOC_NUMBER', l_doc_number);
  fnd_message.set_token('AUCTION_TITLE', l_auction_title);
  fnd_message.set_token('NEG_SUMMARY_URL', l_neg_summary_url);
  l_document := fnd_message.get;

  wf_notification.WriteToClob(x_document, l_document);

  pon_auction_pkg.unset_session_language;

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, 'Completed ' );
  END IF;
END gen_eval_update_scorer_body;


END PON_EVAL_TEAM_UTIL_PVT;

/
