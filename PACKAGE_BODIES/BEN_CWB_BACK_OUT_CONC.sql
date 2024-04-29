--------------------------------------------------------
--  DDL for Package Body BEN_CWB_BACK_OUT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_BACK_OUT_CONC" as
/* $Header: bencwbbo.pkb 120.10.12010000.5 2009/06/05 13:24:45 sgnanama ship $ */
--
/* ============================================================================
*    Name
*       Back-out Compensation Life Events Concurrent Manager Processes
*
*    Purpose
*       This is a new package added to backout data created by the CWB global
*       budget.
*       This package houses the  procedure which would be called from
*       the concurrent manager.
*
*    History
*      Date        Who        Version    What?
*      ---------   ---------  -------    --------------------------------------
*      16-Jan-04   rpgupta    115.0      Created
       09-Feb-04   nhunur     115.1      commented business_group_id clause
       16-Feb-04   nhunur     115.2      commented business_group_id,ler_id clause
       20-feb-04   nhunur     115.3      removed latest check call
       03-Mar-04   rpgupta    115.4      1. Commented delete dmls and added calls to api's
       19-Mar-04   pbodla     115.5      Bug 3517726 : CWB data is not getting deleted.
       23-Mar-04   nhunur     115.6      removed if clause before cwb delete,added distinct
                                         clause for person rates cursor.
       25-Mar-04   rpgupta    115.7      Changed logic for person selection to work like
       					 participation process.
       26-Mar-04   pbodla     115.8      Added code to delete
                                            BEN_CWB_PERSON_INFO,
                                             BEN_CWB_SUMMARY,
                                              ben_cwb_pl_dsgn
       26-Mar-04   pbodla     115.9      l_ocrd_date need to be passed to
                                         BEN_CWB_PL_DSGN_PKG.delete_pl_dsgn
       27-Apr-04   rpgupta    115.13     bug 3517726 - elete records in ben_cwb_person_rates
                                         with the given group_pl_id, ler_id and life event
                                         ocrd date. Sometimes when one thread of benmngle
                                         fails, theres a possibility that a few records in
                                         person_rates exist with group_per_in_ler_id as -1
       27-Apr-04   rpgupta    115.14/15  Added online backout procedure/trace calls.
       01-Feb-2005 steotia    115.16     cwb_delete_routine and ben_cwb_person_info API
                                         used to delete person_info record
       11-Feb-2005 pbodla     115.17     Bug 4021004 : when group per in ler
                                         is backed out it is not backing out the
                                         heirarchy data and not resetting
                                         heirarchy data for reporting employees
                                         linked to this PIL.
       23-Feb-2005 pbodla     115.18     4109090 : Removed the coun(*) statements which
                                         are causing performance problems.
       28-Feb-2005 nhunur     115.19     added code to close cursors in all conditions
       13-apr-2005 nhunur     115.20     bug 4300599 - added code to handle person sel rule exceptions.
       23-sep-2005 pbodla     115.21     bug 4598824 - Romove element entry if
                                         life event backed out.
                                         Added get_ele_dt_del_mode, backout_cwb_element
       12-oct-2005 pbodla     115.22     bug 4653929 - Backout is not deleting
                                         cwb plan design data as some life events
                                         are not getting deleted : some cases
                                         are - person hired and processed after
                                         the life event occured date.
                                         - As heirarchy data is in contention
                                         it should be moved out of multi thread
       30-Nov-2005 pbodla     115.23     Bug 4758468 : join condition is missing
                                         in c_group_pils.
       08-Mar-2006 stee       115.24     Bug 5060080 : Fix cursor to not delete
                                         all the person rates for a plan and
                                         life event occurred date. If there
                                         is more than 1 life event for the
                                         person, the person rates are also
                                         deleted and the element entries are
                                         not backed out.
       06-Apr-2006 abparekh  115.25      Bug 5130397 : When CWB plan has options attached,
                                         then while backing out BEN_CWB_PERSON_RATES rows
                                         delete pay proposal only once
       25-May-2006 ikasired  115.26      Bug 5240208 fix for heirarchy issue for
                                         reassign, backout and reprocess issue
       26-May-2006 maagrawa  115.27      Always run summary refresh at end
                                         when running backout in batch.
                                         In online mode, call delete apis
                                         with update_summary ON.
       21-aug-06   nhunur    115.28      Report any broken hierarchies, people who do not have
                                         a level 1 manager but have a worksheet manager id
       20-sep-06   nhunur    115.29      Reformat the list of people and change message.
       06-Feb-07   maagrawa  115.30      When more than 1 person_rates record
                                         exists for a group_per_in_ler_id,
                                         pl_id, oipl_id combination, you get
                                         a error when calling delete api for
                                         2nd record.
       05-May-09  sgnanama   115.32      8392328: Added the cursor c_get_ovn to get the
                                         correct ovn for future_change of element entries
       26-May-09  sgnanama   115.33      8548730: Got the correct delete mode for recurring
                                         element with the modified effective date
     5-Jun-09 sgnanama 120.10.12010000.5 5264858: ER Webadi customize prompts
* -----------------------------------------------------------------------------
*/

/* global variables */
g_package                 varchar2(80) := 'ben_cwb_back_out_conc';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_max_errors_allowed      number(9) := 200;
g_rec                     ben_type.g_report_rec;
g_debug boolean := hr_utility.debug_enabled;
--
/*
procedure backout_heirarchy_data
                        (p_per_in_ler_id          in number
                         ) is
  cursor c_chr is
    select rowid
        from ben_cwb_group_hrchy
        where mgr_per_in_ler_id  =  p_per_in_ler_id;
  --
  l_proc                        varchar2(50) := g_package||'.cwb_delete_routine';
begin
    --
    hr_utility.set_location( 'Entering '|| l_proc, 5);
    --
    -- Delete heirarchy data : bug 4021004
    --
    delete from ben_cwb_group_hrchy hrc
           where emp_per_in_ler_id = p_per_in_ler_id;
    --
    -- Now delete all the data where this per in ler id is manager
    --
    for l_chr in c_chr loop
          begin
               update ben_cwb_group_hrchy set
                  mgr_per_in_ler_id = -1 ,
                  LVL_NUM = -1
               where rowid = l_chr.rowid;
          exception
              when others then
                  null;
          end;
    end loop;
    --
    hr_utility.set_location( 'Leaving '||l_proc, 50);
    --
end backout_heirarchy_data;
*/
--
--
procedure backout_heirarchy_data
                        (p_per_in_ler_id          in number
                         ) is
  cursor c_chr is
    select rowid, emp_per_in_ler_id
        from ben_cwb_group_hrchy
        where mgr_per_in_ler_id  =  p_per_in_ler_id;
  --
  l_proc                        varchar2(50) := g_package||'.cwb_delete_routine';
begin
    --
    hr_utility.set_location( 'Entering '|| l_proc, 5);
    --
    -- Delete heirarchy data : bug 4021004
    --
    delete from ben_cwb_group_hrchy hrc
           where emp_per_in_ler_id = p_per_in_ler_id;
    --
    -- Now delete all the data where this per in ler id is manager
    --
    for l_chr in c_chr loop
          begin
               update ben_cwb_group_hrchy set
                  mgr_per_in_ler_id = -1 ,
                  LVL_NUM = -1
               where rowid = l_chr.rowid;
              --
              delete from ben_cwb_group_hrchy
              where emp_per_in_ler_id = l_chr.emp_per_in_ler_id
                and LVL_NUM > -1;
              --
          exception
              when others then
                  null;
          end;
    end loop;
    --
    hr_utility.set_location( 'Leaving '||l_proc, 50);
    --
end backout_heirarchy_data;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_ele_dt_del_mode>---------------------------|
-- ----------------------------------------------------------------------------
--
function get_ele_dt_del_mode
(p_effective_date  in date,
 p_base_key_value  in number)
return varchar2 is

  l_zap_mode                  boolean;
  l_delete_mode               boolean;
  l_future_change_mode        boolean;
  l_delete_next_change_mode   boolean;
  l_del_mode                  varchar2(30);
  l_zap_start_date            date;
  l_zap_end_date              date;
  l_delete_start_date         date;
  l_delete_end_date           date;
  l_del_future_start_date     date;
  l_del_future_end_date       date;
  l_del_next_start_date       date;
  l_del_next_end_date         date;
  --
