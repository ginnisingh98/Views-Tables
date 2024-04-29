--------------------------------------------------------
--  DDL for Package PER_ES_CREATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_CREATE_PERSON" AUTHID CURRENT_USER as
/* $Header: peesconp.pkh 120.0.12000000.1 2007/01/21 22:24:44 appldev ship $ */
--         p_first_last_name                p_last_name
--         p_identifier_type           p_per_information2
--         p_identifier_value          p_per_information3

PROCEDURE create_es_person (p_last_name           VARCHAR2
                           ,p_first_name          VARCHAR2
                           ,p_national_identifier VARCHAR2
                           ,p_per_information1    VARCHAR2
                           ,p_per_information2    VARCHAR2
                           ,p_per_information3    VARCHAR2
                           );
--
END PER_ES_CREATE_PERSON;

 

/
