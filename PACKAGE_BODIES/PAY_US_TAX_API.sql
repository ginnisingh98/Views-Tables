--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_API" AS
/* $Header: pytaxapi.pkb 115.8 2003/06/03 17:39:29 tclewis ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_us_tax_api.';
-- ----------------------------------------------------------------------------
-- |---------------------< correct_tax_percentage >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure correct_tax_percentage
             (
              p_validate                  boolean default false
             ,p_assignment_id             number
             ,p_effective_date            date
             ,p_state_code                varchar2
             ,p_county_code               varchar2
             ,p_city_code                 varchar2
             ,p_percentage                number
            ) is
   l_effective_start_date date := p_effective_date;
   l_effective_end_date   date;
   l_proc                 varchar2(72) := g_package||'correct_tax_percentage';
begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    pay_us_tax_internal.maintain_tax_percentage
       (
        p_assignment_id          => p_assignment_id,
        p_effective_date         => p_effective_date,
        p_state_code             => p_state_code,
        p_county_code            => p_county_code,
        p_city_code              => p_city_code,
        p_percentage             => p_percentage,
        p_datetrack_mode         => 'CORRECTION',
        p_calculate_pct          => TRUE,
        p_effective_start_date   => l_effective_start_date,
        p_effective_end_date     => l_effective_end_date
       );
    hr_utility.set_location('Leaving:'||l_proc, 20);
end correct_tax_percentage;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_tax_rule >---------------------------|
-- ----------------------------------------------------------------------------
-- Deletes the tax rule(s) and percentages for a given jurisdiction as well as
-- deleting all subordinate jurisdictions and their respective tax percentages.
--
procedure delete_tax_rule
  (p_validate                       in     boolean  default false
  ,p_assignment_id                  in     number
  ,p_state_code                     in     varchar2
  ,p_county_code                    in     varchar2 default '000'
  ,p_city_code                      in     varchar2 default '0000'
  ,p_effective_start_date           out nocopy   date
  ,p_effective_end_date             out nocopy   date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2 default 'ZAP'
  ,p_delete_routine                 in     varchar2 default null
  ) is
  --
  -- Declare types, cursors and local variables
  --
  TYPE gen_rec is RECORD
     (
      state_code            pay_us_emp_city_tax_rules_f.state_code%TYPE,
      county_code           pay_us_emp_city_tax_rules_f.state_code%TYPE,
      city_code             pay_us_emp_city_tax_rules_f.state_code%TYPE,
      object_version_number number
     );
  --
  --
  -- Find the city_tax_rule_id, object_version_number,
  -- and effective_start and end dates for the current jurisdiction.
  --
  Cursor get_city_tax_rule_id(l_jurisdiction varchar2) is
     select emp_city_tax_rule_id, object_version_number,
            effective_start_date, effective_end_date
     from pay_us_emp_city_tax_rules_f
     where assignment_id = p_assignment_id
       and jurisdiction_code = l_jurisdiction
       and p_effective_date between effective_start_date
           and effective_end_date;
  --
  -- Find the county_tax_rule_id, object_version_number,
  -- and effective_start and end dates for the current jurisdiction.
  --
  Cursor get_county_tax_rule_id(l_jurisdiction varchar2) is
     select emp_county_tax_rule_id, object_version_number,
            effective_start_date, effective_end_date
     from pay_us_emp_county_tax_rules_f
     where assignment_id = p_assignment_id
       and jurisdiction_code = l_jurisdiction
       and p_effective_date between effective_start_date
           and effective_end_date;
  --
  -- Find the state_tax_rule_id, object_version_number,
  -- and effective_start and end dates for the current jurisdiction.
  --
  Cursor get_state_tax_rule_id(l_jurisdiction varchar2) is
     select emp_state_tax_rule_id, object_version_number,
            effective_start_date, effective_end_date
     from pay_us_emp_state_tax_rules_f
     where assignment_id = p_assignment_id
       and jurisdiction_code = l_jurisdiction
       and p_effective_date between effective_start_date
           and effective_end_date;
  --
  -- Find all cities under county jurisdiction
  --
  cursor csr_city_parm_sel is
     select state_code, county_code,
            city_code, object_version_number
     from pay_us_emp_city_tax_rules_f
     where assignment_id = p_assignment_id
       and state_code = p_state_code
       and county_code = p_county_code
       and (city_code <> '0000'
           and city_code is not null)
       and p_effective_date
     between effective_start_date
       and effective_end_date;
  --
  -- Find all counties under state jurisdiction
  --
  cursor csr_county_parm_sel is
     select state_code, county_code,
            '0000' city_code, object_version_number
     from pay_us_emp_county_tax_rules_f
     where assignment_id = p_assignment_id
       and state_code = p_state_code
       and (county_code <> '000'
       and county_code is not null)
       and p_effective_date
       between effective_start_date
          and effective_end_date;
  --
  --
  --
  cursor csr_chk_vertex_exist(
                              p_jurisdiction   varchar2,
                              p_effective_date date
                             ) is
     select count(*)
     from pay_element_entries_f peef,
          pay_element_entry_values_f peevf,
          pay_element_types_f petf,
          pay_element_links_f pelf
     where peef.assignment_id=p_assignment_id
       and p_effective_date < peef.effective_end_date
       and petf.element_name='VERTEX'
       and pelf.element_type_id=petf.element_type_id
       and peef.element_link_id=pelf.element_link_id
       and peevf.screen_entry_value = p_jurisdiction
       and p_effective_date < peevf.effective_end_date
       and peevf.element_entry_id = peef.element_entry_id;

  /*
     Constants
  */
  CITY_JURISDICTION   constant number := 1;
  COUNTY_JURISDICTION constant number := 2;
  STATE_JURISDICTION  constant number := 3;

  l_proc                   varchar2(72) := g_package||'delete_tax_rule';
  l_jurisdiction_code      pay_us_emp_state_tax_rules.jurisdiction_code%TYPE;
  l_object_version_number
                        pay_us_emp_city_tax_rules_f.object_version_number%TYPE;
  l_effective_start_date pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
  l_effective_end_date     pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
  l_emp_city_tax_rule_id pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE;
  l_emp_county_tax_rule_id
                     pay_us_emp_county_tax_rules_f.emp_county_tax_rule_id%TYPE;
  l_emp_state_tax_rule_id
                       pay_us_emp_state_tax_rules_f.emp_state_tax_rule_id%TYPE;
  l_element_entry_id       pay_element_entries_f.element_entry_id%TYPE;
  t_effective_start_date pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
  l_effective_date       pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
  l_vertex_exist           number;
  l_delete_jurisdiction    number;
  l_parm_sel               varchar2(2000);
  l_jurisdiction_rec       gen_rec;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
    savepoint delete_tax_rule;

  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Process Logic
  --
  l_jurisdiction_code := p_state_code||'-'
                       ||p_county_code||'-'
                       ||p_city_code;
  --
  if p_city_code <> '0000' then
     hr_utility.set_location(l_proc, 20);
     l_delete_jurisdiction := CITY_JURISDICTION;
     -- just delete the city.
  elsif p_county_code <> '000' and p_city_code = '0000' then
     hr_utility.set_location(l_proc, 25);
     l_delete_jurisdiction := COUNTY_JURISDICTION;
     -- find all of the cities, then delete them
     for l_jurisdiction_rec in csr_city_parm_sel loop
        delete_tax_rule
           (
            p_validate               => FALSE
           ,p_assignment_id          => p_assignment_id
           ,p_state_code             => l_jurisdiction_rec.state_code
           ,p_county_code            => l_jurisdiction_rec.county_code
           ,p_city_code              => l_jurisdiction_rec.city_code
           ,p_effective_start_date   => l_effective_start_date
           ,p_effective_end_date     => l_effective_end_date
           ,p_object_version_number  => l_jurisdiction_rec.object_version_number
           ,p_effective_date         => p_effective_date
           ,p_datetrack_mode         => p_datetrack_mode
           ,p_delete_routine         => p_delete_routine
           );
     end loop;
  elsif p_state_code is not null and p_county_code = '000'
    and p_city_code = '0000' then
     hr_utility.set_location(l_proc, 30);
     l_delete_jurisdiction := STATE_JURISDICTION;
     -- find all of the counties then delete them
     for l_jurisdiction_rec in csr_county_parm_sel loop
        delete_tax_rule
           (
            p_validate               => FALSE
           ,p_assignment_id          => p_assignment_id
           ,p_state_code             => l_jurisdiction_rec.state_code
           ,p_county_code            => l_jurisdiction_rec.county_code
           ,p_city_code              => l_jurisdiction_rec.city_code
           ,p_effective_start_date   => l_effective_start_date
           ,p_effective_end_date     => l_effective_end_date
           ,p_object_version_number  => l_jurisdiction_rec.object_version_number
           ,p_effective_date         => p_effective_date
           ,p_datetrack_mode         => p_datetrack_mode
           ,p_delete_routine         => p_delete_routine
           );
     end loop;
  end if;
  --
  --
  l_object_version_number := p_object_version_number;
  --
  if l_delete_jurisdiction = CITY_JURISDICTION then
    --
    --
    --
    open get_city_tax_rule_id(l_jurisdiction_code);
    fetch get_city_tax_rule_id into l_emp_city_tax_rule_id,
                                    l_object_version_number,
                                    l_effective_start_date,
                                    l_effective_end_date;
    if get_city_tax_rule_id%FOUND then
       close get_city_tax_rule_id;
       --
       hr_utility.set_location(l_proc, 40);
       --
       pay_cty_del.del
          (
           p_emp_city_tax_rule_id          => l_emp_city_tax_rule_id
          ,p_effective_start_date          => l_effective_start_date
          ,p_effective_end_date            => l_effective_end_date
          ,p_object_version_number         => l_object_version_number
          ,p_effective_date                => p_effective_date
          ,p_datetrack_mode                => p_datetrack_mode
          ,p_delete_routine                => p_delete_routine
          );
    else
       close get_city_tax_rule_id;
       hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
       hr_utility.set_message_token('table', 'pay_us_emp_city_tax_rules_f');
       hr_utility.set_message_token('step','45');
       hr_utility.raise_error;
    end if;
  elsif l_delete_jurisdiction = COUNTY_JURISDICTION then
     --
     --
     --
     open get_county_tax_rule_id(l_jurisdiction_code);
     fetch get_county_tax_rule_id into l_emp_county_tax_rule_id,
                                       l_object_version_number,
                                       l_effective_start_date,
                                       l_effective_end_date;
     if get_county_tax_rule_id%FOUND then
        close get_county_tax_rule_id;
        --
        hr_utility.set_location(l_proc, 50);
        --
        pay_cnt_del.del
           (
            p_emp_county_tax_rule_id        => l_emp_county_tax_rule_id
           ,p_effective_start_date          => l_effective_start_date
           ,p_effective_end_date            => l_effective_end_date
           ,p_object_version_number         => l_object_version_number
           ,p_effective_date                => p_effective_date
           ,p_datetrack_mode                => p_datetrack_mode
           ,p_delete_routine                => p_delete_routine
           );
     else
        close get_county_tax_rule_id;
        hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
        hr_utility.set_message_token('table', 'pay_us_emp_county_tax_rules_f');
        hr_utility.set_message_token('step','55');
        hr_utility.raise_error;
     end if;
  elsif l_delete_jurisdiction = STATE_JURISDICTION then
     --
     --
     --
     open get_state_tax_rule_id(l_jurisdiction_code);
     fetch get_state_tax_rule_id into l_emp_state_tax_rule_id,
                                      l_object_version_number,
                                      l_effective_start_date,
                                      l_effective_end_date;
     if get_state_tax_rule_id%FOUND then
        close get_state_tax_rule_id;
        --
        hr_utility.set_location(l_proc, 60);
        --
        pay_sta_del.del
           (
            p_emp_state_tax_rule_id         => l_emp_state_tax_rule_id
           ,p_effective_start_date          => l_effective_start_date
           ,p_effective_end_date            => l_effective_end_date
           ,p_object_version_number         => l_object_version_number
           ,p_effective_date                => p_effective_date
           ,p_datetrack_mode                => p_datetrack_mode
           ,p_delete_routine                => p_delete_routine
           );
     else
        close get_state_tax_rule_id;
        hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
        hr_utility.set_message_token('table', 'pay_us_emp_state_tax_rules_f');
        hr_utility.set_message_token('step','65');
        hr_utility.raise_error;
     end if;
  end if;
  --
  if p_datetrack_mode = 'DELETE' then
     l_effective_date := p_effective_date;
  else
     l_effective_date := hr_api.g_date;
  end if;
  open csr_chk_vertex_exist(l_jurisdiction_code, l_effective_date);
  fetch csr_chk_vertex_exist into l_vertex_exist;
  t_effective_start_date := p_effective_date;
  if csr_chk_vertex_exist%FOUND then
     --
     hr_utility.set_location(l_proc, 35);
     --
     pay_us_tax_internal.maintain_tax_percentage
        (
         p_assignment_id          => p_assignment_id,
         p_effective_date         => p_effective_date,
         p_state_code             => p_state_code,
         p_county_code            => p_county_code,
         p_city_code              => p_city_code,
         p_datetrack_mode         => p_datetrack_mode,
         p_calculate_pct          => FALSE,
         p_effective_start_date   => t_effective_start_date,
         p_effective_end_date     => l_effective_end_date
        );
  end if;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_tax_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO delete_tax_rule;
    raise;
    --
