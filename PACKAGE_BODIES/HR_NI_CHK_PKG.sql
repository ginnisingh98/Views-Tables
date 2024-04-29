--------------------------------------------------------
--  DDL for Package Body HR_NI_CHK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NI_CHK_PKG" AS
/* $Header: penichk.pkb 120.1.12000000.3 2007/04/05 12:44:49 agolechh ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_ni_chk_pkg.';

/*
 Name        : hr_ni_chk_pkg  (BODY)
*/
--
-- ------------------- validate_national_identifier --------------------
--
--
function validate_national_identifier
( p_national_identifier    VARCHAR2,
  p_birth_date             DATE,
  p_gender                 VARCHAR2,
  p_business_group_id      NUMBER,
  p_session_date           DATE)
return VARCHAR2 IS
--
  l_return_value            varchar2(240);
  l_person_id               per_people_f.person_id%TYPE;
  l_legislation_code        per_business_groups.legislation_code%TYPE;
  l_proc      varchar2(72)  := g_package||'validate_national_identifier';
  l_warning   varchar2(1)   :='N';
  l_person_type_id          per_people_f.person_type_id%TYPE;
  l_region_of_birth         per_people_f.region_of_birth%TYPE;
  l_country_of_birth        per_people_f.country_of_birth%TYPE;
--
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 3);
  --
  -- validate arguments prior to calling validate_national_identifier
  --
  -- check national identifier is not null
  --
  if p_national_identifier is null then
    hr_utility.set_message(801,'HR_51242_PER_NAT_ID_NULL');
    hr_utility.raise_error;
  end if;
  l_return_value := p_national_identifier;
  --
  -- check birth date is not null
  --
  if p_birth_date is null then
    hr_utility.set_message(800,'HR_52767_PER_DOB_NULL');
    hr_utility.raise_error;
  end if;
  --
  -- check gender is not null
  --
  if p_gender is null then
    hr_utility.set_message(800,'HR_52766_PER_GENDER_NULL');
    hr_utility.raise_error;
  end if;
  --
  -- check session date is not null
  --
  if p_session_date is null then
    hr_utility.set_message(800,'HR_52768_PER_SESSION_DATE_NULL');
    hr_utility.raise_error;
  end if;
  --
  -- validate p_business_group and derrive legislation code
  --
  if p_business_group_id is null then
    hr_utility.set_message(800,'HR_52769_PER_BUS_GRP_NULL');
    hr_utility.raise_error;
  else
    open csr_bg;
    fetch csr_bg into l_legislation_code;
    if csr_bg%notfound then
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
	 hr_utility.raise_error;
    end if;
    close csr_bg;
  end if;
  --
  --
  hr_utility.set_location(l_proc, 6);
  --
  --
  -- Now call NI validation routine...
  l_return_value := hr_ni_chk_pkg.validate_national_identifier(
	p_national_identifier => p_national_identifier,
	p_birth_date          => p_birth_date,
	p_gender              => p_gender,
	p_person_id           => l_person_id,
	p_business_group_id   => p_business_group_id,
	p_legislation_code    => l_legislation_code,
	p_session_date        => p_session_date,
        p_warning             => l_warning,
        p_person_type_id      => l_person_type_id,
        p_region_of_birth     => l_region_of_birth,
        p_country_of_birth    => l_country_of_birth);
  --
  --
  hr_utility.set_location('Leaving:'|| l_proc, 8);
  --
  return l_return_value;
--
end validate_national_identifier;
--
--
-- ------------------- validate_national_identifier -----------------------
--
--
function validate_national_identifier
( p_national_identifier    VARCHAR2,
  p_birth_date             DATE,
  p_gender                 VARCHAR2,
  p_event                  VARCHAR2 default 'WHEN-VALIDATE-RECORD',
  p_person_id              NUMBER,
  p_business_group_id      NUMBER,
  p_legislation_code       VARCHAR2,
  p_session_date           DATE,
  p_warning            OUT NOCOPY VARCHAR2,
  p_person_type_id         NUMBER default NULL,
  p_region_of_birth         VARCHAR2 default NULL,
  p_country_of_birth        VARCHAR2 default NULL
      ) return VARCHAR2 IS