begin

  dt_api.find_dt_del_modes -- _and_dates
 (p_effective_date       => p_effective_date,
  p_base_table_name      => 'PAY_ELEMENT_ENTRIES_F',
  p_base_key_column      => 'ELEMENT_ENTRY_ID',
  p_base_key_value       => p_base_key_value,
  p_zap                  => l_zap_mode,
  p_delete               => l_delete_mode,
  p_future_change        => l_future_change_mode,
  p_delete_next_change   => l_delete_next_change_mode); /*,
  p_zap_start_date       => l_zap_start_date,
  p_zap_end_date          => l_zap_end_date,
  p_delete_start_date     => l_delete_start_date,
  p_delete_end_date       => l_delete_end_date,
  p_del_future_start_date => l_del_future_start_date,
  p_del_future_end_date   => l_del_future_end_date,
  p_del_next_start_date   => l_del_next_start_date,
  p_del_next_end_date     => l_del_next_end_date);*/
  --
  hr_utility.set_location('l_zap_start_date = ' || l_zap_start_date, 12);
  hr_utility.set_location('l_zap_end_date = ' || l_zap_end_date, 12);
  hr_utility.set_location('l_delete_start_date = ' || l_delete_start_date, 12);
  hr_utility.set_location('l_delete_end_date = ' || l_delete_end_date, 12);
  hr_utility.set_location('l_del_future_start_date = ' || l_del_future_start_date, 12);
  hr_utility.set_location('l_del_future_end_date = ' || l_del_future_end_date, 12);
  hr_utility.set_location('l_del_next_start_date = ' || l_del_next_start_date, 12);
  hr_utility.set_location('l_del_next_end_date = ' || l_del_next_end_date, 12);

  if l_zap_mode then
     hr_utility.set_location('l_zap true', 13);
  end if;
  if l_delete_mode then
     hr_utility.set_location('l_delete_mode true', 13);
  end if;
  if l_future_change_mode then
     hr_utility.set_location('l_future_change_mode true', 13);
  end if;
  if l_delete_next_change_mode then
     hr_utility.set_location('l_delete_next_change_mode true', 13);
  end if;
  if l_delete_next_change_mode = true or l_future_change_mode = true then
     l_del_mode := hr_api.g_future_change;
  else
     l_del_mode := hr_api.g_zap;
  end if;
  --
  return l_del_mode;

end get_ele_dt_del_mode;

-- ----------------------------------------------------------------------------
-- |----------------------< backout_cwb_element   >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure backout_cwb_element(
          p_validate               IN BOOLEAN
         ,p_element_entry_value_id in number
         ,p_business_group_id      IN NUMBER
         ,p_person_id              IN NUMBER
         ,p_acty_ref_perd          in varchar2 default null
         ,p_acty_base_rt_id        in number default null
         ,p_element_link_id        IN NUMBER default null
         ,p_rt_end_date            IN DATE default null
         ,p_effective_date         IN DATE default null
         ,p_dt_delete_mode         IN VARCHAR2 default null
         ,p_amt                    in number default null ) is
  --
  l_proc                     VARCHAR2(72) := 'backout_cwb_element';
  l_element_link_id          number;
  l_element_type_id          number;
  l_input_value_id           NUMBER;
  l_element_name             varchar2(80);
  l_processing_type          varchar2(30);
  l_assignment_id            NUMBER;
  l_payroll_id               NUMBER;
  l_element_entry_id         NUMBER;
  l_element_entry_start_date date;
  l_element_entry_end_date   date;
  l_object_version_number    NUMBER;
  l_original_entry_id        number;
  l_entry_type               varchar2(30);
  l_curr_val_char            varchar2 (60);
  l_delete_warning           BOOLEAN;
  l_dt_delete_mode           varchar2(80);
  l_effective_start_date     DATE;
  l_effective_end_date       DATE;
  l_effective_date           date;
  l_string                   varchar2(4000);
  L_ELEMENT_ENTRY_VALUE_ID   NUMBER;
  --
  cursor c_min_max_dt(p_element_entry_id number) is
  select min(effective_start_date),
       max(effective_end_date)
  from pay_element_entries_f
  where element_entry_id = p_element_entry_id;
  --
  l_min_start_date            date;
  l_max_end_date              date;
  --
  cursor c_ele_info(p_element_entry_value_id number) is
  select pel.element_link_id,
         pel.element_type_id,
         pev.input_value_id,
         pet.element_name,
         pet.processing_type
    from pay_element_types_f pet,
         pay_element_links_f pel,
         pay_element_entries_f pee,
         pay_element_entry_values_f pev
   where pev.element_entry_value_id = p_element_entry_value_id
     and pee.element_entry_id = pev.element_entry_id
     and pev.effective_start_date between pee.effective_start_date
     and pee.effective_end_date
     and pel.element_link_id = pee.element_link_id
     and pee.effective_start_date between pel.effective_start_date
     and pel.effective_end_date
     and pet.element_type_id = pel.element_type_id
     and pel.effective_start_date between pet.effective_start_date
     and pet.effective_end_date;
  --
  cursor get_element_entry_id (p_element_type_id         in number
                            ,p_input_value_id          in number
                            ,p_element_entry_value_id  in number
                            ,p_effective_date          in date) is
  select asg.assignment_id,
       asg.payroll_id,
       pee.element_entry_id,
       pee.effective_start_date,
       pee.effective_end_date,
       pee.object_version_number,
       pee.original_entry_id,
       pee.entry_type,
       pee.element_link_id,
       pev.screen_entry_value
  from   per_all_assignments_f asg,
       pay_element_links_f pel,
       pay_element_entries_f pee,
       pay_element_entry_values_f pev
  where  asg.person_id = p_person_id
  and    pee.assignment_id = asg.assignment_id
  and    p_effective_date between asg.effective_start_date
  and    asg.effective_end_date
  and    pee.creator_type = 'F'
  and    pee.entry_type = 'E'
  and    p_effective_date <= pee.effective_end_date
  and    pel.element_link_id = pee.element_link_id
  and    pee.effective_start_date between pel.effective_start_date
  and    pel.effective_end_date
  and    pel.element_type_id = p_element_type_id
  and    pev.element_entry_id = pee.element_entry_id
  and    pev.input_value_id = p_input_value_id
  and    (p_element_entry_value_id is null or
          pev.element_entry_value_id = p_element_entry_value_id)
  and    pev.effective_start_date between pee.effective_start_date
  and    pee.effective_end_date
  order by pee.effective_start_date ;
  --

  -- added for 8392328
  cursor c_get_ovn (p_element_entry_id  in number
	     ,p_effective_date    in date) is
  select object_version_number
  from   pay_element_entries_f pee
  where  pee.element_entry_id = p_element_entry_id
  and    p_effective_date = pee.effective_end_date;
