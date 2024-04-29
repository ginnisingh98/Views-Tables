--------------------------------------------------------
--  DDL for Package Body GHR_REI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_REI_BUS" as
/* $Header: ghreirhi.pkb 120.2.12010000.2 2008/09/02 07:19:59 vmididho ship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_rei_bus.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_PA_REQUEST_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in PA_REQUEST_ID is in the GHR_PA_REQUESTS table.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_pa_request_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_pa_request_id
  (
   p_pa_request_id        in      ghr_pa_request_extra_info.pa_request_id%type
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_pa_request_id';
  l_dummy       varchar2(1);
--
  cursor c_valid_req is
      select 'x'
        from ghr_pa_requests
       where pa_request_id = p_pa_request_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'pa_request_id',
     p_argument_value   => p_pa_request_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the pa_request_id is in the ghr_pa_requests table.
  --
  open c_valid_req;
  fetch c_valid_req into l_dummy;
  if c_valid_req%notfound then
    close c_valid_req;
    hr_utility.set_message(8301, 'HR_38119_INV_REQ_ID');
    hr_utility.raise_error;
  end if;
  close c_valid_req;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
End chk_pa_request_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the non updateable arguments not changed.
--   For the PA_REQUEST_EXTRA_INFO table neither of the FK's can be updated
--   i.e. PA_REQUEST_ID and INFORMATION_TYPE
--
-- Pre Conditions:
--   None
--
-- In Parameters:
--   p_rec
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in ghr_rei_shd.g_rec_type) is
--
  l_proc        varchar2(72) := g_package||'chk_non_updateable_args';
  l_error       exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema.
  if not ghr_rei_shd.api_updating
   (p_pa_request_extra_info_id  => p_rec.pa_request_extra_info_id
   ,p_object_version_number => p_rec.object_version_number
   ) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location (l_proc, 30);
  --
  if nvl(p_rec.pa_request_id,hr_api.g_number)
        <> nvl(ghr_rei_shd.g_old_rec.pa_request_id,hr_api.g_number) then
     l_argument := 'pa_request_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.information_type,hr_api.g_varchar2)
        <> nvl(ghr_rei_shd.g_old_rec.information_type,hr_api.g_varchar2) then
     l_argument := 'information_type';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Leaving : '|| l_proc, 40);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
end chk_non_updateable_args;
--
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_pa_request_info_type >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_pa_request_info_type(p_information_type varchar2,
					   p_multiple_occurrences_flag out nocopy  varchar2) is
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure check number of rows against an info type
--   Information_type must exist with active_inactive_flag='Y',
--   FK GHR_PA_REQUEST_EXTRA_INFO_FK1, ensures the existence of row in info type table
--   but it should exist with active_inactive_flag = 'Y'
--
--
-- Pre Conditions:
--   This private procedure is called from insert/update_validate procedure.
--
-- In Parameters:
--   A Pl/Sql record structure, and multiple occurrence flag.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  l_proc  varchar2(72) := g_package||'chk_pa_request_info_type';
  l_active_inactive_flag GHR_PA_REQUEST_INFO_TYPES.ACTIVE_INACTIVE_FLAG%TYPE;
  l_inactive_type exception;
--
  CURSOR c_info_type IS
	SELECT	rit.multiple_occurrences_flag
			,rit.active_inactive_flag
	FROM		ghr_pa_request_info_types	rit
	WHERE		rit.information_type 		= p_information_type
	;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'information_type',
     p_argument_value   => p_information_type
    );
  open c_info_type;
  fetch c_info_type into p_multiple_occurrences_flag, l_active_inactive_flag;
--
-- Check if there is any matching row for given info type
--
  if c_info_type%NOTFOUND then
	raise no_data_found;
  end if;
--
-- Check if info type is active or not.
--
  if l_active_inactive_flag = 'N' then
	raise l_inactive_type;
  end if;
--
  close c_info_type;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
--
  when l_inactive_type then
    close c_info_type;
    hr_utility.set_message(8301, 'HR_38120_INACTIVE_INFO_TYPE');
    hr_utility.raise_error;
--
  when no_data_found then
    close c_info_type;
    hr_utility.set_message(8301, 'HR_38121_INVALID_INFO_TYPE');
    hr_utility.raise_error;
--
End chk_pa_request_info_type;
--
--
-- Ensures that number of rows should not exceed one,
-- if multiple_occurrences_flag='N'
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_count_rows >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_count_rows(p_information_type in varchar2
				, p_pa_request_id in number
				, p_multiple_occurrences_flag in varchar2
			) is
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure check number of rows against an info type
--
-- Pre Conditions:
--   This private procedure is called from insert/update_validate procedure.
--
-- In Parameters:
--   A Pl/Sql record structure
--
-- Out Parameters
--   multiple occurrence flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
  l_proc  		varchar2(72) := g_package||'chk_count_rows';
  l_dummy 		varchar2(1);
  l_success 	exception;
  l_failure		exception;
--
  CURSOR c_count_rows IS
	SELECT	'x'
	FROM		ghr_pa_request_extra_info	rei
	WHERE		rei.information_type 		= p_information_type
	AND		rei.pa_request_id			= p_pa_request_id ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_multiple_occurrences_flag = 'N' then
      --
      -- Check mandatory parameters have been set
      --
      hr_api.mandatory_arg_error
        (
         p_api_name         => l_proc,
         p_argument         => 'information_type',
         p_argument_value   => p_information_type
        );
      --
      --
      hr_api.mandatory_arg_error
        (
         p_api_name         => l_proc,
         p_argument         => 'pa_request_id',
         p_argument_value   => p_pa_request_id
        );
	  open c_count_rows;
	  fetch c_count_rows into l_dummy;
	  if c_count_rows%FOUND then
    		close c_count_rows;
		raise l_failure;
	  else
		close c_count_rows;
		raise l_success;
	  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  when l_success then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  when l_failure then
    hr_utility.set_message(8301, 'GHR_38122_INFO_TYPE_ALLOWS_1_R');
    hr_utility.raise_error;

End chk_count_rows;
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
        IF (l_api_updating
        AND
        ((nvl(ghr_rei_shd.g_old_rec.rei_information3,hr_api.g_varchar2)
                                <> nvl(p_reason_for_submission,hr_api.g_varchar2)))
        OR
        ((nvl(ghr_rei_shd.g_old_rec.rei_information4,hr_api.g_varchar2)
                                <> nvl(p_explanation,hr_api.g_varchar2)))
)
        OR
        NOT l_api_updating THEN
/*
  if ((l_api_updating and
       nvl(ghr_rei_shd.g_old_rec.rei_information4,hr_api.g_varchar2)
       <> nvl(p_explanation, hr_api.g_varchar2)) or
       (not l_api_updating))
  then
*/
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
-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_ddf_for_866 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the retained grade rec in the EI for 866 (info type :'GHR_US_PAR_TERM_RET_GRADE' ),
--   is not already end dated.
--  We could not do this in the value set because of cancellation action which require
--  even end dated actions to be viewed  by the user.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_rei_information3
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_ddf_for_866
  (p_rec  in  ghr_rei_shd.g_rec_type
   ) is

  l_proc             varchar2(72) := g_package||'chk_ddf_for_866';
  l_first_noa_code   ghr_pa_requests.first_noa_code%type;
  l_effective_date   date;

    Cursor c_date_end is
    Select pei_information2
    From   per_people_extra_info
    Where  person_extra_info_id  =  p_rec.rei_information3;

    Cursor c_find_noa_code is
    Select first_noa_code,effective_date
    From   ghr_pa_requests
    Where  pa_request_id = p_rec.pa_request_id;

