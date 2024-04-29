--------------------------------------------------------
--  DDL for Package Body HR_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON" AS
/* $Header: peperson.pkb 120.5.12010000.5 2008/08/12 06:38:17 sathkris ship $ */
--
g_debug boolean := hr_utility.debug_enabled;

-- Bug 2678794: defintions changed to varchar2
-- to avoid ORA-06502 when implicit numeric conversions occur.
--
emp_number_sv per_all_people_f.employee_number%TYPE  := '0';   --NUMBER := 0;
apl_number_sv per_all_people_f.applicant_number%TYPE := '0';   --NUMBER := 0;
npw_number_sv per_all_people_f.npw_number%TYPE       := '0';   --NUMBER := 0;

-- --------------------------------------------------------------------- +
-- #2660279            Is_Unique_Person_number                           +
-- --------------------------------------------------------------------- +
-- Returns 'Y' if number is unique within Business Group
-- otherwise returns 'N'
--
FUNCTION IS_UNIQUE_PERSON_NUMBER (p_person_id         IN  number
                                 ,p_person_type       IN  per_number_generation_controls.type%TYPE
                                 ,p_person_number     IN  varchar2
                                 ,p_business_group_id IN  number
                                  )
  RETURN varchar2 IS

  l_status varchar2(1);
BEGIN
  l_status := 'N';
  if p_person_type = 'APL'  then
    SELECT 'N'
    INTO   l_status
    FROM   sys.dual
    WHERE  exists (SELECT 'Y'
    FROM   per_all_people_f  pp
    WHERE (p_person_id IS NULL
       OR  p_person_id <> pp.person_id)
    AND    pp.business_group_id  +0 = p_business_group_id
    AND    pp.applicant_number      = p_person_number);
  --
  end if;
  --
  if p_person_type = 'EMP'  then
    --
    -- The employee number is also validated against the npw number when
    -- the CWK numbering method if Use Employee Numbering.
    --
    SELECT 'N'
    INTO   l_status
    FROM   sys.dual
    WHERE  exists (select 'Y'
    FROM   per_all_people_f  pp
    WHERE (p_person_id IS NULL
       OR  p_person_id <> pp.person_id)
    AND    pp.business_group_id = p_business_group_id
    AND   (pp.employee_number   = p_person_number
       OR  (pp.npw_number       = p_person_number
       AND EXISTS
             (SELECT null
              FROM   per_business_groups pbg
              WHERE  pbg.business_group_id = p_business_group_id
              AND    NVL(method_of_generation_cwk_num,hr_api.g_varchar2) = 'E'))));
  --
  end if;
  --
  if p_person_type = 'CWK'  then
  --
    SELECT 'N'
    INTO   l_status
    FROM   sys.dual
    WHERE  exists (select 'Y'
    FROM   per_all_people_f  pp
    WHERE (p_person_id IS NULL
       OR  p_person_id <> pp.person_id)
    AND    pp.business_group_id = p_business_group_id
    AND   (pp.npw_number        = p_person_number
       OR  (pp.employee_number  = p_person_number
       AND EXISTS
             (SELECT null
              FROM   per_business_groups pbg
              WHERE  pbg.business_group_id = p_business_group_id
              AND    NVL(method_of_generation_cwk_num,hr_api.g_varchar2) = 'E'))));
    --
  end if;

  RETURN(l_status);

EXCEPTION
   when no_data_found then
      if g_debug then
         hr_utility.trace('Unique Person Number 999');
      end if;
      return('Y');

END IS_UNIQUE_PERSON_NUMBER;
-- --------------------------------------------------------------------- +
-- #2660279               Get_Person_Number                              +
-- --------------------------------------------------------------------- +
-- Gets the next person number from the per_number_generation_controls
-- table/global sequence. It will check that the number is unique within the
-- Business Group. In case this number already exists, it will check the next
-- value (maximum 25 times) until an unassigned number is found.
-- If after 25 times, a number could not be found, then an error message
-- will be raised.
--
--
PROCEDURE GET_PERSON_NUMBER (p_person_type       IN     per_number_generation_controls.type%TYPE
                            ,p_person_number     IN OUT NOCOPY varchar2
                            ,p_business_group_id IN     number
                            ,p_person_id         IN     number
                            ,p_effective_date    IN     date
                            ,p_party_id          IN     number
                            ,p_date_of_birth     IN     date
                            ,p_start_date        IN     date
                            ,p_national_id       IN     varchar2
                            ) IS
  --
  e_MaxExceeds exception;
    PRAGMA EXCEPTION_INIT(e_MaxExceeds, -1438);

  cursor csr_getSessionDate is
    select fnd.effective_date
      from fnd_sessions fnd
     where fnd.session_id = userenv('sessionid');

  l_counter          number := 1;
  l_person_number    varchar2(30);
  l_is_unique        varchar2(1);
  l_max_sequence     number       := 25;    -- determines maximum iterations for loop
  l_rowid            ROWID ;
  l_use_sequence     boolean      := false; -- based on x-bg person numbering profile
  l_formula_id       number;
  l_effective_date   date;
  l_legislation_code varchar2(150);

BEGIN
   l_is_unique := 'N';
   l_formula_id := PER_BG_NUMBERING_METHOD_PKG.Get_PersonNumber_Formula
                     (p_person_type, p_effective_date);
   IF l_formula_id is not null THEN
   -- ------------------------------------------------------------------------+
   -- Process number generation using Fast Formula                            +
   -- ------------------------------------------------------------------------+
      --
      -- Get other parameters
      --
      l_legislation_code :=  per_utility_functions.get_legislation
                             (p_business_group_id => p_business_group_id);
      --
      -- Execute formula
      --
      l_person_number := PER_BG_NUMBERING_METHOD_PKG.Execute_Get_Person_Number_FF(
                          p_formula_id        => l_formula_id
                         ,p_effective_date    => p_effective_date
                         ,p_business_group_id => p_business_group_id
                         ,p_person_type       => p_person_type
                         ,p_legislation_code  => l_legislation_code
                         ,p_person_id         => p_person_id
                         ,p_person_number     => p_person_number
                         ,p_party_id          => p_party_id
                         ,p_date_of_birth     => p_date_of_birth
                         ,p_start_date        => p_start_date
                         ,p_national_id       => p_national_id
                         );
      --
      -- verify person number is unique
      --
      l_is_unique := IS_UNIQUE_PERSON_NUMBER
                      (p_person_id         => p_person_id
                      ,p_person_type       => p_person_type
                      ,p_person_number     => l_person_number
                      ,p_business_group_id => p_business_group_id
                      );

       if l_is_unique = 'N' then
            p_person_number := null;
            if p_person_type = 'EMP' then
                hr_utility.set_message(800,'HR_7692_PERSON_NUM_EXIST');
            elsif p_person_type = 'APL' then
                hr_utility.set_message(800,'HR_7693_PERSON_NUM_EXISTS');
            elsif p_person_type = 'CWK' then
                hr_utility.set_message(800,'HR_289656_CWK_NUM_EXIST');
            end if;
            hr_utility.raise_error;
       end if;
       p_person_number := l_person_number;
   ELSE
   -- ------------------------------------------------------------------------+
   -- Process number generation using existing mechanism                      +
   -- ------------------------------------------------------------------------+
   BEGIN
    l_use_sequence := PER_BG_NUMBERING_METHOD_PKG.Global_person_numbering(p_person_type);
    if l_use_sequence then
      -- retrieve number from sequence
      l_person_number := PER_BG_NUMBERING_METHOD_PKG.GetGlobalPersonNum(p_person_type);
    else
       -- Table-based method is used
        SELECT next_value
        ,      rowid
        INTO   l_person_number
        ,      l_rowid
        FROM   per_number_generation_controls
        WHERE  business_group_id = p_business_group_id
        AND    type              = p_person_type
        FOR UPDATE OF next_value ;
    end if;
    WHILE (l_counter <= l_max_sequence and l_is_unique = 'N') LOOP

        l_is_unique := IS_UNIQUE_PERSON_NUMBER
                              (p_person_id         => p_person_id
                              ,p_person_type       => p_person_type
                              ,p_person_number     => l_person_number
                              ,p_business_group_id => p_business_group_id
                              );
        if l_is_unique = 'N' then
           if l_use_sequence then
              -- get number from sequence
              l_person_number := PER_BG_NUMBERING_METHOD_PKG.GetGlobalPersonNum(p_person_type);
           else
              l_counter := l_counter + 1;
              l_person_number := l_person_number + 1;
           end if;
        end if;
    END LOOP;
    if l_is_unique = 'N' then
        p_person_number := null;
        if p_person_type = 'EMP' then
            hr_utility.set_message(800,'HR_7692_PERSON_NUM_EXIST');
        elsif p_person_type = 'APL' then
            hr_utility.set_message(800,'HR_7693_PERSON_NUM_EXISTS');
        elsif p_person_type = 'CWK' then
            hr_utility.set_message(800,'HR_289656_CWK_NUM_EXIST');
        end if;
        hr_utility.raise_error;
    else
       if NOT l_use_sequence then
           UPDATE per_number_generation_controls
           SET    next_value = l_person_number + 1
           WHERE  rowid      = l_rowid ;
       end if;
        --
        p_person_number := l_person_number;
    end if;
   EXCEPTION
      when e_MaxExceeds then
         hr_utility.set_message(800,'PER_289194_MAX_NUM_REACHED');
         hr_utility.raise_error;
   END;
   -- ------------------------------------------------------------------------+
   -- End existing mechanisms                                                 +
   -- ------------------------------------------------------------------------+
   END IF;

END GET_PERSON_NUMBER;
-- --------------------------------------------------------------------- +
--
-- -----------------------  generate_number ------------------------
--
-- Procedure accepts the current emp/apl/npw flags, national identifier
-- and business group and outputs the appropriate person number
-- (Note if the person numbers are supplied and the method
--  is not automatic - the numbers will remain unchanged).
--
PROCEDURE generate_number
 (p_current_employee    VARCHAR2 default null,
  p_current_applicant   VARCHAR2 default null,
  p_current_npw         VARCHAR2 default null,
  p_national_identifier VARCHAR2 default null,
  p_business_group_id   NUMBER,
  p_person_id           NUMBER,
  p_employee_number  IN OUT NOCOPY VARCHAR2 ,
  p_applicant_number IN OUT NOCOPY VARCHAR2 ,
  p_npw_number       IN OUT NOCOPY VARCHAR2) IS

