--------------------------------------------------------
--  DDL for Package Body PAY_BATCH_ELEMENT_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BATCH_ELEMENT_ENTRY_API" as
/* $Header: pybthapi.pkb 120.3.12010000.4 2009/11/17 08:39:53 priupadh ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_batch_element_entry_api.';
--
--
function get_upgrade_status
   (p_batch_id          number
   ,p_batch_line_id     number
   ,p_short_name        varchar2
   )return varchar2 is
   --
   l_status pay_upgrade_status.status%type;
   l_business_group_id pay_batch_headers.business_group_id%TYPE;
   --
   cursor csr_bg_id is
      select bth.business_group_id
        from pay_batch_headers bth
       where bth.batch_id = p_batch_id
       union all
      select bth.business_group_id
        from pay_batch_headers bth,
             pay_batch_lines btl
       where bth.batch_id = btl.batch_id
         and btl.batch_line_id = p_batch_line_id;
   --
begin
   --
   open csr_bg_id;
   fetch csr_bg_id into l_business_group_id;
   close csr_bg_id;
   --
   pay_core_utils.get_upgrade_status(l_business_group_id,p_short_name,l_status);
   --
   return l_status;
   --
exception
   when others then
   --
   return 'E';
   --
end;
--
-- -------------------------------------------------------------------------
-- Procedure to convert input values from display format to internal format.
-- -------------------------------------------------------------------------
function convert_display_to_internal
  (p_input_value     varchar2,
   p_uom_value       varchar2,
   p_lookup_type     varchar2,
   p_value_set_id    number,
   p_currency_code   varchar2)
   return varchar2 is
--
   l_display_value   varchar2(80) := p_input_value;
   l_formatted_value varchar2(80) := p_input_value;
   l_dummy           varchar2(100);
   --
   cursor csr_valid_lookup
          (p_lookup_type varchar2,
           p_meaning     varchar2) is
       select HL.lookup_code
         from hr_lookups HL
        where HL.lookup_type = p_lookup_type
          and HL.meaning     = p_meaning;
--
begin
--
   if (p_lookup_type is not null and
       l_display_value is not null) then
      --
      open csr_valid_lookup(p_lookup_type, l_display_value);
      fetch csr_valid_lookup into l_formatted_value ;
      --
      if csr_valid_lookup%NOTFOUND then
         close csr_valid_lookup;
         raise no_data_found;
      end if;
      --
      close csr_valid_lookup;
      --
   elsif (p_value_set_id is not null and
          l_display_value is not null) then
      --
      l_formatted_value := pay_input_values_pkg.decode_vset_meaning(
                           p_value_set_id, l_display_value);
      --
      if l_formatted_value is null then
         raise no_data_found;
      end if;
      --
   else
      --
      hr_chkfmt.checkformat (
         l_display_value, 		/* the value to be formatted (out - display) */
         p_uom_value,			/* the format to check */
         l_formatted_value, 	/* the formatted value on output (out - canonical) */
         null, 				/* minimum value (can be null) */
         null,		 		    /* maximum value (can be null) */
         'Y', 				    /* is ok to be null ? */
         l_dummy,              /* used for range checking */
         p_currency_code );
      --
   end if;
   --
   return l_formatted_value;
--
exception
   when others then
      fnd_message.set_name ('PAY','PAY_6306_INPUT_VALUE_FORMAT');
      fnd_message.set_token ('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', p_uom_value ));
      fnd_message.raise_error;
