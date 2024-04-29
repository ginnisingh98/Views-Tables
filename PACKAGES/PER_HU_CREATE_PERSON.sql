--------------------------------------------------------
--  DDL for Package PER_HU_CREATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_CREATE_PERSON" AUTHID CURRENT_USER as
/* $Header: pehuconp.pkh 120.0.12000000.1 2007/01/21 23:14:38 appldev ship $ */

PROCEDURE create_hu_person  (p_last_name           VARCHAR2
                            ,p_first_name          VARCHAR2
                            ,p_per_information1    VARCHAR2
                            ,p_per_information2    VARCHAR2
                            );
END PER_HU_CREATE_PERSON ;

 

/
