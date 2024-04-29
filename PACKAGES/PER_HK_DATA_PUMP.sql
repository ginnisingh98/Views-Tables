--------------------------------------------------------
--  DDL for Package PER_HK_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HK_DATA_PUMP" AUTHID CURRENT_USER as
/* $Header: hrhkdpmf.pkh 120.0 2005/05/31 00:42:50 appldev noship $
   Name        Date         Version      Bug               Text
------------------------------------------------------------------
  apunekar    29-MAY-2001     115.0     1620654  Mapping function Created
*/

function get_legal_employer_id
(p_legal_employer_name         in varchar2,
 p_business_group_id           in number)
 return varchar2;
pragma restrict_references (get_legal_employer_id, WNDS);


------------------------------------------------------------------------------------
end per_hk_data_pump ;

 

/
