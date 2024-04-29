--------------------------------------------------------
--  DDL for Package HR_RU_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_PEOPLE_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peruvald.pkh 120.0.12000000.1 2007/01/22 03:59:16 appldev noship $ */
   PROCEDURE validate_person (
      p_first_name          VARCHAR2
     ,p_effective_date      DATE
     ,p_per_information1    VARCHAR2
     ,p_per_information4    VARCHAR2
     ,p_per_information5    VARCHAR2
     ,p_per_information6    VARCHAR2
     ,p_per_information7    VARCHAR2
     ,p_per_information8    VARCHAR2
     ,p_per_information9    VARCHAR2
     ,p_per_information10   VARCHAR2
     ,p_per_information11   VARCHAR2
     ,p_per_information12   VARCHAR2
     ,p_per_information13   VARCHAR2
     ,p_per_information14   VARCHAR2
     ,p_per_information15   VARCHAR2
     ,p_per_information18   VARCHAR2

   );

   PROCEDURE create_ru_employee (
      p_first_name          VARCHAR2
     ,p_hire_date      DATE
     ,p_date_of_birth       DATE
     ,p_sex                 VARCHAR2
     ,p_per_information1    VARCHAR2
     ,p_per_information4    VARCHAR2
     ,p_per_information5    VARCHAR2
     ,p_per_information6    VARCHAR2
     ,p_per_information7    VARCHAR2
     ,p_per_information8    VARCHAR2
     ,p_per_information9    VARCHAR2
     ,p_per_information10   VARCHAR2
     ,p_per_information11   VARCHAR2
     ,p_per_information12   VARCHAR2
     ,p_per_information13   VARCHAR2
     ,p_per_information14   VARCHAR2
     ,p_per_information15   VARCHAR2
     ,p_per_information18   VARCHAR2

   );

   PROCEDURE create_ru_applicant (
      p_first_name          VARCHAR2
     ,p_date_received       DATE
     ,p_per_information1    VARCHAR2
     ,p_per_information4    VARCHAR2
     ,p_per_information5    VARCHAR2
     ,p_per_information6    VARCHAR2
     ,p_per_information7    VARCHAR2
     ,p_per_information8    VARCHAR2
     ,p_per_information9    VARCHAR2
     ,p_per_information10   VARCHAR2
     ,p_per_information11   VARCHAR2
     ,p_per_information12   VARCHAR2
     ,p_per_information13   VARCHAR2
     ,p_per_information14   VARCHAR2
     ,p_per_information15   VARCHAR2
     ,p_per_information18   VARCHAR2
   );

   PROCEDURE create_ru_contact (
      p_first_name          VARCHAR2
     ,p_start_date          DATE
     ,p_per_information1    VARCHAR2
     ,p_per_information4    VARCHAR2
     ,p_per_information5    VARCHAR2
     ,p_per_information6    VARCHAR2
     ,p_per_information7    VARCHAR2
     ,p_per_information8    VARCHAR2
     ,p_per_information9    VARCHAR2
     ,p_per_information10   VARCHAR2
     ,p_per_information11   VARCHAR2
     ,p_per_information12   VARCHAR2
     ,p_per_information13   VARCHAR2
     ,p_per_information14   VARCHAR2
     ,p_per_information15   VARCHAR2
     ,p_per_information18   VARCHAR2
   );

   PROCEDURE create_ru_cwk (
      p_first_name          VARCHAR2
     ,p_start_date          DATE
     ,p_per_information1    VARCHAR2
     ,p_per_information4    VARCHAR2
     ,p_per_information5    VARCHAR2
     ,p_per_information6    VARCHAR2
     ,p_per_information7    VARCHAR2
     ,p_per_information8    VARCHAR2
     ,p_per_information9    VARCHAR2
     ,p_per_information10   VARCHAR2
     ,p_per_information11   VARCHAR2
     ,p_per_information12   VARCHAR2
     ,p_per_information13   VARCHAR2
     ,p_per_information14   VARCHAR2
     ,p_per_information15   VARCHAR2
     ,p_per_information18   VARCHAR2
   );

   PROCEDURE update_ru_person (
      p_person_id           NUMBER
     ,p_first_name          VARCHAR2
     ,p_person_type_id      NUMBER
     ,p_effective_date      DATE
     ,p_date_of_birth       DATE
     ,p_sex                 VARCHAR2
     ,p_per_information1    VARCHAR2
     ,p_per_information4    VARCHAR2
     ,p_per_information5    VARCHAR2
     ,p_per_information6    VARCHAR2
     ,p_per_information7    VARCHAR2
     ,p_per_information8    VARCHAR2
     ,p_per_information9    VARCHAR2
     ,p_per_information10   VARCHAR2
     ,p_per_information11   VARCHAR2
     ,p_per_information12   VARCHAR2
     ,p_per_information13   VARCHAR2
     ,p_per_information14   VARCHAR2
     ,p_per_information15   VARCHAR2
     ,p_per_information18   VARCHAR2
   );

   CURSOR csr_val_person_type (p_person_type_id 	NUMBER)
     IS
     SELECT system_person_type,seeded_person_type_key
       FROM per_person_types
      WHERE person_type_id = p_person_type_id;





END hr_ru_people_leg_hook;

 

/
