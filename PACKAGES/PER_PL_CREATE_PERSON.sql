--------------------------------------------------------
--  DDL for Package PER_PL_CREATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_CREATE_PERSON" AUTHID CURRENT_USER as
/* $Header: peplconp.pkh 120.1.12000000.1 2007/01/22 01:38:56 appldev noship $ */

PROCEDURE create_pl_person(p_last_name   VARCHAR2
                          ,p_first_name  VARCHAR2
                          ,p_date_of_birth DATE
                          ,p_marital_status VARCHAR2
                          ,p_nationality  VARCHAR2
                          ,p_national_identifier VARCHAR2
                          ,p_business_group_id NUMBER
                          ,p_sex VARCHAR2
                          ,p_person_type_id   NUMBER
                          ,p_per_information1 VARCHAR2
                          ,p_per_information2 VARCHAR2
                          ,p_per_information3 VARCHAR2
                          ,p_per_information4 VARCHAR2
                          ,p_per_information5 VARCHAR2
                          ,p_per_information6 VARCHAR2
                          ,p_per_information7 VARCHAR2
                          ,p_per_information8 VARCHAR2);
--
END PER_PL_CREATE_PERSON;

 

/