--
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering :'||l_proc,5);
    hr_utility.set_location('Element_link_id='||to_char(p_element_link_id),6);
    hr_utility.set_location('p_element_entry_value_id='||to_char(p_element_entry_value_id),6);
    hr_utility.set_location('Effective_date='||to_char(p_effective_date),6);
    hr_utility.set_location('p_rt_end_date='||to_char(p_rt_end_date),6);
  end if;
  --
  -- After discussing with CWB team decide to go with simple approach.
  -- Issues to consider
  -- Can elements be recurring. CWB team  - not
  -- if element type is attached in cwb pl design table, can backout work ? YES
  -- Ignore proration etc., YES
  -- Element entry is shared by mutliple cwb entries ? NO
  --
  -- Assumptions.
  --   ben_cwb_person_rates.ELEMENT_ENTRY_VALUE_ID will be passed this routine.
  --   Element type from ben_cwb_plan_design overrides from abr.
  --   Abr information have to be fetched similar to cwb post process.
  --
  --
  -- if no element entry was created to start with, return
  --
  if p_element_entry_value_id is null then
     hr_utility.set_location('no element entry '||l_proc,7);
     hr_utility.set_location('Leaving: '||l_proc,7);
     return;
  end if;
  --
  -- find the element type and input value based on element_entry_value_id
  -- attached to prtt rt.
  --
  open c_ele_info(p_element_entry_value_id);
  fetch c_ele_info into
    l_element_link_id,
    l_element_type_id,
    l_input_value_id,
    l_element_name,
    l_processing_type;
  --
  if c_ele_info%notfound then
    close c_ele_info;
    if g_debug then
      --
      -- entry_value_id attached to prtt rt does not exist. This is possible
      -- prior to FP C when ct. could delete the entries
      --
      hr_utility.set_location('Leaving: '||l_proc,7);
    end if;
    return;
  end if;
  close c_ele_info;
  --
  l_effective_date := p_effective_date;
  --
  if g_debug then
    hr_utility.set_location('ele type='||l_element_type_id,7);
    hr_utility.set_location('inp val='||l_input_value_id,7);
    hr_utility.set_location('l_effective_date='||l_effective_date,7);
  end if;
  --
  -- find the element entry that needs to be deleted.
  --
  open get_element_entry_id(-- p_enrt_rslt_id
                            l_element_type_id
                           ,l_input_value_id
                           ,l_element_entry_value_id
                           ,l_effective_date);
  fetch get_element_entry_id into
    l_assignment_id,
    l_payroll_id,
    l_element_entry_id,
    l_element_entry_start_date,
    l_element_entry_end_date,
    l_object_version_number,
    l_original_entry_id,
    l_entry_type,
    l_element_link_id,
    l_curr_val_char;
  --
  if get_element_entry_id%notfound then
    close get_element_entry_id;
    if g_debug then
      -- element entry already ended.
      hr_utility.set_location('element entry already ended',8);
      hr_utility.set_location('Leaving: '||l_proc,7);
    end if;

     -- 9999 is it needed.
    ben_warnings.load_warning
     (p_application_short_name  => 'BEN',
      p_message_name            => 'BEN_93455_ELE_ALREADY_ENDED',
      p_parma => l_element_name,
      p_parmb => to_char(l_effective_date),
      p_person_id => p_person_id);
      --
    if fnd_global.conc_request_id in ( 0,-1) then
         --
         fnd_message.set_name('BEN','BEN_93455_ELE_ALREADY_ENDED');
         fnd_message.set_token('PARMA',l_element_name);
         fnd_message.set_token('PARMB',to_char(l_effective_date));
         l_string       := fnd_message.get;
         benutils.write(p_text => l_string);
         --
    end if;
    --
    if g_debug then
      --
      -- Could delete the entries
      --
      hr_utility.set_location('Leaving: '||l_proc,8);
      --
    end if;
    --
    return;
    --
  end if;
  --
  -- Check if element is already processed in payroll, then make a
  -- quickpay entries. -- 9999
  --
  -- Add the function 9999
  l_dt_delete_mode := get_ele_dt_del_mode(p_effective_date, l_element_entry_id);
  --
  -- get the min effective_start date also.
  --
  open c_min_max_dt(l_element_entry_id);
  fetch c_min_max_dt into l_min_start_date,l_max_end_date;
  close c_min_max_dt;
  --
  if l_processing_type <> 'R' or p_effective_date < l_min_start_date then
     l_dt_delete_mode := hr_api.g_zap;
  else
     if p_effective_date = l_min_start_date then
        l_dt_delete_mode := hr_api.g_zap;
     else
        l_effective_date := p_effective_date -1;
	-- added for 8548730
	l_dt_delete_mode := get_ele_dt_del_mode(l_effective_date, l_element_entry_id);
	-- added if-block for 8392328
        if l_dt_delete_mode = hr_api.g_future_change then
	    open c_get_ovn(l_element_entry_id,l_effective_date);
	    fetch c_get_ovn into l_object_version_number;
	    close c_get_ovn;
        end if;
     end if;
  end if;
  --

  hr_utility.set_location('l_dt_delete_mode = ' || l_dt_delete_mode, 9);
  hr_utility.set_location('l_element_entry_id = ' || l_element_entry_id, 9);
  hr_utility.set_location('l_processing_type = ' || l_processing_type, 9);
  --
  -- If procesing type id Non Recussring then zap the element entry.
  -- If it is recurring then check whether the min effective_start date
  -- less than the p_effective date, if so then do a future change, otherwise
  -- zap it.
  --
  py_element_entry_api.delete_element_entry
        (p_validate              => p_validate
        ,p_datetrack_delete_mode => l_dt_delete_mode
        ,p_effective_date        => l_effective_date
        ,p_element_entry_id      => l_element_entry_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        ,p_delete_warning        => l_delete_warning);
      --
  if g_debug then
    hr_utility.set_location('Leaving :'||l_proc,5);
  end if;
  --
end backout_cwb_element;

--

procedure delete_custom_integrator(p_group_pl_id    in number
                        ,p_lf_evt_ocrd_dt in date) is

 cursor c_data_exists is
    select custom_integrator
    from   ben_cwb_pl_dsgn i
    where  i.group_pl_id    = p_group_pl_id
    and    i.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and    i.pl_id = i.group_pl_id
    and    i.oipl_id = -1
    and    i.group_oipl_id = -1
    and    i.custom_integrator is not null;

 l_return  number;
 l_proc     varchar2(72) := g_package||'delete_custom_integrator';

begin

   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   for l_data_exists in c_data_exists loop
        l_return := bne_integrator_utils.delete_integrator(800,l_data_exists.custom_integrator);
        if g_debug then
            hr_utility.set_location('Deleted custom integrator :'|| l_data_exists.custom_integrator, 20);
            hr_utility.set_location('l_return :'|| l_return, 21);
        end if;
   end loop;
   if g_debug then
      hr_utility.set_location('Leaving:'|| l_proc, 30);
   end if;

end delete_custom_integrator;

--
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                   << Procedure: Restart >>
-- *****************************************************************
--
procedure restart (errbuf                 out nocopy varchar2
                  ,retcode                out nocopy number
                  ,p_benefit_action_id    in  number) is
  --
  -- Cursor Declaration
  --
  cursor c_parameters is
    Select process_date
          ,mode_cd
          ,validate_flag
          ,business_group_id
          ,person_selection_rl
          ,ler_id
          ,debug_messages_flag
	  ,date_from
          ,ptnl_ler_for_per_stat_cd
          ,pl_id
    From  ben_benefit_actions ben
    Where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_proc        varchar2(80) := g_package||'.restart';
  l_parameters	c_parameters%rowtype;
  l_errbuf      varchar2(80);
  l_retcode     number;
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
    --
    fetch c_parameters into l_parameters;
    If c_parameters%notfound then
      --
      close c_parameters;
      fnd_message.set_name('BEN','BEN_91710_RESTRT_PARMS_NOT_FND');
      fnd_message.raise_error;
      --
    End if;
    --
  close c_parameters;
  --
  -- Call process procedure with parameters for restart
  --
  process(errbuf                     => l_errbuf
         ,retcode                    => l_retcode
         ,p_benefit_action_id        => p_benefit_action_id
         ,p_effective_date           => fnd_date.date_to_canonical
                                        (l_parameters.process_date)
         ,p_validate                 => l_parameters.validate_flag
         ,p_business_group_id        => l_parameters.business_group_id
         ,p_life_event_id            => l_parameters.ler_id
         ,p_ocrd_date	             => fnd_date.date_to_canonical
                                        (l_parameters.date_from)
	 ,p_group_pl_id		     => l_parameters.pl_id
         ,p_person_selection_rule_id => l_parameters.person_selection_rl
         ,p_debug_messages           => l_parameters.debug_messages_flag);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
end restart;
--