end delete_tax_rule;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< submit_fed_w4 >--------------------------------|
-- ----------------------------------------------------------------------------
procedure submit_fed_w4
(
   p_validate                    IN     boolean    default false
  ,p_person_id		         IN     number
  ,p_effective_date              IN     date
  ,p_source_name	         IN     varchar2
  ,p_filing_status_code          IN     varchar2
  ,p_withholding_allowances      IN     number
  ,p_fit_additional_tax          IN     number
  ,p_fit_exempt                  IN     varchar2
  ,p_stat_trans_audit_id         OUT nocopy pay_stat_trans_audit.stat_trans_audit_id%TYPE
)
AS
	l_proc				VARCHAR2(80) := g_package || 'submit_fed_w4';
	lv_trans_type			VARCHAR2(30) := 'US_TAX_FORMS';
	lv_trans_subtype		VARCHAR2(30) := 'W4';
	ln_business_group_id		per_people_f.business_group_id%TYPE;
	ln_parent_audit_id		pay_stat_trans_audit.stat_trans_audit_id%TYPE;
	ln_assignment_id		per_assignments_f.assignment_id%TYPE;
	ln_gre_id			hr_organization_units.organization_id%TYPE;
	ln_fed_tax_rule_id		pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
	ln_ovn				pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
	ld_old_start_date		pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
	ld_start_date			pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
	ld_end_date			pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
	lv_filing_status_code		pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE;
	lv_state_filing_status_code 	pay_us_emp_state_tax_rules_f.filing_status_code%TYPE;
	lv_context			pay_stat_trans_audit.audit_information_category%TYPE;
	ln_dummy			NUMBER(15);
	lv_datetrack_mode		VARCHAR2(30);
	lv_update_method		VARCHAR2(30);
	l_primary_only			VARCHAR2(1);
	lv_update_error_msg		VARCHAR2(10000);

	CURSOR c_get_bg_id(p_person_id number) IS
		select  business_group_id
		from	per_people_f
		where	person_id = p_person_id;

	CURSOR c_fed_tax_rows IS
		select	ftr.emp_fed_tax_rule_id,
      			ftr.object_version_number,
			ftr.effective_start_date,
			paf.assignment_id,
			hsck.segment1
    		from	pay_us_emp_fed_tax_rules_f ftr, per_assignments_f paf,
			hr_soft_coding_keyflex hsck
    		where	paf.person_id = p_person_id
		  and	paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
		  and 	paf.assignment_id = ftr.assignment_id
		  and	paf.assignment_type = 'E'
		  and   decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
		  and 	p_effective_date between paf.effective_start_date and paf.effective_end_date
    		  and	p_effective_date between ftr.effective_start_date and ftr.effective_end_date
		  and 	not exists(	select 'x'
				   	from	hr_organization_information hoi,
						hr_soft_coding_keyflex sck
					where	paf.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
	  				  and	sck.segment1 = hoi.organization_id
	  				  and   hoi.org_information_context = '1099R Magnetic Report Rules')
    		for update nowait;

	CURSOR c_state_tax_rows IS
		select	str.emp_state_tax_rule_id,
      			str.object_version_number,
			str.effective_start_date,
			pus.state_abbrev,
			pus.state_code,
			paf.assignment_id,
			stif.sta_information7,
			hsck.segment1
    		from	pay_us_emp_state_tax_rules_f str, per_assignments_f paf,
			pay_us_state_tax_info_f stif, pay_us_states pus,
			hr_soft_coding_keyflex hsck
    		where	paf.person_id = p_person_id
		  and 	paf.assignment_id = str.assignment_id
		  and	paf.assignment_type = 'E'
		  and	paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
		  and 	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
		  and	str.state_code = stif.state_code
		  and 	str.state_code = pus.state_code
		  and	stif.sta_information7 like 'Y%'
		  and 	p_effective_date between stif.effective_start_date and stif.effective_end_date
		  and 	p_effective_date between paf.effective_start_date and paf.effective_end_date
    		  and	p_effective_date between str.effective_start_date and str.effective_end_date
		  and 	not exists(	select 'x'
				   	from	hr_organization_information hoi,
						hr_soft_coding_keyflex sck
					where	paf.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
	  				  and	sck.segment1 = hoi.organization_id
	  				  and   hoi.org_information_context = '1099R Magnetic Report Rules')
    		for update nowait;

	c_state_rec 	c_state_tax_rows%ROWTYPE;

  BEGIN

	hr_utility.set_location('Entering :' || l_proc, 10);
	-- set a savepoint before we do anything
	SAVEPOINT submit_fed_w4;

	-- get the update method
     	lv_update_method := 'PRIMARY';
	if lv_update_method = 'PRIMARY' then
		l_primary_only := 'Y';
	else
		l_primary_only := 'N';
	end if;

	-- lock records
	open c_state_tax_rows;
	open c_fed_tax_rows;

	-- get the bg of the person
	open c_get_bg_id(p_person_id);
	fetch c_get_bg_id into ln_business_group_id;
	if c_get_bg_id%NOTFOUND then
		close c_get_bg_id;
         	hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         	hr_utility.set_message_token('PROCEDURE',l_proc);
         	hr_utility.set_message_token('STEP','1');
         	hr_utility.raise_error;
	end if;
	close c_get_bg_id;

	-- make sure we can update
	lv_update_error_msg := chk_w4_allowed(p_person_id 	=> p_person_id,
					      p_effective_date	=> p_effective_date,
					      p_source_name	=> p_source_name
					     );
	if lv_update_error_msg is not null then
      		hr_utility.set_message(801, lv_update_error_msg);
      		hr_utility.raise_error;
	end if;
