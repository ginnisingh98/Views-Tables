--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_INTERNAL" AS
/* $Header: pytaxbsi.pkb 120.4.12010000.5 2009/08/21 09:33:57 emunisek ship $ */
--
-- Package Variables
--
   g_package  varchar2(33) := '  pay_us_tax_internal.';
   --
   PRV constant number := -1;
   NXT constant number := 1;
   --
   TYPE location_rec is record
      (
       assignment_id per_assignments_f.assignment_id%TYPE,
       location_id   per_assignments_f.location_id%TYPE,
       start_date    per_assignments_f.effective_start_date%TYPE,
       end_date      per_assignments_f.effective_end_date%TYPE
      );
   --
   TYPE location_tbl is table of location_rec index by
      binary_integer;

  cursor csr_get_tax_loc(p_assignment number, p_session_dt date) is
  select hsck.segment18
  from   HR_SOFT_CODING_KEYFLEX hsck,
         PER_ASSIGNMENTS_F      paf
  where  paf.assignment_id = p_assignment
  and    p_session_dt between paf.effective_start_date
                      and paf.effective_end_date
  and    hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
  and    hsck.segment18 is not null;

cursor csr_loc_addr(p_lc_id number) is
     select sta.state_code, cnt.county_code, cty.city_code,
	    sta2.state_code, cnt2.county_code, cty2.city_code
     from   hr_locations loc
           ,pay_us_states sta
           ,pay_us_counties cnt
           ,pay_us_city_names cty
           ,pay_us_states sta2
           ,pay_us_counties cnt2
           ,pay_us_city_names cty2
     where  loc.location_id = p_lc_id
     AND   cnt.state_code = sta.state_code
     AND   loc.town_or_city = cty.city_name
     AND   loc.region_1 = cnt.county_name
     AND   loc.region_2 = sta.state_abbrev
     AND   cnt.state_code = cty.state_code
     AND   cnt.county_code = cty.county_code
     AND   cnt2.state_code = sta2.state_code
     AND   nvl(loc.loc_information18,loc.town_or_city) = cty2.city_name
     AND   nvl(loc.loc_information19,loc.region_1) = cnt2.county_name
     AND   nvl(loc.loc_information17,loc.region_2) = sta2.state_abbrev
     AND   cnt2.state_code = cty2.state_code
     AND   cnt2.county_code = cty2.county_code;


  cursor csr_res_addr(p_person_id number,p_effective_date date) is
     select sta.state_code, cnt.county_code, cty.city_code,
	    sta2.state_code, cnt2.county_code, cty2.city_code
     from   per_addresses adr
           ,pay_us_states sta
           ,pay_us_counties cnt
           ,pay_us_city_names cty
	   ,pay_us_states sta2
	   ,pay_us_counties cnt2
	   ,pay_us_city_names cty2
     where  adr.person_id = p_person_id
     and    adr.primary_flag = 'Y'
     and    p_effective_date between adr.date_from
                                 and nvl(adr.date_to, hr_api.g_eot)
     AND   CNT.STATE_CODE = STA.STATE_CODE
     AND   ADR.TOWN_OR_CITY = CTY.CITY_NAME
     AND   ADR.REGION_1 = CNT.COUNTY_NAME
     AND   ADR.REGION_2 = STA.STATE_ABBREV
     AND   CNT.STATE_CODE = CTY.STATE_CODE
     AND   CNT.COUNTY_CODE = CTY.COUNTY_CODE
     AND   CNT2.STATE_CODE = STA2.STATE_CODE
     AND   nvl(adr.add_information18,ADR.TOWN_OR_CITY) = CTY2.CITY_NAME
     AND   nvl(adr.add_information19,ADR.REGION_1) = CNT2.COUNTY_NAME
     AND   nvl(adr.add_information17,ADR.REGION_2) = STA2.STATE_ABBREV
     AND   CNT2.STATE_CODE = CTY2.STATE_CODE
     AND   CNT2.COUNTY_CODE = CTY2.COUNTY_CODE;

/*  Bug# 6496113 and 5600887: Condition checks for date effectivity which is not
    required for person address form. The person address form will use the
    following cursor */
  cursor csr_res_addr_no_eff_dt(p_person_id number,p_effective_date date) is
          select sta.state_code, cnt.county_code, cty.city_code,
	    sta2.state_code, cnt2.county_code, cty2.city_code
     from   per_addresses adr
           ,pay_us_states sta
           ,pay_us_counties cnt
           ,pay_us_city_names cty
	   ,pay_us_states sta2
	   ,pay_us_counties cnt2
	   ,pay_us_city_names cty2
     where  adr.person_id = p_person_id
     and    adr.primary_flag = 'Y'


     AND   CNT.STATE_CODE = STA.STATE_CODE
     AND   ADR.TOWN_OR_CITY = CTY.CITY_NAME
     AND   ADR.REGION_1 = CNT.COUNTY_NAME
     AND   ADR.REGION_2 = STA.STATE_ABBREV
     AND   CNT.STATE_CODE = CTY.STATE_CODE
     AND   CNT.COUNTY_CODE = CTY.COUNTY_CODE
     AND   CNT2.STATE_CODE = STA2.STATE_CODE
     AND   nvl(adr.add_information18,ADR.TOWN_OR_CITY) = CTY2.CITY_NAME
     AND   nvl(adr.add_information19,ADR.REGION_1) = CNT2.COUNTY_NAME
     AND   nvl(adr.add_information17,ADR.REGION_2) = STA2.STATE_ABBREV
     AND   CNT2.STATE_CODE = CTY2.STATE_CODE
     AND   CNT2.COUNTY_CODE = CTY2.COUNTY_CODE;


 cursor csr_future_state_rule( p_state_code number,
			       p_assignment_id number,
				l_csr_date date default hr_api.g_sot) is
    select null
    from   pay_us_emp_state_tax_rules_f sta
    where  sta.assignment_id = p_assignment_id
    and    sta.state_code = p_state_code
    and    sta.effective_start_date > l_csr_date;
  --
  cursor csr_future_county_rule( p_state_code number, p_county_code number,
				 p_assignment_id number,
				 l_csr_date date default hr_api.g_sot) is
    select null
    from   pay_us_emp_county_tax_rules_f cnt
    where  cnt.assignment_id = p_assignment_id
    and    cnt.state_code = p_state_code
    and    cnt.county_code = p_county_code
    and    cnt.effective_start_date > l_csr_date;
  --
  cursor csr_future_city_rule( p_state_code number, p_county_code number,
			       p_city_code varchar2, p_assignment_id number,
			       l_csr_date date default hr_api.g_sot) is
    select null
    from   pay_us_emp_city_tax_rules_f cty
    where  cty.assignment_id = p_assignment_id
    and    cty.state_code = p_state_code
    and    cty.county_code = p_county_code
    and    cty.city_code = p_city_code
    and    cty.effective_start_date > l_csr_date;
  --
  -- reimp - moved csr because its used by more than one proc.
  --
  cursor csr_defaulting_met(p_asg_id number,p_ef_date date) is
    select null
    from   per_assignments_f asg, per_addresses adr
    where  asg.assignment_id = p_asg_id
    and    p_ef_date between asg.effective_start_date
           and asg.effective_end_date
    and    asg.pay_basis_id is not null
    and    asg.payroll_id is not null
    and    asg.location_id is not null
    and    asg.soft_coding_keyflex_id is not null
    and    asg.assignment_type = 'E'
    and    asg.person_id = adr.person_id
    and    p_ef_date between adr.date_from
                              and nvl(adr.date_to, hr_api.g_eot)
    and    adr.primary_flag = 'Y'
    and    rownum = 1
    and    exists (select null
                   from  hr_soft_coding_keyflex sck
                   where sck.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
                   and   sck.segment1 is not null);
  --

  cursor csr_defaulting_date(p_assignment_id number) is
    select 	min(effective_start_date)
    from 	pay_us_emp_fed_tax_rules_f
    where 	assignment_id = p_assignment_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_tax_rules_for_jd >-------------------------|
-- ----------------------------------------------------------------------------
--
   Procedure create_tax_rules_for_jd
      (
 	p_state_code		   in  varchar default null,
	p_county_code		   in  varchar default null,
	p_city_code		   in  varchar default null,
	p_assignment_id		   in  varchar default null,
	p_effective_date	   in  date
      ) IS

   	l_tmp_id number;
	l_tmp_ovn number;
	l_tmp_eff_start_date date;
	l_tmp_eff_end_date date;
	l_temp_char varchar2(50);

 begin

  if p_state_code is not null then

    open csr_future_state_rule(p_state_code,p_assignment_id);
    fetch csr_future_state_rule into l_temp_char;
    if csr_future_state_rule%notfound then
      close csr_future_state_rule; -- 3431376
      pay_state_tax_rule_api.create_state_tax_rule (
                     p_effective_date         => p_effective_date
                    ,p_default_flag           => 'Y'
                    ,p_assignment_id          => p_assignment_id
                    ,p_state_code             => p_state_code
                    ,p_emp_state_tax_rule_id  => l_tmp_id
                    ,p_object_version_number  => l_tmp_ovn
                    ,p_effective_start_date   => l_tmp_eff_start_date
                    ,p_effective_end_date     => l_tmp_eff_end_date
                    );
    else
       close csr_future_state_rule;
    end if;

    if p_county_code is not null then
     	 open csr_future_county_rule(p_state_code,p_county_code,
				     p_assignment_id);
     	 fetch csr_future_county_rule into l_temp_char;
     	 if csr_future_county_rule%notfound then
                close csr_future_county_rule;
      	    	pay_county_tax_rule_api.create_county_tax_rule (
                   p_effective_date         => p_effective_date
                  ,p_assignment_id          => p_assignment_id
                  ,p_state_code             => p_state_code
                  ,p_county_code            => p_county_code
                  ,p_additional_wa_rate     => 0
                  ,p_filing_status_code     => '01'
                  ,p_lit_additional_tax     => 0
                  ,p_lit_override_amount    => 0
                  ,p_lit_override_rate      => 0
                  ,p_withholding_allowances => 0
                  ,p_lit_exempt             => 'N'
                  ,p_emp_county_tax_rule_id => l_tmp_id
                  ,p_object_version_number  => l_tmp_ovn
                  ,p_effective_start_date   => l_tmp_eff_start_date
                  ,p_effective_end_date     => l_tmp_eff_end_date
                  );
         else
            close csr_future_county_rule;
         end if;

	 if p_city_code is not null then
    	   open csr_future_city_rule(p_state_code,p_county_code,
		 	      	     p_city_code,p_assignment_id);
    	   fetch csr_future_city_rule into l_temp_char;
    	   if csr_future_city_rule%notfound then
                close csr_future_city_rule;
      		pay_city_tax_rule_api.create_city_tax_rule (
                   p_effective_date         => p_effective_date
                  ,p_assignment_id          => p_assignment_id
                  ,p_state_code             => p_state_code
                  ,p_county_code            => p_county_code
                  ,p_city_code              => p_city_code
                  ,p_additional_wa_rate     => 0
                  ,p_filing_status_code     => '01'
                  ,p_lit_additional_tax     => 0
                  ,p_lit_override_amount    => 0
                  ,p_lit_override_rate      => 0
                  ,p_withholding_allowances => 0
                  ,p_lit_exempt             => 'N'
                  ,p_emp_city_tax_rule_id   => l_tmp_id
                  ,p_object_version_number  => l_tmp_ovn
                  ,p_effective_start_date   => l_tmp_eff_start_date
                  ,p_effective_end_date     => l_tmp_eff_end_date
                  );
           else
              close csr_future_city_rule;
           end if;

	 end if; -- city not null
       end if;	-- county not null
     end if; -- state not not null
end create_tax_rules_for_jd;

--
-- ----------------------------------------------------------------------------
-- |----------------------< maintain_tax_percentage >-------------------------|
-- ----------------------------------------------------------------------------
--
   Procedure maintain_tax_percentage
      (
       p_assignment_id              in     number,
       p_effective_date             in     date,
       p_state_code                 in     varchar2,
       p_county_code                in     varchar2,
       p_city_code                  in     varchar2,
       p_percentage                 in     number  default 0,
       p_calculate_pct              in     boolean default true,
       p_datetrack_mode             in     varchar2,
       p_effective_start_date       in out nocopy date,
       p_effective_end_date         in out nocopy date
      ) is
      --
      -- -----------------------------------------------------------------
      -- Declare cursors, types and local variables
      -- -----------------------------------------------------------------
      --
      -- Cursor to determine all of the location changes in an
      -- assignment.
      --
      -- reimp - changed cursor to only return rows on or after the defaulting
      -- of taxes
      Cursor csr_assignment_locations(p_assignment_id number,
				      p_def_date date) is
         select location_id,
                effective_start_date,
                effective_end_date
         from per_assignments_f
         where assignment_id = p_assignment_id
	   and effective_start_date >= p_def_date
         order by effective_start_date;
      --
      -- cursor finds the subordinate jurisdictions for use in
      -- the percent sum routine.
      --
      cursor csr_get_sub_jurisdictions
                (
                 p_assignment_id             number,
                 p_subordinate_jurisdiction  varchar2,
                 p_exclude_jurisdiction      varchar2,
                 p_effective_date            date
                ) is
         select peef.effective_start_date,
            peef.effective_end_date,
            peevf.screen_entry_value
         from pay_element_entries_f peef,
              pay_element_entry_values_f peevf,
              pay_input_values_f pivf,
              pay_element_types_f petf,
              pay_element_links_f pelf
         where peef.assignment_id = p_assignment_id
           and peef.creator_type = 'UT'
           and petf.element_name = 'VERTEX'
           and peevf.screen_entry_value like p_subordinate_jurisdiction||'%'
           and peevf.screen_entry_value not like '%'||p_exclude_jurisdiction||'%'
           and upper(pivf.name)='JURISDICTION'
           and peevf.input_value_id = pivf.input_value_id
           and peef.element_entry_id = peevf.element_entry_id
           and p_effective_date between peef.effective_start_date and
               peef.effective_end_date
           and peef.effective_start_date = peevf.effective_start_date
           and peef.effective_end_date = peevf.effective_end_date
           and peef.element_link_id = pelf.element_link_id
           and pelf.element_type_id = petf.element_type_id
         order by peef.assignment_id asc,
                  petf.element_name asc,
                  peef.element_entry_id asc,
                  peef.effective_start_date asc,
                  peevf.element_entry_value_id asc;

      -- Cursor to get the 'VERTEX' element type.
      --
      Cursor csr_vertex_element is
         select petf.element_type_id,
                pivf.input_value_id,
                pivf.name
         from PAY_ELEMENT_TYPES_F petf,
              PAY_INPUT_VALUES_F pivf
         where petf.element_name = 'VERTEX'
           and p_effective_date between petf.effective_start_date
              and petf.effective_end_date
           and petf.element_type_id = pivf.element_type_id
           and p_effective_date between pivf.effective_start_date
              and pivf.effective_end_date;
      --
      -- Cursor to get the 'VERTEX' element entry for
      -- the jurisdiction.
      --
      cursor csr_ele_entry (p_element_link  number,
                            p_input_val     number,
                            p_jurisdiction  varchar2,
                            p_assignment_id number) is
         select peef.element_entry_id
         from PAY_ELEMENT_ENTRIES_F peef,
              PAY_ELEMENT_ENTRY_VALUES_F pevf
         where peef.assignment_id = p_assignment_id
           and p_effective_date between peef.effective_start_date
           and peef.effective_end_date
           and peef.element_link_id = p_element_link
           and pevf.element_entry_id = peef.element_entry_id
           and p_effective_date between pevf.effective_start_date
              and pevf.effective_end_date
           and pevf.input_value_id = p_input_val
           and pevf.screen_entry_value like p_jurisdiction;
      --
      -- Cursor to get the 'VERTEX' element entry for
      -- the jurisdiction.(INSERT OVERRIDE)
      --
      cursor csr_ele_entry_io (p_element_link  number,
                               p_input_val     number,
                               p_jurisdiction  varchar2,
                               p_assignment_id number) is
         select peef.element_entry_id, peef.effective_start_date
         from PAY_ELEMENT_ENTRIES_F peef,
              PAY_ELEMENT_ENTRY_VALUES_F pevf
         where peef.assignment_id = p_assignment_id
           and peef.element_link_id = p_element_link
           and pevf.element_entry_id = peef.element_entry_id
           and pevf.input_value_id = p_input_val
           and pevf.screen_entry_value = p_jurisdiction
           and rownum = 1
           order by peef.effective_start_date asc;
      --
      -- Finds all vertex entries for an assignment
      -- in a particular jurisdiction for INSERT_OVERRIDE.
      --
      cursor csr_vertex_in_jurisdiction(p_element_link number,
                                        p_input_val number)is
         select peef.element_entry_id, peef.effective_start_date,
                peef.effective_end_date
         from PAY_ELEMENT_ENTRIES_F peef,
              PAY_ELEMENT_ENTRY_VALUES_F pevf
         where peef.assignment_id = p_assignment_id
           and peef.element_link_id = p_element_link
           and pevf.element_entry_id = peef.element_entry_id
           and p_effective_date between pevf.effective_start_date
              and pevf.effective_end_date
           and pevf.input_value_id = p_input_val
           and pevf.screen_entry_value =
               p_state_code ||'-'|| p_county_code ||'-'|| p_city_code
         order by peef.effective_start_date;
      --
      -- Cursor to get the current percentage of the element entry
      --
      cursor csr_get_curr_percnt (p_ele_entry_id   number,
                                  p_input_val      number,
                                  p_effective_date date)is
         select screen_entry_value
         from PAY_ELEMENT_ENTRY_VALUES_F
         where element_entry_id = p_ele_entry_id
           and  p_effective_date between effective_start_date
              and effective_end_date
           and input_value_id = p_input_val
           and screen_entry_value is not null;
      --
      -- Find all jurisdiction codes for a given assignment.
      --
      cursor csr_get_jurisdiction (l_assignment_id  number,
                                   l_effective_date date) is
         select /*+ ORDERED
                    INDEX(PAF PER_ASSIGNMENTS_F_PK)
                    USE_NL(PAF, HL, PUS, PUC, PUCN) */
                pus.state_code ||'-'|| puc.county_code ||'-'|| pucn.city_code
         from per_assignments_f paf,
              hr_locations      hl,
              pay_us_states     pus,
              pay_us_counties   puc,
              pay_us_city_names pucn
         where paf.assignment_id  = l_assignment_id
           and l_effective_date   between paf.effective_start_date
                                      and paf.effective_end_date
           and hl.location_id     = paf.location_id
           and nvl(hl.loc_information18, hl.town_or_city) = pucn.city_name
           and nvl(hl.loc_information19, hl.region_1)     = puc.county_name
           and nvl(hl.loc_information17, hl.region_2)     = pus.state_abbrev
           and pus.state_code     = puc.state_code
           and puc.state_code     = pucn.state_code
           and puc.county_code    = pucn.county_code;
      --
      cursor csr_get_ele_entry_id(
                                  p_assignment_id  number,
                                  p_jurisdiction   varchar2,
                                  p_effective_date date
                                 ) is
         select peef.element_entry_id
         from pay_element_entries_f peef, pay_element_entry_values_f peevf,
              pay_element_links_f pelf, pay_element_types_f petf
         where peef.assignment_id= p_assignment_id
           and petf.element_name='VERTEX'
           and peevf.screen_entry_value = p_jurisdiction
           and p_effective_date between peef.effective_start_date
               and peef.effective_end_date
           and peef.element_link_id = pelf.element_link_id
           and pelf.element_type_id = petf.element_type_id
           and peef.element_entry_id = peevf.element_entry_id
           and p_effective_date between peevf.effective_start_date
               and peevf.effective_end_date;
      --
      TYPE l_element_rec is table of csr_vertex_in_jurisdiction%ROWTYPE
           index by binary_integer;
      --
      TYPE location_rec is record
         (
          assignment_id per_assignments_f.assignment_id%TYPE,
          location_id   per_assignments_f.location_id%TYPE,
          start_date    per_assignments_f.effective_start_date%TYPE,
          end_date      per_assignments_f.effective_end_date%TYPE
         );
      --
      TYPE location_tbl is table of location_rec index by
           binary_integer;
      --
      l_proc                 varchar2(72) := g_package||'maintain_tax_percentage';
      l_element_type_id      pay_element_types_f.element_type_id%TYPE := null;
      t_element_entry_id     pay_element_types_f.element_type_id%TYPE := null;
      l_input_value_id_tbl   hr_entry.number_table;
      l_new_vertex_value_tbl hr_entry.varchar2_table;
      l_element_rec_tbl      l_element_rec;
      l_asg_tbl              location_tbl;
      l_location_chg_tbl     location_tbl;
      l_state_code           pay_us_emp_city_tax_rules_f.state_code%TYPE;
      l_county_code          pay_us_emp_city_tax_rules_f.county_code%TYPE;
      l_city_code            pay_us_emp_city_tax_rules_f.city_code%TYPE;
      l_jurisdiction         pay_us_emp_city_tax_rules_f.jurisdiction_code%TYPE;
      l_datetrack_mode       varchar2(30);
      l_location_id          per_assignments_f.location_id%TYPE;
      l_start_date           per_assignments_f.effective_start_date%TYPE;
      l_end_date             per_assignments_f.effective_end_date%TYPE;
      cur_location_id        per_assignments_f.location_id%TYPE;
      cur_start_date         per_assignments_f.effective_start_date%TYPE;
      cur_end_date           per_assignments_f.effective_end_date%TYPE;
      l_effective_start_date pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
      l_effective_end_date   pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
      l_assignment_id        per_assignments_f.assignment_id%TYPE := null;
      l_effective_date       per_assignments_f.effective_start_date%TYPE := null;
      l_input_value_id       pay_input_values_f.input_value_id%TYPE := null;
      l_input_name           pay_input_values_f.name%TYPE := null;
      l_element_link_id      pay_element_links_f.element_link_id%TYPE := null;
      l_element_entry_id     pay_element_entries_f.element_entry_id%TYPE := null;
      l_io                   boolean;
      l_modified_correction  boolean := FALSE;
      l_validate             boolean;
      l_payroll_installed    boolean;
      l_inc                  number;
      l_asg_inc              number;
      l_pct_inc              number;
      l_percentage           number;
      l_defaulting_date      date;
      l_entry_found          boolean;
      t_effective_start_date date;
--
-- ----------------------------------------------------------------------------
-- |-------------------< get_curr_jurisdiction_db_value >---------------------|
-- ----------------------------------------------------------------------------
--
   function get_curr_jurisdiction_db_value
               (
                p_assignment_id      number,
                p_jurisdiction       varchar2,
                p_effective_date     date,
                p_element_link_id    number,
                p_input_value_id_tbl hr_entry.number_table
               )
   return number is
      l_element_entry_id   number;
      l_cp		   varchar2(80);
      l_current_percentage number;
      l_proc                 varchar2(72)
                             := g_package||'get_curr_jurisdiction_db_value';
   begin
      hr_utility.set_location('Entering:'||l_proc, 10);
      open csr_ele_entry
              (
               p_element_link_id,
               p_input_value_id_tbl(2),
               p_jurisdiction,
               p_assignment_id
              );
      fetch csr_ele_entry into l_element_entry_id;
      hr_utility.set_location(l_proc, 20);
      if csr_ele_entry%FOUND then
         close csr_ele_entry;
         open csr_get_curr_percnt
                 (
                  l_element_entry_id,
                  p_input_value_id_tbl(3),
                  p_effective_date
                 );
         fetch csr_get_curr_percnt into l_cp;
	 l_current_percentage := fnd_number.canonical_to_number(l_cp);
         if csr_get_curr_percnt%FOUND then
            close csr_get_curr_percnt;
            return l_current_percentage;
         else
            close csr_get_curr_percnt;
         end if;
      end if;
      close csr_ele_entry;
      hr_utility.set_location('Leaving:'||l_proc, 30);
      return 0;
   end get_curr_jurisdiction_db_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_work_location >---------------------------|
-- ----------------------------------------------------------------------------
-- Check to see if the jurisdiction is a work location.
--
   function chk_work_location(l_assignment_id  number,
                              p_effective_date date,
                              p_jurisdiction   varchar2
                             )
   return boolean is
      l_jurisdiction varchar2(11);
      l_proc                 varchar2(72)
                             := g_package||'chk_work_location';
   begin
      hr_utility.set_location('Entering:'||l_proc, 10);
      open csr_get_jurisdiction
              (
               p_assignment_id,
               p_effective_date
              );
      fetch csr_get_jurisdiction into l_jurisdiction;
      if csr_get_jurisdiction%FOUND and
         l_jurisdiction = p_jurisdiction then
         close csr_get_jurisdiction;
         return TRUE;
      else
         close csr_get_jurisdiction;
         return FALSE;
      end if;
      hr_utility.set_location('Leaving:'||l_proc, 20);
   end chk_work_location;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< asg_loc_comp >------------------------------|
-- ----------------------------------------------------------------------------
-- Determine if an assignment's current location has been changed to the same
-- location as the next or previous assignment record.
--
   function asg_loc_comp(
                         t_asg_tbl         location_tbl,
                         l_prev_next       number,
                         l_effective_date  date,
                         l_defaulting_date date
                        )
   return boolean is
      l_inc number;
      l_proc                 varchar2(72)
                             := g_package||'asg_loc_comp';
   Begin
      hr_utility.set_location('Entering:'||l_proc, 10);
      if t_asg_tbl.first is not null then
         l_inc := t_asg_tbl.first;
         while t_asg_tbl.exists(l_inc) loop
            if l_effective_date >= t_asg_tbl(l_inc).start_date
               and l_effective_date <= t_asg_tbl(l_inc).end_date
               then
               if t_asg_tbl.exists(l_inc+l_prev_next) then
                  if t_asg_tbl(l_inc).location_id =
                     t_asg_tbl(l_inc+l_prev_next).location_id and
                     t_asg_tbl(l_inc+l_prev_next).start_date >=
                     l_defaulting_date then
                     return TRUE;
                  end if;
               end if;
            end if;
         l_inc := t_asg_tbl.next(l_inc);
         end loop;
      end if;
      hr_utility.set_location('Leaving:'||l_proc, 20);
      return FALSE;
   end asg_loc_comp;
--
-- ----------------------------------------------------------------------------
-- |--------------------< set_and_correct_jurisdiction >----------------------|
-- ----------------------------------------------------------------------------
-- This procedure corrects the actual percentage stored within the
-- pay_element_entry_values_f structure for a 'VERTEX' element in a given
-- jurisdiction.
--
    procedure set_and_correct_jurisdiction
               (
                p_assignment_id      number,
                p_jurisdiction       varchar2,
                p_percentage         number,
                p_element_link_id    number,
                p_input_value_id_tbl hr_entry.number_table,
                p_effective_date     date
               )
   is
      l_proc                 varchar2(72)
                             := g_package||'set_and_correct_jurisdiction';
      l_new_vertex_value_tbl hr_entry.varchar2_table;
      l_element_entry_id     number;
   begin
      hr_utility.set_location('Entering:'||l_proc, 10);
      open csr_ele_entry
              (
               p_element_link_id,
               p_input_value_id_tbl(2),
               p_jurisdiction,
               p_assignment_id
              );
      fetch csr_ele_entry into l_element_entry_id;
      if csr_ele_entry%FOUND then
         close csr_ele_entry;
         l_new_vertex_value_tbl(1)     := null;
         l_new_vertex_value_tbl(2)     := p_jurisdiction;
         if p_percentage is not null then
            hr_utility.set_location(l_proc, 20);
            l_new_vertex_value_tbl(3)     := fnd_number.canonical_to_number(p_percentage);
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'CORRECTION',
                p_session_date             => p_effective_date,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => p_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         else
            hr_utility.set_location(l_proc, 30);
            hr_utility.set_message(801, 'HR_7040_PERCENT_RANGE');
            hr_utility.set_message_token('1',l_proc);
            hr_utility.raise_error;
         end if;
      else
               hr_utility.set_message(801, 'HR_13140_TAX_ELEMENT_ERROR');
               hr_utility.set_message_token('2','VERTEX');
               hr_utility.raise_error;
      end if;
      hr_utility.set_location('Leaving:'||l_proc, 40);
   end set_and_correct_jurisdiction;
--
-- ----------------------------------------------------------------------------
-- |------------------< get_sub_jurisdiction_sum >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure determines the percentage sum of subordinate jurisdictions
-- for the current jurisdiction at the effective_date for an assignemnt.
--
   function get_sub_jurisdiction_sum
               (
                p_jurisdiction        varchar2,
                p_assignment_id       number,
                p_element_link_id     number,
                p_input_value_id_tbl  hr_entry.number_table,
                p_effective_date      date
               )
   return number is
      l_state                varchar2(10);
      l_county               varchar2(10);
      l_city                 varchar2(10);
      l_exclude_jurisdiction varchar2(11);
      l_sum                  number := 0;
      l_proc                 varchar2(72)
                             := g_package||'get_sub_jurisdiction_sum';
   begin
      hr_utility.set_location('Entering:'||l_proc, 10);
      l_state := substr(p_jurisdiction,1,2);
      l_county := nvl(substr(p_jurisdiction,4,3),'000');
      l_city := nvl(substr(p_jurisdiction,8,4),'0000');
      l_exclude_jurisdiction := l_state||'-'||l_county||'-'||l_city;
      for sub_jurisdiction in csr_get_sub_jurisdictions
                (
                 p_assignment_id,
                 p_jurisdiction,
                 l_exclude_jurisdiction,
                 p_effective_date
                ) loop
         l_sum := l_sum + get_curr_jurisdiction_db_value
                             (
                              p_assignment_id,
                              sub_jurisdiction.screen_entry_value,
                              p_effective_date,
                              p_element_link_id,
                              p_input_value_id_tbl
                             );
      end loop;
      hr_utility.set_location('Leaving:'||l_proc, 20);
      return l_sum;
   end get_sub_jurisdiction_sum;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< calculate_db_percentage >------------------------|
