--------------------------------------------------------
--  DDL for Package Body PON_THREAD_DISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_THREAD_DISC_PKG" as
/* $Header: PONTHDIB.pls 120.8.12010000.2 2009/02/11 15:56:59 ankusriv ship $ */

g_module_prefix        CONSTANT VARCHAR2(50) := 'pon.plsql.PON_THREAD_DISC_PKG.';

function insert_pon_discussions(
         p_entity_name             IN VARCHAR2,
         p_entity_pk1              IN VARCHAR2,
         p_entity_pk2              IN VARCHAR2,
         p_entity_pk3              IN VARCHAR2,
         p_entity_pk4              IN VARCHAR2,
         p_entity_pk5              IN VARCHAR2,
         p_subject                 IN VARCHAR2,
         p_language_code           IN VARCHAR2,
         p_party_id                IN NUMBER,
         p_validation_class        IN VARCHAR2)
return NUMBER
IS

    l_discussion_id NUMBER(15);

BEGIN
-- bug 8224577
BEGIN
  SELECT discussion_id
  INTO   l_discussion_id
  FROM  pon_discussions
  WHERE  ENTITY_NAME = p_entity_name
  AND pk1_value =  p_entity_pk1;

EXCEPTION
WHEN No_Data_Found THEN

    SELECT pon_discussions_s.nextval
    INTO   l_discussion_id
    FROM   dual;

    INSERT INTO pon_discussions(
          DISCUSSION_ID,
          ENTITY_NAME,
          PK1_VALUE,
          SUBJECT,
          LAST_UPDATE_DATE,
          VALIDATION_CLASS,
          PK2_VALUE,
          PK3_VALUE,
          PK4_VALUE,
          PK5_VALUE,
          LANGUAGE_CODE,
          OWNER_PARTY_ID
    )VALUES(
          l_discussion_id,
          p_entity_name,
          p_entity_pk1,
          nvl(p_subject,p_entity_pk1),
          sysdate,
          p_validation_class,
          p_entity_pk2,
          p_entity_pk3,
          p_entity_pk4,
          p_entity_pk5,
          p_language_code,
          p_party_id);
END;
    return l_discussion_id;

END insert_pon_discussions;

function insert_pon_threads(
         p_discussion_id           IN NUMBER,
         p_subject                 IN VARCHAR2,
         p_language_code           IN VARCHAR2,
         p_party_id                IN NUMBER)
return NUMBER
IS

    l_prev_thread_number NUMBER(15);
    l_now_date           DATE;
    l_lang_code          VARCHAR2(4);

BEGIN

    l_now_date := sysdate;

    SELECT nvl(max(thread_number), -1)
    INTO l_prev_thread_number
    FROM pon_threads
    WHERE discussion_id = p_discussion_id;

    SELECT nvl(p_language_code, language_code)
    INTO l_lang_code
    FROM pon_discussions
    WHERE discussion_id = p_discussion_id;


    INSERT INTO pon_threads(
          THREAD_NUMBER,
          OWNER_PARTY_ID,
          DISCUSSION_ID,
          SUBJECT,
          LANGUAGE_CODE,
          LAST_UPDATE_DATE
    )VALUES(
          l_prev_thread_number + 1,
          p_party_id,
          p_discussion_id,
          p_subject,
          l_lang_code,
          l_now_date);

    UPDATE pon_discussions
    SET last_update_date = l_now_date
    WHERE discussion_id = p_discussion_id;

    return l_prev_thread_number + 1;

END insert_pon_threads;


function insert_thread_entry(
         p_from_id in NUMBER,
         p_from_first_name in VARCHAR2,
         p_from_last_name in VARCHAR2,
         p_subject in VARCHAR2,
         p_discussion_id in VARCHAR2,
         p_thread_id in NUMBER,
         p_broadcast_flag in VARCHAR2,
         p_parent_id in NUMBER)
return NUMBER
IS

    l_entry_id   NUMBER(15);
    l_now_date   DATE;

