--------------------------------------------------------
--  DDL for Package IRC_INP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_INP_RKD" AUTHID CURRENT_USER as
/* $Header: irinprhi.pkh 120.1 2006/02/15 16:07:32 gjaggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_party_id_o                   in number
  ,p_person_id_o                  in number
  ,p_notification_preference_id   in number
  ,p_matching_jobs_o              in varchar2
  ,p_matching_job_freq_o          in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_receive_info_mail_o          in varchar2
  ,p_allow_access_o               in varchar2
  ,p_address_id_o                 in number
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
  ,p_object_version_number_o      in number
  ,p_agency_id_o                  in number
  ,p_attempt_id_o                 in number
  );
--
end irc_inp_rkd;

 

/
