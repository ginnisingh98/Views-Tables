--------------------------------------------------------
--  DDL for Package Body HR_PSF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PSF_BUS" as
/* $Header: hrpsfrhi.pkb 120.6.12010000.6 2009/11/26 10:02:00 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_psf_bus.';  -- Global package name
--
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  set_security_group_id  >------------------------|
--  ---------------------------------------------------------------------------
--
--
  procedure set_security_group_id
   (
    p_position_id                in hr_positions.position_id%TYPE
   ) is
  --
  -- Declare cursor
  --
     cursor csr_sec_grp is
       select inf.org_information14
      from hr_organization_information inf
         , hr_all_positions_f  pos
     where pos.position_id = p_position_id
       and inf.organization_id = pos.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';
  --
  -- Local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72) ;
  --
  begin
g_debug := hr_utility.debug_enabled;
if g_debug then
    l_proc        := g_package||'set_security_group_id';
    hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'position_id',
                             p_argument_value => p_position_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  if csr_sec_grp%notfound then
    close csr_sec_grp;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end if;
  --
end set_security_group_id;
--
--
--  ----------------------------------------------------------------------------
--  |--------------------------<  get_validation_date  >--------------------|
--  ----------------------------------------------------------------------------
--
--  Desciption :
--
--  Validates that the position NAME is unique within position's BUSINESS GROUP
--
--  Pre-conditions :
--
--  In Arguments :
--    p_date_effective
--    p_validation_Start_Date
--    p_validation_date
--
--  Post Success :
--
--  Post Failure :
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
Procedure get_validation_date(
      p_date_effective        in  date
     ,p_validation_start_date in  date
     ,p_validation_date       out nocopy date
) is
l_proc varchar2(30);

Begin
if g_debug then
l_proc :='get_validation_date';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  --   Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'date_effective'
    ,p_argument_value           => p_date_effective
    );
  --
if g_debug then
  hr_utility.set_location(l_proc, 10);
end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'validation_start_date'
    ,p_argument_value           => p_validation_start_date
    );
  --
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  -- If this is the first row then date_effective must be used for validation
  -- as this is the date a position becomes effective
  -- for changes in any other row, use validation_start_Date.
  --
  if p_date_effective < p_validation_start_date then
if g_debug then
    hr_utility.set_location(l_proc, 30);
end if;
    p_validation_Date := p_validation_start_Date;
  else
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    p_validation_date := p_date_effective;
  end if;
  --
if g_debug then
  hr_utility.set_location(l_proc, 100);
end if;
--
End get_validation_date;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_end dates >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the various end dates compared to the effective date
--
--  Pre-conditions :
--
--  In Arguments :
--
--  Post Success :
--
--  Post Failure :
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
procedure chk_end_dates
(
position_id                     in number
,availability_status_id         in number
,p_effective_date               in date
,current_org_prop_end_date      in date
,current_job_prop_end_date      in date
,avail_status_prop_end_date     in date
,earliest_hire_date             in date
,fill_by_date                   in date
,proposed_date_for_layoff       in date
,date_effective                 in date)
is
   l_avail_status_start_date  date;
begin
   if current_org_prop_end_date < date_effective then
      hr_utility.set_message(800,'PER_INVALID_ORG_PROP_END_DATE');
      hr_utility.raise_error;
   end if;
   if current_job_prop_end_date < date_effective then
      hr_utility.set_message(800,'PER_INVALID_JOB_PROP_END_DATE');
      hr_utility.raise_error;
   end if;

   l_avail_status_start_date := hr_general.DECODE_AVAIL_STATUS_START_DATE (
                                            position_id
                                            ,availability_status_id
                                            ,p_effective_date ) ;
   if avail_status_prop_end_date < nvl(l_avail_status_start_date,date_effective) then
      hr_utility.set_message(800,'PER_INVALID_STATUS_PROP_END_DT');
      hr_utility.raise_error;
   end if;

   if earliest_hire_date < date_effective then
      hr_utility.set_message(800,'PER_INVALID_EARLIEST_HIRE_DATE');
      hr_utility.raise_error;
   end if;
   if fill_by_date < nvl(earliest_hire_date, date_effective) then
      hr_utility.set_message(800,'PER_INVALID_FILL_BY_DATE');
      hr_utility.set_message_token('VALID_DATE',nvl(earliest_hire_date, date_effective));
      hr_utility.raise_error;
   end if;
   if proposed_date_for_layoff < date_effective then
      hr_utility.set_message(800,'PER_INVALID_PROP_DT_FOR_LAYOFF');
      hr_utility.raise_error;
   end if;
end chk_end_dates;
--  ---------------------------------------------------------------------------
--  |--------------------------<  chg_date_effective >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--  Validates that the date effective is to be changed or not
--
--  Pre-conditions :
--
--  In Arguments :
--
--  Post Success :
--
--  Post Failure :
--
--  Access Status :
--    Internal Table Handler Use and independent procedure of the package
--
-- {End of Comments}
--
-- -------------------------------------------------------------------------
--
procedure chg_date_effective
     (p_position_id             in number
     ,p_effective_start_date    in date
     ,p_effective_end_date      in date
     ,p_date_effective          in date
     ,p_new_date_effective      out nocopy date
     ,p_chg_date_effective      out nocopy boolean
     ,p_business_group_id       in number
     ,p_old_avail_status_id     in number
     ,p_availability_status_id  in number
     ,p_datetrack_mode          in varchar2
      )
is
-- cursor to check active rows for the position prior to the effective_start_date of their row
    cursor pos_active_rows(p_position_id number,p_effective_start_date date) is
       select count(*)
       from hr_all_positions_f pos, per_shared_types sht
       where pos.position_id = p_position_id
       and pos.effective_start_date < p_effective_start_date
       and hr_psf_shd.get_availability_status(pos.availability_status_id,p_business_group_id) ='ACTIVE';
-- cursor to find out the next active row's effective start date
    cursor next_active_row(p_position_id number,p_effective_start_date date) is
       select effective_start_date
       from hr_all_positions_f pos, per_shared_types sht
       where pos.position_id = p_position_id
       and pos.effective_start_date > p_effective_start_date
       and hr_psf_shd.get_availability_status(pos.availability_status_id,p_business_group_id) ='ACTIVE';
-- cursor to find the first active row
    cursor valid_first_active_row(p_position_id number,p_effective_end_date date) is
       select min(effective_start_date)
       from hr_all_positions_f pos
       where effective_start_date > p_effective_end_date + 1
       and hr_psf_shd.get_availability_status(pos.availability_status_id,p_business_group_id) ='ACTIVE';
    l_active_rows      number;
    l_current_row_stat varchar2(30);
    l_next_active_date date;
    l_proc             varchar2(72) ;
    l_effective_date   date;
    l_date_effective   date;
begin

g_debug := hr_utility.debug_enabled;
if g_debug then
    l_proc              := g_package||'Chg_date_effective' ;
   hr_utility.set_location('Entering'||l_proc, 10);
end if;
   p_chg_date_effective := FALSE ;
-- call to chk_availability_status_id is made to check wether the status transition is a valid transition or not.
-- if it is a valid transition only then control will be coming to the change in date_effective code
-- otherwise invalid status change will be displayed
   chk_availability_status_id(p_position_id            => p_position_id
                             ,p_business_group_id      => p_business_group_id
                             ,p_datetrack_mode         => p_datetrack_mode
                             ,p_validation_start_date  => p_effective_start_date
                             ,p_availability_status_id => p_availability_status_id
                             ,p_effective_date         => l_effective_date
                             ,p_date_effective         => l_date_effective
                             ,p_old_avail_status_id    => p_old_avail_status_id
                            );
   if g_debug then
   hr_utility.set_location('after chk_avail_stat '||l_proc, 20);
   end if;
-- depending upon the datetrack mode action has to be taken to find out
-- the change in date effective
    if p_datetrack_mode = 'INSERT'
       or p_datetrack_mode = 'CORRECTION'
       or p_datetrack_mode = 'UPDATE'
       or p_datetrack_mode = 'UPDATE_OVERRIDE'
       or p_datetrack_mode = 'UPDATE_CHANGE_INSERT'
       then
--
-- if current row's status is active and there are no active rows
-- prior to this row then date effective is to
-- be changed to the effective start date of this row.
-- no. of active rows in the database for this position prior to
-- the effective start date is computed
--
if g_debug then
       hr_utility.set_location('inside for action '||p_datetrack_mode||l_proc, 30);
end if;
       open pos_active_rows(p_position_id,p_effective_start_date);
       fetch pos_active_rows into l_active_rows ;
       close pos_active_rows ;
       if l_active_rows = 0 then
          -- status of the current row is found
          l_current_row_stat := hr_psf_shd.get_availability_status(p_availability_status_id,p_business_group_id);
          if l_current_row_stat ='ACTIVE' then
             -- current row is going to be first active row date effective is to be changed
             -- to the effective start date of the first active row
             p_new_date_effective := p_effective_start_date ;
             p_chg_date_effective := (p_new_date_effective <> p_date_effective);
          else
             -- check to find out the effective start date of the first row after current row
             -- next active row's effective start date is fetched
             if g_debug then
             hr_utility.set_location('next row is to be found'||l_proc, 40);
             end if;
             open next_active_row(p_position_id,p_effective_start_date);
             fetch next_active_row into l_next_active_date;
             if next_active_row%found then
                -- there is a active row for this position after the current position
                p_new_date_effective := l_next_active_date ;
                p_chg_date_effective := (p_new_date_effective <> p_date_effective);
             end if;
             close next_active_row;
          end if;
       else
          -- there exists a active row prior to the current row
          -- date effective is not going to be changed
          p_chg_date_effective := FALSE ;
       end if;
    elsif p_datetrack_mode = 'DELETE_NEXT_CHANGE'  then
    if g_debug then
       hr_utility.set_location('inside for action '||p_datetrack_mode||l_proc, 50);
    end if;
          if p_date_effective < p_effective_start_date then
             -- nothing should be done as first active row is not going to be deleted
             null;
          else
             -- status of the current row is found
             l_current_row_stat := hr_psf_shd.get_availability_status(p_availability_status_id,p_business_group_id);
             if l_current_row_stat ='ACTIVE' then
                -- current row is active row itself, so nothing is to be changed
                p_chg_date_effective := FALSE;
             else
             if g_debug then
                hr_utility.set_location('valid active row searching'||l_proc, 60);
             end if;
                open valid_first_active_row(p_position_id,p_effective_end_date);
                fetch valid_first_active_row into l_next_active_date ;
                if valid_first_active_row%found then
                   -- next active row effective start date has been found after deletion of the next row
                   p_new_date_effective := l_next_active_date ;
                   p_chg_date_effective := (p_new_date_effective <> p_date_effective);
                end if;
                close valid_first_active_row ;
             end if;
          end if;
    elsif p_datetrack_mode = 'FUTURE_CHANGE'
       or p_datetrack_mode = 'ZAP' then  -- 'Purge' as seen on GUI
          -- nothing is to be done in this case
          p_chg_date_effective := FALSE ;
         if g_debug then
              hr_utility.set_location('inside for action '||p_datetrack_mode||l_proc, 70);
         end if;
    end if;
   hr_utility.set_location('Leaving'||l_proc, 1000);
end chg_date_effective ;

--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_availability_status_id >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the availability_status_id exists in PER_SHARED_TYPES
--
--  Pre-conditions :
--
--  In Arguments :
--
--  Post Success :
--
--  Post Failure :
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
procedure chk_availability_status_id
   (p_position_id            in number
   ,p_validation_start_date  in date
   ,p_availability_status_id in number
   ,p_old_avail_status_id    in number
   ,p_business_group_id      in number
   ,p_date_effective         in date default null
   ,p_effective_date         in date default null
   ,p_object_version_number  in number default 1
   ,p_datetrack_mode         in varchar2)
is
   type stat_matrix is record
        (previous_stat varchar2(30)
        ,present_stat  varchar2(30)
        ,future_stat   varchar2(30)) ;
   TYPE tran_stat IS table of stat_matrix
             index by binary_integer ;
   chk_stat  tran_stat;
   cursor csr_stat(p_position_id number,p_effective_start_date date,p_business_group_id number) is
      select hr_psf_shd.get_availability_status(pos.availability_status_id,p_business_group_id)
      from hr_all_positions_f pos
      where pos.position_id = p_position_id
      and pos.effective_start_date = p_effective_start_date;
   cursor csr_prev(p_position_id number, p_effective_start_date date) is
       select max(effective_start_date)
       from hr_all_positions_f
       where position_id = p_position_id
       and effective_start_date < p_effective_start_date ;
   cursor csr_future(p_position_id number, p_effective_start_date date) is
       select min(effective_start_date)
       from hr_all_positions_f
       where position_id = p_position_id
       and effective_start_date > p_effective_start_date ;
   cursor csr_present(p_position_id number, p_object_version_number number) is
       select effective_start_date
       from hr_all_positions_f
       where position_id = p_position_id
       and object_version_number = p_object_version_number ;
   l_present_stat varchar2(30) ;
   l_prev_stat    varchar2(30);
   l_future_stat  varchar2(30);
   l_prev_esd     date ;
   l_future_esd   date ;
   l_current_esd  date ;
   l_proc         varchar2(72) ;
   l_return       boolean := false ;
   i              number ;
   l_count        number ;
   l_validation_reqd boolean := TRUE ;
   --
   procedure set_stat (p_chk_stat     in out nocopy tran_stat
                    , p_subscript     in     number
                    , p_prev_stat     in     varchar2
                    , p_present_stat  in     varchar2
                    , p_future_stat   in     varchar2) is
   --
   begin
     --
     p_chk_stat(p_subscript).previous_stat := p_prev_stat ;
     p_chk_stat(p_subscript).present_stat  := p_present_stat;
     p_chk_stat(p_subscript).future_stat   := p_future_stat;
     --
   end;
   --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    l_proc := g_package||'chk_avail_stat';
  --
  end if;
  --
  l_present_stat := hr_psf_shd.get_availability_status(p_availability_status_id
                                                      ,p_business_group_id);
  --
  -- populating the status transition matrix
  --
      set_stat(chk_stat, 1, NULL, 'PROPOSED', NULL);
      set_stat(chk_stat, 2, NULL, 'PROPOSED', 'PROPOSED');
      set_stat(chk_stat, 3, 'PROPOSED', 'PROPOSED', NULL);
      set_stat(chk_stat, 4, 'PROPOSED', 'PROPOSED', 'PROPOSED');
      set_stat(chk_stat, 5, 'PROPOSED', 'PROPOSED', 'ACTIVE');
      set_stat(chk_stat, 6, 'PROPOSED', 'PROPOSED', 'DELETED');
      set_stat(chk_stat, 7, 'PROPOSED', 'DELETED', 'DELETED');
      set_stat(chk_stat, 8, 'PROPOSED', 'DELETED', NULL);
      set_stat(chk_stat, 9, 'PROPOSED', 'ACTIVE', NULL);
      set_stat(chk_stat, 10, 'DELETED',  'DELETED', 'DELETED');
      set_stat(chk_stat, 11, 'DELETED',  'DELETED', NULL);
      set_stat(chk_stat, 12, 'PROPOSED', 'ACTIVE', 'ACTIVE');
      set_stat(chk_stat, 13, 'ACTIVE', 'ACTIVE', 'ACTIVE');
      set_stat(chk_stat, 14, 'ACTIVE', 'ACTIVE', NULL);
      set_stat(chk_stat, 15, NULL, 'ACTIVE', 'ACTIVE');
      set_stat(chk_stat, 16, NULL, 'ACTIVE', NULL);
      set_stat(chk_stat, 17, 'ACTIVE', 'ACTIVE', 'FROZEN');
      set_stat(chk_stat, 18, 'ACTIVE', 'FROZEN', 'FROZEN');
      set_stat(chk_stat, 19, 'ACTIVE', 'FROZEN', 'ACTIVE');
      set_stat(chk_stat, 20, 'FROZEN', 'FROZEN', 'FROZEN');
      set_stat(chk_stat, 21, 'FROZEN', 'FROZEN', 'ACTIVE');
      set_stat(chk_stat, 22, 'FROZEN', 'ACTIVE', 'ACTIVE');
      set_stat(chk_stat, 23, 'FROZEN', 'ACTIVE', 'FROZEN');
      set_stat(chk_stat, 24, 'ACTIVE', 'ACTIVE', 'FROZEN');
      set_stat(chk_stat, 25, 'ACTIVE', 'FROZEN', 'FROZEN');
      set_stat(chk_stat, 26, 'ACTIVE', 'ELIMINATED', 'ELIMINATED');
      set_stat(chk_stat, 27, 'ACTIVE', 'ACTIVE', 'ELIMINATED');
      set_stat(chk_stat, 28, 'ELIMINATED', 'ELIMINATED', 'ELIMINATED');
      set_stat(chk_stat, 29, 'FROZEN', 'ELIMINATED', 'ELIMINATED');
      set_stat(chk_stat, 30, 'FROZEN', 'FROZEN', 'ELIMINATED');
      set_stat(chk_stat, 31, 'ACTIVE', 'FROZEN', 'ELIMINATED');
      set_stat(chk_stat, 32, 'FROZEN', 'ACTIVE', 'ELIMINATED');
      set_stat(chk_stat, 33, 'PROPOSED', 'ACTIVE', 'ELIMINATED');
      set_stat(chk_stat, 34, 'PROPOSED', 'ACTIVE', 'FROZEN');
      set_stat(chk_stat, 35, NULL, 'ACTIVE', 'ELIMINATED');
      set_stat(chk_stat, 36, NULL, 'ACTIVE', 'FROZEN');
      set_stat(chk_stat, 37, 'ACTIVE', 'FROZEN', NULL);
      set_stat(chk_stat, 38, 'FROZEN', 'FROZEN', NULL);
      set_stat(chk_stat, 39, 'ELIMINATED', 'ELIMINATED', NULL);
      set_stat(chk_stat, 40, 'ACTIVE', 'ELIMINATED', NULL);
      set_stat(chk_stat, 41, 'FROZEN', 'ELIMINATED', NULL);
      set_stat(chk_stat, 42, 'FROZEN', 'ACTIVE', NULL);
      set_stat(chk_stat, 43, NULL, 'PROPOSED', 'ACTIVE');
      --
      --set_stat(chk_stat, 44, 'ACTIVE', 'DELETED', NULL); -- Added for bug 2130540

--
-- status transition matrix is populated depending upon the datetrack mode
-- previous and future status will be defined and compared with the matrix
-- values.
    if p_datetrack_mode = 'INSERT' then
       l_prev_stat := NULL;
       l_future_stat := NULL ;
    elsif p_datetrack_mode = 'CORRECTION' then
       -- old rec value does not matter to us and previous and future
       -- values are to be fetched from the database
       open csr_prev(p_position_id,p_validation_start_date) ;
       fetch csr_prev into l_prev_esd ;
       close csr_prev ;
       open csr_future(p_position_id,p_validation_start_date) ;
       fetch csr_future into l_future_esd ;
       close csr_future ;
       -- corresponding to the previous and future records status is fetched
       -- from the database
       open csr_stat(p_position_id,l_prev_esd,p_business_group_id) ;
       fetch csr_stat into l_prev_stat ;
       close csr_stat ;
       open csr_stat(p_position_id,l_future_esd,p_business_group_id) ;
       fetch csr_stat into l_future_stat ;
       close csr_stat ;
    elsif p_datetrack_mode = 'UPDATE' or
          p_datetrack_mode = 'UPDATE_OVERRIDE' then
       -- old rec values are used for previous status and future stat is
       -- fetched from the database
       l_prev_stat := hr_psf_shd.get_availability_status( p_old_avail_status_id,
                                                          p_business_group_id) ;
       l_future_stat := NULL ;
    elsif p_datetrack_mode = 'UPDATE_CHANGE_INSERT' then -- 'INSERT after UPDATE' as seen on GUI
       -- old rec values are used for previous status and future stat is
       -- fetched from the database
       l_prev_stat := hr_psf_shd.get_availability_status( p_old_avail_status_id,
                                                          p_business_group_id) ;

       open csr_future(p_position_id,p_validation_start_date) ;
       fetch csr_future into l_future_esd ;
       close csr_future ;
       -- corresponding to the previous and future records status is fetched
       -- from the database
       open csr_stat(p_position_id,l_future_esd,p_business_group_id) ;
       fetch csr_stat into l_future_stat ;
       close csr_stat ;
    elsif p_datetrack_mode = 'FUTURE_CHANGE' then -- 'All' as seen on GUI
       l_validation_reqd := false ;
    elsif p_datetrack_mode = 'DELETE_NEXT_CHANGE' then  -- 'Next' as seen on GUI
       -- current row effective start date is used to fetch next rows  as
       -- validation start date does not have value in this case
       open csr_present(p_position_id,p_object_version_number) ;
       fetch csr_present into l_current_esd ;
       close csr_present ;
if g_debug then
       hr_utility.set_location('current row esd is'||l_current_esd||l_proc,111);
       hr_utility.set_location('curr, ovn is'||p_object_version_number||l_proc,111);
end if;

       -- old rec value does not matter to us and previous and future
       -- values are to be fetched from the database
       open csr_prev(p_position_id,l_current_esd) ;
       fetch csr_prev into l_prev_esd ;
       close csr_prev ;

       -- as next row is getting deleted we have to find out the status of the
       -- next to next row. That's why there are two calls.
       open csr_future(p_position_id,l_current_esd) ;
       fetch csr_future into l_future_esd ;
       close csr_future ;
if g_debug then
       hr_utility.set_location('deleted row esd is'||l_future_esd||l_proc,111);
end if;
       open csr_future(p_position_id,l_future_esd) ;
       fetch csr_future into l_future_esd ;
       close csr_future ;
if g_debug then
       hr_utility.set_location('next row esd is'||l_future_esd||l_proc,111);
end if;

       -- corresponding to the previous and future records status is fetched
       -- from the database
       open csr_stat(p_position_id,l_prev_esd,p_business_group_id) ;
       fetch csr_stat into l_prev_stat ;
       close csr_stat ;
       open csr_stat(p_position_id,l_future_esd,p_business_group_id) ;
       fetch csr_stat into l_future_stat ;
       close csr_stat ;
if g_debug then
       hr_utility.set_location('next row stat is'||l_future_stat||l_proc,111);
end if;
    elsif p_datetrack_mode = 'ZAP' then  -- 'Purge' as seen on GUI
       l_validation_reqd := false ;
    end if;
if g_debug then
    hr_utility.set_location(nvl(l_prev_stat,'NULL')||nvl(l_present_stat,'NULL')||nvl(l_future_stat,'NULL'),100);
    hr_utility.set_location(p_datetrack_mode||l_proc ,100);
end if;
    if l_validation_reqd = true then
       l_count := chk_stat.count ;
       i := 1 ;
       loop
         if nvl(chk_stat(i).previous_stat,'ZZZZ') = nvl(l_prev_stat,'ZZZZ')
           and nvl(chk_stat(i).present_stat,'ZZZZ') = nvl(l_present_stat,'ZZZZ')
           and nvl(chk_stat(i).future_stat,'ZZZZ') = nvl(l_future_stat,'ZZZZ')
         then
           l_return := true ;
           exit ;
         else
           i := i + 1;
         end if;
         if i > l_count then
            exit ;
         end if;
       end loop;
       if l_return <> true then
          hr_utility.set_message(800,'HR_NOT_VALID_STATUS_CHANGE');
          hr_utility.raise_error;
       end if;
   end if;
/*
-- code to stop change in availability status to active (Row is going to first active row )
-- when date_effective is not equal to effective date
   if l_present_stat = 'ACTIVE' then
      if l_prev_stat in ('NULL','PROPOSED') then
         if p_effective_date <> p_date_effective then
            -- raise the error
            hr_utility.set_message(800,'PER_STAT_ACTIVE_DE_ED_ONLY');
            hr_utility.raise_error;
         end if;
      end if;
   end if;
*/
end chk_availability_status_id;
--

