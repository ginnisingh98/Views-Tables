--------------------------------------------------------
--  DDL for Package Body CS_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_DRT_PKG" AS
/* $Header: csdrtpb.pls 120.0.12010000.9 2018/05/03 19:43:27 lkullamb noship $*/
  l_package varchar2(33) DEFAULT 'cs_drt_PKG. ';
  --
  --- Implement log writter
  --
  PROCEDURE write_log
    (message       IN         varchar2
    ,stage       IN                 varchar2) IS
  BEGIN
                if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
                    fnd_log.string(fnd_log.level_procedure,message,stage);
                end if;
  END write_log;
  --
  --- Implement sub-sprogram add record corresponding to an error/warning/error
  --
/*
PROCEDURE add_to_results
    (person_id       IN         number
    ,entity_type     IN         varchar2
    ,status          IN         varchar2
    ,msgcode         IN         varchar2
    ,msgaplid        IN         number
    ,result_tbl      IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    n number(15);
  begin
    n := result_tbl.count + 1;
    result_tbl(n).person_id := person_id;
    result_tbl(n).entity_type := entity_type;
    result_tbl(n).status := status;
    result_tbl(n).msgcode := msgcode;
    --hr_utility.set_message(msgaplid,msgcode);
   --result_tbl(n).msgtext := hr_utility.get_message();
  end add_to_results;
*/
  --
  --- Implement Core HR specific DRC for HR entity type
  --
  PROCEDURE cs_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    l_proc varchar2(72) := l_package|| 'cs_hr_drc';
    p_person_id number(20);
    l_count number;
    l_count1 NUMBER;
    l_ownsup_count        NUMBER;
    l_ownpartner_count    NUMBER;
    l_ownparty_count      NUMBER;
    l_assignsup_count     NUMBER;
    l_assignpartner_count NUMBER;
    l_assignparty_count   NUMBER;
    l_temp varchar2(20);
    l_status	varchar2(1);
    l_msg		varchar2(1000);
    l_msg_code		varchar2(100);
    l_emp_res_id        NUMBER;
    l_sup_res_id        NUMBER;
    l_party_res_id      NUMBER;
    l_resource_id       NUMBER;
	l_partner_res_id    NUMBER;
  BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
    ---- Check DRC rule# 1
    --
    --
    --- Check If the TCA party id is a customer or contact for open SRved or not
    --
    --
    select count(*) into l_count
    from cs_incidents_all_B where customer_id=p_person_id and status_flag='O';

    if l_count > 0 then
     	l_status:='E';
        l_msg_code:='CS_CUST_LIVE_SR';
        per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
    end if;
     -- Check for the party id as a contact for SR
     --reset the value
     l_count := 0;

    select count(*) into l_count from cs_hz_sr_contact_points a,cs_incidents_all_b b
    where a.party_id=p_person_id AND a.contact_type='PERSON'
    and a.incident_id=b.incident_id and b.status_flag = 'O';

    if l_count>0 then
   	l_status:='E';
        l_msg_code:='CS_CUSTCONTACT_LIVE_SR';
        per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
    end if;

    --reset the value
    l_count := 0;
    -- Check for relationship party
    select count(*) into l_count from cs_hz_sr_contact_points a,cs_incidents_all_b b,hz_relationships c
    where b.incident_id=a.incident_id and b.status_flag = 'O' AND a.contact_type='PARTY_RELATIONSHIP'
    and c.subject_id=p_person_id and c.subject_type='PERSON' and c.party_id=a.party_id and c.DIRECTIONAL_FLAG = 'F';

    if l_count>0 then
   	l_status:='E';
        l_msg_code:='CS_RELCONTACT_LIVE_SR';
        per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
    end if;

    --reset the value
    l_count := 0;
    --check for person type bill to or ship to customer or self-contact
    select count(*) into l_count from cs_incidents_all_b a,hz_parties b
    where a.status_flag = 'O' AND
    ((a.BILL_TO_PARTY_ID = b.party_id AND b.party_type='PERSON') OR (a.BILL_TO_CONTACT_ID = b.party_id AND b.party_type='PERSON')
    OR (a.SHIP_TO_PARTY_ID = b.party_id AND b.party_type='PERSON') OR (a.SHIP_TO_CONTACT_ID = b.party_id AND b.party_type='PERSON'))
    AND b.party_id=p_person_id;

    if l_count>0 then
   	l_status:='E';
        l_msg_code:='CS_BILLSHIPTO_CUST_LIVE_SR';
        per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
    end if;

    --reset the value
    l_count := 0;
    --check for person type bill to or ship to contact
	select count(*) into l_count from hz_relationships c, hz_parties d where c.party_id = d.party_id AND
      d.party_type = 'PARTY_RELATIONSHIP' AND c.subject_type='PERSON'  AND   c.subject_id =p_person_id AND
      exists (select  incident_id from cs_incidents_all_b a,cs_incident_statuses_b d
                where a.incident_status_id=d.incident_Status_id and nvl(d.close_flag,'N')='N' and
                     (a.bill_to_party_id=c.party_id or a.bill_to_contact_id = c.party_id  or
                       a.ship_to_party_id = c.party_id or a.ship_to_contact_id= c.party_id));

    if l_count>0 then
   	l_status:='E';
        l_msg_code:='CS_BILLSHIPTOCNTCT_LIVE_SR';
        per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
    end if;


 -- Find Employee as Assignee We are doing it on TCA call as we are deriving the employee id based on the TCA id
 -- For SR owner
 --reset the value
 l_count := 0;
 /**/
 SELECT COUNT(*) INTO l_count
 FROM cs_incidents_all_b a, cs_incident_statuses_b d
 where a.incident_status_id=d.incident_Status_id and nvl(d.close_flag,'N')='N'
 AND incident_owner_id in (select resource_id from jtf_rs_resource_extns where
                             (CATEGORY = 'EMPLOYEE' AND SOURCE_ID in (SELECT PERSON_ID FROM PER_ALL_PEOPLE_F
			   		 WHERE PARTY_ID =  p_person_id)));
