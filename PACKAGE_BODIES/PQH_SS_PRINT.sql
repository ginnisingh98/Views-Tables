--------------------------------------------------------
--  DDL for Package Body PQH_SS_PRINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SS_PRINT" as
/* $Header: pqprtswi.pkb 120.9 2006/09/26 11:36:46 krajarat noship $ */

-- Declaring global variables.
--
g_session_id     NUMBER;
g_transaction_id NUMBER;
g_debug   boolean      := hr_utility.debug_enabled;
g_package varchar2(72) := 'pqh_ss_print';
g_effective_date    DATE;

--
-- This procedure will be called from RefreshAMImpl, to set
-- g_effective_date in order to get proper values for
-- get_change_reason,get_employement_category etc for refresh
-- attributes functionality
--
PROCEDURE set_eff_dte_for_refresh_atts is
cursor c_session_date is
select effective_date
from fnd_sessions
where session_id = userenv('sessionid');
begin

         open c_session_date;
         fetch c_session_date into g_effective_date;
         close c_session_date;
end;

--
-- This function will be invoked from Fast Formula , Example :PQH_DOCUMENTS_FASTFORMULA
-- Print_document_data / set_document_data
--
-- If tag_value is null,
function get_session_details (p_txn_id OUT NOCOPY NUMBER, p_session_id OUT NOCOPY NUMBER, p_effective_date OUT NOCOPY DATE)
return number
IS
BEGIN

      select userenv('sessionid') into p_session_id from dual;
      select trunc(sysdate) into p_effective_date from dual;
      p_txn_id :=g_transaction_id;

return 0;

END;


--
FUNCTION set_document_data(p_tag_name IN VARCHAR2,
                           p_tag_value IN VARCHAR2)
RETURN NUMBER IS
--
-- Declaring cursors here.
--

-- this cursor checks for given tag present in pqh_ss_print_data or not.
--
Cursor csr_check_tag_exists(p_tag_name VARCHAR2,p_session_id number) IS
   Select 'X'
   From pqh_ss_print_data
   Where name = p_tag_name -- no upper case change
   and session_id = p_session_id
   and transaction_id =g_transaction_id;


--
-- Local variable declartion goes here.
--
l_result     VARCHAR2(100);
l_session_id NUMBER;
l_transaction_id NUMBER;

BEGIN
           -- Get session_id into l_session_id, this session_id will be inserted into
           -- temp table.
           -- If p_transaction_id is null then make use of g_transaction_id else
           -- g_transaction_id gets p_transaction_id value.


           --
              l_transaction_id  := g_transaction_id;
           --



	    SELECT userenv('sessionid') into l_session_id from dual;

               OPEN csr_check_tag_exists(p_tag_name,l_session_id);

                 FETCH csr_check_tag_exists into l_result;

                 CLOSE csr_check_tag_exists;
                 IF (l_result IS NULL ) THEN -- i.e. l_result is null , no record with current tag,
                   --
                     INSERT INTO PQH_SS_PRINT_DATA(session_id,transaction_id,name,value)
                     VALUES (l_session_id, l_transaction_id,p_tag_name,p_tag_value);

                 ELSE

                     UPDATE PQH_SS_PRINT_DATA
                     SET   value = p_tag_value
                     WHERE session_id = l_session_id
                     AND name = p_tag_name
                     AND transaction_id = l_transaction_id;

                 END IF;

                 l_result := null;


RETURN 0;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   RETURN 0;
END;

----
---
---
FUNCTION get_function_parameter_value(
                  p_parameter_name IN VARCHAR2,
                  p_transaction_id IN VARCHAR2,
                  p_type_code      IN VARCHAR2 default 'PRE',
                  p_effective_date IN VARCHAR2)
RETURN VARCHAR2 IS
--
-- Defining cursors
--
Cursor csr_parameter_value IS
SELECT decode(SemiProcessedName ,'N/A','N/A', nvl(substr(SemiProcessedName , 1, instr(SemiProcessedName,'&')-1),SemiProcessedName)) ShortName
From
(
SELECT decode(instr(parameters,p_parameter_name),null,'N/A',0 ,'N/A',
substr(parameters,instr(parameters,p_parameter_name)+length(p_parameter_name)+1)) SemiProcessedName
FROM fnd_form_functions FFF,
     hr_api_transactions HAT
WHERE HAT.transaction_id = p_transaction_id
   AND HAT.function_id = FFF.function_id
);
--
--
Cursor csr_check_grp_existency(p_short_name varchar2, p_eff_date date) IS
Select count(*)
from pqh_transaction_categories cats,
     pqh_txn_category_documents catDocs,
     pqh_documents_f docs
where form_name like 'PQH_GROUPS'
and   cats.short_name like p_short_name
and   cats.transaction_category_id = catDocs.transaction_category_id
and   docs.document_id = catDocs.document_id
and   nvl(p_eff_date,trunc(sysdate)) between effective_start_date and effective_end_date;
--
--
Cursor csr_valid_grp_documents(p_short_name varchar2) IS
Select count(*)
from pqh_txn_category_documents
where transaction_category_id = (
              Select transaction_category_id
              from pqh_transaction_categories
              where short_name =p_short_name)
and type_code in ( p_type_code, 'BOTH');
--
--
-- Defining local variables.
--
l_parameter_value varchar2(100):=null;
l_effective_date date := null;
l_pdf_in_table   varchar2(10);
--
BEGIN

  --
  OPEN csr_parameter_value;
     Fetch csr_parameter_value into l_parameter_value;
  CLOSE csr_parameter_value;
  --
  -- Set the date
  l_effective_date := fnd_date.canonical_to_date(p_effective_date);

   If (l_effective_date is null) then
      l_effective_date := trunc(sysdate);
   End if;

  hr_util_misc_ss.setEffectiveDate(l_effective_date);

  --
  -- Check this short_name is valid name as on that date or not.
  --
  IF l_parameter_value <> 'N/A' and p_parameter_name='pGroupName' THEN
  --
  		OPEN csr_check_grp_existency(l_parameter_value , l_effective_date);
  		    Fetch csr_check_grp_existency into l_pdf_in_table;
  		CLOSE csr_check_grp_existency;

               IF l_pdf_in_table = 0 THEN
  		--If Group Not Exists
                   l_parameter_value := 'INVALID';
                --
               Else
               -- If Group is Present
               -- Check any PRE/BOTH type of Document s attched to group or Not
               --
                  OPEN csr_valid_grp_documents(l_parameter_value);
                     FETCH csr_valid_grp_documents into l_pdf_in_table;
                  CLOSE csr_valid_grp_documents;
                 IF l_pdf_in_table = 0 THEN
                 --
  		  l_parameter_value := 'INVALID';
                 --
                 END IF;
  		--
  		END IF;
  --
  END IF;


