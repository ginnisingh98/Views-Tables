--------------------------------------------------------
--  DDL for Package Body CCT_CLASS_ENGINE_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CLASS_ENGINE_UPG" as
/* $Header: cctupgcb.pls 115.13 2003/12/10 01:08:23 gvasvani noship $ */

procedure Upgrade_Class_Schema
IS
    l_upgraded        NUMERIC;
    l_updated VARCHAR2(1) := 'N';
    status NUMERIC;
    l_loop_count INTEGER := 0;
    l_count INTEGER := 0;
    l_deleted_count INTEGER := 0;
    BEGIN
      BEGIN
        SELECT Count(*) INTO l_upgraded
        FROM CCT_CLASSIFICATIONS
        WHERE CLASSIFICATION_VALUE_ID IS NOT NULL ;
       --EXECUTE IMMEDIATE 'DROP SEQUENCE cct_upgclass_priority_s';
      -- EXECUTE IMMEDIATE 'CREATE SEQUENCE cct_upgclass_priority_s START WITH 1';
      EXCEPTION
	When Others Then
	  status := SQLCODE;
	  --dbms_output.put_line('In Upgrade_Class_Schema Proc '||SQLERRM(STATUS));
    return;
      END;
      if (l_upgraded > 0) THEN
         --dbms_output.put_line('Classification Schema is Already Upgraded');
         return;
      END IF;
  insert into cct_classification_values (classification_value_id, classification_value,seeded,
      LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,f_deletedflag)
  select cct_classification_values_s.nextval, classification,'N',
  	TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1,
  	TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1,a.f_deletedflag  from cct_classifications a
  where (upper(type)= 'LITERAL') AND classification_value_id is null
  	AND upper(classification) <> 'UNCLASSIFIED';

  insert into cct_classification_values (classification_value_id, classification_value,
		seeded,LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
  select cct_classification_values_s.nextval, 'unClassified', 'Y',
  	TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1,
  	TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1  from dual;

  --dbms_output.put_line('Classification Values is Upgraded');
  insert into cct_plsql_functions (function_id, function, function_name, package,appdb,
  	dburl, dbdriver, return_type,seeded,LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
	CREATED_BY)
  select cct_plsql_functions_s.nextval,substr(classification, instr(classification,'.',1)+1),
  classification,substr(classification,1, instr(classification,'.',1)-1),
 	DECODE(db_driver, nvl(db_driver,'Y'),'N','Y'), dburl, db_driver,  'occtClassification',
	'N', TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1,TO_DATE ('01/01/1951', 'DD/MM/YYYY'),1
	from cct_classifications a
	where (upper(type)= 'DBPROC')
 		AND classification_value_id is null AND nvl(a.f_deletedflag,'N') <> 'D';

  --dbms_output.put_line(' PL/SQL Functions is Upgraded');

FOR l_record IN (
    SELECT classification_id, classification FROM cct_classifications
    WHERE type = 'LITERAL' order by f_deletedflag desc)
 LOOP
   l_loop_count := l_loop_count + 1;
   l_updated := 'N';
   select COUNT(*) into l_count from cct_classification_values where l_record.classification = classification_value
                                             and nvl(f_deletedflag,'N')<>'D';
   select COUNT(*) into l_deleted_count from cct_classification_values where l_record.classification = classification_value
                                             and nvl(f_deletedflag,'N')='D';
   FOR l_classValue_record IN (select classification_value_id, nvl(f_deletedflag,'N') f_deletedflag
  	  from cct_classification_values where l_record.classification = classification_value
           OR (upper(l_record.classification)='UNCLASSIFIED' AND classification_value='unClassified'))
   LOOP
     IF ((l_count >= 1 OR l_deleted_count >= 1 OR upper(l_record.classification)='UNCLASSIFIED') AND l_updated = 'N') THEN
     l_updated := 'Y';
     --In case we have multiple classifications defined in cct_classifications table, We don't
     --want to update cct_classification table with already deleted classification. Although we still
     --want deleted classificaiton value to sit into cct_classification_values table (due to Business Intelligence req).
       update cct_classifications a set a.classification_value_id = l_classValue_record.classification_value_id,
     	   a.IsEnabled = nvl(a.IsEnabled,'YES'),
         a.Priority = l_loop_count,
      	 a.Rule_Chaining = nvl(a.Rule_Chaining,'AND')
       where a.classification_id = l_record.classification_id;
     --DBMS_OUTPUT.PUT_LINE('Inserted into cct_classifications table '||l_classValue_record.classification_value_id||' and '||l_record.classification);
     END IF;
   END LOOP;
 END LOOP;


FOR l_record IN (
   SELECT classification_id, classification FROM cct_classifications
   WHERE type = 'DBPROC' AND nvl(f_deletedflag,'N')<>'D')
LOOP
      l_loop_count := l_loop_count + 1;
 update cct_classifications a set a.classification_value_id = (select b.function_id
 		from cct_plsql_functions b
		where l_record.classification = b.package||decode(b.package, '','','.')||b.function
			AND nvl(b.f_deletedflag,'N')<>'D'), a.IsEnabled = nvl(a.IsEnabled,'YES'),
 a.Priority = l_loop_count,
 a.Rule_Chaining = nvl(a.Rule_Chaining,'AND')
 where a.classification_id = l_record.classification_id;
END LOOP;

  --dbms_output.put_line(' Populate cct_classifications table with PL/SQL Function ids');
insert into cct_plsql_function_params (function_param_id,function_id,param,datatype,direction,
    sequence,value,LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
    select cct_plsql_function_params_s.nextval,b.classification_value_id,a.param,
    		a.datatype,a.direction, a.sequence,a.value, TO_DATE ('01/01/1951', 'DD/MM/YYYY'),
		1,TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1
	from cct_route_params a, cct_classifications b
	where a.classification_id=b.classification_id AND upper(b.type)='DBPROC'
		AND nvl(a.f_deletedflag,'N')<>'D' AND nvl(b.f_deletedflag,'N')<>'D';

  --dbms_output.put_line('Populated pl/sql function params..');
insert into cct_classification_sg_map (classification_sg_map_id, classification_id,
		server_group_id, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
	select cct_classification_sg_map_s.nextval, b.classification_id, a.server_group_id,
	    TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1,TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1
	from ieo_svr_groups a, cct_classifications b
	where a.group_group_id is null AND nvl(b.f_deletedflag,'N')<>'D';

  --dbms_output.put_line(' Populate cct_sg_map table ');
insert into cct_classification_mt_map (classification_mt_map_id,
classification_id, media_type_uuid,LAST_UPDATE_DATE, LAST_UPDATED_BY,
CREATION_DATE, CREATED_BY)
select cct_classification_mt_map_s.nextval, b.classification_id,
a.media_type_uuid, TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1,
TO_DATE ('01/01/1951', 'DD/MM/YYYY'),
 1 from cct_supported_media_types a, cct_classifications b
where nvl(b.f_deletedflag,'N')<>'D';

  --dbms_output.put_line(' Populate cct_mt_map table ');

   END Upgrade_Class_Schema;


procedure fix_class_priorities
IS
  Cursor csr_Server_Groups IS
    Select distinct Server_Group_id
    From cct_classification_sg_map
    where nvl(f_deletedflag,'N')<>'D';

  CURSOR csr_classifications(p_server_group_id number) IS
    SELECT map.classification_id
    FROM cct_classification_sg_map map,cct_classifications class
    where map.server_group_id=p_server_Group_id
    and nvl(map.f_deletedflag,'N')<>'D'
    and map.priority is null
    and map.classification_id=class.classification_id
    and nvl(class.f_deletedflag,'N')<>'D'
    ORDER BY class.priority;
  l_server_Group_id Number;
  l_priority Number;
  l_class_id Number;
BEGIN
   SAVEPOINT  fix_class_priorities_pt;

   OPEN csr_server_groups;
   LOOP
     FETCH csr_server_groups INTO l_server_Group_id;
     EXIT WHEN csr_server_groups%NOTFOUND;
     --dbms_output.put_line('ServerGroupId='||to_char(l_server_Group_id));
	l_priority:=1;

	Open csr_classifications(l_server_group_id);
	Loop
	   Fetch csr_classifications into l_class_id;
	   Exit when csr_classifications%NOTFOUND;
        --dbms_output.put_line('Classification ID='||to_char(l_class_id)||' priority='||to_char(l_priority));
        update cct_classification_sg_map
        set priority = l_priority
        where classification_id = l_class_id;
        l_priority:=l_priority+1;
     END LOOP;
	Close csr_classifications;
   End Loop;
   CLOSE csr_server_Groups;

EXCEPTION
   WHEN others THEN
      ROLLBACK TO fix_class_priorities_pt;
END fix_class_priorities;

-- Procedure to transfer deleted Classification records to new schema, as Business Intelligence
-- also, looks for deleted Classifications.

procedure Upgrade_Class_BI
IS
l_class_value_id Number(15);
 BEGIN
 -- Insert all deleted Classifications from cct_classifications table to a cct_classification_values table. This
 -- newly inserted record in cct_classification_values table must have deletedflag set to 'D'.
 -- As 1158 upgrade script won't carry over deleted classifications and Business Intelligence team needs those.
 -- Update cct_classifications table with this new classification_value_id.

   FOR l_record IN (
    SELECT classification, classification_id FROM cct_classifications
    where (upper(type)= 'LITERAL') AND classification_value_id is null
     AND nvl(f_deletedflag,'N')='D' AND upper(classification) <> 'UNCLASSIFIED')
 LOOP
  select cct_classification_values_s.nextval into l_class_value_id from dual;
  insert into cct_classification_values (classification_value_id, classification_value,seeded,
      LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,f_deletedflag)
  select l_class_value_id, l_record.classification,'N',
     TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1, TO_DATE ('01/01/1951', 'DD/MM/YYYY'), 1,'D'
     from dual;

   update cct_classifications a set a.classification_value_id = l_class_value_id
   where a.classification_id = l_record.classification_id;

  --dbms_output.put_line('At End of UpgradeBI loop');
 END LOOP;

END Upgrade_Class_BI;

PROCEDURE UpgradeIKeys
IS
    l_upgraded        NUMERIC;
    status NUMERIC;
    StringOperation Varchar2(20);
    l_loop_count          INTEGER := 0;

   -- Declare program variables as shown above
BEGIN
FOR l_record IN (
    select classification_rule_id, operation from CCT_CLASSIFICATION_RULES
    where key in ('AccountCode','AccountNum','occtRoutePoint', 'ContractNum')
    AND operation in ('=','>','>=','<','<=','!=','DOESNOTEXISTSIN','BETWEEN')
    AND nvl(f_deletedflag,'N')<>'D'
    )
LOOP
--dbms_output.put_line('At beginning of For Loop');
 StringOperation:='EQUAL';
 IF l_record.operation='!=' THEN
   StringOperation:='NOTEQUAL';
 ELSIF UPPER(l_record.operation)='DOESNOTEXISTSIN' THEN
   StringOperation:='DONOTEXISTIN';
 END IF;

 update CCT_CLASSIFICATION_RULES set operation=StringOperation
 where classification_rule_id = l_record.classification_rule_id;

 END LOOP;
--dbms_output.put_line('At End of 1st For Loop');

FOR l_record IN (
  select route_param_id, operation from cct_route_params
  WHERE value IS NOT NULL AND direction is null and sequence is null
  AND param in ('AccountCode','AccountNum','occtRoutePoint', 'ContractNum')
  AND operation in ('=','>','>=','<','<=','!=','DOESNOTEXISTSIN','BETWEEN')
  AND nvl(f_deletedflag,'N')<>'D'
  )
LOOP
--dbms_output.put_line('At beginning of 2nd For Loop');
 StringOperation:='EQUAL';
 IF l_record.operation='!=' THEN
   StringOperation:='NOTEQUAL';
 ELSIF UPPER(l_record.operation)='DOESNOTEXISTSIN' THEN
   StringOperation:='DONOTEXISTIN';
 END IF;

 update cct_route_params set operation=StringOperation
 where route_param_id = l_record.route_param_id;

END LOOP;

-- Update occtAgentID Key.
update cct_interaction_keys set IVR_MAP_ENABLED='Y' where interaction_key='occtAgentID' ;

--dbms_output.put_line('At End of 2nd For Loop');
EXCEPTION
    WHEN Others THEN
      status := SQLCODE;
	  --dbms_output.put_line('In Upgrade_Class_Schema Proc's CCT_IKEY_UPGRADE Portion '||SQLERRM(STATUS));
END UpgradeIKeys; -- Procedure


END CCT_CLASS_ENGINE_UPG;

/
