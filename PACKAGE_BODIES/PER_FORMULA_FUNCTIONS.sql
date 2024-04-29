--------------------------------------------------------
--  DDL for Package Body PER_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FORMULA_FUNCTIONS" as
/* $Header: pefmlfnc.pkb 120.0 2005/05/31 08:49:45 appldev noship $ */
--
g_package  varchar2(33) := '  per_formula_functions.';  -- Global package name
hr_formula_application_id number;
hr_formula_message varchar2(80);
hr_formula_error exception;
/* Use a random user-defined errnum, using -20001 affects fnd_message calls */
pragma exception_init (hr_formula_error, -201);

--
/* =====================================================================
   Define a global table to hold the relevant looping formulas required
   to calculate pto accruals.
   ---------------------------------------------------------------------*/
TYPE formula_cache_r is RECORD
(
 formula_id             number_tbl,
 formula_name           varchar_80_tbl,
 business_group_id      number_tbl,
 effective_start_date   date_tbl,
 effective_end_date     date_tbl,
 sz                     number
);

g_formula_cache         formula_cache_r;
g_formulas_cached       boolean := FALSE;

/* =====================================================================
   Define a package global record and table type of numeric values.
   Declare an instance of the table.
   ---------------------------------------------------------------------*/
TYPE global_number_r is RECORD
(name  varchar2(30)
,value number);
--
TYPE global_number_t is TABLE OF global_number_r INDEX BY BINARY_INTEGER;
--
global_number global_number_t;
--
/* =====================================================================
   Define a package global record and table type of date values.
   Declare an instance of the table.
   ---------------------------------------------------------------------*/
TYPE global_date_r is RECORD
(name  varchar2(30)
,value date);
--
TYPE global_date_t is TABLE OF global_date_r INDEX BY BINARY_INTEGER;
--
global_date global_date_t;
--
/* =====================================================================
   Define a package global record and table type of text values.
   Declare an instance of the table.
   ---------------------------------------------------------------------*/
TYPE global_text_r is RECORD
(name  varchar2(30)
,value varchar2(80));
--
TYPE global_text_t is TABLE OF global_text_r INDEX BY BINARY_INTEGER;
--
global_text global_text_t;
--
/* =====================================================================
   Name    : Cache Formulas
   Purpose : Populates the PL/SQL table with the given formula_name. If
             the table is already cached, the formula is added.
   Returns : Nothing.
   ---------------------------------------------------------------------*/
procedure cache_formulas (p_formula_name in varchar2) is

  cursor c_get_formulas is
  select ff.formula_id,
         ff.formula_name,
         ff.business_group_id,
         ff.effective_start_date,
         ff.effective_end_date
  from   ff_formulas_f ff
        ,ff_compiled_info_f ffci
  where  ff.formula_id = ffci.formula_id
  and    ff.effective_start_date = ffci.effective_start_date
  and    ff.effective_end_date = ffci.effective_end_date
  and    ff.formula_name = p_formula_name;

  l_proc varchar2(80) := g_package||'cache_formulas';
--
begin
--

   if g_formulas_cached = FALSE then
     g_formula_cache.sz := 0;
   end if;
--
   for ff_rec in c_get_formulas loop
--
     g_formula_cache.sz := g_formula_cache.sz + 1;
     g_formula_cache.formula_id(g_formula_cache.sz) := ff_rec.formula_id;
     g_formula_cache.formula_name(g_formula_cache.sz) := ff_rec.formula_name;
     g_formula_cache.business_group_id(g_formula_cache.sz) := ff_rec.business_group_id;
     g_formula_cache.effective_start_date(g_formula_cache.sz) := ff_rec.effective_start_date;
     g_formula_cache.effective_end_date(g_formula_cache.sz) := ff_rec.effective_end_date;
--
   end loop;
--
   g_formulas_cached := TRUE;
--
end cache_formulas;
--
/* =====================================================================
   Name    : Cache Formulas (overloaded)
   Purpose : Populates the PL/SQL table with the given formula_id. If
             the table is already cached, the formula is added.
   Returns : Nothing.
   ---------------------------------------------------------------------*/