return l_parameter_value;
--
END get_function_parameter_value;

--
--This procedure Populate a pl/sql table which stores the parameters of a where clasue
--
PROCEDURE populate_params_table(p_Transaction_Id 	 IN 	VARCHAR2,
                                p_effective_date     IN     DATE)
IS
--This cursor obtain the values of hte parameters used in where clause of different Table_routes
-- 'P_SELECTED_EMP_ID, P_PASSED_ASSIGNMENT_ID removed from list as current
--manager not obtained from base table but from transaction table.
Cursor obtain_param_values is
SELECT  atv.name column_name,atv.datatype column_type,atv.varchar2_value|| Atv.Number_value||FND_DATE.date_to_canonical(Atv.date_value)  column_value
FROM    hr_api_transaction_values atv
WHERE   atv.transaction_step_id in (Select max(transaction_step_id)
                                    From hr_api_transaction_steps
                                    where transaction_id = p_Transaction_Id
                                    group by api_name
                                        )
AND    atv.name in ('P_PERSON_ID','P_ASSIGNMENT_ID','P_QUALIFICATION_ID','P_SELECTED_PERSON_ID');
l_proc          varchar2(72) := g_package||'populate_params_table';

BEGIN
     --Setting the where clause params in params table
    params_table(1).param_name := 'p_effective_date';
    params_table(1).param_value := fnd_date.date_to_canonical(p_effective_date);
    params_table(1).param_data_type := 'D';
    params_table(2).param_name := 'p_assignment_id';
    params_table(2).param_value := 'NULL';
    params_table(2).param_data_type := 'N';
    params_table(3).param_name := 'p_person_id';
    params_table(3).param_value := 'NULL';
    params_table(3).param_data_type := 'N';
    params_table(4).param_name := 'p_qualification_id';
    params_table(4).param_value := 'NULL';
    params_table(4).param_data_type := 'N';
    --Execute the obtain_param_values cursor an populate the params_table with the values
    FOR  where_clause_param_values IN obtain_param_values Loop
          IF UPPER(where_clause_param_values.column_name)='P_SELECTED_PERSON_ID' THEN
             params_table(3).param_value := where_clause_param_values.column_value;
          ELSIF NVL(params_table.COUNT,0) <> 0 THEN
            -- loop thru the params table and set the value
            FOR i IN NVL(params_table.FIRST,0)..NVL(params_table.LAST,-1) LOOP
                IF UPPER(params_table(i).param_name) = UPPER(where_clause_param_values.column_name)  THEN
                    params_table(i).param_value := where_clause_param_values.column_value;
                    --hr_utility.set_location('Name ' || params_table(i).param_name || '  value  ' || params_table(i).param_value,8);
                    EXIT;
                END IF;
            END LOOP;
        END IF;
  End Loop;
END populate_params_table;

--
--
-- Conversion functions are added here
--
--
--
--
FUNCTION decode_value(p_lookup_code varchar2) RETURN VARCHAR2
IS
CURSOR csr_meaning IS
Select Meaning from hr_lookups
where lookup_type ='PQH_CURRENT_PROPOSED'
AND enabled_flag = 'Y'
AND lookup_code = p_lookup_code;

l_meaning hr_lookups.meaning%type := null;

BEGIN

   OPEN csr_meaning;
     FETCH csr_meaning into l_meaning;
   CLOSE csr_meaning;

   return l_meaning;
--
END decode_value;
--
--
--
FUNCTION get_salary(p_assignment_id IN per_assignments_f.assignment_type%TYPE)
RETURN  VARCHAR2 IS
CURSOR salary IS
Select proposed_salary_n
From   per_pay_proposals ppp
Where  ppp.assignment_id = p_assignment_id
and    ppp.change_date = ( select max(change_date)
                            from  per_pay_proposals
                            where change_date <= g_effective_date
						    and   assignment_id =
p_assignment_id
						    and   approved = 'Y' );
l_salary   per_pay_proposals.PROPOSED_SALARY_N%Type;
BEGIN
  IF p_assignment_id IS NOT null then
    --
    OPEN salary;
    FETCH salary into l_salary;
    CLOSE salary;
    --
  END IF;
  RETURN l_salary;
Exception
when others then
  null;
END;
--
--
--
FUNCTION get_currency(p_pay_basis_id per_pay_bases.pay_basis_id%TYPE) RETURN VARCHAR2
   IS
   Cursor currency is
   Select petf.input_currency_code
   From  per_pay_bases ppb,
        pay_input_values_f pivf,
        pay_element_types_f petf
   Where ppb.pay_basis_id=p_pay_basis_id
   And   ppb.input_value_id = pivf.input_value_id
   AND   pivf.element_type_id = petf.element_type_id;

  l_currency_code   pay_element_types_f.input_currency_code%Type;
  l_currency        fnd_currencies.description%Type;

  BEGIN

     IF p_pay_basis_id IS not null Then
     Open  currency;
     Fetch currency into l_currency_code;
     Close currency;
       IF l_currency_code is not null Then
            l_currency := get_currency_meaning(l_currency_code);
       End If;
     End If;
   Return  l_currency;
  Exception
   when others then
        null;
END;
--
--
--
FUNCTION get_change_amount(p_pay_proposal_id per_pay_proposals.pay_proposal_id%Type)
Return Varchar2
IS
  CURSOR is_multiple_comp is
  Select  1
  From   per_pay_proposals  ppp
  where  ppp.pay_proposal_id = p_pay_proposal_id
  AND    ppp.MULTIPLE_COMPONENTS = 'Y';

  CURSOR change_amount_cur is
  Select CHANGE_AMOUNT
  From   per_pay_proposal_components  pppc
  where  pppc.pay_proposal_id = p_pay_proposal_id;

  l_change_amount per_pay_proposal_components.change_amount%Type;
  l_multiple_comp  number;