/*
    	begin
    	--
    	-- Start of API User Hook for the before hook of create_state_tax_rule
    	--
    	pay_tax_bk1.submit_fed_w4_b
    	(
   		p_source_name	 	   	=> p_source_name
  		,p_person_id         	  	=> p_person_id
  		,p_business_group_id     	=> ln_business_group_id
  		,p_filing_status_code           => p_filing_status_code
  		,p_withholding_allowances       => p_withholding_allowances
  		,p_fit_additional_tax           => p_fit_additional_tax
  		,p_fit_exempt                   => p_fit_exempt
  	);

  	exception
    	when hr_api.cannot_find_prog_unit then
      		hr_api.cannot_find_prog_unit_error
        	(
         		p_module_name => 'submit_fed_w4'
        		,p_hook_type   => 'BP'
        	);
    	--
    	-- End of API User Hook for the before hook of create_state_tax_rule
    	--
  	end;
*/
	hr_utility.set_location(l_proc, 20);
	-- start by putting a master w-4 transaction event which will be the
        -- parent for the rest of these transactions
	pay_aud_ins.ins(
  		 p_effective_date => p_effective_date
  	 	,p_transaction_type => lv_trans_type
		,p_transaction_subtype => lv_trans_subtype
  		,p_transaction_date => trunc(sysdate)
  		,p_transaction_effective_date => p_effective_date
  		,p_business_group_id => ln_business_group_id
  		,p_person_id => p_person_id
  		,p_source1 => '00-000-0000'
  		,p_source1_type => 'JURISDICTION'
  		,p_source3 => p_source_name
  		,p_source3_type => 'SOURCE_NAME'
		,p_audit_information_category => 'W4 FED'
  		,p_audit_information1 => p_filing_status_code
  		,p_audit_information2 => fnd_number.number_to_canonical(p_withholding_allowances)
  		,p_audit_information3 => fnd_number.number_to_canonical(p_fit_additional_tax)
  		,p_audit_information4 => p_fit_exempt
  		,p_stat_trans_audit_id => ln_parent_audit_id
  		,p_object_version_number => ln_ovn
  		);

	-- start by updating the fed tax records
	FETCH c_fed_tax_rows INTO ln_fed_tax_rule_id,
				  ln_ovn,
				  ld_old_start_date,
				  ln_assignment_id,
				  ln_gre_id;

	if c_fed_tax_rows%NOTFOUND then
		close c_fed_tax_rows;
         	hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         	hr_utility.set_message_token('PROCEDURE',l_proc);
         	hr_utility.set_message_token('STEP','2');
         	hr_utility.raise_error;
	end if;

	hr_utility.set_location(l_proc, 30);
	-- We loop on the cursor
	WHILE c_fed_tax_rows%FOUND LOOP
		-- We insert using datetrack mode of UPDATE
		-- future dated records will cause an error
		-- if the old start date = p_ef_date, we perform a correction instead
		if ld_old_start_date = p_effective_date then
			lv_datetrack_mode := 'CORRECTION';
		else
			lv_datetrack_mode := 'UPDATE';
		end if;

		hr_utility.trace('filing stat ' || ln_fed_tax_rule_id);
		pay_federal_tax_rule_api.update_fed_tax_rule
				(p_emp_fed_tax_rule_id 		=> ln_fed_tax_rule_id
				,p_withholding_allowances 	=> p_withholding_allowances
				,p_fit_additional_tax		=> p_fit_additional_tax
				,p_filing_status_code		=> p_filing_status_code
				,p_fit_exempt			=> p_fit_exempt
				,p_object_version_number 	=> ln_ovn
				,p_effective_start_date 	=> ld_start_date
				,p_effective_end_date		=> ld_end_date
				,p_effective_date		=> p_effective_date
				,p_datetrack_update_mode 	=> lv_datetrack_mode
				);

		-- we insert a row into the transaction table to show the change to this assignment
		pay_aud_ins.ins(
	  		 p_effective_date => p_effective_date
	  	 	,p_transaction_type => lv_trans_type
	  		,p_transaction_date => trunc(sysdate)
	  		,p_transaction_effective_date => p_effective_date
	  		,p_business_group_id => ln_business_group_id
	  		,p_transaction_subtype => lv_trans_subtype
  			,p_person_id => p_person_id
			,p_assignment_id => ln_assignment_id
  			,p_source1 => '00-000-0000'
  			,p_source1_type => 'JURISDICTION'
			,p_source2 => fnd_number.number_to_canonical(ln_gre_id)
			,p_source2_type => 'GRE'
  			,p_source3 => p_source_name
  			,p_source3_type => 'SOURCE_NAME'
			,p_transaction_parent_id => ln_parent_audit_id
  			,p_stat_trans_audit_id => ln_dummy
  			,p_object_version_number => ln_ovn
  			);

		-- as a sanity check we make sure that the dates are right
		if (ld_start_date <> p_effective_date) or
		   (ld_end_date <> hr_api.g_eot) then
	         	hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
	         	hr_utility.set_message_token('PROCEDURE',l_proc);
	         	hr_utility.set_message_token('STEP','2');
	         	hr_utility.raise_error;
		end if;

		-- we fetch the next row
		FETCH c_fed_tax_rows INTO ln_fed_tax_rule_id,ln_ovn,ld_old_start_date,
					  ln_assignment_id, ln_gre_id;
	end LOOP;

	-- next we update state tax records
	-- we don't update the amount withheld, because it is probably of a different magnitude
	-- then the state taxes.

	hr_utility.set_location(l_proc, 40);
	fetch c_state_tax_rows into c_state_rec;

	WHILE c_state_tax_rows%FOUND LOOP
		if c_state_rec.effective_start_date = p_effective_date then
			lv_datetrack_mode := 'CORRECTION';
		else
			lv_datetrack_mode := 'UPDATE';
		end if;

		-- We need to test whether or not the state being updated has a filing status
		-- that we are filing.  We do this by validating it in the state api.  If it fails
		-- validation, we default to single.

		-- Also, if the fed type is '03', we change it to '04' for the states
		if p_filing_status_code = '03' then
			lv_state_filing_status_code := '04';
		else
			lv_state_filing_status_code := p_filing_status_code;
		end if;

	        BEGIN

			lv_state_filing_status_code := '04'; -- fed '03' maps to state '04'
			pay_sta_bus.chk_filing_status_code(
					p_emp_state_tax_rule_id => null
					,p_state_code => c_state_rec.state_code
					,p_filing_status_code => lv_state_filing_status_code
					,p_effective_date => p_effective_date
					,p_validation_start_date => p_effective_date
					,p_validation_end_date => hr_api.g_eot
					);
		EXCEPTION
			WHEN OTHERS THEN
				lv_state_filing_status_code := '01';
		END;

		pay_state_tax_rule_api.update_state_tax_rule
				(p_emp_state_tax_rule_id => c_state_rec.emp_state_tax_rule_id
				,p_withholding_allowances => p_withholding_allowances
				,p_sit_additional_tax	=> 0
				,p_filing_status_code	=> lv_state_filing_status_code
				,p_sit_exempt		=> p_fit_exempt
				,p_object_version_number => c_state_rec.object_version_number
				,p_effective_start_date => ld_start_date
				,p_effective_end_date	=> ld_end_date
				,p_effective_date	=> p_effective_date
				,p_datetrack_update_mode => lv_datetrack_mode
				);

		-- when we insert into the transaction audit table, we only show
		-- where the child record is different from the parent record
		-- therefore, if state filing status <> fed filing status we
		-- store it, otherwise there is nothing stored except the child
		-- record info

		if p_filing_status_code <> lv_state_filing_status_code then
			lv_context := 'W4 FED';
		else
			lv_context := null;
			lv_state_filing_status_code := null;
		end if;


		-- insert a row in the transaction table
		pay_aud_ins.ins(
	  		 p_effective_date => p_effective_date
	  	 	,p_transaction_type => lv_trans_type
	  		,p_transaction_date => trunc(sysdate)
	  		,p_transaction_effective_date => p_effective_date
	  		,p_business_group_id => ln_business_group_id
	  		,p_transaction_subtype => lv_trans_subtype
  			,p_person_id => p_person_id
			,p_assignment_id => c_state_rec.assignment_id
  			,p_source1 => c_state_rec.state_code || '-000-0000'
  			,p_source1_type => 'JURISDICTION'
			,p_source2 => fnd_number.number_to_canonical(c_state_rec.segment1) --gre
			,p_source2_type => 'GRE'
  			,p_source3 => p_source_name
  			,p_source3_type => 'SOURCE_NAME'
			,p_audit_information_category => lv_context
			,p_audit_information1 => lv_state_filing_status_code
			,p_transaction_parent_id => ln_parent_audit_id
  			,p_stat_trans_audit_id => ln_dummy
  			,p_object_version_number => ln_ovn
  			);

		-- as a sanity check we make sure that the dates are right
		if (ld_start_date <> p_effective_date) or
		   (ld_end_date <> hr_api.g_eot) then
	         	hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
	         	hr_utility.set_message_token('PROCEDURE',l_proc);
	         	hr_utility.set_message_token('STEP','3');
	         	hr_utility.raise_error;
		end if;

		-- fetch the next row
		fetch c_state_tax_rows into c_state_rec;

	end LOOP;

	-- Fire off the workflow to handle notifications

	hr_utility.set_location(l_proc, 50);

	pay_us_tax_wf.start_wf(p_transaction_id => ln_parent_audit_id
			      ,p_process => 'FED_W4_NOTIFICATION'
			      );

