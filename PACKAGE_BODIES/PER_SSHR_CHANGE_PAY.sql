--------------------------------------------------------
--  DDL for Package Body PER_SSHR_CHANGE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSHR_CHANGE_PAY" as
/* $Header: pepypshr.pkb 120.45.12010000.11 2010/04/12 11:27:58 vkodedal ship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package  Varchar2(30) := 'per_sshr_change_pay.';
g_debug boolean := hr_utility.debug_enabled;
--
  type t_tx_name is table of varchar2(30)   index by binary_integer;
  type t_tx_char is table of varchar2(2000) index by binary_integer;
  type t_tx_num  is table of number         index by binary_integer;
  type t_tx_date is table of date           index by binary_integer;
  type t_tx_type is table of varchar2(30)   index by binary_integer;
--
--------------------------------------------------------------------------------
--
--

function Check_GSP_Manual_Override (p_assignment_id in NUMBER, p_effective_date in DATE,p_transaction_id in NUMBER)
RETURN VARCHAR2
is
--
 Cursor csr_gsp_ladder_id Is
   select hatv.number_value
           from hr_api_transaction_steps hats,
           hr_api_transactions hat,
           hr_api_transaction_values hatv
           where hats.api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
           and hatv.transaction_step_id = hats.transaction_step_id
           and hatv.name = 'P_GRADE_LADDER_PGM_ID'
           and hats.TRANSACTION_ID = hat.TRANSACTION_ID
           and hat.TRANSACTION_ID = p_transaction_id
		   and hat.status<>'AC';
--
 Cursor csr_assignment_check Is
   Select Nvl(Gsp_Allow_Override_Flag,'Y')
     From Ben_Pgm_f Pgm,
          Per_all_assignments_F paa
    Where paa.Assignment_Id = p_assignment_id
      and p_effective_date between paa.Effective_Start_Date and paa.Effective_End_Date
      and paa.GRADE_LADDER_PGM_ID is Not NULL
      and pgm.pgm_id = paa.Grade_Ladder_Pgm_Id
      and p_effective_date between Pgm.Effective_Start_Date and Pgm.Effective_End_Date
      and Pgm_typ_Cd = 'GSP'
      and Pgm_stat_Cd = 'A'
      and Update_Salary_Cd = 'SALARY_BASIS';
--
 Cursor csr_transaction_check(l_transaction_ladder_id number) Is
   Select Nvl(Gsp_Allow_Override_Flag,'Y')
     From Ben_Pgm_f Pgm
    Where pgm.pgm_id = l_transaction_ladder_id
      and p_effective_date between Pgm.Effective_Start_Date and Pgm.Effective_End_Date
      and Pgm_typ_Cd = 'GSP'
      and Pgm_stat_Cd = 'A'
      and Update_Salary_Cd = 'SALARY_BASIS';
--
 l_status  Varchar2(1) := 'Y';
 l_txn_grade_ladder_id number;
Begin
l_txn_grade_ladder_id := -1;
 if g_debug then
     hr_utility.set_location('Enter Check_GSP_Manual_Override  ', 1);
     hr_utility.set_location('p_assignment_id  '||p_assignment_id, 2);
     hr_utility.set_location('p_effective_date  '||p_effective_date,3);
     hr_utility.set_location('p_transaction_id  '||p_transaction_id,4);
 end if;

    Open csr_gsp_ladder_id;
    Fetch csr_gsp_ladder_id into l_txn_grade_ladder_id ;
    Close csr_gsp_ladder_id;

 if g_debug then
     hr_utility.set_location('In GSP_CHECK  l_txn_grade_ladder_id '||l_txn_grade_ladder_id, 5);
 end if;

    if l_txn_grade_ladder_id is null or l_txn_grade_ladder_id = -1 then
         Open  csr_assignment_check;
         Fetch csr_assignment_check into l_Status;
         Close csr_assignment_check;
         if g_debug then
         hr_utility.set_location('In GSP_CHECK_AST  l_Status '||l_Status, 6);
         end if;
    else
         Open  csr_transaction_check(l_txn_grade_ladder_id);
         Fetch csr_transaction_check into l_Status;
         Close csr_transaction_check;
         if g_debug then
         hr_utility.set_location('In GSP_CHECK_TXN  l_Status '||l_Status, 7);
         end if;
    end if;
   RETURN l_Status;
End;


--
--
PROCEDURE check_base_salary_profile(p_transaction_step_id in NUMBER
                                    ,p_item_key in varchar2
                                    ,p_item_type in varchar2
                                    ,p_effective_date in date
                                    ,p_assignment_id in varchar2)
is
--
  l_hr_base_salary_required VARCHAR2(10) := fnd_profile.VALUE('HR_BASE_SALARY_REQUIRED');
--
   l_change_date          date := null;
   l_asst_id              number;
   l_txn_basis            number;
   l_ast_basis            number;
   l_transaction_id       number;
   l_transaction_step_id  number;
   l_pay_basis            per_all_assignments_f.pay_basis_id%type;
--
Cursor asg_step is
  select transaction_id,transaction_step_id
                 from hr_api_transaction_steps
                 where transaction_step_id = (Select transaction_step_id from hr_api_transaction_steps
                                         where item_key = p_item_key
                                         and item_type = p_item_type
                                         and api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API');

--
--
Cursor txn_details(c_transaction_step_id number) Is
  select  max(col1) as assignment_id,
          max(col2) as pay_basis_id
          from
         (select decode(NAME, 'P_ASSIGNMENT_ID', NUMBER_VALUE) col1,
                 decode(NAME, 'P_PAY_BASIS_ID', NUMBER_VALUE) col2
                 from hr_api_transaction_values
                 where TRANSACTION_STEP_ID = c_transaction_step_id);
--
Cursor csr_pay_basis_exists(c_assignment_id number,c_effective_date date) IS
   select pay_basis_id
          from   per_all_assignments_f
          where  assignment_id = c_assignment_id
          and c_effective_date between effective_start_date and effective_end_date;
--
Cursor csr_txn_prop is
          select change_date
          from per_pay_transactions
          where p_transaction_step_id is not null
           and transaction_step_id = p_transaction_step_id
          and PARENT_PAY_TRANSACTION_ID is null
          and status <> 'DELETE';
--
Cursor csr_prop is
        select change_date
          from per_pay_proposals
         where assignment_id = p_assignment_id
           and pay_proposal_id not in (select pay_proposal_id
                                         from per_pay_transactions
                                        where p_transaction_step_id is not null
                                          and transaction_step_id = p_transaction_step_id
                                          and PARENT_PAY_TRANSACTION_ID is null
                                          and status <> 'DELETE');
--
BEGIN
--
   if g_debug then
     hr_utility.set_location('Enter check_base_salary_profile  ', 1);
   end if;
   --
   -- Get the transaction_step_id of the assignment step.
   --
   Open asg_step;
   Fetch asg_step into l_transaction_id,l_transaction_step_id;
   Close asg_step;
   --
    if g_debug then
      hr_utility.set_location('l_transaction_id  '||l_transaction_id, 2);
      hr_utility.set_location('l_transaction_step_id  '||l_transaction_step_id, 3);
    end if;
   --
   -- There exists an assignment step, Hence get the pay basis from the txn table.
   -- Note, If new hire flow, there will be an assignment txn step.
   --
   if l_transaction_step_id is not null then
        -- Get pay basis id from assignment step.
        Open txn_details(l_transaction_step_id);
        Fetch txn_details into l_asst_id,l_txn_basis;
        Close txn_details;

      l_pay_basis := l_txn_basis;
   Else
      -- Get pay basis from assignment
      Open csr_pay_basis_exists(p_assignment_id,p_effective_date);
      Fetch csr_pay_basis_exists into l_ast_basis;
      Close csr_pay_basis_exists;
      l_pay_basis := l_ast_basis;

   end if;

   -- There is a pay basis either in assignment or on txn table.
   --
   if ((l_hr_base_salary_required is not null)
       and (l_hr_base_salary_required = 'Y')
       and (l_pay_basis is not null ))
    then
         -- foll cursor wont return any rows if
         -- 1) no action was done through change pay pages
         -- 2) only action done through change pay pages was delete
         --
         Open csr_txn_prop;
         Fetch csr_txn_prop into l_change_date;
         Close csr_txn_prop;
         --
         -- If No rows returned by above cursor, we need to check master table.
         --
         if l_change_date is null then
             --
             -- Foll cursor wont return any rows if
             -- 1) we are new hire flow and the assignment is new
             -- 2) we are any other flow, but deleted all the pay proposals
             --
             Open csr_prop ;
             Fetch csr_prop  into l_change_date;
             Close csr_prop ;
             -- If no row returned above, raise error
             if l_change_date is null then
                hr_utility.set_message(800,'PER_33490_CHGPAY_PROPOSAL_REQD');
                hr_utility.raise_error;
             end if;
             --
          End if;
          --
   End if;
End;
--
--
FUNCTION get_comp_flex(p_dff_name in varchar2)
return VARCHAR2
IS
l_mandatory_field varchar2(20);
cursor flex is
    select APPLICATION_COLUMN_NAME from
           fnd_descr_flex_col_usage_vl
    where APPLICATION_ID = 800
    and DESCRIPTIVE_FLEXFIELD_NAME = p_dff_name
    and nvl(REQUIRED_FLAG,'N') = 'Y';
begin
    open flex;
        fetch flex into l_mandatory_field;
    close flex;

  if l_mandatory_field is null then
        l_mandatory_field := '';
    end if;

return l_mandatory_field;
end get_comp_flex;

--
--

PROCEDURE create_salary_basis_chg_step
(p_item_type                   in varchar2 ,
  p_item_key                    in varchar2 ,
  p_activity_id                 in number ,
  P_ASSIGNMENT_ID               IN NUMBER ,
  P_PAY_BASIS_ID                IN NUMBER ,
  P_DATETRACK_UPDATE_MODE       IN VARCHAR2 ,
  P_EFFECTIVE_DATE              IN DATE ,
  P_EFFECTIVE_DATE_OPTION       IN VARCHAR2 ,
  P_LOGIN_PERSON_ID             IN NUMBER ,
  P_APPROVER_ID                 IN NUMBER   default null,
  P_SAVE_MODE                   IN VARCHAR2 default null)  IS
--
--
  l_tx_name             t_tx_name;
  l_tx_char t_tx_char;
  l_tx_num  t_tx_num;
  l_tx_date t_tx_date;
  l_tx_type t_tx_type;

  l_api_error                     boolean;
  l_transaction_id                number := null;
  l_transaction_step_id           number := null;
  l_result                        varchar2(100);
  l_count                         number := 1;
  l_update_mode                   boolean := true;
  --
  l_asg_rec                       per_all_assignments_f%ROWTYPE;
  --
Cursor csg_asg_details is
 Select * from per_all_assignments_f
  Where assignment_id = p_assignment_id
    and trunc(p_effective_date) between effective_start_date and effective_end_date;
 --
Begin

-- Check if the step already exists, create if it does not exist.
get_pay_transaction
 (p_item_type                    => p_item_type,
  p_item_key                     => p_item_key,
  p_activity_id                  => p_activity_id,
  p_login_person_id              => p_login_person_id,
  p_api_name                     => 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API',
  p_effective_date_option        => p_effective_date_option,
  p_transaction_id               => l_transaction_id,
  p_transaction_step_id          => l_transaction_step_id,
  p_update_mode                  => l_update_mode);
--
Update hr_api_transactions
   set transaction_effective_date = trunc(P_EFFECTIVE_DATE)
where transaction_id = l_transaction_id;
--
wf_engine.setitemattrtext (itemtype => p_item_type
                          ,itemkey  => p_item_key
                          ,aname    => 'P_EFFECTIVE_DATE'
                          ,avalue   => to_char(trunc(P_EFFECTIVE_DATE),'YYYY-MM-DD'));


--
-- If it exists, perform update of the transaction values
--
If l_update_mode then
  --
  l_count  := 1;
  --
  -- Initialise the passed transaction values.
  --
  l_tx_name(l_count) := 'P_APPROVER_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := P_APPROVER_ID;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';

/**
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ASSIGNMENT_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := P_ASSIGNMENT_ID;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';

  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_DATETRACK_UPDATE_MODE';
  l_tx_char(l_count) := P_DATETRACK_UPDATE_MODE;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
**/

  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_EFFECTIVE_DATE';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := P_EFFECTIVE_DATE;
  l_tx_type(l_count) := 'DATE';

  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_EFFECTIVE_DATE_OPTION';
  l_tx_char(l_count) := P_EFFECTIVE_DATE_OPTION;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';

  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_LOGIN_PERSON_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := P_LOGIN_PERSON_ID;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';

  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_REVIEW_ACTID';
  l_tx_char(l_count) := to_char(p_activity_id);
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';

  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_REVIEW_PROC_CALL';
  l_tx_char(l_count) := 'HrAssignment';
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';

If P_SAVE_MODE is not null then
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_SAVE_MODE';
  l_tx_char(l_count) := P_SAVE_MODE;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
  else
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_SAVE_MODE';
  l_tx_char(l_count) := 'SAVE';
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
  End if;

  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PAY_BASIS_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := P_PAY_BASIS_ID;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
  --
  forall i in 1..l_count
        update hr_api_transaction_values
        set
        varchar2_value             = l_tx_char(i),
        number_value               = l_tx_num(i),
        date_value                 = l_tx_date(i)
        where transaction_step_id  = l_transaction_step_id
        and   name                 = l_tx_name(i);
  --
Else
  --
  Open csg_asg_details;
  Fetch csg_asg_details into l_asg_rec;
  Close csg_asg_details;
  --
  l_count := 1;
  --
  -- Initialise the passed transaction values.
  --

 l_tx_name(l_count) := 'P_ASSIGNMENT_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := P_ASSIGNMENT_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_OBJECT_VERSION_NUMBER';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.OBJECT_VERSION_NUMBER;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_EFFECTIVE_DATE';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := P_EFFECTIVE_DATE;
 l_tx_type(l_count) := 'DATE';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_EFFECTIVE_DATE_OPTION';
 l_tx_char(l_count) := P_EFFECTIVE_DATE_OPTION;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ELEMENT_CHANGED';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DATETRACK_UPDATE_MODE';
 l_tx_char(l_count) := P_DATETRACK_UPDATE_MODE;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ORGANIZATION_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.ORGANIZATION_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_BUSINESS_GROUP_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.BUSINESS_GROUP_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PERSON_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PERSON_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_LOGIN_PERSON_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := P_LOGIN_PERSON_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ORG_NAME';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_POSITION_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.POSITION_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_POS_NAME';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

l_count := l_count + 1;
 l_tx_name(l_count) := 'P_JOB_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.JOB_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_JOB_NAME';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_GRADE_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.GRADE_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_GRADE_NAME';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_LOCATION_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.LOCATION_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_EMPLOYMENT_CATEGORY';
 l_tx_char(l_count) := l_asg_rec.EMPLOYMENT_CATEGORY;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_SUPERVISOR_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.SUPERVISOR_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_MANAGER_FLAG';
 l_tx_char(l_count) := l_asg_rec.MANAGER_FLAG;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_NORMAL_HOURS';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.NORMAL_HOURS;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_FREQUENCY';
 l_tx_char(l_count) := l_asg_rec.FREQUENCY;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_TIME_NORMAL_FINISH';
 l_tx_char(l_count) := l_asg_rec.TIME_NORMAL_FINISH;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_TIME_NORMAL_START';
 l_tx_char(l_count) := l_asg_rec.TIME_NORMAL_START;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_BARGAINING_UNIT_CODE';
 l_tx_char(l_count) := l_asg_rec.BARGAINING_UNIT_CODE;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_LABOUR_UNION_MEMBER_FLAG';
 l_tx_char(l_count) := l_asg_rec.LABOUR_UNION_MEMBER_FLAG;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_SPECIAL_CEILING_STEP_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.SPECIAL_CEILING_STEP_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASSIGNMENT_STATUS_TYPE_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.ASSIGNMENT_STATUS_TYPE_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_CHANGE_REASON';
 l_tx_char(l_count) := l_asg_rec.CHANGE_REASON;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE_CATEGORY';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE_CATEGORY;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE1';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE1;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE2';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE2;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE3';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE3;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE4';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE4;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE5';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE5;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE6';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE6;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE7';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE7;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE8';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE8;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE9';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE9;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE10';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE10;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE11';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE11;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE12';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE12;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE13';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE13;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE14';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE14;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE15';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE15;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE16';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE16;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE17';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE17;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE18';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE18;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE19';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE19;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE20';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE20;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE21';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE21;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE22';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE22;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE23';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE23;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE24';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE24;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE25';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE25;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE26';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE26;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE27';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE27;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE28';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE28;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE29';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE29;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASS_ATTRIBUTE30';
 l_tx_char(l_count) := l_asg_rec.ASS_ATTRIBUTE30;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PEOPLE_GROUP_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PEOPLE_GROUP_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_SOFT_CODING_KEYFLEX_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.SOFT_CODING_KEYFLEX_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PAYROLL_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PAYROLL_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PAY_BASIS_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PAY_BASIS_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_SAL_REVIEW_PERIOD';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.SAL_REVIEW_PERIOD;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_SAL_REVIEW_PERIOD_FREQUENCY';
 l_tx_char(l_count) := l_asg_rec.SAL_REVIEW_PERIOD_FREQUENCY;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DATE_PROBATION_END';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := l_asg_rec.DATE_PROBATION_END;
 l_tx_type(l_count) := 'DATE';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PROBATION_PERIOD';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PROBATION_PERIOD;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PROBATION_UNIT';
 l_tx_char(l_count) := l_asg_rec.PROBATION_UNIT;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_NOTICE_PERIOD';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.NOTICE_PERIOD;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_NOTICE_PERIOD_UOM';
 l_tx_char(l_count) := l_asg_rec.NOTICE_PERIOD_UOM;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_EMPLOYEE_CATEGORY';
 l_tx_char(l_count) := l_asg_rec.EMPLOYEE_CATEGORY;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_WORK_AT_HOME';
 l_tx_char(l_count) := l_asg_rec.WORK_AT_HOME;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_JOB_POST_SOURCE_NAME';
 l_tx_char(l_count) := l_asg_rec.JOB_POST_SOURCE_NAME;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PERF_REVIEW_PERIOD';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PERF_REVIEW_PERIOD;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PERF_REVIEW_PERIOD_FREQUENCY';
 l_tx_char(l_count) := l_asg_rec.PERF_REVIEW_PERIOD_FREQUENCY;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_INTERNAL_ADDRESS_LINE';
 l_tx_char(l_count) := l_asg_rec.INTERNAL_ADDRESS_LINE;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_CONTRACT_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.CONTRACT_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ESTABLISHMENT_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.ESTABLISHMENT_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_COLLECTIVE_AGREEMENT_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.COLLECTIVE_AGREEMENT_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_CAGR_ID_FLEX_NUM';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.CAGR_ID_FLEX_NUM;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_CAGR_GRADE_DEF_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.CAGR_GRADE_DEF_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';



 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DEFAULT_CODE_COMB_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.DEFAULT_CODE_COMB_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_SET_OF_BOOKS_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.SET_OF_BOOKS_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';



 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_VENDOR_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.VENDOR_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_ASSIGNMENT_TYPE';
 l_tx_char(l_count) := l_asg_rec.ASSIGNMENT_TYPE;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';



 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_TITLE';
 l_tx_char(l_count) := l_asg_rec.TITLE;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PROJECT_TITLE';
 l_tx_char(l_count) := l_asg_rec.PROJECT_TITLE;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_SOURCE_TYPE';
 l_tx_char(l_count) := l_asg_rec.SOURCE_TYPE;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';



 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_VENDOR_ASSIGNMENT_NUMBER';
 l_tx_char(l_count) := l_asg_rec.VENDOR_ASSIGNMENT_NUMBER;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_VENDOR_EMPLOYEE_NUMBER';
 l_tx_char(l_count) := l_asg_rec.VENDOR_EMPLOYEE_NUMBER;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

If P_SAVE_MODE is not null then
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_SAVE_MODE';
  l_tx_char(l_count) := P_SAVE_MODE;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
  else
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_SAVE_MODE';
  l_tx_char(l_count) := 'SAVE';
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
  End if;


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_REVIEW_PROC_CALL';
 l_tx_char(l_count) := 'HrAssignment';
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_REVIEW_ACTID';
 l_tx_char(l_count) := to_char(p_activity_id);
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_HRS_LAST_DATE';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'DATE';

l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DISPLAY_POS';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DISPLAY_ORG';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DISPLAY_JOB';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DISPLAY_ASS_STATUS';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 If l_asg_rec.grade_id is not null then
    l_tx_char(l_count) := 'Y';
 End if;


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_DISPLAY_GRADE';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';


 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_GRADE_LOV';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'VARCHAR2';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_APPROVER_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := P_APPROVER_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_GRADE_LADDER_PGM_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.GRADE_LADDER_PGM_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PO_HEADER_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PO_HEADER_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PO_LINE_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.PO_LINE_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_VENDOR_SITE_ID';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := l_asg_rec.VENDOR_SITE_ID;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'NUMBER';

 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PROJ_ASGN_END';
 l_tx_char(l_count) := null;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := l_asg_rec.PROJECTED_ASSIGNMENT_END;
 l_tx_type(l_count) := 'DATE';
---vkodedal bug#8849484
 l_count := l_count + 1;
 l_tx_name(l_count) := 'P_PRIMARY_FLAG';
 l_tx_char(l_count) := l_asg_rec.PRIMARY_FLAG;
 l_tx_num(l_count)  := null;
 l_tx_date(l_count) := null;
 l_tx_type(l_count) := 'DATE';

  -- Insert all other assignment values as unchanged.

  forall i in 1..l_count
    insert into hr_api_transaction_values
        ( transaction_value_id,
          transaction_step_id,
          datatype,
          name,
          varchar2_value,
          number_value,
          date_value,
          original_varchar2_value,
          original_number_value,
          original_date_value)
     Values
        ( hr_api_transaction_values_s.nextval,
          l_transaction_step_id,
          l_tx_type(i),
          l_tx_name(i),
          l_tx_char(i),
          l_tx_num(i),
          l_tx_date(i),
          l_tx_char(i),
          l_tx_num(i),
          l_tx_date(i));

    -- Update change in pay basis value

      update hr_api_transaction_values
        set
        number_value              = p_pay_basis_id
        where transaction_step_id  = l_transaction_step_id
        and   name                 = 'P_PAY_BASIS_ID';
 end if;
  --
