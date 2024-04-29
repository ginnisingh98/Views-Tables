--------------------------------------------------------
--  DDL for Package BEN_ERC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ERC_RKD" AUTHID CURRENT_USER as
/* $Header: beercrhi.pkh 120.0 2005/05/28 02:50:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_enrt_rt_ctfn_id                in number
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_enrt_rt_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_erc_attribute_category_o       in varchar2
 ,p_erc_attribute1_o               in varchar2
 ,p_erc_attribute2_o               in varchar2
 ,p_erc_attribute3_o               in varchar2
 ,p_erc_attribute4_o               in varchar2
 ,p_erc_attribute5_o               in varchar2
 ,p_erc_attribute6_o               in varchar2
 ,p_erc_attribute7_o               in varchar2
 ,p_erc_attribute8_o               in varchar2
 ,p_erc_attribute9_o               in varchar2
 ,p_erc_attribute10_o              in varchar2
 ,p_erc_attribute11_o              in varchar2
 ,p_erc_attribute12_o              in varchar2
 ,p_erc_attribute13_o              in varchar2
 ,p_erc_attribute14_o              in varchar2
 ,p_erc_attribute15_o              in varchar2
 ,p_erc_attribute16_o              in varchar2
 ,p_erc_attribute17_o              in varchar2
 ,p_erc_attribute18_o              in varchar2
 ,p_erc_attribute19_o              in varchar2
 ,p_erc_attribute20_o              in varchar2
 ,p_erc_attribute21_o              in varchar2
 ,p_erc_attribute22_o              in varchar2
 ,p_erc_attribute23_o              in varchar2
 ,p_erc_attribute24_o              in varchar2
 ,p_erc_attribute25_o              in varchar2
 ,p_erc_attribute26_o              in varchar2
 ,p_erc_attribute27_o              in varchar2
 ,p_erc_attribute28_o              in varchar2
 ,p_erc_attribute29_o              in varchar2
 ,p_erc_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_erc_rkd;

 

/
