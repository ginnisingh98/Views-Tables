--------------------------------------------------------
--  DDL for Package Body CAC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_DRT_PKG" AS
/* $Header: cacdrtpb.pls 120.1.12010000.1 2018/06/14 09:33:31 nmetta noship $*/
  l_package varchar2(50) DEFAULT 'cac_drt_pkg. ';
  --
  --- Implement logging
  --
  PROCEDURE write_log
    (message       IN         varchar2
    ,stage         IN         varchar2)
  IS
  BEGIN
                if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
                    fnd_log.string(fnd_log.level_procedure,message,stage);
                end if;
  END write_log;
  --
  --- Implement Common Application Calendar Core specific DRC for Entity Type HR
  --
	PROCEDURE cac_tca_drc
	(person_id       		IN         NUMBER
	,result_tbl    			OUT NOCOPY per_drt_pkg.result_tbl_type)
	IS
	l_proc 					VARCHAR2(100) := l_package|| 'cac_tca_drc';
	p_person_id 			NUMBER;
	l_count 				NUMBER;
	l_count1 				NUMBER;
	l_ownsup_count        	NUMBER;
	l_ownpartner_count   	NUMBER;
	l_ownparty_count      	NUMBER;
	l_assignsup_count     	NUMBER;
	l_assignpartner_count 	NUMBER;
	l_assignparty_count   	NUMBER;
	l_temp 					VARCHAR2(20);
	l_status				VARCHAR2(1);
	l_msg					VARCHAR2(1000);
	l_msg_code				VARCHAR2(100);
	l_emp_res_id        	NUMBER;
	l_sup_res_id        	NUMBER;
	l_party_res_id      	NUMBER;
	l_resource_id       	NUMBER;
	l_partner_res_id    	NUMBER;
	BEGIN
		write_log ('Entering:'|| l_proc,'10');
		p_person_id := person_id;
		write_log ('p_person_id: '|| p_person_id,'20');
		--
		---- Check DRC rule# 1
		--
		--
		--- Check If the TCA party id is a CUSTOMER or CONTACT for open TASK ?
		--
		--
		SELECT  COUNT(*)
		INTO 	l_count
		FROM 	JTF_TASKS_B
		WHERE 	CUSTOMER_ID = p_person_id
		AND 	OPEN_FLAG='Y';

		if l_count > 0 then
			l_status:='E';
			l_msg_code:='CAC_CUST_TASK_OPEN';
			per_drt_pkg.add_to_results
				  (person_id => p_person_id
				  ,entity_type => 'TCA'
				  ,status => l_status
				  ,msgcode => l_msg_code
				  ,msgaplid =>690
				  ,result_tbl => result_tbl);
		end if;

		 -- Check for the party id as a contact for SR
		 --reset the value
		 l_count := 0;


		SELECT COUNT(*)
		INTO   l_count
		FROM   JTF_TASK_PARTY_CONTACTS_V A,JTF_TASKS_B B,JTF_TASK_CONTACTS C,FND_LOOKUPS F
		WHERE  B.TASK_ID=C.TASK_ID
		AND    NVL(B.OPEN_FLAG,'N')='Y'
		AND    C.CONTACT_TYPE_CODE = 'CUST'
		AND    C.CONTACT_ID IN (A.PARTY_ID, A.SUBJECT_PARTY_ID)
		AND    A.SUBJECT_ID  = p_person_id
		AND	   F.LOOKUP_TYPE = 'JTF_TASK_CONTACT_TYPE'
		AND    F.LOOKUP_CODE = 'CUST'
		AND    F.ENABLED_FLAG='Y'
		AND    C.CONTACT_TYPE_CODE = F.LOOKUP_CODE
		AND    SYSDATE >= NVL(F.START_DATE_ACTIVE,SYSDATE)
		AND    SYSDATE <= NVL(F.END_DATE_ACTIVE,SYSDATE);


		if l_count>0 then
			l_status:='E';
			l_msg_code:='CAC_CUSTCONTACT_TASK';
			per_drt_pkg.add_to_results
				  (person_id => p_person_id
				  ,entity_type => 'TCA'
				  ,status => l_status
				  ,msgcode => l_msg_code
				  ,msgaplid =>690
				  ,result_tbl => result_tbl);
		end if;



		--For TASK OWNER deriving value of category EMPLOYEE from person id

		l_count := 0;
		SELECT COUNT(*)
		INTO 	l_count
		FROM    jtf_tasks_b
		WHERE   SOURCE_OBJECT_TYPE_CODE='TASK' and open_flag='Y'
		AND     owner_id IN (  select resource_id
								from jtf_rs_resource_extns
								where (CATEGORY = 'EMPLOYEE'
								AND    SOURCE_ID in (SELECT PERSON_ID
													 FROM PER_ALL_PEOPLE_F
													 WHERE PARTY_ID =  p_person_id
													 )
										)
							);
		--For TASK OWNER deriving value of category SUPPLIER_CONTACT from person id
		l_ownsup_count := 0;
		SELECT COUNT(*)
		INTO 	l_ownsup_count
		FROM 	JTF_TASKS_B
		WHERE 	SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y'
		AND 	OWNER_ID IN (	SELECT RESOURCE_ID
								FROM JTF_RS_RESOURCE_EXTNS
								WHERE   ( CATEGORY = 'SUPPLIER_CONTACT'
								AND 	  SOURCE_ID IN (SELECT VENDOR_CONTACT_ID
													  FROM PO_VENDOR_CONTACTS PVC,PO_VENDORS PV
													  WHERE PVC.VENDOR_ID = PV.VENDOR_ID
													  AND PVC.PER_PARTY_ID = P_PERSON_ID
													  )
										)
							);

		--For TASK OWNER deriving value of category PARTNER from person id

		l_ownpartner_count := 0;
		SELECT COUNT(*)
		INTO 	l_ownpartner_count
		FROM 	JTF_TASKS_B
		WHERE 	SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y'
		AND 	OWNER_ID IN (   SELECT  RESOURCE_ID
								FROM 	JTF_RS_RESOURCE_EXTNS
								WHERE  (CATEGORY = 'PARTNER'
								AND 	SOURCE_ID IN (SELECT PARTY_ID
													  FROM JTF_RS_PARTNERS_VL JP
													  WHERE JP.PARTY_ID = P_PERSON_ID
													  )
										)
							);


		--For TASK OWNER deriving value of category PARTY from person id
		l_ownparty_count := 0;
		SELECT COUNT(*)
		INTO 	l_ownparty_count
		FROM 	JTF_TASKS_B
		WHERE   SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y'
		AND 	OWNER_ID IN (SELECT RESOURCE_ID
							 FROM JTF_RS_RESOURCE_EXTNS
							 WHERE (CATEGORY = 'PARTY' AND SOURCE_ID = P_PERSON_ID
								   )
							);

		--For TASK ASSIGNMENTS deriving value of category EMPLOYEE from person id
		l_count1 := 0;
		SELECT 	COUNT(*)
		INTO 	l_count1
		FROM 	JTF_TASK_ASSIGNMENTS
		WHERE   TASK_ID IN (SELECT TASK_ID
							FROM JTF_TASKS_B
							WHERE SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y'
							)
		AND 	RESOURCE_ID IN (SELECT RESOURCE_ID
								FROM JTF_RS_RESOURCE_EXTNS
								WHERE   ( CATEGORY = 'EMPLOYEE'
								AND 	  SOURCE_ID IN (SELECT PERSON_ID
													  FROM PER_ALL_PEOPLE_F
													  WHERE PARTY_ID =  P_PERSON_ID
													  )
										)
								);

		--For TASK ASSIGNMENTS deriving value of category SUPPLIER_CONTACT from person id
		l_assignsup_count := 0;
		SELECT  COUNT(*)
		INTO 	l_assignsup_count
		FROM 	JTF_TASK_ASSIGNMENTS
		WHERE   TASK_ID IN (SELECT TASK_ID
							FROM   JTF_TASKS_B
							WHERE  SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y')
		AND 	RESOURCE_ID IN (SELECT RESOURCE_ID
								FROM JTF_RS_RESOURCE_EXTNS
								WHERE 	(	CATEGORY = 'SUPPLIER_CONTACT'
								AND 		SOURCE_ID IN (SELECT VENDOR_CONTACT_ID
														  FROM  PO_VENDOR_CONTACTS PVC,PO_VENDORS PV
														  WHERE PVC.VENDOR_ID    = PV.VENDOR_ID
														  AND   PVC.PER_PARTY_ID = P_PERSON_ID
														  )
										)
								);


		--For TASK ASSIGNMENTS deriving value of category PARTNER from person id

		l_assignpartner_count := 0;
		SELECT  COUNT(*)
		INTO 	l_assignpartner_count
		FROM 	JTF_TASK_ASSIGNMENTS
		WHERE   TASK_ID IN (SELECT TASK_ID
							FROM JTF_TASKS_B
							WHERE SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y')
		AND 	RESOURCE_ID IN (SELECT RESOURCE_ID
								FROM JTF_RS_RESOURCE_EXTNS
								WHERE  (CATEGORY = 'PARTNER'
								AND 	SOURCE_ID IN (SELECT PARTY_ID
													  FROM JTF_RS_PARTNERS_VL JP
													  WHERE JP.PARTY_ID = P_PERSON_ID
													  )
										)
								);

		--For TASK ASSIGNMENTS deriving value of category PARTY from person id

		l_assignparty_count := 0;
		SELECT  COUNT(*)
		INTO 	l_assignparty_count
		FROM 	JTF_TASK_ASSIGNMENTS
		WHERE   TASK_ID IN (SELECT TASK_ID
							FROM JTF_TASKS_B
							WHERE SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y')
		AND RESOURCE_ID IN (SELECT RESOURCE_ID
							FROM JTF_RS_RESOURCE_EXTNS
							WHERE (CATEGORY = 'PARTY' AND SOURCE_ID = P_PERSON_ID
								  )
							);


		IF l_count  	      >0
		OR l_ownsup_count 	  >0
		OR l_ownpartner_count >0
		OR l_ownparty_count   >0
		OR l_count1 		  >0
		OR l_assignsup_count  >0
		OR l_assignpartner_count >0
		OR l_assignparty_count   >0
		THEN
		 l_status	:='E';
		 l_msg_code :='CAC_OWN_ASSIGN_TASK_OPEN';
		 per_drt_pkg.add_to_results
				  (person_id => p_person_id
				  ,entity_type => 'TCA'
				  ,status => l_status
				  ,msgcode => l_msg_code
				  ,msgaplid =>690
				  ,result_tbl => result_tbl);
		END IF;


		-- Getting RESOURCE_ID for Resource Type ='EMPLOYEE'

		BEGIN
			SELECT RESOURCE_ID
			INTO l_emp_res_id
			FROM JTF_RS_RESOURCE_EXTNS
			WHERE (CATEGORY = 'EMPLOYEE'
			AND SOURCE_ID IN (SELECT PERSON_ID
							  FROM PER_ALL_PEOPLE_F
							  WHERE PARTY_ID =  P_PERSON_ID
							  )
				   );
		EXCEPTION WHEN others THEN
		   l_emp_res_id := null;
		END;

		-- Getting RESOURCE_ID for Resource Type ='SUPPLIER_CONTACT'
		BEGIN
			SELECT RESOURCE_ID
			INTO l_sup_res_id
			FROM JTF_RS_RESOURCE_EXTNS
			WHERE ( CATEGORY = 'SUPPLIER_CONTACT'
			AND     SOURCE_ID IN (SELECT VENDOR_CONTACT_ID
								  FROM PO_VENDOR_CONTACTS PVC,PO_VENDORS PV
								  WHERE PVC.VENDOR_ID = PV.VENDOR_ID
								  AND PVC.PER_PARTY_ID = P_PERSON_ID
								  )
				  );
		EXCEPTION WHEN others THEN
		   l_sup_res_id := null;
		END;


		-- Getting RESOURCE_ID for Resource Type ='PARTY'

		BEGIN
			SELECT RESOURCE_ID
			INTO   l_party_res_id
			FROM   JTF_RS_RESOURCE_EXTNS
			WHERE (CATEGORY = 'PARTY'
			AND    SOURCE_ID =  P_PERSON_ID
				   );
		EXCEPTION WHEN others THEN
		   l_party_res_id := null;
		END;

		-- Getting RESOURCE_ID for Resource Type ='PARTNER'

		BEGIN
			SELECT RESOURCE_ID
			INTO l_partner_res_id
			FROM JTF_RS_RESOURCE_EXTNS
			WHERE (CATEGORY = 'PARTNER'
			AND    SOURCE_ID IN ( SELECT PARTY_ID
								  FROM JTF_RS_PARTNERS_VL JP
								  WHERE JP.PARTY_ID = P_PERSON_ID
								)
				   );
		EXCEPTION WHEN others THEN
		   l_partner_res_id := null;
		END;


		--Decode condition for getting resource id from above conditions.
		select decode(l_emp_res_id,null,DECODE(l_sup_res_id,null,DECODE(l_party_res_id,null,l_partner_res_id,l_party_res_id),l_sup_res_id),l_emp_res_id)
		into l_resource_id
		from dual;

		-- JTF_TASK_DEFAULT_OWNER : Task Manager : Default task owner
		IF l_resource_id IS NOT NULL
		THEN

			l_count := 0;
			SELECT COUNT(1)
			INTO l_count
			FROM DUAL
			WHERE EXISTS (SELECT PROFILE_OPTION_VALUE
						  FROM  FND_PROFILE_OPTION_VALUES A,FND_PROFILE_OPTIONS B
						  WHERE A.APPLICATION_ID     = 690
						  AND   A.PROFILE_OPTION_ID  = B.PROFILE_OPTION_ID
						  AND   B.PROFILE_OPTION_NAME='JTF_TASK_DEFAULT_OWNER'
						  AND   PROFILE_OPTION_VALUE =l_resource_id);

			 IF l_count >0 THEN
				 l_status:='E';
				 l_msg_code:='CAC_PRF_DEF_TASK_OWNER';
				 per_drt_pkg.add_to_results
						  (person_id => p_person_id
						  ,entity_type => 'TCA'
						  ,status => l_status
						  ,msgcode => l_msg_code
						  ,msgaplid =>690
						  ,result_tbl => result_tbl);
			  END IF;
		 END IF; --end of if l_resource_id is not null


		write_log ('Leaving:'|| l_proc,'999');
	END cac_tca_drc;
  --
  --- Implement Core Service specific DRC for Employee  entity type
  --
	PROCEDURE cac_hr_drc
		(person_id       IN         number
		,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
	IS
		l_proc 			VARCHAR2(72) := l_package|| 'cac_hr_drc';
		p_person_id 	NUMBER(20);
		n 				NUMBER;
		l_temp 			VARCHAR2(20);
		l_result_tbl 	per_drt_pkg.result_tbl_type;
		l_count 		NUMBER;
		l_count1 		NUMBER;
		l_temp 			VARCHAR2(20);
		l_status		VARCHAR2(1);
		l_msg			VARCHAR2(1000);
		l_msg_code		VARCHAR2(100);
		l_emp_res_id 	NUMBER;
		l_sup_res_id 	NUMBER;
		 l_resource_id 	NUMBER;
	BEGIN
		write_log ('Entering:'|| l_proc,'10');
		p_person_id := person_id;
		write_log ('p_person_id: '|| p_person_id,'20');


	--For TASK OWNER deriving value of category EMPLOYEE from person id

		l_count := 0;
		SELECT COUNT(*)
		INTO 	l_count
		FROM    jtf_tasks_b
		WHERE   SOURCE_OBJECT_TYPE_CODE='TASK' and open_flag='Y'
		AND     owner_id IN (  select resource_id
								from jtf_rs_resource_extns
								where (CATEGORY = 'EMPLOYEE'
								AND    SOURCE_ID in (SELECT PERSON_ID
													 FROM PER_ALL_PEOPLE_F
													 WHERE PARTY_ID =  p_person_id
													 )
										)
							);

		--For TASK ASSIGNMENTS deriving value of category EMPLOYEE from person id
		l_count1 := 0;
		SELECT 	COUNT(*)
		INTO 	l_count1
		FROM 	JTF_TASK_ASSIGNMENTS
		WHERE   TASK_ID IN (SELECT TASK_ID
							FROM JTF_TASKS_B
							WHERE SOURCE_OBJECT_TYPE_CODE='TASK' and OPEN_FLAG='Y'
							)
		AND 	RESOURCE_ID IN (SELECT RESOURCE_ID
								FROM JTF_RS_RESOURCE_EXTNS
								WHERE   ( CATEGORY = 'EMPLOYEE'
								AND 	  SOURCE_ID IN (SELECT PERSON_ID
													  FROM PER_ALL_PEOPLE_F
													  WHERE PARTY_ID =  P_PERSON_ID
													  )
										)
								);

		IF l_count  	      >0
		OR l_count1 		  >0
		THEN
		 l_status	:='E';
		 l_msg_code :='CAC_OWN_ASSIGN_TASK_OPEN';
		 per_drt_pkg.add_to_results
				  (person_id => p_person_id
				  ,entity_type => 'HR'
				  ,status => l_status
				  ,msgcode => l_msg_code
				  ,msgaplid =>690
				  ,result_tbl => result_tbl);
		END IF;




		if l_status<>'E' then
				l_status:='S';
				l_msg_code:='';
				per_drt_pkg.add_to_results
				  (person_id => p_person_id
				  ,entity_type => 'HR'
				  ,status => l_status
				  ,msgcode => l_msg_code
				  ,msgaplid =>690
				  ,result_tbl => result_tbl);

		end if;



	END cac_hr_drc;
  --
  --- Implement Core HR specific DRC for FND entity type
  --
	PROCEDURE cac_fnd_drc
	(person_id       IN         number
	,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
	IS
	l_proc 			VARCHAR2(72) := l_package|| 'cac_fnd_drc';
	p_person_id 	NUMBER(20);
	n 				NUMBER;
	l_temp 			VARCHAR2(20);
	l_result_tbl per_drt_pkg.result_tbl_type;
	l_count 		NUMBER;
	l_temp 			VARCHAR2(20);
	l_status		VARCHAR2(1);
	l_msg			VARCHAR2(1000);
	l_msg_code		VARCHAR2(100);
	BEGIN
		write_log ('Entering:'|| l_proc,'10');
		p_person_id := person_id;
		write_log ('p_person_id: '|| p_person_id,'20');

		-- For CAC-TASK we do not have to deal with FND user here as that is taken care in TCA processing
			l_status:='S';
			l_msg_code:='';
				per_drt_pkg.add_to_results
				  (person_id => p_person_id
				  ,entity_type => 'HR'
				  ,status => l_status
				  ,msgcode => l_msg_code
				  ,msgaplid =>690
				  ,result_tbl => result_tbl);
		write_log ('Leaving: '|| l_proc,'80');
	END cac_fnd_drc;

END cac_drt_pkg;

/
