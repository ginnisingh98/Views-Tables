--------------------------------------------------------
--  DDL for Package PER_BPD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPD_RKD" AUTHID CURRENT_USER as
/* $Header: pebpdrhi.pkh 120.0 2005/05/31 06:19:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_payment_detail_id            in number,
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
end per_bpd_rkd;

 

/