--
  l_nationality    varchar2(30);
  l_return_value varchar2(240);
  begin

l_return_value :=hr_ni_chk_pkg.validate_national_identifier(
	p_national_identifier => p_national_identifier,
	p_birth_date          => p_birth_date,
	p_gender              => p_gender,
	p_person_id           => p_person_id,
	p_business_group_id   => p_business_group_id,
	p_legislation_code    => p_legislation_code,
	p_session_date        => p_session_date,
        p_warning             => p_warning,
        p_person_type_id      => p_person_type_id,
        p_region_of_birth     => p_region_of_birth,
        p_country_of_birth    => p_country_of_birth,
        p_nationality         => l_nationality );

  return l_return_value;  -- change for the 5970526

 end validate_national_identifier;
--

-- added a new parameter p_nationality
FUNCTION validate_national_identifier
( p_national_identifier     VARCHAR2,
  p_birth_date              DATE,
  p_gender                  VARCHAR2,
  p_event                   VARCHAR2 default 'WHEN-VALIDATE-RECORD',
  p_person_id               NUMBER,
  p_business_group_id       NUMBER,
  p_legislation_code        VARCHAR2,
  p_session_date            DATE,
  p_warning             OUT NOCOPY VARCHAR2,
  p_person_type_id          NUMBER default NULL,
  p_region_of_birth         VARCHAR2 default NULL,
  p_country_of_birth        VARCHAR2 default NULL,
  p_nationality            varchar2 -- added for the bug 5961277
      ) RETURN VARCHAR2 is

l_formula_id ff_formulas_f.formula_id%type;
  l_effective_start_date ff_formulas_f.effective_start_date%type;
  l_inputs ff_exec.inputs_t;
  l_outputs ff_exec.outputs_t;
  l_return_value varchar2(240);
  l_invalid_mesg varchar2(240);
  l_warning varchar2(1) := 'N';
  l_compiled_formula_id	number;
--
   l_proc      varchar2(72) := g_package||'validate_national_identifier';
   --
   --
   -- Cursor to check that the formula being used has been compiled
   --
   cursor csr_compiled_formula is
   select formula_id
   from ff_compiled_info_f
   where formula_id = l_formula_id
   and p_session_date between effective_start_date and effective_end_date;

begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 5);
   --
--
   l_return_value := p_national_identifier;
--
--   select formula_id,effective_start_date
--   into   l_formula_id,l_effective_start_date
--   from   ff_formulas_f
--   where  formula_name='NI_VALIDATION'
--   and    business_group_id is null
--   and    legislation_code=p_legislation_code
--   and    p_session_date between effective_start_date and effective_end_date;

--
--bug 2091601
--
SELECT FORMULA_ID,EFFECTIVE_START_DATE
  into l_formula_id,l_effective_start_date
  FROM FF_FORMULAS_F fo, ff_formula_types ft
 WHERE  ft.formula_type_name = 'Oracle Payroll'
   and fo.formula_type_id = ft.formula_type_id
   and fo.FORMULA_NAME = 'NI_VALIDATION'
   AND fo.BUSINESS_GROUP_ID IS NULL
   AND fo.LEGISLATION_CODE = p_legislation_code
   AND p_session_date BETWEEN fo.EFFECTIVE_START_DATE AND fo.EFFECTIVE_END_DATE;
