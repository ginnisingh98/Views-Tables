--------------------------------------------------------
--  DDL for Package Body PAY_PUR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PUR_BUS" as
/* $Header: pypurrhi.pkb 120.1.12010000.2 2009/12/23 09:46:10 asnell ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pur_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_user_row_id                 number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_user_row_id                          in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_user_rows_f pur
     where pur.user_row_id = p_user_row_id
       and pbg.business_group_id = pur.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'user_row_id'
    ,p_argument_value     => p_user_row_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'USER_ROW_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_user_row_id                          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_user_rows_f pur
     where pur.user_row_id = p_user_row_id
       and pbg.business_group_id (+) = pur.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'user_row_id'
    ,p_argument_value     => p_user_row_id
    );
  --
  if ( nvl(pay_pur_bus.g_user_row_id, hr_api.g_number)
       = p_user_row_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pur_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_pur_bus.g_user_row_id                 := p_user_row_id;
    pay_pur_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_legislation_code>-------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the legislation code exists in fnd_territories
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_legislation_code
( p_legislation_code  in varchar2 )
is
--
cursor csr_legislation_code is
select null
from fnd_territories
where territory_code = p_legislation_code ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_legislation_code';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_legislation_code;
  fetch csr_legislation_code into l_exists ;

  if csr_legislation_code%notfound then
    close csr_legislation_code;
    fnd_message.set_name('PAY', 'PAY_33177_LEG_CODE_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_legislation_code;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_ROWS_F.LEGISLATION_CODE'
       ) then
      raise;
    end if;
  when others then
    if csr_legislation_code%isopen then
      close csr_legislation_code;
    end if;
    raise;
end chk_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |----------------------<  return_user_key_units  >-------------------------|
-- ----------------------------------------------------------------------------
--
function return_user_key_units
( p_user_table_id in PAY_USER_TABLES.USER_TABLE_ID%TYPE )
return varchar2 is
--
cursor csr_user_key_units
is
	select user_key_units
	from   pay_user_tables put
	where  put.user_table_id = p_user_table_id ;

l_proc   varchar2(100) := g_package || 'return_user_key_units';
--
begin

  hr_utility.set_location('Entering:'||l_proc, 10);

  if g_user_key_units is null then

	--
	-- USER_TABLE_ID is mandatory.
	--
	hr_api.mandatory_arg_error
	(p_api_name       =>  l_proc
	,p_argument       =>  'USER_TABLE_ID'
	,p_argument_value =>  p_user_table_id
	);
	--

	open csr_user_key_units;
	fetch csr_user_key_units into g_user_key_units;

	If csr_user_key_units%notfound then
    	      close csr_user_key_units;
    	      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
	      fnd_message.set_token('PROCEDURE', l_proc);
	      fnd_message.set_token('STEP','5');
	      fnd_message.raise_error;
	end if;

	close csr_user_key_units;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

  return g_user_key_units;

end return_user_key_units;
--
-- ----------------------------------------------------------------------------
-- |----------------------<  return_range_or_match >--------------------------|
-- ----------------------------------------------------------------------------
--
function return_range_or_match
( p_user_table_id in PAY_USER_TABLES.USER_TABLE_ID%TYPE )
return varchar2 is
--
cursor csr_range_or_match
is
	select range_or_match
	from   pay_user_tables put
	where  put.user_table_id = p_user_table_id ;

l_proc   varchar2(100) := g_package || 'return_range_or_match';
--
begin

  hr_utility.set_location('Entering:'||l_proc, 10);

  if g_range_or_match is null then

	--
	-- USER_TABLE_ID is mandatory.
	--
	hr_api.mandatory_arg_error
	(p_api_name       =>  l_proc
	,p_argument       =>  'USER_TABLE_ID'
	,p_argument_value =>  p_user_table_id
	);
	--

	open csr_range_or_match;
	fetch csr_range_or_match into g_range_or_match;

	If csr_range_or_match%notfound then
    	      close csr_range_or_match;
    	      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
	      fnd_message.set_token('PROCEDURE', l_proc);
	      fnd_message.set_token('STEP','5');
	      fnd_message.raise_error;
	end if;

	close csr_range_or_match;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

  return g_range_or_match;

end return_range_or_match;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_user_table_id >---------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the user_table_id exists in pay_user_tables
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_user_table_id
--    p_legislation_code
--    p_business_group_id
--
--  Post Success:
--    Processing continues if the user_table_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the user_table_id is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_user_table_id
(p_user_table_id     in number
,p_legislation_code  in varchar2
,p_business_group_id in number
) is
--
cursor csr_user_table_id is
select put.legislation_code , put.business_group_id
from   pay_user_tables put
where  put.user_table_id = p_user_table_id ;
--
l_busgrpid PAY_USER_ROWS_F.BUSINESS_GROUP_ID%TYPE;
l_legcode  PAY_USER_ROWS_F.LEGISLATION_CODE%TYPE;

l_proc   varchar2(100) := g_package || 'chk_user_table_id';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- USER_TABLE_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'USER_TABLE_ID'
  ,p_argument_value =>  p_user_table_id
  );
  --
  open csr_user_table_id;
  fetch csr_user_table_id into l_legcode, l_busgrpid ;

  if csr_user_table_id%notfound then
    close csr_user_table_id;
    fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
    fnd_message.set_token('PARENT' , 'User Table Id' );
    fnd_message.raise_error;
  end if;
  close csr_user_table_id;
  --
  -- Confirm that the parent USER_TABLE's startup mode is compatible
  -- with this PAY_USER_ROWS row.
  --
  if not pay_put_shd.chk_startup_mode_compatible
         (p_parent_bgid    => l_busgrpid
         ,p_parent_legcode => l_legcode
         ,p_child_bgid     => p_business_group_id
         ,p_child_legcode  => p_legislation_code
         ) then
    fnd_message.set_name('PAY', 'PAY_33175_BGLEG_MISMATCH');
    fnd_message.set_token('CHILD', 'User Row');
    fnd_message.set_token('PARENT' , 'User Table');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_USER_ROWS_F.USER_TABLE_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_user_table_id%isopen then
      close csr_user_table_id;
    end if;
    raise;

end chk_user_table_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_format >------------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the p_value is in the format specified by p_format_code
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_value - This relates to the row_low_range_or_name or row_high_range
--              columns in pay_user_rows_f table
--    p_format_code - This relates to user_key_units column in pay_user_tables
--
--  Post Success:
--    Processing continues if p_value is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the p_value is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
function chk_format
(p_value in out nocopy varchar2
,p_format_code in varchar2
)
return boolean  is
  --
  l_return boolean;
  l_dummy varchar2(255);
  l_format varchar2(255);
  l_unformatted_value varchar2(255);

  l_proc   varchar2(100) := g_package || 'chk_format';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_format_code = 'D' then
      l_format := 'DATE' ;
  elsif p_format_code = 'T' then
      l_format := 'C' ;
  else
      l_format := p_format_code ;
  end if ;

  l_unformatted_value := p_value;

  hr_chkfmt.checkformat ( l_unformatted_value ,
                          l_format ,
                          p_value  ,
                          null ,
                          null ,
                          'N'  ,
                          l_dummy,
                          null
                        );
  l_return := TRUE;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

  return l_return;

exception
    when app_exception.application_exception then
      l_return := FALSE;
      return l_return;

end chk_format;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_row_low_range_or_name >---------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the row_low_range_or_name
--	 1. Is Mandatory.
--	 2. Is Numeric if range match is used.
--	 3. Is in the format as specified by user_key_units in pay_user_tables
--	    (Conditional)
--	 4. Is Unique. (Conditional)
--
--  Pre-Requisites:
--    user_table_id must be validated.
--
--  In Parameters:
--    p_user_row_id
--    p_user_table_id
--    p_row_low_range_or_name
--    p_object_version_number
--    p_disable_units_check - User supplied flag which indicates whether
--			      data type validation has to be carried out or not
--    p_disable_range_overlap_check - User supplied flag which indicates
--                                    whether range overlap check has to be
--				      carried out or not (Conditional)
--    p_legislation_code
--    p_business_group_id
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if the row_low_range_or_name is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the row_low_range_or_name is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_row_low_range_or_name
( p_user_row_id           in number
 ,p_user_table_id         in number
 ,p_row_low_range_or_name in out nocopy varchar2
 ,p_object_version_number in number
 ,p_disable_units_check   in boolean
 ,p_disable_range_overlap_check   in boolean
 ,p_business_group_id     in number
 ,p_legislation_code      in varchar2
 ,p_effective_date        in date
 ,p_validation_start_date in date
 ,p_validation_end_date   in date
) is
--
cursor csr_unique_name is
	select null
	from   pay_user_rows_f  usr
	where  usr.user_table_id = p_user_table_id
	and    upper(usr.row_low_range_or_name) = upper(p_row_low_range_or_name)
	and    ( p_user_row_id is null
		or ( p_user_row_id is not null and usr.user_row_id <> p_user_row_id ) )
        and    ( p_business_group_id is null
 	        or ( p_business_group_id is not null and p_business_group_id = usr.business_group_id )
		or ( p_business_group_id is not null and
			usr.legislation_code is null and usr.business_group_id is null )
		or ( p_business_group_id is not null and
		        usr.legislation_code = hr_api.return_legislation_code(p_business_group_id )))
	and    ( p_legislation_code is null
		or ( p_legislation_code is not null and p_legislation_code = usr.legislation_code )
		or ( p_legislation_code is not null and
			usr.legislation_code is null and usr.business_group_id is null)
		or ( p_legislation_code is not null and
			p_legislation_code = hr_api.return_legislation_code(usr.business_group_id )))
	and    ( usr.effective_start_date <= p_validation_end_date and
			usr.effective_end_date >= p_validation_start_date );


l_proc   varchar2(100) := g_package || 'chk_row_low_range_or_name';
l_range_or_match  PAY_USER_TABLES.RANGE_OR_MATCH%TYPE;
l_user_key_units  PAY_USER_TABLES.USER_KEY_UNITS%TYPE;
l_exists varchar2(1);
l_result boolean;
l_prod_status    varchar2(1);
l_ghr_installed  varchar2(1);
l_industry	 varchar2(1);
l_oracle_scheema varchar2(30);

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_USER_ROWS_F.USER_TABLE_ID'
     ,p_associated_column1 => 'PAY_USER_ROWS_F.ROW_LOW_RANGE_OR_NAME'
     ) and (
       not pay_pur_shd.api_updating
              (p_user_row_id           => p_user_row_id
	      ,p_effective_date        => p_effective_date
	      ,p_object_version_number => p_object_version_number
              ) or
       nvl(p_row_low_range_or_name, hr_api.g_varchar2) <>
       pay_pur_shd.g_old_rec.row_low_range_or_name
     ) then
    --
    -- The name is mandatory.
    --
    hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'ROW_LOW_RANGE_OR_NAME'
    ,p_argument_value =>  p_row_low_range_or_name
    );

    if p_disable_units_check is null then
	fnd_message.set_name('PAY', 'HR_7207_API_MANDATORY_ARG');
	fnd_message.set_token('API_NAME', l_proc);
	fnd_message.set_token('ARGUMENT','DISABLE_UNITS_CHECK');
	fnd_message.raise_error;
    end if;

    if p_disable_range_overlap_check is null then
	fnd_message.set_name('PAY', 'HR_7207_API_MANDATORY_ARG');
	fnd_message.set_token('API_NAME', l_proc);
	fnd_message.set_token('ARGUMENT','DISABLE_RANGE_OVERLAP_CHECK');
	fnd_message.raise_error;
    end if;

    l_user_key_units := return_user_key_units(p_user_table_id);
    l_range_or_match := return_range_or_match(p_user_table_id);


    if( l_range_or_match = 'R' or ( l_range_or_match = 'M' and p_disable_units_check = FALSE)) then

           l_result := chk_format( p_row_low_range_or_name,
                                               l_user_key_units ) ;

	    if ( l_result = FALSE ) then
		if ( l_range_or_match = 'M' ) then
			  fnd_message.set_name ( 'PAY', 'PAY_33131_UT_INVALID_ROW' );
		          fnd_message.raise_error;
		elsif (l_range_or_match = 'R' ) then
			  fnd_message.set_name ( 'PAY', 'PAY_34025_UT_RANGE_NOT_NUMERIC' );
		          fnd_message.raise_error;
	        end if;
	    end if;
    end if;


    l_result := fnd_installation.get_app_info ( 'GHR',
   	  	  	            l_prod_status,
	 			    l_industry,
  				    l_oracle_scheema );

    if ( l_prod_status = 'I' ) then
    	l_ghr_installed := 'Y';
    else
        l_ghr_installed := 'N';
    end if;
-- bug 9234524 start
--    if ( l_ghr_installed = 'N'
--          or ( l_ghr_installed = 'Y' and l_range_or_match = 'M' )
--             or ( l_ghr_installed = 'Y' and p_disable_range_overlap_check = FALSE ) ) then
      if ( l_range_or_match = 'M' or p_disable_range_overlap_check = FALSE ) then

		open csr_unique_name;
		fetch csr_unique_name into l_exists;

		if csr_unique_name%found then
	             close csr_unique_name;
		     fnd_message.set_name( 'PAY' , 'PAY_7884_USER_TABLE_UNIQUE' );
	             fnd_message.raise_error ;
		end if ;

		close csr_unique_name;
    end if;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_USER_ROWS_F.ROW_LOW_RANGE_OR_NAME') then
	      raise;
       end if;

    when others then
       if csr_unique_name%isopen then
      	    close csr_unique_name;
       end if;
       raise;

end chk_row_low_range_or_name ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_row_high_range >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the row_high_range
--	 1. Is Mandatory for range tables.
--	 2. Is Ignored for match tables.
--	 3. Is numeric.
--
--  Pre-Requisites:
--    user_table_id must be validated
--
--  In Parameters:
--    p_user_row_id
--    p_user_table_id
--    p_row_high_range
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Processing continues if the row_high_range is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the row_high_range is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_row_high_range
( p_row_high_range in out nocopy varchar2
 ,p_user_table_id  in number
 ,p_user_row_id    in number
 ,p_object_version_number in number
 ,p_effective_date in date
) is
--
l_proc   varchar2(100) := g_package || 'chk_row_high_range';
l_range_or_match  PAY_USER_TABLES.RANGE_OR_MATCH%TYPE;
l_user_key_units  PAY_USER_TABLES.USER_KEY_UNITS%TYPE;
l_exists varchar2(1);
l_result boolean;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_USER_ROWS_F.USER_TABLE_ID'
     ,p_associated_column1 => 'PAY_USER_ROWS_F.ROW_HIGH_RANGE'
     ) and (
       not pay_pur_shd.api_updating
              (p_user_row_id           => p_user_row_id
	      ,p_effective_date        => p_effective_date
	      ,p_object_version_number => p_object_version_number
              ) or
       nvl(p_row_high_range, hr_api.g_varchar2) <>
       nvl(pay_pur_shd.g_old_rec.row_high_range, hr_api.g_varchar2)
     ) then
    --
    -- Ignore all validations for ROW_HIGH_RANGE for Exact Match User Tables.
    --

       l_user_key_units := return_user_key_units(p_user_table_id);
       l_range_or_match := return_range_or_match(p_user_table_id);

       if l_range_or_match = 'R' then

	    -- row_high_range is mandatory

	    hr_api.mandatory_arg_error
	    (p_api_name       =>  l_proc
	    ,p_argument       =>  'ROW_HIGH_RANGE'
	    ,p_argument_value =>  p_row_high_range
	    );


            l_result := chk_format( p_row_high_range,
                                    l_user_key_units  ) ;

	    if ( l_result = FALSE ) then
	             fnd_message.set_name ( 'PAY', 'PAY_34025_UT_RANGE_NOT_NUMERIC' );
		     fnd_message.raise_error;
	    end if;
      end if;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_USER_ROWS_F.ROW_HIGH_RANGE') then
	      raise;
       end if;

    when others then
       raise;

end chk_row_high_range ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_range >--------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the
--	 1. row_high_range >= row_low_range_or_name for range tables
--	 2. The range row_low_range_or_name -> row_high_range does not overlap
--	    with other rows. (Conditional)
--
--  Pre-Requisites:
--     row_low_range_or_name and row_high_range must be validated.
--
--  In Parameters:
--    p_user_row_id
--    p_user_table_id
--    p_row_low_range_or_name
--    p_row_high_range
--    p_object_version_number
--    p_disable_range_overlap_check - User supplied flag which indicates
--                                    whether range overlap check has to be
--				      carried out or not (Conditional)
--    p_legislation_code
--    p_business_group_id
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if the range is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the range is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_range
( p_user_row_id           in number
 ,p_user_table_id         in number
 ,p_row_low_range_or_name in varchar2
 ,p_row_high_range        in varchar2
 ,p_disable_range_overlap_check in boolean
 ,p_object_version_number in number
 ,p_business_group_id     in number
 ,p_legislation_code      in varchar2
 ,p_effective_date        in date
 ,p_validation_start_date in date
 ,p_validation_end_date   in date
) is
--

cursor csr_row_overlap is
  select null
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    ( p_user_row_id is null
		or ( p_user_row_id is not null and usr.user_row_id <> p_user_row_id ) )
  and    ( p_business_group_id is null
          or ( p_business_group_id is not null and p_business_group_id = usr.business_group_id )
   	  or ( p_business_group_id is not null and
			usr.legislation_code is null and usr.business_group_id is null )
	  or ( p_business_group_id is not null and
		        usr.legislation_code = hr_api.return_legislation_code(p_business_group_id ) ))
  and    ( p_legislation_code is null
	  or ( p_legislation_code is not null and p_legislation_code = usr.legislation_code )
	  or ( p_legislation_code is not null and
			usr.legislation_code is null and usr.business_group_id is null)
	  or ( p_legislation_code is not null and
			p_legislation_code = hr_api.return_legislation_code(usr.business_group_id) ))
  and    (fnd_number.canonical_to_number(p_row_low_range_or_name) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range)
  or     (fnd_number.canonical_to_number(p_row_high_range) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range))
  or     (fnd_number.canonical_to_number(usr.row_low_range_or_name) between
          fnd_number.canonical_to_number(p_row_low_range_or_name) and fnd_number.canonical_to_number(p_row_high_range))
  or     (fnd_number.canonical_to_number(usr.row_high_range) between
          fnd_number.canonical_to_number(p_row_low_range_or_name) and fnd_number.canonical_to_number(p_row_high_range)))
  and    ( usr.effective_start_date <= p_validation_end_date and
			usr.effective_end_date >= p_validation_start_date );

l_proc   varchar2(100) := g_package || 'chk_range';
l_range_or_match  PAY_USER_TABLES.RANGE_OR_MATCH%TYPE;
l_user_key_units  PAY_USER_TABLES.USER_KEY_UNITS%TYPE;
l_exists varchar2(1);
l_result boolean;
l_prod_status    varchar2(1);
l_ghr_installed  varchar2(1);
l_industry	 varchar2(1);
l_oracle_scheema varchar2(30);

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if hr_multi_message.no_exclusive_error
     ( p_check_column1      => 'PAY_USER_ROWS_F.ROW_LOW_RANGE_OR_NAME'
      ,p_check_column2      => 'PAY_USER_ROWS_F.ROW_HIGH_RANGE'
      ,p_associated_column1 => 'PAY_USER_ROWS_F.ROW_LOW_RANGE_OR_NAME'
      ,p_associated_column2 => 'PAY_USER_ROWS_F.ROW_HIGH_RANGE'
     ) and (
       not pay_pur_shd.api_updating
              (p_user_row_id           => p_user_row_id
	      ,p_effective_date        => p_effective_date
	      ,p_object_version_number => p_object_version_number
              ) or (
       nvl(p_row_low_range_or_name, hr_api.g_varchar2) <>
       nvl(pay_pur_shd.g_old_rec.row_low_range_or_name, hr_api.g_varchar2) or
       nvl(p_row_high_range, hr_api.g_varchar2) <>
       nvl(pay_pur_shd.g_old_rec.row_high_range, hr_api.g_varchar2))
     ) then

	  if p_disable_range_overlap_check is null then
		fnd_message.set_name('PAY', 'HR_7207_API_MANDATORY_ARG');
		fnd_message.set_token('API_NAME', l_proc);
		fnd_message.set_token('ARGUMENT','DISABLE_RANGE_OVERLAP_CHECK');
		fnd_message.raise_error;
	  end if;

       -- Validation required only for Range Match

          l_range_or_match := return_range_or_match(p_user_table_id);

          if l_range_or_match = 'R' then

             -- Bug 3832215. Convert row_low_range_or_name and row_high_range
             -- from canonical to number before compare.

	     if fnd_number.canonical_to_number(p_row_high_range) <
                            fnd_number.canonical_to_number(p_row_low_range_or_name) then
             	 fnd_message.set_name('PAY','PAY_33178_RANGE_INVALID');
		 fnd_message.raise_error ;
	     end if;


    	     l_result := fnd_installation.get_app_info ( 'GHR',
   	  		  	            l_prod_status,
	 				    l_industry,
  					    l_oracle_scheema );

	     if ( l_prod_status = 'I' ) then
	    	l_ghr_installed := 'Y';
	     else
        	l_ghr_installed := 'N';
	     end if;

-- bug 9234524 start
--	     if ( ( l_ghr_installed = 'N' )
--	     or (   l_ghr_installed = 'Y' and p_disable_range_overlap_check = FALSE) ) then
      if ( p_disable_range_overlap_check = FALSE ) then

	     open csr_row_overlap;
	     fetch csr_row_overlap into l_exists;

		if csr_row_overlap%found then
	             close csr_row_overlap;
                     fnd_message.set_name('PER','PER_34003_USER_ROW_OVERLAP');
		     fnd_message.raise_error ;
		end if ;

		close csr_row_overlap;
	     end if;
	end if;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_USER_ROWS_F.ROW_LOW_RANGE_OR_NAME' ,
          p_associated_column2 => 'PAY_USER_ROWS_F.ROW_HIGH_RANGE' ) then
	      raise;
       end if;

    when others then
       if csr_row_overlap%isopen then
      	    close csr_row_overlap;
       end if;
       raise;
end chk_range;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_display_sequence >---------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the display_sequence is numeric
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_display_sequence
--
--  Post Success:
--    Processing continues if the display_sequence is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the display_sequence is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_display_sequence
( p_display_sequence in number )
is
l_proc   varchar2(100) := g_package || 'chk_display_sequence';
--
Begin

	hr_utility.set_location('Entering:'|| l_proc, 10);
/* Bug fix: 4661747 : Added the if condition to this call */
        if(p_display_sequence is not NULL) then
	hr_dbchkfmt.is_db_format( p_display_sequence , 'DISPLAY_SEQUENCE' , 'I' );
	end if;

        hr_utility.set_location(' Leaving:'|| l_proc, 20);

Exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_USER_ROWS_F.DISPLAY_SEQUENCE' ) then
	      raise;
       end if;

    when others then
	raise;

end chk_display_sequence;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the
--	 1. For Delete Mode there are no child rows on or after
--	    validation_start_date
--	 2. For Zap Mode there are no child rows at all.
--	 3. For DELETE_NEXT_CHANGE and FUTURE_CHANGE modes deletion
--	    will not violate the uniqueness or overlap constraints.(Conditional)
--
--  Pre-Requisites:
--        None.
--
--  In Parameters:
--    p_user_row_id
--    p_user_table_id
--    p_row_low_range_or_name
--    p_row_high_range
--    p_datetrack_mode
--    p_disable_range_overlap_check - User supplied flag which indicates
--                                    whether range overlap check has to be
--				      carried out or not (Conditional)
--    p_legislation_code
--    p_business_group_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if the deletion is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the deletion is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_delete
(p_user_table_id in number
,p_user_row_id in number
,p_row_low_range_or_name in varchar2
,p_row_high_range in varchar2
,p_datetrack_mode in varchar2
,p_business_group_id in number
,p_legislation_code in varchar2
,p_disable_range_overlap_check in boolean
,p_validation_start_date in date
,p_validation_end_date in date
)is
--
cursor csr_unique_name is
  select null
  from   pay_user_rows_f  usr
  where  usr.user_table_id = p_user_table_id
  and    upper(usr.row_low_range_or_name) = upper(p_row_low_range_or_name)
  and    ( p_user_row_id is null
 	 or ( p_user_row_id is not null and usr.user_row_id <> p_user_row_id ) )
  and    ( p_business_group_id is null
          or ( p_business_group_id is not null and p_business_group_id = usr.business_group_id )
   	  or ( p_business_group_id is not null and
			usr.legislation_code is null and usr.business_group_id is null )
	  or ( p_business_group_id is not null and
		        usr.legislation_code = hr_api.return_legislation_code(p_business_group_id ) ))
  and    ( p_legislation_code is null
	  or ( p_legislation_code is not null and p_legislation_code = usr.legislation_code )
	  or ( p_legislation_code is not null and
			usr.legislation_code is null and usr.business_group_id is null)
	  or ( p_legislation_code is not null and
			p_legislation_code = hr_api.return_legislation_code(usr.business_group_id ) ))
  and    ( usr.effective_start_date <= p_validation_end_date and
			usr.effective_end_date >= p_validation_start_date );

