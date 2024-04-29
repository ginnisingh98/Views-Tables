--------------------------------------------------------
--  DDL for Package IRC_POSTING_CONTENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_POSTING_CONTENT_BK2" AUTHID CURRENT_USER as
/* $Header: iripcapi.pkh 120.7 2008/02/21 14:21:22 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_posting_content_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_posting_content_b
(
 P_POSTING_CONTENT_ID         in number
,P_DISPLAY_MANAGER_INFO       in varchar2
,P_DISPLAY_RECRUITER_INFO     in varchar2
,P_LANGUAGE_CODE              in varchar2
,P_NAME                       in varchar2
,P_ORG_NAME                   in varchar2
,P_ORG_DESCRIPTION            in varchar2
,P_JOB_TITLE                  in varchar2
,P_BRIEF_DESCRIPTION          in varchar2
,P_DETAILED_DESCRIPTION       in varchar2
,P_JOB_REQUIREMENTS           in varchar2
,P_ADDITIONAL_DETAILS         in varchar2
,P_HOW_TO_APPLY               in varchar2
,P_BENEFIT_INFO               in varchar2
,P_IMAGE_URL                  in varchar2
,P_ALT_IMAGE_URL              in varchar2
,P_ATTRIBUTE_CATEGORY         in varchar2
,P_ATTRIBUTE1                 in varchar2
,P_ATTRIBUTE2                 in varchar2
,P_ATTRIBUTE3                 in varchar2
,P_ATTRIBUTE4                 in varchar2
,P_ATTRIBUTE5                 in varchar2
,P_ATTRIBUTE6                 in varchar2
,P_ATTRIBUTE7                 in varchar2
,P_ATTRIBUTE8                 in varchar2
,P_ATTRIBUTE9                 in varchar2
,P_ATTRIBUTE10                in varchar2
,P_ATTRIBUTE11                in varchar2
,P_ATTRIBUTE12                in varchar2
,P_ATTRIBUTE13                in varchar2
,P_ATTRIBUTE14                in varchar2
,P_ATTRIBUTE15                in varchar2
,P_ATTRIBUTE16                in varchar2
,P_ATTRIBUTE17                in varchar2
,P_ATTRIBUTE18                in varchar2
,P_ATTRIBUTE19                in varchar2
,P_ATTRIBUTE20                in varchar2
,P_ATTRIBUTE21                in varchar2
,P_ATTRIBUTE22                in varchar2
,P_ATTRIBUTE23                in varchar2
,P_ATTRIBUTE24                in varchar2
,P_ATTRIBUTE25                in varchar2
,P_ATTRIBUTE26                in varchar2
,P_ATTRIBUTE27                in varchar2
,P_ATTRIBUTE28                in varchar2
,P_ATTRIBUTE29                in varchar2
,P_ATTRIBUTE30                in varchar2
,P_IPC_INFORMATION_CATEGORY   in varchar2
,P_IPC_INFORMATION1           in varchar2
,P_IPC_INFORMATION2           in varchar2
,P_IPC_INFORMATION3           in varchar2
,P_IPC_INFORMATION4           in varchar2
,P_IPC_INFORMATION5           in varchar2
,P_IPC_INFORMATION6           in varchar2
,P_IPC_INFORMATION7           in varchar2
,P_IPC_INFORMATION8           in varchar2
,P_IPC_INFORMATION9           in varchar2
,P_IPC_INFORMATION10          in varchar2
,P_IPC_INFORMATION11          in varchar2
,P_IPC_INFORMATION12          in varchar2
,P_IPC_INFORMATION13          in varchar2
,P_IPC_INFORMATION14          in varchar2
,P_IPC_INFORMATION15          in varchar2
,P_IPC_INFORMATION16          in varchar2
,P_IPC_INFORMATION17          in varchar2
,P_IPC_INFORMATION18          in varchar2
,P_IPC_INFORMATION19          in varchar2
,P_IPC_INFORMATION20          in varchar2
,P_IPC_INFORMATION21          in varchar2
,P_IPC_INFORMATION22          in varchar2
,P_IPC_INFORMATION23          in varchar2
,P_IPC_INFORMATION24          in varchar2
,P_IPC_INFORMATION25          in varchar2
,P_IPC_INFORMATION26          in varchar2
,P_IPC_INFORMATION27          in varchar2
,P_IPC_INFORMATION28          in varchar2
,P_IPC_INFORMATION29          in varchar2
,P_IPC_INFORMATION30          in varchar2
,P_OBJECT_VERSION_NUMBER      in number
,P_DATE_APPROVED              in  date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_posting_content_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_posting_content_a
(
 P_POSTING_CONTENT_ID         in number
,P_DISPLAY_MANAGER_INFO       in varchar2
,P_DISPLAY_RECRUITER_INFO     in varchar2
,P_LANGUAGE_CODE              in varchar2
,P_NAME                       in varchar2
,P_ORG_NAME                   in varchar2
,P_ORG_DESCRIPTION            in varchar2
,P_JOB_TITLE                  in varchar2
,P_BRIEF_DESCRIPTION          in varchar2
,P_DETAILED_DESCRIPTION       in varchar2
,P_JOB_REQUIREMENTS           in varchar2
,P_ADDITIONAL_DETAILS         in varchar2
,P_HOW_TO_APPLY               in varchar2
,P_BENEFIT_INFO               in varchar2
,P_IMAGE_URL                  in varchar2
,P_ALT_IMAGE_URL              in varchar2
,P_ATTRIBUTE_CATEGORY         in varchar2
,P_ATTRIBUTE1                 in varchar2
,P_ATTRIBUTE2                 in varchar2
,P_ATTRIBUTE3                 in varchar2
,P_ATTRIBUTE4                 in varchar2
,P_ATTRIBUTE5                 in varchar2
,P_ATTRIBUTE6                 in varchar2
,P_ATTRIBUTE7                 in varchar2
,P_ATTRIBUTE8                 in varchar2
,P_ATTRIBUTE9                 in varchar2
,P_ATTRIBUTE10                in varchar2
,P_ATTRIBUTE11                in varchar2
,P_ATTRIBUTE12                in varchar2
,P_ATTRIBUTE13                in varchar2
,P_ATTRIBUTE14                in varchar2
,P_ATTRIBUTE15                in varchar2
,P_ATTRIBUTE16                in varchar2
,P_ATTRIBUTE17                in varchar2
,P_ATTRIBUTE18                in varchar2
,P_ATTRIBUTE19                in varchar2
,P_ATTRIBUTE20                in varchar2
,P_ATTRIBUTE21                in varchar2
,P_ATTRIBUTE22                in varchar2
,P_ATTRIBUTE23                in varchar2
,P_ATTRIBUTE24                in varchar2
,P_ATTRIBUTE25                in varchar2
,P_ATTRIBUTE26                in varchar2
,P_ATTRIBUTE27                in varchar2
,P_ATTRIBUTE28                in varchar2
,P_ATTRIBUTE29                in varchar2
,P_ATTRIBUTE30                in varchar2
,P_IPC_INFORMATION_CATEGORY   in varchar2
,P_IPC_INFORMATION1           in varchar2
,P_IPC_INFORMATION2           in varchar2
,P_IPC_INFORMATION3           in varchar2
,P_IPC_INFORMATION4           in varchar2
,P_IPC_INFORMATION5           in varchar2
,P_IPC_INFORMATION6           in varchar2
,P_IPC_INFORMATION7           in varchar2
,P_IPC_INFORMATION8           in varchar2
,P_IPC_INFORMATION9           in varchar2
,P_IPC_INFORMATION10          in varchar2
,P_IPC_INFORMATION11          in varchar2
,P_IPC_INFORMATION12          in varchar2
,P_IPC_INFORMATION13          in varchar2
,P_IPC_INFORMATION14          in varchar2
,P_IPC_INFORMATION15          in varchar2
,P_IPC_INFORMATION16          in varchar2
,P_IPC_INFORMATION17          in varchar2
,P_IPC_INFORMATION18          in varchar2
,P_IPC_INFORMATION19          in varchar2
,P_IPC_INFORMATION20          in varchar2
,P_IPC_INFORMATION21          in varchar2
,P_IPC_INFORMATION22          in varchar2
,P_IPC_INFORMATION23          in varchar2
,P_IPC_INFORMATION24          in varchar2
,P_IPC_INFORMATION25          in varchar2
,P_IPC_INFORMATION26          in varchar2
,P_IPC_INFORMATION27          in varchar2
,P_IPC_INFORMATION28          in varchar2
,P_IPC_INFORMATION29          in varchar2
,P_IPC_INFORMATION30          in varchar2
,P_OBJECT_VERSION_NUMBER      in number
,P_DATE_APPROVED              in  date
);
--
end IRC_POSTING_CONTENT_BK2;

/
