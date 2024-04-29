--------------------------------------------------------
--  DDL for Package PON_THREAD_DISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_THREAD_DISC_PKG" AUTHID CURRENT_USER as
/* $Header: PONTHDIS.pls 120.3 2007/08/13 04:49:29 adsahay ship $ */


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
return NUMBER;

function insert_pon_threads(
         p_discussion_id           IN NUMBER,
         p_subject                 IN VARCHAR2,
         p_language_code           IN VARCHAR2,
         p_party_id                IN NUMBER)
return NUMBER;

function insert_thread_entry(
         p_from_id in NUMBER,
         p_from_first_name in VARCHAR2,
         p_from_last_name in VARCHAR2,
         p_subject in VARCHAR2,
         p_discussion_id in VARCHAR2,
         p_thread_id in NUMBER,
         p_broadcast_flag in VARCHAR2,
         p_parent_id in NUMBER)
return NUMBER;

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
--
-- Parameters:
--
--              p_to_id            IN NUMBER
--              p_entry_id         IN NUMBER
--              p_auctioneer_tp_id IN NUMBER
--              p_message_type     IN VARCHAR2
--
 *=======================================================================*/


function GET_REPLIED_BY_LIST (p_to_id IN NUMBER,
p_entry_id      IN NUMBER,
p_auctioneer_tp_id IN NUMBER,
p_message_type IN VARCHAR2)
return VARCHAR2;


PROCEDURE update_recipient_to_read(
p_entry_id in NUMBER,
p_recipient_id in NUMBER,
p_to_company_id in NUMBER,
p_to_first_name in VARCHAR2,
p_to_last_name in VARCHAR2,
p_to_company_name in VARCHAR2);


procedure insert_or_update_recipient(
p_entry_id in NUMBER,
p_recipient_id in NUMBER,
p_read_flag in VARCHAR2,
p_replied_flag in VARCHAR2,
p_to_company_id in NUMBER,
p_to_first_name in VARCHAR2,
p_to_last_name in VARCHAR2,
p_to_company_name in VARCHAR2);


procedure record_read(
         p_reader in NUMBER,
         p_entry_id in NUMBER);

/*=======================================================================+
-- API Name: GET_REPLIED_BY_LIST
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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

end PON_THREAD_DISC_PKG;


/
