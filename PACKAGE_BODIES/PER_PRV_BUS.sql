--------------------------------------------------------
--  DDL for Package Body PER_PRV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PRV_BUS" as
/* $Header: peprvrhi.pkb 120.1 2006/04/14 17:27:46 kandra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_prv_bus.';  -- Global package name
--
g_legislation_code       varchar2(150)  default null;
g_performance_review_id   number         default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_performance_review_id >---------------------|
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
--   performance_review_id PK of record being inserted or updated.
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
Procedure chk_performance_review_id(p_performance_review_id in      number
                                   ,p_object_version_number in      number) is
  --
  l_proc         varchar2(72) := g_package||'chk_performance_review_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_prv_shd.api_updating
    (p_performance_review_id       => p_performance_review_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_performance_review_id,hr_api.g_number)
     <>  per_prv_shd.g_old_rec.performance_review_id) then
    --
    -- raise error as PK has changed
    --
    per_prv_shd.constraint_error('PER_PERFORMANCE_REVIEWS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_performance_review_id is not null then
      --
      -- raise error as PK is not null
      --
      per_prv_shd.constraint_error('PER_PERFORMANCE_REVIEWS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_performance_review_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_event_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the event id is valid
--
-- Pre-Conditions
--   none
--
-- In Parameters
--   p_performance_review_id
--     the performance review id
--   p_event_id
--      the id of the event associated with the review
--   p_object_version_number
--     the object version number
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
Procedure chk_event_id (p_performance_review_id in      number
                       ,p_event_id              in      number
                       ,p_object_version_number in      number) is
  --
  l_proc         varchar2(72) := g_package||'chk_event_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor get_event is
    select null
    from   per_events pev
    where  pev.event_id = p_event_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if (p_event_id is not null) then
    l_api_updating := per_prv_shd.api_updating
       (p_performance_review_id   => p_performance_review_id
       ,p_object_version_number   => p_object_version_number);
    --
    if (l_api_updating
       and nvl(p_event_id,hr_api.g_number)
       <> nvl(per_prv_shd.g_old_rec.event_id,hr_api.g_number)
       or not l_api_updating) then
      --
      -- check if event_id value exists in per_events table
      --
      open get_event;
        --
        fetch get_event into l_dummy;
        if get_event%notfound then
          --
          close get_event;
          --
          -- raise error as FK does not relate to PK in per_events
          -- table.
          --
          per_prv_shd.constraint_error('PER_PERFORMANCE_REVIEWS_FK2');
          --
        end if;
        --
      close get_event;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_event_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id_date >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_person_id_date(p_performance_review_id in number
                            ,p_object_version_number in number
                            ,p_person_id             in number
                            ,p_review_date           in date) is

  cursor get_person is
  select 1
  from per_all_people_f ppf
  where ppf.person_id=p_person_id
  and p_review_date between ppf.effective_start_date
  and ppf.effective_end_date
  and ppf.current_employee_flag='Y';

  cursor get_dup_date is
  select 1
  from per_performance_reviews prv
  where prv.person_id=p_person_id
  and   prv.review_date=p_review_date;

  l_proc         varchar2(72) := g_package||'chk_person_id_date';
  l_api_updating boolean;
  l_dummy number;

  begin

   hr_utility.set_location('Entering:'||l_proc,5);
--
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'review_date'
    ,p_argument_value   => p_review_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'person_id'
    ,p_argument_value   => p_person_id
    );
  --
  l_api_updating := per_prv_shd.api_updating
     (p_performance_review_id            => p_performance_review_id,
      p_object_version_number            => p_object_version_number);
  --
  if (l_api_updating
       and ( nvl(p_person_id,hr_api.g_number)
         <> nvl(per_prv_shd.g_old_rec.person_id,hr_api.g_number)
         or nvl(p_review_date,hr_api.g_date)
           <> nvl(per_prv_shd.g_old_rec.review_date,hr_api.g_date))
       or not l_api_updating) then
     hr_utility.set_location(l_proc,10);
     --
    -- check if the person exists on this date
    --
    open get_person;
      --
      fetch get_person into l_dummy;
      if get_person%notfound then
        hr_utility.set_location(l_proc,15);
        --
        close get_person;
        --
        -- raise error as FK does not relate to PK in per_events
        -- table.
        --
        per_prv_shd.constraint_error('PER_PERFORMANCE_REVIEWS_DT1');
        --
      end if;
      --
    close get_person;
    --
    hr_utility.set_location(l_proc,20);
    open get_dup_date;
    fetch get_dup_date into l_dummy;
    if get_dup_date%FOUND then
      close get_dup_date;
      hr_utility.set_location(l_proc,25);
      hr_utility.set_message(801,'HR_13000_SAL_DATE_NOT_UNIQUE');
      hr_utility.raise_error;
    end if;
    close get_dup_date;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,30);
  end chk_person_id_date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_next_perf_review_date >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_next_perf_review_date(p_performance_review_id in     number
                                   ,p_object_version_number in     number
                                   ,p_review_date           in     date
                                   ,p_next_perf_review_date in     date
                                   ,p_person_id             in     number
                                   ,p_next_review_date_warning out nocopy boolean) is
--
  l_proc  varchar2(72) := g_package||'chk_next_perf_review_date';
  l_api_updating boolean;
  l_dummy number;
--
  cursor get_person is
  select 1
  from per_all_people_f ppf
  where ppf.person_id=p_person_id
  and p_next_perf_review_date between ppf.effective_start_date
  and ppf.effective_end_date
  and ppf.current_employee_flag='Y';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'review_date'
    ,p_argument_value   => p_review_date
    );
--
  l_api_updating := per_prv_shd.api_updating
         (p_performance_review_id        => p_performance_review_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND
      (nvl(per_prv_shd.g_old_rec.next_perf_review_date,hr_api.g_date) <>
       nvl(p_next_perf_review_date,hr_api.g_date)
      or nvl(per_prv_shd.g_old_rec.review_date ,hr_api.g_date)
      <> nvl(p_review_date,hr_api.g_date))
      or not l_api_updating) then
--
        hr_utility.set_location(l_proc, 10);
        if(p_next_perf_review_date<=p_review_date) then
           hr_utility.set_message(801, 'HR_51260_PYP_INVAL_PERF_DATE');
           hr_utility.raise_error;
        end if;
        open get_person;
        fetch get_person into l_dummy;
        if get_person%notfound and p_next_perf_review_date is not null then
          hr_utility.set_location(l_proc, 15);
          close get_person;
          p_next_review_date_warning:=TRUE;
        else
          close get_person;
          p_next_review_date_warning:=FALSE;
        end if;
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc,20);
  end chk_next_perf_review_date;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_get_next_perf_review_date >--------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_get_next_perf_review_date(p_performance_review_id in     number
                                       ,p_object_version_number in     number
                                       ,p_review_date           in     date
                                       ,p_next_perf_review_date in out nocopy date
                                       ,p_assignment_id         in     number) is
--
  l_proc  varchar2(72) := g_package||'chk_get_next_perf_review_date';
  l_api_updating boolean;
  l_period number;
  l_frequency varchar2(30);
--
  cursor get_frequency is
  select perf_review_period,perf_review_period_frequency
  from per_all_assignments_f paf
  where paf.assignment_id=p_assignment_id
  and p_review_date between paf.effective_start_date
  and paf.effective_end_date;
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'review_date'
    ,p_argument_value   => p_review_date
    );
--
  l_api_updating := per_prv_shd.api_updating
         (p_performance_review_id        => p_performance_review_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND
      (nvl(per_prv_shd.g_old_rec.review_date ,hr_api.g_date)
      <> nvl(p_review_date,hr_api.g_date))
      or not l_api_updating) then
--
        hr_utility.set_location(l_proc, 10);
        if(p_assignment_id is not null
          and p_next_perf_review_date is null) then
          open get_frequency;
          fetch get_frequency into l_period,l_frequency;
          if get_frequency%found then
            hr_utility.set_location(l_proc, 15);
            close get_frequency;
            if(l_frequency='M') THEN
              hr_utility.set_location(l_proc, 20);
              p_next_perf_review_date:=add_months(p_review_date,l_period);
            elsif(l_frequency='Y') THEN
              hr_utility.set_location(l_proc, 25);
              p_next_perf_review_date:=add_months(p_review_date,l_period*12);
            elsif(l_frequency='D') THEN
              hr_utility.set_location(l_proc, 30);
              p_next_perf_review_date:=p_review_date+l_period;
            elsif(l_frequency='W') THEN
              hr_utility.set_location(l_proc, 35);
              p_next_perf_review_date:=p_review_date+(l_period*7);
            else
              hr_utility.set_location(l_proc||' '||l_frequency, 40);
            end if;
          else
            hr_utility.set_location(l_proc, 50);
            close get_frequency;
          end if;
        end if;
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc,55);
  end chk_get_next_perf_review_date;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_performance_rating >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates the value entered for performance_rating exists on hr_lookups.
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_performance_review_id
--    p_performance_rating
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The performance_rating value is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--      - The performance_rating value is invalid
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_performance_rating
  (p_performance_review_id in per_performance_reviews.performance_review_id%TYPE
  ,p_performance_rating    in per_performance_reviews.performance_rating%TYPE
  ,p_review_date           in per_performance_reviews.review_date%TYPE
  ,p_object_version_number in per_performance_reviews.object_version_number%TYPE
  )
  is
--
   l_proc           varchar2(72):= g_package||'chk_performance_rating';
   l_api_updating   boolean;
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check mandatory parameters have being set.
--
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'performance_rating'
    ,p_argument_value   => p_performance_rating
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for performance_rating  has changed
  --
  l_api_updating := per_prv_shd.api_updating
         (p_performance_review_id        => p_performance_review_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_prv_shd.g_old_rec.performance_rating,hr_api.g_varchar2) <>
      nvl(p_performance_rating,hr_api.g_varchar2)) OR not l_api_updating) then
     hr_utility.set_location(l_proc, 10);
     --
     -- check that the p_performance_rating exists in hr_lookups.
     --
     if hr_api.not_exists_in_hr_lookups
	(p_effective_date         => p_review_date
	 ,p_lookup_type           => 'PERFORMANCE_RATING'
         ,p_lookup_code           => p_performance_rating
        ) then
	hr_utility.set_location(l_proc, 15);
        hr_utility.set_message(801,'HR_51264_PYP_INVAL_PERF_RATING');
        hr_utility.raise_error;
     end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end chk_performance_rating;
--
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
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
procedure chk_df
  (p_rec in per_prv_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.performance_review_id is not null) and (
     nvl(per_prv_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
     nvl(p_rec.attribute21, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
     nvl(p_rec.attribute22, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
     nvl(p_rec.attribute23, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
     nvl(p_rec.attribute24, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
     nvl(p_rec.attribute25, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
     nvl(p_rec.attribute26, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
     nvl(p_rec.attribute27, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
     nvl(p_rec.attribute28, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
     nvl(p_rec.attribute29, hr_api.g_varchar2) or
     nvl(per_prv_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
     nvl(p_rec.attribute30, hr_api.g_varchar2)))
     or
     (p_rec.performance_review_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PERFORMANCE_REVIEWS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      ,p_attribute21_name   => 'ATTRIBUTE21'
      ,p_attribute21_value  => p_rec.attribute21
      ,p_attribute22_name   => 'ATTRIBUTE22'
      ,p_attribute22_value  => p_rec.attribute22
      ,p_attribute23_name   => 'ATTRIBUTE23'
      ,p_attribute23_value  => p_rec.attribute23
      ,p_attribute24_name   => 'ATTRIBUTE24'
      ,p_attribute24_value  => p_rec.attribute24
      ,p_attribute25_name   => 'ATTRIBUTE25'
      ,p_attribute25_value  => p_rec.attribute25
      ,p_attribute26_name   => 'ATTRIBUTE26'
      ,p_attribute26_value  => p_rec.attribute26
      ,p_attribute27_name   => 'ATTRIBUTE27'
      ,p_attribute27_value  => p_rec.attribute27
      ,p_attribute28_name   => 'ATTRIBUTE28'
      ,p_attribute28_value  => p_rec.attribute28
      ,p_attribute29_name   => 'ATTRIBUTE29'
      ,p_attribute29_value  => p_rec.attribute29
      ,p_attribute30_name   => 'ATTRIBUTE30'
      ,p_attribute30_value  => p_rec.attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
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
  (p_rec in per_prv_shd.g_rec_type ) IS
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
  IF NOT per_prv_shd.api_updating
       (p_performance_review_id  => p_rec.performance_review_id
       ,p_object_version_number => p_rec.object_version_number
       ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     nvl(per_prv_shd.g_old_rec.person_id
        ,hr_api.g_number) then
     l_argument := 'person_id';
     raise l_error;
  end if;
  --
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
-- |-----------------------< chk_delete_performance_review>-------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_delete_performance_review(p_performance_review_id in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete_performance_review';
  l_exists number;
  --
  cursor c_used is
  select 1
  from per_pay_proposals ppp
  where ppp.performance_review_id=p_performance_review_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'performance_review_id'
    ,p_argument_value => p_performance_review_id
    );
  --
  open c_used;
  fetch c_used into l_exists;
  if(c_used%found) then
    close c_used;
    hr_utility.set_location(l_proc,10);
    hr_utility.set_message(800,'HR_52408_PRV_PROPOSAL_EXISTS');
    hr_utility.raise_error;
  else
    close c_used;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_delete_performance_review;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_prv_shd.g_rec_type
                         ,p_next_review_date_warning out nocopy boolean ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_per_bus.set_security_group_id
    (
     p_person_id => p_rec.person_id
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_performance_review_id
  (p_performance_review_id          => p_rec.performance_review_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_event_id
  (p_performance_review_id          => p_rec.performance_review_id,
   p_event_id          => p_rec.event_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_person_id_date(p_performance_review_id => p_rec.performance_review_id
                    ,p_object_version_number => p_rec.object_version_number
                    ,p_person_id             => p_rec.person_id
                    ,p_review_date           => p_rec.review_date);
--
  hr_utility.set_location(l_proc, 20);
--
chk_next_perf_review_date(p_performance_review_id    => p_rec.performance_review_id
                         ,p_object_version_number    => p_rec.object_version_number
                         ,p_review_date              => p_rec.review_date
                         ,p_next_perf_review_date    => p_rec.next_perf_review_date
                         ,p_person_id                => p_rec.person_id
                         ,p_next_review_date_warning => p_next_review_date_warning);
  --
chk_performance_rating
  (p_performance_review_id => p_rec.performance_review_id
  ,p_performance_rating    => p_rec.performance_rating
  ,p_review_date           => p_rec.review_date
  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 25);
--
  chk_df(p_rec => p_rec);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_prv_shd.g_rec_type
                         ,p_next_review_date_warning out nocopy boolean ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_per_bus.set_security_group_id
    (
     p_person_id => p_rec.person_id
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(
     p_rec            => p_rec);
--
  chk_performance_review_id
  (p_performance_review_id          => p_rec.performance_review_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_event_id
  (p_performance_review_id          => p_rec.performance_review_id,
   p_event_id          => p_rec.event_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 15);
--
  chk_person_id_date(p_performance_review_id => p_rec.performance_review_id
                    ,p_object_version_number => p_rec.object_version_number
                    ,p_person_id             => p_rec.person_id
                    ,p_review_date           => p_rec.review_date);
--
  hr_utility.set_location(l_proc, 20);
--
chk_next_perf_review_date(p_performance_review_id    => p_rec.performance_review_id
                         ,p_object_version_number    => p_rec.object_version_number
                         ,p_review_date              => p_rec.review_date
                         ,p_next_perf_review_date    => p_rec.next_perf_review_date
                         ,p_person_id                => p_rec.person_id
                         ,p_next_review_date_warning => p_next_review_date_warning);
  --
chk_performance_rating
  (p_performance_review_id => p_rec.performance_review_id
  ,p_performance_rating    => p_rec.performance_rating
  ,p_review_date           => p_rec.review_date
  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 25);
--
  chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_prv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    chk_delete_performance_review (p_performance_review_id => p_rec.performance_review_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------< return_legislation_code >---------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
  (p_performance_review_id in number
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
    from per_business_groups pbg
       , per_performance_reviews prv
       , per_all_people          per
    where prv.performance_review_id = p_performance_review_id
      and per.person_id = prv.person_id
      and per.business_group_id = pbg.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code    varchar2(150);
  l_proc                varchar2(72) := 'return_legislation_code';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'performance_review_id'
      ,p_argument_value => p_performance_review_id
      );
  if nvl(g_performance_review_id, hr_api.g_number) = p_performance_review_id then
     --
     -- The legislation code has already been found with a previous
     -- call to this function.  Just return the value in the global
     -- variable.
     --
     l_legislation_code := g_legislation_code;
     hr_utility.set_location(l_proc,20);
  else
     --
     -- The ID is different to the last call to this function
     -- or this is the first call to this function.
     --
     open csr_leg_code;
     fetch csr_leg_code into l_legislation_code;
     if csr_leg_code%notfound then
  --
  -- The primary key is invalid, therefore we must error
  --
  close csr_leg_code;
  fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
  fnd_message.raise_error;
     end if;
     hr_utility.set_location(l_proc,30);
     --
     -- Set the global variables so the values are available
     -- for the next call to this function.
     --
     close csr_leg_code;
     g_performance_review_id := p_performance_review_id;
     g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving: '||l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_prv_bus;

/
