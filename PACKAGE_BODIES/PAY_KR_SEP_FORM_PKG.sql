--------------------------------------------------------
--  DDL for Package Body PAY_KR_SEP_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_SEP_FORM_PKG" as
/* $Header: pykrsepf.pkb 120.2 2006/10/09 11:38:33 vaisriva noship $ */
--
-- Global Variables.
--
g_package		varchar2(33) := 'pay_kr_sep_form_pkg.';   -- Global package name
g_debug                 boolean      :=  hr_utility.debug_enabled;
g_old_rec		pay_element_entries_f%ROWTYPE;             -- Global record definition
g_run_type_id   number;
g_run_type_name pay_run_types_f_tl.run_type_name%type;
g_entry_type    varchar2(1) := 'E';
--
g_business_group_id number;
g_legislation_code  varchar2(2);
g_session_date      date;
g_element_entry_id  number;
g_input_value_index number;
type screen_entry_value_tbl is table of pay_element_entry_values_f.screen_entry_value%type index by binary_integer;
g_screen_entry_value_tbl screen_entry_value_tbl;
type element_name_tbl is table of pay_element_types_f.element_name%type index by binary_integer;
type element_type_id_tbl is table of pay_element_types_f.element_type_id%type index by binary_integer;
type input_value_id_tbl is table of pay_input_values_f.input_value_id%type index by binary_integer;
type display_sequence_tbl is table of pay_input_values_f.display_sequence%type index by binary_integer;
type lookup_type_tbl is table of pay_input_values_f.lookup_type%type index by binary_integer;
type mandatory_flag_tbl is table of pay_input_values_f.mandatory_flag%type index by binary_integer;
type input_value_name_tbl is table of pay_input_values_f.name%type index by binary_integer;
type input_value_d_name_tbl is table of pay_input_values_f_tl.name%type index by binary_integer;
type get_input_value_id_rec is record(
  element_type_id  element_type_id_tbl,
  input_value_id   input_value_id_tbl,
  display_sequence display_sequence_tbl,
  lookup_type      lookup_type_tbl,
  mandatory_flag   mandatory_flag_tbl,
  name             input_value_name_tbl,
  d_name           input_value_d_name_tbl);
g_get_input_value_id get_input_value_id_rec;
type get_element_type_id_rec is record(
  element_name     element_name_tbl,
  element_type_id  element_type_id_tbl);
g_get_element_type_id get_element_type_id_rec;
--
--------------------------------------------------------------------------------
function get_run_type_name(p_run_type_id    in number,
                           p_effective_date in date) return varchar2
--------------------------------------------------------------------------------
is
--
  l_run_type_name pay_run_types_f_tl.run_type_name%type;
--
  cursor csr_run_type_name
  is
  select prtt.run_type_name
  from   pay_run_types_f_tl prtt,
         pay_run_types_f    prt
  where  prt.run_type_id = p_run_type_id
  and    p_effective_date
         between prt.effective_start_date and prt.effective_end_date
  and    prtt.run_type_id = prt.run_type_id
  and    prtt.language = userenv('LANG');
--
begin
--
  if g_run_type_id = p_run_type_id then
     l_run_type_name := g_run_type_name;
  else
     open csr_run_type_name;
     fetch csr_run_type_name into l_run_type_name;
     close csr_run_type_name;
  end if;
--
  return l_run_type_name;
--
end get_run_type_name;
--
--------------------------------------------------------------------------------
function get_kr_d_address_line1(p_address_line1 in varchar2) return varchar2
--------------------------------------------------------------------------------
is
--
  l_postal_code_id  number;
  l_d_address_line1 varchar2(200);
--
  cursor csr_kr_d_address
  is
  select pka.city_province||' '||
         pka.district||' '||
         pka.town_village
 --        pka.house_number    -- Commented for Bug# 2506248
  from   per_kr_addresses pka
  where  pka.postal_code_id = l_postal_code_id;
--
begin
--
  l_postal_code_id := to_number(p_address_line1);
--
  open csr_kr_d_address;
  fetch csr_kr_d_address into l_d_address_line1;
  close csr_kr_d_address;
--
  return l_d_address_line1;
--
end get_kr_d_address_line1;
--------------------------------------------------------------------------------
procedure process_run(p_payroll_id           in number,
                      p_consolidation_set_id in number,
                      p_earned_date          in varchar2,
                      p_date_paid            in varchar2,
                      p_ele_set_id           in number,
                      p_assignment_set_id    in number,
                      p_run_type_id          in number,
                      p_leg_params           in varchar2,
		      p_payout_date	     in varchar2,		-- Bug # 5559330
                      p_req_id               in out NOCOPY number,
                      p_success              out NOCOPY boolean,
                      errbuf                 out NOCOPY varchar2)
--------------------------------------------------------------------------------
-- /* This code is copied from hr_rungen.perform_run source. */
is
--
  l_wait_outcome  boolean;
  l_phase         varchar2(80);
  l_status        varchar2(80);
  l_dev_phase     varchar2(80);
  l_dev_status    varchar2(80);
  l_message       varchar2(80);
  l_errbuf        varchar2(240);
--
-- Bug # 5559330: Adding new parameter to pass the profile option value and payout date
--
  l_action_parameter_group varchar2(80);
  l_payout_date varchar2(80);
--
begin
--
-- Bug # 5559330: Fetching and passing the profile option value to KR Separation Pay Payroll
--
  l_action_parameter_group := fnd_profile.value('ACTION_PARAMETER_GROUPS');
--
-- Bug # 5559330: Assigning value for the hidden parameter PAYOUTDATE
--
  if p_payout_date is not null then
    l_payout_date := 'PAYOUTDATE='||p_payout_date;
  else
    l_payout_date := null;
  end if;
--
  p_req_id := fnd_request.submit_request(
                        application => 'PAY',
                        program     => 'PAYKRSEP',
                        argument1   => 'RUN',
                        argument2   => p_payroll_id,
                        argument3   => p_consolidation_set_id,
                        argument4   => p_earned_date,
                        argument5   => p_date_paid,
                        argument6   => p_ele_set_id,
                        argument7   => p_assignment_set_id,
                        argument8   => p_run_type_id,
			argument9   => l_action_parameter_group,	-- Bug # 5559330
                        argument10  => p_leg_params,
			argument11  => p_payout_date,
			argument12  => l_payout_date);			-- Bug # 5559330
  if p_req_id = 0 then
    p_success := false;
    fnd_message.retrieve(l_errbuf);
    hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
    raise zero_req_id;
  else
  --
    commit;
  --
    l_wait_outcome := fnd_concurrent.wait_for_request(
                                        request_id => p_req_id,
                                        interval   => 2,
                                        phase      => l_phase,
                                        status     => l_status,
                                        dev_phase  => l_dev_phase,
                                        dev_status => l_dev_status,
                                        message    => l_message);
  --
    p_success := true;
  --
  end if;
--
  errbuf := l_errbuf;
--
exception
  when zero_req_id then
    raise;
  when others then
    p_success := false;
    l_errbuf := sqlerrm;
    errbuf := l_errbuf;
    hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
--
end process_run;
--------------------------------------------------------------------------------
procedure archive_run(p_business_group_id    in number,
                      p_start_date           in varchar2,
                      p_effective_date       in varchar2,
                      p_payroll_id           in number,
                      p_payroll_id_hd        in varchar2,
                      p_req_id               in out NOCOPY number,
                      p_success              out NOCOPY boolean,
                      errbuf                 out NOCOPY varchar2)
--------------------------------------------------------------------------------
-- /* This code is copied from hr_rungen.perform_run source. */
is
--
  l_wait_outcome       boolean;
  l_phase              varchar2(80);
  l_status             varchar2(80);
  l_dev_phase          varchar2(80);
  l_dev_status         varchar2(80);
  l_message            varchar2(80);
  l_errbuf             varchar2(240);
  l_report_type        varchar2(30) := 'KR_SEP';
  l_report_qualifier   varchar2(30) := 'KR';
  l_report_category    varchar2(30) := 'KR_SEP';
  l_magnetic_file_name varchar2(50);
  l_report_file_name   varchar2(50);
--
begin
--
  p_req_id := fnd_request.submit_request(
                        application => 'PAY',
                        program     => 'PAYKRSAV',
                        argument1   => 'ARCHIVE',
                        argument2   => l_report_type,
                        argument3   => l_report_qualifier,
                        argument4   => p_start_date,
                        argument5   => p_effective_date,
                        argument6   => l_report_category,
                        argument7   => p_business_group_id,
                        argument8   => l_magnetic_file_name,
                        argument9   => l_report_file_name,
			argument10  => p_payroll_id,
			argument11  => p_payroll_id_hd);
  if p_req_id = 0 then
    p_success := false;
    fnd_message.retrieve(l_errbuf);
    hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
    raise zero_req_id;
  else
  --
    commit;
  --
    l_wait_outcome := fnd_concurrent.wait_for_request(
                                        request_id => p_req_id,
                                        interval   => 2,
                                        phase      => l_phase,
                                        status     => l_status,
                                        dev_phase  => l_dev_phase,
                                        dev_status => l_dev_status,
                                        message    => l_message);
  --
    p_success := true;
  --
  end if;
--
  errbuf := l_errbuf;
--
exception
  when zero_req_id then
    raise;
  when others then
    p_success := false;
    l_errbuf := sqlerrm;
    errbuf := l_errbuf;
    hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
--
end archive_run;
--------------------------------------------------------------------------------
procedure delete_action(p_source_action_id in number,
                        p_dml_mode         in varchar2 /* NO_COMMIT, NONE, FULL */)
--------------------------------------------------------------------------------
is
--
begin
--
  py_rollback_pkg.rollback_ass_action(p_assignment_action_id => p_source_action_id,
                                      p_rollback_mode        => 'ROLLBACK',
                                      p_leave_base_table_row => false,
                                      p_all_or_nothing       => true,
                                      p_dml_mode             => p_dml_mode,
                                      p_multi_thread         => false);
--
end delete_action;
--------------------------------------------------------------------------------
procedure lock_action(p_source_action_id in number)
--------------------------------------------------------------------------------
is
--
  cursor csr_assact
  is
  select *
  from   pay_assignment_actions
  where  assignment_action_id = p_source_action_id
  for update nowait;
--
  l_csr_assact csr_assact%rowtype;
--
begin
--
  open csr_assact;
  fetch csr_assact into l_csr_assact;
  if csr_assact%notfound then
    close csr_assact;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_assact;
--exception
--  when others then
--
end lock_action;
--------------------------------------------------------------------------------
procedure find_dt_upd_modes(
  p_effective_date       in         date,
  p_base_key_value       in         number,
  p_correction           out NOCOPY boolean,
  p_update               out NOCOPY boolean,
  p_update_override      out NOCOPY boolean,
  p_update_change_insert out NOCOPY boolean)
