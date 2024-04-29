--------------------------------------------------------
--  DDL for Package Body GHR_DUT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_DUT_BUS" as
/* $Header: ghdutrhi.pkb 120.0.12000000.1 2007/01/18 13:42:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_dut_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_duty_station_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   duty_station_id       -- PK of record being inserted or updated.
--   effective_date        -- Effective Date of session
--   object_version_number -- Object version number of record being
--                            inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_duty_station_id(p_duty_station_id       in number,
			      p_effective_date        in date,
			      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duty_station_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_dut_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_duty_station_id       => p_duty_station_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_duty_station_id,hr_api.g_number)
     <>  ghr_dut_shd.g_old_rec.duty_station_id) then
    --
    -- raise error as PK has changed
    --
    ghr_dut_shd.constraint_error('GHR_DUTY_STATIONS_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_duty_station_id is not null then
      --
      -- raise error as PK is not null
      --
      ghr_dut_shd.constraint_error('GHR_DUTY_STATIONS_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_duty_station_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_duty_station_code >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the unique key for the table
--   is created properly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   duty_station_id       -- PK of record being inserted or updated.
--   duty_station_code     -- Unique Key of the record being inserted or updated
--   effective_date        -- Effective Date of session
--   object_version_number -- Object version number of record being
--                            inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_duty_station_code(p_duty_station_id       in number,
                                p_duty_station_code     in varchar2,
         		        p_effective_date        in date,
			        p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duty_station_code';
  l_api_updating boolean;
  l_dummy_flag   varchar2(1);

  CURSOR c_duty_station_exists is
  SELECT '1'
  FROM   ghr_duty_stations_f
  WHERE  duty_station_code = p_duty_station_code
    AND  p_effective_date between effective_start_date
		              and effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_dut_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_duty_station_id       => p_duty_station_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_duty_station_code,hr_api.g_number)
     <>  ghr_dut_shd.g_old_rec.duty_station_code) then
    --
    -- raise error as UK has changed
    --
    ghr_dut_shd.constraint_error('GHR_DUTY_STATIONS_F_UK');
    --
  elsif not l_api_updating then
    --
    -- check if duty_station_code already exists
    --
    open c_duty_station_exists;
    fetch c_duty_station_exists into l_dummy_flag;
    close c_duty_station_exists;
    IF l_dummy_flag = '1'  Then
	ghr_dut_shd.constraint_error('GHR_DUTY_STATIONS_F_UK');
    End If;
    --
    -- check for cpdf edit#120.00.1. If first 2 characters of dutystation code are alphabets,
    -- then last 3 characters should be zeroes(000)
    --
    IF(
	SUBSTR(p_duty_station_code,1,1) not in ('0','1','2','3','4','5','6','7','8','9')
	AND
	SUBSTR(p_duty_station_code,2,1) not in ('0','1','2','3','4','5','6','7','8','9')
      ) AND
	SUBSTR(p_duty_station_code,-3,3) <> '000' then
      hr_utility.set_message(8301, 'GHR_38829_INVALID_DUTYSTN_CODE');
      hr_utility.raise_error;
  end if;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_duty_station_code;
--
 ----------------------------------------------------------------------------
-- |-----------------------------< chk_duty_station_flag >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Duty Station flag is set properly
--   or not. If the first two positions of the Duty Station code are numbers,
--   and positions 3 through 9 are all zeroes, then the Duty Station Indicator must be "N".
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   duty_station_id       PK of record being inserted or updated.
--   duty_station_code     Duty Station Code of the record
--   is_duty_station       Duty Station flag to be checked
--   effective_date        Effective Date of session
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_duty_station_flag(p_duty_station_id       in number,
                                p_is_duty_station       in varchar2,
				p_duty_station_code     in varchar2,
                                p_effective_date        in date,
	           	        p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duty_station_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_dut_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_duty_station_id       => p_duty_station_id,
     p_object_version_number => p_object_version_number);
  --
  if (   (l_api_updating and
          nvl(p_is_duty_station,hr_api.g_varchar2) <>  ghr_dut_shd.g_old_rec.is_duty_station)
       OR not l_api_updating
      ) then
    --
     IF p_is_duty_station = 'Y'
        and substr(p_duty_station_code,1,1) IN ('0','1','2','3','4','5','6','7','8','9')
	and substr(p_duty_station_code,2,1) IN ('0','1','2','3','4','5','6','7','8','9')
	and substr(p_duty_station_code,3,7) = '0000000'
     THEN
	fnd_message.set_name('GHR','GHR_38821_INVALID_DUTY_STN_IND');
        fnd_message.raise_error;
     end if;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_duty_station_flag;
--
-- --------------------------------------------------------------------------
--|-----------------------------< chk_active_assignments >-------------------|
-- --------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the active assignments with the
--   duty station code as on the effective date when user wants to end date
--   a duty station.  If any assignment exists, user will get the error message
--   and process will be terminated.
-- Pre Conditions
--   None.
--
-- In Parameters
--   duty_station_code --  Duty station Code to be deleted
--   effective_date    -- Effective Date of session
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
procedure chk_active_assignments(p_duty_station_id   IN VARCHAR2,
				   p_effective_date  IN Date
				 ) IS
  l_count   NUMBER := 0;

  Cursor  c_assgnments is
  select  '1'
    from  per_assignments_f paf,hr_location_extra_info hrle
   where  paf.location_id = hrle.location_id
     and  paf.assignment_type = 'E'
     and  p_effective_date between paf.effective_start_date and paf.effective_end_date
     and  hrle.lei_information_category = 'GHR_US_LOC_INFORMATION'
     and  hrle. lei_information3 = p_duty_station_id;
Begin
  FOR c_assgnments_rec IN c_assgnments
  LOOP
   l_count := 1;
   EXIT;
  END LOOP;
  IF l_count > 0 then
     fnd_message.set_name('GHR','GHR_38820_DUT_STN_HAS_ASGNMNT');
     fnd_message.raise_error;
  END IF;
End chk_active_assignments;
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
            (p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
   When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
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
            (p_duty_station_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
  If (p_datetrack_mode = 'DELETE') then
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
       p_argument       => 'duty_station_id',
       p_argument_value => p_duty_station_id);
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('GHR','GHR_38819_DUTY_STATION_EXISTS');
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ghr_dut_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_duty_station_id
     (p_duty_station_id       => p_rec.duty_station_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_duty_station_code
     (p_duty_station_id       => p_rec.duty_station_id,
      p_duty_station_code     => p_rec.duty_station_code,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
   chk_duty_station_flag
     (p_duty_station_id       => p_rec.duty_station_id,
      p_is_duty_station       => p_rec.is_duty_station,
      p_duty_station_code     => p_rec.duty_station_code,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  --  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ghr_dut_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_duty_station_id
     (p_duty_station_id  => p_rec.duty_station_id,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
   chk_duty_station_flag
     (p_duty_station_id  => p_rec.duty_station_id,
      p_is_duty_station => p_rec.is_duty_station,
      p_duty_station_code   => p_rec.duty_station_code,
      p_effective_date => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate (p_datetrack_mode	      => p_datetrack_mode,
                      p_validation_start_date => p_validation_start_date,
                      p_validation_end_date   => p_validation_end_date);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ghr_dut_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_active_assignments(p_duty_station_id => p_rec.duty_station_id,
                         p_effective_date    => p_effective_date);

  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_duty_station_id		=> p_rec.duty_station_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_duty_station_id in number) return varchar2 is
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_legislation_code := 'US';
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ghr_dut_bus;

/
