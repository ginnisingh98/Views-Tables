--------------------------------------------------------
--  DDL for Package PER_HU_CREATE_APPLICANT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_CREATE_APPLICANT" AUTHID CURRENT_USER as
/* $Header: pehuappp.pkh 120.0.12000000.1 2007/01/21 23:14:23 appldev ship $ */

PROCEDURE create_hu_applicant (p_last_name              varchar2
                              ,p_first_name             VARCHAR2
                              ,p_per_information1       VARCHAR2
                              ,p_per_information2       VARCHAR2
                               );

--
END PER_HU_CREATE_APPLICANT;

 

/