End;
--
---------------------------------------------------------------------------------------
--
--
PROCEDURE check_Salary_Basis_Change
        ( p_assignment_id in NUMBER
        , p_effective_date in DATE
        , p_item_key in varchar2
        , p_allow_change_date out nocopy varchar2
        , p_allow_basis_change out nocopy varchar2)
is

 Cursor csr_txn_basis_change_date Is
    select hatv1.date_value date_value
			from hr_api_transaction_values hatv,
			     hr_api_transaction_steps hats,
			     hr_api_transactions hat,
			     hr_api_transaction_values hatv1
			where hatv.NAME = 'P_PAY_BASIS_ID'
			and hatv1.NAME = 'P_EFFECTIVE_DATE'
			and hatv1.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
			and hatv.NUMBER_VALUE <> hatv.ORIGINAL_NUMBER_VALUE
			and hatv.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
			and hats.TRANSACTION_ID = hat.TRANSACTION_ID
			and hat.ASSIGNMENT_ID = p_assignment_id
			and hat.ITEM_KEY = p_item_key
			and hat.status<>'AC';

 Cursor csr_asg_basis_change_date IS
     select effective_start_date date_value
          	from per_all_assignments_f
	        where assignment_id = p_assignment_id
	        and effective_start_date >= p_effective_date
	        and pay_basis_id <> (Select pay_basis_id from per_all_assignments_f
	                               where assignment_id = p_assignment_id
                         	       and p_effective_date between effective_start_date and effective_end_date)
     order by date_value desc;
l_date date;
Begin
p_allow_change_date := 'YES';
p_allow_basis_change := 'YES';

--hr_utility.trace_on(null, 'TIGER');
--g_debug := TRUE;

  if g_debug then
      hr_utility.set_location('Enter check_Salary_Basis_Change  ', 1);
      hr_utility.set_location('p_assignment_id  '||p_assignment_id, 2);
      hr_utility.set_location('p_effective_date: '||p_effective_date, 3);
      hr_utility.set_location('p_item_key  '||p_item_key, 4);
   end if;

       Open  csr_asg_basis_change_date;
          Fetch csr_asg_basis_change_date into l_date;
               if l_date is not null then
                   p_allow_basis_change := 'ASG_BASIS';
                   p_allow_change_date := 'NO';
                   if g_debug then
                       hr_utility.set_location('ASG_BASIS  ', 5);
                   end if;
                   return;
               end if;
       Close csr_asg_basis_change_date;

       Open  csr_txn_basis_change_date;
          Fetch csr_txn_basis_change_date into l_date;
               if l_date is not null then
                   p_allow_basis_change := 'F_BASIS';
                   p_allow_change_date := 'NO';
                   if g_debug then
                       hr_utility.set_location('F_BASIS  ', 6);
                   end if;
               end if;
       Close csr_txn_basis_change_date;

End check_Salary_Basis_Change;
  --
  --
  --
  PROCEDURE delete_transaction(p_assgn_id            IN number,
                               p_effective_dt        IN date,
                               p_transaction_id      IN number,
                               p_transaction_step_id IN number,
                               p_item_key            IN varchar2,
                               p_item_type           IN varchar2,
                               p_next_change_date    In date,
                               p_changedt_curr       IN date,
                               p_changedt_last       IN date default Null,
                               p_failed_to_delete IN OUT NOCOPY varchar2,
                               p_busgroup_id         IN number)
  IS
  --
  cursor csr_recs_on_top(c_assignment_id number, c_change_date date) is
        select max(change_date)
        from  per_pay_transactions ppt,
		      hr_api_transactions hat
       where  ppt.ASSIGNMENT_ID = c_assignment_id
         and  ppt.change_date > c_change_date
		 and  ppt.transaction_id=hat.transaction_id
		 and  hat.status<>'AC';

  cursor csr_delete_recs(c_effective_dt date, c_assgn_id number, c_changedt_curr date, c_changedt_last date
                         ,c_transaction_id number) is
  Select
  	    ppt.PAY_TRANSACTION_ID,
  	    ppt.TRANSACTION_ID,
  	    ppt.TRANSACTION_STEP_ID,
  	    ppt.ITEM_TYPE,
  	    ppt.ITEM_KEY,
  	    ppt.PAY_PROPOSAL_ID,
  	    ppt.ASSIGNMENT_ID,
  	    ppt.COMPONENT_ID,
  	    ppt.REASON,
  	    ppt.PAY_BASIS_ID,
  	    ppt.BUSINESS_GROUP_ID,
  	    ppt.CHANGE_DATE,
  	    ppt.DATE_TO,
  	    ppt.last_change_date,
  	    ppt.PROPOSED_SALARY_N,
  	    ppt.CHANGE_AMOUNT_N,
  	    ppt.CHANGE_PERCENTAGE,
  	    ppb.PAY_ANNUALIZATION_FACTOR,
  	    pet.INPUT_CURRENCY_CODE,
  	    ppt.STATUS,
  	    ppt.DML_OPERATION,
  	    'TRANSACTION' from_tab,
  	    ppt.PRIOR_PROPOSED_SALARY_N,
  	    ppt.PRIOR_PAY_BASIS_ID,
  	    ppt.ATTRIBUTE_CATEGORY,
  	    ppt.ATTRIBUTE1,
  	    ppt.ATTRIBUTE2,
  	    ppt.ATTRIBUTE3,
	    ppt.ATTRIBUTE4,
	    ppt.ATTRIBUTE5,
	    ppt.ATTRIBUTE6,
	    ppt.ATTRIBUTE7,
	    ppt.ATTRIBUTE8,
	    ppt.ATTRIBUTE9,
	    ppt.ATTRIBUTE10,
	    ppt.ATTRIBUTE11,
	    ppt.ATTRIBUTE12,
	    ppt.ATTRIBUTE13,
	    ppt.ATTRIBUTE14,
	    ppt.ATTRIBUTE15,
	    ppt.ATTRIBUTE16,
	    ppt.ATTRIBUTE17,
	    ppt.ATTRIBUTE18,
	    ppt.ATTRIBUTE19,
	    ppt.ATTRIBUTE20,
	    ppt.MULTIPLE_COMPONENTS,
	    ppt.PARENT_PAY_TRANSACTION_ID,
        ppt.PRIOR_PAY_PROPOSAL_ID,
        ppt.PRIOR_PAY_TRANSACTION_ID,
        ppt.APPROVED,
        ppt.object_version_number
	from per_pay_transactions ppt,
	     per_pay_bases ppb,
	     pay_input_values_f piv,
	     pay_element_types_f pet
	  where ppt.assignment_id = c_assgn_id
	  AND ppt.PARENT_PAY_TRANSACTION_ID is null
	  AND ppt.TRANSACTION_ID = c_transaction_id
	  AND ppt.change_date between  c_changedt_last and c_changedt_curr
	  AND ppb.pay_basis_id = ppt.pay_basis_id
	  AND ppb.input_value_id = piv.input_value_id
	  AND c_effective_dt BETWEEN piv.effective_start_date AND piv.effective_end_date
	  AND piv.element_type_id = pet.element_type_id
	  AND c_effective_dt BETWEEN pet.effective_start_date AND pet.effective_end_date
	  AND ppt.status <> 'DELETE'
	Union
	  Select
	    null PAY_TRANSACTION_ID,
	    null TRANSACTION_ID,
	    null TRANSACTION_STEP_ID,
	    null  ITEM_TYPE,
	    null  ITEM_KEY,
	    pay.PAY_PROPOSAL_ID,
	    pay.ASSIGNMENT_ID ASSIGNMENT_ID,
	    null COMPONENT_ID,
	    pay.PROPOSAL_REASON REASON,
	    paaf.PAY_BASIS_ID PAY_BASIS_ID,
	    pay.BUSINESS_GROUP_ID,
	    pay.CHANGE_DATE,
	    pay.DATE_TO,
	    pay.last_change_date,
	    pay.PROPOSED_SALARY_N,
	    null change_amount_n,
	    null change_percentage,
	    ppb.PAY_ANNUALIZATION_FACTOR,
	    pet.INPUT_CURRENCY_CODE,
	    null STATUS,
	    null DML_OPERATION,
	    'PROPOSAL' from_tab,
	    null PRIOR_PROPOSED_SALARY_N,
	    null PRIOR_PAY_BASIS_ID,
	    pay.ATTRIBUTE_CATEGORY,
	    pay.ATTRIBUTE1,
	    pay.ATTRIBUTE2,
	    pay.ATTRIBUTE3,
	    pay.ATTRIBUTE4,
	    pay.ATTRIBUTE5,
	    pay.ATTRIBUTE6,
	    pay.ATTRIBUTE7,
	    pay.ATTRIBUTE8,
	    pay.ATTRIBUTE9,
	    pay.ATTRIBUTE10,
	    pay.ATTRIBUTE11,
	    pay.ATTRIBUTE12,
	    pay.ATTRIBUTE13,
	    pay.ATTRIBUTE14,
	    pay.ATTRIBUTE15,
	    pay.ATTRIBUTE16,
	    pay.ATTRIBUTE17,
	    pay.ATTRIBUTE18,
	    pay.ATTRIBUTE19,
	    pay.ATTRIBUTE20,
	    pay.MULTIPLE_COMPONENTS,
	    null PARENT_PAY_TRANSACTION_ID,
        null PRIOR_PAY_PROPOSAL_ID,
        null PRIOR_PAY_TRANSACTION_ID,
        null APPROVED,
        pay.object_version_number
    from per_pay_proposals pay,
	     per_all_assignments_f paaf,
	     per_pay_bases ppb,
	     pay_input_values_f piv,
	     pay_element_types_f pet
	where pay.assignment_id = c_assgn_id
   	  AND pay.change_date between  c_changedt_last and c_changedt_curr
	  AND pay.assignment_id =  paaf.assignment_id
	  and c_effective_dt BETWEEN paaf.effective_start_date AND paaf.effective_end_date
      --AND (p_changedt_curr BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	  --      OR p_changedt_last BETWEEN paaf.effective_start_date AND paaf.effective_end_date)
	  AND ppb.pay_basis_id = paaf.pay_basis_id AND ppb.input_value_id = piv.input_value_id
	  AND c_effective_dt    BETWEEN piv.effective_start_date AND piv.effective_end_date
	  AND piv.element_type_id = pet.element_type_id
	  AND c_effective_dt    BETWEEN pet.effective_start_date AND pet.effective_end_date
	  AND pay.pay_proposal_id not in (select nvl(pay_proposal_id, -1) from per_pay_transactions
                                       where assignment_id = pay.assignment_id
                                       and   TRANSACTION_ID = c_transaction_id)
	ORDER by change_date asc;

cursor csr_update_comps(c_parent_proposal_id in number) is
select
    component_id       ,
    pay_proposal_id    ,
    business_group_id  ,
    approved           ,
    component_reason   ,
    change_amount      ,
    change_percentage  ,
    comments           ,
    new_amount         ,
    attribute_category ,
    attribute1         ,
    attribute2         ,
    attribute3         ,
    attribute4         ,
    attribute5         ,
    attribute6         ,
    attribute7         ,
    attribute8         ,
    attribute9         ,
    attribute10        ,
    attribute11        ,
    attribute12        ,
    attribute13        ,
    attribute14        ,
    attribute15        ,
    attribute16        ,
    attribute17        ,
    attribute18        ,
    attribute19        ,
    attribute20        ,
    change_amount_n    ,
    object_version_number
from per_pay_proposal_components
where PAY_PROPOSAL_ID = c_parent_proposal_id;


    --
	l_count number(3);
	--
	l_curr_date_to date;
	--
	l_seq_val Number;
	--
	l_last_rec_from varchar2(20);
	--
	l_curr_rec_from varchar2(20);
	--
	l_curr_rec_proposal_id number;
	--
	l_last_trans_id number;
	--
	l_last_row  csr_delete_recs%rowtype;
	--
    l_proc     varchar2(72) := g_package||'delete_transaction';
    --
    l_changedt_last date;
    --
    l_last_change_date_curr date;
    --
    l_do_delete varchar2(20);
    --
    l_failed_to_delete varchar2(2) := 'N';
    --