procedure cache_formulas (p_formula_id in number) is

  cursor c_get_formulas is
  select ff.formula_id,
         ff.formula_name,
         ff.business_group_id,
         ff.effective_start_date,
         ff.effective_end_date
  from   ff_formulas_f ff
        ,ff_compiled_info_f ffci
  where  ff.formula_id = ffci.formula_id
  and    ff.effective_start_date = ffci.effective_start_date
  and    ff.effective_end_date = ffci.effective_end_date
  and    ff.formula_id = p_formula_id;

  l_proc varchar2(80) := g_package||'cache_formulas';
--
begin
--
   if g_formulas_cached = FALSE then
     g_formula_cache.sz := 0;
   end if;
--
   for ff_rec in c_get_formulas loop
--
     g_formula_cache.sz := g_formula_cache.sz + 1;
     g_formula_cache.formula_id(g_formula_cache.sz) := ff_rec.formula_id;
     g_formula_cache.formula_name(g_formula_cache.sz) := ff_rec.formula_name;
     g_formula_cache.business_group_id(g_formula_cache.sz) := ff_rec.business_group_id;
     g_formula_cache.effective_start_date(g_formula_cache.sz) := ff_rec.effective_start_date;
     g_formula_cache.effective_end_date(g_formula_cache.sz) := ff_rec.effective_end_date;

   end loop;

   g_formulas_cached := TRUE;

end cache_formulas;
--
/* =====================================================================
   Name    : Get Cache Formula
/* =====================================================================
   Name    : Get Cache Formula
   Purpose : Gets the formula_id from a cached pl/sql table to prevent
             a full table scan on ff_formulas_f for each person in the
             payroll run.
   Returns : formula_id if found, otherwise 0.
   ---------------------------------------------------------------------*/
function get_cache_formula(p_formula_name      in varchar2,
                           p_business_group_id in number,
                           p_calculation_date  in date)
                           return number is

ff_rec         number;
l_formula_id   number := 0;

begin
--

   for ff_rec in 1..g_formula_cache.sz loop

     if   (g_formula_cache.formula_name(ff_rec) = p_formula_name)
      and (nvl(g_formula_cache.business_group_id(ff_rec), p_business_group_id) = p_business_group_id)
      and (p_calculation_date between g_formula_cache.effective_start_date(ff_rec) and
                                     g_formula_cache.effective_end_date(ff_rec))
     then
       l_formula_id := g_formula_cache.formula_id(ff_rec);
     end if;

   end loop;

   return l_formula_id;
   -- This will be zero if the formula is not in the cached formulas

--
end get_cache_formula;
/* =====================================================================
   Name    : Get Cache Formula (overloaded)
   Purpose : Gets the formula_id from a cached pl/sql table to prevent
             a hit on ff_formulas_f for each person in the
             payroll run.
   Returns : formula_id if found, otherwise 0.
   ---------------------------------------------------------------------*/
function get_cache_formula(p_formula_id       in number,
                           p_calculation_date in date)
                           return varchar2 is

ff_rec         number;
l_formula_name ff_formulas_f.formula_name%TYPE;

begin
--

   for ff_rec in 1..g_formula_cache.sz loop

     if   (g_formula_cache.formula_id(ff_rec) = p_formula_id)
     and (p_calculation_date between g_formula_cache.effective_start_date(ff_rec) and
                                     g_formula_cache.effective_end_date(ff_rec))
     then
       l_formula_name := g_formula_cache.formula_name(ff_rec);
     end if;

   end loop;

   return l_formula_name;
   -- This will be null if the formula is not in the cached formulas

end get_cache_formula;
--
/* =====================================================================
   Name    : Get Formula
   Purpose : Gets the formula_id from a cached pl/sql table to prevent
             a full table scan on ff_formulas_f for each person in the
             payroll run.
   Returns : formula_id if found, otherwise null.
   ---------------------------------------------------------------------*/
function get_formula(p_formula_name      in varchar2,
                     p_business_group_id in number,
                     p_calculation_date  in date)
                     return number is

l_formula_id   number;

