--------------------------------------------------------
--  DDL for Package PQH_PSU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PSU_RKD" AUTHID CURRENT_USER as
/* $Header: pqpsurhi.pkh 120.0 2005/05/29 02:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_emp_stat_situation_id        in number
  ,p_statutory_situation_id_o     in number
  ,p_person_id_o                  in number
  ,p_provisional_start_date_o     in date
  ,p_provisional_end_date_o       in date
  ,p_actual_start_date_o          in date
  ,p_actual_end_date_o            in date
  ,p_approval_flag_o              in varchar2
  ,p_comments_o                   in varchar2
  ,p_contact_person_id_o          in number
  ,p_contact_relationship_o       in varchar2
  ,p_external_organization_id_o   in number
  ,p_renewal_flag_o               in varchar2
  ,p_renew_stat_situation_id_o    in number
  ,p_seconded_career_id_o         in number
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
  ,p_object_version_number_o      in number
  );
--
end pqh_psu_rkd;

 

/