begin
   --
   --hr_utility.trace_on(null, 'TIGER');
   --g_debug := TRUE;
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if g_debug then
      hr_utility.set_location('assgnid:'||p_assgn_id||'effDate:'||p_effective_dt||'transId:'||p_transaction_id, 10);
      hr_utility.set_location('transStepId:'||p_transaction_step_id||'itemKey:'||p_item_key||'itemtype:'||p_item_type, 10);
      hr_utility.set_location('nextChangedt:'||p_next_change_date||'currChangedt:'||p_changedt_curr||'lastChangedt:'||p_changedt_last, 10);
   end if;
   --
   l_count := 0;
   --
   if p_changedt_last is null then
      --
      if g_debug then
        hr_utility.set_location('Entering if p_changedt_last:'|| l_proc, 20);
      end if;
      --
      l_changedt_last := p_changedt_curr;
      --
   else
      --
      if g_debug then
        hr_utility.set_location('Entering else p_changedt_last:'|| l_proc, 30);
      end if;
      --
      l_changedt_last := p_changedt_last;
      --
   end if;

   p_failed_to_delete := l_failed_to_delete;

   /*
   --
   l_do_delete := check_Salary_Basis_Change(p_assgn_id,p_changedt_curr);
   --
   if l_do_delete = 'NONE' then
     --
     l_failed_to_delete := 'N';
     --
     p_failed_to_delete := l_failed_to_delete;
     --
   elsif l_do_delete = 'F_ASSIGNMENT' then
     --
     l_failed_to_delete := 'Y';
     --
     p_failed_to_delete := l_failed_to_delete;
     --
     return;
     --
   else
     --
     l_failed_to_delete := 'N';
     --
     p_failed_to_delete := l_failed_to_delete;
     --
   end if;
   */

   for delete_recs in csr_delete_recs(p_effective_dt, p_assgn_id, p_changedt_curr, l_changedt_last, p_transaction_id) loop
     --
     if g_debug then
        hr_utility.set_location(l_proc, 40);
     end if;
     --
     if l_count = 0 then
       --
       if g_debug then
         hr_utility.set_location('Entering l_count 0:'|| l_proc, 50);
       end if;
       --
       --
       l_last_rec_from := delete_recs.from_tab;
       --
       l_last_trans_id := delete_recs.pay_transaction_id;
       --
       l_last_row := delete_recs;
       --
       if l_changedt_last = p_changedt_curr then
         --
         --
         if g_debug then
           hr_utility.set_location('Entering when last date NULL:'|| l_proc, 60);
         end if;
         --
         if delete_recs.from_tab = 'TRANSACTION' then
           --
           if delete_recs.pay_proposal_id is null then
             --
             delete from per_pay_transactions
             where parent_pay_transaction_id = delete_recs.pay_transaction_id;
             --
             delete from per_pay_transactions
             where pay_transaction_id = delete_recs.pay_transaction_id;
             --
           else
             update per_pay_transactions
             set STATUS = 'DELETE',
                 DML_OPERATION = 'DELETE'
             where parent_pay_transaction_id = delete_recs.pay_transaction_id;
             --
             update per_pay_transactions
             set STATUS = 'DELETE',
                 DML_OPERATION = 'DELETE'
             where pay_transaction_id = delete_recs.pay_transaction_id;
             --
           end if;
           --
       else
           --
           --
           if g_debug then
              hr_utility.set_location('Inserting when p_changedt_last NULL:'|| l_proc, 70);
           end if;
           --
           select PER_PAY_TRANSACTIONS_S.NEXTVAL into l_seq_val from dual;
           --
           insert into per_pay_transactions
               (PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            PAY_PROPOSAL_ID,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            COMPONENT_ID,-- COMPONENT_ID,
	            REASON,-- REASON,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            BUSINESS_GROUP_ID,
	            CHANGE_DATE,
	            DATE_TO,
	            PROPOSED_SALARY_N,
	            change_amount_n,
	            change_percentage,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
	            PRIOR_PROPOSED_SALARY_N,-- PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,-- PRIOR_PAY_BASIS_ID,
	            ATTRIBUTE_CATEGORY,
	            ATTRIBUTE1,
	            ATTRIBUTE2,
	            ATTRIBUTE3,
	            ATTRIBUTE4,
	            ATTRIBUTE5,
	            ATTRIBUTE6,
	            ATTRIBUTE7,
	            ATTRIBUTE8,
	            ATTRIBUTE9,
	            ATTRIBUTE10,
	            ATTRIBUTE11,
	            ATTRIBUTE12,
	            ATTRIBUTE13,
	            ATTRIBUTE14,
	            ATTRIBUTE15,
	            ATTRIBUTE16,
	            ATTRIBUTE17,
	            ATTRIBUTE18,
	            ATTRIBUTE19,
	            ATTRIBUTE20,
	            MULTIPLE_COMPONENTS,
	            PARENT_PAY_TRANSACTION_ID,-- PARENT_PAY_TRANSACTION_ID,
                PRIOR_PAY_PROPOSAL_ID,-- PRIOR_PAY_PROPOSAL_ID,
                PRIOR_PAY_TRANSACTION_ID,-- PRIOR_PAY_TRANSACTION_ID,
                APPROVED,               -- APPROVED
                object_version_number)
         values(l_seq_val ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            l_last_row.PAY_PROPOSAL_ID,
	            l_last_row.ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            l_last_row.COMPONENT_ID,
	            l_last_row.REASON,-- REASON,
	            l_last_row.PAY_BASIS_ID,-- PAY_BASIS_ID,
	            l_last_row.BUSINESS_GROUP_ID,
	            l_last_row.CHANGE_DATE,
	            l_curr_date_to, --update last recs date_to to curr_rec
	            l_last_row.PROPOSED_SALARY_N,-- proposed_salary_n,
	            l_last_row.change_amount_n,  -- change_amount_n,
	            l_last_row.change_percentage,-- change_percentage,
	            'DELETE',-- STATUS,
	            'DELETE',-- DML_OPERATION,
	            l_last_row.PRIOR_PROPOSED_SALARY_N,
	            l_last_row.PRIOR_PAY_BASIS_ID,
	            l_last_row.ATTRIBUTE_CATEGORY,
	            l_last_row.ATTRIBUTE1,
	            l_last_row.ATTRIBUTE2,
	            l_last_row.ATTRIBUTE3,
	            l_last_row.ATTRIBUTE4,
	            l_last_row.ATTRIBUTE5,
	            l_last_row.ATTRIBUTE6,
	            l_last_row.ATTRIBUTE7,
	            l_last_row.ATTRIBUTE8,
	            l_last_row.ATTRIBUTE9,
	            l_last_row.ATTRIBUTE10,
	            l_last_row.ATTRIBUTE11,
	            l_last_row.ATTRIBUTE12,
	            l_last_row.ATTRIBUTE13,
	            l_last_row.ATTRIBUTE14,
	            l_last_row.ATTRIBUTE15,
	            l_last_row.ATTRIBUTE16,
	            l_last_row.ATTRIBUTE17,
	            l_last_row.ATTRIBUTE18,
	            l_last_row.ATTRIBUTE19,
	            l_last_row.ATTRIBUTE20,
	            l_last_row.MULTIPLE_COMPONENTS,
	            l_last_row.PARENT_PAY_TRANSACTION_ID,
                l_last_row.PRIOR_PAY_PROPOSAL_ID,
                l_last_row.PRIOR_PAY_TRANSACTION_ID,
                l_last_row.APPROVED,
                l_last_row.OBJECT_VERSION_NUMBER);
           --
           if l_last_row.multiple_components = 'Y' then
           --
             for rec_update_comps in csr_update_comps(l_last_row.pay_proposal_id) loop
               --
               insert into per_pay_transactions
                (PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            PAY_PROPOSAL_ID,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            COMPONENT_ID,-- COMPONENT_ID,
	            REASON,-- REASON,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            BUSINESS_GROUP_ID,
	            CHANGE_DATE,
	            DATE_TO,
	            PROPOSED_SALARY_N,
	            change_amount_n,
	            change_percentage,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
	            COMMENTS,
	            PRIOR_PROPOSED_SALARY_N,-- PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,-- PRIOR_PAY_BASIS_ID,
	            ATTRIBUTE_CATEGORY,
	            ATTRIBUTE1,
	            ATTRIBUTE2,
	            ATTRIBUTE3,
	            ATTRIBUTE4,
	            ATTRIBUTE5,
	            ATTRIBUTE6,
	            ATTRIBUTE7,
	            ATTRIBUTE8,
	            ATTRIBUTE9,
	            ATTRIBUTE10,
	            ATTRIBUTE11,
	            ATTRIBUTE12,
	            ATTRIBUTE13,
	            ATTRIBUTE14,
	            ATTRIBUTE15,
	            ATTRIBUTE16,
	            ATTRIBUTE17,
	            ATTRIBUTE18,
	            ATTRIBUTE19,
	            ATTRIBUTE20,
	            MULTIPLE_COMPONENTS,
	            PARENT_PAY_TRANSACTION_ID,-- PARENT_PAY_TRANSACTION_ID,
                PRIOR_PAY_PROPOSAL_ID,-- PRIOR_PAY_PROPOSAL_ID,
                PRIOR_PAY_TRANSACTION_ID,-- PRIOR_PAY_TRANSACTION_ID,
                APPROVED,
                object_version_number
             )
             values(PER_PAY_TRANSACTIONS_S.NEXTVAL  ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            rec_update_comps.PAY_PROPOSAL_ID,
	            l_last_row.ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            rec_update_comps.COMPONENT_ID,
	            rec_update_comps.component_reason,-- REASON,
	            l_last_row.PAY_BASIS_ID,-- PAY_BASIS_ID,
	            l_last_row.BUSINESS_GROUP_ID,
	            null,
	            null, --update last recs date_to to curr_rec
	            null,-- proposed_salary_n,
	            rec_update_comps.CHANGE_AMOUNT_N,-- change_amount_n,
	            rec_update_comps.CHANGE_PERCENTAGE, -- change_percentage,
	            'DELETE',-- STATUS,
	            'DELETE',-- DML_OPERATION,
	            rec_update_comps.comments,
	            null, --
	            null, --l_last_row.PRIOR_PAY_BASIS_ID,
	            rec_update_comps.ATTRIBUTE_CATEGORY,
	            rec_update_comps.ATTRIBUTE1,
	            rec_update_comps.ATTRIBUTE2,
	            rec_update_comps.ATTRIBUTE3,
	            rec_update_comps.ATTRIBUTE4,
	            rec_update_comps.ATTRIBUTE5,
	            rec_update_comps.ATTRIBUTE6,
	            rec_update_comps.ATTRIBUTE7,
	            rec_update_comps.ATTRIBUTE8,
	            rec_update_comps.ATTRIBUTE9,
	            rec_update_comps.ATTRIBUTE10,
	            rec_update_comps.ATTRIBUTE11,
	            rec_update_comps.ATTRIBUTE12,
	            rec_update_comps.ATTRIBUTE13,
	            rec_update_comps.ATTRIBUTE14,
	            rec_update_comps.ATTRIBUTE15,
	            rec_update_comps.ATTRIBUTE16,
	            rec_update_comps.ATTRIBUTE17,
	            rec_update_comps.ATTRIBUTE18,
	            rec_update_comps.ATTRIBUTE19,
	            rec_update_comps.ATTRIBUTE20,
	            null, --l_last_row.MULTIPLE_COMPONENTS,
	            l_seq_val, --l_last_row.PARENT_PAY_TRANSACTION_ID,
                null, --l_last_row.PRIOR_PAY_PROPOSAL_ID,
                null, --l_last_row.PRIOR_PAY_TRANSACTION_ID,
                rec_update_comps.APPROVED,
                rec_update_comps.OBJECT_VERSION_NUMBER
             );
             end loop;
             --
           end if;
           --
         end if;
         --
       end if;
       --
     elsif l_count = 1 then
       --
       if g_debug then
         hr_utility.set_location('Entering l_count 1:'|| l_proc, 80);
       end if;
       --
       l_curr_rec_from := delete_recs.from_tab;
       --
       l_curr_date_to := delete_recs.date_to;
       --
       l_curr_rec_proposal_id := delete_recs.pay_proposal_id;
       --
       if l_last_rec_from = 'TRANSACTION' then
         --
         if g_debug then
           hr_utility.set_location('Entering last rec TRANS:'|| l_proc, 90);
         end if;
         --
         --
         --update the last record with current recs date_to
         update per_pay_transactions
         set date_to = l_curr_date_to
         where pay_transaction_id = l_last_trans_id;
         --
       else
         --
         --
         if g_debug then
           hr_utility.set_location('Inserting last rec from PROPO:'|| l_proc, 120);
         end if;
         --
         --
         select PER_PAY_TRANSACTIONS_S.NEXTVAL into l_seq_val from dual;--replace by Seq number
         --
         insert into per_pay_transactions
               (PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            PAY_PROPOSAL_ID,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            COMPONENT_ID,-- COMPONENT_ID,
	            REASON,-- REASON,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            BUSINESS_GROUP_ID,
	            CHANGE_DATE,
	            DATE_TO,
	            last_change_date,
	            PROPOSED_SALARY_N,
	            change_amount_n,
	            change_percentage,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
	            PRIOR_PROPOSED_SALARY_N,-- PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,-- PRIOR_PAY_BASIS_ID,
	            ATTRIBUTE_CATEGORY,
	            ATTRIBUTE1,
	            ATTRIBUTE2,
	            ATTRIBUTE3,
	            ATTRIBUTE4,
	            ATTRIBUTE5,
	            ATTRIBUTE6,
	            ATTRIBUTE7,
	            ATTRIBUTE8,
	            ATTRIBUTE9,
	            ATTRIBUTE10,
	            ATTRIBUTE11,
	            ATTRIBUTE12,
	            ATTRIBUTE13,
	            ATTRIBUTE14,
	            ATTRIBUTE15,
	            ATTRIBUTE16,
	            ATTRIBUTE17,
	            ATTRIBUTE18,
	            ATTRIBUTE19,
	            ATTRIBUTE20,
	            MULTIPLE_COMPONENTS,
	            PARENT_PAY_TRANSACTION_ID,-- PARENT_PAY_TRANSACTION_ID,
                PRIOR_PAY_PROPOSAL_ID,-- PRIOR_PAY_PROPOSAL_ID,
                PRIOR_PAY_TRANSACTION_ID,-- PRIOR_PAY_TRANSACTION_ID,
                APPROVED, -- APPROVED
                object_version_number)
         values(l_seq_val ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            l_last_row.PAY_PROPOSAL_ID,
	            l_last_row.ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            l_last_row.COMPONENT_ID,
	            l_last_row.REASON,-- REASON,
	            l_last_row.PAY_BASIS_ID,-- PAY_BASIS_ID,
	            l_last_row.BUSINESS_GROUP_ID,
	            l_last_row.CHANGE_DATE,
	            l_curr_date_to, --update last recs date_to to curr_rec
	            l_last_row.last_change_date,
	            l_last_row.PROPOSED_SALARY_N, -- proposed_salary_n,
	            l_last_row.change_amount_n,   -- change_amount_n,
	            l_last_row.change_percentage, -- change_percentage,
	            'DATE_ADJUSTED',-- STATUS,
	            'UPDATE',-- DML_OPERATION,
	            l_last_row.PRIOR_PROPOSED_SALARY_N,
	            l_last_row.PRIOR_PAY_BASIS_ID,
	            l_last_row.ATTRIBUTE_CATEGORY,
	            l_last_row.ATTRIBUTE1,
	            l_last_row.ATTRIBUTE2,
	            l_last_row.ATTRIBUTE3,
	            l_last_row.ATTRIBUTE4,
	            l_last_row.ATTRIBUTE5,
	            l_last_row.ATTRIBUTE6,
	            l_last_row.ATTRIBUTE7,
	            l_last_row.ATTRIBUTE8,
	            l_last_row.ATTRIBUTE9,
	            l_last_row.ATTRIBUTE10,
	            l_last_row.ATTRIBUTE11,
	            l_last_row.ATTRIBUTE12,
	            l_last_row.ATTRIBUTE13,
	            l_last_row.ATTRIBUTE14,
	            l_last_row.ATTRIBUTE15,
	            l_last_row.ATTRIBUTE16,
	            l_last_row.ATTRIBUTE17,
	            l_last_row.ATTRIBUTE18,
	            l_last_row.ATTRIBUTE19,
	            l_last_row.ATTRIBUTE20,
	            l_last_row.MULTIPLE_COMPONENTS,
	            l_last_row.PARENT_PAY_TRANSACTION_ID,
                l_last_row.PRIOR_PAY_PROPOSAL_ID,
                l_last_row.PRIOR_PAY_TRANSACTION_ID,
                l_last_row.APPROVED,
                l_last_row.OBJECT_VERSION_NUMBER
                );
         if l_last_row.MULTIPLE_COMPONENTS = 'Y' then
           --
           for rec_update_comps in csr_update_comps(l_last_row.pay_proposal_id) loop
             insert into per_pay_transactions
             (PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            PAY_PROPOSAL_ID,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            COMPONENT_ID,-- COMPONENT_ID,
	            REASON,-- REASON,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            BUSINESS_GROUP_ID,
	            CHANGE_DATE,
	            DATE_TO,
	            PROPOSED_SALARY_N,
	            change_amount_n,
	            change_percentage,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
	            COMMENTS,
	            PRIOR_PROPOSED_SALARY_N,-- PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,-- PRIOR_PAY_BASIS_ID,
	            ATTRIBUTE_CATEGORY,
	            ATTRIBUTE1,
	            ATTRIBUTE2,
	            ATTRIBUTE3,
	            ATTRIBUTE4,
	            ATTRIBUTE5,
	            ATTRIBUTE6,
	            ATTRIBUTE7,
	            ATTRIBUTE8,
	            ATTRIBUTE9,
	            ATTRIBUTE10,
	            ATTRIBUTE11,
	            ATTRIBUTE12,
	            ATTRIBUTE13,
	            ATTRIBUTE14,
	            ATTRIBUTE15,
	            ATTRIBUTE16,
	            ATTRIBUTE17,
	            ATTRIBUTE18,
	            ATTRIBUTE19,
	            ATTRIBUTE20,
	            MULTIPLE_COMPONENTS,
	            PARENT_PAY_TRANSACTION_ID,-- PARENT_PAY_TRANSACTION_ID,
                PRIOR_PAY_PROPOSAL_ID,-- PRIOR_PAY_PROPOSAL_ID,
                PRIOR_PAY_TRANSACTION_ID,-- PRIOR_PAY_TRANSACTION_ID,
                APPROVED,
                object_version_number
             )
             values(PER_PAY_TRANSACTIONS_S.NEXTVAL  ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            rec_update_comps.PAY_PROPOSAL_ID,
	            l_last_row.ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            rec_update_comps.COMPONENT_ID,
	            rec_update_comps.component_reason,-- REASON,
	            l_last_row.PAY_BASIS_ID,-- PAY_BASIS_ID,
	            l_last_row.BUSINESS_GROUP_ID,
	            null,
	            null, --update last recs date_to to curr_rec
	            null,-- proposed_salary_n,
	            rec_update_comps.CHANGE_AMOUNT_N,-- change_amount_n,
	            rec_update_comps.CHANGE_PERCENTAGE, -- change_percentage,
	            'DATE_ADJUSTED',-- STATUS,
	            'UPDATE',-- DML_OPERATION,
	            rec_update_comps.comments,
	            null, --
	            null, --l_last_row.PRIOR_PAY_BASIS_ID,
	            rec_update_comps.ATTRIBUTE_CATEGORY,
	            rec_update_comps.ATTRIBUTE1,
	            rec_update_comps.ATTRIBUTE2,
	            rec_update_comps.ATTRIBUTE3,
	            rec_update_comps.ATTRIBUTE4,
	            rec_update_comps.ATTRIBUTE5,
	            rec_update_comps.ATTRIBUTE6,
	            rec_update_comps.ATTRIBUTE7,
	            rec_update_comps.ATTRIBUTE8,
	            rec_update_comps.ATTRIBUTE9,
	            rec_update_comps.ATTRIBUTE10,
	            rec_update_comps.ATTRIBUTE11,
	            rec_update_comps.ATTRIBUTE12,
	            rec_update_comps.ATTRIBUTE13,
	            rec_update_comps.ATTRIBUTE14,
	            rec_update_comps.ATTRIBUTE15,
	            rec_update_comps.ATTRIBUTE16,
	            rec_update_comps.ATTRIBUTE17,
	            rec_update_comps.ATTRIBUTE18,
	            rec_update_comps.ATTRIBUTE19,
	            rec_update_comps.ATTRIBUTE20,
	            null, --l_last_row.MULTIPLE_COMPONENTS,
	            l_seq_val, --l_last_row.PARENT_PAY_TRANSACTION_ID,
                null, --l_last_row.PRIOR_PAY_PROPOSAL_ID,
                null, --l_last_row.PRIOR_PAY_TRANSACTION_ID,
                rec_update_comps.APPROVED,
                rec_update_comps.OBJECT_VERSION_NUMBER
             );
             end loop;
           --
         end if;
         --
      end if;
      --
      --if curr rec to be deleted is from Trans
      if delete_recs.from_tab = 'TRANSACTION' then
         --
         --
         if g_debug then
              hr_utility.set_location('Entering curr rec from TRANS:'|| l_proc, 100);
         end if;
         --

         if delete_recs.pay_proposal_id is null then
             --
             l_last_change_date_curr := delete_recs.last_change_date;
             --
             delete from per_pay_transactions
             where parent_pay_transaction_id = delete_recs.pay_transaction_id;
             --
             delete from per_pay_transactions
             where pay_transaction_id = delete_recs.pay_transaction_id;
             --
           else
             --
             l_last_change_date_curr := delete_recs.last_change_date;
             --
             update per_pay_transactions
             set STATUS = 'DELETE',
                 DML_OPERATION = 'DELETE'
             where parent_pay_transaction_id = delete_recs.pay_transaction_id;
             --
             update per_pay_transactions
             set STATUS = 'DELETE',
                 DML_OPERATION = 'DELETE'
             where pay_transaction_id = delete_recs.pay_transaction_id;

         end if;
         --
      else
           --
           select PER_PAY_TRANSACTIONS_S.NEXTVAL into l_seq_val from dual; --replace by Seq number
           --
           --
            if g_debug then
              hr_utility.set_location('Inserting curr rec PROPOSAL:'|| l_proc, 110);
            end if;
           --
           l_last_change_date_curr := delete_recs.last_change_date;
           --
           insert into per_pay_transactions
               (PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            PAY_PROPOSAL_ID,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            COMPONENT_ID,-- COMPONENT_ID,
	            REASON,-- REASON,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            BUSINESS_GROUP_ID,
	            CHANGE_DATE,
	            DATE_TO,
	            last_change_date,
	            PROPOSED_SALARY_N,
	            change_amount_n,
	            change_percentage,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
	            PRIOR_PROPOSED_SALARY_N,-- PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,-- PRIOR_PAY_BASIS_ID,
	            ATTRIBUTE_CATEGORY,
	            ATTRIBUTE1,
	            ATTRIBUTE2,
	            ATTRIBUTE3,
	            ATTRIBUTE4,
	            ATTRIBUTE5,
	            ATTRIBUTE6,
	            ATTRIBUTE7,
	            ATTRIBUTE8,
	            ATTRIBUTE9,
	            ATTRIBUTE10,
	            ATTRIBUTE11,
	            ATTRIBUTE12,
	            ATTRIBUTE13,
	            ATTRIBUTE14,
	            ATTRIBUTE15,
	            ATTRIBUTE16,
	            ATTRIBUTE17,
	            ATTRIBUTE18,
	            ATTRIBUTE19,
	            ATTRIBUTE20,
	            MULTIPLE_COMPONENTS,
	            PARENT_PAY_TRANSACTION_ID,-- PARENT_PAY_TRANSACTION_ID,
                PRIOR_PAY_PROPOSAL_ID,-- PRIOR_PAY_PROPOSAL_ID,
                PRIOR_PAY_TRANSACTION_ID,-- PRIOR_PAY_TRANSACTION_ID,
                APPROVED,-- APPROVED
                object_version_number)
         values(l_seq_val ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            delete_recs.PAY_PROPOSAL_ID,
	            delete_recs.ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            delete_recs.COMPONENT_ID,
	            delete_recs.REASON,-- REASON,
	            delete_recs.PAY_BASIS_ID,-- PAY_BASIS_ID,
	            delete_recs.BUSINESS_GROUP_ID,
	            delete_recs.CHANGE_DATE,
	            delete_recs.DATE_TO,
	            delete_recs.last_change_date,
	            delete_recs.PROPOSED_SALARY_N,
	            delete_recs.change_amount_n,
	            delete_recs.change_percentage,
	            'DELETE',-- STATUS,
	            'DELETE',-- DML_OPERATION,
	            delete_recs.PRIOR_PROPOSED_SALARY_N,
	            delete_recs.PRIOR_PAY_BASIS_ID,
	            delete_recs.ATTRIBUTE_CATEGORY,
	            delete_recs.ATTRIBUTE1,
	            delete_recs.ATTRIBUTE2,
	            delete_recs.ATTRIBUTE3,
	            delete_recs.ATTRIBUTE4,
	            delete_recs.ATTRIBUTE5,
	            delete_recs.ATTRIBUTE6,
	            delete_recs.ATTRIBUTE7,
	            delete_recs.ATTRIBUTE8,
	            delete_recs.ATTRIBUTE9,
	            delete_recs.ATTRIBUTE10,
	            delete_recs.ATTRIBUTE11,
	            delete_recs.ATTRIBUTE12,
	            delete_recs.ATTRIBUTE13,
	            delete_recs.ATTRIBUTE14,
	            delete_recs.ATTRIBUTE15,
	            delete_recs.ATTRIBUTE16,
	            delete_recs.ATTRIBUTE17,
	            delete_recs.ATTRIBUTE18,
	            delete_recs.ATTRIBUTE19,
	            delete_recs.ATTRIBUTE20,
	            delete_recs.MULTIPLE_COMPONENTS,
	            delete_recs.PARENT_PAY_TRANSACTION_ID,
                delete_recs.PRIOR_PAY_PROPOSAL_ID,
                delete_recs.PRIOR_PAY_TRANSACTION_ID,
                delete_recs.APPROVED,
                delete_recs.OBJECT_VERSION_NUMBER
                );
           --
           if delete_recs.MULTIPLE_COMPONENTS = 'Y' then
           --
           for rec_update_comps in csr_update_comps(delete_recs.pay_proposal_id) loop
             insert into per_pay_transactions
             (PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            PAY_PROPOSAL_ID,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            COMPONENT_ID,-- COMPONENT_ID,
	            REASON,-- REASON,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            BUSINESS_GROUP_ID,
	            CHANGE_DATE,
	            DATE_TO,
	            PROPOSED_SALARY_N,
	            change_amount_n,
	            change_percentage,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
	            COMMENTS,
	            PRIOR_PROPOSED_SALARY_N,-- PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,-- PRIOR_PAY_BASIS_ID,
	            ATTRIBUTE_CATEGORY,
	            ATTRIBUTE1,
	            ATTRIBUTE2,
	            ATTRIBUTE3,
	            ATTRIBUTE4,
	            ATTRIBUTE5,
	            ATTRIBUTE6,
	            ATTRIBUTE7,
	            ATTRIBUTE8,
	            ATTRIBUTE9,
	            ATTRIBUTE10,
	            ATTRIBUTE11,
	            ATTRIBUTE12,
	            ATTRIBUTE13,
	            ATTRIBUTE14,
	            ATTRIBUTE15,
	            ATTRIBUTE16,
	            ATTRIBUTE17,
	            ATTRIBUTE18,
	            ATTRIBUTE19,
	            ATTRIBUTE20,
	            MULTIPLE_COMPONENTS,
	            PARENT_PAY_TRANSACTION_ID,-- PARENT_PAY_TRANSACTION_ID,
                PRIOR_PAY_PROPOSAL_ID,-- PRIOR_PAY_PROPOSAL_ID,
                PRIOR_PAY_TRANSACTION_ID,-- PRIOR_PAY_TRANSACTION_ID,
                APPROVED,
                object_version_number
             )
             values(PER_PAY_TRANSACTIONS_S.NEXTVAL  ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            rec_update_comps.PAY_PROPOSAL_ID,
	            delete_recs.ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            rec_update_comps.COMPONENT_ID,
	            rec_update_comps.component_reason,-- REASON,
	            delete_recs.PAY_BASIS_ID,-- PAY_BASIS_ID,
	            delete_recs.BUSINESS_GROUP_ID,
	            null,
	            null, --update last recs date_to to curr_rec
	            null,-- proposed_salary_n,
	            rec_update_comps.CHANGE_AMOUNT_N,-- change_amount_n,
	            rec_update_comps.CHANGE_PERCENTAGE, -- change_percentage,
	            'DELETE',-- STATUS,
	            'DELETE',-- DML_OPERATION,
	            rec_update_comps.comments,
	            null, --
	            null, --l_last_row.PRIOR_PAY_BASIS_ID,
	            rec_update_comps.ATTRIBUTE_CATEGORY,
	            rec_update_comps.ATTRIBUTE1,
	            rec_update_comps.ATTRIBUTE2,
	            rec_update_comps.ATTRIBUTE3,
	            rec_update_comps.ATTRIBUTE4,
	            rec_update_comps.ATTRIBUTE5,
	            rec_update_comps.ATTRIBUTE6,
	            rec_update_comps.ATTRIBUTE7,
	            rec_update_comps.ATTRIBUTE8,
	            rec_update_comps.ATTRIBUTE9,
	            rec_update_comps.ATTRIBUTE10,
	            rec_update_comps.ATTRIBUTE11,
	            rec_update_comps.ATTRIBUTE12,
	            rec_update_comps.ATTRIBUTE13,
	            rec_update_comps.ATTRIBUTE14,
	            rec_update_comps.ATTRIBUTE15,
	            rec_update_comps.ATTRIBUTE16,
	            rec_update_comps.ATTRIBUTE17,
	            rec_update_comps.ATTRIBUTE18,
	            rec_update_comps.ATTRIBUTE19,
	            rec_update_comps.ATTRIBUTE20,
	            null, --l_last_row.MULTIPLE_COMPONENTS,
	            l_seq_val, --l_last_row.PARENT_PAY_TRANSACTION_ID,
                null, --l_last_row.PRIOR_PAY_PROPOSAL_ID,
                null, --l_last_row.PRIOR_PAY_TRANSACTION_ID,
                rec_update_comps.APPROVED,
                rec_update_comps.OBJECT_VERSION_NUMBER
             );
             end loop;
           --
         end if;
         --
       end if;
       --
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location('Incrementing l_count'|| l_proc, 55);
    end if;
    --
    l_count := l_count + 1;
    --
  end loop;
  --
  update_transaction(p_assgn_id, p_transaction_id, l_changedt_last,l_last_change_date_curr, p_busgroup_id);
  --
  --
  open csr_recs_on_top(p_assgn_id, l_last_row.change_date);
      fetch csr_recs_on_top into l_changedt_last;
  close csr_recs_on_top;
  --
  --Delete the only record from transaction
  --if it comes from pay_proposal
  --and there are no records on top of it in DELETE status
  --
  if     l_last_rec_from = 'TRANSACTION'
     and l_curr_rec_from = 'TRANSACTION'
     and l_curr_rec_proposal_id is null
     and p_next_change_date is null
     and l_changedt_last is null
     and l_last_row.pay_proposal_id is not null
     and l_last_row.status = 'DATE_ADJUSTED' then
    --
    delete from per_pay_transactions
    where PAY_TRANSACTION_ID = l_last_row.PAY_TRANSACTION_ID;
    --
  end if;
  --