BEGIN
   generate_number
    (p_current_employee    => p_current_employee
    ,p_current_applicant   => p_current_applicant
    ,p_current_npw         => p_current_npw
    ,p_national_identifier => p_national_identifier
    ,p_business_group_id   => p_business_group_id
    ,p_person_id           => p_person_id
    ,p_employee_number     => p_employee_number
    ,p_applicant_number    => p_applicant_number
    ,p_npw_number          => p_npw_number
    ,p_effective_date      => null
    ,p_party_id            => null
    ,p_date_of_birth       => null
    ,p_start_date          => null
    );


END generate_number;
--
-- Overloaded
--
PROCEDURE generate_number
    (p_current_employee    VARCHAR2 default null
    ,p_current_applicant   VARCHAR2 default null
    ,p_current_npw         VARCHAR2 default null
    ,p_national_identifier VARCHAR2 default null
    ,p_business_group_id   NUMBER
    ,p_person_id           NUMBER
    ,p_employee_number     IN OUT NOCOPY VARCHAR2
    ,p_applicant_number    IN OUT NOCOPY VARCHAR2
    ,p_npw_number          IN OUT NOCOPY VARCHAR2
    ,p_effective_date      IN     date
    ,p_party_id            IN     number
    ,p_date_of_birth       IN     date
    ,p_start_date          IN     date default null
    )
--
--
IS
  l_method_of_generation  VARCHAR2(30);
  l_method_of_gen_emp     VARCHAR2(30);
  l_legislation_code      VARCHAR2(30);
  l_rowid                 ROWID ;
  l_person_id             NUMBER;
--
begin
--
--
   hr_utility.set_location('hr_person.generate_number',1);
--
if p_current_applicant = 'Y' then
 --
 if g_debug then
  hr_utility.set_location('number_generation',1);
 end if;
 --
  SELECT pbg.method_of_generation_apl_num
  ,      pbg.legislation_code
  INTO   l_method_of_generation
  ,      l_legislation_code
  FROM   per_business_groups pbg
  WHERE  pbg.business_group_id = p_business_group_id;
  --
  if l_method_of_generation = 'A' then
   if g_debug then
       hr_utility.set_location('number_generation',2);
   end if;
   if p_applicant_number is NOT NULL then
     begin
       select person_id
       into   l_person_id
       from   per_people_f ppf
       where  ppf.applicant_number = p_applicant_number
           and ppf.business_group_id  +0 = p_business_group_id
           and rownum = 1;

       if (l_person_id = p_person_id) then
           apl_number_sv := 0;
       else
           p_applicant_number := NULL;
       end if;
       exception
         when no_data_found then
            if p_applicant_number = apl_number_sv then
               p_applicant_number := NULL;
            else
               apl_number_sv := 0;
            end if;
     end;

   end if;

--Second Check
   if p_applicant_number is NOT NULL then
     begin
       select null
       into   p_applicant_number
       from   sys.dual
       where  (p_person_id is not null
                   and not exists (select '1'
                                   from per_assignments_f paf
                                   where assignment_type = 'A'
                                   and   paf.person_id = p_person_id
                                  )
              );
       exception
         when no_data_found then NULL;
     end;
     end if;
  -- 3652025 >>
  if (p_applicant_number is NULL) then
     begin
     select applicant_number into p_applicant_number
       from per_people_f
      where person_id = p_person_id
        and applicant_number is not null
        and rownum = 1;
     exception
       when others then p_applicant_number := NULL;
     end;
     if g_debug then
        hr_utility.set_location('hr_person.generate_number',15);
     end if;
     apl_number_sv := p_applicant_number;
  end if;
  -- <<
  if (p_applicant_number is NULL) then
  --
  -- -> #2660279: NEW code
     Get_Person_Number(p_person_type       => 'APL'
                      ,p_person_number     => p_applicant_number
                      ,p_business_group_id => p_business_group_id
                      ,p_person_id         => p_person_id
                      ,p_effective_date    => p_effective_date
                      ,p_party_id          => p_party_id
                      ,p_date_of_birth     => p_date_of_birth
                      ,p_start_date         => p_start_date
                      ,p_national_id       => p_national_identifier);
  --
  -- <- end NEW code
  -- ------------------------------------------------------------+
  -- this code gets replaced with a call to Get_Person_Number    |
  -- ------------------------------------------------------------+
  --   SELECT next_value
  -- ,      rowid
  -- INTO   p_applicant_number
  -- ,      l_rowid
  -- FROM   per_number_generation_controls
  -- WHERE  business_group_id  +0 = p_business_group_id
  -- AND    type              = 'APL'
  -- FOR UPDATE OF next_value ;
  --
  -- UPDATE per_number_generation_controls
  -- SET    next_value = next_value + 1
  -- WHERE  rowid      = l_rowid ;
  -- ------------------------------------------------------------+

   if g_debug then
      hr_utility.set_location('hr_person.generate_number',20);
   end if;
   apl_number_sv := p_applicant_number;

  end if;
  --
  elsif l_method_of_generation = 'N'
      and ((p_applicant_number IS NULL)
           or (p_national_identifier is null)
           or (p_national_identifier is not null
               and p_applicant_number <> p_national_identifier)
          )
  then
    if p_national_identifier is null then
        if l_legislation_code = 'US' then
	hr_utility.set_message(801,'HR_7580_ALL_MAN_SOL_FIELD');
	else
        hr_utility.set_message(801,'HR_7578_ALL_MAN_NAT_FIELD');
	end if;
        hr_utility.raise_error;
    elsif p_applicant_number is null then  -- bug2986823
            p_applicant_number := p_national_identifier ;
    end if;
  elsif l_method_of_generation = 'M'
      and  p_applicant_number IS NULL then
        hr_utility.set_message(801,'HR_7579_ALL_MAN_APP_FIELD');
        hr_utility.raise_error;
  end if;
  --
end if;
if p_current_employee = 'Y' then
  --
 if g_debug then
  hr_utility.set_location('hr_person.generate_number',4);
 end if;
  SELECT pbg.method_of_generation_emp_num
  ,      pbg.legislation_code
  INTO   l_method_of_generation
  ,      l_legislation_code
  FROM   per_business_groups pbg
  WHERE  pbg.business_group_id  = p_business_group_id;
  --
  if l_method_of_generation = 'A' then
 if g_debug then
   hr_utility.set_location('hr_person.generate_number',5);
 end if;
   if p_employee_number is NOT NULL then
     begin
       select person_id
       into   l_person_id
       from   per_people_f ppf
       where  ppf.employee_number = p_employee_number
           and ppf.business_group_id  +0 = p_business_group_id
           and rownum = 1;

       if (l_person_id = p_person_id) then
           emp_number_sv := 0;
       else
           p_employee_number := NULL;
       end if;
       exception
         when no_data_found then
          if p_employee_number = emp_number_sv then
             p_employee_number := NULL;
          else
             emp_number_sv := 0;
          end if;
     end;
   end if;

-- Second check
   if p_employee_number is NOT NULL then
     begin
       select null
       into   p_employee_number
       from   sys.dual
       where  (p_person_id is not null
                   and not exists (select '1'
                                   from per_assignments_f paf
                                   where assignment_type = 'E'
                                   and   paf.person_id = p_person_id
                                  )
              );
       exception
         when no_data_found then NULL;
     end;
   end if;

   if p_employee_number IS NULL then
   --
   -- Special case for SSHR if the profile is set
   -- as we need to make sure that the generation controls table is not
   -- locked.
   --
   if fnd_profile.value('PER_SSHR_NO_EMPNUM_GENERATION') = 'Y' then
     return;
   end if;
   --
   -- -> #2660279: NEW code
     Get_Person_Number(p_person_type       => 'EMP'
                      ,p_person_number     => p_employee_number
                      ,p_business_group_id => p_business_group_id
                      ,p_person_id         => p_person_id
                      ,p_effective_date    => p_effective_date
                      ,p_party_id          => p_party_id
                      ,p_date_of_birth     => p_date_of_birth
                      ,p_start_date        => p_start_date
                      ,p_national_id       => p_national_identifier);
  --
  -- <- end NEW code
  -- ------------------------------------------------------------+
  -- this code gets replaced with a call to Get_Person_Number    |
  -- ------------------------------------------------------------+
  --   SELECT next_value
  -- ,      rowid
  -- INTO   p_employee_number
  -- ,      l_rowid
  -- FROM   per_number_generation_controls
  -- WHERE  business_group_id  +0 = p_business_group_id
  -- AND    type              = 'EMP'
  -- FOR UPDATE OF next_value ;
  --
  -- UPDATE per_number_generation_controls
  -- SET    next_value = next_value + 1
  -- WHERE  rowid      = l_rowid ;
  -- ------------------------------------------------------------+

 if g_debug then
   hr_utility.set_location('hr_person.generate_number',6);
 end if;
   emp_number_sv := p_employee_number;

   end if;
  --
  elsif l_method_of_generation = 'N'
      and ((p_employee_number IS NULL)
           or (p_national_identifier is null)
           or (p_national_identifier is not null
               and p_employee_number <> p_national_identifier)
          )
  then
    if p_national_identifier is null then
      if l_legislation_code = 'US' then
          hr_utility.set_message(801,'HR_7580_ALL_MAN_SOL_FIELD');
        else
          hr_utility.set_message(801,'HR_7578_ALL_MAN_NAT_FIELD');
      end if;
        hr_utility.raise_error;
    elsif p_employee_number is null then -- bug#2986823
        p_employee_number := p_national_identifier ;
    end if;
  elsif l_method_of_generation = 'M'
      and p_employee_number IS NULL then
        hr_utility.set_message(801,'HR_7581_ALL_MAN_EMP');
        hr_utility.raise_error;
  end if;
  --