/*
    	begin
    	--
    	-- Start of API User Hook for the after hook of submit_fed_w4
    	--
    	pay_tax_bk1.submit_fed_w4_a
    	(
   		p_source_name	    		=> p_source_name
  		,p_person_id         	  	=> p_person_id
  		,p_business_group_id     	=> ln_business_group_id
  		,p_filing_status_code           => p_filing_status_code
  		,p_withholding_allowances       => p_withholding_allowances
  		,p_fit_additional_tax           => p_fit_additional_tax
  		,p_fit_exempt                   => p_fit_exempt
		,p_stat_trans_audit_id		=> ln_parent_audit_id
  	);

  	exception
    	when hr_api.cannot_find_prog_unit then
      		hr_api.cannot_find_prog_unit_error
        	(
         		p_module_name => 'submit_fed_w4'
        		,p_hook_type   => 'AP'
        	);
    	--
    	-- End of API User Hook for the before hook of create_state_tax_rule
    	--
  	end;
*/
	if p_validate then
		raise hr_api.validate_enabled;
	end if;

	-- Set the output variable
	p_stat_trans_audit_id := ln_parent_audit_id;

	hr_utility.trace(' Leaving: ' || l_proc);
 EXCEPTION
  	when hr_api.validate_enabled then
    	--
    	-- As the Validate_Enabled exception has been raised
    	-- we must rollback to the savepoint
    	--
    	ROLLBACK TO submit_fed_w4;
	p_stat_trans_audit_id := null;

  	when others then
    	-- A validation or unexpected error has occurred
    	--
        ROLLBACK TO submit_fed_w4;
	p_stat_trans_audit_id := null;
    	raise;

 END submit_fed_w4;


