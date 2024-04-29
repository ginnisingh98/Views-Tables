--------------------------------------------------------
--  DDL for Package PER_FR_WORK_CERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_WORK_CERT" AUTHID CURRENT_USER AS
/* $Header: pefrwkct.pkh 115.0 2003/05/15 14:32:28 sfmorris noship $ */

FUNCTION get_job_details(p_person_id NUMBER
                        ,p_period_of_service_id NUMBER) RETURN VARCHAR2;

END per_fr_work_cert;

 

/