end if;
if p_current_npw = 'Y' then
  --
 if g_debug then
  hr_utility.set_location('hr_person.generate_number',10);
 end if;
  SELECT pbg.method_of_generation_cwk_num
  ,      pbg.method_of_generation_emp_num
  ,      pbg.legislation_code
  INTO   l_method_of_generation
  ,      l_method_of_gen_emp
  ,      l_legislation_code
  FROM   per_business_groups pbg
  WHERE  pbg.business_group_id  = p_business_group_id;
  --
  if l_method_of_generation = 'A'
  or (l_method_of_generation = 'E' and
      l_method_of_gen_emp = 'A') then
 if g_debug then
   hr_utility.set_location('hr_person.generate_number',15);
 end if;
   if p_npw_number is NOT NULL then
     begin
       select person_id
       into   l_person_id
       from   per_people_f ppf
       where  ppf.npw_number = p_npw_number
           and ppf.business_group_id  +0 = p_business_group_id
           and rownum = 1;

       if (l_person_id = p_person_id) then
           npw_number_sv := 0;
       else
           p_npw_number := NULL;
       end if;
       exception
         when no_data_found then
          if p_npw_number = npw_number_sv then
             p_npw_number := NULL;
          else
             npw_number_sv := 0;
          end if;
     end;
   end if;

-- Second check
   if p_npw_number is NOT NULL then
 if g_debug then
    hr_utility.set_location('hr_person.generate_number',20);
 end if;
     begin
       select null
       into   p_npw_number
       from   sys.dual
       where  (p_person_id is not null
                   and not exists (select '1'
                                   from per_assignments_f paf
                                   where assignment_type = 'C'
                                   and   paf.person_id = p_person_id
                                  )
              );
       exception
         when no_data_found then NULL;
     end;
   end if;

   if p_npw_number IS NULL then
 if g_debug then
   hr_utility.set_location('hr_person.generate_number',25);
 end if;

     if l_method_of_generation = 'A' then
       --
       -- Automatic numbering so use the CWK number type.
       --
 if g_debug then
       hr_utility.set_location('hr_person.generate_number',27);
 end if;
   -- -> #2660279: NEW code
     Get_Person_Number(p_person_type       => 'CWK'
                      ,p_person_number     => p_npw_number
                      ,p_business_group_id => p_business_group_id
                      ,p_person_id         => p_person_id
                      ,p_effective_date    => p_effective_date
                      ,p_party_id          => p_party_id
                      ,p_date_of_birth     => p_date_of_birth
                      ,p_start_date        => p_start_date
                      ,p_national_id       => p_national_identifier);
  -- <- end NEW code
  -- ------------------------------------------------------------+
  -- this code gets replaced with a call to Get_Person_Number    |
  -- ------------------------------------------------------------+
  --   SELECT next_value
  -- ,      rowid
  -- INTO   p_npw_number
  -- ,      l_rowid
  -- FROM   per_number_generation_controls
  -- WHERE  business_group_id = p_business_group_id
  -- AND    type              = 'CWK'
  -- FOR UPDATE OF next_value ;
  --
  -- UPDATE per_number_generation_controls
  -- SET    next_value = next_value + 1
  -- WHERE  rowid      = l_rowid ;
  -- ------------------------------------------------------------+
  --
     elsif l_method_of_generation = 'E'
     and   l_method_of_gen_emp = 'A' then
       --
       -- This is based on emp numbering which is automatic.
       -- Use the next employee number sequence instead of the
       -- CWK type.
       --
 if g_debug then
       hr_utility.set_location('hr_person.generate_number',28);
 end if;
    -- -> #2660279: NEW code
     Get_Person_Number(p_person_type       => 'EMP'
                      ,p_person_number     => p_npw_number
                      ,p_business_group_id => p_business_group_id
                      ,p_person_id         => p_person_id
                      ,p_effective_date    => p_effective_date
                      ,p_party_id          => p_party_id
                      ,p_date_of_birth     => p_date_of_birth
                      ,p_start_date        => p_start_date
                      ,p_national_id       => p_national_identifier);
  --
  -- <- end NEW code
  -- ------------------------------------------------------------+
  -- this code gets replaced with a call to Get_Person_Number    |
  -- ------------------------------------------------------------+
  --   SELECT next_value
  -- ,      rowid
  -- INTO   p_npw_number
  -- ,      l_rowid
  -- FROM   per_number_generation_controls
  -- WHERE  business_group_id = p_business_group_id
  -- AND    type              = 'EMP'
  -- FOR UPDATE OF next_value ;
  --
  -- UPDATE per_number_generation_controls
  -- SET    next_value = next_value + 1
  -- WHERE  rowid      = l_rowid ;
  -- ------------------------------------------------------------+

     end if;

 if g_debug then
   hr_utility.set_location('hr_person.generate_number',29);
 end if;
   npw_number_sv := p_npw_number;

   end if;
  --
  elsif (l_method_of_generation = 'N'
     or (l_method_of_generation = 'E' and
         l_method_of_gen_emp = 'N'))
      and ((p_npw_number IS NULL)
           or (p_national_identifier is null)
           or (p_national_identifier is not null
               and p_npw_number <> p_national_identifier)
          )
  then
 if g_debug then
  hr_utility.set_location('hr_person.generate_number',30);
 end if;
    if p_national_identifier is null then
      if l_legislation_code = 'US' then
        hr_utility.set_message(801,'HR_7580_ALL_MAN_SOL_FIELD');
        else
        hr_utility.set_message(801,'HR_7578_ALL_MAN_NAT_FIELD');
      end if;
        hr_utility.raise_error;
    elsif p_npw_number is null then -- bug#2986823
        p_npw_number := p_national_identifier ;
    end if;
  elsif(l_method_of_generation = 'M'
  or   (l_method_of_generation = 'E' and
        l_method_of_gen_emp = 'M'))
      and p_npw_number IS NULL then
 if g_debug then
   hr_utility.set_location('hr_person.generate_number',35);
 end if;
       -- Changed the application id form 801 to 800 for fix of #3295346
        hr_utility.set_message(800,'HR_289692_ALL_MAN_CWK');
        hr_utility.raise_error;
  end if;
  --
end if;
--
-- Fix for bug 3529732 starts here. Commented the following block.
-- If the person is not current employee or applicant or CWK
-- then pass the same values back to the calling proc.
--
/*
if p_current_employee IS NULL
     and p_current_applicant IS NULL
     and p_current_npw IS NULL then
    begin
      select p.employee_number
      ,      p.applicant_number
      ,      p.npw_number
      into   p_employee_number
      ,      p_applicant_number
      ,      p_npw_number
      from   per_people p
      where p.person_id = p_person_id;
      --
      exception
        when no_data_found then
          p_applicant_number   := null ;
          p_employee_number    := null ;
          p_npw_number         := null ;
        when others then
          raise;
   end;
  --
end if;
*/
--
-- Fix for bug 3529732 ends here.
--
end generate_number ;
--
-- -------------------------- derive_full_name  ---------------------------
-- Construct FULL_NAME based on all name fields and if this name and date of
-- birth combination already exists (upper or lower case) then write an error
-- but DO NOT FAIL the procedure. Full Name may still be required as forms
-- treats this as a warning not an error
--
PROCEDURE derive_full_name
(p_first_name    VARCHAR2,
 p_middle_names  VARCHAR2,
 p_last_name     VARCHAR2,
 p_known_as      VARCHAR2,
 p_title         VARCHAR2,
 p_suffix        VARCHAR2,
 p_pre_name_adjunct VARCHAR2,
 p_date_of_birth DATE,
 p_person_id         NUMBER,
 p_business_group_id NUMBER,
 p_full_name OUT NOCOPY VARCHAR2 ,
 p_duplicate_flag OUT NOCOPY VARCHAR2,
 p_per_information1 VARCHAR2 DEFAULT NULL,
 p_per_information2 VARCHAR2 DEFAULT NULL,
 p_per_information3 VARCHAR2 DEFAULT NULL,
 p_per_information4 VARCHAR2 DEFAULT NULL,
 p_per_information5 VARCHAR2 DEFAULT NULL,
 p_per_information6 VARCHAR2 DEFAULT NULL,
 p_per_information7 VARCHAR2 DEFAULT NULL,
 p_per_information8 VARCHAR2 DEFAULT NULL,
 p_per_information9 VARCHAR2 DEFAULT NULL,
 p_per_information10 VARCHAR2 DEFAULT NULL,
 p_per_information11 VARCHAR2 DEFAULT NULL,
 p_per_information12 VARCHAR2 DEFAULT NULL,
 p_per_information13 VARCHAR2 DEFAULT NULL,
 p_per_information14 VARCHAR2 DEFAULT NULL,
 p_per_information15 VARCHAR2 DEFAULT NULL,
 p_per_information16 VARCHAR2 DEFAULT NULL,
 p_per_information17 VARCHAR2 DEFAULT NULL,
 p_per_information18 VARCHAR2 DEFAULT NULL,
 p_per_information19 VARCHAR2 DEFAULT NULL,
 p_per_information20 VARCHAR2 DEFAULT NULL,
 p_per_information21 VARCHAR2 DEFAULT NULL,
 p_per_information22 VARCHAR2 DEFAULT NULL,
 p_per_information23 VARCHAR2 DEFAULT NULL,
 p_per_information24 VARCHAR2 DEFAULT NULL,
 p_per_information25 VARCHAR2 DEFAULT NULL,
 p_per_information26 VARCHAR2 DEFAULT NULL,
 p_per_information27 VARCHAR2 DEFAULT NULL,
 p_per_information28 VARCHAR2 DEFAULT NULL,
 p_per_information29 VARCHAR2 DEFAULT NULL,
 p_per_information30 VARCHAR2 DEFAULT NULL)
 IS