--------------------------------------------------------------------------------
is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
  l_entry_type		pay_element_entries_f.entry_type%TYPE;
  l_processing_type	pay_element_types_f.processing_type%TYPE;
--
  cursor C_Sel1 is
  select  pee.entry_type,
          pet.processing_type
  from    pay_element_types_f		pet,
          pay_element_links_f		pel,
          pay_element_entries_f	pee
  where   pee.element_entry_id = p_base_key_value
  and     p_effective_date
          between pee.effective_start_date and pee.effective_end_date
  and     pel.element_link_id = pee.element_link_id
  and     p_effective_date
          between pel.effective_start_date and pel.effective_end_date
  and     pet.element_type_id = pel.element_type_id
  and     p_effective_date
          between pet.effective_start_date and pet.effective_end_date;
--
begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  open  C_Sel1;
  fetch C_Sel1 into l_entry_type,
                    l_processing_type;
  if C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  end if;
  close C_Sel1;
--
  if l_processing_type = 'N' or
     l_entry_type <> 'E' then
    p_correction		:= true;
    p_update			:= false;
    p_update_override		:= false;
    p_update_change_insert	:= false;
  else
    --
    -- Call the corresponding datetrack api
    --
    dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_element_entries_f',
	 p_base_key_column	=> 'element_entry_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
end find_dt_upd_modes;
--------------------------------------------------------------------------------
procedure find_dt_del_modes(
  p_effective_date     in         date,
  p_base_key_value     in         number,
  p_zap                out NOCOPY boolean,
  p_delete             out NOCOPY boolean,
  p_future_change      out NOCOPY boolean,
  p_delete_next_change out NOCOPY boolean)
--------------------------------------------------------------------------------
is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1	number;
  l_parent_key_value2	number;
  l_entry_type		pay_element_entries_f.entry_type%TYPE;
  l_processing_type	pay_element_types_f.processing_type%TYPE;
--
  cursor C_Sel1 is
  select  pee.assignment_id,
          pee.element_link_id,
          pee.entry_type,
          pet.processing_type
  from    pay_element_types_f		pet,
          pay_element_links_f		pel,
          pay_element_entries_f	pee
  where   pee.element_entry_id = p_base_key_value
  and     p_effective_date
          between pee.effective_start_date and pee.effective_end_date
  and     pel.element_link_id = pee.element_link_id
  and     p_effective_date
          between pel.effective_start_date and pel.effective_end_date
  and     pet.element_type_id = pel.element_type_id
  and     p_effective_date
          between pet.effective_start_date and pet.effective_end_date;
--
begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  open  C_Sel1;
  fetch C_Sel1 into l_parent_key_value1,
                    l_parent_key_value2,
                    l_entry_type,
                    l_processing_type;
  if C_Sel1%notfound then
    close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  end if;
  close C_Sel1;
--
  if l_processing_type = 'N' or
     l_entry_type <> 'E' then
    p_zap			:= true;
    p_delete			:= false;
    p_future_change		:= false;
    p_delete_next_change	:= false;
  else
    --
    -- Call the corresponding datetrack api
    --
    dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_element_entries_f',
	 p_base_key_column	=> 'element_entry_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'per_all_assignments_f',
	 p_parent_key_column1	=> 'assignment_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'pay_element_links_f',
	 p_parent_key_column2	=> 'element_link_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
end find_dt_del_modes;
--------------------------------------------------------------------------------
procedure lock_element_entry(
  p_effective_date        in  date,
  p_datetrack_mode        in  varchar2,
  p_element_entry_id      in  number,
  p_object_version_number in  number,
  p_validation_start_date out NOCOPY date,
  p_validation_end_date   out NOCOPY date)
--------------------------------------------------------------------------------
is
--
  l_proc		  varchar2(72) := g_package||'lock_element_entry';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  cursor C_Sel1 is
  select  *
  from    pay_element_entries_f
  where   element_entry_id = p_element_entry_id
  and	  p_effective_date
          between effective_start_date and effective_end_date
  for update nowait;
  --
  -- The following code is not supported in this package.
  --
  -- cursor C_Sel3 select comment text
  --
  -- cursor C_Sel3 is
  --   select hc.comment_text
  --   from   hr_comments hc
  --   where  hc.comment_id = g_old_rec.comment_id;
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'element_entry_id',
                             p_argument_value => p_element_entry_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  if (p_datetrack_mode <> 'INSERT') then
  --
  -- We must select and lock the current row.
  --
    open  C_Sel1;
    fetch C_Sel1 into g_old_rec;
    if C_Sel1%notfound then
      close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    close C_Sel1;
    --
    -- Check if the set object version number is the same as the existing
    -- object version number
    --
    if (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 15);
    end if;
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    -- The following code is not supported in this package.
    --
    -- if ((g_old_rec.comment_id is not null)             and
    --     (p_datetrack_mode = 'UPDATE'                   or
    --      p_datetrack_mode = 'CORRECTION'               or
    --      p_datetrack_mode = 'UPDATE_OVERRIDE'          or
    --      p_datetrack_mode = 'UPDATE_CHANGE_INSERT')) then
    --   open C_Sel3;
    --   fetch C_Sel3 into g_old_rec.comment_text;
    --   if C_Sel3%notfound then
    --     --
    --     -- The comment_text for the specified comment_id does not exist.
    --     -- We must error due to data integrity problems.
    --     --
    --     close C_Sel3;
    --     hr_utility.set_message(801, 'HR_7202_COMMENT_TEXT_NOT_EXIST');
    --     hr_utility.raise_error;
    --   end if;
    --   close C_Sel3;
    -- end if;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    if g_debug then
      hr_utility.set_location('Entering validation_dt_mode', 15);
    end if;

    dt_api.validate_dt_mode(
      p_effective_date          => p_effective_date,
      p_datetrack_mode          => p_datetrack_mode,
      p_base_table_name         => 'pay_element_entries_f',
      p_base_key_column         => 'element_entry_id',
      p_base_key_value          => p_element_entry_id,
      p_parent_table_name1      => 'per_all_assignments_f',
      p_parent_key_column1      => 'assignment_id',
      p_parent_key_value1       => g_old_rec.assignment_id,
      p_parent_table_name2      => 'pay_element_links_f',
      p_parent_key_column2      => 'element_link_id',
      p_parent_key_value2       => g_old_rec.element_link_id,
      p_enforce_foreign_locking => true,
      p_validation_start_date   => l_validation_start_date,
      p_validation_end_date     => l_validation_end_date);
  else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
    --
  end If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 30);
  end if;
--
-- We need to trap the ORA LOCK exception
--
exception
  when HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_entries_f');
    hr_utility.raise_error;
  when l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_entries_f');
    hr_utility.raise_error;
end lock_element_entry;
--------------------------------------------------------------------------------
procedure insert_element_entry(
  p_validate          in boolean,
  p_assignment_id     in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_element_link_id   in number,
  p_input_value_id1   in number,
  p_input_value_id2   in number,
  p_input_value_id3   in number,
  p_input_value_id4   in number,
  p_input_value_id5   in number,
  p_input_value_id6   in number,
  p_input_value_id7   in number,
  p_input_value_id8   in number,
  p_input_value_id9   in number,
  p_input_value_id10  in number,
  p_input_value_id11  in number,
  p_input_value_id12  in number,
  p_input_value_id13  in number,
  p_input_value_id14  in number,
  p_input_value_id15  in number,
  p_entry_value1      in varchar2,
  p_entry_value2      in varchar2,
  p_entry_value3      in varchar2,
  p_entry_value4      in varchar2,
  p_entry_value5      in varchar2,
  p_entry_value6      in varchar2,
  p_entry_value7      in varchar2,
  p_entry_value8      in varchar2,
  p_entry_value9      in varchar2,
  p_entry_value10     in varchar2,
  p_entry_value11     in varchar2,
  p_entry_value12     in varchar2,
  p_entry_value13     in varchar2,
  p_entry_value14     in varchar2,
  p_entry_value15     in varchar2,
  p_element_entry_id      out NOCOPY number,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date,
  p_object_version_number out NOCOPY number)
--------------------------------------------------------------------------------
is
--
  l_warning boolean;
--
begin
--
  pay_element_entry_api.create_element_entry(
        p_validate              => p_validate,
	p_effective_date        => p_effective_date,
        p_business_group_id     => p_business_group_id,
	p_assignment_id         => p_assignment_id,
	p_element_link_id       => p_element_link_id,
	p_entry_type            => g_entry_type,
	p_input_value_id1       => p_input_value_id1,
	p_input_value_id2       => p_input_value_id2,
	p_input_value_id3       => p_input_value_id3,
	p_input_value_id4       => p_input_value_id4,
	p_input_value_id5       => p_input_value_id5,
	p_input_value_id6       => p_input_value_id6,
	p_input_value_id7       => p_input_value_id7,
	p_input_value_id8       => p_input_value_id8,
	p_input_value_id9       => p_input_value_id9,
	p_input_value_id10      => p_input_value_id10,
	p_input_value_id11      => p_input_value_id11,
	p_input_value_id12      => p_input_value_id12,
	p_input_value_id13      => p_input_value_id13,
	p_input_value_id14      => p_input_value_id14,
	p_input_value_id15      => p_input_value_id15,
	p_entry_value1          => p_entry_value1,
	p_entry_value2          => p_entry_value2,
	p_entry_value3          => p_entry_value3,
	p_entry_value4          => p_entry_value4,
	p_entry_value5          => p_entry_value5,
	p_entry_value6          => p_entry_value6,
	p_entry_value7          => p_entry_value7,
	p_entry_value8          => p_entry_value8,
	p_entry_value9          => p_entry_value9,
	p_entry_value10         => p_entry_value10,
	p_entry_value11         => p_entry_value11,
	p_entry_value12         => p_entry_value12,
	p_entry_value13         => p_entry_value13,
	p_entry_value14         => p_entry_value14,
	p_entry_value15         => p_entry_value15,
    p_effective_start_date  => p_effective_start_date,
    p_effective_end_date    => p_effective_end_date,
    p_element_entry_id      => p_element_entry_id,
    p_object_version_number => p_object_version_number,
    p_create_warning        => l_warning);