-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--  	this procedure is called from 'process'.  It calls the back-out routine.
-- ============================================================================
procedure do_multithread
             (errbuf                  out nocopy    varchar2
             ,retcode                 out nocopy    number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
             ,p_ocrd_date             in     varchar2
             ,p_group_pl_id 	      in     number
             ,p_life_event_id         in     number
             ,p_bckt_stat_cd          in     varchar2
             ) is
  -- Local variable declaration
  --
  l_proc                   varchar2(80) := g_package||'.do_multithread';
  l_person_id              ben_person_actions.person_id%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_object_version_number  ben_person_actions.object_version_number%type;
  l_ler_id                 ben_person_actions.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_record_number          number := 0;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_actn                   varchar2(80);
  l_cnt                    number(5):= 0;
  l_chunk_size             number(15);
  l_threads                number(15);
  l_effective_date         date;
  l_ocrd_date         date;
  l_commit number;
  l_per_rec       per_all_people_f%rowtype;
  l_dummy2 number;
  -- l_per_dummy_rec per_all_people_f%rowtype;

  -- Cursors declaration
  --
  Cursor c_range_thread is
    Select ran.range_id
          ,ran.starting_person_action_id
          ,ran.ending_person_action_id
    From   ben_batch_ranges ran
    Where  ran.range_status_cd = 'U'
    And    ran.BENEFIT_ACTION_ID  = P_BENEFIT_ACTION_ID
    And    rownum < 2
    For    update of ran.range_status_cd;
  --
  cursor c_person_thread is
    select ben.person_id,
           ben.person_action_id
    from   ben_person_actions ben
    where  ben.benefit_action_id = p_benefit_action_id
    and    ben.action_status_cd not in ('P','E')
    and    ben.person_action_id
           between l_start_person_action_id
           and     l_end_person_action_id
    order  by ben.person_action_id;
  --
  cursor c_ler_thread is
    select pil.per_in_ler_id,
           pil.person_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.business_group_id,
           ler.typ_cd,
           ler.ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = l_person_id
    and    pil.lf_evt_ocrd_dt = l_ocrd_date
    and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
    and    pil.group_pl_id = p_group_pl_id -- CWBGLOBAL
    and    ler.ler_id = pil.ler_id
    and    ler.typ_cd = 'COMP'    -- CWBGLOBAL
    and    nvl(l_effective_date,trunc(sysdate))
           between ler.effective_start_date
           and ler.effective_end_date
    order  by pil.person_id desc;
  --
  l_ler_thread c_ler_thread%rowtype;
  --
  Cursor c_parameter is
    Select *
    From   ben_benefit_actions ben
    Where  ben.benefit_action_id = p_benefit_action_id;
  --
  l_parm c_parameter%rowtype;
  --
  --
  cursor c_latest_ler_cwb is
     select pil.per_in_ler_id,
            ler.name
     from   ben_per_in_ler pil,
            ben_ler_f  ler
     where  pil.person_id = l_person_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
     and    pil.ler_id = ler.ler_id
     and    ler.typ_cd = 'COMP'
     and    nvl(l_effective_date,trunc(sysdate))
            between ler.effective_start_date
            and ler.effective_end_date
     order by pil.lf_evt_ocrd_dt desc, pil.per_in_ler_id desc;
  --
  l_latest_ler_cwb c_latest_ler_cwb%rowtype;
  --
  cursor c_person is
    select ppf.*
    from   per_all_people_f ppf
    where  ppf.person_id = l_person_id
    and    nvl(l_effective_date,trunc(sysdate))
           between ppf.effective_start_date
           and     ppf.effective_end_date;
  --
  cursor c_person_last is
    select ppf.*
    from   per_all_people_f ppf
    where  ppf.person_id = l_person_id
    order by effective_start_date desc;
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','dt_fndate.change_ses_date');
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  l_ocrd_date := trunc(fnd_date.canonical_to_date(p_ocrd_date));
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','benutils.get_parameter');
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENBOCON'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  --
  hr_utility.set_location ('l_threads '||l_threads,10);
  hr_utility.set_location ('l_chunk_size '||l_chunk_size,10);
  --
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','ben_env_object.init');
  ben_env_object.init(p_business_group_id => p_business_group_id,
                      p_effective_date    => l_effective_date,
                      p_thread_id         => p_thread_id,
                      p_chunk_size        => l_chunk_size,
                      p_threads           => l_threads,
                      p_max_errors        => g_max_errors_allowed,
                      p_benefit_action_id => p_benefit_action_id);
  --
  -- Copy benefit action id to global in benutils package
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := p_thread_id;
  g_persons_errored            := 0;
  g_persons_processed          := 0;
  --
  open c_parameter;
    --
    fetch c_parameter into l_parm;
    --
  close c_parameter;
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','ben_batch_utils.print_parameters');
  ben_batch_utils.print_parameters
          (p_thread_id                => p_thread_id
          ,p_benefit_action_id        => p_benefit_action_id
          ,p_validate                 => p_validate
          ,p_business_group_id        => p_business_group_id
          ,p_effective_date           => l_effective_date
          ,p_person_selection_rule_id => l_parm.person_selection_rl
          ,p_organization_id          => l_parm.organization_id
          ,p_benfts_grp_id            => l_parm.benfts_grp_id
          ,p_location_id              => l_parm.location_id
          ,p_legal_entity_id          => l_parm.legal_entity_id);


  --
  -- While loop to only try and fetch records while they exist
  -- we always try and fetch the size of the chunk, if we get less
  -- then we know that the process is finished so we end the while loop.
  -- The process is as follows :
  -- 1) Lock the rows that are not processed
  -- 2) Grab as many rows as we can upto the chunk size
  -- 3) Put each row into the person cache.
  -- 4) Process the person cache
  -- 5) Go to number 1 again.
  --
  hr_utility.set_location('getting range',10);
  --
  Loop
    --
    open c_range_thread;
      --
      fetch c_range_thread into l_range_id
                               ,l_start_person_action_id
                               ,l_end_person_action_id;
      hr_utility.set_location('doing range fetch',10);
      --
      if c_range_thread%notfound then
        --
        hr_utility.set_location('range not Found',10);
        --
        close c_range_thread;
        exit;
        --
      end if;
      --
      hr_utility.set_location('range Found',10);
      --
    close c_range_thread;
    --
    update ben_batch_ranges ran
    set    ran.range_status_cd = 'P'
    where  ran.range_id = l_range_id;
    --
    commit;
    --
    -- Get person who are in the range
    --
    open c_person_thread;
      --
      loop
        --
        fetch c_person_thread into l_person_id,
                                   l_person_action_id;
        hr_utility.set_location('person id'||l_person_id,10);
        --
        exit when c_person_thread%notfound;
        --
        savepoint last_place;
        benutils.set_cache_record_position;

        --
        -- CWB - Added to avoid calling ben_person_object.get_object
        --

        open c_person;
        fetch c_person into l_per_rec;
        --
        -- if l_per_rec is null get the data mased on first entry found,
        --  order by based on effective_end_date.
        --
        if c_person%notfound then
           --
           open c_person_last;
           fetch c_person_last into l_per_rec;
           close c_person_last;
           --
        end if;
        close c_person;
        --
        begin
          --
          hr_utility.set_location('Before open',10);
          open c_ler_thread;
            --
            Loop
              --
              fetch c_ler_thread into l_ler_thread;
              exit when c_ler_thread%notfound;
              --
              hr_utility.set_location ('per_in_ler_id '||l_ler_thread.per_in_ler_id,10);
              hr_utility.set_location ('typ_cd '||l_ler_thread.typ_cd,10);
              hr_utility.set_location ('bg id '||l_ler_thread.business_group_id,10);
              --
              --
              fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
              fnd_message.set_token('PROC','ben_back_out_life_event');
              hr_utility.set_location ('calling bolfe ',10);
	      ben_back_out_life_event.g_enrt_made_flag := Null;
              ben_back_out_life_event.back_out_life_events
               (p_per_in_ler_id      => l_ler_thread.per_in_ler_id
               ,p_business_group_id  => l_ler_thread.business_group_id
               ,p_bckt_stat_cd       => p_bckt_stat_cd
               ,p_effective_date     => l_effective_date);
              --
              -- 9999 for some reason above proc errors just make the pil backed out.
              --
              -- CWBGLOBAL -- Call procedure to delete CWB de normalised data
              --
              -- Check if the current pil is the group pil. If so, call
              -- delete_cwb_data.
              --
              hr_utility.set_location ('this ler is '||l_ler_thread.per_in_ler_id||
                                       'group pil is '||p_life_event_id,777);
              --
              -- Bug 3517726 : CWB data is not getting deleted.
                hr_utility.set_location ('calling delete_cwb_data',10);
              fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
              fnd_message.set_token('PROC','delete_cwb_data');
              delete_cwb_data
                  (p_per_in_ler_id	=>	l_ler_thread.per_in_ler_id
                 , p_business_group_id	=> 	l_ler_thread.business_group_id
                 , p_update_summary     =>     false
                  ) ;

		/* bug 3517726
		*/

              delete from ben_cwb_person_rates
		where group_pl_id = p_group_pl_id
		and lf_evt_ocrd_dt = l_ocrd_date
                and group_per_in_ler_id = -1 -- Bug 5060080
		and person_id = l_person_id;
              --
              g_rec.ler_id := l_ler_thread.ler_id;
              g_rec.rep_typ_cd := 'LFBO';
              g_rec.person_id := l_person_id;
              --
              --  This is to assign the global variable which contains information about
              --  the closed or in process life events with or without election,
              --  that were backed out.
              --
	      g_rec.text      := l_ler_thread.per_in_ler_stat_cd ||
                                        ben_back_out_life_event.g_enrt_made_flag;
              --
              -- This is to assign the per_in_ler_id in the record to extract the
	      -- the electable choices later.
              g_rec.temporal_ler_id :=  l_ler_thread.per_in_ler_id;

              benutils.write(p_rec => g_rec);
              --
            End loop;
            --
          close c_ler_thread;
          --
          -- If we get here it was successful.
          --
          update ben_person_actions
              set   action_status_cd = 'P'
              where person_id = l_person_id
              and   benefit_action_id = p_benefit_action_id;
          --
          benutils.write(l_per_rec.full_name||' processed successfully');
          g_persons_processed := g_persons_processed + 1;
          --
        exception
          --
          when others then
            --
            hr_utility.set_location('Super Error exception level',10);
            hr_utility.set_location(sqlerrm,10);

            if c_latest_ler_cwb%isopen then

              close c_latest_ler_cwb;
              --
            end if;

            --
            if c_ler_thread%isopen then

              close c_ler_thread;
              --
            end if;
            --
            rollback to last_place;
            benutils.rollback_cache;
            --
            update ben_person_actions
              set   action_status_cd = 'E'
              where person_id = l_person_id
              and   benefit_action_id = p_benefit_action_id;
            --
            commit;
            --
            g_persons_errored := g_persons_errored + 1;
            g_rec.ler_id := nvl(p_life_event_id,l_ler_thread.ler_id);
            g_rec.rep_typ_cd := 'ERROR_LF';
            -- g_rec.text := fnd_message.get;
            g_rec.person_id := l_person_id;

            g_rec.national_identifier := l_per_rec.national_identifier;
            g_rec.error_message_code := benutils.get_message_name;
            g_rec.text := fnd_message.get;

            hr_utility.set_location('Error Message '||g_rec.text,10);
            benutils.write(l_per_rec.full_name||' processed unsuccessfully');
            benutils.write(g_rec.text);
            benutils.write(p_rec => g_rec);
            --
            hr_utility.set_location('Max Errors = '||g_max_errors_allowed,10);
            hr_utility.set_location('Num Errors = '||g_persons_errored,10);
            if g_persons_errored > g_max_errors_allowed then
              --
              fnd_message.set_name('BEN','BEN_92431_BENBOCON_ERROR_LIMIT');
              benutils.write(p_text => fnd_message.get);
              --
              raise;
              --
            end if;
            --
        end;
        --
        hr_utility.set_location('Closing c_person_thread',10);
        --
      end loop;
      --
    close c_person_thread;
    --
    -- Commit chunk
    --
    if p_validate = 'Y' then
      --
      hr_utility.set_location('Rolling back transaction ',10);
      --
      rollback;
      --
    end if;
    --
    fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
    fnd_message.set_token('PROC','benutils.write_table_and_file');
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    commit;
    --
  end loop;
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','benbatch_utils.write_logfile');
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                               ,p_num_pers_errored   => g_persons_errored);
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
Exception
  --
  When others then
    --
    hr_utility.set_location('Super Error',10);
    hr_utility.set_location(sqlerrm,10);
    hr_utility.set_location('Super Error',10);
    rollback;
    benutils.rollback_cache;
    --
    g_rec.ler_id := nvl(p_life_event_id,l_ler_thread.ler_id);
    g_rec.rep_typ_cd := 'FATAL';
    g_rec.text := fnd_message.get;
    g_rec.person_id := l_person_id;
    --
    benutils.write(p_text => g_rec.text);
    benutils.write(p_rec => g_rec);
    --
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                                 ,p_num_pers_errored   => g_persons_errored);
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    commit;
    --
    fnd_message.raise_error;
    --
