--------------------------------------------------------
--  DDL for Package IRC_IPC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IPC_RKD" AUTHID CURRENT_USER as
/* $Header: iripcrhi.pkh 120.0 2005/07/26 15:08:59 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_posting_content_id           in number
  ,p_display_manager_info_o       in varchar2
  ,p_display_recruiter_info_o     in varchar2
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
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_ipc_information_category_o   in varchar2
  ,p_ipc_information1_o           in varchar2
  ,p_ipc_information2_o           in varchar2
  ,p_ipc_information3_o           in varchar2
  ,p_ipc_information4_o           in varchar2
  ,p_ipc_information5_o           in varchar2
  ,p_ipc_information6_o           in varchar2
  ,p_ipc_information7_o           in varchar2
  ,p_ipc_information8_o           in varchar2
  ,p_ipc_information9_o           in varchar2
  ,p_ipc_information10_o          in varchar2
  ,p_ipc_information11_o          in varchar2
  ,p_ipc_information12_o          in varchar2
  ,p_ipc_information13_o          in varchar2
  ,p_ipc_information14_o          in varchar2
  ,p_ipc_information15_o          in varchar2
  ,p_ipc_information16_o          in varchar2
  ,p_ipc_information17_o          in varchar2
  ,p_ipc_information18_o          in varchar2
  ,p_ipc_information19_o          in varchar2
  ,p_ipc_information20_o          in varchar2
  ,p_ipc_information21_o          in varchar2
  ,p_ipc_information22_o          in varchar2
  ,p_ipc_information23_o          in varchar2
  ,p_ipc_information24_o          in varchar2
  ,p_ipc_information25_o          in varchar2
  ,p_ipc_information26_o          in varchar2
  ,p_ipc_information27_o          in varchar2
  ,p_ipc_information28_o          in varchar2
  ,p_ipc_information29_o          in varchar2
  ,p_ipc_information30_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_date_approved_o              in date
  ,p_recruiter_full_name_o        in varchar2
  ,p_recruiter_email_o            in varchar2
  ,p_recruiter_work_telephone_o   in varchar2
  ,p_manager_full_name_o          in varchar2
  ,p_manager_email_o              in varchar2
  ,p_manager_work_telephone_o     in varchar2
  );
--
end irc_ipc_rkd;

 

/
