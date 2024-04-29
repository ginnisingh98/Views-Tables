--------------------------------------------------------
--  DDL for Package PER_HU_CREATE_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_CREATE_EMPLOYEE" AUTHID CURRENT_USER as
/* $Header: pehuempp.pkh 120.0.12000000.1 2007/01/21 23:16:33 appldev ship $ */

PROCEDURE create_hu_employee (p_last_name           VARCHAR2
                              ,p_first_name          VARCHAR2
                              ,p_national_identifier VARCHAR2
                              ,p_per_information1    VARCHAR2
                              ,p_per_information2    VARCHAR2
                              );

END PER_HU_CREATE_EMPLOYEE;

 

/