--
end convert_display_to_internal;
--
-- -------------------------------------------------------------------------------
-- Procedure to convert date input values from display format to canonical format.
-- -------------------------------------------------------------------------------
procedure convert_date_to_canonical
  (p_iv1               in out nocopy varchar2
  ,p_iv2               in out nocopy varchar2
  ,p_iv3               in out nocopy varchar2
  ,p_iv4               in out nocopy varchar2
  ,p_iv5               in out nocopy varchar2
  ,p_iv6               in out nocopy varchar2
  ,p_iv7               in out nocopy varchar2
  ,p_iv8               in out nocopy varchar2
  ,p_iv9               in out nocopy varchar2
  ,p_iv10              in out nocopy varchar2
  ,p_iv11              in out nocopy varchar2
  ,p_iv12              in out nocopy varchar2
  ,p_iv13              in out nocopy varchar2
  ,p_iv14              in out nocopy varchar2
  ,p_iv15              in out nocopy varchar2
  ,p_element_type_id   in number
  ,p_element_name      in varchar2
  ,p_batch_id          in number        default null
  ,p_effective_date    in date
  ,p_batch_line_id     in number        default null
  ,p_date_cfmt         in varchar2
  ,p_int_fmt           in varchar2
  ) is
  --
  cursor csr_table_inp_ids(p_ele_type_id number
                          ,p_eff_date    date) is
       select inv.uom,inv.lookup_type,inv.value_set_id
       from   pay_input_values_f  inv
       where  inv.element_type_id   = p_ele_type_id
       and    p_eff_date between inv.effective_start_date
                         and     inv.effective_end_date
       order by inv.display_sequence
       ,        inv.name;
  --
  l_uom               pay_input_values_f.uom%TYPE;
  --
  l_lookup_type       pay_input_values_f.lookup_type%TYPE;
  l_value_set_id      pay_input_values_f.value_set_id%TYPE;
  l_input_curr_code   pay_element_types_f.input_currency_code%TYPE;
  --
  l_element_type_id   pay_element_types_f.element_type_id%TYPE := null;
  l_element_name      pay_element_types_f.element_name%TYPE := null;
  l_count             number := 0;
  l_legislation_code  per_business_groups.legislation_code%TYPE := null;
  l_business_group_id per_business_groups.business_group_id%TYPE;
  l_batch_id          pay_batch_lines.batch_id%TYPE;
  l_effective_date    pay_batch_lines.effective_date%TYPE;
  --

  lv_dummy           varchar2(100);
  cursor csr_element_type (p_ele_name     varchar2
                          ,p_bus_group_id number
                          ,p_leg_code     varchar2
                          ,p_eff_date     date
                          ,p_ele_id       number) is
       select pet.element_type_id,pet.input_currency_code
         from pay_element_types_f pet
        where p_ele_id is null
          and upper(pet.element_name) = upper(p_ele_name)
          and p_eff_date between pet.effective_start_date
                         and     pet.effective_end_date
          and (pet.business_group_id = p_bus_group_id
                 or (pet.business_group_id is null
                     and pet.legislation_code = p_leg_code)
                 or (pet.business_group_id is null
                     and pet.legislation_code is null))
       union all
       select pet.element_type_id,pet.input_currency_code
         from pay_element_types_f pet
        where p_ele_id is not null
          and pet.element_type_id = p_ele_id
          and p_eff_date between pet.effective_start_date
                         and     pet.effective_end_date;
  --
  l_proc        varchar2(72) := g_package||'convert_date_to_canonical';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_effective_date = hr_api.g_date then
     select effective_date
       into l_effective_date
       from pay_batch_lines pbl
      where pbl.batch_line_id = p_batch_line_id;
  else
     l_effective_date := p_effective_date;
  end if;
  --
  if (p_element_type_id = hr_api.g_number) then
     select pbl.element_type_id
       into l_element_type_id
       from pay_batch_lines pbl
      where pbl.batch_line_id = p_batch_line_id;
  else
     l_element_type_id := p_element_type_id;
  end if;
  --
  if (l_element_type_id is null) then
     --
     if (p_batch_id is null and p_batch_line_id is not null) then
        select pbl.batch_id
          into l_batch_id
          from pay_batch_lines pbl
         where pbl.batch_line_id = p_batch_line_id;
     else
        l_batch_id := p_batch_id;
     end if;
     --
     if p_element_name = hr_api.g_varchar2 then
        select pbl.element_name
          into l_element_name
          from pay_batch_lines pbl
         where pbl.batch_line_id = p_batch_line_id;
     else
         l_element_name := p_element_name;
     end if;
     --
     select pbg.business_group_id,pbg.legislation_code
       into l_business_group_id,l_legislation_code
       from per_business_groups pbg,
            pay_batch_headers pbh
      where pbh.batch_id = l_batch_id
        and pbg.business_group_id = pbh.business_group_id;
     --
     open csr_element_type(l_element_name
                          ,l_business_group_id
                          ,l_legislation_code
                          ,l_effective_date
                          ,l_element_type_id);
     fetch csr_element_type into l_element_type_id,l_input_curr_code;
     close csr_element_type;
     --
  else
     --
     open csr_element_type(l_element_name
                          ,l_business_group_id
                          ,l_legislation_code
                          ,l_effective_date
                          ,l_element_type_id);
     fetch csr_element_type into l_element_type_id,l_input_curr_code;
     close csr_element_type;
     --
  end if;
  --
  open csr_table_inp_ids(l_element_type_id,l_effective_date);
  --
  loop
    fetch csr_table_inp_ids into l_uom,l_lookup_type,l_value_set_id;
    exit when csr_table_inp_ids%NOTFOUND;
    --
    l_count := l_count +1;
    --
    if l_count > 15 then
       exit;
    end if;
    --
    -- Only convert the date if the input value is of date format, as well as the
    -- input value is not defaulted or the intented format is canonical but the passed
    -- value might be DD-MON-YYYY or DD-MON-YY format or they are specifically stated as
    -- non-canonical format.
    if (l_count = 1
        and p_iv1 <> hr_api.g_varchar2
        and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv1,'-',1,2) <> 0)
             or (l_uom = 'D' and p_date_cfmt = 'N')
             or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv1,'/',1,2) <> 0 then
          p_iv1:=to_char(to_date(p_iv1,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv1,l_uom,p_iv1,null,null,'Y',lv_dummy,l_input_curr_code );
       else
       --
          p_iv1 := convert_display_to_internal(p_iv1,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
       --
       end if;
    elsif (l_count = 2
           and p_iv2 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv2,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv2,'/',1,2) <> 0 then
          p_iv2 :=to_char(to_date(p_iv2,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv2,l_uom,p_iv2,null,null,'Y',lv_dummy,l_input_curr_code );
       else
           --
          p_iv2 := convert_display_to_internal(p_iv2,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 3
           and p_iv3 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv3,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv3,'/',1,2) <> 0 then
          p_iv3 :=to_char(to_date(p_iv3,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv3,l_uom,p_iv3,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv3 := convert_display_to_internal(p_iv3,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 4
           and p_iv4 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv4,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv4,'/',1,2) <> 0 then
          p_iv4 :=to_char(to_date(p_iv4,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv4,l_uom,p_iv4,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv4 := convert_display_to_internal(p_iv4,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 5
           and p_iv5 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv5,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv5,'/',1,2) <> 0 then
          p_iv5 :=to_char(to_date(p_iv5,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv5,l_uom,p_iv5,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv5 := convert_display_to_internal(p_iv5,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 6
           and p_iv6 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv6,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv6,'/',1,2) <> 0 then
          p_iv6 :=to_char(to_date(p_iv6,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv6,l_uom,p_iv6,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv6 := convert_display_to_internal(p_iv6,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 7
           and p_iv7 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv7,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv7,'/',1,2) <> 0 then
          p_iv7 :=to_char(to_date(p_iv7,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv7,l_uom,p_iv7,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv7 := convert_display_to_internal(p_iv7,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 8
           and p_iv8 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv8,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv8,'/',1,2) <> 0 then
          p_iv8 :=to_char(to_date(p_iv8,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv8,l_uom,p_iv8,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv8 := convert_display_to_internal(p_iv8,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 9
           and p_iv9 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv9,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv9,'/',1,2) <> 0 then
          p_iv9 :=to_char(to_date(p_iv9,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv9,l_uom,p_iv9,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv9 := convert_display_to_internal(p_iv9,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 10
           and p_iv10 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv10,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv10,'/',1,2) <> 0 then
          p_iv10 :=to_char(to_date(p_iv10,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv10,l_uom,p_iv10,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv10 := convert_display_to_internal(p_iv10,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 11
           and p_iv11 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv11,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv11,'/',1,2) <> 0 then
          p_iv11 :=to_char(to_date(p_iv11,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv11,l_uom,p_iv11,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv11 := convert_display_to_internal(p_iv11,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 12
           and p_iv12 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv12,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv12,'/',1,2) <> 0 then
          p_iv12 :=to_char(to_date(p_iv12,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv12,l_uom,p_iv12,null,null,'Y',lv_dummy,l_input_curr_code );
       else
           --
          p_iv12 := convert_display_to_internal(p_iv12,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 13
           and p_iv13 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv13,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv13,'/',1,2) <> 0 then
          p_iv13 :=to_char(to_date(p_iv13,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv13,l_uom,p_iv13,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv13 := convert_display_to_internal(p_iv13,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 14
           and p_iv14 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv14,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv14,'/',1,2) <> 0 then
          p_iv14 :=to_char(to_date(p_iv14,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv14,l_uom,p_iv14,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv14 := convert_display_to_internal(p_iv14,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    elsif (l_count = 15
           and p_iv15 <> hr_api.g_varchar2
           and ((l_uom = 'D' and p_date_cfmt = 'Y' and instr(p_iv15,'-',1,2) <> 0)
                or (l_uom = 'D' and p_date_cfmt = 'N')
                or (l_uom <> 'D'))) then
       /*Bug 8873865 */
       If l_uom = 'D' and p_date_cfmt = 'N' and instr(p_iv15,'/',1,2) <> 0 then
          p_iv15 :=to_char(to_date(p_iv15,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
       end if;

       If (l_uom <> 'D' and p_int_fmt = 'N' ) then
          hr_chkfmt.checkformat (p_iv15,l_uom,p_iv15,null,null,'Y',lv_dummy,l_input_curr_code );
       else
          --
          p_iv15 := convert_display_to_internal(p_iv15,l_uom,l_lookup_type,l_value_set_id,l_input_curr_code);
          --
       end if;
    end if;
    --
  end loop;
  --
  close csr_table_inp_ids;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
exception
  when others then
    --fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    --fnd_message.set_token('PROCEDURE', l_proc);
    --fnd_message.set_token('STEP','10');
    --fnd_message.raise_error;
    fnd_message.set_name ('PAY','PAY_6306_INPUT_VALUE_FORMAT');
    fnd_message.set_token ('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', l_uom ));
    fnd_message.raise_error;
end convert_date_to_canonical;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_header >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_header
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_name                    in     varchar2
  ,p_batch_status                  in     varchar2 default 'U'
  ,p_business_group_id             in     number
  ,p_action_if_exists              in     varchar2 default 'R'
  ,p_batch_reference               in     varchar2 default null
  ,p_batch_source                  in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_date_effective_changes        in     varchar2 default null
  ,p_purge_after_transfer          in     varchar2 default 'N'
  ,p_reject_if_future_changes      in     varchar2 default 'Y'
  ,p_batch_id                         out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_reject_if_results_exists      in     varchar2 default 'Y'
  ,p_purge_after_rollback          in     varchar2 default 'N'
  ,p_batch_type                    in     varchar2 default null
  ,p_REJECT_ENTRY_NOT_REMOVED      in     varchar2 default 'N'
  ,p_ROLLBACK_ENTRY_UPDATES        in     varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_batch_header';
  l_batch_id               pay_batch_headers.batch_id%TYPE;
  l_object_version_number  pay_batch_headers.object_version_number%TYPE;
  l_session_date           date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_batch_header;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_session_date := trunc(p_session_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk1.create_batch_header_b
      (p_session_date                   => l_session_date
      ,p_batch_name                     => p_batch_name
      ,p_batch_status                   => p_batch_status
      ,p_business_group_id              => p_business_group_id
      ,p_action_if_exists               => p_action_if_exists
      ,p_batch_reference                => p_batch_reference
      ,p_batch_source                   => p_batch_source
      ,p_comments                       => p_comments
      ,p_date_effective_changes         => p_date_effective_changes
      ,p_purge_after_transfer           => p_purge_after_transfer
      ,p_reject_if_future_changes       => p_reject_if_future_changes
      ,p_reject_if_results_exists       => p_reject_if_results_exists
      ,p_purge_after_rollback           => p_purge_after_rollback
      ,p_batch_type                     => p_batch_type
      ,p_REJECT_ENTRY_NOT_REMOVED       => p_REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES         => p_ROLLBACK_ENTRY_UPDATES
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_batch_header_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_bth_ins.ins
      (p_session_date             => l_session_date
      ,p_business_group_id        => p_business_group_id
      ,p_batch_name               => p_batch_name
      ,p_batch_status             => p_batch_status
      ,p_action_if_exists         => p_action_if_exists
      ,p_batch_reference          => p_batch_reference
      ,p_batch_source             => p_batch_source
      ,p_batch_type               => p_batch_type
      ,p_comments                 => p_comments
      ,p_date_effective_changes   => p_date_effective_changes
      ,p_purge_after_transfer     => p_purge_after_transfer
      ,p_reject_if_future_changes => p_reject_if_future_changes
      ,p_reject_if_results_exists => p_reject_if_results_exists
      ,p_purge_after_rollback     => p_purge_after_rollback
      ,p_REJECT_ENTRY_NOT_REMOVED => p_REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES   => p_ROLLBACK_ENTRY_UPDATES
      ,p_batch_id                 => l_batch_id
      ,p_object_version_number    => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk1.create_batch_header_a
      (p_session_date                   => l_session_date
      ,p_batch_name                     => p_batch_name
      ,p_batch_status                   => p_batch_status
      ,p_business_group_id              => p_business_group_id
      ,p_action_if_exists               => p_action_if_exists
      ,p_batch_reference                => p_batch_reference
      ,p_batch_source                   => p_batch_source
      ,p_comments                       => p_comments
      ,p_date_effective_changes         => p_date_effective_changes
      ,p_purge_after_transfer           => p_purge_after_transfer
      ,p_reject_if_future_changes       => p_reject_if_future_changes
      ,p_batch_id                       => l_batch_id
      ,p_object_version_number          => l_object_version_number
      ,p_reject_if_results_exists       => p_reject_if_results_exists
      ,p_purge_after_rollback           => p_purge_after_rollback
      ,p_batch_type                     => p_batch_type
      ,p_REJECT_ENTRY_NOT_REMOVED       => p_REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES         => p_ROLLBACK_ENTRY_UPDATES
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_batch_header_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_batch_id               := l_batch_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_batch_header;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_batch_id               := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_batch_header;
    p_batch_id               := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_batch_header;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_batch_line >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_line
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_batch_line_status             in     varchar2 default 'U'
  ,p_assignment_id                 in     number   default null
  ,p_assignment_number             in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_entry_information_category    in     varchar2 default null
  ,p_entry_information1            in     varchar2 default null
  ,p_entry_information2            in     varchar2 default null
  ,p_entry_information3            in     varchar2 default null
  ,p_entry_information4            in     varchar2 default null
  ,p_entry_information5            in     varchar2 default null
  ,p_entry_information6            in     varchar2 default null
  ,p_entry_information7            in     varchar2 default null
  ,p_entry_information8            in     varchar2 default null
  ,p_entry_information9            in     varchar2 default null
  ,p_entry_information10           in     varchar2 default null
  ,p_entry_information11           in     varchar2 default null
  ,p_entry_information12           in     varchar2 default null
  ,p_entry_information13           in     varchar2 default null
  ,p_entry_information14           in     varchar2 default null
  ,p_entry_information15           in     varchar2 default null
  ,p_entry_information16           in     varchar2 default null
  ,p_entry_information17           in     varchar2 default null
  ,p_entry_information18           in     varchar2 default null
  ,p_entry_information19           in     varchar2 default null
  ,p_entry_information20           in     varchar2 default null
  ,p_entry_information21           in     varchar2 default null
  ,p_entry_information22           in     varchar2 default null
  ,p_entry_information23           in     varchar2 default null
  ,p_entry_information24           in     varchar2 default null
  ,p_entry_information25           in     varchar2 default null
  ,p_entry_information26           in     varchar2 default null
  ,p_entry_information27           in     varchar2 default null
  ,p_entry_information28           in     varchar2 default null
  ,p_entry_information29           in     varchar2 default null
  ,p_entry_information30           in     varchar2 default null
  ,p_date_earned                   in     date     default null
  ,p_personal_payment_method_id    in     number   default null
  ,p_subpriority                   in     number   default null
  ,p_batch_sequence                in     number   default null
  ,p_concatenated_segments         in     varchar2 default null
  ,p_cost_allocation_keyflex_id    in     number   default null
  ,p_effective_date                in     date     default null
  ,p_effective_start_date          in     date     default null
  ,p_effective_end_date            in     date     default null
  ,p_element_name                  in     varchar2 default null
  ,p_element_type_id               in     number   default null
  ,p_entry_type                    in     varchar2 default null
  ,p_reason                        in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_value_1                       in     varchar2 default null
  ,p_value_2                       in     varchar2 default null
  ,p_value_3                       in     varchar2 default null
  ,p_value_4                       in     varchar2 default null
  ,p_value_5                       in     varchar2 default null
  ,p_value_6                       in     varchar2 default null
  ,p_value_7                       in     varchar2 default null
  ,p_value_8                       in     varchar2 default null
  ,p_value_9                       in     varchar2 default null
  ,p_value_10                      in     varchar2 default null
  ,p_value_11                      in     varchar2 default null
  ,p_value_12                      in     varchar2 default null
  ,p_value_13                      in     varchar2 default null
  ,p_value_14                      in     varchar2 default null
  ,p_value_15                      in     varchar2 default null
  ,p_canonical_date_format         in     varchar2 default 'Y'
  ,p_iv_all_internal_format        in     varchar2 default 'N'
  ,p_batch_line_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_batch_line';
  l_batch_line_id          pay_batch_lines.batch_line_id%TYPE;
  l_object_version_number  pay_batch_lines.object_version_number%TYPE;
  l_session_date           date;
  l_effective_date         date;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_date_earned            date;
  --
  l_value_1                pay_batch_lines.value_1%TYPE := p_value_1;
  l_value_2                pay_batch_lines.value_2%TYPE := p_value_2;
  l_value_3                pay_batch_lines.value_3%TYPE := p_value_3;
  l_value_4                pay_batch_lines.value_4%TYPE := p_value_4;
  l_value_5                pay_batch_lines.value_5%TYPE := p_value_5;
  l_value_6                pay_batch_lines.value_6%TYPE := p_value_6;
  l_value_7                pay_batch_lines.value_7%TYPE := p_value_7;
  l_value_8                pay_batch_lines.value_8%TYPE := p_value_8;
  l_value_9                pay_batch_lines.value_9%TYPE := p_value_9;
  l_value_10               pay_batch_lines.value_10%TYPE := p_value_10;
  l_value_11               pay_batch_lines.value_11%TYPE := p_value_11;
  l_value_12               pay_batch_lines.value_12%TYPE := p_value_12;
  l_value_13               pay_batch_lines.value_13%TYPE := p_value_13;
  l_value_14               pay_batch_lines.value_14%TYPE := p_value_14;
  l_value_15               pay_batch_lines.value_15%TYPE := p_value_15;
  --
  l_bee_iv_upgrade  varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_batch_line;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_session_date         := trunc(p_session_date);
  --l_effective_date       := trunc(p_effective_date);
/*If effective date is not passed, then we are setting the session date
    passed as effective date.*/
  if (p_effective_date is null) then
      l_effective_date := trunc(p_session_date);
  else
      l_effective_date := trunc(p_effective_date);
  end if;
  l_effective_start_date := trunc(p_effective_start_date);
  l_effective_end_date   := trunc(p_effective_end_date);
  l_date_earned          := trunc(p_date_earned);
  --
  l_bee_iv_upgrade := get_upgrade_status(p_batch_id,null,'BEE_IV_UPG');
  --
  -- Check whether the upgrade process is in progress.
  --
  if l_bee_iv_upgrade = 'E' then
     hr_utility.set_message(800, 'HR_449106_BEE_UPGRADING');
     hr_utility.raise_error;
  end if;
  --
  if p_iv_all_internal_format = 'Y' and l_bee_iv_upgrade = 'N' then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME','P_IV_ALL_INTERNAL_FORMAT');
    fnd_message.raise_error;
  end if;
  --
  if p_iv_all_internal_format = 'Y' and p_canonical_date_format = 'N' then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME','P_CANONICAL_DATE_FORMAT');
    fnd_message.raise_error;
  end if;
  --
  --
  if p_iv_all_internal_format <> 'Y' then
     convert_date_to_canonical
     (p_iv1               => l_value_1
     ,p_iv2               => l_value_2
     ,p_iv3               => l_value_3
     ,p_iv4               => l_value_4
     ,p_iv5               => l_value_5
     ,p_iv6               => l_value_6
     ,p_iv7               => l_value_7
     ,p_iv8               => l_value_8
     ,p_iv9               => l_value_9
     ,p_iv10              => l_value_10
     ,p_iv11              => l_value_11
     ,p_iv12              => l_value_12
     ,p_iv13              => l_value_13
     ,p_iv14              => l_value_14
     ,p_iv15              => l_value_15
     ,p_element_type_id   => p_element_type_id
     ,p_element_name      => p_element_name
     ,p_batch_id          => p_batch_id
     ,p_effective_date    => l_effective_date
     ,p_date_cfmt         => p_canonical_date_format
     ,p_int_fmt           => l_bee_iv_upgrade
     );
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk2.create_batch_line_b
      (p_session_date                   => l_session_date
      ,p_batch_id                       => p_batch_id
      ,p_batch_line_status              => p_batch_line_status
      ,p_assignment_id                  => p_assignment_id
      ,p_assignment_number              => p_assignment_number
      ,p_attribute_category             => p_attribute_category
      ,p_attribute1                     => p_attribute1
      ,p_attribute2                     => p_attribute2
      ,p_attribute3                     => p_attribute3
      ,p_attribute4                     => p_attribute4
      ,p_attribute5                     => p_attribute5
      ,p_attribute6                     => p_attribute6
      ,p_attribute7                     => p_attribute7
      ,p_attribute8                     => p_attribute8
      ,p_attribute9                     => p_attribute9
      ,p_attribute10                    => p_attribute10
      ,p_attribute11                    => p_attribute11
      ,p_attribute12                    => p_attribute12
      ,p_attribute13                    => p_attribute13
      ,p_attribute14                    => p_attribute14
      ,p_attribute15                    => p_attribute15
      ,p_attribute16                    => p_attribute16
      ,p_attribute17                    => p_attribute17
      ,p_attribute18                    => p_attribute18
      ,p_attribute19                    => p_attribute19
      ,p_attribute20                    => p_attribute20
      ,p_entry_information_category     => p_entry_information_category
      ,p_entry_information1             => p_entry_information1
      ,p_entry_information2             => p_entry_information2
      ,p_entry_information3             => p_entry_information3
      ,p_entry_information4             => p_entry_information4
      ,p_entry_information5             => p_entry_information5
      ,p_entry_information6             => p_entry_information6
      ,p_entry_information7             => p_entry_information7
      ,p_entry_information8             => p_entry_information8
      ,p_entry_information9             => p_entry_information9
      ,p_entry_information10            => p_entry_information10
      ,p_entry_information11            => p_entry_information11
      ,p_entry_information12            => p_entry_information12
      ,p_entry_information13            => p_entry_information13
      ,p_entry_information14            => p_entry_information14
      ,p_entry_information15            => p_entry_information15
      ,p_entry_information16            => p_entry_information16
      ,p_entry_information17            => p_entry_information17
      ,p_entry_information18            => p_entry_information18
      ,p_entry_information19            => p_entry_information19
      ,p_entry_information20            => p_entry_information20
      ,p_entry_information21            => p_entry_information21
      ,p_entry_information22            => p_entry_information22
      ,p_entry_information23            => p_entry_information23
      ,p_entry_information24            => p_entry_information24
      ,p_entry_information25            => p_entry_information25
      ,p_entry_information26            => p_entry_information26
      ,p_entry_information27            => p_entry_information27
      ,p_entry_information28            => p_entry_information28
      ,p_entry_information29            => p_entry_information29
      ,p_entry_information30            => p_entry_information30
      ,p_date_earned                    => l_date_earned
      ,p_personal_payment_method_id     => p_personal_payment_method_id
      ,p_subpriority                    => p_subpriority
      ,p_batch_sequence                 => p_batch_sequence
      ,p_concatenated_segments          => p_concatenated_segments
      ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
      ,p_effective_date                 => l_effective_date
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_element_name                   => p_element_name
      ,p_element_type_id                => p_element_type_id
      ,p_entry_type                     => p_entry_type
      ,p_reason                         => p_reason
      ,p_segment1                       => p_segment1
      ,p_segment2                       => p_segment2
      ,p_segment3                       => p_segment3
      ,p_segment4                       => p_segment4
      ,p_segment5                       => p_segment5
      ,p_segment6                       => p_segment6
      ,p_segment7                       => p_segment7
      ,p_segment8                       => p_segment8
      ,p_segment9                       => p_segment9
      ,p_segment10                      => p_segment10
      ,p_segment11                      => p_segment11
      ,p_segment12                      => p_segment12
      ,p_segment13                      => p_segment13
      ,p_segment14                      => p_segment14
      ,p_segment15                      => p_segment15
      ,p_segment16                      => p_segment16
      ,p_segment17                      => p_segment17
      ,p_segment18                      => p_segment18
      ,p_segment19                      => p_segment19
      ,p_segment20                      => p_segment20
      ,p_segment21                      => p_segment21
      ,p_segment22                      => p_segment22
      ,p_segment23                      => p_segment23
      ,p_segment24                      => p_segment24
      ,p_segment25                      => p_segment25
      ,p_segment26                      => p_segment26
      ,p_segment27                      => p_segment27
      ,p_segment28                      => p_segment28
      ,p_segment29                      => p_segment29
      ,p_segment30                      => p_segment30
      ,p_value_1                        => l_value_1
      ,p_value_2                        => l_value_2
      ,p_value_3                        => l_value_3
      ,p_value_4                        => l_value_4
      ,p_value_5                        => l_value_5
      ,p_value_6                        => l_value_6
      ,p_value_7                        => l_value_7
      ,p_value_8                        => l_value_8
      ,p_value_9                        => l_value_9
      ,p_value_10                       => l_value_10
      ,p_value_11                       => l_value_11
      ,p_value_12                       => l_value_12
      ,p_value_13                       => l_value_13
      ,p_value_14                       => l_value_14
      ,p_value_15                       => l_value_15
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_batch_line_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_btl_ins.ins
      (p_session_date                => l_session_date
      ,p_batch_id                    => p_batch_id
      ,p_batch_line_status           => p_batch_line_status
      ,p_cost_allocation_keyflex_id  => p_cost_allocation_keyflex_id
      ,p_element_type_id             => p_element_type_id
      ,p_assignment_id               => p_assignment_id
      ,p_assignment_number           => p_assignment_number
      ,p_batch_sequence              => p_batch_sequence
      ,p_concatenated_segments       => p_concatenated_segments
      ,p_effective_date              => l_effective_date
      ,p_element_name                => p_element_name
      ,p_entry_type                  => p_entry_type
      ,p_reason                      => p_reason
      ,p_segment1                    => p_segment1
      ,p_segment2                    => p_segment2
      ,p_segment3                    => p_segment3
      ,p_segment4                    => p_segment4
      ,p_segment5                    => p_segment5
      ,p_segment6                    => p_segment6
      ,p_segment7                    => p_segment7
      ,p_segment8                    => p_segment8
      ,p_segment9                    => p_segment9
      ,p_segment10                   => p_segment10
      ,p_segment11                   => p_segment11
      ,p_segment12                   => p_segment12
      ,p_segment13                   => p_segment13
      ,p_segment14                   => p_segment14
      ,p_segment15                   => p_segment15
      ,p_segment16                   => p_segment16
      ,p_segment17                   => p_segment17
      ,p_segment18                   => p_segment18
      ,p_segment19                   => p_segment19
      ,p_segment20                   => p_segment20
      ,p_segment21                   => p_segment21
      ,p_segment22                   => p_segment22
      ,p_segment23                   => p_segment23
      ,p_segment24                   => p_segment24
      ,p_segment25                   => p_segment25
      ,p_segment26                   => p_segment26
      ,p_segment27                   => p_segment27
      ,p_segment28                   => p_segment28
      ,p_segment29                   => p_segment29
      ,p_segment30                   => p_segment30
      ,p_value_1                     => l_value_1
      ,p_value_2                     => l_value_2
      ,p_value_3                     => l_value_3
      ,p_value_4                     => l_value_4
      ,p_value_5                     => l_value_5
      ,p_value_6                     => l_value_6
      ,p_value_7                     => l_value_7
      ,p_value_8                     => l_value_8
      ,p_value_9                     => l_value_9
      ,p_value_10                    => l_value_10
      ,p_value_11                    => l_value_11
      ,p_value_12                    => l_value_12
      ,p_value_13                    => l_value_13
      ,p_value_14                    => l_value_14
      ,p_value_15                    => l_value_15
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_entry_information_category  => p_entry_information_category
      ,p_entry_information1          => p_entry_information1
      ,p_entry_information2          => p_entry_information2
      ,p_entry_information3          => p_entry_information3
      ,p_entry_information4          => p_entry_information4
      ,p_entry_information5          => p_entry_information5
      ,p_entry_information6          => p_entry_information6
      ,p_entry_information7          => p_entry_information7
      ,p_entry_information8          => p_entry_information8
      ,p_entry_information9          => p_entry_information9
      ,p_entry_information10         => p_entry_information10
      ,p_entry_information11         => p_entry_information11
      ,p_entry_information12         => p_entry_information12
      ,p_entry_information13         => p_entry_information13
      ,p_entry_information14         => p_entry_information14
      ,p_entry_information15         => p_entry_information15
      ,p_entry_information16         => p_entry_information16
      ,p_entry_information17         => p_entry_information17
      ,p_entry_information18         => p_entry_information18
      ,p_entry_information19         => p_entry_information19
      ,p_entry_information20         => p_entry_information20
      ,p_entry_information21         => p_entry_information21
      ,p_entry_information22         => p_entry_information22
      ,p_entry_information23         => p_entry_information23
      ,p_entry_information24         => p_entry_information24
      ,p_entry_information25         => p_entry_information25
      ,p_entry_information26         => p_entry_information26
      ,p_entry_information27         => p_entry_information27
      ,p_entry_information28         => p_entry_information28
      ,p_entry_information29         => p_entry_information29
      ,p_entry_information30         => p_entry_information30
      ,p_date_earned                 => l_date_earned
      ,p_personal_payment_method_id  => p_personal_payment_method_id
      ,p_subpriority                 => p_subpriority
      ,p_effective_start_date        => l_effective_start_date
      ,p_effective_end_date          => l_effective_end_date
      ,p_batch_line_id               => l_batch_line_id
      ,p_object_version_number       => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk2.create_batch_line_a
      (p_session_date                   => l_session_date
      ,p_batch_id                       => p_batch_id
      ,p_batch_line_status              => p_batch_line_status
      ,p_assignment_id                  => p_assignment_id
      ,p_assignment_number              => p_assignment_number
      ,p_attribute_category             => p_attribute_category
      ,p_attribute1                     => p_attribute1
      ,p_attribute2                     => p_attribute2
      ,p_attribute3                     => p_attribute3
      ,p_attribute4                     => p_attribute4
      ,p_attribute5                     => p_attribute5
      ,p_attribute6                     => p_attribute6
      ,p_attribute7                     => p_attribute7
      ,p_attribute8                     => p_attribute8
      ,p_attribute9                     => p_attribute9
      ,p_attribute10                    => p_attribute10
      ,p_attribute11                    => p_attribute11
      ,p_attribute12                    => p_attribute12
      ,p_attribute13                    => p_attribute13
      ,p_attribute14                    => p_attribute14
      ,p_attribute15                    => p_attribute15
      ,p_attribute16                    => p_attribute16
      ,p_attribute17                    => p_attribute17
      ,p_attribute18                    => p_attribute18
      ,p_attribute19                    => p_attribute19
      ,p_attribute20                    => p_attribute20
      ,p_entry_information_category     => p_entry_information_category
      ,p_entry_information1             => p_entry_information1
      ,p_entry_information2             => p_entry_information2
      ,p_entry_information3             => p_entry_information3
      ,p_entry_information4             => p_entry_information4
      ,p_entry_information5             => p_entry_information5
      ,p_entry_information6             => p_entry_information6
      ,p_entry_information7             => p_entry_information7
      ,p_entry_information8             => p_entry_information8
      ,p_entry_information9             => p_entry_information9
      ,p_entry_information10            => p_entry_information10
      ,p_entry_information11            => p_entry_information11
      ,p_entry_information12            => p_entry_information12
      ,p_entry_information13            => p_entry_information13
      ,p_entry_information14            => p_entry_information14
      ,p_entry_information15            => p_entry_information15
      ,p_entry_information16            => p_entry_information16
      ,p_entry_information17            => p_entry_information17
      ,p_entry_information18            => p_entry_information18
      ,p_entry_information19            => p_entry_information19
      ,p_entry_information20            => p_entry_information20
      ,p_entry_information21            => p_entry_information21
      ,p_entry_information22            => p_entry_information22
      ,p_entry_information23            => p_entry_information23
      ,p_entry_information24            => p_entry_information24
      ,p_entry_information25            => p_entry_information25
      ,p_entry_information26            => p_entry_information26
      ,p_entry_information27            => p_entry_information27
      ,p_entry_information28            => p_entry_information28
      ,p_entry_information29            => p_entry_information29
      ,p_entry_information30            => p_entry_information30
      ,p_date_earned                    => l_date_earned
      ,p_personal_payment_method_id     => p_personal_payment_method_id
      ,p_subpriority                    => p_subpriority
      ,p_batch_sequence                 => p_batch_sequence
      ,p_concatenated_segments          => p_concatenated_segments
      ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
      ,p_effective_date                 => l_effective_date
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_element_name                   => p_element_name
      ,p_element_type_id                => p_element_type_id
      ,p_entry_type                     => p_entry_type
      ,p_reason                         => p_reason
      ,p_segment1                       => p_segment1
      ,p_segment2                       => p_segment2
      ,p_segment3                       => p_segment3
      ,p_segment4                       => p_segment4
      ,p_segment5                       => p_segment5
      ,p_segment6                       => p_segment6
      ,p_segment7                       => p_segment7
      ,p_segment8                       => p_segment8
      ,p_segment9                       => p_segment9
      ,p_segment10                      => p_segment10
      ,p_segment11                      => p_segment11
      ,p_segment12                      => p_segment12
      ,p_segment13                      => p_segment13
      ,p_segment14                      => p_segment14
      ,p_segment15                      => p_segment15
      ,p_segment16                      => p_segment16
      ,p_segment17                      => p_segment17
      ,p_segment18                      => p_segment18
      ,p_segment19                      => p_segment19
      ,p_segment20                      => p_segment20
      ,p_segment21                      => p_segment21
      ,p_segment22                      => p_segment22
      ,p_segment23                      => p_segment23
      ,p_segment24                      => p_segment24
      ,p_segment25                      => p_segment25
      ,p_segment26                      => p_segment26
      ,p_segment27                      => p_segment27
      ,p_segment28                      => p_segment28
      ,p_segment29                      => p_segment29
      ,p_segment30                      => p_segment30
      ,p_value_1                        => l_value_1
      ,p_value_2                        => l_value_2
      ,p_value_3                        => l_value_3
      ,p_value_4                        => l_value_4
      ,p_value_5                        => l_value_5
      ,p_value_6                        => l_value_6
      ,p_value_7                        => l_value_7
      ,p_value_8                        => l_value_8
      ,p_value_9                        => l_value_9
      ,p_value_10                       => l_value_10
      ,p_value_11                       => l_value_11
      ,p_value_12                       => l_value_12
      ,p_value_13                       => l_value_13
      ,p_value_14                       => l_value_14
      ,p_value_15                       => l_value_15
      ,p_batch_line_id                  => l_batch_line_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_batch_line_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_batch_line_id          := l_batch_line_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_batch_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_batch_line_id          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_batch_line;
    p_batch_line_id          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_batch_line;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_total >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_total
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_control_status                in     varchar2 default 'U'
  ,p_control_total                 in     varchar2 default null
  ,p_control_type                  in     varchar2 default null
  ,p_batch_control_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_batch_total';
  l_batch_control_id       pay_batch_control_totals.batch_control_id%TYPE;
  l_object_version_number  pay_batch_control_totals.object_version_number%TYPE;
  l_session_date           date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_batch_total;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_session_date := trunc(p_session_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk3.create_batch_total_b
      (p_session_date                   => l_session_date
      ,p_batch_id                       => p_batch_id
      ,p_control_status                 => p_control_status
      ,p_control_total                  => p_control_total
      ,p_control_type                   => p_control_type
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_batch_total_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_bct_ins.ins
      (p_session_date             => l_session_date
      ,p_batch_id                 => p_batch_id
      ,p_control_status           => p_control_status
      ,p_control_total            => p_control_total
      ,p_control_type             => p_control_type
      ,p_batch_control_id         => l_batch_control_id
      ,p_object_version_number    => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk3.create_batch_total_a
      (p_session_date                   => l_session_date
      ,p_batch_id                       => p_batch_id
      ,p_control_status                 => p_control_status
      ,p_control_total                  => p_control_total
      ,p_control_type                   => p_control_type
      ,p_batch_control_id               => l_batch_control_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_batch_total_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_batch_control_id       := l_batch_control_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_batch_total;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_batch_control_id       := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_batch_total;
    p_batch_control_id       := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_batch_total;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_header >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_header
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_object_version_number         in out nocopy number
  ,p_action_if_exists              in     varchar2 default hr_api.g_varchar2
  ,p_batch_name                    in     varchar2 default hr_api.g_varchar2
  ,p_batch_reference               in     varchar2 default hr_api.g_varchar2
  ,p_batch_source                  in     varchar2 default hr_api.g_varchar2
  ,p_batch_status                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_effective_changes        in     varchar2 default hr_api.g_varchar2
  ,p_purge_after_transfer          in     varchar2 default hr_api.g_varchar2
  ,p_reject_if_future_changes      in     varchar2 default hr_api.g_varchar2
  ,p_reject_if_results_exists      in     varchar2 default hr_api.g_varchar2
  ,p_purge_after_rollback          in     varchar2 default hr_api.g_varchar2
  ,p_batch_type                    in     varchar2 default hr_api.g_varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED      in     varchar2 default hr_api.g_varchar2
  ,p_ROLLBACK_ENTRY_UPDATES        in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_batch_header';
  l_object_version_number  pay_batch_headers.object_version_number%TYPE;
  l_session_date           date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_batch_header;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_session_date := trunc(p_session_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk4.update_batch_header_b
      (p_session_date                   => l_session_date
      ,p_batch_id                       => p_batch_id
      ,p_object_version_number          => l_object_version_number
      ,p_action_if_exists               => p_action_if_exists
      ,p_batch_name                     => p_batch_name
      ,p_batch_reference                => p_batch_reference
      ,p_batch_source                   => p_batch_source
      ,p_batch_status                   => p_batch_status
      ,p_comments                       => p_comments
      ,p_date_effective_changes         => p_date_effective_changes
      ,p_purge_after_transfer           => p_purge_after_transfer
      ,p_reject_if_future_changes       => p_reject_if_future_changes
      ,p_reject_if_results_exists       => p_reject_if_results_exists
      ,p_purge_after_rollback           => p_purge_after_rollback
      ,p_batch_type                     => p_batch_type
      ,p_REJECT_ENTRY_NOT_REMOVED       => p_REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES         => p_ROLLBACK_ENTRY_UPDATES
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_batch_header_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_bth_upd.upd
      (p_session_date             => l_session_date
      ,p_batch_id                 => p_batch_id
      ,p_object_version_number    => l_object_version_number
      ,p_batch_name               => p_batch_name
      ,p_batch_status             => p_batch_status
      ,p_action_if_exists         => p_action_if_exists
      ,p_batch_reference          => p_batch_reference
      ,p_batch_source             => p_batch_source
      ,p_batch_type               => p_batch_type
      ,p_comments                 => p_comments
      ,p_date_effective_changes   => p_date_effective_changes
      ,p_purge_after_transfer     => p_purge_after_transfer
      ,p_reject_if_future_changes => p_reject_if_future_changes
      ,p_reject_if_results_exists => p_reject_if_results_exists
      ,p_purge_after_rollback     => p_purge_after_rollback
      ,p_REJECT_ENTRY_NOT_REMOVED => p_REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES   => p_ROLLBACK_ENTRY_UPDATES);
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk4.update_batch_header_a
      (p_session_date                   => l_session_date
      ,p_batch_id                       => p_batch_id
      ,p_object_version_number          => l_object_version_number
      ,p_action_if_exists               => p_action_if_exists
      ,p_batch_name                     => p_batch_name
      ,p_batch_reference                => p_batch_reference
      ,p_batch_source                   => p_batch_source
      ,p_batch_status                   => p_batch_status
      ,p_comments                       => p_comments
      ,p_date_effective_changes         => p_date_effective_changes
      ,p_purge_after_transfer           => p_purge_after_transfer
      ,p_reject_if_future_changes       => p_reject_if_future_changes
      ,p_reject_if_results_exists       => p_reject_if_results_exists
      ,p_purge_after_rollback           => p_purge_after_rollback
      ,p_batch_type                     => p_batch_type
      ,p_REJECT_ENTRY_NOT_REMOVED       => p_REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES         => p_ROLLBACK_ENTRY_UPDATES
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_batch_header_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_batch_header;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_batch_header;
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_batch_header;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_batch_line >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_line
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_line_id                 in     number
  ,p_batch_line_status             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_assignment_number             in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_entry_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_entry_information1            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information2            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information3            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information4            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information5            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information6            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information7            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information8            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information9            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information10           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information11           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information12           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information13           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information14           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information15           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information16           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information17           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information18           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information19           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information20           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information21           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information22           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information23           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information24           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information25           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information26           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information27           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information28           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information29           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information30           in     varchar2  default hr_api.g_varchar2
  ,p_date_earned                   in     date      default hr_api.g_date
  ,p_personal_payment_method_id    in     number    default hr_api.g_number
  ,p_subpriority                   in     number    default hr_api.g_number
  ,p_batch_sequence                in     number   default hr_api.g_number
  ,p_concatenated_segments         in     varchar2 default hr_api.g_varchar2
  ,p_cost_allocation_keyflex_id    in     number   default hr_api.g_number
  ,p_effective_date                in     date     default hr_api.g_date
  ,p_effective_start_date          in     date     default hr_api.g_date
  ,p_effective_end_date            in     date     default hr_api.g_date
  ,p_element_name                  in     varchar2 default hr_api.g_varchar2
  ,p_element_type_id               in     number   default hr_api.g_number
  ,p_entry_type                    in     varchar2 default hr_api.g_varchar2
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_value_1                       in     varchar2 default hr_api.g_varchar2
  ,p_value_2                       in     varchar2 default hr_api.g_varchar2
  ,p_value_3                       in     varchar2 default hr_api.g_varchar2
  ,p_value_4                       in     varchar2 default hr_api.g_varchar2
  ,p_value_5                       in     varchar2 default hr_api.g_varchar2
  ,p_value_6                       in     varchar2 default hr_api.g_varchar2
  ,p_value_7                       in     varchar2 default hr_api.g_varchar2
  ,p_value_8                       in     varchar2 default hr_api.g_varchar2
  ,p_value_9                       in     varchar2 default hr_api.g_varchar2
  ,p_value_10                      in     varchar2 default hr_api.g_varchar2
  ,p_value_11                      in     varchar2 default hr_api.g_varchar2
  ,p_value_12                      in     varchar2 default hr_api.g_varchar2
  ,p_value_13                      in     varchar2 default hr_api.g_varchar2
  ,p_value_14                      in     varchar2 default hr_api.g_varchar2
  ,p_value_15                      in     varchar2 default hr_api.g_varchar2
  ,p_canonical_date_format         in     varchar2 default 'Y'
  ,p_iv_all_internal_format        in     varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_batch_line';
  l_object_version_number  pay_batch_lines.object_version_number%TYPE;
  l_session_date           date;
  l_effective_date         date;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_date_earned            date;
  --
  l_value_1                pay_batch_lines.value_1%TYPE := p_value_1;
  l_value_2                pay_batch_lines.value_2%TYPE := p_value_2;
  l_value_3                pay_batch_lines.value_3%TYPE := p_value_3;
  l_value_4                pay_batch_lines.value_4%TYPE := p_value_4;
  l_value_5                pay_batch_lines.value_5%TYPE := p_value_5;
  l_value_6                pay_batch_lines.value_6%TYPE := p_value_6;
  l_value_7                pay_batch_lines.value_7%TYPE := p_value_7;
  l_value_8                pay_batch_lines.value_8%TYPE := p_value_8;
  l_value_9                pay_batch_lines.value_9%TYPE := p_value_9;
  l_value_10               pay_batch_lines.value_10%TYPE := p_value_10;
  l_value_11               pay_batch_lines.value_11%TYPE := p_value_11;
  l_value_12               pay_batch_lines.value_12%TYPE := p_value_12;
  l_value_13               pay_batch_lines.value_13%TYPE := p_value_13;
  l_value_14               pay_batch_lines.value_14%TYPE := p_value_14;
  l_value_15               pay_batch_lines.value_15%TYPE := p_value_15;
  --
  l_bee_iv_upgrade  varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_batch_line;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_session_date         := trunc(p_session_date);
  l_effective_date       := trunc(p_effective_date);
  l_effective_start_date := trunc(p_effective_start_date);
  l_effective_end_date   := trunc(p_effective_end_date);
  l_date_earned          := trunc(p_date_earned);
  --
  l_bee_iv_upgrade := get_upgrade_status(null,p_batch_line_id,'BEE_IV_UPG');
  --
  -- Check whether the upgrade process is in progress.
  --
  if l_bee_iv_upgrade = 'E' then
     hr_utility.set_message(800, 'HR_449106_BEE_UPGRADING');
     hr_utility.raise_error;
  end if;
  --
  if p_iv_all_internal_format = 'Y' and l_bee_iv_upgrade = 'N' then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME','P_IV_ALL_INTERNAL_FORMAT');
    fnd_message.raise_error;
  end if;
  --
  if p_iv_all_internal_format = 'Y' and p_canonical_date_format = 'N' then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME','P_CANONICAL_DATE_FORMAT');
    fnd_message.raise_error;
  end if;
  --
  --
  if p_iv_all_internal_format <> 'Y' then
     convert_date_to_canonical
     (p_iv1               => l_value_1
     ,p_iv2               => l_value_2
     ,p_iv3               => l_value_3
     ,p_iv4               => l_value_4
     ,p_iv5               => l_value_5
     ,p_iv6               => l_value_6
     ,p_iv7               => l_value_7
     ,p_iv8               => l_value_8
     ,p_iv9               => l_value_9
     ,p_iv10              => l_value_10
     ,p_iv11              => l_value_11
     ,p_iv12              => l_value_12
     ,p_iv13              => l_value_13
     ,p_iv14              => l_value_14
     ,p_iv15              => l_value_15
     ,p_element_type_id   => p_element_type_id
     ,p_element_name      => p_element_name
     ,p_effective_date    => p_effective_date
     ,p_batch_line_id     => p_batch_line_id
     ,p_date_cfmt         => p_canonical_date_format
     ,p_int_fmt           => l_bee_iv_upgrade
     );
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk5.update_batch_line_b
      (p_session_date                   => l_session_date
      ,p_batch_line_id                  => p_batch_line_id
      ,p_batch_line_status              => p_batch_line_status
      ,p_object_version_number          => l_object_version_number
      ,p_assignment_id                  => p_assignment_id
      ,p_assignment_number              => p_assignment_number
      ,p_attribute_category             => p_attribute_category
      ,p_attribute1                     => p_attribute1
      ,p_attribute2                     => p_attribute2
      ,p_attribute3                     => p_attribute3
      ,p_attribute4                     => p_attribute4
      ,p_attribute5                     => p_attribute5
      ,p_attribute6                     => p_attribute6
      ,p_attribute7                     => p_attribute7
      ,p_attribute8                     => p_attribute8
      ,p_attribute9                     => p_attribute9
      ,p_attribute10                    => p_attribute10
      ,p_attribute11                    => p_attribute11
      ,p_attribute12                    => p_attribute12
      ,p_attribute13                    => p_attribute13
      ,p_attribute14                    => p_attribute14
      ,p_attribute15                    => p_attribute15
      ,p_attribute16                    => p_attribute16
      ,p_attribute17                    => p_attribute17
      ,p_attribute18                    => p_attribute18
      ,p_attribute19                    => p_attribute19
      ,p_attribute20                    => p_attribute20
      ,p_entry_information_category     => p_entry_information_category
      ,p_entry_information1             => p_entry_information1
      ,p_entry_information2             => p_entry_information2
      ,p_entry_information3             => p_entry_information3
      ,p_entry_information4             => p_entry_information4
      ,p_entry_information5             => p_entry_information5
      ,p_entry_information6             => p_entry_information6
      ,p_entry_information7             => p_entry_information7
      ,p_entry_information8             => p_entry_information8
      ,p_entry_information9             => p_entry_information9
      ,p_entry_information10            => p_entry_information10
      ,p_entry_information11            => p_entry_information11
      ,p_entry_information12            => p_entry_information12
      ,p_entry_information13            => p_entry_information13
      ,p_entry_information14            => p_entry_information14
      ,p_entry_information15            => p_entry_information15
      ,p_entry_information16            => p_entry_information16
      ,p_entry_information17            => p_entry_information17
      ,p_entry_information18            => p_entry_information18
      ,p_entry_information19            => p_entry_information19
      ,p_entry_information20            => p_entry_information20
      ,p_entry_information21            => p_entry_information21
      ,p_entry_information22            => p_entry_information22
      ,p_entry_information23            => p_entry_information23
      ,p_entry_information24            => p_entry_information24
      ,p_entry_information25            => p_entry_information25
      ,p_entry_information26            => p_entry_information26
      ,p_entry_information27            => p_entry_information27
      ,p_entry_information28            => p_entry_information28
      ,p_entry_information29            => p_entry_information29
      ,p_entry_information30            => p_entry_information30
      ,p_date_earned                    => l_date_earned
      ,p_personal_payment_method_id     => p_personal_payment_method_id
      ,p_subpriority                    => p_subpriority
      ,p_batch_sequence                 => p_batch_sequence
      ,p_concatenated_segments          => p_concatenated_segments
      ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
      ,p_effective_date                 => l_effective_date
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_element_name                   => p_element_name
      ,p_element_type_id                => p_element_type_id
      ,p_entry_type                     => p_entry_type
      ,p_reason                         => p_reason
      ,p_segment1                       => p_segment1
      ,p_segment2                       => p_segment2
      ,p_segment3                       => p_segment3
      ,p_segment4                       => p_segment4
      ,p_segment5                       => p_segment5
      ,p_segment6                       => p_segment6
      ,p_segment7                       => p_segment7
      ,p_segment8                       => p_segment8
      ,p_segment9                       => p_segment9
      ,p_segment10                      => p_segment10
      ,p_segment11                      => p_segment11
      ,p_segment12                      => p_segment12
      ,p_segment13                      => p_segment13
      ,p_segment14                      => p_segment14
      ,p_segment15                      => p_segment15
      ,p_segment16                      => p_segment16
      ,p_segment17                      => p_segment17
      ,p_segment18                      => p_segment18
      ,p_segment19                      => p_segment19
      ,p_segment20                      => p_segment20
      ,p_segment21                      => p_segment21
      ,p_segment22                      => p_segment22
      ,p_segment23                      => p_segment23
      ,p_segment24                      => p_segment24
      ,p_segment25                      => p_segment25
      ,p_segment26                      => p_segment26
      ,p_segment27                      => p_segment27
      ,p_segment28                      => p_segment28
      ,p_segment29                      => p_segment29
      ,p_segment30                      => p_segment30
      ,p_value_1                        => l_value_1
      ,p_value_2                        => l_value_2
      ,p_value_3                        => l_value_3
      ,p_value_4                        => l_value_4
      ,p_value_5                        => l_value_5
      ,p_value_6                        => l_value_6
      ,p_value_7                        => l_value_7
      ,p_value_8                        => l_value_8
      ,p_value_9                        => l_value_9
      ,p_value_10                       => l_value_10
      ,p_value_11                       => l_value_11
      ,p_value_12                       => l_value_12
      ,p_value_13                       => l_value_13
      ,p_value_14                       => l_value_14
      ,p_value_15                       => l_value_15
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_batch_line_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 11);
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_btl_upd.upd
      (p_session_date                => l_session_date
      ,p_batch_line_id               => p_batch_line_id
      ,p_object_version_number       => l_object_version_number
      ,p_batch_line_status           => p_batch_line_status
      ,p_cost_allocation_keyflex_id  => p_cost_allocation_keyflex_id
      ,p_element_type_id             => p_element_type_id
      ,p_assignment_id               => p_assignment_id
      ,p_assignment_number           => p_assignment_number
      ,p_batch_sequence              => p_batch_sequence
      ,p_concatenated_segments       => p_concatenated_segments
      ,p_effective_date              => l_effective_date
      ,p_element_name                => p_element_name
      ,p_entry_type                  => p_entry_type
      ,p_reason                      => p_reason
      ,p_segment1                    => p_segment1
      ,p_segment2                    => p_segment2
      ,p_segment3                    => p_segment3
      ,p_segment4                    => p_segment4
      ,p_segment5                    => p_segment5
      ,p_segment6                    => p_segment6
      ,p_segment7                    => p_segment7
      ,p_segment8                    => p_segment8
      ,p_segment9                    => p_segment9
      ,p_segment10                   => p_segment10
      ,p_segment11                   => p_segment11
      ,p_segment12                   => p_segment12
      ,p_segment13                   => p_segment13
      ,p_segment14                   => p_segment14
      ,p_segment15                   => p_segment15
      ,p_segment16                   => p_segment16
      ,p_segment17                   => p_segment17
      ,p_segment18                   => p_segment18
      ,p_segment19                   => p_segment19
      ,p_segment20                   => p_segment20
      ,p_segment21                   => p_segment21
      ,p_segment22                   => p_segment22
      ,p_segment23                   => p_segment23
      ,p_segment24                   => p_segment24
      ,p_segment25                   => p_segment25
      ,p_segment26                   => p_segment26
      ,p_segment27                   => p_segment27
      ,p_segment28                   => p_segment28
      ,p_segment29                   => p_segment29
      ,p_segment30                   => p_segment30
      ,p_value_1                     => l_value_1
      ,p_value_2                     => l_value_2
      ,p_value_3                     => l_value_3
      ,p_value_4                     => l_value_4
      ,p_value_5                     => l_value_5
      ,p_value_6                     => l_value_6
      ,p_value_7                     => l_value_7
      ,p_value_8                     => l_value_8
      ,p_value_9                     => l_value_9
      ,p_value_10                    => l_value_10
      ,p_value_11                    => l_value_11
      ,p_value_12                    => l_value_12
      ,p_value_13                    => l_value_13
      ,p_value_14                    => l_value_14
      ,p_value_15                    => l_value_15
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_entry_information_category  => p_entry_information_category
      ,p_entry_information1          => p_entry_information1
      ,p_entry_information2          => p_entry_information2
      ,p_entry_information3          => p_entry_information3
      ,p_entry_information4          => p_entry_information4
      ,p_entry_information5          => p_entry_information5
      ,p_entry_information6          => p_entry_information6
      ,p_entry_information7          => p_entry_information7
      ,p_entry_information8          => p_entry_information8
      ,p_entry_information9          => p_entry_information9
      ,p_entry_information10         => p_entry_information10
      ,p_entry_information11         => p_entry_information11
      ,p_entry_information12         => p_entry_information12
      ,p_entry_information13         => p_entry_information13
      ,p_entry_information14         => p_entry_information14
      ,p_entry_information15         => p_entry_information15
      ,p_entry_information16         => p_entry_information16
      ,p_entry_information17         => p_entry_information17
      ,p_entry_information18         => p_entry_information18
      ,p_entry_information19         => p_entry_information19
      ,p_entry_information20         => p_entry_information20
      ,p_entry_information21         => p_entry_information21
      ,p_entry_information22         => p_entry_information22
      ,p_entry_information23         => p_entry_information23
      ,p_entry_information24         => p_entry_information24
      ,p_entry_information25         => p_entry_information25
      ,p_entry_information26         => p_entry_information26
      ,p_entry_information27         => p_entry_information27
      ,p_entry_information28         => p_entry_information28
      ,p_entry_information29         => p_entry_information29
      ,p_entry_information30         => p_entry_information30
      ,p_date_earned                 => l_date_earned
      ,p_personal_payment_method_id  => p_personal_payment_method_id
      ,p_subpriority                 => p_subpriority
      ,p_effective_start_date        => l_effective_start_date
      ,p_effective_end_date          => l_effective_end_date);
  --
  hr_utility.set_location(l_proc, 12);
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk5.update_batch_line_a
      (p_session_date                   => l_session_date
      ,p_batch_line_id                  => p_batch_line_id
      ,p_batch_line_status              => p_batch_line_status
      ,p_object_version_number          => l_object_version_number
      ,p_assignment_id                  => p_assignment_id
      ,p_assignment_number              => p_assignment_number
      ,p_attribute_category             => p_attribute_category
      ,p_attribute1                     => p_attribute1
      ,p_attribute2                     => p_attribute2
      ,p_attribute3                     => p_attribute3
      ,p_attribute4                     => p_attribute4
      ,p_attribute5                     => p_attribute5
      ,p_attribute6                     => p_attribute6
      ,p_attribute7                     => p_attribute7
      ,p_attribute8                     => p_attribute8
      ,p_attribute9                     => p_attribute9
      ,p_attribute10                    => p_attribute10
      ,p_attribute11                    => p_attribute11
      ,p_attribute12                    => p_attribute12
      ,p_attribute13                    => p_attribute13
      ,p_attribute14                    => p_attribute14
      ,p_attribute15                    => p_attribute15
      ,p_attribute16                    => p_attribute16
      ,p_attribute17                    => p_attribute17
      ,p_attribute18                    => p_attribute18
      ,p_attribute19                    => p_attribute19
      ,p_attribute20                    => p_attribute20
      ,p_entry_information_category     => p_entry_information_category
      ,p_entry_information1             => p_entry_information1
      ,p_entry_information2             => p_entry_information2
      ,p_entry_information3             => p_entry_information3
      ,p_entry_information4             => p_entry_information4
      ,p_entry_information5             => p_entry_information5
      ,p_entry_information6             => p_entry_information6
      ,p_entry_information7             => p_entry_information7
      ,p_entry_information8             => p_entry_information8
      ,p_entry_information9             => p_entry_information9
      ,p_entry_information10            => p_entry_information10
      ,p_entry_information11            => p_entry_information11
      ,p_entry_information12            => p_entry_information12
      ,p_entry_information13            => p_entry_information13
      ,p_entry_information14            => p_entry_information14
      ,p_entry_information15            => p_entry_information15
      ,p_entry_information16            => p_entry_information16
      ,p_entry_information17            => p_entry_information17
      ,p_entry_information18            => p_entry_information18
      ,p_entry_information19            => p_entry_information19
      ,p_entry_information20            => p_entry_information20
      ,p_entry_information21            => p_entry_information21
      ,p_entry_information22            => p_entry_information22
      ,p_entry_information23            => p_entry_information23
      ,p_entry_information24            => p_entry_information24
      ,p_entry_information25            => p_entry_information25
      ,p_entry_information26            => p_entry_information26
      ,p_entry_information27            => p_entry_information27
      ,p_entry_information28            => p_entry_information28
      ,p_entry_information29            => p_entry_information29
      ,p_entry_information30            => p_entry_information30
      ,p_date_earned                    => l_date_earned
      ,p_personal_payment_method_id     => p_personal_payment_method_id
      ,p_subpriority                    => p_subpriority
      ,p_batch_sequence                 => p_batch_sequence
      ,p_concatenated_segments          => p_concatenated_segments
      ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
      ,p_effective_date                 => l_effective_date
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_element_name                   => p_element_name
      ,p_element_type_id                => p_element_type_id
      ,p_entry_type                     => p_entry_type
      ,p_reason                         => p_reason
      ,p_segment1                       => p_segment1
      ,p_segment2                       => p_segment2
      ,p_segment3                       => p_segment3
      ,p_segment4                       => p_segment4
      ,p_segment5                       => p_segment5
      ,p_segment6                       => p_segment6
      ,p_segment7                       => p_segment7
      ,p_segment8                       => p_segment8
      ,p_segment9                       => p_segment9
      ,p_segment10                      => p_segment10
      ,p_segment11                      => p_segment11
      ,p_segment12                      => p_segment12
      ,p_segment13                      => p_segment13
      ,p_segment14                      => p_segment14
      ,p_segment15                      => p_segment15
      ,p_segment16                      => p_segment16
      ,p_segment17                      => p_segment17
      ,p_segment18                      => p_segment18
      ,p_segment19                      => p_segment19
      ,p_segment20                      => p_segment20
      ,p_segment21                      => p_segment21
      ,p_segment22                      => p_segment22
      ,p_segment23                      => p_segment23
      ,p_segment24                      => p_segment24
      ,p_segment25                      => p_segment25
      ,p_segment26                      => p_segment26
      ,p_segment27                      => p_segment27
      ,p_segment28                      => p_segment28
      ,p_segment29                      => p_segment29
      ,p_segment30                      => p_segment30
      ,p_value_1                        => l_value_1
      ,p_value_2                        => l_value_2
      ,p_value_3                        => l_value_3
      ,p_value_4                        => l_value_4
      ,p_value_5                        => l_value_5
      ,p_value_6                        => l_value_6
      ,p_value_7                        => l_value_7
      ,p_value_8                        => l_value_8
      ,p_value_9                        => l_value_9
      ,p_value_10                       => l_value_10
      ,p_value_11                       => l_value_11
      ,p_value_12                       => l_value_12
      ,p_value_13                       => l_value_13
      ,p_value_14                       => l_value_14
      ,p_value_15                       => l_value_15
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_batch_line_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_batch_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_batch_line;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_batch_line;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_total >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_total
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_control_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_control_status                in     varchar2 default hr_api.g_varchar2
  ,p_control_total                 in     varchar2 default hr_api.g_varchar2
  ,p_control_type                  in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_batch_total';
  l_object_version_number  pay_batch_control_totals.object_version_number%TYPE;
  l_session_date           date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_batch_total;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_session_date := trunc(p_session_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk6.update_batch_total_b
      (p_session_date                   => l_session_date
      ,p_batch_control_id               => p_batch_control_id
      ,p_object_version_number          => l_object_version_number
      ,p_control_status                 => p_control_status
      ,p_control_total                  => p_control_total
      ,p_control_type                   => p_control_type
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_batch_total_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_bct_upd.upd
      (p_session_date             => l_session_date
      ,p_batch_control_id         => p_batch_control_id
      ,p_object_version_number    => l_object_version_number
      ,p_control_status           => p_control_status
      ,p_control_total            => p_control_total
      ,p_control_type             => p_control_type);
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk6.update_batch_total_a
      (p_session_date                   => l_session_date
      ,p_batch_control_id               => p_batch_control_id
      ,p_object_version_number          => l_object_version_number
      ,p_control_status                 => p_control_status
      ,p_control_total                  => p_control_total
      ,p_control_type                   => p_control_type
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_batch_total_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_batch_total;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_batch_total;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_batch_total;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_header >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_header
  (p_validate                      in     boolean  default false
  ,p_batch_id                      in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_batch_header';
  --
  cursor csr_batch_lines is
     select btl.batch_line_id,btl.object_version_number
       from pay_batch_lines btl
      where btl.batch_id = p_batch_id;
  --
  cursor csr_batch_ctl_totals is
     select bct.batch_control_id,bct.object_version_number
       from pay_batch_control_totals bct
      where bct.batch_id = p_batch_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_batch_header;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk7.delete_batch_header_b
      (p_batch_id                       => p_batch_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_batch_header_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- Deletes all batch lines.
  --
  for cssr in csr_batch_lines loop
      --
      -- Deletes all messages
      --
      delete from pay_message_lines
       where SOURCE_TYPE = 'L'
         and SOURCE_ID = cssr.batch_line_id;
      --
      pay_btl_del.del
      (p_batch_line_id                 => cssr.batch_line_id
      ,p_object_version_number         => cssr.object_version_number
      );
  end loop;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Deletes all batch control totals
  --
  for cssr in csr_batch_ctl_totals loop
      --
      -- Deletes all messages
      --
      delete from pay_message_lines
       where SOURCE_TYPE = 'C'
         and SOURCE_ID = cssr.batch_control_id;
      --
      pay_bct_del.del
      (p_batch_control_id              => cssr.batch_control_id
      ,p_object_version_number         => cssr.object_version_number
      );
  end loop;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Deletes all messages
  --
  delete from pay_message_lines
   where SOURCE_TYPE = 'H'
     and SOURCE_ID = p_batch_id;
  --
  -- Deletes the batch header
  --
  pay_bth_del.del
  (p_batch_id                      => p_batch_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk7.delete_batch_header_a
      (p_batch_id                       => p_batch_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_batch_header_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 21);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_batch_header;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 22);
  --
  when others then
  --
  --
  ROLLBACK TO delete_batch_header;
  --
  raise;
  --
end delete_batch_header;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_batch_line >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_line
  (p_validate                      in     boolean  default false
  ,p_batch_line_id                 in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_batch_line';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_batch_line;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk8.delete_batch_line_b
      (p_batch_line_id                  => p_batch_line_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_batch_line_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- Deletes all messages
  --
  delete from pay_message_lines
   where SOURCE_TYPE = 'L'
     and SOURCE_ID = p_batch_line_id;
  --
  -- Deletes the batch line
  --
  pay_btl_del.del
  (p_batch_line_id                 => p_batch_line_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk8.delete_batch_line_a
      (p_batch_line_id                  => p_batch_line_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_batch_line_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 21);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_batch_line;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 22);
  --
  when others then
  --
  --
  ROLLBACK TO delete_batch_line;
  --
  raise;
  --
end delete_batch_line;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_total >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_total
  (p_validate                      in     boolean  default false
  ,p_batch_control_id              in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_batch_total';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_batch_total;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_batch_element_entry_bk9.delete_batch_total_b
      (p_batch_control_id               => p_batch_control_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_batch_total_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- Deletes all messages
  --
  delete from pay_message_lines
   where SOURCE_TYPE = 'C'
     and SOURCE_ID = p_batch_control_id;
  --
  -- Deletes the batch header
  --
  pay_bct_del.del
  (p_batch_control_id              => p_batch_control_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_batch_element_entry_bk9.delete_batch_total_a
      (p_batch_control_id               => p_batch_control_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_batch_total_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 21);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_batch_total;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 22);
  --
  when others then
  --
  --
  ROLLBACK TO delete_batch_total;
  --
  raise;
  --
end delete_batch_total;
--
end PAY_BATCH_ELEMENT_ENTRY_API;

/
