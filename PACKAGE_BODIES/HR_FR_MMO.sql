--------------------------------------------------------
--  DDL for Package Body HR_FR_MMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_MMO" as
/* $Header: hrfrmmo.pkb 120.0 2005/05/30 21:03:47 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_fr_mmo';
--
-- ---------------------------------------------------------------------------
-- |---------------------< Get_formula >--------------------------------------|
-- ----------------------------------------------------------------------------
--
Function Get_formula (p_business_group_id IN Number,
                      p_session_date      IN  date) Return Number IS
--
-- Define Local variable
ln_formula_id   ff_formulas.formula_id%TYPE;
--
-- local cursor
Cursor Get_user_formula_id (p_business_group_id ff_formulas_f.business_group_id%TYPE,
                            p_formula_name      ff_formulas_f.formula_name%TYPE) IS
SELECT ff.formula_id
FROM   ff_formulas_f ff
WHERE  ff.business_group_id = p_business_group_id and
       ff.formula_name = p_formula_name and
       (p_session_date BETWEEN ff.effective_start_date and ff.effective_end_date);
--

Cursor Get_template_formula_id (p_legislation_code ff_formulas_f.legislation_code%TYPE,
                                p_formula_name     ff_formulas_f.formula_name%TYPE) IS
SELECT ff.formula_id
FROM   ff_formulas_f ff
WHERE  ff.legislation_code = p_legislation_code and
       ff.formula_name = p_formula_name and
       (p_session_date BETWEEN ff.effective_start_date and ff.effective_end_date);

Begin
   -- First, check if there is a formula called USER_MMO_REASON for the user's Business_group
   OPEN Get_user_formula_id (p_business_group_id,'USER_MMO_REASON');
   FETCH Get_user_formula_id into ln_formula_id;
   if (Get_user_formula_id%NOTFOUND) Then
      -- The customized formula has not been found. Get the Template formula_id
      CLOSE Get_user_formula_id;
      OPEN Get_template_formula_id ('FR','TEMPLATE_MMO_REASON');
      FETCH Get_template_formula_id into ln_formula_id;
      if (Get_template_formula_id%NOTFOUND) Then
      -- Error. None of the formula has been created
         ln_formula_id := 0;
      End if;
      CLOSE Get_template_formula_id;
   Else
      CLOSE Get_user_formula_id;
   End if;


   Return ln_formula_id;

End Get_formula;


--
-- ---------------------------------------------------------------------------
-- |---------------------< Get_start_date >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Function Get_start_date
   (p_person_id 		IN number
   ,p_establishment_id	        IN number
   ,p_end_date		        IN date
   ,p_include_suspended         IN varchar
   ) RETURN date is
--
--  Define Local Variables
--
l_proc varchar2(72) := g_package||'Get_start_date';
l_date date;
--
Begin

/* Find the record which precedes the assignment data block and which does not meet the
   Assignment Status Type and Establishment criteria
*/
   select max(a.effective_end_date) + 1
   into l_date
   from per_all_assignments_f       a,
        per_assignment_status_types s
   where a.person_id = p_person_id
     AND a.primary_flag = 'Y'
     AND a.effective_end_date < p_end_date
     AND a.assignment_status_type_id = s.assignment_status_type_id
     AND (s.per_system_status not in
           ('ACTIVE_ASSIGN',decode(p_include_suspended,'Y','SUSP_ASSIGN','ACTIVE_ASSIGN'))
         OR a.establishment_id  <> p_establishment_id);

   if l_date is null then

/* If no record is found above then get the latest start date which does meet the criteria
   for which there is no preceding record which meets the criteria
*/

   select max(a.effective_start_date)
   into l_date
   from per_all_assignments_f       a,
        per_assignment_status_types s
   where a.person_id = p_person_id
     AND a.primary_flag = 'Y'
     AND a.effective_start_date < p_end_date
     AND a.assignment_status_type_id = s.assignment_status_type_id
     AND (s.per_system_status in
           ('ACTIVE_ASSIGN',decode(p_include_suspended,'Y','SUSP_ASSIGN','ACTIVE_ASSIGN'))
     AND    a.establishment_id  = p_establishment_id)
and not exists
   (select null
   from per_all_assignments_f       a2,
        per_assignment_status_types s2
   where a2.person_id = p_person_id
     AND a2.primary_flag = 'Y'
     AND a2.effective_end_date = a.effective_start_date-1
     AND a2.assignment_status_type_id = s2.assignment_status_type_id
     AND (s2.per_system_status in
           ('ACTIVE_ASSIGN',decode(p_include_suspended,'Y','SUSP_ASSIGN','ACTIVE_ASSIGN'))
     AND    a2.establishment_id  = p_establishment_id));

   end if;


   Return l_date;
End Get_start_date;
--
-- ---------------------------------------------------------------------------
-- |---------------------< Get_end_date >-------------------------------------|
-- ----------------------------------------------------------------------------
--
Function Get_end_date
   (p_person_id 		IN number
   ,p_establishment_id          IN number
   ,p_start_date                IN date
   ,p_include_suspended         IN VARCHAR
   ) RETURN date is
--
--  Define Local Variables
--
l_proc varchar2(72) := g_package||'Get_end_date';
l_date date;
--
Begin