End do_multithread;




-- *************************************************************************
-- *                          << Procedure: Process >>
-- *************************************************************************
--  This is called from the concurrent manager


procedure process
	          (errbuf                     out nocopy    varchar2
                 ,retcode                    out nocopy    number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_group_pl_id              in     number
                 ,p_life_event_id            in     number
                 ,p_ocrd_date                in     varchar2
                 ,p_person_selection_rule_id in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_bckt_stat_cd             in     varchar2 default 'UNPROCD'
                ) is

/* local variable defintions */
  l_proc                   varchar2(80) := g_package||'.process';
  l_request_id             number;
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_object_version_number  ben_benefit_actions.object_version_number%type;
  l_person_id              per_people_f.person_id%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_ler_id                 ben_ler_f.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_chunk_size             number := 20;
  l_threads                number := 1;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_prev_person_id         number := 0;
  rl_ret                   char(1);
  skip                     boolean;
  l_person_cnt             number := 0;
  l_cnt                    number := 0;
  l_num_range              number := 0;
  l_chunk_num              number := 1;
  l_num_row                number := 0;
  l_commit 		   number;
  --
  l_effective_date         date;
  l_ocrd_date              date;
  l_no_one_to_process      exception;
  l_business_group_id      number;
  --
  l_person_selection       number;

/* cursor definitions*/


   cursor c_person is
    select distinct  ppf.person_id, ppf.business_group_id
    from   per_all_people_f ppf
    where  -- l_effective_date between ppf.effective_start_date and ppf.effective_end_date and
         exists (select null
                   from   ben_per_in_ler pil
                   	  , ben_ler_f ler
                   where  pil.lf_evt_ocrd_dt = l_ocrd_date
                   and    pil.ler_id = ler.ler_id
                   and    l_effective_date between ler.effective_start_date
                          and ler.effective_end_date
                   /* and    ler.business_group_id = p_business_group_id   */
                   -- Looks like p_life_event_id is not passed in
                   and    ler.typ_cd = 'COMP'
                   and    pil.ler_id = nvl(p_life_event_id, pil.ler_id)
                   /* life event id made non mandatory parameter*/
                   and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                   and    pil.person_id = ppf.person_id
                   and    pil.group_pl_id = p_group_pl_id
                   ) ;
   /*
   cursor c_person is
    select distinct  pil.person_id, pil.business_group_id
    from   ben_per_in_ler pil
                   where  pil.lf_evt_ocrd_dt = l_ocrd_date
                   and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                   and    pil.group_pl_id = p_group_pl_id;

   */
   cursor c_person_selection (cv_formula_id number
			   , cv_business_group_id number
                           , cv_effective_date date
                           ) is
      select fff.formula_id
      from ff_formulas_f fff,
           ff_formulas_f fff1
      where fff.business_group_id = cv_business_group_id
        and cv_effective_date between fff.effective_start_date
                                  and fff.effective_end_date
        and fff.formula_name      = fff1.formula_name
        and cv_effective_date between fff1.effective_start_date
                                  and fff1.effective_end_date
        and fff1.formula_id        = cv_formula_id;

    -- Bug 4758468 : join condition is missing in c_group_pils.

    cursor c_group_pils(cv_group_bg_id in number) is
    Select pil.per_in_ler_id
      from ben_person_actions act,
           ben_per_in_ler pil
     where act.benefit_action_id = l_benefit_action_id
       and act.action_status_cd = 'P'
       and act.person_id = pil.person_id
       and pil.lf_evt_ocrd_dt = l_ocrd_date
       and pil.per_in_ler_stat_cd = 'BCKDT'
       and pil.business_group_id = cv_group_bg_id
       and pil.group_pl_id = p_group_pl_id;
     --
    cursor c_group_pl_bg is
    Select pln.business_group_id
    from ben_pl_f pln
    where pln.pl_id = p_group_pl_id
    and l_ocrd_date between pln.effective_start_date
                        and pln.effective_end_date;
  --
  cursor c_broke_hier (cv_group_pl_id in number,
                       cv_ocrd_date in date) is
  select inf.full_name, inf.person_id
  from  ben_cwb_person_info inf
       ,ben_per_in_ler pil
  where pil.group_pl_id = cv_group_pl_id
  and   pil.lf_evt_ocrd_dt = cv_ocrd_date
  and   pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
  and   pil.ws_mgr_id is not null
  and   pil.per_in_ler_id = inf.group_per_in_ler_id
  and   not exists (select 'Y'
                   from ben_cwb_group_hrchy hrchy
                   where hrchy.emp_per_in_ler_id = pil.per_in_ler_id
                   and    hrchy.lvl_num = 1) ;
  --
  l_group_business_group_id number;
  l_person_ok    varchar2(1) := 'Y';
  l_err_message  varchar2(2000);
  l_head number := 0 ;

begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --

  hr_utility.set_location ('p_business_group_id '||p_business_group_id,10);
  hr_utility.set_location ('p_life_event_id '||p_life_event_id,10);
  hr_utility.set_location ('p_ocrd_date '||p_ocrd_date,10);
  hr_utility.set_location ('p_group_pl_id '||p_group_pl_id,10);
  hr_utility.set_location ('p_person_selection_rule_id '||p_person_selection_rule_id,10);
  --

  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  l_ocrd_date:=trunc(fnd_date.canonical_to_date(p_ocrd_date));

  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  -- Get chunk_size and Thread values for multi-thread process.
  --
  ben_batch_utils.ini;
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENBOCON'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create if a benefit action already exists, in other words
  -- we are doing a restart.
  --
  If p_benefit_action_id is null then
    --
    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => null
      ,p_person_type_id         => null
      ,p_pgm_id                 => null
      ,p_business_group_id      => p_business_group_id
      ,p_pl_typ_id              => null
      ,p_pl_id                  => p_group_pl_id -- CWBGLOBAL
      ,p_popl_enrt_typ_cycl_id  => null
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => null
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => p_life_event_id
      ,p_organization_id        => null
      ,p_benfts_grp_id          => null
      ,p_location_id            => null
      ,p_pstl_zip_rng_id        => null
      ,p_rptg_grp_id            => null
      ,p_opt_id                 => null
      ,p_eligy_prfl_id          => null
      ,p_vrbl_rt_prfl_id        => null
      ,p_legal_entity_id        => null
      ,p_payroll_id             => null
      ,p_debug_messages_flag    => p_debug_messages
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      ,p_date_from              => l_ocrd_date
      ,p_uneai_effective_date   => null);
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    hr_utility.set_location ('l_benefit_action_id created is  '||l_benefit_action_id,30);
    -- Delete/clear ranges from ben_batch_ranges table
    --
    Delete from ben_batch_ranges
    Where  benefit_action_id = l_benefit_action_id;
    --
    -- Now lets create person actions for all the people we are going to
    -- process in the Back-out life event run
    --
    open c_person;
      --
      l_person_cnt := 0;
      l_cnt := 0;
      --
      loop
        --
        l_person_selection := null;
        fetch c_person into l_person_id, l_business_group_id;
        hr_utility.set_location ('next person selected is  '||l_person_id,30);
        exit when c_person%notfound;
        --
        l_cnt := l_cnt + 1;
        --
        l_person_ok := 'Y';
        --
        If p_person_selection_rule_id is not NULL then
        --
           open c_person_selection (p_person_selection_rule_id,
                                    l_business_group_id, l_ocrd_date);
           fetch c_person_selection into l_person_selection;
           close c_person_selection;
           --
           if l_person_selection is not null then
             --
             ben_batch_utils.person_selection_rule
                      (p_person_id               => l_person_id
                      ,p_business_group_id       => l_business_group_id
                      ,p_person_selection_rule_id=> l_person_selection
                      ,p_effective_date          => l_effective_date
                      ,p_return                  => l_person_ok
                      ,p_err_message             => l_err_message );
             --
             if l_err_message  is not null
             then
              --
              -- 9999 if the error message corresponds to
              -- BEN_91698_NO_ASSIGNMENT_FND then try running the formula again
              -- with different effective date.
              -- get the effective date from person record and use it.
              -- select effective_start_date, effective_end_date
              -- from per_all_people_f where person_id = l_person_id
              -- order by effective_start_date desc;
              --
	      Ben_batch_utils.write(p_text =>
        		'<< Person id : '||to_char(l_person_id)||' failed.'||
			'   Reason : '|| l_err_message ||' >>' );
              l_err_message := NULL ;
              --
	     end if ;
             --
           end if;

        End if;
        --
        -- Store person_id into person actions table.
        --
        If l_person_ok = 'Y' then
          --
          hr_utility.set_location ('person passed selection rule  '||l_person_id,35);
          Ben_person_actions_api.create_person_actions
            (p_validate              => false
            ,p_person_action_id      => l_person_action_id
            ,p_person_id             => l_person_id
            ,p_ler_id                => l_ler_id
            ,p_benefit_action_id     => l_benefit_action_id
            ,p_action_status_cd      => 'U'
            ,p_chunk_number          => l_chunk_num
            ,p_object_version_number => l_object_version_number
            ,p_effective_date        => l_effective_date);
          --
          hr_utility.set_location ('person action created is  '||l_person_action_id,40);
          --
          l_num_row := l_num_row + 1;
          l_person_cnt := l_person_cnt + 1;
          l_end_person_action_id := l_person_action_id;
          --
          If l_num_row = 1 then
            --
            l_start_person_action_id := l_person_action_id;
            --
          End if;
          ----
          If l_num_row = l_chunk_size then
            --
            -- Create a range of data to be multithreaded.
            --
            Ben_batch_ranges_api.create_batch_ranges
              (p_validate                  => false
              ,p_benefit_action_id         => l_benefit_action_id
              ,p_range_id                  => l_range_id
              ,p_range_status_cd           => 'U'
              ,p_starting_person_action_id => l_start_person_action_id
              ,p_ending_person_action_id   => l_end_person_action_id
              ,p_object_version_number     => l_object_version_number
              ,p_effective_date            => l_effective_date);
            --
            hr_utility.set_location ('person action range created is  '||l_range_id,45);
            --
            l_start_person_action_id := 0;
            l_end_person_action_id := 0;
            l_num_row  := 0;
            l_num_range := l_num_range + 1;
            --
          End if;
          --
        End if;
        --
      End loop;
      --
    close c_person;
    --
    --
    hr_utility.set_location('l_num_row='||to_char(l_num_row),48);
    --
    If l_num_row <> 0 then
      --
      Ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => false
        ,p_benefit_action_id         => l_benefit_action_id
        ,p_range_id                  => l_range_id
        ,p_range_status_cd           => 'U'
        ,p_starting_person_action_id => l_start_person_action_id
        ,p_ending_person_action_id   => l_end_person_action_id
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date);
      --
      l_num_range := l_num_range + 1;
      --
      hr_utility.set_location('l_num_row='||to_char(l_num_row),50);
      hr_utility.set_location ('person action range created is  '||l_range_id,55);
      --
    End if;
    --
  Else
    --
    l_benefit_action_id := p_benefit_action_id;
    --
    Ben_batch_utils.create_restart_person_actions
     (p_benefit_action_id  => p_benefit_action_id
     ,p_effective_date     => l_effective_date
     ,p_chunk_size         => l_chunk_size
     ,p_threads            => l_threads
     ,p_num_ranges         => l_num_range
     ,p_num_persons        => l_person_cnt);
    --
  End if;
  --
  If l_num_range > 1 then
    --
    For l_count in 1..least(l_threads,l_num_range)-1 loop
      --
      hr_utility.set_location('spawning thread  #'||l_count,60);
      --
      l_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BENCWBBT'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => p_validate
                       ,argument2   => l_benefit_action_id
                       ,argument3   => l_count
                       ,argument4   => p_effective_date
                       ,argument5   => p_business_group_id
                       ,argument6   => p_ocrd_date
                       ,argument7   => p_group_pl_id
                       ,argument8   => p_life_event_id
                       ,argument9   => p_bckt_stat_cd
                       );
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
      --
    End loop;
    --
    commit;
    --
  Elsif (l_num_range = 0 ) then
    --
    Ben_batch_utils.print_parameters
     (p_thread_id                => 99
     ,p_benefit_action_id        => l_benefit_action_id
     ,p_validate                 => p_validate
     ,p_business_group_id        => p_business_group_id
     ,p_effective_date           => l_effective_date
     ,p_person_selection_rule_id => p_person_selection_rule_id
     ,p_ler_id                   => p_life_event_id
     ,p_organization_id          => null
     ,p_benfts_grp_id            => null
     ,p_location_id              => null
     ,p_legal_entity_id          => null);
    --
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC' , l_proc);
    raise l_no_one_to_process;
    --
  End if;
  --
  do_multithread(errbuf               => errbuf
                ,retcode              => retcode
                ,p_validate           => p_validate
                ,p_benefit_action_id  => l_benefit_action_id
                ,p_thread_id          => l_threads+1
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                ,p_ocrd_date          => p_ocrd_date
                ,p_group_pl_id        => p_group_pl_id
                --,p_to_ocrd_date       => p_ocrd_date
                ,p_life_event_id      => p_life_event_id
                ,p_bckt_stat_cd       => p_bckt_stat_cd
                );
  --
  hr_utility.set_location('waiting for slaves',65);
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  hr_utility.set_location('hurray my slaves are done',70);
  --
  -- Once all slaves are done go and delete heirarchy data.
  --
  if p_validate = 'N' then
      --
     open c_group_pl_bg;
     fetch c_group_pl_bg into l_group_business_group_id;
     close c_group_pl_bg;
     --
     for l_group_pil_rec in c_group_pils(l_group_business_group_id) loop
        backout_heirarchy_data
             (p_per_in_ler_id  => l_group_pil_rec.per_in_ler_id);
     end loop;
     --
     hr_utility.set_location('Deleting custom integrator ',5);
     delete_custom_integrator
                        (p_group_pl_id    => p_group_pl_id
                        ,p_lf_evt_ocrd_dt => l_ocrd_date);

     hr_utility.set_location('Deleting data from ben_cwb_pl_dsgn ',10);
     BEN_CWB_PL_DSGN_PKG.delete_pl_dsgn
                          (p_group_pl_id        => p_group_pl_id
                          ,p_lf_evt_ocrd_dt     => l_ocrd_date);
     --
     hr_utility.set_location('Refreshing Summary ',20);
     ben_cwb_summary_pkg.refresh_summary_group_pl
                          (p_group_pl_id        => p_group_pl_id
                          ,p_lf_evt_ocrd_dt     => l_ocrd_date);
     --
     commit;
     --
     hr_utility.set_location('Refreshing Summary Complete',30);

  end if;
  --
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id);
  --
  -- Report any broken hierarchies, people who do not have a level 1 manager
  -- but have a worksheet manager id
  --
  l_head := 0;
  --
  for i in c_broke_hier (p_group_pl_id,l_ocrd_date )
  loop
     if l_head = 0
     then
      fnd_file.put_line(which => fnd_file.log,
               buff  => 'Note: List of persons who do not have a level 1 manager but have a worksheet manager id.');
      fnd_file.put_line(which => fnd_file.log,
               buff  => '      Please re-assign these employees to a new manager.');
      fnd_file.put_line(which => fnd_file.log,
               buff  => '----------------------------------------------------------------------------------------');
      l_head := 1 ;
     end if;
     fnd_file.put_line(which => fnd_file.log,
                       buff  => i.full_name ||' ('||'person_id = ' || i.person_id||')'  );
  end loop;
  --
  hr_utility.set_location('Submitting reports',72);
  --
  -- submit summary report here
  --
  l_request_id := fnd_request.submit_request
                  (application    => 'BEN',
                   program        => 'BENBOSUM',
                   description    => null,
                   sub_request    => false,
                   argument1      => fnd_global.conc_request_id);
  --
  --  submit Error reports here
  --
  l_request_id := fnd_request.submit_request
                  (application    => 'BEN',
                   program        => 'BENERTYP',
                   description    => null,
                   sub_request    => false,
                   argument1      => fnd_global.conc_request_id);
  --
  l_request_id := fnd_request.submit_request
                  (application    => 'BEN',
                   program        => 'BENERPER',
                   description    => null,
                   sub_request    => false,
                   argument1      => fnd_global.conc_request_id);
  --
  hr_utility.set_location ('Leaving '||l_proc,75);
  --
  -- hr_utility.trace_off;