Begin

   hr_utility.set_location('Entering:'||l_proc, 5);

   for find_noa_code in c_find_noa_code loop
       l_first_noa_code := find_noa_code.first_noa_code;
       l_effective_date := nvl(find_noa_code.effective_date,sysdate);
   end loop;

   if l_first_noa_code not in ('001', '002') then
      If p_rec.information_type = 'GHR_US_PAR_TERM_RET_GRADE' then
         for date_end in C_date_end loop
             If nvl(fnd_date.canonical_to_date(date_end.pei_information2),l_effective_date)
                  < l_effective_date then
                hr_utility.set_message(8301,'GHR_38500_REC_ALREADY_ENDED');
                hr_utility.raise_error;
             End if;
         End loop;
      End if;
   End if;

   hr_utility.set_location('Leaving:'||l_proc, 10);

End chk_ddf_for_866;

-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_ddf_for_temp_promo >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the retained grade rec in the EI for 866 and 703
--  (info type :'GHR_US_PAR_RG_TEMP_PROMO' ) should not have TPS value
--  If there is no active Retained Grade record for the employee
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_rec
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_ddf_for_temp_promo
  (p_rec  in  ghr_rei_shd.g_rec_type
   ) is

  l_proc             varchar2(72) := g_package||'chk_ddf_for_temp_promo';
  l_first_noa_code   ghr_pa_requests.first_noa_code%type;
  l_effective_date   date;
  l_person_id        ghr_pa_requests.person_id%type;


    Cursor c_find_noa_code is
    Select first_noa_code,effective_date,person_id
    From   ghr_pa_requests
    Where  pa_request_id = p_rec.pa_request_id;