begin
--
   if g_formulas_cached = FALSE then
     cache_formulas (p_formula_name => p_formula_name);
   end if;

   l_formula_id := get_cache_formula (
                       p_formula_name => p_formula_name,
                       p_business_group_id => p_business_group_id,
                       p_calculation_date => p_calculation_date
                       );

   if l_formula_id = 0 then
     -- Formula not found in existing cached table. This probably means
     -- that payroll is processing several different accrual plans
     -- such as Vacation and Sick plans which are using different
     -- formulae. We continue adding to the cached plsql table
     -- until we have all the formula required.
     cache_formulas (p_formula_name => p_formula_name);

     -- Again search the cached table for the newly added formula records.
     l_formula_id := get_cache_formula (
                       p_formula_name => p_formula_name,
                       p_business_group_id => p_business_group_id,
                       p_calculation_date => p_calculation_date
                       );

   end if;

   return l_formula_id;
   -- This will be zero if formula does not exist or is not compiled.

--
end get_formula;
/* =====================================================================
   Name    : Get Formula (overloaded)
   Purpose : Gets the formula_name from a cached pl/sql table to prevent
             a hit on ff_formulas_f for each PTO formula used.
   Returns : formula_name if found, otherwise null.
   ---------------------------------------------------------------------*/
function get_formula(p_formula_id       in number,
                     p_calculation_date in date)
                     return varchar2 is

l_formula_name   ff_formulas_f.formula_name%TYPE;

begin
--
   if g_formulas_cached = FALSE then
     cache_formulas (p_formula_id => p_formula_id);
   end if;

   l_formula_name := get_cache_formula (
                       p_formula_id => p_formula_id,
                       p_calculation_date => p_calculation_date
                       );

   if l_formula_name is null then
     -- Formula not found in existing cached table. Add the formula to
     -- the cache.
     cache_formulas (p_formula_id => p_formula_id);

     -- Again search the cached table for the newly added formula records.
     l_formula_name := get_cache_formula (
                         p_formula_id => p_formula_id,
                         p_calculation_date => p_calculation_date
                         );

   end if;

   return l_formula_name;
   -- This will be null if formula does not exist or is not compiled.