if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_ASSIGNEE_SR';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

 l_count := 0;
 SELECT COUNT(*) INTO l_count
 FROM cs_incidents_all_b a, cs_incident_statuses_b d
 where a.incident_status_id=d.incident_Status_id and nvl(d.close_flag,'N')='N'
 AND incident_owner_id in (select resource_id from jtf_rs_resource_extns where
                           (CATEGORY = 'SUPPLIER_CONTACT'
						   and SOURCE_ID in (SELECT VENDOR_CONTACT_ID
						   FROM po_vendor_contacts PVC,PO_VENDORS PV
                           WHERE pvc.vendor_id = PV.vendor_id and PVC.PER_PARTY_ID = p_person_id)));
if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_ASSIGNEE_SR';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

 l_count := 0;
SELECT COUNT(*) INTO l_count
 FROM cs_incidents_all_b a, cs_incident_statuses_b d
 where a.incident_status_id=d.incident_Status_id and nvl(d.close_flag,'N')='N'
 AND incident_owner_id in (select resource_id from jtf_rs_resource_extns
 where (CATEGORY = 'PARTNER' and SOURCE_ID in (SELECT PARTY_ID FROM JTF_RS_PARTNERS_VL JP
 WHERE JP.PARTY_ID = p_person_id )));

 if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_ASSIGNEE_SR';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

 --Added for PARTY type
 l_count := 0;

SELECT COUNT(*) INTO l_count
 FROM cs_incidents_all_b a, cs_incident_statuses_b d
 where a.incident_status_id=d.incident_Status_id and nvl(d.close_flag,'N')='N'
 AND incident_owner_id in (select resource_id from jtf_rs_resource_extns
 where (CATEGORY = 'PARTY' and SOURCE_ID = p_person_id));

if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_ASSIGNEE_SR';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

 --For unsubmitted charge lines,person customer
--reset the value
 l_count := 0;

