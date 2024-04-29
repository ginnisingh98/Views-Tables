--------------------------------------------------------
--  DDL for Package PER_CHK_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CHK_RKD" AUTHID CURRENT_USER as
/* $Header: pechkrhi.pkh 120.0 2005/05/31 06:41:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_checklist_item_id              in number
 ,p_person_id_o                    in number
 ,p_item_code_o                    in varchar2
 ,p_date_due_o                     in date
 ,p_date_done_o                    in date
 ,p_status_o                       in varchar2
 ,p_notes_o                        in varchar2
 ,p_object_version_number_o        in number
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
 ,p_attribute21_o                  in varchar2
 ,p_attribute22_o                  in varchar2
 ,p_attribute23_o                  in varchar2
 ,p_attribute24_o                  in varchar2
 ,p_attribute25_o                  in varchar2
 ,p_attribute26_o                  in varchar2
 ,p_attribute27_o                  in varchar2
 ,p_attribute28_o                  in varchar2
 ,p_attribute29_o                  in varchar2
 ,p_attribute30_o                  in varchar2
  );
--
end per_chk_rkd;

 

/