--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_PREFS_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_PREFS_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_notification_prefs_a (
p_party_id                     number,
p_person_id                    number,
p_notification_preference_id   number,
p_effective_date               date,
p_matching_jobs                varchar2,
p_matching_job_freq            varchar2,
p_allow_access                 varchar2,
p_receive_info_mail            varchar2,
p_object_version_number        number,
p_address_id                   number,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_attribute21                  varchar2,
p_attribute22                  varchar2,
p_attribute23                  varchar2,
p_attribute24                  varchar2,
p_attribute25                  varchar2,
p_attribute26                  varchar2,
p_attribute27                  varchar2,
p_attribute28                  varchar2,
p_attribute29                  varchar2,
p_attribute30                  varchar2,
p_agency_id                    number,
p_attempt_id                   number);
end irc_notification_prefs_be2;

/
