--------------------------------------------------------
--  DDL for Package Body PER_SUCC_MGMT_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUCC_MGMT_MIGRATION_PKG" AS
/* $Header: pesucmgr.pkb 120.0.12010000.1 2009/05/22 20:33:44 kgowripe noship $*/
PROCEDURE   check_migration_required(p_business_group_id IN NUMBER, retcode IN OUT  NOCOPY NUMBER) IS
  CURSOR csr_chk_eit (p_bg_id NUMBER) IS
    SELECT 'Y'
    FROM    dual
    WHERE EXISTS (SELECT 'x'
                  FROM   per_people_extra_info pei,
                         per_all_people_f ppf
                  WHERE  ppf.business_group_id = p_bg_id
                  AND    ppf.person_id = pei.person_id
                  AND    pei.information_type = 'PER_SUCCESSION_PLANNING');
  l_data_exist VARCHAR2(10);
BEGIN
  IF NVL(fnd_profile.value('HR_SUCCESSION_MGMT_LICENSED'),'N') = 'N' THEN
    fnd_file.put_line(fnd_file.log,'Oracle Succession Management is not licensed. No need of running the migration program. Exiting.');
    retcode := 2;
  END IF;
  OPEN csr_chk_eit(p_business_group_id);
  FETCH csr_chk_eit INTO l_data_exist;
  IF csr_chk_eit%FOUND THEN
    fnd_file.put_line(fnd_file.log,'Data Exist in EIT PER_SUCCESSION_PLANNING. Continue with migration');
  ELSE
    fnd_file.put_line(fnd_file.log,'No data is entered in the EIT PER_SUCCESSION_PLANNING. Nothing to migrate.Exiting.');
    retcode := 1;
  END IF;
  CLOSE csr_chk_eit;
END check_migration_required;
--
--
PROCEDURE check_lookup_mappings(p_business_group_id IN NUMBER,retcode IN OUT NOCOPY NUMBER) IS
  CURSOR csr_suc_potential(p_bg_id IN NUMBER) IS
    SELECT rpad(lookup_code,30) LOOKUP_CODE, meaning
    FROM   hr_lookups h
    WHERE  lookup_type = 'PER_SUCC_PLAN_POTENTIAL'
    AND    lookup_code IN (SELECT distinct pei_information1
                           FROM   per_people_extra_info pei,
                                  per_all_people_f ppf
                           WHERE  pei.information_type = 'PER_SUCCESSION_PLANNING'
                           AND    pei.person_id = ppf.person_id
                           AND    trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
                           AND    ppf.business_group_id = p_bg_id)
    AND    lookup_code NOT IN (SELECT lookup_code
                               FROM    hr_lookups
                               WHERE  lookup_type = 'READINESS_LEVEL'
                               AND    enabled_flag = 'Y'
                               AND    trunc(sysdate) BETWEEN nvl(start_date_active,trunc(sysdate)) AND NVL(end_date_active,trunc(sysdate)) );
  CURSOR csr_risk_of_loss(p_bg_id IN NUMBER) IS
    SELECT rpad(lookup_code,30) LOOKUP_CODE, meaning
    FROM   hr_lookups h
    WHERE  lookup_type = 'PER_SUCC_PLAN_RISK_LEVEL'
    AND    lookup_code IN (SELECT distinct pei_information2
                           FROM   per_people_extra_info pei,
                                  per_all_people_f ppf
                           WHERE  pei.information_type = 'PER_SUCCESSION_PLANNING'
                           AND    pei.person_id = ppf.person_id
                           AND    trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
                           AND    ppf.business_group_id = p_bg_id)
    AND    lookup_code NOT IN (SELECT lookup_code
                               FROM    hr_lookups
                               WHERE  lookup_type = 'PER_RETENTION_POTENTIAL'
                               AND    enabled_flag = 'Y'
                               AND    trunc(sysdate) BETWEEN nvl(start_date_active,trunc(sysdate)) AND NVL(end_date_active,trunc(sysdate)) );
 counter NUMBER;