-- ----------------------------------------------------------------------------
-- This procedure determines the actual percentage to be stored within the
-- pay_element_entry_values_f structure for a 'VERTEX' element in a given
-- jurisdiction.
--
   procedure calculate_db_percentage
                (
                 p_scn_percent          number,
                 p_state_code           varchar2,
                 p_county_code          varchar2,
                 p_city_code            varchar2,
                 p_element_link_id      number,
                 p_input_value_id_tbl   hr_entry.number_table,
                 p_effective_date       date
                )
   is
      l_proc                   varchar2(72) := g_package||'calculate_db_percentage';
      l_curr_cty_db_value      number :=0;
      l_curr_cnt_db_value      number :=0;
      l_curr_sta_db_value      number :=0;
      l_new_cty_db_value       number :=0;
      l_new_cnt_db_value       number :=0;
      l_new_sta_db_value       number :=0;
      l_cty_sum                number :=0;
      l_cty_cnt_sum            number :=0;
      l_other_jurisdiction_sum number :=0;
   begin
      hr_utility.set_location('Entering:'||l_proc, 10);
      l_jurisdiction := p_state_code||'-'||
                        p_county_code||'-'||
                        p_city_code;
      if p_city_code <> '0000' then
         hr_utility.set_location(l_proc, 15);
         l_curr_cty_db_value := get_curr_jurisdiction_db_value
                                   (
                                    p_assignment_id,
                                    l_jurisdiction,
                                    p_effective_date,
                                    p_element_link_id,
                                    p_input_value_id_tbl
                                   );
         hr_utility.set_location(l_proc, 20);
         l_curr_cnt_db_value := get_curr_jurisdiction_db_value
                                   (
                                    p_assignment_id,
                                    p_state_code||'-'||
                                    p_county_code||'-0000',
                                    p_effective_date,
                                    p_element_link_id,
                                    p_input_value_id_tbl
                                   );
         l_new_cnt_db_value := l_curr_cty_db_value - p_scn_percent +
                               l_curr_cnt_db_value;
         if l_new_cnt_db_value < 0 then
            hr_utility.set_message(801, 'PAY_52236_TAX_CITY_PERCENT');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP','25');
            hr_utility.raise_error;
         else
            hr_utility.set_location(l_proc, 30);
            set_and_correct_jurisdiction
               (
                p_assignment_id,
                l_jurisdiction,
                p_scn_percent,
                p_element_link_id,
                p_input_value_id_tbl,
                p_effective_date
               );
            hr_utility.set_location(l_proc, 35);
            set_and_correct_jurisdiction
               (
                p_assignment_id,
                p_state_code||'-'||p_county_code||'-0000',
                l_new_cnt_db_value,
                p_element_link_id,
                p_input_value_id_tbl,
                p_effective_date
               );
         end if;
      elsif p_county_code <> '000' and p_city_code = '0000' then
         hr_utility.set_location(l_proc, 40);
         l_curr_cnt_db_value := get_curr_jurisdiction_db_value
                                   (
                                    p_assignment_id,
                                    l_jurisdiction,
                                    p_effective_date,
                                    p_element_link_id,
                                    p_input_value_id_tbl
                                   );
         hr_utility.set_location(l_proc, 45);
         l_cty_sum := get_sub_jurisdiction_sum
                         (
                          p_state_code||'-'||p_county_code,
                          p_assignment_id,
                          p_element_link_id,
                          p_input_value_id_tbl,
                          p_effective_date
                          );
         hr_utility.set_location(l_proc, 50);
         l_curr_sta_db_value := get_curr_jurisdiction_db_value
                                   (
                                    p_assignment_id,
                                    p_state_code||'-'||'000-0000',
                                    p_effective_date,
                                    p_element_link_id,
                                    p_input_value_id_tbl
                                   );
         l_new_cnt_db_value := p_scn_percent - l_cty_sum;
         if l_new_cnt_db_value < 0 then
            hr_utility.set_message(801, 'PAY_72831_TAX_MIN_CNT_PCT');
            hr_utility.raise_error;
         else
            hr_utility.set_location(l_proc, 60);
            l_new_sta_db_value := l_curr_cnt_db_value - l_new_cnt_db_value
                                  + l_curr_sta_db_value;
            if l_new_sta_db_value < 0 then
               hr_utility.set_message(801, 'PAY_52237_TAX_COUNTY_PERCENT');
               hr_utility.raise_error;
            else
               hr_utility.set_location(l_proc, 70);
               set_and_correct_jurisdiction
                  (
                   p_assignment_id,
                   l_jurisdiction,
                   l_new_cnt_db_value,
                   p_element_link_id,
                   p_input_value_id_tbl,
                   p_effective_date
                  );
               hr_utility.set_location(l_proc, 75);
               set_and_correct_jurisdiction
                  (
                   p_assignment_id,
                   p_state_code||'-'||'000-0000',
                   l_new_sta_db_value,
                   p_element_link_id,
                   p_input_value_id_tbl,
                   p_effective_date
                  );
            end if;
         end if;
      elsif p_state_code <> '00' and p_county_code = '000' and
            p_city_code = '0000' then
         hr_utility.set_location(l_proc, 80);
         l_cty_cnt_sum := get_sub_jurisdiction_sum
                             (
                              p_state_code,
                              p_assignment_id,
                              p_element_link_id,
                              p_input_value_id_tbl,
                              p_effective_date
                             );
         l_new_sta_db_value := p_scn_percent - l_cty_cnt_sum;
         if l_new_sta_db_value < 0 then
            hr_utility.set_message(801, 'PAY_72832_TAX_MIN_STA_PCT');
            hr_utility.raise_error;
         else
            hr_utility.set_location(l_proc, 90);
            for asg_other_jurisdiction in csr_get_sub_jurisdictions
                                             (
                                              p_assignment_id,
                                              '',
                                              p_state_code||'-',
                                              p_effective_date
                                             ) loop
               hr_utility.set_location(l_proc, 95);
               l_other_jurisdiction_sum := l_other_jurisdiction_sum +
                                           get_curr_jurisdiction_db_value
                                              (
                                               p_assignment_id,
                                               asg_other_jurisdiction.screen_entry_value,
                                               p_effective_date,
                                               p_element_link_id,
                                               p_input_value_id_tbl
                                              );
            end loop;
            if l_cty_cnt_sum + l_new_sta_db_value +
               l_other_jurisdiction_sum > 100 then
               hr_utility.set_message(801, 'PAY_72833_TAX_MAX_STA_PCT');
               hr_utility.raise_error;
            else
               hr_utility.set_location(l_proc, 105);
               set_and_correct_jurisdiction
                  (
                   p_assignment_id,
                   l_jurisdiction,
                   l_new_sta_db_value,
                   p_element_link_id,
                   p_input_value_id_tbl,
                   p_effective_date
                  );
            end if;
         end if;
      end if;
      hr_utility.set_location('Leaving:'||l_proc, 110);
   end calculate_db_percentage;

   Begin
      --
      hr_utility.set_location('Entering:'|| l_proc, 5);
      --
      --
      -- Process Logic
      --
      --
      -- Check to see if the PAYROLL product is installed.
      --
      l_payroll_installed := hr_utility.chk_product_install
                                (p_product     =>'Oracle Payroll',
                                 p_legislation =>'US');
      if l_payroll_installed then

       hr_utility.set_location(l_proc, 15);
         --
         -- Find the element entry type id, input_value, and
         -- input name for and element type with a screen value
         -- of 'VERTEX'.
         --
         Open csr_vertex_element;

         hr_utility.set_location(l_proc, 20);

         loop
            Fetch csr_vertex_element into l_element_type_id,
                                       l_input_value_id,
                                       l_input_name;
            exit when csr_vertex_element%NOTFOUND;

            if upper(l_input_name) = 'PAY VALUE' then
               l_input_value_id_tbl(1) := l_input_value_id;
            elsif upper(l_input_name) = 'JURISDICTION' then
               l_input_value_id_tbl(2) := l_input_value_id;
            elsif upper(l_input_name) = 'PERCENTAGE' then
               l_input_value_id_tbl(3) := l_input_value_id;
            end if;
         end loop;

         Close csr_vertex_element;

         hr_utility.set_location(l_proc, 25);

         --
         -- Check that all of the input value id(s)
         -- for the vertex element exist.
         --
         for i in 1..3 loop
            if l_input_value_id_tbl(i) = null or
               l_input_value_id_tbl(i) = 0 then
               hr_utility.set_message(801, 'HR_13140_TAX_ELEMENT_ERROR');
               hr_utility.set_message_token('26','VERTEX');
               hr_utility.raise_error;
            end if;
         end loop;
         --
         hr_utility.set_location(l_proc, 30);
         --
         -- assign the parameters to local variables because
         -- the element entry procedures expect them to be in
         -- out parameters
         --
         l_effective_start_date   := p_effective_start_date;
         l_effective_end_date     := p_effective_end_date;
         l_datetrack_mode         := p_datetrack_mode;

         l_jurisdiction := p_state_code||'-'||
                           p_county_code||'-'||p_city_code;

         if p_datetrack_mode <> 'ZAP' then
            --
            -- Get element link id
            --
            l_element_link_id := hr_entry_api.get_link
                                    (
                                     p_assignment_id   => p_assignment_id,
                                     p_element_type_id => l_element_type_id,
                                     p_session_date    => l_effective_start_date
                                    );
            if l_element_link_id is null or
               l_element_link_id = 0 then
               hr_utility.set_message(801, 'HR_13140_TAX_ELEMENT_ERROR');
               hr_utility.set_message_token('31','VERTEX');
               hr_utility.raise_error;
            end if;
         else
            open csr_get_ele_entry_id(
                                      p_assignment_id,
                                      l_jurisdiction,
                                      p_effective_date
                                     );
            fetch csr_get_ele_entry_id into l_element_entry_id;
            close csr_get_ele_entry_id;
         end if;
         --
         hr_utility.set_location(l_proc, 35);
         --
         if p_percentage < 0 or p_percentage > 100 then
            hr_utility.set_message(801, 'HR_7040_PERCENT_RANGE');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP','36');
            hr_utility.raise_error;
         end if;
         --
         --  Store screen entry value in the table
         --
         l_new_vertex_value_tbl(1)     := null;
         l_new_vertex_value_tbl(2)     := l_jurisdiction;
         l_new_vertex_value_tbl(3)     := nvl(fnd_number.canonical_to_number(p_percentage),'0');
         --
         If p_datetrack_mode in ('DELETE_NEXT_CHANGE',
                                 'FUTURE_CHANGE',
                                 'DELETE',
                                 'CORRECTION',
                                 'UPDATE',
                                 'UPDATE_CHANGE_INSERT',
                                 'UPDATE_OVERRIDE',
                                 'INSERT_OVERRIDE',
                                 'INSERT_OLD') then
            --
            hr_utility.set_location(l_proc, 40);
            --
            -- Find the element link id for the current assignment
            -- with the derived element entry type id.
            --
            if p_datetrack_mode = 'INSERT_OVERRIDE' then
               Open csr_ele_entry_io (
                                      l_element_link_id,
                                      l_input_value_id_tbl(2),
                                      l_jurisdiction,
                                      p_assignment_id);
               Fetch csr_ele_entry_io into l_element_entry_id, t_effective_start_date;
               Close csr_ele_entry_io;
            else
               Open csr_ele_entry (
                                   l_element_link_id,
                                   l_input_value_id_tbl(2),
                                   l_jurisdiction,
                                   p_assignment_id
                                  );
               Fetch csr_ele_entry into l_element_entry_id;
               Close csr_ele_entry;
            end if;
            --
            hr_utility.set_location(l_proc, 45);
            --
            if p_datetrack_mode not in ('UPDATE','INSERT_OVERRIDE', 'UPDATE_OVERRIDE') then
               open csr_get_curr_percnt(l_element_entry_id,
                                        l_input_value_id_tbl(3),
                                        p_effective_date);
               fetch csr_get_curr_percnt into l_new_vertex_value_tbl(3);
               if csr_get_curr_percnt%NOTFOUND then
                  close csr_get_curr_percnt;
                  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                  hr_utility.set_message_token('PROCEDURE', l_proc);
                  hr_utility.set_message_token('STEP','46');
                  hr_utility.raise_error;
               end if;
               close csr_get_curr_percnt;
            end if;
         End if;

         --
         hr_utility.set_location(l_proc, 47);
         --
         --
         -- Find defaulting date
         --
         Open csr_defaulting_date(p_assignment_id);
         Fetch csr_defaulting_date into l_defaulting_date;
         close csr_defaulting_date;

         --
         -- Find and store the assignment location changes.
         --
         Open csr_assignment_locations(p_assignment_id,l_defaulting_date);
         Fetch csr_assignment_locations
          into cur_location_id,
               cur_start_date,
               cur_end_date;

         if csr_assignment_locations%FOUND then
            --
            hr_utility.set_location(l_proc, 50);
            --

            l_location_id := cur_location_id;
            l_start_date := cur_start_date;
            l_end_date := cur_end_date;
            l_inc := 0;
            l_asg_inc := 0;
            While csr_assignment_locations%FOUND loop
               --
               hr_utility.set_location(l_proc, 55);
               --
               l_asg_inc := l_asg_inc + 1;

               --
               -- Store all assignment records.
               --
               l_asg_tbl(l_asg_inc).start_date := cur_start_date;
               l_asg_tbl(l_asg_inc).end_date := cur_end_date;
               l_asg_tbl(l_asg_inc).location_id := cur_location_id;

               Fetch csr_assignment_locations
                  into cur_location_id,
                       cur_start_date,
                       cur_end_date;

               if csr_assignment_locations%FOUND then
                  if l_location_id <> cur_location_id then
                     l_location_chg_tbl(l_inc).location_id
                                            := l_location_id;
                     l_location_chg_tbl(l_inc).start_date
                                            := l_start_date;
                     l_location_chg_tbl(l_inc).end_date
                                            := l_end_date;
                     l_inc     := l_inc + 1;
                     l_location_id := cur_location_id;
                     l_start_date := cur_start_date;
                     l_end_date := cur_end_date;
                  else
                     l_end_date := cur_end_date;
                  end if;
               else
                  l_location_chg_tbl(l_inc).location_id := l_location_id;
                  l_location_chg_tbl(l_inc).start_date := l_start_date;
                  l_location_chg_tbl(l_inc).end_date := l_end_date;
               end if;
            End loop;
            --
            hr_utility.set_location(l_proc, 60);
            --
         elsif p_datetrack_mode <> 'ZAP' then
            close csr_assignment_locations;

            hr_utility.set_message(801, 'HR_51746_ASG_INV_ASG_ID');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.raise_error;
         end if;
         if csr_assignment_locations%ISOPEN then
            close csr_assignment_locations;
         end if;

         --
         -- Locate all of the percentage records for the current
         -- Jurisdiction.
         --
         l_inc := 0;
         l_io := FALSE;
         --
         hr_utility.set_location(l_proc, 65);
         --
         for l_insert_old_recs in csr_vertex_in_jurisdiction
                                    (
                                     l_element_link_id,
                                     l_input_value_id_tbl(2)
                                    ) loop
            l_inc := l_inc + 1;
            l_element_rec_tbl(l_inc).element_entry_id
               := l_insert_old_recs.element_entry_id;
            l_element_rec_tbl(l_inc).effective_start_date
               := l_insert_old_recs.effective_start_date;
            l_element_rec_tbl(l_inc).effective_end_date
               := l_insert_old_recs.effective_end_date;
            if l_insert_old_recs.effective_start_date < p_effective_date then
               l_io := TRUE;
               if p_effective_date >= l_insert_old_recs.effective_start_date
                  and p_effective_date <= l_insert_old_recs.effective_end_date then
                  l_pct_inc := l_inc;
               end if;
            end if;
         end loop;
      -- end if; -- if l_payroll_installed
      --
      -- Select the corresponding datetrack mode
      --
      -- a. call hr_entry_api.update_element_entry with a datetrack_mode
      --    of 'UPDATE' if the effective end date of the current record
      --    is the end of time.
      -- b. if the effective end date of the current record is not the
      --    end of time then call hr_entry_api.update_element_entry with
      --    a mode of 'UPDATE_INSERT'.
      --
      If p_datetrack_mode = 'INSERT_OLD' then
         --
         hr_utility.set_location(l_proc, 70);
         --
         l_pct_inc := 0;
         l_inc := 0;
         --
         -- Scan the percentage records for the current record.
         --
         for l_insert_old_recs in csr_vertex_in_jurisdiction
                                     (
                                      l_element_link_id,
                                      l_input_value_id_tbl(2)
                                     ) loop
            l_inc := l_inc + 1;
            l_element_rec_tbl(l_inc).element_entry_id
               := l_insert_old_recs.element_entry_id;
            l_element_rec_tbl(l_inc).effective_start_date
               := l_insert_old_recs.effective_start_date;
            l_element_rec_tbl(l_inc).effective_end_date
               := l_insert_old_recs.effective_end_date;
            If p_effective_date >=
               l_element_rec_tbl(l_inc).effective_start_date and
               p_effective_date <=
               l_element_rec_tbl(l_inc).effective_end_date then
               l_pct_inc := l_inc;
            End if;
         end loop;
         --
         -- Make sure that the start and end dates match the 'VERTEX'
         -- Element Entry row(s).
         --
         If l_element_rec_tbl(l_pct_inc).effective_end_date = hr_api.g_eot
            or not l_element_rec_tbl.exists(l_pct_inc + 1) then
            --
            hr_utility.set_location(l_proc, 75);
            --
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'UPDATE',
                p_session_date             => p_effective_date,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => l_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         else
            --
            hr_utility.set_location(l_proc, 80);
            --
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'UPDATE_CHANGE_INSERT',
                p_session_date             => p_effective_date,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => l_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         end if;
         --
         -- a. get the current jurisdiction's percentage record.
         -- b. if the current percentage record is the last record with an
         --    effective end date of the end of time then call
         --    hr_entry_api.update_element_entry with a mode of 'UPDATE'.
         -- c. else if call hr_entry_api.update_element_entry with a mode
         --    of 'UPDATE_INSERT'.
         -- d. remove any percentage records which are before the new effective
         --    date from pay_element_entry_values_f and pay_element_entries_f.
         -- e. if the new effective date is before the old defaulting date then
         --    update the effective start date of the first record in
         --    pay_element_entries_f and pay_element_entry_values_f.
      elsif p_datetrack_mode = 'INSERT_OVERRIDE' then
         --
         hr_utility.set_location(l_proc, 85);
         --
         if l_io = TRUE then
            l_new_vertex_value_tbl(3) := get_curr_jurisdiction_db_value
                                            (
                                             p_assignment_id,
                                             l_jurisdiction,
                                             p_effective_date,
                                             l_element_link_id,
                                             l_input_value_id_tbl
                                            );
            if l_element_rec_tbl(l_pct_inc).effective_start_date <= p_effective_date and
               l_element_rec_tbl(l_pct_inc).effective_end_date >= p_effective_date and
               (l_element_rec_tbl(l_pct_inc).effective_end_date = hr_api.g_eot
                or not l_element_rec_tbl.exists(l_pct_inc + 1)) then
               --
               hr_utility.set_location(l_proc, 90);
               --
               hr_entry_api.update_element_entry
                  (
                   p_dt_update_mode           => 'UPDATE',
                   p_session_date             => p_effective_date,
                   p_element_entry_id         => l_element_entry_id,
                   p_num_entry_values         => 3,
                   p_input_value_id_tbl       => l_input_value_id_tbl,
                   p_entry_value_tbl          => l_new_vertex_value_tbl);
            else
               --
               hr_utility.set_location(l_proc, 95);
               --
               hr_entry_api.update_element_entry
                  (
                   p_dt_update_mode           => 'UPDATE_CHANGE_INSERT',
                   p_session_date             => p_effective_date,
                   p_element_entry_id         => l_element_entry_id,
                   p_num_entry_values         => 3,
                   p_input_value_id_tbl       => l_input_value_id_tbl,
                   p_entry_value_tbl          => l_new_vertex_value_tbl);
            end if;
            --
            -- Remove trailing records
            --
            Begin
               --
               hr_utility.set_location(l_proc, 100);
               --
               --
               -- Remove element entry values first
               --
               Delete from pay_element_entry_values_f
               Where element_entry_id = l_element_entry_id
                 and effective_start_date < p_effective_date;
               --
               -- Next, remove the parent element entry records.
               --
               Delete from pay_element_entries_f
               Where element_entry_id = l_element_entry_id
                 and effective_start_date < p_effective_date;
            Exception
               when others then
                  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                  hr_utility.set_message_token('PROCEDURE', l_proc ||
                            '- SQLCODE:'|| to_char(sqlcode));
                  hr_utility.set_message_token('STEP','102');
                  hr_utility.raise_error;
            End;
         else
            --
            hr_utility.set_location(l_proc, 105);
            --
            Begin
               Update pay_element_entry_values_f
               Set effective_start_date = p_effective_date
               Where element_entry_id = l_element_entry_id
                 and effective_start_date = t_effective_start_date;
               --
               Update pay_element_entries_f
               Set effective_start_date = p_effective_date
               Where element_entry_id = l_element_entry_id
                 and effective_start_date = t_effective_start_date;
               --
            Exception
               when others then
                  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                  hr_utility.set_message_token('PROCEDURE', l_proc ||
                     '- SQLCODE:'|| to_char(sqlcode));
                  hr_utility.set_message_token('STEP','109');
                  hr_utility.raise_error;
            End;
         End if;
         /*
            a. create a percentage record for the new jurisdiction at
               the defaulting date.
            b. apply all location changes to the new percentage record, by
               calling hr_entry_element.update_element_entry with MODE
                = 'UPDATE' at the start date for each location change.
            c. correct the percentage for the current jurisdiction record to
               0% for assignment jurisdiction not equal to the current
               jurisdiction and 100% where the assignment jurisdiction and
               current jurisdiction are equal and the current jurisdiction
               is a city.
         */
      elsif p_datetrack_mode = 'INSERT' then
         --
         hr_utility.set_location(l_proc ,110);

         If l_defaulting_date is not null then
            --
            -- Create a percentage record for the new jurisdiction at
            --    the defaulting date.
            --
            l_new_vertex_value_tbl(3) := '0';
            --
            hr_utility.set_location(l_proc ,115);
            --
            hr_entry_api.insert_element_entry
               (
                p_effective_start_date => l_defaulting_date,
                p_effective_end_date   => l_effective_end_date,
                p_element_entry_id     => l_element_entry_id,
                p_assignment_id        => p_assignment_id,
                p_element_link_id      => l_element_link_id,
                p_creator_type         => 'UT',
                p_entry_type           => 'E',
                p_num_entry_values     => 3,
                p_input_value_id_tbl   => l_input_value_id_tbl,
                p_entry_value_tbl      => l_new_vertex_value_tbl
               );
            --
            hr_utility.set_location(l_proc ,120);
            --
            --  Find all location changes in the assignment record.
            --  Apply all location changes to the new percentage record, by
            --  calling hr_entry_element.update_element_entry with MODE = 'UPDATE'.
            --
            if l_location_chg_tbl.first is not null then
               --
               hr_utility.set_location(l_proc ,125);
               --
               l_inc := l_location_chg_tbl.next(l_location_chg_tbl.first);
               While l_location_chg_tbl.exists(l_inc) loop
                  --
                  -- Get location percentage;
                  -- The percentage is assigned 0% for location not equal to
                  -- current jurisdiction and 100% where the jurisdiction and location
                  -- are equal.
                  --
                  hr_entry_api.update_element_entry
                     (
                      p_dt_update_mode           => 'UPDATE',
                      p_session_date             => l_location_chg_tbl(l_inc).start_date,
                      p_element_entry_id         => l_element_entry_id,
                      p_num_entry_values         => 3,
                      p_input_value_id_tbl       => l_input_value_id_tbl,
                      p_entry_value_tbl          => l_new_vertex_value_tbl);
                  l_inc := l_location_chg_tbl.next(l_inc);
               End loop;
               --
               -- Set the proper percentage.  If current jurisdiction is a CITY,
               -- and the assignment jurisdiction is the same, then the percentage
               -- = '100' else percentage = '0'.
               --
               If p_city_code <> '0000' and
                  chk_work_location(
                                    p_assignment_id,
                                    p_effective_date,
                                    p_state_code||'-'||
                                    p_county_code||'-'||
                                    p_city_code
                                   ) then
                  --
                  hr_utility.set_location(l_proc ,125);
                  --
                  l_new_vertex_value_tbl(3) := '100';
               else
                  l_new_vertex_value_tbl(3) := '0';
               end if;               --
               --
               hr_utility.set_location(l_proc ,130);
               --
               hr_entry_api.update_element_entry
                  (
                   p_dt_update_mode           => 'CORRECTION',
                   p_session_date             => p_effective_date,
                   p_element_entry_id         => l_element_entry_id,
                   p_num_entry_values         => 3,
                   p_input_value_id_tbl       => l_input_value_id_tbl,
                   p_entry_value_tbl          => l_new_vertex_value_tbl
                  );
            else
               hr_utility.set_message(801, 'HR_51746_ASG_INV_ASG_ID');
               hr_utility.set_message_token('PROCEDURE', l_proc);
               hr_utility.raise_error;
            end if;
         end if;
         --
      /*
         a. find the current assignment location record.
         b. find the current element_entry (percentage) record for the current
            jurisdiction and effective date.
         c. if the end date of the current assignment location record is less
            than the effective end date for the current percentage record and
            the percentage record's effective end date = the end of time or the
            current percentage record is the last record, then call
            hr_entry_api.update_element_entry with a mode of 'UPDATE' and
            a session date = the curr ent assignments effective end date + 1.
         d. else if the current assignment location record's effective end
            date < the currect assignments' element entry record's effective end
            date, then call hr_entry_api.update_element_entry with a mode of
            'UPDATE_INSERT' and a session date = the current assignments
            effective end date + 1.
         e. set the percentage value to the new percentage.
         f. if the current percentage record's effective start date < the
            current assignment location record's effective start date then call
            hr_entry_api.update_element_entry with a mode of 'UPDATE_CHANGE_INSERT'
            and at the assignments effective start date + 1.
         g. else if not modified then find the current assignment's defaulting
            date.
         h. check to see if the value of the assignment's location for the next
            record. if it is the same as the current assignment record's
            location, then call hr_entry_api.delete_element_entry with a mode of
            'DELETE_NEXT_CHANGE' at the effective date.
         g. check the value of the location for the assignment's prior record, if
            it is the same as the location for the assignment's current record,
            call hr_entry_api.delete_element_entry with a mode of
            'DELETE_NEXT_CHANGE' at the effective end date of the assignment's
            next record.
         h. if this is a call from the public api correct percentage, calculate
            the jurisdiction's new element entry value.
         i. else call hr_entry_api.update_element_entry with a mode of 'CORRECTION'
            at the effective date.
      */
      elsif p_datetrack_mode = 'CORRECTION' then
         --
         hr_utility.set_location(l_proc ,140);
         --
         l_inc := 0;
         if l_location_chg_tbl.first is not null then
            l_inc := l_location_chg_tbl.first;
            While l_location_chg_tbl.exists(l_inc) loop
               If p_effective_date >= l_location_chg_tbl(l_inc).start_date and
                  p_effective_date <= l_location_chg_tbl(l_inc).end_date then
                  l_asg_inc := l_inc;
               end if;
               l_inc := l_location_chg_tbl.next(l_inc);
            End loop;
            l_inc := 0;
            for l_insert_old_recs in csr_vertex_in_jurisdiction
                  (l_element_link_id,
                   l_input_value_id_tbl(2)) loop
               l_inc := l_inc + 1;
               l_element_rec_tbl(l_inc).element_entry_id
                  := l_insert_old_recs.element_entry_id;
               l_element_rec_tbl(l_inc).effective_start_date
                  := l_insert_old_recs.effective_start_date;
               l_element_rec_tbl(l_inc).effective_end_date
                  := l_insert_old_recs.effective_end_date;
               if l_insert_old_recs.effective_end_date >= p_effective_date and
                  l_insert_old_recs.effective_start_date <= p_effective_date then
                  l_pct_inc := l_inc;
               end if;
            end loop;
         else
            hr_utility.set_message(801, 'HR_51746_ASG_INV_ASG_ID');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.raise_error;
         end if;
         If l_location_chg_tbl(l_asg_inc).end_date <
            l_element_rec_tbl(l_pct_inc).effective_end_date
            and (l_element_rec_tbl(l_pct_inc).effective_end_date = hr_api.g_eot
                 or not l_element_rec_tbl.exists(l_pct_inc + 1)) then
            --
            hr_utility.set_location(l_proc ,145);
            --
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'UPDATE',
                p_session_date             => l_location_chg_tbl(l_asg_inc).end_date + 1,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => l_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         elsif l_location_chg_tbl(l_asg_inc).end_date <
            l_element_rec_tbl(l_pct_inc).effective_end_date then
            --
            hr_utility.set_location(l_proc ,150);
            --
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'UPDATE_CHANGE_INSERT',
                p_session_date             => l_location_chg_tbl(l_asg_inc).end_date + 1,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => l_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         end if;
         l_new_vertex_value_tbl(3) := fnd_number.canonical_to_number(p_percentage);
         if l_element_rec_tbl(l_pct_inc).effective_start_date <
            l_location_chg_tbl(l_asg_inc).start_date then
            l_modified_correction := TRUE;
            --
            -- With new pct values
            --
            --
            hr_utility.set_location(l_proc ,155);
            --
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'UPDATE_CHANGE_INSERT',
                p_session_date             => l_location_chg_tbl(l_asg_inc).start_date,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => l_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         else
            If l_modified_correction = FALSE then
               if l_defaulting_date is null then
                  hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
                  hr_utility.set_message_token('PROCEDURE', l_proc);
                  hr_utility.raise_error;
               end if;

               if asg_loc_comp(
                               l_asg_tbl ,
                               NXT,
                               p_effective_date,
                               l_defaulting_date
                              ) = TRUE and p_calculate_pct = FALSE then
                  --
                  hr_utility.set_location(l_proc ,160);
                  --
                  hr_entry_api.delete_element_entry
                     (
                      p_dt_delete_mode   => 'DELETE_NEXT_CHANGE',
                      p_session_date     => p_effective_date,
                      p_element_entry_id => l_element_entry_id
                     );
               End if;
               if asg_loc_comp(
                               l_asg_tbl,
                               PRV,
                               p_effective_date,
                               l_defaulting_date
                              ) = TRUE and p_calculate_pct = FALSE then
                  --
                  hr_utility.set_location(l_proc ,165);
                  --
                  hr_entry_api.delete_element_entry
                     (
                      p_dt_delete_mode   => 'DELETE_NEXT_CHANGE',
                      p_session_date     => l_element_rec_tbl(l_pct_inc).effective_start_date - 1,
                      p_element_entry_id => l_element_entry_id
                     );
                  End if;
               --
               if p_calculate_pct then
                  --
                  hr_utility.set_location(l_proc ,170);
                  --
                  calculate_db_percentage
                     (
                      p_percentage,
                      p_state_code,
                      p_county_code,
                      p_city_code,
                      l_element_link_id,
                      l_input_value_id_tbl,
                      p_effective_date
                     );
               else
                  --
                  hr_utility.set_location(l_proc ,175);
                  --
                  hr_entry_api.update_element_entry
                     (
                      p_dt_update_mode     => 'CORRECTION',
                      p_session_date       => p_effective_date,
                      p_element_entry_id   => l_element_entry_id,
                      p_num_entry_values   => 3,
                      p_input_value_id_tbl => l_input_value_id_tbl,
                      p_entry_value_tbl    => l_new_vertex_value_tbl
                     );
               end if;
            end if;
         End if;
         --
      /*
         a. if the current assignment location record's effective end date <
            current percentage record's effective end date and current percentage
            record's effective end date = hr_api.g_eot or the next percentage
            record doesn't exist then call hr_entry_api.update_element_entry with
            a mode of 'UPDATE' at the the assignment record's effective end
            date + 1.
         b. else if the current assignment location record's effective end date
            < the current percentage record's effective end date then call
            hr_entry_api.update_element_entry with a mode of 'UPDATE_CHANGE_INSERT'
            at the next assignment record's effective end date.
         c. call hr_entry_api.update_element_entry with a mode of
            'UPDATE_CHANGE_INSERT' at the effective date and with the new percentage
            value.
         d. if the assignment's next record's location is the same as the current
            assignment record's location then call hr_entry_api.delete_element_entry
            with a mode of 'DELETE_NEXT_CHANGE' at the effective date.
      */
      elsif p_datetrack_mode = 'UPDATE_CHANGE_INSERT' then
         --
         hr_utility.set_location(l_proc ,180);
         --
         l_inc := 0;
         if l_location_chg_tbl.first is not null then
            l_inc := l_location_chg_tbl.first;
            While l_location_chg_tbl.exists(l_inc) loop
               If p_effective_date >= l_location_chg_tbl(l_inc).start_date and
                  p_effective_date <= l_location_chg_tbl(l_inc).end_date then
                  l_asg_inc := l_inc;
               end if;
               l_inc := l_location_chg_tbl.next(l_inc);
            End loop;
            l_inc := 0;
            for l_insert_old_recs in csr_vertex_in_jurisdiction
                  (l_element_link_id,
                   l_input_value_id_tbl(2)) loop
               l_inc := l_inc + 1;
               l_element_rec_tbl(l_inc).element_entry_id
                  := l_insert_old_recs.element_entry_id;
               l_element_rec_tbl(l_inc).effective_start_date
                  := l_insert_old_recs.effective_start_date;
               l_element_rec_tbl(l_inc).effective_end_date
                  := l_insert_old_recs.effective_end_date;
               if l_insert_old_recs.effective_end_date >= p_effective_date and
                  l_insert_old_recs.effective_start_date <= p_effective_date then
                  l_pct_inc := l_inc;
               end if;
            end loop;
         else
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc ||
               '- SQLCODE:'|| to_char(sqlcode));
            hr_utility.set_message_token('STEP','184');
            hr_utility.raise_error;
         end if;
         If l_location_chg_tbl(l_asg_inc).end_date <
            l_element_rec_tbl(l_pct_inc).effective_end_date
            and (l_element_rec_tbl(l_pct_inc).effective_end_date = hr_api.g_eot
                 or not l_element_rec_tbl.exists(l_pct_inc + 1)) then
            --
            hr_utility.set_location(l_proc ,185);
            --
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'UPDATE',
                p_session_date             => l_location_chg_tbl(l_asg_inc).end_date + 1,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => l_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         elsif l_location_chg_tbl(l_asg_inc).end_date <
            l_element_rec_tbl(l_pct_inc).effective_end_date then
            --
            hr_utility.set_location(l_proc ,190);
            --
            hr_entry_api.update_element_entry
               (
                p_dt_update_mode           => 'UPDATE_CHANGE_INSERT',
                p_session_date             => l_location_chg_tbl(l_asg_inc).end_date + 1,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => l_input_value_id_tbl,
                p_entry_value_tbl          => l_new_vertex_value_tbl
               );
         end if;
         --
         -- Call hr_entry_api.update_element_entry with MODE =
         -- 'UPDATE_CHANGE_INSERT' as of the effective date.
         --
         l_new_vertex_value_tbl(3) := fnd_number.canonical_to_number(p_percentage);
         --
         hr_utility.set_location(l_proc ,195);
         --
         hr_entry_api.update_element_entry
            (
             p_dt_update_mode           => p_datetrack_mode,
             p_session_date             => p_effective_date,
             p_element_entry_id         => l_element_entry_id,
             p_num_entry_values         => 3,
             p_input_value_id_tbl       => l_input_value_id_tbl,
             p_entry_value_tbl          => l_new_vertex_value_tbl
            );
         if asg_loc_comp(
                         l_asg_tbl,
                         NXT,
                         p_effective_date,
                         p_effective_date
                        ) then
            --
            hr_utility.set_location(l_proc ,200);
            --
            hr_entry_api.delete_element_entry
               (
                p_dt_delete_mode           => 'DELETE_NEXT_CHANGE',
                p_session_date             => p_effective_date,
                p_element_entry_id         => l_element_entry_id
               );
         end if;
      /*
         a. call hr_entry_api.update_element_entry with a mode of p_datetrack_mode
            at the effective date.
      */
      elsif p_datetrack_mode in ('UPDATE_OVERRIDE', 'UPDATE') then
         hr_utility.set_location(l_proc ,205);
         --
         hr_entry_api.update_element_entry
            (
             p_dt_update_mode           => p_datetrack_mode,
             p_session_date             => p_effective_date,
             p_element_entry_id         => l_element_entry_id,
             p_num_entry_values         => 3,
             p_input_value_id_tbl       => l_input_value_id_tbl,
             p_entry_value_tbl          => l_new_vertex_value_tbl
            );

      /*
         a. get the value of the old percentage record.
         b. check to see if the current assignment record's effective end date
            < next percentage record's
      */
      elsif p_datetrack_mode in ('ZAP', 'DELETE', 'FUTURE_CHANGE') then
         --
         hr_utility.set_location(l_proc ,210);
         --
         hr_entry_api.delete_element_entry
           (
            p_dt_delete_mode           => p_datetrack_mode,
            p_session_date             => p_effective_date,
            p_element_entry_id         => l_element_entry_id
           );

      elsif p_datetrack_mode = 'DELETE_NEXT_CHANGE' then
         --
         hr_utility.set_location(l_proc ,215);
         --
         l_asg_inc := 0;
         l_pct_inc := 0;
         l_inc := 0;
         --
         -- Look for assignment record breaks that need to be inserted.
         --
         if l_location_chg_tbl.first is not null then
            --
            -- Scan the percentage records for the next record after the current
            -- record.
            --
            for l_insert_old_recs in csr_vertex_in_jurisdiction
                                        (
                                         l_element_link_id,
                                         l_input_value_id_tbl(2)
                                        ) loop
               l_inc := l_inc + 1;
               l_element_rec_tbl(l_inc).element_entry_id
                  := l_insert_old_recs.element_entry_id;
               l_element_rec_tbl(l_inc).effective_start_date
                  := l_insert_old_recs.effective_start_date;
               l_element_rec_tbl(l_inc).effective_end_date
                  := l_insert_old_recs.effective_end_date;
               If p_effective_date >=
                  l_element_rec_tbl(l_inc).effective_start_date and
                  p_effective_date <=
                  l_element_rec_tbl(l_inc).effective_end_date then
                  l_pct_inc := l_inc + 1;
               End if;
            end loop;
            if l_element_rec_tbl.exists(l_pct_inc) then
               l_inc := l_location_chg_tbl.first;
               While l_location_chg_tbl.exists(l_inc) loop
                  If l_element_rec_tbl(l_pct_inc).effective_start_date >=
                     l_location_chg_tbl(l_inc).start_date and
                     l_element_rec_tbl(l_pct_inc).effective_start_date <
                     l_location_chg_tbl(l_inc).end_date+1 then
                     l_asg_inc := l_inc;
                  End if;
                  l_inc := l_location_chg_tbl.next(l_inc);
               End loop;
               --
               -- Make sure that the start and end dates match the 'VERTEX'
               -- Element Entry row(s).
               --
               hr_utility.set_location(l_proc ,220);
               --
               l_new_vertex_value_tbl(3) := get_curr_jurisdiction_db_value
                                               (
                                                p_assignment_id,
                                                l_jurisdiction,
                                                l_element_rec_tbl(l_pct_inc).effective_start_date,
                                                l_element_link_id,
                                                l_input_value_id_tbl
                                               );
               If l_location_chg_tbl(l_asg_inc).end_date <
                  l_element_rec_tbl(l_pct_inc).effective_end_date
                  and (l_element_rec_tbl(l_pct_inc).effective_end_date = hr_api.g_eot
                       or not l_element_rec_tbl.exists(l_pct_inc + 1)) then
                  --
                  hr_utility.set_location(l_proc ,225);
                  --
                  hr_entry_api.update_element_entry
                     (
                      p_dt_update_mode           => 'UPDATE',
                      p_session_date             => l_location_chg_tbl(l_asg_inc).end_date + 1,
                      p_element_entry_id         => l_element_entry_id,
                      p_num_entry_values         => 3,
                      p_input_value_id_tbl       => l_input_value_id_tbl,
                      p_entry_value_tbl          => l_new_vertex_value_tbl
                     );
               elsif l_location_chg_tbl(l_asg_inc).end_date <
                  l_element_rec_tbl(l_pct_inc).effective_start_date then
                  --
                  hr_utility.set_location(l_proc ,230);
                  --
                  hr_entry_api.update_element_entry
                     (
                      p_dt_update_mode           => 'UPDATE_CHANGE_INSERT',
                      p_session_date             => l_location_chg_tbl(l_asg_inc).end_date + 1,
                      p_element_entry_id         => l_element_entry_id,
                      p_num_entry_values         => 3,
                      p_input_value_id_tbl       => l_input_value_id_tbl,
                      p_entry_value_tbl          => l_new_vertex_value_tbl
                     );
               end if;
            end if;
         end if;
         --
         -- Call hr_entry_api.delete_element_entry with MODE =
         -- 'DELETE_NEXT_CHANGE' for any rows found.
         --
         hr_utility.set_location(l_proc ,235);
         --
         hr_entry_api.delete_element_entry
            (
             p_dt_delete_mode           => p_datetrack_mode,
             p_session_date             => p_effective_date,
             p_element_entry_id         => l_element_entry_id
            );

      end if;
      --
      hr_utility.set_location(l_proc, 245);
      --
      -- Set all output arguments
      --
      p_effective_start_date := l_effective_start_date;
      p_effective_end_date := l_effective_end_date;
      --
      end if; -- if l_payroll_installed
      --
      hr_utility.set_location(' Leaving:'||l_proc, 250);
      --
      --
   end maintain_tax_percentage;

