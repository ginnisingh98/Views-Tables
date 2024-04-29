--------------------------------------------------------
--  DDL for Package Body PQH_STR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STR_BUS" as
/* $Header: pqstrrhi.pkb 115.10 2004/04/06 05:49 svorugan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_str_bus.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;

--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_stat_situation_rule_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_stat_situation_rule_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_fr_stat_situation_rules str
         , pqh_fr_stat_situations sts
      where str.stat_situation_rule_id = p_stat_situation_rule_id
      and str.statutory_situation_id = sts.statutory_situation_id
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
  End if;

  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'stat_situation_rule_id'
    ,p_argument_value     => p_stat_situation_rule_id
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
        => nvl(p_associated_column1,'STAT_SITUATION_RULE_ID')
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
  End if;

  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_stat_situation_rule_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , pqh_fr_stat_situation_rules str
         , pqh_fr_stat_situations sts
     where str.stat_situation_rule_id = p_stat_situation_rule_id
     	   and pbg.business_group_id = sts.business_group_id
     	   and sts.statutory_situation_id = str.statutory_situation_id;
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
  End if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'stat_situation_rule_id'
    ,p_argument_value     => p_stat_situation_rule_id
    );
  --
  if ( nvl(pqh_str_bus.g_stat_situation_rule_id, hr_api.g_number)
       = p_stat_situation_rule_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_str_bus.g_legislation_code;

  if g_debug then
  --
    hr_utility.set_location(l_proc, 20);
  --
  End if;

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
    End if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_str_bus.g_stat_situation_rule_id      := p_stat_situation_rule_id;
    pqh_str_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  End if;
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
  ,p_rec in pqh_str_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_str_shd.api_updating
      (p_stat_situation_rule_id            => p_rec.stat_situation_rule_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- No non-updateable args have
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< validations >----------------------------|
-- ----------------------------------------------------------------------------

Procedure validations
  (p_effective_date               in date
  ,p_rec                          in pqh_str_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'validations';
  l_value varchar2(10);





--
Begin

  if g_debug then
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;
  --




--
End validations;
--
procedure chk_validate_criteria(p_txn_category_attribute_id varchar2)
is
--
 Cursor csr_validate_criteria IS
  Select null
  from    pqh_txn_category_attributes txnAttrs,
          pqh_transaction_categories txnCats
  where txnAttrs.transaction_category_id = txnCats.transaction_category_id
      and txnCats.short_name ='FR_PQH_STAT_SIT_TXN'
      and txn_category_attribute_id = p_txn_category_attribute_id;
--
l_value varchar2(100) := null;
Begin

-- Validate Criteria (transaction category attribute)
	  Open csr_validate_criteria;
	  --
	  	Fetch csr_validate_criteria into l_value;

	  	IF csr_validate_criteria%NOTFOUND THEN
	  	--
	  	   fnd_message.set_name('PQH','PQH_FR_INVALID_CRITERIA');

      	 	   hr_multi_message.add(p_associated_column1=> 'TXN_CATEGORY_ATTRIBUTE_ID');
	  	--
	  	END If;
	  --
	 close csr_validate_criteria;

End chk_validate_criteria;
--
procedure chk_value_set_existence(p_txn_category_attribute_id varchar2)
is
 Cursor chk_value_set_existence(p_value_set_id varchar2) IS
 Select null
 from FND_FLEX_VALUE_SETS
 where flex_value_set_id = p_value_set_id;

 Cursor csr_get_value_style IS
 Select value_style_cd ,value_set_id
 from pqh_txn_category_attributes
 where txn_category_attribute_id = p_txn_category_attribute_id;
--
l_value varchar2(100) := null;
l_value_style_cd varchar2(100) := null;
l_value_set_id varchar2(100) := null;
Begin

        Open csr_get_value_style ;

         Fetch csr_get_value_style into l_value_style_cd, l_value_set_id;

         Close csr_get_value_style;

         if (l_value_style_cd ='EXACT' and l_value_set_id is not null) then
         --
           Open chk_value_set_existence(l_value_set_id);
      	 	  --
      	 	  	Fetch chk_value_set_existence into l_value;

      	 	  	IF chk_value_set_existence%NOTFOUND THEN
      	 	  	--
      	 	  	   fnd_message.set_name('PQH','PQH_FR_INVALID_VALUESET');
                           fnd_message.set_token('FIELD','FROM_VALUE');

      	 	  	   hr_multi_message.add(p_associated_column1=> 'FROM_VALUE');
      	 	  	--
      	 	  	END If;
      	 	  --
	 close chk_value_set_existence;
	 --
	 End if;

End chk_value_set_existence;

Procedure  chk_to_value(p_txn_category_attribute_id number, p_to_value varchar2)
is

 Cursor csr_get_value_style IS
 Select value_style_cd
 from pqh_txn_category_attributes
 where txn_category_attribute_id = p_txn_category_attribute_id;
 --
 l_value_style_cd varchar2(1000);
Begin

                 if p_to_value is not null then
                 --
                         Open csr_get_value_style ;

		          Fetch csr_get_value_style into l_value_style_cd;

		          Close csr_get_value_style;

		          if (l_value_style_cd = 'EXACT') then

		          --
		           fnd_message.set_name('PQH','PQH_FR_INVALID_TO_VALUE');
			       		       hr_multi_message.add
		           (p_associated_column1 => 'TO_VALUE');
		          --
		          end if;

		--
                 end if;

                 --



End chk_to_value;


Procedure chk_from_value (p_txn_category_attribute_id number, p_from_value varchar2,p_to_value varchar2)
is
--
Cursor csr_get_txn_record IS
Select value_style_cd
from pqh_txn_category_attributes
where txn_category_attribute_id = p_txn_category_attribute_id;
--
l_value_style_cd pqh_txn_category_attributes.value_style_cd%type;
--
begin
--
         Open csr_get_txn_record ;
           --
             Fetch csr_get_txn_record into l_value_style_cd;
            --
         Close csr_get_txn_record;


	if pqh_fr_stat_sit_util.Is_input_is_valid
	              (p_txn_category_attribute_id, p_from_value) = 'N' then
	              --
		           fnd_message.set_name('PQH','PQH_FR_INVALID_VALUE');
			       		       fnd_message.set_token('ATTRIBUTE',p_from_value);
			       		       hr_multi_message.add
		           (p_associated_column1 => 'FROM_VALUE');
		      --
         else
                   If (l_value_style_cd = 'RANGE') Then
                   --
                      if (to_number(p_from_value) <=0 ) then
                      --
                       fnd_message.set_name('PQH','PQH_FR_STAT_SIT_VALGRT_ZERO');
                       hr_multi_message.add(p_associated_column1=>'FROM_VALUE_MEANING');
                      --
                      end if;
                  --
                 end if;
       end if;

end ;

Procedure chk_from_to_value (p_txn_category_attribute_id number, p_from_value varchar2, p_to_value varchar2)
is
l_from_value number;
l_to_value number;
l_field_name varchar2(100);
begin

 if (p_from_value is not null and p_to_value is not null) then
    --
     if pqh_fr_stat_sit_util.Is_input_is_valid
                      (p_txn_category_attribute_id, p_from_value) = 'Y'
        and   pqh_fr_stat_sit_util.Is_input_is_valid
                      (p_txn_category_attribute_id, p_to_value) = 'Y' then
                --
                -- Check input values are number or not
               Begin
                --
                  l_field_name := 'FROM_VALUE';
                  l_from_value := to_number(p_from_value);
                  l_field_name := 'TO_VALUE';
                  l_to_value   := to_number(p_to_value);

                  if ( to_number(p_from_value) > to_number(p_to_value) )
                    then
                    --
                      fnd_message.set_name('PQH','PQH_FR_STAT_CRIT_FROM_TO_ERR');
                      hr_multi_message.add (p_associated_column1 => 'TO_VALUE');
                   --
                   end if;
               Exception
                when others then
                   fnd_message.set_name('PQH','PQH_FR_STAT_CRIT_INVALID_FRMTO');
                   fnd_message.set_token('FIELD_NAME',hr_general.decode_lookup('FR_PQH_FORM_PROMPTS',l_field_name));
                      hr_multi_message.add (p_associated_column1 => 'TO_VALUE');
             End;

    --
   End if;
 --
 End if;

end chk_from_to_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_str_shd.g_rec_type
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
    pqh_sts_bus.set_security_group_id
     (
      p_statutory_situation_id => p_rec.statutory_situation_id
     );
  -- Validate Dependent Attributes

  hr_multi_message.end_validation_set;
  --
  chk_value_set_existence(p_rec.txn_category_attribute_id);

  chk_validate_criteria(p_rec.txn_category_attribute_id);


  chk_from_value (p_rec.txn_category_attribute_id, p_rec.from_value,p_rec.to_value);


  chk_to_value(p_rec.txn_category_attribute_id,p_rec.to_value);

  hr_multi_message.end_validation_set;

   chk_from_to_value(p_rec.txn_category_attribute_id, p_rec.from_value,p_rec.to_value);

  hr_multi_message.end_validation_set;
  --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_str_shd.g_rec_type
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

  pqh_sts_bus.set_security_group_id
   (
    p_statutory_situation_id => p_rec.statutory_situation_id
   );

   hr_multi_message.end_validation_set;

   --

   chk_validate_criteria(p_rec.txn_category_attribute_id);

   chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

   hr_multi_message.end_validation_set;

   chk_from_value (p_rec.txn_category_attribute_id, p_rec.from_value,p_rec.to_value);

   chk_to_value(p_rec.txn_category_attribute_id,p_rec.to_value);

   hr_multi_message.end_validation_set;

    chk_from_to_value(p_rec.txn_category_attribute_id, p_rec.from_value,p_rec.to_value);

  hr_multi_message.end_validation_set;
  --
  --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_str_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
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
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

End delete_validate;
--
end pqh_str_bus;

/
