--------------------------------------------------------
--  DDL for Package Body HR_GB_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GB_UTILITY" AS
/* $Header: hrgbutil.pkb 120.2.12010000.2 2008/08/06 08:41:34 ubhat ship $ */
-----------------------------------------------------------------------
function push_pay_message(p_applid    in number,
                          p_msg_name  in varchar2,
                          p_level     in varchar2) return number is
--
l_number number;
--
begin
  begin
  l_number := 0;
  pay_core_utils.push_message(p_applid   => p_applid,
                              p_msg_name => p_msg_name,
                              p_level    => p_level);
--
  exception when others then
    l_number := 1;
  end;
return l_number;
end push_pay_message;
------------------------------------------------------------------------
function push_pay_token(p_tok_name    in varchar2,
                        p_tok_value   in varchar2) return number is
--
l_number number;
--
begin
  begin
  l_number := 0;
  pay_core_utils.push_token(p_tok_name  => p_tok_name,
                            p_tok_value => p_tok_value);
  --
  exception when others then
    l_number := 1;
  end;
return l_number;
end push_pay_token;
-----------------------------------------------------------------------
function place_message_stack(p_pactid in number) return number is
--
-- Commented out code as this should not be used.
l_number number;
--
begin
  begin
  l_number := 0;
  -- pay_core_utils.mesg_stack_error_hdlr(p_pactid => p_pactid);
  --
  exception when others then
    l_number := 1;
  end;
return l_number;
end place_message_stack;
----------------------------------------------------------------------
function lookup_valid (p_lookup_type in varchar2,
                       p_lookup_code in varchar2,
                       p_effective_date in date) return boolean is
  --
   cursor csr_lookup_code(c_lookup_type    in varchar2,
                          c_lookup_code    in varchar2,
                          c_effective_date in date) is
   select 1 from dual where exists
   (select hlu.lookup_code
    from hr_lookups hlu
    where hlu.lookup_type = c_lookup_type
    and hlu.lookup_code = c_lookup_code
    and c_effective_date between
            nvl(hlu.start_date_active, p_effective_date)
       and  nvl(hlu.end_date_active, p_effective_date)
    and hlu.enabled_flag = 'Y');
    --
    l_valid boolean := TRUE;
    l_exist_number number;
  --
begin -- lookup_valid
  BEGIN
  --
    open csr_lookup_code(p_lookup_type, p_lookup_code, p_effective_date);
    fetch csr_lookup_code into l_exist_number;
     --
     if csr_lookup_code%NOTFOUND or l_exist_number <> 1 then
        l_valid := FALSE;
     end if;
    close csr_lookup_code;
  EXCEPTION WHEN OTHERS THEN
     l_valid := FALSE;
  END;
  --
  return l_valid;
  --
end lookup_valid;
-----------------------------------------------------------------------
-- function: ni_validate
-- description: takes in a NI Number and the effective date,
--              then checks whether the format is valid, and whether
--              the prefix and suffix are within the allowable range
--              of the lookups.
-----------------------------------------------------------------------
function ni_validate(p_ni_number      in varchar2,
                     p_effective_date in date) return number is
--
 l_validate_ni_code varchar2(30);
 l_return_code number;
 l_exist_number number;
 l_ni_number varchar2(30);
 l_ni_prefix varchar2(2);
 l_ni_suffix varchar2(1);

 l_char_chk          constant varchar2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 l_number_chk        constant varchar2(10) := '0123456789';
 l_translated_value  varchar2(200);
 l_invalid_char      constant varchar2(1) := '~';  -- required for translate