BEGIN
  IF p_pay_proposal_id is not null then
    OPEN is_multiple_comp;
    FETCH is_multiple_comp into l_multiple_comp;
    CLOSE is_multiple_comp;
    IF l_multiple_comp is  not null then
         l_change_amount := null;
    ElSE
         OPEN change_amount_cur;
         FETCH change_amount_cur into l_change_amount;
         CLOSE change_amount_cur;
    END IF;
  END IF;
  Return l_change_amount;
END;
--
--
--
FUNCTION get_change_percent(p_pay_proposal_id per_pay_proposals.pay_proposal_id%Type)
Return Varchar2
IS
  CURSOR is_multiple_comp is
  Select  1
  From   per_pay_proposals  ppp
  where  ppp.pay_proposal_id = p_pay_proposal_id
  AND    ppp.MULTIPLE_COMPONENTS = 'Y';

  CURSOR change_percent_cur is
  Select CHANGE_PERCENTAGE
  From   per_pay_proposal_components  pppc
  where  pppc.pay_proposal_id = p_pay_proposal_id;

  l_change_percent per_pay_proposal_components.change_percentage%Type;
  l_multiple_comp  number;
BEGIN
  IF p_pay_proposal_id is not null then
    OPEN is_multiple_comp;
    FETCH is_multiple_comp into l_multiple_comp;
    CLOSE is_multiple_comp;
    IF l_multiple_comp is  not null then
         l_change_percent := null;
    ElSE
         OPEN change_percent_cur;
         FETCH change_percent_cur into l_change_percent;
         CLOSE change_percent_cur;
    END IF;
  END IF;
  Return l_change_percent;
END;
--
--
--
FUNCTION get_tenure_status (p_lookup_code varchar2) RETURN VARCHAR2 IS

l_meaning hr_lookups.meaning%type :=null;
BEGIN

     SELECT hr_general.decode_lookup('PQH_TENURE_STATUS',p_lookup_code) into l_meaning
     FROM DUAL;

return l_meaning;

END get_tenure_status;
--
--
FUNCTION get_qualification (p_qualification_type_id varchar2) RETURN VARCHAR2 IS

l_meaning per_qualification_types.name%type := null;

BEGIN

   Select name into l_meaning
   from per_qualification_types
   where qualification_type_id = p_qualification_type_id;

return l_meaning;

END get_qualification;
--
--
FUNCTION get_award_status (p_award_id varchar2) RETURN VARCHAR2 IS

l_meaning hr_lookups.meaning%type :=null;

Cursor get_award_meaning IS
select meaning
from hr_leg_lookups
where lookup_type = 'PER_SUBJECT_STATUSES' and
lookup_code = p_award_id and
g_effective_date between nvl(start_date_active, g_effective_date)
and nvl(end_date_active, g_effective_date) and enabled_flag = 'Y'
order by lookup_code,meaning;

BEGIN

Open get_award_meaning;

Fetch get_award_meaning into l_meaning;

close get_award_meaning;

return l_meaning;


END get_award_status;
--
--
FUNCTION get_tuition_method (p_tuition_id varchar2) RETURN VARCHAR2 IS

Cursor cur_get_tuition_meaning is
SELECT
meaning
FROM
hr_leg_lookups
WHERE
lookup_type = 'PER_TUITION_METHODS'
AND lookup_code = p_tuition_id
AND g_effective_date BETWEEN NVL(start_date_active, g_effective_date)
AND NVL(end_date_active, g_effective_date)
AND enabled_flag = 'Y';

l_meaning hr_leg_lookups.meaning%type := null;
BEGIN

OPEN cur_get_tuition_meaning;
   FETCH cur_get_tuition_meaning into l_meaning;
CLOSE cur_get_tuition_meaning;

return l_meaning;

END get_tuition_method;

--
--
FUNCTION get_currency_meaning(p_currency_code varchar2) RETURN VARCHAR2 IS

CURSOR csr_get_currency IS
SELECT
description
FROM
fnd_currencies_vl
WHERE
enabled_flag = 'Y'
AND currency_code = p_currency_code
AND currency_flag = 'Y'
AND sysdate >= NVL(start_date_active, sysdate)
AND sysdate <= NVL(end_date_active, sysdate);

l_meaning fnd_currencies.description%type :=  null;

BEGIN

  OPEN csr_get_currency;
    FETCH csr_get_currency into l_meaning;
  CLOSE csr_get_currency;

  return l_meaning;
--
END get_currency_meaning;
--
--
FUNCTION get_person_title(p_title_code varchar2) RETURN VARCHAR2 IS

cursor csr_get_title IS
select hl.meaning
from   hr_lookups hl
where  hl.lookup_type = 'TITLE'
and    hl.lookup_code = p_title_code
and    hl.enabled_flag = 'Y'
and    trunc(g_effective_date) between trunc(nvl(hl.start_date_active,g_effective_date))
and trunc(nvl(hl.end_date_active,g_effective_date));

l_meaning hr_lookups.meaning%type := null;

BEGIN

OPEN csr_get_title;
  FETCH csr_get_title into l_meaning;
CLOSE csr_get_title;

return l_meaning;
--
END get_person_title;
--
--
FUNCTION get_gender (p_gender_code varchar2) RETURN VARCHAR2 IS

CURSOR csr_gender IS
select hrl.meaning
from hr_lookups hrl where
hrl.lookup_type = 'SEX' and
hrl.Lookup_Code = p_gender_code and
hrl.enabled_flag = 'Y' and
trunc(SYSDATE) between trunc(nvl(hrl.start_date_active,SYSDATE))
               and trunc(nvl(hrl.end_date_active,SYSDATE));

l_meaning hr_lookups.meaning%type := null;

BEGIN

OPEN csr_gender;

  FETCH csr_gender into l_meaning;
CLOSE csr_gender;

return l_meaning;
--
END get_gender;
--
--
FUNCTION get_marital_status (p_marital_code varchar2) RETURN VARCHAR2 IS

CURSOR csr_marital_status IS
select hl.meaning
from   hr_lookups hl
where  hl.lookup_type = 'MAR_STATUS'
and    hl.lookup_code = p_marital_code
and    hl.enabled_flag = 'Y'
and    g_effective_date between nvl(start_date_active, g_effective_date - 1)
               and     nvl(end_date_active, g_effective_date);

l_meaning hr_lookups.meaning%type := null;

BEGIN

 OPEN csr_marital_status;
   FETCH csr_marital_status into l_meaning;
 CLOSE csr_marital_status;

 return l_meaning;

