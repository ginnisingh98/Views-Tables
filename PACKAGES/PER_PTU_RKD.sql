--------------------------------------------------------
--  DDL for Package PER_PTU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PTU_RKD" AUTHID CURRENT_USER as
/* $Header: pepturhi.pkh 120.0 2005/05/31 15:58:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_person_type_usage_id           in number,
  p_person_id_o                    in number,
  p_person_type_id_o               in number,
  p_effective_start_date_o         in date,
  p_effective_end_date_o           in date,
  p_object_version_number_o        in number,
  p_request_id_o                   in number,
  p_program_application_id_o       in number,
  p_program_id_o                   in number,
  p_program_update_date_o          in date,
  p_attribute_category_o           in varchar2,
  p_attribute1_o                   in varchar2,
  p_attribute2_o                   in varchar2,
  p_attribute3_o                   in varchar2,
  p_attribute4_o                   in varchar2,
  p_attribute5_o                   in varchar2,
  p_attribute6_o                   in varchar2,
  p_attribute7_o                   in varchar2,
  p_attribute8_o                   in varchar2,
  p_attribute9_o                   in varchar2,
  p_attribute10_o                  in varchar2,
  p_attribute11_o                  in varchar2,
  p_attribute12_o                  in varchar2,
  p_attribute13_o                  in varchar2,
  p_attribute14_o                  in varchar2,
  p_attribute15_o                  in varchar2,
  p_attribute16_o                  in varchar2,
  p_attribute17_o                  in varchar2,
  p_attribute18_o                  in varchar2,
  p_attribute19_o                  in varchar2,
  p_attribute20_o                  in varchar2,
  p_attribute21_o                  in varchar2,
  p_attribute22_o                  in varchar2,
  p_attribute23_o                  in varchar2,
  p_attribute24_o                  in varchar2,
  p_attribute25_o                  in varchar2,
  p_attribute26_o                  in varchar2,
  p_attribute27_o                  in varchar2,
  p_attribute28_o                  in varchar2,
  p_attribute29_o                  in varchar2,
  p_attribute30_o                  in varchar2,
  p_effective_date                 in date,
  p_datetrack_mode                 in varchar2,
  p_validation_start_date          in date,
  p_validation_end_date            in date,
  p_effective_start_date           in date,
  p_effective_end_date             in date,
  p_object_version_number          in number
  );

end per_ptu_rkd;

 

/