--
BEGIN
  --
  -- Default the return code, and set NI number to upper, incase passed in lower
  --
  l_return_code := 0;

  -- Added for bug fix : 5381242
  l_translated_value :=
      translate(p_ni_number,
                l_invalid_char||l_char_chk||l_number_chk,
                l_invalid_char);

  if l_translated_value is not null then
      hr_utility.trace('Lower case chars found: '||l_translated_value);
      l_return_code := 5; -- Not valid
  end if;

  l_ni_number := upper(p_ni_number);
  --
  -- NULL is an allowable NI Number, if this is the case then return 0 (valid)
  IF p_ni_number is null then
     l_return_code := 0;
  --
  ELSE
    -- Check that the NI Number is the correct format, AADDDDDDA,
    -- where A=Alpha Character, D = Digit. Returns full NI number back if OK, or
    -- 0 if not ok.
    --
    l_validate_ni_code := hr_ni_chk_pkg.chk_nat_id_format(p_ni_number, 'AADDDDDDA');
    --
    if l_validate_ni_code = '0' then
       -- The NI Number is not in the right format, send the apt code.
       l_return_code := 1;
    else
       -- NI Number in right format, check prefix and suffix
       l_ni_prefix := substr(l_ni_number,1,2);
       l_ni_suffix := substr(l_ni_number,9,1);
       --
       if not(lookup_valid('GB_NI_VALIDATION_PREFIX', l_ni_prefix, p_effective_date)) then
          -- Prefix is invalid, is suffix also
        if not(lookup_valid('GB_NI_VALIDATION_SUFFIX', l_ni_suffix, p_effective_date)) then
           -- both invalid
           l_return_code := 4;
        else
           -- just prefix invalid
           l_return_code := 2;
        end if;
       else
        if not(lookup_valid('GB_NI_VALIDATION_SUFFIX', l_ni_suffix, p_effective_date)) then
           -- just suffix invalid
           l_return_code := 3;
        end if;
       end if;
       --
    end if; -- validation code
  END IF; -- null NI Number
  --
RETURN l_return_code;
--
END ni_validate;
--------------------------------------------------------------------
-- NAME  tax_code_validate                                        --
--                                                                --
--DESCRIPTION                                                     --
-- This Function uses the TAX_CODE validation fast formula and    --
-- returns an error message if an incorrect tax code is entered.  --
-- Copied from pyudet and externalised so can be called from      --
-- external plsql code.                                           --
--------------------------------------------------------------------
--
function tax_code_validate (p_tax_code          in varchar2,
                            p_effective_date    in date,
                            p_assignment_id     in number)
return VARCHAR2 IS
--
  l_formula_id           ff_formulas_f.formula_id%type;
  l_effective_start_date ff_formulas_f.effective_start_date%type;
  l_inputs               ff_exec.inputs_t;
  l_outputs              ff_exec.outputs_t;
  l_return_value         varchar2(50):= null;
  l_formula_mesg         varchar2(50):= null;
  l_status_value         varchar2(2):= null;
  l_proc                 varchar2(72) := 'hr_gb_utility.tax_code_validate';
  --
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 5);
   --
   BEGIN
     select formula_id,effective_start_date
     into   l_formula_id, l_effective_start_date
     from   ff_formulas_f
     where  formula_name='TAX_CODE'
     and    business_group_id is null
     and    legislation_code='GB'
     and    p_effective_date between effective_start_date and effective_end_date;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     hr_utility.trace('Error: TAX_CODE formula not defined');
     l_return_value := 'TAX_CODE formula not found';
   END;
   --
   hr_utility.set_location(l_proc, 10);
   --
   ff_exec.init_formula(l_formula_id,l_effective_start_date,l_inputs,l_outputs);
   --
   for l_in_cnt in
   l_inputs.first..l_inputs.last
   loop
     if  l_inputs(l_in_cnt).name = 'ENTRY_VALUE' then
          l_inputs(l_in_cnt).value := ltrim(p_tax_code);
      end if;
      if  l_inputs(l_in_cnt).name = 'DATE_EARNED' then
         -- Bug 6888656 modified to_char to fnd_date.date_to_canonical
	 -- l_inputs(l_in_cnt).value := to_char(p_effective_date,'DD-MON-YYYY');
	 l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(p_effective_date);
      end if;
      if  l_inputs(l_in_cnt).name = 'ASSIGNMENT_ID' then
           l_inputs(l_in_cnt).value := to_char(p_assignment_id);
      end if;
    end loop;
   --
   hr_utility.set_location(l_proc, 15);
   --
   ff_exec.run_formula(l_inputs,l_outputs);
   --
   for l_out_cnt in
   l_outputs.first..l_outputs.last
   loop
      if l_outputs(l_out_cnt).name='FORMULA_MESSAGE' then
         l_formula_mesg := l_outputs(l_out_cnt).value;
      end if;

      if l_outputs(l_out_cnt).name='FORMULA_STATUS' then
         l_status_value := l_outputs(l_out_cnt).value;
      end if;
   end loop;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 20);
   --
   if l_status_value = 'E' and
      l_formula_mesg is null then
      l_return_value := 'TAX_CODE Formula error';
   else
      l_return_value := l_formula_mesg;
   end if;
 return l_return_value;