l_retained_grade   ghr_pay_calc.retained_grade_rec_type;
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);

   for find_noa_code in c_find_noa_code loop
     l_first_noa_code := find_noa_code.first_noa_code;
     l_effective_date := nvl(find_noa_code.effective_date,sysdate);
     l_person_id      := find_noa_code.person_id;
   end loop;
   IF l_person_id is not null AND
     l_effective_date is NOT NULL AND
     l_first_noa_code in ('866','703') AND
     p_rec.information_type = 'GHR_US_PAR_RG_TEMP_PROMO' THEN
     BEGIN
       l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details
                          (l_person_id
                          ,l_effective_date
                          ,p_rec.pa_request_id);
       EXCEPTION WHEN OTHERS THEN
       IF p_rec.rei_information3 is NOT NULL THEN
         hr_utility.set_message(8301,'GHR_38823_TEMP_PROMO_NO_RG');
         hr_utility.raise_error;
       ELSE
         NULL;
       END IF;
     END;
   END IF;
   hr_utility.set_location('Leaving:'||l_proc, 10);

End chk_ddf_for_temp_promo;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_multiple_occurrences_flag	ghr_pa_request_info_types.multiple_occurrences_flag%type;
--
l_person_id  per_people_f.person_id%type;
l_position_id per_positions.position_id%type;
l_bus_group_id per_people_f.business_group_id%type;

-- Bug#5729582 (i)added local variable l_effective_date
-- (ii) Modified the cursors c_get_perpos_ids,c_per_bus_group_id,c_pos_bus_group_id
l_effective_date ghr_pa_requests.effective_date%type;

cursor c_get_perpos_ids is
  select par.person_id,nvl(par.from_position_id,par.to_position_id) position_id,
         par.effective_date
  from ghr_pa_requests  par
  where pa_request_id = p_rec.pa_request_id;
cursor c_per_bus_group_id(p_person_id in per_people_f.person_id%TYPE) is
  select ppf.business_group_id
  from per_people_f ppf
  where ppf.person_id = p_person_id
  and l_effective_date between ppf.effective_start_date
  and ppf.effective_end_date;
cursor c_pos_bus_group_id(p_position_id in per_positions.position_id%TYPE ) is
  select pos.business_group_id
  from hr_all_positions_f pos  -- Venkat -- Position DT
  where pos.position_id = p_position_id
  and  l_effective_date  between pos.effective_start_date
  and pos.effective_end_date;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location('Getting Ids',1);
