--------------------------------------------------------
--  DDL for Package Body PAY_FR_DADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_DADS_PKG" as
/* $Header: pyfrdads.pkb 120.1 2006/03/16 10:31 aparkes noship $ */
--
-- Globals
--
g_package    CONSTANT VARCHAR2(20):= 'pay_fr_dads_pkg.';
--
g_cache_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
g_param_issuing_estab_id  hr_organization_information.organization_id%TYPE;
g_param_company_id        hr_organization_information.organization_id%TYPE;
g_param_estab_id          hr_organization_information.organization_id%TYPE;
g_param_business_group_id per_business_Groups.business_group_id%TYPE;
g_param_reference         varchar2(50);
g_param_start_date        date;
g_param_effective_date    date;
--
--
g_cre_info_issue pay_fr_dads_estab_comp.g_cre_info_issue%TYPE;
--
-------------------------------------------------------------------------------
-- ARCHIVE HOOK POINTS
--
-------------------------------------------------------------------------------
-- RANGE CURSOR
-- DESCRIPTION : Single threaded.
--               Returns the Range Cursor String
-------------------------------------------------------------------------------
procedure range_cursor (
          pactid                       in number
         ,sqlstr                       out nocopy varchar) is
  BAD EXCEPTION;
  l_text                    fnd_lookup_values.meaning%TYPE;
  l_proc VARCHAR2(40) :=    g_package||' range_cursor ';
BEGIN
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Get the legislative parameters used in the call to prove the seed data
  -- retrict the list of addresses
  --
  hr_utility.set_location('Step ' || l_proc,20);
  --
  -- Return the select string
  --
  sqlstr := 'SELECT DISTINCT person_id
             FROM  per_people_f ppf
                  ,pay_payroll_actions ppa
             WHERE ppa.payroll_action_id = :payroll_action_id
               AND ppa.business_group_id = ppf.business_group_id
          ORDER BY ppf.person_id';
  --
  hr_utility.set_location('Leaving:  '||l_proc,50);
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(' Leaving with EXCEPTION: '||l_proc,50);
      -- Return cursor that selects no rows
      sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
END range_cursor;
-------------------------------------------------------------------------------
-- ACTION CREATION --
-- DESCRIPTION :      Creates new assignment actions under the (archive)
--                    payroll action
-------------------------------------------------------------------------------
PROCEDURE action_creation  (pactid    IN NUMBER,
                            stperson  IN NUMBER,
                            endperson IN NUMBER,
                            chunk     IN NUMBER) IS
