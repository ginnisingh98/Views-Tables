--------------------------------------------------------
--  DDL for Package Body HR_PSF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PSF_SHD" as
/* $Header: hrpsfrhi.pkb 120.6.12010000.6 2009/11/26 10:02:00 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_psf_shd.';  -- Global package name
--
function get_availability_status(p_availability_status_id number
                                ,p_business_group_id      number)
return varchar2 is
cursor c1 is select system_type_cd
             from per_shared_types
             where shared_type_id = p_availability_status_id
             and lookup_type ='POSITION_AVAILABILITY_STATUS'
             and (business_group_id = p_business_group_id or business_group_id is null);
l_avail_status varchar2(30);
begin
   open c1;
   fetch c1 into l_avail_status;
   if c1%notfound then
      close c1;
      return null ;
   else
      close c1;
   end if;
   return l_avail_status;
end;
--
procedure get_position_job_org(p_position_id number,
                               p_effective_date date default sysdate,
                               p_job_id  out nocopy number,
                               p_organization_id out nocopy number
                               ) is
cursor c1 is select job_id, organization_id
             from hr_all_positions_f
             where position_id = p_position_id
             and p_effective_date
                  between effective_start_date
                  and effective_end_date;
l_job_id number;
l_organization_id number;
begin
   open c1;
   fetch c1 into p_job_id, p_organization_id;
   close c1;
end;
---
---
---
function POS_SYSTEM_AVAILABILITY_STATUS (
--
         p_position_id      number,
         p_effective_date   date) return varchar2 is
--
cursor csr_lookup is
         select    system_type_cd
         from      per_shared_types sht, hr_all_positions_f psf
         where     shared_type_id  = psf.availability_status_id
         and       psf.position_id = p_position_id
         and       p_effective_date between psf.effective_start_date and psf.effective_end_date;
--
v_meaning          varchar2(30) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_position_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end pos_system_availability_status;
--
--
--
function SYSTEM_AVAILABILITY_STATUS (
--
         p_availability_status_id      number) return varchar2 is
--
cursor csr_lookup is
         select    system_type_cd
         from      per_shared_types
         where     shared_type_id  = p_availability_status_id;
--
v_meaning          varchar2(30) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_availability_status_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end system_availability_status;

procedure position_wf_sync(p_position_id number, p_effective_date date) is
       myparms  wf_parameter_list_t;
       l_future_change  boolean;
       l_position_id    varchar2(15);
       l_future_date    date;
       l_proc           varchar2(30);

  begin
g_debug := hr_utility.debug_enabled;
    if g_debug then
      l_proc := g_package||'position_wf_sync';
    end if;

       l_position_id := p_position_id;
       --
         hr_psf_shd.my_synch_routine(l_position_id);
if g_debug then
         hr_utility.set_location('After my_synch_routine - '  ||l_proc, 16);
end if;
  end;
  --
--
-- ----------------------------------------------------------------------------
-- |---------------------------< my_synch_routine >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure my_synch_routine(mykey in varchar2) is
        --
        l_position_id  number := to_number(mykey);
        l_plist        wf_parameter_list_t;
        l_proc         varchar2(30);
        l_dummy        varchar2(10);
        l_start_date date;
        l_expiration_date date;
        cnt number;
        l_name hr_all_positions_f_tl.name%type;
        --
      begin
        --
g_debug := hr_utility.debug_enabled;
          if g_debug then
              l_proc := g_package||'MY_SYNC_ROUTINE';
        hr_utility.set_location('Before calling WF_SYNC package:'||l_proc, 30);
          end if;

select count(*) into cnt from hr_all_positions_f where position_id = l_position_id and availability_status_id = 1;
if cnt = 0 then
select hr_general.effective_date into l_expiration_date from dual;

         wf_event.AddParameterToList( 'USER_NAME', 'POS'||':'||l_position_id, l_plist);
         wf_event.AddParameterToList( 'DISPLAYNAME', '-', l_plist);
         wf_event.AddParameterToList( 'DESCRIPTION', '-', l_plist);
         wf_event.AddParameterToList( 'orclWFOrigSystem','POS',l_plist);
         wf_event.AddParameterToList( 'orclWFOrigSystemID',l_position_id,l_plist);
         wf_event.AddParameterToList( 'orclWorkFlowNotificationPref', 'QUERY', l_plist);
         wf_event.AddParameterToList( 'orclIsEnabled', 'ACTIVE', l_plist);
         wf_event.AddParameterToList( 'ExpirationDate',to_char(l_expiration_date,wf_engine.date_format), l_plist);
         wf_event.AddParameterToList( 'WFSYNCH_OVERWRITE','TRUE',l_plist);
--         wf_event.AddParameterToList( 'Raiseerrors', 'TRUE', l_plist);

              WF_LOCAL_SYNCH.propagate_role(
                                  p_orig_system     => 'POS',
                                  p_orig_system_id  => l_position_id,
                                  p_attributes      => l_plist,
                                  p_expiration_date => l_expiration_date);
else
select min(effective_start_date), max(effective_end_date)
into l_start_date, l_expiration_date from hr_all_positions_f
where position_id = l_position_id and availability_status_id = 1;

begin
select name into l_name from hr_all_positions_f_tl where position_id = l_position_id and language = userenv('LANG');
exception when others then
null;
end;

         wf_event.AddParameterToList( 'USER_NAME', 'POS'||':'||l_position_id, l_plist);
         wf_event.AddParameterToList( 'DISPLAYNAME', l_name, l_plist);
         wf_event.AddParameterToList( 'DESCRIPTION', l_name, l_plist);
         wf_event.AddParameterToList( 'orclWFOrigSystem','POS',l_plist);
         wf_event.AddParameterToList( 'orclWFOrigSystemID',l_position_id,l_plist);
         wf_event.AddParameterToList( 'orclWorkFlowNotificationPref', 'QUERY', l_plist);
         wf_event.AddParameterToList( 'orclIsEnabled', 'ACTIVE', l_plist);
         wf_event.AddParameterToList( 'ExpirationDate',to_char(l_expiration_date,wf_engine.date_format), l_plist);
         wf_event.AddParameterToList( 'WFSYNCH_OVERWRITE','TRUE',l_plist);
--         wf_event.AddParameterToList( 'Raiseerrors', 'TRUE', l_plist);

if g_debug then
   hr_utility.set_location('l_start_date is '||l_start_date, 20);
end if;

              WF_LOCAL_SYNCH.propagate_role(
                                  p_orig_system     => 'POS',
                                  p_orig_system_id  => l_position_id,
                                  p_attributes      => l_plist,
                                  p_start_date      => l_start_date,
                                  p_expiration_date => l_expiration_date);



end if;

if g_debug then
        hr_utility.set_location('After calling WF_SYNC package:'||l_proc, 30);
end if;
        --
end my_synch_routine;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc    varchar2(72);
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc     := g_package||'constraint_error';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  If (p_constraint_name = 'HR_ALL_POSITIONS_F_FK11') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_ALL_POSITIONS_F_FK12') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_ALL_POSITIONS_F_FK4') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_ALL_POSITIONS_F_FK5') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_ALL_POSITIONS_F_FK6') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_ALL_POSITIONS_F_FK7') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_ALL_POSITIONS_F_PK') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(800, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date     in date,
   p_position_id     in number,
   p_object_version_number in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
   position_id,
   effective_start_date,
   effective_end_date,
   availability_status_id,
   business_group_id,
   entry_step_id,
   entry_grade_rule_id,
   job_id,
   location_id,
   organization_id,
   pay_freq_payroll_id,
   position_definition_id,
   position_transaction_id,
   prior_position_id,
   relief_position_id,
   entry_grade_id,
   successor_position_id,
   supervisor_position_id,
   amendment_date,
   amendment_recommendation,
   amendment_ref_number,
   bargaining_unit_cd,
   null,
   current_job_prop_end_date,
   current_org_prop_end_date,
   avail_status_prop_end_date,
   date_effective,
   date_end,
   earliest_hire_date,
   fill_by_date,
   frequency,
   fte,
   max_persons,
   name,
   overlap_period,
   overlap_unit_cd,
   pay_term_end_day_cd,
   pay_term_end_month_cd,
   permanent_temporary_flag,
   permit_recruitment_flag,
   position_type,
   posting_description,
   probation_period,
   probation_period_unit_cd,
   replacement_required_flag,
   review_flag,
   seasonal_flag,
   security_requirements,
   status,
   term_start_day_cd,
   term_start_month_cd,
   time_normal_finish,
   time_normal_start,
   update_source_cd,
   working_hours,
   works_council_approval_flag,
   work_period_type_cd,
   work_term_end_day_cd,
   work_term_end_month_cd,
        proposed_fte_for_layoff,
        proposed_date_for_layoff,
        pay_basis_id            ,
        supervisor_id           ,
        copied_to_old_table_flag,
/*
position_id               ,
effective_start_date      ,
effective_end_date        ,
availability_status_id    ,
business_group_id         ,
entry_step_id             ,
entry_grade_rule_id       ,
job_id                    ,
location_id               ,
organization_id           ,
pay_freq_payroll_id       ,
position_definition_id    ,
position_transaction_id   ,
prior_position_id         ,
relief_position_id        ,
entry_grade_id            ,
successor_position_id     ,
supervisor_position_id    ,
amendment_date            ,
amendment_recommendation  ,
amendment_ref_number      ,
bargaining_unit_cd        ,
comments                  ,
current_job_prop_end_date ,
current_org_prop_end_date ,
avail_status_prop_end_date,
date_effective            ,
date_end                  ,
earliest_hire_date        ,
fill_by_date              ,
frequency                 ,
fte                       ,
max_persons               ,
name                      ,
overlap_period            ,
overlap_unit_cd           ,
pay_term_end_day_cd       ,
pay_term_end_month_cd     ,
permanent_temporary_flag  ,
permit_recruitment_flag   ,
position_type             ,
posting_description       ,
probation_period          ,
probation_period_unit_cd  ,
replacement_required_flag ,
review_flag               ,
seasonal_flag             ,
security_requirements     ,
status                    ,
term_start_day_cd         ,
term_start_month_cd       ,
time_normal_finish        ,
time_normal_start         ,
update_source_cd          ,
working_hours             ,
works_council_approval_flag,
work_period_type_cd       ,
work_term_end_day_cd      ,
work_term_end_month_cd    ,
proposed_fte_for_layoff   ,
proposed_date_for_layoff  ,
pay_basis_id              ,
supervisor_id             ,
copied_to_old_table_flag  ,
*/
   information1,
   information2,
   information3,
   information4,
   information5,
   information6,
   information7,
   information8,
   information9,
   information10,
   information11,
   information12,
   information13,
   information14,
   information15,
   information16,
   information17,
   information18,
   information19,
   information20,
   information21,
   information22,
   information23,
   information24,
   information25,
   information26,
   information27,
   information28,
   information29,
   information30,
   information_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30,
   attribute_category,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   object_version_number,
   null
    from hr_all_positions_f
    where   position_id = p_position_id
    and     p_effective_date
    between effective_start_date and effective_end_date;