End delete_transaction;
--
--
--
function update_component_transaction(p_pay_transaction_id  Number
                                     ,p_ASSIGNMENT_ID  Number
                                     ,p_change_date  date
                                     ,p_prior_proposed_salary  Number default Null
                                     ,p_prior_proposal_id Number      default Null
                                     ,p_prior_transaction_id Number   default Null
                                     ,p_prior_pay_basis_id Number     default Null
                                     ,p_update_prior varchar2         default 'N'
                                     ,p_xchg_rate in Number
                                     )
return Number
IS
cursor csr_update_comp(p_pay_transaction_id number,p_ASSIGNMENT_ID number,p_change_date date)
IS
    Select
	      ppt.pay_transaction_id,
          ppt.PROPOSED_SALARY_N,
	      ppt.CHANGE_AMOUNT_N,
	      ppt.CHANGE_PERCENTAGE
	 from per_pay_transactions ppt
	where ppt.PARENT_PAY_TRANSACTION_ID = p_pay_transaction_id
      AND ppt.assignment_id = p_ASSIGNMENT_ID
	  --AND ppt.change_date = p_change_date
	  AND ppt.status <> 'DELETE';
	  --
	  l_change_amount_comp number;
	  --
      l_proc     varchar2(72) := g_package||'update_component_transaction';
      --
begin
      --
      if g_debug then
        hr_utility.set_location('Entering:'|| l_proc, 10);
      end if;
      --
      --
      --hr_utility.trace_on(null, 'TIGER');
      --g_debug := TRUE;
      --
      l_change_amount_comp := 0 ;
      --
      for update_comp_recs in csr_update_comp (p_pay_transaction_id,
                                               p_ASSIGNMENT_ID,
                                               p_change_date) loop
        --
        --computing the change amount for each component and storing it
        l_change_amount_comp := l_change_amount_comp + (update_comp_recs.change_percentage * p_prior_proposed_salary*p_xchg_rate/100);
        --
        --
        if g_debug then
          hr_utility.set_location('Entering:l_change amount'||l_change_amount_comp||l_proc, 10);
          hr_utility.set_location('Entering:prior PROPOSED_SALARY_N'||p_prior_proposed_salary||l_proc, 10);
        end if;
        --
        if p_update_prior = 'Y' then
          --
          --
          if g_debug then
            hr_utility.set_location('Entering: prior Update:p_prior_transaction_id'||p_prior_transaction_id, 10);
          end if;
          --
          update per_pay_transactions
             set change_amount_n = (update_comp_recs.change_percentage * p_prior_proposed_salary*p_xchg_rate/100),
                 PRIOR_PROPOSED_SALARY_N = p_prior_proposed_salary,
                 PRIOR_PAY_PROPOSAL_ID = p_prior_proposal_id,
                 PRIOR_PAY_TRANSACTION_ID = p_prior_transaction_id,
                 PRIOR_PAY_BASIS_ID = p_prior_pay_basis_id
          where PAY_TRANSACTION_ID = update_comp_recs.PAY_TRANSACTION_ID
            --and change_date = p_change_date
            and assignment_id = p_ASSIGNMENT_ID;
          --
        else
          --
          if g_debug then
            hr_utility.set_location('Entering: Else of prior Update'||l_proc, 10);
          end if;
          --
          update per_pay_transactions
             set change_amount_n = (update_comp_recs.change_percentage * p_prior_proposed_salary*p_xchg_rate/100)
          where PAY_TRANSACTION_ID = update_comp_recs.PAY_TRANSACTION_ID
            --and change_date = p_change_date
            and assignment_id = p_ASSIGNMENT_ID;
          --
        end if;
        --
      end loop;
      --
      return l_change_amount_comp;
      --
end update_component_transaction;
--
--
--
PROCEDURE update_transaction(p_assgn_id IN number,
                             p_transaction_id IN number,
                             p_changedate_curr IN date,
                             p_last_change_date IN date,
                             p_busgroup_id IN number)
IS
cursor csr_update_recs(c_assgn_id number, c_changedate_curr date, c_transaction_id number) is
  --cursor to fetch data from transactions which needs to be updated
  Select
	    ppt.pay_transaction_id,
	    ppt.pay_proposal_id,
	    ppt.pay_basis_id,
	    ppt.assignment_id,
	    ppt.change_date,
	    ppt.last_change_date,
  	    ppt.MULTIPLE_COMPONENTS,
        ppt.PROPOSED_SALARY_N,
	    ppt.CHANGE_AMOUNT_N,
	    ppt.CHANGE_PERCENTAGE,
	    ppt.PRIOR_PROPOSED_SALARY_N,
	    ppt.PRIOR_PAY_BASIS_ID,
	    ppt.PARENT_PAY_TRANSACTION_ID,
        ppt.PRIOR_PAY_PROPOSAL_ID,
        ppt.PRIOR_PAY_TRANSACTION_ID,
        pet.input_currency_code,
        ppt.object_version_number
   from per_pay_transactions ppt,
         per_pay_bases ppb,
	     pay_input_values_f piv,
	     pay_element_types_f pet
  where   ppt.assignment_id = c_assgn_id
	  AND ppt.PARENT_PAY_TRANSACTION_ID is null
	  AND ppt.TRANSACTION_ID = c_transaction_id
	  AND ppt.change_date >= c_changedate_curr
	  AND ppb.pay_basis_id = ppt.pay_basis_id
	  AND ppb.input_value_id = piv.input_value_id
	  AND ppt.change_date BETWEEN piv.effective_start_date AND piv.effective_end_date
	  AND piv.element_type_id = pet.element_type_id
	  AND ppt.change_date BETWEEN pet.effective_start_date AND pet.effective_end_date
	  AND ppt.status <> 'DELETE'
  --where ppt.assignment_id = c_assgn_id
  --  AND ppt.TRANSACTION_ID = c_transaction_id
  --  AND ppt.change_date >= c_changedate_curr
  --  AND ppt.status <> 'DELETE'
  --  AND ppt.PARENT_PAY_TRANSACTION_ID is null
  order by change_date asc;
      --
	  l_count number(3);
	  --
	  l_last_rec_from varchar2(20);
	  --
	  l_prior_trans_id number;
	  --
	  l_prior_proposal_id  number;
	  --
	  l_prior_proposed_sal number;
	  --
	  l_prior_pay_basis_id number;
	  --
	  l_change_amount number;
	  --
	  l_last_change_date date;
	  --
	  l_update_rec csr_update_recs%rowtype;
	  --
      l_proc     varchar2(72) := g_package||'update_transaction';
      --
      l_xchg_rate number;
      --
      l_last_currency varchar2(10);
      --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   --
   --hr_utility.trace_on(null, 'TIGER');
   --g_debug := TRUE;
   --
   l_count := 0;
   --
   l_change_amount := 0;
   --
   l_prior_proposed_sal := 0;
   --
   for update_recs in csr_update_recs(p_assgn_id, p_changedate_curr, p_transaction_id) loop
     --
     if g_debug then
        hr_utility.set_location(l_proc, 25);
     end if;
     --
     l_change_amount := 0;
     --
     if l_count = 0 then
       --
       if g_debug then
         hr_utility.set_location(l_proc||'l_count 0', 25);
       end if;
       --
       --
       l_prior_trans_id := update_recs.pay_transaction_id;
       --
       l_prior_proposal_id := update_recs.pay_proposal_id;
       --
       l_prior_proposed_sal := update_recs.PROPOSED_SALARY_N;
       --
       l_prior_pay_basis_id := update_recs.pay_basis_id;
       --
       l_last_change_date := update_recs.change_date;
       --
       l_last_currency := update_recs.input_currency_code;
       --
       if p_last_change_date is null then
          --
          if g_debug then
            hr_utility.set_location('when last_change_date is null'||l_proc, 30);
            hr_utility.set_location('l_prior_trans_id'||l_prior_trans_id||l_proc, 30);
          end if;
          --need to change prior record as well
          --when deleting only rec from PPP
          update per_pay_transactions
          set CHANGE_PERCENTAGE = null,
              CHANGE_AMOUNT_N = 0
          where parent_pay_transaction_id = l_prior_trans_id;
          --
          update per_pay_transactions
          set CHANGE_AMOUNT_N = l_prior_proposed_sal,
              CHANGE_PERCENTAGE = null,
              last_change_date = null,
              PRIOR_PAY_PROPOSAL_ID = null,
              PRIOR_PAY_TRANSACTION_ID = null,
              PRIOR_PROPOSED_SALARY_N = 0
          --    PRIOR_PAY_BASIS_ID = null
          where pay_transaction_id = l_prior_trans_id;
          --
       end if;
       --
     elsif l_count = 1 then
       --immediate record to last record
       --to be updated in case of UPD/DEL
       --
       if g_debug then
         hr_utility.set_location(l_proc||'l_count 1', 25);
       end if;
       --
       if update_recs.MULTIPLE_COMPONENTS = 'N' then
         --
         if g_debug then
           hr_utility.set_location('No MULTIPLE_COMPONENTS '||l_prior_proposed_sal||l_proc, 25);
         end if;
         --
         if l_last_currency <> update_recs.input_currency_code then
            select PER_SALADMIN_UTILITY.get_currency_rate(l_last_currency,update_recs.input_currency_code,update_recs.change_date,p_busgroup_id) into l_xchg_rate
            from dual;
         else
            l_xchg_rate := 1;
         end if;
         --
         --
         --update only the % , change_amount remains same
         update per_pay_transactions
         set    PRIOR_PROPOSED_SALARY_N = l_prior_proposed_sal,
         PRIOR_PAY_PROPOSAL_ID = l_prior_proposal_id,
         PRIOR_PAY_TRANSACTION_ID = l_prior_trans_id,
         PRIOR_PAY_BASIS_ID = l_prior_pay_basis_id,
         last_change_date = l_last_change_date,
         CHANGE_PERCENTAGE = round(((update_recs.proposed_salary_n - (l_prior_proposed_sal*l_xchg_rate))/(l_prior_proposed_sal*l_xchg_rate) * 100), 6),
         CHANGE_AMOUNT_N = (update_recs.proposed_salary_n - (l_prior_proposed_sal*l_xchg_rate))
         where PAY_TRANSACTION_ID = update_recs.PAY_TRANSACTION_ID;
         --
         exit;
         --
       else
         --
         if l_last_currency <> update_recs.input_currency_code then
            select PER_SALADMIN_UTILITY.get_currency_rate(l_last_currency,update_recs.input_currency_code,update_recs.change_date,p_busgroup_id) into l_xchg_rate
            from dual;
         else
            l_xchg_rate := 1;
         end if;
         --
         --
         --
         --calculate change amount when Components exists
         l_change_amount := update_component_transaction(update_recs.pay_transaction_id,
                                                           update_recs.ASSIGNMENT_ID,
                                                           update_recs.change_date,
                                                           l_prior_proposed_sal,
                                                           l_prior_proposal_id,
                                                           l_prior_trans_id,
                                                           l_prior_pay_basis_id,
                                                           'Y',
                                                           l_xchg_rate);

         --
         if g_debug then
           hr_utility.set_location('l_change_amt'||l_change_amount, 25);
         end if;
         ----
         --Update only change amount , % remains same
         update per_pay_transactions
         set    PRIOR_PROPOSED_SALARY_N = l_prior_proposed_sal,
         PRIOR_PAY_PROPOSAL_ID = l_prior_proposal_id,
         PRIOR_PAY_TRANSACTION_ID = l_prior_trans_id,
         PRIOR_PAY_BASIS_ID = l_prior_pay_basis_id,
         last_change_date = l_last_change_date,
         PROPOSED_SALARY_N = (l_prior_proposed_sal*l_xchg_rate+l_change_amount),
         change_amount_n = l_change_amount,
         CHANGE_PERCENTAGE = round((l_change_amount/(l_prior_proposed_sal*l_xchg_rate) * 100), 6)
         where PAY_TRANSACTION_ID = update_recs.PAY_TRANSACTION_ID;
       end if;
       --
       --update change amount for next iteration
       l_prior_proposed_sal := l_prior_proposed_sal*l_xchg_rate + l_change_amount;
       --
     elsif l_count > 1 then
       --
       --
       if g_debug then
         hr_utility.set_location(l_proc||'l_count :'||l_count, 25);
       end if;
       --
       if update_recs.MULTIPLE_COMPONENTS = 'N' then
         --
         if g_debug then
           hr_utility.set_location(l_proc||'No MULTIPLE_COMPONENTS'||l_count, 25);
         end if;
         --
         if l_last_currency <> update_recs.input_currency_code then
            select PER_SALADMIN_UTILITY.get_currency_rate(l_last_currency,update_recs.input_currency_code,update_recs.change_date,p_busgroup_id) into l_xchg_rate
            from dual;
         else
            l_xchg_rate := 1;
         end if;
         --
         --
         --update only the % , change_amount: ProposedSal remains same
         update per_pay_transactions
         set    CHANGE_PERCENTAGE = round(((update_recs.proposed_salary_n - (l_prior_proposed_sal*l_xchg_rate))/(l_prior_proposed_sal*l_xchg_rate) * 100), 6),
                CHANGE_AMOUNT_N = (update_recs.proposed_salary_n - (l_prior_proposed_sal*l_xchg_rate))
         where PAY_TRANSACTION_ID = update_recs.PAY_TRANSACTION_ID;
         --
         exit;
         --
       else
         --
         if g_debug then
           hr_utility.set_location('Multiple Comp'||l_proc, 25);
         end if;
         --
         if l_last_currency <> update_recs.input_currency_code then
            select PER_SALADMIN_UTILITY.get_currency_rate(l_last_currency,update_recs.input_currency_code,update_recs.change_date,p_busgroup_id) into l_xchg_rate
            from dual;
         else
            l_xchg_rate := 1;
         end if;
         --
         --
         --calculate change amount when Components exists
         l_change_amount := update_component_transaction(update_recs.pay_transaction_id,
                                                           update_recs.ASSIGNMENT_ID,
                                                           update_recs.change_date,
                                                           l_prior_proposed_sal,
                                                           l_prior_proposal_id,
                                                           l_prior_trans_id,
                                                           l_prior_pay_basis_id,
                                                           'Y',
                                                           l_xchg_rate);

         --
         --Update only change amount, proposedSal: % remains same
         update per_pay_transactions
         set   PROPOSED_SALARY_N = (PRIOR_PROPOSED_SALARY_N*l_xchg_rate + l_change_amount),
               CHANGE_AMOUNT_N = l_change_amount,
               CHANGE_PERCENTAGE = round((l_change_amount/(prior_proposed_salary_n*l_xchg_rate)*100), 6)
         where PAY_TRANSACTION_ID = update_recs.PAY_TRANSACTION_ID;
         --
         --
       end if;
       --
       --
       --update change amount for next iteration
       l_prior_proposed_sal := l_prior_proposed_sal + l_change_amount;
       --
     end if;
     --
    l_count := l_count + 1;
    --
   end loop;
   --
End update_transaction;
--
--
--
Procedure rollback_transactions(p_assignment_id in Number,
                                p_item_type in varchar2,
                                p_item_key      in varchar2,
                                p_status  OUT NOCOPY varchar2)
IS
  cursor csr_rows_to_be_deleted(c_item_type in varchar2, c_item_key in varchar2, c_assgn_id in number) is
  select trans.pay_basis_id,
         trans.pay_transaction_id
  from  per_pay_transactions trans,
        hr_api_transaction_steps tr_steps,
        hr_api_transaction_values tr_values,
        hr_api_transaction_values tr_values2
  where trans.assignment_id = c_assgn_id
  and   trans.item_type = c_item_type
  and   trans.item_key = c_item_key
  and   tr_steps.item_type = c_item_type
  and   tr_steps.item_key = c_item_key
  and   tr_steps . api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
  and   tr_values.TRANSACTION_STEP_ID = tr_steps.transaction_step_id
  and   tr_values2.TRANSACTION_STEP_ID = tr_steps.TRANSACTION_STEP_ID
  and   tr_values.name = 'P_EFFECTIVE_DATE'
  and   tr_values.date_value between  trans.change_date and trans.date_to
  and   tr_values2.name = 'P_PAY_BASIS_ID'
  and   tr_values2.number_value <> trans.pay_basis_id;
  --
  --
  cursor csr_chk_diff_in_asgn(c_item_type in varchar2, c_item_key in varchar2, c_assgn_id in number) is
  select trans.pay_basis_id
  from   per_pay_transactions trans,
         per_all_assignments_f asg
  where  trans.assignment_id  = c_assgn_id
  and    trans.item_type = c_item_type
  and    trans.item_key = c_item_key
  and    asg.assignment_id  = trans.assignment_id
  and    asg.pay_basis_id <> trans.pay_basis_id
  and    trans.change_date between asg.effective_start_date and asg.effective_end_date
  and not exists ( select '1'
                   from   hr_api_transaction_steps
                   where  api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
                   and    item_type = c_item_type
                   and    item_key = c_item_key );
  --
  l_pay_basis_id number;
  --
  l_pay_trans_id number;
  --
  l_proc     varchar2(72) := g_package||'rollback_transaction';
  --
Begin
   --
   p_status := 'N';
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   open csr_rows_to_be_deleted(p_item_type, p_item_key, p_assignment_id);
   fetch csr_rows_to_be_deleted into l_pay_basis_id, l_pay_trans_id;
   --
   if (csr_rows_to_be_deleted%found AND l_pay_trans_id is not null) then
     --
     delete from per_pay_transactions
     where item_key = p_item_key
     and   item_type = p_item_type;
     --
     p_status := 'Y';
     --
   else
     --
     open csr_chk_diff_in_asgn(p_item_type, p_item_key, p_assignment_id);
     fetch csr_chk_diff_in_asgn into l_pay_basis_id;
     --
     if(csr_chk_diff_in_asgn%found AND l_pay_basis_id is not null) then
       --
       delete from per_pay_transactions
       where item_key = p_item_key
       and   item_type = p_item_type;
       --
       p_status := 'Y';
       --
     end if;
     --
     close csr_chk_diff_in_asgn;
     --
   end if;
   --
   close csr_rows_to_be_deleted;
   --
end rollback_transactions;
--
--
--
Procedure get_transaction_step
 (p_item_type                    in varchar2,
  p_item_key                     in varchar2,
  p_activity_id                  in number,
  p_login_person_id              in number,
  p_api_name                     in varchar2,
  p_transaction_id              out nocopy number,
  p_transaction_step_id         out nocopy number,
  p_update_mode                 out nocopy varchar2,
  p_effective_date_option        in varchar2)
IS

l_update_mode boolean;
l_transaction_id number;
l_transaction_step_id number;

begin

  get_pay_transaction(
   p_item_type => p_item_type,
   p_item_key => p_item_key,
   p_activity_id => p_activity_id,
   p_login_person_id => p_login_person_id,
   p_api_name => p_api_name,
   p_effective_date_option => p_effective_date_option,
   p_transaction_id => l_transaction_id,
   p_transaction_step_id => l_transaction_step_id,
   p_update_mode => l_update_mode);

  if l_update_mode then
    p_update_mode:='Y';
  else
    p_update_mode:='N';
  end if;

  p_transaction_id := l_transaction_id;
  p_transaction_step_id := l_transaction_step_id;

end get_transaction_step;

---------------------- get_pay_transaction --------------------------------------
--
Procedure get_pay_transaction
 (p_item_type                    in varchar2,
  p_item_key                     in varchar2,
  p_activity_id                  in number,
  p_login_person_id              in number,
  p_api_name                     in varchar2,
  p_effective_date_option        in varchar2 default null,
  p_transaction_id              out nocopy number,
  p_transaction_step_id         out nocopy number,
  p_update_mode                 out nocopy boolean) IS
--
cursor csr_txn_step is
  select hats.transaction_step_id
   from    hr_api_transaction_steps   hats
   where   hats.item_type   = p_item_type
   and     hats.item_key    = p_item_key
  -- and     hats.activity_id = p_activity_id
   and     hats.api_name    = upper(p_api_name)
   order by hats.transaction_step_id;
 --
  l_transaction_id                number := null;
  l_transaction_step_id           number := null;
  l_result                        varchar2(100);
  l_trans_obj_vers_num            number;
  l_processing_order              number := 1;
--
  l_tx_name             t_tx_name;
  l_tx_char             t_tx_char;
  l_tx_num              t_tx_num;
  l_tx_date             t_tx_date;
  l_tx_type             t_tx_type;
--
  l_proc varchar2(61) := 'get_pay_transaction' ;
--
Begin
--
 hr_utility.set_location('Entering '||l_proc,10);
 --
 p_update_mode := true;
 -- get the transaction id
 l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);

  -- if it is not available create it.
  if l_transaction_id is null then
     hr_transaction_ss.start_transaction
        (itemtype   => p_item_type
        ,itemkey    => p_item_key
        ,actid      => p_activity_id
        ,funmode    => 'RUN'
        ,p_login_person_id => p_login_person_id
        ,result     => l_result);
     --

     l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  end if;
  --
  -- get the transaction_step_id
  --
  Open csr_txn_step;
  Fetch csr_txn_step into l_transaction_step_id;
  Close csr_txn_step;
  --
  if upper(p_api_name) = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API' then
     l_processing_order := 1;
  else
     l_processing_order := 5;
  end if;
  --
  -- if it is not available, create it.
  if l_transaction_step_id is null then
     --
    hr_transaction_api.create_trans_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => upper(p_api_name)
     ,p_api_display_name      => upper(p_api_name)
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_activity_id
     ,p_processing_order      => l_processing_order
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
     --
     p_update_mode := false;
     --
     if upper(p_api_name) = 'PER_SSHR_CHANGE_PAY.PROCESS_API' then
        --
         l_tx_name(1) := 'P_REVIEW_ACTID';
         l_tx_char(1) := to_char(p_activity_id);
         l_tx_num(1)  := null;
         l_tx_date(1) := null;
         l_tx_type(1) := 'VARCHAR2';

         l_tx_name(2) := 'P_REVIEW_PROC_CALL';
         l_tx_char(2) := 'HrChangePay';
         l_tx_num(2)  := null;
         l_tx_date(2) := null;
         l_tx_type(2) := 'VARCHAR2';
       --
       forall i in 1..2
        insert into hr_api_transaction_values
        ( transaction_value_id,
          transaction_step_id,
          datatype,
          name,
          varchar2_value,
          number_value,
          date_value,
          original_varchar2_value,
          original_number_value,
          original_date_value)
        Values
        ( hr_api_transaction_values_s.nextval,
          l_transaction_step_id,
          l_tx_type(i),
          l_tx_name(i),
          l_tx_char(i),
          l_tx_num(i),
          l_tx_date(i),
          l_tx_char(i),
          l_tx_num(i),
          l_tx_date(i));
        --
     End if;
  end if;
  --
  p_transaction_id      := l_transaction_id;
  p_transaction_step_id := l_transaction_step_id;
  --
 hr_utility.set_location('Leaving '||l_proc,99);