--
l_proc VARCHAR2(60):= g_package||' action_creation ';
--
  cursor csr_qualifying_assignments is
    select /*+leading(asg_run) index(asg_run PER_ASSIGNMENTS_F_N12)
              index(org_est HR_ORGANIZATION_INFORMATIO_FK2)
              index(org_coy HR_ORGANIZATION_INFORMATIO_FK2) */
             ppa_run.payroll_id, asg_run.assignment_id,
             max(nvl(paa_run.source_action_id
                    ,paa_run.assignment_action_id))               mst_action_id
      from   pay_assignment_Actions paa_run
            ,pay_payroll_actions    ppa_run
            ,per_all_assignments_f  asg_run
            ,hr_organization_information org_est
            ,hr_organization_information org_coy
    where    ppa_run.business_group_id = asg_run.business_group_id
      and    asg_run.business_group_id = g_param_business_group_id
      and    ppa_run.payroll_action_id = paa_run.payroll_Action_id
      and    ppa_run.action_type in     ('R','Q')
      and    ppa_run.action_status     = 'C'
      and    paa_run.action_status     = 'C'
      and    ppa_run.effective_Date between g_param_start_date
                                        and g_param_effective_date
      and    paa_run.assignment_id     = asg_run.assignment_id
      and    ppa_run.effective_date BETWEEN asg_run.effective_start_date
                                        AND asg_run.effective_end_date
      and    asg_run.person_id      BETWEEN stperson
                                        AND endperson
      and   (paa_run.source_action_id is null or paa_run.end_date is not null)
      /* the estab parameter condition is met */
      and    paa_run.tax_unit_id   = nvl(g_param_estab_id, paa_run.tax_unit_id)
      /* the company parameter condition is met */
      and    org_est.organization_id = paa_run.tax_unit_id
      and    org_est.org_information_context = 'FR_ESTAB_INFO'
      and    org_coy.organization_id+0 = nvl(g_param_company_id /*comp param*/
                                            ,org_coy.organization_id)
     /* the estab's coy has the parameterized issueing estab */
      and    org_est.org_information1 = org_coy.organization_id
      and    org_coy.org_information_context = 'FR_COMP_INFO'
      and    org_coy.org_information4 = g_param_issuing_estab_id
    group by ppa_run.payroll_id, asg_run.assignment_id;

  --
  l_qualify_asg_rec csr_qualifying_assignments%ROWTYPE;
  --
  l_actid pay_assignment_actions.assignment_action_id%TYPE;
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc,20);
  --
  if g_cache_payroll_action_id is null
  or g_cache_payroll_action_id <> pactid then
    pay_fr_dads_pkg.get_all_parameters (
                 p_payroll_action_id => pactid
                ,p_issuing_estab_id  => g_param_issuing_estab_id
                ,p_company_id        => g_param_company_id
                ,p_estab_id          => g_param_estab_id
                ,p_business_Group_id => g_param_business_group_id
                ,p_reference         => g_param_reference
                ,p_start_date        => g_param_start_date
                ,p_effective_date    => g_param_effective_date);
    g_cache_payroll_action_id := pactid;
  end if;
  --
  --
  -- get any qualifying assignments
  --
  open csr_qualifying_assignments;
  LOOP
    fetch csr_qualifying_assignments into l_qualify_asg_rec;
    EXIT WHEN csr_qualifying_assignments%NOTFOUND;
    --
    -- get the latest master action in the period and lock it
    --
    -- create a new action and lock the fetched one
    --
    SELECT pay_assignment_actions_s.NEXTVAL
      INTO l_actid
      FROM dual;
    --
    hr_nonrun_asact.insact(l_actid
                           ,l_qualify_asg_rec.assignment_id
                           ,pactid
                           ,chunk);
    --
    hr_nonrun_asact.insint(
             lockingactid => l_actid
            ,lockedactid  => l_qualify_asg_rec.mst_action_id);
    --
  END LOOP;

  --
  hr_utility.set_location('Leaving ' || l_proc, 100);
END action_creation;
-------------------------------------------------------------------------------
-- ARCHIVE_INIT --
-- DESCRIPTION :                    Caches the SRS Parameters
-------------------------------------------------------------------------------
procedure archive_init(
          p_payroll_action_id        in number) is
  --
  l_proc VARCHAR2(40):= g_package||' archinit ';
BEGIN
  --
  hr_utility.set_location('Entering ' || l_proc, 10);
  if g_cache_payroll_action_id is null
  or g_cache_payroll_action_id <> p_payroll_action_id then
    pay_fr_dads_pkg.get_all_parameters (
                   p_payroll_action_id => p_payroll_action_id
                  ,p_issuing_estab_id  => g_param_issuing_estab_id
                  ,p_company_id        => g_param_company_id
                  ,p_estab_id          => g_param_estab_id
                  ,p_business_Group_id => g_param_business_group_id
                  ,p_reference         => g_param_reference
                  ,p_start_date        => g_param_start_date
                  ,p_effective_date    => g_param_effective_date);
    g_cache_payroll_action_id := p_payroll_action_id;
  end if;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  --
