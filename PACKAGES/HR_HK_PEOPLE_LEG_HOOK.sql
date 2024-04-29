--------------------------------------------------------
--  DDL for Package HR_HK_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HK_PEOPLE_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: hrhklhpp.pkh 120.0.12000000.1 2007/01/21 16:34:52 appldev ship $ */

  CURSOR csr_val_person_type (p_person_type_id 	NUMBER)
  IS
  SELECT system_person_type
  FROM   per_person_types
  WHERE  person_type_id = p_person_type_id;

  PROCEDURE check_hkid_passport(         p_person_type_id           NUMBER
                                        ,p_national_identifier      VARCHAR2
                                        ,p_per_information1         VARCHAR2
                                        ,p_per_information2         VARCHAR2
                                        ,p_per_information3         VARCHAR2
                                        ,p_per_information4         VARCHAR2);

  /* Bug 2737948 */
  PROCEDURE check_hongkong_name(         p_person_type_id           NUMBER
                                        ,p_per_information6         VARCHAR2);

END hr_hk_people_leg_hook;

 

/
