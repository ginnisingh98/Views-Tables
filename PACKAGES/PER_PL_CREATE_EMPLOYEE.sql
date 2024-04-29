--------------------------------------------------------
--  DDL for Package PER_PL_CREATE_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_CREATE_EMPLOYEE" AUTHID CURRENT_USER as
/* $Header: peplempp.pkh 120.2.12000000.1 2007/01/22 01:39:38 appldev noship $ */

PROCEDURE CREATE_PL_EMPLOYEE(p_last_name   VARCHAR2
                            ,p_first_name  VARCHAR2
                            ,p_date_of_birth DATE
                            ,p_marital_status VARCHAR2
                            ,p_nationality  VARCHAR2
                            ,p_national_identifier VARCHAR2
                            ,p_business_group_id NUMBER
                            ,p_sex VARCHAR2
                            ,p_per_information1 VARCHAR2
                            ,p_per_information2 VARCHAR2
                            ,p_per_information3 VARCHAR2
                            ,p_per_information4 VARCHAR2
                            ,p_per_information5 VARCHAR2
                            ,p_per_information6 VARCHAR2
                            ,p_per_information7 VARCHAR2
                            ,p_per_information8 VARCHAR2);

END PER_PL_CREATE_EMPLOYEE;

 

/