exception
   when others then
      hr_utility.set_location('Exception Raised',420);
      raise;
End get_pay_transaction;
--
---------------------- process_salary_basis_change --------------------------------------
--
Procedure process_salary_basis_change(
  p_transaction_step_id         in number) IS
 --
 --
 Cursor csr_sel_item is
 Select transaction_step_id,api_name
 from hr_api_transaction_steps
 where transaction_id = (Select transaction_id
                           from hr_api_transaction_steps
                           Where transaction_step_id = p_transaction_step_id)
 and   api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API';
 --
 --
  l_proc varchar2(61) := 'process_salary_basis_change' ;
--
Begin
--
 hr_utility.set_location('Entering '||l_proc,10);
 --
   for csr_sel in csr_sel_item loop
       --
       hr_transaction_ss.process_web_api_call
       (p_transaction_step_id => csr_sel.transaction_step_id
       ,p_api_name            => csr_sel.api_name
       ,p_validate            => false);
   end loop;
 --
 --
 hr_utility.set_location('Leaving '||l_proc,99);
exception
   when others then
      hr_utility.set_location('Exception Raised',420);
      raise;
 End process_salary_basis_change;
--
--
---------------------- process_create_pay_action --------------------------------------
--
Procedure process_create_pay_action(
  p_transaction_step_id         in number) IS
--
  Cursor csr_insert_pay is
  Select * from per_pay_transactions
  where transaction_step_id = p_transaction_step_id
    and dml_operation = 'INSERT'
    and PARENT_PAY_TRANSACTION_ID is null
  order by CHANGE_DATE;
--
  Cursor csr_insert_comp is
  Select * from per_pay_transactions
  where transaction_step_id = p_transaction_step_id
    and dml_operation = 'INSERT'
    and PARENT_PAY_TRANSACTION_ID is not null
  order by PARENT_PAY_TRANSACTION_ID;

 --
 Cursor csr_eff_date is
 Select TRANSACTION_EFFECTIVE_DATE, EFFECTIVE_DATE_OPTION
   From hr_api_transactions
  Where transaction_id = (Select transaction_id from hr_api_transaction_steps where transaction_step_id = p_transaction_step_id);
 --
 --
  l_pay_proposal_id            per_pay_proposals.pay_proposal_id%type;
  l_pay_ovn                    per_pay_proposals.object_version_number%type;
  l_component_id               per_pay_proposal_components.component_id%type;
  l_comp_ovn                   per_pay_proposal_components.object_version_number%type;
  l_change_date                per_pay_proposals.change_date%type;
  l_element_entry_id           pay_element_entries_f.element_entry_id%type;
  l_inv_next_sal_date_warning  boolean;
  l_proposed_salary_warning    boolean;
  l_approved_warning           boolean;
  l_payroll_warning            boolean;
  l_assignment_id              per_all_assignments_f.assignment_id%type;
  l_g_assignment_id            per_all_assignments_f.assignment_id%type := null;
 --
  l_proc varchar2(61) := 'process_create_pay_action' ;
  l_item_type                  hr_api_transaction_steps.item_type%type;
  l_item_key                   hr_api_transaction_steps.item_key%type;
--
 --
  l_transaction_effective_date hr_api_transactions.TRANSACTION_EFFECTIVE_DATE%type;
  l_effective_date_option      hr_api_transactions.EFFECTIVE_DATE_OPTION%type;
--
Begin
--
 hr_utility.set_location('Entering '||l_proc,10);
 --
--
--
Open csr_eff_date;
Fetch csr_eff_date into l_transaction_effective_date,l_effective_date_option;
Close csr_eff_date;
--
IF (( hr_process_person_ss.g_assignment_id is not null) and
          (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) THEN
      --
      -- Set the Assignment Id to the one just created, don't use the
      -- transaction table.

      l_g_assignment_id := hr_process_person_ss.g_assignment_id;
      hr_utility.set_location('Getting global assignment id = ' ||to_char(l_g_assignment_id),20);
      --
END IF;
 --
 -- query insert pay actions.
 --
 For l_pay_rec in csr_insert_pay loop
   --
   If l_g_assignment_id is not null THEN
      l_assignment_id := l_g_assignment_id;
   else
      l_assignment_id := l_pay_rec.assignment_id;
   End if;
   --
   If nvl(l_effective_date_option,'E') = 'A' then
      l_change_date := trunc(l_transaction_effective_date);
   Else
      l_change_date := l_pay_rec.change_date;
   End if;
   --
   --
   -- Insert salary proposal record.
   --
   hr_maintain_proposal_api.insert_salary_proposal(
        p_pay_proposal_id              => l_pay_proposal_id,
        p_assignment_id                => l_assignment_id,
        p_business_group_id            => l_pay_rec.business_group_id,
        p_change_date                  => l_change_date,
        p_comments                     => l_pay_rec.comments,
        p_next_sal_review_date         => l_pay_rec.next_sal_review_date,
        p_proposal_reason              => l_pay_rec.reason,
        p_proposed_salary_n            => l_pay_rec.proposed_salary_n,
        p_date_to                      => l_pay_rec.date_to ,
        p_attribute_category           => l_pay_rec.attribute_category,
        p_attribute1                   => l_pay_rec.attribute1,
        p_attribute2                   => l_pay_rec.attribute2,
        p_attribute3                   => l_pay_rec.attribute3,
        p_attribute4                   => l_pay_rec.attribute4,
        p_attribute5                   => l_pay_rec.attribute5,
        p_attribute6                   => l_pay_rec.attribute6,
        p_attribute7                   => l_pay_rec.attribute7,
        p_attribute8                   => l_pay_rec.attribute8,
        p_attribute9                   => l_pay_rec.attribute9,
        p_attribute10                  => l_pay_rec.attribute10,
        p_attribute11                  => l_pay_rec.attribute11,
        p_attribute12                  => l_pay_rec.attribute12,
        p_attribute13                  => l_pay_rec.attribute13,
        p_attribute14                  => l_pay_rec.attribute14,
        p_attribute15                  => l_pay_rec.attribute15,
        p_attribute16                  => l_pay_rec.attribute16,
        p_attribute17                  => l_pay_rec.attribute17,
        p_attribute18                  => l_pay_rec.attribute18,
        p_attribute19                  => l_pay_rec.attribute19,
        p_attribute20                  => l_pay_rec.attribute20,
        p_object_version_number        => l_pay_ovn,
        p_multiple_components          => l_pay_rec.multiple_components,
        p_approved                     => 'Y',
        p_validate                     => FALSE,
        p_element_entry_id             => l_element_entry_id,
        p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning,
        p_proposed_salary_warning      => l_proposed_salary_warning,
        p_approved_warning             => l_approved_warning,
        p_payroll_warning              => l_payroll_warning);

        --
        -- Write the pay_proposal_id on the component records, if any.
        --
        Update per_pay_transactions
          set PAY_PROPOSAL_ID = l_pay_proposal_id
         Where transaction_step_id = p_transaction_step_id
           and PARENT_PAY_TRANSACTION_ID = l_pay_rec.pay_transaction_id;
        --
 End loop;
 --
 -- Now insert components
 --
 For l_comp_rec in csr_insert_comp loop
  --
  hr_maintain_proposal_api.insert_proposal_component(
        p_component_id                 => l_component_id ,
        p_pay_proposal_id              => l_comp_rec.pay_proposal_id,
        p_business_group_id            => l_comp_rec.business_group_id ,
        p_approved                     => l_comp_rec.approved,
        p_component_reason             => l_comp_rec.reason,
        p_change_amount_n              => l_comp_rec.change_amount_n,
        p_change_percentage            => l_comp_rec.change_percentage,
        p_comments                     => l_comp_rec.comments,
        p_attribute_category           => l_comp_rec.attribute_category,
        p_attribute1                   => l_comp_rec.attribute1,
        p_attribute2                   => l_comp_rec.attribute2,
        p_attribute3                   => l_comp_rec.attribute3,
        p_attribute4                   => l_comp_rec.attribute4,
        p_attribute5                   => l_comp_rec.attribute5,
        p_attribute6                   => l_comp_rec.attribute6,
        p_attribute7                   => l_comp_rec.attribute7,
        p_attribute8                   => l_comp_rec.attribute8,
        p_attribute9                   => l_comp_rec.attribute9,
        p_attribute10                  => l_comp_rec.attribute10,
        p_attribute11                  => l_comp_rec.attribute11,
        p_attribute12                  => l_comp_rec.attribute12,
        p_attribute13                  => l_comp_rec.attribute13,
        p_attribute14                  => l_comp_rec.attribute14,
        p_attribute15                  => l_comp_rec.attribute15,
        p_attribute16                  => l_comp_rec.attribute16,
        p_attribute17                  => l_comp_rec.attribute17,
        p_attribute18                  => l_comp_rec.attribute18,
        p_attribute19                  => l_comp_rec.attribute19,
        p_attribute20                  => l_comp_rec.attribute20,
        p_object_version_number        => l_comp_ovn,
        p_validation_strength          => 'STRONG',
        p_validate                     => FALSE);

  End loop;
  --
 hr_utility.set_location('Leaving '||l_proc,99);
exception
   when others then
      hr_utility.set_location('Exception Raised',420);
      raise;
--
End process_create_pay_action;
--
---------------------- process_update_pay_action --------------------------------------
--
Procedure process_update_pay_action(
  p_transaction_step_id         in number) IS
--
--
  Cursor csr_update_pay is
  Select * from per_pay_transactions
  where transaction_step_id = p_transaction_step_id
    and dml_operation = 'UPDATE'
    and PARENT_PAY_TRANSACTION_ID is null
  order by CHANGE_DATE desc;
--
  Cursor csr_update_comp is
  Select * from per_pay_transactions
  where transaction_step_id = p_transaction_step_id
    and dml_operation = 'UPDATE'
    and PARENT_PAY_TRANSACTION_ID is not null
  order by PARENT_PAY_TRANSACTION_ID;
 --
  l_pay_proposal_id            per_pay_proposals.pay_proposal_id%type;
  l_pay_ovn                    per_pay_proposals.object_version_number%type;
  l_component_id               per_pay_proposal_components.component_id%type;
  l_comp_ovn                   per_pay_proposal_components.object_version_number%type;
  l_element_entry_id           pay_element_entries_f.element_entry_id%type;
  l_inv_next_sal_date_warning  boolean;
  l_proposed_salary_warning    boolean;
  l_approved_warning           boolean;
  l_payroll_warning            boolean;
 --
  l_proc varchar2(61) := 'process_update_pay_action' ;
--
Begin
--
hr_utility.set_location('Entering '||l_proc,10);
 --
 per_pyp_bus.g_validate_ss_change_pay := 'Y';
 For l_pay_rec in csr_update_pay loop
   --
   -- Query update pay actions.
   -- Call Update API to Update salary proposal record.
   --
   Select object_version_number into l_pay_ovn
   From per_pay_proposals where pay_proposal_id = l_pay_rec.pay_proposal_id;
   --

   hr_maintain_proposal_api.update_salary_proposal(
        p_pay_proposal_id              => l_pay_rec.pay_proposal_id,
        p_change_date                  => l_pay_rec.change_date,
        p_comments                     => l_pay_rec.comments,
        p_next_sal_review_date         => l_pay_rec.next_sal_review_date,
        p_proposal_reason              => l_pay_rec.reason,
        p_proposed_salary_n            => l_pay_rec.proposed_salary_n,
        p_date_to                      => l_pay_rec.date_to ,
        p_attribute_category           => l_pay_rec.attribute_category,
        p_attribute1                   => l_pay_rec.attribute1,
        p_attribute2                   => l_pay_rec.attribute2,
        p_attribute3                   => l_pay_rec.attribute3,
        p_attribute4                   => l_pay_rec.attribute4,
        p_attribute5                   => l_pay_rec.attribute5,
        p_attribute6                   => l_pay_rec.attribute6,
        p_attribute7                   => l_pay_rec.attribute7,
        p_attribute8                   => l_pay_rec.attribute8,
        p_attribute9                   => l_pay_rec.attribute9,
        p_attribute10                  => l_pay_rec.attribute10,
        p_attribute11                  => l_pay_rec.attribute11,
        p_attribute12                  => l_pay_rec.attribute12,
        p_attribute13                  => l_pay_rec.attribute13,
        p_attribute14                  => l_pay_rec.attribute14,
        p_attribute15                  => l_pay_rec.attribute15,
        p_attribute16                  => l_pay_rec.attribute16,
        p_attribute17                  => l_pay_rec.attribute17,
        p_attribute18                  => l_pay_rec.attribute18,
        p_attribute19                  => l_pay_rec.attribute19,
        p_attribute20                  => l_pay_rec.attribute20,
        p_object_version_number        => l_pay_ovn,
        p_multiple_components          => l_pay_rec.multiple_components,
        p_approved                     => 'Y',
        p_validate                     => FALSE,
        p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning,
        p_proposed_salary_warning      => l_proposed_salary_warning,
        p_approved_warning             => l_approved_warning,
        p_payroll_warning              => l_payroll_warning);

 End loop;
 per_pyp_bus.g_validate_ss_change_pay := 'N';
 --
 -- Now Update components
 --
 For l_comp_rec in csr_update_comp loop
  --
  hr_maintain_proposal_api.update_proposal_component(
        --
        p_component_id                 => l_comp_rec.component_id ,
        p_approved                     => l_comp_rec.approved,
        p_component_reason             => l_comp_rec.reason,
        p_change_amount_n              => l_comp_rec.change_amount_n,
        p_change_percentage            => l_comp_rec.change_percentage,
        p_comments                     => l_comp_rec.comments,
        p_attribute_category           => l_comp_rec.attribute_category,
        p_attribute1                   => l_comp_rec.attribute1,
        p_attribute2                   => l_comp_rec.attribute2,
        p_attribute3                   => l_comp_rec.attribute3,
        p_attribute4                   => l_comp_rec.attribute4,
        p_attribute5                   => l_comp_rec.attribute5,
        p_attribute6                   => l_comp_rec.attribute6,
        p_attribute7                   => l_comp_rec.attribute7,
        p_attribute8                   => l_comp_rec.attribute8,
        p_attribute9                   => l_comp_rec.attribute9,
        p_attribute10                  => l_comp_rec.attribute10,
        p_attribute11                  => l_comp_rec.attribute11,
        p_attribute12                  => l_comp_rec.attribute12,
        p_attribute13                  => l_comp_rec.attribute13,
        p_attribute14                  => l_comp_rec.attribute14,
        p_attribute15                  => l_comp_rec.attribute15,
        p_attribute16                  => l_comp_rec.attribute16,
        p_attribute17                  => l_comp_rec.attribute17,
        p_attribute18                  => l_comp_rec.attribute18,
        p_attribute19                  => l_comp_rec.attribute19,
        p_attribute20                  => l_comp_rec.attribute20,
        p_object_version_number        => l_comp_ovn,
        p_validation_strength          => 'STRONG',
        p_validate                     => FALSE);
        --
  End loop;
  --
 hr_utility.set_location('Leaving '||l_proc,99);
exception
   when others then
      per_pyp_bus.g_validate_ss_change_pay := 'N';
      hr_utility.set_location('Exception Raised',420);
      raise;
--
End process_update_pay_action;
--
---------------------- process_delete_pay_action --------------------------------------
--
Procedure process_delete_pay_action(
  p_transaction_step_id         in number) IS
--
--
  Cursor csr_delete_pay is
  Select * from per_pay_transactions
  where transaction_step_id = p_transaction_step_id
    and dml_operation = 'DELETE'
    and PARENT_PAY_TRANSACTION_ID is null
  order by CHANGE_DATE;
--
  Cursor csr_delete_comp is
  Select * from per_pay_transactions
  where transaction_step_id = p_transaction_step_id
    and dml_operation = 'DELETE'
    and PARENT_PAY_TRANSACTION_ID is not null
  order by PARENT_PAY_TRANSACTION_ID;
 --
  l_pay_ovn                    per_pay_proposals.object_version_number%type;
  l_comp_ovn                   per_pay_proposal_components.object_version_number%type;
  l_salary_warning             boolean;
  l_proc varchar2(61)          := 'process_delete_pay_action' ;
--
Begin
--
  hr_utility.set_location('Entering '||l_proc,10);
  --
  For l_comp_rec in csr_delete_comp loop
   --
   Select object_version_number into l_comp_ovn
   From per_pay_proposal_components where component_id = l_comp_rec.component_id;
   --
    hr_maintain_proposal_api.delete_proposal_component(
       p_component_id                       => l_comp_rec.component_id,
       p_validation_strength                => 'STRONG',
       p_object_version_number              => l_comp_ovn,
       p_validate                           => FALSE);
  End loop;
  --
  For l_pay_rec in csr_delete_pay loop
   --
   Select object_version_number into l_pay_ovn
   From per_pay_proposals where pay_proposal_id = l_pay_rec.pay_proposal_id;
   --
    hr_maintain_proposal_api.delete_salary_proposal
      (p_pay_proposal_id       => l_pay_rec.pay_proposal_id
      ,p_business_group_id     => l_pay_rec.business_group_id
      ,p_object_version_number => l_pay_ovn
      ,p_validate              => FALSE
      ,p_salary_warning        => l_salary_warning);
  End loop;

  hr_utility.set_location('Leaving '||l_proc,99);
exception
   when others then
      hr_utility.set_location('Exception Raised',420);
      raise;
--
End process_delete_pay_action;

--
--12-Jan-2010 vkodedal   bug#9023204 - added new proc process_new_hire
procedure process_new_hire(
  p_transaction_step_id         in number,
  p_item_key                    in varchar2 default null,
  p_item_type                   in varchar2 default null) is

  l_item_type                  hr_api_transaction_steps.item_type%type;
  l_item_key                   hr_api_transaction_steps.item_key%type;
  l_proc varchar2(61) := 'process_new_hire' ;

 Cursor csr_sel_item is
 Select item_type,item_key
 from hr_api_transaction_steps
 where transaction_step_id = p_transaction_step_id;

begin

   savepoint apply_change_pay_hire_txn;
    --
    hr_utility.set_location('Entering :'||l_proc,5);
    hr_utility.set_location('p_transaction_step_id :'||p_transaction_step_id,5);
    hr_utility.set_location('p_item_key :'||p_item_key,5);
    hr_utility.set_location('p_item_type :'||p_item_type,5);
    --
    Open csr_sel_item;
    Fetch csr_sel_item into l_item_type,l_item_key;
    Close csr_sel_item;
    --Bug#9035808 vkodedal 22-Oct-09
    if( l_item_type is null or l_item_key is null)
    then
    l_item_type := p_item_type;
    l_item_key  := p_item_key;

    hr_utility.set_location('l_item_key :'||l_item_key,15);
    hr_utility.set_location('l_item_type :'||l_item_type,15);
    end if;

    hr_new_user_reg_ss.process_selected_transaction
         (p_item_type => l_item_type,
          p_item_key  => l_item_key);

    hr_utility.set_location('Exiting :'||l_proc,99);
exception
  when others then
     --
     ROLLBACK TO apply_change_pay_hire_txn;
     --
     hr_utility.set_location('Exception Raised',420);
     raise;
end;
--
--
--
------------------------------------------------------------------------------
-- The following procedure is called from continue button on overview page.
--
Procedure process_pay_api(
  p_validate                    in varchar2,
  p_transaction_step_id         in number,
  p_effective_date              in date default null,
  p_new_hire_flag               in varchar2 default null,
  p_item_key                    in varchar2 default null,
  p_item_type                   in varchar2 default null,
  p_assignment_id               in varchar2 default null) is
--
 l_proc varchar2(61) := 'process_pay_api' ;
 l_gsp_assignment varchar2(30);
--
Begin
--

--
   hr_utility.set_location('Entering '||l_proc,10);
   --
   savepoint apply_change_pay_txn;
   --
   -- gsp support changes --vkodedal 6141175
	l_gsp_assignment :=
              hr_transaction_api.get_varchar2_value
                               (p_transaction_step_id => p_transaction_step_id,
                                p_name =>'P_REVIEW_ACTID');
   if (l_gsp_assignment = '-1' ) then
   return;
   end if;
   -- end of gsp support changes --vkodedal
   --
   -- BUG 6002700. Check for "HR Base Salary Required"
   check_base_salary_profile(p_transaction_step_id,p_item_key,p_item_type,p_effective_date,p_assignment_id);
   --
   hr_utility.set_location('Profile check done '||l_proc,12);

   --
   if nvl(p_new_hire_flag,'N') = 'N' then
      --
      process_salary_basis_change(
      p_transaction_step_id         => p_transaction_step_id);
      --
   else
    --
      process_new_hire(p_transaction_step_id,p_item_key,p_item_type);
    --
  END IF;
   --
   process_delete_pay_action(
   p_transaction_step_id         => p_transaction_step_id);
   --
   hr_utility.set_location('After Deletes '||l_proc,10);
   --
   process_update_pay_action(
   p_transaction_step_id         => p_transaction_step_id);
   --
   hr_utility.set_location('After Updates '||l_proc,10);
   --
   process_create_pay_action(
   p_transaction_step_id         => p_transaction_step_id);
   --
   --
   hr_utility.set_location('After Inserts '||l_proc,10);
   --
   if nvl(p_validate,'N') = 'Y' then
      hr_utility.set_location('validate mode '||p_validate,10);
      raise hr_api.validate_enabled;
   Else
      --
      -- Purge data from transaction tables.
      --
      Delete from per_pay_transactions
       where transaction_step_id = p_transaction_step_id;
      --
   end if;
   --
   hr_utility.set_location('Leaving '||l_proc,99);
   --
exception
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO apply_change_pay_txn;
     --
     hr_utility.set_location('Leaving after Rollback'||l_proc,99);
     --
   when others then
     --
     ROLLBACK TO apply_change_pay_txn;
     --
     hr_utility.set_location('Exception Raised',420);
     raise;
End;
--
--
---------------------- process_api --------------------------------------
--
-- The pay actions are applied in the following order
-- 1. DELETE
-- 2. UPDATE
-- 3. INSERT
-- The transaction records are then purged.
--
Procedure process_api(
  p_validate                    in boolean default false,
  p_transaction_step_id         in number,
  p_effective_date              in varchar2 default null) is
--
  l_proc varchar2(61) := 'process_api' ;
  l_gsp_assignment varchar2(30);
  --------vkodedal 09-Jul-2009 ER 4384022
  l_asg_id number;
  l_return_status varchar2(1);
--
Begin
--
   hr_utility.set_location('Entering '||l_proc,10);
   --
   savepoint apply_change_pay_txn1;
   --
   -- gsp support changes --vkodedal 6141175
	l_gsp_assignment :=
              hr_transaction_api.get_varchar2_value
                               (p_transaction_step_id => p_transaction_step_id,
                                p_name =>'P_REVIEW_ACTID');
   if (l_gsp_assignment = '-1' ) then
   return;
   end if;
   -- end of gsp support changes --vkodedal
   --
   process_delete_pay_action(
   p_transaction_step_id         => p_transaction_step_id);
   --
   hr_utility.set_location('After Deletes '||l_proc,10);
   --
   process_update_pay_action(
   p_transaction_step_id         => p_transaction_step_id);
   --
   hr_utility.set_location('After Updates '||l_proc,10);
   --
   process_create_pay_action(
   p_transaction_step_id         => p_transaction_step_id);
   --
   hr_utility.set_location('After Inserts '||l_proc,10);
   --
   if p_validate then
      hr_utility.set_location('validate mode '||l_proc,10);
      raise hr_api.validate_enabled;
   Else
   --
   --------vkodedal 09-Jul-2009 ER 4384022
    hr_utility.set_location('Get the assignment id '||l_proc,10);

    Select DISTINCT ASSIGNMENT_ID into l_asg_id
        from per_pay_transactions
        where transaction_step_id =p_transaction_step_id;
   --
    hr_utility.set_location('Call  HR_UTIL_MISC_SS.merge_attachments for asg id:'||l_asg_id,10);

   HR_UTIL_MISC_SS.merge_attachments ( p_dest_entity_name => 'PER_ASSIGNMENTS_F',
                                        p_dest_pk1_value  => l_asg_id,
                                        p_return_status   =>l_return_status
   );

   /*
      Do not purge --ER 4691806 --vkodedal 08-Apr-2010
      --
      -- Purge data from transaction tables.
      --
      Delete from per_pay_transactions
       where transaction_step_id = p_transaction_step_id;
      --
   */
   end if;
   --
   hr_utility.set_location('Leaving '||l_proc,99);
   --
exception
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO apply_change_pay_txn1;
     --
     hr_utility.set_location('Leaving after Rollback'||l_proc,99);
     --
   when others then
     --
     ROLLBACK TO apply_change_pay_txn1;
     --
     hr_utility.set_location('Exception Raised',420);
     raise;
--
End process_api;
--
--
--

PROCEDURE get_create_date(p_assignment_id in NUMBER
                       ,p_effective_date in date
                       ,p_transaction_id in NUMBER
                       ,p_create_date out NOCOPY date
                       ,p_default_salary_basis_id out NOCOPY number
                       ,p_allow_basis_change out NOCOPY varchar2
                       ,p_min_create_date out NOCOPY date
                       ,p_allow_date_change out NOCOPY varchar2
                       ,p_allow_create out NOCOPY varchar2
                       ,p_status out NOCOPY NUMBER
                       ,p_basis_default_date out NOCOPY date
                       ,p_basis_default_min_date out NOCOPY date
                       ,p_orig_salary_basis_id out NOCOPY number) IS
--
--
 Cursor csr_assgn_exists Is
 select '1'
 from  per_all_assignments_f
 where assignment_id  = p_assignment_id
 and   p_effective_date between effective_start_date and effective_end_date;
--
 Cursor csr_last_change_date Is
    select change_date
           from per_pay_proposals
           where assignment_id = p_assignment_id
    union
--vkodedal 08-Apr-2009 bug#8400759
    select ppt.change_date
           from per_pay_transactions ppt,
            wf_item_attribute_values wf,
			hr_api_transactions hat
           where ppt.assignment_id = p_assignment_id
           and ppt.PARENT_PAY_TRANSACTION_ID is null
	       and ppt.status <> 'DELETE'
	       and wf.item_type = ppt.item_type
           and wf.item_key = ppt.item_key
           and wf.name = 'TRAN_SUBMIT'
           AND wf.text_value not in ('W','S','D','E','N')
		   and ppt.transaction_id=hat.transaction_id
		   and hat.status<>'AC'
    order by change_date desc;
--
 Cursor csr_txn_basis_change_date Is
    select hatv1.date_value ,hatv.number_value, hatv.original_number_value
           from hr_api_transaction_values hatv,
           hr_api_transaction_steps hats,
           hr_api_transactions hat,
           hr_api_transaction_values hatv1
           where hatv.NAME = 'P_PAY_BASIS_ID'
           and hatv1.NAME = 'P_EFFECTIVE_DATE'
           and hatv1.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
           and hatv.NUMBER_VALUE <> hatv.ORIGINAL_NUMBER_VALUE
           and hatv.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
           and hats.TRANSACTION_ID = hat.TRANSACTION_ID
           and hat.ASSIGNMENT_ID = p_assignment_id
           and hat.TRANSACTION_ID = p_transaction_id
		   and hat.status<>'AC'
           order by hatv1.date_value desc  ;
--
 Cursor csr_txn_asst_change_date Is
   select hatv.date_value
           from hr_api_transaction_steps hats,
           hr_api_transactions hat,
           hr_api_transaction_values hatv
           where hats.api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
           and hatv.transaction_step_id = hats.transaction_step_id
           and hatv.name = 'P_EFFECTIVE_DATE'
           and hats.TRANSACTION_ID = hat.TRANSACTION_ID
           and hat.ASSIGNMENT_ID = p_assignment_id
           and hat.TRANSACTION_ID = p_transaction_id
		   and hat.status<>'AC';
--
 Cursor csr_future_asst_change_max(l_min_change_date date,l_change_date date) Is
    select effective_start_date
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date > l_min_change_date
           and effective_start_date < l_change_date
    order by effective_start_date desc;
--
 Cursor csr_asst_start_date Is
    select effective_start_date
           from per_all_assignments_f
           where assignment_id = p_assignment_id
    order by effective_start_date asc;
--
 Cursor csr_asst_change_date(l_max_change_date date) Is
    select effective_start_date
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date > l_max_change_date
    order by effective_start_date asc;
--
  Cursor csr_asst_basis_change_date(l_max_change_date date) Is
    select effective_start_date,pay_basis_id
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date > l_max_change_date
           and pay_basis_id <> (Select pay_basis_id from per_all_assignments_f
	                               where assignment_id = p_assignment_id
                         	       and l_max_change_date between effective_start_date
                                                         and effective_end_date)
    order by effective_start_date asc;
--
 CURSOR csr_get_next_payroll_date
        (l_assignment_id NUMBER
        ,l_date DATE
        )
 IS
     select min(ptp.start_date) next_payroll_date
           	from per_time_periods ptp
           		,per_all_assignments_f paaf
           	where ptp.payroll_id = paaf.payroll_id
           	and paaf.assignment_id = l_assignment_id
           	and ptp.start_date > l_date ;
--
 Cursor csr_pay_basis_exists(c_assignment_id number, c_effective_date date) IS
    select pay_basis_id
           from   per_all_assignments_f
           where  assignment_id = c_assignment_id
           and  c_effective_date between effective_start_date and effective_end_date;
--
 Cursor csr_txn_basis_id Is
    select hatv.number_value,
           hatv.original_number_value
           from hr_api_transaction_values hatv,
           hr_api_transaction_steps hats,
           hr_api_transactions hat
           where hatv.NAME = 'P_PAY_BASIS_ID'
           and hatv.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
           and hats.TRANSACTION_ID = hat.TRANSACTION_ID
           and hat.TRANSACTION_ID = p_transaction_id
		   and hat.status<>'AC';
--
--
    l_last_payroll_run_date date;
    l_last_change_date date;
    l_txn_basis_change_date date;
    l_dflt_txn_basis_id number;
    l_orig_txn_basis_id number;
    l_txn_asst_change_date date;
    l_asst_basis_change_date date;
    l_dflt_asst_basis_id number;
    l_asst_change_date date;
    l_status number;
    l_payroll_attached varchar2(10);
    l_proposals_exists varchar2(10);
    l_assign_on_gsp varchar2(10);
    l_csr_asst_chg_count number;
    l_csr_asst_basis_chg_count number;
    l_max_create_date date;
    l_min_create_date date;
    l_max_create_date_src varchar2(20);
    l_asst_on_gsp varchar2(20);
    l_future_asst_change_max date;
    l_assgn_exists varchar2(5);
--
--
Begin
--
--
 -- hr_utility.trace_on(null, 'TIGER');
 -- g_debug := TRUE;

    l_proposals_exists := 'YES';
    l_payroll_attached := 'YES';
    p_allow_date_change := 'YES';
    p_allow_basis_change := 'YES';
    p_allow_create := 'YES';
    p_status := 1;
    p_basis_default_date := null;
    p_default_salary_basis_id := null;
    p_basis_default_min_date := null;
--
 if g_debug then
      hr_utility.set_location('Enter get_create_date  ', 1);
      hr_utility.set_location('p_assignment_id  '||p_assignment_id, 2);
      hr_utility.set_location('p_effective_date: '||p_effective_date, 3);
      hr_utility.set_location('p_transaction_id  '||p_transaction_id, 4);
   end if;

    open csr_assgn_exists;
      Fetch csr_assgn_exists into l_assgn_exists;
    close csr_assgn_exists;

    if l_assgn_exists is null then

       l_asst_on_gsp := PER_SSHR_CHANGE_PAY.Check_GSP_Manual_Override(p_assignment_id,p_effective_date,p_transaction_id);
         if g_debug then
            hr_utility.set_location('l_asst_on_gsp  '||l_asst_on_gsp, 5);
         end if;
       if l_asst_on_gsp = 'N' then
            p_allow_create := 'Y_GSP';
	    p_create_date := p_effective_date;
             if g_debug then
                hr_utility.set_location('GSP EXISTS  ', 6);
             end if;
            return;
       end if;



       open csr_txn_basis_id;
          Fetch csr_txn_basis_id into p_default_salary_basis_id, p_orig_salary_basis_id;
       close csr_txn_basis_id;

       if p_default_salary_basis_id is null then
            if g_debug then
                   hr_utility.set_location('New Hire and N_BASIS  ', 5);
            end if;
	  p_create_date := sysdate;
          p_allow_create := 'N_BASIS';
          return;
       else
            Open  csr_last_change_date;
                 Fetch csr_last_change_date into l_last_change_date;
            Close csr_last_change_date;

            if l_last_change_date is null then
               p_create_date := p_effective_date;
               --p_default_salary_basis_id
               p_allow_basis_change := 'YES';
               p_min_create_date := p_effective_date;
               p_allow_date_change := 'YES';
               p_allow_create := 'YES';
               p_status := 1;
               --p_basis_default_date
               --p_basis_default_min_date
               --p_orig_salary_basis_id
                if g_debug then
                   hr_utility.set_location('New Hire and p_create_date  '||p_create_date, 6);
                end if;
           else
                if p_effective_date > l_last_change_date then
                   p_create_date := p_effective_date;
                else
                    p_create_date := l_last_change_date+1;
                end if;

               p_allow_basis_change := 'NO';
               p_min_create_date := l_last_change_date+1;
               p_allow_date_change := 'YES';
               p_allow_create := 'YES';
               p_status := 1;
               --p_basis_default_date
               --p_basis_default_min_date
               --p_orig_salary_basis_id
                if g_debug then
                   hr_utility.set_location('New Hire and p_create_date  '||p_create_date, 7);
                end if;
           end if;

           return;
        end if;
    end if;



--
   l_last_payroll_run_date := PER_SALADMIN_UTILITY.get_last_payroll_dt(p_assignment_id);
   if(l_last_payroll_run_date is null) then
       l_last_payroll_run_date := p_effective_date;
       l_payroll_attached := 'NO';
   end if;
--
   Open  csr_last_change_date;
     Fetch csr_last_change_date into l_last_change_date;
   Close csr_last_change_date;
   if(l_last_change_date is null) then
       l_last_change_date := p_effective_date;
       l_proposals_exists := 'NO';
   end if;
--
   if g_debug then
      hr_utility.set_location('l_payroll_attached  '||l_payroll_attached, 10);
      hr_utility.set_location('l_last_payroll_run_date: '||l_last_payroll_run_date, 15);
      hr_utility.set_location('l_last_change_date  '||l_last_change_date, 16);
      hr_utility.set_location('l_proposals_exists: '||l_proposals_exists, 17);
   end if;

--
    -- CASE 1,2,3,4
   l_max_create_date := p_effective_date;
   l_min_create_date := p_effective_date;
   l_max_create_date_src := 'EFFECTIVEDATE';
   if l_max_create_date <= l_last_change_date and l_proposals_exists = 'YES' then
            if l_payroll_attached = 'NO' then
                l_max_create_date := l_last_change_date + 1;
                l_min_create_date := l_last_change_date + 1;
            else
                Open csr_get_next_payroll_date(p_assignment_id,l_last_change_date);
                    Fetch csr_get_next_payroll_date into l_max_create_date;
                Close csr_get_next_payroll_date;
                if l_last_payroll_run_date > l_last_change_date then
                    l_min_create_date := l_last_payroll_run_date + 1;
                else
                    l_min_create_date := l_last_change_date + 1;
                end if;
            end if;
            l_max_create_date_src := 'PAYPROPOSAL';
   elsif l_max_create_date <= l_last_payroll_run_date and l_payroll_attached = 'YES' then
            Open csr_get_next_payroll_date(p_assignment_id,l_last_payroll_run_date);
                Fetch csr_get_next_payroll_date into l_max_create_date;
            Close csr_get_next_payroll_date;
            l_min_create_date := l_last_payroll_run_date + 1;
            l_max_create_date_src := 'PAYROLL';
   end if;
                if g_debug then
                 hr_utility.set_location('l_max_create_date  '||l_max_create_date, 18);
                 hr_utility.set_location('l_min_create_date: '||l_min_create_date, 19);
                end if;

--
   if l_max_create_date_src = 'EFFECTIVEDATE' then
        if l_proposals_exists = 'YES' and l_payroll_attached = 'YES' then
             if l_last_payroll_run_date > l_last_change_date then
                    l_min_create_date := l_last_payroll_run_date + 1;
             else
                    l_min_create_date := l_last_change_date + 1;
             end if;
                if g_debug then
                 hr_utility.set_location('l_max_create_date  '||l_max_create_date, 20);
                 hr_utility.set_location('l_min_create_date: '||l_min_create_date, 21);
                end if;
        elsif l_payroll_attached = 'YES' and l_payroll_attached = 'NO' then
                    l_min_create_date := l_last_payroll_run_date + 1;
                if g_debug then
                 hr_utility.set_location('l_max_create_date  '||l_max_create_date, 22);
                 hr_utility.set_location('l_min_create_date: '||l_min_create_date, 23);
                end if;
        elsif l_payroll_attached = 'NO' and l_proposals_exists = 'YES' then
                    l_min_create_date := l_last_change_date + 1;
                if g_debug then
                 hr_utility.set_location('l_max_create_date  '||l_max_create_date, 24);
                 hr_utility.set_location('l_min_create_date: '||l_min_create_date, 25);
                end if;
        elsif l_payroll_attached = 'NO' and l_proposals_exists = 'NO' then
               Open csr_asst_start_date;
                   Fetch csr_asst_start_date into l_min_create_date;
               Close csr_asst_start_date;
               if l_min_create_date is null then
                    l_min_create_date := l_max_create_date;
               end if;
                if g_debug then
                 hr_utility.set_location('l_max_create_date  '||l_max_create_date, 26);
                 hr_utility.set_location('l_min_create_date: '||l_min_create_date, 27);
                end if;
        end if;
   end if;



   Open csr_future_asst_change_max(l_min_create_date,l_max_create_date);
       Fetch csr_future_asst_change_max into l_future_asst_change_max;
            if g_debug then
            hr_utility.set_location('l_future_asst_change_max  '||l_future_asst_change_max, 28);
            end if;
   Close csr_future_asst_change_max;

   if l_future_asst_change_max is not null then
        l_min_create_date := l_future_asst_change_max;
            if g_debug then
            hr_utility.set_location('l_min_create_date  '||l_min_create_date, 29);
            end if;
   end if;
--
   p_create_date := l_max_create_date;
   p_min_create_date := l_min_create_date;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 30);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 35);
   end if;
