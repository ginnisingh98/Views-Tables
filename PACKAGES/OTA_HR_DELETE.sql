--------------------------------------------------------
--  DDL for Package OTA_HR_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_HR_DELETE" AUTHID CURRENT_USER as
/* $Header: otdhr01t.pkh 115.0 99/07/16 00:51:23 porting ship $ */
--
Procedure check_delete(p_person_id       number default null
                      ,p_organization_id number default null
                      ,p_job_id          number default null
                      ,p_position_id     number default null
                      ,p_address_id      number default null
                      ,p_analysis_criteria_id number default null
                      );
--
end ota_hr_delete;

 

/
