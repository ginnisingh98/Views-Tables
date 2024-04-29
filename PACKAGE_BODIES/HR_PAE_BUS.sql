--------------------------------------------------------
--  DDL for Package Body HR_PAE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAE_BUS" as
/* $Header: hrpaerhi.pkb 115.1 99/07/17 05:36:26 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_pae_bus.';  -- Global package name
--
--
--  Business Validation Rules
--
-- --------------------------------------------------------------------------
-- |---------------------------< Check_Exception_Name >---------------------|
-- --------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Ensure that a valid exception name is enterd.  It must be unique,
--   (case-insensitive_check).
--
Procedure check_exception_name (p_exception_id in number default null,
				p_object_version_number in number default null,
				p_exception_name in varchar2) is
--
l_proc  varchar2(72) := g_package||'Check_Exception_Name';
l_api_updating boolean;

cursor c1 is
  select hpe.rowid
  from   hr_pattern_exceptions hpe
  where  upper(hpe.exception_name) = upper(p_exception_name);

 c1_rec c1%ROWTYPE;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

    l_api_updating := hr_pae_shd.api_updating
      (p_exception_id   => p_exception_id,
       p_object_version_number => p_object_version_number);

  if ((l_api_updating and hr_pae_shd.g_old_rec.exception_name <>
                                          p_exception_name)
       or (NOT l_api_updating)) then

     hr_utility.set_location(l_proc,10);

     open c1;
     fetch c1 into c1_rec;
     if c1%FOUND then
       close c1;
    --  *** NEW_MESSAGE_REQUIRED ***
       fnd_message.set_name('HR','EXCEP_NAME_NOT_UNIQUE');
       fnd_message.raise_error;
     end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END check_exception_name;
--
-- -------------------------------------------------------------------------
-- |---------------------------< Check_Exception_Category >----------------|
-- -------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Ensure that the exception category is valid, must exist in
--   HR_LOOKUPS where lookup type = 'EXCEPTION_CATEGORY'
--
Procedure Check_Exception_Category ( p_exception_category in varchar2) is
--
  l_proc  varchar2(72) := g_package||'Check_Exception_Category';

 cursor c1 is
  select h.rowid
  from   hr_lookups h
  where  h.lookup_type = 'EXCEPTION_CATEGORY'
    and  h.lookup_code = p_exception_category;

  c1_rec c1%ROWTYPE;
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
     if p_exception_category is not null then
     open c1;
     fetch c1 into c1_rec;
     if c1%NOTFOUND    then
    --  *** NEW_MESSAGE_REQUIRED ***
       fnd_message.set_name('HR','INVALID_EXCEP_CATEGORY');
       fnd_message.raise_error;
     end if;
     close c1;
     end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END check_exception_category;

--
-- --------------------------------------------------------------------------
-- |---------------------------< To_Days >----------------------------------|
-- --------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Convert user-defined time-unit into days for ease of comparison
--   and manipulation
--
Function to_days (p_quantity in number,
		  p_units    varchar2) return number is

  l_proc  varchar2(72) := g_package||'Derive_Excep_End_Time';
  conversion_factor   number := 1;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_units = 'H' then
     conversion_factor := 24;
  elsif
     p_units = 'W' then
       conversion_factor := 1/7;
  end if;

  return (p_quantity / conversion_factor);

  hr_utility.set_location('Entering:'||l_proc, 10);
END to_days;
--
-- --------------------------------------------------------------------------
-- |---------------------------< Derive_Excep_End_Time >--------------------|
-- --------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    If there are no pattern_construction_children, then set the
--    exception_end_time equal to the exception_start_time .
--    If there are pattern_construction children, then set the
--    exception_end_time equal to the exception_start_time plus the
--    duration of the pattern construction.  Convert each base_time_unit
--    to a fraction of a day, multiplying that figure by the time unit
--    multiplier for each bit of the construction, then summate the
--    products (IU).
--
Procedure Derive_Excep_End_Time (p_pattern_id in number,
				 p_exception_start_time in date,
				 p_exception_end_time out date) is

  l_proc  varchar2(72) := g_package||'Derive_Excep_End_Time';
  l_time  number := 0;

  cursor c1 is
    select bit1.time_unit_multiplier tum,
	   bit1.base_time_unit btu,
	   con1.sequence_no,
	   0
    from   hr_pattern_constructions  con1,
	   hr_pattern_bits           bit1
    where  bit1.pattern_bit_id = con1.pattern_bit_id
      and  con1.pattern_id     = p_pattern_id
    union all
    select bit2.time_unit_multiplier tum,
	   bit2.base_time_unit btu,
	   con2.sequence_no,
	   con3.sequence_no
    from   hr_pattern_bits           bit2,
	   hr_pattern_constructions  con2,
	   hr_pattern_constructions  con3
    where  bit2.pattern_bit_id = con3.pattern_bit_id
      and  con2.component_pattern_id = con3.pattern_id
      and  con2.pattern_id = p_pattern_id
    order by 3,4;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  for c1_rec in c1 loop
     l_time := l_time + to_days(p_quantity   => c1_rec.tum,
				p_units      => c1_rec.btu);
  end loop;
  p_exception_end_time := p_exception_start_time + nvl(l_time,0);

  hr_utility.set_location('Entering:'||l_proc, 10);
END Derive_Excep_End_Time;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in out hr_pae_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
    hr_api.mandatory_arg_error (p_api_name       => l_proc,
				p_argument       => 'pattern_id',
		                p_argument_value => p_rec.pattern_id);

    hr_api.mandatory_arg_error
	 (p_api_name       => l_proc,
	  p_argument       => 'exception_start_time',
          p_argument_value => p_rec.exception_start_time);

  --

  hr_pae_bus.Derive_Excep_End_Time (p_rec.pattern_id,
                                    p_rec.exception_start_time,
				    p_rec.exception_end_time);

  hr_pae_bus.check_exception_name (p_rec.exception_id,
				   p_rec.object_version_number,
				   p_rec.exception_name);
  --
  hr_pae_bus.Check_Exception_Category (p_rec.exception_category);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in out hr_pae_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
/*    if (hr_pae_shd.api_updating
	    ( p_exception_id           => p_rec.exception_id,
   	      p_object_version_number  => p_rec.object_version_number)
	      and
               p_rec.pattern_id <> hr_ern_shd.g_old_rec.pattern_id) then
                  hr_api.argument_changed_error
                         (p_api_name => l_proc,
                          p_argument => 'pattern_id');
    end if; */
  --
/*    if (hr_pae_shd.api_updating
	    ( p_exception_id           => p_rec.exception_id,
   	      p_object_version_number  => p_rec.object_version_number)
	      and
               p_rec.exception_start_time <>
		      hr_ern_shd.g_old_rec.exception_start_time) then
                  hr_api.argument_changed_error
                         (p_api_name => l_proc,
                          p_argument => 'p_rec.exception_start_time');
    end if;
 */ --

  hr_pae_bus.Derive_Excep_End_Time (p_rec.pattern_id,
                                    p_rec.exception_start_time,
				    p_rec.exception_end_time);
  --
  hr_pae_bus.check_exception_name (p_rec.exception_id,
				   p_rec.object_version_number,
				   p_rec.exception_name);
  --
  hr_pae_bus.Check_Exception_Category (p_rec.exception_category);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_pae_shd.g_rec_type) is
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
end hr_pae_bus;

/
