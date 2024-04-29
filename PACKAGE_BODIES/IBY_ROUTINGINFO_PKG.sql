--------------------------------------------------------
--  DDL for Package Body IBY_ROUTINGINFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ROUTINGINFO_PKG" as
/*$Header: ibyroutb.pls 115.24 2002/05/17 12:53:32 pkm ship    $*/

/*-------------------------------------------------------------------+
|  Function: createRoutingInfo.                                      |
|  Purpose:  To create a Routing information in the database.        |
+-------------------------------------------------------------------*/
procedure createRoutingInfo(i_rules in t_rulesRec,
                            i_conditions in t_condtRecVec)
is
l_count		int :=0;
l_cntBep	int :=0;
l_ruleId	iby_routinginfo.PAYMENTMETHODID%type;
CURSOR c_routingInfo IS
  SELECT count(1)
    FROM iby_routinginfo  a
    WHERE
      i_rules.ruleName=a.paymentmethodName ;
BEGIN

  IF c_routingInfo%ISOPEN
  THEN
      CLOSE c_routingInfo;
      OPEN c_routingInfo;
  ELSE
      OPEN c_routingInfo;
  END IF;

-- Check whether this method name is already being used
-- if not create a new row.
  FETCH c_routingInfo INTO l_count;
  CLOSE c_routingInfo;

  SELECT COUNT(*) into l_cntBep
    FROM iby_bepinfo
   WHERE BEPID = i_rules.bepId;
  IF ( l_cntBep = 0 ) THEN
       	raise_application_error(-20000, 'IBY_204558#', FALSE);
  END IF;

  IF (isDuplicateCondNames(i_conditions) = true) THEN
        raise_application_error(-20000, 'IBY_204589#', FALSE);
  END IF;

  IF ( l_count = 0 )
  THEN
    select IBY_PMTMETHOD_S.NextVal INTO l_ruleId from dual;
    INSERT INTO iby_routinginfo
      (payeeid, bepkey, bepid, paymentmethodid, paymentmethodName, instr_type,
       configured, priority, last_update_date, last_updated_by, creation_date,
       created_by, last_update_login, hitcounter, object_version_number)
    VALUES ( i_rules.payeeId, i_rules.merchantAccount, i_rules.bepId, l_ruleId,
       i_rules.ruleName, i_rules.bepInstrType, i_rules.activeStatus,
       i_rules.priority, sysdate, fnd_global.user_id, sysdate,
       fnd_global.user_id, fnd_global.login_id, i_rules.hitcounter, 1);

    FOR v_count in 1..i_conditions.COUNT LOOP
      INSERT INTO iby_pmtmthd_conditions
        (paymentmethodid, parameter_code, operation_code, value,
         is_value_string, entry_sequence, condition_name, last_update_date,
         last_updated_by, creation_date,  created_by, last_update_login,
         object_version_number)
      VALUES ( l_ruleId, i_conditions(v_count).parameter,
         i_conditions(v_count).operation, i_conditions(v_count).value,
         i_conditions(v_count).is_value_string,
         i_conditions(v_count).entry_seq,
         i_conditions(v_count).condition_name, sysdate, fnd_global.user_id,
         sysdate, fnd_global.user_id, fnd_global.login_id, 1);
    END LOOP;
  ELSE
       	raise_application_error(-20000, 'IBY_204559#', FALSE);
    	--raise_application_error(-20520,
      	--'Payment Method Name already in use. Use unique payment method name.',
      --FALSE);
  END IF;

  COMMIT;

END;


/*
** Function: modifyRoutingInfo.
** Purpose:  modifies the Routing information in the database.
*/
procedure modifyRoutingInfo(i_rules in t_rulesRec,
                            i_conditions in t_condtRecVec)
is
l_ruleId	iby_routinginfo.PAYMENTMETHODID%type;

CURSOR c_routingInfo IS
  SELECT *
    FROM iby_routinginfo  a
   WHERE i_rules.object_version = a.object_version_number AND
         i_rules.ruleName=a.paymentmethodName AND
         i_rules.ruleId = a.paymentmethodId
    FOR UPDATE ;