--
  l_proc varchar2(72);
  l_fct_ret boolean;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc      := g_package||'api_updating';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  If (p_effective_date is null or
      p_position_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_position_id = g_old_rec.position_id and
        p_object_version_number = g_old_rec.object_version_number) Then
if g_debug then
      hr_utility.set_location(l_proc, 10);
end if;
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
if g_debug then
      hr_utility.set_location(l_proc, 15);
end if;
      l_fct_ret := true;
    End If;
  End If;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end if;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
   (p_effective_date in  date,
    p_base_key_value in  number,
    p_zap       out nocopy boolean,
    p_delete    out nocopy boolean,
    p_future_change out nocopy boolean,
    p_delete_next_change out nocopy boolean) is
--
  l_proc       varchar2(72);
--
  l_parent_key_value1   number;
  l_parent_key_value2   number;
  l_parent_key_value3   number;
--  l_parent_key_value4 number;
  --
  Cursor C_Sel1 Is
    select  t.supervisor_position_id,
            t.successor_position_id,
            t.relief_position_id
    from    hr_all_positions_f t
    where   t.position_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc  := g_package||'find_dt_del_modes';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
          l_parent_key_value2,
          l_parent_key_value3;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date       =>  p_effective_date,
    p_base_table_name   => 'hr_all_positions_f',
    p_base_key_column   => 'position_id',
    p_base_key_value       =>  p_base_key_value,
    p_parent_table_name1   => 'hr_all_positions_f',
    p_parent_key_column1   => 'successor_position_id',
    p_parent_key_value1 =>  l_parent_key_value1,
    p_parent_table_name2   => 'hr_all_positions_f',
    p_parent_key_column2   => 'relief_position_id',
    p_parent_key_value2 =>  l_parent_key_value2,
    p_parent_table_name3   => 'hr_all_positions_f',
    p_parent_key_column3   => 'supervisor_position_id',
    p_parent_key_value3 =>  l_parent_key_value3,
    p_zap         =>  p_zap,
    p_delete            =>  p_delete,
    p_future_change        =>  p_future_change,
    p_delete_next_change   =>  p_delete_next_change);
  --
  p_delete := false ;