--
--

  -- These definitions are used to allow the check for duplicate names
  -- to be case insensitive whilst still using the index. This technique
  -- is used by forms for items with the case insensitive query option.
  --
  -- Example taken from Forms reference manual
  -- In order to search for names like 'Blake'
  --
  --  SELECT * FROM EMP
  --  WHERE UPPER(ENAME) = 'BLAKE'
  --  AND ( ENAME LIKE 'Bl%' OR ENAME LIKE 'bL%' OR
  --        ENAME LIKE 'BL%' OR ENAME LIKE 'bl%' ) ;
  --
  -- VT 1159810 01/26/00
  l_first_char  VARCHAR2(5) := substr( p_last_name , 1 , 1 ) ;
  l_second_char VARCHAR2(5) := substr( p_last_name , 2 , 1 ) ;
  l_ul_check    VARCHAR2(15) := upper(l_first_char)||lower(l_second_char)||'%';
  l_lu_check    VARCHAR2(15) := lower(l_first_char)||upper(l_second_char)||'%';
  l_uu_check    VARCHAR2(15) := upper(l_first_char)||upper(l_second_char)||'%';
  l_ll_check    VARCHAR2(15) := lower(l_first_char)||lower(l_second_char)||'%';
  --
  --
  --
  l_full_name   VARCHAR2(240);
  l_status      VARCHAR2(1);
  l_title_meaning  VARCHAR2(80);
--
  local_warning exception;

--
 cursor csr_leg_pkg(p_pkg VARCHAR2) IS
     select '1'
     from user_objects
     where object_name = p_pkg
     and object_type = 'PACKAGE';

 cursor csr_leg_cod is
  select legislation_code
  from per_business_groups_perf -- #3907786 - Changed to per_business_groups_perf
  where business_group_id =  p_business_group_id;

l_leg_code VARCHAR2(150);
-- l_cursor NUMBER;
l_dummy VARCHAR2(1);
l_procedure_name VARCHAR2(50);
l_proc_call VARCHAR2(4790);
l_package_name VARCHAR2(50);
v_fullname VARCHAR2(240);
--
begin
--
p_duplicate_flag:='N';
  --

 if g_debug then
    hr_utility.set_location('hr_person.derive_full_name',1);
 end if;

    if p_title IS NOT NULL and
      fnd_profile.value('PER_USE_TITLE_IN_FULL_NAME') = 'Y' then
      SELECT meaning
      INTO   l_title_meaning
      FROM   hr_lookups
      WHERE  lookup_type = 'TITLE'
      AND    p_title     = lookup_code;
    end if;

 if g_debug then
    hr_utility.set_location('l_title_meaning = '||l_title_meaning,4);
 end if;
--
--
-- Note this is only a select because PL/SQL can't cope with DECODEs
--
 if g_debug then
  hr_utility.set_location('hr_person.derive_full_name',2);
 end if;
  SELECT rtrim(substrb(DECODE(p_pre_name_adjunct,'','',p_pre_name_adjunct||' ')||
                      p_last_name||','||DECODE(l_title_meaning,'','',
                      ' '||l_title_meaning)||DECODE(p_first_name,'','',
                      ' '||p_first_name)||DECODE(p_middle_names,'','',
                      ' '||p_middle_names)||
                      DECODE(p_suffix,'','',' '||p_suffix)||
                      DECODE(p_known_as,'','',
                      ' ('||p_known_as||')'),1,240))
  INTO  l_full_name
  FROM sys.dual ;
--
-- Performing rtrim to remove any blank spaces from the full name, see bug 2042825 for details
--
p_full_name := rtrim(l_full_name);
--
 if g_debug then
hr_utility.set_location('hr_person.derive_full_name',4);
 end if;
  open csr_leg_cod;
  fetch csr_leg_cod into l_leg_code;
if csr_leg_cod%found then

-- Start of bug # 2459815
-- check for installed legislation
-- added the or condition for the fix of #3291084
  if ( hr_utility.chk_product_install('Oracle Human Resources',l_leg_code) or (l_leg_code = 'JP')) then
-- if a legislation exits then we must call the function
-- hr_XX_utility.per_XX_full_name which derives the full name
-- according to the legislation.

    l_package_name := 'HR_'||l_leg_code||'_UTILITY';
    l_procedure_name := 'per_'||lower(l_leg_code)||'_full_name';


-- check package exists
   open csr_leg_pkg(l_package_name);
   fetch csr_leg_pkg into l_dummy;
 if csr_leg_pkg%found then
/*
  #1858645 replaced dbms_sql with native dynamic sql call
      l_cursor := dbms_sql.open_cursor;
*/

  -- construct an anonymous block with bind variable

l_proc_call := 'SELECT rtrim(substrb( '|| l_package_name ||'.'||l_procedure_name||'(:p_first_name,:p_middle_names,:p_last_name,:p_known_as,:p_title,';

l_proc_call := l_proc_call||':p_suffix,:p_pre_name_adjunct,:p_per_information1,:p_per_information2,:p_per_information3,:p_per_information4,:p_per_information5,';

l_proc_call := l_proc_call||':p_per_information6,:p_per_information7,:p_per_information8,:p_per_information9,:p_per_information10,';

l_proc_call := l_proc_call||':p_per_information11,:p_per_information12,:p_per_information13,:p_per_information14,:p_per_information15,:p_per_information16,:p_per_information17,';

l_proc_call := l_proc_call||':p_per_information18,:p_per_information19,:p_per_information20,:p_per_information21,:p_per_information22,:p_per_information23,:p_per_information24,';

l_proc_call := l_proc_call||':p_per_information25,:p_per_information26,:p_per_information27,:p_per_information28,:p_per_information29,:p_per_information30),1,240)) FROM sys.dual ';

/*  #1858645 replaced dbms_sql with native dynamic sql call

  -- Parse the statment

  dbms_sql.parse(l_cursor, l_proc_call, dbms_sql.V7);

  -- Bind input variables
  dbms_sql.bind_variable(l_cursor,':p_first_name',p_first_name);
  dbms_sql.bind_variable(l_cursor,':p_middle_names',p_middle_names);
  dbms_sql.bind_variable(l_cursor,':p_last_name',p_last_name);
  dbms_sql.bind_variable(l_cursor,':p_known_as',p_known_as);
  dbms_sql.bind_variable(l_cursor,':p_title',p_title);
  dbms_sql.bind_variable(l_cursor,':p_suffix',p_suffix);
  dbms_sql.bind_variable(l_cursor,':p_pre_name_adjunct',p_pre_name_adjunct);
  dbms_sql.bind_variable(l_cursor,':p_per_information1',p_per_information1);
  dbms_sql.bind_variable(l_cursor,':p_per_information2',p_per_information2);
  dbms_sql.bind_variable(l_cursor,':p_per_information3',p_per_information3);
  dbms_sql.bind_variable(l_cursor,':p_per_information4',p_per_information4);
  dbms_sql.bind_variable(l_cursor,':p_per_information5',p_per_information5);
  dbms_sql.bind_variable(l_cursor,':p_per_information6',p_per_information6);
  dbms_sql.bind_variable(l_cursor,':p_per_information7',p_per_information7);
  dbms_sql.bind_variable(l_cursor,':p_per_information8',p_per_information8);
  dbms_sql.bind_variable(l_cursor,':p_per_information9',p_per_information9);
  dbms_sql.bind_variable(l_cursor,':p_per_information10',p_per_information10);
  dbms_sql.bind_variable(l_cursor,':p_per_information11',p_per_information11);
  dbms_sql.bind_variable(l_cursor,':p_per_information12',p_per_information12);
  dbms_sql.bind_variable(l_cursor,':p_per_information13',p_per_information13);
  dbms_sql.bind_variable(l_cursor,':p_per_information14',p_per_information14);
  dbms_sql.bind_variable(l_cursor,':p_per_information15',p_per_information15);
  dbms_sql.bind_variable(l_cursor,':p_per_information16',p_per_information16);
  dbms_sql.bind_variable(l_cursor,':p_per_information17',p_per_information17);
  dbms_sql.bind_variable(l_cursor,':p_per_information18',p_per_information18);
  dbms_sql.bind_variable(l_cursor,':p_per_information19',p_per_information19);
  dbms_sql.bind_variable(l_cursor,':p_per_information20',p_per_information20);
  dbms_sql.bind_variable(l_cursor,':p_per_information21',p_per_information21);
  dbms_sql.bind_variable(l_cursor,':p_per_information22',p_per_information22);
  dbms_sql.bind_variable(l_cursor,':p_per_information23',p_per_information23);
  dbms_sql.bind_variable(l_cursor,':p_per_information24',p_per_information24);
  dbms_sql.bind_variable(l_cursor,':p_per_information27',p_per_information27);
  dbms_sql.bind_variable(l_cursor,':p_per_information28',p_per_information28);
  dbms_sql.bind_variable(l_cursor,':p_per_information29',p_per_information29);
  dbms_sql.bind_variable(l_cursor,':p_per_information30',p_per_information30);

 -- Define the Ouput Variables
  dbms_sql.define_column(l_cursor,1,v_fullname,240);

  -- Execute the statement
  l_dummy := dbms_sql.execute(l_cursor);

   -- fetch loop
  LOOP

    IF DBMS_SQL.FETCH_ROWS(l_cursor) = 0 THEN
        EXIT;
    END IF;

    DBMS_SQL.COLUMN_VALUE(l_cursor,1,v_fullname);
  END LOOP;


    native dynamic sql
*/
  EXECUTE IMMEDIATE l_proc_call
  INTO v_fullname
  USING  p_first_name
        ,p_middle_names
        ,p_last_name
        ,p_known_as
        ,p_title
        ,p_suffix
        ,p_pre_name_adjunct
        ,p_per_information1
        ,p_per_information2
        ,p_per_information3
        ,p_per_information4
        ,p_per_information5
        ,p_per_information6
        ,p_per_information7
        ,p_per_information8
        ,p_per_information9
        ,p_per_information10
        ,p_per_information11
        ,p_per_information12
        ,p_per_information13
        ,p_per_information14
        ,p_per_information15
        ,p_per_information16
        ,p_per_information17
        ,p_per_information18
        ,p_per_information19
        ,p_per_information20
        ,p_per_information21
        ,p_per_information22
        ,p_per_information23
        ,p_per_information24
        ,p_per_information25
        ,p_per_information26
        ,p_per_information27
        ,p_per_information28
        ,p_per_information29
        ,p_per_information30;


   p_full_name := rtrim(v_fullname);
  end if;
  --
  -- Code inserted for Bug 1654922
  --
  close csr_leg_pkg;
  --
  -- End of insert for Bug 1654922
  --
  end if; -- end of bug #2459815
