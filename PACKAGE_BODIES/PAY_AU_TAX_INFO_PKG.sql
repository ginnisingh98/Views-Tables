--------------------------------------------------------
--  DDL for Package Body PAY_AU_TAX_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_TAX_INFO_PKG" as
/* $Header: pyautinf.pkb 120.2.12010000.1 2008/10/28 01:53:40 keyazawa noship $ */
--
c_package                  constant varchar2(31) := 'pay_au_tax_info_pkg.';
--
c_legislation_code         per_business_groups_perf.legislation_code%type := 'AU';
--
c_tax_info_elm             constant pay_element_types_f.element_name%type := 'Tax Information';
--
c_iv_upper varchar2(1) := 'N';
--
type t_input_value_id_rec is record(
  input_value_id pay_input_values_f.input_value_id%type,
  name           pay_input_values_f.name%type);
type t_input_value_id_tbl is table of t_input_value_id_rec index by binary_integer;
--
g_input_value_id_tbl       t_input_value_id_tbl;
g_tax_info_elm_id          number;
--
g_debug                    boolean := hr_utility.debug_enabled;
--
-- -------------------------------------------------------------------------
-- get_element_type_id
-- -------------------------------------------------------------------------
function get_element_type_id(
            p_element_name in varchar2,
            p_element_type_id in number)
return number
is
--
  cursor csr_element_type_id
  is
  select element_type_id
  from   pay_element_types_f
  where  element_name = p_element_name
  and    legislation_code = c_legislation_code;
--
  l_element_type_id number := p_element_type_id;
--
begin
--
  if l_element_type_id is null then
  --
    open csr_element_type_id;
    fetch csr_element_type_id into l_element_type_id;
    close csr_element_type_id;
  --
  end if;
--
return l_element_type_id;
end get_element_type_id;
--
-- -------------------------------------------------------------------------
-- get_input_value_id
-- -------------------------------------------------------------------------
function get_input_value_id(
           p_element_type_id in number,
           p_input_value_name in varchar2,
           p_input_value_id in number)
return number
is
--
  cursor csr_input_value_id
  is
  select input_value_id,
         decode(c_iv_upper,'Y',upper(name),name) iv_name
  from   pay_input_values_f
  where  element_type_id = p_element_type_id
  and    legislation_code = c_legislation_code;
--
  l_iv_tbl_name pay_input_values_f.name%type;
  l_iv_tbl_id   pay_input_values_f.input_value_id%type;
--
  l_iv_tbl_cnt number := 0;
  l_input_value_id number := p_input_value_id;
--
begin
--
  if l_input_value_id is null then
  --
    if g_input_value_id_tbl.count = 0 then
    --
      open csr_input_value_id;
      loop
      --
        fetch csr_input_value_id into
          l_iv_tbl_id,
          l_iv_tbl_name;
        exit when csr_input_value_id%notfound;
      --
        g_input_value_id_tbl(l_iv_tbl_cnt).name := l_iv_tbl_name;
        g_input_value_id_tbl(l_iv_tbl_cnt).input_value_id := l_iv_tbl_id;
      --
        l_iv_tbl_cnt := l_iv_tbl_cnt + 1;
      --
      end loop;
      close csr_input_value_id;
    --
    end if;
    --
    for i in 0..g_input_value_id_tbl.count loop
    --
      if g_input_value_id_tbl(i).name = p_input_value_name then
      --
        l_input_value_id := g_input_value_id_tbl(i).input_value_id;
        exit;
      --
      end if;
    --
    end loop;
  --
  end if;
--
return l_input_value_id;
end get_input_value_id;
--
-- -------------------------------------------------------------------------
-- set_eev_upd_mode
-- -------------------------------------------------------------------------
procedure set_eev_upd_mode(
           p_assignment_id  in number,
           p_session_date   in date,
           p_scl_upd_mode   in varchar2,
           p_scl_upd_esd    in date,
           p_eev_upd_esd    in date,
           p_update_mode    out nocopy varchar2,
           p_effective_date out nocopy date,
           p_warning        out nocopy varchar2)
