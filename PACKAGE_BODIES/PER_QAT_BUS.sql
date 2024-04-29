--------------------------------------------------------
--  DDL for Package Body PER_QAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QAT_BUS" as
/* $Header: peqatrhi.pkb 120.0.12010000.2 2008/11/20 12:27:31 kgowripe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_qat_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_qualification_id            number         default null;
g_language                    varchar2(4)    default null;
--
-- The following global vaiables are only to be used by the
-- validate_translation function.
--
g_qualification_type_id       number default null;
g_person_id                   number default null;
g_attendance_id               number default null;
g_business_group_id           number default null;
g_object_version_number       number default null;
g_start_date                  date   default null;
g_end_date                    date   default null;
g_party_id                    number default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_qualification_id                     in number
  ) is
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_qua_bus.set_security_group_id(p_qualification_id => p_qualification_id);
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
  (p_qualification_id                     in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_qualifications_tl qat
         , per_qualifications qau
     where qat.qualification_id  = p_qualification_id
       and pbg.business_group_id = qau.business_group_id
       and qau.qualification_id  = qat.qualification_id;
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
    ,p_argument           => 'qualification_id'
    ,p_argument_value     => p_qualification_id
    );
  --
  --
  if (( nvl(per_qat_bus.g_qualification_id, hr_api.g_number)
       = p_qualification_id)
  and ( nvl(per_qat_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_qat_bus.g_legislation_code;
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
    per_qat_bus.g_qualification_id  := p_qualification_id;
    per_qat_bus.g_language          := p_language;
    per_qat_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_qat_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_qat_shd.api_updating
      (p_qualification_id                  => p_rec.qualification_id
      ,p_language                          => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qual_overlap >-------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_qual_overlap (p_qualification_id      in number,
                            p_qualification_type_id in number,
                            p_person_id             in number,
                            p_attendance_id         in number,
                            p_business_group_id     in number,
                            p_start_date            in date,
                            p_end_date              in date,
                            p_title                 in varchar2,
                            p_object_version_number in number,
                            p_party_id              in number default null,
                            p_language              in varchar2
                           ) is
  --
  l_proc  varchar2(72) := g_package||'chk_qual_overlap';
  --
  --
  -- This cursor checks for any identical overlapping qualifications for a
  -- person taking a particular qualification. If the start date or end date
  -- is within the bounds of a previously taken qualification then the
  -- qualification is invalid i.e. dates must be changed. The reason that
  -- qualifications can be taken more than once is for resits or failure, etc.
  --
  cursor c1 is
    select null
    from   per_qualifications per
          ,per_qualifications_tl qat
    where  qat.language                  = p_language
    and    qat.title                     = p_title
    and    qat.qualification_id          = per.qualification_id
    and    per.qualification_type_id     = p_qualification_type_id
    and    nvl(per.person_id,-1)         = nvl(p_person_id,-1)
    and    nvl(per.party_id,-1)          = nvl(p_party_id,nvl(per.party_id,-1)) --HR/TCA merge
    and    nvl(per.attendance_id,-1)     = nvl(p_attendance_id,-1)
    and    nvl(per.business_group_id,-1) = nvl(p_business_group_id,
                                           nvl(per.business_group_id,-1))
    and    per.qualification_id         <> NVL(p_qualification_id,-1)
    and    (nvl(per.start_date,hr_api.g_sot)
    between nvl(p_start_date,hr_api.g_sot)
    and     nvl(p_end_date,hr_api.g_eot)
   ---modified below condition for fixing bug#7571790
    --or      nvl(per.end_date,nvl(per.start_date,p_start_date))
    or      nvl(per.end_date,hr_api.g_eot)
    between nvl(p_start_date,hr_api.g_sot)
    and     nvl(p_end_date,hr_api.g_eot));
  --
  l_dummy           varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
       ,p_check_column2 => 'PER_QUALIFICATIONS.PARTY_ID'
       ,p_check_column3 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
       ,p_check_column4 => 'PER_QUALIFICATIONS.QUALIFICATION_ID'
       ,p_check_column5 => 'PER_QUALIFICATIONS.QUALIFICATION_TYPE_ID'
       ) then
    --
    if hr_multi_message.no_all_inclusive_error
         (p_check_column1 => 'PER_QUALIFICATIONS.START_DATE'
         ,p_check_column2 => 'PER_QUALIFICATIONS.END_DATE'
         ,p_check_column3 => 'PER_QUALIFICATIONS.TITLE'
         ) then
      --
      --
   /* This is commented out becuase the  per_qua_shd.api_updating is
      returning the new record and not the old rec. This may need to
      be moved to the api since it needs values off the base table.

      With this comment out the check will also run indepdent of
      if the unique key have changed.

      joward 28-JAN-2003

      l_b_api_updating := per_qua_shd.api_updating
                          (p_qualification_id        => p_qualification_id,
                           p_object_version_number   => p_object_version_number);

       if l_b_api_updating then
        --
        l_tl_api_updating := per_qat_shd.api_updating
                            (p_qualification_id        => null,
                             p_language                => p_language);
      end if;
      --
      --
      if (l_b_api_updating
        and (nvl(p_qualification_type_id,hr_api.g_number)
             <> nvl(per_qua_shd.g_old_rec.qualification_type_id,hr_api.g_number)
	     or nvl(p_person_id,hr_api.g_number)
	     <> nvl(per_qua_shd.g_old_rec.person_id,hr_api.g_number)
             or nvl(p_party_id,hr_api.g_number)                     -- HR/TCA merge
             <> nvl(per_qua_shd.g_old_rec.party_id,hr_api.g_number) --
    	     or nvl(p_attendance_id,hr_api.g_number)
	     <> nvl(per_qua_shd.g_old_rec.attendance_id,hr_api.g_number)
	     or nvl(p_business_group_id,hr_api.g_number)
  	     <> nvl(per_qua_shd.g_old_rec.business_group_id,hr_api.g_number)
	     or nvl(p_title,hr_api.g_varchar2)
	     <> nvl(per_qat_shd.g_old_rec.title,hr_api.g_varchar2)
	     or nvl(p_start_date,hr_api.g_date)
 	     <> nvl(per_qua_shd.g_old_rec.start_date,hr_api.g_date)
	     or nvl(p_end_date,hr_api.g_date)
	     <> nvl(per_qua_shd.g_old_rec.end_date,hr_api.g_date))
        or not l_b_api_updating) then
    */    --
        --
        -- check if record already exists in PER_QUALIFICATIONS table.
        --
        open c1;
        --
        fetch c1 into l_dummy;
        if c1%found then
          --
          -- raise error as qualification record already exists within these
          -- date boundaries.
          --
          hr_utility.set_message(801,'HR_51847_QUA_REC_EXISTS');
          hr_utility.raise_error;
          --
        end if;
        --
        close c1;
        --
   /*   end if; */
      --
    end if; -- no_all_inclusive_error 2
    --
  end if; -- no_all_inclusive_error 1
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_qual_overlap;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------<  chk_qual_overlap  >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_qual_overlap
  (p_rec                          in per_qat_shd.g_rec_type
  ,p_qualification_id             in number default NULL
  ) is
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
  -- Declare cursor
  --
  cursor csr_qualification is
    select qau.qualification_type_id
          ,qau.person_id
          ,qau.attendance_id
          ,qau.business_group_id
          ,qau.object_version_number
          ,qau.start_date
          ,qau.end_date
          ,qau.party_id
      from per_qualifications qau
     where qau.qualification_id  = NVL(p_rec.qualification_id, p_qualification_id);
  --
  l_qau_rec  csr_qualification%ROWTYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_qualification;
  --
  fetch csr_qualification into l_qau_rec;
  --
  close csr_qualification;
  --
  chk_qual_overlap
    (p_qualification_id       => NVL(p_rec.qualification_id,
                                    p_qualification_id)
    ,p_qualification_type_id  => l_qau_rec.qualification_type_id
    ,p_person_id              => l_qau_rec.person_id
    ,p_attendance_id          => l_qau_rec.attendance_id
    ,p_business_group_id      => l_qau_rec.business_group_id
    ,p_start_date             => l_qau_rec.start_date
    ,p_end_date               => l_qau_rec.end_date
    ,p_title                  => p_rec.title
    ,p_object_version_number  => l_qau_rec.object_version_number
    ,p_party_id               => l_qau_rec.party_id
    ,p_language               => p_rec.language);
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_qual_overlap;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_qat_shd.g_rec_type
  ,p_qualification_id             in number
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_qual_overlap
    (p_rec              => p_rec
    ,p_qualification_id => p_qualification_id
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
  (p_rec                          in per_qat_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- set_security_group_id(p_qualification_id => p_rec.qualification_id);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  chk_qual_overlap
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_qat_shd.g_rec_type
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
-- |-----------------------< set_translation_globals >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_translation_globals
  (p_qualification_type_id          in number
  ,p_person_id                      in number
  ,p_attendance_id                  in number
  ,p_business_group_id              in number
  ,p_object_version_number          in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_party_id                       in number
  ) IS
--
  l_proc  varchar2(72) := g_package||'set_translation_globals';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  g_qualification_type_id := p_qualification_type_id;
  g_person_id             := p_person_id;
  g_attendance_id         := p_attendance_id;
  g_business_group_id     := p_business_group_id;
  g_object_version_number := p_object_version_number;
  g_start_date            := p_start_date;
  g_end_date              := p_end_date;
  g_party_id              := p_party_id;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END;
--
-- ----------------------------------------------------------------------------
-- |------------------------<  validate_translation>--------------------------|
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_qualification_id               in number
  ,p_language                       in varchar2
  ,p_title                          in varchar2
  ,p_group_ranking                  in varchar2
  ,p_license_restrictions           in varchar2
  ,p_awarding_body                  in varchar2
  ,p_grade_attained                 in varchar2
  ,p_reimbursement_arrangements     in varchar2
  ,p_training_completed_units       in varchar2
  ,p_membership_category            in varchar2
  ,p_qualification_type_id          in number default null
  ,p_person_id                      in number default null
  ,p_attendance_id                  in number default null
  ,p_business_group_id              in number default null
  ,p_object_version_number          in number default null
  ,p_start_date                     in date   default null
  ,p_end_date                       in date   default null
  ,p_party_id                       in number default null
  ) is
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  chk_qual_overlap
    (p_qualification_id      => p_qualification_id
    ,p_qualification_type_id => nvl(p_qualification_type_id,
                                    g_qualification_type_id)
    ,p_person_id             => nvl(p_person_id, g_person_id)
    ,p_attendance_id         => nvl(p_attendance_id, g_attendance_id)
    ,p_business_group_id     => nvl(p_business_group_id, g_business_group_id)
    ,p_start_date            => nvl(p_start_date, g_start_date)
    ,p_end_date              => nvl(p_end_date, g_end_date)
    ,p_title                 => p_title
    ,p_object_version_number => nvl(p_object_version_number,
                                    g_object_version_number)
    ,p_party_id              => nvl(p_party_id, g_party_id)
    ,p_language              => p_language);
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End validate_translation;
--
end per_qat_bus;

/
