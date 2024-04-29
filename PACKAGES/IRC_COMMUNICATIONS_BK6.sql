--------------------------------------------------------
--  DDL for Package IRC_COMMUNICATIONS_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_COMMUNICATIONS_BK6" AUTHID CURRENT_USER as
/* $Header: ircomapi.pkh 120.2.12010000.4 2010/04/07 09:53:10 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_MESSAGE_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_MESSAGE_b
    (p_effective_date            in date
    ,p_communication_topic_id    in number
    ,p_parent_id                 in number
    ,p_message_subject           in varchar2
    ,p_message_post_date         in date
    ,p_sender_type               in varchar2
    ,p_sender_id                 in number
    ,p_message_body              in varchar2
    ,p_document_type             in varchar2
    ,p_document_id               in number
    ,p_deleted_flag              in varchar2
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_MESSAGE_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_MESSAGE_a
    (p_effective_date            in date
    ,p_communication_topic_id    in number
    ,p_parent_id                 in number
    ,p_message_subject           in varchar2
    ,p_message_post_date         in date
    ,p_sender_type               in varchar2
    ,p_sender_id                 in number
    ,p_message_body              in varchar2
    ,p_document_type             in varchar2
    ,p_document_id               in number
    ,p_deleted_flag              in varchar2
    ,p_communication_message_id  in number
    ,p_object_version_number     in number
    );
--
end IRC_COMMUNICATIONS_BK6;

/