END get_marital_status;
--
--
FUNCTION get_termination_reason (p_termination_code varchar2) RETURN VARCHAR2
IS
CURSOR csr_reason IS
SELECT meaning
FROM hr_leg_lookups
WHERE lookup_type = 'LEAV_REAS'
AND lookup_code = p_termination_code
AND enabled_flag = 'Y';

l_meaning hr_lookups.meaning%type := null;

BEGIN


OPEN csr_reason;

 FETCH csr_reason into l_meaning;

CLOSE csr_reason;


return l_meaning;

END get_termination_reason;
--
--
FUNCTION get_work_schedule_frequency (p_freq_code varchar2) RETURN VARCHAR2
IS

CURSOR csr_frequency IS
select  hl.meaning
from    hr_leg_lookups hl
where   hl.lookup_type = 'FREQUENCY'
and     hl.lookup_code = p_freq_code
and     hl.enabled_flag = 'Y'
and     trunc(g_effective_date) BETWEEN nvl(hl.start_date_active, trunc(g_effective_date))
                       AND     nvl(hl.end_date_active, trunc(g_effective_date));

l_meaning hr_lookups.meaning%type := null;
BEGIN

OPEN csr_frequency ;

  FETCH csr_frequency into l_meaning;

CLOSE csr_frequency;

return l_meaning;

END get_work_schedule_frequency;
--
--
FUNCTION get_employee_category (p_category_code varchar2) RETURN VARCHAR2
IS

CURSOR csr_category IS
select  hl.meaning
from    hr_leg_lookups hl
where   hl.lookup_type = 'EMPLOYEE_CATG'
and     hl.lookup_code = p_category_code
and     hl.enabled_flag = 'Y'
and     trunc(g_effective_date) between nvl(start_date_active, trunc(g_effective_date))
                       and     nvl(end_date_active, trunc(g_effective_date));
l_meaning hr_lookups.meaning%type := null;
BEGIN

OPEN csr_category;
 FETCH csr_category into l_meaning;
CLOSE csr_category;

return l_meaning;

END get_employee_category;
--
--
FUNCTION get_employment_category (p_category_code varchar2) RETURN VARCHAR2
IS

CURSOR csr_category IS
select  hl.meaning
from    hr_leg_lookups hl
where   hl.lookup_type = 'EMP_CAT'
and     hl.lookup_code = p_category_code
and     hl.enabled_flag = 'Y'
and     trunc(g_effective_date) between nvl(start_date_active, trunc(g_effective_date))
                       and     nvl(end_date_active, trunc(g_effective_date));
l_meaning hr_lookups.meaning%type := null;
BEGIN

OPEN csr_category;
 FETCH csr_category into l_meaning;
CLOSE csr_category;

return l_meaning;

END get_employment_category;
--
--
FUNCTION get_yes_no (p_lookup_code varchar2) RETURN VARCHAR2
IS
CURSOR csr_meaning IS
Select Meaning from hr_lookups
where lookup_type ='YES_NO'
AND enabled_flag = 'Y'
AND lookup_code = p_lookup_code;

l_meaning hr_lookups.meaning%type := null;

BEGIN

   OPEN csr_meaning;
     FETCH csr_meaning into l_meaning;
   CLOSE csr_meaning;

   return l_meaning;
--
END get_yes_no;

--
--

FUNCTION get_establishment (p_establishment_id varchar2) RETURN VARCHAR2
IS
CURSOR csr_establishment IS
SELECT
NAME SCHOOL
FROM
PER_ESTABLISHMENTS
Where ESTABLISHMENT_ID = p_establishment_id;

l_meaning hr_lookups.meaning%type := null;

BEGIN

   OPEN csr_establishment;
     FETCH csr_establishment into l_meaning;
   CLOSE csr_establishment;

   return l_meaning;
--
END get_establishment;
--
--

FUNCTION get_person_latest_name (p_person_id varchar2) RETURN VARCHAR2 --Not Used for Now
IS

l_full_name     varchar2(240);
--

BEGIN

if p_person_id is not null then
  --
  l_full_name := hr_person_name.get_person_name(p_person_id,trunc(sysdate));
  --
end if;
return l_full_name;
--
END get_person_latest_name;
--
--
FUNCTION get_person_brief_name (p_person_id varchar2) RETURN VARCHAR2 IS
l_brief_name     varchar2(240);
--
cursor csr_brief_name is
select first_name||' '||last_name||' '||suffix brief_name
from per_all_people_f ppf
where ppf.person_id = p_person_id
order by effective_end_date desc;


BEGIN

if p_person_id is not null then
  --
  open csr_brief_name;
  fetch csr_brief_name into l_brief_name;
  close csr_brief_name;
  --
end if;
return l_brief_name;
--

END get_person_brief_name;
--
--
FUNCTION decode_payroll_latest_name (p_payroll_id varchar2) RETURN VARCHAR2
IS
l_payroll_name pay_all_payrolls_f.payroll_name%type;
Cursor csr_payroll_name IS
select    payroll_name
from      pay_all_payrolls_f pay
where     payroll_id      = p_payroll_id
and       g_effective_date between
          pay.effective_start_date and pay.effective_end_date
order by effective_start_date desc;

BEGIN


OPEN csr_payroll_name;
 FETCH csr_payroll_name into l_payroll_name;
CLOSE csr_payroll_name;

 return l_payroll_name;

END decode_payroll_latest_name;
--
--
FUNCTION decode_bargaining_unit_code (p_bargaining_unit_code IN VARCHAR2)
RETURN VARCHAR2 IS
--
BEGIN
  return (hr_general.decode_lookup ('BARGAINING_UNIT_CODE',p_bargaining_unit_code));
END decode_bargaining_unit_code;
--
FUNCTION decode_collective_agreement(p_collective_agreement_id IN NUMBER)
RETURN VARCHAR2 IS
--
  CURSOR csr_collective_agreement(p_collective_agreement_id NUMBER) IS
   SELECT name
     FROM per_collective_agreements
    WHERE collective_agreement_id = p_collective_agreement_id;
--
l_name per_collective_agreements.name%TYPE := null;
--
BEGIN
--
 IF p_collective_agreement_id IS NOT NULL THEN
 --
   OPEN csr_collective_agreement(p_collective_agreement_id);
   FETCH csr_collective_agreement INTO l_name;
   CLOSE csr_collective_agreement;
 --
 END IF;

 RETURN l_name;