-- Getting person_id,position_id
  for c_get_perpos_rec in c_get_perpos_ids
  loop
    l_person_id   := c_get_perpos_rec.person_id;
    l_position_id := c_get_perpos_rec.position_id;
    --Bug#5729582
    -- Bug# 6215050 added NVL as it is raising an error saving to inbox with
    -- out giving effective date
    l_effective_date := nvl(c_get_perpos_rec.effective_date,sysdate);
    exit;
  end loop;
  hr_utility.set_location('Person Id '||to_char(l_person_id),2);
  hr_utility.set_location('Position Id '||to_char(l_position_id),2);
  --
  --
  -- Set up the CLIENT_INFO
  --
  ghr_utility.set_client_info(p_person_id   =>l_person_id,
                              p_position_id =>l_position_id);
  --
  -- Call all supporting business operations
  --
  --
  -- 1) Call chk_pa_request_id to validate oa_request_id
  chk_pa_request_id( p_pa_request_id => p_rec.pa_request_id );
  --
  -- 2) Call info_type procedure to validate info_type
  --
  chk_pa_request_info_type(p_information_type => p_rec.information_type
                ,p_multiple_occurrences_flag => l_multiple_occurrences_flag);
  --
  --
  -- 3) Call count_rows procedure to allow/disallow inserts in extra_info
  chk_count_rows(p_information_type         => p_rec.information_type
                ,p_pa_request_id              => p_rec.pa_request_id
                ,p_multiple_occurrences_flag => l_multiple_occurrences_flag
               );
  --
  --4)
   chk_ddf_for_866(p_rec);

  --5)
   chk_ddf_for_temp_promo(p_rec);
  --
-- Extra DDF Validation for PD Employee information
  ghr_rei_bus.chk_ddf_extra_val(p_rec) ;
  -- Call df procedure to validate Descritive Flex Fields
/*
  ghr_rei_flex.df(p_rec) ;
*/
  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'GHR'
      ,p_descflex_name      => 'GHR_PA_REQUEST_EXTRA_INFO'
      ,p_attribute_category => p_rec.rei_attribute_category
      ,p_attribute1_name    => 'REI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.REI_ATTRIBUTE1
      ,p_attribute2_name    => 'REI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.REI_ATTRIBUTE2
      ,p_attribute3_name    => 'REI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.REI_ATTRIBUTE3
      ,p_attribute4_name    => 'REI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.REI_ATTRIBUTE4
      ,p_attribute5_name    => 'REI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.REI_ATTRIBUTE5
      ,p_attribute6_name    => 'REI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.REI_ATTRIBUTE6
      ,p_attribute7_name    => 'REI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.REI_ATTRIBUTE7
      ,p_attribute8_name    => 'REI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.REI_ATTRIBUTE8
      ,p_attribute9_name    => 'REI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.REI_ATTRIBUTE9
      ,p_attribute10_name    => 'REI_ATTRIBUTE10'
      ,p_attribute10_value   => p_rec.REI_ATTRIBUTE10
      ,p_attribute11_name    => 'REI_ATTRIBUTE11'
      ,p_attribute11_value   => p_rec.REI_ATTRIBUTE11
      ,p_attribute12_name    => 'REI_ATTRIBUTE12'
      ,p_attribute12_value   => p_rec.REI_ATTRIBUTE12
      ,p_attribute13_name    => 'REI_ATTRIBUTE13'
      ,p_attribute13_value   => p_rec.REI_ATTRIBUTE13
      ,p_attribute14_name    => 'REI_ATTRIBUTE14'
      ,p_attribute14_value   => p_rec.REI_ATTRIBUTE14
      ,p_attribute15_name    => 'REI_ATTRIBUTE15'
      ,p_attribute15_value   => p_rec.REI_ATTRIBUTE15
      ,p_attribute16_name    => 'REI_ATTRIBUTE16'
      ,p_attribute16_value   => p_rec.REI_ATTRIBUTE16
      ,p_attribute17_name    => 'REI_ATTRIBUTE17'
      ,p_attribute17_value   => p_rec.REI_ATTRIBUTE17
      ,p_attribute18_name    => 'REI_ATTRIBUTE18'
      ,p_attribute18_value   => p_rec.REI_ATTRIBUTE18
      ,p_attribute19_name    => 'REI_ATTRIBUTE19'
      ,p_attribute19_value   => p_rec.REI_ATTRIBUTE19
      ,p_attribute20_name    => 'REI_ATTRIBUTE20'
      ,p_attribute20_value   => p_rec.REI_ATTRIBUTE20
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  --
  hr_utility.set_location(l_proc, 15);
  -- Call ddf procedure to validate Developer Descritive Flex Fields
  --
/*
  ghr_rei_flex_ddf.ddf(p_rec) ;
*/
-- Business group Id has to be populated for the server side DDF Validation
-- Get the Business Group Id  as follows
-- Get the person_id/position_id from ghr_pa_requests using pa_request_id
-- With person_id/position_id get the business group id form per_peope_f/per_positions
-- Set the business group_id using fnd_profile.put
-- If there is no person_id or position_id in ghr_pa_requests do not validate using dflex -- ??

