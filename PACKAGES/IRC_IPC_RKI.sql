--------------------------------------------------------
--  DDL for Package IRC_IPC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IPC_RKI" AUTHID CURRENT_USER as
/* $Header: iripcrhi.pkh 120.0 2005/07/26 15:08:59 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_posting_content_id           in number
  ,p_display_manager_info         in varchar2
  ,p_display_recruiter_info       in varchar2
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
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_ipc_information_category     in varchar2
  ,p_ipc_information1             in varchar2
  ,p_ipc_information2             in varchar2
  ,p_ipc_information3             in varchar2
  ,p_ipc_information4             in varchar2
  ,p_ipc_information5             in varchar2
  ,p_ipc_information6             in varchar2
  ,p_ipc_information7             in varchar2
  ,p_ipc_information8             in varchar2
  ,p_ipc_information9             in varchar2
  ,p_ipc_information10            in varchar2
  ,p_ipc_information11            in varchar2
  ,p_ipc_information12            in varchar2
  ,p_ipc_information13            in varchar2
  ,p_ipc_information14            in varchar2
  ,p_ipc_information15            in varchar2
  ,p_ipc_information16            in varchar2
  ,p_ipc_information17            in varchar2
  ,p_ipc_information18            in varchar2
  ,p_ipc_information19            in varchar2
  ,p_ipc_information20            in varchar2
  ,p_ipc_information21            in varchar2
  ,p_ipc_information22            in varchar2
  ,p_ipc_information23            in varchar2
  ,p_ipc_information24            in varchar2
  ,p_ipc_information25            in varchar2
  ,p_ipc_information26            in varchar2
  ,p_ipc_information27            in varchar2
  ,p_ipc_information28            in varchar2
  ,p_ipc_information29            in varchar2
  ,p_ipc_information30            in varchar2
  ,p_object_version_number        in number
  ,p_date_approved                in date
  ,p_recruiter_full_name          in varchar2
  ,p_recruiter_email              in varchar2
  ,p_recruiter_work_telephone     in varchar2
  ,p_manager_full_name            in varchar2
  ,p_manager_email                in varchar2
  ,p_manager_work_telephone       in varchar2
  );
end irc_ipc_rki;

 

/