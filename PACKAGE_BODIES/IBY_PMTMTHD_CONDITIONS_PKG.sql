--------------------------------------------------------
--  DDL for Package Body IBY_PMTMTHD_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PMTMTHD_CONDITIONS_PKG" as
/*$Header: ibycondb.pls 115.12 2002/10/04 20:47:05 jleybovi ship $*/

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
               i_condition_name in iby_pmtmthd_conditions.condition_name%type)
is
l_count int:=0;
CURSOR c_ruleCondt IS
  SELECT COUNT(*)
    FROM iby_pmtmthd_conditions  a
    WHERE
      i_entry_sequence=a.entry_sequence AND
      i_paymentmethodId = a.paymentmethodId ;
BEGIN

  IF c_ruleCondt%ISOPEN
  THEN
      CLOSE c_ruleCondt;
      OPEN c_ruleCondt;
  ELSE
      OPEN c_ruleCondt;
  END IF;

  FETCH c_ruleCondt INTO l_count;
  CLOSE c_ruleCondt;

  IF (checkDuplicateCondName(i_condition_name, i_paymentmethodid) = false)
  THEN
    raise_application_error(-20000, 'IBY_204589#', FALSE);
  END IF;

-- Check whether this condition is already being used
-- if not create a new row.

  IF (l_count = 0)
  THEN
    INSERT INTO iby_pmtmthd_conditions
      (paymentmethodid, parameter_code, operation_code, value, is_value_string,
       entry_sequence, last_update_date, last_updated_by, creation_date,
       created_by, last_update_login, condition_name, object_version_number)
    VALUES ( i_paymentmethodid, i_parameter_code, i_operation_code, i_value,
       i_is_value_string, i_entry_sequence, sysdate, fnd_global.user_id, sysdate, fnd_global.user_id,
       fnd_global.login_id, i_condition_name, 1);
  ELSE
	  raise_application_error(-20000, 'IBY_204554#', FALSE);
  END IF;

  COMMIT;

END;


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
               i_condition_name in iby_pmtmthd_conditions.condition_name%type)
is

CURSOR c_ruleCondt IS
  SELECT *
    FROM iby_pmtmthd_conditions  a
    WHERE i_version = a.object_version_number AND
      i_entry_sequence=a.entry_sequence AND
      i_paymentmethodId = a.paymentmethodId
    FOR UPDATE;
BEGIN

  IF c_ruleCondt%ISOPEN
  THEN
      CLOSE c_ruleCondt;
      OPEN c_ruleCondt;
  ELSE
      OPEN c_ruleCondt;
  END IF;

  IF c_ruleCondt%NOTFOUND
  THEN
    CLOSE c_ruleCondt;
	  raise_application_error(-20000, 'IBY_204555#', FALSE);
  END IF;

  CLOSE c_ruleCondt;

  IF (checkDuplicateCondName(i_condition_name, i_paymentmethodid) = false)
  THEN
    raise_application_error(-20000, 'IBY_204589#', FALSE);
  END IF;

  FOR v_ruleCondt  IN c_ruleCondt LOOP
  UPDATE iby_pmtmthd_conditions
    SET paymentmethodid = i_paymentmethodid, parameter_code = i_parameter_code,
      operation_code = i_operation_code, value=i_value,
      is_value_string = i_is_value_string, entry_sequence=i_entry_sequence,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      condition_name = i_condition_name,
      object_version_number = object_version_number+1
    WHERE CURRENT OF c_ruleCondt;

  END LOOP;

  IF c_ruleCondt%ISOPEN
  THEN
      CLOSE c_ruleCondt;
  END IF;

  COMMIT;

END;



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
               i_version in iby_pmtmthd_conditions.object_version_number%type)
is
-- Check whether this method name is already being used
CURSOR c_ruleCondt IS
  SELECT *
    FROM iby_pmtmthd_conditions  a
    WHERE i_version = a.object_version_number AND
      i_entry_sequence=a.entry_sequence AND
      i_paymentmethodId = a.paymentmethodId
    FOR UPDATE;
BEGIN
  IF c_ruleCondt%ISOPEN
  THEN
      CLOSE c_ruleCondt;
      OPEN c_ruleCondt;
  ELSE
      OPEN c_ruleCondt;
  END IF;

  IF c_ruleCondt%NOTFOUND
  THEN
    CLOSE c_ruleCondt;
	  raise_application_error(-20000, 'IBY_204556#', FALSE);
  END IF;

  CLOSE c_ruleCondt;

  FOR v_ruleCondt  IN c_ruleCondt LOOP
    DELETE FROM iby_pmtmthd_conditions
      WHERE CURRENT OF c_ruleCondt;
  END LOOP;

  IF c_ruleCondt%ISOPEN
  THEN
      CLOSE c_ruleCondt;
  END IF;

  COMMIT;

END;

/*
** Function: checkDuplicateCondName.
** Purpose: Checks whether the condition name is unique for this rule. Returns
**          true if the name is unique, false otherwise.
*/
function checkDuplicateCondName(
               i_condition_name in iby_pmtmthd_conditions.condition_name%type,
               i_paymentmethodid in iby_pmtmthd_conditions.paymentmethodid%type
               )
return boolean is

l_count int:=0;
BEGIN

  SELECT COUNT(*) into l_count
  FROM iby_pmtmthd_conditions  a
  WHERE UPPER(i_condition_name) = UPPER(a.condition_name)
  AND i_paymentmethodId = a.paymentmethodId ;

  IF (l_count = 0) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END checkDuplicateCondName;

end iby_pmtmthd_conditions_pkg;

/