--Getting Business Group Id
  if l_person_id is not null then
  for c_per_bus_rec in c_per_bus_group_id(l_person_id)
    loop
      l_bus_group_id := c_per_bus_rec.business_group_id;
      exit;
    end loop;
  end if;
  if l_person_id is null then
  if l_position_id is not null then
    for c_pos_bus_rec in c_pos_bus_group_id(l_position_id)
      loop
        l_bus_group_id := c_pos_bus_rec.business_group_id;
        exit;
      end loop;
  end if;
  end if;
if l_person_id is not null or l_position_id is not null then
--Putting the BUSINESS GROUP_ID
  hr_utility.set_location('BG ID '||l_bus_group_id,4);
  fnd_profile.put('PER_BUSINESS_GROUP_ID',l_bus_group_id);
  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'GHR'
      ,p_descflex_name      => 'Extra PA Request Info DDF'
      ,p_attribute_category => p_rec.rei_information_category
      ,p_attribute1_name    => 'REI_INFORMATION1'
      ,p_attribute1_value   => p_rec.REI_INFORMATION1
      ,p_attribute2_name    => 'REI_INFORMATION2'
      ,p_attribute2_value   => p_rec.REI_INFORMATION2
      ,p_attribute3_name    => 'REI_INFORMATION3'
      ,p_attribute3_value   => p_rec.REI_INFORMATION3
      ,p_attribute4_name    => 'REI_INFORMATION4'
      ,p_attribute4_value   => p_rec.REI_INFORMATION4
      ,p_attribute5_name    => 'REI_INFORMATION5'
      ,p_attribute5_value   => p_rec.REI_INFORMATION5
      ,p_attribute6_name    => 'REI_INFORMATION6'
      ,p_attribute6_value   => p_rec.REI_INFORMATION6
      ,p_attribute7_name    => 'REI_INFORMATION7'
      ,p_attribute7_value   => p_rec.REI_INFORMATION7
      ,p_attribute8_name    => 'REI_INFORMATION8'
      ,p_attribute8_value   => p_rec.REI_INFORMATION8
      ,p_attribute9_name    => 'REI_INFORMATION9'
      ,p_attribute9_value   => p_rec.REI_INFORMATION9
      ,p_attribute10_name    => 'REI_INFORMATION10'
      ,p_attribute10_value   => p_rec.REI_INFORMATION10
      ,p_attribute11_name    => 'REI_INFORMATION11'
      ,p_attribute11_value   => p_rec.REI_INFORMATION11
      ,p_attribute12_name    => 'REI_INFORMATION12'
      ,p_attribute12_value   => p_rec.REI_INFORMATION12
      ,p_attribute13_name    => 'REI_INFORMATION13'
      ,p_attribute13_value   => p_rec.REI_INFORMATION13
      ,p_attribute14_name    => 'REI_INFORMATION14'
      ,p_attribute14_value   => p_rec.REI_INFORMATION14
      ,p_attribute15_name    => 'REI_INFORMATION15'
      ,p_attribute15_value   => p_rec.REI_INFORMATION15
      ,p_attribute16_name    => 'REI_INFORMATION16'
      ,p_attribute16_value   => p_rec.REI_INFORMATION16
      ,p_attribute17_name    => 'REI_INFORMATION17'
      ,p_attribute17_value   => p_rec.REI_INFORMATION17
      ,p_attribute18_name    => 'REI_INFORMATION18'
      ,p_attribute18_value   => p_rec.REI_INFORMATION18
      ,p_attribute19_name    => 'REI_INFORMATION19'
      ,p_attribute19_value   => p_rec.REI_INFORMATION19
      ,p_attribute20_name    => 'REI_INFORMATION20'
      ,p_attribute20_value   => p_rec.REI_INFORMATION20
      ,p_attribute21_name    => 'REI_INFORMATION21'
      ,p_attribute21_value   => p_rec.REI_INFORMATION21
      ,p_attribute22_name    => 'REI_INFORMATION22'
      ,p_attribute22_value   => p_rec.REI_INFORMATION22
      ,p_attribute23_name    => 'REI_INFORMATION23'
      ,p_attribute23_value   => p_rec.REI_INFORMATION23
      ,p_attribute24_name    => 'REI_INFORMATION24'
      ,p_attribute24_value   => p_rec.REI_INFORMATION24
      ,p_attribute25_name    => 'REI_INFORMATION25'
      ,p_attribute25_value   => p_rec.REI_INFORMATION25
      ,p_attribute26_name    => 'REI_INFORMATION26'
      ,p_attribute26_value   => p_rec.REI_INFORMATION26
      ,p_attribute27_name    => 'REI_INFORMATION27'
      ,p_attribute27_value   => p_rec.REI_INFORMATION27
      ,p_attribute28_name    => 'REI_INFORMATION28'
      ,p_attribute28_value   => p_rec.REI_INFORMATION28
      ,p_attribute29_name    => 'REI_INFORMATION29'
      ,p_attribute29_value   => p_rec.REI_INFORMATION29
      ,p_attribute30_name    => 'REI_INFORMATION30'
      ,p_attribute30_value   => p_rec.REI_INFORMATION30
      );