cursor csr_row_overlap is
  select null
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    ( p_user_row_id is null
		or ( p_user_row_id is not null and usr.user_row_id <> p_user_row_id ) )
  and    ( p_business_group_id is null
          or ( p_business_group_id is not null and p_business_group_id = usr.business_group_id )
   	  or ( p_business_group_id is not null and
			usr.legislation_code is null and usr.business_group_id is null )
	  or ( p_business_group_id is not null and
		        usr.legislation_code = hr_api.return_legislation_code(p_business_group_id ) ))
  and    ( p_legislation_code is null
	  or ( p_legislation_code is not null and p_legislation_code = usr.legislation_code )
	  or ( p_legislation_code is not null and
			usr.legislation_code is null and usr.business_group_id is null)
	  or ( p_legislation_code is not null and
			p_legislation_code = hr_api.return_legislation_code(usr.business_group_id ) ))
  and    (fnd_number.canonical_to_number(p_row_low_range_or_name) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range)
  or     (fnd_number.canonical_to_number(p_row_high_range) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range))
  or     (fnd_number.canonical_to_number(usr.row_low_range_or_name) between
          fnd_number.canonical_to_number(p_row_low_range_or_name) and fnd_number.canonical_to_number(p_row_high_range))
  or     (fnd_number.canonical_to_number(usr.row_high_range) between
          fnd_number.canonical_to_number(p_row_low_range_or_name) and fnd_number.canonical_to_number(p_row_high_range)))
  and    ( usr.effective_start_date <= p_validation_end_date and
			usr.effective_end_date >= p_validation_start_date );