--
--
--

   --
   hr_utility.set_location(l_proc, 10);
   --
   -- Addition for 1891893
   --
   open csr_compiled_formula;
   fetch csr_compiled_formula into l_compiled_formula_id;
   if csr_compiled_formula%found then
   --
   -- End of current addition 1891893, elsif/error message below
   --
   --
   ff_exec.init_formula(l_formula_id,l_effective_start_date,l_inputs,l_outputs);
   --
   for l_in_cnt in
   l_inputs.first..l_inputs.last
   loop
      if l_inputs(l_in_cnt).name='NATIONAL_IDENTIFIER' then
         l_inputs(l_in_cnt).value := p_national_identifier;
      end if;
      if l_inputs(l_in_cnt).name='BIRTH_DATE' then
         l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(p_birth_date);
      end if;
      if l_inputs(l_in_cnt).name='GENDER' then
         l_inputs(l_in_cnt).value := p_gender;
      end if;
      if l_inputs(l_in_cnt).name='EVENT' then
         l_inputs(l_in_cnt).value := p_event;
      end if;
      if l_inputs(l_in_cnt).name='PERSON_TYPE_ID' then
         l_inputs(l_in_cnt).value := p_person_type_id;
      end if;
      if l_inputs(l_in_cnt).name='REGION_OF_BIRTH' then
         l_inputs(l_in_cnt).value := p_region_of_birth;
      end if;
      if l_inputs(l_in_cnt).name='COUNTRY_OF_BIRTH' then
         l_inputs(l_in_cnt).value := p_country_of_birth;
      end if;
       if l_inputs(l_in_cnt).name='NATIONALITY' then
         l_inputs(l_in_cnt).value := p_nationality;
      end if;
   end loop;
   --
   hr_utility.set_location(l_proc, 15);
   --
   --
   ff_exec.run_formula(l_inputs,l_outputs);
   --
   for l_out_cnt in
   l_outputs.first..l_outputs.last
   loop
      if l_outputs(l_out_cnt).name='RETURN_VALUE' then
         l_return_value := l_outputs(l_out_cnt).value;
      end if;
      if l_outputs(l_out_cnt).name='INVALID_MESG' then
         l_invalid_mesg := l_outputs(l_out_cnt).value;
      end if;
   end loop;
   --
   if l_return_value = 'INVALID_ID' then
      if fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <>'NONE' then
        if fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <>'WARN' then
                    hr_utility.set_message(801,l_invalid_mesg);
                    hr_utility.raise_error;
        else
            l_warning :='Y';
        end if;
      end if;
    end if;
     p_warning := l_warning;
   -- ********************************************
   -- If the formula is invalid then error 1891893
   -- ********************************************
   elsif fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <>'NONE' then
           fnd_message.set_name('PER','HR_289303_NI_FORMULA_ERROR');
           hr_utility.raise_error;
   end if;
   close csr_compiled_formula;
   --
   -- End of fix for 1891893
   --
   hr_utility.set_location('Leaving:'|| l_proc, 20);
   --
   if fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') ='NONE' or fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') ='WARN' then
             l_return_value := p_national_identifier;
   end if;

   --
   return l_return_value;
exception
when NO_DATA_FOUND then
   --
   hr_utility.set_location('Leaving:'|| l_proc, 22);
   --
   return l_return_value;
--

end validate_national_identifier;
--
--
FUNCTION chk_nat_id_format(

/* This function checks that a supplied national identifier
is in the specified format.  It also ensures that the correct
format mask is applied to the national identifier, which is
then returned to the calling program.  If the validation fails
then the rountine passes back a '0'.

It should conform to business process validation standards,
from which it is called in order that the person API routines
remain under the control of one person.

*/
	p_national_identifier	IN VARCHAR2,
	p_format_string		IN VARCHAR2

) RETURN VARCHAR2 AS

l_nat_id		VARCHAR2(30);
l_format_mask		VARCHAR2(30);
l_format_string         VARCHAR2(30);
l_valid			NUMBER;
l_len_format_mask	NUMBER;
l_number_format_ch	NUMBER;
l_no_format_nat_id	VARCHAR2(30);
l_no_format_string_opt	VARCHAR2(30);
l_no_format_string_nopt	VARCHAR2(30);
l_format_count		NUMBER;
l_nat_id_count		NUMBER;
l_lgth_string_nopt	NUMBER;
l_lgth_string_opt	NUMBER;
l_lgth_nat_id		NUMBER;


   l_proc      varchar2(72) := g_package||'chk_nat_id_format';
   --
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 5);
   --