--
end insert_element_entry;
----------------------------------------------------------------------------------
procedure update_element_entry(
  p_validate              in boolean,
  p_dt_update_mode        in varchar2, /* UPDATE,UPDATE_CHANGE_INSERT,UPDATE_OVERRIDE,CORRECTION */
  p_effective_date        in date,
  p_business_group_id     in number,
  p_element_entry_id      in number,
  p_object_version_number in out NOCOPY number,
  p_input_value_id1       in number,
  p_input_value_id2       in number,
  p_input_value_id3       in number,
  p_input_value_id4       in number,
  p_input_value_id5       in number,
  p_input_value_id6       in number,
  p_input_value_id7       in number,
  p_input_value_id8       in number,
  p_input_value_id9       in number,
  p_input_value_id10      in number,
  p_input_value_id11      in number,
  p_input_value_id12      in number,
  p_input_value_id13      in number,
  p_input_value_id14      in number,
  p_input_value_id15      in number,
  p_entry_value1          in varchar2,
  p_entry_value2          in varchar2,
  p_entry_value3          in varchar2,
  p_entry_value4          in varchar2,
  p_entry_value5          in varchar2,
  p_entry_value6          in varchar2,
  p_entry_value7          in varchar2,
  p_entry_value8          in varchar2,
  p_entry_value9          in varchar2,
  p_entry_value10         in varchar2,
  p_entry_value11         in varchar2,
  p_entry_value12         in varchar2,
  p_entry_value13         in varchar2,
  p_entry_value14         in varchar2,
  p_entry_value15         in varchar2,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date)
--------------------------------------------------------------------------------
is
--
  l_warning boolean;
--
begin
--
  pay_element_entry_api.update_element_entry(
    p_validate              => p_validate,
    p_datetrack_update_mode => p_dt_update_mode,
	p_effective_date        => p_effective_date,
    p_business_group_id     => p_business_group_id,
	p_element_entry_id      => p_element_entry_id,
    p_object_version_number => p_object_version_number,
	p_input_value_id1       => p_input_value_id1,
	p_input_value_id2       => p_input_value_id2,
	p_input_value_id3       => p_input_value_id3,
	p_input_value_id4       => p_input_value_id4,
	p_input_value_id5       => p_input_value_id5,
	p_input_value_id6       => p_input_value_id6,
	p_input_value_id7       => p_input_value_id7,
	p_input_value_id8       => p_input_value_id8,
	p_input_value_id9       => p_input_value_id9,
	p_input_value_id10      => p_input_value_id10,
	p_input_value_id11      => p_input_value_id11,
	p_input_value_id12      => p_input_value_id12,
	p_input_value_id13      => p_input_value_id13,
	p_input_value_id14      => p_input_value_id14,
	p_input_value_id15      => p_input_value_id15,
	p_entry_value1          => p_entry_value1,
	p_entry_value2          => p_entry_value2,
	p_entry_value3          => p_entry_value3,
	p_entry_value4          => p_entry_value4,
	p_entry_value5          => p_entry_value5,
	p_entry_value6          => p_entry_value6,
	p_entry_value7          => p_entry_value7,
	p_entry_value8          => p_entry_value8,
	p_entry_value9          => p_entry_value9,
	p_entry_value10         => p_entry_value10,
	p_entry_value11         => p_entry_value11,
	p_entry_value12         => p_entry_value12,
	p_entry_value13         => p_entry_value13,
	p_entry_value14         => p_entry_value14,
	p_entry_value15         => p_entry_value15,
    p_effective_start_date  => p_effective_start_date,
    p_effective_end_date    => p_effective_end_date,
    p_update_warning        => l_warning);
--
end update_element_entry;
--------------------------------------------------------------------------------
procedure delete_element_entry(
  p_validate              in boolean,
  p_dt_delete_mode        in varchar2, /* DELETE,ZAP,DELETE_NEXT_CHANGE,FUTURE_CHANGE */
  p_effective_date        in date,
  p_element_entry_id      in number,
  p_object_version_number in out NOCOPY number,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date)
--------------------------------------------------------------------------------
is
--
  l_warning boolean;
--
begin
--
  pay_element_entry_api.delete_element_entry(
        p_validate              => p_validate,
        p_datetrack_delete_mode => p_dt_delete_mode,
        p_effective_date        => p_effective_date,
        p_element_entry_id      => p_element_entry_id,
        p_object_version_number => p_object_version_number,
        p_effective_start_date  => p_effective_start_date,
        p_effective_end_date    => p_effective_end_date,
        p_delete_warning        => l_warning);
--
end delete_element_entry;
--------------------------------------------------------------------------------
procedure chk_entry(
  p_element_entry_id      in number,
  p_assignment_id         in number,
  p_element_link_id       in number,
  p_entry_type            in varchar2,
  p_original_entry_id     in number,
  p_target_entry_id       in number,
  p_effective_date        in date,
  p_validation_start_date in date,
  p_validation_end_date   in date,
  p_effective_start_date  in out NOCOPY date,
  p_effective_end_date    in out NOCOPY date,
  p_usage                 in varchar2,
  p_dt_update_mode        in varchar2,
  p_dt_delete_mode        in varchar2)
--------------------------------------------------------------------------------
is
begin
	hr_entry.chk_element_entry(
		p_element_entry_id	=> p_element_entry_id,
		p_original_entry_id	=> p_original_entry_id,
		p_session_date		=> p_effective_date,
		p_element_link_id	=> p_element_link_id,
		p_assignment_id		=> p_assignment_id,
		p_entry_type		=> p_entry_type,
		p_effective_start_date	=> p_effective_start_date,
		p_effective_end_date	=> p_effective_end_date,
		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date,
		p_dt_update_mode	=> p_dt_update_mode,
		p_dt_delete_mode	=> p_dt_delete_mode,
		p_usage			=> p_usage,
		p_target_entry_id	=> p_target_entry_id);
end chk_entry;
--------------------------------------------------------------------------------
procedure chk_formula(
  p_formula_id        in  number,
  p_entry_value       in  varchar2,
  p_business_group_id in  number,
  p_assignment_id     in  number,
  p_date_earned       in  date,
  p_formula_status    out NOCOPY varchar2,
  p_formula_message   out NOCOPY varchar2)
--------------------------------------------------------------------------------
is
--
	l_counter	NUMBER := 0;
	l_inputs	ff_exec.inputs_t;
	l_outputs	ff_exec.outputs_t;
--
	cursor csr_fdi
    is
    select item_name NAME,
           decode(data_type,'T','TEXT','N','NUMBER','D','DATE')	DATATYPE,
           decode(usage,'U','CONTEXT','INPUT') CLASS
    from   ff_fdi_usages_f
    where  formula_id = p_formula_id
    and    p_date_earned
           between effective_start_date and effective_end_date;
--
begin
  --
  -- Initialize formula informations.
  --
  ff_exec.init_formula(
			p_formula_id		=> p_formula_id,
			p_effective_date	=> p_date_earned,
			p_inputs		=> l_inputs,
			p_outputs		=> l_outputs);
  --
  -- Setup input variables.
  --
  l_counter := l_inputs.first;
  while l_counter is not NULL loop
    if l_inputs(l_counter).name = 'BUSINESS_GROUP_ID' then
      l_inputs(l_counter).value := fnd_number.number_to_canonical(p_business_group_id);
    elsif l_inputs(l_counter).name = 'ASSIGNMENT_ID' then
      l_inputs(l_counter).value := fnd_number.number_to_canonical(p_assignment_id);
    elsif l_inputs(l_counter).name = 'DATE_EARNED' then
      l_inputs(l_counter).value := fnd_date.date_to_canonical(p_date_earned);
    elsif l_inputs(l_counter).name = 'ENTRY_VALUE' then
      l_inputs(l_counter).value := p_entry_value;
    end if;
      l_counter := l_inputs.next(l_counter);
  end loop;
  --
  -- Execute formula. Formula unexpected error is raised by ffexec,
  -- so not necessary to handle error.
  --
  ff_exec.run_formula(
			p_inputs		=> l_inputs,
			p_outputs		=> l_outputs,
			p_use_dbi_cache		=> FALSE);
  --
  -- Setup output variables.
  --
  l_counter := l_outputs.first;
  while l_counter is not NULL loop
    if l_outputs(l_counter).name = 'FORMULA_STATUS' then
      p_formula_status := l_outputs(l_counter).value;
    elsif l_outputs(l_counter).name = 'FORMULA_MESSAGE' then
      p_formula_message := l_outputs(l_counter).value;
    end if;
      l_counter := l_outputs.next(l_counter);
  end loop;
end chk_formula;
--------------------------------------------------------------------------------
procedure validate_entry_value(
  p_element_link_id	  in     number,
  p_input_value_id	  in     number,
  p_effective_date	  in     date,
  p_business_group_id     in     number,
  p_assignment_id         in     number,
  p_user_value		  in out NOCOPY varchar2,
  p_canonical_value	  out NOCOPY    varchar2,
  p_hot_defaulted         out NOCOPY    boolean,
  p_min_max_warning	  out NOCOPY    boolean,
  p_user_min_value	  out NOCOPY    varchar2,
  p_user_max_value	  out NOCOPY    varchar2,
  p_formula_warning	  out NOCOPY    boolean,
  p_formula_message	  out NOCOPY    varchar2)
--------------------------------------------------------------------------------
is
--
  l_min_max_status	varchar2(1);
  l_formula_status	varchar2(1);
--
	cursor csr_iv
    is
    select  pivtl.name,
            piv.uom,
            piv.mandatory_flag,
            piv.hot_default_flag,
            piv.lookup_type,
            decode(piv.hot_default_flag,
                   'Y',nvl(pliv.default_value,piv.default_value),
                    pliv.default_value)	DEFAULT_VALUE,
--			decode(piv.lookup_type,NULL,NULL,
--				hr_general.decode_lookup(
--						piv.lookup_type,
--						decode(piv.hot_default_flag,
--							'Y',nvl(pliv.default_value,piv.default_value),
--							pliv.default_value)))	D_DEFAULT_VALUE,
            decode(piv.hot_default_flag,
                   'Y',nvl(pliv.min_value,piv.min_value),
                   pliv.min_value)		MIN_VALUE,
            decode(piv.hot_default_flag,
                   'Y',nvl(pliv.max_value,piv.max_value),
                   pliv.max_value)		MAX_VALUE,
            piv.formula_id,
            decode(piv.hot_default_flag,
                   'Y',nvl(pliv.warning_or_error,piv.warning_or_error),
                   pliv.warning_or_error)	WARNING_OR_ERROR,
            pet.input_currency_code
  from      pay_element_types_f	pet,
            pay_input_values_f_tl	pivtl,
            pay_input_values_f	piv,
            pay_link_input_values_f	pliv
  where     pliv.element_link_id = p_element_link_id
  and       pliv.input_value_id = p_input_value_id
  and       p_effective_date
            between pliv.effective_start_date and pliv.effective_end_date
  and       piv.input_value_id = pliv.input_value_id
  and       p_effective_date
            between piv.effective_start_date and piv.effective_end_date
  and       pivtl.input_value_id = piv.input_value_id
  and       pivtl.language = userenv('LANG')
  and       pet.element_type_id = piv.element_type_id
  and       p_effective_date
            between pet.effective_start_date and pet.effective_end_date;
--
  l_rec   csr_iv%ROWTYPE;
  l_d_uom hr_lookups.meaning%TYPE;
