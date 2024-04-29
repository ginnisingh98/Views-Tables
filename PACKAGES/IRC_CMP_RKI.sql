--------------------------------------------------------
--  DDL for Package IRC_CMP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMP_RKI" AUTHID CURRENT_USER as
/* $Header: ircmprhi.pkh 120.0 2007/11/19 11:40:35 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_communication_property_id    in number
  ,p_object_type                  in varchar2
  ,p_object_id                    in number
  ,p_default_comm_status          in varchar2
  ,p_allow_attachment_flag        in varchar2
  ,p_auto_notification_flag       in varchar2
  ,p_allow_add_recipients         in varchar2
  ,p_default_moderator            in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_information_category         in varchar2
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4                 in varchar2
  ,p_information5                 in varchar2
  ,p_information6                 in varchar2
  ,p_information7                 in varchar2
  ,p_information8                 in varchar2
  ,p_information9                 in varchar2
  ,p_information10                in varchar2
  ,p_object_version_number        in number
  );
end irc_cmp_rki;

/
