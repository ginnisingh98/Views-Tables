--------------------------------------------------------
--  DDL for Package BEN_PIL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_RKD" AUTHID CURRENT_USER as
/* $Header: bepilrhi.pkh 120.0 2005/05/28 10:50:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_per_in_ler_id                  in number
 ,p_per_in_ler_stat_cd_o           in varchar2
 ,p_prvs_stat_cd_o                 in varchar2
 ,p_lf_evt_ocrd_dt_o               in date
 ,p_trgr_table_pk_id_o             in number
 ,p_procd_dt_o                     in date
 ,p_strtd_dt_o                     in date
 ,p_voidd_dt_o                     in date
 ,p_bckt_dt_o                      in date
 ,p_clsd_dt_o                      in date
 ,p_ntfn_dt_o                      in date
 ,p_ptnl_ler_for_per_id_o          in number
 ,p_bckt_per_in_ler_id_o           in number
 ,p_ler_id_o                       in number
 ,p_person_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_ASSIGNMENT_ID_o                in  number
 ,p_WS_MGR_ID_o                    in  number
 ,p_GROUP_PL_ID_o                  in  number
 ,p_MGR_OVRID_PERSON_ID_o          in  number
 ,p_MGR_OVRID_DT_o                 in  date
 ,p_pil_attribute_category_o       in varchar2
 ,p_pil_attribute1_o               in varchar2
 ,p_pil_attribute2_o               in varchar2
 ,p_pil_attribute3_o               in varchar2
 ,p_pil_attribute4_o               in varchar2
 ,p_pil_attribute5_o               in varchar2
 ,p_pil_attribute6_o               in varchar2
 ,p_pil_attribute7_o               in varchar2
 ,p_pil_attribute8_o               in varchar2
 ,p_pil_attribute9_o               in varchar2
 ,p_pil_attribute10_o              in varchar2
 ,p_pil_attribute11_o              in varchar2
 ,p_pil_attribute12_o              in varchar2
 ,p_pil_attribute13_o              in varchar2
 ,p_pil_attribute14_o              in varchar2
 ,p_pil_attribute15_o              in varchar2
 ,p_pil_attribute16_o              in varchar2
 ,p_pil_attribute17_o              in varchar2
 ,p_pil_attribute18_o              in varchar2
 ,p_pil_attribute19_o              in varchar2
 ,p_pil_attribute20_o              in varchar2
 ,p_pil_attribute21_o              in varchar2
 ,p_pil_attribute22_o              in varchar2
 ,p_pil_attribute23_o              in varchar2
 ,p_pil_attribute24_o              in varchar2
 ,p_pil_attribute25_o              in varchar2
 ,p_pil_attribute26_o              in varchar2
 ,p_pil_attribute27_o              in varchar2
 ,p_pil_attribute28_o              in varchar2
 ,p_pil_attribute29_o              in varchar2
 ,p_pil_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_pil_rkd;

 

/
