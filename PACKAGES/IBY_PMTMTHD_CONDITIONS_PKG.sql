--------------------------------------------------------
--  DDL for Package IBY_PMTMTHD_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PMTMTHD_CONDITIONS_PKG" AUTHID CURRENT_USER as
/*$Header: ibyconds.pls 115.6 2002/10/04 20:46:16 jleybovi ship $*/

/*--------------------------------------------------------------+
|  Function: createCondition.                                   |
|  Purpose:  To create a rule condition in the database.        |
+--------------------------------------------------------------*/

procedure createCondition(
               i_paymentmethodid in iby_pmtmthd_conditions.paymentmethodid%type,
               i_parameter_code in iby_pmtmthd_conditions.parameter_code%type,
               i_operation_code in iby_pmtmthd_conditions.operation_code%type,
               i_value in iby_pmtmthd_conditions.value%type,
               i_is_value_string in iby_pmtmthd_conditions.is_value_string%type,
               i_entry_sequence in iby_pmtmthd_conditions.entry_sequence%type,
               i_condition_name in iby_pmtmthd_conditions.condition_name%type);

/*
** Function: modifyCondition.
** Purpose:  modifies rule condition information in the database.
*/
procedure modifyCondition (
               i_paymentmethodid in iby_pmtmthd_conditions.paymentmethodid%type,
               i_parameter_code in iby_pmtmthd_conditions.parameter_code%type,
               i_operation_code in iby_pmtmthd_conditions.operation_code%type,
               i_value in iby_pmtmthd_conditions.value%type,
               i_is_value_string in iby_pmtmthd_conditions.is_value_string%type,
               i_entry_sequence in iby_pmtmthd_conditions.entry_sequence%type,
               i_version in iby_pmtmthd_conditions.object_version_number%type,
               i_condition_name in iby_pmtmthd_conditions.condition_name%type);

/*
** Function: deleteCondition.
** Purpose:  deletes rule condition in the database.
*/
procedure deleteCondition (
               i_paymentmethodid in iby_pmtmthd_conditions.paymentmethodid%type,
               i_parameter_code in iby_pmtmthd_conditions.parameter_code%type,
               i_operation_code in iby_pmtmthd_conditions.operation_code%type,
               i_value in iby_pmtmthd_conditions.value%type,
               i_is_value_string in iby_pmtmthd_conditions.is_value_string%type,
               i_entry_sequence in iby_pmtmthd_conditions.entry_sequence%type,
               i_version in iby_pmtmthd_conditions.object_version_number%type);

/*
** Function: checkDuplicateCondName.
** Purpose: Checks whether the condition name is unique for this rule. Returns
**          true if the name is unique, false otherwise.
*/
function checkDuplicateCondName(
               i_condition_name in iby_pmtmthd_conditions.condition_name%type,
               i_paymentmethodid in iby_pmtmthd_conditions.paymentmethodid%type
               ) RETURN BOOLEAN;

end iby_pmtmthd_conditions_pkg;

 

/
