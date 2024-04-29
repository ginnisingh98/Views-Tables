--------------------------------------------------------
--  DDL for Package Body PER_GRA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GRA_BUS" as
/* $Header: pegrarhi.pkb 115.4 2003/08/31 00:48:34 kjagadee ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= ' per_gra_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_cagr_grade_id >-------------------------------|
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
--   cagr_grade_id PK of record being inserted or updated.
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_cagr_grade_id(p_cagr_grade_id                in number,
                            p_object_version_number        in number,
                            p_effective_date		   in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_cagr_grade_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_gra_shd.api_updating
    (p_cagr_grade_id                => p_cagr_grade_id,
     p_object_version_number        => p_object_version_number,
     p_effective_date		    => p_effective_date);
  --
  if (l_api_updating
     and nvl(p_cagr_grade_id,hr_api.g_number)
     <>  per_gra_shd.g_old_rec.cagr_grade_id) then
    --
    -- raise error as PK has changed
    --
    per_gra_shd.constraint_error('PER_CAGR_GRADES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cagr_grade_id is not null then
      --
      -- raise error as PK is not null
      --
      per_gra_shd.constraint_error('PER_CAGR_GRADES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cagr_grade_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_cagr_grade_structure_id >----------------------|
-- ----------------------------------------------------------------------------
--  Desciption :
--
--    Validates CAGR_GRADE_STRUCTURE_ID must be not null.
--    Validates that CAGR_GRADE_STRUCTURE_ID exits.
--
--  Pre-conditions:
--
--
--  In Arguments :
--    p_cagr_grade_structure_id
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_cagr_grade_structure_id(
		  p_cagr_grade_structure_id IN NUMBER
		 ) is
--
cursor crs_cgs is
  SELECT  '1'
    FROM  per_cagr_grade_structures cgs
      wHERE  cgs.cagr_grade_structure_id = p_cagr_grade_structure_id;
--
l_proc         varchar2(72) := g_package||'chk_cagr_grade_structure_id';
l_exists VARCHAR2(2);
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
     hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'cagr_grade_structure_id',
      p_argument_value => p_cagr_grade_structure_id);
   --
   hr_utility.set_location(l_proc,10);
   --
   OPEN crs_cgs;
   --
   FETCH crs_cgs INTO l_exists;
    hr_utility.set_location(l_proc,15);
   IF crs_cgs%notfound THEN
      fnd_message.set_name('PER','PER_52810_INVALID_STRUCTURE');
      CLOSE crs_cgs;
      fnd_message.raise_error;
   END IF;
   CLOSE crs_cgs;
   --
   hr_utility.set_location('Leaving:'||l_proc, 20);
   --
END chk_cagr_grade_structure_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_cagr_grade_def_id >----------------------------|
-- ----------------------------------------------------------------------------
--  Desciption :
--
--    Validates CAGR_GRADE_DEF_ID must be not null.
--    Validates that CAGR_GRADE_DEF_ID exits.
--
--  Pre-conditions:
--
--
--  In Arguments :
--    p_cagr_grade_def_id
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_cagr_grade_def_id(
		  p_cagr_grade_def_id IN NUMBER
		 ) is
--
cursor crs_cgd is
  SELECT  '1'
    FROM  per_cagr_grades_def cgs
      wHERE  cgs.cagr_grade_def_id = p_cagr_grade_def_id;
--
l_proc         varchar2(72) := g_package||'chk_cagr_grade_def_id';
l_exists VARCHAR2(2);
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
     hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'cagr_grade_def_id',
      p_argument_value => p_cagr_grade_def_id);
   --
   hr_utility.set_location(l_proc,10);
   --
   OPEN crs_cgd;
   --
   FETCH crs_cgd INTO l_exists;
    hr_utility.set_location(l_proc,15);
   IF crs_cgd%notfound THEN
      fnd_message.set_name('PER','PER_52616_INVALID_GRADE_DEF');
      CLOSE crs_cgd;
      fnd_message.raise_error;
   END IF;
   CLOSE crs_cgd;
   --
   hr_utility.set_location('Leaving:'||l_proc, 20);
   --
END chk_cagr_grade_def_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_sequence >-----------------------------------|
-- ---------------------------------------------------------------------------
--  Desciption :
--
--    Validates SEQUENCE must be not null.
--    Validates that SEQUENCE does not exit for a same structure.
--
--  Pre-conditions:
--
--
--  In Arguments :
--    p_cagr_grade_id
--    p_sequence
--    p_cagr_grades_structure_id
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_sequence(
		  p_cagr_grade_id IN NUMBER,
		  p_sequence IN NUMBER,
		  p_cagr_grade_structure_id IN NUMBER
		 ) IS
--
cursor c_all_seq IS
  SELECT  '1'
    FROM  per_cagr_grades cgs
      wHERE  cgs.cagr_grade_structure_id = p_cagr_grade_structure_id
      AND cgs.sequence = p_sequence
      AND (p_cagr_grade_id <> cgs.cagr_grade_id
           OR p_cagr_grade_id IS NULL);
--
l_proc         varchar2(72) := g_package||'chk_seq';
l_exists VARCHAR2(2);
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
     hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'sequence',
      p_argument_value => p_sequence);
   --
   hr_utility.set_location(l_proc,10);
   --
   OPEN c_all_seq;
   --
   FETCH c_all_seq INTO l_exists;
    hr_utility.set_location(l_proc,15);
   IF c_all_seq%FOUND THEN
      fnd_message.set_name('PAY','HR_7127_GRADE_DUP_SEQ');
      CLOSE c_all_seq;
      fnd_message.raise_error;
   END IF;
   CLOSE c_all_seq;
   --
   if p_sequence < 0 then
     fnd_message.set_name('PAY','PER_7833_DEF_GRADE_SEQUENCE');
     fnd_message.raise_error;
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 20);
   --
END chk_sequence;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_gra_shd.g_rec_type,
			  p_effective_date   in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_cagr_grade_id
  (p_cagr_grade_id          => p_rec.cagr_grade_id,
   p_object_version_number  => p_rec.object_version_number,
   p_effective_date	    => p_effective_date);
  --
  chk_cagr_grade_structure_id
  (p_cagr_grade_structure_id    => p_rec.cagr_grade_structure_id);
  --
  chk_cagr_grade_def_id
  (p_cagr_grade_def_id    => p_rec.cagr_grade_def_id);
  --
  chk_sequence
  (p_cagr_grade_id 	          => p_rec.cagr_grade_id,
   p_sequence		          => p_rec.sequence,
   p_cagr_grade_structure_id	  => p_rec.cagr_grade_structure_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_gra_shd.g_rec_type,
			  p_effective_date   in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_cagr_grade_id
  (p_cagr_grade_id          => p_rec.cagr_grade_id,
   p_object_version_number  => p_rec.object_version_number,
   p_effective_date	    => p_effective_date);
  --
  chk_cagr_grade_structure_id
  (p_cagr_grade_structure_id    => p_rec.cagr_grade_structure_id);
  --
  chk_cagr_grade_def_id
  (p_cagr_grade_def_id    => p_rec.cagr_grade_def_id);
  --
  chk_sequence
  (p_cagr_grade_id 	          => p_rec.cagr_grade_id,
   p_sequence		          => p_rec.sequence,
   p_cagr_grade_structure_id	  => p_rec.cagr_grade_structure_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_gra_shd.g_rec_type,
			  p_effective_date   in date) is
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
end per_gra_bus;

/