END;
-------------------------------------------------------------------------------
-- ARCHIVE CODE
-- DESCRIPTION : Main routine for storing data against the assignment actions.
-------------------------------------------------------------------------------
procedure archive_code(
          p_assactid                 in number
         ,p_effective_date           in date) is
  --
  l_proc     VARCHAR2(40):= g_package||' Archive code ';
  --
  -- Cursor for getting companies
  -- for the selected issuing establishment
  cursor get_compid_cur is
  select distinct hoi.organization_id organization_id
  from hr_organization_information hoi,
       hr_organization_information hoi_issue
  where hoi.org_information_context = 'CLASS'
  and hoi.org_information1 = 'FR_SOCIETE'
  and hoi_issue.organization_id = hoi.organization_id
  and hoi_issue.org_information_context = 'FR_COMP_INFO'
  and hoi_issue.org_information4 = g_param_issuing_estab_id;
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);

    IF g_param_company_id IS NULL THEN
       for get_compid_rec in get_compid_cur loop
          -- Call procedure for retrieving S30 data
           hr_utility.set_location('Calling S30 p_assact_id:'||p_assactid,101);
           PAY_FR_DADS_EMP_PKG.execS30_G01_00(
                         p_assact_id =>p_assactid
                        ,p_issuing_estab_id => g_param_issuing_estab_id
                        ,p_org_id =>get_compid_rec.organization_id
                        ,p_estab_id =>g_param_estab_id
                        ,p_business_Group_id => g_param_business_group_id
                        ,p_reference => g_param_reference
                        ,p_start_date => g_param_start_date
                        ,p_effective_date => g_param_effective_date);
       end loop;
    ELSE
          hr_utility.set_location('Calling S30-COmp p_assact_id:'||p_assactid,101);
           PAY_FR_DADS_EMP_PKG.execS30_G01_00(
                         p_assact_id =>p_assactid
                        ,p_issuing_estab_id => g_param_issuing_estab_id
                        ,p_org_id =>g_param_company_id
                        ,p_estab_id =>g_param_estab_id
                        ,p_business_Group_id => g_param_business_group_id
                        ,p_reference => g_param_reference
                        ,p_start_date => g_param_start_date
                        ,p_effective_date => g_param_effective_date);

    END IF;

  hr_utility.set_location('Leaving ' || l_proc, 100);
  --
END Archive_Code;

-------------------------------------------------------------------------------
-- GET_PARAMETER                   used in sql to decode legislative parameters
--                                 copied from uk code.
-------------------------------------------------------------------------------
function get_parameter(
         p_parameter_string in varchar2
        ,p_token            in varchar2
        ,p_segment_number   in number default null )    RETURN varchar2
