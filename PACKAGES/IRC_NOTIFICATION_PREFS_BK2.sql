--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_PREFS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_PREFS_BK2" AUTHID CURRENT_USER as
/* $Header: irinpapi.pkh 120.4 2008/02/21 14:16:27 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< update_notification_prefs_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_notification_prefs_b
  (p_party_id                      in     number
  ,p_person_id                     in     number
  ,p_notification_preference_id    in     number
  ,p_effective_date                in     date
  ,p_matching_jobs                 in     varchar2
  ,p_matching_job_freq             in     varchar2
  ,p_allow_access                  in     varchar2
  ,p_receive_info_mail             in     varchar2
  ,p_object_version_number         in     number
  ,p_address_id                    in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_agency_id                     in     number
  ,p_attempt_id                    in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< update_notification_prefs_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_notification_prefs_a
  (p_party_id                      in     number
  ,p_person_id                     in     number
  ,p_notification_preference_id    in     number
  ,p_effective_date                in     date
  ,p_matching_jobs                 in     varchar2
  ,p_matching_job_freq             in     varchar2
  ,p_allow_access                  in     varchar2
  ,p_receive_info_mail             in     varchar2
  ,p_object_version_number         in     number
  ,p_address_id                    in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_agency_id                     in     number
  ,p_attempt_id                    in     number
  );
--
end IRC_NOTIFICATION_PREFS_BK2;

/