--
begin
  --
  -- Initialize output variables.
  --
  p_canonical_value	:= NULL;
  p_hot_defaulted		:= FALSE;
  p_min_max_warning	:= FALSE;
  p_user_min_value	:= NULL;
  p_user_max_value	:= NULL;
  p_formula_warning	:= FALSE;
  p_formula_message	:= NULL;
  --
  -- When p_input_value_id is not NULL then validate.
  --
  if p_input_value_id is not NULL then
  --
  -- Fetch input value attributes.
  --
    open csr_iv;
    fetch csr_iv into l_rec;
    if csr_iv%NOTFOUND then
      close csr_iv;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hr_entry.check_format');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    end If;
    close csr_iv;
    --
    -- When user entered value is NULL.
    --
    if p_user_value is NULL then
    --
    -- Mandatory Validation.
    --
      if l_rec.mandatory_flag = 'Y' then
      --
      -- When not hot defaulted.
      --
        if l_rec.hot_default_flag = 'N' then
          hr_utility.set_message(801,'HR_6127_ELE_ENTRY_VALUE_MAND');
          hr_utility.set_message_token('INPUT_VALUE_NAME',l_rec.name);
          hr_utility.raise_error;
          --
          -- When hot defaulted.
          --
        else
          if l_rec.default_value is NULL then
            hr_utility.set_message(801,'HR_6128_ELE_ENTRY_MAND_HOT');
            hr_utility.set_message_token('INPUT_VALUE_NAME',l_rec.name);
            hr_utility.raise_error;
          else
            p_canonical_value := l_rec.default_value;
            hr_chkfmt.changeformat(
                      input		    => p_canonical_value,
                      output		=> p_user_value,
                      format		=> l_rec.uom,
                      curcode		=> l_rec.input_currency_code);
          end if;
        end if;
      end if;
    end if;
    --
    -- When p_user_value is not NULL.
    -- Hot defaulted value is validated again in the following routine.
    --
    if p_user_value is not NULL then
      --
	  -- Check format validation(format, min and max validations).
	  -- Hot defaulted value is validated again for range validation.
	  --
	  begin
	    hr_chkfmt.checkformat(
                    value		=> p_user_value,
                    format		=> l_rec.uom,
                    output		=> p_canonical_value,
                    minimum		=> l_rec.min_value,
                    maximum		=> l_rec.max_value,
                    nullok		=> 'Y',
                    rgeflg		=> l_min_max_status,
                    curcode		=> l_rec.input_currency_code);
      exception
      --
      -- In case the value input is incorrect format.
      --
      when others then
          l_d_uom := hr_general.decode_lookup('UNITS',l_rec.uom);
          hr_utility.set_message(801,'PAY_6306_INPUT_VALUE_FORMAT');
          hr_utility.set_message_token('UNIT_OF_MEASURE',l_d_uom);
          hr_utility.raise_error;
      end;
      --
      -- Format min_value and max_value for output parameters.
      -- These parameters should be used for message only.
      --
      if l_rec.min_value is not NULL then
        hr_chkfmt.changeformat(
                  input		    => l_rec.min_value,
                  output		=> p_user_min_value,
                  format		=> l_rec.uom,
                  curcode		=> l_rec.input_currency_code);
      end if;
      if l_rec.max_value is not NULL then
        hr_chkfmt.changeformat(
                  input  		=> l_rec.max_value,
                  output		=> p_user_max_value,
                  format		=> l_rec.uom,
                  curcode		=> l_rec.input_currency_code);
      end if;
      --
      -- If warning_or_error = 'E'(Error) and l_min_max_status = 'F'(Fatal),
      -- then raise error. In case of 'W'(Warning), Forms should warn to user
      -- with fnd_message.warn procedure.
      --
      if l_min_max_status = 'F' and l_rec.warning_or_error = 'E' then
        hr_utility.set_message(801,'PAY_6303_INPUT_VALUE_OUT_RANGE');
        hr_utility.raise_error;
      end If;
      --
      -- Execute formula validation.
      --
      if l_rec.formula_id is not NULL then
        chk_formula(
          p_formula_id        => l_rec.formula_id,
          p_entry_value       => p_canonical_value,
          p_business_group_id => p_business_group_id,
          p_assignment_id     => p_assignment_id,
          p_date_earned       => p_effective_date,
          p_formula_status    => l_formula_status,
          p_formula_message   => p_formula_message);
      end if;
      --
      -- If warning_or_error = 'E'(Error) and l_formula_status = 'E'(Error),
      -- then raise error. In case of 'W'(Warning), Forms should warn to user
      -- with fnd_message.warn procedure.
      --
      if l_formula_status = 'E' and l_rec.warning_or_error = 'E' then
        hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
        hr_utility.set_message_token('FORMULA_TEXT',p_formula_message);
        hr_utility.raise_error;
      end If;
      --
      -- In case lookup_type validation is applied.
      --
      if l_rec.lookup_type is not NULL then
      --
      -- Lookup_type validation with effective_date.
      --
        if hr_api.not_exists_in_hr_lookups(
                 p_effective_date	=> p_effective_date,
                 p_lookup_type		=> l_rec.lookup_type,
                 p_lookup_code		=> p_canonical_value) then
          hr_utility.set_message(801,'HR_7033_ELE_ENTRY_LKUP_INVLD');
          hr_utility.set_message_token('LOOKUP_TYPE',l_rec.lookup_type);
          hr_utility.raise_error;
        end if;
      end if;
    end if;
	--
	-- Set output variables.
	--
	if l_min_max_status = 'F' then
      p_min_max_warning := TRUE;
    end if;
    if l_formula_status = 'E' then
      p_formula_warning := TRUE;
    end if;
    if l_rec.hot_default_flag = 'Y' and p_canonical_value = l_rec.default_value then
      p_hot_defaulted := TRUE;
    end if;
	--
	-- When p_input_value_id is NULL.
	--
  else
    p_user_value := NULL;
  end if;
end validate_entry_value;
--------------------------------------------------------------------------------
function get_session_date return date
--------------------------------------------------------------------------------
is
--
  l_effective_date date;
--
  cursor session_date
  is
  select effective_date
  from   fnd_sessions
  where  session_id = userenv('sessionid');
--
begin
--
  l_effective_date := null;
--
  open session_date;
  fetch session_date into l_effective_date;
  close session_date;
--
  return l_effective_date;
--
end get_session_date;
--------------------------------------------------------------------------------
function get_element_type_id(
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date) return number
--------------------------------------------------------------------------------
is
--
  l_effective_date date;
  l_element_type_id number;
  l_reset boolean := false;
  l_found boolean := false;
  l_tbl_index number;
--
  cursor csr_element_type_id
  is
  select pet.element_type_id
  from   pay_element_types_f pet
  where  pet.element_name = p_element_name
  and    l_effective_date
         between pet.effective_start_date and pet.effective_end_date
  and    nvl(pet.legislation_code,g_legislation_code) = g_legislation_code
  and    nvl(pet.business_group_id,g_business_group_id) = g_business_group_id;
--
begin
--
  l_element_type_id := null;
--
  if p_effective_date is null then
    l_effective_date := get_session_date;
  else
    l_effective_date := p_effective_date;
  end if;
--
  if g_business_group_id is null
     or g_business_group_id <> p_business_group_id
     or g_session_date <> l_effective_date then
  --
     g_business_group_id := p_business_group_id;
     g_legislation_code := pay_kr_report_pkg.legislation_code(p_business_group_id => g_business_group_id);
     g_session_date := l_effective_date;
     g_get_element_type_id.element_name.delete;
     g_get_element_type_id.element_type_id.delete;
  --
     l_reset := true;
  --
  end if;
--
  l_tbl_index := g_get_element_type_id.element_type_id.count;
--
  if not l_reset then
    for i in 1..l_tbl_index loop
      if g_get_element_type_id.element_name(i) = p_element_name then
        l_found := true;
        l_element_type_id := g_get_element_type_id.element_type_id(i);
        exit;
      end if;
    end loop;
  end if;
--
  if not l_found or l_reset then
  --
     open csr_element_type_id;
     fetch csr_element_type_id into l_element_type_id;
     close csr_element_type_id;
  --
     if l_element_type_id is not null then
       g_get_element_type_id.element_type_id(l_tbl_index + 1) := l_element_type_id;
       g_get_element_type_id.element_name(l_tbl_index + 1) := p_element_name;
     end if;
  --
  end if;
--
  return l_element_type_id;
--
end get_element_type_id;
--------------------------------------------------------------------------------
function get_input_value_id(
  p_element_type_id         in number,
  p_sequence                in number, /* Different from display sequence */
  p_business_group_id       in number,
  p_effective_date          in date) return number
--------------------------------------------------------------------------------
is
--
  l_effective_date date;
  l_input_value_id number;
  l_get_input_value_id get_input_value_id_rec;
  l_reset boolean := false;
  l_found boolean := false;
  l_tbl_index number;
  l_get_index number;
  l_seq_index number := 0;
--
  cursor csr_input_value_id
  is
  select piv.element_type_id	element_type_id,
         piv.input_value_id	input_value_id,
         piv.display_sequence	display_sequence,
         piv.lookup_type        lookup_type,
         piv.mandatory_flag		mandatory_flag,
         piv.name				name,
         pivtl.name				d_name
  from   pay_input_values_f_tl pivtl,
         pay_input_values_f    piv
  where  piv.element_type_id = p_element_type_id
  and    l_effective_date
         between piv.effective_start_date and piv.effective_end_date
  and    pivtl.input_value_id = piv.input_value_id
  and    pivtl.language = userenv('LANG')
  order by piv.display_sequence, piv.name;
--
begin
--
  l_input_value_id := null;
--
  if p_effective_date is null then
    l_effective_date := get_session_date;
  else
    l_effective_date := p_effective_date;
  end if;
--
  if g_business_group_id is null
     or g_business_group_id <> p_business_group_id
     or g_session_date <> l_effective_date then
  --
     g_business_group_id := p_business_group_id;
     g_legislation_code := pay_kr_report_pkg.legislation_code(p_business_group_id => g_business_group_id);
     g_session_date := l_effective_date;
     g_get_input_value_id.element_type_id.delete;
     g_get_input_value_id.input_value_id.delete;
     g_get_input_value_id.display_sequence.delete;
     g_get_input_value_id.lookup_type.delete;
     g_get_input_value_id.mandatory_flag.delete;
     g_get_input_value_id.name.delete;
     g_get_input_value_id.d_name.delete;
     g_input_value_index := null;
  --
     l_reset := true;
  --
  end if;
--
  l_tbl_index := g_get_input_value_id.input_value_id.count;
--
  /* Check the start point */
  if not l_reset then
    for i in 1..l_tbl_index loop
      if g_get_input_value_id.element_type_id(i) = p_element_type_id then
        l_found := true;
        g_input_value_index := i;
        exit;
      end if;
    end loop;
  end if;