-- ----------------------------------------------------------------------------
-- |-----------------------------< maintain_wc >------------------------------|
-- ----------------------------------------------------------------------------
--

procedure maintain_wc
  (p_emp_fed_tax_rule_id            in     number
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'maintain_wc';
  l_assignment_id        pay_us_emp_fed_tax_rules_f.assignment_id%TYPE;
  l_jurisdiction_code    pay_us_emp_fed_tax_rules_f.sui_jurisdiction_code%TYPE;
  l_element_type_id      number       :=0;
  l_inp_name             varchar2(50) :=null;
  l_inp_val_id           number       :=0;
  l_element_link_id      number       :=0;
  l_element_entry_id     number       :=0;
  l_effective_start_date date         := null;
  l_effective_end_date   date         := null;
  l_effective_date       date;
  l_mode                 varchar2(30);
  l_delete_flag          varchar2(1);
  l_payroll_installed    boolean := FALSE;
  l_wc_min_start_date    pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_defaulting_date      pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_get_old_value_date   date;
  l_temp_char            varchar2(2);
  lc_workers_comp        varchar2(25) := 'Workers Compensation';
  l_tmp_date             date;

  l_inp_value_id_table   hr_entry.number_table;
  l_scr_value_table      hr_entry.varchar2_table;

  /* Cursor to get details about the federal tax rule */

  cursor csr_fed_detail is
    select fed.assignment_id,
           fed.sui_jurisdiction_code
    from   pay_us_emp_fed_tax_rules_f fed
    where  fed.emp_fed_tax_rule_id = p_emp_fed_tax_rule_id
    and    l_get_old_value_date between fed.effective_start_date
           and fed.effective_end_date;

  /* Cursor to check for existence of the federal tax rule */

  cursor csr_fed_rule_exists is
     select null
     from   pay_us_emp_fed_tax_rules_f fed
     where  fed.emp_fed_tax_rule_id = p_emp_fed_tax_rule_id
     and    fed.effective_start_date = l_effective_end_date + 1;

  /* Cursor to get the tax defaulting date */

  cursor csr_min_fed_tax_date is
     select min(effective_start_date)
     from pay_us_emp_fed_tax_rules_f
     where emp_fed_tax_rule_id = p_emp_fed_tax_rule_id;

  /* Cursor to get the worker's compensation element type */

  cursor csr_wc_tax_element is
    select pet.element_type_id,
           piv.input_value_id,
           piv.name
    from   PAY_ELEMENT_TYPES_F pet,
           PAY_INPUT_VALUES_F  piv
    where  pet.element_name   = lc_workers_comp
    and    l_get_old_value_date between pet.effective_start_date
           and pet.effective_end_date
    and    pet.element_type_id       = piv.element_type_id
    and    l_get_old_value_date between piv.effective_start_date
           and piv.effective_end_date;

  /* Cursor to get the worker's compensation element entry */

  cursor csr_wc_ele_entry (p_element_link number)is
    select pee.element_entry_id
    from   PAY_ELEMENT_ENTRIES_F pee
    where  pee.assignment_id         = l_assignment_id
    and    pee.element_link_id       = p_element_link
    and    rownum < 2;

  /* Cursor to get the worker's compensation earliest start date */

  cursor csr_wc_min_start is
    select min(pee.effective_start_date)
    from   PAY_ELEMENT_ENTRIES_F pee
    where  pee.element_entry_id      = l_element_entry_id;

  /* Cursor to get the current worker's compensation jurisdiction */

  cursor csr_get_curr_jurisd (p_csr_ele_entry_id number, p_csr_inp_val number) is
    select pev.screen_entry_value
    from   pay_element_entry_values_f pev
    where  pev.element_entry_id      = p_csr_ele_entry_id
    and    l_get_old_value_date between pev.effective_start_date
                            and pev.effective_end_date
    and    pev.input_value_id        = p_csr_inp_val
    and    pev.screen_entry_value is not null;

  /* Cursor to check for existing worker's comp entries to be purged or ended */

  cursor csr_get_ele_entry_id(l_csr_assignment_id  number
                             ,l_csr_effective_date date
                             ) is
    select peef.element_entry_id
    from   pay_element_entries_f peef
          ,pay_element_entry_values_f peevf
          ,pay_element_links_f pelf
          ,pay_element_types_f petf
    where  peef.assignment_id= l_csr_assignment_id
      and  petf.element_name = lc_workers_comp
      and  l_csr_effective_date < peef.effective_end_date
      and  peef.element_link_id = pelf.element_link_id
      and  pelf.element_type_id = petf.element_type_id
      and  peef.element_entry_id = peevf.element_entry_id
      and  l_csr_effective_date < peevf.effective_end_date;
  --
begin
  --
  l_effective_date := trunc(p_effective_date);
  l_effective_start_date := trunc(p_effective_start_date);
  l_effective_end_date := trunc(p_effective_end_date);
  --
  -- Check that Oracle Payroll is installed
  --
  l_payroll_installed := hr_utility.chk_product_install(
                                              p_product =>'Oracle Payroll',
                                              p_legislation => 'US');
  if l_payroll_installed then

    hr_utility.set_location('Entering:'|| l_proc ,10);
    --
    if p_datetrack_mode = 'INSERT_OVERRIDE' then
      open csr_min_fed_tax_date;
      fetch csr_min_fed_tax_date into l_defaulting_date;
      if csr_min_fed_tax_date%notfound then
        close csr_min_fed_tax_date;
        hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
        hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
        hr_utility.raise_error;
      end if;
      close csr_min_fed_tax_date;
      --
      -- Set l_get_old_value_date to the later of l_effective_date and
      -- l_defaulting_date. If l_effective_date is before l_defaulting_date,
      -- it will be unable to fetch existing wc element entry information,
      -- so we fetch that information as of the defaulting date,
      -- then pull back the workers comp entry, if necessary.
      --
      if l_effective_date < l_defaulting_date then
        l_get_old_value_date := l_defaulting_date;
      else
        l_get_old_value_date := l_effective_date;
      end if;
    else
      l_get_old_value_date := l_effective_date;
    end if;
    --
    -- Get assignment_id and jurisdiction code for p_emp_fed_tax_rule_id
    --
    open  csr_fed_detail;
    fetch csr_fed_detail into l_assignment_id, l_jurisdiction_code;
    if csr_fed_detail%NOTFOUND then
      close csr_fed_detail;
      --
      -- No Federal tax rule exists for this id
      --
      hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
      hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
      hr_utility.raise_error;
    end if;
    close csr_fed_detail;
    --
    -- Check for datetrack modes ZAP and DELETE.  These should only be processed
    -- when the assignment is terminated or purged.  In these cases, the assignment delete
    -- code might process the element entries, including the workers compensation entries.
    -- If the entries have already been purged or deleted, there is nothing to do here,
    -- otherwise, perform the delete.
    --
    if p_datetrack_mode in('ZAP','DELETE') then
       if p_datetrack_mode = hr_api.g_zap then
         l_tmp_date := hr_api.g_date;
       else
         l_tmp_date := l_effective_date;
       end if;
       open csr_get_ele_entry_id(l_assignment_id
                                ,l_tmp_date);
       fetch csr_get_ele_entry_id into l_element_entry_id;
       if csr_get_ele_entry_id%found then
         hr_entry_api.delete_element_entry(
             p_dt_delete_mode           => p_datetrack_mode,
             p_session_date             => l_effective_date,
             p_element_entry_id         => l_element_entry_id);
       end if;
       --
    else        -- p_datetrack_mode not in ('ZAP','DELETE')
       --
       -- Get element_type_id and input values for the workers comp element.
       --
       open  csr_wc_tax_element;
       loop
         fetch csr_wc_tax_element into l_element_type_id,
                                       l_inp_val_id,
                                       l_inp_name;
         exit when csr_wc_tax_element%NOTFOUND;

         if upper(l_inp_name) = 'PAY VALUE' then
           l_inp_value_id_table(1) := l_inp_val_id;
         elsif upper(l_inp_name) = 'JURISDICTION' then
           l_inp_value_id_table(2) := l_inp_val_id;
         end if;

       end loop;

       close csr_wc_tax_element;

       hr_utility.set_location('Entering:'|| l_proc,20);

       /* Check that all of the input value id for vertex, exists */

       for i in 1..2 loop
          if l_inp_value_id_table(i) = null or
             l_inp_value_id_table(i) = 0 then

             fnd_message.set_name('PAY', 'HR_7713_TAX_ELEMENT_ERROR');
             fnd_message.raise_error;
          end if;
       end loop;
       hr_utility.set_location('Entering:'|| l_proc, 30);

       /* Get element link */
       l_element_link_id := hr_entry_api.get_link(
                              P_assignment_id   => l_assignment_id,
                              P_element_type_id => l_element_type_id,
                              P_session_date    => l_get_old_value_date);

       if l_element_link_id is null or l_element_link_id = 0 then
           fnd_message.set_name('PAY', 'HR_7713_TAX_ELEMENT_ERROR');
           fnd_message.raise_error;
       end if;
       hr_utility.set_location('Entering:'|| l_proc, 40);

       /* Store screen entry value in the table */
       l_scr_value_table(1)     := null;
       l_scr_value_table(2)     := l_jurisdiction_code;

       /* assign the parameters to local variables because the element entry
          procedures expect them to be in out parameters */
       l_effective_start_date   := trunc(p_effective_start_date);
       l_effective_end_date     := trunc(p_effective_end_date);
       l_mode                   := p_datetrack_mode;

       if p_datetrack_mode = 'INSERT' then
         /* Insert the worker's compensation element entry */

         hr_utility.set_location('Entering:'|| l_proc, 50);
         hr_entry_api.insert_element_entry(
              P_effective_start_date     => l_effective_start_date,
              P_effective_end_date       => l_effective_end_date,
              P_element_entry_id         => l_element_entry_id,
              P_assignment_id            => l_assignment_id,
              P_element_link_id          => l_element_link_id,
              P_creator_type             => 'UT',
              P_entry_type               => 'E',
              P_num_entry_values         => 2,
              P_input_value_id_tbl       => l_inp_value_id_table,
              P_entry_value_tbl          => l_scr_value_table);
         hr_utility.set_location('Entering:'|| l_proc, 80);

       elsif p_datetrack_mode in ('CORRECTION', 'UPDATE', 'UPDATE_CHANGE_INSERT',
                        'UPDATE_OVERRIDE', 'DELETE_NEXT_CHANGE',
                        'FUTURE_CHANGE', 'INSERT_OVERRIDE', 'INSERT_OLD') then
             /* Get the worker's compensation element entry id */

         open csr_wc_ele_entry(l_element_link_id);
         fetch csr_wc_ele_entry into l_element_entry_id;
         if csr_wc_ele_entry%NOTFOUND then
           if p_datetrack_mode in('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
              l_delete_flag := 'N';
           else
              close csr_wc_ele_entry;
              fnd_message.set_name(801, 'HR_6153_ALL_PROCEDURE_FAIL');
              fnd_message.set_token('PROCEDURE', l_proc);
              fnd_message.set_token('STEP','8');
              fnd_message.raise_error;
           end if;
         else /* found the wc element entry id */
           l_delete_flag := 'Y';
         end if;

         close csr_wc_ele_entry;

         if p_datetrack_mode in('DELETE_NEXT_CHANGE', 'FUTURE_CHANGE')
                   and l_delete_flag = 'Y' then

         /* All of the tax %age records will be created from the date on which the
            default tax rules criteria was met till the end of time. So, we should
            get records for the state, county and city for the same effective start
            date */
            hr_entry_api.delete_element_entry(
                p_dt_delete_mode           => l_mode,
                p_session_date             => l_effective_date,
                p_element_entry_id         => l_element_entry_id);


         elsif p_datetrack_mode in ('CORRECTION','UPDATE', 'UPDATE_CHANGE_INSERT',
                          'UPDATE_OVERRIDE') then

            hr_entry_api.update_element_entry(
               p_dt_update_mode           => l_mode,
               p_session_date             => l_effective_date,
               p_element_entry_id         => l_element_entry_id,
               p_num_entry_values         => 2,
               p_input_value_id_tbl       => l_inp_value_id_table,
               p_entry_value_tbl          => l_scr_value_table);

         elsif p_datetrack_mode in ('INSERT_OVERRIDE') then

           open csr_wc_min_start;
           fetch csr_wc_min_start into l_wc_min_start_date;
           close csr_wc_min_start;

           if l_effective_date > l_wc_min_start_date then
             -- Perform an 'INSERT_OLD' at l_effective_date, then delete earlier entries.

             open csr_get_curr_jurisd(l_element_entry_id, l_inp_value_id_table(2));
             fetch csr_get_curr_jurisd into l_scr_value_table(2);
             if csr_get_curr_jurisd%notfound then
               close csr_get_curr_jurisd;
               hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
               hr_utility.set_message_token('PROCEDURE', l_proc);
               hr_utility.set_message_token('STEP', '9');
               hr_utility.raise_error;
             end if;
             close csr_get_curr_jurisd;

             open csr_fed_rule_exists;
             fetch csr_fed_rule_exists into l_temp_char;
             if csr_fed_rule_exists%notfound then
               l_mode := 'UPDATE';
             else
               l_mode := 'UPDATE_CHANGE_INSERT';
             end if;
             close csr_fed_rule_exists;

             hr_entry_api.update_element_entry(
                p_dt_update_mode           => l_mode,
                p_session_date             => l_effective_date,
                p_element_entry_id         => l_element_entry_id,
                p_num_entry_values         => 2,
                p_input_value_id_tbl       => l_inp_value_id_table,
                p_entry_value_tbl          => l_scr_value_table);

             delete from pay_element_entry_values_f pev
             where  pev.element_entry_id     = l_element_entry_id
             and    pev.effective_start_date < l_effective_date;

             delete from pay_element_entries_f pee
             where  pee.element_entry_id     = l_element_entry_id
             and    pee.effective_start_date < l_effective_date;

           elsif l_effective_date < l_wc_min_start_date then
             -- Manually set effective start date of earliest record to l_effective_date

             update pay_element_entry_values_f pev
             set    pev.effective_start_date = l_effective_date
             where  pev.element_entry_id     = l_element_entry_id
             and    pev.effective_start_date = l_wc_min_start_date;

             update pay_element_entries_f pee
             set    pee.effective_start_date = l_effective_date
             where  pee.element_entry_id     = l_element_entry_id
             and    pee.effective_start_date = l_wc_min_start_date;
           end if;

         elsif p_datetrack_mode in ('INSERT_OLD') then
           open csr_get_curr_jurisd(l_element_entry_id, l_inp_value_id_table(2));
           fetch csr_get_curr_jurisd into l_scr_value_table(2);
           if csr_get_curr_jurisd%notfound then
             close csr_get_curr_jurisd;
             hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE', l_proc);
             hr_utility.set_message_token('STEP', '9');
             hr_utility.raise_error;
           end if;
           close csr_get_curr_jurisd;

           open csr_fed_rule_exists;
           fetch csr_fed_rule_exists into l_temp_char;
           if csr_fed_rule_exists%notfound then
             l_mode := 'UPDATE';
           else
             l_mode := 'UPDATE_CHANGE_INSERT';
           end if;
           close csr_fed_rule_exists;

           hr_entry_api.update_element_entry(
              p_dt_update_mode           => l_mode,
              p_session_date             => l_effective_date,
              p_element_entry_id         => l_element_entry_id,
              p_num_entry_values         => 2,
              p_input_value_id_tbl       => l_inp_value_id_table,
              p_entry_value_tbl          => l_scr_value_table);

         end if;

       end if;

    end if;

  end if;
  --
  -- Set OUT parameter
  --
  --
end maintain_wc;

-- ----------------------------------------------------------------------------
-- |------------------------< delete_fed_tax_rule >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fed_tax_rule
  (p_effective_date                 in     date
  ,p_datetrack_delete_mode          in     varchar2
  ,p_assignment_id                  in     number
  ,p_delete_routine                 in     varchar2
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'delete_fed_tax_rule';
  l_effective_date             date;
  l_state_code                 pay_us_emp_state_tax_rules_f.state_code%TYPE;
  l_emp_fed_tax_rule_id        pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
  l_effective_start_date       pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_effective_end_date         pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_object_version_number      pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
  l_tmp_effective_start_date   pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_tmp_effective_end_date     pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_tmp_object_version_number  pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
  --
  l_exit_quietly          exception;
  --
  cursor csr_fed_rule is
    select fed.emp_fed_tax_rule_id, fed.object_version_number
    from   pay_us_emp_fed_tax_rules_f fed
    where  fed.assignment_id = p_assignment_id
    and    l_effective_date between fed.effective_start_date
                                and fed.effective_end_date;
  --
  cursor csr_state_rules is
    select sta.state_code, sta.object_version_number
    from   pay_us_emp_state_tax_rules_f sta
    where  sta.assignment_id = p_assignment_id
    and    l_effective_date between sta.effective_start_date
                                and sta.effective_end_date;
  --
  --
begin
  --
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate that a federal tax rule exists for this assignment
  --
  open csr_fed_rule;
  fetch csr_fed_rule into l_emp_fed_tax_rule_id, l_object_version_number;
  if csr_fed_rule%notfound then
    close csr_fed_rule;
    raise l_exit_quietly;
  end if;
  close csr_fed_rule;
  --
  if p_datetrack_delete_mode NOT IN ('ZAP', 'DELETE') then
    hr_utility.set_message(801, 'HR_7204_DT_DEL_MODE_INVALID');
    hr_utility.raise_error;
  end if;
  --
  -- Validate that this routine is called from Assignment code
  --
  if nvl(p_delete_routine,'X') <> 'ASSIGNMENT' then
    hr_utility.set_message(801, 'HR_6674_PAY_ASSIGN');
    hr_utility.raise_error;
  end if;
  --
  open csr_state_rules;
  loop
    fetch csr_state_rules into l_state_code, l_tmp_object_version_number;
    exit when csr_state_rules%notfound;
    --
    --  Call delete_tax_rules API here passing in l_assignment_id, l_state_code
    pay_us_tax_api.delete_tax_rule(
                    p_validate              => NULL
                   ,p_effective_date        => l_effective_date
                   ,p_assignment_id         => p_assignment_id
                   ,p_state_code            => l_state_code
                   ,p_county_code           => '000'
                   ,p_city_code             => '0000'
                   ,p_datetrack_mode        => p_datetrack_delete_mode
                   ,p_effective_start_date  => l_tmp_effective_start_date
                   ,p_effective_end_date    => l_tmp_effective_end_date
                   ,p_object_version_number => l_tmp_object_version_number
                   ,p_delete_routine        => p_delete_routine
                   );
    --
  end loop;
  close csr_state_rules;
  --
  maintain_wc(
                   p_emp_fed_tax_rule_id    => l_emp_fed_tax_rule_id
                  ,p_effective_start_date   => l_effective_start_date
                  ,p_effective_end_date     => l_effective_end_date
                  ,p_effective_date         => l_effective_date
                  ,p_datetrack_mode         => p_datetrack_delete_mode
                  );
  --
  pay_fed_del.del(p_emp_fed_tax_rule_id     => l_emp_fed_tax_rule_id
                 ,p_effective_start_date    => l_effective_start_date
                 ,p_effective_end_date      => l_effective_end_date
                 ,p_object_version_number   => l_object_version_number
                 ,p_effective_date          => l_effective_date
                 ,p_datetrack_mode          => p_datetrack_delete_mode
                 ,p_delete_routine          => p_delete_routine
                 );
  --
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Set all output arguments
  --
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when l_exit_quietly then
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 75);
    --
    --
end delete_fed_tax_rule;
-- ----------------------------------------------------------------------------
-- |---------------------------< address_change >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure address_change
    (p_effective_date               In      date
    ,p_person_id                    In      number     default null
    ,p_assignment_id                In      number     default null
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72) := g_package||'address_change';
  l_effective_date              date;
  l_defaulting_date		date;
  l_temp_char                   varchar2(10);
  l_assignment_id               per_assignments_f.assignment_id%TYPE;
  l_person_id                   per_assignments_f.person_id%TYPE;
  l_res_state_code              pay_us_states.state_code%TYPE;
  l_res_county_code             pay_us_counties.county_code%TYPE;
  l_res_city_code               pay_us_city_names.city_code%TYPE;
  l_res_ovrd_state_code         pay_us_states.state_code%TYPE;
  l_res_ovrd_county_code        pay_us_counties.county_code%TYPE;
  l_res_ovrd_city_code          pay_us_city_names.city_code%TYPE;

  --
  cursor csr_per_id is
    select null
    from   per_people_f peo
    where  peo.person_id = p_person_id;
  --
  cursor csr_asg_id is
    select asg.person_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id;
  --
  cursor csr_per_asg_id is
    select asg.assignment_id
    from   per_assignments_f asg
    where  asg.person_id = p_person_id
    and    l_effective_date between asg.effective_start_date
           and asg.effective_end_date;
  --
  --

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate p_person_id or p_assignment_id
  --
  if p_assignment_id is not null then
    open csr_asg_id;
    fetch csr_asg_id into l_person_id;
    if csr_asg_id%notfound then
      close csr_asg_id;
      hr_utility.set_message(801, 'HR_7702_PDT_VALUE_NOT_FOUND');
      hr_utility.raise_error;
    end if;
    close csr_asg_id;
  elsif p_person_id is not null then
    open  csr_per_id;
    fetch csr_per_id into l_temp_char;
    if csr_per_id%NOTFOUND then
      close csr_per_id;
      hr_utility.set_message(801, 'HR_51396_WEB_PERSON_NOT_FND');
      hr_utility.raise_error;
    end if;
    close csr_per_id;
    l_person_id := p_person_id;
  else
    hr_utility.set_message(801,'HR_6480_FF_DEF_RULE');
    hr_utility.set_message_token('ELEMENT_OR_INPUT',
                                 'Assignment_id or person_id');
    hr_utility.raise_error;
  end if;
  --
  -- Select the codes for the new primary residence state, county and city
  --
  open csr_res_addr(l_person_id,l_effective_date);
  fetch csr_res_addr into l_res_state_code, l_res_county_code, l_res_city_code,
			  l_res_ovrd_state_code, l_res_ovrd_county_code,
			  l_res_ovrd_city_code;
  if csr_res_addr%NOTFOUND then
    close csr_res_addr;
    -- it is being called by Person Address form So checks for date
    -- effectivity which is not required for person address form.
    -- Cursor csr_res_addr_no_eff_dt does not check for effective dates
    open csr_res_addr_no_eff_dt(l_person_id,l_effective_date);
    fetch csr_res_addr_no_eff_dt into l_res_state_code, l_res_county_code, l_res_city_code,
			  l_res_ovrd_state_code, l_res_ovrd_county_code,
			  l_res_ovrd_city_code;
    if csr_res_addr_no_eff_dt%NOTFOUND then
       close csr_res_addr_no_eff_dt;
       hr_utility.set_message(801, 'HR_7144_PER_NO_PRIM_ADD');
       hr_utility.raise_error;
    end if;
    close csr_res_addr_no_eff_dt;
  else
   close csr_res_addr;
  end if;
  --
  if p_assignment_id is null then
    --
    -- Cursor through the assignments for the given person_id
    --
    open  csr_per_asg_id;
    loop
      fetch csr_per_asg_id into l_assignment_id;
      exit when csr_per_asg_id%NOTFOUND;
      --
      open csr_defaulting_date(l_assignment_id);
      fetch csr_defaulting_date into l_defaulting_date;
      close csr_defaulting_date;
      if l_defaulting_date is not null then
        --
   	create_tax_rules_for_jd(p_state_code => l_res_state_code,
				p_county_code => l_res_county_code,
				p_city_code => l_res_city_code,
				p_effective_date => l_defaulting_date,
				p_assignment_id => l_assignment_id
				);

   	create_tax_rules_for_jd(p_state_code => l_res_ovrd_state_code,
				p_county_code => l_res_ovrd_county_code,
				p_city_code => l_res_ovrd_city_code,
				p_effective_date => l_defaulting_date,
				p_assignment_id => l_assignment_id
				);

      end if;
      --
    end loop;
    close csr_per_asg_id;
    --
  else
    --
      open csr_defaulting_date(p_assignment_id);
      fetch csr_defaulting_date into l_defaulting_date;
      close csr_defaulting_date;
      if l_defaulting_date is not null then
        --
   	create_tax_rules_for_jd(p_state_code => l_res_state_code,
				p_county_code => l_res_county_code,
				p_city_code => l_res_city_code,
				p_effective_date => l_defaulting_date,
				p_assignment_id => p_assignment_id
				);

   	create_tax_rules_for_jd(p_state_code => l_res_ovrd_state_code,
				p_county_code => l_res_ovrd_county_code,
				p_city_code => l_res_ovrd_city_code,
				p_effective_date => l_defaulting_date,
				p_assignment_id => p_assignment_id
				);

       end if; -- defaulting date
    --
  end if; -- assignment id null
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end address_change;
-- ----------------------------------------------------------------------------
-- |-----------------------< validate_us_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_us_address(p_person_id      number
                            , p_effective_date date
                            , p_primary_flag   varchar2
                            , p_style          varchar2) IS

  --
  cursor csr_latest_pos is
     select final_process_date
       from per_periods_of_service pos
      where pos.person_id = p_person_id
        and pos.date_start =
             (select max(date_start)
                from per_periods_of_service pos2
               where pos2.person_id = pos.person_id
                 and date_start <= p_effective_date);
   --
   l_proc          varchar2(100) := g_package||'validate_us_address';
   --
   l_final_date    date; -- final process date

BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    if p_primary_flag = 'Y' then
       if p_style <> 'US' then
            hr_utility.set_location(l_proc, 15);
            if Hr_General2.is_person_type(p_person_id,'EX_EMP',p_effective_date) then
               --
               hr_utility.set_location(l_proc, 20);
               --
               open csr_latest_pos;
               fetch csr_latest_pos into l_final_date;
               if csr_latest_pos%FOUND then
                  if (l_final_date is null)
                    or (l_final_date is not null
                         and l_final_date >= p_effective_date)
                  then
                     close csr_latest_pos;
                     hr_utility.set_message(800, 'HR_51283_ADD_MUST_BE_US_STYLE');
                     hr_utility.raise_error;

                  end if;
               end if;
               close csr_latest_pos;
            elsif Hr_General2.is_person_type(p_person_id,'EMP',p_effective_date) then
                hr_utility.set_location(l_proc, 30);
                hr_utility.set_message(800, 'HR_51283_ADD_MUST_BE_US_STYLE');
                hr_utility.raise_error;
            end if;
       end if; -- style
    end if; -- primary flag
          --
    hr_utility.set_location('Leaving:'|| l_proc, 50);

END validate_us_address;
-- ----------------------------------------------------------------------------
-- |-----------------------< create_default_tax_rules >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_default_tax_rules
  (p_effective_date                 in      date
  ,p_assignment_id                  in      number
  ,p_emp_fed_tax_rule_id                out nocopy number
  ,p_fed_object_version_number          out nocopy number
  ,p_fed_effective_start_date           out nocopy date
  ,p_fed_effective_end_date             out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'create_default_tax_rules';
  l_effective_date              date;
  l_emp_fed_tax_rule_id    pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
  l_fed_effective_start_date
                          pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_fed_effective_end_date  pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_fed_object_version_number
                         pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
  l_business_group_id       per_assignments_f.business_group_id%TYPE;
  l_additional_wa_amount
                     pay_us_emp_fed_tax_rules_f.additional_wa_amount%TYPE:='0';
  l_filing_status_code
                     pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE:='01';
/*
  l_eic_filing_status_code
       pay_us_emp_fed_tax_rules_f.eic_filing_status_code%TYPE:='3'; No EIC */

  l_eic_filing_status_code
       pay_us_emp_fed_tax_rules_f.eic_filing_status_code%TYPE; /* No EIC */

  l_fit_override_amount
                     pay_us_emp_fed_tax_rules_f.fit_override_amount%TYPE:='0';
  l_fit_override_rate
                     pay_us_emp_fed_tax_rules_f.fit_override_rate%TYPE:='0';
  l_withholding_allowances
                   pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE:='0';
  l_cumulative_taxation    pay_us_emp_fed_tax_rules_f.cumulative_taxation%TYPE;
  l_fit_additional_tax     pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE;
  l_fit_exempt             pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE;
  l_futa_tax_exempt        pay_us_emp_fed_tax_rules_f.futa_tax_exempt%TYPE;
  l_medicare_tax_exempt    pay_us_emp_fed_tax_rules_f.medicare_tax_exempt%TYPE;
  l_ss_tax_exempt          pay_us_emp_fed_tax_rules_f.ss_tax_exempt%TYPE;
  l_wage_exempt            pay_us_emp_fed_tax_rules_f.wage_exempt%TYPE;
  l_statutory_employee     pay_us_emp_fed_tax_rules_f.statutory_employee%TYPE;
  l_supp_tax_override_rate pay_us_emp_fed_tax_rules_f.supp_tax_override_rate%TYPE;
  --
  l_temp_tax_rule_id        pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
  l_temp_eff_start_date   pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_temp_eff_end_date       pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_temp_ovn             pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
  --
  l_default_flag            varchar2(1) := 'Y';
  l_asg_min_start_date      per_assignments_f.effective_start_date%TYPE;
  l_adr_min_start_date      per_addresses.date_from%TYPE;
  l_defaulting_date         per_assignments_f.effective_start_date%TYPE;

  l_loc_state_code          pay_us_states.state_code%TYPE;
  l_loc_ovrd_state_code     pay_us_states.state_code%TYPE;
  l_loc_county_code         pay_us_counties.county_code%TYPE;
  l_loc_ovrd_county_code    pay_us_counties.county_code%TYPE;
  l_loc_city_code           pay_us_city_names.city_code%TYPE;
  l_loc_ovrd_city_code      pay_us_city_names.city_code%TYPE;

  l_res_state_code          pay_us_states.state_code%TYPE;
  l_res_county_code         pay_us_counties.county_code%TYPE;
  l_res_city_code           pay_us_city_names.city_code%TYPE;
  l_res_ovrd_state_code     pay_us_states.state_code%TYPE;
  l_res_ovrd_county_code    pay_us_counties.county_code%TYPE;
  l_res_ovrd_city_code      pay_us_city_names.city_code%TYPE;

  l_tax_location_id		hr_locations.location_id%TYPE;
  l_tax_loc_state_code          pay_us_states.state_code%TYPE;
  l_tax_loc_ovrd_state_code     pay_us_states.state_code%TYPE;
  l_tax_loc_county_code         pay_us_counties.county_code%TYPE;
  l_tax_loc_ovrd_county_code    pay_us_counties.county_code%TYPE;
  l_tax_loc_city_code           pay_us_city_names.city_code%TYPE;
  l_tax_loc_ovrd_city_code      pay_us_city_names.city_code%TYPE;

  l_sui_state_code	    pay_us_states.state_code%TYPE;
  l_sui_state_jd_code       pay_state_rules.jurisdiction_code%TYPE;

  l_tmp_loc_id              number;
  l_hold_loc_id             number;
  l_person_id		    per_people_f.person_id%TYPE;
  --
  l_exit_quietly            exception;
  --
  cursor csr_asg_bg_id is
    select asg.business_group_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    l_effective_date between asg.effective_start_date
           and asg.effective_end_date;
  --
  cursor csr_asg_defaulting_date is
     select min(asg.effective_start_date)
     from   per_assignments_f asg
     where  asg.assignment_id = p_assignment_id
     and    asg.pay_basis_id is not null
     and    asg.payroll_id is not null
     and    asg.soft_coding_keyflex_id is not null
     and    asg.location_id is not null
     and    asg.assignment_type = 'E'
     and    exists (select null
                  from   hr_soft_coding_keyflex sck
                  where  sck.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
                  and    sck.segment1 is not null);
  --
  cursor csr_adr_defaulting_date is
     select min(adr.date_from)
     from   per_addresses adr
            ,per_assignments_f asg
     where  asg.assignment_id = p_assignment_id
     and    adr.person_id = asg.person_id
     and    adr.primary_flag = 'Y';
  --
  cursor csr_asg_loc_id is
    select location_id
    from   per_assignments_f
    where  assignment_id = p_assignment_id
    and    effective_end_date > l_effective_date
    order by effective_end_date;

  cursor csr_get_asg_details is
    select location_id,person_id
    from   per_assignments_f
    where  assignment_id = p_assignment_id
    and	   l_defaulting_date between effective_start_date and effective_end_date;
  --
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- First check if geocode has been installed or not. If no geocodes
  -- installed then return because there is nothing to be done by this
  -- defaulting procedure
  if hr_general.chk_maintain_tax_records = 'N' then
     raise l_exit_quietly;
  end if;
  --
  -- Validate p_assignment_id and get its business_group_id
  --
  open  csr_asg_bg_id;
  fetch csr_asg_bg_id into l_business_group_id;
  if csr_asg_bg_id%NOTFOUND then
    close csr_asg_bg_id;
    hr_utility.set_message(801, 'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  end if;
  close csr_asg_bg_id;
  --
  -- Check that no Federal rule already exists for this assignment
  --
  open csr_defaulting_date(p_assignment_id);
  fetch csr_defaulting_date into l_defaulting_date;
  close csr_defaulting_date;
  if l_defaulting_date is not null then
    raise l_exit_quietly;
  end if;
  --
  hr_utility.set_location(l_proc, 30);

  -- Select initial date that the tax defaulting criteria was met.
  -- Check when the assignment criteria was met, and when the primary
  -- address criteria was met.  The defaulting date will be the later
  -- of these two dates.
  --
  open csr_asg_defaulting_date;
  fetch csr_asg_defaulting_date into l_asg_min_start_date;
  close csr_asg_defaulting_date;

  if l_asg_min_start_date is null then
    raise l_exit_quietly;
  end if;

  open csr_asg_loc_id;
  fetch csr_asg_loc_id into l_hold_loc_id;
  loop
    exit when csr_asg_loc_id%notfound;
    fetch csr_asg_loc_id into l_tmp_loc_id;
    if l_tmp_loc_id <> l_hold_loc_id then
       close csr_asg_loc_id;
       hr_utility.set_message('801','PAY_52299_TAX_FUT_LOC');
       hr_utility.raise_error;
    end if;
  end loop;
  close csr_asg_loc_id;
  --
  -- Select initial date that the tax defaulting criteria was met.
  -- Check when the assignment criteria was met, and when the primary
  -- address criteria was met.  The defaulting date will be the later
  -- of these two dates.
  --
-- rmonge
--  open csr_asg_defaulting_date;
--  fetch csr_asg_defaulting_date into l_asg_min_start_date;
--  close csr_asg_defaulting_date;
--  if l_asg_min_start_date is null then
--    raise l_exit_quietly;
--  end if;
  --
  hr_utility.set_location(l_proc, 40);
  open csr_adr_defaulting_date;
  fetch csr_adr_defaulting_date into l_adr_min_start_date;
  close csr_adr_defaulting_date;
  if l_adr_min_start_date is null then
    raise l_exit_quietly;
  end if;
  --
  if l_adr_min_start_date > l_asg_min_start_date then
    l_defaulting_date := l_adr_min_start_date;
  else
    l_defaulting_date := l_asg_min_start_date;
  end if;
  --
  -- Select state, county, city codes for the work location of the assignment.
  --

  open csr_get_asg_details;
  fetch csr_get_asg_details into l_tmp_loc_id, l_person_id;
  close csr_get_asg_details;

  open csr_loc_addr(l_tmp_loc_id);
  fetch csr_loc_addr into l_loc_state_code, l_loc_county_code, l_loc_city_code,
			  l_loc_ovrd_state_code, l_loc_ovrd_county_code,
			  l_loc_ovrd_city_code;

  if csr_loc_addr%NOTFOUND then
    close csr_loc_addr;
    hr_utility.set_message(801, 'HR_51138_TAX_NOT_COMP_LOC_COV');
    hr_utility.raise_error;
  end if;
  close csr_loc_addr;
  hr_utility.set_location(l_proc, 50);
  --
  -- Derive the jurisdiction codes for the assignment work location.
  if l_loc_ovrd_state_code is not null then
	l_sui_state_code := l_loc_ovrd_state_code;
  else
	l_sui_state_code := l_loc_state_code;
  end if;


  --
  -- Set default values
  --
  l_cumulative_taxation     := 'N';
  l_fit_additional_tax      := 0;
  l_fit_exempt              := 'N';
  l_futa_tax_exempt         := 'N';
  l_medicare_tax_exempt     := 'N';
  l_ss_tax_exempt           := 'N';
  l_wage_exempt             := 'N';
  l_statutory_employee      := 'N';
  l_supp_tax_override_rate  := 0;
  --

-- Testing bug 2277932
-- Eliminated the default value of '3' assigned to l_eic_filing_status_code
-- Selecting the value from fnd_common_lookups

 begin
  select lookup_code
  into   l_eic_filing_status_code
  from  fnd_common_lookups
  where  lookup_type ='US_EIC_FILING_STATUS'
  and   Meaning='No EIC';
 exception
  when no_data_found then
      l_eic_filing_status_code := '0';
  end ;

  -- Insert a default federal tax rule
  --
  pay_fed_ins.ins (p_emp_fed_tax_rule_id          => l_emp_fed_tax_rule_id
                  ,p_effective_start_date         => l_fed_effective_start_date
                  ,p_effective_end_date           => l_fed_effective_end_date
                  ,p_assignment_id                => p_assignment_id
                  ,p_sui_state_code               => l_sui_state_code
                  ,p_sui_jurisdiction_code        => l_sui_state_code || '-000-0000'
                  ,p_business_group_id            => l_business_group_id
                  ,p_additional_wa_amount         => l_additional_wa_amount
                  ,p_filing_status_code           => l_filing_status_code
		  ,p_eic_filing_status_code       => l_eic_filing_status_code
                  ,p_fit_override_amount          => l_fit_override_amount
                  ,p_fit_override_rate            => l_fit_override_rate
                  ,p_withholding_allowances       => l_withholding_allowances
                  ,p_cumulative_taxation          => l_cumulative_taxation
                  ,p_fit_additional_tax           => l_fit_additional_tax
                  ,p_fit_exempt                   => l_fit_exempt
                  ,p_futa_tax_exempt              => l_futa_tax_exempt
                  ,p_medicare_tax_exempt          => l_medicare_tax_exempt
                  ,p_ss_tax_exempt                => l_ss_tax_exempt
                  ,p_wage_exempt                  => l_wage_exempt
                  ,p_statutory_employee           => l_statutory_employee
                  ,p_supp_tax_override_rate       => l_supp_tax_override_rate
                  ,p_object_version_number        => l_fed_object_version_number
                  ,p_effective_date               => l_defaulting_date
                  ,p_attribute_category        => null
                  ,p_attribute1                => null
                  ,p_attribute2                => null
                  ,p_attribute3                => null
                  ,p_attribute4                => null
                  ,p_attribute5                => null
                  ,p_attribute6                => null
                  ,p_attribute7                => null
                  ,p_attribute8                => null
                  ,p_attribute9                => null
                  ,p_attribute10               => null
                  ,p_attribute11               => null
                  ,p_attribute12               => null
                  ,p_attribute13               => null
                  ,p_attribute14               => null
                  ,p_attribute15               => null
                  ,p_attribute16               => null
                  ,p_attribute17               => null
                  ,p_attribute18               => null
                  ,p_attribute19               => null
                  ,p_attribute20               => null
                  ,p_attribute21               => null
                  ,p_attribute22               => null
                  ,p_attribute23               => null
                  ,p_attribute24               => null
                  ,p_attribute25               => null
                  ,p_attribute26               => null
                  ,p_attribute27               => null
                  ,p_attribute28               => null
                  ,p_attribute29               => null
                  ,p_attribute30               => null
                  ,p_fed_information_category  => null
                  ,p_fed_information1          => null
                  ,p_fed_information2          => null
                  ,p_fed_information3          => null
                  ,p_fed_information4          => null
                  ,p_fed_information5          => null
                  ,p_fed_information6          => null
                  ,p_fed_information7          => null
                  ,p_fed_information8          => null
                  ,p_fed_information9          => null
                  ,p_fed_information10         => null
                  ,p_fed_information11         => null
                  ,p_fed_information12         => null
                  ,p_fed_information13         => null
                  ,p_fed_information14         => null
                  ,p_fed_information15         => null
                  ,p_fed_information16         => null
                  ,p_fed_information17         => null
                  ,p_fed_information18         => null
                  ,p_fed_information19         => null
                  ,p_fed_information20         => null
                  ,p_fed_information21         => null
                  ,p_fed_information22         => null
                  ,p_fed_information23         => null
                  ,p_fed_information24         => null
                  ,p_fed_information25         => null
                  ,p_fed_information26         => null
                  ,p_fed_information27         => null
                  ,p_fed_information28         => null
                  ,p_fed_information29         => null
                  ,p_fed_information30         => null                  );
  --
  -- Create a workers compensation element entry for this assignment.
  --
  maintain_wc(
                   p_emp_fed_tax_rule_id    => l_emp_fed_tax_rule_id
                  ,p_effective_start_date   => l_fed_effective_start_date
                  ,p_effective_end_date     => l_fed_effective_end_date
                  ,p_effective_date         => l_defaulting_date
                  ,p_datetrack_mode         => 'INSERT'
                  );

 --
  -- Create a default tax rules for the work location
  --
  create_tax_rules_for_jd(p_effective_date        => l_defaulting_date
                        ,p_assignment_id          => p_assignment_id
                        ,p_state_code             => l_loc_state_code
			,p_county_code		  => l_loc_county_code
			,p_city_code		  => l_loc_city_code
                        );

  --
  -- Create a default tax rules for the work location taxation address
  --
  create_tax_rules_for_jd(p_effective_date        => l_defaulting_date
                        ,p_assignment_id          => p_assignment_id
                        ,p_state_code             => l_loc_ovrd_state_code
			,p_county_code		  => l_loc_ovrd_county_code
			,p_city_code		  => l_loc_ovrd_city_code
                        );

  --
  -- create default tax rules for taxation location
  --
  open csr_get_tax_loc(p_assignment_id,l_defaulting_date);
  fetch csr_get_tax_loc into l_tax_location_id;
  if csr_get_tax_loc%FOUND then
	open csr_loc_addr(l_tax_location_id);
	fetch csr_loc_addr into l_tax_loc_state_code,l_tax_loc_county_code,
				l_tax_loc_city_code,l_tax_loc_ovrd_state_code,
				l_tax_loc_ovrd_county_code,l_tax_loc_ovrd_city_code;

  	if csr_loc_addr%NOTFOUND then
    		close csr_loc_addr;
		close csr_get_tax_loc;
    		hr_utility.set_message(801, 'PY_51133_TXADJ_INVALID_CITY');
    		hr_utility.raise_error;
  	end if;

	close csr_loc_addr;

   	create_tax_rules_for_jd(p_state_code => l_tax_loc_state_code,
				p_county_code => l_tax_loc_county_code,
				p_city_code => l_tax_loc_city_code,
				p_effective_date => l_defaulting_date,
				p_assignment_id => p_assignment_id
				);

   	create_tax_rules_for_jd(p_state_code => l_tax_loc_ovrd_state_code,
				p_county_code => l_tax_loc_ovrd_county_code,
				p_city_code => l_tax_loc_ovrd_city_code,
				p_effective_date => l_defaulting_date,
				p_assignment_id => p_assignment_id
				);
  end if; -- csr_get_tax_loc

  close csr_get_tax_loc;

  --
  -- Select state, county and city codes for the person's residence.
  --
  open csr_res_addr(l_person_id,l_defaulting_date);
  fetch csr_res_addr into l_res_state_code, l_res_county_code, l_res_city_code,
			  l_res_ovrd_state_code, l_res_ovrd_county_code,
			  l_res_ovrd_city_code;
  if csr_res_addr%NOTFOUND then
    close csr_res_addr;
    hr_utility.set_message(801, 'HR_7144_PER_NO_PRIM_ADD');
    hr_utility.raise_error;
  end if;
  close csr_res_addr;
  --
  -- Determine if other tax rules for the residence location should be created
  --
  if (l_res_state_code||l_res_county_code||l_res_city_code <>
	l_loc_state_code||l_loc_county_code||l_loc_city_code) and
     (l_res_state_code||l_res_county_code||l_res_city_code <>
	l_loc_ovrd_state_code||l_loc_ovrd_county_code||l_loc_ovrd_city_code) then

     -- Create Tax Rules for Residence Address

     create_tax_rules_for_jd(p_effective_date        => l_defaulting_date
                            ,p_assignment_id         => p_assignment_id
                            ,p_state_code            => l_res_state_code
			    ,p_county_code	     => l_res_county_code
			    ,p_city_code	     => l_res_city_code
                            );
  end if;

  if (l_res_ovrd_state_code||l_res_ovrd_county_code||l_res_ovrd_city_code <>
	l_loc_state_code||l_loc_county_code||l_loc_city_code) and
     (l_res_ovrd_state_code||l_res_ovrd_county_code||l_res_city_code <>
	l_loc_ovrd_state_code||l_loc_ovrd_county_code||l_loc_ovrd_city_code) then

     -- Create Tax Rules for Taxation Address

     create_tax_rules_for_jd(p_effective_date        => l_defaulting_date
                            ,p_assignment_id         => p_assignment_id
                            ,p_state_code            => l_res_ovrd_state_code
			    ,p_county_code	     => l_res_ovrd_county_code
			    ,p_city_code	     => l_res_ovrd_city_code
                            );
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Set all output arguments
  --
  p_emp_fed_tax_rule_id := l_emp_fed_tax_rule_id;
  p_fed_effective_start_date := l_fed_effective_start_date;
  p_fed_effective_end_date := l_fed_effective_end_date;
  p_fed_object_version_number := l_fed_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when l_exit_quietly then
    --
    -- One of the following conditions has made it unnecessary to create tax
    -- rules:
    --  Geocodes are not installed, Federal tax rules already exist, the
    --  assignment or primary address does not meet tax rule defaulting
    --  criteria.  We return to the calling program without making any changes.
    --
    p_emp_fed_tax_rule_id := null;
    p_fed_effective_start_date := null;
    p_fed_effective_end_date := null;
    p_fed_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 75);
  --
end create_default_tax_rules;

-- ----------------------------------------------------------------------------
-- |----------------------< maintain_us_employee_taxes >----------------------|
-- ----------------------------------------------------------------------------
procedure maintain_us_employee_taxes
(  p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2  default null
  ,p_assignment_id                  in  number    default null
  ,p_location_id                    in  number    default null
  ,p_address_id                     in  number    default null
  ,p_delete_routine                 in  varchar2  default null
 ) is
  TYPE assign_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := g_package||'maintain_us_employee_taxes';
  l_counter                    number := 0;
  l_effective_date             date;
  l_assignment_id              per_assignments_f.assignment_id%TYPE;
  l_location_id                per_assignments_f.location_id%TYPE;
  l_defaulting_date       pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_fed_tax_rule_id       pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
  l_fed_object_version_number
                          pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
  l_fed_eff_start_date    pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_fed_eff_end_date      pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_tax_location_id	  hr_locations.location_id%TYPE;
  l_tax_loc_state_code	  pay_us_states.state_code%TYPE;
  l_tax_loc_county_code	  pay_us_counties.county_code%TYPE;
  l_tax_loc_city_code	  pay_us_city_names.city_code%TYPE;
  l_tax_loc_ovrd_state_code	  pay_us_states.state_code%TYPE;
  l_tax_loc_ovrd_county_code	  pay_us_counties.county_code%TYPE;
  l_tax_loc_ovrd_city_code	  pay_us_city_names.city_code%TYPE;
  l_temp_char             varchar2(1);
  l_temp_num              number;
  l_cnt                   number;
  l_assignment_tbl        assign_tbl_type;
  -- >> 2858888
  l_person_id             per_all_people_f.person_id%TYPE;
  l_adr_primary           per_addresses.primary_flag%TYPE;
  l_adr_style             per_addresses.style%TYPE;
  -- <<
  l_exit_quietly          exception;
  l_payroll_id            per_all_assignments_f.payroll_id%TYPE;
  l_effective_start_date  per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date    per_all_assignments_f.effective_end_date%TYPE;
  --
-- rmonge Bug fix 3599825.

  cursor csr_asg_id(p_csr_assignment_id number) is
    select null
    from per_assignments_f  asg,
        hr_organization_information bus
    where asg.assignment_id    = p_csr_assignment_id
    and bus.organization_id  = asg.business_group_id
    and bus.org_information9  = 'US'
    and bus.org_information_context = 'Business Group Information'
    and p_effective_date  between asg.effective_start_date
                              and asg.effective_end_date ;


  --
  cursor csr_adr_id(p_adr_id number) is
    select person_id, primary_flag, style  -- #2858888
    from   per_addresses adr
    where  adr.address_id = p_adr_id;
  --
  cursor csr_adr_asg_id(p_adr_id number) is
    select asg.assignment_id
    from   per_assignments_f asg,
           per_addresses     adr
    where  asg.person_id = adr.person_id
    and    p_effective_date between asg.effective_start_date
                                and asg.effective_end_date
    and    adr.address_id = p_adr_id;
  --
/*Bug8285850 Cursor to check if the current update or correction statement
is removing payroll information from the assignment.This will
return records only when we have Vertex or Workers compensation links setup
as link to all payrolls and  trying to remove payroll after defaulting*/

  cursor csr_defaultpayrollremoved(p_assignment_id number,p_effective_date date) is
    select null
    from  per_all_assignments_f paa,
          pay_element_links_f pel,
          pay_element_types_f pet
    where paa.assignment_id=p_assignment_id
    and   paa.payroll_id is null
    and   p_effective_date between paa.effective_start_date
	                       and paa.effective_end_date
    and   paa.business_group_id=pel.business_group_id
    and   pel.link_to_all_payrolls_flag = 'Y'
    and   p_effective_date between pel.effective_start_date
	                       and pel.effective_end_date
    and   pel.element_type_id=pet.element_type_id
    and   p_effective_date between pet.effective_start_date
                               and pet.effective_end_date
    and   pet.element_name in ('VERTEX','Workers Compensation');

/*Bug8285850 Cursor to get the details of the assignment that is being updated */

  cursor csr_asgmt_details(p_assignment_id number,p_effective_date date) is
    select payroll_id,
           effective_start_date,
	   effective_end_date
    from  per_all_assignments_f
    where assignment_id=p_assignment_id
    and   p_effective_date between effective_start_date
                               and effective_end_date;

  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- First check if geocode has been installed or not. If no geocodes
  -- installed then return because there is nothing to be done by this
  -- procedure
  if hr_general.chk_maintain_tax_records = 'N' then
     raise l_exit_quietly;
  end if;
  --
  if p_assignment_id is null and p_address_id is null then
    hr_utility.set_message(801,'HR_6480_FF_DEF_RULE');
    hr_utility.set_message_token('ELEMENT_OR_INPUT',
                          'Assignment_id or address_id');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  if p_datetrack_mode NOT IN ('ZAP',
                              'DELETE',
                              'UPDATE',
                              'CORRECTION',
                              'UPDATE_OVERRIDE',
                              'UPDATE_CHANGE_INSERT') then
    hr_utility.set_message(801, 'HR_7204_DT_DEL_MODE_INVALID');
    hr_utility.raise_error;
  elsif p_datetrack_mode in ('ZAP', 'DELETE') then
    hr_utility.set_location(l_proc, 40);
    --
    if p_assignment_id is not null then
      l_assignment_tbl(1) := p_assignment_id;
    else
      l_cnt := 0;
      for l_assgn_rec in csr_adr_asg_id(p_address_id) loop
        l_cnt := l_cnt + 1;
        l_assignment_tbl(l_cnt) := l_assgn_rec.assignment_id;
      end loop;
    end if;
    --
    for l_cnt in 1..l_assignment_tbl.last loop
      open csr_asg_id(l_assignment_tbl(l_cnt));
      fetch csr_asg_id into l_temp_num;
      if csr_asg_id%notfound then
        close csr_asg_id;
        hr_utility.set_message(801,'PAY_7702_PDT_VALUE_NOT_FOUND');
        hr_utility.raise_error;
      end if;
      close csr_asg_id;
      --
      hr_utility.set_location(l_proc, 45);
      delete_fed_tax_rule(
                        p_effective_date         => l_effective_date
                       ,p_datetrack_delete_mode  => p_datetrack_mode
                       ,p_assignment_id          => l_assignment_tbl(l_cnt)
                       ,p_delete_routine         => p_delete_routine
                       ,p_effective_start_date   => l_fed_eff_start_date
                       ,p_effective_end_date     => l_fed_eff_end_date
                       ,p_object_version_number  => l_fed_object_version_number
                       );
    end loop;
  else
    if p_assignment_id is not null then
      --
      hr_utility.set_location(l_proc, 50);
      l_assignment_id := p_assignment_id;
      --
      open csr_asg_id(l_assignment_id);
      fetch csr_asg_id into l_temp_num;
      if csr_asg_id%notfound then
        close csr_asg_id;
        hr_utility.set_message(801,'PAY_7702_PDT_VALUE_NOT_FOUND');
        hr_utility.raise_error;
      end if;
      close csr_asg_id;
      --
      open csr_defaulting_date(l_assignment_id);
      fetch csr_defaulting_date into l_defaulting_date;
      close csr_defaulting_date;

      if l_defaulting_date is null then

        create_default_tax_rules(
                      p_effective_date         => l_effective_date
                     ,p_assignment_id          => p_assignment_id
                     ,p_emp_fed_tax_rule_id    => l_fed_tax_rule_id
                     ,p_fed_object_version_number => l_fed_object_version_number
                     ,p_fed_effective_start_date  => l_fed_eff_start_date
                     ,p_fed_effective_end_date    => l_fed_eff_end_date
                     );

      else
	-- reimp - discovered it was possible to remove defaulting conditions
	-- we need to make sure that this change is not removing some defaulting
	-- condition.  To do this, we check to make sure that if l_effective_date => l_default_date
	-- then chk_defaulting_met must be true;
	if l_effective_date >= l_defaulting_date then

		open csr_defaulting_met(p_assignment_id,l_effective_date);
		fetch csr_defaulting_met into l_temp_char;

		/*Modified for bug 8285850.Introduced cursor csr_asgpayrollremoved
		 to check if the current update or correction operation is trying
		 to remove the payroll information after the defaulting for a setup
		 with vertex or Workers compensation link set as Link to All Payrolls.*/

		if csr_defaulting_met%NOTFOUND then

		open csr_defaultpayrollremoved(p_assignment_id,p_effective_date);
		fetch csr_defaultpayrollremoved into l_temp_char;

               /*An error will be thrown,if we try to remove payroll for an employee
	         with default tax records created and his business group has Vertex
		 or Workers Compensations set as Link to all payrolls.If these links
		 are Open, we will permit the removal of payroll*/

		  if csr_defaultpayrollremoved%FOUND then
		      close csr_defaulting_met;
		      close csr_defaultpayrollremoved;
		      hr_utility.set_message(801,'PAY_75264_US_PAYROLL_REMOVAL');
      		      hr_utility.raise_error;
                  end if;

   		close csr_defaultpayrollremoved;
                close csr_defaulting_met;

		/*Check to make sure we are not removing payroll for which there are
		  assignment actions at future date */

		  open csr_asgmt_details(p_assignment_id,l_effective_date);
		  fetch csr_asgmt_details into l_payroll_id,
		                         l_effective_start_date,l_effective_end_date;
                  close csr_asgmt_details;
		  if p_datetrack_mode='CORRECTION' then

		  hrentmnt.check_payroll_changes_asg
                   (p_assignment_id,l_payroll_id,p_datetrack_mode,
		    l_effective_start_date,l_effective_end_date);

		  elsif p_datetrack_mode='UPDATE' then

		  hrentmnt.check_payroll_changes_asg
                   (p_assignment_id,l_payroll_id,p_datetrack_mode,
		    l_effective_date,l_effective_end_date);

		  end if;
                else
                   close csr_defaulting_met;
		end if;

	end if;

        -- I'm overriding the value of p_location_id if the datetrace mode
        -- is UPDATE_OVERRIDE and the location_id was passed as default value
        -- ie:hr_api.g_number.  Reason for this is we should take the value of
        -- the location_id as of the effective date of the change and we must
        -- maintain the tax records.  The value of
        -- per_us_extra_assignment_rules.g_old_assgt_location  is set in the user
        -- hook (before) procedure to used for stored data.
        --
        if p_datetrack_mode = 'UPDATE_OVERRIDE' THEN
           l_location_id := per_us_extra_assignment_rules.g_old_assgt_location;
        else
           l_location_id := p_location_id;
        end if;
        --
	open csr_get_tax_loc(p_assignment_id,l_effective_date);
	fetch csr_get_tax_loc into l_tax_location_id;
	if csr_get_tax_loc%FOUND then
		open csr_loc_addr(l_tax_location_id);
		fetch csr_loc_addr into l_tax_loc_state_code,l_tax_loc_county_code,
					l_tax_loc_city_code,l_tax_loc_ovrd_state_code,
					l_tax_loc_ovrd_county_code,l_tax_loc_ovrd_city_code;

  		if csr_loc_addr%NOTFOUND then
    			close csr_loc_addr;
			close csr_get_tax_loc;
    			hr_utility.set_message(801, 'PY_51133_TXADJ_INVALID_CITY');
    			hr_utility.raise_error;
  		end if;

		close csr_loc_addr;

		create_tax_rules_for_jd(p_state_code => l_tax_loc_state_code,
					p_county_code => l_tax_loc_county_code,
					p_city_code => l_tax_loc_city_code,
					p_effective_date => l_defaulting_date,
					p_assignment_id => p_assignment_id
					);



		create_tax_rules_for_jd(p_state_code => l_tax_loc_ovrd_state_code,
					p_county_code => l_tax_loc_ovrd_county_code,
					p_city_code => l_tax_loc_ovrd_city_code,
					p_effective_date => l_defaulting_date,
					p_assignment_id => p_assignment_id
					);
	end if; -- csr_get_tax_loc
        close csr_get_tax_loc;

	-- reimp - changed hr_api.g_number to be null, since this code assumes null
	-- to mean the location hasn't changed.

	if l_location_id = hr_api.g_number then
		l_location_id := null;
	end if;

	-- reimp - changed the conditions before move_tax_default_date is called
	-- before it required l_location_id to not be null/hr_api.g_number

        if  l_location_id is not null and
               l_effective_date >= l_defaulting_date then
            --
            hr_utility.set_location(l_proc, 60);
            --
              location_change(
                     p_effective_date            => l_effective_date
                    ,p_datetrack_mode            => p_datetrack_mode
                    ,p_assignment_id             => p_assignment_id
                    ,p_location_id               => l_location_id
                    );

         elsif l_effective_date < l_defaulting_date then
            --
            hr_utility.set_location(l_proc, 70);
            --
            move_tax_default_date(
                     p_effective_date            => l_effective_date
                    ,p_datetrack_mode            => p_datetrack_mode
                    ,p_assignment_id             => p_assignment_id
                    ,p_new_location_id           => l_location_id
                    );
          end if;  -- assignment id is not null, defaulting date found, pull back?
      end if;   -- assignment id is not null, defaulting date found?

    else      -- assignment id is null, so address id must not be null
      --
      hr_utility.set_location(l_proc, 80);
      --
      open csr_adr_id(p_address_id);
      fetch csr_adr_id into l_person_id, l_adr_primary, l_adr_style;
      if csr_adr_id%notfound then
        close csr_adr_id;
        hr_utility.set_message(801,'HR_51396_WEB_PERSON_NOT_FND');
        hr_utility.raise_error;
      --
      -- # 2858888: validate address is US style
      -- Reverting these changes, no longer needed (3406718)
      --else
      -- validate_us_address(l_person_id, l_effective_date
      --                      ,l_adr_primary, l_adr_style);
      end if;
      close csr_adr_id;
      --
      -- This will loop through each assignment for the given person's
      -- address_id
      --
      hr_utility.set_location(l_proc, 85);
      for l_assgn_rec in csr_adr_asg_id(p_address_id) loop
        --
        open csr_defaulting_date(l_assgn_rec.assignment_id);
        fetch csr_defaulting_date into l_defaulting_date;
        close csr_defaulting_date;
        --
        if l_defaulting_date is null then
          --
          hr_utility.set_location(l_proc, 90);
          --
          create_default_tax_rules(
                          p_effective_date            => l_effective_date
                         ,p_assignment_id             => l_assgn_rec.assignment_id
                         ,p_emp_fed_tax_rule_id       => l_fed_tax_rule_id
                         ,p_fed_object_version_number => l_fed_object_version_number
                         ,p_fed_effective_start_date  => l_fed_eff_start_date
                         ,p_fed_effective_end_date    => l_fed_eff_end_date
                         );
          --
        else      -- federal tax rule found for this assignment
          --
          -- address id not null, defaulting date found, hire date null
          --
          hr_utility.set_location(l_proc, 100);
          --
          address_change(
                   p_effective_date            => l_effective_date
                  ,p_assignment_id             => l_assgn_rec.assignment_id
                  );
          --
        end if;  -- address id not null, defaulting date found?
      end loop;  -- loop through each assignment for address_id
    end if;  -- assignment id is not null?
  end if;  -- datetrack mode is ZAP?
  --
  hr_utility.set_location(' Leaving:'||l_proc, 120);
 --
exception
  --
  when l_exit_quietly then
    hr_utility.set_location(' Leaving:'||l_proc, 125);
  --
end maintain_us_employee_taxes;

-- ----------------------------------------------------------------------------
-- |---------------------------< location_change >--------------------------|
-- ----------------------------------------------------------------------------
procedure location_change
    (p_effective_date               In      date
    ,p_datetrack_mode               In      varchar2
    ,p_assignment_id                In      number
    ,p_location_id                  In      number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72) := g_package||'location_change';
  l_effective_date              date;
  l_temp_char                   varchar2(10);
  l_default_flag                varchar2(1) := 'Y';
  l_defaulting_date        pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_fed_tax_end_date       pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_assignment_id               per_assignments_f.assignment_id%TYPE;
  l_business_group_id           per_assignments_f.business_group_id%TYPE;
  l_location_id                 per_assignments_f.location_id%TYPE;
  l_loc_id                      per_assignments_f.location_id%TYPE;
  l_chg_effective_start_date    per_assignments_f.effective_start_date%TYPE;
  l_chg_effective_end_date      per_assignments_f.effective_end_date%TYPE;
  l_sui_state_code		pay_us_states.state_code%TYPE;
  l_loc_state_code              pay_us_states.state_code%TYPE;
  l_loc_ovrd_state_code		pay_us_states.state_code%TYPE;
  l_loc_county_code             pay_us_counties.county_code%TYPE;
  l_loc_ovrd_county_code	pay_us_counties.county_code%TYPE;
  l_loc_city_code               pay_us_city_names.city_code%TYPE;
  l_loc_ovrd_city_code		pay_us_city_names.city_name%TYPE;
  l_jurisdiction_code     pay_us_emp_fed_tax_rules_f.sui_jurisdiction_code%TYPE;
  l_csr_state_code              pay_us_states.state_code%TYPE;
  l_csr_county_code             pay_us_counties.county_code%TYPE;
  l_csr_city_code               pay_us_city_names.city_code%TYPE;

  l_dt_mode                     varchar2(25);
  l_pct_eff_start_date     pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_pct_eff_end_date        pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_city_pct                    number;
  --
  l_fed_rec                     pay_fed_shd.g_rec_type;
  l_fed_rec_dup                 pay_fed_shd.g_rec_type;
  l_sta_rec                     pay_sta_shd.g_rec_type;
  l_sta_rec_dup                 pay_sta_shd.g_rec_type;
  l_cnt_rec                     pay_cnt_shd.g_rec_type;
  l_cnt_rec_dup                 pay_cnt_shd.g_rec_type;
  l_cty_rec                     pay_cty_shd.g_rec_type;
  l_cty_rec_dup                 pay_cty_shd.g_rec_type;
  l_exit_quietly                exception;
  --
  cursor csr_fed_tax_dates is
    select min(effective_start_date), max(effective_end_date)
    from   pay_us_emp_fed_tax_rules_f
    where  assignment_id = p_assignment_id;
  --
  cursor csr_asg_data is
    select asg.location_id, asg.effective_start_date, asg.effective_end_date
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    l_effective_date between asg.effective_start_date
           and asg.effective_end_date;
  --
  cursor csr_chk_location_id is
    select null
    from   hr_locations loc
    where  loc.location_id = p_location_id;
  --
  cursor csr_fed_rec1(l_csr_assignment_id number
                     ,l_csr_start_date date
                     ,l_csr_end_date date) is
     select emp_fed_tax_rule_id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,sui_state_code
           ,sui_jurisdiction_code
           ,business_group_id
           ,additional_wa_amount
           ,filing_status_code
           ,fit_override_amount
           ,fit_override_rate
           ,withholding_allowances
           ,cumulative_taxation
           ,eic_filing_status_code
           ,fit_additional_tax
           ,fit_exempt
           ,futa_tax_exempt
           ,medicare_tax_exempt
           ,ss_tax_exempt
           ,wage_exempt
           ,statutory_employee
           ,w2_filed_year
           ,supp_tax_override_rate
           ,excessive_wa_reject_date
           ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,fed_information_category
           ,fed_information1
           ,fed_information2
           ,fed_information3
           ,fed_information4
           ,fed_information5
           ,fed_information6
           ,fed_information7
           ,fed_information8
           ,fed_information9
           ,fed_information10
           ,fed_information11
           ,fed_information12
           ,fed_information13
           ,fed_information14
           ,fed_information15
           ,fed_information16
           ,fed_information17
           ,fed_information18
           ,fed_information19
           ,fed_information20
           ,fed_information21
           ,fed_information22
           ,fed_information23
           ,fed_information24
           ,fed_information25
           ,fed_information26
           ,fed_information27
           ,fed_information28
           ,fed_information29
           ,fed_information30
     from   pay_us_emp_fed_tax_rules_f
     where  assignment_id = l_csr_assignment_id
     and    effective_end_date >= l_csr_start_date
     and    effective_start_date <= l_csr_end_date;
  --
  cursor csr_fed_rec2(l_csr_assignment_id number
                     ,l_csr_start_date date
                     ,l_csr_end_date date) is
     select emp_fed_tax_rule_id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,sui_state_code
           ,sui_jurisdiction_code
           ,business_group_id
           ,additional_wa_amount
           ,filing_status_code
           ,fit_override_amount
           ,fit_override_rate
           ,withholding_allowances
           ,cumulative_taxation
           ,eic_filing_status_code
           ,fit_additional_tax
           ,fit_exempt
           ,futa_tax_exempt
           ,medicare_tax_exempt
           ,ss_tax_exempt
           ,wage_exempt
           ,statutory_employee
           ,w2_filed_year
           ,supp_tax_override_rate
           ,excessive_wa_reject_date
           ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,fed_information_category
           ,fed_information1
           ,fed_information2
           ,fed_information3
           ,fed_information4
           ,fed_information5
           ,fed_information6
           ,fed_information7
           ,fed_information8
           ,fed_information9
           ,fed_information10
           ,fed_information11
           ,fed_information12
           ,fed_information13
           ,fed_information14
           ,fed_information15
           ,fed_information16
           ,fed_information17
           ,fed_information18
           ,fed_information19
           ,fed_information20
           ,fed_information21
           ,fed_information22
           ,fed_information23
           ,fed_information24
           ,fed_information25
           ,fed_information26
           ,fed_information27
           ,fed_information28
           ,fed_information29
           ,fed_information30
     from   pay_us_emp_fed_tax_rules_f
     where  assignment_id = l_csr_assignment_id
     and    effective_start_date between l_csr_start_date and l_csr_end_date;
  --
  cursor csr_sta_rec1(l_csr_assignment_id number
                     ,l_csr_start_date date
                     ,l_csr_end_date date) is
     select emp_state_tax_rule_id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,state_code
           ,jurisdiction_code
           ,business_group_id
           ,additional_wa_amount
           ,filing_status_code
           ,remainder_percent
           ,secondary_wa
           ,sit_additional_tax
           ,sit_override_amount
           ,sit_override_rate
           ,withholding_allowances
           ,excessive_wa_reject_date
           ,sdi_exempt
           ,sit_exempt
           ,sit_optional_calc_ind
           ,state_non_resident_cert
           ,sui_exempt
           ,wc_exempt
           ,wage_exempt
           ,sui_wage_base_override_amount
           ,supp_tax_override_rate
           ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,sta_information_category
           ,sta_information1
           ,sta_information2
           ,sta_information3
           ,sta_information4
           ,sta_information5
           ,sta_information6
           ,sta_information7
           ,sta_information8
           ,sta_information9
           ,sta_information10
           ,sta_information11
           ,sta_information12
           ,sta_information13
           ,sta_information14
           ,sta_information15
           ,sta_information16
           ,sta_information17
           ,sta_information18
           ,sta_information19
           ,sta_information20
           ,sta_information21
           ,sta_information22
           ,sta_information23
           ,sta_information24
           ,sta_information25
           ,sta_information26
           ,sta_information27
           ,sta_information28
           ,sta_information29
           ,sta_information30
     from   pay_us_emp_state_tax_rules_f
     where  assignment_id = l_csr_assignment_id
     and    effective_end_date >= l_csr_start_date
     and    effective_start_date <= l_csr_end_date;
  --
  cursor csr_cnt_rec1(l_csr_assignment_id number
                     ,l_csr_start_date date
                     ,l_csr_end_date date) is
     select emp_county_tax_rule_id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,state_code
           ,county_code
           ,business_group_id
           ,additional_wa_rate
           ,filing_status_code
           ,jurisdiction_code
           ,lit_additional_tax
           ,lit_override_amount
           ,lit_override_rate
           ,withholding_allowances
           ,lit_exempt
           ,sd_exempt
           ,ht_exempt
           ,wage_exempt
           ,school_district_code
           ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,cnt_information_category
           ,cnt_information1
           ,cnt_information2
           ,cnt_information3
           ,cnt_information4
           ,cnt_information5
           ,cnt_information6
           ,cnt_information7
           ,cnt_information8
           ,cnt_information9
           ,cnt_information10
           ,cnt_information11
           ,cnt_information12
           ,cnt_information13
           ,cnt_information14
           ,cnt_information15
           ,cnt_information16
           ,cnt_information17
           ,cnt_information18
           ,cnt_information19
           ,cnt_information20
           ,cnt_information21
           ,cnt_information22
           ,cnt_information23
           ,cnt_information24
           ,cnt_information25
           ,cnt_information26
           ,cnt_information27
           ,cnt_information28
           ,cnt_information29
           ,cnt_information30
     from   pay_us_emp_county_tax_rules_f
     where  assignment_id = l_csr_assignment_id
     and    effective_end_date >= l_csr_start_date
     and    effective_start_date <= l_csr_end_date;
  --
  cursor csr_cty_rec1(l_csr_assignment_id number
                     ,l_csr_start_date date
                     ,l_csr_end_date date) is
     select emp_city_tax_rule_id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,state_code
           ,county_code
           ,city_code
           ,business_group_id
           ,additional_wa_rate
           ,filing_status_code
           ,jurisdiction_code
           ,lit_additional_tax
           ,lit_override_amount
           ,lit_override_rate
           ,withholding_allowances
           ,lit_exempt
           ,sd_exempt
           ,ht_exempt
           ,wage_exempt
           ,school_district_code
           ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,cty_information_category
           ,cty_information1
           ,cty_information2
           ,cty_information3
           ,cty_information4
           ,cty_information5
           ,cty_information6
           ,cty_information7
           ,cty_information8
           ,cty_information9
           ,cty_information10
           ,cty_information11
           ,cty_information12
           ,cty_information13
           ,cty_information14
           ,cty_information15
           ,cty_information16
           ,cty_information17
           ,cty_information18
           ,cty_information19
           ,cty_information20
           ,cty_information21
           ,cty_information22
           ,cty_information23
           ,cty_information24
           ,cty_information25
           ,cty_information26
           ,cty_information27
           ,cty_information28
           ,cty_information29
           ,cty_information30
     from   pay_us_emp_city_tax_rules_f
     where  assignment_id = l_csr_assignment_id
     and    effective_end_date >= l_csr_start_date
     and    effective_start_date <= l_csr_end_date;
  --
  cursor csr_asg_state_code is
     select sta.state_code
     from   pay_us_emp_state_tax_rules_f sta
     where  sta.assignment_id = p_assignment_id;
  --
  cursor csr_asg_county_code is
     select cnt.state_code, cnt.county_code
     from   pay_us_emp_county_tax_rules_f cnt
     where  cnt.assignment_id = p_assignment_id;
  --
  cursor csr_asg_city_code is
     select cty.state_code, cty.county_code, cty.city_code
     from   pay_us_emp_city_tax_rules_f cty
     where  cty.assignment_id = p_assignment_id;
  --
  cursor csr_fed_rule_exists(l_csr_tmp_date in date) is
     select null
     from   pay_us_emp_fed_tax_rules_f fed
     where  fed.assignment_id = p_assignment_id
     and    fed.effective_start_date = l_csr_tmp_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  if p_assignment_id is null then
    hr_utility.set_message(801, 'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  end if;
  --
  if p_datetrack_mode in('CORRECTION', 'UPDATE', 'UPDATE_CHANGE_INSERT',
                         'UPDATE_OVERRIDE') and p_location_id is null then
    hr_utility.set_message(801, 'HR_7880_PDT_VALUE_NOT_FOUND');
    hr_utility.raise_error;
  end if;
  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- First check if geocode has been installed or not. If no geocodes
  -- installed then return because there is nothing to be done by this
  -- defaulting procedure
  if hr_general.chk_maintain_tax_records = 'N' then
     return;
  end if;
  --
  -- Validate p_assignment_id and p_location_id
  --
  open  csr_asg_data;
  fetch csr_asg_data into l_loc_id,
                          l_chg_effective_start_date,
                          l_chg_effective_end_date;
  if csr_asg_data%notfound then
    close csr_asg_data;
    hr_utility.set_message(801, 'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  end if;
  close csr_asg_data;
  --
  -- Ensure that the new location id is different from the current location id
  --
  -- bug 924139  comment the following if statement as it is comparing the
  -- new location record to itself.  Hense tax records are not being updated
  -- when we change the location on the assignment record and the location
  -- address resided in a different state.
  --
  -- bug 1168727  comparing the p_location_id to global
  -- per_us_extra_assignment_rules.g_old_assgt_location.  If the old location
  -- id is same as the parameter location id then there is no need to update
  -- the tax records.  PLEASE NOTE THAT THE GLOBAL IS DEFINE IN PACKAGE
  -- per_us_extra_assignment_rules AND SET IN PROCEDURE get_curr_ass_location_id.
  --
  -- We will always attempt to process the location change is the date track
  -- mode is UPDATE_OVERRIDE.
  --
  if p_datetrack_mode in ('CORRECTION', 'UPDATE',
                         'UPDATE_CHANGE_INSERT' ) and
    p_location_id = per_us_extra_assignment_rules.g_old_assgt_location then
    RAISE l_exit_quietly;
  end if;
  --
  if p_datetrack_mode in('CORRECTION', 'UPDATE',
                         'UPDATE_CHANGE_INSERT' ) then
    open  csr_chk_location_id;
    fetch csr_chk_location_id into l_temp_char;
    if csr_chk_location_id%notfound then
      close csr_chk_location_id;
      hr_utility.set_message(801, 'HR_7880_PDT_VALUE_NOT_FOUND');
      hr_utility.raise_error;
    end if;
    close csr_chk_location_id;
    l_location_id := p_location_id;
  else
    l_location_id := l_loc_id;
  end if;
  --
  -- Get overall start and end dates of the federal tax rule
  --
  open  csr_fed_tax_dates;
  fetch csr_fed_tax_dates into l_defaulting_date, l_fed_tax_end_date;
  close csr_fed_tax_dates;
  if l_chg_effective_start_date < l_defaulting_date then
    hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
    hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
    hr_utility.set_message_token('SESSION_DATE', l_chg_effective_start_date);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Select state, county and city codes for the new work location of the
  -- assignment.
  --
  open csr_loc_addr(l_location_id);
  fetch csr_loc_addr into l_loc_state_code, l_loc_county_code, l_loc_city_code,
			  l_loc_ovrd_state_code,l_loc_ovrd_county_code,l_loc_ovrd_city_code;
  if csr_loc_addr%NOTFOUND then
    close csr_loc_addr;
    hr_utility.set_message(801, 'PY_51133_TXADJ_INVALID_CITY');
    hr_utility.raise_error;
  end if;
  close csr_loc_addr;

  -- since l_loc_ovrd_state_code defaults to the loc_state_code, we
  -- use it to set the sui
  l_sui_state_code := l_loc_ovrd_state_code;

  --
  hr_utility.set_location(l_proc, 40);
  --
  --
  --  Branch according to p_datetrack_mode here
  --
  if p_datetrack_mode = 'CORRECTION' then
    --
    hr_utility.set_location(l_proc, 50);
    --
    -- Select the federal tax record as of the assignment end date.
    --
    open csr_fed_rec1(p_assignment_id, l_chg_effective_end_date,
                          l_chg_effective_end_date);
    fetch csr_fed_rec1 into l_fed_rec;
    if csr_fed_rec1%notfound then
      -- No federal tax rule exists as of the end of the assignment record!
      close csr_fed_rec1;
      hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
      hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
      hr_utility.set_message_token('SESSION_DATE', l_chg_effective_end_date);
      hr_utility.raise_error;
    end if;
    close csr_fed_rec1;
    --
    -- If the assignment effective end date does not match the federal tax rule
    -- effective end date, update the federal record to create a federal row
    -- with the same effective end date as the assignment.  Do the same for the
    -- workers comp entry.
    --
    if l_fed_rec.effective_end_date > l_chg_effective_end_date then
      open csr_fed_rule_exists(l_fed_rec.effective_end_date + 1);
      fetch csr_fed_rule_exists into l_temp_char;
      if csr_fed_rule_exists%notfound then
        l_dt_mode := 'UPDATE';
      else
        l_dt_mode := 'UPDATE_CHANGE_INSERT';
      end if;
      close csr_fed_rule_exists;
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_end_date + 1, l_dt_mode);
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_end_date + 1
                  ,p_datetrack_mode       => l_dt_mode
                  );
    end if;
    --
    -- Select the federal record as of the assignment start date.
    --
    open csr_fed_rec1(p_assignment_id, l_chg_effective_start_date,
                      l_chg_effective_start_date);
    fetch csr_fed_rec1 into l_fed_rec;
    if csr_fed_rec1%notfound then
      -- No federal tax rule exists as of the start of the assignment record!
      close csr_fed_rec1;
      hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
      hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
      hr_utility.set_message_token('SESSION_DATE', l_chg_effective_start_date);
      hr_utility.raise_error;
    end if;
    close csr_fed_rec1;
    --
    -- Set new sui location in the record structure.
    --
      l_fed_rec.sui_state_code := l_sui_state_code;
      l_fed_rec.sui_jurisdiction_code := l_sui_state_code || '-000-0000';
    --
    -- If the start dates do not match, update the federal record to create a
    -- row with the same start date as the assignment.  If they do match,
    -- correct the federal record.  Do the same for the workers comp entry.
    --
    if l_fed_rec.effective_start_date = l_chg_effective_start_date then
      --
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, 'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
      --
    elsif l_fed_rec.effective_start_date < l_chg_effective_start_date then
      open csr_fed_rule_exists(l_fed_rec.effective_end_date + 1);
      fetch csr_fed_rule_exists into l_temp_char;
      if csr_fed_rule_exists%notfound then
        l_dt_mode := 'UPDATE';
      else
        l_dt_mode := 'UPDATE_CHANGE_INSERT';
      end if;
      close csr_fed_rule_exists;
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, l_dt_mode);
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => l_dt_mode
                  );
    end if;
    --
    -- Correct sui_state and sui_jurisdiction for each federal record that
    -- exists at all between the start date + 1 and the end date of the
    -- assignment
    --
    for l_fed_rec in csr_fed_rec2(p_assignment_id, l_chg_effective_start_date+1,
                                  l_chg_effective_end_date)
    loop

/* changes for bug 1970341 possible a DB issue. */
--      l_fed_rec_dup := l_fed_rec;

      l_fed_rec_dup.emp_fed_tax_rule_id       := l_fed_rec.emp_fed_tax_rule_id;
      l_fed_rec_dup.effective_start_date      := l_fed_rec.effective_start_date;
      l_fed_rec_dup.effective_end_date        := l_fed_rec.effective_end_date;
      l_fed_rec_dup.assignment_id             := l_fed_rec.assignment_id;
      l_fed_rec_dup.sui_state_code            := l_fed_rec.sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code     := l_fed_rec.sui_jurisdiction_code;
      l_fed_rec_dup.business_group_id         := l_fed_rec.business_group_id;
      l_fed_rec_dup.additional_wa_amount      := l_fed_rec.additional_wa_amount;
      l_fed_rec_dup.filing_status_code        := l_fed_rec.filing_status_code;
      l_fed_rec_dup.fit_override_amount       := l_fed_rec.fit_override_amount;
      l_fed_rec_dup.fit_override_rate         := l_fed_rec.fit_override_rate;
      l_fed_rec_dup.withholding_allowances    := l_fed_rec.withholding_allowances;
      l_fed_rec_dup.cumulative_taxation       := l_fed_rec.cumulative_taxation;
      l_fed_rec_dup.eic_filing_status_code    := l_fed_rec.eic_filing_status_code;
      l_fed_rec_dup.fit_additional_tax        := l_fed_rec.fit_additional_tax;
      l_fed_rec_dup.fit_exempt                := l_fed_rec.fit_exempt;
      l_fed_rec_dup.futa_tax_exempt           := l_fed_rec.futa_tax_exempt;
      l_fed_rec_dup.medicare_tax_exempt       := l_fed_rec.medicare_tax_exempt;
      l_fed_rec_dup.ss_tax_exempt             := l_fed_rec.ss_tax_exempt;
      l_fed_rec_dup.wage_exempt               := l_fed_rec.wage_exempt;
      l_fed_rec_dup.statutory_employee        := l_fed_rec.statutory_employee;
      l_fed_rec_dup.w2_filed_year             := l_fed_rec.w2_filed_year;
      l_fed_rec_dup.supp_tax_override_rate    := l_fed_rec.supp_tax_override_rate;
      l_fed_rec_dup.excessive_wa_reject_date  := l_fed_rec.excessive_wa_reject_date;
      l_fed_rec_dup.object_version_number     := l_fed_rec.object_version_number;
      l_fed_rec_dup.attribute_category        := l_fed_rec.attribute_category;
      l_fed_rec_dup.attribute1                := l_fed_rec.attribute1;
      l_fed_rec_dup.attribute2                := l_fed_rec.attribute2;
      l_fed_rec_dup.attribute3                := l_fed_rec.attribute3;
      l_fed_rec_dup.attribute4                := l_fed_rec.attribute4;
      l_fed_rec_dup.attribute5                := l_fed_rec.attribute5;
      l_fed_rec_dup.attribute6                := l_fed_rec.attribute6;
      l_fed_rec_dup.attribute7                := l_fed_rec.attribute7;
      l_fed_rec_dup.attribute8                := l_fed_rec.attribute8;
      l_fed_rec_dup.attribute9                := l_fed_rec.attribute9;
      l_fed_rec_dup.attribute10               := l_fed_rec.attribute10;
      l_fed_rec_dup.attribute11               := l_fed_rec.attribute11;
      l_fed_rec_dup.attribute12               := l_fed_rec.attribute12;
      l_fed_rec_dup.attribute13               := l_fed_rec.attribute13;
      l_fed_rec_dup.attribute14               := l_fed_rec.attribute14;
      l_fed_rec_dup.attribute15               := l_fed_rec.attribute15;
      l_fed_rec_dup.attribute16               := l_fed_rec.attribute16;
      l_fed_rec_dup.attribute17               := l_fed_rec.attribute17;
      l_fed_rec_dup.attribute18               := l_fed_rec.attribute18;
      l_fed_rec_dup.attribute19               := l_fed_rec.attribute19;
      l_fed_rec_dup.attribute20               := l_fed_rec.attribute20;
      l_fed_rec_dup.attribute21               := l_fed_rec.attribute21;
      l_fed_rec_dup.attribute22               := l_fed_rec.attribute22;
      l_fed_rec_dup.attribute23               := l_fed_rec.attribute23;
      l_fed_rec_dup.attribute24               := l_fed_rec.attribute24;
      l_fed_rec_dup.attribute25               := l_fed_rec.attribute25;
      l_fed_rec_dup.attribute26               := l_fed_rec.attribute26;
      l_fed_rec_dup.attribute27               := l_fed_rec.attribute27;
      l_fed_rec_dup.attribute28               := l_fed_rec.attribute28;
      l_fed_rec_dup.attribute29               := l_fed_rec.attribute29;
      l_fed_rec_dup.attribute30               := l_fed_rec.attribute30;
      l_fed_rec_dup.fed_information_category  := l_fed_rec.fed_information_category;
      l_fed_rec_dup.fed_information1          := l_fed_rec.fed_information1;
      l_fed_rec_dup.fed_information2          := l_fed_rec.fed_information2;
      l_fed_rec_dup.fed_information3          := l_fed_rec.fed_information3;
      l_fed_rec_dup.fed_information4          := l_fed_rec.fed_information4;
      l_fed_rec_dup.fed_information5          := l_fed_rec.fed_information5;
      l_fed_rec_dup.fed_information6          := l_fed_rec.fed_information6;
      l_fed_rec_dup.fed_information7          := l_fed_rec.fed_information7;
      l_fed_rec_dup.fed_information8          := l_fed_rec.fed_information8;
      l_fed_rec_dup.fed_information9          := l_fed_rec.fed_information9;
      l_fed_rec_dup.fed_information10         := l_fed_rec.fed_information10;
      l_fed_rec_dup.fed_information11         := l_fed_rec.fed_information11;
      l_fed_rec_dup.fed_information12         := l_fed_rec.fed_information12;
      l_fed_rec_dup.fed_information13         := l_fed_rec.fed_information13;
      l_fed_rec_dup.fed_information14         := l_fed_rec.fed_information14;
      l_fed_rec_dup.fed_information15         := l_fed_rec.fed_information15;
      l_fed_rec_dup.fed_information16         := l_fed_rec.fed_information16;
      l_fed_rec_dup.fed_information17         := l_fed_rec.fed_information17;
      l_fed_rec_dup.fed_information18         := l_fed_rec.fed_information18;
      l_fed_rec_dup.fed_information19         := l_fed_rec.fed_information19;
      l_fed_rec_dup.fed_information20         := l_fed_rec.fed_information20;
      l_fed_rec_dup.fed_information21         := l_fed_rec.fed_information21;
      l_fed_rec_dup.fed_information22         := l_fed_rec.fed_information22;
      l_fed_rec_dup.fed_information23         := l_fed_rec.fed_information23;
      l_fed_rec_dup.fed_information24         := l_fed_rec.fed_information24;
      l_fed_rec_dup.fed_information25         := l_fed_rec.fed_information25;
      l_fed_rec_dup.fed_information26         := l_fed_rec.fed_information26;
      l_fed_rec_dup.fed_information27         := l_fed_rec.fed_information27;
      l_fed_rec_dup.fed_information28         := l_fed_rec.fed_information28;
      l_fed_rec_dup.fed_information29         := l_fed_rec.fed_information29;
      l_fed_rec_dup.fed_information30         := l_fed_rec.fed_information30;
/* changes for bug 1970341 possible a DB issue. */

      l_fed_rec_dup.sui_state_code            := l_sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code     := l_sui_state_code || '-000-0000';

      pay_fed_upd.upd(l_fed_rec_dup, l_fed_rec_dup.effective_start_date,
                      'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
    end loop;
    --


  elsif p_datetrack_mode = 'UPDATE' then
    --
    hr_utility.set_location(l_proc, 60);
    --
    -- Select the federal record as of the assignment start date.
    --
    open csr_fed_rec1(p_assignment_id, l_chg_effective_start_date,
                      l_chg_effective_start_date);
    fetch csr_fed_rec1 into l_fed_rec;
    if csr_fed_rec1%notfound then
      -- No federal tax rule exists as of the start of the assignment record!
      close csr_fed_rec1;
      hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
      hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
      hr_utility.set_message_token('SESSION_DATE', l_chg_effective_start_date);
      hr_utility.raise_error;
    end if;
    close csr_fed_rec1;
    --
    -- Set new sui location in the record structure.
    --
      l_fed_rec.sui_state_code := l_sui_state_code;
      l_fed_rec.sui_jurisdiction_code := l_sui_state_code || '-000-0000';
    --
    -- If the start dates do not match, update the federal record to create a
    -- row with the same start date as the assignment.  If they do match,
    -- correct the federal record.  Do the same for the workers comp entry.
    --
    if l_fed_rec.effective_start_date = l_chg_effective_start_date then
      --
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, 'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
      --
    elsif l_fed_rec.effective_start_date < l_chg_effective_start_date then
      open csr_fed_rule_exists(l_fed_rec.effective_end_date + 1);
      fetch csr_fed_rule_exists into l_temp_char;
      if csr_fed_rule_exists%notfound then
        l_dt_mode := 'UPDATE';
      else
        l_dt_mode := 'UPDATE_CHANGE_INSERT';
      end if;
      close csr_fed_rule_exists;
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, l_dt_mode);
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => l_dt_mode
                  );
    end if;
    --
    -- Correct sui_state and sui_jurisdiction for each federal record that
    -- exists at all between the start and end dates of the assignment. Correct
    -- the workers comp entry.
    --
    for l_fed_rec in csr_fed_rec2(p_assignment_id, l_chg_effective_start_date+1,
                                  l_chg_effective_end_date)
    loop