SELECT COUNT(*) INTO l_count from hz_parties hz where hz.party_id = p_person_id
and hz.party_type='PERSON' and exists (
		select ced.estimate_detail_id
		FROM cs_estimate_details ced, cs_incidents_all_b inc, cs_incident_statuses_b st
		WHERE inc.incident_id=ced.incident_id AND ced.order_line_id IS NULL
		AND inc.incident_status_id=st.incident_Status_id and nvl(st.close_flag,'N')='N'
		AND (ced.BILL_TO_PARTY_ID = hz.party_id OR ced.BILL_TO_CONTACT_ID = hz.party_id
		OR ced.SHIP_TO_PARTY_ID = hz.party_id OR ced.SHIP_TO_CONTACT_ID = hz.party_id));

 if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_BILLSHIPTO_CUST_CHRG';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

--For unsubmitted charge lines,relationship record
 --reset the value
 l_count := 0;
 SELECT COUNT(*) INTO l_count
 from hz_parties hz,hz_relationships rel
 where hz.party_id = rel.party_id and hz.party_type='PARTY_RELATIONSHIP'
 and rel.subject_id = p_person_id and rel.subject_type='PERSON'
 and exists (
	  select ced.estimate_detail_id
	  FROM cs_estimate_details ced, cs_incidents_all_b inc , cs_incident_statuses_b st
	  WHERE inc.incident_id=ced.incident_id  AND ced.order_line_id IS NULL
	  AND inc.incident_status_id=st.incident_Status_id and nvl(st.close_flag,'N')='N'
	  AND (ced.BILL_TO_PARTY_ID = hz.party_id OR ced.BILL_TO_CONTACT_ID = hz.party_id
	  OR ced.SHIP_TO_PARTY_ID = hz.party_id  OR ced.SHIP_TO_CONTACT_ID = hz.party_id));

if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_BILLSHIPTOCNTCT_CHRG';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

--For task owner
--reset the value
 l_count := 0;
SELECT COUNT(*) INTO l_count
FROM jtf_tasks_b
where source_object_type_code='SR' and open_flag='Y'
AND owner_id IN  (select resource_id from jtf_rs_resource_extns
				  where (CATEGORY = 'EMPLOYEE'
				  AND SOURCE_ID in (SELECT PERSON_ID
									FROM PER_ALL_PEOPLE_F
									WHERE PARTY_ID =  p_person_id)));

/*if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_TASK_ASSIGNEE_SR';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;*/

l_ownsup_count := 0;
SELECT COUNT(*) INTO l_ownsup_count
FROM jtf_tasks_b
where source_object_type_code='SR' and open_flag='Y'
AND owner_id IN  (select resource_id from jtf_rs_resource_extns
				  where (CATEGORY = 'SUPPLIER_CONTACT'
				  and SOURCE_ID in (SELECT VENDOR_CONTACT_ID
									FROM po_vendor_contacts PVC,PO_VENDORS PV
									WHERE pvc.vendor_id = PV.vendor_id
									and PVC.PER_PARTY_ID = p_person_id)));

/*if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_TASK_ASSIGNEE_SR';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;*/

l_ownpartner_count := 0;
SELECT COUNT(*) INTO l_ownpartner_count
FROM jtf_tasks_b
where source_object_type_code='SR' and open_flag='Y'
AND owner_id IN (select resource_id from jtf_rs_resource_extns
				 where (CATEGORY = 'PARTNER'
				 and SOURCE_ID in (SELECT PARTY_ID FROM JTF_RS_PARTNERS_VL JP
								   WHERE JP.PARTY_ID = p_person_id )));

/*if l_count>0 then
    l_status:='E';
    l_msg_code:='CS_TASK_ASSIGNEE_SR';
    per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;*/

l_ownparty_count := 0;
SELECT COUNT(*) INTO l_ownparty_count
FROM jtf_tasks_b
where source_object_type_code='SR' and open_flag='Y'
AND owner_id IN (select resource_id from jtf_rs_resource_extns
				 where (CATEGORY = 'PARTY'
				 and SOURCE_ID = p_person_id ));

--For task assignee
--reset the value
 l_count1 := 0;