--
END decode_collective_agreement;
--
--
FUNCTION decode_contract(p_contract_id IN NUMBER)
RETURN VARCHAR2 IS
--
  CURSOR csr_contract(p_contract_id NUMBER) IS
   SELECT reference
     FROM per_contracts_f
    WHERE contract_id = p_contract_id
      AND g_effective_date between effective_start_date and effective_end_date;
--
l_reference per_contracts_f.reference%TYPE := null;
--
BEGIN
--
 IF p_contract_id IS NOT NULL THEN
 --
    OPEN csr_contract(p_contract_id);
   FETCH csr_contract INTO l_reference;
   CLOSE csr_contract;
 --
 END IF;

 RETURN l_reference;
--
END decode_contract;
--
--
FUNCTION get_table_route_id(p_table_alias IN varchar2 ) RETURN VARCHAR2
IS
--
CURSOR csr_table_route IS
Select TABLE_ROUTE_ID
from pqh_table_route
where table_alias like 'PQH_SS%';

l_table_route_id pqh_table_route.table_route_id%type := null;
BEGIN
--
        if p_table_alias is not null then
         --
           open csr_table_route ;
             fetch csr_table_route into l_table_route_id;
           close csr_table_route;
         --
        end if;

return l_table_route_id;
--
END get_table_route_id;
--
--
FUNCTION get_user_status(p_assignment_status_type_id IN NUMBER) RETURN VARCHAR2
IS
CURSOR csr_user_status IS
 select tl.user_status
  from per_assignment_status_types asg,
       per_assignment_status_types_tl tl
  where asg.assignment_status_type_id = p_assignment_status_type_id
  and asg.assignment_status_type_id = tl.assignment_status_type_id
  and tl.language=USERENV('LANG');
--
l_user_status  per_assignment_status_types_tl.user_status%type :=null;
--
BEGIN

		open csr_user_status ;
		  FETCH csr_user_status into l_user_status;
		close csr_user_status;
		--
     return l_user_status;

END get_user_status;
--
--
FUNCTION get_change_reason(p_reason_code IN VARCHAR2) RETURN VARCHAR2
IS
CURSOR csr_change_reason IS
select meaning
from hr_leg_lookups
where lookup_type = 'EMP_ASSIGN_REASON'
and enabled_flag = 'Y'
AND trunc(g_effective_date) BETWEEN NVL(start_date_active, trunc(g_effective_date))
AND NVL(end_date_active, trunc(g_effective_date))
and lookup_code =p_reason_code
UNION
select meaning
from hr_leg_lookups
where lookup_type = 'CWK_ASSIGN_REASON'
and enabled_flag = 'Y'
AND trunc(g_effective_date) BETWEEN NVL(start_date_active,
trunc(g_effective_date))
AND NVL(end_date_active, trunc(g_effective_date))
and lookup_code =p_reason_code;
--
l_reason varchar2(100):=null;
l_proc VARCHAR2(72):= 'get_change_reason';
--
BEGIN
       hr_utility.set_location('Leaving: ' || l_proc,10);
       --
 	     open csr_change_reason ;
                  FETCH csr_change_reason into l_reason;
                close csr_change_reason;
       --
    hr_utility.set_location('Leaving: ' || l_proc,20);

  return l_reason;
END get_change_reason;
--
--
--
PROCEDURE purge_temp_data(p_effective_date date default trunc(sysdate))
IS
PRAGMA AUTONOMOUS_TRANSACTION;
--
l_proc VARCHAR2(72);
--
Begin
 --
  l_proc := g_package || 'purge_temp_data';

  hr_utility.set_location('Leaving: ' || l_proc,10);

    Delete
    from pqh_ss_print_label_temp
    where trunc(creation_date) < p_effective_date;
 -- Issuing autonomous commit
    COMMIT;
  hr_utility.set_location('Leaving: ' || l_proc,20);
 --
EXCEPTION
  WHEN OTHERS THEN ROLLBACK;
--
End purge_temp_data;
--

FUNCTION get_value_from_params_table( p_column_name  IN  pqh_attributes.column_name%TYPE)
RETURN VARCHAR2 IS
-- local variables
--
 l_proc          varchar2(72) := g_package||'get_value_from_array';
 l_col_val       VARCHAR2(8000) := null;
 l_col_type      VARCHAR2(1) := null;
BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Col Name : '||p_column_name, 6);

  IF NVL(params_table.COUNT,0) <> 0 THEN
    -- loop thru the params table and get the value
     FOR i IN NVL(params_table.FIRST,0)..NVL(params_table.LAST,-1) LOOP
        IF UPPER(params_table(i).param_name) = UPPER(p_column_name)  THEN
           l_col_val := params_table(i).param_value;
           l_col_type := params_table(i).param_data_type;
           IF    l_col_type = 'D' THEN
           l_col_val := ' fnd_date.canonical_to_date(''' || l_col_val || ''')';
           ELSIF l_col_type = 'V' THEN
           l_col_val := '''' || l_col_val || '''';
           END IF;
           hr_utility.set_location('Name ' || p_column_name || '  value  ' || l_col_val,8);
           EXIT;
           -- exit the loop as the column is found
        END IF;
     END LOOP;
  END IF;
RETURN l_col_val;
END get_value_from_params_table;

PROCEDURE replace_where_clause_params(p_where_clause_in  IN PQH_TABLE_ROUTE.where_clause%TYPE,
                                      p_where_clause_out OUT NOCOPY PQH_TABLE_ROUTE.where_clause%TYPE)
IS
l_proc          varchar2(72) := g_package||'replace_where_clause_params';
l_atoms_tab     PQH_REFRESH_DATA.atoms_tabtype;
-- to hold the where_clause atoms
l_no_atoms      number;
l_key_column    pqh_attributes.column_name%TYPE;
l_key_val       VARCHAR2(8000);
l_where_out     pqh_table_route.where_clause%TYPE;
l_atom_length   number;
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
   PQH_REFRESH_DATA.parse_string(
                                p_string_in        => p_where_clause_in,
                                p_atomics_list_out => l_atoms_tab,
                                p_num_atomics_out  => l_no_atoms
                               );

    -- loop thru the PL/SQL table and replace params
    FOR table_row IN NVL(l_atoms_tab.FIRST,0)..NVL(l_atoms_tab.LAST,-1) LOOP
       l_atom_length := LENGTH(TRIM(l_atoms_tab(table_row)));
       IF substr(NVL (l_atoms_tab(table_row), 'NULL') ,1,1) = '<' and l_atom_length > 2 THEN
           l_key_column  := substr(l_atoms_tab(table_row),2,(l_atom_length - 2)) ;
           l_key_val := get_value_from_params_table(p_column_name => l_key_column);
           hr_utility.set_location(l_key_column||' = '||l_key_val,15);
           -- if value is null pass it null
           -- replace the param with the actual value
           l_atoms_tab(table_row) := l_key_val;
        END IF;
    END LOOP;

   -- build the where clause again
    l_where_out := '';
    FOR table_row IN NVL(l_atoms_tab.FIRST,0)..NVL(l_atoms_tab.LAST,-1)
    LOOP
       l_where_out := l_where_out||nvl(l_atoms_tab(table_row),' ');
    END LOOP;

    -- assign the out parameter the final where string
    p_where_clause_out := l_where_out;

EXCEPTION
      WHEN OTHERS THEN
      p_where_clause_out := null;
END replace_where_clause_params;


/*----------------------------------------------------------------------------------
POPULATE_CWB_PARAMS: Populate the global parameters table with the values
that will be bound to the where clause later.
------------------------------------------------------------------------------------*/
procedure populate_cwb_params (
p_group_per_in_ler_id in number,
p_group_plan_id in number, p_lf_evt_ocrd_dt
in date)is
begin
hr_utility.set_location('Entering populate_cwb_params',1);
     --Setting the where clause params in params table
    params_table(1).param_name := 'P_GROUP_PER_IN_LER_ID';
    params_table(1).param_value := p_group_per_in_ler_id;
    params_table(1).param_data_type := 'N';

    params_table(2).param_name := 'P_GROUP_PLAN_ID';
    params_table(2).param_value := p_group_plan_id;
    params_table(2).param_data_type := 'N';

    params_table(3).param_name := 'P_LIFE_EVENT_DATE';
    params_table(3).param_value := p_lf_evt_ocrd_dt;
    params_table(3).param_data_type := 'V';
hr_utility.set_location('Leaving populate_cwb_params',2);
end populate_cwb_params;

/*----------------------------------------------------------------------------------
POPULATE_DATA_FROM_FF: Common routine to execute the fast formula defined for the
document. The input values are bound before executing the same.

For SSHR Following inputs are available:
P_EFFECTIVE_DATE
P_TRANS_ID

For CWB
P_GROUP_PER_IN_LER_ID
P_GROUP_PLAN_ID
P_PLAN_ID
P_LIFE_EVENT_DATE
------------------------------------------------------------------------------------*/
procedure populate_data_from_ff (
    p_doc_short_name       in varchar2,
    p_effective_date       in date,
    p_transaction_id       in number default null,
    p_group_per_in_ler_id  in number default null,
    p_group_plan_id        in number default null,
    p_lf_evt_ocrd_dt       in date     default null) is

--Fast Formula cursors
Cursor get_fastformula(p_short_name varchar2) is
Select formula_id
from   pqh_documents_f
where  p_effective_date  between effective_start_date and effective_end_date
and    short_name = p_short_name;

Cursor cur_chk_forumual_effective(p_eff_date date , p_formula_id number) is
Select 'X', userenv('sessionid')
from ff_formulas_f
where formula_id = p_formula_id
and   p_eff_date between effective_start_date and effective_end_date;
--
-- Defining local variables.
--
l_inputs FF_EXEC.INPUTS_T;
l_outputs FF_EXEC.OUTPUTS_T;

l_session_id     NUMBER;
l_formula_id     NUMBER;
l_formula_existance VARCHAR2(10);
BEGIN

  OPEN get_fastformula(p_doc_short_name);
    FETCH get_fastformula into l_formula_id;
  CLOSE get_fastformula;

  IF l_formula_id IS NOT NULL THEN
	--
	Open cur_chk_forumual_effective(p_effective_date , l_formula_id);
	  Fetch cur_chk_forumual_effective into l_formula_existance, l_session_id;
	Close cur_chk_forumual_effective;

   If l_formula_existance = 'X' then
      FF_EXEC.INIT_FORMULA(l_formula_id, p_effective_date,l_inputs,l_outputs);

      for l_in_cnt in 1..l_inputs.COUNT loop
        if(l_inputs(l_in_cnt).name = 'P_SESSION_ID') then
           l_inputs(l_in_cnt).value:= l_session_id;
           --
        elsif(l_inputs(l_in_cnt).name = 'P_TRANS_ID') then
           l_inputs(l_in_cnt).value:=p_transaction_id;
        --
        elsif(l_inputs(l_in_cnt).name = 'P_EFFECTIVE_DATE') then
           l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(p_effective_date);
           l_inputs(l_in_cnt).datatype := 'DATE';
        --
       elsif(l_inputs(l_in_cnt).name = 'P_GROUP_PER_IN_LER_ID') then
           l_inputs(l_in_cnt).value := p_group_per_in_ler_id;
       --
       elsif(l_inputs(l_in_cnt).name = 'P_GROUP_PLAN_ID') then
           l_inputs(l_in_cnt).value := p_group_plan_id;
       --
       elsif(l_inputs(l_in_cnt).name = 'P_LIFE_EVENT_DATE') then
           l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(p_lf_evt_ocrd_dt);
           l_inputs(l_in_cnt).datatype := 'DATE';
       --
       end if;
     end loop;
     g_transaction_id := p_transaction_id;
     FF_EXEC.RUN_FORMULA(l_inputs,l_outputs);
     --
   End If; -- formula existance
 END IF ;-- formula id not null
END populate_data_from_ff;

/*----------------------------------------------------------------------------------
POPULATE_DATA_FROM_QUERY: Common routine to build the dynamic query using the
from & where clause from pqh_table_route, bind the variables in where clause
and execute the query.
------------------------------------------------------------------------------------*/
procedure populate_data_from_query (
    p_doc_short_name in varchar2,
    p_effective_date in date,
    p_transaction_id in number  )
 is
 l_no_cols    integer :=0;
 p    integer :=0;
 columnval    varchar2(32000) :=null;
 sql_query    varchar2(32000) :=null;
 columntag    varchar2(32000) :=null;
 l_statement  varchar2(32000) ;

 l_where_clause_out PQH_TABLE_ROUTE.where_clause%TYPE;

 /* Removed the RECORD TYPE current_values_record in version 120.5 as selecting into this record type was limiting the attributes to 42. */

 /*Bug fix 4722431*/

--this cursor decides what are the table_route_id for which query need to be done depending on the
--It also selects the from_clause and the where clause for the table_route_id
cursor table_routes  is
select distinct att.master_table_route_id table_rt_id,
                ptr.from_clause  from_clause,
                ptr.where_clause  where_clause,
                doc.document_category
from    pqh_documents_f doc,
        pqh_document_attributes_f doa,
        pqh_attributes att,
        pqh_table_route ptr
where   doc.short_name    = p_doc_short_name
  AND   doa.document_id = doc.document_id
  AND   p_effective_date between doc.effective_start_date and doc.effective_end_date
  AND   p_effective_date between doa.effective_start_date and doa.effective_end_date
  AND   att.attribute_id = doa.attribute_id
  AND   att.master_table_route_id=ptr.table_route_id
  AND   ptr.where_clause is not null;
-- This curosr selects the column names and tag anme that need to be queried to form a dynamic sql query
cursor column_tag_names(p_table_route_id   pqh_table_route.table_route_id %TYPE) is
select att.column_name  att_column,doa.tag_name doc_tag,att.enable_flag flag
from   pqh_documents_f doc,
       pqh_document_attributes_f doa,
       pqh_attributes att
where  doc.short_name    = p_doc_short_name
  AND   doa.document_id = doc.document_id
  AND   p_effective_date between doc.effective_start_date and doc.effective_end_date
  AND   p_effective_date between doa.effective_start_date and doa.effective_end_date
  AND   att.attribute_id = doa.attribute_id
  AND   att.master_table_route_id=p_table_route_id
order by att.attribute_id;

begin
hr_utility.set_location('Entering populate_data_from_query',1);
--    populate_params_table(p_Transaction_Id ,p_effective_date );
    --Loop starts for each table_route
    For table_route_rslt IN table_routes LOOP
        -- columns are retrieved corresponding to a document tags for the table_route_id
        hr_utility.set_location('Table Route Id'||table_route_rslt.table_rt_id,11);
         For column_name_r IN column_tag_names(table_route_rslt.table_rt_id) Loop
             IF l_no_cols > 0 THEN
                columnval:=columnval||',' ;
                columntag:=columntag||',' ;
             END IF;
             l_no_cols :=l_no_cols+1;
             columnval:=columnval || column_name_r.att_column ||' Val'||l_no_cols ;
             columntag:=columntag ||''''|| column_name_r.doc_tag ||''' Tag'||l_no_cols ;
         End Loop;

         replace_where_clause_params(table_route_rslt.where_clause,l_where_clause_out);

         sql_query := 'Select '|| columntag||','||columnval ||' From ' || table_route_rslt.from_clause ||' Where ' || l_where_clause_out ;