-- ----------------------------------------------------------------------------
-- |-------------------------< chk_w4_allowed >-------------------------------|
-- ----------------------------------------------------------------------------
function chk_w4_allowed
(
   p_person_id			    IN 	   number
  ,p_effective_date                 IN     date
  ,p_source_name		    IN 	   varchar2
  ,p_state_code			    IN     varchar2  DEFAULT null
 ) return fnd_new_messages.message_name%TYPE IS

     l_primary_only 	VARCHAR2(1);
     l_proc 		VARCHAR2(80) := g_package || 'chk_w4_allowed';

     CURSOR c_tax_defaulting IS
	select 'x'
	from 	pay_us_emp_fed_tax_rules_f prtf,
		per_assignments_f paf
	where	paf.person_id = p_person_id
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	prtf.assignment_id = paf.assignment_id
	  and	prtf.effective_start_date <= p_effective_date;

     CURSOR c_primary_retiree_asg IS
	select	'x'
	from	per_assignments_f paf,
		hr_organization_information hoi,
		hr_soft_coding_keyflex	sck
	where	paf.person_id = p_person_id
	  and	paf.primary_flag = 'Y'
	  and	paf.effective_end_date >= p_effective_date
	  and	paf.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
	  and 	paf.assignment_type = 'E'
	  and	sck.segment1 = hoi.organization_id
	  and   hoi.org_information_context = '1099R Magnetic Report Rules';

     CURSOR c_excess_over_fed IS
	select 	'x'
	from	per_assignments_f paf,
		pay_us_emp_fed_tax_rules_f ftr
	where 	paf.person_id = p_person_id
	  and	ftr.assignment_id = paf.assignment_id
	  and   paf.assignment_type = 'E'
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	p_effective_date between ftr.effective_start_date and ftr.effective_end_date
	  and	p_effective_date between paf.effective_start_date and paf.effective_end_date
	  and	(ftr.excessive_wa_reject_date is not null
		 or nvl(ftr.fit_override_rate,0) <> 0
		 or nvl(ftr.supp_tax_override_rate,0) <> 0
		 or nvl(ftr.fit_override_amount,0) <> 0);

     CURSOR c_excess_over_state IS
	select 	'x'
	from	per_assignments_f paf,
		pay_us_emp_state_tax_rules_f str
	where 	paf.person_id = p_person_id
	  and 	paf.assignment_type = 'E'
	  and	str.assignment_id = paf.assignment_id
	  and	str.state_code = p_state_code
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	p_effective_date between str.effective_start_date and str.effective_end_date
	  and	p_effective_date between paf.effective_start_date and paf.effective_end_date
	  and	(str.excessive_wa_reject_date is not null
		 or nvl(str.sit_override_amount,0) <> 0
		 or nvl(str.sit_override_rate,0) <> 0
		 or nvl(str.sui_wage_base_override_amount,0) <> 0
		 or nvl(str.supp_tax_override_rate,0) <> 0);

     CURSOR c_excess_over_state_for_fed IS
	select 	'x'
	from	per_assignments_f paf,
		pay_us_emp_state_tax_rules_f str,
		pay_us_state_tax_info_f stif
	where 	paf.person_id = p_person_id
	  and 	paf.assignment_type = 'E'
	  and	str.assignment_id = paf.assignment_id
	  and	stif.state_code = str.state_code
	  and	stif.sta_information7 like 'Y%'
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	p_effective_date between str.effective_start_date and str.effective_end_date
	  and	p_effective_date between paf.effective_start_date and paf.effective_end_date
	  and	(str.excessive_wa_reject_date is not null
		 or nvl(str.sit_override_amount,0) <> 0
		 or nvl(str.sit_override_rate,0) <> 0
		 or nvl(str.sui_wage_base_override_amount,0) <> 0
		 or nvl(str.supp_tax_override_rate,0) <> 0);

     CURSOR c_future_fed_recs IS
	select 'x'
	from	per_assignments_f paf,
		pay_us_emp_fed_tax_rules_f ftr
	where	paf.person_id = p_person_id
	  and   paf.assignment_type = 'E'
	  and	ftr.assignment_id = paf.assignment_id
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and  	ftr.effective_start_date > p_effective_date
	  and	p_effective_date between paf.effective_start_date and paf.effective_end_date;

     CURSOR c_future_state_recs IS
	select 'x'
	from	per_assignments_f paf,
		pay_us_emp_state_tax_rules_f str
	where	paf.person_id = p_person_id
	  and	str.assignment_id = paf.assignment_id
	  and	paf.assignment_type = 'E'
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	str.state_code = p_state_code
	  and  	str.effective_start_date > p_effective_date
	  and	p_effective_date between paf.effective_start_date and paf.effective_end_date;


     CURSOR c_future_state_recs_for_fed IS
	select 'x'
	from	per_assignments_f paf,
		pay_us_emp_state_tax_rules_f str,
		pay_us_state_tax_info_f stif
	where	paf.person_id = p_person_id
	  and	str.assignment_id = paf.assignment_id
	  and	paf.assignment_type = 'E'
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	stif.state_code = str.state_code
 	  and	stif.sta_information7 like 'Y%'
	  and  	str.effective_start_date > p_effective_date
	  and	p_effective_date between paf.effective_start_date and paf.effective_end_date
	  and	p_effective_date between stif.effective_start_date and stif.effective_end_date;

     curs_dummy 	VARCHAR2(1);
     lv_update_method	VARCHAR2(30);

  BEGIN
     hr_utility.trace('Entering: ' || l_proc);

     -- NOTE: need to replace this call with a check of the bg org flex
     lv_update_method := 'PRIMARY';

     -- check for update method set to NONE
     hr_utility.trace(l_proc || ' - Testing W4_UPDATE_METHOD');

     if lv_update_method = 'PRIMARY' then
	l_primary_only := 'Y';
     elsif lv_update_method = 'ALL' then
	l_primary_only := 'N';
     else -- update_method = NONE
	hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - Method = None');
	return 'PAY_US_OTF_NO_UPDATE_ALLOWED';
     end if;

     -- we make sure tax records have been defaulted by the effective date
     hr_utility.trace(l_proc || ' - Testing DEFAULT_TAX_RECORDS_CREATED');
     open c_tax_defaulting;
     fetch c_tax_defaulting into curs_dummy;

     if c_tax_defaulting%NOTFOUND then
	hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - Defaulting has not taken place');
	close c_tax_defaulting;
	return 'PAY_US_OTF_NO_TAX_DEFAULTING';
     end if;

     close c_tax_defaulting;

     -- check for primary assignment being a retiree assignment
     hr_utility.trace(l_proc || ' - Testing PRIMARY_ASG = RETIREE ASG');
     open c_primary_retiree_asg;
     fetch c_primary_retiree_asg into curs_dummy;

     if c_primary_retiree_asg%FOUND then
	hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - Primary Assignment is a Retiree');
	close c_primary_retiree_asg;
	return 'PAY_US_OTF_RETIREE_PRIMARY_ASG';
     end if;
     close c_primary_retiree_asg;

     -- if p_state code is null, check the federal cursors
     if p_state_code is null then

        -- check for excessive wa reject date or override amounts
        -- Note: we don't actually check the date of the reject, just
        --	 	it's existence shuts the employee out

        hr_utility.trace(l_proc || ' - Testing FED_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');
        open c_excess_over_fed;
        fetch c_excess_over_fed into curs_dummy;

        if c_excess_over_fed%FOUND then
	   hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - Fed Reject Date or Overrides');
	   close c_excess_over_fed;
	   return 'PAY_US_OTF_REJECT_DATE_OR_OVER';
        end if;

        close c_excess_over_fed;

        hr_utility.trace(l_proc || ' - Testing STATE_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');
        open c_excess_over_state_for_fed;
        fetch c_excess_over_state_for_fed into curs_dummy;

        if c_excess_over_state_for_fed%FOUND then
      	   hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - State Reject Date or Overrides');
	   close c_excess_over_state_for_fed;
	   return 'PAY_US_OTF_REJECT_DATE_OR_OVER';
        end if;
        close c_excess_over_state_for_fed;

        -- check for any future dated changes in non-retiree asgs for both state and fed

        hr_utility.trace(l_proc || ' - Testing FED_FUTURE_DATED_CHANGES');
        open c_future_fed_recs;
        fetch c_future_fed_recs into curs_dummy;
        if c_future_fed_recs%FOUND then
	   close c_future_fed_recs;
	   hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - Future Dated Federal Tax Records');
     	   return 'PAY_US_OTF_FUTURE_RECORDS';
        end if;
        close c_future_fed_recs;

        hr_utility.trace(l_proc || ' - Testing STATE_FUTURE_DATED_CHANGES');
        open c_future_state_recs_for_fed;
        fetch c_future_state_recs_for_fed into curs_dummy;
        if c_future_state_recs_for_fed%FOUND then
	   close c_future_state_recs_for_fed;
	   hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - Future Dated State Tax Records');
	   return 'PAY_US_OTF_FUTURE_RECORDS';
        end if;

        close c_future_state_recs_for_fed;

     else -- check the state cursors only

        hr_utility.trace(l_proc || ' - Testing STATE_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');
        open c_excess_over_state;
        fetch c_excess_over_state into curs_dummy;

        if c_excess_over_state%FOUND then
      	   hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - State Reject Date or Overrides');
	   close c_excess_over_state;
	   return 'PAY_US_OTF_REJECT_DATE_OR_OVER';
        end if;
        close c_excess_over_state;

        hr_utility.trace(l_proc || ' - Testing STATE_FUTURE_DATED_CHANGES');
        open c_future_state_recs;
        fetch c_future_state_recs into curs_dummy;
        if c_future_state_recs_for_fed%FOUND then
	   close c_future_state_recs;
	   hr_utility.trace(' Leaving: ' || l_proc || ' - Failed - Future Dated State Tax Records');
	   return 'PAY_US_OTF_FUTURE_RECORDS';
        end if;
        close c_future_state_recs;
     end if;

     -- if we've reached this point, then allow update
     hr_utility.trace(' Leaving: ' || l_proc || ' - Passed ');
     return null;

end chk_w4_allowed;

end pay_us_tax_api;

/
