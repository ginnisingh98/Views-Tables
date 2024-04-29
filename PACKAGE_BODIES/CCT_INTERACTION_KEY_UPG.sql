--------------------------------------------------------
--  DDL for Package Body CCT_INTERACTION_KEY_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_INTERACTION_KEY_UPG" as
/* $Header: cctupgib.pls 120.0 2005/06/02 10:11:15 appldev noship $ */

procedure Upgrade_Interaction_Keys
IS
    l_upgraded        NUMERIC;
    status NUMERIC;
    l_operation varchar2(20) := 'EQUAL';
    BEGIN
      BEGIN
        SELECT Count(*) INTO l_upgraded
        FROM cct_interaction_keys
        WHERE (interaction_key='AccountCode' and data_type='STRING') OR
			(interaction_key='ContractNum' and data_type='STRING') OR
			(interaction_key='AccountNum' and data_type='STRING') ;
      EXCEPTION
	When Others Then
	  status := SQLCODE;
	  --dbms_output.put_line('In Upgrade_Interaction_Key Proc '||SQLERRM(STATUS));
    return;
      END;
      if (l_upgraded > 0) THEN
         --dbms_output.put_line('Interaction Keys are Already Upgraded');
         return;
      END IF;


 FOR l_record IN (
 	select route_param_id, value, operation from cct_route_params
 		where nvl(f_deletedflag,'N') <> 'D' )
 LOOP
	l_operation := 'EQUAL';
    IF ((l_record.value = 'AccountCode') OR (l_record.value = 'ContractNum')
								OR (l_record.value = 'AccountNum')) THEN
       IF (l_record.operation = '!=') THEN
         l_operation := 'NOTEQUAL';
       ELSIF (l_record.operation = 'DOESNOTEXISTSIN') THEN
         l_operation := 'DONOTEXISTSIN';
       ELSIF (l_record.operation = 'EXISTSIN') THEN
         l_operation := 'EXISTSIN';
    	  END IF;

    	  update cct_route_params set operation = l_operation
		where route_param_id = l_record.route_param_id AND nvl(f_deletedflag,'N')<>'D';

    END IF;
 END LOOP;


FOR l_record IN (
    select classification_rule_id, key, operation from CCT_Classification_Rules
        where nvl(f_deletedflag,'N') <> 'D' )
LOOP
   l_operation := 'EQUAL';
	 IF ((l_record.key = 'AccountCode') OR (l_record.key = 'ContractNum')
								OR (l_record.key = 'AccountNum')) THEN
      IF (l_record.operation = '!=') THEN
        l_operation := 'NOTEQUAL';
      ELSIF (l_record.operation = 'DOESNOTEXISTSIN') THEN
        l_operation := 'DONOTEXISTSIN';
      ELSIF (l_record.operation = 'EXISTSIN') THEN
        l_operation := 'EXISTSIN';
      END IF;

      update CCT_Classification_Rules set operation = l_operation
      where classification_rule_id = l_record.classification_rule_id
		AND nvl(f_deletedflag,'N')<>'D'  ;

   END IF;
END LOOP;
	update cct_interaction_keys set data_type='STRING'
		where (interaction_key='AccountCode' or interaction_key='ContractNum'
									  or interaction_key='AccountNum');


  --dbms_output.put_line(' Populate cct_interaction_keys table ');

  END Upgrade_Interaction_Keys;
END CCT_INTERACTION_KEY_UPG;

/