BEGIN

    SELECT pon_thread_entries_s.nextval
    INTO l_entry_id FROM dual;

    l_now_date := sysdate;

    INSERT INTO pon_thread_entries(
          ENTRY_ID,
          PARENT_ENTRY_ID,
          FROM_ID,
          FROM_FIRST_NAME,
          FROM_LAST_NAME,
          POSTED_DATE,
          SUBJECT,
          THREAD_NUMBER,
          DISCUSSION_ID,
          BROADCAST_FLAG,
          CONTENT
    )VALUES(
          l_entry_id,
          p_parent_id,
          p_from_id,
          p_from_first_name,
          p_from_last_name,
          l_now_date,
          p_subject,
          p_thread_id,
          p_discussion_id,
          p_broadcast_flag,
          empty_clob());

    UPDATE pon_threads
    SET last_update_date = l_now_date
    WHERE discussion_id = p_discussion_id
    AND thread_number = p_thread_id;

    UPDATE pon_discussions
    SET last_update_date = l_now_date
    WHERE discussion_id = p_discussion_id;

    RETURN l_entry_id;

END insert_thread_entry;

/*=======================================================================+
-- API Name: insert_or_update_recipient
--
-- Type    : Public
--
-- Pre-reqs: None
--
-- Function: This API is called by the Online Discussion code.
--           It inserts a record to pon_te_recipients if it
--           does not exists for given p_to_id and p_entry_id.
--           Else it will update the record with appropriate
--           read or replied flag.
--
-- Parameters:
--
--           p_entry_id in NUMBER
--           p_recipient_id in NUMBER
--           p_read_flag in VARCHAR2
--           p_replied_flag in VARCHAR2
--
-- Following paraemters are added as part of R12 : Online Discussion Enhancement Project.
--           p_to_company_id in NUMBER
--           p_to_first_name in VARCHAR2
--           p_to_last_name in VARCHAR2
--           p_to_company_name in VARCHAR2
--
 *=======================================================================*/

procedure insert_or_update_recipient(
         p_entry_id in NUMBER,
         p_recipient_id in NUMBER,
         p_read_flag in VARCHAR2,
         p_replied_flag in VARCHAR2,
         p_to_company_id in NUMBER,
         p_to_first_name in VARCHAR2,
         p_to_last_name in VARCHAR2,
         p_to_company_name in VARCHAR2)
IS
  l_row_exists NUMBER;
  l_module_name VARCHAR2(40) := 'INSERT_OR_UPDATE_RECIPIENT';

BEGIN

    SELECT COUNT(1) INTO l_row_exists
    FROM pon_te_recipients
    WHERE to_id = p_recipient_id
    AND entry_id = p_entry_id;


     IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_procedure,
          module => g_module_prefix || l_module_name,
          message  => 'Entering PON_THREAD_DISC_PKG.INSERT_OR_UPDATE_RECIPIENT'
                      || ', l_row_exists = ' || l_row_exists
                      || ', p_recipient_id = ' || p_recipient_id
                      || ', p_entry_id = ' || p_entry_id
                      || ', p_read_flag  = ' || p_read_flag
                      || ', p_replied_flag   = ' || p_replied_flag
                      || ', p_to_company_id = ' ||    p_to_company_id
                      || ', p_to_first_name = ' ||    p_to_first_name
                      || ', p_to_last_name   = ' || p_to_last_name
                      || ', p_to_company_name = '||   p_to_company_name);
     END IF;

    IF (l_row_exists > 0) THEN

        UPDATE pon_te_recipients
        SET read_flag = p_read_flag,
            replied_flag = p_replied_flag
        WHERE to_id = p_recipient_id
        AND entry_id = p_entry_id;

    ELSE

        INSERT INTO pon_te_recipients(
            TO_ID,
            READ_FLAG,
            ENTRY_ID,
            REPLIED_FLAG,
            TO_COMPANY_ID,
            TO_FIRST_NAME,
            TO_LAST_NAME,
            TO_COMPANY_NAME
        )VALUES(
            p_recipient_id,
            p_read_flag,
            p_entry_id,
            p_replied_flag,
            p_to_company_id,
            p_to_first_name,
            p_to_last_name ,
            p_to_company_name);
    END IF;