--  ---------------------------------------------------------------------------
--  |-------------------< chk_entry_step_id >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_entry_step_id
  (p_position_id              in hr_all_positions_f.position_id%TYPE
  ,p_entry_step_id            in hr_all_positions_f.entry_step_id%TYPE
  ,p_entry_grade_id           in hr_all_positions_f.entry_grade_id%TYPE
  ,p_business_group_id        in hr_all_positions_f.business_group_id%TYPE
  ,p_validation_start_date    in hr_all_positions_f.effective_start_date%TYPE
  ,p_validation_end_date      in hr_all_positions_f.effective_end_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in hr_all_positions_f.object_version_number%TYPE
  )
  is
--
   l_sequence           per_spinal_point_steps_f.sequence%TYPE;
   l_exists            varchar2(1);
   l_api_updating      boolean;
   l_business_group_id number(15);
   l_proc              varchar2(72) ;
--
   cursor csr_valid_step is
   select  business_group_id
     from  per_spinal_point_steps_f psps
     where psps.step_id               = p_entry_step_id
       and p_validation_start_date between psps.effective_start_date and psps.effective_end_date;
--
   cursor csr_valid_step_grade is
     select   psps.sequence
     from     per_grade_spines_f pgs,
              per_spinal_point_steps_f psps
     where    psps.step_id       = p_entry_step_id
       and    pgs.grade_id       = p_entry_grade_id
       and    pgs.grade_spine_id = psps.grade_spine_id
       and    p_effective_date between pgs.effective_start_date
                                   and pgs.effective_end_date
       and    p_effective_date between psps.effective_start_date
                                   and psps.effective_end_date;
--
begin
if g_debug then
  l_proc  := g_package||'chk_entry_step_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  if g_debug then
            hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for special ceiling step has changed
  --
  l_api_updating := hr_psf_shd.api_updating
        (p_position_id          => p_position_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  if ((l_api_updating and
       nvl(hr_psf_shd.g_old_rec.entry_step_id, hr_api.g_number) <>
       nvl(p_entry_step_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    if p_entry_step_id is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 50);
    end if;
      --
      -- Check that entry_step_id exists and is date effective
      -- per_grade_spines_f
      --
      open csr_valid_step;
      fetch csr_valid_step into l_business_group_id;
      if csr_valid_step%notfound then
        close csr_valid_step;
        hr_utility.set_message(800, 'HR_ENTRY_STEP_ID_NF');
        hr_utility.raise_error;
        --
      end if;
      close csr_valid_step;
      if g_debug then
        hr_utility.set_location(l_proc, 60);
      end if;
      --
      -- Check that the business group of the entry_step_id on
      -- per_grade_spines is the same as that of the position.
      --
      if l_business_group_id <> p_business_group_id then
       hr_utility.set_message(800, 'HR_PSF_INV_BG_FOR_ENTRY_STEP');
        hr_utility.raise_error;
      end if;
      if g_debug then
                hr_utility.set_location(l_proc, 70);
      end if;
      --
      -- Check that the entry_step_id is valid for the grade
      -- if p_grade is not null.
      --
      if p_entry_grade_id is not null then
        open csr_valid_step_grade;
        fetch csr_valid_step_grade into l_sequence;
        if csr_valid_step_grade%notfound then
          close csr_valid_step_grade;
          hr_utility.set_message(800, 'HR_PSF_STEP_INV_FOR_GRADE');
          hr_utility.raise_error;
        end if;
        close csr_valid_step_grade;
        if g_debug then
          hr_utility.set_location(l_proc, 80);
        end if;
      else
        --
        -- If the value for step is not null
        -- then grade id must also be not null
        --
        hr_utility.set_message(800, 'HR_PSF_GRADE_REQUIRED');
        hr_utility.raise_error;
      end if;
      if g_debug then
      hr_utility.set_location(l_proc, 90);
      end if;
      --
    end if;
    if g_debug then
    hr_utility.set_location(l_proc, 130);
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 140);
end chk_entry_step_id;
--
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_entry_grade_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_entry_grade_id
  (p_position_id              in     hr_all_positions_f.position_id%TYPE
  ,p_business_group_id        in     hr_all_positions_f.business_group_id%TYPE
  ,p_entry_grade_id           in     hr_all_positions_f.entry_grade_id%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     hr_all_positions_f.effective_start_date%TYPE
  ,p_validation_end_date      in     hr_all_positions_f.effective_end_date%TYPE
  ,p_object_version_number    in     hr_all_positions_f.object_version_number%TYPE
  )
  is
--
  l_exists             varchar2(1);
  l_api_updating       boolean;
  l_business_group_id  number(15);
  l_proc               varchar2(72);
  l_vac_grade_id       hr_all_positions_f.entry_grade_id%TYPE;
  --
  cursor csr_valid_grade is
    select   business_group_id
    from     per_grades
    where    grade_id = p_entry_grade_id
    and      p_validation_start_date
      between date_from and nvl(date_to, hr_api.g_eot);
  --
begin
if g_debug then
 l_proc  :=    g_package||'chk_entry_grade_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;

  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for grade has changed
  --
  l_api_updating := hr_psf_shd.api_updating
        (p_position_id            => p_position_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  if g_debug then
  hr_utility.set_location(l_proc, 30);
  end if;
  --
  if ((l_api_updating and
       nvl(hr_psf_shd.g_old_rec.entry_grade_id, hr_api.g_number) <>
       nvl(p_entry_grade_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
   if g_debug then
   hr_utility.set_location(l_proc, 40);
   end if;
   --
   -- Check if the grade is set.
   --
   if p_entry_grade_id is not null then
     --
     -- Check that the grade exists between date from and date to in
     -- PER_GRADES.
     --
     open csr_valid_grade;
     fetch csr_valid_grade into l_business_group_id;
     if csr_valid_grade%notfound then
       close csr_valid_grade;
       hr_utility.set_message(800, 'HR_PSF_INVALID_GRADE');
       hr_utility.raise_error;
       --
     end if;
     close csr_valid_grade;
   if g_debug then
     hr_utility.set_location(l_proc, 50);
   end if;
     --
     -- Check that the business group for the grade is the same
     -- as that of the position
     --
     if l_business_group_id <> p_business_group_id then
       --
       hr_utility.set_message(800, 'HR_PSF_INVALID_BG_GRADE');
       hr_utility.raise_error;
       --
     end if;
     if g_debug then
     hr_utility.set_location(l_proc, 60);
     end if;
     --
   end if;
   if g_debug then
   hr_utility.set_location(l_proc, 80);
   end if;
   --
  end if;
  if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 110);
  end if;
  --
end chk_entry_grade_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_entry_grade_rule_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_entry_grade_rule_id
  (p_position_id              in     hr_all_positions_f.position_id%TYPE
  ,p_business_group_id        in     hr_all_positions_f.business_group_id%TYPE
  ,p_entry_grade_rule_id           in     hr_all_positions_f.entry_grade_rule_id%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     hr_all_positions_f.effective_start_date%TYPE
  ,p_validation_end_date      in     hr_all_positions_f.effective_end_date%TYPE
  ,p_object_version_number    in     hr_all_positions_f.object_version_number%TYPE
  )
  is
--
  l_exists             varchar2(1);
  l_api_updating       boolean;
  l_business_group_id  number(15);
  l_proc               varchar2(72) ;
  l_entry_grade_rule_id       hr_all_positions_f.entry_grade_rule_id%TYPE;
  --
  cursor csr_valid_grade_rule is
    select   business_group_id
    from     pay_grade_rules_f
    where    grade_rule_id = p_entry_grade_rule_id
    and      p_validation_start_date
      between effective_start_date and effective_end_date;
  --
begin
if g_debug then
 l_proc  :=  g_package||'chk_entry_grade_rule_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;

  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
    if g_debug then
  hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for grade has changed
  --
  l_api_updating := hr_psf_shd.api_updating
        (p_position_id            => p_position_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  if g_debug then
  hr_utility.set_location(l_proc, 30);
  end if;
  --
  if ((l_api_updating and
       nvl(hr_psf_shd.g_old_rec.entry_grade_rule_id, hr_api.g_number) <>
       nvl(p_entry_grade_rule_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
   if g_debug then
   hr_utility.set_location(l_proc, 40);
   end if;
   --
   -- Check if the grade is set.
   --
   if p_entry_grade_rule_id is not null then
     --
     -- Check that the grade exists between date from and date to in
     -- PER_GRADES.
     --
     open csr_valid_grade_rule;
     fetch csr_valid_grade_rule into l_business_group_id;
     if csr_valid_grade_rule%notfound then
       close csr_valid_grade_rule;
       hr_utility.set_message(800, 'HR_PSF_INVALID_GRADE_RULE');
       hr_utility.raise_error;
       --
     end if;
     close csr_valid_grade_rule;
     if g_debug then
     hr_utility.set_location(l_proc, 50);
     end if;
     --
     -- Check that the business group for the grade rule is the same
     -- as that of the position
     --
     if l_business_group_id <> p_business_group_id then
       --
       hr_utility.set_message(800, 'HR_PSF_INVALID_BG_GRADE_RULE');
       hr_utility.raise_error;
       --
     end if;
     hr_utility.set_location(l_proc, 60);
     --
   end if;
   hr_utility.set_location(l_proc, 80);
   --
  end if;
  if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 110);
  end if;
  --
end chk_entry_grade_rule_id;
--
--
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_pay_freq_payroll_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_pay_freq_payroll_id
  (p_position_id           in hr_all_positions_f.position_id%TYPE
  ,p_business_group_id     in hr_all_positions_f.business_group_id%TYPE
  ,p_pay_freq_payroll_id   in hr_all_positions_f.pay_freq_payroll_id%TYPE
  ,p_validation_start_date in hr_all_positions_f.effective_start_date%TYPE
  ,p_validation_end_date   in hr_all_positions_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_object_version_number in hr_all_positions_f.object_version_number%TYPE
  )
  is
  --
  l_api_updating                 boolean;
  l_cur_opu_effective_start_date date;
  l_cur_opu_effective_end_date   date;
  l_business_group_id            number(15);
  l_exists                       varchar2(1);
  l_future_change                boolean;
  l_invalid_ppm                  boolean;
  l_min_opu_effective_start_date date;
  l_min_ppm_effective_start_date date;
  l_max_opu_effective_end_date   date;
  l_max_ppm_effective_end_date   date;
  l_org_payment_method_id
                      pay_personal_payment_methods_f.org_payment_method_id%TYPE;
  l_org_pay_method_usage_id
                       pay_org_pay_method_usages_f.org_pay_method_usage_id%TYPE;
  l_personal_payment_method_id
                 pay_personal_payment_methods_f.personal_payment_method_id%TYPE;
  l_proc                         varchar2(72);
  l_working_start_date           date;
  l_working_end_date             date;
  --
  cursor csr_payroll_exists is
    select business_group_id
    from pay_payrolls_f pp
    where pp.payroll_id = p_pay_freq_payroll_id and
          p_validation_start_date between pp.effective_start_date and pp.effective_end_date ;
--
begin
if g_debug then
l_proc  :=  g_package||'chk_pay_freq_payroll_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
         (p_position_id          => p_position_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  if (l_api_updating and
       (nvl(hr_psf_shd.g_old_rec.pay_freq_payroll_id, hr_api.g_number)
         <> nvl(p_pay_freq_payroll_id, hr_api.g_number))
     )
    or  NOT l_api_updating
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    if p_pay_freq_payroll_id is not null then
      --
      -- Check that payroll exists and the effective start date of the
      -- position is the same as or after the effective start date
      -- of the payroll. Also the effective end date of the assignment
      -- is the same as or before the effective end date of the payroll.
      --
      open csr_payroll_exists;
      fetch csr_payroll_exists into l_business_group_id;
      if csr_payroll_exists%notfound then
        close csr_payroll_exists;
        hr_utility.set_message(800, 'HR_PSF_PAYROLL_NF');
        hr_utility.raise_error;
      end if;
      close csr_payroll_exists;
if g_debug then
      hr_utility.set_location(l_proc, 60);
end if;
      --
      -- Check that business group of payroll is the
      -- same as that of the position
      --
      if l_business_group_id <> p_business_group_id then
        hr_utility.set_message(800, 'HR_PSF_INVALID_BG_PAYROLL');
        hr_utility.raise_error;
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 70);
end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 300);
end if;
end chk_pay_freq_payroll_id;
--
--  ----------------------------------------------------------------------------
--  |--------------------------<  chk_ccid_unique_for_BG  >--------------------|
--  ----------------------------------------------------------------------------
--
--  PMFLETCH - New uniqueness validation routine
--
--  Desciption :
--
--    Validates that the POSITION_DEFINITION_ID is unique within a
--    position's BUSINESS GROUP
--
--  Pre-conditions :
--
--  In Arguments :
--    p_business_group_id
--    p_position_id
--    p_position_definition_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success :
--    If the POSITION_DEFINITION_ID in HR_ALL_POSITIONS_F table does not exist
--    for given BUSINESS_GROUP_ID then processing continues
--
--  Post Failure :
--    If the POSITION_DEFINITION_ID does exist in HR_ALL_POSITIONS_F table for given
--    BUSINESS_GROUP_ID, then an application error will be raised and processing
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
procedure chk_ccid_unique_for_BG
  (p_business_group_id             in      number
  ,p_position_id                   in      number
  ,p_position_definition_id        in      number
  ,p_validation_start_date         in      date
  ,p_validation_end_date           in      date
  ,p_effective_date                in      date
  ,p_object_version_number         in      number
  )  is
--
   l_api_updating                  boolean;
   l_exists                        varchar2(1);
   l_proc                          varchar2(72) ;
--
  -- Check there are no records in this business group that have the same
  -- position definition id within the validation date range - except for
  -- the current position
   cursor csr_ccid_unique is
     select 'x'
       from hr_all_positions_f psf
      where psf.position_id <> nvl(p_position_id, -1)
        and psf.business_group_id = p_business_group_id
        and psf.position_definition_id = p_position_definition_id
        and psf.effective_start_date <= p_validation_end_date
        and psf.effective_end_date   >= p_validation_start_date;
--
begin
  if g_debug then
     l_proc :=      g_package||'chk_ccid_unique_for_BG';
    hr_utility.set_location('Entering:'||l_proc, 10);
    hr_utility.set_location('p_business_group_id:'||p_business_group_id, 10);
    hr_utility.set_location('p_position_id:'||p_position_id, 10);
    hr_utility.set_location('p_position_definition_id:'||p_position_definition_id, 10);
    hr_utility.set_location('p_validation_start_date:'||p_validation_start_date, 10);
    hr_utility.set_location('p_validation_end_date:'||p_validation_end_date, 10);
    hr_utility.set_location('p_effective_date:'||p_effective_date, 10);
    hr_utility.set_location('p_object_version_number:'||p_object_version_number, 10);
  end if;
  --
  --   Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'business_group_id'
    ,p_argument_value           => p_business_group_id
    );
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'position_definition_id'
    ,p_argument_value           => p_position_definition_id
    );
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'validation_start_date'
    ,p_argument_value           => p_validation_start_date
    );
  if g_debug then
    hr_utility.set_location(l_proc, 40);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'validation_end_date'
    ,p_argument_value           => p_validation_end_date
    );
  if g_debug then
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'effective_date'
    ,p_argument_value           => p_effective_date
    );
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  l_api_updating := hr_psf_shd.api_updating
         (p_position_id          => p_position_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  if g_debug then
    hr_utility.set_location(l_proc, 70);
  end if;
  --
  if (l_api_updating and
       (nvl(hr_psf_shd.g_old_rec.position_definition_id, hr_api.g_number)
         <> nvl(p_position_definition_id, hr_api.g_number))
     )
    or  NOT l_api_updating
  then
    if g_debug then
      hr_utility.set_location(l_proc, 80);
    end if;
    --
    --    Check for unique ccid
    --
    open csr_ccid_unique;
    fetch csr_ccid_unique into l_exists;
    if csr_ccid_unique%found then
      close csr_ccid_unique;
      hr_utility.set_message(800,'PAY_7688_USER_POS_TAB_UNIQUE');
      hr_utility.raise_error;
    else
      close csr_ccid_unique;
      if g_debug then
        hr_utility.set_location(l_proc, 90);
      end if;
    end if;
  --
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  end if;
--
end chk_ccid_unique_for_BG;
--
--
--  ----------------------------------------------------------------------------
--  |--------------------------<  chk_name_unique_for_BG  >--------------------|
--  ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the position NAME is unique within position's BUSINESS GROUP
--
--  Pre-conditions :
--
--  In Arguments :
--    p_business_group_id
--    p_position_id
--    p_name
--    p_effective_date
--
--  Post Success :
--    If the NAME in HR_ALL_POSITIONS table does not exist for given BUSINESS_GROUP_ID
--    then processing continues
--
--  Post Failure :
--    If the NAME does exist in PER_POSITIONS table for given BUSINESS_GROUP_ID,
--    then an application error will be raised and processing terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
procedure chk_name_unique_for_BG
  (p_business_group_id  in      number
  ,p_position_id        in      number
  ,p_effective_date     in      date
  ,p_name               in      varchar2
  ,p_object_version_number in number
  )  is
--
   l_api_updating                 boolean;
   l_exists             varchar2(1);
   l_proc               varchar2(72) ;
--
   cursor csr_name_unique is
      select  'x'
        from  hr_all_positions_f psf
       where  psf.name = p_name
         and  (p_position_id is null or psf.position_id <> p_position_id)
         and  psf.business_group_id = p_business_group_id;
--
--
Begin
if g_debug then
   l_proc :=      g_package||'chk_name_unique_for_BG';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  --   Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'business_group_id'
    ,p_argument_value           => p_business_group_id
    );
if g_debug then
  hr_utility.set_location(l_proc, 2);
end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'name'
    ,p_argument_value           => p_name
    );
if g_debug then
  hr_utility.set_location(l_proc, 3);
end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'effective_date'
    ,p_argument_value           => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
         (p_position_id          => p_position_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  if (l_api_updating and
       (nvl(hr_psf_shd.g_old_rec.name, hr_api.g_varchar2)
         <> nvl(p_name, hr_api.g_varchar2))
     )
    or  NOT l_api_updating
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    --    Check for unique name
    --
    open csr_name_unique;
    fetch csr_name_unique into l_exists;
    if csr_name_unique%found then
      close csr_name_unique;
      hr_utility.set_message(800,'PAY_7688_USER_POS_TAB_UNIQUE');
      hr_utility.raise_error;
    else
      close csr_name_unique;
    end if;
  --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end if;
end chk_name_unique_for_BG;
--
--
-- End insert/update/delete_validate
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_hrs_frequency  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that if the values for WORKING_HOURS and FREQUENCY are null that
--    the values are defaulted from HR_ORGANIZATION_UNITS for the position's
--    ORGANIZATION_ID. When organization defaults are not maintained, the
--    default values from the business group are used.
--
--    Validate that if FREQUENCY is null and WORKING_HOURS is not null
--    or if WORKING_HOURS is null and FREQUENCY is not null an error
--    is raised
--
--    Validate the FREQUENCY value against the table
--    FND_COMMON_LOOKUPS where the LOOKUP_TYPE is 'FREQUENCY'. (I,U)
--
--    Validate that if the value for WORKING_HOURS is NOT NULL,
--    that the FREQUENCY value is valid for the WORKING_HOURS value.
--
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_business_group_id
--    p_organization_id
--    p_position_id
--    p_working_hours
--    p_frequency
--    p_effective_date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_hrs_frequency
  (p_position_id        in number default null
  ,p_working_hours         in number
  ,p_effective_date        in date
  ,p_frequency             in varchar2
  ,p_object_version_number in number default null)    is
--
   l_proc   varchar2(72);
   l_exists          varchar2(1);
   l_working_hours    number;
   l_frequency        varchar2(30);
   l_api_updating     boolean;
--
   cursor csr_valid_freq is
     select 'x'
     from fnd_common_lookups
     where lookup_type = 'FREQUENCY'
     and lookup_code = p_frequency
     and enabled_flag = 'Y'
     and p_effective_date between nvl(start_date_active,p_effective_date)
       and nvl(end_date_active,p_effective_date);
--
begin
if g_debug then
   l_proc   := g_package||'chk_hrs_frequency';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The working hours value has changed or
  -- c) The frequency value has changed
  --
--
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id        => p_position_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
      (nvl(hr_psf_shd.g_old_rec.working_hours,hr_api.g_number) <>
      nvl(p_working_hours,hr_api.g_number) or
      (nvl(hr_psf_shd.g_old_rec.frequency,hr_api.g_varchar2) <>
      nvl(p_frequency,hr_api.g_varchar2)))) or
      (NOT l_api_updating)) then
      --
      --    Check for values consistency
      --