end if;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
l_person_id  per_people_f.person_id%type;
l_position_id per_positions.position_id%type;
l_bus_group_id per_people_f.business_group_id%type;

-- Bug#5729582 (i)added local variable l_effective_date
-- (ii) Modified the cursors c_get_perpos_ids,c_per_bus_group_id,c_pos_bus_group_id
l_effective_date ghr_pa_requests.effective_date%type;

cursor c_get_perpos_ids is
  select par.person_id,nvl(par.from_position_id,par.to_position_id) position_id,
         par.effective_date
  from ghr_pa_requests  par
  where pa_request_id = p_rec.pa_request_id;
cursor c_per_bus_group_id(p_person_id in per_people_f.person_id%TYPE) is
  select ppf.business_group_id
  from per_people_f ppf
  where ppf.person_id = p_person_id
  and l_effective_date between ppf.effective_start_date
  and ppf.effective_end_date;
cursor c_pos_bus_group_id(p_position_id in per_positions.position_id%TYPE ) is
  select pos.business_group_id
  from hr_all_positions_f pos  -- Venkat -- Position DT
  where pos.position_id = p_position_id
  and  l_effective_date  between pos.effective_start_date
  and pos.effective_end_date;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location('Getting Ids',1);
-- Getting person_id,position_id
  for c_get_perpos_rec in c_get_perpos_ids
  loop
    l_person_id   := c_get_perpos_rec.person_id;
    l_position_id := c_get_perpos_rec.position_id;
    --Bug#5729582
    -- Bug#6215050 added NVL to consider sysdate if effective date is NULL
    l_effective_date := NVL(c_get_perpos_rec.effective_date,sysdate);
    exit;
  end loop;
  hr_utility.set_location('Person Id '||to_char(l_person_id),2);
  hr_utility.set_location('Position Id '||to_char(l_position_id),2);
  --
  --
  -- Set up the CLIENT_INFO
  --
  ghr_utility.set_client_info(p_person_id   =>l_person_id,
                              p_position_id =>l_position_id);
  -- Call all supporting business operations
  --
   chk_ddf_for_866(p_rec);
  --
   chk_ddf_for_temp_promo(p_rec);
  --
  -- 2) Check those columns which cannot be updated have not changed.
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_non_updateable_args (p_rec => p_rec);
-- Extra DDF Validation for PD Employee information
  ghr_rei_bus.chk_ddf_extra_val(p_rec) ;
  --
  -- Call df procedure to validate Descritive Flex Fields
  --