/* changes for bug 1970341 possible a DB issue. */
--      l_fed_rec_dup := l_fed_rec;

      l_fed_rec_dup.emp_fed_tax_rule_id       := l_fed_rec.emp_fed_tax_rule_id;
      l_fed_rec_dup.effective_start_date      := l_fed_rec.effective_start_date;
      l_fed_rec_dup.effective_end_date        := l_fed_rec.effective_end_date;
      l_fed_rec_dup.assignment_id             := l_fed_rec.assignment_id;
      l_fed_rec_dup.sui_state_code            := l_fed_rec.sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code     := l_fed_rec.sui_jurisdiction_code;
      l_fed_rec_dup.business_group_id         := l_fed_rec.business_group_id;
      l_fed_rec_dup.additional_wa_amount      := l_fed_rec.additional_wa_amount;
      l_fed_rec_dup.filing_status_code        := l_fed_rec.filing_status_code;
      l_fed_rec_dup.fit_override_amount       := l_fed_rec.fit_override_amount;
      l_fed_rec_dup.fit_override_rate         := l_fed_rec.fit_override_rate;
      l_fed_rec_dup.withholding_allowances    := l_fed_rec.withholding_allowances;
      l_fed_rec_dup.cumulative_taxation       := l_fed_rec.cumulative_taxation;
      l_fed_rec_dup.eic_filing_status_code    := l_fed_rec.eic_filing_status_code;
      l_fed_rec_dup.fit_additional_tax        := l_fed_rec.fit_additional_tax;
      l_fed_rec_dup.fit_exempt                := l_fed_rec.fit_exempt;
      l_fed_rec_dup.futa_tax_exempt           := l_fed_rec.futa_tax_exempt;
      l_fed_rec_dup.medicare_tax_exempt       := l_fed_rec.medicare_tax_exempt;
      l_fed_rec_dup.ss_tax_exempt             := l_fed_rec.ss_tax_exempt;
      l_fed_rec_dup.wage_exempt               := l_fed_rec.wage_exempt;
      l_fed_rec_dup.statutory_employee        := l_fed_rec.statutory_employee;
      l_fed_rec_dup.w2_filed_year             := l_fed_rec.w2_filed_year;
      l_fed_rec_dup.supp_tax_override_rate    := l_fed_rec.supp_tax_override_rate;
      l_fed_rec_dup.excessive_wa_reject_date  := l_fed_rec.excessive_wa_reject_date;
      l_fed_rec_dup.object_version_number     := l_fed_rec.object_version_number;
      l_fed_rec_dup.attribute_category        := l_fed_rec.attribute_category;
      l_fed_rec_dup.attribute1                := l_fed_rec.attribute1;
      l_fed_rec_dup.attribute2                := l_fed_rec.attribute2;
      l_fed_rec_dup.attribute3                := l_fed_rec.attribute3;
      l_fed_rec_dup.attribute4                := l_fed_rec.attribute4;
      l_fed_rec_dup.attribute5                := l_fed_rec.attribute5;
      l_fed_rec_dup.attribute6                := l_fed_rec.attribute6;
      l_fed_rec_dup.attribute7                := l_fed_rec.attribute7;
      l_fed_rec_dup.attribute8                := l_fed_rec.attribute8;
      l_fed_rec_dup.attribute9                := l_fed_rec.attribute9;
      l_fed_rec_dup.attribute10               := l_fed_rec.attribute10;
      l_fed_rec_dup.attribute11               := l_fed_rec.attribute11;
      l_fed_rec_dup.attribute12               := l_fed_rec.attribute12;
      l_fed_rec_dup.attribute13               := l_fed_rec.attribute13;
      l_fed_rec_dup.attribute14               := l_fed_rec.attribute14;
      l_fed_rec_dup.attribute15               := l_fed_rec.attribute15;
      l_fed_rec_dup.attribute16               := l_fed_rec.attribute16;
      l_fed_rec_dup.attribute17               := l_fed_rec.attribute17;
      l_fed_rec_dup.attribute18               := l_fed_rec.attribute18;
      l_fed_rec_dup.attribute19               := l_fed_rec.attribute19;
      l_fed_rec_dup.attribute20               := l_fed_rec.attribute20;
      l_fed_rec_dup.attribute21               := l_fed_rec.attribute21;
      l_fed_rec_dup.attribute22               := l_fed_rec.attribute22;
      l_fed_rec_dup.attribute23               := l_fed_rec.attribute23;
      l_fed_rec_dup.attribute24               := l_fed_rec.attribute24;
      l_fed_rec_dup.attribute25               := l_fed_rec.attribute25;
      l_fed_rec_dup.attribute26               := l_fed_rec.attribute26;
      l_fed_rec_dup.attribute27               := l_fed_rec.attribute27;
      l_fed_rec_dup.attribute28               := l_fed_rec.attribute28;
      l_fed_rec_dup.attribute29               := l_fed_rec.attribute29;
      l_fed_rec_dup.attribute30               := l_fed_rec.attribute30;
      l_fed_rec_dup.fed_information_category  := l_fed_rec.fed_information_category;
      l_fed_rec_dup.fed_information1          := l_fed_rec.fed_information1;
      l_fed_rec_dup.fed_information2          := l_fed_rec.fed_information2;
      l_fed_rec_dup.fed_information3          := l_fed_rec.fed_information3;
      l_fed_rec_dup.fed_information4          := l_fed_rec.fed_information4;
      l_fed_rec_dup.fed_information5          := l_fed_rec.fed_information5;
      l_fed_rec_dup.fed_information6          := l_fed_rec.fed_information6;
      l_fed_rec_dup.fed_information7          := l_fed_rec.fed_information7;
      l_fed_rec_dup.fed_information8          := l_fed_rec.fed_information8;
      l_fed_rec_dup.fed_information9          := l_fed_rec.fed_information9;
      l_fed_rec_dup.fed_information10         := l_fed_rec.fed_information10;
      l_fed_rec_dup.fed_information11         := l_fed_rec.fed_information11;
      l_fed_rec_dup.fed_information12         := l_fed_rec.fed_information12;
      l_fed_rec_dup.fed_information13         := l_fed_rec.fed_information13;
      l_fed_rec_dup.fed_information14         := l_fed_rec.fed_information14;
      l_fed_rec_dup.fed_information15         := l_fed_rec.fed_information15;
      l_fed_rec_dup.fed_information16         := l_fed_rec.fed_information16;
      l_fed_rec_dup.fed_information17         := l_fed_rec.fed_information17;
      l_fed_rec_dup.fed_information18         := l_fed_rec.fed_information18;
      l_fed_rec_dup.fed_information19         := l_fed_rec.fed_information19;
      l_fed_rec_dup.fed_information20         := l_fed_rec.fed_information20;
      l_fed_rec_dup.fed_information21         := l_fed_rec.fed_information21;
      l_fed_rec_dup.fed_information22         := l_fed_rec.fed_information22;
      l_fed_rec_dup.fed_information23         := l_fed_rec.fed_information23;
      l_fed_rec_dup.fed_information24         := l_fed_rec.fed_information24;
      l_fed_rec_dup.fed_information25         := l_fed_rec.fed_information25;
      l_fed_rec_dup.fed_information26         := l_fed_rec.fed_information26;
      l_fed_rec_dup.fed_information27         := l_fed_rec.fed_information27;
      l_fed_rec_dup.fed_information28         := l_fed_rec.fed_information28;
      l_fed_rec_dup.fed_information29         := l_fed_rec.fed_information29;
      l_fed_rec_dup.fed_information30         := l_fed_rec.fed_information30;