end if;
--
-- Code inserted for Bug 1654922
--
close csr_leg_cod;
--
-- End of insert for Bug 1654922
--

--
-- Bug 2040730
-- When Cross Business Groups is enabled, new global duplicate checking is
-- carried out, so don't need to repeat check here
--
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
   begin
    --
 if g_debug then
    hr_utility.set_location('hr_person.derive_full_name',3);
 end if;
    SELECT 'Y'
    INTO   l_status
    FROM   sys.dual
    WHERE  EXISTS (SELECT 'Duplicate Person Exists'
    FROM   per_all_people_f pp
    WHERE  /* Perform case insensitive check on last name */
           /* trying to use the index on last name        */
           upper(pp.last_name)  = upper(p_last_name)
    AND   (    pp.last_name like l_ul_check
            OR pp.last_name like l_lu_check
            OR pp.last_name like l_uu_check
            OR pp.last_name like l_ll_check
          )
    AND   (upper(pp.first_name) = upper(p_first_name)
           OR p_first_name IS NULL
           OR pp.first_name IS NULL)
    AND   (pp.date_of_birth = p_date_of_birth
           OR p_date_of_birth IS NULL
           OR pp.date_of_birth IS NULL)
    AND   ((p_person_id IS NOT NULL
        AND p_person_id <> pp.person_id)
         OR p_person_id IS NULL)
    AND    pp.business_group_id  +0 = p_business_group_id);
    --
    hr_utility.set_message(801,'HR_PERSON_DUPLICATE');

    raise local_warning;

   --
   exception
    when NO_DATA_FOUND then null ;
   --
   end;
  end if;
--
--
exception
  when local_warning then
    hr_utility.set_warning;
    p_duplicate_flag:='Y';
 -- #3907786 start
  when others then
    if csr_leg_cod%isopen then
     close csr_leg_cod;
    end if;
    raise;
 -- #3907786 end
--
end derive_full_name;
--
PROCEDURE derive_full_name
(p_first_name    VARCHAR2,
 p_middle_names  VARCHAR2,
 p_last_name     VARCHAR2,
 p_known_as      VARCHAR2,
 p_title         VARCHAR2,
 p_suffix        VARCHAR2,
 p_date_of_birth DATE,
 p_person_id         NUMBER,
 p_business_group_id NUMBER,
 p_full_name OUT NOCOPY VARCHAR2 ,
 p_duplicate_flag OUT NOCOPY VARCHAR2,
 p_per_information1 VARCHAR2 DEFAULT NULL,
 p_per_information2 VARCHAR2 DEFAULT NULL,
 p_per_information3 VARCHAR2 DEFAULT NULL,
 p_per_information4 VARCHAR2 DEFAULT NULL,
 p_per_information5 VARCHAR2 DEFAULT NULL,
 p_per_information6 VARCHAR2 DEFAULT NULL,
 p_per_information7 VARCHAR2 DEFAULT NULL,
 p_per_information8 VARCHAR2 DEFAULT NULL,
 p_per_information9 VARCHAR2 DEFAULT NULL,
 p_per_information10 VARCHAR2 DEFAULT NULL,
 p_per_information11 VARCHAR2 DEFAULT NULL,
 p_per_information12 VARCHAR2 DEFAULT NULL,
 p_per_information13 VARCHAR2 DEFAULT NULL,
 p_per_information14 VARCHAR2 DEFAULT NULL,
 p_per_information15 VARCHAR2 DEFAULT NULL,
 p_per_information16 VARCHAR2 DEFAULT NULL,
 p_per_information17 VARCHAR2 DEFAULT NULL,
 p_per_information18 VARCHAR2 DEFAULT NULL,
 p_per_information19 VARCHAR2 DEFAULT NULL,
 p_per_information20 VARCHAR2 DEFAULT NULL,
 p_per_information21 VARCHAR2 DEFAULT NULL,
 p_per_information22 VARCHAR2 DEFAULT NULL,
 p_per_information23 VARCHAR2 DEFAULT NULL,
 p_per_information24 VARCHAR2 DEFAULT NULL,
 p_per_information25 VARCHAR2 DEFAULT NULL,
 p_per_information26 VARCHAR2 DEFAULT NULL,
 p_per_information27 VARCHAR2 DEFAULT NULL,
 p_per_information28 VARCHAR2 DEFAULT NULL,
 p_per_information29 VARCHAR2 DEFAULT NULL,
 p_per_information30 VARCHAR2 DEFAULT NULL) is
l_pre_name_adjunct VARCHAR2(30);
begin
  hr_person.derive_full_name(
 p_first_name =>p_first_name
,p_middle_names =>p_middle_names
,p_last_name =>p_last_name
,p_known_as =>p_known_as
,p_title =>p_title
,p_suffix =>p_suffix
,p_pre_name_adjunct =>l_pre_name_adjunct
,p_date_of_birth =>p_date_of_birth
,p_person_id => p_person_id
,p_business_group_id => p_business_group_id
,p_full_name => p_full_name
,p_duplicate_flag =>p_duplicate_flag
,p_per_information1 => p_per_information1
, p_per_information2 => p_per_information2
,p_per_information3 => p_per_information3
,p_per_information4 => p_per_information4
,p_per_information5 => p_per_information5
,p_per_information6 => p_per_information6
,p_per_information7 =>p_per_information7
,p_per_information8 => p_per_information8
,p_per_information9 => p_per_information9
,p_per_information10 => p_per_information10
,p_per_information11 => p_per_information11
,p_per_information12 => p_per_information12
,p_per_information13 => p_per_information13
,p_per_information14 => p_per_information14
,p_per_information15 => p_per_information15
,p_per_information16 => p_per_information16
,p_per_information17 => p_per_information17
,p_per_information18 => p_per_information18
,p_per_information19 => p_per_information19
,p_per_information20 => p_per_information20
,p_per_information21 => p_per_information21
,p_per_information22 => p_per_information22
,p_per_information23 => p_per_information23
,p_per_information24 => p_per_information24
,p_per_information25 => p_per_information25
,p_per_information26 => p_per_information26
,p_per_information27 => p_per_information27
,p_per_information28 => p_per_information28
,p_per_information29 => p_per_information29
,p_per_information30 => p_per_information30);
end;
--
PROCEDURE derive_full_name
(p_first_name    VARCHAR2,
 p_middle_names  VARCHAR2,
 p_last_name     VARCHAR2,
 p_known_as      VARCHAR2,
 p_title         VARCHAR2,
 p_date_of_birth DATE,
 p_person_id         NUMBER,
 p_business_group_id NUMBER,
 p_full_name OUT NOCOPY VARCHAR2 ,
 p_duplicate_flag OUT NOCOPY VARCHAR2,
 p_per_information1 VARCHAR2 DEFAULT NULL,
 p_per_information2 VARCHAR2 DEFAULT NULL,
 p_per_information3 VARCHAR2 DEFAULT NULL,
 p_per_information4 VARCHAR2 DEFAULT NULL,
 p_per_information5 VARCHAR2 DEFAULT NULL,
 p_per_information6 VARCHAR2 DEFAULT NULL,
 p_per_information7 VARCHAR2 DEFAULT NULL,
 p_per_information8 VARCHAR2 DEFAULT NULL,
 p_per_information9 VARCHAR2 DEFAULT NULL,
 p_per_information10 VARCHAR2 DEFAULT NULL,
 p_per_information11 VARCHAR2 DEFAULT NULL,
 p_per_information12 VARCHAR2 DEFAULT NULL,
 p_per_information13 VARCHAR2 DEFAULT NULL,
 p_per_information14 VARCHAR2 DEFAULT NULL,
 p_per_information15 VARCHAR2 DEFAULT NULL,
 p_per_information16 VARCHAR2 DEFAULT NULL,
 p_per_information17 VARCHAR2 DEFAULT NULL,
 p_per_information18 VARCHAR2 DEFAULT NULL,
 p_per_information19 VARCHAR2 DEFAULT NULL,
 p_per_information20 VARCHAR2 DEFAULT NULL,
 p_per_information21 VARCHAR2 DEFAULT NULL,
 p_per_information22 VARCHAR2 DEFAULT NULL,
 p_per_information23 VARCHAR2 DEFAULT NULL,
 p_per_information24 VARCHAR2 DEFAULT NULL,
 p_per_information25 VARCHAR2 DEFAULT NULL,
 p_per_information26 VARCHAR2 DEFAULT NULL,
 p_per_information27 VARCHAR2 DEFAULT NULL,
 p_per_information28 VARCHAR2 DEFAULT NULL,
 p_per_information29 VARCHAR2 DEFAULT NULL,
 p_per_information30 VARCHAR2 DEFAULT NULL) is