END insert_or_update_recipient;

/*=======================================================================+
-- API Name: update_recipient_to_read
--
-- Type    : Public
--
-- Pre-reqs: None
--
-- Function: This API is called by the Online Discussion code.
--           It checks if any record exist for given p_entry_id
--           and p_recipient_id and calls insert_or_update_recipient
--           with appropriate value for Read and Replied flag.
-- Parameters:
--
--           p_entry_id in NUMBER
--           p_recipient_id in NUMBER
--
-- Following paraemters are added as part of R12 : Online Discussion Enhancement Project.
--           p_to_company_id in NUMBER
--           p_to_first_name in VARCHAR2
--           p_to_last_name in VARCHAR2
--           p_to_company_name in VARCHAR2
--
*=======================================================================*/

PROCEDURE update_recipient_to_read(
         p_entry_id in NUMBER,
         p_recipient_id in NUMBER,
         p_to_company_id in NUMBER,
         p_to_first_name in VARCHAR2,
         p_to_last_name in VARCHAR2,
         p_to_company_name in VARCHAR2)
IS
    l_num_entries  NUMBER(1);
    l_replied_state  VARCHAR(1);
    l_module_name VARCHAR2(40) := 'UPDATE_RECIPIENT_TO_READ';
BEGIN
    SELECT count(1) INTO l_num_entries
    FROM pon_te_recipients
    WHERE entry_id = p_entry_id
    AND to_id = p_recipient_id;

     IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_procedure,
          module => g_module_prefix || l_module_name,
          message  => 'Entering PON_THREAD_DISC_PKG.UPDATE_RECIPIENT_TO_READ'
                      || ', l_num_entries = ' || l_num_entries
                      || ', p_recipient_id = ' || p_recipient_id
                      || ', p_entry_id = ' || p_entry_id
                      || ', p_to_company_id = ' ||    p_to_company_id
                      || ', p_to_first_name = ' ||    p_to_first_name
                      || ', p_to_last_name   = ' ||   p_to_last_name
                      || ', p_to_company_name = '||   p_to_company_name);
     END IF;

    IF (l_num_entries = 0) THEN
        insert_or_update_recipient( p_entry_id, p_recipient_id, 'Y', 'N', p_to_company_id, p_to_first_name, p_to_last_name, p_to_company_name);
    ELSE
        SELECT replied_flag INTO l_replied_state
        FROM pon_te_recipients
        WHERE entry_id = p_entry_id
        AND to_id = p_recipient_id;

        insert_or_update_recipient( p_entry_id, p_recipient_id, 'Y', l_replied_state, null, null, null, null);
    END IF;
END update_recipient_to_read;




PROCEDURE record_read(
         p_reader in NUMBER,
         p_entry_id in NUMBER)
IS
BEGIN

    INSERT INTO pon_te_view_audit(
            VIEW_DATE,
            ENTRY_ID,
            VIEWER_PARTY_ID
        )VALUES(
            sysdate,
            p_entry_id,
            p_reader
        );

END record_read;

/*=======================================================================+
-- API Name: GET_REPLIED_BY_LIST
--
-- Type    : Public
--
-- Pre-reqs: None
--
-- Function: This API is called by the Online Discussion code.
--           It returns the list of Buyer's who has already replied to
--           the message for given entry id.
--           This function will retrieve list of buyer's only,it will not
--           include supplier's name. Also, it will consider EXTERNAL messages
--           only.
--
-- Parameters:
--
--              p_to_id            IN NUMBER
--              p_entry_id         IN NUMBER
--              p_auctioneer_tp_id IN NUMBER
--              p_message_type     IN VARCHAR2
--
 *=======================================================================*/

function GET_REPLIED_BY_LIST (p_to_id         IN NUMBER,
                              p_entry_id      IN NUMBER,
                              p_auctioneer_tp_id IN NUMBER,
                              p_message_type IN VARCHAR2)