Exception

  when l_no_one_to_process then
    if c_person%isopen then
         close c_person;
    end if;
    benutils.write(p_text => fnd_message.get);
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);

  when others then
     --
     if c_person%isopen then
         close c_person;
     end if;
     hr_utility.set_location('Super Error',10);
     rollback;
     benutils.write(p_text => fnd_message.get);
     benutils.write(p_text => sqlerrm);
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     If (l_num_range > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_person_cnt
                                  ,p_business_group_id => p_business_group_id
       ) ;
     End if;
     fnd_message.raise_error;
End process;
--
-- *************************************************************************
-- *                          << Procedure: cwb_delete_routine >>
-- *************************************************************************
--  Procedure to delete data from the table passed as parameter ' p_routine'

procedure cwb_delete_routine
			(p_routine                in varchar2
                         ,p_per_in_ler_id          in number
                         ,p_update_summary         in boolean
                         ) is
  -- CWBGLOBAL
  cursor c_cwb_person_task is
    select task_id, object_version_number
    from ben_cwb_person_tasks
    where group_per_in_ler_id = p_per_in_ler_id;
  --
  cursor c_cwb_person_group is
    select group_pl_id, group_oipl_id, object_version_number
    from ben_cwb_person_groups
    where group_per_in_ler_id = p_per_in_ler_id;
  --
  cursor c_cwb_person_rates is
    select distinct pl_id, oipl_id, pay_proposal_id
    from ben_cwb_person_rates
    where group_per_in_ler_id = p_per_in_ler_id
    order by pay_proposal_id;
  --
  l_pl_id                       number;
  l_oipl_id                     number;
  --
  cursor c_chk_rts_exists is
     select ELEMENT_ENTRY_VALUE_ID,
            COMP_POSTING_DATE,
            person_id,
            object_version_number
     from ben_cwb_person_rates
     where group_per_in_ler_id = p_per_in_ler_id
     and   pl_id = l_pl_id
     and   oipl_id = l_oipl_id ;
  --
  l_pay_proposal_id           number;
  l_pay_proposal_id_prev      number := -1;
  --
  cursor c_pay_proposals is
    select object_version_number, business_group_id
    from per_pay_proposals
    where pay_proposal_id = l_pay_proposal_id;
  --
  --***************audit changes***************--
  --
  cursor c_cwb_person_info is
    select object_version_number
    from ben_cwb_person_info
    where group_per_in_ler_id = p_per_in_ler_id;

  --
  l_proc			varchar2(50) := g_package||'.cwb_delete_routine';
  l_task_id			number;
  l_group_pl_id			number;
  l_person_rate_id		number;
  l_group_oipl_id		number;
  l_object_version_number	number;
  l_dum				number;
  l_salary_warning		boolean;

  l_object_version_number_prop	number;
  l_business_group_id_prop	number;
  l_dummy			number;
  l_dummy1			number;
  l_dummy2			number;
  l_ELEMENT_ENTRY_VALUE_ID      number;
  l_COMP_POSTING_DATE           date;
  l_person_id                   number;
  --
begin

  hr_utility.set_location( 'Entering '|| l_proc, 5);
  --
  -- CWBGLOBAL
  --
  if p_routine = 'BEN_CWB_PERSON_TASKS' then
    --
    open c_cwb_person_task;
    loop
      fetch c_cwb_person_task into l_task_id, l_object_version_number;
      exit when c_cwb_person_task%NOTFOUND ;

      ben_cwb_person_tasks_api.delete_person_task
    	( p_validate			=> false,
    	  p_group_per_in_ler_id 	=> p_per_in_ler_id,
    	  p_task_id			=> l_task_id,
    	  p_object_version_number	=> l_object_version_number
    	  );

    end loop;
    --
    close c_cwb_person_task;
    --
  elsif p_routine = 'BEN_CWB_PERSON_GROUPS' then
    --
    open c_cwb_person_group;
    loop
      fetch c_cwb_person_group into  l_group_pl_id,
                                   l_group_oipl_id, l_object_version_number;
      exit when c_cwb_person_group%NOTFOUND ;

      BEN_CWB_PERSON_GROUPS_API.delete_group_budget
    	( p_validate			=> false,
  	  p_group_per_in_ler_id 	=> p_per_in_ler_id,
  	  p_group_pl_id			=> l_group_pl_id,
  	  p_group_oipl_id		=> l_group_oipl_id,
  	  p_object_version_number	=> l_object_version_number,
          p_update_summary              => p_update_summary
  	  );

    end loop;
    close c_cwb_person_group;
    --
  elsif p_routine = 'BEN_CWB_PERSON_RATES' then
    --
    l_pay_proposal_id_prev := -1;
    --
    open c_cwb_person_rates;
    loop

      l_ELEMENT_ENTRY_VALUE_ID := null;
      l_COMP_POSTING_DATE      := null;
      l_object_version_number  := null;
      --
      fetch c_cwb_person_rates into   l_pl_id, l_oipl_id,
                                      l_pay_proposal_id;
      exit when c_cwb_person_rates%NOTFOUND ;

      open  c_chk_rts_exists;
      fetch c_chk_rts_exists into l_ELEMENT_ENTRY_VALUE_ID,
                                  l_COMP_POSTING_DATE ,
                                  l_person_id,
                                  l_object_version_number;
      close c_chk_rts_exists;

      if l_pay_proposal_id is not null then
         --
         open c_pay_proposals;
         fetch c_pay_proposals
         into l_object_version_number_prop, l_business_group_id_prop;
         close c_pay_proposals;
         --
      end if;
      --
      -- Delete element entry if attached to rate row.
      --
      hr_utility.set_location('l_ELEMENT_ENTRY_VALUE_ID = '
                               || l_ELEMENT_ENTRY_VALUE_ID, 88);
      hr_utility.set_location('l_business_group_id_prop = '
                               || l_business_group_id_prop, 88);
      hr_utility.set_location('l_person_id = ' || l_person_id, 88);
      hr_utility.set_location('l_COMP_POSTING_DATE = '
                               || l_COMP_POSTING_DATE, 88);
      if l_ELEMENT_ENTRY_VALUE_ID is not null and
         l_COMP_POSTING_DATE is not null then

         backout_cwb_element(
          p_element_entry_value_id => l_ELEMENT_ENTRY_VALUE_ID
         ,p_validate               => false
         ,p_business_group_id      => l_business_group_id_prop
         ,p_person_id              => l_person_id
         ,p_effective_date         => l_COMP_POSTING_DATE
         );

      end if;
      --
      if l_object_version_number is not null then
        ben_cwb_person_rates_api.delete_person_rate
        (p_validate    		=>	false
        ,p_group_per_in_ler_id      =>      p_per_in_ler_id
        ,p_pl_id                    =>	l_pl_id
        ,p_oipl_id                  =>      l_oipl_id
        ,p_object_version_number    =>	l_object_version_number
        ,p_update_summary           => p_update_summary) ;
      end if;
      --
      -- Bug 5130397 : When CWB plan has options attached, then all corresponding rows in BEN_CWB_PERSON_RATES
      --               has pay_proposal_id populated and this being same ID, we should not call delete API
      --               more than once. Hence added following check : l_pay_proposal_id <> l_pay_proposal_id_prev
      --
      if l_pay_proposal_id is not null AND
         l_pay_proposal_id <> l_pay_proposal_id_prev
      then
        --
        hr_maintain_proposal_api.delete_salary_proposal
          ( p_pay_proposal_id  => l_pay_proposal_id
           ,p_business_group_id => l_business_group_id_prop
           ,p_object_version_number => l_object_version_number_prop
           ,p_validate              => false
           ,p_salary_warning       => l_salary_warning  ) ;
        --
        l_pay_proposal_id_prev := l_pay_proposal_id;
        --
      end if;
      --
    end loop;
    close c_cwb_person_rates;

  elsif p_routine = 'BEN_CWB_PERSON_INFO' then

    hr_utility.set_location( 'in audit changes BEN_CWB_PERSON_INFO'
                              || l_proc, 500);

    open c_cwb_person_info;
    loop
    fetch c_cwb_person_info into l_object_version_number;
    exit when c_cwb_person_info%NOTFOUND ;

      BEN_CWB_PERSON_INFO_API.delete_person_info
    	( p_validate			=> false,
  	  p_group_per_in_ler_id 	=> p_per_in_ler_id,
  	  p_object_version_number	=> l_object_version_number
  	  );

    end loop;
    close c_cwb_person_info;
    hr_utility.set_location( 'LEAVING audit changes BEN_CWB_PERSON_INFO'
                              || l_proc, 600);

  end if;
  hr_utility.set_location( 'Leaving '||l_proc, 50);