--
  if not l_found or l_reset then
  --
     open csr_input_value_id;
     fetch csr_input_value_id bulk collect into
						l_get_input_value_id.element_type_id,
                        l_get_input_value_id.input_value_id,
                        l_get_input_value_id.display_sequence,
						l_get_input_value_id.lookup_type,
						l_get_input_value_id.mandatory_flag,
						l_get_input_value_id.name,
						l_get_input_value_id.d_name;
     close csr_input_value_id;
  --
     l_get_index := l_get_input_value_id.input_value_id.count;
  --
     if 0 < l_get_index and l_get_index >= p_sequence then
       for j in 1..l_get_index loop
         g_get_input_value_id.element_type_id(l_tbl_index + j) := l_get_input_value_id.element_type_id(j);
         g_get_input_value_id.input_value_id(l_tbl_index + j) := l_get_input_value_id.input_value_id(j);
         g_get_input_value_id.display_sequence(l_tbl_index + j) := l_get_input_value_id.display_sequence(j);
         g_get_input_value_id.lookup_type(l_tbl_index + j) := l_get_input_value_id.lookup_type(j);
         g_get_input_value_id.mandatory_flag(l_tbl_index + j) := l_get_input_value_id.mandatory_flag(j);
         g_get_input_value_id.name(l_tbl_index + j) := l_get_input_value_id.name(j);
         g_get_input_value_id.d_name(l_tbl_index + j) := l_get_input_value_id.d_name(j);
         if j = p_sequence then
            l_input_value_id := l_get_input_value_id.input_value_id(j);
            g_input_value_index := l_tbl_index + j;
         end if;
       end loop;
     end if;
  else
   if g_input_value_index + p_sequence - 1 <= l_tbl_index then
     if g_get_input_value_id.element_type_id(g_input_value_index + p_sequence - 1) = p_element_type_id then
        l_input_value_id := g_get_input_value_id.input_value_id(g_input_value_index + p_sequence - 1);
        g_input_value_index := g_input_value_index + p_sequence - 1;
     else
        /* Re Check All */
        g_input_value_index := null;
        for k in 1..l_tbl_index loop
          if g_get_input_value_id.element_type_id(k) = p_element_type_id then
             l_seq_index := l_seq_index + 1;
             if l_seq_index = p_sequence then
                l_input_value_id := g_get_input_value_id.input_value_id(k);
                g_input_value_index := k;
                exit;
             end if;
          end if;
        end loop;
     end if;
      --/* p_sequence should be 1..15 */
      ----for k in g_input_value_index..l_tbl_index loop
      ----  if k = g_input_value_index + 15 then
      ----     exit;
      ----  end if;
      --for k in g_input_value_index..g_input_value_index + 14 loop
      --  if k = g_input_value_index + p_sequence - 1 then
      --    if g_get_input_value_id.element_type_id(k) = p_element_type_id then
      --       l_input_value_id := g_get_input_value_id.input_value_id(k);
      --       g_input_value_index := j;
      --       exit;
      --    else
      --       g_input_value_index := null;
      --       exit;
      --    end if;
      --  end if;
      --end loop;
    end if;
  end if;
--
  if l_input_value_id is null then
     g_input_value_index := null;
  end if;
--
  return l_input_value_id;
--
end get_input_value_id;
--------------------------------------------------------------------------------
function get_input_value_name(
  p_element_type_id         in number,
  p_sequence                in number, /* Different from display sequence */
  p_business_group_id       in number,
  p_effective_date          in date) return varchar2
--------------------------------------------------------------------------------
is
--
  l_effective_date date;
  l_input_value_id number;
  l_input_value_name pay_input_values_f_tl.name%type;
  l_index number;
  l_csr_index number := 0;
--
  cursor csr_input_value_name
  is
  select piv.name		name,
         pivtl.name		d_name
  from   pay_input_values_f_tl pivtl,
         pay_input_values_f    piv
  where  piv.element_type_id = p_element_type_id
  and    l_effective_date
         between piv.effective_start_date and piv.effective_end_date
  and    pivtl.input_value_id = piv.input_value_id
  and    pivtl.language = userenv('LANG')
  order by piv.display_sequence, piv.name;
--
  l_csr_input_value_name csr_input_value_name%rowtype;
--
begin
--
  l_input_value_id := get_input_value_id(
                               p_element_type_id   => p_element_type_id,
                               p_sequence          => p_sequence,
                               p_business_group_id => p_business_group_id,
                               p_effective_date    => p_effective_date);
--
  if l_input_value_id is not null then
  --
    l_index := g_get_input_value_id.input_value_id.count;
  --
    if g_input_value_index is not null then
       l_input_value_name := g_get_input_value_id.d_name(g_input_value_index);
    else
      if l_index > 0 then
        for i in 1..l_index loop
          if g_get_input_value_id.input_value_id(i) = l_input_value_id then
            l_input_value_name := g_get_input_value_id.d_name(i);
            exit;
          end if;
        end loop;
      else
        if p_effective_date is null then
          l_effective_date := get_session_date;
        else
          l_effective_date := p_effective_date;
        end if;
        open csr_input_value_name;
        loop
          fetch csr_input_value_name into l_csr_input_value_name;
          exit when csr_input_value_name%notfound;
          l_csr_index := l_csr_index + 1;
          if l_csr_index = p_sequence then
             l_input_value_name := l_csr_input_value_name.d_name;
             exit;
          --elsif l_csr_index > p_sequence then
          --   exit;
          end if;
        end loop;
        close csr_input_value_name;
      end if;
    end if;
  end if;
--
  return l_input_value_name;
--
end get_input_value_name;
--------------------------------------------------------------------------------
function get_input_value_d_sequence(
  p_element_type_id         in number,
  p_sequence                in number, /* Different from display sequence */
  p_business_group_id       in number,
  p_effective_date          in date) return number
--------------------------------------------------------------------------------
is
--
  l_effective_date date;
  l_input_value_id number;
  l_input_value_d_sequence number;
  l_index number;
  l_csr_index number := 0;
--
  cursor csr_input_value_d_sequence
  is
  select piv.display_sequence	display_sequence
  from   pay_input_values_f    piv
  where  piv.element_type_id = p_element_type_id
  and    l_effective_date
         between piv.effective_start_date and piv.effective_end_date
  order by piv.display_sequence, piv.name;
--
  l_csr_input_value_d_sequence csr_input_value_d_sequence%rowtype;
--
begin
--
  l_input_value_id := get_input_value_id(
                               p_element_type_id   => p_element_type_id,
                               p_sequence          => p_sequence,
                               p_business_group_id => p_business_group_id,
                               p_effective_date    => p_effective_date);
--
  if l_input_value_id is not null then
  --
    l_index := g_get_input_value_id.input_value_id.count;
  --
    if g_input_value_index is not null then
       l_input_value_d_sequence := g_get_input_value_id.display_sequence(g_input_value_index);
    else
      if l_index > 0 then
        for i in 1..l_index loop
          if g_get_input_value_id.input_value_id(i) = l_input_value_id then
            l_input_value_d_sequence := g_get_input_value_id.display_sequence(i);
            exit;
          end if;
        end loop;
      else
        if p_effective_date is null then
          l_effective_date := get_session_date;
        else
          l_effective_date := p_effective_date;
        end if;
        open csr_input_value_d_sequence;
        loop
          fetch csr_input_value_d_sequence into l_csr_input_value_d_sequence;
          exit when csr_input_value_d_sequence%notfound;
          l_csr_index := l_csr_index + 1;
          if l_csr_index = p_sequence then
             l_input_value_d_sequence := l_csr_input_value_d_sequence.display_sequence;
             exit;
          --elsif l_csr_index > p_sequence then
          --   exit;
          end if;
        end loop;
        close csr_input_value_d_sequence;
      end if;
    end if;
  end if;
--
  return l_input_value_d_sequence;
--
end get_input_value_d_sequence;
--------------------------------------------------------------------------------
function get_input_value_lookup_type(
  p_element_type_id         in number,
  p_sequence                in number, /* Different from display sequence */
  p_business_group_id       in number,
  p_effective_date          in date) return varchar2
--------------------------------------------------------------------------------
is
--
  l_effective_date date;
  l_input_value_id number;
  l_input_value_lookup_type pay_input_values_f.lookup_type%type;
  l_index number;
  l_csr_index number := 0;
--
  cursor csr_input_value_lookup_type
  is
  select piv.lookup_type	lookup_type
  from   pay_input_values_f    piv
  where  piv.element_type_id = p_element_type_id
  and    l_effective_date
         between piv.effective_start_date and piv.effective_end_date
  order by piv.display_sequence, piv.name;
--
  l_csr_input_value_lookup_type csr_input_value_lookup_type%rowtype;
--
begin
--
  l_input_value_id := get_input_value_id(
                               p_element_type_id   => p_element_type_id,
                               p_sequence          => p_sequence,
                               p_business_group_id => p_business_group_id,
                               p_effective_date    => p_effective_date);
--
  if l_input_value_id is not null then
  --
    l_index := g_get_input_value_id.input_value_id.count;
  --
    if g_input_value_index is not null then
       l_input_value_lookup_type := g_get_input_value_id.lookup_type(g_input_value_index);
    else
      if l_index > 0 then
        for i in 1..l_index loop
          if g_get_input_value_id.input_value_id(i) = l_input_value_id then
            l_input_value_lookup_type := g_get_input_value_id.lookup_type(i);
            exit;
          end if;
        end loop;
      else
        if p_effective_date is null then
          l_effective_date := get_session_date;
        else
          l_effective_date := p_effective_date;
        end if;
        open csr_input_value_lookup_type;
        loop
          fetch csr_input_value_lookup_type into l_csr_input_value_lookup_type;
          exit when csr_input_value_lookup_type%notfound;
          l_csr_index := l_csr_index + 1;
          if l_csr_index = p_sequence then
             l_input_value_lookup_type := l_csr_input_value_lookup_type.lookup_type;
             exit;
          --elsif l_csr_index > p_sequence then
          --   exit;
          end if;
        end loop;
        close csr_input_value_lookup_type;
      end if;
    end if;
  end if;
--
  return l_input_value_lookup_type;
--
end get_input_value_lookup_type;
--------------------------------------------------------------------------------
function get_input_value_mandatory(
  p_element_type_id         in number,
  p_sequence                in number, /* Different from display sequence */
  p_business_group_id       in number,
  p_effective_date          in date) return varchar2
--------------------------------------------------------------------------------
is
--
  l_effective_date date;
  l_input_value_id number;
  l_input_value_mandatory pay_input_values_f.mandatory_flag%type;
  l_index number;
  l_csr_index number := 0;
--
  cursor csr_input_value_mandatory
  is
  select piv.mandatory_flag	mandatory_flag
  from   pay_input_values_f    piv
  where  piv.element_type_id = p_element_type_id
  and    l_effective_date
         between piv.effective_start_date and piv.effective_end_date
  order by piv.display_sequence, piv.name;
--
  l_csr_input_value_mandatory csr_input_value_mandatory%rowtype;
