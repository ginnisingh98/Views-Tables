--------------------------------------------------------
--  DDL for Package Body PQH_SS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SS_UTILITY" as
/* $Header: pqutlswi.pkb 120.1.12010000.6 2010/05/07 10:45:38 gpurohit ship $*/
--
CURSOR cur_asgn (c_assignmentId NUMBER, c_effectiveDate DATE) IS
SELECT to_char(object_version_number), effective_start_date
FROM   per_all_assignments_f
WHERE  assignment_id        = c_assignmentId
AND    c_effectiveDate BETWEEN effective_start_date AND effective_end_date;

procedure get_rg_eligibility(p_person_id in number,
                            p_rptg_grp_id in number,
                            p_eligibility_flag out nocopy varchar2,
                            p_eligibility out nocopy varchar2) is
--
--
l_dummy0 varchar2(10);
l_dummy1 varchar2(10);
l_dummy2 varchar2(10);
l_bus_grp number;
--
cursor c_bus_grp_id(p_person_id number) is
select business_group_id
from per_all_people_f
where person_id = p_person_id;
--
cursor c_run(p_person_id number, p_rptg_grp_id number,
             p_business_group_id number) is
select 'x'
from BEN_POPL_RPTG_GRP_F prg
where rptg_grp_id = p_rptg_grp_id
and business_group_id = p_business_group_id
and prg.pgm_id is null
and sysdate between prg.effective_start_date and prg.effective_end_date;
--
cursor c_eligible(p_person_id number, p_rptg_grp_id number) is
select 'x'
from dual
where exists
(select eper.pl_id
from BEN_POPL_RPTG_GRP_F prg, ben_elig_per_f eper
where rptg_grp_id = p_rptg_grp_id
and person_id = p_person_id
and prg.pl_id = eper.pl_id
and eper.pgm_id is null
and sysdate between prg.effective_start_date and prg.effective_end_date
and sysdate between eper.effective_start_date and eper.effective_end_date
and eper.elig_flag = 'Y'
);
--
cursor c_ineligible(p_person_id number, p_rptg_grp_id number) is
select 'x'
from dual
where exists
(select eper.pl_id
from BEN_POPL_RPTG_GRP_F prg, ben_elig_per_f eper
where rptg_grp_id = p_rptg_grp_id
and person_id = p_person_id
and prg.pl_id = eper.pl_id
and eper.pgm_id is null
and sysdate between prg.effective_start_date and prg.effective_end_date
and sysdate between eper.effective_start_date and eper.effective_end_date
and eper.elig_flag = 'N'
);
--
begin
  --
  if p_rptg_grp_id is null then
    p_eligibility_flag := 'Y';
  else
    --
    open c_bus_grp_id(p_person_id);
    fetch c_bus_grp_id into l_bus_grp;
    close c_bus_grp_id;
    --
    open c_run(p_person_id, p_rptg_grp_id,l_bus_grp);
    fetch c_run into l_dummy0;
    --
    if c_run%notfound then
      close c_run;
      p_eligibility_flag := 'Y';
    else
      --
      close c_run;
      --
      open c_eligible(p_person_id, p_rptg_grp_id);
      fetch c_eligible into l_dummy1;
      --
      if c_eligible%found then
        close c_eligible;
        p_eligibility_flag := 'Y';
      else
        close c_eligible;
        open c_ineligible(p_person_id, p_rptg_grp_id);
        fetch c_ineligible into l_dummy2;
        if c_ineligible%found then
          p_eligibility_flag := 'N';
        end if;
        close c_ineligible;
      end if;
      --
    end if;
    --
  end if;
  --
  if p_eligibility_flag = 'Y' then
    p_eligibility := hr_general.decode_lookup('YES_NO', 'Y');
  elsif p_eligibility_flag = 'N' then
    p_eligibility := hr_general.decode_lookup('YES_NO', 'N');
  else
    p_eligibility_flag := null;
    p_eligibility := null;
  end if;
  --
end;
--
--
function get_Reporting_Group_id(
               p_function_name varchar2,
               p_business_group_id number) return number is
--
cursor c1(p_function_name varchar2,p_business_group_id varchar2) is
select rptg_grp_id
from ben_rptg_grp
where function_code = p_function_name
and rptg_prps_cd = 'PERACT'
and nvl(business_group_id, p_business_group_id) = p_business_group_id
order by business_group_id;
--
l_reporting_group_id number;
--
begin
--
 open c1(p_function_name, p_business_group_id);
 fetch c1 into l_reporting_group_id;
 close c1;
 --
 return l_reporting_group_id;
end;
--
--
function check_eligibility(
               p_person_id number,
               p_rptg_grp_id number) return boolean is
--
cursor c1(p_person_id number, p_rptg_grp_id number) is
select 'x'
from dual
where exists
(select eper.pl_id
from BEN_POPL_RPTG_GRP prg, ben_elig_per_f eper
where rptg_grp_id = p_rptg_grp_id
and person_id = p_person_id
and prg.pl_id = eper.pl_id
and eper.pgm_id is null
and sysdate between prg.effective_start_date and prg.effective_end_date
and sysdate between eper.effective_start_date and eper.effective_end_date
and eper.elig_flag = 'Y'
);
--
l_dummy varchar2(10);
--
begin
--
 open c1(p_person_id, p_rptg_grp_id);
 fetch c1 into l_dummy;
 if c1%found then close c1; return true; end if;
 close c1;