exception
when NO_DATA_FOUND then
   hr_utility.set_location('Leaving:'|| l_proc, 22);
   --
   return l_return_value;
--
end tax_code_validate;
---------------------------------------------------------------------------
procedure DERIVE_HR_LOC_ADDRESS
                       (p_tax_name                  in varchar2,
                        p_style                     in varchar2,
                        p_address_line_1            in varchar2,
                        p_address_line_2            in varchar2,
                        p_address_line_3            in varchar2,
                        p_town_or_city              in varchar2,
                        p_country                   in varchar2,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_loc_information13         in varchar2,
                        p_loc_information14         in varchar2,
                        p_loc_information15         in varchar2,
                        p_loc_information16         in varchar2,
                        p_loc_information17         in varchar2,
                        p_attribute_category        in varchar2,
                        p_attribute1                in varchar2,
                        p_attribute2                in varchar2,
                        p_attribute3                in varchar2,
                        p_attribute4                in varchar2,
                        p_attribute5                in varchar2,
                        p_attribute6                in varchar2,
                        p_attribute7                in varchar2,
                        p_attribute8                in varchar2,
                        p_attribute9                in varchar2,
                        p_attribute10               in varchar2,
                        p_attribute11               in varchar2,
                        p_attribute12               in varchar2,
                        p_attribute13               in varchar2,
                        p_attribute14               in varchar2,
                        p_attribute15               in varchar2,
                        p_attribute16               in varchar2,
                        p_attribute17               in varchar2,
                        p_attribute18               in varchar2,
                        p_attribute19               in varchar2,
                        p_attribute20               in varchar2,
                        p_global_attribute_category in varchar2,
                        p_global_attribute1         in varchar2,
                        p_global_attribute2         in varchar2,
                        p_global_attribute3         in varchar2,
                        p_global_attribute4         in varchar2,
                        p_global_attribute5         in varchar2,
                        p_global_attribute6         in varchar2,
                        p_global_attribute7         in varchar2,
                        p_global_attribute8         in varchar2,
                        p_global_attribute9         in varchar2,
                        p_global_attribute10        in varchar2,
                        p_global_attribute11        in varchar2,
                        p_global_attribute12        in varchar2,
                        p_global_attribute13        in varchar2,
                        p_global_attribute14        in varchar2,
                        p_global_attribute15        in varchar2,
                        p_global_attribute16        in varchar2,
                        p_global_attribute17        in varchar2,
                        p_global_attribute18        in varchar2,
                        p_global_attribute19        in varchar2,
                        p_global_attribute20        in varchar2,
                        p_loc_information18         in varchar2,
                        p_loc_information19         in varchar2,
                        p_loc_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       ) is
begin
  p_derived_locale := p_town_or_city || ', ' || p_country;