if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
   (p_effective_date in  date,
    p_base_key_value in  number,
    p_correction   out nocopy boolean,
    p_update    out nocopy boolean,
    p_update_override out nocopy boolean,
    p_update_change_insert out nocopy boolean) is
--
  l_proc    varchar2(72);
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'find_dt_upd_modes';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
   (p_effective_date       => p_effective_date,
    p_base_table_name   => 'hr_all_positions_f',
    p_base_key_column   => 'position_id',
    p_base_key_value    => p_base_key_value,
    p_correction     => p_correction,
    p_update            => p_update,
    p_update_override   => p_update_override,
    p_update_change_insert => p_update_change_insert);
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
   (p_effective_date    in date,
    p_base_key_value    in number,
    p_new_effective_end_date  in date,
    p_validation_start_date   in date,
    p_validation_end_date     in date,
         p_object_version_number       out nocopy number) is
--
  l_proc         varchar2(72);
  l_object_version_number number;
--
Begin
g_debug := hr_utility.debug_enabled;
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc  := g_package||'upd_effective_end_date';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
   (p_base_table_name   => 'hr_all_positions_f',
    p_base_key_column   => 'position_id',
    p_base_key_value => p_base_key_value);
  --
if g_debug then
  hr_utility.set_location(l_proc, 10);
