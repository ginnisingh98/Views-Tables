--------------------------------------------------------
--  DDL for Package Body PQP_NL_EXT_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_EXT_FUNCTIONS" AS
/* $Header: pqpextff.pkb 120.3 2005/10/30 21:07 vjhanak noship $ */


--cursor to fetch the subcategory for the pension type
CURSOR c_get_subcat(c_pt IN varchar2) IS
SELECT distinct(pension_sub_category)
  FROM pqp_pension_types_f
WHERE  pension_type_id = fnd_number.canonical_to_number(c_pt);

--cursor to check the enabled flag for the lookup code before logging changes
CURSOR chk_if_enabled(c_code IN VARCHAR2) IS
SELECT enabled_flag
  FROM hr_lookups
WHERE  lookup_type = 'BEN_EXT_CHG_EVT'
  AND  lookup_code = c_code;

--
-- ----------------------------------------------------------------------------
-- |-------------------< create_org_pt_ins_chg_evt >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pt_ins_chg_evt (p_organization_id         number
                                      ,p_org_information1        varchar2
                                      ,p_org_information2        varchar2
                                      ,p_org_information3        varchar2
                                      ,p_org_information6        varchar2
                                      ,p_effective_date          date
                                      ) IS

l_log_id  ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn     ben_ext_chg_evt_log.object_version_number%TYPE;
l_business_group_id ben_ext_chg_evt_log.business_group_id%TYPE;
l_sub_cat  pqp_pension_types_f.pension_sub_category%TYPE;
l_enabled varchar2(1) := 'N';

CURSOR c_get_bgid IS
SELECT business_group_id
  FROM hr_all_organization_units
WHERE  organization_id = p_organization_id;

BEGIN

  --Fetch the business group id for the ORG
  OPEN c_get_bgid;
  FETCH c_get_bgid INTO l_business_group_id;
  CLOSE c_get_bgid;

  --fetch the sub category for the pension type
  OPEN c_get_subcat(p_org_information3);
  FETCH c_get_subcat INTO l_sub_cat;
  CLOSE c_get_subcat;

  --first check if the logging of participation dates is enabled or not
  OPEN chk_if_enabled('COAPPD');
  FETCH chk_if_enabled INTO l_enabled;
  CLOSE chk_if_enabled;

  IF l_enabled = 'Y' THEN

     --Insert a row into the ben_chg_evt_log table for the current ORG for a person_id -1

     ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                         (p_ext_chg_evt_log_id    =>  l_log_id
                         ,p_chg_evt_cd            =>  'COAPPD'
                         ,p_chg_eff_dt            =>  fnd_date.canonical_to_date(p_org_information1)
                         ,p_prmtr_01              =>  'ORG'
                         ,p_prmtr_02              =>  p_org_information3
                         ,p_prmtr_03              =>  p_org_information6
                         ,p_prmtr_04              =>  p_organization_id
                         ,p_prmtr_05              =>  l_sub_cat
                         ,p_person_id             =>  -1
                         ,p_business_group_id     =>  l_business_group_id
                         ,p_object_version_number =>  l_ovn
                         ,p_effective_date        =>  fnd_date.canonical_to_date(p_org_information1)
                         ,p_new_val1              =>  p_org_information1
                         ,p_new_val2              =>  p_org_information2
                         ,p_old_val1              =>  null
                         ,p_old_val2              =>  null
                         );
END IF;
END create_org_pt_ins_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |-------------------< create_org_pt_upd_chg_evt >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pt_upd_chg_evt (p_organization_id         number
                                      ,p_org_information1        varchar2
                                      ,p_org_information2        varchar2
                                      ,p_org_information3        varchar2
                                      ,p_org_information6        varchar2
                                      ,p_org_information1_o      varchar2
                                      ,p_org_information2_o      varchar2
                                      ,p_org_information3_o      varchar2
                                      ,p_org_information6_o      varchar2
                                      ,p_effective_date          date
                                      ) IS

CURSOR c_get_chg_evt_log IS
SELECT ext_chg_evt_log_id,chg_evt_cd,chg_eff_dt,prmtr_01,
       prmtr_02,prmtr_04,prmtr_05,business_group_id,object_version_number
  FROM ben_ext_chg_evt_log
WHERE  new_val1   =   p_org_information1_o
  AND  new_val2   =   nvl(p_org_information2_o,fnd_date.date_to_canonical(hr_api.g_eot))
  AND  prmtr_01   =   'ORG'
  AND  prmtr_02   =   p_org_information3_o
  AND  prmtr_04   =   p_organization_id
  AND  chg_evt_cd =   'COAPPD';

CURSOR c_get_bgid IS
SELECT business_group_id
  FROM hr_all_organization_units
WHERE  organization_id = p_organization_id;

l_log_id    ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn       ben_ext_chg_evt_log.object_version_number%TYPE;
l_cd        ben_ext_chg_evt_log.chg_evt_cd%TYPE;
l_eff_dt    ben_ext_chg_evt_log.chg_eff_dt%TYPE;
l_prmtr1    ben_ext_chg_evt_log.prmtr_01%TYPE;
l_prmtr2    ben_ext_chg_evt_log.prmtr_02%TYPE;
l_prmtr4    ben_ext_chg_evt_log.prmtr_04%TYPE;
l_prmtr5    ben_ext_chg_evt_log.prmtr_05%TYPE;
l_bgid      ben_ext_chg_evt_log.business_group_id%TYPE;
l_sub_cat   pqp_pension_types_f.pension_sub_category%TYPE;
l_enabled varchar2(1) := 'N';