--
begin
--
  l_input_value_id := get_input_value_id(
                               p_element_type_id   => p_element_type_id,
                               p_sequence          => p_sequence,
                               p_business_group_id => p_business_group_id,
                               p_effective_date    => p_effective_date);
--
  if l_input_value_id is not null then
  --
    l_index := g_get_input_value_id.input_value_id.count;
  --
    if g_input_value_index is not null then
       l_input_value_mandatory := g_get_input_value_id.mandatory_flag(g_input_value_index);
    else
      if l_index > 0 then
        for i in 1..l_index loop
          if g_get_input_value_id.input_value_id(i) = l_input_value_id then
            l_input_value_mandatory := g_get_input_value_id.mandatory_flag(i);
            exit;
          end if;
        end loop;
      else
        if p_effective_date is null then
          l_effective_date := get_session_date;
        else
          l_effective_date := p_effective_date;
        end if;
        open csr_input_value_mandatory;
        loop
          fetch csr_input_value_mandatory into l_csr_input_value_mandatory;
          exit when csr_input_value_mandatory%notfound;
          l_csr_index := l_csr_index + 1;
          if l_csr_index = p_sequence then
             l_input_value_mandatory := l_csr_input_value_mandatory.mandatory_flag;
             exit;
          --elsif l_csr_index > p_sequence then
          --   exit;
          end if;
        end loop;
        close csr_input_value_mandatory;
      end if;
    end if;
  end if;
--
  return l_input_value_mandatory;
--
end get_input_value_mandatory;
--------------------------------------------------------------------------------
procedure get_default_value(
  p_assignment_id	 in  number,
  p_element_type_id      in  number,
  p_business_group_id	 in  varchar2,
  p_entry_type           in  varchar2,
  p_effective_date	 in  date,
  p_element_link_id	 out NOCOPY number,
  p_input_value_id1      out NOCOPY number,
  p_input_value_id2      out NOCOPY number,
  p_input_value_id3      out NOCOPY number,
  p_input_value_id4      out NOCOPY number,
  p_input_value_id5      out NOCOPY number,
  p_input_value_id6      out NOCOPY number,
  p_input_value_id7      out NOCOPY number,
  p_input_value_id8      out NOCOPY number,
  p_input_value_id9      out NOCOPY number,
  p_input_value_id10     out NOCOPY number,
  p_input_value_id11     out NOCOPY number,
  p_input_value_id12     out NOCOPY number,
  p_input_value_id13     out NOCOPY number,
  p_input_value_id14     out NOCOPY number,
  p_input_value_id15     out NOCOPY number,
  p_default_value1       out NOCOPY varchar2,
  p_default_value2       out NOCOPY varchar2,
  p_default_value3       out NOCOPY varchar2,
  p_default_value4       out NOCOPY varchar2,
  p_default_value5       out NOCOPY varchar2,
  p_default_value6       out NOCOPY varchar2,
  p_default_value7       out NOCOPY varchar2,
  p_default_value8       out NOCOPY varchar2,
  p_default_value9       out NOCOPY varchar2,
  p_default_value10      out NOCOPY varchar2,
  p_default_value11      out NOCOPY varchar2,
  p_default_value12      out NOCOPY varchar2,
  p_default_value13      out NOCOPY varchar2,
  p_default_value14      out NOCOPY varchar2,
  p_default_value15      out NOCOPY varchar2,
  p_b_default_value1     out NOCOPY varchar2,
  p_b_default_value2     out NOCOPY varchar2,
  p_b_default_value3     out NOCOPY varchar2,
  p_b_default_value4     out NOCOPY varchar2,
  p_b_default_value5     out NOCOPY varchar2,
  p_b_default_value6     out NOCOPY varchar2,
  p_b_default_value7     out NOCOPY varchar2,
  p_b_default_value8     out NOCOPY varchar2,
  p_b_default_value9     out NOCOPY varchar2,
  p_b_default_value10    out NOCOPY varchar2,
  p_b_default_value11    out NOCOPY varchar2,
  p_b_default_value12    out NOCOPY varchar2,
  p_b_default_value13    out NOCOPY varchar2,
  p_b_default_value14    out NOCOPY varchar2,
  p_b_default_value15    out NOCOPY varchar2,
  p_effective_start_date in out NOCOPY date,
  p_effective_end_date	 in out NOCOPY date)
is
--
  l_element_type_id  number;
  l_csr_index number := 0;
  type input_value_tbl_rec is record(
        input_value_id   input_value_id_tbl,
  --      display_sequence display_sequence_tbl,
        default_value    screen_entry_value_tbl,
        b_default_value  screen_entry_value_tbl);
  l_input_value_tbl input_value_tbl_rec;
--
  cursor csr_default_value
  is
  select piv.input_value_id   input_value_id,
         piv.display_sequence display_sequence,
         hr_chkfmt.changeformat(
            decode(piv.lookup_type,
                  null,
                  decode(piv.hot_default_flag,
                        'Y',nvl(pliv.default_value,piv.default_value),
                         pliv.default_value),
                  hr_general.decode_lookup(piv.lookup_type,
                        decode(piv.hot_default_flag,
                              'Y',nvl(pliv.default_value,piv.default_value),
                              pliv.default_value))),
         piv.uom,
         pet.output_currency_code) default_value,
         decode(piv.lookup_type,
                null,
                null,
                decode(piv.hot_default_flag,
                      'Y',nvl(pliv.default_value,piv.default_value),
                      pliv.default_value)) b_default_value
  from   pay_element_types_f     pet,
         pay_input_values_f      piv,
         pay_link_input_values_f pliv
  where  pliv.element_link_id = p_element_link_id
  and    p_effective_date
         between pliv.effective_start_date and pliv.effective_end_date
  and    piv.input_value_id = pliv.input_value_id
  and    p_effective_date
         between piv.effective_start_date and piv.effective_end_date
  and    pet.element_type_id = piv.element_type_id
  and    p_effective_date
         between pet.effective_start_date and pet.effective_end_date
  order by piv.display_sequence, piv.name;
--
  l_csr_default_value csr_default_value%rowtype;
--
begin
--
--  if p_element_type_id is null then
--    l_element_type_id := pay_kr_sep_form_pkg.get_element_type_id(p_element_name,p_business_group_id,p_effective_date);
--  else
--    l_element_type_id := p_element_type_id;
--  end if;
--
  p_element_link_id := hr_entry_api.get_link(
                                p_assignment_id => p_assignment_id,
--                                p_element_type_id => l_element_type_id,
                                p_element_type_id => p_element_type_id,
                                p_session_date => p_effective_date);
--
  if p_element_link_id is null then
    hr_utility.set_message(801,'HR_7027_ELE_ENTRY_EL_NOT_EXST');
    hr_utility.set_message_token('DATE',fnd_date.date_to_displaydate(p_effective_date));
    hr_utility.raise_error;
  end if;
--
  chk_entry(
	p_element_entry_id      => NULL,
	p_assignment_id         => p_assignment_id,
	p_element_link_id       => p_element_link_id,
	p_entry_type            => p_entry_type,
	p_effective_date        => p_effective_date,
	p_validation_start_date => NULL,
	p_validation_end_date   => NULL,
	p_effective_start_date  => p_effective_start_date,
	p_effective_end_date    => p_effective_end_date,
	p_usage                 => 'INSERT',
	p_dt_update_mode        => NULL,
	p_dt_delete_mode        => NULL);
--
  open csr_default_value;
  loop
    fetch csr_default_value into l_csr_default_value;
    exit when csr_default_value%notfound;
    l_csr_index := l_csr_index + 1;
    l_input_value_tbl.input_value_id(l_csr_index) := l_csr_default_value.input_value_id;
  --  l_input_value_tbl.display_sequence(l_csr_index) := l_csr_default_value.display_sequence;
    l_input_value_tbl.default_value(l_csr_index) := l_csr_default_value.default_value;
    l_input_value_tbl.b_default_value(l_csr_index) := l_csr_default_value.b_default_value;
  end loop;
  close csr_default_value;
--
  if l_csr_index < 15 then
   for i in l_csr_index + 1..15 loop
    l_input_value_tbl.input_value_id(i) := null;
   -- l_input_value_tbl.display_sequence(i) := null;
    l_input_value_tbl.default_value(i) := null;
    l_input_value_tbl.b_default_value(i) := null;
   end loop;
  end if;
--
  p_input_value_id1  := l_input_value_tbl.input_value_id(1);
  p_input_value_id2  := l_input_value_tbl.input_value_id(2);
  p_input_value_id3  := l_input_value_tbl.input_value_id(3);
  p_input_value_id4  := l_input_value_tbl.input_value_id(4);
  p_input_value_id5  := l_input_value_tbl.input_value_id(5);
  p_input_value_id6  := l_input_value_tbl.input_value_id(6);
  p_input_value_id7  := l_input_value_tbl.input_value_id(7);
  p_input_value_id8  := l_input_value_tbl.input_value_id(8);
  p_input_value_id9  := l_input_value_tbl.input_value_id(9);
  p_input_value_id10 := l_input_value_tbl.input_value_id(10);
  p_input_value_id11 := l_input_value_tbl.input_value_id(11);
  p_input_value_id12 := l_input_value_tbl.input_value_id(12);
  p_input_value_id13 := l_input_value_tbl.input_value_id(13);
  p_input_value_id14 := l_input_value_tbl.input_value_id(14);
  p_input_value_id15 := l_input_value_tbl.input_value_id(15);
--
  p_default_value1  := l_input_value_tbl.default_value(1);
  p_default_value2  := l_input_value_tbl.default_value(2);
  p_default_value3  := l_input_value_tbl.default_value(3);
  p_default_value4  := l_input_value_tbl.default_value(4);
  p_default_value5  := l_input_value_tbl.default_value(5);
  p_default_value6  := l_input_value_tbl.default_value(6);
  p_default_value7  := l_input_value_tbl.default_value(7);
  p_default_value8  := l_input_value_tbl.default_value(8);
  p_default_value9  := l_input_value_tbl.default_value(9);
  p_default_value10 := l_input_value_tbl.default_value(10);
  p_default_value11 := l_input_value_tbl.default_value(11);
  p_default_value12 := l_input_value_tbl.default_value(12);
  p_default_value13 := l_input_value_tbl.default_value(13);
  p_default_value14 := l_input_value_tbl.default_value(14);
  p_default_value15 := l_input_value_tbl.default_value(15);