exception
   --
   when others then
      --
      hr_utility.set_location('Super Error exception level',10);
      hr_utility.set_location(sqlerrm,10);
      --
      if c_cwb_person_info%isopen then
         close c_cwb_person_info;
      end if;
      if c_cwb_person_rates%isopen then
         close c_cwb_person_rates;
      end if;
      if c_cwb_person_group%isopen then
         close c_cwb_person_group;
      end if;
      if c_cwb_person_group%isopen then
         close c_cwb_person_group;
      end if;
      if c_cwb_person_task%isopen then
         close c_cwb_person_task;
      end if;
      raise;
      --
end cwb_delete_routine;


-- *************************************************************************
-- *                          << Procedure: delete_cwb_data >>
-- *************************************************************************
--  Procedure to delete data from CWB de normalised tables

procedure delete_cwb_data
		 (p_per_in_ler_id     		in number
                  ,p_business_group_id 		in number
                  ,p_update_summary             in boolean default false
                  ) is

  l_proc                  varchar2(50) := g_package||'.delete_cwb_data';
  p_object_version_number ben_cwb_person_info.object_version_number%type;
begin

  hr_utility.set_location( 'Entering '||l_proc, 5);

  --1. BEN_CWB_PERSON_TASKS
  hr_utility.set_location( 'Calling delete for  BEN_CWB_PERSON_TASKS', 10);
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','delete_person_tasks');
  cwb_delete_routine
  	   (p_routine           	=> 'BEN_CWB_PERSON_TASKS'
            ,p_per_in_ler_id     	=> p_per_in_ler_id
            ,p_update_summary           => p_update_summary
            );

  --2. BEN_CWB_PERSON_RATES
  hr_utility.set_location( 'Calling delete for  BEN_CWB_PERSON_RATES', 15);
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','delete_person_rates');
  cwb_delete_routine
  	   (p_routine           	=> 'BEN_CWB_PERSON_RATES'
            ,p_per_in_ler_id     	=> p_per_in_ler_id
            ,p_update_summary           => p_update_summary
            );

   --3. BEN_CWB_PERSON_GROUPS
   hr_utility.set_location( 'BEN_CWB_PERSON_GROUPS', 20);
   fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
   fnd_message.set_token('PROC','delete_person_groups');
  cwb_delete_routine
           (p_routine                   => 'BEN_CWB_PERSON_GROUPS'
            ,p_per_in_ler_id            => p_per_in_ler_id
            ,p_update_summary           => p_update_summary
            );

  --4. BEN_CWB_PERSON_INFO
  hr_utility.set_location( 'Calling delete for  BEN_CWB_PERSON_INFO', 25);
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','delete_person_info');
  cwb_delete_routine
  	   (p_routine           	=> 'BEN_CWB_PERSON_INFO'
            ,p_per_in_ler_id     	=> p_per_in_ler_id
            ,p_update_summary           => p_update_summary
            );
  --************************************************************ --

  hr_utility.set_location( 'Leaving '||l_proc, 50);
  --
end delete_cwb_data;
--
procedure delete_summary(p_group_per_in_ler_id in number) is
  --
  cursor csr_summary is
     select rowid, s.*
     from  ben_cwb_summary s
     where s.group_per_in_ler_id = p_group_per_in_ler_id;
  --
  cursor csr_mgr_pil_ids is
   select mgr_per_in_ler_id
   from ben_cwb_group_hrchy
   where emp_per_in_ler_id = p_group_per_in_ler_id
   and lvl_num  > 0;
  --
begin
  --
  ben_cwb_summary_pkg.save_pl_sql_tab;
  for summs in csr_summary loop
    for mgr in csr_mgr_pil_ids loop
      ben_cwb_summary_pkg.update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id     => mgr.mgr_per_in_ler_id
            ,p_group_pl_id             => summs.group_pl_id
            ,p_group_oipl_id           => summs.group_oipl_id
            ,p_elig_count_all          => -summs.elig_count_all
            ,p_emp_recv_count_all      => -summs.emp_recv_count_all
            ,p_elig_sal_val_all        => -summs.elig_sal_val_all
            ,p_ws_bdgt_val_all         => -summs.ws_bdgt_val_all
            ,p_ws_bdgt_iss_val_all     => -summs.ws_bdgt_iss_val_all
            ,p_ws_val_all              => -summs.ws_val_all
            ,p_stat_sal_val_all        => -summs.stat_sal_val_all
            ,p_oth_comp_val_all        => -summs.oth_comp_val_all
            ,p_tot_comp_val_all        => -summs.tot_comp_val_all
            ,p_rec_val_all             => -summs.rec_val_all
            ,p_rec_mn_val_all          => -summs.rec_mn_val_all
            ,p_rec_mx_val_all          => -summs.rec_mx_val_all
            ,p_misc1_val_all           => -summs.misc1_val_all
            ,p_misc2_val_all           => -summs.misc2_val_all
            ,p_misc3_val_all           => -summs.misc3_val_all);
    end loop;
    delete ben_cwb_summary
    where  rowid = summs.rowid;
  end loop;

  ben_cwb_summary_pkg.save_pl_sql_tab;

end delete_summary;
--
procedure p_backout_global_cwb_event
                (p_effective_date           in     date
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_group_pl_id              in     number
                 ,p_life_event_id            in     number default null
                 ,p_lf_evt_ocrd_dt           in     date
                 ,p_person_id                in     number   default null
                 ,p_bckt_stat_cd             in     varchar2 default 'UNPROCD'
                ) is
  --
  cursor c_pil(cv_person_id number,
               cv_lf_evt_ocrd_dt date,
               cv_group_pl_id    number,
               cv_effective_date date) is
    select pil.per_in_ler_id,
           pil.person_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.business_group_id,
           ler.typ_cd,
           ler.ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = cv_person_id
    and    pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
    and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
    and    pil.group_pl_id = cv_group_pl_id
    and    ler.ler_id = pil.ler_id
    and    ler.typ_cd = 'COMP'
    and    nvl(cv_effective_date,trunc(sysdate))
           between ler.effective_start_date
           and ler.effective_end_date;
  --
  l_pil_rec c_pil%rowtype;
  l_proc    varchar2(50) := g_package||'.p_backout_global_cwb_event';
  --
begin
  --
  hr_utility.set_location( 'Entering '||l_proc, 10);
  open c_pil(p_person_id,
               p_lf_evt_ocrd_dt,
               p_group_pl_id,
               p_lf_evt_ocrd_dt);
    --
    Loop
       --
       fetch c_pil into l_pil_rec;
       exit when c_pil%notfound;
       --
       hr_utility.set_location ('per_in_ler_id '||l_pil_rec.per_in_ler_id,10);
       hr_utility.set_location ('typ_cd '||l_pil_rec.typ_cd,10);
       hr_utility.set_location ('bg id '||l_pil_rec.business_group_id,10);
       --
       fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
       fnd_message.set_token('PROC','ben_back_out_life_event');
       hr_utility.set_location ('calling bolfe ',10);
       --
       ben_back_out_life_event.g_enrt_made_flag := Null;
       --
       ben_back_out_life_event.back_out_life_events
           (p_per_in_ler_id      => l_pil_rec.per_in_ler_id
           ,p_business_group_id  => l_pil_rec.business_group_id
           ,p_bckt_stat_cd       => p_bckt_stat_cd
           ,p_effective_date     => l_pil_rec.lf_evt_ocrd_dt);
       --
       delete_cwb_data
           (p_per_in_ler_id      => l_pil_rec.per_in_ler_id
           ,p_business_group_id  => l_pil_rec.business_group_id
           ,p_update_summary     => true);
       --
       delete_summary(p_group_per_in_ler_id  => l_pil_rec.per_in_ler_id);
       --
       backout_heirarchy_data
           (p_per_in_ler_id     => l_pil_rec.per_in_ler_id);
       --
       delete from ben_cwb_person_rates
       where group_pl_id = p_group_pl_id
         and lf_evt_ocrd_dt = l_pil_rec.lf_evt_ocrd_dt
         and group_per_in_ler_id = -1  -- Bug 5060080
         and person_id = p_person_id;
       --
   End loop;
   --
   close c_pil;
   --
   hr_utility.set_location('Leaving '||l_proc, 50);
exception
   --
   when others then
      --
      hr_utility.set_location('Super Error exception level',10);
      hr_utility.set_location(sqlerrm,10);
      --
      if c_pil%isopen then
         --
         close c_pil;
         --
      end if;
      --
      raise;
      --
end p_backout_global_cwb_event;
--
end ben_cwb_back_out_conc;
--

/
