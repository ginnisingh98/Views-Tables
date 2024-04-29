--------------------------------------------------------
--  DDL for Package PER_NZ_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NZ_DATA_PUMP" AUTHID CURRENT_USER as
/* $Header: hrnzdpmf.pkh 120.2 2005/12/22 03:54:33 abhjain noship $
   Name        Date         Version      Bug               Text
------------------------------------------------------------------
  apunekar    01-MAY-2001     115.0     1620642     MappingFunctionCreated
  abhjain     22-dec-2005     115.1     4901666     Added function get_run_type_id
  abhjain     22-dec-2005     115.2     4901666     Added dbdrv for gscc compliance

*/
------------------------------ get_legal_employer__id ---------------------------


------------------------------ get_registered_employer__id ---------------------------

function get_registered_employer_id
(p_employer_ird_number         in varchar2,
 p_business_group_id           in number)
 return varchar2;
pragma restrict_references (get_registered_employer_id, WNDS);

FUNCTION get_run_type_id
 RETURN NUMBER;
pragma restrict_references (get_run_type_id, WNDS);


------------------------------------------------------------------------------------
end per_nz_data_pump ;

 

/