if g_debug then
      hr_utility.set_location(l_proc, 5);
end if;
      --
    if ((p_working_hours is null and p_frequency is not null) or
      (p_working_hours is not null and p_frequency is null)) then
       hr_utility.set_message(800,'PER_52981_POS_WORK_FREQ_NULL');
       hr_utility.raise_error;
    end if;
      --
      --    Check for valid frequency against fnd_common_lookups
      --
if g_debug then
    hr_utility.set_location(l_proc, 6);
end if;
      --
if p_frequency is not null then

    open csr_valid_freq;
    fetch csr_valid_freq into l_exists;
    if csr_valid_freq%notfound then
      hr_utility.set_message(800,'HR_51363_POS_INVAL_FREQUENCY');
      hr_utility.raise_error;
    end if;
      --
      --    Validate combinations of working_hours and frequency
      --
if g_debug then
    hr_utility.set_location(l_proc, 7);
end if;
      --
    if ((p_working_hours > 24 AND p_frequency = 'D') or
       ((p_working_hours > 168)
        and (p_frequency = 'W')) or
       ((p_working_hours > 744)
        and (p_frequency = 'M')) or
       ((p_working_hours > 8784)
        and (p_frequency = 'Y'))) then
       hr_utility.set_message(800,'HR_POS_2_MANY_HOURS');
       hr_utility.raise_error;
    end if;
    --
  end if;
--
end if;
if g_debug then
hr_utility.set_location(' Leaving:'||l_proc, 8);
end if;
end chk_hrs_frequency;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_pay_basis_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_pay_basis_id
  (p_position_id           in hr_all_positions_f.position_id%TYPE
  ,p_business_group_id     in hr_all_positions_f.business_group_id%TYPE
  ,p_pay_basis_id          in hr_all_positions_f.pay_basis_id%TYPE
  ,p_validation_start_date in hr_all_positions_f.effective_start_date%TYPE
  ,p_validation_end_date   in hr_all_positions_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_object_version_number in hr_all_positions_f.object_version_number%TYPE
  )
  is
  --
  cursor c1 is
  select 'x'
  from per_pay_bases
  where pay_basis_id = p_pay_basis_id and
        business_group_id = p_business_group_id;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72);
  l_exists            varchar2(1);
begin
if g_debug then
  l_proc              :=  g_package||'chk_pay_basis_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'position_id',
                             p_argument_value => p_position_id);
  --
if g_debug then
  hr_utility.set_location('Entering : ' || l_proc, 10);
end if;
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'position_id',
                             p_argument_value => p_position_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'business_group_id',
                             p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'validation_start_date',
                             p_argument_value => p_validation_start_date);
  --
  open c1;
  fetch c1 into l_exists;
  if c1%notfound then
    --
      close c1;
      hr_utility.set_message(800,'HR_PSF_INVALID_PAY_BASIS');
      hr_utility.raise_error;
  else
      close c1;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving : ' || l_proc, 100);
end if;
end;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_position_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , hr_positions_f         pos
     where pos.position_id       = p_position_id
       and pbg.business_group_id = pos.business_group_id
     order by pos.effective_start_date;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  ;
begin
if g_debug then
  l_proc              :=  g_package||'return_legislation_code';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'position_id',
                             p_argument_value => p_position_id);
  --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
    close csr_leg_code;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end if;
  --
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_dates >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates DATE_EFFECTIVE is not null
--
--    Validates that DATE_EFFECTIVE is less than or equal to the value for
--    DATE_END on the same POSITION record
--
--  Pre-conditions:
--    Format of p_date_effective must be correct
--
--  In Arguments :
--    p_position_id
--    p_date_effective
--    p_date_end
--    p_effective_date
--    p_validation_start_Date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_dates
  (p_position_id           in number default null
  ,p_date_effective        in date
  ,p_date_end              in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_effective_date        in date
  ,p_object_version_number in number default null) is
--
   cursor c_get_eff_start_date (p_position_id number) is
   select min(effective_start_date)
   from hr_all_positions_f
   where position_id = p_position_id;
--
   l_proc               varchar2(72)   ;
   l_api_updating          boolean;
   l_effective_start_date  date;

   l_return    boolean;
   l_industry  varchar2(10);
   l_status    varchar2(10);
   l_full_hr   boolean;
   l_ll        date;
   l_ul        date;
   l_updateable Boolean;

--
begin
if g_debug then
   l_proc   := g_package||'chk_dates';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  --  Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'date_effective'
    ,p_argument_value   => p_date_effective
    );

  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'validation_start_date'
    ,p_argument_value   => p_validation_start_date
    );

  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'validation_end_date'
    ,p_argument_value   => p_validation_end_date
    );

if g_debug then
  hr_utility.set_location(l_proc, 2);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id        => p_position_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  --
if g_debug then
  hr_utility.set_location('HR Installation check ' || l_proc, 40);
end if;
  --
  -- Find if full hr installation or shared hr installation
  --
  l_return := fnd_installation.get(appl_id     => 800,
                                   dep_appl_id => 800,
                                   status      => l_status,
                                   industry    => l_industry);
  --
if g_debug then
  hr_utility.set_location('HR Installation check done ' || l_proc, 45);
end if;
  if l_status = 'I' then
     l_full_hr := true;
  elsif l_status = 'S' then
     l_full_hr := false;
  else
     hr_utility.set_message(801,'HR_NULL_INSTALLATION_STATUS');
     hr_utility.raise_error;
  end if;

  --
  -- if full hr is installed the date_end must be null
  --
  if l_full_hr  and p_date_end is not null then
      hr_utility.set_message(800,'HR_DATE_END_MUST_BE_NULL');
      hr_utility.raise_error;
  end if;
  --
  if (((l_api_updating and
       (hr_psf_shd.g_old_rec.date_end <> p_date_end) or
       (hr_psf_shd.g_old_rec.date_effective <> p_date_effective)) or
       (NOT l_api_updating))) then
    --
    --   Check that date_effective <= date_end
    --
if g_debug then
    hr_utility.set_location(l_proc, 3);
end if;
    --
    if p_date_effective > nvl(p_date_end,hr_api.g_eot) then
      hr_utility.set_message(800,'HR_51362_POS_INVAL_EFF_DATE');
      hr_utility.raise_error;
    end if;
    --
/*
    --
    -- Date_effective must be on or after effective_start_Date
    --
    if ( l_api_updating) then
      --
      open c_get_eff_start_date(p_position_id);
      fetch c_get_eff_start_date into l_effective_start_Date;
      close c_get_eff_start_date;
      if l_effective_start_date is null then
I       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP','5');
        hr_utility.raise_error;
      end if;
    else
      l_effective_start_date := p_validation_start_date;
    end if;
    --
    if ( p_date_effective < l_effective_start_date ) then
      hr_utility.set_message(800,'HR_PSF_DE_MUST_LATER_OR_EQ_ESD');
      hr_utility.raise_error;
    end if;
--
    if (nvl(p_date_effective, hr_api.g_date) <>
        nvl(hr_psf_shd.g_old_rec.effective_start_date, hr_api.g_date)) then
      -- find if date_Effective can be modified
      --
      DE_Update_properties(
          p_position_id           => p_position_id,
          p_effective_Start_Date  => hr_psf_shd.g_old_rec.effective_start_date,
          p_updateable            => l_updateable,
          p_lower_limit           => l_ll,
          p_upper_limit           => l_ul);
      --
      if not l_updateable then
        --
        hr_utility.set_message(800,'HR_PSF_DE_NOT_UPDT_THIS_ROW');
        hr_utility.raise_error;
      end if;
      --
      if p_date_effective not between l_ll and l_ul then
         hr_utility.set_message(801,'HR_PSF_DE_OUT_OF_RANGE');
         hr_utility.raise_error;
      end if;
      -- if it is first row with ACTIVE status then
    --
    end if;
  --
*/
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end if;
end chk_dates;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_job_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_job_id
  (p_position_id             in     hr_positions_f.position_id%TYPE           default null
  ,p_business_group_id       in     hr_positions_f.business_group_id%TYPE
  ,p_job_id                  in     hr_positions_f.job_id%TYPE
  ,p_effective_date          in     date
  ,p_validation_start_date   in     hr_positions_f.effective_start_date%TYPE
  ,p_validation_end_date     in     hr_positions_f.effective_end_date%TYPE
  ,p_object_version_number   in     hr_positions_f.object_version_number%TYPE default null
  )
  is
  --
  l_proc              varchar2(72) ;
  l_exists            varchar2(1);
  l_api_updating      boolean;
  l_business_group_id hr_positions_f.business_group_id%TYPE;
  l_vac_job_id        hr_positions_f.job_id%TYPE;
  --
  cursor csr_valid_job_id is
     select 'x'
     from per_jobs_v job
     where job.job_id = p_job_id
     and job.business_group_id + 0 = p_business_group_id;
  --
  cursor csr_valid_job_dates(p_validation_date date)  is
     select 'x'
     from per_jobs_v job
     where job.job_id = p_job_id
       and p_validation_date between job.date_from
       and nvl(job.date_to,hr_api.g_eot);
  --

begin
if g_debug then
  l_proc :=  g_package||'chk_job_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'job_id'
    ,p_argument_value   => p_job_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  --  Check if the position is being updated.
  --
  l_api_updating := hr_psf_shd.api_updating
        (p_position_id            => p_position_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for job has changed
  --
  if ((l_api_updating and
       nvl(hr_psf_shd.g_old_rec.job_id,
       hr_api.g_number) <> nvl(p_job_id, hr_api.g_number))
    or
      NOT l_api_updating) then
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    --    Check for valid job id
    --
    open csr_valid_job_id;
    fetch csr_valid_job_id into l_exists;
    if csr_valid_job_id%notfound then
      close csr_valid_job_id;
      hr_utility.set_message(800,'HR_51090_JOB_NOT_EXIST');
      hr_utility.raise_error;
    else
if g_debug then
      hr_utility.set_location(l_proc, 3);
end if;
      --
      close csr_valid_job_id;
      --
      --    Check validation_date between job date_from and date_to
      --
      open csr_valid_job_dates(p_validation_start_date);
      fetch csr_valid_job_dates into l_exists;
      if csr_valid_job_dates%notfound then
        close csr_valid_job_dates;
        hr_utility.set_message(800,'HR_51358_POS_JOB_INVALID_DATE');
        hr_utility.raise_error;
      end if;
      close csr_valid_job_dates;
    end if;
    --
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
end if;
  --
end chk_job_id;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_organization_id >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_organization_id
  (p_position_id             in  hr_positions_f.position_id%TYPE            default null
  ,p_organization_id         in  hr_positions_f.organization_id%TYPE
  ,p_business_group_id       in  hr_positions_f.business_group_id%TYPE
  ,p_validation_start_date   in  hr_positions_f.effective_start_date%TYPE
  ,p_validation_end_date     in  hr_positions_f.effective_end_date%TYPE
  ,p_effective_date          in  date
  ,p_object_version_number   in  hr_positions_f.object_version_number%TYPE  default null
  )
is
  --
  l_exists               varchar2(1);
  l_api_updating         boolean;
  l_proc                 varchar2(72);
  l_business_group_id    hr_positions_f.business_group_id%TYPE;
  --
  cursor csr_valid_organization_id is
     select 'x'
     from per_organization_units oru
     where oru.organization_id = p_organization_id
     and oru.business_group_id = p_business_group_id
     and oru.internal_external_flag = 'INT';
  --
  cursor csr_valid_organization_dates( p_validation_date date) is
     select 'x'
     from hr_organization_units oru
     where oru.organization_id = p_organization_id
       and p_validation_date between oru.date_from
       and nvl(oru.date_to,hr_api.g_eot);
  --

begin
if g_debug then
  l_proc :=  g_package||'chk_organization_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'organization_id'
    ,p_argument_value => p_organization_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for organization_id has changed
  --
  l_api_updating := hr_psf_shd.api_updating
         (p_position_id            => p_position_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  if (l_api_updating and
     hr_psf_shd.g_old_rec.organization_id <> p_organization_id)
    or
      NOT l_api_updating
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    --    Check for valid organization id
    --
    open csr_valid_organization_id;
    fetch csr_valid_organization_id into l_exists;
    if csr_valid_organization_id%notfound then
      close csr_valid_organization_id;
      hr_utility.set_message(800,'HR_51371_POS_ORG_NOT_EXIST');
      hr_utility.raise_error;
    else
if g_debug then
      hr_utility.set_location(l_proc, 3);
end if;
      close csr_valid_organization_id;
      --
      --    Check validation_date between org date_from and date_to
      --
      open csr_valid_organization_dates(p_validation_start_date);
      fetch csr_valid_organization_dates into l_exists;
      if csr_valid_organization_dates%notfound then
        close csr_valid_organization_dates;
        hr_utility.set_message(800,'HR_51359_POS_ORG_INVAL_W_DATE');
        hr_utility.raise_error;
      end if;
      close csr_valid_organization_dates;
    end if;
  end if;
  --
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 140);
end if;
end chk_organization_id;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_successor_position_id  >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--
--    Validates that if SUCCESSOR_POSITION_ID exists, it must be a valid
--    position for the business group and the successor DATE_END is on or after
--    the DATE_EFFECTIVE of the position.
--
--  Pre-conditions:
--
--  In Arguments :
--    p_position_id
--    p_business_group_id
--    p_successor_position_id
--    p_effective_date
--    p_validation_start_Date
--    p_validation_end_Date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ----------------------------------------------------------------------------
procedure chk_successor_position_id
  (p_business_group_id      in number
  ,p_position_id            in number default null
  ,p_successor_position_id  in number
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_effective_date      in date
  ,p_object_version_number  in number default null
  )   is
--
   l_exists           varchar2(1);
   l_proc   varchar2(72) ;
   l_api_updating     boolean;
--
cursor csr_valid_successor_position (p_validation_start_date date) is
select 'x'
from hr_all_positions_f psf, per_shared_types sht
where psf.position_id = p_successor_position_id
and psf.availability_status_id = sht.shared_type_id
and (sht.business_group_id = p_business_group_id
     or sht.business_group_id is null)
and sht.system_type_cd in ('ACTIVE','FROZEN')
and psf.business_group_id = p_business_group_id
and p_validation_start_date between psf.effective_start_date
                            and psf.effective_end_date ;

begin
if g_debug then
  l_proc     :=   g_package||'chk_successor_position_id';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The successor_position_id value has changed
  --
  if p_successor_position_id is not null then
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation start date'
    ,p_argument_value => p_validation_start_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation end date'
    ,p_argument_value => p_validation_end_date);
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date            => p_effective_date
    ,p_object_version_number     => p_object_version_number);
  --
  --
  --    Check for valid successor position id
  --
  if ((l_api_updating and
       hr_psf_shd.g_old_rec.successor_position_id <>
       p_successor_position_id) or
       (NOT l_api_updating)) then
    --
if g_debug then
      hr_utility.set_location(l_proc, 2);
end if;
      open csr_valid_successor_position(p_validation_start_date);
      fetch csr_valid_successor_position into l_exists;
      if csr_valid_successor_position%notfound then
        close csr_valid_successor_position;
        hr_utility.set_message(800,'PER_52979_POS_SUCC_NOT_EXIST');
        hr_utility.raise_error;
     else
      close csr_valid_successor_position;
      if(l_api_updating and p_position_id = p_successor_position_id) then
        hr_utility.set_message(800,'HR_51360_POS_SUCCESSOR_EQ_POS');
        hr_utility.raise_error;
     end if;
    end if;
   end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 3);
end if;
end chk_successor_position_id;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_relief_position_id  >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--
--    Validates that if relief_position_id exists, it must be a valid

--    position for the business group and the successor DATE_END is on or after
--    the DATE_EFFECTIVE of the position.
--
--  Pre-conditions:
--
--  In Arguments :
--    p_position_id
--    p_business_group_id
--    p_relief_position_id
--    p_effective_date
--    p_validation_start_Date
--    p_validation_end_Date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ----------------------------------------------------------------------------
procedure chk_relief_position_id
  (p_business_group_id      in number
  ,p_position_id            in number default null
  ,p_relief_position_id     in number
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_effective_date      in date
  ,p_object_version_number  in number default null
  )   is
--
   l_exists           varchar2(1);
   l_proc   varchar2(72) ;
   l_api_updating     boolean;
--
cursor csr_valid_relief_position (p_validation_start_date date) is
select 'x'
from hr_all_positions_f psf, per_shared_types sht
where psf.position_id = p_relief_position_id
and psf.availability_status_id = sht.shared_type_id
and (sht.business_group_id = p_business_group_id
     or sht.business_group_id is null)
and sht.system_type_cd in ('ACTIVE','FROZEN')
and psf.business_group_id = p_business_group_id
and p_validation_start_date between psf.effective_start_date
                            and psf.effective_end_date ;
--
begin
if g_debug then
   l_proc :=   g_package||'chk_relief_position_id';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The relief_position_id value has changed
  --
  if p_relief_position_id is not null then
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date);
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date            => p_effective_date
    ,p_object_version_number     => p_object_version_number);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation start date'
    ,p_argument_value => p_validation_start_date);
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation end date'
    ,p_argument_value => p_validation_end_date);
  --
  --    Check for valid successor position id
  --
  if ((l_api_updating and
       hr_psf_shd.g_old_rec.relief_position_id <>
       p_relief_position_id) or
       (NOT l_api_updating)) then
    --
if g_debug then
    hr_utility.set_location(l_proc, 2);
end if;
    --
      open csr_valid_relief_position(p_validation_start_date);
      fetch csr_valid_relief_position into l_exists;
      if csr_valid_relief_position%notfound then
        close csr_valid_relief_position;
        hr_utility.set_message(800,'PER_52980_POS_RELF_NOT_EXIST');
        hr_utility.raise_error;
     else
      close csr_valid_relief_position;
      if(l_api_updating and p_position_id = p_relief_position_id) then
        hr_utility.set_message(800,'HR_51361_POS_RELIEF_EQ_POS');
        hr_utility.raise_error;
     end if;
    end if;
   end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 3);
end if;
end chk_relief_position_id;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_location_id >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_location_id
  (p_position_id           in hr_positions.position_id%TYPE           default null
  ,p_location_id           in hr_positions.location_id%TYPE
  ,p_effective_date        in date
  ,p_validation_start_date in hr_positions.effective_start_date%TYPE
  ,p_validation_end_date   in hr_positions.effective_end_date%TYPE
  ,p_object_version_number in hr_positions.object_version_number%TYPE default null
  )
  is
  --
  l_exists          varchar2(1);
  l_api_updating    boolean;
  l_proc            varchar2(72);
  l_inactive_date   date;
  --
  cursor csr_valid_location is
     select 'x'
     from   hr_locations loc
     where  loc.location_id = p_location_id
      and p_effective_date < nvl(loc.inactive_date,
         hr_api.g_eot);

  --
begin

if g_debug then
  l_proc  :=  g_package||'chk_location_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 20);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for location_id has changed
  --
  l_api_updating := hr_psf_shd.api_updating
         (p_position_id          => p_position_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 30);