--
   Open csr_asst_change_date(l_max_create_date);
       Fetch csr_asst_change_date into l_asst_change_date;
       l_csr_asst_chg_count :=  csr_asst_change_date%ROWCOUNT;
   Close csr_asst_change_date;

--
   Open csr_asst_basis_change_date(l_max_create_date);
       Fetch csr_asst_basis_change_date into l_asst_basis_change_date,l_dflt_asst_basis_id;
       l_csr_asst_basis_chg_count := csr_asst_basis_change_date%ROWCOUNT;
   Close csr_asst_basis_change_date;

--
   Open csr_txn_asst_change_date;
       Fetch csr_txn_asst_change_date into l_txn_asst_change_date;
   Close csr_txn_asst_change_date;

--
   Open csr_txn_basis_change_date;
       Fetch csr_txn_basis_change_date into l_txn_basis_change_date,l_dflt_txn_basis_id,l_orig_txn_basis_id;
   Close csr_txn_basis_change_date;

--
    if (l_asst_change_date is not null and l_csr_asst_chg_count >1) then
            p_allow_create := 'M_BASIS';
            p_status := 5;
         if g_debug then
            hr_utility.set_location('p_create_date  '||p_create_date, 38);
            hr_utility.set_location('p_min_create_date: '||p_min_create_date, 39);
         end if;
   end if;
--
    -- CASE 5,6,7,8
    if (l_txn_basis_change_date is not null and l_asst_basis_change_date is null) then
        if (l_csr_asst_chg_count = 0 and
            ( l_proposals_exists = 'YES' and l_last_change_date <> l_txn_basis_change_date)
            ) then
            p_allow_create := 'YES';
            p_create_date := l_txn_basis_change_date;
            p_min_create_date := l_min_create_date;
            p_default_salary_basis_id := l_dflt_txn_basis_id;
            p_orig_salary_basis_id := l_orig_txn_basis_id;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 1;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 40);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 45);
   end if;
        end if;
    end if;
--
    if (l_txn_basis_change_date is not null and l_asst_basis_change_date is null) then
        if (l_csr_asst_chg_count = 0 and
            ( l_proposals_exists = 'YES' and l_last_change_date = l_txn_basis_change_date)
            ) then
            p_default_salary_basis_id := l_dflt_txn_basis_id;
            p_orig_salary_basis_id := l_orig_txn_basis_id;
            p_allow_basis_change := 'NO';
            p_allow_date_change := 'YES';
            p_status := 1;
             if g_debug then
                hr_utility.set_location('p_create_date  '||p_create_date, 47);
                hr_utility.set_location('p_min_create_date: '||p_min_create_date, 48);
            end if;
        end if;
    end if;
--
    -- CASE 9,10,11,12
    if (l_txn_asst_change_date is not null and l_txn_basis_change_date is null and l_asst_basis_change_date is null) then
        if (l_csr_asst_chg_count = 0) then
            p_allow_create := 'YES';
            p_create_date := l_max_create_date;
            p_min_create_date := l_min_create_date;
            p_basis_default_date := l_txn_asst_change_date;
            p_basis_default_min_date := l_txn_asst_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 2;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 50);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 55);
   end if;
        end if;
    end if;
--
    -- CASE 13,14,15,16
    if (l_asst_basis_change_date is null and l_asst_change_date is not null
        and l_txn_asst_change_date is null) then
            p_allow_create := 'YES';
            p_create_date := l_max_create_date;
            p_min_create_date := l_min_create_date;
            p_basis_default_date := l_asst_change_date;
            p_basis_default_min_date := l_asst_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 3;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 60);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 65);
   end if;
    end if;
--
    -- CASE 17,18,19,20
    if ((l_asst_basis_change_date is null and l_asst_change_date is not null)
        and (l_txn_basis_change_date is null and l_txn_asst_change_date is not null)) then
            p_allow_create := 'YES';
            p_create_date := l_max_create_date;
            p_min_create_date := l_min_create_date;
            p_basis_default_date := l_txn_asst_change_date;
            p_basis_default_min_date := l_asst_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 4;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 70);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 75);
   end if;
    end if;
--
    -- CASE 21,22,23,24
    if ((l_asst_basis_change_date is null and l_asst_change_date is not null)
        and (l_txn_basis_change_date is not null)
        and ( l_proposals_exists = 'YES' and l_last_change_date <> l_txn_basis_change_date)
        ) then
            p_allow_create := 'YES';
            p_create_date := l_txn_basis_change_date;
            p_min_create_date := l_txn_basis_change_date;
            p_default_salary_basis_id := l_dflt_txn_basis_id;
            p_orig_salary_basis_id := l_orig_txn_basis_id;
            p_basis_default_date := l_txn_basis_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 4;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 80);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 85);
   end if;
    end if;
