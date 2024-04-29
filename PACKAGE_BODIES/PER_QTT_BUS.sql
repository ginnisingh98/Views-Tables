--------------------------------------------------------
--  DDL for Package Body PER_QTT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QTT_BUS" as
/* $Header: peqttrhi.pkb 115.2 2003/05/13 06:22:26 fsheikh noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_qtt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_qualification_type_id       number         default null;
g_language                    varchar2(4)    default null;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qualification_name >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_name_unique( p_qualification_type_id in    number
                         , p_language              in    varchar2
                         , p_name                  in    varchar2
                         ) is
  --
  l_proc  varchar2(72) := g_package||'chk_name_unique';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select 'x'
    from   per_qualification_types_tl qtt
    where  qtt.name = p_name
      and  qtt.language = p_language
      and  ( (p_qualification_type_id is null)
             or
              p_qualification_type_id <> qtt.qualification_type_id
           );
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_qtt_shd.api_updating
    (p_qualification_type_id => p_qualification_type_id,
     p_language => p_language
    );
  --

  if (  (l_api_updating and (per_qtt_shd.g_old_rec.name
		        <> nvl(p_name,hr_api.g_varchar2))
         ) or
        (NOT l_api_updating)
      ) then
    --
    if p_name is null then
      --
      -- raise error
      --
      hr_utility.set_message(801, 'HR_51536_EQT_NAME_UK');
      hr_utility.raise_error;
      --
    end if;
    --
    -- check if the qualification name exists in the per_qualification_types
    -- table.
    --
    open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
        --
        -- raise error
        --
      close c1;
      hr_utility.set_message(801, 'HR_51536_EQT_NAME_UK');
      hr_utility.raise_error;
      --
    end if;
    --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);

end chk_name_unique;
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
  (p_rec in per_qtt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_qtt_shd.api_updating
      (p_qualification_type_id             => p_rec.qualification_type_id
      ,p_language                          => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- No non-updateable args
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------<  validate_translation>--------------------------|
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_rec                          in per_qtt_shd.g_rec_type
  ,p_qualification_type_id        in per_qualification_types_tl.qualification_type_id%TYPE default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Get any required base table values here
  -- (none)
  --
  validate_translation
    (p_qualification_type_id          => p_rec.qualification_type_id
    ,p_language                       => p_rec.language
    ,p_name                           => p_rec.name
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_qtt_shd.g_rec_type
  ,p_qualification_type_id        in per_qualification_types_tl.qualification_type_id%TYPE
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- PMFLETCH - Implemented as per base table
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  -- Fix for bug 2723065
  -- Commented line which hardcodes security profile to '0'
  -- hr_api.set_security_group_id(p_security_group_id => 0);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  validate_translation
    ( p_rec
    , p_qualification_type_id
    );
  --
  -- Validate Dependent Attributes
  -- None
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_qtt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- PMFLETCH - Implemented as per base table
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  -- Fix for bug 2723065
  -- Commented line which hardcodes security profile to '0'
  -- hr_api.set_security_group_id(p_security_group_id => 0);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  --
  validate_translation
    ( p_rec
    );
  --
  -- Validate Dependent Attributes
  -- None
  --
  chk_non_updateable_args
    (p_rec              => p_rec
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
  (p_rec                          in per_qtt_shd.g_rec_type
  ) is
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
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_translation >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs the validation for the MLS widget.
--
-- Prerequisites:
--   This procedure is called from from the MLS widget.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_qualification_type_id          in number
  ,p_language                       in varchar2
  ,p_name                           in varchar2
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  chk_name_unique
    ( p_qualification_type_id       => p_qualification_type_id
    , p_language                    => p_language
    , p_name                        => p_name
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END;
--
end per_qtt_bus;

/