--
end get_formula;
--
/* =====================================================================
   Name    : Loop Control
   Purpose : To repeatedly run a formula while the CONTINUE_PROCESSING_FLAG
             output parameter is set to 'Y'. If the value is 'N' then the
             function will end normally otherwise it will abort.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function loop_control(p_business_group_id number
		     ,p_calculation_date  date
		     ,p_assignment_id number
		     ,p_payroll_id number
		     ,p_accrual_plan_id number
		     ,p_formula_name   varchar2) return number is
--
l_proc        varchar2(72) := g_package||'loop_control';
--
l_continue_loop            varchar2(1);
l_inputs                   ff_exec.inputs_t;
l_get_outputs              ff_exec.outputs_t;
l_formula_id               number;
--

begin
--
  hr_utility.set_location(l_proc, 5);


  -- Get the formula ID from a a plsql table instead of ff_formulas_f
  -- to improve performance of batch processes.
  l_formula_id := get_formula (
                    p_formula_name => p_formula_name,
                    p_business_group_id => p_business_group_id,
                    p_calculation_date => p_calculation_date
                    );

  if l_formula_id = 0 then
  --
    hr_utility.set_location(l_proc, 10);
    fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
    fnd_message.set_token('1', p_formula_name);
    fnd_message.raise_error;
  --
  else
  --

    -----------------------------
    -- Initialise the formula. --
    -----------------------------
    --
    l_inputs(1).name := 'ASSIGNMENT_ID';
    l_inputs(1).value := p_assignment_id;
    l_inputs(2).name := 'DATE_EARNED';
    -- Start of fix 3047532
    --l_inputs(2).value := to_char(p_calculation_date, 'DD-MON-YYYY');
    l_inputs(2).value := fnd_date.date_to_canonical(p_calculation_date);
    -- End of fix 2047532
    l_inputs(3).name := 'ACCRUAL_PLAN_ID';
    l_inputs(3).value := p_accrual_plan_id;
    l_inputs(4).name := 'BUSINESS_GROUP_ID';
    l_inputs(4).value := p_business_group_id;
    l_inputs(5).name := 'PAYROLL_ID';
    l_inputs(5).value := p_payroll_id;

    l_get_outputs(1).name := 'CONTINUE_PROCESSING_FLAG';

    while true loop
    --
      ----------------------
      -- Run the formula. --
      ----------------------
      hr_utility.set_location('Prior to Run Formula '||l_proc, 10);
      --
      per_formula_functions.run_formula (p_formula_id => l_formula_id
				        ,p_calculation_date => p_calculation_date
                                        ,p_inputs => l_inputs
                                        ,p_outputs => l_get_outputs);

      l_continue_loop := l_get_outputs(1).value;
      --
      hr_utility.set_location('Run Formula Complete '||l_proc, 15);
      -------------------------------
      -- Test the output parameter --
      -------------------------------
      if l_continue_loop = 'Y' then
        null; -- continue processing
      elsif l_continue_loop = 'N' then
        exit; -- exit the loop and end looping sucessfully
      else
        return 1;
      end if;
    --
    end loop;
  --
  end if;

  hr_utility.set_location('Successful Exit '||l_proc, 20);
  return 0;
--
end loop_control;
--
/* =====================================================================
   Name    : call_formula
   Purpose : To run a named formula, with no inputs and no outputs
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function call_formula
(p_business_group_id number
,p_calculation_date date
,p_assignment_id number
,p_payroll_id number
,p_accrual_plan_id number
,p_formula_name   varchar2) return number is
--
l_proc        varchar2(72) := g_package||'call_formula';
l_inputs                   ff_exec.inputs_t;
l_get_outputs              ff_exec.outputs_t;
--
begin
     -----------------------------
     -- Initialise the formula. --
     -----------------------------
     --
     l_inputs(1).name := 'ASSIGNMENT_ID';
     l_inputs(1).value := p_assignment_id;
     l_inputs(2).name := 'DATE_EARNED';
     l_inputs(2).value := to_char(p_calculation_date, 'DD-MON-YYYY');
     l_inputs(3).name := 'ACCRUAL_PLAN_ID';
     l_inputs(3).value := p_accrual_plan_id;
     l_inputs(4).name := 'BUSINESS_GROUP_ID';
     l_inputs(4).value := p_business_group_id;
     l_inputs(5).name := 'PAYROLL_ID';
     l_inputs(5).value := p_payroll_id;

     l_get_outputs(1).name := 'CONTINUE_PROCESSING_FLAG';
     ----------------------
     -- Run the formula. --
     ----------------------
     hr_utility.set_location('Prior to Run Formula '||l_proc, 10);
     --
     per_formula_functions.run_formula (p_formula_name => p_formula_name
				      ,p_business_group_id => p_business_group_id
				      ,p_calculation_date => p_calculation_date
                                      ,p_inputs => l_inputs
                                      ,p_outputs => l_get_outputs);
     hr_utility.set_location('Run Formula Complete '||l_proc, 15);
     return 0;
end call_formula;
--
/* =====================================================================
   Name    : run_formula
   Purpose : To run a named formula, handling the input and output
             parameters.
   ---------------------------------------------------------------------*/
procedure run_formula
(p_formula_name      varchar2
,p_business_group_id number
,p_calculation_date  date
,p_inputs            ff_exec.inputs_t
,p_outputs IN OUT NOCOPY    ff_exec.outputs_t) is
--
l_proc        varchar2(72) := g_package||'run_formula';
l_inputs  ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;
l_formula_id number;

begin

  hr_utility.set_location('Entering '||l_proc, 5);
  --
  ------------------------
  -- Get the formula id --
  ------------------------

  -- Get the formula ID from a a plsql table instead of ff_formulas_f
  -- to improve performance of batch processes.
  l_formula_id := get_formula (
                    p_formula_name => p_formula_name,
                    p_business_group_id => p_business_group_id,
                    p_calculation_date => p_calculation_date
                    );

  if l_formula_id = 0 then
     hr_utility.set_location(l_proc, 10);
      fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
      fnd_message.set_token('1', p_formula_name);
      fnd_message.raise_error;
  else
     run_formula(p_formula_id => l_formula_id,
		 p_calculation_date => p_calculation_date,
		 p_inputs => p_inputs,
		 p_outputs => p_outputs);
  end if;