--
    if ((l_asst_basis_change_date is null and l_asst_change_date is not null)
        and (l_txn_basis_change_date is not null)
        and ( l_proposals_exists = 'YES' and l_last_change_date = l_txn_basis_change_date)
        ) then
	   p_basis_default_min_date := l_txn_basis_change_date;
            p_default_salary_basis_id := l_dflt_txn_basis_id;
            p_orig_salary_basis_id := l_orig_txn_basis_id;
            p_basis_default_date := l_txn_basis_change_date;
            p_allow_basis_change := 'NO';
            p_allow_date_change := 'YES';
            p_status := 4;
                if g_debug then
                  hr_utility.set_location('p_create_date  '||p_create_date, 87);
                  hr_utility.set_location('p_min_create_date: '||p_min_create_date, 88);
                end if;
  end if;
--
    -- CASE 25 to 28
    -- CASE 29,30,31,32 partially
    if (l_asst_basis_change_date is not null and l_txn_basis_change_date is null) then
        if (l_csr_asst_basis_chg_count > 1) then
            p_allow_create := 'M_BASIS';
            p_status := 5;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 90);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 95);
   end if;
        elsif (l_csr_asst_basis_chg_count = 1) then
            p_create_date := l_asst_basis_change_date;
            p_min_create_date := l_asst_basis_change_date;
            p_default_salary_basis_id := l_dflt_asst_basis_id;
            p_orig_salary_basis_id := l_orig_txn_basis_id;
            p_basis_default_date := l_asst_basis_change_date;
            p_allow_basis_change := 'NO';
            p_allow_date_change := 'NO';
            p_status := 0;
   if g_debug then
      hr_utility.set_location('p_create_date  '||p_create_date, 100);
      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 105);
   end if;
        end if;
    end if;
--
    -- CASE 29,30,31,32 partially
    if ((l_asst_basis_change_date is not null and l_txn_basis_change_date is not null)
         OR (l_csr_asst_basis_chg_count > 1)) then
            p_allow_create := 'M_BASIS';
            p_status := 5;
         if g_debug then
            hr_utility.set_location('p_create_date  '||p_create_date, 110);
            hr_utility.set_location('p_min_create_date: '||p_min_create_date, 115);
         end if;
   end if;
--
 l_asst_on_gsp := PER_SSHR_CHANGE_PAY.Check_GSP_Manual_Override(p_assignment_id,p_create_date,p_transaction_id);
       if l_asst_on_gsp = 'N' then
            p_allow_create := 'Y_GSP';
             if g_debug then
                hr_utility.set_location('GSP EXISTS  ', 120);
             end if;
            return;
       end if;
--
    if p_default_salary_basis_id is null then

        Open csr_txn_basis_id;
            fetch csr_txn_basis_id into p_default_salary_basis_id, p_orig_salary_basis_id;
        Close csr_txn_basis_id;

        if p_default_salary_basis_id is null then
	        Open csr_pay_basis_exists(p_assignment_id,p_create_date);
        	    fetch csr_pay_basis_exists into p_default_salary_basis_id;
	        Close csr_pay_basis_exists;
	end if;

	 if g_debug then
            hr_utility.set_location('p_default_salary_basis_id  '||p_default_salary_basis_id, 130);
         end if;
    end if;

    if p_default_salary_basis_id is null then
        Open csr_txn_basis_id;
            fetch csr_txn_basis_id into p_default_salary_basis_id, p_orig_salary_basis_id;
        Close csr_txn_basis_id;
         if g_debug then
            hr_utility.set_location('p_default_salary_basis_id  '||p_default_salary_basis_id, 140);
         end if;
    end if;


--
--
End get_create_date;

--
--
--
Procedure get_Create_Date_old(p_assignment_id in NUMBER
                       ,p_effective_date in date
                       ,p_transaction_id in NUMBER
                       ,p_create_date out NOCOPY date
                       ,p_default_salary_basis_id out NOCOPY number
                       ,p_allow_basis_change out NOCOPY varchar2
                       ,p_min_create_date out NOCOPY date
                       ,p_allow_date_change out NOCOPY varchar2
                       ,p_allow_create out NOCOPY varchar2)
is
--
--
 Cursor csr_pay_basis_exists(c_assignment_id number, c_effective_date date) IS
    select pay_basis_id
           from   per_all_assignments_f
           where  assignment_id = c_assignment_id
           and  c_effective_date between effective_start_date and effective_end_date;
--
--
 Cursor csr_last_change_date Is
    select change_date
           from per_pay_proposals
           where assignment_id = p_assignment_id
    union
    select change_date
           from per_pay_transactions ppt,
		        hr_api_transactions hat
           where ppt.assignment_id = p_assignment_id
           and ppt.PARENT_PAY_TRANSACTION_ID is null
	       and ppt.status <> 'DELETE'
		   and ppt.transaction_id=hat.transaction_id
		   and hat.status<>'AC'
    order by change_date desc;
--
--
 Cursor csr_txn_basis_change_date Is
    select hatv1.date_value ,hatv.number_value
           from hr_api_transaction_values hatv,
           hr_api_transaction_steps hats,
           hr_api_transactions hat,
           hr_api_transaction_values hatv1
           where hatv.NAME = 'P_PAY_BASIS_ID'
           and hatv1.NAME = 'P_EFFECTIVE_DATE'
           and hatv1.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
           and hatv.NUMBER_VALUE <> hatv.ORIGINAL_NUMBER_VALUE
           and hatv.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
           and hats.TRANSACTION_ID = hat.TRANSACTION_ID
           and hat.ASSIGNMENT_ID = p_assignment_id
           and hat.TRANSACTION_ID = p_transaction_id
		   and hat.status<>'AC'
           order by hatv1.date_value desc  ;
--
--
 Cursor csr_curr_asst_change_date(l_curr_change_date date) Is
    select effective_start_date
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date <= l_curr_change_date
           order by effective_start_date desc;
--
--
 Cursor csr_last_asst_change_date(l_max_change_date date) Is
    select effective_start_date,pay_basis_id
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date > l_max_change_date
    order by effective_start_date asc;
--
--
 CURSOR csr_get_next_payroll_date
        (p_assignment_id NUMBER
        ,p_effective_date DATE
        )
 IS
     select min(ptp.start_date) next_payroll_date
           	from per_time_periods ptp
           		,per_all_assignments_f paaf
           	where ptp.payroll_id = paaf.payroll_id
           	and paaf.assignment_id = p_assignment_id
           	and ptp.start_date > p_effective_date ;
--
--
   l_last_change_date date;
   l_txn_basis_change_date date;
   l_last_assignment_change_date date;
   l_last_payroll_run_date date;
   l_payroll_param_date date;
   l_payroll_attached varchar2(10);
   l_assign_on_gsp varchar2(10);
   l_pay_basis_id number;
   l_default_asst_salary_basis_id number;
   l_default_txn_salary_basis_id number;
   l_csr_last_asst_chg_dt_count number;
   l_proposals_exists varchar2(10);
--
--
Begin
   --
   --hr_utility.trace_on(null, 'TIGER');
   g_debug := TRUE;
   --
   if g_debug then
      hr_utility.set_location('Entering '||'get_Create_Date', 5);
   end if;
   p_create_date := p_effective_date;
   p_allow_date_change := 'YES';
   p_allow_basis_change := 'YES';
   l_payroll_attached := 'YES';
   l_proposals_exists := 'YES';

   l_last_payroll_run_date := PER_SALADMIN_UTILITY.get_last_payroll_dt(p_assignment_id);

   if g_debug then
      hr_utility.set_location('Selected p_effective_date  '||p_effective_date, 10);
      hr_utility.set_location('l_last_payroll_run_date: '||l_last_payroll_run_date, 15);
   end if;

   if(l_last_payroll_run_date is null) then
       l_last_payroll_run_date := p_effective_date;
       l_payroll_attached := 'NO';
       if g_debug then
         hr_utility.set_location('l_last_payroll_run_date is null and set to '||l_last_payroll_run_date,20);
       end if;
   end if;

   Open  csr_last_change_date;
       Fetch csr_last_change_date into l_last_change_date;
   Close csr_last_change_date;

   Open  csr_txn_basis_change_date;
       Fetch csr_txn_basis_change_date into l_txn_basis_change_date,l_default_txn_salary_basis_id;
   Close csr_txn_basis_change_date;

   if g_debug then
      hr_utility.set_location('l_last_change_date '||l_last_change_date, 25);
      hr_utility.set_location('l_txn_basis_change_date '||l_txn_basis_change_date, 27);
   end if;

    if l_last_change_date is null then
        l_last_change_date := l_last_payroll_run_date;
        l_proposals_exists := 'NO';
            if g_debug then
              hr_utility.set_location('l_last_change_date is null and set to '||l_last_change_date, 30);
            end if;
    end if;

    Open  csr_last_asst_change_date(l_last_change_date);
        Fetch csr_last_asst_change_date into l_last_assignment_change_date,l_default_asst_salary_basis_id;
        l_csr_last_asst_chg_dt_count:=  csr_last_asst_change_date%ROWCOUNT;
    Close csr_last_asst_change_date;

    if g_debug then
      hr_utility.set_location('l_csr_last_asst_chg_dt_count: '||l_csr_last_asst_chg_dt_count, 35);
      hr_utility.set_location('l_last_assignment_change_date: '||l_last_assignment_change_date, 38);
      hr_utility.set_location('l_default_asst_salary_basis_id: '||l_default_asst_salary_basis_id, 39);
   end if;
--
--
    if( (l_txn_basis_change_date is not null and l_last_assignment_change_date is not null and l_txn_basis_change_date <> l_last_assignment_change_date)
         OR
        (l_csr_last_asst_chg_dt_count >1)
      ) then
        p_allow_create := 'M_BASIS';
            if g_debug then
                 hr_utility.set_location('l_csr_last_asst_chg_dt_count>1:: M_BASIS::return ',40);
            end if;
        return;
    else
            if g_debug then
                 hr_utility.set_location('l_csr_last_asst_chg_dt_count<1:: p_allow_create = Y ',43);
            end if;
        p_allow_create := 'Y';
    end if;
--
--
		if (l_txn_basis_change_date is not null) then
		  	if (l_last_change_date = l_txn_basis_change_date) then
				p_allow_basis_change := 'NO';

				if g_debug then
                    hr_utility.set_location('TXN_SAL_BASIS_EXISTS and l_last_change_date = l_txn_basis_change_date',45);
                end if;

				if (l_last_payroll_run_date > l_last_change_date) then

		            if(l_payroll_attached = 'NO') then
                		p_create_date := p_effective_date;
                		p_min_create_date := l_last_change_date;
                		  if g_debug then
                           hr_utility.set_location('p_create_date '||p_create_date,46);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,47);
                          end if;
		            else
                		Open csr_get_next_payroll_date(p_assignment_id,l_last_payroll_run_date);
    	       				Fetch csr_get_next_payroll_date into p_create_date;
     					Close csr_get_next_payroll_date;
     					p_min_create_date := l_last_payroll_run_date;
     					  if g_debug then
                           hr_utility.set_location('p_create_date '||p_create_date,48);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,49);
                          end if;
                    end if;

                elsif (l_last_payroll_run_date = l_last_change_date) then

		            if(l_payroll_attached = 'NO' and l_proposals_exists = 'YES') then
                		p_create_date := l_last_change_date+1;
                		p_min_create_date := l_last_change_date;
                		  if g_debug then
                           hr_utility.set_location('p_create_date '||p_create_date,50);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,51);
                          end if;
                    elsif(l_payroll_attached = 'NO' and l_proposals_exists = 'NO') then
                		p_create_date := p_effective_date;
                		p_min_create_date := p_effective_date;
                		  if g_debug then
                           hr_utility.set_location('p_create_date '||p_create_date,52);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,53);
                          end if;
		            else
                		Open csr_get_next_payroll_date(p_assignment_id,l_last_change_date);
    	       				Fetch csr_get_next_payroll_date into p_create_date;
     					Close csr_get_next_payroll_date;
     					p_min_create_date := l_last_change_date+1;
     					  if g_debug then
                           hr_utility.set_location('p_create_date '||p_create_date,54);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,55);
                          end if;
                    end if;

				elsif (l_last_payroll_run_date < l_last_change_date) then

					if(l_payroll_attached = 'NO') then
                       p_create_date := l_last_change_date+1;
                       p_min_create_date := l_last_change_date;
                            if g_debug then
                             hr_utility.set_location('p_create_date '||p_create_date,56);
                             hr_utility.set_location('p_min_create_date '||p_min_create_date,57);
                            end if;
                    else
					   Open csr_get_next_payroll_date(p_assignment_id,l_last_change_date);
    	       				Fetch csr_get_next_payroll_date into p_create_date;
				       Close csr_get_next_payroll_date;
				       p_min_create_date := l_last_change_date;
				            if g_debug then
                             hr_utility.set_location('p_create_date '||p_create_date,61);
                             hr_utility.set_location('p_min_create_date '||p_min_create_date,63);
                            end if;
                    end if;

				end if;

            else
				--
                if l_payroll_attached = 'NO' then
                   l_last_payroll_run_date := l_last_assignment_change_date;
                end if;
                --
                if l_proposals_exists = 'NO' then
                   l_last_change_date := l_last_assignment_change_date;
                end if;
                --
                if((l_txn_basis_change_date >= l_last_payroll_run_date) and (l_txn_basis_change_date > l_last_change_date)) then
					 p_allow_basis_change := 'YES';
					 p_create_date := l_txn_basis_change_date;
					 p_min_create_date := l_txn_basis_change_date;
					 p_allow_date_change := 'NO';
					     if g_debug then
					       hr_utility.set_location('l_txn_basis_change_date >= l_last_payroll_run_date  l_last_change_date ',66);
                           hr_utility.set_location('p_create_date '||p_create_date,67);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,68);
                         end if;
				else
   					p_create_date := null;
   					    if g_debug then
                          hr_utility.set_location('p_create_date is set to null ', 69);
                        end if;
				end if;
		   end if;
--
--
		elsif (l_last_assignment_change_date is not null) then
		  if (l_last_change_date = l_last_assignment_change_date) then
				--p_allow_basis_change := 'NO';

			     	if g_debug then
                      hr_utility.set_location('AST_SAL_BASIS_CHG_EXISTS', 70);
                    end if;

				if (l_last_payroll_run_date > l_last_change_date) then

		            if(l_payroll_attached = 'NO') then
            		   p_create_date := p_effective_date;
            		   p_min_create_date := l_last_change_date;
            		   if g_debug then
					     hr_utility.set_location('p_create_date '||p_create_date,71);
                         hr_utility.set_location('p_min_create_date '||p_min_create_date,72);
                       end if;
		            else
            		   Open csr_get_next_payroll_date(p_assignment_id,l_last_payroll_run_date);
    	       				Fetch csr_get_next_payroll_date into p_create_date;
                       Close csr_get_next_payroll_date;
                       p_min_create_date := l_last_payroll_run_date;
                        if g_debug then
					      hr_utility.set_location('p_create_date '||p_create_date,73);
                          hr_utility.set_location('p_min_create_date '||p_min_create_date,74);
                        end if;
                	end if;

          	   elsif (l_last_payroll_run_date = l_last_change_date) then

		            if(l_payroll_attached = 'NO' and l_proposals_exists = 'YES') then
            		   p_create_date := l_last_change_date+1;
            		   p_min_create_date := l_last_change_date;
            		   if g_debug then
					     hr_utility.set_location('p_create_date '||p_create_date,75);
                         hr_utility.set_location('p_min_create_date '||p_min_create_date,76);
                       end if;
                    elsif(l_payroll_attached = 'NO' and l_proposals_exists = 'NO') then
                		p_create_date := p_effective_date;
                		p_min_create_date := p_effective_date;
                		  if g_debug then
                           hr_utility.set_location('p_create_date '||p_create_date,77);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,78);
                          end if;
		            else
            		   Open csr_get_next_payroll_date(p_assignment_id,l_last_payroll_run_date);
    	       				Fetch csr_get_next_payroll_date into p_create_date;
                       Close csr_get_next_payroll_date;
                       p_min_create_date := l_last_change_date;
                        if g_debug then
					      hr_utility.set_location('p_create_date '||p_create_date,79);
                          hr_utility.set_location('p_min_create_date '||p_min_create_date,80);
                        end if;
                	end if;

		       elsif (l_last_payroll_run_date < l_last_change_date) then

					if(l_payroll_attached = 'NO') then
			           p_create_date := l_last_change_date+1;
			           p_min_create_date := l_last_change_date;
			                 if g_debug then
					          hr_utility.set_location('p_create_date '||p_create_date,83);
                              hr_utility.set_location('p_min_create_date '||p_min_create_date,84);
                             end if;
                    else
					   Open csr_get_next_payroll_date(p_assignment_id,l_last_change_date);
 	       			      	Fetch csr_get_next_payroll_date into p_create_date;
				       Close csr_get_next_payroll_date;
				       p_min_create_date := l_last_change_date;
				              if g_debug then
					           hr_utility.set_location('p_create_date '||p_create_date,87);
                               hr_utility.set_location('p_min_create_date '||p_min_create_date,88);
                              end if;
                    end if;

    		   end if;
    		 else
                --
                if l_payroll_attached = 'NO' then
                   l_last_payroll_run_date := l_last_assignment_change_date;
                end if;
                --
                if l_proposals_exists = 'NO' then
                   l_last_change_date := l_last_assignment_change_date;
                end if;
                --
                if((l_last_assignment_change_date >= l_last_payroll_run_date) and (l_last_assignment_change_date > l_last_change_date)) then
					p_allow_basis_change := 'YES';
					p_create_date := l_last_assignment_change_date;
					p_min_create_date := l_txn_basis_change_date;
					p_allow_date_change := 'NO';
					       if g_debug then
             			     hr_utility.set_location('l_last_assignment_change_date > l_last_payroll_run_date  ',90);
					         hr_utility.set_location('p_create_date '||p_create_date,95);
                             hr_utility.set_location('p_min_create_date '||p_min_create_date,96);
                           end if;
				else
					p_create_date := null;
					if g_debug then
                      hr_utility.set_location('p_create_date is set null ', 100);
                    end if;
				end if;
		end if;
--
--
	else
    	    if g_debug then
              hr_utility.set_location('NO_SAL_BASIS_CHG ', 101);
            end if;
		p_allow_basis_change := 'YES';

		if (l_last_payroll_run_date > l_last_change_date) then

			if(l_payroll_attached = 'NO') then
               p_create_date := p_effective_date;
               p_min_create_date := l_last_change_date;
                    if g_debug then
                    hr_utility.set_location('p_create_date: '||p_create_date, 101);
                    hr_utility.set_location('p_min_create_date: '||p_min_create_date, 102);
                    end if;
            else
               Open csr_get_next_payroll_date(p_assignment_id,l_last_payroll_run_date);
 		             Fetch csr_get_next_payroll_date into p_create_date;
               Close csr_get_next_payroll_date;
               p_min_create_date := l_last_payroll_run_date;
                        if g_debug then
                        hr_utility.set_location('p_create_date: '||p_create_date, 103);
                        hr_utility.set_location('p_min_create_date: '||p_min_create_date, 104);
                        end if;
            end if;

        elsif (l_last_payroll_run_date = l_last_change_date) then

			if(l_payroll_attached = 'NO' and l_proposals_exists = 'YES' ) then
               p_create_date := l_last_change_date+1;
               p_min_create_date := p_effective_date;
                    if g_debug then
                    hr_utility.set_location('p_create_date: '||p_create_date, 105);
                    hr_utility.set_location('p_min_create_date: '||p_min_create_date, 106);
                    end if;
            elsif(l_payroll_attached = 'NO' and l_proposals_exists = 'NO') then
                		p_create_date := p_effective_date;
                		p_min_create_date := p_effective_date;
                		  if g_debug then
                           hr_utility.set_location('p_create_date '||p_create_date,107);
                           hr_utility.set_location('p_min_create_date '||p_min_create_date,108);
                          end if;
            else
               Open csr_get_next_payroll_date(p_assignment_id,l_last_change_date);
 		             Fetch csr_get_next_payroll_date into p_create_date;
               Close csr_get_next_payroll_date;
               p_min_create_date := l_last_change_date+1;
                        if g_debug then
                        hr_utility.set_location('p_create_date: '||p_create_date, 109);
                        hr_utility.set_location('p_min_create_date: '||p_min_create_date, 110);
                        end if;
            end if;

		elsif (l_last_payroll_run_date < l_last_change_date) then

            if(l_payroll_attached = 'NO') then
              p_create_date := l_last_change_date+1;
              p_min_create_date := l_last_change_date;
                    if g_debug then
                    hr_utility.set_location('p_create_date: '||p_create_date, 111);
                    hr_utility.set_location('p_min_create_date: '||p_min_create_date, 112);
                    end if;
            else
              Open csr_get_next_payroll_date(p_assignment_id,l_last_change_date);
    	         Fetch csr_get_next_payroll_date into p_create_date;
		      Close csr_get_next_payroll_date;
		      p_min_create_date := l_last_change_date;
		              if g_debug then
                      hr_utility.set_location('p_create_date: '||p_create_date, 117);
                      hr_utility.set_location('p_min_create_date: '||p_min_create_date, 118);
                      end if;
            end if;

		end if;
    end if;
--
--
--
--
   l_assign_on_gsp := PER_SALADMIN_UTILITY.Check_GSP_Manual_Override(p_assignment_id,p_create_date);

       if l_assign_on_gsp = 'N' then
            p_allow_create := 'Y_GSP';
            return;
       else
            p_allow_create := 'N_GSP';
       end if;
--
--
   Open csr_pay_basis_exists(p_assignment_id, p_create_date);
       Fetch csr_pay_basis_exists into l_pay_basis_id;
   Close csr_pay_basis_exists;

   if l_pay_basis_id is null then
      p_allow_create := 'N_BASIS';
      return;
   else
      p_allow_create := 'Y_BASIS';
   end if;
--
--
   if g_debug then
     hr_utility.set_location('csr_pay_basis_exists : '||l_pay_basis_id, 120);
     hr_utility.set_location('p_allow_create : '||p_allow_create, 121);
   end if;