RETURN VARCHAR2
IS
    v_display_name VARCHAR2(240);
    v_member_list  VARCHAR2(2500);
    l_module_name VARCHAR2(40) := 'GET_REPLIED_BY_LIST';

    CURSOR memberlist(x_entry_id NUMBER,x_auctioneer_tp_id NUMBER, x_to_id NUMBER, x_message_type VARCHAR2) IS
        SELECT PON_LOCALE_PKG.get_party_display_name(PTR.TO_ID, PON_LOCALE_PKG.DEFAULT_NAME_DISPLAY_PATTERN, userenv('LANG')) as name
        FROM  PON_TE_RECIPIENTS PTR
        WHERE PTR.REPLIED_FLAG='Y'
            AND PTR.ENTRY_ID = x_entry_id
            AND PTR.TO_COMPANY_ID = x_auctioneer_tp_id      -- auctioneer's trading partner id
            AND PTR.TO_ID <> x_to_id                        -- Replied by Others
            AND 'EXTERNAL'=x_message_type;                  -- Replied to External Messages
BEGIN

     IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_procedure,
          module => g_module_prefix || l_module_name,
          message  => 'Entering PON_THREAD_DISC_PKG.GET_REPLIED_BY_LIST'
                      || ', p_to_id = ' || p_to_id
                      || ', p_entry_id = ' || p_entry_id
                      || ', p_auctioneer_tp_id = ' || p_auctioneer_tp_id
                      || ', p_message_type = ' || p_message_type);
     END IF;


    FOR teammember IN memberlist(p_entry_id,p_auctioneer_tp_id, p_to_id, p_message_type) LOOP
        IF (v_member_list is not null) THEN
            v_member_list := v_member_list || '; '|| teammember.name;
        ELSE
            v_member_list := teammember.name;
        END IF;
    END LOOP;

RETURN v_member_list;

END GET_REPLIED_BY_LIST;

/*=======================================================================+
-- API Name: GET_RECIPIENTS_LIST
--
-- Type    : Public
--
-- Pre-reqs: None
--
-- Function: This API is called by the Online Discussion code.
--           It returns the list of message recipients for
--           the message for given entry id.
--
-- Parameters:
--
--              p_from_id            IN NUMBER
--              p_entry_id         IN NUMBER
--              p_message_type     IN VARCHAR2
--
 *=======================================================================*/

function GET_RECIPIENTS_LIST (p_from_id         IN NUMBER,
                              p_entry_id      IN NUMBER,
                              p_message_type IN VARCHAR2)
RETURN VARCHAR2
IS
    v_display_name VARCHAR2(240);
    v_member_list  VARCHAR2(2500);
    l_module_name VARCHAR2(40) := 'GET_RECIPIENTS_LIST';
    l_from_company_id NUMBER;

    CURSOR memberlist(x_entry_id NUMBER, x_from_id NUMBER, x_message_type VARCHAR2, x_from_company_id NUMBER) IS
        SELECT PON_LOCALE_PKG.get_party_display_name(PTR.TO_ID, PON_LOCALE_PKG.DEFAULT_NAME_DISPLAY_PATTERN, userenv('LANG')) || DECODE(x_message_type,'EXTERNAL',' - '|| PTR.TO_COMPANY_NAME) as name
        FROM  PON_TE_RECIPIENTS PTR
        WHERE PTR.ENTRY_ID = x_entry_id
            AND PTR.TO_ID <> x_from_id
	    AND ((x_message_type='EXTERNAL' AND PTR.TO_COMPANY_ID <> x_from_company_id)
                 OR x_message_type <> 'EXTERNAL');


