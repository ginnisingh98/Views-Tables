--------------------------------------------------------
--  DDL for Package PER_HU_UPDATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_UPDATE_PERSON" AUTHID CURRENT_USER as
/* $Header: pehuperp.pkh 120.0.12000000.1 2007/01/21 23:19:29 appldev ship $ */

PROCEDURE update_hu_person (p_person_id           NUMBER
                           ,p_last_name           VARCHAR2
                           ,p_first_name          VARCHAR2
                           ,p_national_identifier VARCHAR2
                           ,p_per_information1    VARCHAR2
                           ,p_per_information2    VARCHAR2
                           ,p_effective_date      DATE
                           );
END PER_HU_UPDATE_PERSON;

 

/