--
end run_formula;
--
/* =====================================================================
   Name    : run_formula
   Purpose : To run a named formula, handling the input and output
             parameters.
   ---------------------------------------------------------------------*/
procedure run_formula
(p_formula_id     number
,p_calculation_date date
,p_inputs         ff_exec.inputs_t
,p_outputs IN OUT NOCOPY ff_exec.outputs_t) is
--

  /* Gets the FF name when a FF is not compiled. */
  cursor csr_get_ff_name is
  select ff.formula_name
  from   ff_formulas_f ff
  where  ff.formula_id = p_formula_id
  and    p_calculation_date between
         ff.effective_start_date and ff.effective_end_date;

  l_formula_name ff_formulas_f.formula_name%TYPE;
  l_proc         varchar2(72) := g_package||'run_formula';
  l_inputs       ff_exec.inputs_t;
  l_outputs      ff_exec.outputs_t;
--
begin

  hr_utility.set_location('Entering '||l_proc, 5);

  -- Cache this formula.  The purpose of this is to fetch the formula name
  -- (if the formula does not exist or is not compiled it is listed in the
  -- error message). It is cached to prevent frequent hits on ff_formulas_f
  -- and ff_compiled_info_f.
  l_formula_name := get_formula (
                      p_formula_id => p_formula_id,
                      p_calculation_date => p_calculation_date
                    );
  if l_formula_name is null then

     hr_utility.set_location(l_proc, 8);

     open  csr_get_ff_name;
     fetch csr_get_ff_name into l_formula_name;
     close csr_get_ff_name;

     fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
     fnd_message.set_token('1', l_formula_name);
     fnd_message.raise_error;
  else
    --
    ----------------------------
    -- Initialize the formula --
    ----------------------------
    ff_exec.init_formula(p_formula_id, p_calculation_date, l_inputs, l_outputs);
    --
    hr_utility.set_location('Handle inputs '||l_proc, 10);
    -----------------------------
    -- Set up the input values --
    -----------------------------
    if l_inputs.count > 0 and p_inputs.count > 0 then
      for i in l_inputs.first..l_inputs.last loop
       for j in p_inputs.first..p_inputs.last loop
          if l_inputs(i).name = p_inputs(j).name then
             l_inputs(i).value := p_inputs(j).value;
               exit;
          end if;
       end loop;
      end loop;
    end if;
    --
    hr_utility.set_location('Run Formula '||l_proc, 15);
    ---------------------
    -- Run the formula --
    ---------------------
    ff_exec.run_formula(l_inputs,l_outputs);
      --
    hr_utility.set_location('Handle outputs '||l_proc, 20);
    -------------------------------
    -- Populate the output table --
    -------------------------------
    if l_outputs.count > 0 and p_inputs.count > 0 then
      for i in l_outputs.first..l_outputs.last loop
          for j in p_outputs.first..p_outputs.last loop
              if l_outputs(i).name = p_outputs(j).name then
                p_outputs(j).value := l_outputs(i).value;
                exit;
             end if;
         end loop;
      end loop;
    end if;

  end if;

exception
   when hr_formula_error then
        hr_utility.set_location(l_proc, 98);
        hr_utility.set_message(hr_formula_application_id,hr_formula_message);
        hr_utility.raise_error;
   when others then
        hr_utility.set_location(l_proc, 99);
        raise;
end run_formula;
--
/* =====================================================================
   Name    : get_number
   Purpose : To retrieve the value of a numeric global variable
   Returns : The value of the varibale if found, NULL otherwise
   ---------------------------------------------------------------------*/
function get_number
(p_name varchar2) return number IS
--
l_proc        varchar2(72) := g_package||'get_number';
--
begin
  hr_utility.set_location(l_proc, 1);

  if global_number.count>0 then
  --
   for i in global_number.first..global_number.last loop
       if global_number(i).name = p_name then
          hr_utility.set_location(
                 p_name||'='||global_number(i).value||' '||l_proc, 5);
          return global_number(i).value;
       end if;
   end loop;
   --
  end if;

   hr_utility.set_location(p_name||' Not Found '||l_proc, 10);
   return null;