end if;
  --
  if ((l_api_updating and
       nvl(hr_psf_shd.g_old_rec.location_id, hr_api.g_number) <>
       nvl(p_location_id, hr_api.g_number)) or
      (NOT l_api_updating))
  then
    --
if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 40);
end if;
    --
    if p_location_id is not null then
      --
      -- Check that the location exists in HR_LOCATIONS
      --
      open csr_valid_location;
      fetch csr_valid_location into l_exists;
      if csr_valid_location%notfound then
        close csr_valid_location;
        hr_utility.set_message(800, 'HR_51357_POS_LOC_NOT_EXIST');
        hr_utility.raise_error;
        --
      end if;
      close csr_valid_location;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 90);
end if;
end chk_location_id;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_position_definition_id  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that POSITION_DEFINITION_ID is not null
--
--
--  Pre-conditions:
--
--  In Arguments :
--    p_position_definition_id
--
--  Post Success :
--
--  Post Failure :
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_position_definition_id
  (p_position_definition_id   in number
  ,p_effective_date           in    date
  ,p_position_id              in    number default null
  ,p_object_version_number    in    number default null
  )   is
--
   l_proc   varchar2(72)   ;
   l_exists    varchar2(1);
   l_api_updating  boolean;
--
cursor csr_pos_def is
  select 'x'
  from per_position_definitions
  where position_definition_id = p_position_definition_id;
--
begin
if g_debug then
   l_proc   := g_package||'chk_position_definition_id';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  --  Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'position_definition_id'
    ,p_argument_value   => p_position_definition_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
if g_debug then
  hr_utility.set_location(l_proc, 2);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id        => p_position_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 3);
end if;
  --
  if ((l_api_updating and
       (hr_psf_shd.g_old_rec.position_definition_id <>
          p_position_definition_id)) or
       (NOT l_api_updating)) then
--
if g_debug then
  hr_utility.set_location(l_proc, 4);
end if;
  --
  open csr_pos_def;
  fetch csr_pos_def into l_exists;
  if csr_pos_def%notfound then
    hr_utility.set_message(800,'HR_51369_POS_DEF_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  close csr_pos_def;
--
end if;
if g_debug then
  hr_utility.set_location('Leaving '||l_proc, 5);
end if;
  --
end chk_position_definition_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_probation_info >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that if the PROBATION_PERIOD is null and PROBATION_PERIOD_UNITS
--    is not null or if PROBATION_PERIOD is not null and PROBATION_PERIOS_UNITS
--    is null then an error is raised
--
--    Validate the value for PROBATION_PERIOD_UNITS against the table
--    FND_COMMON_LOOKUPS where the LOOKUP_TYPE is 'QUALIFYING_UNITS'.
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_position_id
--    p_probation_period
--    p_probation_period_units
--    p_effective_date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_probation_info
  (p_position_id              in number default null
  ,p_Effective_date           in date
  ,p_probation_period      in number
  ,p_probation_period_unit_cd in varchar2
  ,p_object_version_number    in number default null) is
--
   l_proc   varchar2(72);
   l_api_updating     boolean;
   l_exists    varchar2(1);
--
   cursor csr_valid_unit is
     select 'x'
     from fnd_common_lookups
     where lookup_type = 'QUALIFYING_UNITS'
       and lookup_code = p_probation_period_unit_cd;
--
begin
if g_debug then
   l_proc      := g_package||'chk_probation_info';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The probation_period value has changed
  -- c) The probation_period_unit_cd value has changed
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id        => p_position_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
    (nvl(hr_psf_shd.g_old_rec.probation_period,hr_api.g_number) <>
    nvl(p_probation_period,hr_api.g_number)) or
    (nvl(hr_psf_shd.g_old_rec.probation_period_unit_cd,hr_api.g_varchar2) <>
    nvl(p_probation_period_unit_cd,hr_api.g_varchar2))) or
    (NOT l_api_updating)) then
    --
    --    Check for values consistency
    --
if g_debug then
    hr_utility.set_location(l_proc, 2);
end if;
    --
    if (p_probation_period is null and
        p_probation_period_unit_cd is not null) or
       (p_probation_period is not null and
       p_probation_period_unit_cd is null) then
       hr_utility.set_message(800,'HR_51365_POS_PROB_UNITS_REQ');
       hr_utility.raise_error;
    else
      --
      --    Validate probation_period_unit_cd against fnd_common_lookups
      --
if g_debug then
      hr_utility.set_location(l_proc, 3);
end if;
      --
      if p_probation_period is not null
           and p_probation_period_unit_cd is not null then
        open csr_valid_unit;
        fetch csr_valid_unit into l_exists;
        if csr_valid_unit%notfound then
          hr_utility.set_message(800,'HR_51366_POS_PROB_UNITS_INV');
          hr_utility.raise_error;
        end if;
     end if;
  end if;
end if;
    --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end if;
end chk_probation_info;
--
--
--  ---------------------------------------------------------------------------
--  |------------------<  chk_time_start_finish  >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that TIME_NORMAL_FINISH is not before TIME_NORMAL_START.
--
--    Selects TIME_NORMAL_START and TIME_NORMAL_FINISH from the corresponding
--    values on HR_ORGANIZATION_UNITS for the position's ORGANIZATION_ID when
--    the values are null. When organization defaults are not maintained, the
--    default values from the business group are used.
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_business_group_id
--    p_organization_id
--    p_position_id
--    p_time_normal_start
--    p_time_normal_finish
--    p_effective_date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_time_start_finish
  (p_position_id         in number default null
  ,p_effective_Date         in date
  ,p_time_normal_start      in varchar2
  ,p_time_normal_finish     in varchar2
  ,p_object_version_number  in number default null)   is
--
   l_exists            varchar2(1);
   l_proc              varchar2(72);
   l_time_normal_start    varchar2(5);
   l_time_normal_finish   varchar2(5);
   l_api_updating         boolean;
--
begin
if g_debug then
   l_proc   := g_package||'chk_time_start_finish';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The time_normal_start value has changed
  -- c) The time_normal_finish value has changed
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id        => p_position_id
    ,p_effective_Date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
     (nvl(hr_psf_shd.g_old_rec.time_normal_start,hr_api.g_varchar2) <>
     nvl(p_time_normal_start,hr_api.g_varchar2) or
     (nvl(hr_psf_shd.g_old_rec.time_normal_finish,hr_api.g_varchar2) <>
     nvl(p_time_normal_finish,hr_api.g_varchar2)))) or
     (NOT l_api_updating)) then
  --
    --    Check for values consistency
    --
if g_debug then
    hr_utility.set_location(l_proc, 4);
end if;
    --
    if (p_time_normal_start is not null and p_time_normal_finish is null) or
      (p_time_normal_start is null and p_time_normal_finish is not null) then
        hr_utility.set_message(800,'HR_51367_POS_TIMES_REQ');
        hr_utility.raise_error;
--
  elsif not (substr(p_time_normal_start,1,2) between '00' and '24'
        and substr(p_time_normal_start,4,2) between '00' and '59'
        and substr(p_time_normal_start,3,1) = ':') then
        hr_utility.set_message(800,'HR_51154_INVAL_TIME_FORMAT');
        hr_utility.raise_error;
--
   elsif not (substr(p_time_normal_finish,1,2) between '00' and '24'
        and substr(p_time_normal_finish,4,2) between '00' and '59'
        and substr(p_time_normal_finish,3,1) = ':') then
        hr_utility.set_message(800,'HR_51154_INVAL_TIME_FORMAT');
        hr_utility.raise_error;
end if;
/*
-- remove this check
    --
    --   Check that time_normal_start <= time_normal_finish
    --
if g_debug then
    hr_utility.set_location(l_proc, 5);
end if;
    --
    if p_time_normal_finish <= p_time_normal_start then
      hr_utility.set_message(801,'HR_51368_POS_FIN_GT_START');
      hr_utility.raise_error;
    end if;
*/
    --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 6);
end if;
end chk_time_start_finish;
/*
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_position_transaction_id >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_position_transaction_id
  (p_position_id              in hr_all_positions_f.position_id%TYPE
  ,p_position_transaction_id  in hr_all_positions_f.position_transaction_id%TYPE
  ,p_validation_start_date    in hr_all_positions_f.effective_start_date%TYPE
  ,p_validation_end_date      in hr_all_positions_f.effective_end_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in hr_all_positions_f.object_version_number%TYPE
  )
  is
--
   l_exists            varchar2(1);
   l_api_updating      boolean;
   l_business_group_id number(15);
   l_proc              varchar2(72) ;
--
   cursor csr_valid_tran is
   select  null
     from  pqh_position_transactions ptx
     where ptx.position_transaction_id = p_position_transaction_id;
--
begin
if g_debug then
   l_proc  := g_package||'chk_position_transaction_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position_transaction_id has changed
  --
  l_api_updating := hr_psf_shd.api_updating
        (p_position_id            => p_position_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  if ((l_api_updating and
       nvl(hr_psf_shd.g_old_rec.position_transaction_id, hr_api.g_number) <>
       nvl(p_position_transaction_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    if p_position_transaction_id is not null then
if g_debug then
      hr_utility.set_location(l_proc, 50);
end if;
      --
      -- Check that position_transaction_id exists in
      -- pqh_position_transactions
      --
      open csr_valid_tran;
      fetch csr_valid_tran into l_exists;
      if csr_valid_tran%notfound then
        close csr_valid_tran;
        hr_utility.set_message(800, 'HR_INV_POSN_TRAN');
        hr_utility.raise_error;
        --
      end if;
      close csr_valid_tran;
if g_debug then
      hr_utility.set_location(l_proc, 60);
    hr_utility.set_location(l_proc, 130);
  hr_utility.set_location(' Leaving:'|| l_proc, 140);
end if;
end chk_position_transaction_id;
*/
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_supervisor_position_id  >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--
--    Validates that if supervisor_position_id exists, it must be a valid
--    position for the business group and the successor DATE_END is on or after
--    the DATE_EFFECTIVE of the position.
--
--  Pre-conditions:
--
--  In Arguments :
--    p_position_id
--    p_business_group_id
--    p_supervisor_position_id
--    p_effective_date
--    p_validation_start_Date
--    p_validation_end_Date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ----------------------------------------------------------------------------
procedure chk_supervisor_position_id
  (p_business_group_id      in number
  ,p_position_id            in number default null
  ,p_supervisor_position_id  in number
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_effective_date      in date
  ,p_object_version_number  in number default null
  )   is
--
   l_exists           varchar2(1);
   l_proc   varchar2(72) ;
   l_api_updating     boolean;
--
cursor csr_valid_supervisor_position (p_validation_start_date date) is
select 'x'
from hr_all_positions_f psf, per_shared_types sht
where psf.position_id = p_supervisor_position_id
and psf.availability_status_id = sht.shared_type_id
and (sht.business_group_id = p_business_group_id
     or sht.business_group_id is null)
and sht.system_type_cd in ('ACTIVE','FROZEN')
and psf.business_group_id = p_business_group_id
and p_validation_start_date between psf.effective_start_date
                            and psf.effective_end_date ;
--
begin
if g_debug then
   l_proc    :=   g_package||'chk_supervisor_position_id';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The supervisor_position_id value has changed
  --
  if p_supervisor_position_id is not null then
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation start date'
      ,p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation end date'
      ,p_argument_value => p_validation_end_date);
    --
    l_api_updating := hr_psf_shd.api_updating
      (p_position_id          => p_position_id
      ,p_effective_date            => p_effective_date
      ,p_object_version_number     => p_object_version_number);
    --
    --
    --    Check for valid successor position id
    --
    if ((l_api_updating and
         hr_psf_shd.g_old_rec.supervisor_position_id <>
         p_supervisor_position_id) or
         (NOT l_api_updating)) then
      --
if g_debug then
      hr_utility.set_location(l_proc, 2);
end if;
      open csr_valid_supervisor_position(p_validation_start_date);
      fetch csr_valid_supervisor_position into l_exists;
      if csr_valid_supervisor_position%notfound then
        close csr_valid_supervisor_position;
        hr_utility.set_message(800,'HR_PSF_SUPER_NOT_EXIST');
        hr_utility.raise_error;
      else
        close csr_valid_supervisor_position;
        if(l_api_updating and p_position_id = p_supervisor_position_id) then
            hr_utility.set_message(800,'HR_PSF_SUPERVISOR_EQ_POS');
            hr_utility.raise_error;
        end if;
      end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 3);
end if;
end chk_supervisor_position_id;
--
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_prior_position_id  >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--
--    Validates that if prior_position_id exists, it must be a valid
--    position for the business group and the successor DATE_END is on or after
--    the DATE_EFFECTIVE of the position.
--
--  Pre-conditions:
--
--  In Arguments :
--    p_position_id
--    p_business_group_id
--    p_prior_position_id
--    p_effective_date
--    p_validation_start_Date
--    p_validation_end_Date
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ----------------------------------------------------------------------------
procedure chk_prior_position_id
  (p_business_group_id      in number
  ,p_position_id            in number default null
  ,p_prior_position_id  in number
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_effective_date      in date
  ,p_object_version_number  in number default null
  )   is
--
   l_exists           varchar2(1);
   l_proc   varchar2(72) ;
   l_api_updating     boolean;
--
cursor csr_valid_prior_position (p_validation_start_date date) is
select 'x'
from hr_all_positions_f psf, per_shared_types sht
where psf.position_id = p_prior_position_id
and psf.availability_status_id = sht.shared_type_id
and (sht.business_group_id = p_business_group_id
     or sht.business_group_id is null)
and sht.system_type_cd in ('ACTIVE','FROZEN')
and psf.business_group_id = p_business_group_id
and p_validation_start_date between psf.effective_start_date
                            and psf.effective_end_date ;
--
begin
if g_debug then
   l_proc    :=   g_package||'chk_prior_position_id';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The prior_position_id value has changed
  --
  if p_prior_position_id is not null then
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation start date'
      ,p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation end date'
      ,p_argument_value => p_validation_end_date);
    --
    l_api_updating := hr_psf_shd.api_updating
      (p_position_id          => p_position_id
      ,p_effective_date            => p_effective_date
      ,p_object_version_number     => p_object_version_number);
    --
    --
    --    Check for valid successor position id
    --
    if ((l_api_updating and
         hr_psf_shd.g_old_rec.prior_position_id <>
         p_prior_position_id) or
         (NOT l_api_updating)) then
      --
if g_debug then
      hr_utility.set_location(l_proc, 2);
end if;
      open csr_valid_prior_position(p_validation_start_date);
      fetch csr_valid_prior_position into l_exists;
      if csr_valid_prior_position%notfound then
        close csr_valid_prior_position;
        hr_utility.set_message(800,'HR_PSF_PRIOR_NOT_EXIST');
        hr_utility.raise_error;
      else
        close csr_valid_prior_position;
      end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 3);