select count(*) into l_count1
from jtf_task_assignments
where  task_id in (select task_id from jtf_tasks_b
				   where source_object_type_code='SR' and open_flag='Y')
and resource_id in (select resource_id from jtf_rs_resource_extns
					where (CATEGORY = 'EMPLOYEE'
					AND SOURCE_ID in (SELECT PERSON_ID
									  FROM PER_ALL_PEOPLE_F
									  WHERE PARTY_ID =  p_person_id)));
/*if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_TASK_ASSIGNEE_SR';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;*/

 l_assignsup_count := 0;
select count(*) into l_assignsup_count
from jtf_task_assignments
where  task_id in (select task_id from jtf_tasks_b
				   where source_object_type_code='SR' and open_flag='Y')
and resource_id in (select resource_id from jtf_rs_resource_extns
					where (CATEGORY = 'SUPPLIER_CONTACT'
				    and SOURCE_ID in (SELECT VENDOR_CONTACT_ID
								      FROM po_vendor_contacts PVC,PO_VENDORS PV
									  WHERE pvc.vendor_id = PV.vendor_id
									  and PVC.PER_PARTY_ID = p_person_id)));
/*if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_TASK_ASSIGNEE_SR';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;*/

 l_assignpartner_count := 0;
select count(*) into l_assignpartner_count
from jtf_task_assignments
where  task_id in (select task_id from jtf_tasks_b
				   where source_object_type_code='SR' and open_flag='Y')
and resource_id in (select resource_id from jtf_rs_resource_extns
					where (CATEGORY = 'PARTNER'
					and SOURCE_ID in (SELECT PARTY_ID
									  FROM JTF_RS_PARTNERS_VL JP
									  WHERE JP.PARTY_ID = p_person_id )));

l_assignparty_count := 0;
select count(*) into l_assignpartner_count
from jtf_task_assignments
where  task_id in (select task_id from jtf_tasks_b
		 where source_object_type_code='SR' and open_flag='Y')
                 and resource_id in (select resource_id from jtf_rs_resource_extns
					where (CATEGORY = 'PARTY'
					and SOURCE_ID = p_person_id ));


if l_count  >0 OR l_ownsup_count >0 OR l_ownpartner_count >0 OR l_ownparty_count > 0
  OR l_count1 > 0 OR l_assignsup_count >0 OR l_assignpartner_count >0 OR  l_assignparty_count > 0 then
     l_status:='E';
     l_msg_code:='CS_TASK_ASSIGNEE_SR';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

BEGIN
    select resource_id into l_emp_res_id from jtf_rs_resource_extns where (CATEGORY = 'EMPLOYEE' AND SOURCE_ID in (SELECT PERSON_ID
			FROM PER_ALL_PEOPLE_F WHERE PARTY_ID =  p_person_id));
EXCEPTION WHEN others THEN
   l_emp_res_id := null;
END;

BEGIN
select resource_id into l_sup_res_id from jtf_rs_resource_extns
					where (CATEGORY = 'SUPPLIER_CONTACT'
				    and SOURCE_ID in (SELECT VENDOR_CONTACT_ID
					FROM po_vendor_contacts PVC,PO_VENDORS PV
					WHERE pvc.vendor_id = PV.vendor_id
					and PVC.PER_PARTY_ID = p_person_id));
EXCEPTION WHEN others THEN
   l_sup_res_id := null;
END;


BEGIN
    select resource_id into l_party_res_id from jtf_rs_resource_extns where (CATEGORY = 'PARTY' AND SOURCE_ID =  p_person_id);
EXCEPTION WHEN others THEN
   l_party_res_id := null;
END;

-- START :Added for PARTNER

BEGIN
select resource_id into l_partner_res_id from jtf_rs_resource_extns
					 where (CATEGORY = 'PARTNER'
					 and SOURCE_ID in (SELECT PARTY_ID
					 FROM JTF_RS_PARTNERS_VL JP
					 WHERE JP.PARTY_ID = p_person_id ));