--
 return false;
--
end;
--
--
--
FUNCTION get_pos_structure_version
   ( p_business_group_id number)
   RETURN  number is
--
 l_pos_structure_version_id number;
 --
 cursor c_pos_struct_ver(p_business_group_id number) is
 select ver.pos_structure_version_id
 from per_position_structures str, per_pos_structure_versions ver
 where str.position_structure_id = ver.position_structure_id
 and sysdate between ver.date_from and nvl(ver.date_to, hr_general.end_of_time)
 and str.primary_position_flag = 'Y'
 and str.business_group_id = p_business_group_id;
 --
 BEGIN
   open c_pos_struct_ver(p_business_group_id);
   fetch c_pos_struct_ver into l_pos_structure_version_id;
   close c_pos_struct_ver;
   --
   return l_pos_structure_version_id;
   --
END;
--
--
PROCEDURE get_Role_Info (
        p_roleTypeCd       IN VARCHAR2
       ,p_businessGroupId  IN NUMBER
       ,p_globalRoleFlag  OUT NOCOPY VARCHAR2
       ,p_roleName        OUT NOCOPY VARCHAR2
       ,p_roleId          OUT NOCOPY NUMBER ) IS
--
--
CURSOR cur_role IS
SELECT decode(business_group_id,null,'Y','N') global_role, role_name, role_id
FROM   pqh_roles
WHERE  role_type_cd      = p_roleTypeCd
AND    enable_flag       = 'Y'
AND  ( business_group_id = p_businessGroupId OR  business_group_id IS NULL);
--
--
BEGIN
--
--
   OPEN  cur_role;
   FETCH cur_role INTO p_globalRoleFlag, p_roleName, p_roleId;
   CLOSE cur_role;
--
--
END;
--
--
function  check_edit_privilege (
        p_personId        IN NUMBER
       ,p_businessGroupId IN NUMBER ) return VARCHAR2 is
l_editAllowed varchar2(10) := 'N';
begin
pqh_ss_utility.check_edit_privilege (
        p_personId        =>p_personId
       ,p_businessGroupId =>p_businessGroupId
       ,p_editAllowed     =>l_editAllowed );
return l_editAllowed;
end;
--
 /* ****************************************************************** */
  --
  -- Check edit privilege
  -- This procedure first checks if the Editable by approver
  -- exclusion role is defined, if so, it then checks if the
  -- Person is added to the exclusion role. If yes, the procedure
  -- returns p_editAllowed as N
  -- If either the exclusion role is not defined or the person is
  -- not in the list, it then checks if the inclusion role is defined
  -- if defined, it checks for the person in the list of that role
  -- If person is found, it returns editAllowed as Y else returns
  -- editAllowed as N.
  -- If the inclusion role is not defined editAllowed=Y.
  --
  -- In general if both exclusion d roles are not defined
  --     Person has the privilege to edit
  -- If the person is added to both exclusion role and inclusion role
  --     person does not have the privilege, exclusion role takes the precedence.
  -- if both roles are defined but person is not in either of the list,
  --     person does not have the privlege.
  -- if person is found in exactly one list (either inclusion or exclusion)
  --     person will (or will not) have the privilege to edit depending on the list
  --     he/she is included.
  -- If only exclusion list is defined, and the person is not in that list,
  --     person will have edit privilege
  -- If only inclusion list is defined, and the person is not in the list,
  --     person will not have edit privilege.
/* ****************************************************************************** */
PROCEDURE  check_edit_privilege (
        p_personId        IN NUMBER
       ,p_businessGroupId IN NUMBER
       ,p_editAllowed    OUT NOCOPY VARCHAR2 ) IS
--
--
l_roleId   NUMBER;
l_roleName  PQH_ROLES.role_name%TYPE;
l_flag      VARCHAR2(10);
dummy       VARCHAR2(1);
--
--
CURSOR cur_role (p_role_type_cd VARCHAR2) IS
SELECT role_id
FROM   pqh_roles
WHERE  role_type_cd      = p_role_type_cd
AND    enable_flag       = 'Y'
AND  ( business_group_id = p_businessGroupId OR  business_group_id IS NULL);  -- either cross business_group or the bg of logged user
--
--
CURSOR cur_edit (p_roleId NUMBER) IS
SELECT 'X'
from  per_people_extra_info pei , pqh_roles rls
WHERE information_type              = 'PQH_ROLE_USERS'
 and  rls.role_id                   = to_number(pei.pei_information3)
 and  nvl(pei.pei_information5,'Y') ='Y'
 and  rls.role_id                   = p_roleId
 and  pei.person_id                 = p_personId;