BEGIN

  IF c_routingInfo%ISOPEN
  THEN
      CLOSE c_routingInfo;
      OPEN c_routingInfo;
  ELSE
      OPEN c_routingInfo;
  END IF;

  IF c_routingInfo%NOTFOUND
  THEN
    CLOSE c_routingInfo;
       	raise_application_error(-20000, 'IBY_204560#', FALSE);
    --raise_application_error(-20520,
      --'Rule condition has been changed. Modify Failed.', FALSE);
  END IF;

  CLOSE c_routingInfo;

  IF (isDuplicateCondNames(i_conditions) = true) THEN
        raise_application_error(-20000, 'IBY_204589#', FALSE);
  END IF;

  l_ruleId := i_rules.ruleId;
  FOR v_routingInfo  IN c_routingInfo LOOP
  UPDATE iby_routinginfo
    SET payeeid = i_rules.payeeId, bepkey = i_rules.merchantAccount,
      bepid = i_rules.bepid, configured = i_rules.activeStatus,
      instr_type = i_rules.bepInstrType, priority = i_rules.priority,
      last_update_date = sysdate, last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      hitcounter = i_rules.hitcounter,
      object_version_number = object_version_number+1
    WHERE CURRENT OF c_routingInfo;
  END LOOP;

  COMMIT;
  IF ( i_conditions.COUNT > 0 ) THEN
   DELETE FROM iby_pmtmthd_conditions
	  WHERE l_ruleId = iby_pmtmthd_conditions.PAYMENTMETHODID ;

   FOR v_count in 1..i_conditions.COUNT LOOP
   iby_pmtmthd_conditions_pkg.createCondition(l_ruleId,
			  i_conditions(v_count).parameter,
			  i_conditions(v_count).operation,
			  i_conditions(v_count).value,
			  i_conditions(v_count).is_value_string,
			  i_conditions(v_count).entry_seq,
			  i_conditions(v_count).condition_name );
   END LOOP;

  END IF;

END;

/*
** Function: deleteRoutingInfo.
** Purpose:  deletes the Routing information in the database.
*/
procedure deleteRoutingInfo ( i_paymentmethodId in
                                   iby_routinginfo.paymentmethodId%type,
                              i_paymentmethodName in
                                   iby_routinginfo.paymentmethodName%type,
                              i_version in
                                   iby_routinginfo.object_version_number%type)
is
-- Check whether this method name is already being used
CURSOR c_routingInfo IS
  SELECT *
    FROM iby_routinginfo  a
    WHERE i_version = a.object_version_number AND
      i_paymentmethodName=a.paymentmethodName AND
      i_paymentmethodId = a.paymentmethodId
    FOR UPDATE ;
BEGIN
  IF c_routingInfo%ISOPEN
  THEN
      CLOSE c_routingInfo;
      OPEN c_routingInfo;
  ELSE
      OPEN c_routingInfo;
  END IF;

  IF c_routingInfo%NOTFOUND
  THEN
    CLOSE c_routingInfo;
       	raise_application_error(-20000, 'IBY_204561#', FALSE);
    --raise_application_error(-20520,
      --'Routing Rule has been changed. Delete Failed.',
      --FALSE);
  END IF;

  CLOSE c_routingInfo;
  FOR v_routingInfo  IN c_routingInfo LOOP
    DELETE FROM iby_routinginfo
          WHERE CURRENT OF c_routingInfo;
  END LOOP;
  IF c_routingInfo%ISOPEN THEN
    CLOSE c_routingInfo;
  END IF;

  DELETE FROM iby_pmtmthd_conditions a
        WHERE a.paymentmethodid = i_paymentmethodId;

  COMMIT;

END;

/*
** Function: isDuplicateCondNames.
** Purpose:  Checks whether the input rule condition names contain
**           duplicates. Returns 'true' if there are duplicates, and
**           'false' if not.
*/
function isDuplicateCondNames ( i_conditions in t_condtRecVec )
return boolean is
BEGIN

  FOR v_count1 in 1..i_conditions.COUNT LOOP
    FOR v_count2 in (v_count1 + 1)..i_conditions.COUNT LOOP
      IF (UPPER(i_conditions(v_count1).condition_name) =
          UPPER(i_conditions(v_count2).condition_name))
      THEN
        return true;
      END IF;
    END LOOP;
  END LOOP;

  return false;

END isDuplicateCondNames;

end iby_routinginfo_pkg;

/
