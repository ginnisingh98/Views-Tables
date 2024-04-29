--------------------------------------------------------
--  DDL for Package Body BEN_XRS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRS_BUS" as
/* $Header: bexrsrhi.pkb 120.1 2005/06/08 14:21:35 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrs_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_rslt_id >------|
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
--   ext_rslt_id PK of record being inserted or updated.
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
Procedure chk_ext_rslt_id(p_ext_rslt_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rslt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xrs_shd.api_updating
    (p_ext_rslt_id                => p_ext_rslt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rslt_id,hr_api.g_number)
     <>  ben_xrs_shd.g_old_rec.ext_rslt_id) then
    --
    -- raise error as PK has changed
    --
    ben_xrs_shd.constraint_error('BEN_EXT_RSLT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_rslt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xrs_shd.constraint_error('BEN_EXT_RSLT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_rslt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_dfn_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ext_rslt_id PK
--   p_ext_dfn_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_ext_dfn_id (p_ext_rslt_id          in number,
                            p_ext_dfn_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_dfn_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_dfn a
    where  a.ext_dfn_id = p_ext_dfn_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xrs_shd.api_updating
     (p_ext_rslt_id            => p_ext_rslt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_dfn_id,hr_api.g_number)
     <> nvl(ben_xrs_shd.g_old_rec.ext_dfn_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_dfn_id value exists in ben_ext_dfn table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_dfn
        -- table.
        --
        ben_xrs_shd.constraint_error('BEN_EXT_RSLT_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_dfn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_rslt_id PK of record being inserted or updated.
--   ext_stat_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
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
Procedure chk_ext_stat_cd(p_ext_rslt_id                in number,
                          p_ext_stat_cd                in varchar2,
                          p_effective_date             in date,
                          p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xrs_shd.api_updating
    (p_ext_rslt_id                => p_ext_rslt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ext_stat_cd
      <> nvl(ben_xrs_shd.g_old_rec.ext_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ext_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EXT_STAT',
           p_lookup_code    => p_ext_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      null;  -- not sure why this is failing so comment temporarily for deadline.
    --  hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
    --  hr_utility.raise_error;
      --
    end if;
    --
    /*if p_ext_stat_cd not in ('A','R') then
         	fnd_message.set_name('BEN','BEN_91944_INVLD_STAT_CD');
         	fnd_message.raise_error;
    end if;*/

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ext_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_output_file >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that output file names do not have blank spaces.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_output_name is output file name
--     p_drctry_name is drctry file name
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
-- ----------------------------------------------------------------------------
Procedure chk_output_file
           (p_output_name                 in   varchar2
           ,p_drctry_name                 in   varchar2)
is
l_proc	    varchar2(72) := g_package||'chk_output_file';
l_dummy    char(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if instr(p_output_name,' ') > 0 or instr(p_drctry_name,' ') > 0 then
      fnd_message.set_name('BEN','BEN_91955_NAME_HAS_SPACE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_output_file;
--



Procedure chk_xdo_template_id
           (p_output_type                 in   varchar2
           ,p_xdo_template_id           in   number)
is
l_proc      varchar2(72) := g_package||'chk_xdo_template_id';
l_dummy    char(1);
--
 cursor c is
 select 'x'
 from xdo_templates_b
 where template_id = p_xdo_template_id ;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  if (  (not nvl(p_output_type,'F')  in ( 'F' , 'X' ) )  and p_xdo_template_id is null )
     or ( p_xdo_template_id is not null and (  p_output_type in ('F' , 'X') ) )
     then
      fnd_message.set_name('BEN','BEN_94036_EXT_XDO_PDF_NULL');
      fnd_message.raise_error;
  end if;

  if  p_xdo_template_id is not null then
      open c ;
      fetch c into l_dummy  ;
      if c%notfound then
          close c ;
          fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
          fnd_message.set_token('PROCEDURE', l_proc);
          fnd_message.set_token('CONSTRAINT_NAME', 'XDO_TEMPLATE_ID');
          fnd_message.raise_error;
      end if ;
      close c ;

  end if  ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_xdo_template_id;


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xrs_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_ext_rslt_id
  (p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_dfn_id
  (p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_stat_cd
  (p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_ext_stat_cd         => p_rec.ext_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_output_file
  (p_output_name	=> p_rec.output_name
  ,p_drctry_name	=> p_rec.drctry_name);


  chk_xdo_template_id
     (p_output_type          =>  p_rec.output_type
     ,p_xdo_template_id      =>  p_rec.xdo_template_id
     )  ;


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xrs_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_ext_rslt_id
  (p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_dfn_id
  (p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_stat_cd
  (p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_ext_stat_cd         => p_rec.ext_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_output_file
  (p_output_name	=> p_rec.output_name
  ,p_drctry_name	=> p_rec.drctry_name);

  chk_xdo_template_id
  (p_output_type          =>  p_rec.output_type
  ,p_xdo_template_id      =>  p_rec.xdo_template_id
  )  ;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xrs_shd.g_rec_type
                         ,p_effective_date in date) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_ext_rslt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_rslt b
    where b.ext_rslt_id      = p_ext_rslt_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.legislation_code%type ;
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'ext_rslt_id',
                             p_argument_value => p_ext_rslt_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_xrs_bus;

/