end if;
end chk_prior_position_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_work_term_end_month_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id PK of record being inserted or updated.
--   work_term_end_month_cd   Value of lookup code.
--   effective_date           effective date
--   validation_start_date
--   validation_end_Date
--   date_effective
--   object_version_number    Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_work_term_end_month_cd
  (p_position_id             in number
  ,p_work_term_end_month_cd  in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
 l_proc       := g_package||'chk_work_term_end_month_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_work_term_end_month_cd
      <> nvl(hr_psf_shd.g_old_rec.work_term_end_month_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_work_term_end_month_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'MONTH_CODE'
          ,p_lookup_code           => p_work_term_end_month_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_work_term_end_month_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_work_term_end_day_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   work_term_end_day_cd          Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_work_term_end_day_cd
  (p_position_id             in number
  ,p_work_term_end_day_cd    in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_work_term_end_day_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_work_term_end_day_cd
      <> nvl(hr_psf_shd.g_old_rec.work_term_end_day_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_work_term_end_day_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'DAY_CODE'
          ,p_lookup_code           => p_work_term_end_day_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_work_term_end_day_cd;
--
-- ----------------------< chk_position_type > ------------------------
--
Procedure chk_position_type
  (p_position_id             in number
  ,p_position_type           in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
l_proc        := g_package||'chk_position_type';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'position type'
      ,p_argument_value => p_position_type);
    --
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation start date'
      ,p_argument_value => p_validation_start_date);
    --
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date);
    --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_position_type
      <> nvl(hr_psf_shd.g_old_rec.position_type,hr_api.g_varchar2)
      or not l_api_updating)
      and p_position_type is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'POSITION_TYPE'
          ,p_lookup_code           => p_position_type
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_position_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_work_period_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   work_period_type_cd          Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_work_period_type_cd
  (p_position_id             in number
  ,p_work_period_type_cd    in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_work_period_type_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_work_period_type_cd
      <> nvl(hr_psf_shd.g_old_rec.work_period_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_work_period_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'YES_NO'
          ,p_lookup_code           => p_work_period_type_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_work_period_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_works_council_approval_flg >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   works_council_approval_flag   Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_works_council_approval_flg
  (p_position_id             in number
  ,p_works_council_approval_flag    in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc     := g_package||'chk_works_council_approval_flg';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_works_council_approval_flag
      <> nvl(hr_psf_shd.g_old_rec.works_council_approval_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_works_council_approval_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'YES_NO'
          ,p_lookup_code           => p_works_council_approval_flag
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_works_council_approval_flg;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_term_start_month_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_term_start_month_cd   Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_term_start_month_cd
  (p_position_id             in number
  ,p_term_start_month_cd    in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
 l_proc          := g_package||'chk_term_start_month_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_term_start_month_cd
      <> nvl(hr_psf_shd.g_old_rec.term_start_month_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_term_start_month_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'MONTH_CODE'
          ,p_lookup_code           => p_term_start_month_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_term_start_month_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_term_start_day_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_term_start_day_cd   Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_term_start_day_cd
  (p_position_id             in number
  ,p_term_start_day_cd    in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc      := g_package||'chk_term_start_day_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_term_start_day_cd
      <> nvl(hr_psf_shd.g_old_rec.term_start_day_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_term_start_day_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'DAY_CODE'
          ,p_lookup_code           => p_term_start_day_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_term_start_day_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_seasonal_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_seasonal_flag               Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_seasonal_flag
  (p_position_id             in number
  ,p_seasonal_flag    in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_seasonal_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_seasonal_flag
      <> nvl(hr_psf_shd.g_old_rec.seasonal_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_seasonal_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'YES_NO'
          ,p_lookup_code           => p_seasonal_flag
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_seasonal_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_review_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_review_flag                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_review_flag
  (p_position_id             in number
  ,p_review_flag    in varchar2
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_object_version_number   in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc         := g_package||'chk_review_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_review_flag
      <> nvl(hr_psf_shd.g_old_rec.review_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_review_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'YES_NO'
          ,p_lookup_code           => p_review_flag
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_review_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_replacement_required_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_replacement_required_flag                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_replacement_required_flag
  (p_position_id               in number
  ,p_replacement_required_flag in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
l_proc       := g_package||'chk_replacement_required_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_replacement_required_flag
      <> nvl(hr_psf_shd.g_old_rec.replacement_required_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_replacement_required_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'YES_NO'
          ,p_lookup_code           => p_replacement_required_flag
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_replacement_required_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_probation_period_unit_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_probation_period_unit_cd                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_probation_period_unit_cd
  (p_position_id               in number
  ,p_probation_period_unit_cd in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc   := g_package||'chk_probation_period_unit_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_probation_period_unit_cd
      <> nvl(hr_psf_shd.g_old_rec.probation_period_unit_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_probation_period_unit_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'FREQUENCY'
          ,p_lookup_code           => p_probation_period_unit_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_probation_period_unit_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_permit_recruitment_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_permit_recruitment_flag                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_permit_recruitment_flag
  (p_position_id               in number
  ,p_permit_recruitment_flag   in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc         := g_package||'chk_permit_recruitment_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_permit_recruitment_flag
      <> nvl(hr_psf_shd.g_old_rec.permit_recruitment_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_permit_recruitment_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'YES_NO'
          ,p_lookup_code           => p_permit_recruitment_flag
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_permit_recruitment_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_permanent_temporary_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   permanent_temporary_flag                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_permanent_temporary_flag
  (p_position_id               in number
  ,p_permanent_temporary_flag   in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_permanent_temporary_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_permanent_temporary_flag
      <> nvl(hr_psf_shd.g_old_rec.permanent_temporary_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_permanent_temporary_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'YES_NO'
          ,p_lookup_code           => p_permanent_temporary_flag
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_permanent_temporary_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pay_term_end_month_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   pay_term_end_month_cd                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_pay_term_end_month_cd
  (p_position_id               in number
  ,p_pay_term_end_month_cd   in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_pay_term_end_month_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_pay_term_end_month_cd
      <> nvl(hr_psf_shd.g_old_rec.pay_term_end_month_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pay_term_end_month_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'MONTH_CODE'
          ,p_lookup_code           => p_pay_term_end_month_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_pay_term_end_month_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pay_term_end_day_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   pay_term_end_day_cd                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_pay_term_end_day_cd
  (p_position_id               in number
  ,p_pay_term_end_day_cd   in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_pay_term_end_day_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_pay_term_end_day_cd
      <> nvl(hr_psf_shd.g_old_rec.pay_term_end_day_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pay_term_end_day_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'DAY_CODE'
          ,p_lookup_code           => p_pay_term_end_day_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_pay_term_end_day_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_overlap_unit_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   overlap_unit_cd                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_overlap_unit_cd
  (p_position_id               in number
  ,p_overlap_unit_cd   in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_overlap_unit_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_overlap_unit_cd
      <> nvl(hr_psf_shd.g_old_rec.overlap_unit_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_overlap_unit_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'FREQUENCY'
          ,p_lookup_code           => p_overlap_unit_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_overlap_unit_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_bargaining_unit_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   bargaining_unit_cd                 Value of lookup code.
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_bargaining_unit_cd
  (p_position_id               in number
  ,p_bargaining_unit_cd   in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_bargaining_unit_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_bargaining_unit_cd
      <> nvl(hr_psf_shd.g_old_rec.bargaining_unit_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bargaining_unit_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_dt_hr_lookups
          (p_lookup_type           => 'BARGAINING_UNIT_CODE'
          ,p_lookup_code           => p_bargaining_unit_cd
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_effective_date        => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_bargaining_unit_cd;
--
-- ------------------ <chk_fte> ---------------------
--
Procedure chk_fte
  (p_position_id               in number
  ,p_fte                       in number
  ,p_position_type             in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
 l_proc          := g_package||'chk_fte';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'position type'
      ,p_argument_value => p_position_type);
    --
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation start date'
      ,p_argument_value => p_validation_start_date);
    --
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date);
    --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating
      and ((p_fte <> nvl(hr_psf_shd.g_old_rec.fte,hr_api.g_number))
         or (p_position_type <> nvl(hr_psf_shd.g_old_rec.position_type,
                     hr_api.g_varchar2))))
      or not l_api_updating) then
      --
      if p_position_type <> 'NONE' then
        if ( p_fte is null and p_position_type <> 'POOLED') then
          hr_utility.set_message(800,'HR_FTE_NULL_INV_FOR_POS_TYPE');
          hr_utility.raise_error;
        elsif p_position_type = 'SINGLE' then
          if not (p_fte <= 1) then
            hr_utility.set_message(800,'HR_FTE_MUST_BE_LESS_OR_EQ_ONE');
            hr_utility.raise_error;
          end if;
        end if;
      end if;
      --
  end if;
  --
end chk_fte;
--
-- ------------------ <chk_max_persons> ---------------------
--
Procedure chk_max_persons
  (p_position_id               in number
  ,p_max_persons               in number
  ,p_position_type             in varchar2
  ,p_effective_date            in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
 l_proc          := g_package||'p_max_persons';
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Entering:'||p_max_persons, 2);

hr_utility.set_location('Entering:'||
     nvl(hr_psf_shd.g_old_rec.max_persons,hr_api.g_number),3);
end if;
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'position type'
      ,p_argument_value => p_position_type);
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date);
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating
    and ((nvl(p_max_persons,hr_api.g_number) <>
       nvl(hr_psf_shd.g_old_rec.max_persons,hr_api.g_number))
         or (p_position_type <> nvl(hr_psf_shd.g_old_rec.position_type,
                     hr_api.g_varchar2))))
      or not l_api_updating) then
      --
      if (p_position_type = 'SINGLE')
        and ((p_max_persons is NULL) or (p_max_persons <> 1 )) then
          hr_utility.set_message(800,'HR_POS_MAX_PERSONS_NE_ONE');
          hr_utility.raise_error;
      elsif (p_position_type = 'SHARED') and (p_max_persons IS NULL )
       then
          hr_utility.set_message(800,'HR_MAX_PERS_NULL_INV_POS_TYPE');
          hr_utility.raise_error;
      elsif (p_position_type = 'SHARED') and (p_max_persons < 1 )
       then
          hr_utility.set_message(800,'PER_INVALID_SHARED_MAX_PERSON');
          hr_utility.raise_error;
      end if;
      --
  end if;
  --
end chk_max_persons;
--
-- ---------------------------------------------------------------------------
-- --------------------------< chk_resesrved_fte >----------------------------
-- ---------------------------------------------------------------------------

Procedure chk_reserved_fte
  (p_position_id               in number
  ,p_fte                       in number
  ,p_position_type             in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is

  l_proc         varchar2(72) ;
  l_api_updating boolean;
  l_rsv_fte   number;

-- Cursor changed for Bug 8912106
cursor csr_valid_fte(p_position_id number, p_effective_date date) is
select sum(poei_information6) fte
from (SELECT poei_information6, poei_information3, poei_information4, ROWNUM rn FROM per_position_extra_info
where position_id = p_position_id
and information_type= 'PER_RESERVED') PEI
where p_effective_date
  between fnd_date.canonical_to_date(poei_information3)
  and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time);
  --
cursor csr_valid_eff_date(p_position_id number,
                          p_validation_start_date date,
                          p_validation_end_date date) is
select p_validation_start_date start_date
from dual
union
select effective_start_date start_date
from hr_all_positions_f
where effective_start_date between p_validation_start_date
and p_validation_end_date
and position_id = p_position_id
union
select start_date
from (select fnd_date.canonical_to_date(poei_information3) start_date
      from per_position_extra_info
      where position_id = p_position_id
      and information_type = 'PER_RESERVED') a
where a.start_date between p_validation_start_date and p_validation_end_date;
Begin
  --
if g_debug then
  l_proc       := 'chk_reserved_fte';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'position type'
      ,p_argument_value => p_position_type);
    --
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation start date'      ,p_argument_value => p_validation_start_date);
    --
  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date);
    --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --

  if (l_api_updating
      and p_fte
      <> nvl(hr_psf_shd.g_old_rec.fte,hr_api.g_number)
      ) then
      --
    for r2 in csr_valid_eff_date(p_position_id, p_validation_start_date, p_validation_end_date) loop
    if p_position_type ='SHARED' or p_position_type ='SINGLE' then
        open csr_valid_fte(p_position_id, r2.start_date);
         fetch csr_valid_fte into l_rsv_fte;
         if (p_fte < l_rsv_fte) then
            hr_utility.set_message(800,'PER_FTE_LT_RSVD_FTE');
            hr_utility.set_message_token('POSITION_FTE',p_fte);
            hr_utility.set_message_token('RESERVED_FTE',l_rsv_fte);
            hr_utility.set_message_token('EFFECTIVE_DATE',r2.start_date);
            hr_utility.raise_error;
         else
if g_debug then
            hr_utility.set_location(l_proc, 3);
end if;
         end if;
      --
       close csr_valid_fte;
    end if;
    end loop;
  end if;
  --
end chk_reserved_fte;

-- ---------------------------------------------------------------------------
-- --------------------------< chk_proposed_fte_for_layoff >------------------
-- ---------------------------------------------------------------------------
Procedure chk_proposed_fte_for_layoff
( p_fte                      in number
 ,p_proposed_fte_for_layoff  in number
 ,p_proposed_date_for_layoff in date) is

 --
 l_proc    varchar2(30);
Begin
  --
if g_debug then
 l_proc    :='chk_proposed_fte_for_layoff';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  if p_proposed_fte_for_layoff is not null then
    if nvl(p_fte, 0) < p_proposed_fte_for_layoff then
      --
       hr_utility.set_message(800,'HR_FTE_TARGT_LT_LAYOFF_FTE');
       hr_utility.raise_error;
    end if;
    if p_proposed_date_for_layoff is null then
      --
       hr_utility.set_message(800,'HR_PROP_DT_LAYOFF_CANNOT_NULL');
       hr_utility.raise_error;
    end if;
  else
    if p_proposed_date_for_layoff is not null then
      --
       hr_utility.set_message(800,'HR_PROP_DT_LAYOFF_MUSTBE_NULL');
       hr_utility.raise_error;
    end if;
  end if;
end chk_proposed_fte_for_layoff;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_extended_pay >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_extended_pay
  (p_position_id               in number
  ,p_work_period_type_cd       in varchar2
  ,p_term_start_day_cd         in varchar2
  ,p_term_start_month_cd       in varchar2
  ,p_pay_term_end_day_cd       in varchar2
  ,p_pay_term_end_month_cd     in varchar2
  ,p_work_term_end_day_cd      in varchar2
  ,p_work_term_end_month_cd    in varchar2 ) is
  --
  l_proc varchar2(30);
Begin
  --
if g_debug then
l_proc :='chk_extended_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  if p_work_period_type_cd = 'Y' then
/*
    if p_pay_term_end_day_cd is null    or
       p_pay_term_end_month_cd is null  or
       p_work_term_end_day_cd is null   or
       p_work_term_end_month_cd is null     then
      --
       hr_utility.set_message(800,'HR_PAY_WORK_TERM_MUST_BE_ENTR');
       hr_utility.raise_error;
*/
    if (( (p_pay_term_end_day_cd is null and
          p_pay_term_end_month_cd is not null)  or
         (p_pay_term_end_day_cd is not null and
          p_pay_term_end_month_cd is null)) or
       ( (p_term_start_day_cd is null and
          p_term_start_month_cd is not null)  or
         (p_term_start_day_cd is not null and
          p_term_start_month_cd is null))) then
      --
       hr_utility.set_message(800,'HR_INVALID_PAY_TERM');
       hr_utility.raise_error;
    end if;
    if ( (p_work_term_end_day_cd is null and
          p_work_term_end_month_cd is not null)  or
         (p_work_term_end_day_cd is not null and
          p_work_term_end_month_cd is null)) then
      --
       hr_utility.set_message(800,'HR_INVALID_WORK_TERM');
       hr_utility.raise_error;
    end if;
  else
    if p_pay_term_end_day_cd is not null    or
       p_pay_term_end_month_cd is not null  or
       p_term_start_day_cd is not null    or
       p_term_start_month_cd is not null  or
       p_work_term_end_day_cd is not null   or
       p_work_term_end_month_cd is not null     then
      --
       hr_utility.set_message(800,'HR_PAY_WORK_TERM_MUST_BE_NULL');
       hr_utility.raise_error;
    end if;
  end if;
  --
end chk_extended_pay;
-- ----------------------------------------------------------------------------
-- |--------------------------<  chk_seasonal_poi  >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_seasonal_poi
(p_position_id              in number
  ,p_seasonal_flag          in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
l_dummy             varchar2(1);
l_api_updating     boolean;

cursor c_seasonal is
select 'X'
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_SEASONAL';
begin
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);

  if (l_api_updating
      and p_seasonal_flag
      <> nvl(hr_psf_shd.g_old_rec.seasonal_flag,hr_api.g_varchar2)
      and (p_seasonal_flag='N' or p_seasonal_flag is null)) then
    open c_seasonal;
    fetch c_seasonal into l_dummy;
    if c_seasonal%found then
          close c_seasonal;
          hr_utility.set_message(800,'HR_INV_SEASONAL_FLAG');
          hr_utility.raise_error;
    end if;
    close c_seasonal;
  end if;
end;
-- ----------------------------------------------------------------------------
-- |--------------------------<   chk_overlap_poi  >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_overlap_poi
(p_position_id              in number
  ,p_overlap_period         in number
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number) is
l_proc varchar2(100) ;
l_dummy             varchar2(1);
l_api_updating     boolean;
--
cursor c_overlap is
select 'X'
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_OVERLAP';
begin
if g_debug then
l_proc  :='chk_overlap_poi';
  hr_utility.set_location('Entering:'||l_proc,10);
end if;
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);

  if (l_api_updating
      and nvl(p_overlap_period,-1)
      <> nvl(hr_psf_shd.g_old_rec.overlap_period,hr_api.g_number)
      and p_overlap_period is null) then
if g_debug then
    hr_utility.set_location('Checking for Overlap Dates in Position Extra Info:'||l_proc,20);
end if;
    open c_overlap;
    fetch c_overlap into l_dummy;
if g_debug then
    hr_utility.set_location('Checked for Overlap Dates in Position Extra Info:'||l_proc,30);
end if;
    if c_overlap%found then
if g_debug then
    hr_utility.set_location('Overlap Dates Found in Position Extra Info:'||l_proc,40);
end if;
          close c_overlap;
          hr_utility.set_message(800,'HR_INV_OVERLAP_PERIOD');
          hr_utility.raise_error;
    end if;
if g_debug then
    hr_utility.set_location('Overlap Dates not Found in Position Extra Info:'||l_proc,40);
end if;
    close c_overlap;
  end if;
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,20);
end if;
end;
-- ----------------------------------------------------------------------------
-- |--------------------------< permit_extended_pay >-------------------------|
-- ----------------------------------------------------------------------------
function permit_extended_pay(p_position_id varchar2) return boolean is
l_proc varchar2(100) ;
l_position_family   varchar2(100);
l_chk               boolean := false;
cursor c1 is
select poei_information3
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_FAMILY'
and poei_information3 in ('ACADEMIC','FACULTY');
begin
if g_debug then
l_proc  :='PERMIT_EXTENDED_PAY';
  hr_utility.set_location('Entering:'||l_proc,10);
end if;
  if p_position_id is not null then
    open c1;
    fetch c1 into l_position_family;
    if c1%found then
if g_debug then
      hr_utility.set_location('Academic/Faculty Position Extra info Found:'||l_proc,10);
end if;
      close c1;
      return true;
    else
      close c1;
if g_debug then
      hr_utility.set_location('Academic/Faculty Position Extra info not Found:'||l_proc,10);
end if;
      return false;
    end if;
  else
    return(false);
  end if;
if g_debug then
    hr_utility.set_location('Leaving:'||l_proc,20);
end if;
end;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_extended_pay_permit >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_extended_pay_permit
(p_position_id           in number
  ,p_work_period_type_cd       in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ,p_object_version_number     in number
) is
l_proc         varchar2(100);
l_api_updating    boolean;
l_permit_extended_pay   boolean;
begin
if g_debug then
l_proc   :='chk_extended_pay_permit';
    hr_utility.set_location('Entering:'||l_proc,10);
end if;
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);

  if (((l_api_updating and p_work_period_type_cd
      <> nvl(hr_psf_shd.g_old_rec.work_period_type_cd,hr_api.g_varchar2)) or not l_api_updating)
      and nvl(p_WORK_PERIOD_TYPE_CD,'N') = 'Y') then
if g_debug then
    hr_utility.set_location('Check permit_extended_pay:'||l_proc,10);
end if;
    l_permit_extended_pay := permit_extended_pay(p_position_id => p_position_id);
if g_debug then
        hr_utility.set_location('Checking permit_extended_pay complete:'||l_proc,10);
end if;
    if (l_permit_extended_pay = false)  then
      --Position family is neither Academic nor Faculty, so Extended pay cannot be permitted.
      hr_utility.set_message(800,'HR_INV_EXTD_PAY_PERMIT');
      hr_utility.raise_error;
    end if;
  end if;
if g_debug then
    hr_utility.set_location('Leaving:'||l_proc,20);
end if;
end;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_position_type_single >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check for invalid uptation os position type
--    to Single.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   position_id                   PK of record being inserted or updated.
--   p_position_type
--   validation_start_date
--   validation_end_Date
--   date_effective
--   effective_date                effective date
--   object_version_number         Object version number of record being
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_position_type_single
  (p_position_id               in number
  ,p_position_type             in varchar2
  ,p_effective_date            in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  l_no_assignments  number;
  --
  cursor c_no_assignments(p_position_id number, p_effective_date date) is
  select count(1)
  from per_all_assignments_f asg, per_assignment_status_types ast
  where asg.position_id = p_position_id
  and p_effective_date between asg.effective_start_date and asg.effective_end_date
  and asg.assignment_type in ('E', 'C')
  and asg.assignment_status_type_id = ast.assignment_status_type_id
  and ast.per_system_status <> 'TERM_ASSIGN';
  --
Begin
  --
if g_debug then
  l_proc         := g_package||'chk_position_type_single';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_position_type
      <> nvl(hr_psf_shd.g_old_rec.position_type,hr_api.g_varchar2))
  then
    --
    -- check if value of lookup falls within lookup type.
    --
    if ((p_position_type = 'SINGLE')
        and (nvl(hr_psf_shd.g_old_rec.position_type,hr_api.g_varchar2)
        <> 'SINGLE' )) then
      open c_no_assignments(p_position_id, p_effective_date);
      fetch c_no_assignments into l_no_assignments;
      close c_no_assignments;
      if l_no_assignments > 1 then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_message(800,'PER_CANNOT_CHG_POS_SINGLE');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_position_type_single;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_relief_position_id            in number default hr_api.g_number,
             p_successor_position_id         in number default hr_api.g_number,
             p_supervisor_position_id        in number default hr_api.g_number,
             p_pay_freq_payroll_id           in number default hr_api.g_number,
             p_entry_grade_rule_id           in number default hr_api.g_number,
             p_entry_step_id                 in number default hr_api.g_number,
             p_datetrack_mode                in varchar2,
             p_validation_start_date         in date,
             p_validation_end_date           in date) Is
--
  l_proc     varchar2(72) ;
  l_integrity_error Exception;
  l_table_name     all_tables.table_name%TYPE;
--
Begin
if g_debug then
  l_proc   := g_package||'dt_update_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
-- ##
if g_debug then
    hr_utility.set_location(l_proc,20 );
end if;
    If ((nvl(p_relief_position_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'hr_all_positions_f',
             p_base_key_column => 'position_id',
             p_base_key_value  => p_relief_position_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'all positions';
      Raise l_integrity_error;
    End If;
if g_debug then
    hr_utility.set_location(l_proc,30 );
end if;
    If ((nvl(p_successor_position_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'hr_all_positions_f',
             p_base_key_column => 'position_id',
             p_base_key_value  => p_successor_position_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'all positions';
      Raise l_integrity_error;
    End If;
if g_debug then
    hr_utility.set_location(l_proc,40 );
end if;
    If ((nvl(p_supervisor_position_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'hr_all_positions_f',
             p_base_key_column => 'position_id',
             p_base_key_value  => p_supervisor_position_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'all positions';
      Raise l_integrity_error;
    End If;
if g_debug then
    hr_utility.set_location(l_proc,50 );
end if;
    If ((nvl(p_pay_freq_payroll_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_all_payrolls_f',
             p_base_key_column => 'payroll_id',
             p_base_key_value  => p_pay_freq_payroll_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'all payrolls';
      Raise l_integrity_error;
    End If;
if g_debug then
    hr_utility.set_location(l_proc,60 );
end if;
    If ((nvl(p_entry_step_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_spinal_point_steps_f',
             p_base_key_column => 'step_id',
             p_base_key_value  => p_entry_step_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'spinal point steps';
      Raise l_integrity_error;
    End If;
if g_debug then
    hr_utility.set_location(l_proc,70 );
end if;
    If ((nvl(p_entry_grade_rule_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_grade_rules_f',
             p_base_key_column => 'grade_rule_id',
             p_base_key_value  => p_entry_grade_rule_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'grade rules';
      Raise l_integrity_error;
    End If;
-- ##
    --
  End If;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(800, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_position_id     in number,
             p_datetrack_mode     in varchar2,
             p_validation_start_date in date,
             p_validation_end_date   in date) Is
--
  l_proc varchar2(72) ;
  l_rows_exist Exception;
  l_table_name all_tables.table_name%TYPE;
--
Begin
if g_debug then
 l_proc     := g_package||'dt_delete_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'position_id',
       p_argument_value => p_position_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'hr_all_positions_f',
           p_base_key_column => 'relief_position_id',
           p_base_key_value  => p_position_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'all positions';
      Raise l_rows_exist;
    End If;

    If (dt_api.rows_exist
          (p_base_table_name => 'hr_all_positions_f',
           p_base_key_column => 'supervisor_position_id',
           p_base_key_value  => p_position_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'all positions';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'hr_all_positions_f',
           p_base_key_column => 'successor_position_id',
           p_base_key_value  => p_position_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'all positions';
      Raise l_rows_exist;
    End If;
/*
    If (dt_api.rows_exist
          (p_base_table_name => 'hr_all_positions_f',
           p_base_key_column => 'prior_position_id',
           p_base_key_value  => p_position_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'all positions';
      Raise l_rows_exist;
    End If;
*/
    --
    -- Bug 3199913
    -- Removed refernce to 'per_all_assignments_f' since assignment and position
    -- do not have parent-child relationship.
    -- Removed refernce to 'pay_element_links_f' since assignment and position
    -- do not have parent-child relationship.
    --
  End If;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(800, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
Procedure chk_proposed_status
  (p_position_id               in number
  ,p_availability_status_id    in varchar2
  ,p_business_group_id         in varchar2
  ,p_effective_date             in date
  ,p_validate_start_date       in date
  ,p_validate_end_date         in date
  ,p_object_version_number     in number
  ,p_datetrack_mode              in varchar2) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  l_count       number;
  --
  cursor c1 is
  select count(*)
  from per_all_assignments_f
  where position_id = p_position_id
  and effective_start_date between p_validate_start_date and p_validate_end_date;
  --
  --
Begin
  --
if g_debug then
  l_proc         := g_package||'chk_proposed_status';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
if g_debug then
    hr_utility.set_location('datetrack mode:'||p_datetrack_mode, 5);
end if;
 if p_datetrack_mode = 'CORRECTION' then
  if (l_api_updating
      and p_availability_status_id
      <> nvl(hr_psf_shd.g_old_rec.availability_status_id,hr_api.g_number))
  then
if g_debug then
    hr_utility.set_location('Availability_status id:'||p_availability_status_id, 5);
    hr_utility.set_location('position id:'||p_position_id, 5);
  hr_utility.set_location('get avail '||hr_psf_shd.get_availability_status(p_availability_status_id,p_business_group_id),6);
end if;
    if hr_psf_shd.get_availability_status(p_availability_status_id,p_business_group_id) = 'PROPOSED' then
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
      open c1;
      fetch c1 into l_count;
      close c1;
      if l_count >0 then
        hr_utility.set_message(800, 'HR_ASG_EXISTS_CANT_CHG_PROP');
        hr_utility.raise_error;
      end if;
    end if;
   end if;
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_proposed_status;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date        in date,
    p_datetrack_mode        in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) ;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'insert_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
--
if g_debug then
hr_utility.set_location(l_proc, 6);
end if;
--
-- Validate date effective and date_end
--
chk_dates
  (p_date_effective        => p_rec.date_effective
  ,p_date_end              => p_rec.date_end
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_effective_Date        => p_effective_date
  ,p_object_version_number => p_rec.object_version_number
);
--
if g_debug then
hr_utility.set_location(l_proc, 50);
end if;
--
-- validate end dates
chk_end_dates
(position_id                => p_rec.position_id
,availability_status_id     => p_rec.availability_status_id
,p_effective_date           => p_effective_date
,current_org_prop_end_date  => p_rec.current_org_prop_end_date
,current_job_prop_end_date  => p_rec.current_job_prop_end_date
,avail_status_prop_end_date => p_rec.avail_status_prop_end_date
,earliest_hire_date         => p_rec.earliest_hire_date
,fill_by_date               => p_rec.fill_by_date
,proposed_date_for_layoff   => p_rec.proposed_date_for_layoff
,date_effective             => p_rec.date_effective );
--
-- Validate job id
--
if g_debug then
hr_utility.set_location(l_proc, 100);
end if;
chk_job_id
    (p_job_id          => p_rec.job_id
    ,p_business_group_id     => p_rec.business_group_id
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    ,p_effective_Date        => p_effective_date
    ,p_object_version_number => p_rec.object_version_number
);
--
if g_debug then
hr_utility.set_location(l_proc, 110);
end if;
--
-- Validate organization id
--
chk_organization_id
  ( p_organization_id       =>  p_rec.organization_id
   ,p_business_group_id     =>  p_rec.business_group_id
   ,p_validation_start_date =>  p_validation_start_date
   ,p_validation_end_date   =>  p_validation_end_date
   ,p_effective_Date        =>  p_effective_date
   ,p_object_version_number =>  p_rec.object_version_number
);
--
if g_debug then
hr_utility.set_location(l_proc, 120);
end if;
--
-- Validate successor position id
--
chk_successor_position_id
  (p_business_group_id     =>  p_rec.business_group_id
  ,p_position_id           =>  null
  ,p_successor_position_id =>  p_rec.successor_position_id
  ,p_validation_start_date =>  p_validation_start_date
  ,p_validation_end_date   =>  p_validation_end_date
  ,p_effective_date        =>  p_effective_date
  ,p_object_version_number =>  p_rec.object_version_number
);
if g_debug then
hr_utility.set_location(l_proc, 130);
end if;
--
-- Validate relief position id
--
chk_relief_position_id
  (p_business_group_id     =>  p_rec.business_group_id
  ,p_relief_position_id    =>  p_rec.relief_position_id
  ,p_validation_start_date =>  p_validation_start_date
  ,p_validation_end_date   =>  p_validation_end_date
  ,p_effective_date     =>  p_effective_Date
);
--
if g_debug then
hr_utility.set_location(l_proc, 140);
end if;
--
-- Validate location_id
--
chk_location_id
  (p_location_id        => p_rec.location_id
  ,p_effective_Date        => p_effective_date
  ,p_validation_start_date => p_validation_start_Date
  ,p_validation_end_date   => p_validation_end_Date

);
--
if g_debug then
hr_utility.set_location(l_proc, 150);
end if;
--
-- Validate position definition id
--
chk_position_definition_id
  (p_position_definition_id   => p_rec.position_definition_id
  ,p_effective_Date           => p_effective_date
);
--
if g_debug then
hr_utility.set_location(l_proc, 160);
end if;
--
-- Validate working_hours and frequency
--
chk_hrs_frequency
  (p_working_hours     => p_rec.working_hours
  ,p_frequency      => p_rec.frequency
  ,p_effective_date       => p_effective_date
);
--
if g_debug then
hr_utility.set_location(l_proc, 170);
end if;
--
-- Validate probation period and probation_period_unit_cd
--
chk_probation_info
  (p_probation_period         => p_rec.probation_period
  ,p_probation_period_unit_cd => p_rec.probation_period_unit_cd
  ,p_effective_Date           => p_effective_date
);
--
if g_debug then
hr_utility.set_location('Entering:'||l_proc, 180);
end if;
--
-- Validate time normal start and time_normal_finish
--
chk_time_start_finish
  (p_time_normal_start    => p_rec.time_normal_start
  ,p_time_normal_finish   => p_rec.time_normal_finish
  ,p_effective_date       => p_effective_date
);
--
if g_debug then
hr_utility.set_location(l_proc, 200);
end if;
--
chk_entry_step_id
  (p_position_id              => p_rec.position_id
  ,p_entry_step_id            => p_rec.entry_step_id
  ,p_entry_grade_id           => p_rec.entry_grade_id
  ,p_business_group_id        => p_rec.business_group_id
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_effective_date           => p_effective_date
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 210);
end if;
  --
  chk_entry_grade_id
  (p_position_id              => p_rec.position_id
  ,p_business_group_id        => p_rec.business_group_id
  ,p_entry_grade_id           => p_rec.entry_grade_id
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 215);
end if;
  --
  chk_entry_grade_rule_id
  (p_position_id              => p_rec.position_id
  ,p_business_group_id        => p_rec.business_group_id
  ,p_entry_grade_rule_id      => p_rec.entry_grade_rule_id
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 220);
end if;
  --
  chk_work_term_end_month_cd
  (p_position_id              => p_rec.position_id
  ,p_work_term_end_month_cd   => p_rec.work_term_end_month_cd
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 230);
end if;
  --
  chk_work_term_end_day_cd
  (p_position_id           => p_rec.position_id
  ,p_work_term_end_day_cd  => p_rec.work_term_end_day_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 240);
end if;
  --
  chk_work_period_type_cd
  (p_position_id           => p_rec.position_id
  ,p_work_period_type_cd   => p_rec.work_period_type_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 250);
end if;
  --
  chk_works_council_approval_flg
  (p_position_id                 => p_rec.position_id
  ,p_works_council_approval_flag => p_rec.works_council_approval_flag
  ,p_effective_date              => p_effective_date
  ,p_validation_start_date       => p_validation_start_date
  ,p_validation_end_date         => p_validation_end_date
  ,p_object_version_number       => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 260);
end if;
  --
  chk_term_start_month_cd
  (p_position_id           => p_rec.position_id
  ,p_term_start_month_cd   => p_rec.term_start_month_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 270);
end if;
  --
  chk_term_start_day_cd
  (p_position_id           => p_rec.position_id
  ,p_term_start_day_cd     => p_rec.term_start_day_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 280);
end if;
  --
  chk_seasonal_flag
  (p_position_id           => p_rec.position_id
  ,p_seasonal_flag         => p_rec.seasonal_flag
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 290);
end if;
  --
  chk_review_flag
  (p_position_id           => p_rec.position_id
  ,p_review_flag           => p_rec.review_flag
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 300);
end if;
  --
  chk_replacement_required_flag
  (p_position_id               => p_rec.position_id
  ,p_replacement_required_flag => p_rec.replacement_required_flag
  ,p_effective_date            => p_effective_date
  ,p_validation_start_date     => p_validation_start_date
  ,p_validation_end_date       => p_validation_end_date
  ,p_object_version_number     => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 310);
end if;
  --
  chk_probation_period_unit_cd
  (p_position_id              => p_rec.position_id
  ,p_probation_period_unit_cd => p_rec.probation_period_unit_cd
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 320);
end if;
  --
  chk_permit_recruitment_flag
  (p_position_id             => p_rec.position_id
  ,p_permit_recruitment_flag => p_rec.permit_recruitment_flag
  ,p_effective_date          => p_effective_date
  ,p_validation_start_date   => p_validation_start_date
  ,p_validation_end_date     => p_validation_end_date
  ,p_object_version_number   => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 330);
end if;
  --
  chk_permanent_temporary_flag
  (p_position_id              => p_rec.position_id
  ,p_permanent_temporary_flag => p_rec.permanent_temporary_flag
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number);
  --
if g_debug then
   hr_utility.set_location(l_proc, 335);
 end if;
   --
 chk_permanent_seasonal_flag
   (p_position_id               => p_rec.position_id
   ,p_permanent_temporary_flag  => p_rec.permanent_temporary_flag
   ,p_seasonal_flag             => p_rec.seasonal_flag
   ,p_effective_date            => p_effective_date
   ,p_object_version_number     => p_rec.object_version_number);
   --

if g_debug then
  hr_utility.set_location(l_proc, 340);
end if;
  --
  chk_pay_term_end_month_cd
  (p_position_id           => p_rec.position_id
  ,p_pay_term_end_month_cd => p_rec.pay_term_end_month_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 350);
end if;
  --
  chk_pay_term_end_day_cd
  (p_position_id           => p_rec.position_id
  ,p_pay_term_end_day_cd   => p_rec.pay_term_end_day_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 360);
end if;
  --
  chk_overlap_unit_cd
  (p_position_id           => p_rec.position_id
  ,p_overlap_unit_cd       => p_rec.overlap_unit_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 370);
end if;
  --
  chk_bargaining_unit_cd
  (p_position_id           => p_rec.position_id
  ,p_bargaining_unit_cd    => p_rec.bargaining_unit_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 380);
end if;
  --
  chk_pay_freq_payroll_id
  (p_position_id           => p_rec.position_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_pay_freq_payroll_id   => p_rec.pay_freq_payroll_id
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_effective_date        => p_effective_Date
  ,p_datetrack_mode        => p_datetrack_mode
  ,p_object_version_number => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 390);
end if;
  --
/*
  chk_position_transaction_id
  (p_position_id              => p_rec.position_id
  ,p_position_transaction_id  => p_rec.position_transaction_id
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_effective_date           => p_effective_date
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
*/
 --
if g_debug then
  hr_utility.set_location(l_proc, 400);
end if;
  --
  chk_supervisor_position_id
  (p_business_group_id      => p_rec.business_group_id
  ,p_position_id            => p_rec.position_id
  ,p_supervisor_position_id => p_rec.supervisor_position_id
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date
  ,p_effective_date      => p_effective_date
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 410);
end if;
  --
  chk_prior_position_id
  (p_business_group_id      => p_rec.business_group_id
  ,p_position_id            => p_rec.position_id
  ,p_prior_position_id      => p_rec.prior_position_id
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date
  ,p_effective_date      => p_effective_date
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 420);
end if;
  --
  chk_availability_status_id
   (p_position_id            => p_rec.position_id
   ,p_validation_start_date  => p_validation_start_date
   ,p_availability_status_id => p_rec.availability_status_id
   ,p_old_avail_status_id    => hr_psf_shd.g_old_rec.availability_status_id
   ,p_effective_date         => p_effective_date
   ,p_date_effective         => p_rec.date_effective
   ,p_business_group_id      => p_rec.business_group_id
   ,p_object_version_number  => p_rec.object_version_number
   ,p_datetrack_mode         => p_datetrack_mode );
  --
if g_debug then
  hr_utility.set_location(l_proc, 430);
end if;
  --
  chk_position_type
  (p_position_id             => p_rec.position_id
  ,p_position_type           => p_rec.position_type
  ,p_effective_date          => p_effective_date
  ,p_validation_start_date   => p_validation_start_Date
  ,p_validation_end_date     => p_validation_end_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 440);
end if;
  --
  chk_fte
  (p_position_id               => p_rec.position_id
  ,p_fte                       => p_rec.fte
  ,p_position_type             => p_rec.position_type
  ,p_effective_date            => p_effective_date
  ,p_validation_start_date     => p_validation_start_date
  ,p_validation_end_date       => p_validation_end_Date
  ,p_object_version_number     => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 445);
end if;
  --
  chk_max_persons
  (p_position_id               => p_rec.position_id
  ,p_max_persons               => p_rec.max_persons
  ,p_position_type             => p_rec.position_type
  ,p_effective_date            => p_effective_date
  ,p_object_version_number     => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 450);
end if;
  --
  chk_extended_pay
  (p_position_id               => p_rec.position_id
  ,p_work_period_type_cd       => p_rec.work_period_type_cd
  ,p_term_start_day_cd         => p_rec.term_start_day_cd
  ,p_term_start_month_cd       => p_rec.term_start_month_cd
  ,p_pay_term_end_day_cd       => p_rec.pay_term_end_day_cd
  ,p_pay_term_end_month_cd     => p_rec.pay_term_end_month_cd
  ,p_work_term_end_day_cd      => p_rec.work_term_end_day_cd
  ,p_work_term_end_month_cd    => p_rec.work_term_end_month_cd
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 460);
end if;
  --
  chk_proposed_fte_for_layoff
  (p_fte                      => p_rec.fte
  ,p_proposed_fte_for_layoff  => p_rec.proposed_fte_for_layoff
  ,p_proposed_date_for_layoff => p_rec.proposed_Date_for_layoff
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 470);
end if;
  --
/*
chk_extended_pay_permit
(p_position_id            => p_rec.position_id
  ,p_work_period_type_cd        => p_rec.work_period_type_cd
  ,p_effective_date             => p_effective_date
  ,p_validation_start_date      => p_validation_start_Date
  ,p_validation_end_date        => p_validation_end_date
  ,p_object_version_number      => p_rec.object_version_number
);
if g_debug then
hr_utility.set_location(l_proc, 2000);
end if;
--
-- Validate status
--
chk_status
  (p_position_id            => p_rec.position_id
  ,p_effective_Date        =>  p_effective_date
  ,p_status                 => p_rec.status
  ,p_object_version_number  => p_rec.object_version_number
);
--
*/
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 210);
end if;
  --
  --
  -- Call developer descriptive flexfield validation routines
  --
  --hr_psf_bus.chk_ddf(p_rec => p_rec);
  --
  --
  --
  -- Call descriptive flexfield validation routines
  --
  hr_psf_bus.chk_df(p_rec => p_rec);
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 220);
end if;
  --
  -- PMFLETCH ** Not using this uniqueness chech anymore **
  -- Check position_name is unique for Business_group
  --
  --chk_name_unique_for_BG
  -- (p_business_group_id    => p_rec.business_group_id
  -- ,p_position_id          => p_rec.position_id
  -- ,p_effective_date       => p_effective_date
  -- ,p_name                 => p_rec.name
  -- ,p_object_version_number  => p_rec.object_version_number
  -- );
  --
  -- PMFLETCH Check position_definition_id is unique for business group
  --
  chk_ccid_unique_for_BG
    (p_business_group_id             => p_rec.business_group_id
    ,p_position_id                   => p_rec.position_id
    ,p_position_definition_id        => p_rec.position_definition_id
    ,p_validation_start_date         => p_validation_start_date
    ,p_validation_end_date           => p_validation_end_date
    ,p_effective_date                => p_effective_date
    ,p_object_version_number         => p_rec.object_version_number
    );
  --
  --
  -- Call to validate Position Control Business Rules
  --
  if (per_pqh_shr.position_control_enabled
      ( p_organization_id => p_rec.organization_id
      , p_effective_date  => p_effective_date
      ) = 'Y') then
    --
    if p_rec.position_transaction_id is null then
      hr_utility.set_message(800, 'PER_CANT_CRE_PC_POS_NO_TXN');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  per_pqh_shr.hr_psf_bus('INSERT_VALIDATE',p_rec
        ,p_effective_date
        ,p_validation_start_date
        ,p_validation_end_date
        ,p_datetrack_mode);
  --
  --End of Position Control Business Rules call
  --
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 230);
end if;
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) ;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc    := g_package||'update_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 100);
end if;
  -- Validate successor position id
  --
  chk_successor_position_id
    (p_business_group_id     => p_rec.business_group_id
    ,p_position_id           => p_rec.position_id
    ,p_successor_position_id => p_rec.successor_position_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 110);
end if;
  --
  -- Validate relief position id
  --
  chk_relief_position_id
    (p_business_group_id     => p_rec.business_group_id
    ,p_position_id           => p_rec.position_id
    ,p_relief_position_id    => p_rec.relief_position_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_effective_date        =>  p_effective_Date
    ,p_object_version_number => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 120);
end if;
  --
  -- Validate location_id
  --
  chk_location_id
    (p_position_id           => p_rec.position_id
    ,p_location_id        =>  p_rec.location_id
    ,p_effective_Date        => p_effective_date
    ,p_validation_start_date => p_validation_start_Date
    ,p_validation_end_date   => p_validation_end_Date
    ,p_object_version_number => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 130);
end if;
  --
  -- Validate working_hours and frequency
  --
  chk_hrs_frequency
    (p_position_id        => p_rec.position_id
    ,p_working_hours      => p_rec.working_hours
    ,p_frequency       => p_rec.frequency
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 140);
end if;
  --
  -- Validate probation period and probation_period_unit_cd
  --
  chk_probation_info
    (p_position_id              => p_rec.position_id
    ,p_probation_period         => p_rec.probation_period
    ,p_probation_period_unit_cd => p_rec.probation_period_unit_cd
    ,p_effective_Date           => p_effective_date
    ,p_object_version_number    => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 150);
end if;
  --
  -- Validate time normal start and time_normal_finish
  --
  chk_time_start_finish
    (p_position_id           => p_rec.position_id
    ,p_time_normal_start     => p_rec.time_normal_start
    ,p_time_normal_finish    => p_rec.time_normal_finish
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 160);
end if;
  --
  -- Validate position definition id
  --
  chk_position_definition_id
    (p_position_definition_id => p_rec.position_definition_id
    ,p_position_id              => p_rec.position_id
    ,p_effective_Date           => p_effective_date
    ,p_object_version_number    => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 165);
end if;
  --
  -- Validate working_hours and frequency
  --
  chk_hrs_frequency
  (p_position_id          => p_rec.position_id
  ,p_working_hours     => p_rec.working_hours
  ,p_frequency      => p_rec.frequency
  ,p_effective_date       => p_effective_date
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 170);
end if;
  --
  -- Validate probation period and probation_period_unit_cd
  --
  chk_probation_info
  (p_position_id              => p_rec.position_id
  ,p_probation_period         => p_rec.probation_period
  ,p_probation_period_unit_cd => p_rec.probation_period_unit_cd
  ,p_effective_Date           => p_effective_date
  );
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 180);
end if;
  --
  -- Validate time normal start and time_normal_finish
  --
  chk_time_start_finish
  (p_position_id          => p_rec.position_id
  ,p_time_normal_start    => p_rec.time_normal_start
  ,p_time_normal_finish   => p_rec.time_normal_finish
  ,p_effective_date       => p_effective_date
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 200);
end if;
  --
  chk_entry_step_id
  (p_position_id              => p_rec.position_id
  ,p_entry_step_id            => p_rec.entry_step_id
  ,p_entry_grade_id           => p_rec.entry_grade_id
  ,p_business_group_id        => p_rec.business_group_id
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_effective_date           => p_effective_date
  ,p_object_version_number    => p_rec.object_version_number
  );
if g_debug then
hr_utility.set_location(l_proc, 210);
end if;
chk_entry_grade_id
  (p_position_id              => p_rec.position_id
  ,p_business_group_id        => p_rec.business_group_id
  ,p_entry_grade_id           => p_rec.entry_grade_id
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 215);
end if;
  --
  chk_entry_grade_rule_id
  (p_position_id              => p_rec.position_id
  ,p_business_group_id        => p_rec.business_group_id
  ,p_entry_grade_rule_id      => p_rec.entry_grade_rule_id
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 220);
end if;
  --
  chk_work_term_end_month_cd
  (p_position_id            => p_rec.position_id
  ,p_work_term_end_month_cd => p_rec.work_term_end_month_cd
  ,p_effective_date         => p_effective_date
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date
  ,p_object_version_number  => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 230);
end if;
  --
  chk_work_term_end_day_cd
  (p_position_id           => p_rec.position_id
  ,p_work_term_end_day_cd  => p_rec.work_term_end_day_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 240);
end if;
  --
  chk_work_period_type_cd
  (p_position_id           => p_rec.position_id
  ,p_work_period_type_cd   => p_rec.work_period_type_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 250);
end if;
  --
  chk_works_council_approval_flg
  (p_position_id                 => p_rec.position_id
  ,p_works_council_approval_flag => p_rec.works_council_approval_flag
  ,p_effective_date              => p_effective_date
  ,p_validation_start_date       => p_validation_start_date
  ,p_validation_end_date         => p_validation_end_date
  ,p_object_version_number       => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 260);
end if;
  --
  chk_term_start_month_cd
  (p_position_id           => p_rec.position_id
  ,p_term_start_month_cd   => p_rec.term_start_month_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 270);
end if;
  --
  chk_term_start_day_cd
  (p_position_id           => p_rec.position_id
  ,p_term_start_day_cd     => p_rec.term_start_day_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 280);
end if;
  --
  chk_seasonal_flag
  (p_position_id           => p_rec.position_id
  ,p_seasonal_flag         => p_rec.seasonal_flag
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 290);
end if;
  --
  chk_review_flag
  (p_position_id           => p_rec.position_id
  ,p_review_flag           => p_rec.review_flag
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 300);
end if;
  --
  chk_replacement_required_flag
  (p_position_id               => p_rec.position_id
  ,p_replacement_required_flag => p_rec.replacement_required_flag
  ,p_effective_date            => p_effective_date
  ,p_validation_start_date     => p_validation_start_date
  ,p_validation_end_date       => p_validation_end_date
  ,p_object_version_number     => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 310);
end if;
  --
  chk_probation_period_unit_cd
  (p_position_id              => p_rec.position_id
  ,p_probation_period_unit_cd => p_rec.probation_period_unit_cd
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 320);
end if;
  --
  chk_permit_recruitment_flag
  (p_position_id             => p_rec.position_id
  ,p_permit_recruitment_flag => p_rec.permit_recruitment_flag
  ,p_effective_date          => p_effective_date
  ,p_validation_start_date   => p_validation_start_date
  ,p_validation_end_date     => p_validation_end_date
  ,p_object_version_number   => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 330);
end if;
  --
  chk_permanent_temporary_flag
  (p_position_id              => p_rec.position_id
  ,p_permanent_temporary_flag => p_rec.permanent_temporary_flag
  ,p_effective_date           => p_effective_date
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_object_version_number    => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 335);
end if;
--
-- for bug fix 5250975
chk_permanent_seasonal_flag
  (p_position_id               => p_rec.position_id
  ,p_permanent_temporary_flag  => p_rec.permanent_temporary_flag
  ,p_seasonal_flag             => p_rec.seasonal_flag
  ,p_effective_date            => p_effective_date
  ,p_object_version_number     => p_rec.object_version_number);
--

if g_debug then
  hr_utility.set_location(l_proc, 340);
end if;
  --
  chk_pay_term_end_month_cd
  (p_position_id           => p_rec.position_id
  ,p_pay_term_end_month_cd => p_rec.pay_term_end_month_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 350);
end if;
  --
  chk_pay_term_end_day_cd
  (p_position_id           => p_rec.position_id
  ,p_pay_term_end_day_cd   => p_rec.pay_term_end_day_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 360);
end if;
  --
  chk_overlap_unit_cd
  (p_position_id           => p_rec.position_id
  ,p_overlap_unit_cd       => p_rec.overlap_unit_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 370);
end if;
  --
  chk_bargaining_unit_cd
  (p_position_id           => p_rec.position_id
  ,p_bargaining_unit_cd    => p_rec.bargaining_unit_cd
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_object_version_number => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 380);
end if;
  --
  chk_pay_freq_payroll_id
  (p_position_id           => p_rec.position_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_pay_freq_payroll_id   => p_rec.pay_freq_payroll_id
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_effective_date        => p_effective_Date
  ,p_datetrack_mode        => p_datetrack_mode
  ,p_object_version_number => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 390);
end if;
  --
/*
  chk_position_transaction_id
  (p_position_id              => p_rec.position_id
  ,p_position_transaction_id  => p_rec.position_transaction_id
  ,p_validation_start_date    => p_validation_start_date
  ,p_validation_end_date      => p_validation_end_date
  ,p_effective_date           => p_effective_date
  ,p_object_version_number    => p_rec.object_version_number
  );
*/
  --
if g_debug then
  hr_utility.set_location(l_proc, 400);
end if;
  --
  chk_supervisor_position_id
  (p_business_group_id      => p_rec.business_group_id
  ,p_position_id            => p_rec.position_id
  ,p_supervisor_position_id => p_rec.supervisor_position_id
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date
  ,p_effective_date      => p_effective_date
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 410);
end if;
  --
  chk_prior_position_id
  (p_business_group_id      => p_rec.business_group_id
  ,p_position_id            => p_rec.position_id
  ,p_prior_position_id      => p_rec.prior_position_id
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date
  ,p_effective_date      => p_effective_date
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 420);
end if;
  --
  chk_availability_status_id
   (p_position_id            => p_rec.position_id
   ,p_validation_start_date  => p_validation_start_date
   ,p_availability_status_id => p_rec.availability_status_id
   ,p_old_avail_status_id    => hr_psf_shd.g_old_rec.availability_status_id
   ,p_effective_date         => p_effective_date
   ,p_date_effective         => p_rec.date_effective
   ,p_business_group_id      => p_rec.business_group_id
   ,p_object_version_number  => p_rec.object_version_number
   ,p_datetrack_mode         => p_datetrack_mode );
  --
if g_debug then
  hr_utility.set_location(l_proc, 430);
end if;
  --
  chk_position_type
  (p_position_id             => p_rec.position_id
  ,p_position_type           => p_rec.position_type
  ,p_effective_date          => p_effective_date
  ,p_validation_start_date   => p_validation_start_Date
  ,p_validation_end_date     => p_validation_end_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 440);
end if;
  --
  chk_fte
  (p_position_id               => p_rec.position_id
  ,p_fte                       => p_rec.fte
  ,p_position_type             => p_rec.position_type
  ,p_effective_date            => p_effective_date
  ,p_validation_start_date     => p_validation_start_date
  ,p_validation_end_date       => p_validation_end_Date
  ,p_object_version_number     => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 445);
end if;
  --
  chk_max_persons
  (p_position_id               => p_rec.position_id
  ,p_max_persons               => p_rec.max_persons
  ,p_position_type             => p_rec.position_type
  ,p_effective_date            => p_effective_date
  ,p_object_version_number     => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 450);
end if;
  --
  if (p_rec.position_transaction_id is null)  then
  chk_reserved_fte
  (p_position_id               => p_rec.position_id
  ,p_fte                       => p_rec.fte
  ,p_position_type             => p_rec.position_type
  ,p_effective_date            => p_effective_date
  ,p_validation_start_date     => p_validation_start_date
  ,p_validation_end_date       => p_validation_end_Date
  ,p_object_version_number     => p_rec.object_version_number);
  end if;
  --
if g_debug then
  hr_utility.set_location(l_proc, 455);
end if;
  --
  chk_extended_pay
  (p_position_id               => p_rec.position_id
  ,p_work_period_type_cd       => p_rec.work_period_type_cd
  ,p_term_start_day_cd         => p_rec.term_start_day_cd
  ,p_term_start_month_cd       => p_rec.term_start_month_cd
  ,p_pay_term_end_day_cd       => p_rec.pay_term_end_day_cd
  ,p_pay_term_end_month_cd     => p_rec.pay_term_end_month_cd
  ,p_work_term_end_day_cd      => p_rec.work_term_end_day_cd
  ,p_work_term_end_month_cd    => p_rec.work_term_end_month_cd
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 460);
end if;
  --
  chk_proposed_fte_for_layoff
  (p_fte                      => p_rec.fte
  ,p_proposed_fte_for_layoff  => p_rec.proposed_fte_for_layoff
  ,p_proposed_date_for_layoff => p_rec.proposed_Date_for_layoff
  );
  --
if g_debug then
  hr_utility.set_location(l_proc, 470);
end if;
  --
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_supervisor_position_id        => p_rec.supervisor_position_id,
     p_successor_position_id         => p_rec.successor_position_id,
     p_relief_position_id            => p_rec.relief_position_id,
     p_pay_freq_payroll_id           => p_rec.pay_freq_payroll_id,
     p_entry_grade_rule_id           => p_rec.entry_grade_rule_id,
     p_entry_step_id                 => p_rec.entry_step_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date       => p_validation_start_date,
     p_validation_end_date      => p_validation_end_date);
  --
  --
if g_debug then
  hr_utility.set_location(l_proc, 480);
end if;
  --
  --
  chk_proposed_status
  (p_position_id               =>p_rec.position_id
  ,p_availability_status_id    =>p_rec.availability_status_id
  ,p_business_group_id         =>p_rec.business_group_id
  ,p_effective_date            =>p_effective_date
  ,p_validate_start_date       =>p_validation_start_date
  ,p_validate_end_date         =>p_validation_end_date
  ,p_object_version_number     =>p_rec.object_version_number
  ,p_datetrack_mode            =>p_datetrack_mode);
  --
  -- Call all supporting business operations
  --
  --
if g_debug then
  hr_utility.set_location(l_proc, 490);
end if;
  --
  -- validate end dates
  chk_end_dates
  (position_id                => p_rec.position_id
  ,availability_status_id     => p_rec.availability_status_id
  ,p_effective_date           => p_effective_date
  ,current_org_prop_end_date  => p_rec.current_org_prop_end_date
  ,current_job_prop_end_date  => p_rec.current_job_prop_end_date
  ,avail_status_prop_end_date => p_rec.avail_status_prop_end_date
  ,earliest_hire_date         => p_rec.earliest_hire_date
  ,fill_by_date               => p_rec.fill_by_date
  ,proposed_date_for_layoff   => p_rec.proposed_date_for_layoff
  ,date_effective             => p_rec.date_effective );
  --
if g_debug then
  hr_utility.set_location(l_proc, 500);
end if;
  --
  -- Validate date effective
  --
  chk_dates
    (p_position_id            => p_rec.position_id
    ,p_date_effective      => p_rec.date_effective
    ,p_date_end            => p_rec.date_end
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    ,p_effective_Date        => p_effective_date
    ,p_object_version_number => p_rec.object_version_number
  );
  --
  --
  --
if g_debug then
  hr_utility.set_location(l_proc, 510);
end if;
  --
  chk_seasonal_poi
  (p_position_id     => p_rec.position_id
  ,p_seasonal_flag      => p_rec.seasonal_flag
  ,p_effective_date             => p_effective_date
  ,p_validation_start_date      => p_validation_start_Date
  ,p_validation_end_date        => p_validation_end_date
  ,p_object_version_number      => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 520);
end if;
  --
  chk_overlap_poi
  (p_position_id     => p_rec.position_id
  ,p_overlap_period     => p_rec.overlap_period
  ,p_effective_date             => p_effective_date
  ,p_validation_start_date      => p_validation_start_Date
  ,p_validation_end_date        => p_validation_end_date
  ,p_object_version_number      => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 530);
end if;
  --
/*
chk_extended_pay_permit
(p_position_id            => p_rec.position_id
  ,p_work_period_type_cd        => p_rec.work_period_type_cd
  ,p_effective_date             => p_effective_date
  ,p_validation_start_date      => p_validation_start_Date
  ,p_validation_end_date        => p_validation_end_date
  ,p_object_version_number      => p_rec.object_version_number
);
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 450);
end if;
  --
  -- Validate status
  --
  chk_status
    (p_position_id            => p_rec.position_id
    ,p_status                 => p_rec.status
    ,p_object_version_number  => p_rec.object_version_number
  );
*/
  --
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 600);
end if;
  --
  -- PMFLETCH ** Not using this uniqueness chech anymore **
  -- Check position_name is unique for Business_group
  --
  --chk_name_unique_for_BG
  -- (p_business_group_id    => p_rec.business_group_id
  -- ,p_position_id          => p_rec.position_id
  -- ,p_effective_date       => p_effective_date
  -- ,p_name                 => p_rec.name
  -- ,p_object_version_number  => p_rec.object_version_number
  -- );
  --
  -- PMFLETCH Check position_definition_id is unique for business group
  --
  chk_ccid_unique_for_BG
    (p_business_group_id             => p_rec.business_group_id
    ,p_position_id                   => p_rec.position_id
    ,p_position_definition_id        => p_rec.position_definition_id
    ,p_validation_start_date         => p_validation_start_date
    ,p_validation_end_date           => p_validation_end_date
    ,p_effective_date                => p_effective_date
    ,p_object_version_number         => p_rec.object_version_number
    );
  --
  --
if g_debug then
  hr_utility.set_location(l_proc, 610);
end if;
  --
  -- Check validation for position_type change to Single
  --
  chk_position_type_single
  (  p_position_id              => p_rec.position_id
    ,p_position_type            => p_rec.position_type
    ,p_effective_date           => p_effective_date
    ,p_object_version_number    => p_rec.object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 620);
end if;
  --
  --
  --
  -- Call developer descriptive flexfield validation routines
  --
  -- hr_psf_bus.chk_ddf(p_rec => p_rec);
  --
  --
if g_debug then
  hr_utility.set_location(l_proc, 630);
end if;
  --
  -- Call descriptive flexfield validation routines
  --
  hr_psf_bus.chk_df(p_rec => p_rec);
  --
  --
  -- Call to validate Position Control Business Rules
  --
  if (per_pqh_shr.position_control_enabled
                ( p_organization_id => p_rec.organization_id
                , p_effective_date  => p_effective_date
                ) = 'Y') then
    --
    if p_rec.position_transaction_id is null then
      hr_utility.set_message(800, 'PER_CANT_CRE_PC_POS_NO_TXN');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  per_pqh_shr.hr_psf_bus('UPDATE_VALIDATE',p_rec
    ,p_effective_date
    ,p_validation_start_date
    ,p_validation_end_date
    ,p_datetrack_mode);
  --
  --
  --End of Position Control Business Rules call
  --
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 700);
end if;
  --
End update_validate;
--
procedure delete_date_effective(p_position_id           in number
                               ,p_object_version_number in number
                               ,p_business_group_id     in number
                               ,p_datetrack_mode        in varchar2 ) is
 l_proc varchar2(72) ;
 l_next_stat varchar2(30);
 l_next_esd date;
 l_next_eed date;
 l_esd date;
 l_eed date;
 l_eot date := to_date('31/12/4712','dd/mm/yyyy');
-- fetches the next row info. given effective start date
 cursor next_row(p_effective_start_date date) is
    select effective_start_date,effective_end_date
           ,hr_psf_shd.get_availability_status(availability_status_id,p_business_group_id)
    from hr_all_positions_f
    where position_id = p_position_id
    and effective_start_date > p_effective_start_date
    order by effective_start_date ;
  cursor current_row is
    select effective_start_date,effective_end_date
    from hr_all_positions_f
    where position_id = p_position_id
    and object_version_number = p_object_version_number ;
  cursor pos_all is
    select date_effective
    from hr_all_positions_f
    where position_id = p_position_id
    for update of date_effective;
begin
if g_debug then
 l_proc  := g_package||'delete_date_effective ';
  hr_utility.set_location('entering '||l_proc,5);
end if;
  if p_datetrack_mode ='DELETE_NEXT_CHANGE' then
     open current_row ;
     fetch current_row into l_esd,l_eed ;
     close current_row ;
     -- effective start date of current row is fetched from the database
     -- that will be used to fetch the next row and its status
     if l_eed < l_eot then
if g_debug then
        hr_utility.set_location('first row fetched and next row there '||l_proc,15);
end if;
        open next_row(l_esd);
        fetch next_row into l_next_esd,l_next_eed,l_next_stat;
        if next_row%found then
      if l_next_eed <l_eot and l_next_stat = 'ACTIVE' then
if g_debug then
              hr_utility.set_location('next row active and next row there '||l_proc,25);
end if;
         fetch next_row into l_next_esd,l_next_eed,l_next_stat ;
         if l_next_stat = 'ACTIVE' then
       -- next to next row is active effective start date of that row will be
       -- made date effective for all the rows.
if g_debug then
                 hr_utility.set_location('next row active changing date effective '||l_proc,35);
end if;
       for i in pos_all loop
           update hr_all_positions_f
           set date_effective = l_next_esd
           where current of pos_all ;
       end loop;
         end if;
      end if;
        end if;
   close next_row;
     end if;
  end if;
if g_debug then
  hr_utility.set_location('Leaving '||l_proc,100);
end if;
end;
-- ----------------------------------------------------------------------------
-- |-------------------------< pre_delete_checks >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE pre_delete_checks(p_position_id        in  number
                           ,p_business_group_id  in  number
                           ,p_datetrack_mode  in  varchar2
                           ) is
 --
  l_exists                   varchar2(1);
  l_pos_structure_element_id number;
  l_sql_text                 VARCHAR2(2000);
  l_oci_out                  VARCHAR2(1);
  l_sql_cursor               NUMBER;
  l_rows_fetched             NUMBER;
  l_proc                  varchar2(72) ;

begin
if g_debug then
  l_proc                   := g_package||'pre_delete_checks';
 hr_utility.set_location('Entering : ' || l_proc, 10);
end if;
 if p_datetrack_mode = 'ZAP' then
if g_debug then
     hr_utility.set_location(l_proc, 20);
end if;
     l_exists := NULL;
--     if p_hr_ins = 'Y' then
         l_exists := NULL;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      from    PER_BUDGET_ELEMENTS BE
                      where   BE.POSITION_ID = p_position_id);
         exception when no_data_found then
                       null;
         end;
         if l_exists = '1' then
           hr_utility.set_message(801,'PER_7417_POS_ASSIGNMENT');
           hr_utility.raise_error;
         end if;
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 30);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      from    PER_ALL_VACANCIES VAC
                      where   VAC.POSITION_ID = p_position_id);
         exception when no_data_found then
                       null;
         end;
         if l_exists = '1' then
           hr_utility.set_message(801,'PER_7861_DEL_POS_REC_ACT');
           hr_utility.raise_error;
         end if;
if g_debug then
         hr_utility.set_location(l_proc, 40);
end if;
/**** Commented for Bug 9146790 **********
         begin
         select  e.pos_structure_element_id
         into    l_pos_structure_element_id
         from    per_pos_structure_elements e
         where   e.parent_position_id = p_position_id
         and     not exists (
                             select  null
         from    per_pos_structure_elements e2
         where   e2.subordinate_position_id = p_position_id)
         and     1 = (
                      select  count(e3.pos_structure_element_id)
                      from    per_pos_structure_elements e3
                      where   e3.parent_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
**** Commented for Bug 9146790 **********/
if g_debug then
         hr_utility.set_location(l_proc, 50);
end if;
         l_exists := NULL;
	-- if l_pos_structure_element_id is null then			-- condition removed (Bug 9146790)
            begin
            select '1'
            into l_exists
            from sys.dual
            where exists(SELECT  NULL
                      FROM   PER_POS_STRUCTURE_ELEMENTS PSE
                      WHERE  PSE.PARENT_POSITION_ID      = p_position_id
                      OR     PSE.SUBORDINATE_POSITION_ID = p_position_id) ;
            exception when no_data_found then
                        null;
            end;
if g_debug then
            hr_utility.set_location(l_proc, 70);
end if;
            if l_exists = '1' then
               hr_utility.set_message(801,'PER_7416_POS_IN_POS_HIER');
               hr_utility.raise_error;
            end if;
        -- end if;							-- Bug 9146790

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 80);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      FROM PER_VALID_GRADES VG1
                      WHERE business_group_id + 0 = p_business_group_id
                      AND VG1.POSITION_ID = p_position_id);
         exception when no_data_found then
                        null;
         end;
if g_debug then
         hr_utility.set_location(l_proc, 90);
end if;
         if l_exists = '1' then
               hr_utility.set_message(801,'PER_7865_DEF_POS_DEL_GRADE');
               hr_utility.raise_error;
         end if;
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 100);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_job_requirements jre1
                      where jre1.position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7866_DEF_POS_DEL_REQ');
             hr_utility.raise_error;
         end if;
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 110);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_job_evaluations jev1
                      where jev1.position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7867_DEF_POS_DEL_EVAL');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 120);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from hr_all_positions_f
                      where successor_position_id = p_position_id);
         exception when no_data_found then
                        null;

         end;

         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7996_POS_SUCCESSOR_REF');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 120);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from hr_all_positions_f
                      where supervisor_position_id = p_position_id);
         exception when no_data_found then
                        null;

         end;

         if l_exists = '1' then
             hr_utility.set_message(800,'HR_PSF_SUPERVISOR_REF');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 130);
end if;
/*
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_position_extra_info
                      where position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         if l_exists = '1' then
             hr_utility.set_message(800,'HR_DEL_POS_EXTRA_INFO');
             hr_utility.raise_error;
         end if;
*/
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 140);
end if;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_mm_positions
                      where new_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(800,'HR_52776_NOT_DEL_MM_POSITIONS');
             hr_utility.raise_error;
         end if;
         --
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 150);
end if;
/* new logic
         --
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from pqh_position_transactions
                      where position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         --
         if l_exists = '1' then
             hr_utility.set_message(800,'HR_NOT_DEL_PTX');
             hr_utility.raise_error;
         end if;
         --
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 150);
end if;
         --
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from pqh_attribute_ranges
                      where position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         --
         if l_exists = '1' then
             hr_utility.set_message(800,'HR_NOT_DEL_ATT_RANGES');
             hr_utility.raise_error;
         end if;
         --
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 150);
end if;
         --
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from pqh_budgets
                      where position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         --
         if l_exists = '1' then
             hr_utility.set_message(800,'HR_NOT_DEL_BGT');
             hr_utility.raise_error;
         end if;
         --
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 150);
end if;
         --
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from pqh_worksheet_details
                      where position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         --
         if l_exists = '1' then
             hr_utility.set_message(800,'HR_NOT_WKS_DETAIL');
             hr_utility.raise_error;
         end if;
--     end if;
*/
    --
    -- is po installed?
    -- fix for bug 8439584
--    if p_po_ins = 'Y' then
      begin
        l_sql_text := 'select null '
           ||' from sys.dual '
           ||' where exists( select null '
           ||'    from   po_system_parameters '
           ||'    where  security_position_structure_id = '
           ||to_char(p_position_id)
           ||' ) '
           ||' or exists( select null '
           ||'    from   po_employee_hierarchies '
           ||'    where  employee_position_id = '
           ||to_char(p_position_id)
           ||' or    superior_position_id = '
           ||to_char(p_position_id)
           ||' ) '
	   || ' or exists ( select null '
	   || ' from po_position_controls_all '
	   || '    where  position_id = '
           || to_char(p_position_id)
           ||' ) ';
      --
      -- Open Cursor for Processing Sql statment.
      --
if g_debug then
      hr_utility.set_location(l_proc, 150);
end if;
      l_sql_cursor := dbms_sql.open_cursor;
      --
      -- Parse SQL statement.
      --
      dbms_sql.parse(l_sql_cursor, l_sql_text, dbms_sql.v7);
      --
      -- Map the local variables to each returned Column
      --
if g_debug then
      hr_utility.set_location(l_proc, 160);
end if;
      dbms_sql.define_column(l_sql_cursor, 1,l_oci_out,1);
      --
      -- Execute the SQL statement.
      --
if g_debug then
      hr_utility.set_location(l_proc, 170);
end if;
      l_rows_fetched := dbms_sql.execute(l_sql_cursor);
      --
      if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
      then
         hr_utility.set_message(800,'HR_6048_PO_POS_DEL_POS_CONT');
         hr_utility.raise_error;
      end if;
      --
      -- Close cursor used for processing SQL statement.
      --
      dbms_sql.close_cursor(l_sql_cursor);
if g_debug then
      hr_utility.set_location(l_proc, 180);
end if;
      end;
--    end if;
    --
    --  Ref Int check for OTA.
    --
    per_ota_predel_validation.ota_predel_pos_validation(p_position_id);
if g_debug then
    hr_utility.set_location('Leaving : ' || l_proc, 300);
end if;
    --
  end if;
end pre_delete_checks;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) ;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc   := g_package||'delete_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Delete Validations
  pre_delete_checks(p_position_id        => p_rec.position_id
                   ,p_business_group_id  => p_rec.business_group_id
                   ,p_datetrack_mode     => p_datetrack_mode);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode      => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date => p_validation_end_date,
     p_position_id      => p_rec.position_id);
  --
  chk_availability_status_id
   (p_position_id            => p_rec.position_id
   ,p_validation_start_date  => p_validation_start_date
   ,p_availability_status_id => p_rec.availability_status_id
   ,p_old_avail_status_id    => hr_psf_shd.g_old_rec.availability_status_id
   ,p_effective_date         => p_effective_date
   ,p_date_effective         => p_rec.date_effective
   ,p_business_group_id      => p_rec.business_group_id
   ,p_object_version_number  => p_rec.object_version_number
   ,p_datetrack_mode         => p_datetrack_mode );
   --
   -- Bug 3199913 Start
   -- check added
   --
   chk_ref_int_del
    (p_position_id            => p_rec.position_id
    ,p_validation_start_date  => p_validation_start_date
    ,p_validation_end_date    => p_validation_end_date
    ,p_datetrack_mode         => p_datetrack_mode );
   -- Bug 3199913 End

-- changes the date effective if only first active row is getting deleted and there is an
-- active row after that in the position.
   delete_date_effective(p_position_id           => p_rec.position_id
                        ,p_object_version_number => p_rec.object_version_number
                        ,p_business_group_id     => p_rec.business_group_id
                        ,p_datetrack_mode        => p_datetrack_mode );

if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End delete_validate;
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< chk_ddf >---------------------------------|
-- -----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec   in hr_psf_shd.g_rec_type) is
--
  l_proc       varchar2(72) ;
  l_error      exception;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc        := g_package||'chk_ddf';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
  if (p_rec.position_id is null)
    or ((p_rec.position_id is not null)
    and
    nvl(hr_psf_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'DDF HR_ALL_POSITIONS_F'
      ,p_attribute_category => p_rec.information_category
      ,p_attribute1_name    => 'information1'
      ,p_attribute1_value   => p_rec.information1
      ,p_attribute2_name    => 'information2'
      ,p_attribute2_value   => p_rec.information2
      ,p_attribute3_name    => 'information3'
      ,p_attribute3_value   => p_rec.information3
      ,p_attribute4_name    => 'information4'
      ,p_attribute4_value   => p_rec.information4
      ,p_attribute5_name    => 'information5'
      ,p_attribute5_value   => p_rec.information5
      ,p_attribute6_name    => 'information6'
      ,p_attribute6_value   => p_rec.information6
      ,p_attribute7_name    => 'information7'
      ,p_attribute7_value   => p_rec.information7
      ,p_attribute8_name    => 'information8'
      ,p_attribute8_value   => p_rec.information8
      ,p_attribute9_name    => 'information9'
      ,p_attribute9_value   => p_rec.information9
      ,p_attribute10_name   => 'information10'
      ,p_attribute10_value  => p_rec.information10
      ,p_attribute11_name   => 'information11'
      ,p_attribute11_value  => p_rec.information11
      ,p_attribute12_name   => 'information12'
      ,p_attribute12_value  => p_rec.information12
      ,p_attribute13_name   => 'information13'
      ,p_attribute13_value  => p_rec.information13
      ,p_attribute14_name   => 'information14'
      ,p_attribute14_value  => p_rec.information14
      ,p_attribute15_name   => 'information15'
      ,p_attribute15_value  => p_rec.information15
      ,p_attribute16_name   => 'information16'
      ,p_attribute16_value  => p_rec.information16
      ,p_attribute17_name   => 'information17'
      ,p_attribute17_value  => p_rec.information17
      ,p_attribute18_name   => 'information18'
      ,p_attribute18_value  => p_rec.information18
      ,p_attribute19_name   => 'information19'
      ,p_attribute19_value  => p_rec.information19
      ,p_attribute20_name   => 'information20'
      ,p_attribute20_value  => p_rec.information20
      ,p_attribute21_name   => 'information21'
      ,p_attribute21_value  => p_rec.information21
      ,p_attribute22_name   => 'information22'
      ,p_attribute22_value  => p_rec.information22
      ,p_attribute23_name   => 'information23'
      ,p_attribute23_value  => p_rec.information23
      ,p_attribute24_name   => 'information24'
      ,p_attribute24_value  => p_rec.information24
      ,p_attribute25_name   => 'information25'
      ,p_attribute25_value  => p_rec.information25
      ,p_attribute26_name   => 'information26'
      ,p_attribute26_value  => p_rec.information26
      ,p_attribute27_name   => 'information27'
      ,p_attribute27_value  => p_rec.information27
      ,p_attribute28_name   => 'information28'
      ,p_attribute28_value  => p_rec.information28
      ,p_attribute29_name   => 'information29'
      ,p_attribute29_value  => p_rec.information29
      ,p_attribute30_name   => 'information30'
      ,p_attribute30_value  => p_rec.information30
      );
    --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
end chk_ddf;
--
-- Location  :    hr_psf_bus package
-- Called in :    insert_validate
--       update_validate. [Must be the last validation. Can be a part of another
--       procedure called from insert/update_validate]
--

--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in hr_psf_shd.g_rec_type) is
--
  l_proc     varchar2(72);
--
begin
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc      := g_package||'chk_df';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
  --
  if ((p_rec.position_id is not null) and (
    nvl(hr_psf_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2) or
    nvl(hr_psf_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2)))
    or (p_rec.position_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   if nvl(fnd_profile.value('FLEXFIELDS:VALIDATE_ON_SERVER'),'N') = 'Y'
       then
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_POSITIONS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      ,p_attribute21_name   => 'ATTRIBUTE21'
      ,p_attribute21_value  => p_rec.attribute21
      ,p_attribute22_name   => 'ATTRIBUTE22'
      ,p_attribute22_value  => p_rec.attribute22
      ,p_attribute23_name   => 'ATTRIBUTE23'
      ,p_attribute23_value  => p_rec.attribute23
      ,p_attribute24_name   => 'ATTRIBUTE24'
      ,p_attribute24_value  => p_rec.attribute24
      ,p_attribute25_name   => 'ATTRIBUTE25'
      ,p_attribute25_value  => p_rec.attribute25
      ,p_attribute26_name   => 'ATTRIBUTE26'
      ,p_attribute26_value  => p_rec.attribute26
      ,p_attribute27_name   => 'ATTRIBUTE27'
      ,p_attribute27_value  => p_rec.attribute27
      ,p_attribute28_name   => 'ATTRIBUTE28'
      ,p_attribute28_value  => p_rec.attribute28
      ,p_attribute29_name   => 'ATTRIBUTE29'
      ,p_attribute29_value  => p_rec.attribute29
      ,p_attribute30_name   => 'ATTRIBUTE30'
      ,p_attribute30_value  => p_rec.attribute30
      );
   end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end if;

end chk_df;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_ref_int_del >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a position cannot be purged if foreign key
--    references exist to any of the following tables :
--               - PER_ALL_ASSIGNMENTS_F
--               - PAY_ELEMENT_LINKS_F
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_position_id
--    p_validation_start_date
--    p_validation_end_date
--    p_datetrack_mode
--
--  Post Success:
--    If no rows exist in the tables listed above then processing continues.
--
--  Post Failure:
--    If rows exist in any of the tables listed above, an application
--    error is raised and processing is terminated.
--
--  Procedure added for bug 3199913
procedure chk_ref_int_del
  (p_position_id           in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_datetrack_mode        in varchar2
  )
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_ref_int_del';
--
   cursor csr_assgt is
     select   null
     from     sys.dual
     where exists(select   null
                  from     per_all_assignments_f
                  where    position_id = p_position_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       (p_datetrack_mode = 'DELETE'
                  and       effective_start_date >= p_validation_start_date)));

   cursor csr_element_links is
     select null
     from sys.dual
     where exists(select   null
                  from     pay_element_links_f
                  where    position_id = p_position_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       (p_datetrack_mode = 'DELETE'
                  and       effective_start_date >= p_validation_start_date)));

   cursor csr_budget_details is
     select   null
     from     sys.dual
     where exists(select   null
                  from     pqh_budget_details
                  where    position_id = p_position_id
                  and      p_datetrack_mode = 'ZAP');

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that the position is not attached to any assignment
  --
  open csr_assgt;
  fetch csr_assgt into l_exists;
  if csr_assgt%found then
    close csr_assgt;
    hr_utility.set_message(801,'PER_7417_POS_ASSIGNMENT');
    hr_utility.raise_error;
  end if;
  close csr_assgt;
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the position is not attached to any element link
  --
  open csr_element_links;
  fetch csr_element_links into l_exists;
  if csr_element_links%found then
    close csr_element_links;
    hr_utility.set_message(801,'PER_7863_DEL_POS_LINK');
    hr_utility.raise_error;
  end if;
  close csr_element_links;
  --
  hr_utility.set_location(l_proc, 3);
  --
  -- Check that the position is not attached to any Budget
  --
  open csr_budget_details;
  fetch csr_budget_details into l_exists;
  if csr_budget_details%found then
    close csr_budget_details;
    hr_utility.set_message(800,'PER_DEL_POSITION_BUDGET');
    hr_utility.raise_error;
  end if;
  close csr_budget_details;
  --
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 11);
  --
end chk_ref_int_del;

--
Function First_active_position_row(
  p_position_id          in  number,
  p_effective_start_date in  date) return boolean is
    --
    cursor c1 is
      select min(psf.effective_start_date)
      from
         hr_all_positions_f psf
      where psf.position_id = p_position_id
        and hr_psf_shd.get_availability_status(psf.availability_status_id
                                               ,psf.business_group_id) =  'ACTIVE';

    --
    l_minesd        date;
    l_proc          varchar2(30);
    --
Begin
  --
g_debug := hr_utility.debug_enabled;
if g_debug then
   l_proc           :='First_active_position_row';
  hr_utility.set_location( 'Entering : ' || l_proc, 10);
end if;
  open c1;
  fetch c1 into l_minesd;
  close c1;
  --
if g_debug then
  hr_utility.set_location( l_proc, 20);
end if;
  --
  if l_minesd is null or l_minesd = p_effective_start_date then
    --
if g_debug then
    hr_utility.set_location( l_proc, 30);
end if;
    --
    return (true);
    --
  else
    --
if g_debug then
    hr_utility.set_location( l_proc, 40);
end if;
    --
    return (false);
    --
  end if;
if g_debug then
  hr_utility.set_location('Leaving : ' || l_proc, 100);
end if;
  --
End First_active_position_row;
--
Function First_proposed_only_position(
   p_position_id           number,
   p_effective_start_date  date) return boolean is

  --
  l_rows_not_proposed  number(15);
  l_esd              date;
  l_proc             varchar2(30)  ;
  --
  cursor c1 is
    select count(*)
    from
       hr_all_positions_f psf
    where psf.position_id = p_position_id
        and hr_psf_shd.get_availability_status(psf.availability_status_id
                                               ,psf.business_group_id) <>  'PROPOSED';
  --
  cursor c2 is
   select min(psf.effective_Start_Date)
   from
     hr_all_positions_f psf
   where psf.position_id = p_position_id;
  --
Begin
  --
if g_debug then
  l_proc              :='First_proposed_only_position';
  hr_utility.set_location('Entering : ' || l_proc, 10);
end if;
  open c1;
  fetch c1 into l_rows_not_proposed;
  if l_rows_not_proposed = 0 then
    --
if g_debug then
    hr_utility.set_location(l_proc, 20);
end if;
    open c2;
    fetch c2 into l_esd;
    close c2;
    if l_esd is null or l_esd = p_effective_Start_date then
if g_debug then
      hr_utility.set_location(l_proc, 30);
end if;
      return(true);
    end if;
    --
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location( 'Leaving : ' || l_proc, 100);
end if;
  return(false);
  --
End First_proposed_only_position;
--

Function all_proposed_only_position(
   p_position_id           number )
 return boolean is

  --
  l_rows_not_proposed  number(15);
  l_esd              date;
  l_proc             varchar2(30)  ;
  --
  cursor c1 is
    select count(*)
    from
       hr_all_positions_f psf
    where psf.position_id = p_position_id
        and hr_psf_shd.get_availability_status(psf.availability_status_id
                                               ,psf.business_group_id) <>  'PROPOSED';
  --
Begin
  --
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc              :='all_proposed_only_position';
  hr_utility.set_location('Entering : ' || l_proc, 10);
end if;
  open c1;
  fetch c1 into l_rows_not_proposed;
  if l_rows_not_proposed = 0 then
      return(true);
  end if;
  --
if g_debug then
  hr_utility.set_location( 'Leaving : ' || l_proc, 100);
end if;
  return(false);
  --
End all_proposed_only_position;
--
Function Lower_limit(
   p_position_id           in number,
   p_effective_start_date  in date) return date is
  --
  l_esd      date;
  l_proc     varchar2(30)  ;
  --
  cursor c1 is
  select
     min(psf.effective_start_date)
  from
     hr_all_positions_f psf
  where psf.position_id = p_position_id;
  --
  cursor c2 is
  select max(effective_start_date)
  from hr_all_positions_f psf
  where psf.position_id = p_position_id
    and psf.effective_start_date < p_effective_start_date;
  --
  l_proposed_only boolean ;
  l_sot date ;
Begin
  --
if g_debug then
  l_proc      :='Lower_limit';
  hr_utility.set_location( 'Entering : ' || l_proc, 10);
end if;
  l_sot := to_date('01/01/0001','mm/dd/yyyy');
  l_proposed_only := hr_psf_bus.all_proposed_only_position(p_position_id);
  if l_proposed_only = true then
     return(l_sot);
  end if;
  open c1;
  fetch c1 into l_esd;
  close c1;
  --
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  if l_esd is null or l_esd = p_effective_start_date then
if g_debug then
      hr_utility.set_location( 'Leaving : ' || l_proc, 30);
end if;
     return(l_sot);
  else
    --
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    open c2;
    fetch c2 into l_esd;
    close c2;
    --
if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc, 50);
end if;
    --
    return(l_esd + 1);
    --
  end if;
  --
End Lower_limit;
--
Function Upper_limit(
   p_position_id          in number,
   p_effective_Start_date in date) return date is
  --
  l_esd          date;
  l_tmp_esd      date;
  l_ret_date     date;
  l_eot          date;
  l_proc         varchar2(30)  ;
  --
  cursor c1 is
  select max(psf.effective_start_date)
    from hr_all_positions_f psf
    where psf.position_id = p_position_id;
  --
  cursor c2 is
  select min(effective_start_date)
    from per_all_assignments_f paf
    where paf.position_id = p_position_id;
  --
  cursor c3 is
  select min(effective_start_date)
    from hr_all_positions_f psf
    where psf.position_id = p_position_id
      and psf.effective_start_date > p_effective_start_date;
  --
  l_proposed_only boolean;
Begin
  --
if g_debug then
 l_proc          :='Upper_Limit';
  hr_utility.set_location( 'Entering : ' || l_proc, 10);
end if;
  l_eot  := to_date('12/31/4712', 'mm/dd/yyyy');
  --
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  l_proposed_only := hr_psf_bus.all_proposed_only_position(p_position_id);
  if l_proposed_only = true then
     return(l_eot);
  else
     --
     open c1;
     fetch c1 into l_esd;
     close c1;
     --
if g_debug then
     hr_utility.set_location(l_proc, 30);
end if;
     --
     if l_esd is null or l_esd = p_effective_start_date then
if g_debug then
        hr_utility.set_location(l_proc, 40);
end if;
        --
        l_ret_date := l_eot;
     elsE
        --
        l_ret_date := l_esd -1;
     end if;
     --
if g_debug then
     hr_utility.set_location(l_proc, 50);
end if;
     --
     open c2;
     fetch c2 into l_tmp_esd;
     close c2;
     --
if g_debug then
     hr_utility.set_location(l_proc, 60);
end if;
     --
     if nvl(l_tmp_esd, l_eot) < nvl(l_ret_date, l_eot) then
if g_debug then
        hr_utility.set_location(l_proc, 70);
end if;
        --
        l_ret_date := l_tmp_esd;
     end if;
     --
if g_debug then
     hr_utility.set_location(l_proc, 80);
end if;
     --
     open c3;
     fetch c3 into l_tmp_esd;
     close c3;
     --
if g_debug then
     hr_utility.set_location(l_proc, 90);
end if;
     --
     if nvl(l_tmp_esd, l_eot) < nvl(l_esd, l_eot) then
if g_debug then
       hr_utility.set_location(l_proc, 100);
end if;
       --
       l_ret_date := l_tmp_esd - 1;
     end if;
     --
if g_debug then
     hr_utility.set_location( 'Leaving : ' || l_proc, 200);
end if;
     return(nvl(l_ret_date, l_eot));
     --
  end if;
END Upper_limit;
--
--
-- Procedure : DE_Update_properties
-- Description : Determines in Date_Effective is updateable and
--               the valid range
--
Procedure DE_Update_properties(
  p_position_id           in number,
  p_effective_Start_Date  in date,
  p_updateable           out nocopy boolean,
  p_lower_limit          out nocopy date,
  p_upper_limit          out nocopy date) is

  --
  l_updateable     Boolean:=false;
  --
Begin
  --
  l_updateable :=  first_active_position_row (p_position_id, p_effective_start_date);
  if not l_updateable then
    l_updateable :=  hr_psf_bus.all_proposed_only_position(p_position_id);
  end if;
  --
  p_updateable := l_updateable;
  --
  if l_updateable then
     p_lower_limit := lower_limit(p_position_id, p_effective_start_Date);
     p_upper_limit := upper_limit(p_position_id, p_effective_start_Date);
  end if;
end DE_update_properties;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_permanent_seasonal_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check whether both permanent and seasonal flags
--   are enabled.
--
Procedure chk_permanent_seasonal_flag
  (p_position_id               in number
  ,p_permanent_temporary_flag   in varchar2
  ,p_seasonal_flag             in varchar2
  ,p_effective_date            in date
  ,p_object_version_number     in number) is
  --
  l_proc         varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
if g_debug then
  l_proc          := g_package||'chk_permanent_seasonal_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  l_api_updating := hr_psf_shd.api_updating
    (p_position_id            => p_position_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
      (p_permanent_temporary_flag <> nvl(hr_psf_shd.g_old_rec.permanent_temporary_flag,hr_api.g_varchar2)
      or p_seasonal_flag <> nvl(hr_psf_shd.g_old_rec.seasonal_flag,hr_api.g_varchar2)))
      or not l_api_updating) then
      if (p_permanent_temporary_flag is not null and p_seasonal_flag is not null) then
      	if(p_seasonal_flag = 'Y' and p_permanent_temporary_flag = 'Y') then
  	  -- raise error as both flags are set to Y.
	  --
          hr_utility.set_message(8302,'PQH_INV_PRMNT_SEASONAL_FLAG');
          hr_utility.raise_error;
        end if;
      end if;
  end if;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,10);
end if;
  --
end chk_permanent_seasonal_flag;
--

end hr_psf_bus;

/
