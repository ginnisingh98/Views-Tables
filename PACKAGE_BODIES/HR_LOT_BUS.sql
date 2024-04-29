--------------------------------------------------------
--  DDL for Package Body HR_LOT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOT_BUS" as
/* $Header: hrlotrhi.pkb 115.10 2002/12/04 05:45:04 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
-- Added for Bug 957239
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;

g_package  varchar2(33)	:= '  hr_lot_bus.';  -- Global package name
-- Proc Added for Bug 957239
-- ----------------------------------------------------------------------------
-- |---------------------------< set_translation_globals >--------------------|
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_location_code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the location code is unique within
--   its language and business_group (if set).  If the business_group_id is
--   null, the code must be unique within the language.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--
--     p_language_id
--     p_location_code
--     p_language
--     p_business_group_id
--
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
procedure chk_location_code
  (
    p_location_id                       in  number,
    p_location_code                     in  varchar2,
    p_language                          in  varchar2,
    p_business_group_id                 in  number,
    p_called_from_form                  in  boolean
  )
is
  -- Cursor to check whether a location_code is unique within
  -- a particular locations belonging to a particular business group
  -- and witin all global locations.  Used if p_business_group_id
  -- is NOT NULL
  -- 969354: Code check should be case insensitive
  --
  cursor csr_chk_location_codes is
    select null
      from hr_locations_all loc, hr_locations_all_tl lot
      where lot.location_id <> nvl(p_location_id, -99)
        and lot.language = p_language
        and upper(lot.location_code) = upper(p_location_code)
        and lot.location_id = loc.location_id
        and ( loc.business_group_id +0 is null
           or p_business_group_id is null
           or loc.business_group_id +0 = p_business_group_id );
  --
  --
    l_proc         varchar2(72) := g_package||'chk_location_code';
    l_exists       varchar2(1);
    l_api_updating  boolean;
  --
Begin
--
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   l_api_updating := hr_lot_shd.api_updating ( p_location_id,
                                               p_language);

   if (l_api_updating and nvl(hr_lot_shd.g_old_rec.location_code, hr_api.g_varchar2) <>
                              nvl(p_location_code, hr_api.g_varchar2) )
      or (NOT l_api_updating) THEN
      --
      -- See if location_code unique within all locations_codes
      -- for a particular language;
      --
      open csr_chk_location_codes;
      fetch csr_chk_location_codes into l_exists;
      --
      if csr_chk_location_codes%found then
         close csr_chk_location_codes;
         --
         -- The location code is not unique, so report error.
            if p_called_from_form then
              --
            -- If calling
            -- directly from form, use a differrent message (on the form,
   	    -- the field name for LOCATION_CODE is 'Name')
  	    --
            hr_utility.set_message(800, 'PER_52516_INV_LOCATION_NAME');
         else
   	    hr_utility.set_message(800, 'PER_52507_INV_LOCATION_CODE');
         end if;
         --
         hr_utility.raise_error;
      end if;
      --
      close csr_chk_location_codes;
      --
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
   --
end chk_location_code;
-- --
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_location_code overload >----------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the location code is unique within
--   its language and business_group (if set).  If the business_group_id is
--   null, the code must be unique within the language.
--
--  This version is overloaded as this versions is used instead of
--  hr_location_api.validate_translation call in perwsloc.fmb
-- Pre Conditions
--   None.
--
-- In Parameters
--
--     language_id
--     location_code
--     language
--     description ( dummy param ,used to allow the form to compile )
--
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the client
--
-- Access Status
--   Used for call from Client code
procedure chk_location_code(location_id IN NUMBER,
                               language IN VARCHAR2,
                               location_code IN VARCHAR2,
                               description IN VARCHAR2)
                               is
begin
-- Since this is just a wrapper for call from clients
-- there is no standard hr_utility.set_locations calls
-- This will make the proc transperant
hr_lot_bus.chk_location_code(
     p_location_id       => location_id
    ,p_location_code     => location_code
    ,p_language          => language
    ,p_business_group_id => g_business_group_id
    ,p_called_from_form  => TRUE
  );
end chk_location_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate ( p_rec                in hr_lot_shd.g_rec_type,
			    p_business_group_id  in number)
is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Location code must be unique within the set of codes
  -- with the same language and scope determined by
  -- business_group_id
  --
  -- p_location_id should always be NULL on insert.
  --
  chk_location_code
  (
    p_location_id         => p_rec.location_id,
    p_location_code       => p_rec.location_code,
    p_language            => p_rec.language,
    p_business_group_id   => p_business_group_id,
    p_called_from_form    => FALSE
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate( p_rec                in hr_lot_shd.g_rec_type,
			   p_business_group_id  in number )
is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Location code must be unique within the set of codes
  -- with the same language and scope determined by
  -- business_group_id
  --
  chk_location_code
   (
    p_location_id         => p_rec.location_id,
    p_location_code       => p_rec.location_code,
    p_language            => p_rec.language,
    p_business_group_id   => p_business_group_id,
    p_called_from_form    => FALSE
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_lot_shd.g_rec_type) is
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
end hr_lot_bus;

/
