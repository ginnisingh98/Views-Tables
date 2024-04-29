--------------------------------------------------------
--  DDL for Package Body PER_ECA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ECA_BUS" as
/* $Header: peecarhi.pkb 115.6 2002/12/05 10:25:53 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_eca_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_election_candidate_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
(p_election_candidate_id                in number
) is
--
-- Declare cursor
--
cursor csr_sec_grp is
select pbg.security_group_id
from per_business_groups pbg
 , per_election_candidates eca
where eca.election_candidate_id = p_election_candidate_id
and pbg.business_group_id = eca.business_group_id;
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
,p_argument           => 'election_candidate_id'
,p_argument_value     => p_election_candidate_id
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
fnd_message.raise_error;
--
end if;
close csr_sec_grp;
--
-- Set the security_group_id in CLIENT_INFO
--
hr_api.set_security_group_id
(p_security_group_id => l_security_group_id
);
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
(p_election_candidate_id                in     number
)
Return Varchar2 Is
--
-- Declare cursor
--
cursor csr_leg_code is
select pbg.legislation_code
from per_business_groups pbg
 , per_election_candidates eca
where eca.election_candidate_id = p_election_candidate_id
and pbg.business_group_id = eca.business_group_id;
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
,p_argument           => 'election_candidate_id'
,p_argument_value     => p_election_candidate_id
);
--
if ( nvl(per_eca_bus.g_election_candidate_id, hr_api.g_number)
= p_election_candidate_id) then
--
-- The legislation code has already been found with a previous
-- call to this function. Just return the value in the global
-- variable.
--
l_legislation_code := per_eca_bus.g_legislation_code;
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
per_eca_bus.g_election_candidate_id:= p_election_candidate_id;
per_eca_bus.g_legislation_code  := l_legislation_code;
end if;
hr_utility.set_location(' Leaving:'|| l_proc, 40);
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
(p_rec in per_eca_shd.g_rec_type
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
IF NOT per_eca_shd.api_updating
(p_election_candidate_id                => p_rec.election_candidate_id
,p_object_version_number                => p_rec.object_version_number
) THEN
fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
fnd_message.set_token('PROCEDURE ', l_proc);
fnd_message.set_token('STEP ', '5');
fnd_message.raise_error;
END IF;
--
-- EDIT_HERE: Add checks to ensure non-updateable args have
--            not been updated.
--
EXCEPTION
WHEN l_error THEN
hr_api.argument_changed_error
(p_api_name => l_proc
,p_argument => l_argument);
WHEN OTHERS THEN
RAISE;
End chk_non_updateable_args;

--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_delete >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Check if the role_id is null before delete
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_role_id
--
--  Post Success:
--    If role id is null then  processing continues.
--
--  Post Failure:
--    If role id is not null then an application error will be
--    raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete
(p_election_candidate_id in    number
)
is
--
l_proc              varchar2(72)  :=  g_package||'chk_delete';
--
l_election_candidate_id number;
--
cursor csr_valid_del is
select election_candidate_id
from per_election_candidates
where election_candidate_id = p_election_candidate_id
and role_id is null;
--
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'election_candidate_id'
,p_argument_value => p_election_candidate_id
);
--
hr_utility.set_location(l_proc, 20);
--
open csr_valid_del;
fetch csr_valid_del into l_election_candidate_id;
if csr_valid_del%notfound then
--
close csr_valid_del;
hr_utility.set_message(800,'PER_289105_ECA_CANNOT_BE_DELET');
hr_utility.raise_error;
--
end if;
close csr_valid_del;    --
--  end if;
--
hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_delete;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
(p_rec                          in per_eca_shd.g_rec_type
) is
--
l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Call all supporting business operations
chk_delete(p_election_candidate_id => p_rec.election_candidate_id);

--
hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a person id exists in table per_people_f.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--
--  Post Success:
--    If a row does exist in per_all_people_f for the given person id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in per_all_people_f for the given person id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_person_id
(p_person_id                 in     per_election_candidates.person_id%TYPE
)
is
--
l_proc              varchar2(72)  :=  g_package||'chk_person_id';
--
l_api_updating      boolean;
l_person_id number;
--
cursor csr_valid_pers is
select person_id
from per_all_people_f
where person_id = p_person_id;
--
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'person_id'
,p_argument_value => p_person_id
);
--
hr_utility.set_location(l_proc, 20);
--
-- Check that the Person ID is linked to a
-- valid person on PER_PEOPLE_F
--
open csr_valid_pers;
fetch csr_valid_pers into l_person_id;
if csr_valid_pers%notfound then
--
close csr_valid_pers;
hr_utility.set_message(800, 'PER_289101_ECA_PERSON_INVALID');
hr_utility.raise_error;
--
end if;
close csr_valid_pers;
--
hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_election_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a election id exists in table PER_ELECTIONS
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_election_id
--
--  Post Success:
--    If a row does exist in PER_ELECTIONS for the given election id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in PER_ELECTIONS for the given election id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_election_id
(p_election_id           in     per_election_candidates.election_id%TYPE
)
is
--
l_proc              varchar2(72)  :=  g_package||'chk_election_id';
--
l_election_id number;
--
cursor csr_valid_eid is
select election_id
from per_elections
where election_id = p_election_id;
--
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'election_id'
,p_argument_value => p_election_id
);
hr_utility.set_location(l_proc, 20);
--
-- Check that the Election ID is  exists in PER_ELECTIONS
--
open csr_valid_eid;
fetch csr_valid_eid into l_election_id;
if csr_valid_eid%notfound then
--
close csr_valid_eid;
hr_utility.set_message(800, 'PER_289103_ECA_ELEC_ID_INVALID');
hr_utility.raise_error;
--
end if;
close csr_valid_eid;
--
hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_election_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_duplicate_candidate >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a candidate exists already for this election process
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_election_id
--    p_person_id
--
--  Post Success:
--    If a candidate does not exist for this election then processing continues.
--
--  Post Failure:
--    If a candidate already exists for the election then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_duplicate_candidate
(p_election_id           in     per_election_candidates.election_id%TYPE
,p_person_id		 in	per_election_candidates.person_id%TYPE
,p_election_candidate_id in     per_election_candidates.election_candidate_id%TYPE
)
is
--
l_proc              varchar2(72)  :=  g_package||'chk_duplicate_candidate';
--
l_candidate_id number;
--
cursor csr_valid_candidate is
select election_candidate_id
from per_election_candidates
where election_id = p_election_id
and person_id     = p_person_id;
--
begin

hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'election_id'
,p_argument_value => p_election_id
);
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'person_id'
,p_argument_value => p_person_id
);
--
hr_utility.set_location(l_proc, 20);
--
-- Check that the candidate has not been entered for this election before
--
open csr_valid_candidate;
fetch csr_valid_candidate into l_candidate_id;
if csr_valid_candidate%found then
if p_election_candidate_id is null or
   p_election_candidate_id <> l_candidate_id then
hr_utility.set_location(l_proc, 30);
--
fnd_message.set_name('PER', 'HR_289257_ECA_DUP_CANDIDATE');
hr_utility.raise_error;
--
end if;
end if;
close csr_valid_candidate;
--
hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_duplicate_candidate;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_role_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a role id exists in table PER_ROLES
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_role_id
--
--  Post Success:
--    If a row does exist in PER_ROLES for the given role id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in PER_ROLES for the given role id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_role_id
(p_role_id               in     per_election_candidates.role_id%TYPE
)
is
--
l_proc              varchar2(72)  :=  g_package||'chk_role_id';
--
l_role_id number;
--
cursor csr_valid_rid is
select role_id
from per_roles
where role_id = p_role_id;
--
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'role_id'
,p_argument_value => p_role_id
);
hr_utility.set_location(l_proc, 20);
--
--
-- Check that the Role ID is  exists in PER_ROLES
--
open csr_valid_rid;
fetch csr_valid_rid into l_role_id;
if csr_valid_rid%notfound then
--
close csr_valid_rid;
hr_utility.set_message(800, 'PER_289104_ECA_ROLE_ID_INVALID');
hr_utility.raise_error;
--
end if;
close csr_valid_rid;    --
--
hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_role_id;

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
(p_rec in per_eca_shd.g_rec_type
) is
--
l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
hr_utility.set_location('Entering:'||l_proc,10);
--
if ((p_rec.election_candidate_id is not null)  and (
nvl(per_eca_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
nvl(p_rec.attribute1, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
nvl(p_rec.attribute2, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
nvl(p_rec.attribute3, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
nvl(p_rec.attribute4, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
nvl(p_rec.attribute5, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
nvl(p_rec.attribute6, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
nvl(p_rec.attribute7, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
nvl(p_rec.attribute8, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
nvl(p_rec.attribute9, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
nvl(p_rec.attribute10, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
nvl(p_rec.attribute11, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
nvl(p_rec.attribute12, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
nvl(p_rec.attribute13, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
nvl(p_rec.attribute14, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
nvl(p_rec.attribute15, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
nvl(p_rec.attribute16, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
nvl(p_rec.attribute17, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
nvl(p_rec.attribute18, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
nvl(p_rec.attribute19, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
nvl(p_rec.attribute20, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
nvl(p_rec.attribute21, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
nvl(p_rec.attribute22, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
nvl(p_rec.attribute23, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
nvl(p_rec.attribute24, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
nvl(p_rec.attribute25, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
nvl(p_rec.attribute26, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
nvl(p_rec.attribute27, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
nvl(p_rec.attribute28, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
nvl(p_rec.attribute29, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
nvl(p_rec.attribute30, hr_api.g_varchar2) ))
or (p_rec.election_candidate_id is null)  then
--
-- Only execute the validation if absolutely necessary:
-- a) During update, the structure column value or any
--    of the attribute values have actually changed.
-- b) During insert.
--
hr_dflex_utility.ins_or_upd_descflex_attribs
(p_appl_short_name                 => 'PER'
,p_descflex_name                   => 'PER_ELECTION_CANDIDATES'
,p_attribute_category              => p_rec.attribute_category
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
hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
(p_rec in per_eca_shd.g_rec_type
) is
--
l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
hr_utility.set_location('Entering:'||l_proc,10);
--
if ((p_rec.election_candidate_id is not null)  and (
nvl(per_eca_shd.g_old_rec.candidate_info_category, hr_api.g_varchar2) <>
nvl(p_rec.candidate_info_category, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information1, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information1, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information2, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information2, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information3, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information3, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information4, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information4, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information5, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information5, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information6, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information6, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information7, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information7, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information8, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information8, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information9, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information9, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information10, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information10, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information11, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information11, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information12, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information12, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information13, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information13, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information14, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information14, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information15, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information15, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information16, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information16, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information17, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information17, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information18, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information18, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information19, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information19, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information20, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information20, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information21, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information21, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information22, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information22, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information23, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information23, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information24, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information24, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information25, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information25, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information26, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information26, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information27, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information27, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information28, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information28, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information29, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information29, hr_api.g_varchar2)  or
nvl(per_eca_shd.g_old_rec.candidate_information30, hr_api.g_varchar2) <>
nvl(p_rec.candidate_information30, hr_api.g_varchar2) ))
or (p_rec.election_candidate_id is null)  then
--
-- Only execute the validation if absolutely necessary:
-- a) During update, the structure column value or any
--    of the attribute values have actually changed.
-- b) During insert.
--
hr_dflex_utility.ins_or_upd_descflex_attribs
(p_appl_short_name                 => 'PER'
,p_descflex_name                   => 'Candidates Developer DF'
,p_attribute_category              => p_rec.candidate_info_category
,p_attribute1_name                 => 'CANDIDATE_INFORMATION1'
,p_attribute1_value                => p_rec.candidate_information1
,p_attribute2_name                 => 'CANDIDATE_INFORMATION2'
,p_attribute2_value                => p_rec.candidate_information2
,p_attribute3_name                 => 'CANDIDATE_INFORMATION3'
,p_attribute3_value                => p_rec.candidate_information3
,p_attribute4_name                 => 'CANDIDATE_INFORMATION4'
,p_attribute4_value                => p_rec.candidate_information4
,p_attribute5_name                 => 'CANDIDATE_INFORMATION5'
,p_attribute5_value                => p_rec.candidate_information5
,p_attribute6_name                 => 'CANDIDATE_INFORMATION6'
,p_attribute6_value                => p_rec.candidate_information6
,p_attribute7_name                 => 'CANDIDATE_INFORMATION7'
,p_attribute7_value                => p_rec.candidate_information7
,p_attribute8_name                 => 'CANDIDATE_INFORMATION8'
,p_attribute8_value                => p_rec.candidate_information8
,p_attribute9_name                 => 'CANDIDATE_INFORMATION9'
,p_attribute9_value                => p_rec.candidate_information9
,p_attribute10_name                => 'CANDIDATE_INFORMATION10'
,p_attribute10_value               => p_rec.candidate_information10
,p_attribute11_name                => 'CANDIDATE_INFORMATION11'
,p_attribute11_value               => p_rec.candidate_information11
,p_attribute12_name                => 'CANDIDATE_INFORMATION12'
,p_attribute12_value               => p_rec.candidate_information12
,p_attribute13_name                => 'CANDIDATE_INFORMATION13'
,p_attribute13_value               => p_rec.candidate_information13
,p_attribute14_name                => 'CANDIDATE_INFORMATION14'
,p_attribute14_value               => p_rec.candidate_information14
,p_attribute15_name                => 'CANDIDATE_INFORMATION15'
,p_attribute15_value               => p_rec.candidate_information15
,p_attribute16_name                => 'CANDIDATE_INFORMATION16'
,p_attribute16_value               => p_rec.candidate_information16
,p_attribute17_name                => 'CANDIDATE_INFORMATION17'
,p_attribute17_value               => p_rec.candidate_information17
,p_attribute18_name                => 'CANDIDATE_INFORMATION18'
,p_attribute18_value               => p_rec.candidate_information18
,p_attribute19_name                => 'CANDIDATE_INFORMATION19'
,p_attribute19_value               => p_rec.candidate_information19
,p_attribute20_name                => 'CANDIDATE_INFORMATION20'
,p_attribute20_value               => p_rec.candidate_information20
,p_attribute21_name                => 'CANDIDATE_INFORMATION21'
,p_attribute21_value               => p_rec.candidate_information21
,p_attribute22_name                => 'CANDIDATE_INFORMATION22'
,p_attribute22_value               => p_rec.candidate_information22
,p_attribute23_name                => 'CANDIDATE_INFORMATION23'
,p_attribute23_value               => p_rec.candidate_information23
,p_attribute24_name                => 'CANDIDATE_INFORMATION24'
,p_attribute24_value               => p_rec.candidate_information24
,p_attribute25_name                => 'CANDIDATE_INFORMATION25'
,p_attribute25_value               => p_rec.candidate_information25
,p_attribute26_name                => 'CANDIDATE_INFORMATION26'
,p_attribute26_value               => p_rec.candidate_information26
,p_attribute27_name                => 'CANDIDATE_INFORMATION27'
,p_attribute27_value               => p_rec.candidate_information27
,p_attribute28_name                => 'CANDIDATE_INFORMATION28'
,p_attribute28_value               => p_rec.candidate_information28
,p_attribute29_name                => 'CANDIDATE_INFORMATION29'
,p_attribute29_value               => p_rec.candidate_information29
,p_attribute30_name                => 'CANDIDATE_INFORMATION30'
,p_attribute30_value               => p_rec.candidate_information30
);
end if;
--
hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_rec                   in per_eca_shd.g_rec_type
) is
--
l_proc                varchar2(72) := g_package||'insert_validate';
--
--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Validate PERSON_ID
--
per_eca_bus.chk_person_id
(p_person_id              =>  p_rec.person_id
);

--
-- Validate business_group_id
--
hr_api.validate_bus_grp_id(p_rec.business_group_id);
--
-- Validate election_id
--
per_eca_bus.chk_election_id
(p_election_id           => p_rec.election_id
);
--
-- Validate duplicate candidate for an election
--
chk_duplicate_candidate
  (p_election_id	=> p_rec.election_id
  ,p_person_id		=> p_rec.person_id
  ,p_election_candidate_id => p_rec.election_candidate_id
  );
--
-- Validate role_id
--
if p_rec.role_id is not null then
per_eca_bus.chk_role_id
(p_role_id               => p_rec.role_id
);
end if;

--
-- Validate DFs
  per_eca_bus.chk_ddf(p_rec);
--
-- Validate DDFs
  per_eca_bus.chk_df(p_rec);
--
hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
(p_rec                   in per_eca_shd.g_rec_type
) is
--
l_proc                varchar2(72) := g_package||'insert_validate';
--
--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Validate PERSON_ID
--
per_eca_bus.chk_person_id
(p_person_id              =>  p_rec.person_id
);

--
-- Validate business_group_id
--
hr_api.validate_bus_grp_id(p_rec.business_group_id);
--
-- Validate election_id
--
per_eca_bus.chk_election_id
(p_election_id           => p_rec.election_id
);
--
-- Validate duplicate candidate for an election
--
chk_duplicate_candidate
  (p_election_id        => p_rec.election_id
  ,p_person_id          => p_rec.person_id
  ,p_election_candidate_id => p_rec.election_candidate_id
  );
--
-- Validate role_id
--
if p_rec.role_id is not null then
per_eca_bus.chk_role_id
(p_role_id               => p_rec.role_id
);
end if;

--
--
-- Validate DFs
  per_eca_bus.chk_df(p_rec);
--
-- Validate DDFs
  per_eca_bus.chk_ddf(p_rec);
--
hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
end per_eca_bus;

/