BEGIN

  -- fetch the bgid for the organization
  OPEN c_get_bgid;
  FETCH c_get_bgid INTO l_bgid;
  CLOSE c_get_bgid;

  --fetch the sub category for the pension type
  OPEN c_get_subcat(p_org_information3);
  FETCH c_get_subcat INTO l_sub_cat;
  CLOSE c_get_subcat;

  --first check if the logging of participation dates is enabled or not
  OPEN chk_if_enabled('COAPPD');
  FETCH chk_if_enabled INTO l_enabled;
  CLOSE chk_if_enabled;

  IF l_enabled = 'Y' THEN

     --Insert a row into the ben_chg_evt_log table for each of these persons
     --If the Pension Type id is not the same as the old pension type id then
     --Create a new enrollment record, by inserting a null old value for the
     --start and end dates.
     --If the pension type id is the same as the old one,then insert the old and
     -- new values for the start and end dates if a change has occured

     IF p_org_information3 <> p_org_information3_o THEN

        ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                            (p_ext_chg_evt_log_id    =>  l_log_id
                            ,p_chg_evt_cd            =>  'COAPPD'
                            ,p_chg_eff_dt            =>  fnd_date.canonical_to_date(p_org_information1)
                            ,p_prmtr_01              =>  'ORG'
                            ,p_prmtr_02              =>  p_org_information3
                            ,p_prmtr_03              =>  p_org_information6
                            ,p_prmtr_04              =>  p_organization_id
                            ,p_prmtr_05              =>  l_sub_cat
                            ,p_person_id             =>  -1
                            ,p_business_group_id     =>  l_bgid
                            ,p_object_version_number =>  l_ovn
                            ,p_effective_date        =>  fnd_date.canonical_to_date(p_org_information1)
                            ,p_new_val1              =>  p_org_information1
                            ,p_new_val2              =>  p_org_information2
                            ,p_old_val1              =>  null
                            ,p_old_val2              =>  null
                            );

        l_log_id    := null;
        l_ovn       := null;

        --for the old pension type, mark the row in the log table invalid
        OPEN c_get_chg_evt_log;
        FETCH c_get_chg_evt_log INTO l_log_id,l_cd,l_eff_dt,l_prmtr1
                                    ,l_prmtr2,l_prmtr4,l_prmtr5,l_bgid,l_ovn;
        CLOSE c_get_chg_evt_log;
        --now update the previous row to mark the validity as invalid
        ben_EXT_CHG_EVT_api.update_EXT_CHG_EVT
                            (p_ext_chg_evt_log_id    =>  l_log_id
                            ,p_chg_evt_cd            =>  l_cd
                            ,p_chg_eff_dt            =>  l_eff_dt
                            ,p_prmtr_01              =>  l_prmtr1
                            ,p_prmtr_02              =>  l_prmtr2
                            ,p_prmtr_03              =>  'N' -- mark this row as invalid
                            ,p_prmtr_04              =>  l_prmtr4
                            ,p_prmtr_05              =>  l_prmtr5
                            ,p_person_id             =>  -1
                            ,p_business_group_id     =>  l_bgid
                            ,p_object_version_number =>  l_ovn
                            ,p_effective_date        =>  fnd_date.canonical_to_date(p_org_information1)
                            );

     ELSIF (p_org_information1 <> p_org_information1_o) THEN

        --fetch the sub category for the pension type
        OPEN c_get_subcat(p_org_information3_o);
        FETCH c_get_subcat INTO l_sub_cat;
        CLOSE c_get_subcat;

        --if start date has been changed,insert a new row effective the new start date
        ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                            (p_ext_chg_evt_log_id    =>  l_log_id
                            ,p_chg_evt_cd            =>  'COAPPD'
                            ,p_chg_eff_dt            =>  fnd_date.canonical_to_date(p_org_information1)
                            ,p_prmtr_01              =>  'ORG'
                            ,p_prmtr_02              =>  p_org_information3_o
                            ,p_prmtr_03              =>  p_org_information6
                            ,p_prmtr_04              =>  p_organization_id
                            ,p_prmtr_05              =>  l_sub_cat
                            ,p_person_id             =>  -1
                            ,p_business_group_id     =>  l_bgid
                            ,p_object_version_number =>  l_ovn
                            ,p_effective_date        =>  fnd_date.canonical_to_date(p_org_information1)
                            ,p_new_val1              =>  p_org_information1
                            ,p_new_val2              =>  p_org_information2
                            ,p_old_val1              =>  p_org_information1_o
                            ,p_old_val2              =>  p_org_information2_o
                            );

   /*    l_log_id    := null;
       l_ovn       := null;

       OPEN c_get_chg_evt_log;
       FETCH c_get_chg_evt_log INTO l_log_id,l_cd,l_eff_dt,l_prmtr1
                                   ,l_prmtr2,l_prmtr4,l_bgid,l_ovn;
       CLOSE c_get_chg_evt_log;
       --now update the previous row to make it invalid
       ben_EXT_CHG_EVT_api.update_EXT_CHG_EVT
                           (p_ext_chg_evt_log_id     =>   l_log_id
                           ,p_chg_evt_cd             =>   l_cd
                           ,p_chg_eff_dt             =>   l_eff_dt
                           ,p_prmtr_01               =>   l_prmtr1
                           ,p_prmtr_02               =>   l_prmtr2
                           ,p_prmtr_03               =>   'N'
                           ,p_prmtr_04               =>   l_prmtr4
                           ,p_person_id              =>   -1
                           ,p_business_group_id      =>   l_bgid
                           ,p_object_version_number  =>   l_ovn
                           ,p_effective_date         =>   fnd_date.canonical_to_date(p_org_information1)
                           ); */

     ELSIF nvl(p_org_information2,fnd_date.date_to_canonical(hr_api.g_eot)) <>
           nvl(p_org_information2_o,fnd_date.date_to_canonical(hr_api.g_eot)) THEN

        --fetch the sub category for the pension type
        OPEN c_get_subcat(p_org_information3_o);
        FETCH c_get_subcat INTO l_sub_cat;
        CLOSE c_get_subcat;

        --if end date has been changed,insert a new row effective the effective date passed
        ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                            (p_ext_chg_evt_log_id    =>  l_log_id
                            ,p_chg_evt_cd            =>  'COAPPD'
                            ,p_chg_eff_dt            =>  p_effective_date
                            ,p_prmtr_01              =>  'ORG'
                            ,p_prmtr_02              =>  p_org_information3_o
                            ,p_prmtr_03              =>  p_org_information6
                            ,p_prmtr_04              =>  p_organization_id
                            ,p_prmtr_05              =>  l_sub_cat
                            ,p_person_id             =>  -1
                            ,p_business_group_id     =>  l_bgid
                            ,p_object_version_number =>  l_ovn
                            ,p_effective_date        =>  p_effective_date
                            ,p_new_val1              =>  p_org_information1
                            ,p_new_val2              =>  p_org_information2
                            ,p_old_val1              =>  p_org_information1_o
                            ,p_old_val2              =>  p_org_information2_o
                            );
   /*
       l_log_id    := null;
       l_ovn       := null;

       OPEN c_get_chg_evt_log;
       FETCH c_get_chg_evt_log INTO l_log_id,l_cd,l_eff_dt,l_prmtr1
                                   ,l_prmtr2,l_prmtr4,l_bgid,l_ovn;
       CLOSE c_get_chg_evt_log;
       --now update the previous row to make it invalid
       ben_EXT_CHG_EVT_api.update_EXT_CHG_EVT
                           (p_ext_chg_evt_log_id     =>   l_log_id
                           ,p_chg_evt_cd             =>   l_cd
                           ,p_chg_eff_dt             =>   l_eff_dt
                           ,p_prmtr_01               =>   l_prmtr1
                           ,p_prmtr_02               =>   l_prmtr2
                           ,p_prmtr_03               =>   'N'
                           ,p_prmtr_04               =>   l_prmtr4
                           ,p_person_id              =>   -1
                           ,p_business_group_id      =>   l_bgid
                           ,p_object_version_number  =>   l_ovn
                           ,p_effective_date         =>   p_effective_date
                           ); */

     END IF;
