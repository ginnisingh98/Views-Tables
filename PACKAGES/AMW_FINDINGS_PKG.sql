--------------------------------------------------------
--  DDL for Package AMW_FINDINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_FINDINGS_PKG" AUTHID CURRENT_USER as
/*$Header: amwfinds.pls 115.3 2004/06/03 18:37:57 smalde noship $*/


    function calculate_open_findings ( findings_category char,
                                       self_entity_name char, self_pk1_value number,
                                       parent1_entity_name char, parent1_pk1_value number,
                                       parent2_entity_name char, parent2_pk1_value number,
                                       parent3_entity_name char, parent3_pk1_value number,
                                       parent4_entity_name char, parent4_pk1_value number )
    return number;


    function is_create_enabled ( change_category char,
				 org_id number, myprocess_id number )
    return number;


end amw_findings_pkg;

 

/
