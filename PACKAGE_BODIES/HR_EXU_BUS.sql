--------------------------------------------------------
--  DDL for Package Body HR_EXU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EXU_BUS" as
/* $Header: hrexurhi.pkb 120.0.12010000.1 2009/10/12 11:28:03 npannamp noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_exu_bus.';  -- Global package name
--
--
--  Business Validation Rules
--
-- --------------------------------------------------------------------------
-- |---------------------------< Check_No_ID_Conflict >---------------------|
-- --------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Check that there is no conflict on insert.i.e. that either
--    Calendar ID or Calendar Usage ID are entered on Insert and not
--    both.
--
Procedure Check_No_ID_Conflict (p_calendar_id in varchar2,
				p_calendar_usage_id in varchar2) is

  l_proc  varchar2(72) := g_package||'Check_No_ID_Conflict';

cursor c1 is
  select c.rowid
  from   hr_calendars c
  where  c.calendar_id = p_calendar_id;

 c1_rec c1%ROWTYPE;

cursor c2 is
  select u.rowid
  from   hr_calendar_usages u
  where  u.calendar_usage_id = p_calendar_usage_id;

 c2_rec c2%ROWTYPE;

BEGIN
--
-- First check that both id's have not been entered
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_calendar_usage_id is not null and p_calendar_id is not null then
	 --  *** NEW_MESSAGE_REQUIRED ***
     fnd_message.set_name('PAY','EXCEP_USAGE_FK_CONFLICT');
     fnd_message.raise_error;
  elsif p_calendar_usage_id is null and p_calendar_id is null then
      --  *** NEW_MESSAGE_REQUIRED ***
     fnd_message.set_name('PAY','NO_FK_ENTERED');
     fnd_message.raise_error;
  end if;
--
-- No conflict now check that the FK entered is valid
--
  if p_calendar_id is not null then
  hr_utility.set_location(l_proc, 10);
    open c1;
    fetch c1 into c1_rec;
    if c1%NOTFOUND then
	--  *** NEW_MESSAGE_REQUIRED ***
      fnd_message.set_name('PAY', 'INVALID CALENDAR_ID');
      fnd_message.raise_error;
    end if;
    close c1;
  else
  hr_utility.set_location(l_proc, 15);
    open c2;
    fetch  c2 into c2_rec;
    if c2%NOTFOUND then
	--  *** NEW_MESSAGE_REQUIRED ***
      fnd_message.set_name('PAY','INVALID_CALENDAR_USAGE_ID');
      fnd_message.raise_error;
    end if;
    close c2;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END Check_No_ID_Conflict;
--
--
-- ------------------------------------------------------------------------
-- |-------------------------< Cal_Use_For_SSP >--------------------------|
-- ------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
--    Boolean Function to determine wheteher the Calendar Usage is for
--    an SSP pattern purpose.
--
Function Cal_Use_For_SSP (p_calendar_usage_id in number)
  return boolean is

  l_proc  varchar2(72) := g_package||'Cal_Use_For_SSP';

  cursor c1 is
    select '1'
    from   hr_calendar_usages  hcu,
	   hr_calendars         hc,
	   hr_patterns          hp,
	   hr_pattern_purposes hpp
    where  hcu.calendar_usage_id = p_calendar_usage_id
      and  hcu.calendar_id       = hc.calendar_id
      and  hc.pattern_id        = hp.pattern_id
      and  hp.pattern_id        = hpp.pattern_id
      and  hpp.pattern_purpose = 'SSP';

   c1_rec c1%ROWTYPE;
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  open c1;
  fetch c1 into c1_rec;
  if c1%NOTFOUND then
    return(FALSE);
  else
    return(TRUE);
  end if;
  close c1;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END Cal_Use_For_SSP;
--
--
-- ------------------------------------------------------------------------
-- |------------------------< Excep_is_Qual_Non_Qual >--------------------|
-- ------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
--    Boolean Function to determine whether the exception used consists
--    only of availability values of 'QUALIFYING' and 'NON QUALIFYING'
--
Function Excep_is_Qual_Non_Qual (p_exception_id in number)
   return boolean is

  l_proc  varchar2(72) := g_package||'Excep_is_Qual_Non_Qual';

  cursor c2 is
    select '1'
    from   hr_pattern_constructions hpc1,
	   hr_pattern_exceptions    hpe1
    where  hpc1.pattern_id = hpe1.pattern_id
      and  hpe1.exception_id = p_exception_id
      and  not ( hpc1.availability = 'QUALIFYING'
              or hpc1.availability = 'NON QUALIFYING')
    UNION ALL
    select '1'
    from   hr_pattern_constructions hpc2,
	   hr_pattern_constructions hpc3,
	   hr_pattern_exceptions    hpe2
    where  hpc2.component_pattern_id = hpc3.pattern_id
      and  hpc2.pattern_id = hpe2.pattern_id
      and  hpe2.exception_id = p_exception_id
      and  not ( hpc2.availability = 'QUALIFYING'
              or hpc2.availability = 'NON QUALIFYING');

   c2_rec c2%ROWTYPE;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  open c2;
  fetch c2 into c2_rec;
  if c2%FOUND then
    return(FALSE);
  else
    return(TRUE);
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END Excep_is_Qual_Non_Qual;
--
-- ------------------------------------------------------------------------
-- |---------------------------< Check_Exception_ID >---------------------|
-- ------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Ensure that a valid exception_id from hr_pattern_exceptions is
--    entered.
--    SSP_specific Rules:
--    ------------------
--    If the Calendar_usage_id is not null and the calendar usage is for
--    an SSP pattern purpose, then the exception_id must be for an
--    exception which consists only of availability values
--    `QUALIFYING' and 'NON QUALIFYING'
--
Procedure Check_Exception_Id (p_calendar_usage_id in number,
			      p_exception_id      in number) is

  l_proc  varchar2(72) := g_package||'Check_Exception_ID';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_calendar_usage_id is not null and
    cal_use_for_ssp(p_calendar_usage_id) then
      if excep_is_qual_non_qual(p_exception_id) then
	  null;
      else
	--  *** NEW_MESSAGE_REQUIRED ***
	  fnd_message.set_name('PAY','INVALID_EXCEPTION_ID');
	  fnd_message.raise_error;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END Check_Exception_ID;
--
-- ------------------------------------------------------------------------
-- |---------------------------< Check_Unique >---------------------------|
-- ------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A pattern exception may not be applied to a calendar_id if another
--    pattern exception overlaps it in time ia already applied to the
--    calendar_id.  However, if the first pattern is applied to a calendar_id
--    then a overlapping exception_pattern may be applied to a calendar_usage_id
--    and vice-versa.
--
Procedure Check_Unique (p_calendar_id   in number,
			p_calendar_usage_id in number,
			p_exception_id  in number) is

  l_proc  varchar2(72) := g_package||'Check_Unique';

  cursor c1 is
    select  exp.exception_start_time start_time,
	    exp.exception_end_time   end_time
    from    hr_pattern_exceptions exp
    where   exp.exception_id = p_exception_id;

  c1_rec c1%ROWTYPE;

  cursor c2 is
    select  '1'
    from    hr_exception_usages   u,
	    hr_pattern_exceptions e
    where   u.calendar_id = p_calendar_id
      and   u.exception_id = e.exception_id
      and   e.exception_start_time <= c1_rec.end_time
      /* bug fix 8816205 */
      -- and   e.exception_end_time   >= c1_rec.start_time
      and   e.exception_end_time   > c1_rec.start_time
  UNION ALL
    select '1'
    from    hr_exception_usages   u,
	    hr_pattern_exceptions e
    where   u.calendar_usage_id = p_calendar_usage_id
      and  u.exception_id = e.exception_id
      and   e.exception_start_time <= c1_rec.end_time
      /* bug fix 8816205 */
      -- and   e.exception_end_time   >= c1_rec.start_time;
      and   e.exception_end_time   > c1_rec.start_time;

  c2_rec c2%ROWTYPE;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  First get the start and end times of the pattern exception that
  --  we wish to insert
  --
  open c1;
  fetch c1 into c1_rec;
  close c1;
  --
  --  Now see if there are any records returned by cursor2.  If there
  --  are, we have a failure.
  --
  hr_utility.set_location(l_proc, 10);
  open c2;
  fetch c2 into c2_rec;
  if c2%FOUND then
    close c2;
	 --  *** NEW_MESSAGE_REQUIRED ***
    fnd_message.set_name('PAY','OVERLAPPING_EXCEPTIONS_ERROR');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END Check_Unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_exu_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check that the Mandatory Column Exception_Id has been entered
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
			      p_argument       => 'Exception_Id',
			      p_argument_value => p_rec.exception_id);

  hr_utility.set_location(l_proc, 10);

  hr_exu_bus.Check_No_ID_Conflict(p_rec.calendar_id,
				  p_rec.calendar_usage_id);

  hr_utility.set_location(l_proc, 15);
  --
  hr_exu_bus.Check_Exception_Id (p_rec.calendar_usage_id,
			         p_rec.exception_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  hr_exu_bus.Check_Unique (p_rec.calendar_id,
	                   p_rec.calendar_usage_id,
	                   p_rec.exception_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_exu_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
/*   if (hr_exu_shd.api_updating
	 ( p_exception_usage_id => p_rec.exception_usage_id,
	   p_object_version_number => p_rec.object_version_number) and
      nvl(p_rec.calendar_id, hr_exu.g_number) <>
      nvl(hr_exu_shd.g_old_rec.calendar_id,hr_api.g_number)) then
	 (p_api_name => l_proc,
	  p_argument => 'calendar_id');
   end if;

   if (hr_exu_shd.api_updating
	 ( p_exception_usage_id => p_rec.exception_usage_id,
	   p_object_version_number => p_rec.object_version_number) and
      nvl(p_rec.calendar_usage_id,hr_api.g_number) <>
      nvl(hr_exu_shd.g_old_rec.calendar_usage_id,hr_api.g_varchar2)) then
	 (p_api_name => l_proc,
	  p_argument => 'calendar_usage_id');
   end if;

   if (hr_exu_shd.api_updating
	 ( p_exception_usage_id => p_rec.exception_usage_id,
	   p_object_version_number => p_rec.object_version_number) and
      p_rec.exception_id <> hr_exu_shd.g_old_rec.exception_id) then
	 (p_api_name => l_proc,
	  p_argument => 'exception_id');
   end if;
 */
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_exu_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_exu_bus;

/