END IF;
END create_org_pt_upd_chg_evt;


--
-- ----------------------------------------------------------------------------
-- |------------------< create_asg_info_ins_chg_evt >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_asg_info_ins_chg_evt (p_assignment_id            IN NUMBER
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN VARCHAR2
                                      ,p_aei_information2         IN VARCHAR2
                                      ,p_aei_information3         IN VARCHAR2
                                      ,p_aei_information4         IN VARCHAR2
                                      ,p_effective_date           IN DATE
                                      ,p_abp_reporting_date       IN DATE
                                      ) IS

CURSOR c_get_person_id IS
SELECT person_id,business_group_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN effective_start_date
  AND  effective_end_date;

l_person_id          per_all_assignments_f.person_id%TYPE;
l_business_group_id  per_all_assignments_f.business_group_id%TYPE;
l_log_id             ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn                ben_ext_chg_evt_log.object_version_number%TYPE;
l_sub_cat            pqp_pension_types_f.pension_sub_category%TYPE;
l_enabled            VARCHAR2(1) := 'N';

BEGIN

--Fetch the person id from the assignment id
OPEN c_get_person_id;
FETCH c_get_person_id INTO l_person_id,l_business_group_id;
CLOSE c_get_person_id;

--find the sub category of the pension type
OPEN c_get_subcat(p_aei_information3);
FETCH c_get_subcat INTO l_sub_cat;
CLOSE c_get_subcat;

  --first check if the logging of participation dates is enabled or not
  OPEN chk_if_enabled('COAPP');
  FETCH chk_if_enabled INTO l_enabled;
  CLOSE chk_if_enabled;

  IF l_enabled = 'Y' THEN

   --Insert a row in the ben_chg_evt_log table
   ben_ext_chg_evt_api.create_ext_chg_evt
                       (p_validate               =>  true
                       ,p_ext_chg_evt_log_id     =>  l_log_id
                       ,p_chg_evt_cd             =>  'COAPP'
                       ,p_chg_eff_dt             =>  p_effective_date
                       ,p_prmtr_01               =>  l_sub_cat -- Sub cat
                       ,p_prmtr_02               =>  p_aei_information3 --PT id
                       ,p_prmtr_03               =>  fnd_number.number_to_canonical(p_assignment_extra_info_id)
                       ,p_prmtr_04               =>  p_aei_information4 -- End Reason
                       ,p_prmtr_05               =>  NULL
                       ,p_prmtr_06               =>  NULL
                       ,p_prmtr_07               =>  NULL
                       ,p_prmtr_08               =>  NULL
                       ,p_prmtr_09               =>  fnd_date.date_to_canonical(p_abp_reporting_date)
                       ,p_prmtr_10               =>  fnd_number.number_to_canonical(p_assignment_id)
                       ,p_person_id              =>  l_person_id
                       ,p_business_group_id      =>  l_business_group_id
                       ,p_object_version_number  =>  l_ovn
                       ,p_effective_date         =>  p_effective_date
                       ,p_new_val1               =>  p_aei_information1
                       ,p_new_val2               =>  p_aei_information2
                       ,p_old_val1               =>  NULL
                       ,p_old_val2               =>  NULL
                       );
   END IF;

END create_asg_info_ins_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_asg_info_upd_chg_evt >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_asg_info_upd_chg_evt (p_assignment_id            IN NUMBER
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN VARCHAR2
                                      ,p_aei_information2         IN VARCHAR2
                                      ,p_aei_information3         IN VARCHAR2
                                      ,p_aei_information4         IN VARCHAR2
                                      ,p_aei_information1_o       IN VARCHAR2
                                      ,p_aei_information2_o       IN VARCHAR2
                                      ,p_effective_date           IN DATE
                                      ,p_abp_reporting_date       IN DATE
                                      ) IS

