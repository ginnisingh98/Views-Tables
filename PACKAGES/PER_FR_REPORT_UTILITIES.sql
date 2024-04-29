--------------------------------------------------------
--  DDL for Package PER_FR_REPORT_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_REPORT_UTILITIES" AUTHID CURRENT_USER as
/* $Header: pefrutil.pkh 120.1 2005/10/03 02:33 sbairagi noship $ */
function get_job_names (p_job_id in number
                       , p_job_definition_id in number
		       , p_report_name in varchar2 default null)
		       return varchar2;
end per_fr_report_utilities;

 

/
