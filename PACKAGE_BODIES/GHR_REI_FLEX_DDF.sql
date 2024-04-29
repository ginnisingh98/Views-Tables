--------------------------------------------------------
--  DDL for Package Body GHR_REI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_REI_FLEX_DDF" as
/* $Header: ghreiddf.pkb 120.0.12010000.2 2009/05/26 10:46:15 vmididho noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= 'ghr_rei_flex_ddf.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ddf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure ddf
  (p_rec   in ghr_rei_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'ddf';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  Call check procedures to validate reason for submission, explanation and
  --  service only
  --  when information type is 'GHR_US_PD_GEN_EMP'.
  --
  if p_rec.information_type is not null then
    if p_rec.information_type = 'GHR_US_PD_GEN_EMP' then
      chk_reason_for_submission
        (p_pa_request_extra_info_id  => p_rec.pa_request_extra_info_id
        ,p_reason_for_submission     => p_rec.rei_information3
        ,p_effective_date            => sysdate
        ,p_object_version_number     => p_rec.object_version_number
        );
      chk_explanation
        (p_reason_for_submission    => p_rec.rei_information3
        ,p_pa_request_extra_info_id => p_rec.pa_request_extra_info_id
        ,p_explanation              => p_rec.rei_information4
        ,p_object_version_number    => p_rec.object_version_number
        );
      chk_service
        (p_pa_request_extra_info_id => p_rec.pa_request_extra_info_id
        ,p_service                  => p_rec.rei_information5
        ,p_effective_date           => sysdate
        ,p_object_version_number    => p_rec.object_version_number
        );
    end if;
  end if;
/*
  -- Check for value of reference field an then
  -- call relevant validation procedure.
  --
  if <reference field value> is not null then
    --
    -- Reference field       => Information type
    -- Reference field value => 'A'
    --
    else
      --
      -- Reference field values is not supported
      --
      hr_utility.set_message(8301, 'GHR_38117_FLEX_INV_REF_FIELD_V');
      hr_utility.raise_error;
    end if;
  else
    --
    -- When the reference field is null, check
    -- that none of the attribute fields have
    -- been set
    --
  endif;

    if p_rec.rei_information1 is not null then
      raise l_error;
    elsif p_rec.rei_information2 is not null then
      raise l_error;
    elsif p_rec.rei_information3 is not null then
      raise l_error;
    elsif p_rec.rei_information4 is not null then
      raise l_error;
    elsif p_rec.rei_information5 is not null then
      raise l_error;
    elsif p_rec.rei_information6 is not null then
      raise l_error;
    elsif p_rec.rei_information7 is not null then
      raise l_error;
    elsif p_rec.rei_information8 is not null then
      raise l_error;
    elsif p_rec.rei_information9 is not null then
      raise l_error;
    elsif p_rec.rei_information10 is not null then
      raise l_error;
    elsif p_rec.rei_information11 is not null then
      raise l_error;
    elsif p_rec.rei_information12 is not null then
      raise l_error;
    elsif p_rec.rei_information13 is not null then
      raise l_error;
    elsif p_rec.rei_information14 is not null then
      raise l_error;
    elsif p_rec.rei_information15 is not null then
      raise l_error;
    elsif p_rec.rei_information16 is not null then
      raise l_error;
    elsif p_rec.rei_information17 is not null then
      raise l_error;
    elsif p_rec.rei_information18 is not null then
      raise l_error;
    elsif p_rec.rei_information19 is not null then
      raise l_error;
    elsif p_rec.rei_information20 is not null then
      raise l_error;
    elsif p_rec.rei_information21 is not null then
      raise l_error;
    elsif p_rec.rei_information22 is not null then
      raise l_error;
    elsif p_rec.rei_information23 is not null then
      raise l_error;
    elsif p_rec.rei_information24 is not null then
      raise l_error;
    elsif p_rec.rei_information25 is not null then
      raise l_error;
    elsif p_rec.rei_information26 is not null then
      raise l_error;
    elsif p_rec.rei_information27 is not null then
      raise l_error;
    elsif p_rec.rei_information28 is not null then
      raise l_error;
    elsif p_rec.rei_information29 is not null then
      raise l_error;
    elsif p_rec.rei_information30 is not null then
      raise l_error;
    end if;
*/
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(8301, 'GHR_38118_FLEX_INV_ATTRIBUTE_A');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end ddf;
--

-- -------------------------------------------------------------------------
-- |----------------------------- < chk_reason_for_submission > ------------|
-- -------------------------------------------------------------------------
--
procedure chk_reason_for_submission
  (p_pa_request_extra_info_id    in  ghr_pa_request_extra_info.pa_request_extra_info_id%TYPE
  ,p_reason_for_submission       in  ghr_pa_request_extra_info.rei_information3%TYPE
  ,p_effective_date              in  date
  ,p_object_version_number       in  number
  ) is