/* Find the record which succeeds the assignment data block and which does not meet the
   Assignment Status Type and Establishment criteria
*/
   select min(a.effective_start_date) - 1
   into l_date
   from per_all_assignments_f          a,
        per_assignment_status_types    s
   where  a.person_id = p_person_id
     AND a.primary_flag = 'Y'
     AND a.effective_start_date > p_start_date
     AND a.assignment_status_type_id = s.assignment_status_type_id
     AND a.assignment_status_type_id = s.assignment_status_type_id
     AND (s.per_system_status not in
           ('ACTIVE_ASSIGN',decode(p_include_suspended,'Y','SUSP_ASSIGN','ACTIVE_ASSIGN'))
         OR a.establishment_id  <> p_establishment_id);

   if l_date is null then

/* If no record is found above then get the earliest end date which does meet the criteria
   for which there is no succeeding record which meets the criteria
*/
   select min(a.effective_end_date)
   into l_date
   from per_all_assignments_f          a,
        per_assignment_status_types    s
   where  a.person_id = p_person_id
     AND a.primary_flag = 'Y'
     AND a.effective_end_date > p_start_date
     AND a.assignment_status_type_id = s.assignment_status_type_id
     AND a.assignment_status_type_id = s.assignment_status_type_id
     AND (s.per_system_status in
           ('ACTIVE_ASSIGN',decode(p_include_suspended,'Y','SUSP_ASSIGN','ACTIVE_ASSIGN'))
     AND a.establishment_id  = p_establishment_id)
and not exists
   (select null
   from per_all_assignments_f       a2,
        per_assignment_status_types s2
   where a2.person_id = p_person_id
     AND a2.primary_flag = 'Y'
     AND a2.effective_start_date = a.effective_end_date+1
     AND a2.assignment_status_type_id = s2.assignment_status_type_id
     AND (s2.per_system_status in
           ('ACTIVE_ASSIGN',decode(p_include_suspended,'Y','SUSP_ASSIGN','ACTIVE_ASSIGN'))
     AND    a2.establishment_id  = p_establishment_id));

   end if;

   Return l_date;

End get_end_date;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< Get_reason >----------------------------------|
-- comment : the switch_starting_leaving_reason variable can ONLY be set
--           with 2 values, "S" to get the Starting reason, and "L" to get
--           the leaving reason.
-- ----------------------------------------------------------------------------
--
Function Get_reason
   (p_assignment_id 		IN number
   ,p_starting_date	        IN varchar2
   ,p_formula_id	        IN NUMBER
   ,p_switch_starting_leaving   IN varchar2
   ) RETURN varchar2 is
--
--  Define Local Variables
--
l_proc                  varchar2(72) := g_package||' Get_reason';
l_formula_id            ff_formulas_f.formula_id%TYPE;
l_effective_start_date  ff_formulas_f.effective_start_date%TYPE;
l_return_value          varchar2(240);
l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;
--
Begin
   hr_utility.set_location(' Entering:'||l_proc, 5);
   --
   -- Initialize the formula
   --
   hr_utility.set_location(' Initialize formula '||l_proc, 5);
   select formula_id,effective_start_date
   into l_formula_id,l_effective_start_date
   from ff_formulas_f
   where formula_id = p_formula_id;

   hr_utility.set_location('formula id found : ' || to_char(l_formula_id),500);

   ff_exec.init_formula (l_formula_id,
                         l_effective_start_date,
                         l_inputs,
                         l_outputs
                        );

   hr_utility.set_location(' set context variables '||l_proc, 6);

   if (l_inputs.first is not null) and (l_inputs.last is not null)
   then
      -- Set up context values for the formula
      for l_in_cnt in
      l_inputs.first..l_inputs.last
      loop
         hr_utility.set_location(' in the loop ... ' || to_char(l_in_cnt),7);
         if l_inputs(l_in_cnt).name='ASSIGNMENT_ID' then
            l_inputs(l_in_cnt).value := p_assignment_id;
            hr_utility.set_location(' ASSIGNMENT_ID .. done' ,7);
         end if;
         if l_inputs(l_in_cnt).name='DATE_EARNED' then
            l_inputs(l_in_cnt).value := p_starting_date;
            hr_utility.set_location(' DATE_EARNED .. done' ,7);
         end if;
         if l_inputs(l_in_cnt).name='TRANSFER_DATE' then
            l_inputs(l_in_cnt).value := p_starting_date;
            hr_utility.set_location(' TRANSFER_DATE .. done' ,7);
         end if;
         if l_inputs(l_in_cnt).name='SWITCH_STARTING_LEAVING' then
            l_inputs(l_in_cnt).value := p_switch_starting_leaving;
            hr_utility.set_location('SWITCH_STARTING_LEAVING .. done' ,7);
         end if;
      end loop;
   end if;

   --
   -- Run the formula
   --

   hr_utility.set_location(' Prior to execute the formula',8);
   ff_exec.run_formula (l_inputs ,
                        l_outputs
                       );

   hr_utility.set_location(' End run formula',9);

   for l_out_cnt in
   l_outputs.first..l_outputs.last
   loop
      if l_outputs(l_out_cnt).name = 'RETURN_REASON' then
         l_return_value := l_outputs(l_out_cnt).value;
      end if;
   end loop;

   hr_utility.set_location(' After run ..return value = ' || l_return_value,9);

   Return l_return_value;
End Get_reason;
--

End hr_fr_mmo;

/