end if;
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  hr_all_positions_f t
  set   t.effective_end_date    = p_new_effective_end_date,
     t.object_version_number = l_object_version_number
  where    t.position_id     = p_base_key_value
  and   p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  p_object_version_number := l_object_version_number;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 15);
end if;
--
Exception
  When Others Then
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
   (p_effective_date  in  date,
    p_datetrack_mode  in  varchar2,
    p_position_id  in  number,
    p_object_version_number in  number,
    p_validation_start_date out nocopy date,
    p_validation_end_date   out nocopy date) is
--
  l_proc      varchar2(72);
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_invalid     exception;
  l_argument        varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
   position_id,
   effective_start_date,
   effective_end_date,
   availability_status_id,
   business_group_id,
   entry_step_id,
   entry_grade_rule_id,
   job_id,
   location_id,
   organization_id,
   pay_freq_payroll_id,
   position_definition_id,
   position_transaction_id,
   prior_position_id,
   relief_position_id,
   entry_grade_id,
   successor_position_id,
   supervisor_position_id,
   amendment_date,
   amendment_recommendation,
   amendment_ref_number,
   bargaining_unit_cd,
   comments,
   current_job_prop_end_date,
   current_org_prop_end_date,
   avail_status_prop_end_date,
   date_effective,
   date_end,
   earliest_hire_date,
   fill_by_date,
   frequency,
   fte,
   max_persons,
   name,
   overlap_period,
   overlap_unit_cd,
   pay_term_end_day_cd,
   pay_term_end_month_cd,
   permanent_temporary_flag,
   permit_recruitment_flag,
   position_type,
   posting_description,
   probation_period,
   probation_period_unit_cd,
   replacement_required_flag,
   review_flag,
   seasonal_flag,
   security_requirements,
   status,
   term_start_day_cd,
   term_start_month_cd,
   time_normal_finish,
   time_normal_start,
   update_source_cd,
   working_hours,
   works_council_approval_flag,
   work_period_type_cd,
   work_term_end_day_cd,
   work_term_end_month_cd,
      proposed_fte_for_layoff,
      proposed_date_for_layoff,
