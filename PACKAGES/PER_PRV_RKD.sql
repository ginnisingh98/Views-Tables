--------------------------------------------------------
--  DDL for Package PER_PRV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PRV_RKD" AUTHID CURRENT_USER as
/* $Header: peprvrhi.pkh 120.0 2005/05/31 15:13:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_performance_review_id          in number
 ,p_person_id_o                    in number
 ,p_event_id_o                     in number
 ,p_review_date_o                  in date
 ,p_performance_rating_o           in varchar2
 ,p_next_perf_review_date_o        in date
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
 ,p_object_version_number_o        in number
  );
--
end per_prv_rkd;

 

/