/*
  ghr_rei_flex.df(p_rec) ;
*/
  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'GHR'
      ,p_descflex_name      => 'GHR_PA_REQUEST_EXTRA_INFO'
      ,p_attribute_category => p_rec.rei_attribute_category
      ,p_attribute1_name    => 'REI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.REI_ATTRIBUTE1
      ,p_attribute2_name    => 'REI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.REI_ATTRIBUTE2
      ,p_attribute3_name    => 'REI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.REI_ATTRIBUTE3
      ,p_attribute4_name    => 'REI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.REI_ATTRIBUTE4
      ,p_attribute5_name    => 'REI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.REI_ATTRIBUTE5
      ,p_attribute6_name    => 'REI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.REI_ATTRIBUTE6
      ,p_attribute7_name    => 'REI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.REI_ATTRIBUTE7
      ,p_attribute8_name    => 'REI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.REI_ATTRIBUTE8
      ,p_attribute9_name    => 'REI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.REI_ATTRIBUTE9
      ,p_attribute10_name    => 'REI_ATTRIBUTE10'
      ,p_attribute10_value   => p_rec.REI_ATTRIBUTE10
      ,p_attribute11_name    => 'REI_ATTRIBUTE11'
      ,p_attribute11_value   => p_rec.REI_ATTRIBUTE11
      ,p_attribute12_name    => 'REI_ATTRIBUTE12'
      ,p_attribute12_value   => p_rec.REI_ATTRIBUTE12
      ,p_attribute13_name    => 'REI_ATTRIBUTE13'
      ,p_attribute13_value   => p_rec.REI_ATTRIBUTE13
      ,p_attribute14_name    => 'REI_ATTRIBUTE14'
      ,p_attribute14_value   => p_rec.REI_ATTRIBUTE14
      ,p_attribute15_name    => 'REI_ATTRIBUTE15'
      ,p_attribute15_value   => p_rec.REI_ATTRIBUTE15
      ,p_attribute16_name    => 'REI_ATTRIBUTE16'
      ,p_attribute16_value   => p_rec.REI_ATTRIBUTE16
      ,p_attribute17_name    => 'REI_ATTRIBUTE17'
      ,p_attribute17_value   => p_rec.REI_ATTRIBUTE17
      ,p_attribute18_name    => 'REI_ATTRIBUTE18'
      ,p_attribute18_value   => p_rec.REI_ATTRIBUTE18
      ,p_attribute19_name    => 'REI_ATTRIBUTE19'
      ,p_attribute19_value   => p_rec.REI_ATTRIBUTE19
      ,p_attribute20_name    => 'REI_ATTRIBUTE20'
      ,p_attribute20_value   => p_rec.REI_ATTRIBUTE20
      );
  --
  hr_utility.set_location(l_proc, 15);
  --
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call ddf procedure to validate Developer Descritive Flex Fields
  --
/*
  ghr_rei_flex_ddf.ddf(p_rec) ;
*/
-- Business group Id has to be populated for the server side DDF Validation
-- Get the Business Group Id  as follows
-- Get the person_id/position_id from ghr_pa_requests using pa_request_id
-- With person_id/position_id get the business group id form per_peope_f/per_positions
-- Set the business group_id using fnd_profile.put
-- If there is no person_id or position_id in ghr_pa_requests do not validate using dflex -- ??

--Getting Business Group Id
  if l_person_id is not null then
  for c_per_bus_rec in c_per_bus_group_id(l_person_id)
    loop
      l_bus_group_id := c_per_bus_rec.business_group_id;
      exit;
    end loop;
  end if;
  if l_person_id is null then
  if l_position_id is not null then
    for c_pos_bus_rec in c_pos_bus_group_id(l_position_id)
      loop
        l_bus_group_id := c_pos_bus_rec.business_group_id;
        exit;
      end loop;
  end if;
  end if;
