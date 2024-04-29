--------------------------------------------------------
--  DDL for Package Body PQH_STS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STS_BUS" as
/* $Header: pqstsrhi.pkb 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_sts_bus.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;

--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_statutory_situation_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_statutory_situation_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_fr_stat_situations sts
     where sts.statutory_situation_id = p_statutory_situation_id
       and pbg.business_group_id = sts.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  end if;

  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'statutory_situation_id'
    ,p_argument_value     => p_statutory_situation_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'STATUTORY_SITUATION_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  end if;
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_statutory_situation_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_fr_stat_situations sts
     where sts.statutory_situation_id = p_statutory_situation_id
       and pbg.business_group_id = sts.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'statutory_situation_id'
    ,p_argument_value     => p_statutory_situation_id
    );
  --
  if ( nvl(pqh_sts_bus.g_statutory_situation_id, hr_api.g_number)
       = p_statutory_situation_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_sts_bus.g_legislation_code;

    if g_debug then
    --
    hr_utility.set_location(l_proc, 20);
    --
    end if;
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

    if g_debug then
    --
    hr_utility.set_location(l_proc,30);
    --
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_sts_bus.g_statutory_situation_id      := p_statutory_situation_id;
    pqh_sts_bus.g_legislation_code  := l_legislation_code;
  end if;

  if g_debug then
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  end if;

  return l_legislation_code;
end return_legislation_code;
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
  (p_effective_date               in date
  ,p_rec in pqh_sts_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_status   varchar2(10) := null;
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_sts_shd.api_updating
      (p_statutory_situation_id            => p_rec.statutory_situation_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  if nvl(p_rec.business_group_id, hr_api.g_number) <>
  	     nvl(pqh_sts_shd.g_old_rec.business_group_id
  	        ,hr_api.g_number
  	        ) then
  	    hr_api.argument_changed_error
  	      (p_api_name   => l_proc
  	      ,p_argument   => 'BUSINESS_GROUP_ID'
  	      ,p_base_table => pqh_sts_shd.g_tab_nam
  	      );
  end if;

-- Type_Of_PS

  if nvl(p_rec.type_of_ps, hr_api.g_varchar2) <>
    	     nvl(pqh_sts_shd.g_old_rec.type_of_ps
    	        ,hr_api.g_varchar2
    	        ) then
    	    hr_api.argument_changed_error
    	      (p_api_name   => l_proc
    	      ,p_argument   => 'TYPE_OF_PS'
    	      ,p_base_table => pqh_sts_shd.g_tab_nam
    	      );
  end if;

-- Situation Type

   if nvl(p_rec.situation_type, hr_api.g_varchar2) <>
     	     nvl(pqh_sts_shd.g_old_rec.situation_type
     	        ,hr_api.g_varchar2
     	        ) then
     	    hr_api.argument_changed_error
     	      (p_api_name   => l_proc
     	      ,p_argument   => 'SITUATION_TYPE'
     	      ,p_base_table => pqh_sts_shd.g_tab_nam
     	      );
   end if;

-- Sub Type
   if nvl(p_rec.sub_type, hr_api.g_varchar2) <>
     	     nvl(pqh_sts_shd.g_old_rec.sub_type
     	        ,hr_api.g_varchar2
     	        ) then
     	    hr_api.argument_changed_error
     	      (p_api_name   => l_proc
     	      ,p_argument   => 'SUB_TYPE'
     	      ,p_base_table => pqh_sts_shd.g_tab_nam
     	      );
   end if;

-- Source
   if nvl(p_rec.source, hr_api.g_varchar2) <>
     	     nvl(pqh_sts_shd.g_old_rec.source
     	        ,hr_api.g_varchar2
     	        ) then
     	    hr_api.argument_changed_error
     	      (p_api_name   => l_proc
     	      ,p_argument   => 'SOURCE'
     	      ,p_base_table => pqh_sts_shd.g_tab_nam
     	      );
   end if;

-- Location
   if nvl(p_rec.location, hr_api.g_varchar2) <>
     	     nvl(pqh_sts_shd.g_old_rec.location
     	        ,hr_api.g_varchar2
     	        ) then
     	    hr_api.argument_changed_error
     	      (p_api_name   => l_proc
     	      ,p_argument   => 'LOCATION'
     	      ,p_base_table => pqh_sts_shd.g_tab_nam
     	      );
   end if;

-- Reason
   if nvl(p_rec.reason, hr_api.g_varchar2) <>
     	     nvl(pqh_sts_shd.g_old_rec.reason
     	        ,hr_api.g_varchar2
     	        ) then
     	    hr_api.argument_changed_error
     	      (p_api_name   => l_proc
     	      ,p_argument   => 'REASON'
     	      ,p_base_table => pqh_sts_shd.g_tab_nam
     	      );
   end if;

  --
End chk_non_updateable_args;
--

procedure chk_renewable(p_max_no_of_renewals in number,
		 	p_max_duration_per_renewal in number,
		 	p_renewable_allowed in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_renewable';
l_value varchar2(100);
--
begin
--
		if ( p_max_no_of_renewals is not null or
				p_max_duration_per_renewal is not null ) then

				if (p_renewable_allowed = 'N') then
							  --

						 fnd_message.set_name('PQH','PQH_FR_VALUE_NOT_ALLOWED');
				   		 fnd_message.set_token('ATTRIBUTE','MAX_NO_OF_RENEWALS');

				   		 hr_multi_message.add(p_associated_column1=> 'MAX_NO_OF_RENEWALS',
				   		                      p_associated_column2=> 'MAX_DURATION_PER_RENEWAL');
	   		     	end if;
		 end if;

end chk_renewable;
--
procedure chk_duration_limits(p_rec in pqh_sts_shd.g_rec_type)
is
--
l_proc  varchar2(72) := g_package||'chk_duration_limits';
l_value varchar2(100);
--
begin
	if ( 	p_rec.FIRST_PERIOD_MAX_DURATION is not null or
			p_rec.MIN_DURATION_PER_REQUEST is not null or
			p_rec.MAX_DURATION_PER_REQUEST is not null or
			p_rec.MAX_DURATION_WHOLE_CAREER is not null or
			p_rec.RENEWABLE_ALLOWED = 'Y' or
			p_rec.MAX_NO_OF_RENEWALS is not null or
			p_rec.MAX_DURATION_PER_RENEWAL is not null or
			p_rec.MAX_TOT_CONTINUOUS_DURATION is not null ) then
		--
			if (p_rec.FREQUENCY is null ) then
			  --
		     		fnd_message.set_name('PQH','PQH_FR_FREQUENCY_MUST_SELECT');

   		     		 hr_multi_message.add(p_associated_column1=> 'FREQUENCY_NAME');
   		     	end if;
   		     	--
   	end if;

end chk_duration_limits;
--
--
procedure chk_frequency(p_frequency varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_frequency';
l_value varchar2(100);
--
    Cursor csr_frequency IS
       Select null
             from hr_lookups
             Where Lookup_type='PROC_PERIOD_TYPE'
             and ENABLED_FLAG='Y'
         and lookup_code = p_frequency;
--

begin

  if (p_frequency is not null) then
        --
	Open csr_frequency;
   		  --
   		    Fetch csr_frequency into l_value;

   		    if csr_frequency%NOTFOUND then
   		    --
   		        fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
   		        fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','FREQUENCY'));

   		        hr_multi_message.add(p_associated_column1=> 'FREQUENCY_NAME');
   		    end if;
   		  --
   		Close csr_frequency;
         --
         end if;

end chk_frequency;
--
procedure chk_remuneration_paid(p_pay_share in number , p_pay_periods number ,
				p_remuneration_paid varchar2 )
is
--
l_proc  varchar2(72) := g_package||'chk_remuneration_paid';
l_value varchar2(100);
--

--

begin

	 	if ( p_pay_share is not null or
	 			p_pay_periods is not null) then
	 		--
	 			if (p_remuneration_paid = 'N') then
	 			  --
	 		     		fnd_message.set_name('PQH','PQH_FR_VALUE_NOT_ALLOWED');
	    		     		fnd_message.set_token('ATTRIBUTE','PAY_SHARE');

	    		     		hr_multi_message.add(p_associated_column1=> 'REMUNERATION_PAID');
	    		     	end if;
	    		     	--
   		end if;

end chk_remuneration_paid;
--
procedure chk_date(p_date_from in date, p_date_to in date)
is
--
l_proc  varchar2(72) := g_package||'chk_date_check';
l_value varchar2(100);
--

--

begin
           If (p_date_to is not null) then
                   --
   		if (trunc(p_date_from) > trunc(p_date_to)) then
   		--
   		      fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE_DATE_FROM');

      		      hr_multi_message.add(p_associated_column1=> 'DATE_TO');

      		--
      		end if;
      		--
   		End If;

end chk_date;
--
procedure chk_reason(p_reason in varchar2, p_situation_type in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_reason';
l_value varchar2(100);
--

         Cursor csr_reason IS
               Select null
               from hr_lookups
               where lookup_type ='FR_PQH_STAT_SIT_REASON'
               and lookup_code  like p_situation_type || '%'
               and lookup_code = p_reason
          and enabled_flag = 'Y';

--

begin

   		if (p_reason is not null) then
   		--
   		Open csr_reason;
   		  --
   		    Fetch csr_reason into l_value;

   		    if csr_reason%NOTFOUND then
   		    --
   		        fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
   		        fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','REASON'));

   		         hr_multi_message.add
				(p_associated_column1=> 'REASON');
   		    end if;
   		  --
   		Close csr_reason;
   		--
   		end if;

end chk_reason;
--
procedure chk_location(p_location in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_location';
l_value varchar2(100);
--
      Cursor csr_location IS
           Select null
           from hr_lookups
           Where Lookup_type='FR_PQH_STAT_SIT_PLCMENT'
           and ENABLED_FLAG='Y'
         and lookup_code = p_location;

--

begin

		If (p_location is not null) then
				--
		   		Open csr_location;
		   		  --
		   		    Fetch csr_location into l_value;

		   		    if csr_location%NOTFOUND then
		   		    --
		   		        fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
		   		        fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','LOCATION'));

		   		        hr_multi_message.add
				       		       (p_associated_column1
   			  		   				=> 'LOCATION');
		   		    end if;
		   		  --
		   		Close csr_location;
		   		--
   		End If;

end chk_location;
--

--
procedure chk_source(p_source in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_source';
l_value varchar2(100);
--
   Cursor csr_source IS
           Select null
           from hr_lookups
           Where Lookup_type='FR_PQH_STAT_SIT_SOURCE'
           and ENABLED_FLAG='Y'
           and lookup_code = p_source;

--

begin

		IF (p_source is not null) then
   		--
   		Open csr_source;
   		  --
   		    Fetch csr_source into l_value;

   		    if csr_source%NOTFOUND then
   		    --
   		        fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
   		        fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','SOURCE'));

   		       hr_multi_message.add
		          	    (p_associated_column1
   			  		   => 'SOURCE');
   		    end if;
   		  --
   		Close csr_source;
   		--
   		END If;

end chk_source;
--
--
procedure chk_sub_type(p_sub_type in varchar2, p_situation_type in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_sub_type';
l_value varchar2(100);
--
  Cursor csr_sub_type IS
     Select null
     from hr_lookups
     where lookup_type ='FR_PQH_STAT_SIT_SUB_TYPE'
     and lookup_code  like p_situation_type || '%'
     and lookup_code = p_sub_type
     and enabled_flag = 'Y';
--

begin


   if (p_sub_type is not null) then
   --
   Open csr_sub_type;

     Fetch csr_sub_type into l_value ;

     	If csr_sub_type%NOTFOUND then
   	 --
   	  	fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
   	  	fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','SUB_TYPE'));
   	  	hr_multi_message.add
   	    		(p_associated_column1
   			  		   => 'SUB_TYPE_NAME');
   	 --
   	End If;
     --
     End if;


end chk_sub_type;
--
--
procedure chk_pay_share (p_pay_share in number , p_remuneration_paid in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_pay_share';
--
begin

   if (p_pay_share < 0 or p_pay_share >100) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','PAY_SHARE'));
     hr_multi_message.add
       (p_associated_column1
        => 'PAY_SHARE');
    --
    elsif (p_pay_share >0 and p_remuneration_paid = 'N') then
                              --
        fnd_message.set_name('PQH','PQH_FR_STAT_CHECK_REMUNERATION');
        fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','PAY_SHARE'));
        hr_multi_message.add
                (p_associated_column1=> 'REMUNERATION_PAID');

        hr_multi_message.end_validation_set;
    --
   end if;


end chk_pay_share;
--
-- Pay Period Check
--
procedure chk_pay_periods (p_pay_periods in number , p_remuneration_paid in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_pay_periods';
--
begin

   if (p_pay_periods < 0) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','PAY_PERIODS'));
     hr_multi_message.add
       (p_associated_column1
        => 'PAY_PERIODS');
    --
    elsif (p_pay_periods >0 and p_remuneration_paid = 'N') then
                          --
                          fnd_message.set_name('PQH','PQH_FR_STAT_CHECK_REMUNERATION');
                          fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','PAY_PERIODS'));
                          hr_multi_message.add
                           (p_associated_column1=> 'REMUNERATION_PAID');
    --
   end if;
--
end chk_pay_periods;
--
-- first period max duration Check
--
procedure chk_first_period_max_duration (p_first_period_max_duration in number,
					p_frequency in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_first_period_max_duration';
--
begin

   if (p_first_period_max_duration < 0) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','FIRST_PERIOD_MAX_DURATION'));
     hr_multi_message.add
       (p_associated_column1
        => 'FIRST_PERIOD_MAX_DURATION');
    --
   end if;
--
end chk_first_period_max_duration;
--

procedure chk_min_duration_per_rqst (p_min_duration_per_request in number,
				p_frequency in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_min_duration_per_request';
--
begin

   if (p_min_duration_per_request < 0) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MIN_DURATION_PER_REQUEST'));
     hr_multi_message.add
       (p_associated_column1
        => 'MIN_DURATION_PER_REQUEST');
    --
   end if;
--
end chk_min_duration_per_rqst;
--

procedure chk_max_duration_per_request (p_max_duration_per_request in number,
				p_frequency in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_max_duration_per_request';
--
begin

   if (p_max_duration_per_request < 0) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MAX_DURATION_PER_REQUEST'));
     hr_multi_message.add
       (p_associated_column1
        => 'MAX_DURATION_PER_REQUEST');
    --
   end if;
--
end chk_max_duration_per_request;
--

procedure chk_max_duration_whole_crr (p_max_duration_whole_career in number,
					p_frequency in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_max_duration_whole_crr';
--
begin

   if (p_max_duration_whole_career < 0) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MAX_DURATION_WHOLE_CAREER'));
     hr_multi_message.add
       (p_associated_column1
        => 'MAX_DURATION_WHOLE_CAREER');
    --
   end if;
--
end chk_max_duration_whole_crr;
--


procedure chk_max_no_of_renewals (p_max_no_of_renewals in number, p_renewable_allowed in varchar2,
				p_frequency in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_max_no_of_renewals';
--
begin

   if (p_max_no_of_renewals < 0) then
   --
     fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
     fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MAX_NO_OF_RENEWALS'));
     hr_multi_message.add
       (p_associated_column1
        => 'MAX_NO_OF_RENEWALS');
    --
     elsif (p_max_no_of_renewals > 0 and p_renewable_allowed = 'N' ) then
        --
        --
            fnd_message.set_name('PQH','PQH_FR_STAT_RENEWABLE_ALLOWED');
            fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MAX_NO_OF_RENEWALS'));
            hr_multi_message.add
               (p_associated_column1
                => 'RENEWABLE_ALLOWED');

        hr_multi_message.end_validation_set;
      --
    end if;

--
end chk_max_no_of_renewals;
--


procedure chk_max_duration_per_renewal (p_max_duration_per_renewal in number,
		p_renewable_allowed in varchar2, p_frequency in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_max_duration_per_renewal';
--
begin


   if (p_max_duration_per_renewal < 0) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MAX_DURATION_PER_RENEWAL'));
     hr_multi_message.add
       (p_associated_column1
        => 'MAX_DURATION_PER_RENEWAL');
    --
  elsif (p_max_duration_per_renewal > 0 and p_renewable_allowed = 'N' ) then
    --
    --
        fnd_message.set_name('PQH','PQH_FR_STAT_RENEWABLE_ALLOWED');
        fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MAX_DURATION_PER_RENEWAL'));
        hr_multi_message.add
           (p_associated_column1
            => 'RENEWABLE_ALLOWED');
    --
 end if;

--
end chk_max_duration_per_renewal;


procedure chk_max_tot_continuous_dur (p_max_tot_continuous_duration in number,p_frequency in varchar2)
is
--
l_proc  varchar2(72) := g_package||'chk_max_tot_continuous_dur';
--
begin

   if (p_max_tot_continuous_duration is not null
                  and p_max_tot_continuous_duration < 0 ) then
   --
    fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
    fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','MAX_TOT_CONTINUOUS_DURATION'));
     hr_multi_message.add
       (p_associated_column1
        => ' MAX_TOT_CONTINUOUS_DURATION');
    --
   end if;
--
end chk_max_tot_continuous_dur;

---
-- Default check
---
procedure chk_default(p_rec in pqh_sts_shd.g_rec_type)
is
--
  l_proc  varchar2(72) := g_package||'chk_default';
  l_value varchar2(1000);
--
-- Situation Type + Type of PS + BG
 Cursor csr_chk_default IS
	Select null
 	from pqh_fr_stat_situations
 	where
 	type_of_ps = p_rec.type_Of_ps
 	and situation_type = p_rec.situation_type
 	and statutory_situation_id <> nvl(p_rec.statutory_situation_id,-1)
	and business_group_id = p_rec.business_group_id
        and default_flag = 'Y';
--
Begin
 if g_debug then
 --
  hr_utility.set_location('Entering:'||l_proc, 7);
 --
 end if;
 if(p_rec.is_default = 'Y') then

     		Open csr_chk_default;
     		  --
     		    Fetch csr_chk_default into l_value;

     		    if csr_chk_default%FOUND then
     		    --
     		       fnd_message.set_name('PQH','PQH_FR_STAT_DUP_DEFAULT');
     		       hr_multi_message.add
		           (p_associated_column1 => 'DEFAULT_FLAG');

     		    end if;
     		  --
     	        Close csr_chk_default;
end if;
--
End  chk_default;

--
-- Type of Public Sector Check
procedure chk_type_of_ps(p_type_of_ps in varchar2)
is
--
  l_proc  varchar2(72) := g_package||'chk_type_of_ps';
  l_value varchar2(1000);
--
  Cursor csr_type_of_ps IS
     Select null
     From per_shared_types_vl
     Where shared_type_id = to_number(p_type_of_ps);

--
Begin
 if g_debug then
 --
  hr_utility.set_location('Entering:'||l_proc, 7);
 --
 end if;

     		Open csr_type_of_ps;
     		  --
     		    Fetch csr_type_of_ps into l_value;

     		    if csr_type_of_ps%NOTFOUND then
     		    --
     		       fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
     		       fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','TYPE_OF_PS'));
     		       hr_multi_message.add
		           (p_associated_column1 => 'TYPE_OF_PS');

     		    end if;
     		  --
     	        Close csr_type_of_ps;
--
End  chk_type_of_ps;

--
-- Situation Type Check
procedure chk_situation_type(p_situation_type in varchar2)
is
--
  l_proc  varchar2(72) := g_package||'chk_situation_type';
  l_value varchar2(1000);
--
  Cursor csr_situation_type IS
     Select null
     from hr_lookups
     Where Lookup_type='FR_PQH_STAT_SIT_TYPE'
     and ENABLED_FLAG='Y'
     and lookup_code =p_situation_type;
--
Begin
 if g_debug then
 --
  hr_utility.set_location('Entering:'||l_proc, 7);
 --
 end if;

     		Open csr_situation_type;
     		  --
     		    Fetch csr_situation_type into l_value;

     		    if csr_situation_type%NOTFOUND then
     		    --
     		       fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
     		       fnd_message.set_token('ATTRIBUTE',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS','SITUATION_TYPE'));
     		       hr_multi_message.add
		           (p_associated_column1 => 'SITUATION_TYPE');

     		    end if;
     		  --
     	        Close csr_situation_type;
--
End  chk_situation_type;

--
procedure chk_unique_sitaution_name (p_rec in pqh_sts_shd.g_rec_type)
is
--
  l_proc  varchar2(72) := g_package||'chk_unique_sitaution_name';
  l_value varchar2(1000);
--
  Cursor csr_situation_name IS
       Select situation_name
       from pqh_fr_stat_situations
       where situation_name = p_rec.situation_name
       and business_group_id = p_rec.business_group_id
       and statutory_situation_id <> nvl(p_rec.statutory_situation_id,-1);
--
Begin
 if g_debug then
 --
  hr_utility.set_location('Entering:'||l_proc, 6);
 --
 End if;


        Open csr_situation_name;
  		--
  		  Fetch csr_situation_name into l_value;

  		  if csr_situation_name%found then
  		    --
  		      fnd_message.set_name('PQH','PQH_FR_UNIQUE_STAT_SIT_NAME');
		      hr_multi_message.add
		          (p_associated_column1
        			=> 'SITUATION_NAME');


  		  end if;

        Close csr_situation_name;

End  chk_unique_sitaution_name;

--
--
--
procedure chk_unique_sitaution (p_rec in pqh_sts_shd.g_rec_type)
is
--
  l_proc  varchar2(72) := g_package||'chk_unique_sitaution';
  l_value varchar2(1000);
--
  Cursor csr_unique_situation IS
 	Select null
 	from pqh_fr_stat_situations
 	where
 	type_of_ps = p_rec.type_Of_ps
 	and situation_type = p_rec.situation_type
 	and nvl(sub_type,'-1')    = nvl(p_rec.sub_type,'-1')
 	and nvl(source,'-1') = nvl(p_rec.source,'-1')
 	and nvl(location,'-1') = nvl(p_rec.location,'-1')
 	and nvl(reason,'-1')  = nvl(p_rec.reason,'-1')
	and business_group_id = p_rec.business_group_id
	and statutory_situation_id <> nvl(p_rec.statutory_situation_id,-1);
--
Begin
 if g_debug then
 --
  hr_utility.set_location('Entering:'||l_proc, 6);
 --
 End if;


        Open csr_unique_situation;
  		--
  		  Fetch csr_unique_situation into l_value;

  		   if csr_unique_situation%FOUND then
  		    --
  		     fnd_message.set_name('PQH','PQH_FR_UNIQUE_COMBINATION');
			hr_multi_message.add
				(p_associated_column1
					=> 'SITUATION_NAME');

  		    --
  		  end if;

        Close csr_unique_situation;

--
End  chk_unique_sitaution;
--
--
procedure chk_min_max_duration_rqst(p_min_duration_per_request in number,p_max_duration_per_request  in number)
is
--
l_proc  varchar2(72) := g_package||'chk_min_max_duration';
--
begin

  if (p_min_duration_per_request is not null and p_max_duration_per_request is not null) then
  --
   if nvl(p_min_duration_per_request,0) >
                   nvl(p_max_duration_per_request,0) then
   --
   --
    fnd_message.set_name('PQH','PQH_FR_STAT_MIN_MAX_PER_RQST');
    hr_multi_message.add
       (p_associated_column1=> 'MIN_DURATION_PER_REQUEST');
    --
   end if;
  --
  End if;
--
end chk_min_max_duration_rqst;
--
--
procedure chk_max_duration_in_whole(p_FIRST_PERIOD_MAX_DURATION in number, p_MAX_DURATION_WHOLE_CAREER in number)
is
--
l_proc  varchar2(72) := g_package||'chk_max_duration_in_whole';
--
begin

   if p_max_duration_whole_career is not null and p_first_period_max_duration is not null then
   --
    if nvl(p_max_duration_whole_career,0) < nvl(p_first_period_max_duration,0)   then
   --
    fnd_message.set_name('PQH','PQH_FR_STAT_DURATION_WHOLE');
    hr_multi_message.add
       (p_associated_column1=> 'FIRST_PERIOD_MAX_DURATION');
    --
   end if;
   --
   end if;
--
end chk_max_duration_in_whole;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin

 if g_debug then
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 End if;
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_sts_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  --
  hr_multi_message.end_validation_set;

  chk_unique_sitaution_name(p_rec);

  chk_type_of_ps(p_rec.type_of_ps);

  chk_situation_type(p_rec.situation_type);

  chk_sub_type(p_rec.sub_type,p_rec.situation_type);

  chk_source(p_rec.source);

  chk_reason(p_rec.reason, p_rec.situation_type);

  chk_default(p_rec);

  chk_location(p_rec.location);

  chk_frequency (p_rec.frequency);

  hr_multi_message.end_validation_set;

  chk_unique_sitaution(p_rec);

  hr_multi_message.end_validation_set;

  chk_duration_limits(p_rec);


  hr_multi_message.end_validation_set;

  -- Number filed checks
  chk_min_max_duration_rqst(p_rec.MIN_DURATION_PER_REQUEST,p_rec.MAX_DURATION_PER_REQUEST);

  chk_max_duration_in_whole(p_rec.FIRST_PERIOD_MAX_DURATION,p_rec.MAX_DURATION_WHOLE_CAREER);

  hr_multi_message.end_validation_set;

  chk_date(p_rec.date_from , p_rec.date_to);

  chk_pay_share(p_rec.pay_share,p_rec.remuneration_paid);

  chk_pay_periods(p_rec.pay_periods,p_rec.remuneration_paid);

  chk_first_period_max_duration(p_rec.first_period_max_duration,p_rec.frequency);

  chk_min_duration_per_rqst(p_rec.min_duration_per_request,p_rec.frequency);

  chk_max_duration_per_request(p_rec.max_duration_per_request,p_rec.frequency);

  chk_max_duration_whole_crr(p_rec.max_duration_whole_career,p_rec.frequency);

  chk_max_no_of_renewals(p_rec.max_no_of_renewals,p_rec.renewable_allowed,p_rec.frequency);

  chk_max_duration_per_renewal(p_rec.max_duration_per_renewal,p_rec.renewable_allowed,p_rec.frequency);

  chk_max_tot_continuous_dur(p_rec.max_tot_continuous_duration,p_rec.frequency);

  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
 if g_debug then
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
 end if;
 --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
 if g_debug then
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 End if;
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_sts_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
   hr_multi_message.end_validation_set;

   chk_unique_sitaution_name(p_rec);
   chk_default(p_rec);
   chk_date(p_rec.date_from , p_rec.date_to);

  -- Number filed checks

    chk_duration_limits(p_rec);

    hr_multi_message.end_validation_set;

    chk_min_max_duration_rqst(p_rec.MIN_DURATION_PER_REQUEST,p_rec.MAX_DURATION_PER_REQUEST);

    chk_max_duration_in_whole(p_rec.FIRST_PERIOD_MAX_DURATION,p_rec.MAX_DURATION_WHOLE_CAREER);

    chk_pay_share(p_rec.pay_share,p_rec.remuneration_paid);

    chk_pay_periods(p_rec.pay_periods,p_rec.remuneration_paid);

    chk_first_period_max_duration(p_rec.first_period_max_duration,p_rec.frequency);

    chk_min_duration_per_rqst(p_rec.min_duration_per_request,p_rec.frequency);

    chk_max_duration_per_request(p_rec.max_duration_per_request,p_rec.frequency);

    chk_max_duration_whole_crr(p_rec.max_duration_whole_career,p_rec.frequency);

    chk_max_no_of_renewals(p_rec.max_no_of_renewals,p_rec.renewable_allowed,p_rec.frequency);

    chk_max_duration_per_renewal(p_rec.max_duration_per_renewal,p_rec.renewable_allowed,p_rec.frequency);

    chk_max_tot_continuous_dur(p_rec.max_tot_continuous_duration,p_rec.frequency);


  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  hr_multi_message.end_validation_set;
  --
   if g_debug then
   --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
   --
   end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  --

   if g_debug then
   --
    hr_utility.set_location('Entering:'||l_proc, 5);
   --

  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

  End if;
End delete_validate;
--
end pqh_sts_bus;

/
