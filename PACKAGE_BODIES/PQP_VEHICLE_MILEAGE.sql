--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_MILEAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_MILEAGE" AS
/* $Header: pqbladwr.pkb 115.5 2003/06/27 10:22:11 jcpereir noship $*/

PROCEDURE INITIALIZE_BALANCES(errbuf OUT NOCOPY VARCHAR2
                     ,retcode OUT NOCOPY NUMBER
                     ,p_business_group_id IN NUMBER
                     )
AS
-- Get the Car and Mileage Elements which have run result entries between 6-Apr-2003
-- and 5-Apr-2004
CURSOR c_ele_exst (cp_business_group_id NUMBER)
IS
SELECT element_name
      ,substr(pete.EEI_INFORMATION1,0,1) ownership
from pay_element_types_f pet,
     pay_element_type_extra_info pete
where exists (SELECT 'X'
                from pay_run_results  prr
                     ,pay_assignment_actions paa
                     ,pay_payroll_actions ppa
               WHERE prr.element_type_id=pet.element_type_id
                 AND prr.assignment_action_id=paa.assignment_action_id
                 AND paa.payroll_action_id=ppa.payroll_action_id
                AND ppa.effective_date BETWEEN TO_DATE('04/06/2003','MM/DD/YYYY')
                                           AND TO_DATE('04/05/2004','MM/DD/YYYY')
                                            )
 AND pete.element_type_id=pet.element_type_id
 AND pete.information_type='PQP_VEHICLE_MILEAGE_INFO'
 AND pete.EEI_INFORMATION_CATEGORY='PQP_VEHICLE_MILEAGE_INFO'
 AND pete.EEI_INFORMATION1 in ('C','P','PM','PP','CM','CP')
 AND pet.business_group_id =cp_business_group_id;

-- Check if given Element has a link or not
CURSOR c_get_link (cp_business_group_id NUMBER
                  ,cp_element_name    VARCHAR2
		  ,cp_ownership       VARCHAR2
                  )
IS
SELECT element_name
 FROM pay_element_types_f pet
WHERE NOT EXISTS (SELECT 'X'
                    FROM pay_element_links_f pel
                   WHERE pel.element_type_id=pet.element_type_id
                     AND pel.business_group_id=pet.business_group_id
                       )
  AND ( pet.element_name like cp_element_name||'%Addl Ele%'
  OR (pet.element_name like cp_element_name||'%Mileage Res2%'
  AND cp_ownership = 'C'))
  AND pet.business_group_id=cp_business_group_id ;

-- Get Error Info from per_all_assignments_f
CURSOR c_err_log
IS
select purt.location_name||' Needs to be linked to Assignment '
       ||paaf.assignment_number||' of Employee '||papf.full_name ERROR_LOG
       from pay_us_rpt_totals purt
           ,per_all_assignments_f paaf
           ,per_all_people_f papf
       where purt.state_name = 'CARMILEAGE_UPGRADE'
       and purt.tax_unit_id = 250
       and paaf.assignment_id = purt.location_id
       and fnd_date.canonical_to_date(purt.organization_name) between paaf.effective_start_date
       and paaf.effective_end_date
       and paaf.person_id = papf.person_id
       and fnd_date.canonical_to_date(purt.organization_name) between papf.effective_start_date
       and papf.effective_end_date;


l_ele_exst                  c_ele_exst%ROWTYPE;
l_get_link                  c_get_link%ROWTYPE;
l_element_count             NUMBER;
l_link_flag                 NUMBER:=0;
l_err_log    VARCHAR2(100);
BEGIN
 OPEN c_ele_exst (p_business_group_id);
  LOOP
   FETCH c_ele_exst INTO l_ele_exst;
   EXIT WHEn c_ele_exst%NOTFOUND;
    OPEN c_get_link (p_business_group_id
                     ,l_ele_exst.element_name
                     ,l_ele_exst.ownership);
     LOOP
      FETCH c_get_link INTO l_get_link;
      EXIT WHEN c_get_link%NOTFOUND;
      l_link_flag := 1;
       --write into Log the list of Elements for which links don't exist.
       fnd_file.put_line(fnd_file.log,'Link does not exist for ' || l_get_link.element_name );
       hr_utility.set_location('Link does not exist for ' || l_get_link.element_name,10);
     END LOOP;
    CLOSE  c_get_link;

   END LOOP;
  CLOSE c_ele_exst;

  hr_utility.set_location('Missing Links ' || l_link_flag,10);
  -- We need to check if there are any missing links
  IF l_link_flag > 0 THEN
    fnd_file.put_line(fnd_file.log,'Please Create the above Element Links and Retry.');
  ELSE
    --Call the Procedure to initialize the balances
    pqp_ini_bal.Initialize_Balances(p_business_group_id =>p_business_group_id);
    -- Write Error Messages to the Log
    OPEN c_err_log;
    LOOP
     FETCH c_err_log into l_err_log;
     EXIT WHEN c_err_log%NOTFOUND;
     fnd_file.put_line(fnd_file.log,l_err_log);
    END LOOP;
    CLOSE c_err_log;
  END IF;
END initialize_balances;
---------------------------------------------------End------------------------------------------------------------
END;


/