cursor csr_zap_mode is
   select null
   from   pay_user_column_instances_f
   where  user_row_id = p_user_row_id ;

cursor csr_delete_mode is
   select null
   from   pay_user_column_instances_f
   where  user_row_id         = p_user_row_id
   and    effective_end_date >= p_validation_start_date  ;


l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_delete';
l_result boolean;
l_range_or_match PAY_USER_TABLES.RANGE_OR_MATCH%TYPE;
l_prod_status    varchar2(1);
l_ghr_installed  varchar2(1);
l_industry	 varchar2(1);
l_oracle_scheema varchar2(30);

--
Begin

	hr_utility.set_location('Entering:'|| l_proc, 10);

	if p_disable_range_overlap_check is null then
		fnd_message.set_name('PAY', 'HR_7207_API_MANDATORY_ARG');
		fnd_message.set_token('API_NAME', l_proc);
		fnd_message.set_token('ARGUMENT','DISABLE_RANGE_OVERLAP_CHECK');
		fnd_message.raise_error;
	end if;

	if p_datetrack_mode = hr_api.g_delete then

		open csr_delete_mode;
		fetch csr_delete_mode into l_exists;
		if csr_delete_mode%found then
		       close csr_delete_mode;
		       fnd_message.set_name( 'PAY', 'PAY_6982_USERTAB_END_VALUES' );
		       fnd_message.raise_error;
		end if;
		close csr_delete_mode;

	elsif p_datetrack_mode = hr_api.g_zap then

		open csr_zap_mode;
		fetch csr_zap_mode into l_exists ;
	        if csr_zap_mode%found then
		       close csr_zap_mode;
		       fnd_message.set_name( 'PAY', 'HR_6980_USERTAB_VALUES_FIRST' ) ;
		       fnd_message.set_token( 'ROWCOL' , 'row' ) ;
		       fnd_message.raise_error ;
		end if ;
		close csr_zap_mode;

	elsif  p_datetrack_mode in (hr_api.g_future_change,hr_api.g_delete_next_change) then


       	     l_result := fnd_installation.get_app_info ( 'GHR',
 	  				                 l_prod_status,
	 				                 l_industry,
  					                 l_oracle_scheema );

	     if ( l_prod_status = 'I' ) then
	    	l_ghr_installed := 'Y';
	     else
        	l_ghr_installed := 'N';
	     end if;

             l_range_or_match := return_range_or_match(p_user_table_id);

	     if ( l_ghr_installed = 'N'
		or ( l_ghr_installed = 'Y' and l_range_or_match = 'M' )
		or ( l_ghr_installed = 'Y' and p_disable_range_overlap_check = FALSE ) ) then

			open csr_unique_name;
			fetch csr_unique_name into l_exists;

			if csr_unique_name%found then
		             close csr_unique_name;
      			     fnd_message.set_name ('PAY','HR_72033_CANNOT_DNC_RECORD');
			     fnd_message.raise_error ;
			end if;
			close csr_unique_name;
	     end if;

	     if ( l_range_or_match = 'R'
		  and ( l_ghr_installed = 'N'
		         or ( l_ghr_installed = 'Y' and p_disable_range_overlap_check = FALSE))) then

		open csr_row_overlap;
		fetch csr_row_overlap into l_exists;

		if csr_row_overlap%found then
	             close csr_row_overlap;
		     fnd_message.set_name ('PAY','HR_72033_CANNOT_DNC_RECORD');
		     fnd_message.raise_error ;
		end if ;

		close csr_row_overlap;
	     end if;
	end if;

        hr_utility.set_location(' Leaving:'|| l_proc, 20);
Exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_USER_ROWS_F.USER_ROW_ID') then
	      raise;
       end if;

    when others then
       if csr_unique_name%isopen then
      	    close csr_unique_name;
       end if;

       if csr_row_overlap%isopen then
      	    close csr_row_overlap;
       end if;

       if csr_zap_mode%isopen then
      	    close csr_zap_mode;
       end if;

       if csr_delete_mode%isopen then
      	    close csr_delete_mode;
       end if;

       raise;

End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date  in date
  ,p_rec             in pay_pur_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_pur_shd.api_updating
      (p_user_row_id                      => p_rec.user_row_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  if nvl(p_rec.user_table_id, hr_api.g_number) <>
     pay_pur_shd.g_old_rec.user_table_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'USER_TABLE_ID'
     ,p_base_table => pay_pur_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_pur_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BUSINESS_GROUP_ID'
     ,p_base_table => pay_pur_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_pur_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'LEGISLATION_CODE'
     ,p_base_table => pay_pur_shd.g_tab_nam
     );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

End chk_non_updateable_args;
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
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
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
    --
  --
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
  (p_user_row_id                      in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
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
      ,p_argument       => 'user_row_id'
      ,p_argument_value => p_user_row_id
      );
    --
  --
    --
  End If;
  --
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
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode

  IF (p_insert) THEN

    if p_business_group_id is not null and p_legislation_code is not null then
	fnd_message.set_name('PAY', 'PAY_33179_BGLEG_INVALID');
        fnd_message.raise_error;
    end if;

    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in out nocopy pay_pur_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_disable_units_check   in boolean
  ,p_disable_range_overlap_check in boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Clearing the Global variables since the record may have changed.
  --
  g_user_key_units := NULL;
  g_range_or_match := NULL;
  --
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_pur_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;

  END IF;
  --

  if hr_startup_data_api_support.g_startup_mode not in ('GENERIC','USER') then

     --
     -- Validate Important Attributes
     --
        chk_legislation_code(p_legislation_code => p_rec.legislation_code);
     --
        hr_multi_message.end_validation_set;

  end if;
  --
  --
  -- Validate Dependent Attributes
  --

  chk_user_table_id
  (p_user_table_id     => p_rec.user_table_id
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code  => p_rec.legislation_code
  );

  chk_row_low_range_or_name
  (p_user_row_id => p_rec.user_row_id
  ,p_user_table_id => p_rec.user_table_id
  ,p_row_low_range_or_name => p_rec.row_low_range_or_name
  ,p_object_version_number => p_rec.object_version_number
  ,p_disable_units_check   => p_disable_units_check
  ,p_disable_range_overlap_check   => p_disable_range_overlap_check
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code => p_rec.legislation_code
  ,p_effective_date => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );
  --
  --
  chk_display_sequence( p_display_sequence => p_rec.display_sequence );
  --
  --
  chk_row_high_range
  ( p_row_high_range => p_rec.row_high_range
   ,p_user_table_id  => p_rec.user_table_id
   ,p_user_row_id    => p_rec.user_row_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_effective_date => p_effective_date
  );
  --
  --
  chk_range
  ( p_user_row_id => p_rec.user_row_id
   ,p_user_table_id => p_rec.user_table_id
   ,p_row_low_range_or_name => p_rec.row_low_range_or_name
   ,p_row_high_range => p_rec.row_high_range
   ,p_disable_range_overlap_check => p_disable_range_overlap_check
   ,p_object_version_number => p_rec.object_version_number
   ,p_business_group_id => p_rec.business_group_id
   ,p_legislation_code => p_rec.legislation_code
   ,p_effective_date => p_effective_date
   ,p_validation_start_date => p_validation_start_date
   ,p_validation_end_date => p_validation_end_date
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in out nocopy pay_pur_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_disable_units_check     in boolean
  ,p_disable_range_overlap_check in boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Clearing the Global variables since the record may have changed.
  --
  g_user_key_units := NULL;
  g_range_or_match := NULL;
  --
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_pur_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  chk_row_low_range_or_name
  (p_user_row_id => p_rec.user_row_id
  ,p_user_table_id => p_rec.user_table_id
  ,p_row_low_range_or_name => p_rec.row_low_range_or_name
  ,p_object_version_number => p_rec.object_version_number
  ,p_disable_units_check   => p_disable_units_check
  ,p_disable_range_overlap_check   => p_disable_range_overlap_check
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code => p_rec.legislation_code
  ,p_effective_date => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );
  --
  --
  chk_display_sequence( p_display_sequence => p_rec.display_sequence );
  --
  --
  chk_row_high_range
  ( p_row_high_range => p_rec.row_high_range
   ,p_user_table_id  => p_rec.user_table_id
   ,p_user_row_id    => p_rec.user_row_id
   ,p_object_version_number => p_rec.object_version_number
   ,p_effective_date => p_effective_date
  );
  --
  --
  chk_range
  ( p_user_row_id => p_rec.user_row_id
   ,p_user_table_id => p_rec.user_table_id
   ,p_row_low_range_or_name => p_rec.row_low_range_or_name
   ,p_row_high_range => p_rec.row_high_range
   ,p_disable_range_overlap_check => p_disable_range_overlap_check
   ,p_object_version_number => p_rec.object_version_number
   ,p_business_group_id => p_rec.business_group_id
   ,p_legislation_code => p_rec.legislation_code
   ,p_effective_date => p_effective_date
   ,p_validation_start_date => p_validation_start_date
   ,p_validation_end_date => p_validation_end_date
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                           in pay_pur_shd.g_rec_type
  ,p_effective_date                in date
  ,p_datetrack_mode                in varchar2
  ,p_disable_range_overlap_check   in boolean
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Clearing the Global variables since the record may have changed.
  --
  g_user_key_units := NULL;
  g_range_or_match := NULL;
  --
  --
  chk_startup_action(false
                    ,pay_pur_shd.g_old_rec.business_group_id
                    ,pay_pur_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_user_row_id                      => p_rec.user_row_id
    );
  --
  --
  chk_delete
    (p_user_table_id => pay_pur_shd.g_old_rec.user_table_id
    ,p_user_row_id => p_rec.user_row_id
    ,p_row_low_range_or_name => pay_pur_shd.g_old_rec.row_low_range_or_name
    ,p_row_high_range => pay_pur_shd.g_old_rec.row_high_range
    ,p_datetrack_mode => p_datetrack_mode
    ,p_business_group_id => pay_pur_shd.g_old_rec.business_group_id
    ,p_legislation_code =>  pay_pur_shd.g_old_rec.legislation_code
    ,p_disable_range_overlap_check => p_disable_range_overlap_check
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date => p_validation_end_date
    );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_pur_bus;

/