--
--
   if l_default_txn_salary_basis_id is not null then
        p_default_salary_basis_id := l_default_txn_salary_basis_id;
        if g_debug then
          hr_utility.set_location('l_default_txn_salary_basis_id is not null ', 122);
        end if;
   elsif l_default_asst_salary_basis_id is not null then
        p_default_salary_basis_id := l_default_asst_salary_basis_id;
        if g_debug then
          hr_utility.set_location('l_default_asst_salary_basis_id is not null ', 124);
        end if;
   end if;
--
--
   if l_proposals_exists = 'NO' then
        if l_payroll_attached = 'NO' then
            Open  csr_curr_asst_change_date(p_create_date);
                Fetch csr_curr_asst_change_date into p_min_create_date;
            Close csr_curr_asst_change_date;
            if g_debug then
              hr_utility.set_location('p_min_create_date is not null '||p_min_create_date, 130);
            end if;
        else
            p_min_create_date := l_last_payroll_run_date;
            if g_debug then
              hr_utility.set_location('p_min_create_date is not null '||p_min_create_date, 140);
            end if;
        end if;
    end if;
--
--
    if g_debug then
      hr_utility.set_location('Leaving: '||'get_Create_Date', 150);
   end if;
--
--
End get_Create_Date_old;
--
--
--
Function get_payroll_period(p_payroll_id in NUMBER)
RETURN VARCHAR2 is

   CURSOR csr_period_table is
        select nvl(DESCRIPTION,ptt.period_type)
        from PER_TIME_PERIOD_TYPES ptt
        ,pay_all_payrolls_f pap
		,per_all_assignments_f paa
		where pap.payroll_id = p_payroll_id
        and ptt.period_type = pap.period_type;

    l_period varchar2(30);
BEGIN
     Open csr_period_table;
            Fetch csr_period_table into l_period;
     Close csr_period_table;

return l_period;
END get_payroll_period;


--
PROCEDURE get_update_param
        ( p_assignment_id in Number
    	, p_transaction_id in Number
	    , p_current_date in Date
        , p_previous_date in Date
	    , p_proposal_exists in Varchar2
        , p_allow_basis_change out NOCOPY varchar2
        , p_min_update_date out NOCOPY date
        , p_allow_date_change out NOCOPY varchar2
	    , p_status out NOCOPY Number
	    , p_basis_default_date out NOCOPY date
	    , p_basis_default_min_date out NOCOPY date
        , p_orig_basis_id out NOCOPY Number)
is
--
--
 Cursor csr_txn_basis_change_date Is
  select hatv1.date_value ,hatv.number_value, hatv.original_number_value
           from hr_api_transaction_values hatv,
           hr_api_transaction_steps hats,
           hr_api_transactions hat,
           hr_api_transaction_values hatv1
           where hatv.NAME = 'P_PAY_BASIS_ID'
           and hatv1.NAME = 'P_EFFECTIVE_DATE'
           and hatv1.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
           and hatv.NUMBER_VALUE <> hatv.ORIGINAL_NUMBER_VALUE
           and hatv.TRANSACTION_STEP_ID = hats.TRANSACTION_STEP_ID
           and hats.TRANSACTION_ID = hat.TRANSACTION_ID
           and hat.ASSIGNMENT_ID = p_assignment_id
           and hat.TRANSACTION_ID = p_transaction_id
		   and hat.status<>'AC'
           order by hatv1.date_value desc  ;
--
 Cursor csr_txn_asst_change_date Is
    select hatv.date_value
           from hr_api_transaction_steps hats,
           hr_api_transactions hat,
           hr_api_transaction_values hatv
           where hats.api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
           and hatv.transaction_step_id = hats.transaction_step_id
           and hatv.name = 'P_EFFECTIVE_DATE'
           and hats.TRANSACTION_ID = hat.TRANSACTION_ID
           and hat.ASSIGNMENT_ID = p_assignment_id
           and hat.TRANSACTION_ID = p_transaction_id
		   and hat.status<>'AC';
--
 Cursor csr_future_asst_change_max(l_min_change_date date,l_change_date date) Is
    select effective_start_date
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date > l_min_change_date
           and effective_start_date < l_change_date
    order by effective_start_date desc;
--
 Cursor csr_asst_change_date(l_max_change_date date) Is
    select effective_start_date
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date > l_max_change_date
    order by effective_start_date asc;
--
  Cursor csr_asst_basis_change_date(l_max_change_date date) Is
    select effective_start_date,pay_basis_id
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date > l_max_change_date
           and pay_basis_id <> (Select pay_basis_id from per_all_assignments_f
	                               where assignment_id = p_assignment_id
                         	       and l_max_change_date between effective_start_date
                                                         and effective_end_date)
    order by effective_start_date asc;
--
 CURSOR csr_get_next_payroll_date
        (l_assignment_id NUMBER
        ,l_date DATE
        )
 IS
     select min(ptp.start_date) next_payroll_date
           	from per_time_periods ptp
           		,per_all_assignments_f paaf
           	where ptp.payroll_id = paaf.payroll_id
           	and paaf.assignment_id = l_assignment_id
           	and ptp.start_date > l_date ;
--
--
l_last_payroll_run_date date;
l_max_create_date date;
l_min_create_date date;
l_max_create_date_src varchar2(20);
l_future_asst_change_max date;
l_asst_change_date date;
l_csr_asst_chg_count number;
l_asst_basis_change_date date;
l_dflt_asst_basis_id number;
l_txn_asst_change_date date;
l_txn_basis_change_date date;
l_dflt_txn_basis_id number;
l_orig_txn_basis_id number;
l_payroll_attached varchar2(20);
l_csr_asst_basis_chg_count number;
--
--
Begin
--
--
    l_payroll_attached := 'YES';
    p_allow_date_change := 'YES';
    p_allow_basis_change := 'YES';
    p_status := 1;
    p_basis_default_date := null;
    p_basis_default_min_date := null;
    p_min_update_date := null;
--
--
   l_last_payroll_run_date := PER_SALADMIN_UTILITY.get_last_payroll_dt(p_assignment_id);
   if(l_last_payroll_run_date is null) then
       l_last_payroll_run_date := p_previous_date;
       l_payroll_attached := 'NO';
   end if;
--
  if g_debug then
    hr_utility.set_location('get_update_param  ', 5);
    hr_utility.set_location('l_payroll_attached  '||l_payroll_attached, 10);
    hr_utility.set_location('l_last_payroll_run_date: '||l_last_payroll_run_date, 15);
  end if;
   l_max_create_date := p_previous_date;
   l_min_create_date := p_previous_date;
   l_max_create_date_src := 'EFFECTIVEDATE';

   if (l_max_create_date <= l_last_payroll_run_date and l_payroll_attached = 'YES' )then
            Open csr_get_next_payroll_date(p_assignment_id,l_last_payroll_run_date);
                Fetch csr_get_next_payroll_date into l_max_create_date;
            Close csr_get_next_payroll_date;
            l_min_create_date := l_last_payroll_run_date + 1;
            l_max_create_date_src := 'PAYROLL';
   end if;

   if l_max_create_date_src = 'EFFECTIVEDATE' then
	 if (l_payroll_attached = 'YES' and l_last_payroll_run_date > p_previous_date )then
		l_min_create_date := l_last_payroll_run_date + 1;
	 else
		l_min_create_date := p_previous_date + 1;
	 end if;
  end if;

   Open csr_future_asst_change_max(l_min_create_date,l_max_create_date);
       Fetch csr_future_asst_change_max into l_future_asst_change_max;
   Close csr_future_asst_change_max;

    if l_future_asst_change_max is not null then
        l_min_create_date := l_future_asst_change_max;
   end if;

   p_min_update_date := l_min_create_date;

    if g_debug then
     hr_utility.set_location('l_max_create_date  '||l_max_create_date, 25);
     hr_utility.set_location('p_current_date: '||p_current_date, 26);
     hr_utility.set_location('l_min_create_date: '||l_min_create_date, 30);
     hr_utility.set_location('l_max_create_date_src: '||l_max_create_date_src, 31);

    end if;
--
   Open csr_asst_change_date(l_max_create_date);
       Fetch csr_asst_change_date into l_asst_change_date;
       l_csr_asst_chg_count :=  csr_asst_change_date%ROWCOUNT;
   Close csr_asst_change_date;
--
   Open csr_asst_basis_change_date(l_max_create_date);
       Fetch csr_asst_basis_change_date into l_asst_basis_change_date,l_dflt_asst_basis_id;
       l_csr_asst_basis_chg_count := csr_asst_basis_change_date%ROWCOUNT;
   Close csr_asst_basis_change_date;
--
   Open csr_txn_asst_change_date;
       Fetch csr_txn_asst_change_date into l_txn_asst_change_date;
   Close csr_txn_asst_change_date;
--
   Open csr_txn_basis_change_date;
       Fetch csr_txn_basis_change_date into l_txn_basis_change_date,l_dflt_txn_basis_id,p_orig_basis_id;
   Close csr_txn_basis_change_date;
--
    if (l_txn_asst_change_date is not null and l_txn_asst_change_date = p_current_date and l_asst_change_date is not null) then
        if g_debug then
        hr_utility.set_location('l_txn_asst_change_date  '||l_txn_asst_change_date, 32);
        end if;
        l_txn_asst_change_date := null;
    end if;

    if (l_txn_basis_change_date is not null and l_txn_basis_change_date = p_current_date) then
        if g_debug then
        hr_utility.set_location('l_txn_asst_change_date  '||l_txn_asst_change_date, 33);
        end if;
        l_txn_basis_change_date := null;
    end if;
--
if g_debug then
     hr_utility.set_location('l_asst_change_date  '||l_asst_change_date, 36);
     hr_utility.set_location('l_asst_basis_change_date: '||l_asst_basis_change_date, 37);
     hr_utility.set_location('l_txn_asst_change_date: '||l_txn_asst_change_date, 38);
     hr_utility.set_location('l_txn_basis_change_date: '||l_txn_basis_change_date, 39);
end if;
--
if (l_txn_basis_change_date is not null and l_asst_basis_change_date is null) then
        if (l_csr_asst_chg_count = 0 and
            ( p_proposal_exists = 'YES' and p_previous_date <> l_txn_basis_change_date)
            ) then
            p_min_update_date := l_min_create_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 1;
             if g_debug then
                hr_utility.set_location('p_min_update_date  '||p_min_update_date, 40);
                hr_utility.set_location('p_allow_basis_change  '||p_allow_basis_change, 50);
                hr_utility.set_location('p_allow_date_change  '||p_allow_date_change, 51);
            end if;
       end if;
end if;
--
if (l_txn_basis_change_date is not null and l_asst_basis_change_date is null) then
        if (l_csr_asst_chg_count = 0 and
            ( p_proposal_exists = 'YES' and p_previous_date = l_txn_basis_change_date)
            ) then
            p_allow_basis_change := 'NO';
            p_allow_date_change := 'YES';
            p_status := 1;
             if g_debug then
                hr_utility.set_location('p_allow_date_change  '||p_allow_date_change, 50);
                hr_utility.set_location('p_allow_basis_change  '||p_allow_basis_change, 60);
            end if;
      end if;
end if;
--
if (l_txn_asst_change_date is not null and l_txn_basis_change_date is null and l_asst_basis_change_date is null) then
        if (l_csr_asst_chg_count = 0) then
            p_min_update_date := l_min_create_date;
            p_basis_default_date := l_txn_asst_change_date;
            p_basis_default_min_date := l_txn_asst_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 2;
             if g_debug then
                hr_utility.set_location('p_min_update_date  '||p_min_update_date, 65);
                hr_utility.set_location('p_basis_default_date  '||p_basis_default_date, 70);
                hr_utility.set_location('p_basis_default_min_date  '||p_basis_default_min_date, 71);
                hr_utility.set_location('p_allow_basis_change  '||p_allow_basis_change, 72);
            end if;
        end if;
    end if;
--
if (l_asst_basis_change_date is null and l_asst_change_date is not null
        and l_txn_asst_change_date is null) then
            p_min_update_date := l_min_create_date;
            p_basis_default_date := l_asst_change_date;
            p_basis_default_min_date := l_asst_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 3;
             if g_debug then
                hr_utility.set_location('p_min_update_date  '||p_min_update_date, 75);
                hr_utility.set_location('p_basis_default_date  '||p_basis_default_date, 80);
                hr_utility.set_location('p_basis_default_min_date  '||p_basis_default_min_date, 81);
            end if;
end if;
--
if ((l_asst_basis_change_date is null and l_asst_change_date is not null)
        and (l_txn_basis_change_date is null and l_txn_asst_change_date is not null)) then
            p_min_update_date := l_min_create_date;
            p_basis_default_date := l_txn_asst_change_date;
            p_basis_default_min_date := l_asst_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 4;
             if g_debug then
                hr_utility.set_location('p_min_update_date  '||p_min_update_date, 85);
                hr_utility.set_location('p_basis_default_date  '||p_basis_default_date, 90);
                hr_utility.set_location('p_basis_default_min_date  '||p_basis_default_min_date, 91);
            end if;
end if;
--
if ((l_asst_basis_change_date is null and l_asst_change_date is not null)
        and (l_txn_basis_change_date is not null)
        and ( p_proposal_exists = 'YES' and p_previous_date <> l_txn_basis_change_date)
        ) then
            p_min_update_date := l_txn_basis_change_date;
            p_basis_default_date := l_txn_basis_change_date;
            p_allow_basis_change := 'YES';
            p_allow_date_change := 'YES';
            p_status := 4;
             if g_debug then
                hr_utility.set_location('p_min_update_date  '||p_min_update_date, 95);
                hr_utility.set_location('p_basis_default_date  '||p_basis_default_date, 100);
            end if;
end if;
--
if ((l_asst_basis_change_date is null and l_asst_change_date is not null)
        and (l_txn_basis_change_date is not null)
        and ( p_proposal_exists = 'YES' and p_previous_date = l_txn_basis_change_date)
        ) then
            p_basis_default_min_date := l_txn_basis_change_date;
            p_basis_default_date := l_txn_basis_change_date;
            p_allow_basis_change := 'NO';
            p_allow_date_change := 'YES';
            p_status := 4;
             if g_debug then
                hr_utility.set_location('p_min_update_date  '||p_min_update_date, 105);
                hr_utility.set_location('p_basis_default_date  '||p_basis_default_date, 100);
                hr_utility.set_location('p_basis_default_min_date  '||p_basis_default_min_date, 101);
            end if;
end if;
--
if (l_asst_basis_change_date is not null and l_txn_basis_change_date is null) then
        if (l_csr_asst_basis_chg_count = 1) then
            p_min_update_date := l_asst_basis_change_date;
            p_basis_default_date := l_asst_basis_change_date;
            p_allow_basis_change := 'NO';
            p_allow_date_change := 'NO';
            p_status := 0;
             if g_debug then
                hr_utility.set_location('p_min_update_date  '||p_min_update_date, 115);
                hr_utility.set_location('p_basis_default_date  '||p_basis_default_date, 120);
                hr_utility.set_location('p_basis_default_date  '||p_basis_default_date, 121);
            end if;
        end if;
end if;
--
--
--
End get_update_param;
--
--

FUNCTION get_fte_factor(p_assignment_id IN NUMBER
                       ,p_effective_date IN DATE
                       ,p_transaction_id IN NUMBER)
return NUMBER IS
--
l_fte_profile_value VARCHAR2(240) := fnd_profile.VALUE('BEN_CWB_FTE_FACTOR');
--
CURSOR csr_fte_BFTE
IS
select nvl(value, 1) val
  from  per_assignment_budget_values_f
 where  assignment_id   = p_assignment_id
   and  unit = 'FTE'
   and  p_effective_date BETWEEN effective_start_date AND effective_end_date;
--
CURSOR csr_fte_BPFT
IS
select nvl(value, 1) val
 from  per_assignment_budget_values_f
where  assignment_id    = p_assignment_id
  and  unit = 'PFT'
  and p_effective_date BETWEEN effective_start_date AND effective_end_date;
--
---vkodedal 8593436 added effective date column
cursor get_asg_hours is
select max(astHoursCol) as astHours,
                decode(max(frequencyCol)
               ,'Y',1
               ,'M',12
               ,'W',52
               ,'D',365
               ,1) as frequency,
                max(effDateCol)
from(
select   decode(NAME, 'P_FREQUENCY', VARCHAR2_VALUE) frequencyCol,
         decode(NAME, 'P_NORMAL_HOURS', NUMBER_VALUE) astHoursCol,
         decode(NAME, 'P_EFFECTIVE_DATE',DATE_VALUE)  effDateCol
  from hr_api_transaction_values
  where TRANSACTION_STEP_ID = (select TRANSACTION_STEP_ID from hr_api_transaction_steps
  								where API_NAME = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
  								and TRANSACTION_ID = p_transaction_id)
)  ;

--changed by schowdhu for hire flow Bug#7307885 - 05-Sep-08

cursor chk_asg_rec is
 select null
 from per_all_assignments_f  paa
 where paa.assignment_id = p_assignment_id;
cursor get_ids is
Select max(position_id) position_id , max(org_id) org_id, max(bg_id) bg_id from (
select decode (NAME, 'P_POSITION_ID', NUMBER_VALUE) position_id,
       decode (NAME, 'P_ORGANIZATION_ID', NUMBER_VALUE) org_id,
       decode (NAME, 'P_BUSINESS_GROUP_ID', NUMBER_VALUE) bg_id
  from hr_api_transaction_values
  where TRANSACTION_STEP_ID = (select TRANSACTION_STEP_ID from hr_api_transaction_steps
  								where API_NAME = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
  								and TRANSACTION_ID = p_transaction_id));

cursor get_pos_hrs (l_pos_id in NUMBER) is
      select pos.working_hours,
      decode(pos.frequency
                 ,'Y',1
                 ,'M',12
                 ,'W',52
                 ,'D',365
                 ,1)
      from   hr_all_positions pos
      where  pos.position_id = l_pos_id;

cursor get_org_hrs (l_org_id in NUMBER) is
    select fnd_number.canonical_to_number(org.org_information3) normal_hours
  ,      decode(org.org_information4
               ,'Y',1
               ,'M',12
               ,'W',52
               ,'D',365
               ,1)
  from   HR_ORGANIZATION_INFORMATION org
  where  org.organization_id(+) = l_org_id
  and    org.org_information_context(+) = 'Work Day Information';

 cursor get_bus_hrs(l_bg_id in NUMBER) is
  select fnd_number.canonical_to_number(bus.working_hours) normal_hours
  ,      decode(bus.frequency
               ,'Y',1
               ,'M',12
               ,'W',52
               ,'D',365
               ,1)
  from   per_business_groups bus
  where  bus.business_group_id = l_bg_id;

--
l_fte_factor number := null;
l_norm_hours_per_year number;
l_hours_per_year number;
l_hours NUMBER;
l_frequency NUMBER;
l_eff_date  DATE;
--added for new hire flow

l_pos_id NUMBER;
l_org_id NUMBER;
l_bg_id NUMBER;
l_exists varchar2(1);

--
--
BEGIN
--
  if g_debug then
    hr_utility.set_location('get_fte_factor ', 5);
  end if;

  if (l_fte_profile_value = 'NHBGWH') then
         open get_asg_hours;
         fetch get_asg_hours into l_hours,l_frequency,l_eff_date;

         if (get_asg_hours%found and l_hours is not null) THEN
           l_hours_per_year:=nvl(l_hours,0)*l_frequency;
         else
           l_hours_per_year:=null;
         end if;
         close get_asg_hours;
--vkodedal 8593436 30-Jun-2009 added or condition
         if l_hours_per_year is null OR l_eff_date > p_effective_date then
         	l_fte_factor := PER_SALADMIN_UTILITY.get_fte_factor(p_assignment_id,p_effective_date);
         	RETURN l_fte_factor;
         end if;

         if(nvl(l_hours_per_year,0) <> 0) then
         PER_PAY_PROPOSALS_POPULATE.get_norm_hours(p_assignment_id
                    ,p_effective_date
                    ,l_norm_hours_per_year);

--changed by schowdhu for hire flow
l_hours := null;
l_frequency := null;

open chk_asg_rec;
fetch chk_asg_rec into l_exists;
if (chk_asg_rec%notfound)  then -- then hire flow

  --find all the ids
   open get_ids;
   fetch get_ids into l_pos_id, l_org_id, l_bg_id;
   close get_ids;

  --fetch the position hours, freqn
    if (l_pos_id is not null) then
        open get_pos_hrs(l_pos_id);
        fetch get_pos_hrs into l_hours, l_frequency;
        close get_pos_hrs;
    end if;

    if (l_hours is null or l_frequency is null or l_org_id is not null ) then
        hr_utility.set_location('-1-', 20);
        open get_org_hrs(l_org_id);
        fetch get_org_hrs into l_hours, l_frequency;
        close get_org_hrs;
    end if;

    if (l_hours is null or l_frequency is null or l_bg_id is not null) then
        hr_utility.set_location('-2-', 20);
        open get_bus_hrs(l_bg_id);
        fetch get_bus_hrs into l_hours, l_frequency;
        close get_bus_hrs;
    end if;
  l_norm_hours_per_year := nvl(l_hours, 0) * l_frequency;
end if;
close chk_asg_rec;

--changed by schowdhu for hire flow

       if ( nvl(l_norm_hours_per_year,0) = 0) then
         l_fte_factor := 1;
       else
         l_fte_factor := l_hours_per_year/l_norm_hours_per_year;
       end if;
      else
        l_fte_factor := 1;
      end if;
  elsif (l_fte_profile_value = 'BFTE') then
    for r1 in csr_fte_BFTE loop
     l_fte_factor := r1.val;
    end loop;
  elsif (l_fte_profile_value = 'BPFT') then
    for r1 in csr_fte_BPFT loop
     l_fte_factor := r1.val;
    end loop;
  else
   l_fte_factor := 1;
  end if;
-- fte can be more than 1. Bug #7497075 schowdhu
--if (l_fte_factor is null or  l_fte_factor > 1) then
if (l_fte_factor is null) then
 l_fte_factor := 1;
end if;
--

RETURN l_fte_factor;
END get_fte_factor;

--
--
End;



/
