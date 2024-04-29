--------------------------------------------------------
--  DDL for Package HR_SG_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SG_PEOPLE_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: hrsglhpp.pkh 120.0 2005/05/31 02:41:55 appldev noship $ */

  CURSOR  csr_val_person_type (p_person_type_id NUMBER) IS
  SELECT  system_person_type
    FROM  per_person_types
   WHERE  person_type_id = p_person_type_id;

  procedure check_sg_legal_name(        p_person_type_id      NUMBER
                                      , p_per_information1    VARCHAR2);

  procedure check_sg_income_tax(        p_person_type_id      NUMBER
                                      , p_national_identifier VARCHAR2
                                      , p_per_information12   VARCHAR2);

END hr_sg_people_leg_hook;

 

/
