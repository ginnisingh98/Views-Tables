--------------------------------------------------------
--  DDL for Package PER_GRS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GRS_RKU" AUTHID CURRENT_USER as
/* $Header: pegrsrhi.pkh 120.0 2005/05/31 09:34:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cagr_grade_structure_id        in number
 ,p_collective_agreement_id        in number
 ,p_object_version_number          in number
 ,p_id_flex_num                    in number
 ,p_dynamic_insert_allowed         in varchar2
 ,p_attribute_category             in varchar2
 ,p_attribute1                     in varchar2
 ,p_attribute2                     in varchar2
 ,p_attribute3                     in varchar2
 ,p_attribute4                     in varchar2
 ,p_attribute5                     in varchar2
 ,p_attribute6                     in varchar2
 ,p_attribute7                     in varchar2
 ,p_attribute8                     in varchar2
 ,p_attribute9                     in varchar2
 ,p_attribute10                    in varchar2
 ,p_attribute11                    in varchar2
 ,p_attribute12                    in varchar2
 ,p_attribute13                    in varchar2
 ,p_attribute14                    in varchar2
 ,p_attribute15                    in varchar2
 ,p_attribute16                    in varchar2
 ,p_attribute17                    in varchar2
 ,p_attribute18                    in varchar2
 ,p_attribute19                    in varchar2
 ,p_attribute20                    in varchar2
 ,p_collective_agreement_id_o      in number
 ,p_object_version_number_o        in number
 ,p_id_flex_num_o                  in number
 ,p_dynamic_insert_allowed_o       in varchar2
 ,p_attribute_category_o           in varchar2
 ,p_attribute1_o                   in varchar2
 ,p_attribute2_o                   in varchar2
 ,p_attribute3_o                   in varchar2
 ,p_attribute4_o                   in varchar2
 ,p_attribute5_o                   in varchar2
 ,p_attribute6_o                   in varchar2
 ,p_attribute7_o                   in varchar2
 ,p_attribute8_o                   in varchar2
 ,p_attribute9_o                   in varchar2
 ,p_attribute10_o                  in varchar2
 ,p_attribute11_o                  in varchar2
 ,p_attribute12_o                  in varchar2
 ,p_attribute13_o                  in varchar2
 ,p_attribute14_o                  in varchar2
 ,p_attribute15_o                  in varchar2
 ,p_attribute16_o                  in varchar2
 ,p_attribute17_o                  in varchar2
 ,p_attribute18_o                  in varchar2
 ,p_attribute19_o                  in varchar2
 ,p_attribute20_o                  in varchar2
 ,p_effective_date   		   in date
  );
--
end per_grs_rku;

 

/
