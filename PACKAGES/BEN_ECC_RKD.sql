--------------------------------------------------------
--  DDL for Package BEN_ECC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECC_RKD" AUTHID CURRENT_USER as
/* $Header: beeccrhi.pkh 120.0 2005/05/28 01:49:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elctbl_chc_ctfn_id             in number
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_elig_per_elctbl_chc_id_o       in number
 ,p_enrt_bnft_id_o                 in number
 ,p_business_group_id_o            in number
 ,p_ecc_attribute_category_o       in varchar2
 ,p_ecc_attribute1_o               in varchar2
 ,p_ecc_attribute2_o               in varchar2
 ,p_ecc_attribute3_o               in varchar2
 ,p_ecc_attribute4_o               in varchar2
 ,p_ecc_attribute5_o               in varchar2
 ,p_ecc_attribute6_o               in varchar2
 ,p_ecc_attribute7_o               in varchar2
 ,p_ecc_attribute8_o               in varchar2
 ,p_ecc_attribute9_o               in varchar2
 ,p_ecc_attribute10_o              in varchar2
 ,p_ecc_attribute11_o              in varchar2
 ,p_ecc_attribute12_o              in varchar2
 ,p_ecc_attribute13_o              in varchar2
 ,p_ecc_attribute14_o              in varchar2
 ,p_ecc_attribute15_o              in varchar2
 ,p_ecc_attribute16_o              in varchar2
 ,p_ecc_attribute17_o              in varchar2
 ,p_ecc_attribute18_o              in varchar2
 ,p_ecc_attribute19_o              in varchar2
 ,p_ecc_attribute20_o              in varchar2
 ,p_ecc_attribute21_o              in varchar2
 ,p_ecc_attribute22_o              in varchar2
 ,p_ecc_attribute23_o              in varchar2
 ,p_ecc_attribute24_o              in varchar2
 ,p_ecc_attribute25_o              in varchar2
 ,p_ecc_attribute26_o              in varchar2
 ,p_ecc_attribute27_o              in varchar2
 ,p_ecc_attribute28_o              in varchar2
 ,p_ecc_attribute29_o              in varchar2
 ,p_ecc_attribute30_o              in varchar2
 ,p_susp_if_ctfn_not_prvd_flag_o   in varchar2
 ,p_ctfn_determine_cd_o            in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_ecc_rkd;

 

/