CURSOR c_get_person_id IS
SELECT person_id,business_group_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN effective_start_date
  AND  effective_end_date;

CURSOR c_chk_log_exists (c_person_id IN NUMBER) IS
SELECT object_version_number
      ,ext_chg_evt_log_id
      ,chg_eff_dt
  FROM ben_ext_chg_evt_log
 WHERE person_id = c_person_id
   AND chg_evt_cd = 'COAPP'
   AND prmtr_03 = fnd_number.number_to_canonical(p_assignment_extra_info_id);

l_person_id           per_all_assignments_f.person_id%TYPE;
l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
l_ovn                 ben_ext_chg_evt_log.object_version_number%TYPE;
l_sub_cat             pqp_pension_types_f.pension_sub_category%TYPE;
l_enabled             VARCHAR2(1) := 'N';
l_log_xst_ovn         NUMBER;
l_xst_log_id          NUMBER;
l_xst_log_eff_dt      DATE;

BEGIN

OPEN c_get_person_id;
FETCH c_get_person_id INTO l_person_id,l_business_group_id;
CLOSE c_get_person_id;

--
-- Find the sub category of the pension type
--
OPEN c_get_subcat(p_aei_information3);
FETCH c_get_subcat INTO l_sub_cat;
CLOSE c_get_subcat;

  --
  -- First check if the logging of participation dates is enabled or not
  --
  OPEN chk_if_enabled('COAPP');
  FETCH chk_if_enabled INTO l_enabled;
  CLOSE chk_if_enabled;

  IF l_enabled = 'Y' THEN
  --
  -- Check if an existing log row can be updated with the same information
  -- Else create a new log row by calling the insert procedure
  --
  OPEN c_chk_log_exists(l_person_id);
  FETCH c_chk_log_exists INTO l_log_xst_ovn,l_xst_log_id,l_xst_log_eff_dt;

  IF c_chk_log_exists%FOUND THEN
    --
    -- Delete the existing log and create a new one
    --
    ben_ext_chg_evt_api.delete_ext_chg_evt
        (p_validate               => FALSE
        ,p_ext_chg_evt_log_id     => l_xst_log_id
        ,p_object_version_number  => l_log_xst_ovn
        ,p_effective_date         => l_xst_log_eff_dt
        );

     create_asg_info_ins_chg_evt (p_assignment_id         => p_assignment_id
                              ,p_assignment_extra_info_id => p_assignment_extra_info_id
                              ,p_aei_information1         => p_aei_information1
                              ,p_aei_information2         => p_aei_information2
                              ,p_aei_information3         => p_aei_information3
                              ,p_aei_information4         => p_aei_information4
                              ,p_effective_date           => p_effective_date
                              ,p_abp_reporting_date       => p_abp_reporting_date);

  ELSIF c_chk_log_exists%NOTFOUND THEN
  --
  -- Create a new row as we could not find an existing log to update
  --
  create_asg_info_ins_chg_evt (p_assignment_id            => p_assignment_id
                              ,p_assignment_extra_info_id => p_assignment_extra_info_id
                              ,p_aei_information1         => p_aei_information1
                              ,p_aei_information2         => p_aei_information2
                              ,p_aei_information3         => p_aei_information3
                              ,p_aei_information4         => p_aei_information4
                              ,p_effective_date           => p_effective_date
                              ,p_abp_reporting_date       => p_abp_reporting_date);

   END IF; -- check existing logs
   CLOSE c_chk_log_exists;

   END IF; -- check enabled flag

END create_asg_info_upd_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |-------------------< create_org_pp_ins_chg_evt >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pp_ins_chg_evt   (p_organization_id         number
                                      ,p_org_information1        varchar2
                                      ,p_org_information2        varchar2
                                      ,p_org_information3        varchar2
                                      ,p_effective_date          date
                                      ) IS

l_log_id  ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn     ben_ext_chg_evt_log.object_version_number%TYPE;
l_business_group_id ben_ext_chg_evt_log.business_group_id%TYPE;
l_enabled varchar2(1) := 'N';

CURSOR c_get_bgid IS
SELECT business_group_id
  FROM hr_all_organization_units
WHERE  organization_id = p_organization_id;

BEGIN

  --Fetch the business group id for the ORG
  OPEN c_get_bgid;
  FETCH c_get_bgid INTO l_business_group_id;
  CLOSE c_get_bgid;

  --first check if the logging of participation dates is enabled or not
  OPEN chk_if_enabled('COAEN');
  FETCH chk_if_enabled INTO l_enabled;
  CLOSE chk_if_enabled;

  IF l_enabled = 'Y' THEN

     --Insert a row into the ben_chg_evt_log table for the current ORG for a person_id -1

     ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                         (p_ext_chg_evt_log_id    =>  l_log_id
                         ,p_chg_evt_cd            =>  'COAEN'
                         ,p_chg_eff_dt            =>  p_effective_date
                         ,p_prmtr_01              =>  p_organization_id
                         ,p_person_id             =>  -1
                         ,p_business_group_id     =>  l_business_group_id
                         ,p_object_version_number =>  l_ovn
                         ,p_effective_date        =>  p_effective_date
                         ,p_new_val1              =>  p_org_information2
                         ,p_old_val1              =>  null
                         );
END IF;
END create_org_pp_ins_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |-------------------< create_org_pp_upd_chg_evt >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pp_upd_chg_evt (p_organization_id         number
                                      ,p_org_information1        varchar2
                                      ,p_org_information2        varchar2
                                      ,p_org_information3        varchar2
                                      ,p_org_information1_o      varchar2
                                      ,p_org_information2_o      varchar2
                                      ,p_org_information3_o      varchar2
                                      ,p_effective_date          date
                                      ) IS

CURSOR c_get_bgid IS
SELECT business_group_id
  FROM hr_all_organization_units
