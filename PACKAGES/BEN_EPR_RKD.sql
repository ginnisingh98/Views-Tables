--------------------------------------------------------
--  DDL for Package BEN_EPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPR_RKD" AUTHID CURRENT_USER as
/* $Header: beeprrhi.pkh 120.0 2005/05/28 02:44:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_enrt_prem_id                   in number
 ,p_val_o                          in number
 ,p_uom_o                          in varchar2
 ,p_elig_per_elctbl_chc_id_o       in number
 ,p_enrt_bnft_id_o                 in number
 ,p_actl_prem_id_o                 in number
 ,p_business_group_id_o            in number
 ,p_epr_attribute_category_o       in varchar2
 ,p_epr_attribute1_o               in varchar2
 ,p_epr_attribute2_o               in varchar2
 ,p_epr_attribute3_o               in varchar2
 ,p_epr_attribute4_o               in varchar2
 ,p_epr_attribute5_o               in varchar2
 ,p_epr_attribute6_o               in varchar2
 ,p_epr_attribute7_o               in varchar2
 ,p_epr_attribute8_o               in varchar2
 ,p_epr_attribute9_o               in varchar2
 ,p_epr_attribute10_o              in varchar2
 ,p_epr_attribute11_o              in varchar2
 ,p_epr_attribute12_o              in varchar2
 ,p_epr_attribute13_o              in varchar2
 ,p_epr_attribute14_o              in varchar2
 ,p_epr_attribute15_o              in varchar2
 ,p_epr_attribute16_o              in varchar2
 ,p_epr_attribute17_o              in varchar2
 ,p_epr_attribute18_o              in varchar2
 ,p_epr_attribute19_o              in varchar2
 ,p_epr_attribute20_o              in varchar2
 ,p_epr_attribute21_o              in varchar2
 ,p_epr_attribute22_o              in varchar2
 ,p_epr_attribute23_o              in varchar2
 ,p_epr_attribute24_o              in varchar2
 ,p_epr_attribute25_o              in varchar2
 ,p_epr_attribute26_o              in varchar2
 ,p_epr_attribute27_o              in varchar2
 ,p_epr_attribute28_o              in varchar2
 ,p_epr_attribute29_o              in varchar2
 ,p_epr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
  );
--
end ben_epr_rkd;

 

/