EXCEPTION WHEN others THEN
   l_partner_res_id := null;
END;

-- END : Added for PARTNER

select decode(l_emp_res_id,
			  null,
			  DECODE(l_sup_res_id,
					 null,
					 DECODE(l_party_res_id,null,l_partner_res_id,l_party_res_id),
					 l_sup_res_id),
			  l_emp_res_id) into l_resource_id
from dual;

IF l_resource_id IS NOT NULL THEN

  -- CS_SR_DEFAULT_SYSTEM_RESOURCE : Service: Default System Resource
  l_count := 0;
  select COUNT(1) into l_count
  from dual
	where exists (select profile_option_value
	                from fnd_profile_option_values a,fnd_profile_options b
			where a.application_id= 170
			and a.profile_option_id = b.profile_option_id
			and b.profile_option_name='CS_SR_DEFAULT_SYSTEM_RESOURCE'
			and profile_option_value= l_resource_id);

  if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_SYS_RES_CUST';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
   end if;

  -- INC_DEFAULT_INCIDENT_OWNER : Service: Default Service Request Owner
 l_count := 0;
 select COUNT(1) into l_count
 from dual
	where exists (select profile_option_value
			from fnd_profile_option_values a,fnd_profile_options b
			where a.application_id= 170
			and a.profile_option_id = b.profile_option_id
			and b.profile_option_name='INC_DEFAULT_INCIDENT_OWNER'
			and profile_option_value=l_resource_id);

  if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_SR_OWNER_CUST';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
  end if;

  -- INC_DEFAULT_INCIDENT_TASK_OWNER : Service: Default Service Request Task Owner
  l_count := 0;
 select COUNT(1) into l_count
 from dual
	where exists (select profile_option_value
			from fnd_profile_option_values a,fnd_profile_options b
			where a.application_id= 170
			and a.profile_option_id = b.profile_option_id
			and b.profile_option_name='INC_DEFAULT_INCIDENT_TASK_OWNER'
			and profile_option_value=l_resource_id);


  if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_SR_TSK_OWNR_CUST';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
   end if;

  --INC_DEFAULT_INCIDENT_TASK_ASSIGNEE : Service: Default Task Assignee on the Service Request Tasks tab
  l_count := 0;
  select COUNT(1) into l_count
  from dual
	where exists (select profile_option_value
			from fnd_profile_option_values a,fnd_profile_options b
			where a.application_id= 170
			and a.profile_option_id = b.profile_option_id
			and b.profile_option_name='INC_DEFAULT_INCIDENT_TASK_ASSIGNEE'
			and profile_option_value=l_resource_id);

  if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_TSK_ASSGN_CUST';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
  end if;

  -- CSC_TASK_DEFAULT_ASSIGNEE : Customer Care: Default Assignee for New Customer Tasks
  l_count := 0;
  select COUNT(1) into l_count
  from dual
	where exists (select profile_option_value
			from fnd_profile_option_values a,fnd_profile_options b
			where a.application_id= 511
			and a.profile_option_id = b.profile_option_id
			and b.profile_option_name='CSC_TASK_DEFAULT_ASSIGNEE'
			and profile_option_value=l_resource_id);

  if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_ASSGN_NEW_TSK_CUST';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;

 -- CSC_TASK_DEFAULT_OWNER : Customer Care: Default Task Owner for New Customer Tasks

 l_count := 0;
 select COUNT(1) into l_count
  from dual
	where exists (select profile_option_value
			from fnd_profile_option_values a,fnd_profile_options b
			where a.application_id= 511
			and a.profile_option_id = b.profile_option_id
			and b.profile_option_name='CSC_TASK_DEFAULT_OWNER'
			and profile_option_value=l_resource_id);

  if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_OWNR_NEW_TSK_CUST';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
  end if;

 -- JTF_TASK_DEFAULT_OWNER : Task Manager : Default task owner
 l_count := 0;
 select COUNT(1) into l_count
 from dual
	where exists (select profile_option_value
			from fnd_profile_option_values a,fnd_profile_options b
			where a.application_id= 690
			and a.profile_option_id = b.profile_option_id
			and b.profile_option_name='JTF_TASK_DEFAULT_OWNER'
			and profile_option_value=l_resource_id);

 if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_TASK_OWNER_CUST';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
  end if;
 END IF; --end of if l_resource_id is not null

 -- 'CS_SR_DEFAULT_CUSTOMER_NAME' : Service Default customer name
 l_count := 0;
 select COUNT(1) into l_count from dual
  where exists (select profile_option_value from fnd_profile_option_values a,fnd_profile_options b  where a.application_id= 170 and a.profile_option_id = b.profile_option_id  and
                                  b.profile_option_name='CS_SR_DEFAULT_CUSTOMER_NAME' and profile_option_value=p_person_id);
 if l_count >0 then
     l_status:='E';
     l_msg_code:='CS_PRF_DEF_CUSTOMER_NAME';
     per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'TCA'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
  end if;

  if l_status<>'E' then
  	l_status:='S';
        per_drt_pkg.add_to_results
           (person_id => p_person_id
           ,entity_type => 'TCA'
           ,status => l_status
           ,msgcode => ''
           ,msgaplid =>170
           ,result_tbl => result_tbl);
 end if;



    write_log ('Leaving:'|| l_proc,'999');