WHERE  organization_id = p_organization_id;

l_log_id    ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn       ben_ext_chg_evt_log.object_version_number%TYPE;
l_bgid      ben_ext_chg_evt_log.business_group_id%TYPE;
l_enabled varchar2(1) := 'N';

BEGIN

  -- fetch the bgid for the organization
  OPEN c_get_bgid;
  FETCH c_get_bgid INTO l_bgid;
  CLOSE c_get_bgid;

    --first check if the logging of participation dates is enabled or not
  OPEN chk_if_enabled('COAEN');
  FETCH chk_if_enabled INTO l_enabled;
  CLOSE chk_if_enabled;

  IF l_enabled = 'Y' THEN

     --insert a row in the log table if the registration number has changed
     IF p_org_information2 <> p_org_information2_o THEN

     ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                         (p_ext_chg_evt_log_id    =>  l_log_id
                         ,p_chg_evt_cd            =>  'COAEN'
                         ,p_chg_eff_dt            =>  p_effective_date
                         ,p_prmtr_01              =>  p_organization_id
                         ,p_person_id             =>  -1
                         ,p_business_group_id     =>  l_bgid
                         ,p_object_version_number =>  l_ovn
                         ,p_effective_date        =>  p_effective_date
                         ,p_new_val1              =>  p_org_information2
                         ,p_old_val1              =>  p_org_information2_o
                         );

     END IF;
END IF;
END create_org_pp_upd_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |------------------< create_si_info_ins_chg_evt >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_si_info_ins_chg_evt (p_assignment_id            IN number
                                      ,p_aei_information1         IN varchar2
                                      ,p_aei_information2         IN varchar2
                                      ,p_aei_information3         IN varchar2
                                      ,p_effective_date           IN date
                                      ) IS

CURSOR c_get_person_id IS
SELECT person_id,business_group_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
 AND   p_effective_date BETWEEN effective_start_date
 AND   effective_end_date;

l_person_id          per_all_assignments_f.person_id%TYPE;
l_business_group_id  per_all_assignments_f.business_group_id%TYPE;
l_log_id             ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn                ben_ext_chg_evt_log.object_version_number%TYPE;
l_enabled             varchar2(1) := 'N';

BEGIN

--Fetch the person id from the assignment id
OPEN c_get_person_id;
FETCH c_get_person_id INTO l_person_id,l_business_group_id;
CLOSE c_get_person_id;

  --first check if the logging of participation dates is enabled or not
  OPEN chk_if_enabled('COSIPD');
  FETCH chk_if_enabled INTO l_enabled;
  CLOSE chk_if_enabled;

  IF l_enabled = 'Y' THEN

      --Insert a row in the ben_chg_evt_log table
      ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                          (p_validate               =>  true
                          ,p_ext_chg_evt_log_id     =>  l_log_id
                          ,p_chg_evt_cd             =>  'COSIPD'
                          ,p_chg_eff_dt             =>  p_effective_date
                          ,p_prmtr_01               =>  fnd_number.number_to_canonical(p_assignment_id)
                          ,p_person_id              =>  l_person_id
                          ,p_business_group_id      =>  l_business_group_id
                          ,p_object_version_number  =>  l_ovn
                          ,p_effective_date         =>  p_effective_date
                          ,p_new_val1               =>  p_aei_information1
                          ,p_new_val2               =>  p_aei_information2
                          ,p_old_val1               =>  null
                          ,p_old_val2               =>  null
                          );
   END IF;
END create_si_info_ins_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_si_info_upd_chg_evt >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_si_info_upd_chg_evt (p_assignment_id               number
                                      ,p_aei_information1            varchar2
                                      ,p_aei_information2            varchar2
                                      ,p_aei_information3            varchar2
                                      ,p_aei_information1_o          varchar2
                                      ,p_aei_information2_o          varchar2
                                      ,p_aei_information3_o          varchar2
                                      ,p_effective_date              date
                                      ) IS

CURSOR c_get_person_id IS
SELECT person_id,business_group_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
 AND   p_effective_date BETWEEN effective_start_date
 AND   effective_end_date;

CURSOR c_get_chg_evt_log(c_person_id IN ben_ext_chg_evt_log.person_id%TYPE) IS
SELECT ext_chg_evt_log_id,chg_evt_cd,chg_eff_dt,prmtr_01,
       prmtr_02,business_group_id,object_version_number
  FROM ben_ext_chg_evt_log
WHERE  new_val1   =   p_aei_information1_o
  AND  new_val2   =   nvl(p_aei_information2_o,fnd_date.date_to_canonical(hr_api.g_eot))
  AND  prmtr_01   =   'ASG'
  AND  prmtr_02   =   p_aei_information3_o
  AND  person_id  =   c_person_id
  AND  chg_evt_cd =   'COSIPD';

l_person_id           per_all_assignments_f.person_id%TYPE;
l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
l_log_id              ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_cd                  ben_ext_chg_evt_log.chg_evt_cd%TYPE;
l_eff_dt              ben_ext_chg_evt_log.chg_eff_dt%TYPE;
l_prmtr1              ben_ext_chg_evt_log.prmtr_01%TYPE;
l_prmtr2              ben_ext_chg_evt_log.prmtr_02%TYPE;
l_ovn                 ben_ext_chg_evt_log.object_version_number%TYPE;
l_enabled             varchar2(1) := 'N';

BEGIN

OPEN c_get_person_id;
FETCH c_get_person_id INTO l_person_id,l_business_group_id;
CLOSE c_get_person_id;

--first check if the logging of participation dates is enabled or not
OPEN chk_if_enabled('COSIPD');
FETCH chk_if_enabled INTO l_enabled;
CLOSE chk_if_enabled;