--insert into y values (sql_query);commit;
/*Bug fix 4722431*/

/* Added dynamic cursor to fix the issue with being able to get values for only 42 attributes */

--DYNAMIC CURSOR BEGIN
     Begin
       for i in 1.. l_no_cols
         Loop
            l_statement := '
            DECLARE
            cursor dyn_cur is '||sql_query||';
            l_rec dyn_cur%rowType;
            BEGIN
                open dyn_cur;
                fetch dyn_cur into l_rec;
                close dyn_cur;

                INSERT INTO pqh_ss_print_data(session_id,transaction_id,name,value) values(userenv(''sessionid''),'||p_transaction_id||',l_rec.tag'||i||',l_rec.val'||i||');
            END;';
            EXECUTE IMMEDIATE  l_statement;
         End Loop;

          Exception
            --All the exceptions have been supressed so that exception in the
            --query execution of one table route does not prevent the query execution of other
            --table routes
           WHEN others then
               l_no_cols:=0;
               columnval := null;
               columntag := null;
               sql_query := null;
               l_statement := null;
               l_where_clause_out := null;
               hr_utility.set_location('Query execution generated Error: '||sqlerrm,10);

          End;
    END Loop;
    --
hr_utility.set_location('Leaving populate_data_from_query',1);
end;


/* ----------------------------------------------------------------------------------
   POPULATE_TEMP_DATA: Procedure to populate the temporary table with SSHR data
   ---------------------------------------------------------------------------------- */
--
-- The following procedure used to populate temporary table data.
--
PROCEDURE populate_temp_data(
    p_Transaction_Id 	 IN 	VARCHAR2,
    p_session_id     OUT NOCOPY VARCHAR2,
    p_effective_date     IN     DATE,
    p_doc_short_name    IN      VARCHAR2    ) IS

--
-- Defining local variables.
--
l_pdf_short_name    VARCHAR2(100);
l_session_id        NUMBER;
l_approval_type     VARCHAR2(10);
l_proc              VARCHAR2(100) := ' populate_temp_data';
l_document_category VARCHAR2(30);

tag_no       integer :=0;
p            integer :=0;
l_no_cols    integer :=0;

l_where_clause_out PQH_TABLE_ROUTE.where_clause%TYPE;

BEGIN
--
-- Create a save point
--
 hr_utility.set_location('Entering: ' || l_proc,10);
SAVEPOINT POPULATE_TEMP_DATA;
g_effective_date := p_effective_date;
g_transaction_id := p_transaction_id;

l_approval_type := get_function_parameter_value(
            p_parameter_name=>'TYPE',
            p_transaction_id =>p_transaction_id,
            p_effective_date=>fnd_date.date_to_canonical(p_effective_date));


--dt_fndate.set_effective_date(fnd_date.canonical_to_date(p_effective_date));

  hr_util_misc_ss.setEffectiveDate(p_effective_date);
l_pdf_short_name := p_doc_short_name;



hr_utility.set_location('Effective Date' || p_effective_date,12);
hr_utility.set_location('Document Short Name' || l_pdf_short_name,12);

select userenv('sessionid') into p_session_id from dual;


IF l_pdf_short_name <> 'N/A' THEN


     IF l_approval_type = 'PRE' or l_approval_type = 'N/A' THEN

     hr_utility.set_location('Pre approval type data insertion',15);
        --
        -- Retrieve data from transaction tables
        --
        BEGIN
   	INSERT INTO