/* changes for bug 1970341 possible a DB issue. */

      l_fed_rec_dup.sui_state_code := l_sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code := l_sui_state_code || '-000-0000';
      pay_fed_upd.upd(l_fed_rec_dup, l_fed_rec_dup.effective_start_date,
                      'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
    end loop;


  elsif p_datetrack_mode = 'UPDATE_CHANGE_INSERT' then
    --
    hr_utility.set_location(l_proc, 70);
    --
    -- Select the federal tax record as of the assignment end date.
    --
    open csr_fed_rec1(p_assignment_id, l_chg_effective_end_date,
                      l_chg_effective_end_date);
      fetch csr_fed_rec1 into l_fed_rec;
    if csr_fed_rec1%notfound then
      -- No federal tax rule exists as of the end of the assignment record!
      close csr_fed_rec1;
      hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
      hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
      hr_utility.set_message_token('SESSION_DATE', l_chg_effective_end_date);
      hr_utility.raise_error;
    end if;
    close csr_fed_rec1;
    --
    -- If the assignment effective end date does not match the federal tax rule
    -- effective end date, update the federal record to create a federal row
    -- with the same effective end date as the assignment.  Do the same for the
    -- workers comp entry.
    --
    if l_fed_rec.effective_end_date > l_chg_effective_end_date then
      open csr_fed_rule_exists(l_fed_rec.effective_end_date + 1);
      fetch csr_fed_rule_exists into l_temp_char;
      if csr_fed_rule_exists%notfound then
        l_dt_mode := 'UPDATE';
      else
        l_dt_mode := 'UPDATE_CHANGE_INSERT';
      end if;
      close csr_fed_rule_exists;
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_end_date + 1, l_dt_mode);
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_end_date + 1
                  ,p_datetrack_mode       => l_dt_mode
                  );
    end if;
    --
    -- Select the federal record as of the assignment start date.
    --
    open csr_fed_rec1(p_assignment_id, l_chg_effective_start_date,
                      l_chg_effective_start_date);
    fetch csr_fed_rec1 into l_fed_rec;
    if csr_fed_rec1%notfound then
      -- No federal tax rule exists as of the start of the assignment record!
      close csr_fed_rec1;
      hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
      hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
      hr_utility.set_message_token('SESSION_DATE', l_chg_effective_start_date);
      hr_utility.raise_error;
    end if;
    close csr_fed_rec1;
    --
    -- Set new sui location in the record structure.
    --
      l_fed_rec.sui_state_code := l_sui_state_code;
      l_fed_rec.sui_jurisdiction_code := l_sui_state_code || '-000-0000';
    --
    -- If the start dates do not match, update the federal record to create a
    -- row with the same start date as the assignment.  If they do match,
    -- correct the federal record.  Do the same for the workers comp entry.
    --
    if l_fed_rec.effective_start_date = l_chg_effective_start_date then
      --
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, 'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
      --
    elsif l_fed_rec.effective_start_date < l_chg_effective_start_date then
      open csr_fed_rule_exists(l_fed_rec.effective_end_date + 1);
      fetch csr_fed_rule_exists into l_temp_char;
      if csr_fed_rule_exists%notfound then
        l_dt_mode := 'UPDATE';
      else
        l_dt_mode := 'UPDATE_CHANGE_INSERT';
      end if;
      close csr_fed_rule_exists;
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, l_dt_mode);
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => l_dt_mode
                  );
    end if;
    --
    -- Correct sui_state and sui_jurisdiction for each federal record that

    -- exists at all between the start date + 1 and the end date of the
    -- assignment.  Do the same for the workers comp entry.
    --
    for l_fed_rec in csr_fed_rec2(p_assignment_id, l_chg_effective_start_date+1,
                                  l_chg_effective_end_date)
    loop