l_nat_id := '0';
l_valid := 1;

/* First Derive the format mask from the format string.
   This is defined as the remainder of the string, after
   the format characters, namely 'ABDEX' have been removed.
   Also generate the format mask without any kind of
   format characters for continued use in the processing */

l_format_mask := translate(p_format_string,'CABDEX','C');
l_format_string := translate(p_format_string,'A !"$%^&*()-_+=`[]{};''#:@~<>?','A');

/* Check validity of format string  */

if translate(l_format_string,'CABDEX','C') is null then

/* Check validity of format mask */

  if translate(upper(l_format_mask),'A !"$%^&*()-_+=`[]{};''#:@~<>?','A') is null then

      /* Check that the format string and national identifier number are the same length */
      /*  - that is minus any optional characters */

     l_no_format_string_opt:=translate(upper(l_format_string),'ABDEX','ABDEX');
     l_no_format_string_nopt:=translate(upper(l_format_string),'ADXBE','ADX');
     l_no_format_nat_id:=translate(upper(p_national_identifier),'A !"$%^&*()-_+=`[]{};''#:@~<>?','A');

     l_lgth_string_nopt:=length(l_no_format_string_nopt);
     l_lgth_string_opt:=length(l_no_format_string_opt);
     l_lgth_nat_id:=length(l_no_format_nat_id);


     if((l_lgth_nat_id>=l_lgth_string_nopt) and (l_lgth_nat_id<=l_lgth_string_opt)) then

       /* If processing reaches this point, we have a valid format mask, a valid format string
          and a format string that can be checked against the national identifier
          Main format validation can now preceed */

        FOR l_char_pos in 1..l_lgth_string_opt  LOOP

	   if (substr(l_no_format_string_opt,l_char_pos,1)='A') then


              if(substr(l_no_format_nat_id,l_char_pos,1)<'A' OR substr(l_no_format_nat_id,l_char_pos,1)>'Z') then
	              l_valid := 0;
              end if;

           elsif (substr(l_no_format_string_opt,l_char_pos,1)='B') then


	     if (l_lgth_nat_id >= l_char_pos) then

                 if(substr(l_no_format_nat_id,l_char_pos,1)<'A' OR substr(l_no_format_nat_id,l_char_pos,1)>'Z') then
	              l_valid := 0;
              	 end if;

	     end if;

          elsif (substr(l_no_format_string_opt,l_char_pos,1)='D') then


              if(substr(l_no_format_nat_id,l_char_pos,1)<'0' OR substr(l_no_format_nat_id,l_char_pos,1)>'9') then
	              l_valid := 0;
              end if;

          elsif (substr(l_no_format_string_opt,l_char_pos,1)='E') then


	       if (l_lgth_nat_id >= l_char_pos) then

                 if(substr(l_no_format_nat_id,l_char_pos,1)<'0' OR substr(l_no_format_nat_id,l_char_pos,1)>'9') then
	              l_valid := 0;
              	 end if;

	     end if;

          elsif (substr(l_no_format_string_opt,l_char_pos,1)='X') then

               if (substr(l_no_format_nat_id,l_char_pos,1)<'0' OR substr(l_no_format_nat_id,l_char_pos,1)>'9')
                  and (substr(l_no_format_nat_id,l_char_pos,1)<'A' OR substr(l_no_format_nat_id,l_char_pos,1)>'Z')
                     then
                        l_valid := 0;
               end if;

          end if;

        EXIT WHEN l_valid=0;

        END LOOP;

	if l_valid = 1 then

          /* We have a valid national identifier - now to return it in the format mask required */

           l_format_count:=1;
           l_nat_id_count:=1;

	 /* Reset the national identifier to null before adding the passed national identifier */

	   l_nat_id := '';
           FOR l_format_pos in 1..length(p_format_string) LOOP
