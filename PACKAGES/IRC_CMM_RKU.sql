--------------------------------------------------------
--  DDL for Package IRC_CMM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMM_RKU" AUTHID CURRENT_USER as
/* $Header: ircmmrhi.pkh 120.0 2007/11/19 11:33:35 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_communication_message_id     in number
  ,p_parent_id                    in number
  ,p_communication_topic_id       in number
  ,p_message_subject              in varchar2
  ,p_message_body                 in varchar2
  ,p_message_post_date            in date
  ,p_sender_type                  in varchar2
  ,p_sender_id                    in number
  ,p_document_type                in varchar2
  ,p_document_id                  in number
  ,p_deleted_flag                 in varchar2
  ,p_object_version_number        in number
  ,p_parent_id_o                  in number
  ,p_communication_topic_id_o     in number
  ,p_message_subject_o            in varchar2
  ,p_message_body_o               in varchar2
  ,p_message_post_date_o          in date
  ,p_sender_type_o                in varchar2
  ,p_sender_id_o                  in number
  ,p_document_type_o              in varchar2
  ,p_document_id_o                in number
  ,p_deleted_flag_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_cmm_rku;

/