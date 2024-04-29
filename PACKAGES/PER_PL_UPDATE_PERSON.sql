--------------------------------------------------------
--  DDL for Package PER_PL_UPDATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_UPDATE_PERSON" AUTHID CURRENT_USER as
/* $Header: peplperp.pkh 120.2.12000000.1 2007/01/22 01:44:17 appldev noship $ */

PROCEDURE update_pl_person (p_person_type_id  number
                           ,p_last_name   VARCHAR2
                           ,p_first_name  VARCHAR2
                           ,p_date_of_birth DATE
                           ,p_marital_status VARCHAR2
                           ,p_nationality  VARCHAR2
                           ,p_national_identifier VARCHAR2
                           ,p_per_information1 VARCHAR2
                           ,p_person_id number
                           ,p_effective_date date
                           ,p_per_information2 VARCHAR2
                           ,p_per_information3 VARCHAR2
                           ,p_per_information4 VARCHAR2
                           ,p_per_information5 VARCHAR2
                           ,p_per_information6 VARCHAR2
                           ,p_per_information7 VARCHAR2
                           ,p_per_information8 VARCHAR2);

END PER_PL_UPDATE_PERSON;

 

/