--
--
BEGIN
   --Check if exclusion role is defined.
    get_Role_Info (
        p_roleTypeCd       => 'PQH_EXCL'
       ,p_businessGroupId  => p_businessGroupId
       ,p_globalRoleFlag   => l_flag
       ,p_roleName         => l_roleName
       ,p_roleId           => l_roleId  );
   --
   --If defined, check if the person is added to the exclusion role
   IF ( l_roleId IS NOT NULL) THEN
      OPEN  cur_edit(l_roleId);
      FETCH cur_edit INTO dummy;
      CLOSE cur_edit;
   --If found then edit not allowed, no further check needed, return.
     IF (dummy = 'X')  THEN
        p_editAllowed := 'N';
        return;
     END IF;
   END IF;
   --
   --If exclusion rule is not defined, or the person is not included in the exclusion role then
   --check if inclusion rule is defined.
    get_Role_Info (
        p_roleTypeCd       => 'PQH_INCL'
       ,p_businessGroupId  => p_businessGroupId
       ,p_globalRoleFlag   => l_flag
       ,p_roleName         => l_roleName
       ,p_roleId           => l_roleId  );
      --If defined, check if the person is included in the inclusion role.
   IF ( l_roleId IS NOT NULL) THEN
         OPEN  cur_edit(l_roleId);
         FETCH cur_edit INTO dummy;
         CLOSE cur_edit;
         --If found then the person is allowed to edit the transaction.
         IF ( dummy = 'X' ) THEN
            p_editAllowed := 'Y';
         --If not found then the person is not allowed to edit.
         ELSE
            p_editAllowed := 'N';
         END IF;
   -- If Not defined, person is eligile to edit the transaction
   ELSE
            p_editAllowed := 'Y';
   END IF;
END  check_edit_privilege;
--
--
PROCEDURE check_edit_privilege(p_person_id          IN NUMBER
                              ,p_business_group_id  IN NUMBER
                              ,p_transaction_status IN VARCHAR2
                              ,p_edit_privilege     OUT NOCOPY VARCHAR2)
IS
--
BEGIN
--
  IF ( (INSTR(p_transaction_status,'S') > 0) OR ( p_transaction_status IN ('C','N','W','RI') )) THEN
      p_edit_privilege := 'Y';
  ELSE
    IF ( NVL(fnd_profile.value('PQH_ALLOW_APPROVER_TO_EDIT_TXN'),'N') = 'Y' ) THEN
         PQH_SS_UTILITY.check_edit_privilege (
           p_personId        => p_person_id
          ,p_businessGroupId => p_business_group_id
          ,p_editAllowed     => p_edit_privilege);
    ELSE
           p_edit_privilege := 'N';
    END IF;
  END IF;

END check_edit_privilege;
--
--

FUNCTION check_future_change (
             p_txnId          IN NUMBER
            ,p_assignmentId   IN NUMBER
            ,p_effectiveDate  IN DATE
            ,p_calledFrom     IN VARCHAR2 DEFAULT 'REQUEST' ) RETURN VARCHAR2 IS