/* changes for bug 1970341 possible a DB issue. */
--      l_fed_rec_dup := l_fed_rec;

      l_fed_rec_dup.emp_fed_tax_rule_id       := l_fed_rec.emp_fed_tax_rule_id;
      l_fed_rec_dup.effective_start_date      := l_fed_rec.effective_start_date;
      l_fed_rec_dup.effective_end_date        := l_fed_rec.effective_end_date;
      l_fed_rec_dup.assignment_id             := l_fed_rec.assignment_id;
      l_fed_rec_dup.sui_state_code            := l_fed_rec.sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code     := l_fed_rec.sui_jurisdiction_code;
      l_fed_rec_dup.business_group_id         := l_fed_rec.business_group_id;
      l_fed_rec_dup.additional_wa_amount      := l_fed_rec.additional_wa_amount;
      l_fed_rec_dup.filing_status_code        := l_fed_rec.filing_status_code;
      l_fed_rec_dup.fit_override_amount       := l_fed_rec.fit_override_amount;
      l_fed_rec_dup.fit_override_rate         := l_fed_rec.fit_override_rate;
      l_fed_rec_dup.withholding_allowances    := l_fed_rec.withholding_allowances;
      l_fed_rec_dup.cumulative_taxation       := l_fed_rec.cumulative_taxation;
      l_fed_rec_dup.eic_filing_status_code    := l_fed_rec.eic_filing_status_code;
      l_fed_rec_dup.fit_additional_tax        := l_fed_rec.fit_additional_tax;
      l_fed_rec_dup.fit_exempt                := l_fed_rec.fit_exempt;
      l_fed_rec_dup.futa_tax_exempt           := l_fed_rec.futa_tax_exempt;
      l_fed_rec_dup.medicare_tax_exempt       := l_fed_rec.medicare_tax_exempt;
      l_fed_rec_dup.ss_tax_exempt             := l_fed_rec.ss_tax_exempt;
      l_fed_rec_dup.wage_exempt               := l_fed_rec.wage_exempt;
      l_fed_rec_dup.statutory_employee        := l_fed_rec.statutory_employee;
      l_fed_rec_dup.w2_filed_year             := l_fed_rec.w2_filed_year;
      l_fed_rec_dup.supp_tax_override_rate    := l_fed_rec.supp_tax_override_rate;
      l_fed_rec_dup.excessive_wa_reject_date  := l_fed_rec.excessive_wa_reject_date;
      l_fed_rec_dup.object_version_number     := l_fed_rec.object_version_number;
      l_fed_rec_dup.attribute_category        := l_fed_rec.attribute_category;
      l_fed_rec_dup.attribute1                := l_fed_rec.attribute1;
      l_fed_rec_dup.attribute2                := l_fed_rec.attribute2;
      l_fed_rec_dup.attribute3                := l_fed_rec.attribute3;
      l_fed_rec_dup.attribute4                := l_fed_rec.attribute4;
      l_fed_rec_dup.attribute5                := l_fed_rec.attribute5;
      l_fed_rec_dup.attribute6                := l_fed_rec.attribute6;
      l_fed_rec_dup.attribute7                := l_fed_rec.attribute7;
      l_fed_rec_dup.attribute8                := l_fed_rec.attribute8;
      l_fed_rec_dup.attribute9                := l_fed_rec.attribute9;
      l_fed_rec_dup.attribute10               := l_fed_rec.attribute10;
      l_fed_rec_dup.attribute11               := l_fed_rec.attribute11;
      l_fed_rec_dup.attribute12               := l_fed_rec.attribute12;
      l_fed_rec_dup.attribute13               := l_fed_rec.attribute13;
      l_fed_rec_dup.attribute14               := l_fed_rec.attribute14;
      l_fed_rec_dup.attribute15               := l_fed_rec.attribute15;
      l_fed_rec_dup.attribute16               := l_fed_rec.attribute16;
      l_fed_rec_dup.attribute17               := l_fed_rec.attribute17;
      l_fed_rec_dup.attribute18               := l_fed_rec.attribute18;
      l_fed_rec_dup.attribute19               := l_fed_rec.attribute19;
      l_fed_rec_dup.attribute20               := l_fed_rec.attribute20;
      l_fed_rec_dup.attribute21               := l_fed_rec.attribute21;
      l_fed_rec_dup.attribute22               := l_fed_rec.attribute22;
      l_fed_rec_dup.attribute23               := l_fed_rec.attribute23;
      l_fed_rec_dup.attribute24               := l_fed_rec.attribute24;
      l_fed_rec_dup.attribute25               := l_fed_rec.attribute25;
      l_fed_rec_dup.attribute26               := l_fed_rec.attribute26;
      l_fed_rec_dup.attribute27               := l_fed_rec.attribute27;
      l_fed_rec_dup.attribute28               := l_fed_rec.attribute28;
      l_fed_rec_dup.attribute29               := l_fed_rec.attribute29;
      l_fed_rec_dup.attribute30               := l_fed_rec.attribute30;
      l_fed_rec_dup.fed_information_category  := l_fed_rec.fed_information_category;
      l_fed_rec_dup.fed_information1          := l_fed_rec.fed_information1;
      l_fed_rec_dup.fed_information2          := l_fed_rec.fed_information2;
      l_fed_rec_dup.fed_information3          := l_fed_rec.fed_information3;
      l_fed_rec_dup.fed_information4          := l_fed_rec.fed_information4;
      l_fed_rec_dup.fed_information5          := l_fed_rec.fed_information5;
      l_fed_rec_dup.fed_information6          := l_fed_rec.fed_information6;
      l_fed_rec_dup.fed_information7          := l_fed_rec.fed_information7;
      l_fed_rec_dup.fed_information8          := l_fed_rec.fed_information8;
      l_fed_rec_dup.fed_information9          := l_fed_rec.fed_information9;
      l_fed_rec_dup.fed_information10         := l_fed_rec.fed_information10;
      l_fed_rec_dup.fed_information11         := l_fed_rec.fed_information11;
      l_fed_rec_dup.fed_information12         := l_fed_rec.fed_information12;
      l_fed_rec_dup.fed_information13         := l_fed_rec.fed_information13;
      l_fed_rec_dup.fed_information14         := l_fed_rec.fed_information14;
      l_fed_rec_dup.fed_information15         := l_fed_rec.fed_information15;
      l_fed_rec_dup.fed_information16         := l_fed_rec.fed_information16;
      l_fed_rec_dup.fed_information17         := l_fed_rec.fed_information17;
      l_fed_rec_dup.fed_information18         := l_fed_rec.fed_information18;
      l_fed_rec_dup.fed_information19         := l_fed_rec.fed_information19;
      l_fed_rec_dup.fed_information20         := l_fed_rec.fed_information20;
      l_fed_rec_dup.fed_information21         := l_fed_rec.fed_information21;
      l_fed_rec_dup.fed_information22         := l_fed_rec.fed_information22;
      l_fed_rec_dup.fed_information23         := l_fed_rec.fed_information23;
      l_fed_rec_dup.fed_information24         := l_fed_rec.fed_information24;
      l_fed_rec_dup.fed_information25         := l_fed_rec.fed_information25;
      l_fed_rec_dup.fed_information26         := l_fed_rec.fed_information26;
      l_fed_rec_dup.fed_information27         := l_fed_rec.fed_information27;
      l_fed_rec_dup.fed_information28         := l_fed_rec.fed_information28;
      l_fed_rec_dup.fed_information29         := l_fed_rec.fed_information29;
      l_fed_rec_dup.fed_information30         := l_fed_rec.fed_information30;

/* changes for bug 1970341 possible a DB issue. */

      l_fed_rec_dup.sui_state_code := l_sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code := l_sui_state_code || '-000-0000';
      pay_fed_upd.upd(l_fed_rec_dup, l_fed_rec_dup.effective_start_date,
                      'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
    end loop;


  elsif p_datetrack_mode = 'UPDATE_OVERRIDE' then
    --
    hr_utility.set_location(l_proc, 80);
    --
    -- Select the federal record as of the assignment start date.
    --
    open csr_fed_rec1(p_assignment_id, l_chg_effective_start_date,
                      l_chg_effective_start_date);
    fetch csr_fed_rec1 into l_fed_rec;
    if csr_fed_rec1%notfound then
      -- No federal tax rule exists as of the start of the assignment record!
      close csr_fed_rec1;
      hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
      hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
      hr_utility.set_message_token('SESSION_DATE', l_chg_effective_start_date);
      hr_utility.raise_error;
    end if;
    close csr_fed_rec1;
    --
    -- Set new sui location in the record structure.
    --
      l_fed_rec.sui_state_code := l_sui_state_code;
      l_fed_rec.sui_jurisdiction_code := l_sui_state_code || '-000-0000';
    --
    -- If the start dates do not match, update the federal record to create a
    -- row with the same start date as the assignment.  If they do match,
    -- correct the federal record.  Do the same for the workers comp entry.
    --
    if l_fed_rec.effective_start_date = l_chg_effective_start_date then
      --
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, 'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
      --
    elsif l_fed_rec.effective_start_date < l_chg_effective_start_date then
      open csr_fed_rule_exists(l_fed_rec.effective_end_date + 1);
      fetch csr_fed_rule_exists into l_temp_char;
      if csr_fed_rule_exists%notfound then
        l_dt_mode := 'UPDATE';
      else
        l_dt_mode := 'UPDATE_CHANGE_INSERT';
      end if;
      close csr_fed_rule_exists;
      pay_fed_upd.upd(l_fed_rec, l_chg_effective_start_date, l_dt_mode);
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_chg_effective_start_date
                  ,p_datetrack_mode       => l_dt_mode
                  );
    end if;
    --
    -- Correct sui_state and sui_jurisdiction for each federal record that
    -- exists at all between the start date + 1 and the end date of the
    -- assignment.  Do the same for the workers comp entry.
    --
    for l_fed_rec in csr_fed_rec2(p_assignment_id, l_chg_effective_start_date+1,
                                  l_chg_effective_end_date)
    loop

/* changes for bug 1970341 possible a DB issue. */
--      l_fed_rec_dup := l_fed_rec;

      l_fed_rec_dup.emp_fed_tax_rule_id       := l_fed_rec.emp_fed_tax_rule_id;
      l_fed_rec_dup.effective_start_date      := l_fed_rec.effective_start_date;
      l_fed_rec_dup.effective_end_date        := l_fed_rec.effective_end_date;
      l_fed_rec_dup.assignment_id             := l_fed_rec.assignment_id;
      l_fed_rec_dup.sui_state_code            := l_fed_rec.sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code     := l_fed_rec.sui_jurisdiction_code;
      l_fed_rec_dup.business_group_id         := l_fed_rec.business_group_id;
      l_fed_rec_dup.additional_wa_amount      := l_fed_rec.additional_wa_amount;
      l_fed_rec_dup.filing_status_code        := l_fed_rec.filing_status_code;
      l_fed_rec_dup.fit_override_amount       := l_fed_rec.fit_override_amount;
      l_fed_rec_dup.fit_override_rate         := l_fed_rec.fit_override_rate;
      l_fed_rec_dup.withholding_allowances    := l_fed_rec.withholding_allowances;
      l_fed_rec_dup.cumulative_taxation       := l_fed_rec.cumulative_taxation;
      l_fed_rec_dup.eic_filing_status_code    := l_fed_rec.eic_filing_status_code;
      l_fed_rec_dup.fit_additional_tax        := l_fed_rec.fit_additional_tax;
      l_fed_rec_dup.fit_exempt                := l_fed_rec.fit_exempt;
      l_fed_rec_dup.futa_tax_exempt           := l_fed_rec.futa_tax_exempt;
      l_fed_rec_dup.medicare_tax_exempt       := l_fed_rec.medicare_tax_exempt;
      l_fed_rec_dup.ss_tax_exempt             := l_fed_rec.ss_tax_exempt;
      l_fed_rec_dup.wage_exempt               := l_fed_rec.wage_exempt;
      l_fed_rec_dup.statutory_employee        := l_fed_rec.statutory_employee;
      l_fed_rec_dup.w2_filed_year             := l_fed_rec.w2_filed_year;
      l_fed_rec_dup.supp_tax_override_rate    := l_fed_rec.supp_tax_override_rate;
      l_fed_rec_dup.excessive_wa_reject_date  := l_fed_rec.excessive_wa_reject_date;
      l_fed_rec_dup.object_version_number     := l_fed_rec.object_version_number;
      l_fed_rec_dup.attribute_category        := l_fed_rec.attribute_category;
      l_fed_rec_dup.attribute1                := l_fed_rec.attribute1;
      l_fed_rec_dup.attribute2                := l_fed_rec.attribute2;
      l_fed_rec_dup.attribute3                := l_fed_rec.attribute3;
      l_fed_rec_dup.attribute4                := l_fed_rec.attribute4;
      l_fed_rec_dup.attribute5                := l_fed_rec.attribute5;
      l_fed_rec_dup.attribute6                := l_fed_rec.attribute6;
      l_fed_rec_dup.attribute7                := l_fed_rec.attribute7;
      l_fed_rec_dup.attribute8                := l_fed_rec.attribute8;
      l_fed_rec_dup.attribute9                := l_fed_rec.attribute9;
      l_fed_rec_dup.attribute10               := l_fed_rec.attribute10;
      l_fed_rec_dup.attribute11               := l_fed_rec.attribute11;
      l_fed_rec_dup.attribute12               := l_fed_rec.attribute12;
      l_fed_rec_dup.attribute13               := l_fed_rec.attribute13;
      l_fed_rec_dup.attribute14               := l_fed_rec.attribute14;
      l_fed_rec_dup.attribute15               := l_fed_rec.attribute15;
      l_fed_rec_dup.attribute16               := l_fed_rec.attribute16;
      l_fed_rec_dup.attribute17               := l_fed_rec.attribute17;
      l_fed_rec_dup.attribute18               := l_fed_rec.attribute18;
      l_fed_rec_dup.attribute19               := l_fed_rec.attribute19;
      l_fed_rec_dup.attribute20               := l_fed_rec.attribute20;
      l_fed_rec_dup.attribute21               := l_fed_rec.attribute21;
      l_fed_rec_dup.attribute22               := l_fed_rec.attribute22;
      l_fed_rec_dup.attribute23               := l_fed_rec.attribute23;
      l_fed_rec_dup.attribute24               := l_fed_rec.attribute24;
      l_fed_rec_dup.attribute25               := l_fed_rec.attribute25;
      l_fed_rec_dup.attribute26               := l_fed_rec.attribute26;
      l_fed_rec_dup.attribute27               := l_fed_rec.attribute27;
      l_fed_rec_dup.attribute28               := l_fed_rec.attribute28;
      l_fed_rec_dup.attribute29               := l_fed_rec.attribute29;
      l_fed_rec_dup.attribute30               := l_fed_rec.attribute30;
      l_fed_rec_dup.fed_information_category  := l_fed_rec.fed_information_category;
      l_fed_rec_dup.fed_information1          := l_fed_rec.fed_information1;
      l_fed_rec_dup.fed_information2          := l_fed_rec.fed_information2;
      l_fed_rec_dup.fed_information3          := l_fed_rec.fed_information3;
      l_fed_rec_dup.fed_information4          := l_fed_rec.fed_information4;
      l_fed_rec_dup.fed_information5          := l_fed_rec.fed_information5;
      l_fed_rec_dup.fed_information6          := l_fed_rec.fed_information6;
      l_fed_rec_dup.fed_information7          := l_fed_rec.fed_information7;
      l_fed_rec_dup.fed_information8          := l_fed_rec.fed_information8;
      l_fed_rec_dup.fed_information9          := l_fed_rec.fed_information9;
      l_fed_rec_dup.fed_information10         := l_fed_rec.fed_information10;
      l_fed_rec_dup.fed_information11         := l_fed_rec.fed_information11;
      l_fed_rec_dup.fed_information12         := l_fed_rec.fed_information12;
      l_fed_rec_dup.fed_information13         := l_fed_rec.fed_information13;
      l_fed_rec_dup.fed_information14         := l_fed_rec.fed_information14;
      l_fed_rec_dup.fed_information15         := l_fed_rec.fed_information15;
      l_fed_rec_dup.fed_information16         := l_fed_rec.fed_information16;
      l_fed_rec_dup.fed_information17         := l_fed_rec.fed_information17;
      l_fed_rec_dup.fed_information18         := l_fed_rec.fed_information18;
      l_fed_rec_dup.fed_information19         := l_fed_rec.fed_information19;
      l_fed_rec_dup.fed_information20         := l_fed_rec.fed_information20;
      l_fed_rec_dup.fed_information21         := l_fed_rec.fed_information21;
      l_fed_rec_dup.fed_information22         := l_fed_rec.fed_information22;
      l_fed_rec_dup.fed_information23         := l_fed_rec.fed_information23;
      l_fed_rec_dup.fed_information24         := l_fed_rec.fed_information24;
      l_fed_rec_dup.fed_information25         := l_fed_rec.fed_information25;
      l_fed_rec_dup.fed_information26         := l_fed_rec.fed_information26;
      l_fed_rec_dup.fed_information27         := l_fed_rec.fed_information27;
      l_fed_rec_dup.fed_information28         := l_fed_rec.fed_information28;
      l_fed_rec_dup.fed_information29         := l_fed_rec.fed_information29;
      l_fed_rec_dup.fed_information30         := l_fed_rec.fed_information30;

/* changes for bug 1970341 possible a DB issue. */

      l_fed_rec_dup.sui_state_code := l_sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code := l_sui_state_code || '-000-0000';
      pay_fed_upd.upd(l_fed_rec_dup, l_fed_rec_dup.effective_start_date,
                      'CORRECTION');
      maintain_wc(
                   p_emp_fed_tax_rule_id  => l_fed_rec.emp_fed_tax_rule_id
                  ,p_effective_start_date => l_fed_rec.effective_start_date
                  ,p_effective_end_date   => l_fed_rec.effective_end_date
                  ,p_effective_date       => l_fed_rec.effective_start_date
                  ,p_datetrack_mode       => 'CORRECTION'
                  );
    end loop;

  elsif p_datetrack_mode in ('ZAP', 'DELETE',
                             'DELETE_NEXT_CHANGE',
                             'FUTURE_CHANGE') then
    --
    hr_utility.set_location(l_proc, 110);
    --
    -- This process should not be called with these modes.  Call
    -- Maintain_us_emp_taxes for a ZAP delete.
    -- Other delete modes are not allowed.
      hr_utility.set_message(801, 'HR_7204_DT_DEL_MODE_INVALID');
      hr_utility.raise_error;

  else
    -- Unknown datetrack mode
      hr_utility.set_message(801, 'HR_7184_DT_MODE_UNKNOWN');
      hr_utility.set_message_token('DT_MODE', p_datetrack_mode);
      hr_utility.raise_error;

  end if;
  --
  --
  --
  --
  -- Modify the existing tax percentages
  --
  open csr_asg_city_code;
  loop
    fetch csr_asg_city_code into l_csr_state_code, l_csr_county_code,
                                 l_csr_city_code;
    exit when csr_asg_city_code%notfound;
    --
    l_city_pct := 0;
    l_pct_eff_start_date := l_chg_effective_start_date;
    l_pct_eff_end_date := l_chg_effective_end_date;

    /* we check to see if the entry being updated matches the ovrd jurisdiction, which
       defaults to the mailing address jurisdiction if not present.  If so, set that
       percentage at 100 */

    if l_loc_ovrd_state_code||l_loc_ovrd_county_code||l_loc_ovrd_city_code =
                l_csr_state_code||l_csr_county_code||l_csr_city_code then
      l_city_pct := 100;
    end if;
    maintain_tax_percentage(
                 p_assignment_id        => p_assignment_id
                ,p_effective_date       => l_effective_date
                ,p_state_code           => l_csr_state_code
                ,p_county_code          => l_csr_county_code
                ,p_city_code            => l_csr_city_code
                ,p_percentage           => l_city_pct
                ,p_datetrack_mode       => p_datetrack_mode
                ,p_effective_start_date => l_pct_eff_start_date
                ,p_effective_end_date   => l_pct_eff_end_date
                ,p_calculate_pct        => FALSE
                );
  end loop;
  close csr_asg_city_code;
  --
  open csr_asg_county_code;
  loop
    fetch csr_asg_county_code into l_csr_state_code, l_csr_county_code;
    exit when csr_asg_county_code%notfound;
    l_pct_eff_start_date := l_chg_effective_start_date;
    l_pct_eff_end_date := l_chg_effective_end_date;
    maintain_tax_percentage(
                 p_assignment_id        => p_assignment_id
                ,p_effective_date       => l_effective_date
                ,p_state_code           => l_csr_state_code
                ,p_county_code          => l_csr_county_code
                ,p_city_code            => '0000'
                ,p_percentage           => 0
                ,p_datetrack_mode       => p_datetrack_mode
                ,p_effective_start_date => l_pct_eff_start_date
                ,p_effective_end_date   => l_pct_eff_end_date
                ,p_calculate_pct        => FALSE
                );
  end loop;
  close csr_asg_county_code;
  --
  open csr_asg_state_code;
  loop
    fetch csr_asg_state_code into l_csr_state_code;
    exit when csr_asg_state_code%notfound;
    l_pct_eff_start_date := l_chg_effective_start_date;
    l_pct_eff_end_date := l_chg_effective_end_date;
    maintain_tax_percentage(
                 p_assignment_id        => p_assignment_id
                ,p_effective_date       => l_effective_date
                ,p_state_code           => l_csr_state_code
                ,p_county_code          => '000'
                ,p_city_code            => '0000'
                ,p_percentage           => 0
                ,p_datetrack_mode       => p_datetrack_mode
                ,p_effective_start_date => l_pct_eff_start_date
                ,p_effective_end_date   => l_pct_eff_end_date
                ,p_calculate_pct        => FALSE
                );
  end loop;
  close csr_asg_state_code;
  --
  -- Create new tax rules if they do not already exist.
  -- first for the mailing address
  create_tax_rules_for_jd(p_state_code 	=> l_loc_state_code,
			p_county_code 	=> l_loc_county_code,
			p_city_code 	=> l_loc_city_code,
			p_effective_date => l_effective_date,
			p_assignment_id => p_assignment_id
			);

  -- last for the taxation address
  create_tax_rules_for_jd(p_state_code 	=> l_loc_ovrd_state_code,
			p_county_code 	=> l_loc_ovrd_county_code,
			p_city_code 	=> l_loc_ovrd_city_code,
			p_effective_date => l_effective_date,
			p_assignment_id => p_assignment_id
			);


  --
  hr_utility.set_location(' Leaving:'||l_proc, 130);
  --
exception
  --
  -- This is called when location_change runs but the new location is the
  -- same as the existing location
  --
  when l_exit_quietly then
     null;
end location_change;

