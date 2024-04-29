--------------------------------------------------------
--  DDL for Package PER_SG_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SG_DATA_PUMP" AUTHID CURRENT_USER as
/* $Header: hrsgdpmf.pkh 120.0 2005/05/31 02:41:22 appldev noship $
   Name        Date         Version      Bug               Text
------------------------------------------------------------------
  apunekar    01-MAY-2001     115.0     1554453         Created

*/
------------------------------ get_legal_employer__id ---------------------------


/*
NAME
   get_legal_employer_id
DESCRIPTION
   Returns Legal Employer  ID.
NOTES
   This function returns an legal_employer_id and is designed for use
   with the Data Pump.
*/

function get_legal_employer_id
(p_legal_employer_name         in varchar2,
 p_business_group_id           in number)
 return varchar2;
pragma restrict_references (get_legal_employer_id, WNDS);

------------------------------------------------------------------------------------
end per_sg_data_pump ;

 

/