if l_person_id is not null or l_position_id is not null then
--Putting the BUSINESS GROUP_ID
  hr_utility.set_location('BG ID '||l_bus_group_id,4);
  fnd_profile.put('PER_BUSINESS_GROUP_ID',l_bus_group_id);
  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'GHR'
      ,p_descflex_name      => 'Extra PA Request Info DDF'
      ,p_attribute_category => p_rec.rei_information_category
      ,p_attribute1_name    => 'REI_INFORMATION1'
      ,p_attribute1_value   => p_rec.REI_INFORMATION1
      ,p_attribute2_name    => 'REI_INFORMATION2'
      ,p_attribute2_value   => p_rec.REI_INFORMATION2
      ,p_attribute3_name    => 'REI_INFORMATION3'
      ,p_attribute3_value   => p_rec.REI_INFORMATION3
      ,p_attribute4_name    => 'REI_INFORMATION4'
      ,p_attribute4_value   => p_rec.REI_INFORMATION4
      ,p_attribute5_name    => 'REI_INFORMATION5'
      ,p_attribute5_value   => p_rec.REI_INFORMATION5
      ,p_attribute6_name    => 'REI_INFORMATION6'
      ,p_attribute6_value   => p_rec.REI_INFORMATION6
      ,p_attribute7_name    => 'REI_INFORMATION7'
      ,p_attribute7_value   => p_rec.REI_INFORMATION7
      ,p_attribute8_name    => 'REI_INFORMATION8'
      ,p_attribute8_value   => p_rec.REI_INFORMATION8
      ,p_attribute9_name    => 'REI_INFORMATION9'
      ,p_attribute9_value   => p_rec.REI_INFORMATION9
      ,p_attribute10_name    => 'REI_INFORMATION10'
      ,p_attribute10_value   => p_rec.REI_INFORMATION10
      ,p_attribute11_name    => 'REI_INFORMATION11'
      ,p_attribute11_value   => p_rec.REI_INFORMATION11
      ,p_attribute12_name    => 'REI_INFORMATION12'
      ,p_attribute12_value   => p_rec.REI_INFORMATION12
      ,p_attribute13_name    => 'REI_INFORMATION13'
      ,p_attribute13_value   => p_rec.REI_INFORMATION13
      ,p_attribute14_name    => 'REI_INFORMATION14'
      ,p_attribute14_value   => p_rec.REI_INFORMATION14
      ,p_attribute15_name    => 'REI_INFORMATION15'
      ,p_attribute15_value   => p_rec.REI_INFORMATION15
      ,p_attribute16_name    => 'REI_INFORMATION16'
      ,p_attribute16_value   => p_rec.REI_INFORMATION16
      ,p_attribute17_name    => 'REI_INFORMATION17'
      ,p_attribute17_value   => p_rec.REI_INFORMATION17
      ,p_attribute18_name    => 'REI_INFORMATION18'
      ,p_attribute18_value   => p_rec.REI_INFORMATION18
      ,p_attribute19_name    => 'REI_INFORMATION19'
      ,p_attribute19_value   => p_rec.REI_INFORMATION19
      ,p_attribute20_name    => 'REI_INFORMATION20'
      ,p_attribute20_value   => p_rec.REI_INFORMATION20
      ,p_attribute21_name    => 'REI_INFORMATION21'
      ,p_attribute21_value   => p_rec.REI_INFORMATION21
      ,p_attribute22_name    => 'REI_INFORMATION22'
      ,p_attribute22_value   => p_rec.REI_INFORMATION22
      ,p_attribute23_name    => 'REI_INFORMATION23'
      ,p_attribute23_value   => p_rec.REI_INFORMATION23
      ,p_attribute24_name    => 'REI_INFORMATION24'
      ,p_attribute24_value   => p_rec.REI_INFORMATION24
      ,p_attribute25_name    => 'REI_INFORMATION25'
      ,p_attribute25_value   => p_rec.REI_INFORMATION25
      ,p_attribute26_name    => 'REI_INFORMATION26'
      ,p_attribute26_value   => p_rec.REI_INFORMATION26
      ,p_attribute27_name    => 'REI_INFORMATION27'
      ,p_attribute27_value   => p_rec.REI_INFORMATION27
      ,p_attribute28_name    => 'REI_INFORMATION28'
      ,p_attribute28_value   => p_rec.REI_INFORMATION28
      ,p_attribute29_name    => 'REI_INFORMATION29'
      ,p_attribute29_value   => p_rec.REI_INFORMATION29
      ,p_attribute30_name    => 'REI_INFORMATION30'
      ,p_attribute30_value   => p_rec.REI_INFORMATION30
      );
end if;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_rei_shd.g_rec_type) is
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
procedure chk_ddf_extra_val
  (p_rec   in ghr_rei_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'chk_ddf_extra_val';
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
/*
      chk_service
        (p_pa_request_extra_info_id => p_rec.pa_request_extra_info_id
        ,p_service                  => p_rec.rei_information5
        ,p_effective_date           => sysdate
        ,p_object_version_number    => p_rec.object_version_number
        );
*/
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
end chk_ddf_extra_val;
end ghr_rei_bus;

/