--
--
CURSOR cur_chg IS
SELECT object_version_number
FROM   per_all_assignments_f
WHERE  assignment_id        = p_assignmentId
AND    effective_start_date > p_effectiveDate;
--
dummy  VARCHAR2(1);
l_asgnStepId  NUMBER;
l_ovn         VARCHAR2(18);
l_effDate     DATE;
--
CURSOR cur_txnStep (c_txnId NUMBER ) IS
SELECT transaction_step_id
FROM   hr_api_transaction_steps
WHERE  transaction_id = c_txnId
AND    api_name       IN ( 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API', 'HR_SUPERVISOR_SS.PROCESS_API');
--
BEGIN
--
   IF ( p_assignmentId IS NULL) THEN
      RETURN ('N');
   END IF;

   OPEN  cur_txnStep (p_txnId);
   FETCH cur_txnStep INTO l_asgnStepId;
   IF cur_txnStep%NOTFOUND THEN
       CLOSE cur_TxnStep;
       RETURN ('N');
   END IF;
   CLOSE cur_txnStep;

   --
   --  The code below will be executed only if there are future dated changes
   --
   OPEN cur_chg;
   FETCH cur_chg INTO l_ovn;
   IF cur_chg%NOTFOUND THEN
       CLOSE cur_chg;
       RETURN ('N');
   END IF;
   CLOSE cur_chg;
   --
   -- Refresh the object version number when called from Submit
   IF (l_ovn IS NOT NULL) THEN
      IF (p_calledFrom = 'SUBMIT') THEN
              OPEN  cur_asgn( p_assignmentId, p_effectiveDate);
              FETCH cur_asgn INTO l_ovn, l_effDate;
              CLOSE cur_asgn;

              HR_TRANSACTION_API.set_number_value (
                p_transaction_step_id => l_asgnStepId
               ,p_person_id           => null
               ,p_name                => 'P_OBJECT_VERSION_NUMBER'
               ,p_value               => l_ovn
               ,p_original_value      => l_ovn
                );
      commit;
      END IF;
   END IF;

   RETURN('Y');
END check_future_change;
--
--
FUNCTION check_pending_transaction(
          p_txnId       IN NUMBER
         ,p_itemType    IN VARCHAR2
         ,p_personId    IN NUMBER
         ,p_assignId    IN NUMBER ) RETURN VARCHAR2 IS
--
CURSOR cur_txn IS
SELECT 'X'
FROM   hr_api_transaction_steps ts
WHERE  ts.transaction_id     = p_txnId
  AND  ts.api_name IN ('HR_SUPERVISOR_SS.PROCESS_API',
                       'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API',
                       'HR_PAY_RATE_SS.PROCESS_API',
                       'HR_TERMINATION_SS.PROCESS_API' );
--
CURSOR cur_pnd IS
SELECT 'X'
  FROM hr_api_transactions t, hr_api_transaction_steps ts
 WHERE t.transaction_id    = ts.transaction_id
   AND ts.item_type        = p_itemType
   AND ts.update_person_id = p_personId
   AND t.status in ('Y','YS','RO','ROS')  -- not considering C, RI, RIS as they are with init
   AND ts.api_name IN ('HR_SUPERVISOR_SS.PROCESS_API','HR_PROCESS_ASSIGNMENT_SS.PROCESS_API',
                       'HR_PAY_RATE_SS.PROCESS_API',  'HR_TERMINATION_SS.PROCESS_API' )
   AND EXISTS (SELECT NULL
                 FROM hr_api_transaction_values tsv
                WHERE tsv.transaction_step_id = ts.transaction_step_id
                  AND tsv.name        = 'P_REVIEW_PROC_CALL'
                  AND tsv.varchar2_value IS NOT NULL)
  AND EXISTS (SELECT NULL
                FROM wf_item_attribute_values iav2
               WHERE iav2.item_type   = ts.item_type
                 AND iav2.item_key    = ts.item_key
                 AND iav2.name        = 'TRAN_SUBMIT'
                 AND iav2.text_value  = 'Y')
  AND EXISTS (SELECT NULL
                FROM wf_item_attribute_values iav
               WHERE iav.item_type    = ts.item_type
                 AND iav.item_key     = ts.item_key
                 AND iav.name         = 'CURRENT_ASSIGNMENT_ID'
                 AND iav.number_value = p_assignId)
  AND ts.transaction_id  <> p_txnId ;
--
Dummy  VARCHAR2(1);
--
BEGIN
   --
   OPEN  cur_txn;
   FETCH cur_txn INTO dummy;
   --
   IF cur_txn%NOTFOUND THEN
      CLOSE cur_txn;
      return('N');
   END IF;
   --
   CLOSE cur_txn;
   --
   -- Reset Dummy before using it again in the next cursor
   -- else it will pick the previously fetched value if no record
   -- exist for the current cursor i.e cur_pend%notfound
   dummy  := null;
   --
   OPEN  cur_pnd;
   FETCH cur_pnd INTO dummy;
   CLOSE cur_pnd;
   --
   IF (NVL(Dummy,'~') = 'X' ) THEN
        return('Y');
   END IF;
   RETURN('N'); -- No Record Found
   --
END check_pending_transaction;
--
--
FUNCTION check_eligibility (
        p_planId         IN NUMBER
       ,p_personId       IN NUMBER
       ,p_effectiveDate  IN DATE ) RETURN VARCHAR2 IS
--
CURSOR cur_elig IS
SELECT eper.elig_flag eligibility_flag
FROM   ben_elig_per_f eper
WHERE  eper.pl_id     = p_planId
  AND  eper.pgm_id    IS NULL
  AND  eper.person_id = p_personId
  AND  p_EffectiveDate  BETWEEN eper.effective_start_date AND eper.effective_end_date
  ORDER BY eper.effective_start_date desc;
--
l_isEligible  BEN_ELIG_PER_F.elig_flag%TYPE;
--
BEGIN
--
  OPEN  cur_elig;
  FETCH cur_elig INTO l_isEligible;
  CLOSE cur_elig;
--
  IF (l_isEligible <> 'Y') THEN
  --
      l_isEligible := 'N';
  --
  END IF;
  --
  RETURN l_isEligible;
END;
--
--
FUNCTION get_business_group_id (
        p_personId      IN NUMBER
       ,p_effectiveDate IN DATE    ) RETURN NUMBER IS
--
CURSOR cur_bg(p_effectiveDate IN DATE) IS
   SELECT   business_group_id
   FROM     per_all_people_f
   WHERE    person_id  = p_personId
   AND      p_effectiveDate BETWEEN effective_start_date AND effective_end_date  ;
--
l_businessGrpId  NUMBER;
l_effectiveDate  date;
--
BEGIN
      if p_effectiveDate is null then
        l_effectiveDate := trunc(sysdate);
      else
        l_effectiveDate := p_effectiveDate;
      end if;
      --
      OPEN  cur_bg(l_effectiveDate) ;
      FETCH cur_bg INTO l_businessGrpId;
      CLOSE cur_bg;
      --
      RETURN l_businessGrpId;
END;
--
--
Function get_desc (p_function VARCHAR2 ) return varchar2
is
begin
if p_function is null then
return null;
else
  execute immediate 'begin select '||p_function||'into pqh_ss_utility.l_description from dual; end;';
end if;
return pqh_ss_utility.l_description;
end get_desc;

PROCEDURE set_datetrack_mode (
           p_txnId           IN VARCHAR2
          ,p_dateTrack_mode  IN VARCHAR2  ) IS
--
CURSOR cur_asgn  IS
SELECT null
FROM   per_all_assignments_f  af, hr_api_transactions  hat
WHERE  af.assignment_id        = hat.assignment_id
AND    af.effective_start_date = hat.transaction_effective_date
AND    hat.transaction_id       = p_txnId;
--
dummy  varchar2(10);
--
l_mode varchar2(30)  := p_dateTrack_mode;
--
BEGIN
    OPEN  cur_asgn;
    FETCH cur_asgn INTO dummy;
    IF (cur_asgn%FOUND) THEN
       l_mode := 'CORRECTION';
    END IF;
    CLOSE cur_asgn;

    UPDATE  hr_api_transaction_values
       SET  varchar2_value      = l_mode
     WHERE  name                = 'P_DATETRACK_UPDATE_MODE'
       AND  transaction_step_id = (
            SELECT  transaction_step_id
            FROM    hr_api_transaction_steps
            WHERE   transaction_id   = p_txnId
            AND     api_name         = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API' )
       AND  varchar2_value      <> l_mode;

     commit;
END;
--
--
FUNCTION check_function_parameter (
        p_functionId  IN NUMBER,
        p_paramName   IN VARCHAR2 ) RETURN VARCHAR2 IS
--
CURSOR  cur_fn IS
SELECT  parameters
FROM    fnd_form_functions
WHERE   function_id         = p_functionId;
--
l_parameter fnd_form_functions.parameters%TYPE;
BEGIN
   --
   OPEN  cur_fn;
   FETCH cur_fn INTO l_parameter;
   CLOSE cur_fn;
   --
   IF ( INSTR(l_parameter,p_paramName) > 0 ) THEN
        RETURN ('Y');
   END IF;
   --
   RETURN ('N');
--
END  check_function_parameter;
--
--

FUNCTION get_assignment_startdate ( p_assignmentId IN VARCHAR2 ) RETURN DATE IS
--
l_assignment_startdate DATE;
--
CURSOR cur_asgn IS
  SELECT  min(effective_Start_date)
  FROM    per_all_assignments_f
  WHERE   assignment_id   = p_assignmentId
  AND     assignment_type in ('E','C');
--
BEGIN
--
  OPEN  cur_asgn;
  FETCH cur_asgn INTO l_assignment_startDate;
  CLOSE cur_asgn;
--
  RETURN l_assignment_startDate;
--
END get_assignment_startdate;
--
function get_approval_process_version(p_itemType varchar2, p_itemKey varchar2 )
 return varchar2 is
 l_approval_process_version varchar2(10);
begin
 l_approval_process_version := wf_engine.GetItemAttrText(
   itemtype => p_itemType,
   itemkey  => p_itemKey,
   aname    => 'HR_APPROVAL_PRC_VERSION');
 return l_approval_process_version;
exception
 when others then
   return 'N';
end;
--
 /* Private Function used by Public Function IS_REFRESH_NEEDED */
 FUNCTION get_hr_value (p_attribute_key IN VARCHAR2
                       ,p_assignment_rec IN PER_ALL_ASSIGNMENTS_F%ROWTYPE)
 RETURN VARCHAR2
 IS
 BEGIN
   IF    p_attribute_key = 'P_ORGANIZATION_ID'              THEN RETURN p_assignment_rec.organization_id;
   ELSIF p_attribute_key = 'P_JOB_ID'                       THEN RETURN p_assignment_rec.job_id;
   ELSIF p_attribute_key = 'P_MANAGER_FLAG'                 THEN RETURN p_assignment_rec.manager_flag;
   ELSIF p_attribute_key = 'P_SUPERVISOR_ID'                THEN RETURN p_assignment_rec.supervisor_id;
   ELSIF p_attribute_key = 'P_POSITION_ID'                  THEN RETURN p_assignment_rec.position_id;
   ELSIF p_attribute_key = 'P_WORK_AT_HOME'                 THEN RETURN p_assignment_rec.work_at_home;
   ELSIF p_attribute_key = 'P_LOCATION_ID'                  THEN RETURN p_assignment_rec.location_id;
   ELSIF p_attribute_key = 'P_GRADE_ID'                     THEN RETURN p_assignment_rec.grade_id;
   ELSIF p_attribute_key = 'P_SPECIAL_CEILING_STEP_ID'      THEN RETURN p_assignment_rec.special_ceiling_step_id;
   ELSIF p_attribute_key = 'P_PAYROLL_ID'                   THEN RETURN p_assignment_rec.payroll_id;
   ELSIF p_attribute_key = 'P_ASSIGNMENT_STATUS_TYPE_ID'    THEN RETURN p_assignment_rec.assignment_status_type_id;
   ELSIF p_attribute_key = 'P_CHANGE_REASON'                THEN RETURN p_assignment_rec.change_reason;
   ELSIF p_attribute_key = 'P_ESTABLISHMENT_ID'             THEN RETURN p_assignment_rec.establishment_id;
   ELSIF p_attribute_key = 'P_PAY_BASIS_ID'                 THEN RETURN p_assignment_rec.pay_basis_id;
   ELSIF p_attribute_key = 'P_SAL_REVIEW_PERIOD'            THEN RETURN p_assignment_rec.sal_review_period;
   ELSIF p_attribute_key = 'P_SAL_REVIEW_PERIOD_FREQUENCY'  THEN RETURN p_assignment_rec.sal_review_period_frequency;
   ELSIF p_attribute_key = 'P_PERF_REVIEW_PERIOD'           THEN RETURN p_assignment_rec.perf_review_period;
   ELSIF p_attribute_key = 'P_PERF_REVIEW_PERIOD_FREQUENCY' THEN RETURN p_assignment_rec.perf_review_period_frequency;
   ELSIF p_attribute_key = 'P_NORMAL_HOURS'                 THEN RETURN p_assignment_rec.normal_hours;
   ELSIF p_attribute_key = 'P_FREQUENCY'                    THEN RETURN p_assignment_rec.frequency;
   ELSIF p_attribute_key = 'P_TIME_NORMAL_START'            THEN RETURN p_assignment_rec.time_normal_start;
   ELSIF p_attribute_key = 'P_TIME_NORMAL_FINISH'           THEN RETURN p_assignment_rec.time_normal_finish;
   ELSIF p_attribute_key = 'P_EMPLOYEE_CATEGORY'            THEN RETURN p_assignment_rec.employee_category;
   ELSIF p_attribute_key = 'P_EMPLOYMENT_CATEGORY'          THEN RETURN p_assignment_rec.employment_category;
   ELSIF p_attribute_key = 'P_PEOPLE_GROUP_ID'              THEN RETURN p_assignment_rec.people_group_id;
   ELSIF p_attribute_key = 'P_SOFT_CODING_KEYFLEX_ID'       THEN RETURN p_assignment_rec.soft_coding_keyflex_id;
   ELSIF p_attribute_key = 'P_DEFAULT_CODE_COMB_ID'       THEN RETURN p_assignment_rec.default_code_comb_id;
--    ELSIF p_attribute_key = 'P_OBJECT_VERSION_NUMBER'        THEN RETURN
-- p_assignment_rec.object_version_number;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE_CATEGORY'       THEN RETURN p_assignment_rec.ass_attribute_category;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE1'               THEN RETURN p_assignment_rec.ass_attribute1;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE2'               THEN RETURN p_assignment_rec.ass_attribute2;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE3'               THEN RETURN p_assignment_rec.ass_attribute3;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE4'               THEN RETURN p_assignment_rec.ass_attribute4;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE5'               THEN RETURN p_assignment_rec.ass_attribute5;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE6'               THEN RETURN p_assignment_rec.ass_attribute6;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE7'               THEN RETURN p_assignment_rec.ass_attribute7;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE8'               THEN RETURN p_assignment_rec.ass_attribute8;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE9'               THEN RETURN p_assignment_rec.ass_attribute9;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE10'              THEN RETURN p_assignment_rec.ass_attribute10;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE11'              THEN RETURN p_assignment_rec.ass_attribute11;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE12'              THEN RETURN p_assignment_rec.ass_attribute12;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE13'              THEN RETURN p_assignment_rec.ass_attribute13;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE14'              THEN RETURN p_assignment_rec.ass_attribute14;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE15'              THEN RETURN p_assignment_rec.ass_attribute15;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE16'              THEN RETURN p_assignment_rec.ass_attribute16;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE17'              THEN RETURN p_assignment_rec.ass_attribute17;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE18'              THEN RETURN p_assignment_rec.ass_attribute18;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE19'              THEN RETURN p_assignment_rec.ass_attribute19;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE20'              THEN RETURN p_assignment_rec.ass_attribute20;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE21'              THEN RETURN p_assignment_rec.ass_attribute21;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE22'              THEN RETURN p_assignment_rec.ass_attribute22;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE23'              THEN RETURN p_assignment_rec.ass_attribute23;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE24'              THEN RETURN p_assignment_rec.ass_attribute24;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE25'              THEN RETURN p_assignment_rec.ass_attribute25;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE26'              THEN RETURN p_assignment_rec.ass_attribute26;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE27'              THEN RETURN p_assignment_rec.ass_attribute27;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE28'              THEN RETURN p_assignment_rec.ass_attribute28;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE29'              THEN RETURN p_assignment_rec.ass_attribute29;
   ELSIF p_attribute_key = 'P_ASS_ATTRIBUTE30'              THEN RETURN p_assignment_rec.ass_attribute30;
   ELSIF p_attribute_key = 'P_NOTICE_PERIOD'                THEN RETURN p_assignment_rec.notice_period;
   ELSIF p_attribute_key = 'P_NOTICE_PERIOD_UOM'            THEN RETURN p_assignment_rec.notice_period_uom;
   ELSIF p_attribute_key = 'P_PROBATION_PERIOD'             THEN RETURN p_assignment_rec.probation_period;
   ELSIF p_attribute_key = 'P_PROBATION_UNIT'               THEN RETURN p_assignment_rec.probation_unit;
   ELSIF p_attribute_key = 'P_DATE_PROBATION_END'           THEN RETURN p_assignment_rec.date_probation_end;
   ELSIF p_attribute_key = 'P_INTERNAL_ADDRESS_LINE'        THEN RETURN p_assignment_rec.internal_address_line;
   ELSIF p_attribute_key = 'P_BARGAINING_UNIT_CODE'         THEN RETURN p_assignment_rec.bargaining_unit_code;
   ELSIF p_attribute_key = 'P_COLLECTIVE_AGREEMENT_ID'      THEN RETURN p_assignment_rec.collective_agreement_id;
   ELSIF p_attribute_key = 'P_CAGR_ID_FLEX_NUM'             THEN RETURN p_assignment_rec.cagr_id_flex_num;
   ELSIF p_attribute_key = 'P_CAGR_GRADE_DEF_ID'            THEN RETURN p_assignment_rec.cagr_grade_def_id;
   ELSIF p_attribute_key = 'P_CONTRACT_ID'                  THEN RETURN p_assignment_rec.contract_id;
   ELSIF p_attribute_key = 'P_LABOUR_UNION_MEMBER_FLAG'     THEN RETURN p_assignment_rec.labour_union_member_flag;
   ELSIF p_attribute_key = 'P_VENDOR_ID'  THEN RETURN p_assignment_rec.vendor_id;
   ELSIF p_attribute_key = 'P_VENDOR_EMPLOYEE_NUMBER'  THEN RETURN p_assignment_rec.vendor_employee_number;
   ELSIF p_attribute_key = 'P_VENDOR_ASSIGNMENT_NUMBER'  THEN RETURN p_assignment_rec.vendor_assignment_number;
   ELSIF p_attribute_key = 'P_TITLE'  THEN RETURN p_assignment_rec.title;
   ELSIF p_attribute_key = 'P_PROJECT_TITLE'  THEN RETURN p_assignment_rec.project_title;
   -- GSP change
   ELSIF p_attribute_key = 'P_GRADE_LADDER_PGM_ID'  THEN RETURN p_assignment_rec.grade_ladder_pgm_id;
   --End of GSP change

   ELSIF p_attribute_key = 'P_PO_HEADER_ID'  THEN RETURN p_assignment_rec.po_header_id;
   ELSIF p_attribute_key = 'P_PO_LINE_ID'  THEN RETURN p_assignment_rec.po_line_id;
   ELSIF p_attribute_key = 'P_VENDOR_SITE_ID'  THEN RETURN p_assignment_rec.vendor_site_id;
   ELSIF p_attribute_key = 'P_PROJ_ASGN_END'  THEN RETURN p_assignment_rec.projected_assignment_end;
   END IF;
   RETURN NULL;
 END get_hr_value;


--
-- Function to check if refresh is needed or not
-- The p_futureChange flag will decide whethar to compare attribute by attribute
-- (if futurechange=Y, else, simple OVN comparison would suffice

FUNCTION check_intervening_action (
           p_txnId         IN VARCHAR2
          ,p_assignmentId  IN NUMBER
          ,p_effectiveDate IN DATE
          ,p_futureChange  IN VARCHAR2 ) RETURN VARCHAR2 IS
--

 CURSOR csr_transaction_values IS
   SELECT name,
          atv.varchar2_value|| atv.number_value||atv.date_value txn_curr_value,
          atv.original_varchar2_value|| atv.original_number_value||atv.original_date_value txn_old_value
     FROM hr_api_transaction_values atv,
          pqh_attributes att,
          pqh_table_route   ptr
    WHERE att.column_name  = name
      AND att.master_table_route_id = ptr.table_route_id
      AND ptr.table_alias IN ('PQH_SS_ASG_PG1','PQH_SS_OTHER_EMP_INFO_PG1')
      AND atv.transaction_step_id  IN ( SELECT transaction_step_id
                                          FROM hr_api_transaction_steps
                                         WHERE transaction_id = p_txnId
                                           AND api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API');

 CURSOR csr_assignment IS
    SELECT *
    FROM  per_all_assignments_f
    WHERE assignment_id = p_assignmentId
    AND   p_effectiveDate between effective_start_date and effective_end_date
    AND   assignment_type IN ('E','A','C');
--
CURSOR cur_val (p_stepId NUMBER, p_param_name VARCHAR2) IS
  SELECT NVL(original_number_value,number_value)
  FROM   hr_api_transaction_values
  WHERE  transaction_step_id  = p_stepId
  AND    name                 = p_param_name;
--
CURSOR cur_txnStep (c_txnId NUMBER ) IS
SELECT item_type,item_key
FROM   hr_api_transactions
WHERE  transaction_id = c_txnId;
--
CURSOR chk_ex_emp(l_person_id in number, l_effective_date in Date) is
  select ppt.SYSTEM_PERSON_TYPE from per_all_people_f paf, per_person_types ppt where person_id = l_person_id
  and paf.PERSON_TYPE_ID = ppt.PERSON_TYPE_ID
  and l_effective_date between effective_start_date and effective_end_date;
--
  l_ovn       VARCHAR2(15);
  l_hrOvn     VARCHAR2(15);
  l_hrEffDate DATE;
  l_txnId     NUMBER;
  l_stepId    NUMBER;
  l_rehire_flow varchar2(25) default null;
  l_ex_emp varchar2(10) default null;
  l_person_id number;
  l_item_type varchar2(50);
  l_item_key varchar2(50);
--
  l_refresh_needed VARCHAR2(5) := 'N';
  l_assignment_rec PER_ALL_ASSIGNMENTS_F%ROWTYPE;
BEGIN
  --If future changes are present then check each attribute to see if refresh
  --is needed due to an intervening action
  -- IF ( p_futureChange = 'Y') THEN
  --
  -- Bug 2980660: Always perform attr vs attr comparision to check
  -- if intervening action has taken place.

    OPEN  cur_txnStep (p_txnId);
    FETCH cur_txnStep INTO l_item_type,l_item_key;
    CLOSE cur_txnStep;
    if l_item_type is not null and l_item_key is not null then
    	l_rehire_flow := wf_engine.GetItemAttrText(l_item_type,l_item_key,'HR_FLOW_IDENTIFIER',true);
    end if;
    /*
    l_person_id := wf_engine.GetItemAttrText(l_item_type,l_item_key,'CURRENT_PERSON_ID',true);

    open chk_ex_emp(l_person_id, p_effectiveDate);
    fetch chk_ex_emp into l_ex_emp;
    close chk_ex_emp;
   */
    If nvl(l_rehire_flow,'N') = 'EX_EMP'  OR nvl(l_rehire_flow,'N') = 'REVERSE_TERMINATION' then
	return l_refresh_needed;
    end if;

    OPEN  csr_assignment;
    FETCH csr_assignment INTO l_assignment_rec;
    CLOSE csr_assignment;

    FOR csr_transaction_values_rec IN csr_transaction_values
    LOOP
     --
     IF nvl(get_hr_value(csr_transaction_values_rec.name,l_assignment_rec),-1) <>
        nvl(csr_transaction_values_rec.txn_old_value,-1) THEN
           l_refresh_needed := 'Y';
         EXIT;
     END IF;

    END LOOP;
    --

    IF ( l_refresh_needed = 'Y' ) AND
       ( l_assignment_rec.effective_start_date = p_effectiveDate) THEN
         l_refresh_needed := 'YC';
    END IF;
/*
  -- If no future change exist, a simple comparision of OVN and Effective date would suffice
  ELSE
   --
   OPEN  cur_txnStep (p_txnId);
   FETCH cur_txnStep INTO l_stepId;
   CLOSE cur_txnStep;

   -- if assignment step id is null then we don't check for intervening actions.
   IF (l_stepId IS NULL ) THEN
        RETURN('N');
   END IF;
   --
   OPEN  cur_val(l_stepId, 'P_OBJECT_VERSION_NUMBER');
   FETCH cur_val INTO l_ovn;
   CLOSE cur_val;
   --
   OPEN  cur_asgn( p_assignmentId, p_effectiveDate);
   FETCH cur_asgn INTO l_hrOvn, l_hrEffDate;
   CLOSE cur_asgn;
   --
   IF ( NVL(l_ovn,'X') <> NVL(l_hrOvn,'Y') ) THEN
   --
     IF ( l_hrEffDate = p_effectiveDate ) THEN
          l_refresh_needed := 'YC'; -- Yes Correction
     ELSE
          l_refresh_needed := 'Y'; -- Yes No Correction
     END IF;
     --
   END IF;
   --
 END IF; -- if future found Y/N
*/
 --
 RETURN (l_refresh_needed);
 --
END check_intervening_action;

--
--
FUNCTION  get_transaction_step_id (
          p_itemType  IN VARCHAR2
         ,p_itemKey   IN VARCHAR2
         ,p_apiName   IN VARCHAR2 ) RETURN VARCHAR2 IS
--
CURSOR cur_txnStep  IS
SELECT transaction_step_id
FROM   hr_api_transaction_steps
WHERE  item_type      = p_itemType
AND    item_key       = p_itemKey
AND    api_name       = p_apiName;
--
l_stepId VARCHAR2(15);
--
BEGIN

   OPEN  cur_txnStep;
   FETCH cur_txnStep INTO l_stepId;
   CLOSE cur_txnStep;
--
   RETURN l_stepId;
--
END get_transaction_step_id;
--
FUNCTION chk_transaction_step_exist (
         p_transaction_id  IN NUMBER ) RETURN VARCHAR2 IS
--
CURSOR csr_transaction_step_exist IS
 SELECT 'Y'
   FROM hr_api_transaction_steps
  WHERE transaction_id = p_transaction_id;
--
l_transaction_step_exist VARCHAR2(5) := 'N';
--
BEGIN
  IF p_transaction_id IS NOT NULL THEN
     OPEN csr_transaction_step_exist;
     FETCH csr_transaction_step_exist INTO l_transaction_step_exist;
     CLOSE csr_transaction_step_exist;
  END IF;
--
 RETURN l_transaction_step_exist;
--
END chk_transaction_step_exist;
--
--
function plans_exists_for_rg(p_reporting_group_id number,
                      p_business_group_id number,
                      p_effective_date date) return varchar2 is
--
cursor c2(p_reporting_group_id number, p_business_group_id number,
          p_effective_date date) is
SELECT 'x'
FROM ben_popl_rptg_grp_f
where rptg_grp_id = p_reporting_group_id
and business_group_id = p_business_group_id
and trunc(p_effective_date) between effective_start_date and effective_end_date;
--
l_plans_exist boolean;
l_dummy varchar2(10);
--
begin
 --
 if p_reporting_group_id is not null then
   open c2(p_reporting_group_id, p_business_group_id, p_effective_date);
   fetch c2 into l_dummy;
   l_plans_exist := c2%found;
   close c2;
   --
   if l_plans_exist then
     return 'Y';
   end if;
   --
 end if;
 --
 return 'N';
 --
end;
--
--
end;


/
