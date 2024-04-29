--------------------------------------------------------
--  DDL for Package PER_AU_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_AU_DATA_PUMP" AUTHID CURRENT_USER as
/* $Header: hraudpmf.pkh 120.0 2005/05/30 22:54:46 appldev noship $
   Name        Date         Version      Bug               Text
------------------------------------------------------------------
  apunekar    01-MAY-2001     115.0     1620646  Mapping functionCreated

*/

function get_legal_employer_id
(p_legal_employer_name         in varchar2,
 p_business_group_id           in number)
 return varchar2;
pragma restrict_references (get_legal_employer_id, WNDS);

------------------------------------------------------------------------------------
end per_au_data_pump ;

 

/