l_suffix VARCHAR2(30);
l_pre_name_adjunct VARCHAR2(30);
begin
  hr_person.derive_full_name(
 p_first_name =>p_first_name
,p_middle_names =>p_middle_names
,p_last_name =>p_last_name
,p_known_as =>p_known_as
,p_title =>p_title
,p_suffix =>l_suffix
,p_pre_name_adjunct =>l_pre_name_adjunct
,p_date_of_birth =>p_date_of_birth
,p_person_id => p_person_id
,p_business_group_id => p_business_group_id
,p_full_name => p_full_name
,p_duplicate_flag =>p_duplicate_flag
,p_per_information1 => p_per_information1
, p_per_information2 => p_per_information2
,p_per_information3 => p_per_information3
,p_per_information4 => p_per_information4
,p_per_information5 => p_per_information5
,p_per_information6 => p_per_information6
,p_per_information7 =>p_per_information7
,p_per_information8 => p_per_information8
,p_per_information9 => p_per_information9
,p_per_information10 => p_per_information10
,p_per_information11 => p_per_information11
,p_per_information12 => p_per_information12
,p_per_information13 => p_per_information13
,p_per_information14 => p_per_information14
,p_per_information15 => p_per_information15
,p_per_information16 => p_per_information16
,p_per_information17 => p_per_information17
,p_per_information18 => p_per_information18
,p_per_information19 => p_per_information19
,p_per_information20 => p_per_information20
,p_per_information21 => p_per_information21
,p_per_information22 => p_per_information22
,p_per_information23 => p_per_information23
,p_per_information24 => p_per_information24
,p_per_information25 => p_per_information25
,p_per_information26 => p_per_information26
,p_per_information27 => p_per_information27
,p_per_information28 => p_per_information28
,p_per_information29 => p_per_information29
,p_per_information30 => p_per_information30 );
end;

--
-- ------------------- check_ni_unique --------------------
procedure check_ni_unique
( p_national_identifier VARCHAR2,
  p_person_id           NUMBER,
  p_business_group_id   NUMBER)
--
is
--
  l_status            VARCHAR2(1);
  l_legislation_code  VARCHAR2(30);
--
  local_warning exception;
--
begin
 if g_debug then
  hr_utility.set_location('hr_person.validate_national_identifier',1);
 end if;
  SELECT org_information9
  INTO   l_legislation_code
  FROM   hr_organization_information
  WHERE  org_information_context = 'Business Group Information'
  AND    organization_id         = p_business_group_id;
--
--
--
  begin
  SELECT 'Y'
  INTO   l_status
  FROM   sys.dual
  WHERE  exists(SELECT '1'
		 FROM   per_all_people_f pp
		 WHERE (p_person_id IS NULL
		    OR  p_person_id <> pp.person_id)
		 AND    p_national_identifier = pp.national_identifier
		 AND    pp.business_group_id   +0 = p_business_group_id
                );
  --
  -- Note this should be printed out as a warning when called from the form
  -- but should be picked up as an error by HRLink
  --
  if l_legislation_code = 'US' then
      hr_utility.set_message(801,'HR_EMP_SS_EXISTS');
  elsif l_legislation_code = 'GB' then
      hr_utility.set_message(801,'HR_EMP_NI_EXISTS');
  -- psingla - If the legislation is Polish and profile PER_NI_UNIQUE_ERROR_WARNING is set to NULL
  elsif l_legislation_code = 'PL' and fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING') is NULL then -- For Poland
      null;
  else
      hr_utility.set_message(801,'HR_EMP_NAT_ID_EXISTS');
  end if;
 /* psingla - If the legislation is Polish and profile PER_NI_UNIQUE_ERROR_WARNING
              is set to NULL then only null statement to be executed.*/
  if l_legislation_code = 'PL' and fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING') is NULL then -- For Poland
      null;
  else
  raise local_warning;
  end if;
  --
  exception
   when no_data_found then null;
   when local_warning then
    raise;
  end;
  exception
   when NO_DATA_FOUND then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','CHECK_NI_UNIQUE');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   when local_warning then
     hr_utility.set_warning;
end check_ni_unique;
-- ------------------- validate_national_identifier -----------------------
--
-- Pass in national identifier and validate both construct (dependent on
-- the legislation of the business group) and uniqueness within business
-- group
--
PROCEDURE validate_national_identifier
( p_national_identifier VARCHAR2,
  p_person_id           NUMBER,
  p_business_group_id   NUMBER)
--
IS
--
  l_legislation_code  VARCHAR2(30);
--
begin
--
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_national_identifier',1);
 end if;
  SELECT org_information9
  INTO   l_legislation_code
  FROM   hr_organization_information
  WHERE  org_information_context = 'Business Group Information'
  AND    organization_id         = p_business_group_id;
