--------------------------------------------------------
--  DDL for Package IBY_ROUTINGINFO_PKG_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ROUTINGINFO_PKG_WRAP" AUTHID CURRENT_USER as
/*$Header: ibyrutws.pls 115.10 2002/11/21 20:14:48 jleybovi ship $*/

  procedure createroutinginfo(i_rules_ruleid  NUMBER,
    i_rules_rulename  VARCHAR2,
    i_rules_bepinstrtype  VARCHAR2,
    i_rules_priority  NUMBER,
    i_rules_bepid  NUMBER,
    i_rules_bepsuffix  VARCHAR2,
    i_rules_activestatus  NUMBER,
    i_rules_payeeid  VARCHAR2,
    i_rules_merchantaccount VARCHAR2,
    i_rules_hitcounter NUMBER,
    i_rules_object_version  NUMBER,
    i_conditions_rulename JTF_VARCHAR2_TABLE_100,
    i_conditions_ruleid JTF_NUMBER_TABLE,
    i_conditions_condition_name JTF_VARCHAR2_TABLE_100,
    i_conditions_parameter JTF_VARCHAR2_TABLE_100,
    i_conditions_operation JTF_VARCHAR2_TABLE_100,
    i_conditions_value JTF_VARCHAR2_TABLE_100,
    i_conditions_is_value_string JTF_VARCHAR2_TABLE_100,
    i_conditions_entry_seq JTF_NUMBER_TABLE,
    i_conditions_object_version JTF_NUMBER_TABLE);

  procedure modifyroutinginfo(i_rules_ruleid  NUMBER,
    i_rules_rulename  VARCHAR2,
    i_rules_bepinstrtype  VARCHAR2,
    i_rules_priority  NUMBER,
    i_rules_bepid  NUMBER,
    i_rules_bepsuffix  VARCHAR2,
    i_rules_activestatus  NUMBER,
    i_rules_payeeid  VARCHAR2,
    i_rules_merchantaccount VARCHAR2,
    i_rules_hitcounter NUMBER,
    i_rules_object_version  NUMBER,
    i_conditions_rulename JTF_VARCHAR2_TABLE_100,
    i_conditions_ruleid JTF_NUMBER_TABLE,
    i_conditions_condition_name JTF_VARCHAR2_TABLE_100,
    i_conditions_parameter JTF_VARCHAR2_TABLE_100,
    i_conditions_operation JTF_VARCHAR2_TABLE_100,
    i_conditions_value JTF_VARCHAR2_TABLE_100,
    i_conditions_is_value_string JTF_VARCHAR2_TABLE_100,
    i_conditions_entry_seq JTF_NUMBER_TABLE,
    i_conditions_object_version JTF_NUMBER_TABLE);
end iby_routinginfo_pkg_wrap;

 

/