IF l_enabled = 'Y' THEN

      IF (p_aei_information1 <> p_aei_information1_o) THEN

         ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                             (p_ext_chg_evt_log_id     =>  l_log_id
                             ,p_chg_evt_cd             =>  'COSIPD'
                             ,p_chg_eff_dt             =>  fnd_date.canonical_to_date(p_aei_information1)
                             ,p_prmtr_01               =>  fnd_number.number_to_canonical(p_assignment_id)
                             ,p_person_id              =>  l_person_id
                             ,p_business_group_id      =>  l_business_group_id
                             ,p_object_version_number  =>  l_ovn
                             ,p_effective_date         =>  fnd_date.canonical_to_date(p_aei_information1)
                             ,p_new_val1               =>  p_aei_information1
                             ,p_new_val2               =>  p_aei_information2
                             ,p_old_val1               =>  p_aei_information1_o
                             ,p_old_val2               =>  p_aei_information2_o
                             );

      ELSIF fnd_date.canonical_to_date(nvl(p_aei_information2_o,fnd_date.date_to_canonical(hr_api.g_eot))) <>
            fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot))) THEN

            ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                                (p_ext_chg_evt_log_id    =>  l_log_id
                                ,p_chg_evt_cd            =>  'COSIPD'
                                ,p_chg_eff_dt            =>  p_effective_date
                                ,p_prmtr_01              =>  fnd_number.number_to_canonical(p_assignment_id)
                                ,p_person_id             =>  l_person_id
                                ,p_business_group_id     =>  l_business_group_id
                                ,p_object_version_number =>  l_ovn
                                ,p_effective_date        =>  p_effective_date
                                ,p_new_val1              =>  p_aei_information1
                                ,p_new_val2              =>  p_aei_information2
                                ,p_old_val1              =>  p_aei_information1_o
                                ,p_old_val2              =>  p_aei_information2_o
                                );

      END IF;
  END IF;
END create_si_info_upd_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |------------------< create_sal_info_ins_chg_evt >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sal_info_ins_chg_evt (p_assignment_id            IN number
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN varchar2
                                      ,p_aei_information2         IN varchar2
                                      ,p_aei_information4         IN varchar2
                                      ,p_aei_information5         IN varchar2
                                      ,p_aei_information6         IN varchar2
                                      ,p_effective_date           IN date
                                      ,p_abp_reporting_date       IN DATE
                                      ) IS

CURSOR c_get_person_id IS
SELECT person_id,business_group_id,payroll_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN effective_start_date
  AND  effective_end_date;

--cursor to fetch the greatest date earned for the assignment
CURSOR c_get_max_date_earned IS
SELECT max(ppa.date_earned)
  FROM pay_assignment_actions paa
      ,pay_payroll_actions ppa
WHERE  paa.assignment_id = p_assignment_id
  AND  ppa.payroll_action_id = paa.payroll_action_id;

--cursor to fetch the minimum start date of the assignment
CURSOR c_get_min_asg_start IS
SELECT min(effective_start_date)
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id;

--cursor to fetch the start date of the first unprocessed
--payroll period, given the max date earned
CURSOR c_get_next_start_date(c_date_earned IN DATE
                            ,c_payroll_id  IN NUMBER) IS
SELECT start_date
  FROM per_time_periods
WHERE  payroll_id = c_payroll_id
  AND  start_date > c_date_earned
  AND  rownum = 1;

--cursor to fetch the start date of the first unprocessed
--payroll period, given the asg start date and payroll_id
CURSOR c_get_first_start_date(c_start_date IN DATE
                            ,c_payroll_id  IN NUMBER) IS
SELECT start_date
  FROM per_time_periods
WHERE  payroll_id = c_payroll_id
  AND  c_start_date BETWEEN start_date
  AND  end_date;

l_person_id          per_all_assignments_f.person_id%TYPE;
l_business_group_id  per_all_assignments_f.business_group_id%TYPE;
l_log_id             ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn                ben_ext_chg_evt_log.object_version_number%TYPE;
l_date               Date;
l_payroll_id         Number;
l_eff_date           Date;
l_enabled varchar2(1) := 'N';

BEGIN

--Fetch the person id from the assignment id
OPEN c_get_person_id;
FETCH c_get_person_id INTO l_person_id,l_business_group_id
                          ,l_payroll_id;
CLOSE c_get_person_id;

--fetch the start date of the next pay period for the assignment
--this is the effective date that will be used to log the events
--first check if any payroll has already been processed,
--if so fetch the max date earned

OPEN c_get_max_date_earned;
FETCH c_get_max_date_earned INTO l_date;
IF c_get_max_date_earned%FOUND THEN
   CLOSE c_get_max_date_earned;
   OPEN c_get_next_start_date(c_date_earned => l_date
                             ,c_payroll_id  => l_payroll_id
                             );
   FETCH c_get_next_start_date INTO l_eff_date;
   CLOSE c_get_next_start_date;
ELSE
   CLOSE c_get_max_date_earned;
   --if no payroll has been processed yet, find the
   --min asg start date and get the first pay period date

   OPEN c_get_min_asg_start;
   FETCH c_get_min_asg_start INTO l_date;
   CLOSE c_get_min_asg_start;
   OPEN c_get_first_start_date(c_start_date => l_date
                              ,c_payroll_id => l_payroll_id
                              );
   FETCH c_get_first_start_date INTO l_eff_date;
   CLOSE c_get_first_start_date;
END IF;

--first check if the logging of pension salary changes
OPEN chk_if_enabled('COAPS');
FETCH chk_if_enabled INTO l_enabled;
CLOSE chk_if_enabled;