BEGIN
   counter := 0;
   retcode := 0;
   FOR i IN csr_suc_potential(p_business_group_id)
   LOOP
     retcode := 1;
     IF counter = 0 THEN
       fnd_file.put_line(fnd_file.log,'Lookup codes not mapped from PER_SUCC_PLAN_POTENTIAL to READINESS_LEVEL are listed below.');
       fnd_file.put_line(fnd_file.log,'-----------------------------------------------------------------------------------------');
     END IF;
     fnd_file.put_line(fnd_file.log, i.lookup_code||'-'||i.meaning);
     counter := counter +1;
   END LOOP;
   fnd_file.put_line(fnd_file.log,'-----------------------------------------------------------------------------------------');
   counter := 0;
   FOR i IN csr_risk_of_loss(p_business_group_id)
   LOOP
     retcode := 1;
     IF counter = 0 THEN
       fnd_file.put_line(fnd_file.log,'Lookup codes not mapped from PER_SUCC_PLAN_RISK_LEVEL to PER_RETENTION_POTENTIAL are listed below.');
       fnd_file.put_line(fnd_file.log,'-----------------------------------------------------------------------------------------');
     END IF;
     fnd_file.put_line(fnd_file.log, i.lookup_code||'-'||i.meaning);
     counter := counter +1;
   END LOOP;
   fnd_file.put_line(fnd_file.log,'-----------------------------------------------------------------------------------------');
END check_lookup_mappings;
--
--
PROCEDURE migrate_lookup_data(p_business_group_id IN NUMBER) IS
 CURSOR csr_old_eit(p_bg_id IN NUMBER) IS
  SELECT pei.person_id
        ,pei.person_extra_info_id
        ,pei_information3 --- key person
        ,pei_information1 --- potential
        ,pei_information2 --- risk of loss
  FROM  per_people_extra_info pei
       ,per_all_people_f ppf
  WHERE ppf.business_group_id = p_bg_id
  AND    trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
  AND   ppf.person_id = pei.person_id
  AND   pei.information_type = 'PER_SUCCESSION_PLANNING'
  AND   NOT EXISTS (SELECT 'x'
                    FROM   per_people_extra_info new
                    WHERE  new.information_type = 'PER_SUCCESSION_MGMT_INFO'
                    AND    new.person_id = pei.person_id
                    AND    new.pei_information7 = (-1*pei.person_extra_info_id));
  l_ovn NUMBER;
  l_person_extra_info_id NUMBER;
BEGIN
  FOR i IN csr_old_eit(p_business_group_id)
  LOOP
      l_person_extra_info_id := NULL;
      l_ovn := NULL;
	hr_person_extra_info_api.create_person_extra_info
	  (p_person_id                => i.person_id
	  ,p_information_type         => 'PER_SUCCESSION_MGMT_INFO'
	  ,p_pei_information_category => 'PER_SUCCESSION_MGMT_INFO'
	  ,p_pei_information1         => i.pei_information1
	  ,p_pei_information4         => i.pei_information2
	  ,p_pei_information3         => i.pei_information3
	  ,p_pei_information7         => (-1*i.person_extra_info_id)
	  ,p_person_extra_info_id     => l_person_extra_info_id
	  ,p_object_version_number    => l_ovn);
  END LOOP;
EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log,'Error while migrating the data to new EIT Structure');
  rollback;
  RAISE;
END migrate_lookup_data;
--
PROCEDURE migrate_succ_plan_eit(errbuf                      out  nocopy varchar2
                               ,retcode                     out  nocopy number
                               ,p_business_group_id         IN NUMBER ) IS
BEGIN
  retcode := 0;
  check_migration_required(p_business_group_id,retcode);
  IF retcode = 0 THEN
     check_lookup_mappings(p_business_group_id,retcode);
  END IF;
  IF retcode = 0 THEN
     migrate_lookup_data(p_business_group_id);
  END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
     Rollback;
     retcode := 2;
     fnd_file.put_line(fnd_file.log,'Error while completing the migation of EIT Data for Succession Management');
     fnd_file.put_line(fnd_file.log,'ERROR: '||SQLERRM);
END migrate_succ_plan_eit;
END per_succ_mgmt_migration_pkg;

/
