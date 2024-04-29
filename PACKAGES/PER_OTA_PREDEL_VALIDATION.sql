--------------------------------------------------------
--  DDL for Package PER_OTA_PREDEL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OTA_PREDEL_VALIDATION" AUTHID CURRENT_USER as
/* $Header: peperota.pkh 115.2 2002/12/07 00:07:26 dhmulia ship $ */
--
PROCEDURE ota_predel_job_validation(p_job_id    in  number);
--
PROCEDURE ota_predel_pos_validation(p_position_id in number) ;
--
PROCEDURE ota_predel_org_validation(p_organization_id in number);
--
PROCEDURE ota_predel_per_validation(p_person_id in number);
--
PROCEDURE ota_predel_asg_validation(p_assignment_id in number);
--
END PER_OTA_PREDEL_VALIDATION;

 

/