end get_number;
--
/* =====================================================================
   Name    : set_number
   Purpose : To set the value of a numeric global variable
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function set_number
(p_name varchar2
,p_value number) return number IS
--
l_proc        varchar2(72) := g_package||'set_number';
j number;
--
begin
   hr_utility.set_location(
        'Setting '||p_name||'='||to_char(p_value)||' '||l_proc, 5);
   j := 0;
   if global_number.count > 0 then
      for i in global_number.first..global_number.last loop
          j := j + 1;
          if global_number(i).name = p_name then
             global_number(i).value := p_value;
             return 0;
          end if;
      end loop;
   end if;
   global_number(j).name  := p_name;
   global_number(j).value := p_value;
   return 0;
exception
   when others then
        hr_utility.set_location('Error '||l_proc, 10);
        return 1;
end set_number;
/* =====================================================================
   Name    : get_date
   Purpose : To retrieve the value of a date global variable
   Returns : The value of the varibale if found, NULL otherwise
   ---------------------------------------------------------------------*/
function get_date
(p_name varchar2) return date IS
--
l_proc        varchar2(72) := g_package||'get_date';
--
begin
--
  hr_utility.set_location(l_proc, 1);

  if global_date.count>0 then
  --
   for i in global_date.first..global_date.last loop
       if global_date(i).name = p_name then
          hr_utility.set_location(
                 p_name||'='||global_date(i).value||' '||l_proc, 5);
	  return global_date(i).value;
       end if;
   end loop;
  --
  end if;
   --
   hr_utility.set_location(p_name||' Not Found '||l_proc, 10);
   return null;
end get_date;
--
/* =====================================================================
   Name    : set_date
   Purpose : To set the value of a date global variable
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function set_date
(p_name varchar2
,p_value date) return number IS
--
l_proc        varchar2(72) := g_package||'set_date';
--
j number;
begin
   hr_utility.set_location(
        'Setting '||p_name||'='||to_char(p_value,'DD-MM-YYYY')||' '||l_proc, 5);
   j := 0;
   if global_date.count > 0 then
      for i in global_date.first..global_date.last loop
          j := j + 1;
          if global_date(i).name = p_name then
             global_date(i).value := p_value;
             return 0;
          end if;
      end loop;
   end if;
   global_date(j).name  := p_name;
   global_date(j).value := p_value;
   return 0;
exception
   when others then
        hr_utility.set_location('Error '||l_proc, 10);
        return 1;
end set_date;
--
/* =====================================================================
   Name    : get_text
   Purpose : To retrieve the value of a text global variable
   Returns : The value of the varibale if found, NULL otherwise
   ---------------------------------------------------------------------*/
function get_text
(p_name varchar2) return varchar2 IS
--
l_proc        varchar2(72) := g_package||'get_text';
--
begin

  hr_utility.set_location(l_proc, 1);

  if global_text.count>0 then
  --
   for i in global_text.first..global_text.last loop
       if global_text(i).name = p_name then
          hr_utility.set_location(
                 p_name||'='||global_text(i).value||' '||l_proc, 5);
          return global_text(i).value;
       end if;
   end loop;
   --
  end if;

  hr_utility.set_location(p_name||' Not Found '||l_proc, 10);
  return null;
end get_text;
--
/* =====================================================================
   Name    : set_text
   Purpose : To set the value of a text global variable
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function set_text
(p_name varchar2
,p_value varchar2) return number IS
--
l_proc        varchar2(72) := g_package||'set_text';
--
j number;
begin
   hr_utility.set_location(
        'Setting '||p_name||'='||p_value||' '||l_proc, 5);
   j := 0;
   if global_text.count > 0 then
      for i in global_text.first..global_text.last loop
          j := j + 1;
          if global_text(i).name = p_name then
             global_text(i).value := p_value;
             return 0;
          end if;
      end loop;
   end if;
   global_text(j).name  := p_name;
   global_text(j).value := p_value;
   return 0;
exception
   when others then
        hr_utility.set_location('Error '||l_proc, 10);
        return 1;
end set_text;
--
/* =====================================================================
   Name    : isnull
   Purpose : To evaluate whether a text variable is NULL
   Returns : 'Y' if it is null, 'N' otherwise
   ---------------------------------------------------------------------*/