is
--
  l_proc varchar2(80) := c_package||'set_eev_upd_mode';
--
  l_update_mode varchar2(60);
  l_effective_date date;
  l_warning fnd_new_messages.message_name%type;
--
  l_tax_info_fut_ee_id number;
--
  cursor csr_tax_info_fut_ee
  is
  select /*+ ORDERED
             USE_NL(PA,PEL,PEE)
             INDEX(PA PER_ASSIGNMENTS_F_PK)
             INDEX(PEL PAY_ELEMENT_LINKS_F_N7)
             INDEX(PEE PAY_ELEMENT_ENTRIES_F_N51) */
         pee.element_entry_id
  from   per_all_assignments_f pa,
         pay_element_links_f pel,
         pay_element_entries_f pee
  where  pa.assignment_id = p_assignment_id
  and    l_effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pel.element_type_id = g_tax_info_elm_id
  and    l_effective_date
         between pel.effective_start_date and pel.effective_end_date
  and    pel.business_group_id + 0 = pa.business_group_id
  and    pee.assignment_id = pa.assignment_id
  and    pee.element_link_id = pel.element_link_id
  and    pee.effective_start_date > l_effective_date
  and    pee.effective_end_date > l_effective_date;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  g_tax_info_elm_id   := get_element_type_id(c_tax_info_elm, g_tax_info_elm_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('g_tax_info_elm_id : '||to_char(g_tax_info_elm_id));
  end if;
--
  if p_scl_upd_mode = hr_api.g_correction then
  --
    l_effective_date := p_scl_upd_esd;
  --
  else
  --
    l_effective_date := p_session_date;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('l_effective_date : '||to_char(l_effective_date,'YYYY/MM/DD'));
  end if;
--
  open csr_tax_info_fut_ee;
  fetch csr_tax_info_fut_ee into l_tax_info_fut_ee_id;
  close csr_tax_info_fut_ee;
--
  if g_debug then
    hr_utility.set_location(l_proc,30);
    hr_utility.trace('l_tax_info_fut_ee_id : '||to_char(l_tax_info_fut_ee_id));
  end if;
--
-- no support alternative hr_api.g_update_override and hr_api.g_correction option
-- because double asking update option on assignment window (for assignment change and eev change)
-- will be complicated use, which window is for assignment change or for eev change.
--
  if l_tax_info_fut_ee_id is not null then
  --
    if trunc(l_effective_date,'DD') = trunc(p_eev_upd_esd,'DD') then
    --
      l_update_mode := hr_api.g_correction;
      l_warning := 'HR_AU_TAX_SCALE_SYNC_WNG';
    --
    else
    --
      if p_scl_upd_mode = hr_api.g_update_override then
      --
        -- no support hr_api.g_update_override
        -- (use hr_api.g_update_change_insert instead, plus message)
        --
        --l_update_mode := hr_api.g_update_override;
        --
        l_update_mode := hr_api.g_update_change_insert;
        l_warning := 'HR_AU_TAX_SCALE_SYNC_WNG';
      --
      else
      --
      -- show warning in case hr_api.g_update_change_insert is set.
      -- no support hr_api.g_update_override
      --
      -- create history to sync with scl DateTrack
      -- no support hr_api.g_correction by customer option
      --
        l_update_mode := hr_api.g_update_change_insert;
        l_warning := 'HR_AU_TAX_SCALE_SYNC_WNG';
      --
      end if;
    --
    end if;
  --
  else
  --
    if trunc(l_effective_date,'DD') = trunc(p_eev_upd_esd,'DD') then
    --
      l_update_mode := hr_api.g_correction;
    --
    else
    --
    -- create history to sync with scl DateTrack
    -- no support hr_api.g_correction by customer option
    --
      l_update_mode := hr_api.g_update;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,40);
    hr_utility.trace('l_update_mode : '||l_update_mode);
    hr_utility.trace('l_warning     : '||l_warning);
  end if;
--
  p_update_mode    := l_update_mode;
  p_effective_date := l_effective_date;
  p_warning        := l_warning;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end set_eev_upd_mode;
--
end pay_au_tax_info_pkg;

/