--
  p_b_default_value1  := l_input_value_tbl.b_default_value(1);
  p_b_default_value2  := l_input_value_tbl.b_default_value(2);
  p_b_default_value3  := l_input_value_tbl.b_default_value(3);
  p_b_default_value4  := l_input_value_tbl.b_default_value(4);
  p_b_default_value5  := l_input_value_tbl.b_default_value(5);
  p_b_default_value6  := l_input_value_tbl.b_default_value(6);
  p_b_default_value7  := l_input_value_tbl.b_default_value(7);
  p_b_default_value8  := l_input_value_tbl.b_default_value(8);
  p_b_default_value9  := l_input_value_tbl.b_default_value(9);
  p_b_default_value10 := l_input_value_tbl.b_default_value(10);
  p_b_default_value11 := l_input_value_tbl.b_default_value(11);
  p_b_default_value12 := l_input_value_tbl.b_default_value(12);
  p_b_default_value13 := l_input_value_tbl.b_default_value(13);
  p_b_default_value14 := l_input_value_tbl.b_default_value(14);
  p_b_default_value15 := l_input_value_tbl.b_default_value(15);
--
end get_default_value;
--------------------------------------------------------------------------------
function get_screen_entry_value(
  p_element_type_id         in number,
  p_sequence                in number, /* Different from display sequence */
  p_business_group_id       in number,
  p_ee_element_entry_id     in number,
  p_ee_effective_start_date in date,
  p_ee_effective_end_date   in date) return varchar2
--------------------------------------------------------------------------------
is
--
  l_value pay_element_entry_values_f.screen_entry_value%type;
  l_input_value_id number;
  l_input_value_id_tbl input_value_id_tbl;
  l_screen_entry_value_tbl screen_entry_value_tbl;
--
  cursor csr_entry_value
  is
  select peev.input_value_id      input_value_id,
         peev.screen_entry_value  screen_entry_value
  from   pay_element_entry_values_f peev
  where  peev.element_entry_id = p_ee_element_entry_id
  and    peev.effective_start_date = p_ee_effective_start_date
  and    peev.effective_end_date   = p_ee_effective_end_date;
--
begin
--
  l_value := null;
--
  if g_element_entry_id is null or p_ee_element_entry_id <> g_element_entry_id then
  --
    open csr_entry_value;
    fetch csr_entry_value bulk collect into l_input_value_id_tbl,
                                            l_screen_entry_value_tbl;
    close csr_entry_value;
  --
    g_screen_entry_value_tbl.delete;
    for i in 1..l_input_value_id_tbl.count loop
      g_screen_entry_value_tbl(l_input_value_id_tbl(i)) := l_screen_entry_value_tbl(i);
    end loop;
    g_element_entry_id := p_ee_element_entry_id;
  end if;
  --
  l_input_value_id := get_input_value_id(p_element_type_id, p_sequence, p_business_group_id);
  --
  if g_screen_entry_value_tbl.exists(l_input_value_id) then
     l_value := g_screen_entry_value_tbl(l_input_value_id);
  end if;
--
  return l_value;
--
end get_screen_entry_value;
--------------------------------------------------------------------------------
function get_entry_value(
  p_element_type_id         in number,
  p_sequence                in number, /* Different from display sequence */
  p_business_group_id       in number,
  p_ee_element_entry_id     in number,
  p_ee_effective_start_date in date,
  p_ee_effective_end_date   in date,
  p_el_element_link_id      in number) return varchar2
--------------------------------------------------------------------------------
is
--
  l_input_value_id number;
  l_screen_value   pay_element_entry_values_f.screen_entry_value%type;
  l_value          varchar2(240);
--
  cursor csr_entry_value
  is
  select  substr(hr_chkfmt.changeformat(
            decode(piv.lookup_type,
                  null,
                  nvl(l_screen_value,decode(piv.hot_default_flag,
                        'Y',nvl(pliv.default_value,piv.default_value),
                         pliv.default_value)),
                  hr_general.decode_lookup(piv.lookup_type,
                        nvl(l_screen_value,decode(piv.hot_default_flag,
                                           'Y',nvl(pliv.default_value,piv.default_value),
                                            pliv.default_value)))),piv.uom,pet.output_currency_code),1,60) entry_value
  from   pay_element_types_f     pet,
         pay_input_values_f      piv,
         pay_link_input_values_f pliv
  where  pliv.element_link_id = p_el_element_link_id
  and    pliv.input_value_id = l_input_value_id
  and    g_session_date /* set by get_input_value_id */
         between pliv.effective_start_date and pliv.effective_end_date
  and    piv.input_value_id = pliv.input_value_id
  and    g_session_date
         between piv.effective_start_date and piv.effective_end_date
  and    pet.element_type_id = piv.element_type_id
  and    g_session_date
         between pet.effective_start_date and pet.effective_end_date;
--
begin
--
  l_input_value_id := get_input_value_id(p_element_type_id, p_sequence, p_business_group_id);
--
  l_screen_value := get_screen_entry_value(p_element_type_id => p_element_type_id,
                                           p_sequence => p_sequence,
                                           p_business_group_id => p_business_group_id,
                                           p_ee_element_entry_id => p_ee_element_entry_id,
                                           p_ee_effective_start_date => p_ee_effective_start_date,
                                           p_ee_effective_end_date => p_ee_effective_end_date);
--
  open csr_entry_value;
  fetch csr_entry_value into l_value;
  close csr_entry_value;
--
  return l_value;
--
end get_entry_value;
--------------------------------------------------------------------------------
--
-- Bug# 2425705
-- Procedure create_entries gets the element_type_ids for the assignments_ids which
-- are passed from the form and calls procedure create_entry_for_assignment to create.
-- an entry for each selected element_type_id.
-- This procedure is overloaded.
--
--------------------------------------------------------------------------------
procedure create_entries(p_assignment_id_tbl   g_assignment_id_tbl%type,
                         p_element_set_id      pay_element_type_rules.element_set_id%type,
                         p_run_type_id         pay_run_types.run_type_id%type,
                         p_business_group_id   hr_assignment_sets.business_group_id%type,
                         p_session_date        date)
 is
 i number;
 p_element_type_id              pay_element_types.element_type_id%type;
 p_assignment_id                pay_assignment_actions.assignment_id%type;
 l_element_entry_id             number;
 l_effective_start_date         date;
 l_effective_end_date           date;
 l_object_version_number        number;
 cursor csr_get_element_type_id(p_assignment_id       pay_assignment_actions.assignment_id%type,
                                p_element_set_id      pay_element_type_rules.element_set_id%type,
                                p_run_type_id         pay_run_types.run_type_id%type,
                                p_business_group_id   pay_element_types.business_group_id%type,
                                p_session_date        date)
 is
 select petr.element_type_id
   from pay_element_type_rules petr
  where petr.element_set_id = p_element_set_id
    and petr.include_or_exclude = 'I'
    and not exists(select null
                     from pay_element_type_rules    petr
                    where petr.element_set_id     = p_element_set_id
                      and petr.include_or_exclude = 'E')
    and not exists(select null
                     from pay_element_type_usages_f npetu
                    where npetu.element_type_id = petr.element_type_id
                      and p_session_date between npetu.effective_start_date and npetu.effective_end_date
                      and npetu.inclusion_flag = 'N'
                      and npetu.run_type_id = p_run_type_id
                      and npetu.business_group_id = p_business_group_id)
    and nvl(hr_entry_api.get_link(p_assignment_id,petr.element_type_id,p_session_date),0) <> 0
    and petr.element_type_id not in(
                   select distinct pet.element_type_id
                     from pay_element_entries_f pee,
                          pay_element_types_f   pet,
                          pay_element_links_f   pel
                    where assignment_id = p_assignment_id
                      and pet.element_type_id = pel.element_type_id
                      and pee.element_link_id = pel.element_link_id
                      and p_session_date between pet.effective_start_date and pet.effective_end_date
                      and p_session_date between pel.effective_start_date and pel.effective_end_date
                      and p_session_date between pee.effective_start_date and pee.effective_end_date
                      and (pet.business_group_id is null or pet.business_group_id = p_business_group_id)
                      and (pel.business_group_id is null or pel.business_group_id = p_business_group_id));
 begin
   for i in p_assignment_id_tbl.first..p_assignment_id_tbl.last
   loop
     open csr_get_element_type_id(p_assignment_id_tbl(i),p_element_set_id,p_run_type_id,p_business_group_id,p_session_date);
     loop
       fetch csr_get_element_type_id into p_element_type_id;
       exit when csr_get_element_type_id%notfound;
       create_entry_for_assignment(p_assignment_id         => p_assignment_id_tbl(i),
                                   p_element_type_id       => p_element_type_id,
                                   p_business_group_id     => p_business_group_id,
                                   p_entry_type            => 'E',
                                   p_effective_date        => p_session_date,
                                   p_effective_start_date  => l_effective_start_date,
                                   p_effective_end_date    => l_effective_end_date,
                                   p_element_entry_id      => l_element_entry_id,
                                   p_object_version_number => l_object_version_number);
     end loop;
     close csr_get_element_type_id;
   end loop;
   exception
     when others then
       if csr_get_element_type_id%isopen then
         close csr_get_element_type_id;
       end if;
 end create_entries;
--------------------------------------------------------------------------------
procedure create_entries(p_assignment_set_id   hr_assignment_sets.assignment_set_id%type,
                         p_element_set_id      pay_element_type_rules.element_set_id%type,
                         p_run_type_id         pay_run_types.run_type_id%type,
                         p_business_group_id   hr_assignment_sets.business_group_id%type,
                         p_payroll_id          hr_assignment_sets.payroll_id%type,
                         p_session_date        date)
is
 p_element_type_id              pay_element_types.element_type_id%type;
 l_element_entry_id             number;
 l_effective_start_date         date;
 l_effective_end_date           date;
 l_object_version_number        number;

  cursor csr_get_assignments
  is
  select hasa.assignment_id
    from hr_assignment_sets           has,
         hr_assignment_set_amendments hasa
   where business_group_id          = p_business_group_id
     and has.assignment_set_id      = p_assignment_set_id
     and has.payroll_id             = p_payroll_id
     and hasa.assignment_set_id     = has.assignment_set_id
     and hasa.include_or_exclude    = 'I';
  cursor csr_get_element_type_id(p_assignment_id       pay_assignment_actions.assignment_id%type,
                                 p_element_set_id      pay_element_type_rules.element_set_id%type,
                                 p_run_type_id         pay_run_types.run_type_id%type,
                                 p_business_group_id   pay_element_types.business_group_id%type,
                                 p_session_date        date)
  is
   select petr.element_type_id
     from pay_element_type_rules petr
    where petr.element_set_id = p_element_set_id
      and petr.include_or_exclude = 'I'
      and not exists(select null
                       from pay_element_type_rules    petr
                      where petr.element_set_id     = p_element_set_id
                        and petr.include_or_exclude = 'E')
      and not exists(select null
                       from pay_element_type_usages_f npetu
                      where npetu.element_type_id = petr.element_type_id
                        and p_session_date between npetu.effective_start_date and npetu.effective_end_date
                        and npetu.inclusion_flag = 'N'
                        and npetu.run_type_id = p_run_type_id
                        and npetu.business_group_id = p_business_group_id)
      and nvl(hr_entry_api.get_link(p_assignment_id,petr.element_type_id,p_session_date),0) <> 0
      and petr.element_type_id not in(
                     select distinct pet.element_type_id
                       from pay_element_entries_f pee,
                            pay_element_types_f   pet,
                            pay_element_links_f   pel
                      where assignment_id = p_assignment_id
                        and pet.element_type_id = pel.element_type_id
                        and pee.element_link_id = pel.element_link_id
                        and p_session_date between pet.effective_start_date and pet.effective_end_date
                        and p_session_date between pel.effective_start_date and pel.effective_end_date
                        and p_session_date between pee.effective_start_date and pee.effective_end_date
                        and (pet.business_group_id is null or pet.business_group_id = p_business_group_id)
                        and (pel.business_group_id is null or pel.business_group_id = p_business_group_id));
