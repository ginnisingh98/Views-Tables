--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BK3" AUTHID CURRENT_USER as
/* $Header: pecelapi.pkh 120.2 2006/02/13 14:05:47 vbala noship $ */
--
--
-- update_personal_comp_element_b
--
Procedure update_personal_comp_element_b	(
  p_competence_element_id        in number    ,
  p_object_version_number        in number    ,
  p_proficiency_level_id         in number    ,
  p_effective_date_from          in date      ,
  p_effective_date_to            in date      ,
  p_source_of_proficiency_level  in varchar2  ,
  p_certification_date           in date      ,
  p_certification_method         in varchar2  ,
  p_next_certification_date      in date      ,
  p_comments                     in varchar2  ,
  p_attribute_category           in varchar2  ,
  p_attribute1                   in varchar2  ,
  p_attribute2                   in varchar2  ,
  p_attribute3                   in varchar2  ,
  p_attribute4                   in varchar2  ,
  p_attribute5                   in varchar2  ,
  p_attribute6                   in varchar2  ,
  p_attribute7                   in varchar2  ,
  p_attribute8                   in varchar2  ,
  p_attribute9                   in varchar2  ,
  p_attribute10                  in varchar2  ,
  p_attribute11                  in varchar2  ,
  p_attribute12                  in varchar2  ,
  p_attribute13                  in varchar2  ,
  p_attribute14                  in varchar2  ,
  p_attribute15                  in varchar2  ,
  p_attribute16                  in varchar2  ,
  p_attribute17                  in varchar2  ,
  p_attribute18                  in varchar2  ,
  p_attribute19                  in varchar2  ,
  p_attribute20                  in varchar2  ,
  p_effective_date               in Date      );
--
-- update_personal_comp_element_a
--
Procedure update_personal_comp_element_a	(
  p_competence_element_id        in number    ,
  p_object_version_number        in number    ,
  p_proficiency_level_id         in number    ,
  p_effective_date_from          in date      ,
  p_effective_date_to            in date      ,
  p_source_of_proficiency_level  in varchar2  ,
  p_certification_date           in date      ,
  p_certification_method         in varchar2  ,
  p_next_certification_date      in date      ,
  p_comments                     in varchar2  ,
  p_attribute_category           in varchar2  ,
  p_attribute1                   in varchar2  ,
  p_attribute2                   in varchar2  ,
  p_attribute3                   in varchar2  ,
  p_attribute4                   in varchar2  ,
  p_attribute5                   in varchar2  ,
  p_attribute6                   in varchar2  ,
  p_attribute7                   in varchar2  ,
  p_attribute8                   in varchar2  ,
  p_attribute9                   in varchar2  ,
  p_attribute10                  in varchar2  ,
  p_attribute11                  in varchar2  ,
  p_attribute12                  in varchar2  ,
  p_attribute13                  in varchar2  ,
  p_attribute14                  in varchar2  ,
  p_attribute15                  in varchar2  ,
  p_attribute16                  in varchar2  ,
  p_attribute17                  in varchar2  ,
  p_attribute18                  in varchar2  ,
  p_attribute19                  in varchar2  ,
  p_attribute20                  in varchar2  ,
  p_effective_date               in Date      ,
  p_ins_ovn                      in number    ,
  p_ins_comp_id                  in number    );

end hr_competence_element_bk3;

 

/
