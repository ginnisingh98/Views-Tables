--------------------------------------------------------
--  DDL for Package IRC_CMP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMP_RKD" AUTHID CURRENT_USER as
/* $Header: ircmprhi.pkh 120.0 2007/11/19 11:40:35 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_communication_property_id    in number
  ,p_object_type_o                in varchar2
  ,p_object_id_o                  in number
  ,p_default_comm_status_o        in varchar2
  ,p_allow_attachment_flag_o      in varchar2
  ,p_auto_notification_flag_o     in varchar2
  ,p_allow_add_recipients_o       in varchar2
  ,p_default_moderator_o          in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_information_category_o       in varchar2
  ,p_information1_o               in varchar2
  ,p_information2_o               in varchar2
  ,p_information3_o               in varchar2
  ,p_information4_o               in varchar2
  ,p_information5_o               in varchar2
  ,p_information6_o               in varchar2
  ,p_information7_o               in varchar2
  ,p_information8_o               in varchar2
  ,p_information9_o               in varchar2
  ,p_information10_o              in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_cmp_rkd;

/