END cs_tca_drc;
  --
  --- Implement Core Service specific DRC for Employee  entity type
  --
  PROCEDURE cs_hr_drc
        (person_id       IN         number
        ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_proc varchar2(72) := l_package|| 'cs_tca_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
    l_result_tbl per_drt_pkg.result_tbl_type;
    l_count number;
    l_temp varchar2(20);
    l_status	varchar2(1);
    l_msg		varchar2(1000);
    l_msg_code		varchar2(100);
		l_emp_res_id number;
    l_sup_res_id number;
	  l_resource_id number;
  BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
    -- Find employee record as part of SR contact
      	select count(*) into l_count
          from cs_incidents_all_b a,cs_hz_sr_contact_points b,per_all_people_F d
          where a.incident_id=b.incident_id and a.status_flag = 'O'
	  and d.person_id=p_person_id
          and b.party_id=d.person_id AND b.contact_type='EMPLOYEE';

	 if l_count>0 then
	     l_status:='E';
	     l_msg_code:='CS_EMPCONTACT_LIVE_SR';
       				per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 		end if;

-- CS_DEFAULT_WEB_INC_ASSIGNEE : Service: Default Web Service Request Owner
l_count := 0;
select COUNT(1) into l_count
from dual
	where exists (select profile_option_value
								from fnd_profile_option_values a,fnd_profile_options b
								where a.application_id= 170
								and a.profile_option_id = b.profile_option_id
								and b.profile_option_name='CS_DEFAULT_WEB_INC_ASSIGNEE'
								and profile_option_value=p_person_id);

if l_count>0 then
	     l_status:='E';
	     l_msg_code:='CS_PRF_DEF_WEB_SR_OWNR_EMP';
       				per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
 end if;


if l_status<>'E' then
  	l_status:='S';
        per_drt_pkg.add_to_results
           (person_id => p_person_id
           ,entity_type => 'HR'
           ,status => l_status
           ,msgcode => ''
           ,msgaplid =>170
           ,result_tbl => result_tbl);
end if;


  END cs_hr_drc;
  --
  --- Implement Core HR specific DRC for FND entity type
  --
  PROCEDURE cs_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_proc varchar2(72) := l_package|| 'cs_fnd_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
    l_result_tbl per_drt_pkg.result_tbl_type;
    l_count number;
    l_temp varchar2(20);
    l_status	varchar2(1);
    l_msg		varchar2(1000);
    l_msg_code		varchar2(100);
  BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
-- For Service we do not have to deal with FND user here as that is taken care in TCA processing
	   	l_status:='S';
	    l_msg_code:='';
            per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>170
              ,result_tbl => result_tbl);
    write_log ('Leaving: '|| l_proc,'80');
  END cs_fnd_drc;
END cs_drt_pkg;

/