-- ----------------------------------------------------------------------------
-- |-------------------------< move_tax_default_date >------------------------|
-- ----------------------------------------------------------------------------
procedure move_tax_default_date
    (p_effective_date               In      date
    ,p_datetrack_mode               In      varchar2
    ,p_assignment_id                In      number
    ,p_new_location_id              In      number     default null
    ,p_new_hire_date                In      date       default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                     varchar2(72) := g_package||'move_tax_default_date';
  l_effective_date              date;
  l_new_hire_date               date;
  l_tmp_loc_id			hr_locations.location_id%TYPE;
  l_new_location_id		hr_locations.location_id%TYPE;
  l_temp_char                   varchar2(10);
  l_tmp_effective_start_date
                           pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_tmp_effective_end_date   pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_tmp_object_version_number
                          pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
  l_emp_fed_tax_rule_id     pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
  l_new_default_date       pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_defaulting_date        pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_fed_eed                  pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_default_flag                varchar2(1) := 'Y';
  l_defaulting_met              boolean;
  l_asg_eed                     per_assignments_f.effective_end_date%TYPE;
  l_asg_esd                     per_assignments_f.effective_start_date%TYPE;
  l_loc_state_code              pay_us_states.state_code%TYPE;
  l_loc_county_code             pay_us_counties.county_code%TYPE;
  l_loc_city_code               pay_us_city_names.city_code%TYPE;
  l_loc_ovrd_state_code		pay_us_states.state_code%TYPE;
  l_loc_ovrd_county_code        pay_us_counties.county_code%TYPE;
  l_loc_ovrd_city_code          pay_us_city_names.city_code%TYPE;
  l_state_code                  pay_us_emp_state_tax_rules_f.state_code%TYPE;
  l_county_code                 pay_us_emp_county_tax_rules_f.county_code%TYPE;
  l_city_code                   pay_us_emp_city_tax_rules_f.city_code%TYPE;
  l_city_pct                    number;
  --
  l_fed_rec                     pay_fed_shd.g_rec_type;
  l_fed_rec_dup                 pay_fed_shd.g_rec_type;
  l_state_rec                   pay_sta_shd.g_rec_type;
  l_state_rec_dup               pay_sta_shd.g_rec_type;
  l_county_rec                  pay_cnt_shd.g_rec_type;
  l_county_rec_dup              pay_cnt_shd.g_rec_type;
  l_city_rec                    pay_cty_shd.g_rec_type;
  l_city_rec_dup                pay_cty_shd.g_rec_type;
  l_exists                      varchar2(1);
  --
  l_exit_quietly                exception;
  --
  cursor csr_check_payroll(p_csr_date1 date, p_csr_date2 date) is
      select null
      from  per_assignments_f paf
           ,pay_payroll_actions ppa
           ,pay_assignment_actions paa
           ,pay_run_results prr
      where  paf.assignment_id = p_assignment_id
      and    ((paf.effective_start_date <= p_csr_date1
             and paf.effective_end_date >= p_csr_date1)
      OR    (paf.effective_start_date between p_csr_date1 and p_csr_date2 ) )
      and    ppa.payroll_id = paf.payroll_id
      and    ppa.action_type in ('Q','R')
      and    ppa.date_earned between p_csr_date1 and p_csr_date2
      and    ppa.payroll_action_id = paa.payroll_action_id
      and    paa.assignment_id =  paf.assignment_id
      and    paa.assignment_action_id = prr.assignment_action_id ;
--
  cursor csr_fed_tax_rule is
    select min(effective_start_date), min(effective_end_date),
           emp_fed_tax_rule_id
    from   pay_us_emp_fed_tax_rules_f
    where  assignment_id = p_assignment_id
    group by emp_fed_tax_rule_id;
  --
  cursor csr_asg_data(p_csr_asg_id number, p_csr_eff_date date) is
    select asg.effective_start_date, asg.effective_end_date
    from   per_assignments_f asg
    where  asg.assignment_id = p_csr_asg_id
    and    p_csr_eff_date between asg.effective_start_date
           and asg.effective_end_date;
  --
  cursor csr_assignment_id is
    select null
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id;
  --
  -- reimp - added cursor to get current location id
  --	     since it is not passed in if it is unchanged

  cursor csr_asg_loc_id(p_date date) is
    select location_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
      and  p_date between asg.effective_start_date and asg.effective_end_date;
  --
  cursor csr_future_fed_rule(l_csr_date date default hr_api.g_date) is
    select null
    from   pay_us_emp_fed_tax_rules_f fed
    where  fed.assignment_id = p_assignment_id
    and    fed.effective_start_date > l_csr_date;
  --
  cursor csr_fed_rec(l_csr_assignment_id number
                    ,l_csr_effective_date date) is
     select emp_fed_tax_rule_id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,sui_state_code
           ,sui_jurisdiction_code
           ,business_group_id
           ,additional_wa_amount
           ,filing_status_code
           ,fit_override_amount
           ,fit_override_rate
           ,withholding_allowances
           ,cumulative_taxation
           ,eic_filing_status_code
           ,fit_additional_tax
           ,fit_exempt
           ,futa_tax_exempt
           ,medicare_tax_exempt
           ,ss_tax_exempt
           ,wage_exempt
           ,statutory_employee
           ,w2_filed_year
           ,supp_tax_override_rate
           ,excessive_wa_reject_date
           ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,fed_information_category
           ,fed_information1
           ,fed_information2
           ,fed_information3
           ,fed_information4
           ,fed_information5
           ,fed_information6
           ,fed_information7
           ,fed_information8
           ,fed_information9
           ,fed_information10
           ,fed_information11
           ,fed_information12
           ,fed_information13
           ,fed_information14
           ,fed_information15
           ,fed_information16
           ,fed_information17
           ,fed_information18
           ,fed_information19
           ,fed_information20
           ,fed_information21
           ,fed_information22
           ,fed_information23
           ,fed_information24
           ,fed_information25
           ,fed_information26
           ,fed_information27
           ,fed_information28
           ,fed_information29
           ,fed_information30
     from   pay_us_emp_fed_tax_rules_f
     where  assignment_id = l_csr_assignment_id
     and    l_csr_effective_date between effective_start_date
                                 and effective_end_date;
  --
  cursor csr_fed_rows(l_csr_assignment_id number
                     ,l_csr_effective_date date) is
     select emp_fed_tax_rule_id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,sui_state_code
           ,sui_jurisdiction_code
           ,business_group_id
           ,additional_wa_amount
           ,filing_status_code
           ,fit_override_amount
           ,fit_override_rate
           ,withholding_allowances
           ,cumulative_taxation
           ,eic_filing_status_code
           ,fit_additional_tax
           ,fit_exempt
           ,futa_tax_exempt
           ,medicare_tax_exempt
           ,ss_tax_exempt
           ,wage_exempt
           ,statutory_employee
           ,w2_filed_year
           ,supp_tax_override_rate
           ,excessive_wa_reject_date
           ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,fed_information_category
           ,fed_information1
           ,fed_information2
           ,fed_information3
           ,fed_information4
           ,fed_information5
           ,fed_information6
           ,fed_information7
           ,fed_information8
           ,fed_information9
           ,fed_information10
           ,fed_information11
           ,fed_information12
           ,fed_information13
           ,fed_information14
           ,fed_information15
           ,fed_information16
           ,fed_information17
           ,fed_information18
           ,fed_information19
           ,fed_information20
           ,fed_information21
           ,fed_information22
           ,fed_information23
           ,fed_information24
           ,fed_information25
           ,fed_information26
           ,fed_information27
           ,fed_information28
           ,fed_information29
           ,fed_information30
     from   pay_us_emp_fed_tax_rules_f
     where  assignment_id = l_csr_assignment_id
     and    l_csr_effective_date <= effective_end_date
     order by effective_start_date;
  --
  cursor csr_state_rec(l_csr_assignment_id number
                      ,l_csr_effective_date date) is
    select emp_state_tax_rule_id
          ,effective_start_date
          ,effective_end_date
          ,assignment_id
          ,state_code
          ,jurisdiction_code
          ,business_group_id
          ,additional_wa_amount
          ,filing_status_code
          ,remainder_percent
          ,secondary_wa
          ,sit_additional_tax
          ,sit_override_amount
          ,sit_override_rate
          ,withholding_allowances
          ,excessive_wa_reject_date
          ,sdi_exempt
          ,sit_exempt
          ,sit_optional_calc_ind
          ,state_non_resident_cert
          ,sui_exempt
          ,wc_exempt
          ,wage_exempt
          ,sui_wage_base_override_amount
          ,supp_tax_override_rate
          ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,sta_information_category
           ,sta_information1
           ,sta_information2
           ,sta_information3
           ,sta_information4
           ,sta_information5
           ,sta_information6
           ,sta_information7
           ,sta_information8
           ,sta_information9
           ,sta_information10
           ,sta_information11
           ,sta_information12
           ,sta_information13
           ,sta_information14
           ,sta_information15
           ,sta_information16
           ,sta_information17
           ,sta_information18
           ,sta_information19
           ,sta_information20
           ,sta_information21
           ,sta_information22
           ,sta_information23
           ,sta_information24
           ,sta_information25
           ,sta_information26
           ,sta_information27
           ,sta_information28
           ,sta_information29
           ,sta_information30
     from  pay_us_emp_state_tax_rules_f
     where assignment_id = l_csr_assignment_id
     and   l_csr_effective_date between effective_start_date
                                and effective_end_date;
  --
  cursor csr_county_rec(l_csr_assignment_id number
                       ,l_csr_effective_date date) is
    select emp_county_tax_rule_id
          ,effective_start_date
          ,effective_end_date
          ,assignment_id
          ,state_code
          ,county_code
          ,business_group_id
          ,additional_wa_rate
          ,filing_status_code
          ,jurisdiction_code
          ,lit_additional_tax
          ,lit_override_amount
          ,lit_override_rate
          ,withholding_allowances
          ,lit_exempt
          ,sd_exempt
          ,ht_exempt
          ,wage_exempt
          ,school_district_code
          ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,cnt_information_category
           ,cnt_information1
           ,cnt_information2
           ,cnt_information3
           ,cnt_information4
           ,cnt_information5
           ,cnt_information6
           ,cnt_information7
           ,cnt_information8
           ,cnt_information9
           ,cnt_information10
           ,cnt_information11
           ,cnt_information12
           ,cnt_information13
           ,cnt_information14
           ,cnt_information15
           ,cnt_information16
           ,cnt_information17
           ,cnt_information18
           ,cnt_information19
           ,cnt_information20
           ,cnt_information21
           ,cnt_information22
           ,cnt_information23
           ,cnt_information24
           ,cnt_information25
           ,cnt_information26
           ,cnt_information27
           ,cnt_information28
           ,cnt_information29
           ,cnt_information30
     from   pay_us_emp_county_tax_rules_f
     where assignment_id = l_csr_assignment_id
     and   l_csr_effective_date between effective_start_date
                                and effective_end_date;
  --
  cursor csr_city_rec(l_csr_assignment_id number
                     ,l_csr_effective_date date) is
    select emp_city_tax_rule_id
          ,effective_start_date
          ,effective_end_date
          ,assignment_id
          ,state_code
          ,county_code
          ,city_code
          ,business_group_id
          ,additional_wa_rate
          ,filing_status_code
          ,jurisdiction_code
          ,lit_additional_tax
          ,lit_override_amount
          ,lit_override_rate
          ,withholding_allowances
          ,lit_exempt
          ,sd_exempt
          ,ht_exempt
          ,wage_exempt
          ,school_district_code
          ,object_version_number
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30
           ,cty_information_category
           ,cty_information1
           ,cty_information2
           ,cty_information3
           ,cty_information4
           ,cty_information5
           ,cty_information6
           ,cty_information7
           ,cty_information8
           ,cty_information9
           ,cty_information10
           ,cty_information11
           ,cty_information12
           ,cty_information13
           ,cty_information14
           ,cty_information15
           ,cty_information16
           ,cty_information17
           ,cty_information18
           ,cty_information19
           ,cty_information20
           ,cty_information21
           ,cty_information22
           ,cty_information23
           ,cty_information24
           ,cty_information25
           ,cty_information26
           ,cty_information27
           ,cty_information28
           ,cty_information29
           ,cty_information30
    from   pay_us_emp_city_tax_rules_f
     where assignment_id = l_csr_assignment_id
     and   l_csr_effective_date between effective_start_date
                                and effective_end_date;
  --
  --
  procedure pull_back_taxes(p_assignment_id       in number
                           ,p_emp_fed_tax_rule_id in number
                           ,p_fed_eed             in date
                           ,p_new_default_date    in date
                           ,p_defaulting_date     in date
                           ) is
    l_tmp_esd        date;
    l_tmp_eed        date;
    l_state_rec      pay_sta_shd.g_rec_type;
    l_county_rec     pay_cnt_shd.g_rec_type;
    l_city_rec       pay_cty_shd.g_rec_type;

    begin
        update pay_us_emp_fed_tax_rules_f
        set    effective_start_date = p_new_default_date
        where  assignment_id = p_assignment_id
        and    effective_start_date = p_defaulting_date;
        --
        maintain_wc(
                  p_emp_fed_tax_rule_id   => p_emp_fed_tax_rule_id
                 ,p_effective_start_date  => p_defaulting_date
                 ,p_effective_end_date    => p_fed_eed
                 ,p_effective_date        => p_new_default_date
                 ,p_datetrack_mode        => 'INSERT_OVERRIDE'
                 );
        --
        for l_state_rec in csr_state_rec(p_assignment_id, p_defaulting_date)
        loop
          --
          update pay_us_emp_state_tax_rules_f
          set    effective_start_date = p_new_default_date
          where  effective_start_date = p_defaulting_date
          and    assignment_id = p_assignment_id
          and    state_code = l_state_rec.state_code;
          --
          l_tmp_esd  := p_defaulting_date;
          l_tmp_eed  := p_fed_eed;
          maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => p_new_default_date
                     ,p_state_code           => l_state_rec.state_code
                     ,p_county_code          => '000'
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_esd
                     ,p_effective_end_date   => l_tmp_eed
                     ,p_calculate_pct        => FALSE
                     );
        end loop;        -- l_state_rec
        --
        for l_county_rec in csr_county_rec(p_assignment_id, p_defaulting_date)
        loop
          --
          update pay_us_emp_county_tax_rules_f
          set    effective_start_date = p_new_default_date
          where  effective_start_date = p_defaulting_date
          and    assignment_id = p_assignment_id
          and    state_code = l_county_rec.state_code
          and    county_code = l_county_rec.county_code;
          --
          l_tmp_esd  := p_defaulting_date;
          l_tmp_eed  := p_fed_eed;
          maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => p_new_default_date
                     ,p_state_code           => l_county_rec.state_code
                     ,p_county_code          => l_county_rec.county_code
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_esd
                     ,p_effective_end_date   => l_tmp_eed
                     ,p_calculate_pct        => FALSE
                     );
        end loop;        -- l_county_rec
        --
        for l_city_rec in csr_city_rec(p_assignment_id, p_defaulting_date)
        loop
          --
          update pay_us_emp_city_tax_rules_f
          set    effective_start_date = p_new_default_date
          where  effective_start_date = p_defaulting_date
          and    assignment_id = p_assignment_id
          and    state_code = l_city_rec.state_code
          and    county_code = l_city_rec.county_code
          and    city_code = l_city_rec.city_code;
          --
          l_tmp_esd  := p_defaulting_date;
          l_tmp_eed  := p_fed_eed;
          maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => p_new_default_date
                     ,p_state_code           => l_city_rec.state_code
                     ,p_county_code          => l_city_rec.county_code
                     ,p_city_code            => l_city_rec.city_code
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_esd
                     ,p_effective_end_date   => l_tmp_eed
                     ,p_calculate_pct        => FALSE
                     );
          --
        end loop;        -- l_city_rec
        --
    end pull_back_taxes;
  --
  --
  procedure reset_element_entries(p_assignment_id       in number
                                 ,p_emp_fed_tax_rule_id in number
                                 ,p_fed_eed             in date
                                 ,p_defaulting_date     in date
                                 ) is
    l_tmp_esd        date;
    l_tmp_eed        date;
    l_state_rec      pay_sta_shd.g_rec_type;
    l_county_rec     pay_cnt_shd.g_rec_type;
    l_city_rec       pay_cty_shd.g_rec_type;

    begin
        maintain_wc(
                  p_emp_fed_tax_rule_id   => p_emp_fed_tax_rule_id
                 ,p_effective_start_date  => p_defaulting_date
                 ,p_effective_end_date    => p_fed_eed
                 ,p_effective_date        => p_defaulting_date
                 ,p_datetrack_mode        => 'INSERT_OVERRIDE'
                 );
        --
        for l_state_rec in csr_state_rec(p_assignment_id, p_defaulting_date)
        loop
          --
          l_tmp_esd := p_defaulting_date;
          l_tmp_eed := p_fed_eed;
          maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => p_defaulting_date
                     ,p_state_code           => l_state_rec.state_code
                     ,p_county_code          => '000'
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_esd
                     ,p_effective_end_date   => l_tmp_eed
                     ,p_calculate_pct        => FALSE
                     );
          --
        end loop;        -- l_state_rec
        --
        for l_county_rec in csr_county_rec(p_assignment_id, p_defaulting_date)
        loop
          --
          l_tmp_esd  := p_defaulting_date;
          l_tmp_eed  := p_fed_eed;
          maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => p_defaulting_date
                     ,p_state_code           => l_county_rec.state_code
                     ,p_county_code          => l_county_rec.county_code
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_esd
                     ,p_effective_end_date   => l_tmp_eed
                     ,p_calculate_pct        => FALSE
                     );
          --
        end loop;        -- l_county_rec
        --
        for l_city_rec in csr_city_rec(p_assignment_id, p_defaulting_date)
        loop
          --
          l_tmp_esd  := p_defaulting_date;
          l_tmp_eed  := p_fed_eed;
          maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => p_defaulting_date
                     ,p_state_code           => l_city_rec.state_code
                     ,p_county_code          => l_city_rec.county_code
                     ,p_city_code            => l_city_rec.city_code
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_esd
                     ,p_effective_end_date   => l_tmp_eed
                     ,p_calculate_pct        => FALSE
                     );
          --
        end loop;        -- l_city_rec
        --
    end reset_element_entries;
  --
  --
  procedure push_forward_taxes(p_assignment_id       in number
                              ,p_fed_eed             in date
                              ,p_new_default_date    in date
                              ,p_defaulting_date     in date
                              ) is
    l_tmp_esd        date;
    l_tmp_eed        date;
    l_fed_rec                     pay_fed_shd.g_rec_type;
    l_fed_rec_dup                 pay_fed_shd.g_rec_type;
    l_state_rec                   pay_sta_shd.g_rec_type;
    l_state_rec_dup               pay_sta_shd.g_rec_type;
    l_county_rec                  pay_cnt_shd.g_rec_type;
    l_county_rec_dup              pay_cnt_shd.g_rec_type;
    l_city_rec                    pay_cty_shd.g_rec_type;
    l_city_rec_dup                pay_cty_shd.g_rec_type;
    l_exists                      varchar2(1);

    begin
      --
      -- Moving taxes forward involves removing part of the tax records.  This
      -- call checks if payroll has been run for this assignment
      --
      open csr_check_payroll(p_defaulting_date, p_new_default_date);
      fetch csr_check_payroll into l_exists;
      if csr_check_payroll%FOUND then
        hr_utility.set_location(l_proc,15);
        close csr_check_payroll;
        hr_utility.set_message(801, 'PAY_52235_TAX_RULE_DELETE');
        hr_utility.raise_error;
      end if;
      close csr_check_payroll;
      --
      -- Create a break in the federal tax rule at the new defaulting date, then
      -- delete any federal tax rules that begin before the new defaulting date.
      -- The same is done for the other tax rules, the tax percentages, and the
      -- workers compensation entry.
      --
      open csr_fed_rec(p_assignment_id, p_new_default_date);
      fetch csr_fed_rec into l_fed_rec;

/* changes for bug 1970341 possible a DB issue. */
--      l_fed_rec_dup := l_fed_rec;

      l_fed_rec_dup.emp_fed_tax_rule_id       := l_fed_rec.emp_fed_tax_rule_id;
      l_fed_rec_dup.effective_start_date      := l_fed_rec.effective_start_date;
      l_fed_rec_dup.effective_end_date        := l_fed_rec.effective_end_date;
      l_fed_rec_dup.assignment_id             := l_fed_rec.assignment_id;
      l_fed_rec_dup.sui_state_code            := l_fed_rec.sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code     := l_fed_rec.sui_jurisdiction_code ;
      l_fed_rec_dup.business_group_id         := l_fed_rec.business_group_id;
      l_fed_rec_dup.additional_wa_amount      := l_fed_rec.additional_wa_amount;
      l_fed_rec_dup.filing_status_code        := l_fed_rec.filing_status_code;
      l_fed_rec_dup.fit_override_amount       := l_fed_rec.fit_override_amount;
      l_fed_rec_dup.fit_override_rate         := l_fed_rec.fit_override_rate;
      l_fed_rec_dup.withholding_allowances    := l_fed_rec.withholding_allowances;
      l_fed_rec_dup.cumulative_taxation       := l_fed_rec.cumulative_taxation;
      l_fed_rec_dup.eic_filing_status_code    := l_fed_rec.eic_filing_status_code;
      l_fed_rec_dup.fit_additional_tax        := l_fed_rec.fit_additional_tax;
      l_fed_rec_dup.fit_exempt                := l_fed_rec.fit_exempt;
      l_fed_rec_dup.futa_tax_exempt           := l_fed_rec.futa_tax_exempt;
      l_fed_rec_dup.medicare_tax_exempt       := l_fed_rec.medicare_tax_exempt;
      l_fed_rec_dup.ss_tax_exempt             := l_fed_rec.ss_tax_exempt;
      l_fed_rec_dup.wage_exempt               := l_fed_rec.wage_exempt;
      l_fed_rec_dup.statutory_employee        := l_fed_rec.statutory_employee;
      l_fed_rec_dup.w2_filed_year             := l_fed_rec.w2_filed_year;
      l_fed_rec_dup.supp_tax_override_rate    := l_fed_rec.supp_tax_override_rate;
      l_fed_rec_dup.excessive_wa_reject_date  := l_fed_rec.excessive_wa_reject_date;
      l_fed_rec_dup.object_version_number     := l_fed_rec.object_version_number ;
      l_fed_rec_dup.attribute_category        := l_fed_rec.attribute_category;
      l_fed_rec_dup.attribute1                := l_fed_rec.attribute1;
      l_fed_rec_dup.attribute2                := l_fed_rec.attribute2;
      l_fed_rec_dup.attribute3                := l_fed_rec.attribute3;
      l_fed_rec_dup.attribute4                := l_fed_rec.attribute4;
      l_fed_rec_dup.attribute5                := l_fed_rec.attribute5;
      l_fed_rec_dup.attribute6                := l_fed_rec.attribute6;
      l_fed_rec_dup.attribute7                := l_fed_rec.attribute7;
      l_fed_rec_dup.attribute8                := l_fed_rec.attribute8;
      l_fed_rec_dup.attribute9                := l_fed_rec.attribute9;
      l_fed_rec_dup.attribute10               := l_fed_rec.attribute10;
      l_fed_rec_dup.attribute11               := l_fed_rec.attribute11;
      l_fed_rec_dup.attribute12               := l_fed_rec.attribute12;
      l_fed_rec_dup.attribute13               := l_fed_rec.attribute13;
      l_fed_rec_dup.attribute14               := l_fed_rec.attribute14;
      l_fed_rec_dup.attribute15               := l_fed_rec.attribute15;
      l_fed_rec_dup.attribute16               := l_fed_rec.attribute16;
      l_fed_rec_dup.attribute17               := l_fed_rec.attribute17;
      l_fed_rec_dup.attribute18               := l_fed_rec.attribute18;
      l_fed_rec_dup.attribute19               := l_fed_rec.attribute19;
      l_fed_rec_dup.attribute20               := l_fed_rec.attribute20;
      l_fed_rec_dup.attribute21               := l_fed_rec.attribute21;
      l_fed_rec_dup.attribute22               := l_fed_rec.attribute22;
      l_fed_rec_dup.attribute23               := l_fed_rec.attribute23;
      l_fed_rec_dup.attribute24               := l_fed_rec.attribute24;
      l_fed_rec_dup.attribute25               := l_fed_rec.attribute25;
      l_fed_rec_dup.attribute26               := l_fed_rec.attribute26;
      l_fed_rec_dup.attribute27               := l_fed_rec.attribute27;
      l_fed_rec_dup.attribute28               := l_fed_rec.attribute28;
      l_fed_rec_dup.attribute29               := l_fed_rec.attribute29;
      l_fed_rec_dup.attribute30               := l_fed_rec.attribute30;
      l_fed_rec_dup.fed_information_category  := l_fed_rec.fed_information_category;
      l_fed_rec_dup.fed_information1          := l_fed_rec.fed_information1;
      l_fed_rec_dup.fed_information2          := l_fed_rec.fed_information2;
      l_fed_rec_dup.fed_information3          := l_fed_rec.fed_information3;
      l_fed_rec_dup.fed_information4          := l_fed_rec.fed_information4;
      l_fed_rec_dup.fed_information5          := l_fed_rec.fed_information5;
      l_fed_rec_dup.fed_information6          := l_fed_rec.fed_information6;
      l_fed_rec_dup.fed_information7          := l_fed_rec.fed_information7;
      l_fed_rec_dup.fed_information8          := l_fed_rec.fed_information8;
      l_fed_rec_dup.fed_information9          := l_fed_rec.fed_information9;
      l_fed_rec_dup.fed_information10         := l_fed_rec.fed_information10;
      l_fed_rec_dup.fed_information11         := l_fed_rec.fed_information11;
      l_fed_rec_dup.fed_information12         := l_fed_rec.fed_information12;
      l_fed_rec_dup.fed_information13         := l_fed_rec.fed_information13;
      l_fed_rec_dup.fed_information14         := l_fed_rec.fed_information14;
      l_fed_rec_dup.fed_information15         := l_fed_rec.fed_information15;
      l_fed_rec_dup.fed_information16         := l_fed_rec.fed_information16;
      l_fed_rec_dup.fed_information17         := l_fed_rec.fed_information17;
      l_fed_rec_dup.fed_information18         := l_fed_rec.fed_information18;
      l_fed_rec_dup.fed_information19         := l_fed_rec.fed_information19;
      l_fed_rec_dup.fed_information20         := l_fed_rec.fed_information20;
      l_fed_rec_dup.fed_information21         := l_fed_rec.fed_information21;
      l_fed_rec_dup.fed_information22         := l_fed_rec.fed_information22;
      l_fed_rec_dup.fed_information23         := l_fed_rec.fed_information23;
      l_fed_rec_dup.fed_information24         := l_fed_rec.fed_information24;
      l_fed_rec_dup.fed_information25         := l_fed_rec.fed_information25;
      l_fed_rec_dup.fed_information26         := l_fed_rec.fed_information26;
      l_fed_rec_dup.fed_information27         := l_fed_rec.fed_information27;
      l_fed_rec_dup.fed_information28         := l_fed_rec.fed_information28;
      l_fed_rec_dup.fed_information29         := l_fed_rec.fed_information29;
      l_fed_rec_dup.fed_information30         := l_fed_rec.fed_information30;


/* changes for bug 1970341 possible a DB issue. */

      if l_fed_rec_dup.effective_start_date <> p_new_default_date then
        open csr_future_fed_rule(l_fed_rec_dup.effective_end_date);
        fetch csr_future_fed_rule into l_temp_char;
        if csr_future_fed_rule%notfound then
          pay_fed_upd.upd(p_rec            => l_fed_rec_dup
                         ,p_effective_date => p_new_default_date
                         ,p_datetrack_mode => 'UPDATE');
        else
          pay_fed_upd.upd(p_rec            => l_fed_rec_dup
                         ,p_effective_date => p_new_default_date
                         ,p_datetrack_mode => 'UPDATE_CHANGE_INSERT');
        end if;
        close csr_future_fed_rule;
      end if;
      close csr_fed_rec;

      delete from pay_us_emp_fed_tax_rules_f
      where  assignment_id = p_assignment_id
      and    effective_start_date < p_new_default_date;

      maintain_wc(
                  p_emp_fed_tax_rule_id   => l_fed_rec.emp_fed_tax_rule_id
                 ,p_effective_start_date  => l_fed_rec.effective_start_date
                 ,p_effective_end_date    => l_fed_rec.effective_end_date
                 ,p_effective_date        => p_new_default_date
                 ,p_datetrack_mode        => 'INSERT_OVERRIDE'
                 );
      --
      for l_state_rec in csr_state_rec(p_assignment_id, p_new_default_date)
      loop
        l_state_rec_dup := l_state_rec;
        if l_state_rec_dup.effective_start_date <> p_new_default_date then
          open csr_future_state_rule(l_state_rec_dup.state_code,
				     l_state_rec_dup.assignment_id,
				     l_state_rec_dup.effective_end_date);
          fetch csr_future_state_rule into l_temp_char;
          if csr_future_state_rule%notfound then
            pay_sta_upd.upd(p_rec            => l_state_rec_dup
                           ,p_effective_date => p_new_default_date
                           ,p_datetrack_mode => 'UPDATE');
          else
            pay_sta_upd.upd(p_rec            => l_state_rec_dup
                           ,p_effective_date => p_new_default_date
                           ,p_datetrack_mode => 'UPDATE_CHANGE_INSERT');
          end if;
          close csr_future_state_rule;
        end if;
        --
        l_tmp_esd  := p_new_default_date;
        l_tmp_eed  := p_fed_eed;
        maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => p_new_default_date
                     ,p_state_code           => l_state_rec.state_code
                     ,p_county_code          => '000'
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_esd
                     ,p_effective_end_date   => l_tmp_eed
                     ,p_calculate_pct        => FALSE
                     );
        --
      end loop;        -- l_state_rec
      --
      delete from pay_us_emp_state_tax_rules_f
      where  assignment_id = p_assignment_id
      and    effective_start_date < p_new_default_date;
      --
      for l_county_rec in csr_county_rec(p_assignment_id, p_new_default_date)
      loop
        l_county_rec_dup := l_county_rec;
        if l_county_rec_dup.effective_start_date <> p_new_default_date then
          open csr_future_county_rule(l_county_rec_dup.state_code,
				      l_county_rec_dup.county_code,
				      l_county_rec_dup.assignment_id,
				      l_county_rec_dup.effective_end_date);
          fetch csr_future_county_rule into l_temp_char;
          if csr_future_county_rule%notfound then
            pay_cnt_upd.upd(p_rec            => l_county_rec_dup
                           ,p_effective_date => p_new_default_date
                           ,p_datetrack_mode => 'UPDATE');
          else
            pay_cnt_upd.upd(p_rec            => l_county_rec_dup
                           ,p_effective_date => p_new_default_date
                           ,p_datetrack_mode => 'UPDATE_CHANGE_INSERT');
          end if;
          close csr_future_county_rule;
        end if;
        --
        l_tmp_esd  := p_new_default_date;
        l_tmp_eed  := p_fed_eed;
        maintain_tax_percentage(
                    p_assignment_id        => p_assignment_id
                   ,p_effective_date       => p_new_default_date
                   ,p_state_code           => l_county_rec.state_code
                   ,p_county_code          => l_county_rec.county_code
                   ,p_city_code            => '0000'
                   ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                   ,p_effective_start_date => l_tmp_esd
                   ,p_effective_end_date   => l_tmp_eed
                   ,p_calculate_pct        => FALSE
                   );
        --
      end loop;        -- l_county_rec
      --
      delete from pay_us_emp_county_tax_rules_f
      where  assignment_id = p_assignment_id
      and    effective_start_date < p_new_default_date;
      --
      for l_city_rec in csr_city_rec(p_assignment_id, p_new_default_date)
      loop
        l_city_rec_dup := l_city_rec;
        if l_city_rec_dup.effective_start_date <> p_new_default_date then
          open csr_future_city_rule(l_city_rec_dup.state_code,
				    l_city_rec_dup.county_code,
				    l_city_rec_dup.city_code,
				    l_city_rec_dup.assignment_id,
				    l_city_rec_dup.effective_end_date);

          fetch csr_future_city_rule into l_temp_char;
          if csr_future_city_rule%notfound then
            pay_cty_upd.upd(p_rec            => l_city_rec_dup
                           ,p_effective_date => p_new_default_date
                           ,p_datetrack_mode => 'UPDATE');
          else
            pay_cty_upd.upd(p_rec            => l_city_rec_dup
                           ,p_effective_date => p_new_default_date
                           ,p_datetrack_mode => 'UPDATE_CHANGE_INSERT');
          end if;
          close csr_future_city_rule;
        end if;
        --
        l_tmp_esd  := p_new_default_date;
        l_tmp_eed  := p_fed_eed;
        maintain_tax_percentage(
                    p_assignment_id        => p_assignment_id
                   ,p_effective_date       => p_new_default_date
                   ,p_state_code           => l_city_rec.state_code
                   ,p_county_code          => l_city_rec.county_code
                   ,p_city_code            => l_city_rec.city_code
                   ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                   ,p_effective_start_date => l_tmp_esd
                   ,p_effective_end_date   => l_tmp_eed
                   ,p_calculate_pct        => FALSE
                   );
        --
      end loop;        -- l_city_rec
      --
      delete from pay_us_emp_city_tax_rules_f
      where  assignment_id = p_assignment_id
      and    effective_start_date < p_new_default_date;

    end push_forward_taxes;
  --
  --