begin
  open  csr_get_assignments;
  fetch csr_get_assignments bulk collect into g_assignment_id_tbl;
  close csr_get_assignments;

  for i in g_assignment_id_tbl.first..g_assignment_id_tbl.last
   loop
     open csr_get_element_type_id(g_assignment_id_tbl(i),p_element_set_id,p_run_type_id,p_business_group_id,p_session_date);
     loop
       fetch csr_get_element_type_id into p_element_type_id;
       exit when csr_get_element_type_id%notfound;
       create_entry_for_assignment(p_assignment_id         => g_assignment_id_tbl(i),
                                   p_element_type_id       => p_element_type_id,
                                   p_business_group_id     => p_business_group_id,
                                   p_entry_type            => 'E',
                                   p_effective_date        => p_session_date,
                                   p_effective_start_date  => l_effective_start_date,
                                   p_effective_end_date    => l_effective_end_date,
                                   p_element_entry_id      => l_element_entry_id,
                                   p_object_version_number => l_object_version_number);
     end loop;
     close csr_get_element_type_id;
   end loop;
   exception
    when others then
     if csr_get_element_type_id%isopen then
        close csr_get_element_type_id;
     end if;
end create_entries;
--------------------------------------------------------------------------------
--
-- Bug# 2425705
-- Procedure create_entry_for_assignment creates an entry for the assignments which
-- are passed from the Separation Pay form.
--
--------------------------------------------------------------------------------
procedure create_entry_for_assignment(p_assignment_id         in pay_assignment_actions.assignment_id%type,
                                      p_element_type_id       in pay_element_types.element_type_id%type,
                                      p_business_group_id     in pay_element_types.business_group_id%type,
                                      p_entry_type            in pay_element_entries_f.entry_type%type,
                                      p_effective_date        in date,
                                      p_effective_start_date  in out NOCOPY date,
                                      p_effective_end_date    in out NOCOPY date,
                                      p_element_entry_id      out    NOCOPY pay_element_entries_f.element_entry_id%type,
                                      p_object_version_number out    NOCOPY number)
is
  l_element_link_id       number;
  l_input_value_id1       number;
  l_input_value_id2       number;
  l_input_value_id3       number;
  l_input_value_id4       number;
  l_input_value_id5       number;
  l_input_value_id6       number;
  l_input_value_id7       number;
  l_input_value_id8       number;
  l_input_value_id9       number;
  l_input_value_id10      number;
  l_input_value_id11      number;
  l_input_value_id12      number;
  l_input_value_id13      number;
  l_input_value_id14      number;
  l_input_value_id15      number;
  l_default_value1        varchar2(1000);
  l_default_value2        varchar2(1000);
  l_default_value3        varchar2(1000);
  l_default_value4        varchar2(1000);
  l_default_value5        varchar2(1000);
  l_default_value6        varchar2(1000);
  l_default_value7        varchar2(1000);
  l_default_value8        varchar2(1000);
  l_default_value9        varchar2(1000);
  l_default_value10       varchar2(1000);
  l_default_value11       varchar2(1000);
  l_default_value12       varchar2(1000);
  l_default_value13       varchar2(1000);
  l_default_value14       varchar2(1000);
  l_default_value15       varchar2(1000);
  l_b_default_value1      varchar2(1000);
  l_b_default_value2      varchar2(1000);
  l_b_default_value3      varchar2(1000);
  l_b_default_value4      varchar2(1000);
  l_b_default_value5      varchar2(1000);
  l_b_default_value6      varchar2(1000);
  l_b_default_value7      varchar2(1000);
  l_b_default_value8      varchar2(1000);
  l_b_default_value9      varchar2(1000);
  l_b_default_value10     varchar2(1000);
  l_b_default_value11     varchar2(1000);
  l_b_default_value12     varchar2(1000);
  l_b_default_value13     varchar2(1000);
  l_b_default_value14     varchar2(1000);
  l_b_default_value15     varchar2(1000);
begin
savepoint period_not_exists;
pay_kr_sep_form_pkg.get_default_value(
  p_assignment_id        => p_assignment_id,
  p_element_type_id      => p_element_type_id,
  p_business_group_id    => p_business_group_id,
  p_entry_type           => 'E',
  p_effective_date       => p_effective_date,
  p_element_link_id      => l_element_link_id,
  p_input_value_id1      => l_input_value_id1,
  p_input_value_id2      => l_input_value_id2,
  p_input_value_id3      => l_input_value_id3,
  p_input_value_id4      => l_input_value_id4,
  p_input_value_id5      => l_input_value_id5,
  p_input_value_id6      => l_input_value_id6,
  p_input_value_id7      => l_input_value_id7,
  p_input_value_id8      => l_input_value_id8,
  p_input_value_id9      => l_input_value_id9,
  p_input_value_id10     => l_input_value_id10,
  p_input_value_id11     => l_input_value_id11,
  p_input_value_id12     => l_input_value_id12,
  p_input_value_id13     => l_input_value_id13,
  p_input_value_id14     => l_input_value_id14,
  p_input_value_id15     => l_input_value_id15,
  p_default_value1       => l_default_value1  ,
  p_default_value2       => l_default_value2  ,
  p_default_value3       => l_default_value3  ,
  p_default_value4       => l_default_value4  ,
  p_default_value5       => l_default_value5  ,
  p_default_value6       => l_default_value6  ,
  p_default_value7       => l_default_value7  ,
  p_default_value8       => l_default_value8  ,
  p_default_value9       => l_default_value9  ,
  p_default_value10      => l_default_value10 ,
  p_default_value11      => l_default_value11 ,
  p_default_value12      => l_default_value12 ,
  p_default_value13      => l_default_value13 ,
  p_default_value14      => l_default_value14 ,
  p_default_value15      => l_default_value15 ,
  p_b_default_value1     => l_b_default_value1,
  p_b_default_value2     => l_b_default_value2,
  p_b_default_value3     => l_b_default_value3,
  p_b_default_value4     => l_b_default_value4,
  p_b_default_value5     => l_b_default_value5,
  p_b_default_value6     => l_b_default_value6,
  p_b_default_value7     => l_b_default_value7,
  p_b_default_value8     => l_b_default_value8,
  p_b_default_value9     => l_b_default_value9,
  p_b_default_value10    => l_b_default_value10,
  p_b_default_value11    => l_b_default_value11,
  p_b_default_value12    => l_b_default_value12,
  p_b_default_value13    => l_b_default_value13,
  p_b_default_value14    => l_b_default_value14,
  p_b_default_value15    => l_b_default_value15,
  p_effective_start_date => p_effective_start_date,
  p_effective_end_date   => p_effective_end_date);
pay_kr_sep_form_pkg.insert_element_entry(
                       p_validate          => false,
                       p_assignment_id     => p_assignment_id,
                       p_business_group_id => p_business_group_id,
                       p_effective_date    => p_effective_date,
                       p_element_link_id   => l_element_link_id,
                       p_input_value_id1   => l_input_value_id1,
                       p_input_value_id2   => l_input_value_id2,
                       p_input_value_id3   => l_input_value_id3,
                       p_input_value_id4   => l_input_value_id4,
                       p_input_value_id5   => l_input_value_id5,
                       p_input_value_id6   => l_input_value_id6,
                       p_input_value_id7   => l_input_value_id7,
                       p_input_value_id8   => l_input_value_id8,
                       p_input_value_id9   => l_input_value_id9,
                       p_input_value_id10  => l_input_value_id10,
                       p_input_value_id11  => l_input_value_id11,
                       p_input_value_id12  => l_input_value_id12,
                       p_input_value_id13  => l_input_value_id13,
                       p_input_value_id14  => l_input_value_id14,
                       p_input_value_id15  => l_input_value_id15,
                       p_entry_value1      => l_default_value1  ,
                       p_entry_value2      => l_default_value2  ,
                       p_entry_value3      => l_default_value3  ,
                       p_entry_value4      => l_default_value4  ,
                       p_entry_value5      => l_default_value5  ,
                       p_entry_value6      => l_default_value6  ,
                       p_entry_value7      => l_default_value7  ,
                       p_entry_value8      => l_default_value8  ,
                       p_entry_value9      => l_default_value9  ,
                       p_entry_value10     => l_default_value10 ,
                       p_entry_value11     => l_default_value11 ,
                       p_entry_value12     => l_default_value12 ,
                       p_entry_value13     => l_default_value13 ,
                       p_entry_value14     => l_default_value14 ,
                       p_entry_value15     => l_default_value15 ,
                       p_element_entry_id      => p_element_entry_id,
                       p_effective_start_date  => p_effective_start_date,
                       p_effective_end_date    => p_effective_end_date,
                       p_object_version_number => p_object_version_number);
  exception
    when others then
      rollback to period_not_exists;
  end create_entry_for_assignment;
--------------------------------------------------------------------------------
--
-- Bug# 2425705
-- get_employee_status returns the status of an employee.
-- 'U' if an employee does not have an Interim Separation Pay run or Separation Pay run.
-- 'P' if an employee has an Interim Separation Pay run or Separation Pay run.
--
--------------------------------------------------------------------------------
function get_employee_status(p_assignment_id  pay_assignment_actions.assignment_id%type,
                             p_run_type_name  pay_run_types.run_type_name%type,
                             p_date_earned    date) return varchar2
is
status varchar2(1):='U';
cursor csr_get_status
is
select decode(prt.run_type_name,'SEP','P','SEP_I','P','U')
  from pay_assignment_actions   paa,
       pay_payroll_actions      ppa,
       pay_run_types_f          prt
 where ppa.payroll_action_id  = paa.payroll_action_id
   and ppa.run_type_id        = prt.run_type_id
   and prt.run_type_name      = p_run_type_name
   and paa.assignment_id      = p_assignment_id
   and paa.source_action_id   is not null
   and ppa.effective_date between trunc(p_date_earned,'YYYY') and p_date_earned
   order by prt.run_type_name desc;

begin
     open csr_get_status;
     fetch csr_get_status into status;
       if csr_get_status%notfound then
         status:='U';
       end if;
      close csr_get_status;
return status;
end;
------------------------------------------------------------------------------------
end pay_kr_sep_form_pkg;

/