IF l_enabled = 'Y'  THEN

   IF p_aei_information6 IS NOT NULL THEN

   --Insert a row in the ben_chg_evt_log table
   ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                       (p_validate               =>  true
                       ,p_ext_chg_evt_log_id     =>  l_log_id
                       ,p_chg_evt_cd             =>  'COAPS'
                       ,p_chg_eff_dt             =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_prmtr_01               =>  p_assignment_id
                       ,p_prmtr_02               =>  p_aei_information1
                       ,p_person_id              =>  l_person_id
                       ,p_business_group_id      =>  l_business_group_id
                       ,p_object_version_number  =>  l_ovn
                       ,p_effective_date         =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_new_val1               =>  p_aei_information6
                       ,p_old_val1               =>  null
                       );
   END IF;

   IF p_aei_information4 IS NOT NULL THEN

   -- Insert a row in the ben_chg_evt_log table
   -- to indicate that the kind of ptpn has changed.
   ben_ext_chg_evt_api.create_ext_chg_evt
                       (p_validate               =>  FALSE
                       ,p_ext_chg_evt_log_id     =>  l_log_id
                       ,p_chg_evt_cd             =>  'COAPKOP'
                       ,p_chg_eff_dt             =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_prmtr_01               =>  p_aei_information1
                       ,p_prmtr_02               =>  p_aei_information2
                       ,p_prmtr_03               =>  fnd_number.number_to_canonical(p_assignment_extra_info_id)
                       ,p_prmtr_09               =>  fnd_date.date_to_canonical(p_abp_reporting_date)
                       ,p_prmtr_10               =>  p_assignment_id
                       ,p_person_id              =>  l_person_id
                       ,p_business_group_id      =>  l_business_group_id
                       ,p_object_version_number  =>  l_ovn
                       ,p_effective_date         =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_new_val1               =>  p_aei_information4
                       ,p_old_val1               =>  NULL
                       ,p_new_val2               =>  p_aei_information5
                       ,p_old_val2               =>  NULL
                       );
   END IF;

END IF;

END create_sal_info_ins_chg_evt;

--
-- ----------------------------------------------------------------------------
-- |------------------< create_sal_info_upd_chg_evt >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sal_info_upd_chg_evt (p_assignment_id            IN number
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN varchar2
                                      ,p_aei_information2         IN varchar2
                                      ,p_aei_information4         IN varchar2
                                      ,p_aei_information5         IN varchar2
                                      ,p_aei_information6         IN varchar2
                                      ,p_aei_information1_o       IN varchar2
                                      ,p_aei_information2_o       IN varchar2
                                      ,p_aei_information4_o       IN varchar2
                                      ,p_aei_information5_o       IN varchar2
                                      ,p_aei_information6_o       IN varchar2
                                      ,p_effective_date           IN date
                                      ,p_abp_reporting_date       IN DATE
                                      ) IS

CURSOR c_get_person_id IS
SELECT person_id,business_group_id,payroll_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  p_effective_date BETWEEN effective_start_date
  AND  effective_end_date;

--cursor to fetch the greatest date earned for the assignment
CURSOR c_get_max_date_earned IS
SELECT max(ppa.date_earned)
  FROM pay_assignment_actions paa
      ,pay_payroll_actions ppa
WHERE  paa.assignment_id = p_assignment_id
  AND  ppa.payroll_action_id = paa.payroll_action_id;

--cursor to fetch the minimum start date of the assignment
CURSOR c_get_min_asg_start IS
SELECT min(effective_start_date)
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id;

--cursor to fetch the start date of the first unprocessed
--payroll period, given the max date earned
CURSOR c_get_next_start_date(c_date_earned IN DATE
                            ,c_payroll_id  IN NUMBER) IS
SELECT start_date
  FROM per_time_periods
WHERE  payroll_id = c_payroll_id
  AND  start_date > c_date_earned
  AND  rownum = 1;

--cursor to fetch the start date of the first unprocessed
--payroll period, given the asg start date and payroll_id
CURSOR c_get_first_start_date(c_start_date IN DATE
                            ,c_payroll_id  IN NUMBER) IS
SELECT start_date
  FROM per_time_periods
WHERE  payroll_id = c_payroll_id
  AND  c_start_date BETWEEN start_date
  AND  end_date;

CURSOR c_chk_log_exists (c_person_id IN NUMBER) IS
SELECT object_version_number
      ,ext_chg_evt_log_id
      ,chg_eff_dt
  FROM ben_ext_chg_evt_log
 WHERE person_id = c_person_id
   AND chg_evt_cd = 'COAPKOP'
   AND prmtr_03 = fnd_number.number_to_canonical(p_assignment_extra_info_id);

l_person_id          per_all_assignments_f.person_id%TYPE;
l_business_group_id  per_all_assignments_f.business_group_id%TYPE;
l_log_id             ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
l_ovn                ben_ext_chg_evt_log.object_version_number%TYPE;
l_date               Date;
l_payroll_id         Number;
l_eff_date           Date;
l_enabled varchar2(1) := 'N';
l_log_xst_ovn         NUMBER;
l_xst_log_id          NUMBER;
l_xst_log_eff_dt      DATE;

BEGIN

--Fetch the person id from the assignment id
OPEN c_get_person_id;
FETCH c_get_person_id INTO l_person_id,l_business_group_id
                          ,l_payroll_id;
CLOSE c_get_person_id;

--fetch the start date of the next pay period for the assignment
--this is the effective date that will be used to log the events
--first check if any payroll has already been processed,
--if so fetch the max date earned

OPEN c_get_max_date_earned;
FETCH c_get_max_date_earned INTO l_date;
IF c_get_max_date_earned%FOUND THEN
   CLOSE c_get_max_date_earned;
   OPEN c_get_next_start_date(c_date_earned => l_date
                             ,c_payroll_id  => l_payroll_id
                             );
   FETCH c_get_next_start_date INTO l_eff_date;
   CLOSE c_get_next_start_date;