function isnull (p_value varchar2) return varchar2 is
begin
   if p_value is null then
      return 'Y';
   else
      return 'N';
   end if;
end isnull;
--
/* =====================================================================
   Name    : isnull
   Purpose : To evaluate whether a numeric variable is NULL
   Returns : 'Y' if it is null, 'N' otherwise
   ---------------------------------------------------------------------*/
function isnull (p_value number) return varchar2 is
begin
   return isnull(to_char(p_value));
end isnull;
--
/* =====================================================================
   Name    : isnull
   Purpose : To evaluate whether a date variable is NULL
   Returns : 'Y' if it is null, 'N' otherwise
   ---------------------------------------------------------------------*/
function isnull (p_value date) return varchar2 is
begin
   return isnull(to_char(p_value,'DDMMYYYY'));
end isnull;
--
/* =====================================================================
   Name    : remove_globals
   Purpose : To delete all global variables
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function remove_globals return number is
--
l_proc        varchar2(72) := g_package||'remove_globals';
--
init_global_number global_number_t;
init_global_date   global_date_t;
init_global_text   global_text_t;
--
begin
   hr_utility.set_location(l_proc, 5);
   global_number := init_global_number;
   global_date   := init_global_date;
   global_text   := init_global_text;
   return 0;
exception
   when others then
        hr_utility.set_location('Error '||l_proc, 10);
        return 1;
end remove_globals;
--
/* =====================================================================
   Name    : clear_globals
   Purpose : To set the value of all global variables to NULL
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function clear_globals return number is
--
l_proc        varchar2(72) := g_package||'clear_globals';
--
j number;
begin
   hr_utility.set_location('Clearing Numeric Globals '||l_proc, 5);
   j := 0;
   if global_number.count > 0 then
      for i in global_number.first..global_number.last loop
          j := j + 1;
          global_number(i).value := null;
      end loop;
   end if;
   --
   hr_utility.set_location('Clearing Date Globals '||l_proc, 10);
   j := 0;
   if global_date.count > 0 then
      for i in global_date.first..global_date.last loop
          j := j + 1;
          global_date(i).value := null;
      end loop;
   end if;
   --
   hr_utility.set_location('Clearing Text Globals '||l_proc, 15);
   j := 0;
   if global_text.count > 0 then
      for i in global_text.first..global_text.last loop
          j := j + 1;
          global_text(i).value := null;
      end loop;
   end if;
   --
   return 0;
exception
   when others then
        hr_utility.set_location('Error '||l_proc, 10);
        return 1;
end clear_globals;
--
/* =====================================================================
   Name    : debug
   Purpose : To output a string using DBMS_OUTPUT
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function debug(p_message varchar2) return number IS
--
l_proc        varchar2(72) := g_package||'debug';
--
begin
  hr_utility.set_location(l_proc, 5);
  -- Bug#885806
  -- dbms_output.put_line(p_message);
  hr_utility.trace(p_message);
  hr_utility.set_location(l_proc, 10);
  return 0;
exception
   when others then
        hr_utility.set_location('Error '||l_proc, 10);
        return 1;
end debug;
--
/* =====================================================================
   Name    : raise_error
   Purpose : To raise an applications error
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function raise_error
(p_application_id number
,p_message_name varchar2) return number is
--
l_proc        varchar2(72) := g_package||'raise_error';
--
begin
   hr_utility.set_location(l_proc, 10);
   hr_formula_application_id := p_application_id;
   hr_formula_message := p_message_name;
   -- Start of 3294192
   --raise hr_formula_error;
   hr_utility.set_message(p_application_id, p_message_name);
   hr_utility.raise_error;
   -- End of 3294192
   return 0;
end raise_error;
--
end per_formula_functions;

/