BEGIN

     IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_procedure,
          module => g_module_prefix || l_module_name,
          message  => 'Entering PON_THREAD_DISC_PKG.GET_RECIPIENTS_LIST'
                      || ', p_from_id = ' || p_from_id
                      || ', p_entry_id = ' || p_entry_id
                      || ', p_message_type = ' || p_message_type);
     END IF;

    /* Bug 5253337. Buyers viewing EXTERNAL Group messages should not be
       shown in the 'To' field while viewing the message.*/
    SELECT from_company_id
    INTO l_from_company_id
    FROM PON_THREAD_ENTRIES
    WHERE entry_id = p_entry_id;


    FOR teammember IN memberlist(p_entry_id, p_from_id, p_message_type, l_from_company_id ) LOOP
        IF (v_member_list is not null) THEN
            v_member_list := v_member_list || '; '|| teammember.name;
        ELSE
            v_member_list := teammember.name;
        END IF;
    END LOOP;

RETURN v_member_list;

END GET_RECIPIENTS_LIST;

/*=======================================================================+
-- API Name: GET_MESSAGE_STATUS_DISP
--
-- Type    : Public
--
-- Pre-reqs: None
--
-- Function: This API is called by the Print Discussion code.
--           It returns read, unread or replied status of
--           the message for given entry id, depending on viewer.
--
-- Parameters:
--
--              p_viewer_id            IN NUMBER
--              p_entry_id         IN NUMBER
--
 *=======================================================================*/
function GET_MESSAGE_STATUS_DISP (p_viewer_id            IN NUMBER,
                                  p_entry_id      IN NUMBER)
RETURN VARCHAR2
AS
l_msg_read      fnd_new_messages.message_text%TYPE;
l_msg_unread      fnd_new_messages.message_text%TYPE;
l_msg_replied      fnd_new_messages.message_text%TYPE;
l_message_status  fnd_new_messages.message_text%TYPE;
l_module_name VARCHAR2(40) := 'GET_MESSAGE_STATUS_DISP';

BEGIN
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
             FND_LOG.string (log_level => FND_LOG.level_procedure,
             module => g_module_prefix || l_module_name,
             message  => 'Entering PON_THREAD_DISC_PKG.GET_MESSAGE_STATUS_DISP'
                         || ', p_viewer_id = ' || p_viewer_id
                         || ', p_entry_id = ' || p_entry_id);
        END IF;

        -- first get the translated messages for the three statuses
        l_msg_read := fnd_message.get_string('PON', 'PON_TD_READ');
        l_msg_unread := fnd_message.get_string('PON', 'PON_TD_UNREAD');
        l_msg_replied := fnd_message.get_string('PON', 'PON_TD_REPLIED');

        -- then we see if this is a sender or recipient with a record
        SELECT decode(replied_flag, 'Y', l_msg_replied, decode(read_flag, 'Y', l_msg_read, l_msg_unread))
        INTO l_message_status
        FROM pon_thread_entries pte, pon_te_recipients ptr
        WHERE pte.entry_id = p_entry_id
        AND ptr.entry_id = pte.entry_id
        AND ((pte.from_id = p_viewer_id AND pte.from_id = ptr.to_id)
        OR (ptr.to_id = p_viewer_id AND pte.from_id <> ptr.to_id));

        IF SQL%NOTFOUND THEN -- {
           -- message is unread, no record exists
           l_message_status := l_msg_unread;
        END IF; -- }

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
             FND_LOG.string (log_level => FND_LOG.level_procedure,
             module => g_module_prefix || l_module_name,
             message  => 'Exiting PON_THREAD_DISC_PKG.GET_MESSAGE_STATUS_DISP'
                         || ', l_message_status = ' || l_message_status);
        END IF;

        RETURN l_message_status;

EXCEPTION
        WHEN OTHERS THEN
                IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
                     FND_LOG.string (log_level => FND_LOG.level_exception,
                     module => g_module_prefix || l_module_name,
                     message  => 'Exception in PON_THREAD_DISC_PKG.GET_MESSAGE_STATUS_DISP'
                                 || ', returning l_msg_unread = ' || l_msg_unread);
                END IF;
                RETURN l_msg_unread;

END GET_MESSAGE_STATUS_DISP;

end PON_THREAD_DISC_PKG;


/