ELSE
   CLOSE c_get_max_date_earned;
   --if no payroll has been processed yet, find the
   --min asg start date and get the first pay period date

   OPEN c_get_min_asg_start;
   FETCH c_get_min_asg_start INTO l_date;
   CLOSE c_get_min_asg_start;
   OPEN c_get_first_start_date(c_start_date => l_date
                              ,c_payroll_id => l_payroll_id
                              );
   FETCH c_get_first_start_date INTO l_eff_date;
   CLOSE c_get_first_start_date;
END IF;

--first check if the logging of pension salary changes
OPEN chk_if_enabled('COAPS');
FETCH chk_if_enabled INTO l_enabled;
CLOSE chk_if_enabled;

IF l_enabled = 'Y' THEN

   IF (fnd_date.canonical_to_date(p_aei_information1) <>
      fnd_date.canonical_to_date(p_aei_information1_o))
     AND p_aei_information6 IS NOT NULL THEN

   --Insert a row in the ben_chg_evt_log table
   ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                       (p_validate               =>  true
                       ,p_ext_chg_evt_log_id     =>  l_log_id
                       ,p_chg_evt_cd             =>  'COAPS'
                       ,p_chg_eff_dt             =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_prmtr_01               =>  p_assignment_id
                       ,p_prmtr_02               =>  p_aei_information1
                       ,p_person_id              =>  l_person_id
                       ,p_business_group_id      =>  l_business_group_id
                       ,p_object_version_number  =>  l_ovn
                       ,p_effective_date         =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_new_val1               =>  p_aei_information6
                       ,p_old_val1               =>  null
                       );

   ELSIF (nvl(p_aei_information6,'0') <>
          nvl(p_aei_information6_o,'0'))
     AND  p_aei_information6 IS NOT NULL THEN

   --Insert a row in the ben_chg_evt_log table
   ben_EXT_CHG_EVT_api.create_EXT_CHG_EVT
                       (p_validate               =>  true
                       ,p_ext_chg_evt_log_id     =>  l_log_id
                       ,p_chg_evt_cd             =>  'COAPS'
                       ,p_chg_eff_dt             =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_prmtr_01               =>  p_assignment_id
                       ,p_prmtr_02               =>  p_aei_information1
                       ,p_person_id              =>  l_person_id
                       ,p_business_group_id      =>  l_business_group_id
                       ,p_object_version_number  =>  l_ovn
                       ,p_effective_date         =>  nvl(l_eff_date,
                                                     fnd_date.canonical_to_date(p_aei_information1))
                       ,p_new_val1               =>  p_aei_information6
                       ,p_old_val1               =>  p_aei_information6_o
                       );

   ELSIF   (fnd_date.canonical_to_date(p_aei_information1) <>
      fnd_date.canonical_to_date(p_aei_information1_o))
     AND p_aei_information4 <> p_aei_information4_o
     OR
     (fnd_date.canonical_to_date(p_aei_information2) <>
      fnd_date.canonical_to_date(p_aei_information2_o))
     AND p_aei_information4 <> p_aei_information4_o
     OR
     (fnd_date.canonical_to_date(p_aei_information1) <>
      fnd_date.canonical_to_date(p_aei_information1_o))
     AND (fnd_date.canonical_to_date(p_aei_information2) <>
      fnd_date.canonical_to_date(p_aei_information2_o))
     AND p_aei_information4 <> p_aei_information4_o
     OR
      p_aei_information4 <> p_aei_information4_o
     OR
     (fnd_date.canonical_to_date(p_aei_information1) <>
      fnd_date.canonical_to_date(p_aei_information1_o))
     AND p_aei_information4 = p_aei_information4_o
     OR
     (fnd_date.canonical_to_date(p_aei_information2) <>
      fnd_date.canonical_to_date(p_aei_information2_o))
     AND p_aei_information4 = p_aei_information4_o
      THEN
  --
  -- Check if an existing log row can be updated with the same information
  -- Else create a new log row by calling the insert procedure
  --
  OPEN c_chk_log_exists(l_person_id);
  FETCH c_chk_log_exists INTO l_log_xst_ovn,l_xst_log_id,l_xst_log_eff_dt;

  IF c_chk_log_exists%FOUND THEN
    --
    -- Delete the existing log and create a new one
    --
    ben_ext_chg_evt_api.delete_ext_chg_evt
        (p_validate               => FALSE
        ,p_ext_chg_evt_log_id     => l_xst_log_id
        ,p_object_version_number  => l_log_xst_ovn
        ,p_effective_date         => l_xst_log_eff_dt
        );

    create_sal_info_ins_chg_evt
                 (p_assignment_id              =>   p_assignment_id
                 ,p_assignment_extra_info_id   =>   p_assignment_extra_info_id
                 ,p_aei_information1           =>   p_aei_information1
                 ,p_aei_information2           =>   p_aei_information2
                 ,p_aei_information4           =>   p_aei_information4
                 ,p_aei_information5           =>   p_aei_information5
                 ,p_aei_information6           =>   p_aei_information6
                 ,p_effective_date             =>   p_effective_date
                 ,p_abp_reporting_date         =>   p_abp_reporting_date
                     );


  ELSIF c_chk_log_exists%NOTFOUND THEN
  --
  -- Create a new row as we could not find an existing log to update
  --
     create_sal_info_ins_chg_evt
                 (p_assignment_id              =>   p_assignment_id
                 ,p_assignment_extra_info_id   =>   p_assignment_extra_info_id
                 ,p_aei_information1           =>   p_aei_information1
                 ,p_aei_information2           =>   p_aei_information2
                 ,p_aei_information4           =>   p_aei_information4
                 ,p_aei_information5           =>   p_aei_information5
                 ,p_aei_information6           =>   p_aei_information6
                 ,p_effective_date             =>   p_effective_date
                 ,p_abp_reporting_date         =>   p_abp_reporting_date
                     );

   END IF; -- check existing logs
   CLOSE c_chk_log_exists;

   END IF;

END IF;

END create_sal_info_upd_chg_evt;

END pqp_nl_ext_functions;

/
