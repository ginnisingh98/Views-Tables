--------------------------------------------------------
--  DDL for Package Body HXC_EGC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_EGC_BUS" as
/* $Header: hxcegcrhi.pkb 120.2 2005/09/23 10:39:50 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_egc_bus.';  -- Global package name
g_debug    boolean	:= hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in hxc_egc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72);
--
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package || 'chk_df';
	hr_utility.set_location('Entering:'||l_proc,10);
  end if;
  --
  if ((p_rec.entity_group_comp_id is not null)  and (
    nvl(hxc_egc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hxc_egc_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.entity_group_comp_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HXC'
      ,p_descflex_name                   => 'OTC Entity Component Info'
      ,p_attribute_category              => p_rec.entity_type
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
      );
  end if;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc,20);
  end if;
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in hxc_egc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hxc_egc_shd.api_updating
      (p_entity_group_comp_id                 => p_rec.entity_group_comp_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_entity_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid entity_id is entered
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   entity id
--
-- Post Success:
--   Processing continues if the mapping component id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the mapping component id is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_entity_id
  (
   p_entity_id   in hxc_entity_group_comps.entity_id%TYPE
,  p_entity_type in hxc_entity_group_comps.entity_type%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check time_entry_rule_id is valid
--
CURSOR  csr_chk_ter IS
SELECT 'error'
FROM	sys.dual
WHERE NOT EXISTS (
	SELECT	'x'
	FROM	hxc_time_entry_rules ter
	WHERE	ter.time_entry_rule_id = p_entity_id );

CURSOR csr_chk_tr IS
SELECT 'error'
FROM	dual
WHERE	NOT EXISTS (
	SELECT	'x'
	FROM	hxc_time_recipients tr
	WHERE	tr.time_recipient_id	= p_entity_id );

CURSOR csr_chk_rr IS
SELECT 'error'
FROM	dual
WHERE	NOT EXISTS (
	SELECT	'x'
	FROM	hxc_retrieval_rules rr
	WHERE	rr.retrieval_rule_id	= p_entity_id );

CURSOR csr_chk_ptg IS
SELECT 'error'
FROM	dual
WHERE	NOT EXISTS (
	SELECT	'x'
	FROM	hxc_template_summary hts
	WHERE	hts.template_id	= p_entity_id
        and hts.template_type = 'PUBLIC');

 l_error varchar2(5) := NULL;

BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_entity_id';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
-- check that the entity id has been entered
--
IF p_entity_id IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_EGC_ENTITY_ID_MAND');
      hr_utility.raise_error;
--
END IF;

  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

-- check to see what entity we are dealing with

IF ( p_entity_type = 'TIME_ENTRY_RULES' )
THEN

-- check that entity_id is valid

  OPEN  csr_chk_ter;
  FETCH csr_chk_ter INTO l_error;
  CLOSE csr_chk_ter;

  IF l_error IS NOT NULL
  THEN

      hr_utility.set_message(809, 'HXC_EGC_ENTITY_ID_INVALID');
      hr_utility.raise_error;

  END IF;

ELSIF ( p_entity_type = 'TIME_RECIPIENTS' )
THEN

-- check that entity_id is valid

  OPEN  csr_chk_tr;
  FETCH csr_chk_tr INTO l_error;
  CLOSE csr_chk_tr;

  IF l_error IS NOT NULL
  THEN

      hr_utility.set_message(809, 'HXC_EGC_ENTITY_ID_INVALID');
      hr_utility.raise_error;

  END IF;

ELSIF ( p_entity_type = 'RETRIEVAL_RULES' )
THEN

-- check that entity_id is valid

  OPEN  csr_chk_rr;
  FETCH csr_chk_rr INTO l_error;
  CLOSE csr_chk_rr;

  IF l_error IS NOT NULL
  THEN

      hr_utility.set_message(809, 'HXC_EGC_ENTITY_ID_INVALID');
      hr_utility.raise_error;

  END IF;

-- To handle Public Template Group Insert
ELSIF (p_entity_type = 'PUBLIC_TEMPLATE_GROUP')
THEN
      OPEN  csr_chk_ptg;
      FETCH csr_chk_ptg INTO l_error;
      CLOSE csr_chk_ptg;

      IF l_error IS NOT NULL
      THEN

          hr_utility.set_message(809, 'HXC_EGC_ENTITY_ID_INVALID');
          hr_utility.raise_error;

      END IF;


ELSE

      hr_utility.set_message(809, 'HXC_EGC_ENTITY_TYPE_INVALID');
      hr_utility.raise_error;

END IF; -- entity_type

--
END chk_entity_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_entity_group_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid entity group id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   entity group id
--
-- Post Success:
--   Processing continues if the entity id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the entity id is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_entity_group_id
  (
   p_entity_group_id  in hxc_entity_groups.entity_group_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check entity group id is valid
--
CURSOR  csr_chk_egc IS
SELECT 'error'
FROM	sys.dual
WHERE NOT EXISTS (
	SELECT	'x'
	FROM	hxc_entity_groups egc
	WHERE	egc.entity_group_id = p_entity_group_id );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_entity_group_id';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the entity group id has been entered
--
IF p_entity_group_id IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_EGC_ENTITY_GROUP_ID_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that entity_group_id is valid
--
  OPEN  csr_chk_egc;
  FETCH csr_chk_egc INTO l_error;
  CLOSE csr_chk_egc;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_EGC_ENTITY_GROUP_ID_INVLD');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_entity_group_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_entity_type >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid entity type
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   entity type
--
-- Post Success:
--   Processing continues if the entity id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the entity id is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_entity_type
  (
   p_entity_type    in hxc_entity_group_comps.entity_type%TYPE
,  p_effective_date in DATE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check entity type is valid
--
CURSOR  csr_chk_lkup IS
SELECT 'error'
FROM	sys.dual
WHERE NOT EXISTS (
	SELECT	'x'
	FROM	hr_lookups lk
	WHERE	lk.lookup_type = 'HXC_ENTITIES'
	AND	lk.lookup_code = p_entity_type
	AND	p_effective_date BETWEEN
		lk.start_date_active and NVL(lk.end_date_active, hr_general.end_of_time) );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_entity_type';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the entity type has been entered
--
IF p_entity_type IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_EGC_ENTITY_TYPE_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that entity_component_id is valid
--
  OPEN  csr_chk_lkup;
  FETCH csr_chk_lkup INTO l_error;
  CLOSE csr_chk_lkup;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_EGC_ENTITY_TYPE_INVLD');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_entity_type;
-- Procedure to check if there are duplicate rules for a particular
-- recipient application in a PTE TERG.
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dup_app_PTE >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_dup_app_PTE
   (p_entity_group_id hxc_entity_group_comps.entity_group_id%TYPE
   ,p_entity_id hxc_entity_group_comps.entity_id%TYPE
   ,p_entity_group_comp_id hxc_entity_group_comps.entity_group_comp_id%TYPE
   ) is
    cursor csr_chk_dup_app is
    select 'Y'
      from hxc_entity_groups heg,
           hxc_entity_group_comps hec,
	   hxc_time_entry_rules hte1,
	   hxc_time_entry_rules hte2
     where heg.entity_type = 'TIME_ENTRY_RULES' and
           heg.entity_group_id = nvl(p_entity_group_id,-999) and
	   hec.ENTITY_GROUP_ID =heg.entity_group_id and
	   hec.entity_id = hte1.TIME_ENTRY_RULE_ID and
	   hte1.attribute1 = hte2.attribute1 and
	   hte2.time_entry_rule_id = nvl(p_entity_id,-999) and
	   hec.entity_group_comp_id <> nvl(p_entity_group_comp_id,-999);

l_buff varchar2(20);
l_proc  varchar2(72);

Begin
   g_debug:=hr_utility.debug_enabled;
   if g_debug then
	l_proc := g_package||'chk_dup_app_PTE';
	hr_utility.set_location('Entering:'||l_proc, 5);
   end if;
   open csr_chk_dup_app;
   if g_debug then
	   hr_utility.trace('After open');
	   hr_utility.trace('Entity_id ' || p_entity_id);
	   hr_utility.trace('Group id ' || p_entity_group_id);
   end if;
       fetch csr_chk_dup_app into l_buff;
       if g_debug then
		hr_utility.trace('res' || l_buff);
       end if;

   if (csr_chk_dup_app%FOUND) then
       if g_debug then
	hr_utility.set_location('Entering:'||l_proc, 10);
       end if;
       close csr_chk_dup_app;
       hr_utility.set_message(809,'HXC_REC_APP_DUP');
       hr_utility.raise_error;
   end if;
   close csr_chk_dup_app;
   if g_debug then
	hr_utility.set_location('leaving:'||l_proc, 15);
   end if;
end chk_dup_app_PTE;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_egc_shd.g_rec_type
  ,p_called_from_form             in varchar2
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'insert_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
	chk_entity_group_id ( p_entity_group_id => p_rec.entity_group_id );

	chk_entity_type ( p_entity_type		=> p_rec.entity_type
			, p_effective_date 	=> p_effective_date );

-- Call chk_entity_id only if it is not a Dynamic Template i.e. Entity_Id =-1  and
-- Entity_Type = PUBLIC_TEMPLATE_GROUP
  if(p_rec.entity_id = -1)
  then
    if(p_rec.entity_type <> 'PUBLIC_TEMPLATE_GROUP')
    then
      chk_entity_id ( p_entity_id		=> p_rec.entity_id
      ,	p_entity_type		=> p_rec.entity_type );
    end if;
  else
    chk_entity_id ( p_entity_id		=> p_rec.entity_id
      ,	p_entity_type		=> p_rec.entity_type );
  end if;

        if (p_rec.attribute1 = 'PTE') then
	    chk_dup_app_PTE(p_entity_group_id => p_rec.entity_group_id,
			    p_entity_id =>p_rec.entity_id,
			    p_entity_group_comp_id => p_rec.entity_group_comp_id);
	end if;
-- only call the DF validation if API called directly

	IF ( p_called_from_form = 'N' )
	THEN
	        chk_df(p_rec);
	END IF;

  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_egc_shd.g_rec_type
  ,p_called_from_form             in varchar2
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
	chk_entity_group_id ( p_entity_group_id => p_rec.entity_group_id );

	chk_entity_type ( p_entity_type		=> p_rec.entity_type
			, p_effective_date	=> p_effective_date );

	chk_entity_id ( p_entity_id		=> p_rec.entity_id
		,	p_entity_type		=> p_rec.entity_type );

  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
        if (p_rec.attribute1 = 'PTE') then
	    chk_dup_app_PTE(p_entity_group_id => p_rec.entity_group_id,
			    p_entity_id =>p_rec.entity_id,
			    p_entity_group_comp_id => p_rec.entity_group_comp_id);
	end if;
-- only call the DF validation if API called directly

	IF ( p_called_from_form = 'N' )
	THEN
	        chk_df(p_rec);
	END IF;

  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_egc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
null;

  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_egc_bus;

/