--
--
  if  l_legislation_code = 'GB' then
    if    substr(p_national_identifier,1,1) >= 'A'
     AND  substr(p_national_identifier,1,1) <= 'Z'
     AND  substr(p_national_identifier,2,1) >= 'A'
     AND  substr(p_national_identifier,2,1) <= 'Z'
     AND  substr(p_national_identifier,3,1) >= '0'
     AND  substr(p_national_identifier,3,1) <= '9'
     AND  substr(p_national_identifier,4,1) >= '0'
     AND  substr(p_national_identifier,4,1) <= '9'
     AND  substr(p_national_identifier,5,1) >= '0'
     AND  substr(p_national_identifier,5,1) <= '9'
     AND  substr(p_national_identifier,6,1) >= '0'
     AND  substr(p_national_identifier,6,1) <= '9'
     AND  substr(p_national_identifier,7,1) >= '0'
     AND  substr(p_national_identifier,7,1) <= '9'
     AND  substr(p_national_identifier,8,1) >= '0'
     AND  substr(p_national_identifier,8,1) <= '9'
    AND ((substr(p_national_identifier,9,1) IN ('A','B','C','D')
     AND  substr(p_national_identifier,1,2) <> 'TN')
      OR (substr(p_national_identifier,9,1) IN ('M','F')
     AND  substr(p_national_identifier,1,2) = 'TN'))
     AND  length(p_national_identifier) = 9 then
    NULL ;
    else
    --Fix for bug2356249 start here.
     if nvl(fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION'),'ERROR') ='WARN' THEN
        hr_utility.set_warning;
     elsif nvl(fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION'),'ERROR') ='ERROR' then
        hr_utility.set_message(801,'HR_6522_EMP_INVALID_NI_NO');
	hr_utility.raise_error;
     end if;
     --Fix for bug2356249 ends here.
    end if;

 elsif l_legislation_code = 'US' then
--
-- Translate all possible values out of the string
-- and check for the correct placement of the delimiters
--
  if (translate(p_national_identifier,'A01234567890-','A') is null
    and substr(p_national_identifier,4,1) = '-'
    and substr(p_national_identifier,7,1) = '-')
    and length(p_national_identifier) = 11 then
   null;
  else
   --Fix for bug2356249 start here.
    if nvl(fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION'),'ERROR') ='WARN' THEN
       hr_utility.set_warning;
    elsif nvl(fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION'),'ERROR') ='ERROR' then
       hr_utility.set_message(801,'HR_7056_EMP_INVALID_SS_NO');
       hr_utility.raise_error;
    end if;
    --Fix for bug2356249 ends here.
  end if;
 end if;
exception
 when NO_DATA_FOUND then
 null;
--
--
end validate_national_identifier;
--
--
-- ----------------------- validate_dob ------------------------------------
--
-- Date of Birth must be greater than start date for employees and applicants
--
PROCEDURE validate_dob
(p_date_of_birth      DATE,
 p_start_date         DATE)
--
IS
--
begin
--
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_dob',1);
 end if;
     if p_date_of_birth > p_start_date
      then
     hr_utility.set_message(801,'HR_6523_PERSON_DOB_GT_START');
     hr_utility.raise_error;
     end if;
--
end validate_dob;
--
--
PROCEDURE validate_sex_and_title (p_current_employee VARCHAR2
                                , p_sex VARCHAR2
                                , p_title VARCHAR2)
IS
--
  local_warning  exception;
--
  begin
--
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_sex_and_title',1);
 end if;
  if p_current_employee = 'Y' then
   if p_sex  IS NULL then
      hr_utility.set_message(801,'HR_6524_EMP_MANDATORY_SEX');
      hr_utility.raise_error;
   end if;
  end if;
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_sex_and_title',2);
 end if;
  if p_sex IS NULL then
    hr_utility.set_message(801,'PAY_6361_USER_TABLE_UNIQUE');
    raise local_warning;
  elsif p_title IS NULL then
    hr_utility.set_message(801,'PAY_6361_USER_TABLE_UNIQUE');
    raise local_warning;
  elsif p_title = 'MR.' then
     if p_sex <> 'M' then
       hr_utility.set_message(801,'HR_6527_PERSON_SEX_AND_TITLE');
       hr_utility.raise_error;
     end if;
  elsif p_title IN ('MRS.','MS.','MISS') then
     if p_sex <> 'F' then
       hr_utility.set_message(801,'HR_6527_PERSON_SEX_AND_TITLE');
       hr_utility.raise_error;
     end if;
  end if;
--
exception
  when local_warning then
     hr_utility.set_warning;
--
end validate_sex_and_title;
--
-- --------------------------------------------------------------------- +
--                Validate_Unique_Number                                 +
-- --------------------------------------------------------------------- +
PROCEDURE validate_unique_number (p_person_id         NUMBER
                                , p_business_group_id NUMBER
                                , p_employee_number   VARCHAR2
                                , p_applicant_number  VARCHAR2
                                , p_npw_number        VARCHAR2
                                , p_current_employee  VARCHAR2
                                , p_current_applicant VARCHAR2
                                , p_current_npw       VARCHAR2)
IS
--
  l_status VARCHAR2(1);
--
begin
--
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_unique_number',1);
 end if;
 if p_current_applicant = 'Y'  then
   if p_applicant_number IS NULL then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','VALIDATE_UNIQUE_NUMBER');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
  --
 if g_debug then
  hr_utility.set_location('hr_person.validate_unique_number',2);
 end if;
 -- #2660279:
-- --> delete this code
--  SELECT 'Y'
--  INTO   l_status
--  FROM   sys.dual
--  WHERE  exists (SELECT 'Y'
--  FROM   per_all_people_f  pp
--  WHERE (p_person_id IS NULL
--     OR  p_person_id <> pp.person_id)
--  AND    pp.business_group_id  +0 = p_business_group_id
--  AND    pp.applicant_number  = p_applicant_number);
-- <- end delete
  -- >> new code
    if is_unique_person_number(p_person_id         => p_person_id
                              ,p_person_type       => 'APL'
                              ,p_person_number     => p_applicant_number
                              ,p_business_group_id => p_business_group_id
                              ) = 'N'
    then

       hr_utility.set_message(801,'HR_7693_PERSON_NUM_EXISTS');
       hr_utility.raise_error;
    end if;
  -- << End New code
--
 end if;
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_unique_number',3);
 end if;
  if p_current_employee = 'Y'  then
   if p_employee_number IS NULL then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','VALIDATE_UNIQUE_NUMBER');
     hr_utility.set_message_token('STEP','3');
     hr_utility.raise_error;
   end if;
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_unique_number',4);
 end if;
 -- #2660279: >> New code
    if is_unique_person_number(p_person_id         => p_person_id
                              ,p_person_type       => 'EMP'
                              ,p_person_number     => p_employee_number
                              ,p_business_group_id => p_business_group_id
                              ) = 'N'
    then

       hr_utility.set_message(801,'HR_7692_PERSON_NUM_EXIST');
       hr_utility.raise_error;
   end if;
  -- << end new code
  --

--    SELECT 'Y'
--    INTO   l_status
--    FROM   sys.dual
--    WHERE  exists (select 'Y'
--    FROM   per_all_people_f  pp
--    WHERE (p_person_id IS NULL
--       OR  p_person_id <> pp.person_id)
--    AND    pp.business_group_id = p_business_group_id
--    AND   (pp.employee_number   = p_employee_number
--       OR  (pp.npw_number       = p_employee_number
--       AND EXISTS
--             (SELECT null
--              FROM   per_business_groups pbg
--              WHERE  pbg.business_group_id = p_business_group_id
--              AND    NVL(method_of_generation_cwk_num,hr_api.g_varchar2) = 'E'))));
--
   -- << end 2660279
   end if;
 if g_debug then
  hr_utility.set_location('hr_person.validate_unique_number',5);
 end if;
 -- +---------------------------------------------------------------------+
 -- Processing contingent workers
 -- +---------------------------------------------------------------------+
  if p_current_npw = 'Y'  then
   if p_npw_number IS NULL then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','VALIDATE_UNIQUE_NUMBER');
     hr_utility.set_message_token('STEP','4');
     hr_utility.raise_error;
   end if;
--
 if g_debug then
  hr_utility.set_location('hr_person.validate_unique_number',6);
 end if;
 -- #2660279:
 -- >> delete code
--    SELECT 'Y'
--    INTO   l_status
--    FROM   sys.dual
--    WHERE  exists (select 'Y'
--    FROM   per_all_people_f  pp
--    WHERE (p_person_id IS NULL
--       OR  p_person_id <> pp.person_id)
--    AND    pp.business_group_id = p_business_group_id
--    AND   (pp.npw_number        = p_npw_number
--       OR  (pp.employee_number  = p_npw_number
--       AND EXISTS
--             (SELECT null
--              FROM   per_business_groups pbg
--              WHERE  pbg.business_group_id = p_business_group_id
--              AND    NVL(method_of_generation_cwk_num,hr_api.g_varchar2) = 'E'))));
  -- << end delete code
  -- >> new code
    if is_unique_person_number(p_person_id         => p_person_id
                              ,p_person_type       => 'CWK'
                              ,p_person_number     => p_npw_number
                              ,p_business_group_id => p_business_group_id
                              ) = 'N'
    then

      hr_utility.set_message(800,'HR_289656_CWK_NUM_EXIST');
      hr_utility.raise_error;
   end if;
   -- << end new code
  --
   end if;
  --
--
end validate_unique_number;
--
--
  -------------------- BEGIN: product_installed ------------------------------
  /*
    NAME
      product_installed
    DESCRIPTION
      Returns 'Y' if this product is installed, 'N' if not in p_yes_no
      and the ORACLEID of the application in p_oracle_username.
  */
  --
  PROCEDURE product_installed (p_application_short_name	IN varchar2,
			       p_status		 OUT NOCOPY varchar2,
		     	       p_yes_no		 OUT NOCOPY varchar2,
			       p_oracle_username OUT NOCOPY varchar2)
  IS
  --
  BEGIN
    --
    -- Fix for bug 3908271. replace hr_person_delete with hr_person_internal.
    --
 hr_person_internal.product_installed(p_application_short_name,
                               p_status,
                               p_yes_no,
                               p_oracle_username);

    --
  END product_installed;
  -------------------- END: product_installed --------------------------------
  --
  -------------------- BEGIN: weak_predel_validation -------------------------
  /*
    NAME
      weak_predel_validation
    DESCRIPTION
      Validates whether a person can be deleted from the HR database.
      This is the weak validation performed prior to delete using the
      Delete Person form.
  */
  --
  PROCEDURE weak_predel_validation (p_person_id		IN number,
				    p_session_date	IN date)
  IS
  --
  BEGIN
    --
    -- Fix for bug 3908271. replace hr_person_delete with hr_person_internal.
    --
  hr_person_internal.weak_predel_validation(p_person_id,
                                    p_session_date);
  END weak_predel_validation;
  -------------------- END: weak_predel_validation --------------------------
--
  -------------------- BEGIN: strong_predel_validation ---------------------
  /*
    NAME
      strong_predel_validation
    DESCRIPTION
      Called from PERREAQE and PERPEEPI. It performs many checks
      to find if additional data has been entered for this person. It is
      more stringent than weak_predel_validation and ensures that this
      person only has the default data set up by entering a person, contact
      or applicant afresh onto the system.
      If additional data is found then the delete of this person from
      the calling module is invalid as it is beyond its scope. The Delete
      Person form should therefore be used (which only performs
      weak_predel_validation) if a delete really is required.
	p_person_mode  -  'A' check for applicants
			  'E' check for employees
			  'O' check for other types

    NOTE
      No validation is required for security (PER_PERSON_LIST* tables) as
      this is implicit for the person via assignment criteria. The
      rows in these tables can just be deleted.
  */
  PROCEDURE strong_predel_validation (p_person_id	IN number,
				      p_session_date	IN date)
  IS
  --
  --
  BEGIN
    --
    -- Fix for bug 3908271. replace hr_person_delete with hr_person_internal.
    --
   hr_person_internal.strong_predel_validation(p_person_id,
                                     p_session_date);
  END strong_predel_validation;
  -------------------- END: strong_predel_validation -----------------------
--
  -------------------- BEGIN: check_contact ---------------------------------
  /*
    NAME
      check_contact
    DESCRIPTION
      Is this contact a contact for anybody else? If so then do nothing.
      If not then check if this person has ever been an employee or
      applicant. If they have not then check whether they have any extra
      info entered for them (other than default info). If they have not
      then delete this contact also. Otherwise do nothing.
    NOTES
      p_person_id		non-contact in relationship
      p_contact_person_id	contact in this relationship - the person
				who the check is performed against.
      p_contact_relationship_id relationship which is currently being
				considered for this contact.
  */
  --
  PROCEDURE check_contact (p_person_id		IN number,
			   p_contact_person_id	IN number,
			   p_contact_relationship_id IN number,
			   p_session_date	IN date)
  IS
  --
  BEGIN
    --
    -- Fix for bug 3908271. replace hr_person_delete with hr_person_internal.
    --
    hr_person_internal.check_contact(p_person_id,
                           p_contact_person_id,
                           p_contact_relationship_id,
                           p_session_date);
  END check_contact;
  -------------------- END: check_contact  ---------------------------------
--
  -------------------- BEGIN: delete_a_person --------------------------------
  /*
    NAME
      delete_a_person
    DESCRIPTION
      Validates whether a person can be deleted from the HR database.
      It is assumed that weak_predel_validation and the other application
      *_delete_person.*_predel_valdation procedures have been successfully
      completed first.
      Cascades are all performed according to the locking ladder.
    NOTE
      P_FORM_CALL is set to 'Y' if this procedure is called from a forms
      module. In this case, the deletes are performed post-delete and a
      row therefore may not exist in per_people_f (for this person_id).
      For this reason the existance check will be ignored.
  */
  --
  PROCEDURE delete_a_person (p_person_id		IN number,
			     p_form_call		IN boolean,
			     p_session_date		IN date)
  IS
  --
  BEGIN
    --
    -- Fix for bug 3908271. replace hr_person_delete with hr_person_internal.
    --
   hr_person_internal.delete_person(p_person_id,
                            -- p_form_call,
                             p_session_date);
  END delete_a_person;
  -------------------- END: delete_a_person ----------------------------------
--
  -------------------- BEGIN: people_default_deletes -------------------------
  /*
    NAME
      people_default_deletes
    DESCRIPTION
      Delete routine for deleting information set up as default when people
      are created. Used primarily for delete on PERPEEPI (Enter Person).
      The strong_predel_validation should first be performed to ensure that
      no additional info (apart from default) has been entered.
    NOTE
      See delete_a_person for p_form_call details. Further, p_form_call is
      set to TRUE when this procedure is called from check_contact as
      there is no need to check the existance of the contact.
  */
  --
  PROCEDURE people_default_deletes (p_person_id	IN number,
				    p_form_call	IN boolean)
  IS
  --
  --
  --
  BEGIN
    --
    -- Fix for bug 3908271. replace hr_person_delete with hr_person_internal.
    --
    hr_person_internal.people_default_deletes(p_person_id);
                                   -- p_form_call);
    --
  END people_default_deletes;
  -------------------- END: people_default_deletes --------------------------
--
  -------------------- BEGIN: applicant_default_deletes ---------------------
  /*
    NAME
      applicant_default_deletes
    DESCRIPTION
      Delete routine for deleting information set up as default when
      applicants are entered.  Used primarily for delete on PERREAQE
      (Applicant Quick Entry). The strong_predel_validation should first be
      performed to ensure that no additional info (apart from default) has
      been entered.
    NOTE
      See delete_a_person for p_form_call details.
  */
  --
  PROCEDURE applicant_default_deletes (p_person_id IN number,
				       p_form_call IN boolean)
  IS
  --
  --
  BEGIN
    --
    -- Fix for bug 3908271. replace hr_person_delete with hr_person_internal.
    --
    hr_person_internal.applicant_default_deletes(p_person_id);
                                               -- p_form_call);
  END applicant_default_deletes;
  -------------------- END: applicant_default_deletes -----------------------
--
------------------------- BEGIN: chk_future_person_type --------------------
--
--NAME
--  chk_future_person_type
--DESCRIPTION
--  Returns TRUE or FALSE depending on status of applicants Person_types.
--PARAMETERS
--  p_system_person_type : Current system person type of person.
--  p_person_id : Unique id of the Applicant being hired.
--  p_business_group_id : Id of the business group.
--  p_end_date  : End date of the unaccepted applications = start date - 1
--
FUNCTION chk_future_person_type
 	(p_system_person_type IN VARCHAR2
   	,p_person_id IN INTEGER
        ,p_business_group_id IN INTEGER
   	,p_effective_start_date IN DATE) RETURN BOOLEAN IS
l_check_all VARCHAR2 (1);
l_return boolean;
begin
l_check_all := 'Y';
l_return := chk_future_person_type(p_system_person_type => p_system_person_type
                     ,p_person_id => p_person_id
                     ,p_business_group_id => p_business_group_id
                     ,p_check_all => l_check_all
                     ,p_effective_start_date => p_effective_start_date);
  return l_return;
end;
FUNCTION chk_future_person_type
 	(p_system_person_type IN VARCHAR2
   	,p_person_id IN INTEGER
        ,p_business_group_id IN INTEGER
        ,p_check_all IN VARCHAR2 DEFAULT 'Y'
   	,p_effective_start_date IN DATE) RETURN BOOLEAN IS
--
p_test_func varchar2(60);
--
BEGIN
--
 if g_debug then
  hr_utility.set_location('hr_person.chk_future_person_type',1);
 end if;
--
--
        -- Fix for bug 7045968 starts here
	-- Modified the select statement to use the person_type_id from
	-- per_person_type_usages_f
	-- rather than per_people_f

	/*select 'Y'
	into p_test_func
        from sys.dual
        where exists(
        select 'Future Person Type exists'
	from per_people_f ppf
	,per_person_types ppt
	,per_startup_person_types pst
	where  ppf.person_type_id = ppt.person_type_id
	and  ppf.person_id = p_person_id
	and  ppf.business_group_id +0 = ppt.business_group_id+0
	and  ppf.business_group_id +0 = p_business_group_id
	and  (((p_effective_start_date < ppf.effective_start_date)
              and p_check_all = 'Y')
	 or  (p_effective_start_date = ppf.effective_start_date))
	and  ppt.system_person_type <> pst.system_person_type
	and  pst.system_person_type = p_system_person_type
        union
        select 'Future Person Type exists'
        from   per_periods_of_service pps
        where  pps.person_id = p_person_id
        and    p_effective_start_date < pps.date_start
	union --fix for bug 6730008
        select 'Future Person Type exists'
        from   per_periods_of_placement pps
        where  p_system_person_type='OTHER'
        and    pps.person_id = p_person_id
        and (   p_effective_start_date < nvl(pps.actual_termination_date,p_effective_start_date)
        or p_effective_start_date <pps.date_start)
        ); */


	select 'Y'
	into p_test_func
        from sys.dual
        where exists(
        select 'Future Person Type exists'
	from per_person_type_usages_f ptu
	,per_person_types ppt
	,per_startup_person_types pst
	where  ptu.person_type_id = ppt.person_type_id
	and  ptu.person_id = p_person_id
	and  ((p_effective_start_date < ptu.effective_start_date)
              and p_check_all = 'Y')
	-- or  (p_effective_start_date = ptu.effective_start_date)) -- Commented for the bug 7208177
	and  ppt.system_person_type <> pst.system_person_type
	and  pst.system_person_type = p_system_person_type
        );

	 -- Fix for bug 7045968 ends here

--
RETURN TRUE;
--
exception
	when no_data_found then
		RETURN FALSE;
	when hr_utility.hr_error then
		raise;
                RETURN FALSE;
	when others then
		hr_utility.oracle_error(sqlcode);
                RETURN FALSE;
END chk_future_person_type;
------------------------- END: chk_future_person_type --------------------
--
------------------------- BEGIN: chk_prev_person_type --------------------
--
--NAME
--  chk_prev_person_type
--DESCRIPTION
--  Returns TRUE or FALSE depending on status of applicants Person_types.
--PARAMETERS
--  p_system_person_type : Current system person type of person.
--  p_person_id : Unique id of the Applicant being hired.
--  p_business_group_id : Id of the business group.
--  p_end_date  : End date of the unaccepted applications = start date - 1
--
FUNCTION chk_prev_person_type
	 (p_system_person_type IN VARCHAR2
         ,p_person_id IN INTEGER
         ,p_business_group_id IN INTEGER
   	 ,p_effective_start_date IN DATE) RETURN BOOLEAN IS
--
p_test_func varchar2(60);
--
BEGIN
--
 if g_debug then
  hr_utility.set_location('hr_person.chk_prev_person_type',1);
  hr_utility.set_location('p_system_person_type= '||p_system_person_type,10);
  hr_utility.set_location('p_person_id= '||p_person_id,20);
  hr_utility.set_location('p_business_group_id= '||p_business_group_id,30);
  hr_utility.set_location('p_effective_start_date= '||p_effective_start_date,40);
 end if;

select 'Y'
  into p_test_func
  from sys.dual
 where exists
   (
        -- code change start  for bug 3957689
 select 'Previous Person type exists'
   from per_all_people_f ppf ,
        per_person_types ppt ,
        per_startup_person_types pst ,
        per_person_type_usages_f ptu
  where ppf.person_id = p_person_id
    and ppf.business_group_id +0= p_business_group_id
    and ppf.business_group_id +0= ppt.business_group_id +0
    and pst.system_person_type = p_system_person_type
    and ppt.system_person_type <> pst.system_person_type
    and ppf.person_id = ptu.person_id
    and ptu.person_type_id = ppt.person_type_id
/*  and p_effective_start_date between
         ptu.effective_start_date and ptu.effective_end_date --- fix for bug 6161469  */
union
 select 'Previous Person type exists'
   from per_periods_of_service pps
  where pps.person_id = p_person_id
    and p_effective_start_date > nvl(pps.actual_termination_date,
					    p_effective_start_date)
union
 select 'Previous Person type exists'
   from per_periods_of_placement ppp
  where ppp.person_id = p_person_id
     and p_effective_start_date > nvl(ppp.actual_termination_date,
					    p_effective_start_date)); --fix for bug 5961371.


        /*
        select 'Previous Person type exists'
	from per_people_f ppf
	,per_person_types ppt
	,per_startup_person_types pst
	where  ppf.person_type_id = ppt.person_type_id
	and  ppf.person_id = p_person_id
	and  ppf.business_group_id +0= ppt.business_group_id +0
	and  ppf.business_group_id +0= p_business_group_id
	and  p_effective_start_date > ppf.effective_start_date
	and  ppt.system_person_type <> pst.system_person_type
	and  pst.system_person_type = p_system_person_type
        union
        select 'Previous Person type exists'
        from per_periods_of_service pps
        where pps.person_id = p_person_id
        and p_effective_start_date > nvl(pps.actual_termination_date,
					    p_effective_start_date));
		*/
-- code change ended  for bug 3957689
--
RETURN TRUE;
--
exception
	when no_data_found then
		RETURN FALSE;
	when hr_utility.hr_error then
		raise;
                RETURN FALSE;
	when others then
		hr_utility.oracle_error(sqlcode);
                RETURN FALSE;
END chk_prev_person_type;
------------------------- BEGIN: chk_prev_person_type --------------------
--
------------------------- BEGIN: validate_address --------------------
PROCEDURE validate_address(p_person_id INTEGER
                          ,p_business_group_id INTEGER
                          ,p_address_id INTEGER
                          ,p_date_from DATE
                          ,p_date_to DATE
                          ,p_end_of_time DATE
                          ,p_primary_flag VARCHAR2) IS
/*
--NAME
--  validate_address
--DESCRIPTION
--  Returns TRUE or FALSE depending on status of applicants Person_types.
--PARAMETERS
--  p_person_id : Unique Id of the person.
--  p_business_group_id:Id of the business group.
--  p_address_id:Id of the addrtess.
--  p_date_from: Start date of the address being validated.
--  p_date_to: End date of the address being validated.
--  p_end_of_time :Ultimate date on Oracle system 31-Dec-4712.
--  p_primary_flag: Whether primary or secondary.
*/
--
v_dummy VARCHAR2(30);
-- primary flag test.
l_primary_flag VARCHAR2(1) :='Y';
--
begin
 if g_debug then
  hr_utility.set_location('hr_person.validate_address',1);
 end if;
--
--
  select 'Error : Primary address exists'
  into   v_dummy
  from   sys.dual
  where  exists (select 'address exists'
                   from   per_addresses pa
                   where  pa.person_id = p_person_id
                   and    pa.business_group_id  +0 = p_business_group_id
                   and   (pa.address_id <> p_address_id
                       or p_address_id is null)
                   and    pa.primary_flag = l_primary_flag
                   and   (p_date_from  between pa.date_from
                          and nvl(pa.date_to,p_end_of_time)
                       or nvl(p_date_to,p_end_of_time) between
                         pa.date_from and nvl(pa.date_to,p_end_of_time))
                  );
  --
  -- Primary exists and form trying to enter primary
  -- then raise error
  --
  if p_primary_flag = 'Y' then
     hr_utility.set_message(801,'HR_6510_PER_PRIMARY_ADDRESS');
     hr_utility.raise_error;
  end if;
  exception
    when NO_DATA_FOUND then
      -- if no primary found
      -- then if form has primary set
      -- do nothing
      -- else flag an error
      --
      if p_primary_flag <> 'Y' then
        hr_utility.set_message(801,'HR_7144_PER_NO_PRIM_ADD');
        hr_utility.raise_error;
      end if;
end validate_address;
------------------------- END: validate_address --------------------

end hr_person;


/