begin          -- move_tax_default_date procedure
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_new_hire_date := trunc(p_new_hire_date);
  l_effective_date := nvl(l_new_hire_date, trunc(p_effective_date));
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- First check if geocode has been installed or not. If no geocodes
  -- installed then return because there is nothing to be done by this
  -- defaulting procedure
  if hr_general.chk_maintain_tax_records = 'N' then
     return;
  end if;
  --
  -- Check that L_EFFECTIVE_DATE is not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => l_effective_date);
  --
  -- Validate p_assignment_id against per_assignments_f
  --
  if p_assignment_id is null then
    hr_utility.set_message(801,'PAY_7702_PDT_VALUE_NOT_FOUND');
    hr_utility.raise_error;
  else
    open csr_assignment_id;
    fetch csr_assignment_id into l_temp_char;
    if csr_assignment_id%notfound then
      close csr_assignment_id;
      hr_utility.set_message(801,'PAY_7702_PDT_VALUE_NOT_FOUND');
      hr_utility.raise_error;
    end if;
    close csr_assignment_id;
  end if;

  --
  -- Get the start and end dates of the current assignment record.
  --
  open csr_asg_data(p_assignment_id, l_effective_date);
  fetch csr_asg_data into l_asg_esd, l_asg_eed;
  if csr_asg_data%notfound then
    close csr_asg_data;
    hr_utility.set_message(801,'HR_7026_ELE_ENTRY_ASS_NOT_EXST');
    hr_utility.set_message_token('DATE',l_effective_date);
    hr_utility.raise_error;
  end if;
  close csr_asg_data;
  --
  -- Identify the new default date as either the new hire date passed in, or
  -- the start date of the current assignment record.
  --
  l_new_default_date := nvl(l_new_hire_date, l_asg_esd);
  --
  open csr_fed_tax_rule;
  fetch csr_fed_tax_rule into l_defaulting_date, l_fed_eed,
                              l_emp_fed_tax_rule_id;
  if csr_fed_tax_rule%notfound then
    close csr_fed_tax_rule;
    hr_utility.set_message(801,'PAY_51465_PDT_INVALID_LOC');
    hr_utility.raise_error;
  end if;
  close csr_fed_tax_rule;
  --
  -- To pull back the defaulting date, the assignment as of the new default date
  -- must be immediately before the old hire date.  This section checks this
  -- condition.
  --
  if l_new_default_date < l_defaulting_date then
    open csr_asg_data(p_assignment_id, l_new_default_date);
    fetch csr_asg_data into l_asg_esd, l_asg_eed;
    if csr_asg_data%notfound then
      close csr_asg_data;
      hr_utility.set_message(801,'HR_7026_ELE_ENTRY_ASS_NOT_EXST');
      hr_utility.set_message_token('DATE',l_new_default_date);
      hr_utility.raise_error;
    end if;
    close csr_asg_data;
    --
    if l_defaulting_date - 1 not between l_asg_esd and l_asg_eed then
      raise l_exit_quietly;
    end if;
  end if;

  -- reimp
  -- Figure out if the location is the same as the next location
  --
  -- In case of CORRECTION or UPDATE_INSERT, we check to see the location
  -- of the current asg record, and the location of the next asg record.  If
  -- they are different, we set p_new_location_id to the current location id.
  -- Otherwise we set it to null.
  --
  -- If it is DELETE_*_CHANGE or ZAP it doesn't matter what the location id is.
  --
  -- If it is UPDATE_OVERRIDE, the location_id is passed in by the maintain taxes proc.
  --
  if p_datetrack_mode in (hr_api.g_correction,hr_api.g_update_change_insert) then
    open csr_asg_loc_id(l_new_default_date);
    fetch csr_asg_loc_id into l_new_location_id;
    if csr_asg_loc_id%NOTFOUND then
	close csr_asg_loc_id;
	l_new_location_id := null;
    else
	close csr_asg_loc_id;
  	open  csr_asg_loc_id(l_defaulting_date);
	fetch csr_asg_loc_id into l_tmp_loc_id;
	close csr_asg_loc_id;
	if l_tmp_loc_id = l_new_location_id then
		l_new_location_id := null;
	end if;
    end if;
  end if;

  if l_new_location_id is not null then
    open csr_loc_addr(l_new_location_id);
    fetch csr_loc_addr into l_loc_state_code, l_loc_county_code,
                            l_loc_city_code, l_loc_ovrd_state_code,
			    l_loc_ovrd_county_code,l_loc_ovrd_city_code;
    if csr_loc_addr%notfound then
      close csr_loc_addr;
      hr_utility.set_message(801,'HR_51357_POS_LOC_NOT_EXIST');
      hr_utility.raise_error;
    end if;
    close csr_loc_addr;

  end if;
  --
  -- Determine if defaulting criteria is met at the new default date.
  --
  open csr_defaulting_met(p_assignment_id,l_new_default_date);
  fetch csr_defaulting_met into l_temp_char;
  if csr_defaulting_met%found then
    l_defaulting_met := True;
  else
    l_defaulting_met := False;
  end if;
  close csr_defaulting_met;

  --
  --
  -- This section handles the cases where this procedure is called from a
  -- change to the person's hire date.  In these cases, the new hire date
  -- could result in changes to the starting dates of the tax records.  This
  -- change could pull back the tax defaulting date, or push it forward.
  --
  If l_new_hire_date is not null then
    if l_new_default_date < l_defaulting_date then
      if l_defaulting_met then
        --
        -- Pull back the start dates of all tax rules and element entries.
        --
        pull_back_taxes(p_assignment_id       => p_assignment_id
                       ,p_emp_fed_tax_rule_id => l_emp_fed_tax_rule_id
                       ,p_fed_eed             => l_fed_eed
                       ,p_new_default_date    => l_new_default_date
                       ,p_defaulting_date     => l_defaulting_date
                       );
        --
      else             -- hire_date is given, pull back, defaulting not met
        --
        -- Reset the element entries to the old default date in case they were
        -- moved.
        --
        reset_element_entries(p_assignment_id       => p_assignment_id
                             ,p_emp_fed_tax_rule_id => l_emp_fed_tax_rule_id
                             ,p_fed_eed             => l_fed_eed
                             ,p_defaulting_date     => l_defaulting_date
                             );
        --
      end if;          -- hire date given, pull back, defaulting met?
      --
    elsif l_new_default_date > l_defaulting_date then   -- hire_date given, push
                                                        -- forward
      --
      push_forward_taxes(p_assignment_id       => p_assignment_id
                        ,p_fed_eed             => l_fed_eed
                        ,p_new_default_date    => l_new_default_date
                        ,p_defaulting_date     => l_defaulting_date
                        );
      --
    end if;          -- pull back / push forward?
  end if;          -- hire date is not null?
  --
  --
  -- This section handles the cases where this procedure is called from a change
  -- to the assignment, i.e., l_new_hire_date is null.  In these cases, the new
  -- defaulting date will be earlier than the current defaulting date.  If the
  -- change to the assignment occurred after the current defaulting date, the
  -- procedure for location changes would have been called.
  --
  if l_new_hire_date is null and l_new_default_date < l_defaulting_date then
    --
    if p_datetrack_mode = 'DELETE_NEXT_CHANGE' then
      if l_defaulting_met then
        --
        -- Pull back the start date of all tax rules and tax element entries.
        --
        pull_back_taxes(p_assignment_id       => p_assignment_id
                       ,p_emp_fed_tax_rule_id => l_emp_fed_tax_rule_id
                       ,p_fed_eed             => l_fed_eed
                       ,p_new_default_date    => l_new_default_date
                       ,p_defaulting_date     => l_defaulting_date
                       );
        --
      else      -- DELETE_NEXT_CHANGE, defaulting not met
        --
        if l_asg_eed = hr_api.g_eot then
          --
          -- This delete extends to the end of time, so it removes the taxes.
          --
          delete_fed_tax_rule(
                          p_effective_date        => l_defaulting_date
                         ,p_datetrack_delete_mode => 'ZAP'
                         ,p_assignment_id         => p_assignment_id
                         ,p_delete_routine        => 'ASSIGNMENT'
                         ,p_effective_start_date  => l_tmp_effective_start_date
                         ,p_effective_end_date    => l_tmp_effective_end_date
                         ,p_object_version_number => l_tmp_object_version_number
                         );
          --
        else        -- DELETE_NEXT_CHANGE, push defaulting date forward to
                    -- assignment break
          --
          push_forward_taxes(p_assignment_id       => p_assignment_id
                            ,p_fed_eed             => l_fed_eed
                            ,p_new_default_date    => l_asg_eed + 1
                            ,p_defaulting_date     => l_defaulting_date
                            );
          --
        end if;        -- DELETE_NEXT_CHANGE, l_fed_eed at end of time?
        --
      end if;        -- DELETE_NEXT_CHANGE, defaulting met?


    elsif p_datetrack_mode = 'FUTURE_CHANGE' then
      if l_defaulting_met then
        --
        -- Pull back the start date of all tax rules and tax element entries.
        --
        pull_back_taxes(p_assignment_id       => p_assignment_id
                       ,p_emp_fed_tax_rule_id => l_emp_fed_tax_rule_id
                       ,p_fed_eed             => l_fed_eed
                       ,p_new_default_date    => l_new_default_date
                       ,p_defaulting_date     => l_defaulting_date
                       );
        --
      else   -- FUTURE_CHANGE, defaulting not met
        --
        -- Purge all tax rules.
        --
        delete_fed_tax_rule(
                         p_effective_date        => l_defaulting_date
                        ,p_datetrack_delete_mode => 'ZAP'
                        ,p_assignment_id         => p_assignment_id
                        ,p_delete_routine        => 'ASSIGNMENT'
                        ,p_effective_start_date  => l_tmp_effective_start_date
                        ,p_effective_end_date    => l_tmp_effective_end_date
                        ,p_object_version_number => l_tmp_object_version_number
                           );
        --
      end if;      -- FUTURE_CHANGE, defaulting met?


    elsif p_datetrack_mode in('CORRECTION', 'UPDATE_CHANGE_INSERT') then
      if l_defaulting_met then
        if l_new_location_id is not null then
          --
          -- Pull back start date of federal tax rule and workers comp entry.
          --
          update pay_us_emp_fed_tax_rules_f
          set    effective_start_date = l_new_default_date
          where  assignment_id = p_assignment_id
          and    effective_start_date = l_defaulting_date;
          --
          maintain_wc(
                  p_emp_fed_tax_rule_id   => l_emp_fed_tax_rule_id
                 ,p_effective_start_date  => l_defaulting_date
                 ,p_effective_end_date    => l_fed_eed
                 ,p_effective_date        => l_new_default_date
                 ,p_datetrack_mode        => 'INSERT_OVERRIDE'
                 );
          --
          -- Create a break in the federal tax rule at the old defaulting date.
          -- Do the same for the workers comp entry.
          --
          open csr_fed_rec(p_assignment_id, l_defaulting_date);
          fetch csr_fed_rec into l_fed_rec;
            open csr_future_fed_rule(l_fed_rec.effective_end_date);
            fetch csr_future_fed_rule into l_temp_char;
            if csr_future_fed_rule%notfound then
              pay_fed_upd.upd(p_rec          => l_fed_rec
                             ,p_effective_date => l_defaulting_date
                             ,p_datetrack_mode => 'UPDATE');
            else
              pay_fed_upd.upd(p_rec          => l_fed_rec
                             ,p_effective_date => l_defaulting_date
                             ,p_datetrack_mode => 'UPDATE_CHANGE_INSERT');
            end if;
          close csr_future_fed_rule;
          close csr_fed_rec;
          --
          maintain_wc(
                  p_emp_fed_tax_rule_id   => l_emp_fed_tax_rule_id
                 ,p_effective_start_date  => l_new_default_date
                 ,p_effective_end_date    => l_fed_eed
                 ,p_effective_date        => l_defaulting_date
                 ,p_datetrack_mode        => 'INSERT_OLD'
                 );
          --
          -- Update the federal tax rule and workers comp entry to the new
          -- location at the new defaulting date.
          --
          open csr_fed_rec(p_assignment_id, l_new_default_date);
          fetch csr_fed_rec into l_fed_rec;
            l_fed_rec.sui_state_code := l_loc_ovrd_state_code;
            l_fed_rec.sui_jurisdiction_code := l_loc_ovrd_state_code||'-000-0000';
            pay_fed_upd.upd(p_rec          => l_fed_rec
                           ,p_effective_date => l_new_default_date
                           ,p_datetrack_mode => 'CORRECTION');
          close csr_fed_rec;
          --
          maintain_wc(
                  p_emp_fed_tax_rule_id   => l_emp_fed_tax_rule_id
                 ,p_effective_start_date  => l_new_default_date
                 ,p_effective_end_date    => l_fed_eed
                 ,p_effective_date        => l_new_default_date
                 ,p_datetrack_mode        => 'CORRECTION'
                 );
          --
          -- Pull back the state tax rule and %age to the new default date.
          -- Create a break in the %age at the old default date, then correct
          -- the location at the new default date.
          --
          for l_state_rec in csr_state_rec(p_assignment_id, l_defaulting_date)
          loop
            --
            update pay_us_emp_state_tax_rules_f
            set    effective_start_date = l_new_default_date
            where  effective_start_date = l_defaulting_date
            and    assignment_id = p_assignment_id
            and    state_code = l_state_rec.state_code;
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                        p_assignment_id        => p_assignment_id
                       ,p_effective_date       => l_new_default_date
                       ,p_state_code           => l_state_rec.state_code
                       ,p_county_code          => '000'
                       ,p_city_code            => '0000'
                       ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                       ,p_effective_start_date => l_tmp_effective_start_date
                       ,p_effective_end_date   => l_tmp_effective_end_date
                       ,p_calculate_pct        => FALSE
                       );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_defaulting_date
                     ,p_state_code           => l_state_rec.state_code
                     ,p_county_code          => '000'
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OLD'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_state_rec.state_code
                     ,p_county_code          => '000'
                     ,p_city_code            => '0000'
                     ,p_percentage           => 0
                     ,p_datetrack_mode       => 'CORRECTION'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
          --
          end loop;        -- l_state_rec
          --
          -- Pull back the county tax rule and %age to the new default date.
          -- Create a break in the %age at the old default date, then correct
          -- the location at the new default date.
          --
          for l_county_rec in csr_county_rec(p_assignment_id, l_defaulting_date)
          loop
            --
            update pay_us_emp_county_tax_rules_f
            set    effective_start_date = l_new_default_date
            where  effective_start_date = l_defaulting_date
            and    assignment_id = p_assignment_id
            and    state_code = l_county_rec.state_code
            and    county_code = l_county_rec.county_code;
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_county_rec.state_code
                     ,p_county_code          => l_county_rec.county_code
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_defaulting_date
                     ,p_state_code           => l_county_rec.state_code
                     ,p_county_code          => l_county_rec.county_code
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OLD'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_county_rec.state_code
                     ,p_county_code          => l_county_rec.county_code
                     ,p_city_code            => '0000'
                     ,p_percentage           => 0
                     ,p_datetrack_mode       => 'CORRECTION'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
          --
          end loop;        -- l_county_rec
          --
          -- Pull back the city tax rule and %age to the new default date.
          -- Create a break in the %age at the old default date, then correct
          -- the location at the new default date.
          --
          for l_city_rec in csr_city_rec(p_assignment_id, l_defaulting_date)
          loop
            --
            update pay_us_emp_city_tax_rules_f
            set    effective_start_date = l_new_default_date
            where  effective_start_date = l_defaulting_date
            and    assignment_id = p_assignment_id
            and    state_code = l_city_rec.state_code
            and    county_code = l_city_rec.county_code
            and    city_code = l_city_rec.city_code;
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_city_rec.state_code
                     ,p_county_code          => l_city_rec.county_code
                     ,p_city_code            => l_city_rec.city_code
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_defaulting_date
                     ,p_state_code           => l_city_rec.state_code
                     ,p_county_code          => l_city_rec.county_code
                     ,p_city_code            => l_city_rec.city_code
                     ,p_datetrack_mode       => 'INSERT_OLD'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            if l_loc_ovrd_state_code||'-'||l_loc_ovrd_county_code||'-'||l_loc_ovrd_city_code =
               l_city_rec.state_code||'-'||l_city_rec.county_code||
               '-'||l_city_rec.city_code then
              l_city_pct := 100;
            else
              l_city_pct := 0;
            end if;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_city_rec.state_code
                     ,p_county_code          => l_city_rec.county_code
                     ,p_city_code            => l_city_rec.city_code
                     ,p_percentage           => l_city_pct
                     ,p_datetrack_mode       => 'CORRECTION'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
          --
          end loop;        -- l_city_rec
          --
        else       -- CORRECTION or UPD_CHG_INS, defaulting met, same location
          --
          -- Pull back the start date of all tax rules and tax element entries.
          --
          pull_back_taxes(p_assignment_id       => p_assignment_id
                         ,p_emp_fed_tax_rule_id => l_emp_fed_tax_rule_id
                         ,p_fed_eed             => l_fed_eed
                         ,p_new_default_date    => l_new_default_date
                         ,p_defaulting_date     => l_defaulting_date
                         );
          --
        end if;      -- CORRECTION, defaulting met, l_new_location_id is null?
          --
      else       -- CORRECTION, defaulting not met
        --
        -- Reset start date of tax element entries to old default date.  In some
        -- cases, changes to an assignment will move the element entries.  In
        -- this case, the tax entries should not be moved.  Nothing needs to be
        -- done for the tax rules.
        --
        reset_element_entries(p_assignment_id       => p_assignment_id
                             ,p_emp_fed_tax_rule_id => l_emp_fed_tax_rule_id
                             ,p_fed_eed             => l_fed_eed
                             ,p_defaulting_date     => l_defaulting_date
                             );
        --
      end if;       -- CORRECTION, defaulting_met?



    elsif p_datetrack_mode = 'UPDATE_OVERRIDE' then
      --
      if l_defaulting_met then
        if l_new_location_id is not null then
          --
          -- Purge the taxes, then create new default records at the new default
          -- date for the new location.
          --
          delete_fed_tax_rule (
               p_effective_date        => l_defaulting_date
              ,p_datetrack_delete_mode => 'ZAP'
              ,p_assignment_id         => p_assignment_id
              ,p_delete_routine        => 'ASSIGNMENT'
              ,p_effective_start_date  => l_tmp_effective_start_date
              ,p_effective_end_date    => l_tmp_effective_end_date
              ,p_object_version_number => l_tmp_object_version_number
              );
          --
          create_default_tax_rules (
               p_effective_date        => l_defaulting_date
              ,p_assignment_id         => p_assignment_id
              ,p_emp_fed_tax_rule_id   => l_emp_fed_tax_rule_id
              ,p_fed_object_version_number => l_tmp_object_version_number
              ,p_fed_effective_start_date  => l_tmp_effective_start_date
              ,p_fed_effective_end_date    => l_tmp_effective_end_date
              );
          --
        else         -- UPDATE_OVERRIDE, defaulting met, same location
          --
          -- Pull back the start date of the federal tax rule and the workers
          -- comp element entry.
          --
          update pay_us_emp_fed_tax_rules_f
          set    effective_start_date = l_new_default_date
          where  assignment_id = p_assignment_id
          and    effective_start_date = l_defaulting_date;
          --
          maintain_wc(
                  p_emp_fed_tax_rule_id   => l_emp_fed_tax_rule_id
                 ,p_effective_start_date  => l_defaulting_date
                 ,p_effective_end_date    => l_fed_eed
                 ,p_effective_date        => l_new_default_date
                 ,p_datetrack_mode        => 'INSERT_OVERRIDE'
                 );
          --
          -- Correct the sui_state of all future federal tax rule and the
          -- workers comp element entry rows.
          --
          l_loc_state_code := null;
          for l_fed_rec in csr_fed_rows(p_assignment_id, l_defaulting_date)
          loop
            l_loc_state_code := nvl(l_loc_state_code, l_fed_rec.sui_state_code);
            l_fed_rec.sui_state_code := l_loc_state_code;
            l_fed_rec.sui_jurisdiction_code := l_loc_state_code||'-000-0000';
/* changes for bug 1970341 possible a DB issue. */
--      l_fed_rec_dup := l_fed_rec;

      l_fed_rec_dup.emp_fed_tax_rule_id       := l_fed_rec.emp_fed_tax_rule_id;
      l_fed_rec_dup.effective_start_date      := l_fed_rec.effective_start_date;
      l_fed_rec_dup.effective_end_date        := l_fed_rec.effective_end_date;
      l_fed_rec_dup.assignment_id             := l_fed_rec.assignment_id;
      l_fed_rec_dup.sui_state_code            := l_fed_rec.sui_state_code;
      l_fed_rec_dup.sui_jurisdiction_code     := l_fed_rec.sui_jurisdiction_code ;
      l_fed_rec_dup.business_group_id         := l_fed_rec.business_group_id;
      l_fed_rec_dup.additional_wa_amount      := l_fed_rec.additional_wa_amount;
      l_fed_rec_dup.filing_status_code        := l_fed_rec.filing_status_code;
      l_fed_rec_dup.fit_override_amount       := l_fed_rec.fit_override_amount;
      l_fed_rec_dup.fit_override_rate         := l_fed_rec.fit_override_rate;
      l_fed_rec_dup.withholding_allowances    := l_fed_rec.withholding_allowances;
      l_fed_rec_dup.cumulative_taxation       := l_fed_rec.cumulative_taxation;
      l_fed_rec_dup.eic_filing_status_code    := l_fed_rec.eic_filing_status_code;
      l_fed_rec_dup.fit_additional_tax        := l_fed_rec.fit_additional_tax;
      l_fed_rec_dup.fit_exempt                := l_fed_rec.fit_exempt;
      l_fed_rec_dup.futa_tax_exempt           := l_fed_rec.futa_tax_exempt;
      l_fed_rec_dup.medicare_tax_exempt       := l_fed_rec.medicare_tax_exempt;
      l_fed_rec_dup.ss_tax_exempt             := l_fed_rec.ss_tax_exempt;
      l_fed_rec_dup.wage_exempt               := l_fed_rec.wage_exempt;
      l_fed_rec_dup.statutory_employee        := l_fed_rec.statutory_employee;
      l_fed_rec_dup.w2_filed_year             := l_fed_rec.w2_filed_year;
      l_fed_rec_dup.supp_tax_override_rate    := l_fed_rec.supp_tax_override_rate;
      l_fed_rec_dup.excessive_wa_reject_date  := l_fed_rec.excessive_wa_reject_date;
      l_fed_rec_dup.object_version_number     := l_fed_rec.object_version_number ;
      l_fed_rec_dup.attribute_category        := l_fed_rec.attribute_category;
      l_fed_rec_dup.attribute1                := l_fed_rec.attribute1;
      l_fed_rec_dup.attribute2                := l_fed_rec.attribute2;
      l_fed_rec_dup.attribute3                := l_fed_rec.attribute3;
      l_fed_rec_dup.attribute4                := l_fed_rec.attribute4;
      l_fed_rec_dup.attribute5                := l_fed_rec.attribute5;
      l_fed_rec_dup.attribute6                := l_fed_rec.attribute6;
      l_fed_rec_dup.attribute7                := l_fed_rec.attribute7;
      l_fed_rec_dup.attribute8                := l_fed_rec.attribute8;
      l_fed_rec_dup.attribute9                := l_fed_rec.attribute9;
      l_fed_rec_dup.attribute10               := l_fed_rec.attribute10;
      l_fed_rec_dup.attribute11               := l_fed_rec.attribute11;
      l_fed_rec_dup.attribute12               := l_fed_rec.attribute12;
      l_fed_rec_dup.attribute13               := l_fed_rec.attribute13;
      l_fed_rec_dup.attribute14               := l_fed_rec.attribute14;
      l_fed_rec_dup.attribute15               := l_fed_rec.attribute15;
      l_fed_rec_dup.attribute16               := l_fed_rec.attribute16;
      l_fed_rec_dup.attribute17               := l_fed_rec.attribute17;
      l_fed_rec_dup.attribute18               := l_fed_rec.attribute18;
      l_fed_rec_dup.attribute19               := l_fed_rec.attribute19;
      l_fed_rec_dup.attribute20               := l_fed_rec.attribute20;
      l_fed_rec_dup.attribute21               := l_fed_rec.attribute21;
      l_fed_rec_dup.attribute22               := l_fed_rec.attribute22;
      l_fed_rec_dup.attribute23               := l_fed_rec.attribute23;
      l_fed_rec_dup.attribute24               := l_fed_rec.attribute24;
      l_fed_rec_dup.attribute25               := l_fed_rec.attribute25;
      l_fed_rec_dup.attribute26               := l_fed_rec.attribute26;
      l_fed_rec_dup.attribute27               := l_fed_rec.attribute27;
      l_fed_rec_dup.attribute28               := l_fed_rec.attribute28;
      l_fed_rec_dup.attribute29               := l_fed_rec.attribute29;
      l_fed_rec_dup.attribute30               := l_fed_rec.attribute30;
      l_fed_rec_dup.fed_information_category  := l_fed_rec.fed_information_category;
      l_fed_rec_dup.fed_information1          := l_fed_rec.fed_information1;
      l_fed_rec_dup.fed_information2          := l_fed_rec.fed_information2;
      l_fed_rec_dup.fed_information3          := l_fed_rec.fed_information3;
      l_fed_rec_dup.fed_information4          := l_fed_rec.fed_information4;
      l_fed_rec_dup.fed_information5          := l_fed_rec.fed_information5;
      l_fed_rec_dup.fed_information6          := l_fed_rec.fed_information6;
      l_fed_rec_dup.fed_information7          := l_fed_rec.fed_information7;
      l_fed_rec_dup.fed_information8          := l_fed_rec.fed_information8;
      l_fed_rec_dup.fed_information9          := l_fed_rec.fed_information9;
      l_fed_rec_dup.fed_information10         := l_fed_rec.fed_information10;
      l_fed_rec_dup.fed_information11         := l_fed_rec.fed_information11;
      l_fed_rec_dup.fed_information12         := l_fed_rec.fed_information12;
      l_fed_rec_dup.fed_information13         := l_fed_rec.fed_information13;
      l_fed_rec_dup.fed_information14         := l_fed_rec.fed_information14;
      l_fed_rec_dup.fed_information15         := l_fed_rec.fed_information15;
      l_fed_rec_dup.fed_information16         := l_fed_rec.fed_information16;
      l_fed_rec_dup.fed_information17         := l_fed_rec.fed_information17;
      l_fed_rec_dup.fed_information18         := l_fed_rec.fed_information18;
      l_fed_rec_dup.fed_information19         := l_fed_rec.fed_information19;
      l_fed_rec_dup.fed_information20         := l_fed_rec.fed_information20;
      l_fed_rec_dup.fed_information21         := l_fed_rec.fed_information21;
      l_fed_rec_dup.fed_information22         := l_fed_rec.fed_information22;
      l_fed_rec_dup.fed_information23         := l_fed_rec.fed_information23;
      l_fed_rec_dup.fed_information24         := l_fed_rec.fed_information24;
      l_fed_rec_dup.fed_information25         := l_fed_rec.fed_information25;
      l_fed_rec_dup.fed_information26         := l_fed_rec.fed_information26;
      l_fed_rec_dup.fed_information27         := l_fed_rec.fed_information27;
      l_fed_rec_dup.fed_information28         := l_fed_rec.fed_information28;
      l_fed_rec_dup.fed_information29         := l_fed_rec.fed_information29;
      l_fed_rec_dup.fed_information30         := l_fed_rec.fed_information30;

/* changes for bug 1970341 possible a DB issue. */

            pay_fed_upd.upd(p_rec            => l_fed_rec_dup
                         ,p_effective_date => l_fed_rec_dup.effective_start_date
                         ,p_datetrack_mode => 'CORRECTION');
            maintain_wc(
                  p_emp_fed_tax_rule_id   => l_emp_fed_tax_rule_id
                 ,p_effective_start_date  => l_fed_rec_dup.effective_start_date
                 ,p_effective_end_date    => l_fed_rec_dup.effective_end_date
                 ,p_effective_date        => l_fed_rec_dup.effective_start_date
                 ,p_datetrack_mode        => 'CORRECTION'
                 );
          end loop;
          --
          -- Pull back the state tax rule and %age to the new default date.
          -- Then delete future changes on the %ages.
          --
          for l_state_rec in csr_state_rec(p_assignment_id, l_defaulting_date)
          loop
            --
            update pay_us_emp_state_tax_rules_f
            set    effective_start_date = l_new_default_date
            where  effective_start_date = l_defaulting_date
            and    assignment_id = p_assignment_id
            and    state_code = l_state_rec.state_code;
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_state_rec.state_code
                     ,p_county_code          => '000'
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_state_rec.state_code
                     ,p_county_code          => '000'
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'FUTURE_CHANGE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
          --
          end loop;        -- l_state_rec
          --
          -- Pull back the county tax rule and %age to the new default date.
          -- Then delete future changes on the %ages.
          --
          for l_county_rec in csr_county_rec(p_assignment_id, l_defaulting_date)
          loop
            --
            update pay_us_emp_county_tax_rules_f
            set    effective_start_date = l_new_default_date
            where  effective_start_date = l_defaulting_date
            and    assignment_id = p_assignment_id
            and    state_code = l_county_rec.state_code
            and    county_code = l_county_rec.county_code;
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_county_rec.state_code
                     ,p_county_code          => l_county_rec.county_code
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                     p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_county_rec.state_code
                     ,p_county_code          => l_county_rec.county_code
                     ,p_city_code            => '0000'
                     ,p_datetrack_mode       => 'FUTURE_CHANGE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
          --
          end loop;        -- l_county_rec
          --
          -- Pull back the city tax rule and %age to the new default date.
          -- Then delete future changes on the %ages.
          --
          for l_city_rec in csr_city_rec(p_assignment_id, l_defaulting_date)
          loop
            --
            update pay_us_emp_city_tax_rules_f
            set    effective_start_date = l_new_default_date
            where  effective_start_date = l_defaulting_date
            and    assignment_id = p_assignment_id
            and    state_code = l_city_rec.state_code
            and    county_code = l_city_rec.county_code
            and    city_code = l_city_rec.city_code;
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_city_rec.state_code
                     ,p_county_code          => l_city_rec.county_code
                     ,p_city_code            => l_city_rec.city_code
                     ,p_datetrack_mode       => 'INSERT_OVERRIDE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
            --
            --
            l_tmp_effective_start_date := l_defaulting_date;
            l_tmp_effective_end_date   := l_fed_eed;
            maintain_tax_percentage(
                      p_assignment_id        => p_assignment_id
                     ,p_effective_date       => l_new_default_date
                     ,p_state_code           => l_city_rec.state_code
                     ,p_county_code          => l_city_rec.county_code
                     ,p_city_code            => l_city_rec.city_code
                     ,p_datetrack_mode       => 'FUTURE_CHANGE'
                     ,p_effective_start_date => l_tmp_effective_start_date
                     ,p_effective_end_date   => l_tmp_effective_end_date
                     ,p_calculate_pct        => FALSE
                     );
          --
          end loop;        -- l_city_rec
          --
          --
        end if;      -- UPDATE_OVERRIDE, defaulting met, location null?
      else           -- UPDATE_OVERRIDE, defaulting not met
        --
        -- Remove all tax records for this assignment.
        --
        delete_fed_tax_rule (
             p_effective_date        => l_defaulting_date
            ,p_datetrack_delete_mode => 'ZAP'
            ,p_assignment_id         => p_assignment_id
            ,p_delete_routine        => 'ASSIGNMENT'
            ,p_effective_start_date  => l_tmp_effective_start_date
            ,p_effective_end_date    => l_tmp_effective_end_date
            ,p_object_version_number => l_tmp_object_version_number
            );
        --
      end if;        -- UPDATE_OVERRIDE, defaulting_met?


    else          -- hire date is null, datetrack mode is invalid
      --
      hr_utility.set_message(801,'HR_7184_DT_MODE_UNKNOWN');
      hr_utility.set_message_token('DT_MODE',p_datetrack_mode);
      hr_utility.raise_error;
      --
    end if;       -- hire date is null, branching on datetrack mode
  end if;        -- hire date is null and new default < old default
  --
  --
  -- If the state, county or city tax rules for the new location do
  -- not exist, create them.
  --
  if l_new_location_id is not null and l_defaulting_met then
    --
    create_tax_rules_for_jd(p_effective_date      => l_new_default_date
                          ,p_assignment_id        => p_assignment_id
                          ,p_state_code           => l_loc_state_code
	  		  ,p_county_code	  => l_loc_county_code
		  	  ,p_city_code		  => l_loc_city_code
                          );

    create_tax_rules_for_jd(p_effective_date      => l_new_default_date
                          ,p_assignment_id        => p_assignment_id
                          ,p_state_code           => l_loc_ovrd_state_code
	  		  ,p_county_code	  => l_loc_ovrd_county_code
		  	  ,p_city_code		  => l_loc_ovrd_city_code
                          );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 130);
  --
exception
  --
  when l_exit_quietly then
    --
    hr_utility.set_location(' Leaving:'||l_proc, 135);
  --
end move_tax_default_date;


--
End pay_us_tax_internal;

/