pay_basis_id              ,
supervisor_id             ,
copied_to_old_table_flag  ,
   information1,
   information2,
   information3,
   information4,
   information5,
   information6,
   information7,
   information8,
   information9,
   information10,
   information11,
   information12,
   information13,
   information14,
   information15,
   information16,
   information17,
   information18,
   information19,
   information20,
   information21,
   information22,
   information23,
   information24,
   information25,
   information26,
   information27,
   information28,
   information29,
   information30,
   information_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30,
   attribute_category,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   object_version_number,
   null
    from    hr_all_positions_f
    where   position_id         = p_position_id
    and      p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  --
  --
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc   := g_package||'lck';
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
                             p_argument       => 'position_id',
                             p_argument_value => p_position_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
    End If;
if g_debug then
    hr_utility.set_location(l_proc, 15);
end if;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
if g_debug then
    hr_utility.set_location(' effective date ' || p_Effective_Date || l_proc, 12125);
end if;

    -- Bug 3199913
    -- Removed refernce to 'per_all_assignments_f' since assignment and position
    -- do not have parent-child relationship.
    -- Removed refernce to 'pay_element_links_f' since element links and position
    -- do not have parent-child relationship.
    -- Removed reference to 'pay_payrolls_f'

    dt_api.validate_dt_mode
   (p_effective_date    => p_effective_date,
    p_datetrack_mode    => p_datetrack_mode,
    p_base_table_name      => 'hr_all_positions_f',
    p_base_key_column      => 'position_id',
    p_base_key_value       => p_position_id,
    p_parent_table_name1      => 'hr_all_positions_f',
    p_parent_key_column1      => 'successor_position_id',
    p_parent_key_value1       => g_old_rec.successor_position_id,
    p_parent_table_name2      => 'hr_all_positions_f',
    p_parent_key_column2      => 'relief_position_id',
    p_parent_key_value2       => g_old_rec.relief_position_id,
    p_parent_table_name3      => 'hr_all_positions_f',
    p_parent_key_column3      => 'supervisor_position_id',
    p_parent_key_value3       => g_old_rec.supervisor_position_id,
/*
    p_child_table_name3       => 'hr_all_positions_f',
    p_child_key_column3       => 'position_id',
    p_child_table_name4       => 'hr_all_positions_f',
    p_child_key_column4       => 'position_id',
*/
    p_enforce_foreign_locking => true,
    p_validation_start_date   => l_validation_start_date,
    p_validation_end_date     => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  End If;
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
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(800, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'hr_all_positions_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'hr_all_positions_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
   (
   p_position_id                   in number,
   p_effective_start_date          in date,
   p_effective_end_date            in date,
   p_availability_status_id        in number,
   p_business_group_id             in number,
   p_entry_step_id                 in number,
   p_entry_grade_rule_id           in number,
   p_job_id                        in number,
   p_location_id                   in number,
   p_organization_id               in number,
   p_pay_freq_payroll_id           in number,
   p_position_definition_id        in number,
   p_position_transaction_id       in number,
   p_prior_position_id             in number,
   p_relief_position_id            in number,
   p_entry_grade_id         in number,
   p_successor_position_id         in number,
   p_supervisor_position_id        in number,
   p_amendment_date                in date,
   p_amendment_recommendation      in varchar2,
   p_amendment_ref_number          in varchar2,
   p_bargaining_unit_cd            in varchar2,
   p_comments                      in varchar2,
   p_current_job_prop_end_date     in date,
   p_current_org_prop_end_date     in date,
   p_avail_status_prop_end_date    in date,
   p_date_effective                in date,
   p_date_end                      in date,
   p_earliest_hire_date            in date,
   p_fill_by_date                  in date,
   p_frequency                     in varchar2,
   p_fte                           in number,
   p_max_persons                   in number,
   p_name                          in varchar2,
   p_overlap_period                in number,
   p_overlap_unit_cd               in varchar2,
   p_pay_term_end_day_cd           in varchar2,
   p_pay_term_end_month_cd         in varchar2,
   p_permanent_temporary_flag      in varchar2,
   p_permit_recruitment_flag       in varchar2,
   p_position_type                 in varchar2,
   p_posting_description           in varchar2,
   p_probation_period              in number,
   p_probation_period_unit_cd      in varchar2,
   p_replacement_required_flag     in varchar2,
   p_review_flag                   in varchar2,
   p_seasonal_flag                 in varchar2,
   p_security_requirements         in varchar2,
   p_status                        in varchar2,
   p_term_start_day_cd             in varchar2,
   p_term_start_month_cd           in varchar2,
   p_time_normal_finish            in varchar2,
   p_time_normal_start             in varchar2,
   p_update_source_cd              in varchar2,
   p_working_hours                 in number,
   p_works_council_approval_flag   in varchar2,
   p_work_period_type_cd           in varchar2,
   p_work_term_end_day_cd          in varchar2,
   p_work_term_end_month_cd        in varchar2,
        p_proposed_fte_for_layoff       in number,
        p_proposed_date_for_layoff      in date,
        p_pay_basis_id                  in number,
        p_supervisor_id                 in number,
        p_copied_to_old_table_flag      in varchar2,
   p_information1                  in varchar2,
   p_information2                  in varchar2,
   p_information3                  in varchar2,
   p_information4                  in varchar2,
   p_information5                  in varchar2,
   p_information6                  in varchar2,
   p_information7                  in varchar2,
   p_information8                  in varchar2,
   p_information9                  in varchar2,
   p_information10                 in varchar2,
   p_information11                 in varchar2,
   p_information12                 in varchar2,
   p_information13                 in varchar2,
   p_information14                 in varchar2,
   p_information15                 in varchar2,
   p_information16                 in varchar2,
   p_information17                 in varchar2,
   p_information18                 in varchar2,
   p_information19                 in varchar2,
   p_information20                 in varchar2,
   p_information21                 in varchar2,
   p_information22                 in varchar2,
   p_information23                 in varchar2,
   p_information24                 in varchar2,
   p_information25                 in varchar2,
   p_information26                 in varchar2,
   p_information27                 in varchar2,
   p_information28                 in varchar2,
   p_information29                 in varchar2,
   p_information30                 in varchar2,
   p_information_category          in varchar2,
   p_attribute1                    in varchar2,
   p_attribute2                    in varchar2,
   p_attribute3                    in varchar2,
   p_attribute4                    in varchar2,
   p_attribute5                    in varchar2,
   p_attribute6                    in varchar2,
   p_attribute7                    in varchar2,
   p_attribute8                    in varchar2,
   p_attribute9                    in varchar2,
   p_attribute10                   in varchar2,
   p_attribute11                   in varchar2,
   p_attribute12                   in varchar2,
   p_attribute13                   in varchar2,
   p_attribute14                   in varchar2,
   p_attribute15                   in varchar2,
   p_attribute16                   in varchar2,
   p_attribute17                   in varchar2,
   p_attribute18                   in varchar2,
   p_attribute19                   in varchar2,
   p_attribute20                   in varchar2,
   p_attribute21                   in varchar2,
   p_attribute22                   in varchar2,
   p_attribute23                   in varchar2,
   p_attribute24                   in varchar2,
   p_attribute25                   in varchar2,
   p_attribute26                   in varchar2,
   p_attribute27                   in varchar2,
   p_attribute28                   in varchar2,
   p_attribute29                   in varchar2,
   p_attribute30                   in varchar2,
   p_attribute_category            in varchar2,
   p_request_id                    in number,
   p_program_application_id        in number,
   p_program_id                    in number,
   p_program_update_date           in date,
   p_object_version_number         in number,
   p_security_profile_id      in number
   )
   Return g_rec_type is
--
  l_rec    g_rec_type;
  l_proc  varchar2(72);
--
Begin
  --
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc   := g_package||'convert_args';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.position_id                      := p_position_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.availability_status_id           := p_availability_status_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.entry_step_id                    := p_entry_step_id;
  l_rec.entry_grade_rule_id              := p_entry_grade_rule_id;
  l_rec.job_id                           := p_job_id;
  l_rec.location_id                      := p_location_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.pay_freq_payroll_id              := p_pay_freq_payroll_id;
  l_rec.position_definition_id           := p_position_definition_id;
  l_rec.position_transaction_id          := p_position_transaction_id;
  l_rec.prior_position_id                := p_prior_position_id;
  l_rec.relief_position_id               := p_relief_position_id;
  l_rec.entry_grade_id                   := p_entry_grade_id;
  l_rec.successor_position_id            := p_successor_position_id;
  l_rec.supervisor_position_id           := p_supervisor_position_id;
  l_rec.amendment_date                   := p_amendment_date;
  l_rec.amendment_recommendation         := p_amendment_recommendation;
  l_rec.amendment_ref_number             := p_amendment_ref_number;
  l_rec.bargaining_unit_cd               := p_bargaining_unit_cd;
  l_rec.comments                         := p_comments;
  l_rec.current_job_prop_end_date        := p_current_job_prop_end_date;
  l_rec.current_org_prop_end_date        := p_current_org_prop_end_date;
  l_rec.avail_status_prop_end_date       := p_avail_status_prop_end_date;
  l_rec.date_effective                   := p_date_effective;
  l_rec.date_end                         := p_date_end;
  l_rec.earliest_hire_date               := p_earliest_hire_date;
  l_rec.fill_by_date                     := p_fill_by_date;
  l_rec.frequency                        := p_frequency;
  l_rec.fte                              := p_fte;
  l_rec.max_persons                      := p_max_persons;
  l_rec.name                             := p_name;
  l_rec.overlap_period                   := p_overlap_period;
  l_rec.overlap_unit_cd                  := p_overlap_unit_cd;
  l_rec.pay_term_end_day_cd              := p_pay_term_end_day_cd;
  l_rec.pay_term_end_month_cd            := p_pay_term_end_month_cd;
  l_rec.permanent_temporary_flag         := p_permanent_temporary_flag;
  l_rec.permit_recruitment_flag          := p_permit_recruitment_flag;
  l_rec.position_type                    := p_position_type;
  l_rec.posting_description              := p_posting_description;
  l_rec.probation_period                 := p_probation_period;
  l_rec.probation_period_unit_cd         := p_probation_period_unit_cd;
  l_rec.replacement_required_flag        := p_replacement_required_flag;
  l_rec.review_flag                      := p_review_flag;
  l_rec.seasonal_flag                    := p_seasonal_flag;
  l_rec.security_requirements            := p_security_requirements;
  l_rec.status                           := p_status;
  l_rec.term_start_day_cd                := p_term_start_day_cd;
  l_rec.term_start_month_cd              := p_term_start_month_cd;
  l_rec.time_normal_finish               := p_time_normal_finish;
  l_rec.time_normal_start                := p_time_normal_start;
  l_rec.update_source_cd                 := p_update_source_cd;
  l_rec.working_hours                    := p_working_hours;
  l_rec.works_council_approval_flag      := p_works_council_approval_flag;
  l_rec.work_period_type_cd              := p_work_period_type_cd;
  l_rec.work_term_end_day_cd             := p_work_term_end_day_cd;
  l_rec.work_term_end_month_cd           := p_work_term_end_month_cd;
  l_rec.proposed_fte_for_layoff          := p_proposed_fte_for_layoff;
  l_rec.proposed_date_for_layoff         := p_proposed_date_for_layoff;
  l_rec.pay_basis_id                     := p_pay_basis_id;
  l_rec.supervisor_id                    := p_supervisor_id;
  l_rec.copied_to_old_table_flag         := p_copied_to_old_table_flag;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
  l_rec.information_category             := p_information_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.security_profile_id       := p_security_profile_id;
  --
  -- Return the plsql record structure.
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
  Return(l_rec);
--
End convert_args;
--
end hr_psf_shd;

/
