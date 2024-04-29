--------------------------------------------------------
--  DDL for Package PER_BBA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BBA_RKD" AUTHID CURRENT_USER as
/* $Header: pebbarhi.pkh 120.0 2005/05/31 06:02:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_balance_amount_id            in number,
  p_balance_type_id_o            in number,
  p_processed_assignment_id_o    in number,
  p_business_group_id_o          in number,
  p_ytd_amount_o                 in number,
  p_fytd_amount_o                in number,
  p_ptd_amount_o                 in number,
  p_mtd_amount_o                 in number,
  p_qtd_amount_o                 in number,
  p_run_amount_o                 in number,
  p_object_version_number_o      in number,
  p_bba_attribute_category_o         in varchar2,
  p_bba_attribute1_o                 in varchar2,
  p_bba_attribute2_o                 in varchar2,
  p_bba_attribute3_o                 in varchar2,
  p_bba_attribute4_o                 in varchar2,
  p_bba_attribute5_o                 in varchar2,
  p_bba_attribute6_o                 in varchar2,
  p_bba_attribute7_o                 in varchar2,
  p_bba_attribute8_o                 in varchar2,
  p_bba_attribute9_o                 in varchar2,
  p_bba_attribute10_o                in varchar2,
  p_bba_attribute11_o                in varchar2,
  p_bba_attribute12_o                in varchar2,
  p_bba_attribute13_o                in varchar2,
  p_bba_attribute14_o                in varchar2,
  p_bba_attribute15_o                in varchar2,
  p_bba_attribute16_o                in varchar2,
  p_bba_attribute17_o                in varchar2,
  p_bba_attribute18_o                in varchar2,
  p_bba_attribute19_o                in varchar2,
  p_bba_attribute20_o                in varchar2,
  p_bba_attribute21_o                in varchar2,
  p_bba_attribute22_o                in varchar2,
  p_bba_attribute23_o                in varchar2,
  p_bba_attribute24_o                in varchar2,
  p_bba_attribute25_o                in varchar2,
  p_bba_attribute26_o                in varchar2,
  p_bba_attribute27_o                in varchar2,
  p_bba_attribute28_o                in varchar2,
  p_bba_attribute29_o                in varchar2,
  p_bba_attribute30_o                in varchar2
  );
--
end per_bba_rkd;

 

/