pqh_ss_print_data(session_id,transaction_id,name,value,enable_flag)
  	SELECT  userenv('sessionid'),p_transaction_id,
  	        doa.tag_name  NAME,
  		decode(att.decode_function_name,null,atv.varchar2_value|| Atv.Number_value||Atv.date_value,
  		pqh_ss_utility.get_desc (
  	 	decode(atv.varchar2_value|| Atv.Number_value||FND_DATE.date_to_canonical(Atv.date_value),
          	null,null,
          	att.decode_function_name||'('''||atv.varchar2_value|| Atv.Number_value
                     ||FND_DATE.date_to_canonical(Atv.date_value)||''')' ) )) value,
                att.enable_flag
  	FROM hr_api_transaction_steps steps
  		, hr_api_transaction_values atv,
  		pqh_documents_f doc,
  		pqh_document_attributes_f doa,
  		pqh_attributes att,
                pqh_table_route ptr
  	-- Bug Fix 2945716,Added Select Stmt to retrieve max step_id
  	WHERE atv.transaction_step_id in (Select max(transaction_step_id)
                                         From hr_api_transaction_steps
                                         where transaction_id = p_Transaction_Id
                                         group by api_name
                                            )
        AND  atv.transaction_step_id = steps.transaction_step_id
      	AND  doc.short_name    = l_pdf_short_name --'TP'
     	AND   doa.document_id = doc.document_id
        AND   p_effective_date between doc.effective_start_date and doc.effective_end_date
     	AND   p_effective_date between doa.effective_start_date and doa.effective_end_date
     	AND   att.attribute_id = doa.attribute_id
        AND   att.enable_flag='Y'
        AND   att.master_table_route_id=ptr.table_route_id
     	AND   att.COLUMN_NAME = atv.name
        AND   ptr.from_clause=steps.api_name;
hr_utility.set_location('Data Inserted',18);
     Exception
          when others then
               null;
       End;
     --
     -- Else check the l_approval_type
     --
    ELSIF l_approval_type = 'POST' THEN
    --
    --  Retrieve data from History Tables
    --
    hr_utility.set_location('Post approval type data insertion',15);
    BEGIN
        INSERT INTO
pqh_ss_print_data(session_id,transaction_id,name,value,enable_flag)
      	SELECT  userenv('sessionid'),p_transaction_id,
      	        doa.tag_name  NAME,
      		decode(att.decode_function_name,null,atv.value,
                      		pqh_ss_utility.get_desc (
                          	 	decode(atv.value,null,null,
                              	att.decode_function_name||'('''||atv.value||''')' ) )) value,
                att.enable_flag
      	FROM pqh_ss_step_history steps
      		, pqh_ss_value_history atv,
      		pqh_documents_f doc,
      		pqh_document_attributes_f doa,
      		pqh_attributes att,
                pqh_table_route ptr
      	WHERE steps.step_history_id = atv.step_history_id
        AND   steps.approval_history_id = atv.approval_history_id
        AND   (atv.step_history_id,atv.approval_history_id) in
                 (
                Select step_history_id, approval_history_id
                from pqh_ss_step_history
                where transaction_history_id=p_transaction_id
                and approval_history_id = (
                        Select max(approval_history_id) from pqh_ss_step_history
                        where transaction_history_id=p_transaction_id)
                 )
      	AND steps.transaction_history_id  =p_transaction_id
         	AND  doc.short_name    = l_pdf_short_name
         	AND   doa.document_id = doc.document_id
         	AND   p_effective_date  between doc.effective_start_date and doc.effective_end_date
         	AND   p_effective_date  between doa.effective_start_date and doa.effective_end_date
         	AND   att.attribute_id = doa.attribute_id
                AND   att.enable_flag='Y'
                AND   att.master_table_route_id =ptr.table_route_id
         	AND   att.COLUMN_NAME = atv.name
                AND   ptr.from_clause=steps.api_name ;
  hr_utility.set_location('Data Inserted',18);
  Exception
          when others then
               null;
       End;
    --
    --
    END IF;

    --
    --Fetching Proposed values from Transaction Table and Populating pqh_ss_print_data  ENDS
    --
    --
    --This section Fetches data from base table and populates the pq_ss_print_data table
    --

    --This procedure will populate the global params_table with the where_clause_params values
    populate_params_table(p_Transaction_Id ,p_effective_date );

    populate_data_from_query (
       p_doc_short_name => p_doc_short_name,
       p_effective_date => p_effective_date,
       p_transaction_id => p_transaction_id );
   --
END IF;

populate_data_from_ff (
    p_doc_short_name      => p_doc_short_name,
    p_effective_date      => p_effective_date,
    p_transaction_id      => p_transaction_id );
--
-- Check is there any record in pqh_ss_print_data , if not insert one dummy row , so that
-- while opening pdf file , xdo will not error out .
--
hr_utility.set_location('Leaving: '|| l_proc ,20);
EXCEPTION

WHEN DUP_VAL_ON_INDEX THEN
         NULL;
WHEN OTHERS THEN
	NULL;
hr_utility.set_location('Leaving with Other exception '|| l_proc ,20);
--
End populate_temp_data;

/* ----------------------------------------------------------------------------------
   POPULATE_CWB_DATA: Procedure to populate the temporary table with CWB specific
   data for the specified context.
   ---------------------------------------------------------------------------------- */
procedure populate_cwb_data(
    p_group_per_in_ler_id in number,
    p_group_plan_id        in number,
    p_lf_evt_ocrd_dt       in date,
    p_doc_short_name       in varchar2,
    p_session_id           out nocopy varchar2,
    p_effective_date       in date default sysdate)     is

begin
   --
   SAVEPOINT POPULATE_TEMP_DATA;
   --
   populate_cwb_params(p_group_per_in_ler_id, p_group_plan_id, p_lf_evt_ocrd_dt);
   --
   populate_data_from_query(p_doc_short_name,p_effective_date, p_group_per_in_ler_id);
   --
   populate_data_from_ff (
    p_doc_short_name       => p_doc_short_name,
    p_effective_date       => p_effective_date,
    p_transaction_id       => p_group_per_in_ler_id,
    p_group_per_in_ler_id  => p_group_per_in_ler_id,
    p_group_plan_id        => p_group_plan_id,
    p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt );
    --
    p_session_id       := userenv('sessionid');
    --
end populate_cwb_data;
--

END ;

/
