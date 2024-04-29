--------------------------------------------------------
--  DDL for Package BEN_PPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPR_RKD" AUTHID CURRENT_USER as
/* $Header: bepprrhi.pkh 120.0.12010000.1 2008/07/29 12:52:27 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prmry_care_prvdr_id            in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_prmry_care_prvdr_typ_cd_o      in varchar2
 ,p_name_o                         in varchar2
 ,p_ext_ident_o                    in varchar2
 ,p_prtt_enrt_rslt_id_o            in number
 ,p_elig_cvrd_dpnt_id_o            in number
 ,p_business_group_id_o            in number
 ,p_ppr_attribute_category_o       in varchar2
 ,p_ppr_attribute1_o               in varchar2
 ,p_ppr_attribute2_o               in varchar2
 ,p_ppr_attribute3_o               in varchar2
 ,p_ppr_attribute4_o               in varchar2
 ,p_ppr_attribute5_o               in varchar2
 ,p_ppr_attribute6_o               in varchar2
 ,p_ppr_attribute7_o               in varchar2
 ,p_ppr_attribute8_o               in varchar2
 ,p_ppr_attribute9_o               in varchar2
 ,p_ppr_attribute10_o              in varchar2
 ,p_ppr_attribute11_o              in varchar2
 ,p_ppr_attribute12_o              in varchar2
 ,p_ppr_attribute13_o              in varchar2
 ,p_ppr_attribute14_o              in varchar2
 ,p_ppr_attribute15_o              in varchar2
 ,p_ppr_attribute16_o              in varchar2
 ,p_ppr_attribute17_o              in varchar2
 ,p_ppr_attribute18_o              in varchar2
 ,p_ppr_attribute19_o              in varchar2
 ,p_ppr_attribute20_o              in varchar2
 ,p_ppr_attribute21_o              in varchar2
 ,p_ppr_attribute22_o              in varchar2
 ,p_ppr_attribute23_o              in varchar2
 ,p_ppr_attribute24_o              in varchar2
 ,p_ppr_attribute25_o              in varchar2
 ,p_ppr_attribute26_o              in varchar2
 ,p_ppr_attribute27_o              in varchar2
 ,p_ppr_attribute28_o              in varchar2
 ,p_ppr_attribute29_o              in varchar2
 ,p_ppr_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_ppr_rkd;

/
