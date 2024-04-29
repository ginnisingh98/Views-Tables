--------------------------------------------------------
--  DDL for Package PER_BPD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPD_RKU" AUTHID CURRENT_USER as
/* $Header: pebpdrhi.pkh 120.0 2005/05/31 06:19:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date   in  date,
  p_payment_detail_id            in number,
  p_check_number                 in number,
  p_payment_date                   in date,
  p_amount                       in number,
  p_check_type                   in varchar2,
  p_object_version_number        in number,
  p_bpd_attribute_category         in varchar2,
  p_bpd_attribute1                in varchar2,
  p_bpd_attribute2                in varchar2,
  p_bpd_attribute3                in varchar2,
  p_bpd_attribute4                in varchar2,
  p_bpd_attribute5                in varchar2,
  p_bpd_attribute6                in varchar2,
  p_bpd_attribute7                in varchar2,
  p_bpd_attribute8                in varchar2,
  p_bpd_attribute9                in varchar2,
  p_bpd_attribute10               in varchar2,
  p_bpd_attribute11               in varchar2,
  p_bpd_attribute12               in varchar2,
  p_bpd_attribute13               in varchar2,
  p_bpd_attribute14               in varchar2,
  p_bpd_attribute15               in varchar2,
  p_bpd_attribute16               in varchar2,
  p_bpd_attribute17               in varchar2,
  p_bpd_attribute18               in varchar2,
  p_bpd_attribute19               in varchar2,
  p_bpd_attribute20               in varchar2,
  p_bpd_attribute21               in varchar2,
  p_bpd_attribute22               in varchar2,
  p_bpd_attribute23               in varchar2,
  p_bpd_attribute24               in varchar2,
  p_bpd_attribute25               in varchar2,
  p_bpd_attribute26               in varchar2,
  p_bpd_attribute27               in varchar2,
  p_bpd_attribute28               in varchar2,
  p_bpd_attribute29               in varchar2,
  p_bpd_attribute30               in varchar2,
  p_processed_assignment_id_o    in number,
  p_personal_payment_method_id_o in number,
  p_business_group_id_o          in number,
  p_check_number_o               in number,
  p_payment_date_o                 in date,
  p_amount_o                     in number,
  p_check_type_o                 in varchar2,
  p_object_version_number_o      in number,
  p_bpd_attribute_category_o         in varchar2,
  p_bpd_attribute1_o                in varchar2,
  p_bpd_attribute2_o                in varchar2,
  p_bpd_attribute3_o                in varchar2,
  p_bpd_attribute4_o                in varchar2,
  p_bpd_attribute5_o                in varchar2,
  p_bpd_attribute6_o                in varchar2,
  p_bpd_attribute7_o                in varchar2,
  p_bpd_attribute8_o                in varchar2,
  p_bpd_attribute9_o                in varchar2,
  p_bpd_attribute10_o               in varchar2,
  p_bpd_attribute11_o               in varchar2,
  p_bpd_attribute12_o               in varchar2,
  p_bpd_attribute13_o               in varchar2,
  p_bpd_attribute14_o               in varchar2,
  p_bpd_attribute15_o               in varchar2,
  p_bpd_attribute16_o               in varchar2,
  p_bpd_attribute17_o               in varchar2,
  p_bpd_attribute18_o               in varchar2,
  p_bpd_attribute19_o               in varchar2,
  p_bpd_attribute20_o               in varchar2,
  p_bpd_attribute21_o               in varchar2,
  p_bpd_attribute22_o               in varchar2,
  p_bpd_attribute23_o               in varchar2,
  p_bpd_attribute24_o               in varchar2,
  p_bpd_attribute25_o               in varchar2,
  p_bpd_attribute26_o               in varchar2,
  p_bpd_attribute27_o               in varchar2,
  p_bpd_attribute28_o               in varchar2,
  p_bpd_attribute29_o               in varchar2,
  p_bpd_attribute30_o               in varchar2

  );
--
end per_bpd_rku;

 

/
