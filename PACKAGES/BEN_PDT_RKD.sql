--------------------------------------------------------
--  DDL for Package BEN_PDT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDT_RKD" AUTHID CURRENT_USER as
/* $Header: bepdtrhi.pkh 120.0 2005/05/28 10:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_pymt_check_det_id            in number
  ,p_person_id_o                  in number
  ,p_business_group_id_o          in number
  ,p_check_num_o                  in varchar2
  ,p_pymt_dt_o                    in date
  ,p_pymt_amt_o                   in number
  ,p_pdt_attribute_category_o     in varchar2
  ,p_pdt_attribute1_o             in varchar2
  ,p_pdt_attribute2_o             in varchar2
  ,p_pdt_attribute3_o             in varchar2
  ,p_pdt_attribute4_o             in varchar2
  ,p_pdt_attribute5_o             in varchar2
  ,p_pdt_attribute6_o             in varchar2
  ,p_pdt_attribute7_o             in varchar2
  ,p_pdt_attribute8_o             in varchar2
  ,p_pdt_attribute9_o             in varchar2
  ,p_pdt_attribute10_o            in varchar2
  ,p_pdt_attribute11_o            in varchar2
  ,p_pdt_attribute12_o            in varchar2
  ,p_pdt_attribute13_o            in varchar2
  ,p_pdt_attribute14_o            in varchar2
  ,p_pdt_attribute15_o            in varchar2
  ,p_pdt_attribute16_o            in varchar2
  ,p_pdt_attribute17_o            in varchar2
  ,p_pdt_attribute18_o            in varchar2
  ,p_pdt_attribute19_o            in varchar2
  ,p_pdt_attribute20_o            in varchar2
  ,p_pdt_attribute21_o            in varchar2
  ,p_pdt_attribute22_o            in varchar2
  ,p_pdt_attribute23_o            in varchar2
  ,p_pdt_attribute24_o            in varchar2
  ,p_pdt_attribute25_o            in varchar2
  ,p_pdt_attribute26_o            in varchar2
  ,p_pdt_attribute27_o            in varchar2
  ,p_pdt_attribute28_o            in varchar2
  ,p_pdt_attribute29_o            in varchar2
  ,p_pdt_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_pdt_rkd;

 

/
