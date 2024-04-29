--------------------------------------------------------
--  DDL for Package PER_PHN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PHN_RKD" AUTHID CURRENT_USER as
/* $Header: pephnrhi.pkh 120.0 2005/05/31 14:21:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_phone_id                       in number,
  p_date_from_o                    in date,
  p_date_to_o                      in date,
  p_phone_type_o                   in varchar2,
  p_phone_number_o                 in varchar2,
  p_parent_id_o                    in number  ,
  p_parent_table_o                 in varchar2,
  p_attribute_category_o           in varchar2,
  p_attribute1_o                   in varchar2,
  p_attribute2_o                   in varchar2,
  p_attribute3_o                   in varchar2,
  p_attribute4_o                   in varchar2,
  p_attribute5_o                   in varchar2,
  p_attribute6_o                   in varchar2,
  p_attribute7_o                   in varchar2 ,
  p_attribute8_o                   in varchar2,
  p_attribute9_o                   in varchar2,
  p_attribute10_o                  in varchar2,
  p_attribute11_o                  in varchar2,
  p_attribute12_o                  in varchar2,
  p_attribute13_o                  in varchar2,
  p_attribute14_o                  in varchar2,
  p_attribute15_o                  in varchar2,
  p_attribute16_o                  in varchar2,
  p_attribute17_o                  in varchar2,
  p_attribute18_o                  in varchar2,
  p_attribute19_o                  in varchar2,
  p_attribute20_o                  in varchar2,
  p_attribute21_o                  in varchar2,
  p_attribute22_o                  in varchar2,
  p_attribute23_o                  in varchar2,
  p_attribute24_o                  in varchar2,
  p_attribute25_o                  in varchar2,
  p_attribute26_o                  in varchar2,
  p_attribute27_o                  in varchar2,
  p_attribute28_o                  in varchar2,
  p_attribute29_o                  in varchar2,
  p_attribute30_o                  in varchar2,
  p_party_id_o                     in number,     -- HR/TCA merge
  p_validity_o                     in varchar2,
  p_object_version_number_o        in number
  );

end per_phn_rkd;

 

/