IS
  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
  l_start_pos  NUMBER;
  l_delimiter  varchar2(1):=' ';
  l_proc VARCHAR2(40):= g_package||' get parameter ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 20);
  l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  end if;
  IF l_start_pos <> 0 THEN
    l_start_pos := l_start_pos + length(p_token||'=');
    l_parameter := substr(p_parameter_string,
                          l_start_pos,
                          instr(p_parameter_string||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
    IF p_segment_number IS NOT NULL THEN
      l_parameter := ':'||l_parameter||':';
      l_parameter := substr(l_parameter,
                            instr(l_parameter,':',1,p_segment_number)+1,
                            instr(l_parameter,':',1,p_segment_number+1) -1
                            - instr(l_parameter,':',1,p_segment_number));
    END IF;
  END IF;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  RETURN l_parameter;
END get_parameter;
-------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS                gets all parameters for the payroll action
-------------------------------------------------------------------------------
procedure get_all_parameters (
          p_payroll_action_id                    in number
         ,p_issuing_estab_id                     out nocopy number
         ,p_company_id                           out nocopy number
         ,p_estab_id                             out nocopy number
         ,p_business_group_id                    out nocopy number
         ,p_reference                            out nocopy varchar2
         ,p_start_date                           out nocopy date
         ,p_effective_date                       out nocopy date) is
  --
  cursor   csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT   pay_fr_dads_pkg.get_parameter(legislative_parameters, 'ISSUING_ESTAB_ID')
          ,pay_fr_dads_pkg.get_parameter(legislative_parameters, 'COMPANY_ID')
          ,pay_fr_dads_pkg.get_parameter(legislative_parameters, 'ESTAB_ID')
          ,business_group_id
          ,pay_fr_dads_pkg.get_parameter(legislative_parameters, 'REFERENCE')
          ,start_date
          ,effective_date
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  l_proc VARCHAR2(40):= g_package||' get_all_parameters ';

BEGIN
  hr_utility.set_location('Entering ' || l_proc, 20);
  open csr_parameter_info (p_payroll_action_id);
  fetch csr_parameter_info into p_issuing_estab_id, p_company_id, p_estab_id
                               ,p_business_group_id, p_reference, p_start_date
                               ,p_effective_date;
  close csr_parameter_info;

  hr_utility.set_location('Leaving ' || l_proc, 100);
END;
-------------------------------------------------------------------------------
-- DEINITIALIZE
-- DESCRIPTION : Called once per payroll action;
-------------------------------------------------------------------------------
PROCEDURE deinitialize_code(p_payroll_action_id    in number) is
  --
  l_proc VARCHAR2(40) :=    g_package||' deinitialize ';
  --
  -- Cursor for getting companies
  -- for the selected issuing establishment
  cursor S20 is
  select distinct hoi.organization_id
  from hr_organization_information hoi,
       hr_organization_information hoi_issue
  where hoi.org_information_context ||'' = 'CLASS'
  and hoi.org_information1 = 'FR_SOCIETE'
  and hoi_issue.organization_id =hoi.organization_id
  and hoi_issue.org_information_context = 'FR_COMP_INFO'
  and hoi_issue.org_information4 = g_param_issuing_estab_id;
  --
  -- Cursor for getting establishment ids
  -- from archived assignments
  cursor S80 is
  select distinct pacinfo.action_information7 estab_id
  from pay_action_information      pacinfo,
       pay_assignment_actions      pasac
  where pacinfo.action_context_id = pasac.assignment_action_id
    and pasac.payroll_action_id = p_payroll_action_id
    and pacinfo.action_information_category = 'FR_DADS_FILE_DATA'
    and pacinfo.action_information1 = 'S41.G01.00.005';
   --
--
BEGIN
  if g_cache_payroll_action_id is null
  or g_cache_payroll_action_id <> p_payroll_action_id then
    pay_fr_dads_pkg.get_all_parameters (
                 p_payroll_action_id => p_payroll_action_id
                ,p_issuing_estab_id  => g_param_issuing_estab_id
                ,p_company_id        => g_param_company_id
                ,p_estab_id          => g_param_estab_id
                ,p_business_Group_id => g_param_business_group_id
                ,p_reference         => g_param_reference
                ,p_start_date        => g_param_start_date
                ,p_effective_date    => g_param_effective_date);
    g_cache_payroll_action_id := p_payroll_action_id;
  end if;
  --
  -- Retrieve S10 (issuing establishment) data
    pay_fr_dads_estab_comp.S10_00_issue_estab(
               P_PARAM_REFERENCE         => g_param_reference,
               P_PARAM_ISSUING_ESTAB_ID  => g_param_issuing_estab_id,
               P_PARAM_BUSINESS_GROUP_ID => g_param_business_group_id,
               P_PAYROLL_ACTION_ID       => p_payroll_action_id,
               P_CRE_INFO_ISSUE          => g_cre_info_issue);
    --
    pay_fr_dads_estab_comp.S10_01_issue_person(
               P_ISSUING_ESTAB_ID  => g_param_issuing_estab_id,
               P_PAYROLL_ACTION_ID => p_payroll_action_id);
    --
    IF g_param_company_id IS NULL THEN
       for s20_comp_rec in S20 loop
          -- Call procedure for retrieving S20 data
          pay_fr_dads_estab_comp.S20_comp_info(
               P_COMPANY_ID        => s20_comp_rec.organization_id,
               P_CRE_INFO_ISSUE    => g_cre_info_issue,
               P_DADS_START_DATE   => g_param_start_date,
               P_DADS_END_DATE     => g_param_effective_date,
               P_PAYROLL_ACTION_ID => p_payroll_action_id);
       end loop;
    ELSE
       pay_fr_dads_estab_comp.S20_comp_info(
               P_COMPANY_ID        => g_param_company_id,
               P_CRE_INFO_ISSUE    => g_cre_info_issue,
               P_DADS_START_DATE   => g_param_start_date,
               P_DADS_END_DATE     => g_param_effective_date,
               P_PAYROLL_ACTION_ID => p_payroll_action_id);
    END IF;
    --
    for estab_rec in S80 loop
       pay_fr_dads_estab_comp.S80_insee_estab(
               P_ESTAB_ID          => estab_rec.estab_id,
               P_PAYROLL_ACTION_ID => p_payroll_action_id,
               P_DADS_END_DATE     => g_param_effective_date);
    end loop;
    --
  --
end deinitialize_code;
--
END pay_fr_dads_pkg;

/