--
  l_proc          varchar2(72) := 'chk_reason_for_submission';
  l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --
  --  Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         =>  l_proc
    ,p_argument         =>  'effective date'
    ,p_argument_value   =>  p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The reason_for_submission value has changed
  --  c) A record is being inserted
  --
  l_api_updating := ghr_rei_shd.api_updating
                      (p_pa_request_extra_info_id  => p_pa_request_extra_info_id
                      ,p_object_version_number     => p_object_version_number
                      );
  if ((l_api_updating and
       nvl(ghr_rei_shd.g_old_rec.rei_information3,hr_api.g_varchar2)
       <> nvl(p_reason_for_submission, hr_api.g_varchar2)) or
       (not l_api_updating))
  then
    hr_utility.set_location(l_proc, 20);
    --
    --  If reason_for_submission is not null then
    --  Check if the reason_for_submission value exists in hr_lookups
    --  where the lookup_type is 'GHR_US_SUBMISSION_REASON'
    --
    if p_reason_for_submission is not null
    then
      if hr_api.not_exists_in_hr_lookups
           (p_effective_date  => p_effective_date
           ,p_lookup_type     => 'GHR_US_SUBMISSION_REASON'
           ,p_lookup_code     => p_reason_for_submission
           )
      then
        -- Error: Invalid reason_for_submission
        hr_utility.set_message(8301, 'GHR_REASON_FOR_SUB_INVALID');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 30);
    end if;
  end if;
  hr_utility.set_location(' Leavig:'|| l_proc, 40);
end chk_reason_for_submission;
--
-- ----------------------------------------------------------------------------------------------------
-- |------------------------------- < chk_explanation > ----------------------------------------------|
-- ----------------------------------------------------------------------------------------------------
--
procedure chk_explanation
  (p_reason_for_submission       in  ghr_pa_request_extra_info.rei_information3%TYPE
  ,p_pa_request_extra_info_id    in  ghr_pa_request_extra_info.pa_request_extra_info_id%TYPE
  ,p_explanation                 in  ghr_pa_request_extra_info.rei_information4%TYPE
  ,p_object_version_number       in  number
  ) is
--
  l_proc          varchar2(72) := 'chk_explanation';
  l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --
  -- Only proceed with validation if a record is being inserted
  --
  l_api_updating := ghr_rei_shd.api_updating
                      (p_pa_request_extra_info_id  => p_pa_request_extra_info_id
                      ,p_object_version_number     => p_object_version_number
                      );
  if (not l_api_updating)
  then
    if (p_reason_for_submission = '4' and (p_explanation is null))
    then
      hr_utility.set_message(8301, 'GHR_NO_EXPLANATION');
      hr_utility.raise_error;
    end if;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 20);
end chk_explanation;
--
-- ---------------------------------------------------------------------------------------------------
-- |-------------------------------- < chk_service > ------------------------------------------------|
-- ---------------------------------------------------------------------------------------------------
--
procedure chk_service
  (p_pa_request_extra_info_id   in  ghr_pa_request_extra_info.pa_request_extra_info_id%TYPE
  ,p_service                    in  ghr_pa_request_extra_info.rei_information5%TYPE
  ,p_effective_date             in  date
  ,p_object_version_number      in  number
  ) is
--
  l_proc          varchar2(72) := 'chk_service';
  l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --
  --  Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name        => l_proc
    ,p_argument        => 'service'
    ,p_argument_value  => p_service
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The service value has changed
  --  c) A record is being inserted
  --
  l_api_updating := ghr_rei_shd.api_updating
                      (p_pa_request_extra_info_id  => p_pa_request_extra_info_id
                      ,p_object_version_number     => p_object_version_number
                      );
  --
  if ((l_api_updating and
       nvl(ghr_rei_shd.g_old_rec.rei_information5,hr_api.g_varchar2)
       <> nvl(p_service, hr_api.g_varchar2)) or
       (not l_api_updating))
  then
    hr_utility.set_location(l_proc, 20);
    --
    --  If service is not null then
    --  Check if the service value exists in hr_lookups
    --  where the lookup type is 'GHR_US_SERVICE'
    --
    if p_service is not null
    then
      if hr_api.not_exists_in_hr_lookups
           (p_effective_date    => p_effective_date
           ,P_lookup_type       => 'GHR_US_SERVICE'
           ,p_lookup_code       => p_service
           )
      then
        -- Error: Invalid Service
        hr_utility.set_message(8301, 'GHR_SERVICE_INVALID');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 30);
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_service;
--
end ghr_rei_flex_ddf;

/
