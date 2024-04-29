--------------------------------------------------------
--  DDL for Package Body PAY_BEE_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BEE_UPGRADE_PKG" as
/* $Header: pybeeupg.pkb 120.1 2006/02/21 06:42 bshukla noship $ */
--
--
   --
   -- Declare a cursor containing all records with date format.
   CURSOR csr_batch_lines (p_assignment_id number, p_bg_id number,
                           p_leg_code varchar2) IS
      SELECT pbl.batch_line_id,
             pbl.value_1,
             pbl.value_2,
             pbl.value_3,
             pbl.value_4,
             pbl.value_5,
             pbl.value_6,
             pbl.value_7,
             pbl.value_8,
             pbl.value_9,
             pbl.value_10,
             pbl.value_11,
             pbl.value_12,
             pbl.value_13,
             pbl.value_14,
             pbl.value_15,
             pbh.business_group_id,
             p_leg_code legislation_code,
             pbl.effective_date,
             pbl.element_type_id,
             pbl.element_name,
             pbl.assignment_id,
             pbl.assignment_number,
             pbl.batch_line_status
        FROM pay_batch_lines pbl,
             pay_batch_headers pbh
       WHERE pbl.assignment_id is not null
         AND pbl.assignment_id = p_assignment_id
         AND pbh.business_group_id = p_bg_id
         AND pbh.batch_id = pbl.batch_id
         AND p_assignment_id is not null
       UNION ALL
      SELECT pbl.batch_line_id,
             pbl.value_1,
             pbl.value_2,
             pbl.value_3,
             pbl.value_4,
             pbl.value_5,
             pbl.value_6,
             pbl.value_7,
             pbl.value_8,
             pbl.value_9,
             pbl.value_10,
             pbl.value_11,
             pbl.value_12,
             pbl.value_13,
             pbl.value_14,
             pbl.value_15,
             pbh.business_group_id,
             p_leg_code legislation_code,
             pbl.effective_date,
             pbl.element_type_id,
             pbl.element_name,
             asg.assignment_id,
             pbl.assignment_number,
             pbl.batch_line_status
        FROM pay_batch_lines pbl,
             pay_batch_headers pbh,
             per_all_assignments_f asg
       WHERE pbh.business_group_id = p_bg_id
         AND pbl.assignment_id is null
         AND asg.assignment_id = p_assignment_id
         AND asg.business_group_id = p_bg_id
         AND pbl.effective_date between asg.effective_start_date and asg.effective_end_date
         AND upper(pbl.assignment_number) = upper(asg.assignment_number)
         AND pbh.batch_id = pbl.batch_id
         AND p_assignment_id is not null
       UNION ALL
      SELECT pbl.batch_line_id,
             pbl.value_1,
             pbl.value_2,
             pbl.value_3,
             pbl.value_4,
             pbl.value_5,
             pbl.value_6,
             pbl.value_7,
             pbl.value_8,
             pbl.value_9,
             pbl.value_10,
             pbl.value_11,
             pbl.value_12,
             pbl.value_13,
             pbl.value_14,
             pbl.value_15,
             pbh.business_group_id,
             p_leg_code legislation_code,
             pbl.effective_date,
             pbl.element_type_id,
             pbl.element_name,
             pbl.assignment_id,
             pbl.assignment_number,
             pbl.batch_line_status
        FROM pay_batch_lines pbl,
             pay_batch_headers pbh
       WHERE pbh.business_group_id = p_bg_id
         AND pbl.assignment_id is null
         AND (pbl.assignment_number is null or
              not exists
                 (select null
                    from per_all_assignments_f asg
                   where asg.assignment_id = p_assignment_id
                     and asg.business_group_id = p_bg_id
                     and upper(pbl.assignment_number) = upper(asg.assignment_number)
                     and pbl.effective_date between asg.effective_start_date and asg.effective_end_date))
         AND pbh.batch_id = pbl.batch_id
         AND p_assignment_id is null
       ORDER BY element_type_id,element_name;
   --
   --
   g_rec csr_batch_lines%ROWTYPE;
   --
   TYPE input_currency_code_tbl IS TABLE OF pay_element_types_f.input_currency_code%TYPE INDEX BY binary_integer;
   TYPE name_tbl IS TABLE OF pay_input_values_f.name%TYPE INDEX BY binary_integer;
   TYPE display_sequence_tbl IS TABLE OF pay_input_values_f.display_sequence%TYPE INDEX BY binary_integer;
   TYPE uom_tbl IS TABLE OF pay_input_values_f.uom%TYPE INDEX BY binary_integer;
   TYPE lookup_type_tbl IS TABLE OF pay_input_values_f.lookup_type%TYPE INDEX BY binary_integer;
   TYPE value_set_id_tbl IS TABLE OF pay_input_values_f.value_set_id%TYPE INDEX BY binary_integer;
   --
   type input_value_tbl_rec is record(
        input_currency_code input_currency_code_tbl,
        name                name_tbl,
        display_sequence    display_sequence_tbl,
        uom                 uom_tbl,
        lookup_type         lookup_type_tbl,
        value_set_id        value_set_id_tbl);
   --
   g_input_values      input_value_tbl_rec;
   g_element_type_id   pay_element_types_f.element_type_id%TYPE := NULL;
   g_element_name      pay_element_types_f.element_name%TYPE := NULL;
   g_effective_date    pay_batch_lines.effective_date%TYPE := NULL;
   g_business_group_id per_business_groups.business_group_id%TYPE := NULL;
   g_legislation_code  per_business_groups.legislation_code%TYPE := NULL;
   --
   type input_value_rec is record(
        element_type_id     pay_element_types_f.element_type_id%TYPE,
        element_name        pay_element_types_f.element_name%TYPE,
        input_currency_code pay_element_types_f.input_currency_code%TYPE,
        name                pay_input_values_f.name%TYPE,
        display_sequence    pay_input_values_f.display_sequence%TYPE,
        uom                 pay_input_values_f.uom%TYPE,
        lookup_type         pay_input_values_f.lookup_type%TYPE,
        value_set_id        pay_input_values_f.value_set_id%TYPE);
   --
   --
   -- -------------------------------------------------------------------------
   -- Procedure to get the input values for a given element type id.
   -- -------------------------------------------------------------------------
   PROCEDURE get_input_value(
      p_element_type_id         in  number,
      p_element_name            in  varchar2,
      p_business_group_id       in  number,
      p_legislation_code        in  varchar2,
      p_effective_date          in  date) is
   --
      l_found boolean := false;
      --
      CURSOR csr_input_values(p_element_type_id number,
                           p_element_name varchar2,
                           p_effective_date date,
                           p_business_group_id number,
                           p_legislation_code varchar2) IS
      SELECT piv.name,
             piv.display_sequence, piv.uom,piv.lookup_type,
             piv.value_set_id,pet.input_currency_code
        FROM pay_element_types_f pet,
             pay_input_values_f piv
       WHERE p_element_type_id is not null
         AND p_element_type_id = pet.element_type_id
         AND p_effective_date BETWEEN pet.effective_start_date
                                    AND pet.effective_end_date
         AND pet.element_type_id = piv.element_type_id
         AND p_effective_date BETWEEN piv.effective_start_date
                                    AND piv.effective_end_date
       UNION ALL
      SELECT piv.name,
             piv.display_sequence, piv.uom,piv.lookup_type,
             piv.value_set_id,pet.input_currency_code
        FROM pay_element_types_f pet,
             pay_input_values_f piv
       WHERE p_element_type_id is null
         AND upper(p_element_name) = upper(pet.element_name)
         AND (pet.business_group_id = p_business_group_id OR
              (pet.business_group_id is null AND pet.legislation_code = p_legislation_code) OR
              (pet.business_group_id is null AND pet.legislation_code is null))
         AND p_effective_date BETWEEN pet.effective_start_date
                                    AND pet.effective_end_date
         AND pet.element_type_id = piv.element_type_id
         AND p_effective_date BETWEEN piv.effective_start_date
                                    AND piv.effective_end_date
       ORDER BY display_sequence, name;
   --
   begin
   --
      --
      if (g_element_type_id    = p_element_type_id   and
          g_element_name       = p_element_name      and
          g_effective_date     = p_effective_date    and
          g_business_group_id  = p_business_group_id and
          g_legislation_code   = p_legislation_code) then
          --
          l_found := true;
          --
      end if;
      --
      if not l_found then
         --
         g_input_values.name.delete;
         g_input_values.display_sequence.delete;
         g_input_values.uom.delete;
		 g_input_values.lookup_type.delete;
		 g_input_values.value_set_id.delete;
	     g_input_values.input_currency_code.delete;
         --
         open csr_input_values(p_element_type_id,
                               p_element_name,
                               p_effective_date,
                               p_business_group_id,
                               p_legislation_code);
         --
         fetch csr_input_values bulk collect into
                        g_input_values.name,
                        g_input_values.display_sequence,
                        g_input_values.uom,
						g_input_values.lookup_type,
						g_input_values.value_set_id,
						g_input_values.input_currency_code;
         --
         close csr_input_values;
         --
         g_element_type_id    := p_element_type_id;
         g_element_name       := p_element_name;
         g_effective_date     := p_effective_date;
         g_business_group_id  := p_business_group_id;
         g_legislation_code   := p_legislation_code;
         --
      end if;
   --
   end get_input_value;
   ----------------------------------------------------------------------------
   --
   -- -------------------------------------------------------------------------
   -- Function to convert input values from display format to internal format.
   -- -------------------------------------------------------------------------
   function convert_display_to_internal
     (p_input_value       varchar2,
      p_uom_value         varchar2,
      p_lookup_type       varchar2,
      p_value_set_id      number,
      p_currency_code     varchar2,
      p_batch_line_id     varchar2,
      p_batch_line_status varchar2,
      p_iv_number         number)
      return varchar2 is
   --
      l_display_value   varchar2(80) := p_input_value;
      l_formatted_value varchar2(80) := p_input_value;
      l_dummy           varchar2(100);
      --
      lov_error         exception;
      --
      -- cursor csr_valid_lookup
      --        (p_lookup_type varchar2,
      --         p_meaning     varchar2) is
      --     select HL.lookup_code
      --       from hr_lookups HL
      --      where HL.lookup_type = p_lookup_type
      --        and HL.meaning     = p_meaning;
      --
      cursor csr_valid_lookup
             (p_lookup_type varchar2,
              p_meaning     varchar2) is
          SELECT FLV.LOOKUP_CODE
            FROM FND_LOOKUP_VALUES FLV
           WHERE FLV.VIEW_APPLICATION_ID = 3
             AND FLV.SECURITY_GROUP_ID = decode(substr(userenv('CLIENT_INFO'),55,1),
                 ' ', 0, NULL, 0, '0', 0,
                 fnd_global.lookup_security_group(FLV.LOOKUP_TYPE,FLV.VIEW_APPLICATION_ID))
             AND decode(FLV.TAG,
                        NULL, 'Y',
                        decode(substr(FLV.TAG,1,1),
                               '+', decode(sign(instr(FLV.TAG, HR_API.GET_LEGISLATION_CONTEXT)),
                                           1, 'Y', 'N'),
                               '-', decode(sign(instr(FLV.TAG, HR_API.GET_LEGISLATION_CONTEXT)),
                                           1, 'N', 'Y'),
                               'Y' )
                       ) = 'Y'
             AND flv.lookup_type  = p_lookup_type
             AND flv.meaning = p_meaning;
   --
   begin
   --
   hr_utility.set_location('pay_bee_upgrade_pkg.convert_display_to_internal',1);
   --
      if (p_lookup_type is not null and
          l_display_value is not null) then
         --
         open csr_valid_lookup(p_lookup_type, l_display_value);
         fetch csr_valid_lookup into l_formatted_value ;
         --
         if csr_valid_lookup%NOTFOUND then
            close csr_valid_lookup;
            if p_batch_line_status in ('V','T') then
               pay_core_utils.push_message (800,'HR_449107_BEE_UPG_LK_NONE','A');
               pay_core_utils.push_token ('BATCH_LINE_ID', p_batch_line_id);
               pay_core_utils.push_token ('VALUE_ID', 'VALUE_'||p_iv_number);
               pay_core_utils.push_token ('LOOKUP_TYPE', p_lookup_type);
               pay_core_utils.push_token ('UOM', p_uom_value);
               pay_core_utils.push_token ('VALUE', l_display_value);
               --hr_utility.raise_error;
               raise lov_error;
            else
               l_formatted_value := p_input_value;
            end if;
         end if;
         --
         fetch csr_valid_lookup into l_dummy;
         --
         if csr_valid_lookup%FOUND then
            close csr_valid_lookup;
            if p_batch_line_status in ('V','T') then
               pay_core_utils.push_message (800,'HR_449108_BEE_UPG_LK_MANY','A');
               pay_core_utils.push_token ('BATCH_LINE_ID', p_batch_line_id);
               pay_core_utils.push_token ('VALUE_ID', 'VALUE_'||p_iv_number);
               pay_core_utils.push_token ('LOOKUP_TYPE', p_lookup_type);
               pay_core_utils.push_token ('UOM', p_uom_value);
               pay_core_utils.push_token ('VALUE', l_display_value);
               --hr_utility.raise_error;
               raise lov_error;
            else
               l_formatted_value := p_input_value;
            end if;
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
            if p_batch_line_status in ('V','T') then
               pay_core_utils.push_message (800,'HR_449109_BEE_UPG_VS_NONE','A');
               pay_core_utils.push_token ('BATCH_LINE_ID', p_batch_line_id);
               pay_core_utils.push_token ('VALUE_ID', 'VALUE_'||p_iv_number);
               pay_core_utils.push_token ('VALUE_SET_ID', p_value_set_id);
               pay_core_utils.push_token ('UOM', p_uom_value);
               pay_core_utils.push_token ('VALUE', l_display_value);
               --hr_utility.raise_error;
               raise lov_error;
            else
               l_formatted_value := p_input_value;
            end if;
         end if;
         --
      else
         --
         if (p_uom_value <> 'D'
             or (p_uom_value = 'D' and INSTR(l_display_value,'-',1,2) <> 0)) then
             --
             hr_chkfmt.checkformat (
               l_display_value, 		/* the value to be formatted (out - display) */
               p_uom_value,	            /* the format to check */
               l_formatted_value, 	    /* the formatted value on output (out - canonical) */
               null, 				    /* minimum value (can be null) */
               null,		 		    /* maximum value (can be null) */
               'Y', 				    /* is ok to be null ? */
               l_dummy,                 /* used for range checking */
               p_currency_code );
             --
         end if;
         --
      end if;
      --
      --
      hr_utility.trace('IN:'||p_input_value);
      hr_utility.trace('OUT:'||l_formatted_value);
      hr_utility.set_location('pay_bee_upgrade_pkg.convert_display_to_internal',2);
      --
      if ((p_input_value is not null and l_formatted_value is null) or
          (p_input_value is null)) then
         return p_input_value;
      else
         return l_formatted_value;
      end if;
   --
   exception
      when lov_error then
         --
         hr_utility.set_location('pay_bee_upgrade_pkg.convert_display_to_internal',3);
         --
         hr_utility.raise_error;
      when others then
         --
         hr_utility.set_location('pay_bee_upgrade_pkg.convert_display_to_internal',4);
         --
         if p_batch_line_status in ('V','T') then
            pay_core_utils.push_message (800,'HR_449110_BEE_UPG_CONV','A');
            pay_core_utils.push_token ('BATCH_LINE_ID', p_batch_line_id);
            pay_core_utils.push_token ('VALUE_ID', 'VALUE_'||p_iv_number);
            pay_core_utils.push_token ('UOM', p_uom_value);
            pay_core_utils.push_token ('VALUE', l_display_value);
            hr_utility.raise_error;
         else
            return p_input_value;
         end if;
   --
   end convert_display_to_internal;
   -- -------------------------------------------------------------------------
   --
   --
   PROCEDURE convert_pay_input (p_rec csr_batch_lines%ROWTYPE) IS
       --
       l_temp csr_batch_lines%ROWTYPE;
       l_input_value_number integer;
       l_input_value_count  integer;
       --
       l_fetched_input_value input_value_rec;
   BEGIN
       --
       -- Initialize to default values.
       --
       l_temp.value_1  := p_rec.value_1;
       l_temp.value_2  := p_rec.value_2;
       l_temp.value_3  := p_rec.value_3;
       l_temp.value_4  := p_rec.value_4;
       l_temp.value_5  := p_rec.value_5;
       l_temp.value_6  := p_rec.value_6;
       l_temp.value_7  := p_rec.value_7;
       l_temp.value_8  := p_rec.value_8;
       l_temp.value_9  := p_rec.value_9;
       l_temp.value_10  := p_rec.value_10;
       l_temp.value_11  := p_rec.value_11;
       l_temp.value_12  := p_rec.value_12;
       l_temp.value_13  := p_rec.value_13;
       l_temp.value_14  := p_rec.value_14;
       l_temp.value_15  := p_rec.value_15;
       --
       get_input_value(p_element_type_id   => p_rec.element_type_id,
                       p_element_name      => p_rec.element_name,
                       p_effective_date    => p_rec.effective_date,
                       p_business_group_id => p_rec.business_group_id,
                       p_legislation_code  => p_rec.legislation_code);
       --
       l_input_value_count := g_input_values.name.count;
       --
       for i in 1..l_input_value_count loop

           l_fetched_input_value.uom                 := g_input_values.uom(i);
           l_fetched_input_value.lookup_type         := g_input_values.lookup_type(i);
           l_fetched_input_value.value_set_id        := g_input_values.value_set_id(i);
           l_fetched_input_value.input_currency_code := g_input_values.input_currency_code(i);

           l_input_value_number := i;


           if l_input_value_number = 1 then
              --
              l_temp.value_1 := convert_display_to_internal(p_rec.value_1,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 2 then
              --
              l_temp.value_2 := convert_display_to_internal(p_rec.value_2,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 3 then
              --
              l_temp.value_3 := convert_display_to_internal(p_rec.value_3,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 4 then
              --
              l_temp.value_4 := convert_display_to_internal(p_rec.value_4,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 5 then
              --
              l_temp.value_5 := convert_display_to_internal(p_rec.value_5,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 6 then
              --
              l_temp.value_6 := convert_display_to_internal(p_rec.value_6,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 7 then
              --
              l_temp.value_7 := convert_display_to_internal(p_rec.value_7,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 8 then
              --
              l_temp.value_8 := convert_display_to_internal(p_rec.value_8,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 9 then
              --
              l_temp.value_9 := convert_display_to_internal(p_rec.value_9,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 10 then
              --
              l_temp.value_10 := convert_display_to_internal(p_rec.value_10,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 11 then
              --
              l_temp.value_11 := convert_display_to_internal(p_rec.value_11,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 12 then
              --
              l_temp.value_12 := convert_display_to_internal(p_rec.value_12,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 13 then
              --
              l_temp.value_13 := convert_display_to_internal(p_rec.value_13,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 14 then
              --
              l_temp.value_14 := convert_display_to_internal(p_rec.value_14,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
           elsif l_input_value_number = 15 then
              --
              l_temp.value_15 := convert_display_to_internal(p_rec.value_15,
                                                            l_fetched_input_value.uom,
                                                            l_fetched_input_value.lookup_type,
                                                            l_fetched_input_value.value_set_id,
                                                            l_fetched_input_value.input_currency_code,
                                                            p_rec.batch_line_status,
                                                            p_rec.batch_line_id,
                                                            l_input_value_number);
              --
              exit; -- stop looping after the fifteenth input value
           end if;

       end loop;

       if (l_temp.value_1  <> p_rec.value_1  or
           l_temp.value_2  <> p_rec.value_2  or
           l_temp.value_3  <> p_rec.value_3  or
           l_temp.value_4  <> p_rec.value_4  or
           l_temp.value_5  <> p_rec.value_5  or
           l_temp.value_6  <> p_rec.value_6  or
           l_temp.value_7  <> p_rec.value_7  or
           l_temp.value_8  <> p_rec.value_8  or
           l_temp.value_9  <> p_rec.value_9  or
           l_temp.value_10 <> p_rec.value_10 or
           l_temp.value_11 <> p_rec.value_11 or
           l_temp.value_12 <> p_rec.value_12 or
           l_temp.value_13 <> p_rec.value_13 or
           l_temp.value_14 <> p_rec.value_14 or
           l_temp.value_15 <> p_rec.value_15) then
           --
           begin
              --
              payplnk.g_payplnk_call := true;
              --
              update pay_batch_lines
              set value_1 = l_temp.value_1,
                  value_2 = l_temp.value_2,
                  value_3 = l_temp.value_3,
                  value_4 = l_temp.value_4,
                  value_5 = l_temp.value_5,
                  value_6 = l_temp.value_6,
                  value_7 = l_temp.value_7,
                  value_8 = l_temp.value_8,
                  value_9 = l_temp.value_9,
                  value_10 = l_temp.value_10,
                  value_11 = l_temp.value_11,
                  value_12 = l_temp.value_12,
                  value_13 = l_temp.value_13,
                  value_14 = l_temp.value_14,
                  value_15 = l_temp.value_15
              where batch_line_id = p_rec.batch_line_id;
              --
              payplnk.g_payplnk_call := false;
              --
           exception
              when others then
                 --
                 payplnk.g_payplnk_call := false;
                 --
                 pay_core_utils.push_message (800,'HR_449111_BEE_UPG_UPD','A');
                 pay_core_utils.push_token ('BATCH_LINE_ID', p_rec.batch_line_id);
                 hr_utility.raise_error;
                 --
           end;
           --
       end if;

   END convert_pay_input;
   --
   -- ----------------------------------------------------------------------------
   -- |--------------------------< upgrade_iv_values >----------------------------|
   -- ----------------------------------------------------------------------------
   -- {Start Of Comments}
   --
   -- Description:
   --   This procedure upgrades all input values for all batch lines
   --   belong to a given assignment.
   --
   -- In Parameters:
   --   NAME                           REQD TYPE     DESCRIPTION
   --   ----                           ---- ----     -----------
   --   P_ASSIGNMENT_ID                Yes  number   Assignment Id.
   --   P_BUSINESS_GROUP_ID            Yes  number   Business group of record.
   --
   -- {End Of Comments}
   --
   procedure upgrade_iv_values
     (P_ASG_ID                 in     number
     ) is
     --
     --
     cursor csr_min_asg_act is
        select cact.chunk_number,
               pbg.business_group_id,
               pbg.legislation_code,
               cact.payroll_action_id
          from pay_temp_object_actions cact,
               pay_payroll_actions pct,
               per_business_groups pbg
         where cact.object_id = P_ASG_ID
           and pct.payroll_action_id = cact.payroll_action_id
           and pbg.business_group_id = pct.business_group_id;
     --
     l_chunk_number pay_temp_object_actions.chunk_number%TYPE;
     --
     L_ASG_ID per_all_assignments_f.assignment_id%TYPE := P_ASG_ID;
     L_BG_ID per_all_assignments_f.business_group_id%TYPE NULL;
     L_LEG_CODE per_business_groups.legislation_code%TYPE := NULL;
     L_PCT_ID pay_payroll_actions.payroll_action_id%TYPE := NULL;
     --
     cursor csr_max_chunck_num (p_pct_id number) is
        select max(cact.chunk_number) last_chunk
          from pay_temp_object_actions cact
         where cact.payroll_action_id = p_pct_id;
     --
     L_MAX_CHUNK pay_temp_object_actions.chunk_number%TYPE;
     --
   begin
     --
     --
     hr_utility.set_location('pay_bee_upgrade_pkg.upgrade_iv_values',1);
     --
     --
     open csr_min_asg_act;
     fetch csr_min_asg_act into l_chunk_number,L_BG_ID,L_LEG_CODE,L_PCT_ID;
     close csr_min_asg_act;
     --

     --
     -- Within this loop each records will be fetched and its associated table contents
     -- will be updated.
     --

     --
     hr_utility.trace('ASG ID:'||L_ASG_ID);
     hr_utility.trace('LEG CODE:'||L_LEG_CODE);
     hr_utility.trace('BG ID:'||L_ASG_ID);
     --

     FOR g_rec IN csr_batch_lines(L_ASG_ID,L_BG_ID,L_LEG_CODE) LOOP

         --
         hr_utility.trace('BL ID:'||g_rec.batch_line_id);
         --

         -- Call subprogramms to update associated tables.
         convert_pay_input(g_rec);

     END LOOP;

     --
     -- If it is the last chunk then carry out the conversion for any
     -- remaining batch lines.
     --
     open csr_max_chunck_num(L_PCT_ID);
     fetch csr_max_chunck_num into L_MAX_CHUNK;
     close csr_max_chunck_num;
     --
     if l_chunk_number = L_MAX_CHUNK then
        --
        --
        -- Within this loop each records will be fetched and its associated table contents
        -- will be updated.
        --
        --
        hr_utility.trace('ASG ID:'||NULL);
        hr_utility.trace('LEG CODE:'||L_LEG_CODE);
        hr_utility.trace('BG ID:'||L_ASG_ID);
        --
        FOR g_rec IN csr_batch_lines(NULL,L_BG_ID,L_LEG_CODE) LOOP
            --
            hr_utility.trace('BL ID:'||g_rec.batch_line_id);
            --
            -- Call subprogramms to update associated tables.
            convert_pay_input(g_rec);
            --
        END LOOP;
        --
     end if;
     --

     --
     hr_utility.set_location('pay_bee_upgrade_pkg.upgrade_iv_values',2);
     --
     --
   end;
   --
   --
--
--
--
function upgrade_status
   (p_business_group_id number
   ,p_short_name        varchar2
   ) return varchar2 is
   --
   l_status pay_upgrade_status.status%type;
   --
 begin
   pay_core_utils.get_upgrade_status(p_business_group_id,p_short_name,l_status);
   --
   return l_status;
   --
 end upgrade_status;

end PAY_BEE_UPGRADE_PKG;

/
