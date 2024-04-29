--------------------------------------------------------
--  DDL for Package PER_BBA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BBA_RKU" AUTHID CURRENT_USER as
/* $Header: pebbarhi.pkh 120.0 2005/05/31 06:02:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date   in  date,
  p_balance_amount_id            in number,
  p_ytd_amount                   in number,
  p_fytd_amount                  in number,
  p_ptd_amount                   in number,
  p_mtd_amount                   in number,
  p_qtd_amount                   in number,
  p_run_amount                   in number,
  p_object_version_number        in number,
  p_bba_attribute_category           in varchar2,
  p_bba_attribute1                   in varchar2,
  p_bba_attribute2                   in varchar2,
  p_bba_attribute3                   in varchar2,
  p_bba_attribute4                   in varchar2,
  p_bba_attribute5                   in varchar2,
  p_bba_attribute6                   in varchar2,
  p_bba_attribute7                   in varchar2,
  p_bba_attribute8                   in varchar2,
  p_bba_attribute9                   in varchar2,
  p_bba_attribute10                  in varchar2,
  p_bba_attribute11                  in varchar2,
  p_bba_attribute12                  in varchar2,
  p_bba_attribute13                  in varchar2,
  p_bba_attribute14                  in varchar2,
  p_bba_attribute15                  in varchar2,
  p_bba_attribute16                  in varchar2,
  p_bba_attribute17                  in varchar2,
  p_bba_attribute18                  in varchar2,
  p_bba_attribute19                  in varchar2,
  p_bba_attribute20                  in varchar2,
  p_bba_attribute21                  in varchar2,
  p_bba_attribute22                  in varchar2,
  p_bba_attribute23                  in varchar2,
  p_bba_attribute24                  in varchar2,
  p_bba_attribute25                  in varchar2,
  p_bba_attribute26                  in varchar2,
  p_bba_attribute27                  in varchar2,
  p_bba_attribute28                  in varchar2,
  p_bba_attribute29                  in varchar2,
  p_bba_attribute30                  in varchar2,
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
end per_bba_rku;

 

/