--
-- Bug 944746, rearranged string from ABCDEX to CABDEX.
--
              if(translate(substr(p_format_string,l_format_pos,1),'CABDEX','C') is not null) then
                  /* We have a format character - add it on to the return national identifier */
                  l_nat_id := l_nat_id||substr(p_format_string,l_format_pos,1);
              else
                  /* We have a national identifier character - add it on to the return variable */
                  l_nat_id := l_nat_id||substr(l_no_format_nat_id,l_nat_id_count,1);
                  l_nat_id_count:=l_nat_id_count+1;
              end if;

           END LOOP;

	else

	/* The national identifier is not in the valid format */

	-- dbms_output.put_line('The format of the national identifier is not correct');
        null;

	end if;

     else

       /* The format string and national identifier are differing lengths */
      -- dbms_output.put_line('The format string and national identifier (excluding formats)');
      -- dbms_output.put_line('are not the same length');
      null;

     end if;

  end if;

else


/* The format string contains unexecpected characters - check to see if
   the format string and the national identifier are identical, if so,
   then this corresponds to a special format inside the formula rather
   than here, now that the formulae are calling this function */

   -- dbms_output.put_line('Is this a special string - check inside the formula');
   null;

/* End format string check */
end if;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 10);
   --

return l_nat_id;

end chk_nat_id_format;

-- ------------------- check_ni_unique --------------------
procedure check_ni_unique
( p_national_identifier     VARCHAR2,
  p_person_id               NUMBER,
  p_business_group_id       NUMBER,
  p_raise_error_or_warning  VARCHAR2)
--
is
--
  l_status            VARCHAR2(1);
  l_legislation_code  VARCHAR2(30);
  l_nat_lbl           VARCHAR2(2000);
--
  local_warning exception;
  l_proc      varchar2(72) := g_package||'check_ni_unique';
   --
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 5);
   --
  SELECT org_information9
  INTO   l_legislation_code
  FROM   hr_organization_information
  WHERE  org_information_context = 'Business Group Information'
  AND    organization_id         = p_business_group_id;
--
--
   --
   hr_utility.set_location(l_proc, 10);
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
		    AND    pp.business_group_id   +0 = p_business_group_id);
     --
     fnd_message.set_name('PER','HR_NATIONAL_ID_NUMBER_'||l_legislation_code);
     l_nat_lbl := fnd_message.get;
     l_nat_lbl := rtrim(l_nat_lbl);
     if l_nat_lbl = 'HR_NATIONAL_ID_NUMBER_'||l_legislation_code then
        fnd_message.set_name('PER','HR_NATIONAL_IDENTIFIER_NUMBER');
        l_nat_lbl := fnd_message.get;
        l_nat_lbl := rtrim(l_nat_lbl);
     end if;

     if p_raise_error_or_warning = 'ERROR' then
        hr_utility.set_message(801,'HR_NI_UNIQUE_ERROR');
        hr_utility.set_message_token('NI_NUMBER',l_nat_lbl);
        hr_utility.raise_error;
     else
       /* psingla -- To execute null statement if the Legislation is Polish and the profile
                     PER_NI_UNIQUE_ERROR_WARNING is set to null
             hr_utility.set_message(801,'HR_NI_UNIQUE_WARNING');
             hr_utility.set_message_token('NI_NUMBER',l_nat_lbl);
             raise local_warning; */
        if l_legislation_code = 'PL' and fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING') is NULL then -- For Poland
            null;
        else
            hr_utility.set_message(801,'HR_NI_UNIQUE_WARNING');
            hr_utility.set_message_token('NI_NUMBER',l_nat_lbl);
            raise local_warning;
        end if;
     end if;
  --
   --
   hr_utility.set_location(' Leaving:'||l_proc, 15);
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
end hr_ni_chk_pkg;


/
