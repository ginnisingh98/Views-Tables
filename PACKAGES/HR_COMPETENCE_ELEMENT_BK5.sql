--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BK5" AUTHID CURRENT_USER as
/* $Header: pecelapi.pkh 120.2 2006/02/13 14:05:47 vbala noship $ */
--
--
-- maintain_student_comp_element_b
--
Procedure maintain_student_comp_elemen_b	(
    p_person_id                          in number
   ,p_competence_id                      in number
   ,p_proficiency_level_id               in number
   ,p_business_group_id                  in number
   ,p_effective_date_from                in date
   ,p_effective_date_to                  in date
   ,p_certification_date                 in date
   ,p_certification_method               in varchar2
   ,p_next_certification_date            in date
   ,p_source_of_proficiency_level        in varchar2
   ,p_comments                           in varchar2
   ,p_effective_date                     in date );
--
-- maintain_student_comp_element_a
--
Procedure maintain_student_comp_elemen_a	(
    p_person_id                          in number
   ,p_competence_id                      in number
   ,p_proficiency_level_id               in number
   ,p_business_group_id                  in number
   ,p_effective_date_from                in date
   ,p_effective_date_to                  in date
   ,p_certification_date                 in date
   ,p_certification_method               in varchar2
   ,p_next_certification_date            in date
   ,p_source_of_proficiency_level        in varchar2
   ,p_comments                           in varchar2
   ,p_effective_date                     in date
   ,p_competence_created                 in number);

end hr_competence_element_bk5;

 

/