end;
--
procedure DERIVE_PER_ADD_ADDRESS
                       (p_style                     in varchar2,
                        p_address_line1             in varchar2,
                        p_address_line2             in varchar2,
                        p_address_line3             in varchar2,
                        p_country                   in varchar2,
                        p_date_to                   in date,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_town_or_city              in varchar2,
                        p_addr_attribute_category   in varchar2,
                        p_addr_attribute1           in varchar2,
                        p_addr_attribute2           in varchar2,
                        p_addr_attribute3           in varchar2,
                        p_addr_attribute4           in varchar2,
                        p_addr_attribute5           in varchar2,
                        p_addr_attribute6           in varchar2,
                        p_addr_attribute7           in varchar2,
                        p_addr_attribute8           in varchar2,
                        p_addr_attribute9           in varchar2,
                        p_addr_attribute10          in varchar2,
                        p_addr_attribute11          in varchar2,
                        p_addr_attribute12          in varchar2,
                        p_addr_attribute13          in varchar2,
                        p_addr_attribute14          in varchar2,
                        p_addr_attribute15          in varchar2,
                        p_addr_attribute16          in varchar2,
                        p_addr_attribute17          in varchar2,
                        p_addr_attribute18          in varchar2,
                        p_addr_attribute19          in varchar2,
                        p_addr_attribute20          in varchar2,
                        p_add_information13         in varchar2,
                        p_add_information14         in varchar2,
                        p_add_information15         in varchar2,
                        p_add_information16         in varchar2,
			p_add_information17         in varchar2,
                        p_add_information18         in varchar2,
                        p_add_information19         in varchar2,
                        p_add_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       ) is
begin
  p_derived_locale := p_town_or_city || ', ' ||
                      p_region_2 || ', ' ||
                      p_country;

end;
--
FUNCTION per_gb_full_name(

        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in VARCHAR2
                         )
                          RETURN VARCHAR2 IS
--
l_full_name per_all_people_f.full_name%TYPE;
--
l_title hr_lookups.meaning%TYPE;
l_part2 varchar2(240);
BEGIN
  --
-- bug fix for 2504672
/*
  l_full_name := substr(p_last_name||', '||p_title||' '||
                 p_first_name ||' '||p_middle_names,1,240);
*/

-- bug fix for 2581959
  if p_title IS NOT NULL and
      fnd_profile.value('PER_USE_TITLE_IN_FULL_NAME') = 'Y' then
      SELECT meaning
      INTO   l_title
      FROM   hr_lookups
      WHERE  lookup_type = 'TITLE'
      AND    p_title     = lookup_code
      AND    application_id = 800;
  end if;

/********************************************
* Bug 2581959 -                             *
*******************************************/

/*
select trim(
           substr(
         decode(l_title,'','',null,'',l_title || ' ')      ||
         decode(p_first_name,'','',null,'',p_first_name || ' ') ||
         decode(p_middle_names,'','',null,'',p_middle_names) ,
            1,240)
             )
    into l_part2 from dual;

  if length(l_part2) > 1 then
      select trim(substr(decode(p_last_name,'','',null,'',p_last_name || ', ') || l_part2,1,240))
         into l_full_name from dual;
  else
      Select trim(substr(decode(p_last_name,'','',null,'',p_last_name),1,240))
         into l_full_name from dual;
  end if;
*/

-- Note this is only a select because PL/SQL can't cope with DECODEs
--
  SELECT rtrim(substrb(DECODE(p_pre_name_adjunct,'','',p_pre_name_adjunct||' ')||
                      p_last_name||','||DECODE(l_title,'','',
                      ' '||l_title)||DECODE(p_first_name,'','',
                      ' '||p_first_name)||DECODE(p_middle_names,'','',
                      ' '||p_middle_names)||
                      DECODE(p_suffix,'','',' '||p_suffix)||
                      DECODE(p_known_as,'','',
                      ' ('||p_known_as||')'),1,240))
  INTO  l_full_name
  FROM sys.dual ;
--
--

return l_full_name;
--
END;
--
END HR_GB_UTILITY;

/
