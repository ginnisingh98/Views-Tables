--------------------------------------------------------
--  DDL for Package Body GHR_PAR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAR_BUS" as
/* $Header: ghparrhi.pkb 120.5.12010000.3 2008/10/22 07:10:55 utokachi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_par_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_non_updateable_args>----------------------------|
-- ----------------------------------------------------------------------------
-- May not be reuqired as the Family code also is updateable now.

-- ---------------------------------------------------------------------------
--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_nature_of_action_id >---------------------------|
--  ---------------------------------------------------------------------------
--
-- Description:
--   Validates that the nature_of_action is valid for the specific family
--   as of the effective_date
--
-- Pre Conditions:
--
-- In Parameters:
--   p_first_nature_of_action_id
--   p_pa_request_id
--   p_object_version_number
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised and the process is terminated
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- ---------------------------------------------------------------------------
  procedure chk_nature_of_action_id
   (p_first_nature_of_action_id    in  ghr_pa_requests.first_noa_id%TYPE
   ,p_pa_request_id                in  ghr_pa_requests.pa_request_id%TYPE
   ,p_noa_family_code              in  ghr_pa_requests.noa_family_code%TYPE
   ,p_object_version_number        in  ghr_pa_requests.object_version_number%TYPE
   ,p_effective_date               in  date
   )is
  --
  l_proc           varchar2(72) := g_package ||'chk_nature_of_action_id';
  l_exists         boolean      := false;
  l_api_updating   boolean;
  l_effective_date date         := trunc(nvl(p_effective_date,sysdate));

  Cursor    cur_noa_id is
    select  1
    from    ghr_noa_families  noa
    where   noa.nature_of_action_id = p_first_nature_of_action_id
    and     noa.noa_family_code     = p_noa_family_code
    and     l_effective_date
    between nvl(noa.start_date_active,l_effective_date)
    and     nvl(noa.end_date_active,l_effective_date)
    and     noa.enabled_flag        = 'Y';

   begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

  --check mandatory arguments have been set
    hr_api.mandatory_arg_error
   (p_api_name       => l_proc,
    p_argument       => 'noa_family_code',
    p_argument_value => p_noa_family_code
   );

    hr_utility.set_location(l_proc, 20);
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The nature_of_action_id has changed
  --  c) a record is being inserted
  --
    l_api_updating := ghr_par_shd.api_updating
      (p_pa_request_id         => p_pa_request_id
      ,p_object_version_number => p_object_version_number
      );
    hr_utility.set_location(l_proc, 30);
  --
    if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.first_noa_id, hr_api.g_number)
       <> nvl(p_first_nature_of_action_id,hr_api.g_number))
    or
       (NOT l_api_updating))
    then
      hr_utility.set_location(l_proc, 40);
    --
    -- Check if  first_nature_of_action_id is valid
    --
      If p_first_nature_of_action_id is not null then
        for noa_id in cur_noa_id loop
          l_exists := true;
          exit;
        end loop;

    -- to include logic to check if not valid as of the effective date
       if not l_exists then
         hr_utility.set_message(8301, 'GHR_38167_INV_NAT_OF_ACT_FAM');
         hr_utility.raise_error;
       end if;
      end if;
    end if;
   --
     hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
   end chk_nature_of_action_id;
--

-- ---------------------------------------------------------------------------
-- --------------------------- <chk_second_nature_of_action >------------------
-- ---------------------------------------------------------------------------

-- To check that the second nature of action is valid for the specific first_nature_of_action_id

 procedure chk_second_nature_of_action_id
   (p_first_nature_of_action_id    in  ghr_pa_requests.first_noa_id%TYPE
   ,p_second_nature_of_action_id   in  ghr_pa_requests.first_noa_id%TYPE
  , p_first_noa_code               in  ghr_pa_requests.first_noa_code%type
   ,p_pa_request_id                in  ghr_pa_requests.pa_request_id%TYPE
 --  ,p_noa_family_code              in  ghr_pa_requests.noa_family_code%TYPE
   ,p_object_version_number        in  ghr_pa_requests.object_version_number%TYPE
   ,p_effective_date               in  date
   )is
  --
  l_proc           varchar2(72) := g_package ||'chk_second_nature_of_action_id';
  l_exists         boolean      := false;
  l_api_updating   boolean;
  l_effective_date date         := trunc(nvl(p_effective_date,sysdate));

  Cursor    cur_sec_noa_id is
    select  1
    from    ghr_dual_actions  dua
    where   dua.first_noa_id  = p_first_nature_of_action_id
    and     dua.second_noa_id = p_second_nature_of_action_id;
   -- and     l_effective_date
   -- between nvl(noa.start_date_active,l_effective_date)
   -- and     nvl(noa.end_date_active,l_effective_date)
   -- and     noa.enabled_flag        = 'Y';

   begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

  /*--check mandatory arguments have been set
   hr_api.mandatory_arg_error
   (p_api_name       => l_proc,
    p_argument       => 'noa_family_code',
    p_argument_value => p_noa_family_code
   );
  */

    hr_utility.set_location(l_proc, 20);
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The nature_of_action_id has changed
  --  c) a record is being inserted
  --
    l_api_updating := ghr_par_shd.api_updating
      (p_pa_request_id         => p_pa_request_id
      ,p_object_version_number => p_object_version_number
      );
    hr_utility.set_location(l_proc, 30);
  --
    if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.second_noa_id, hr_api.g_number)
       <> nvl(p_second_nature_of_action_id,hr_api.g_number))
    or
       (NOT l_api_updating))
    then
      hr_utility.set_location(l_proc, 40);
    --
    -- Check if  second_nature_of_action_id is valid
    --
      If p_second_nature_of_action_id is not null then
        If p_first_nature_of_action_id is null then
          hr_utility.set_message(8301,'GHR_38273_FIRST_NOA_MUST');
          hr_utility.raise_error;
        Else
          If p_first_noa_code not in ('001','002') then
            for noa_id in cur_sec_noa_id loop
              l_exists := true;
              exit;
            end loop;

            if not l_exists then
              hr_utility.set_message(8301, 'GHR_38274_INVALID_DUAL_NOA');
              hr_utility.raise_error;
            end if;
          End if;
        End if;
      end if;
    end if;
   --
     hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
   end chk_second_nature_of_action_id;


--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_valid_person >---------------------------|
--  ---------------------------------------------------------------------------
--
-- Description:
--   Validates that the person_id exists in the table per_people_f,
--   as of the effective_date
--
-- Pre Conditions:
--
-- In Parameters:
--   p_person_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised and the process is terminated
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- ---------------------------------------------------------------------------
function chk_valid_person_id
  (p_val_person_id    in  ghr_pa_requests.requested_by_person_id%TYPE
  ,p_effective_date   in  date
  ) return char is
  --
  l_proc           varchar2(72) := g_package ||'chk_valid_person_id';
  l_exists         boolean := false;

  --
  cursor cur_per_id is
    SELECT  1
    FROM   per_all_people_f per
    where  per.person_id = p_val_person_id;

  cursor cur_per_dt_id is
    SELECT  1
    FROM    per_all_people_f per
    WHERE   per.person_id = p_val_person_id
    AND     nvl(p_effective_date,sysdate)
    BETWEEN per.effective_start_date and per.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --Check if the person exists
  --
  for cur_person_id in cur_per_id loop
    hr_utility.set_location(l_proc, 20);
    l_exists := true;
    exit;
  end loop;
  If l_exists then
      l_exists := false;
  -- check if person exists as of the effective date
    for csr_person_id_rec in cur_per_dt_id loop
      l_exists := true;
      exit;
    end loop;
    hr_utility.set_location(l_proc, 50);
    if not l_exists then
       return('INV_PER_DT');
    end if;
  else
    return('INV_PER');
  end if;
  return('X');
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
end chk_valid_person_id;
--
--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_additional_info_person_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the additional_info_person_id exists on the ghr_PERSON_F
--    table at a given effective_date
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--   p_pa_request_id
--   p_additional_info_person_id
--   p_effective_date
--   p_object_version_number
--
--  Post Success :
--    Processing continues if the person id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    person id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------

procedure chk_additional_info_person_id
  (p_pa_request_id                  in ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number          in ghr_pa_requests.object_version_number%TYPE
  ,p_additional_info_person_id         in ghr_pa_requests.additional_info_person_id%TYPE
  ,p_effective_date                 in date) is

  l_exists         varchar2(15);
  l_proc           varchar2(72)  := g_package ||'chk_additional_info_person_id';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The additional_info_person_id value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.additional_info_person_id, hr_api.g_number)
      <> nvl(p_additional_info_person_id,hr_api.g_number))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if  additional_info_person_id is valid
    --
    If p_additional_info_person_id is not null then
    --
       l_exists := chk_valid_person_id(p_additional_info_person_id,p_effective_date);
       if nvl(l_exists,'x') = 'INV_PER_DT' then
         hr_utility.set_message(8301, 'GHR_38061_INV_ADD_INFO_PER_DT');
         hr_utility.raise_error;
       elsif nvl(l_exists,'x') = 'INV_PER' then
         hr_utility.set_message(8301, 'GHR_38062_INV_ADD_INFO_PERSON');
         hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_additional_info_person_id;



--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_requested_by_person_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the requested_by_person_id exists on the ghr_PERSON_F
--    table at a given effective_date
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--   p_pa_request_id
--   p_requested_by_person_id
--   p_effective_date
--   p_object_version_number
--
--  Post Success :
--    Processing continues if the person id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    person id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------

procedure chk_requested_by_person_id
  (p_pa_request_id                  in ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number          in ghr_pa_requests.object_version_number%TYPE
  ,p_requested_by_person_id         in ghr_pa_requests.requested_by_person_id%TYPE
  ,p_effective_date                 in date) is

  l_exists         varchar2(15);
  l_proc           varchar2(72)  := g_package ||'chk_requested_by_person_id';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The requested_by_person_id value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.requested_by_person_id, hr_api.g_number)
      <> nvl(p_requested_by_person_id,hr_api.g_number))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if  requested_by_person_id is valid
    --
    If p_requested_by_person_id is not null then
    --
       l_exists := chk_valid_person_id(p_requested_by_person_id,p_effective_date);
       if nvl(l_exists,'x') = 'INV_PER_DT' then
         hr_utility.set_message(8301, 'GHR_38063_INV_REQ_PERSON_DT');
         hr_utility.raise_error;
       elsif nvl(l_exists,'x') = 'INV_PER' then
         hr_utility.set_message(8301, 'GHR_38064_INV_REQ_PERSON');
         hr_utility.raise_error;
       end if;

    end if;
    hr_utility.set_location(l_proc, 50);
    --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_requested_by_person_id;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_person_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the additional_info_person_id exists on the ghr_PERSON_F
--    table at a given effective_date
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--   p_pa_request_id
--   p_person_id
--   p_effective_date
--   p_object_version_number
--
--  Post Success :
--    Processing continues if the person id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    person id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------

procedure chk_person_id
  (p_pa_request_id                  in ghr_pa_requests.pa_request_id%TYPE
  ,p_noa_family_code                in ghr_pa_requests.noa_family_code%TYPE
  ,p_object_version_number          in ghr_pa_requests.object_version_number%TYPE
  ,p_person_id                      in ghr_pa_requests.person_id%TYPE
  ,p_first_noa_cancel_or_correct in ghr_pa_requests.first_noa_cancel_or_correct%TYPE
  ,p_effective_date                 in date) is

  l_exists         varchar2(15);
  l_proc           varchar2(72)  :=  g_package ||'chk_person_id';
  l_api_updating   boolean;
  l_person_type    per_person_types.system_person_type%type := Null;
  l_effective_start_date date := null;
  --
   cursor c_person_type_rec is
    select ppf.effective_start_date,
           ppt.system_person_type
    from   per_all_people_f ppf,
           per_person_types ppt
    where  ppf.person_id = p_person_id
    and    ppf.effective_start_date < nvl(p_effective_date,sysdate)
    and    ppt.person_type_id       = ppf.person_type_id
    order by 1 desc;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
    If p_person_id is not null then
    --
       l_exists := chk_valid_person_id(p_person_id,p_effective_date);
       if nvl(l_exists,'x') = 'INV_PER_DT' then
         hr_utility.set_message(8301, 'GHR_38059_INV_PERSON_DT');
         hr_utility.raise_error;
       elsif nvl(l_exists,'x') = 'INV_PER' then
         hr_utility.set_message(8301, 'GHR_38060_INV_PERSON');
         hr_utility.raise_error;
       end if;
          -- If conversion action and the person type is EX_EMP check to ensure that

       -- he has not been terminated more than 3 days since the effective_date
     IF p_first_noa_cancel_or_correct not in (ghr_history_api.g_cancel,'CORRECT') THEN
       If p_noa_family_code = 'CONV_APP' then
         hr_utility.set_location('Conversion to app',1);
         for person_type_rec in c_person_type_rec loop
           l_person_type := person_type_rec.system_person_type;
           l_effective_start_date := person_type_rec.effective_start_date;
           exit;
         end loop;
         If nvl(l_person_type,hr_api.g_varchar2) = 'EX_EMP' then
           hr_utility.set_location(' Ex Emp in Conv',1);
           hr_utility.set_location('Termination date ' || l_effective_start_date,1);
           if (nvl(p_effective_date,sysdate) - 3) >= (l_effective_start_date ) then
              hr_utility.set_message(8301,'GHR_38645_EX_EMP_MORE_THAN_3');
              hr_utility.raise_error;
           end if;
         End if;
       End if;
     END IF;

    end if;
    hr_utility.set_location(l_proc, 50);
    --
  --end if;
  hr_utility.set_location(l_proc, 60);
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_person_id;


--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_authorized_by_person_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the authorized_by_person_id exists on the ghr_PERSON_F
--    table at a given effective_date
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--   p_pa_request_id
--   p_authorized_by_person_id
--   p_effective_date
--   p_object_version_number
--
--  Post Success :
--    Processing continues if the person id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    person id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------

procedure chk_authorized_by_person_id
  (p_pa_request_id                  in ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number          in ghr_pa_requests.object_version_number%TYPE
  ,p_authorized_by_person_id        in ghr_pa_requests.authorized_by_person_id%TYPE
  ,p_effective_date                 in date) is

  l_exists         varchar2(15);
  l_proc           varchar2(72)  := g_package ||'chk_authorized_by_person_id';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  hr_utility.set_location(l_proc, 20);
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The authorized_by_person_id value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.authorized_by_person_id, hr_api.g_number)
      <> nvl(p_authorized_by_person_id,hr_api.g_number))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if  authorized_by_person_id is valid
    --
    If p_authorized_by_person_id is not null then
    --
       l_exists := chk_valid_person_id(p_authorized_by_person_id,p_effective_date);
       if nvl(l_exists,'x') = 'INV_PER_DT' then
         hr_utility.set_message(8301, 'GHR_38065_INV_AUTH_PERSON_DT');
         hr_utility.raise_error;
       elsif nvl(l_exists,'x') = 'INV_PER' then
         hr_utility.set_message(8301, 'GHR_38066_INV_AUTH_PERSON');
         hr_utility.raise_error;
       end if;

    end if;
    hr_utility.set_location(l_proc, 50);
    --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_authorized_by_person_id;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_employee_assignment>----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that the employee_assignment_id exists in the table per_assignments_f,
--   as of the effective_date
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_pa_request_id
--   p_object_version_number
--   p_employee_assignment_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised and the process is terminated
--
-- Access Status:
--   Internal Table Handler Use Only.
--

procedure chk_employee_assignment_id
  (p_pa_request_id              in  ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number      in ghr_pa_requests.object_version_number%TYPE
  ,p_employee_assignment_id    in  ghr_pa_requests.employee_assignment_id%TYPE
  ,p_effective_date  in  date
   )	is
  --
  l_proc     varchar2(72) := g_package||'chk_employee_assignment_id';
  l_exists   boolean   := false;
  l_person_id per_all_people_f.person_id%type;
  l_api_updating boolean;
  l_effective_date  date;
  l_st_date  date;
  l_ed_date  date;
  --
  cursor cur_par_noa_code is
   SELECT  first_noa_code,noa_family_code
   FROM    ghr_pa_requests par
   WHERE   par.pa_request_id = p_pa_request_id;

  cursor cur_asg_id is
    SELECT   person_id
    FROM     per_all_assignments_f asg
    WHERE    asg.assignment_id = p_employee_assignment_id;

  cursor cur_asg_dt_id is
    SELECT  1
    FROM    per_all_assignments_f asg
    WHERE   asg.assignment_id = p_employee_assignment_id
    AND     nvl(p_effective_date,sysdate)
    BETWEEN asg.effective_start_date and asg.effective_end_date;
--7015822
cursor cur_ex_emp(p_person_id in number) is
    select ppf.effective_start_date,
           ppt.system_person_type
    from   per_all_people_f ppf,
           per_person_types ppt
    where  ppf.person_id = p_person_id
    and    ppf.effective_start_date <= nvl(p_effective_date,sysdate)
    and    ppt.person_type_id       = ppf.person_type_id
    order by 1 desc;
--7015822
 --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The assignment_id value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.employee_assignment_id,hr_api.g_number)
      <> nvl(p_employee_assignment_id,hr_api.g_number))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check if  employee_assignment_id is valid
    --
    If p_employee_assignment_id is not null then
     for  recasg in cur_asg_id loop
       l_exists := true;
       l_person_id := recasg.person_id;
       exit;
     end loop;
  --
     hr_utility.set_location(l_proc, 40);
     if l_exists then
        l_exists := false;
         for par_noa_code_rec in cur_par_noa_code loop
           if par_noa_code_rec.noa_family_code <> 'CONV_APP' then
             l_exists := false;
             for recasg in cur_asg_dt_id loop
               l_exists := true;
               exit;
             end loop;

	      --BUG 7015822- Added this condition to handle an appointment of an Ex-Employee
	      -- when it is saved to inbox by giving only date and opened again to give an employee
	      --details and saved to inbox again raising GHR_38067_INV_ASSIGNMENT_DT error
             if (not l_exists) and
	        par_noa_code_rec.noa_family_code = 'APP' then
		for rec_cur_ex_emp in cur_ex_emp(p_person_id => l_person_id)
		loop
		  if  rec_cur_ex_emp.system_person_type = 'EX_EMP' then
		      l_exists := true;
		  end if;
		  exit;
                end loop;
	     end if;
		-- 7015822

             if not l_exists then
               hr_utility.set_message(8301, 'GHR_38067_INV_ASSIGNMENT_DT');
               hr_utility.raise_error;
             end if;
           end if;
         end loop;
     else
       hr_utility.set_message(8301, 'GHR_38068_INV_ASSIGNMENT');
       hr_utility.raise_error;
     end if;
   end if;
 end if;
 hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
 end chk_employee_assignment_id;



-- ----------------------------------------------------------------------------
-- |---------------------------< chk_from_position_id>----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that the from_position_id exists in the table per_assignments_f,
--   as of the effective_date
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_pa_request_id
--   p_object_version_number
--   p_employee_assignment_id
--   p_from_position_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised and the process is terminated
--
-- Access Status:
--   Internal Table Handler Use Only.
--

procedure chk_from_position_id
  (p_pa_request_id              in  ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number      in  ghr_pa_requests.object_version_number%TYPE
  ,p_employee_assignment_id     in  ghr_pa_requests.employee_assignment_id%TYPE
  ,p_from_position_id           in  ghr_pa_requests.from_position_id%type
  ,p_effective_date  in  date
   )	is
  --
  l_proc     varchar2(72) := g_package||'chk_from_position_id';
  l_exists   boolean   := false;
  l_api_updating boolean;
  l_effective_date  date;
  l_st_date  date;
  l_ed_date  date;
  --
  cursor cur_pos_id is
    SELECT   1
    FROM     per_all_assignments_f asg
    WHERE    asg.assignment_id  = p_employee_assignment_id
    AND      asg.position_id    = p_from_position_id;
 --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The assignment_id value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.from_position_id,hr_api.g_number)
      <> nvl(p_from_position_id,hr_api.g_number))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check if from_position_id is valid
    --
    If p_from_position_id is not null then
     for  recpos in cur_pos_id loop
       l_exists := true;
       exit;
     end loop;
  --
     if not l_exists then
       hr_utility.set_message(8301, 'GHR_38056_INV_FROM_POSITION');
       hr_utility.raise_error;
     end if;
   end if;
 end if;
 hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
 end chk_from_position_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_first_action_la_code1>----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_first_action_la_code1
  (p_pa_request_id              in  ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number      in  ghr_pa_requests.object_version_number%TYPE
  ,p_first_action_la_code1      in  ghr_pa_requests.first_action_la_code1%TYPE
  ,p_first_nature_of_action_id  in  ghr_pa_requests.first_noa_id%TYPE
  ,p_effective_date             in  date
   )is
  --
  l_proc         varchar2(72) := g_package||'chk_first_action_la_code1';
  l_exists       boolean   := false;
  l_api_updating boolean;
 --Bug# 7501214. added the SUBSTR condition for lac_lookup_code to avoid the error
 -- while checking the LAC codes which are duplicated. Like VWN and VWN1 etc.

  cursor c_la_code is
    select  hl.lookup_code ,
            hl.meaning
    from    hr_lookups hl ,
            ghr_noac_las       nla
    where   nla.nature_of_action_id  = p_first_nature_of_action_id
    and     SUBSTR(nla.lac_lookup_code,1,3)      = p_first_action_la_code1
    and     nla.valid_first_lac_flag = 'Y'
    and     hl.lookup_type           = 'GHR_US_LEGAL_AUTHORITY'
    and     hl.lookup_code           = nla.lac_lookup_code
    and     hl.enabled_flag          = 'Y'
    and     nvl(p_effective_date,trunc(sysdate))
    between nvl(hl.start_date_active,nvl(p_effective_date,trunc(sysdate)))
    and     nvl(hl.end_date_active,nvl(p_effective_date,trunc(sysdate)));

begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
 /* --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The first_action_la_code1 value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.first_action_la_code1,hr_api.g_varchar2)
      <> nvl(p_first_action_la_code1,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then

    hr_utility.set_location(l_proc, 30);
    --
*/
    -- Check if  first_action_la_code1 is valid
    --
    If p_first_action_la_code1 is not null then
      for la_code  in c_la_code loop
        l_exists := true;
        exit;
      end loop;
  --
      hr_utility.set_location(l_proc, 40);
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38105_INV_FIRST_LA_CODE1');
        hr_utility.raise_error;
      end if;
    end if;
 -- end if;
 hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
 end chk_first_action_la_code1;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_first_action_la_code2>----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_first_action_la_code2
  (p_pa_request_id              in  ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number      in  ghr_pa_requests.object_version_number%TYPE
  ,p_first_action_la_code2      in  ghr_pa_requests.first_action_la_code2%TYPE
  ,p_first_nature_of_action_id  in  ghr_pa_requests.first_noa_id%TYPE
  ,p_effective_date             in  date
   )is
  --
  l_proc         varchar2(72) := g_package||'chk_first_action_la_code2';
  l_exists       boolean   := false;
  l_api_updating boolean;
 --Bug# 7501214. added the SUBSTR condition for lac_lookup_code to avoid the error
 -- while checking the LAC codes which are duplicated. Like VWN and VWN1 etc.
  cursor c_la_code is
    select  hl.lookup_code ,
            hl.meaning
    from    hr_lookups hl,
            ghr_noac_las       nla
    where   nla.nature_of_action_id = p_first_nature_of_action_id
    and     SUBSTR(nla.lac_lookup_code,1,3)     = p_first_action_la_code2
    and     nla.valid_second_lac_flag = 'Y'
    and     hl.lookup_type          = 'GHR_US_LEGAL_AUTHORITY'
    and     hl.lookup_code          = nla.lac_lookup_code
    and     hl.enabled_flag         = 'Y'
    and     nvl(p_effective_date,trunc(sysdate))
    between nvl(hl.start_date_active,nvl(p_effective_date,trunc(sysdate)))
    and     nvl(hl.end_date_active,nvl(p_effective_date,trunc(sysdate)));

begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
/*
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The first_action_la_code2 value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.first_action_la_code2,hr_api.g_varchar2)
      <> nvl(p_first_action_la_code2,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
*/
    --
    -- Check if  first_action_la_code2 is valid
    --
    If p_first_action_la_code2 is not null then
      for la_code  in c_la_code loop
        l_exists := true;
        exit;
      end loop;
  --
      hr_utility.set_location(l_proc, 40);
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38106_INV_FIRST_LA_CODE2');
        hr_utility.raise_error;
      end if;
    end if;
 -- end if;
 hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
 end chk_first_action_la_code2;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_duty_station_id>----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that the duty_station_id exists in the table per_duty_stations_f,
--   as of the effective_date
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_pa_request_id
--   p_object_version_number
--   p_duty_station_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised and the process is terminated
--
-- Access Status:
--   Internal Table Handler Use Only.
--

 procedure chk_duty_station_id
  (p_pa_request_id              in  ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number      in  ghr_pa_requests.object_version_number%TYPE
  ,p_duty_station_id            in  ghr_pa_requests.duty_station_id%TYPE
  ,p_effective_date  in  date
   )	is
  --
  l_proc     varchar2(72) := g_package||'chk_duty_station_id';
  l_exists   boolean   := false;
  l_api_updating boolean;
  l_effective_date  date;
  l_st_date  date;
  l_ed_date  date;
  --

  cursor cur_duty_station_id is
    SELECT   1
    FROM     ghr_duty_stations_f dsf
    WHERE    dsf.duty_station_id = p_duty_station_id;

  cursor cur_duty_station_id_dt is
    SELECT  1
    FROM    ghr_duty_stations_f dsf
    WHERE   dsf.duty_station_id = p_duty_station_id
    AND     nvl(p_effective_date,sysdate)
   BETWEEN dsf.effective_start_date and dsf.effective_end_date;
 --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The assignment_id value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 20);
  --
  --
   If p_duty_station_id is not null then
    for  recasg in cur_duty_station_id loop
       l_exists := true;
       exit;
     end loop;
  --
     hr_utility.set_location(l_proc, 40);
     if l_exists then
       l_exists := false;
       for recasg in cur_duty_station_id_dt loop
         l_exists := true;
         exit;
       end loop;
       if not l_exists then
         hr_utility.set_message(8301, 'GHR_38646_INV_DUTY_STN_DT');
         hr_utility.raise_error;
       end if;
    else
       hr_utility.set_message(8301, 'GHR_38647_INV_DUTY_STN');
       hr_utility.raise_error;
     end if;
   end if;
   hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
 end chk_duty_station_id;

--

----------------------------------------------------------------------------
-- |---------------------------< chk_second_action_la_code1>----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_second_action_la_code1
  (p_pa_request_id              in  ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number      in  ghr_pa_requests.object_version_number%TYPE
  ,p_second_action_la_code1     in  ghr_pa_requests.second_action_la_code1%TYPE
  ,p_second_nature_of_action_id in  ghr_pa_requests.second_noa_id%TYPE
  ,p_effective_date             in  date
   )is
  --
  l_proc         varchar2(72) := g_package||'chk_second_action_la_code1';
  l_exists       boolean   := false;
  l_api_updating boolean;
 --Bug# 7501214. added the SUBSTR condition for lac_lookup_code to avoid the error
 -- while checking the LAC codes which are duplicated. Like VWN and VWN1 etc.
  cursor c_la_code is
    select  hl.lookup_code ,
            hl.meaning
    from    hr_lookups hl ,
            ghr_noac_las       nla
    where   nla.nature_of_action_id  = p_second_nature_of_action_id
    and     SUBSTR(nla.lac_lookup_code,1,3)      = p_second_action_la_code1
    and     nla.valid_first_lac_flag = 'Y'
    and     hl.lookup_type           = 'GHR_US_LEGAL_AUTHORITY'
    and     hl.lookup_code           = nla.lac_lookup_code
    and     hl.enabled_flag          = 'Y'
    and     nvl(p_effective_date,trunc(sysdate))
    between nvl(hl.start_date_active,nvl(p_effective_date,trunc(sysdate)))
    and     nvl(hl.end_date_active,nvl(p_effective_date,trunc(sysdate)));

begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  /*
--
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The second_action_la_code1 value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.second_action_la_code1,hr_api.g_varchar2)
      <> nvl(p_second_action_la_code1,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
*/
    --
    -- Check if  second_action_la_code1 is valid
    --
    If p_second_action_la_code1 is not null then
      for la_code  in c_la_code loop
        l_exists := true;
        exit;
      end loop;
  --
      hr_utility.set_location(l_proc, 40);
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38107_INV_SECOND_LA_CODE1');
        hr_utility.raise_error;
      end if;
    end if;
 -- end if;
 hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
 end chk_second_action_la_code1;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_second_action_la_code2>----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_second_action_la_code2
  (p_pa_request_id              in  ghr_pa_requests.pa_request_id%TYPE
  ,p_object_version_number      in  ghr_pa_requests.object_version_number%TYPE
  ,p_second_action_la_code2     in  ghr_pa_requests.second_action_la_code2%TYPE
  ,p_second_nature_of_action_id in  ghr_pa_requests.second_noa_id%TYPE
  ,p_effective_date             in  date
   )is
  --
  l_proc         varchar2(72) := g_package||'chk_second_action_la_code2';
  l_exists       boolean   := false;
  l_api_updating boolean;
 --Bug# 7501214. added the SUBSTR condition for lac_lookup_code to avoid the error
 -- while checking the LAC codes which are duplicated. Like VWN and VWN1 etc.
  cursor c_la_code is
    select  hl.lookup_code ,
            hl.meaning
    from    hr_lookups hl ,
            ghr_noac_las       nla
    where   nla.nature_of_action_id   = p_second_nature_of_action_id
    and     substr(nla.lac_lookup_code,1,3)       = p_second_action_la_code2
    and     nla.valid_second_lac_flag = 'Y'
    and     hl.lookup_type            = 'GHR_US_LEGAL_AUTHORITY'
    and     hl.lookup_code            = nla.lac_lookup_code
    and     hl.enabled_flag           = 'Y'
    and     nvl(p_effective_date,trunc(sysdate))
    between nvl(hl.start_date_active,nvl(p_effective_date,trunc(sysdate)))
    and     nvl(hl.end_date_active,nvl(p_effective_date,trunc(sysdate)));

begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
/*
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The second_action_la_code2 value has changed
  --  c) a record is being inserted
  --
  l_api_updating := ghr_par_shd.api_updating
    (p_pa_request_id => p_pa_request_id
    ,p_object_version_number => p_object_version_number
    );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating
      and nvl(ghr_par_shd.g_old_rec.second_action_la_code2,hr_api.g_varchar2)
      <> nvl(p_second_action_la_code2,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
*/
    -- Check if  second_action_la_code2 is valid
    --
    If p_second_action_la_code2 is not null then
      for la_code  in c_la_code loop
        l_exists := true;
        exit;
      end loop;
  --
      hr_utility.set_location(l_proc, 40);
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38108_INV_SECOND_LA_CODE2');
        hr_utility.raise_error;
      end if;
    end if;
 -- end if;
 hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
 end chk_second_action_la_code2;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting  operations

  -- Check that the routing_group is not null

/*  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'routing_group_id',
     p_argument_value => p_rec.routing_group_id); */

-- Check that the Noa_Family Code is not null
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'Noa Family Code',
     p_argument_value => p_rec.noa_family_code);

   --  check person_id
  --
         hr_utility.set_location('chk person id' ,1);
          chk_person_id(p_pa_request_id             => p_rec.pa_request_id,
                     p_object_version_number     => p_rec.object_version_number,
                     p_noa_family_code           => p_rec.noa_family_code,
                     p_person_id                 => p_rec.person_id,
                     p_first_noa_cancel_or_correct  => p_rec.first_noa_cancel_or_correct,
                     p_effective_date            => p_rec.effective_date
                                    );

  --  check additional_info_person_id
  --
       chk_additional_info_person_id(p_pa_request_id             => p_rec.pa_request_id,
                                     p_object_version_number     => p_rec.object_version_number,
                                     p_additional_info_person_id => p_rec.additional_info_person_id,
                                     p_effective_date            => p_rec.effective_date
                                    );


  --  check requested_by_person_id
  --
        chk_requested_by_person_id(p_pa_request_id => p_rec.pa_request_id,
                                     p_object_version_number =>p_rec.object_version_number,
                                     p_requested_by_person_id =>p_rec.requested_by_person_id,
                                     p_effective_date            =>p_rec.effective_date
                                   );

  --  check authorized_by_person_id
  --

        chk_authorized_by_person_id(p_pa_request_id => p_rec.pa_request_id,
                                     p_object_version_number =>p_rec.object_version_number,
                                     p_authorized_by_person_id => p_rec.authorized_by_person_id,
                                     p_effective_date            =>p_rec.effective_date
                                    );

 --  check employee_assignment_id
 --
       chk_employee_assignment_id(p_pa_request_id          => p_rec.pa_request_id,
                                  p_object_version_number  => p_rec.object_version_number,
                                  p_employee_assignment_id => p_rec.employee_assignment_id,
                                  p_effective_date         => p_rec.effective_date
                                 );

 -- check from_position_id
 --
     If p_rec.noa_family_code <> 'CONV_APP' and p_rec.noa_family_code <> 'CANCEL'
       and p_rec.noa_family_code <> 'CORRECT' then
        chk_from_position_id(p_pa_request_id          => p_rec.pa_request_id,
                             p_object_version_number  => p_rec.object_version_number,
                             p_employee_assignment_id => p_rec.employee_assignment_id,
                             p_from_position_id       => p_rec.from_position_id,
                             p_effective_date         => p_rec.effective_date
                            );
          End if;

  -- check nature_of_action_id

       chk_nature_of_action_id
      (p_first_nature_of_action_id   => p_rec.first_noa_id
      ,p_pa_request_id               => p_rec.pa_request_id
      ,p_noa_family_code             => p_rec.noa_family_code
      ,p_object_version_number       => p_rec.object_version_number
      ,p_effective_date              => p_rec.effective_date
      );

  -- check second_nature_of_action_id

      chk_second_nature_of_action_id
      (p_first_nature_of_action_id   => p_rec.first_noa_id
      ,p_second_nature_of_action_id  => p_rec.second_noa_id
     , p_first_noa_code              => p_rec.first_noa_code
      ,p_pa_request_id               => p_rec.pa_request_id
      ,p_object_version_number       => p_rec.object_version_number
      ,p_effective_date              => p_rec.effective_date
      );

  -- check first_action_la_code1

     chk_first_action_la_code1
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_first_action_la_code1        => p_rec.first_action_la_code1
    ,p_first_nature_of_action_id    => p_rec.first_noa_id
    ,p_effective_date               => p_rec.effective_date
    );

  -- check first_action_la_code2

     chk_first_action_la_code2
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_first_action_la_code2        => p_rec.first_action_la_code2
    ,p_first_nature_of_action_id    => p_rec.first_noa_id
    ,p_effective_date               => p_rec.effective_date
    );

 -- check second_action_la_code1
    chk_second_action_la_code1
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_second_action_la_code1       => p_rec.second_action_la_code1
    ,p_second_nature_of_action_id   => p_rec.second_noa_id
    ,p_effective_date               => p_rec.effective_date
    );


 -- check second_action_la_code2

     chk_second_action_la_code2
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_second_action_la_code2       => p_rec.second_action_la_code2
    ,p_second_nature_of_action_id   => p_rec.second_noa_id
    ,p_effective_date               => p_rec.effective_date
    );

 --  check duty_station_id
 --
       chk_duty_station_id(p_pa_request_id          => p_rec.pa_request_id,
                           p_object_version_number  => p_rec.object_version_number,
                           p_duty_station_id        => p_rec.duty_station_id,
                           p_effective_date         => p_rec.effective_date
                          );


  -- Call hr_dflex_utility.ins_or_upd_descflex_attribs procedure to validate Descritive Flex Fields

  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'GHR'
      ,p_descflex_name      => 'GHR_PA_REQUESTS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.ATTRIBUTE1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.ATTRIBUTE2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.ATTRIBUTE3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.ATTRIBUTE4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.ATTRIBUTE5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.ATTRIBUTE6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.ATTRIBUTE7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.ATTRIBUTE8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.ATTRIBUTE9
      ,p_attribute10_name    => 'ATTRIBUTE10'
      ,p_attribute10_value   => p_rec.ATTRIBUTE10
      ,p_attribute11_name    => 'ATTRIBUTE11'
      ,p_attribute11_value   => p_rec.ATTRIBUTE11
      ,p_attribute12_name    => 'ATTRIBUTE12'
      ,p_attribute12_value   => p_rec.ATTRIBUTE12
      ,p_attribute13_name    => 'ATTRIBUTE13'
      ,p_attribute13_value   => p_rec.ATTRIBUTE13
      ,p_attribute14_name    => 'ATTRIBUTE14'
      ,p_attribute14_value   => p_rec.ATTRIBUTE14
      ,p_attribute15_name    => 'ATTRIBUTE15'
      ,p_attribute15_value   => p_rec.ATTRIBUTE15
      ,p_attribute16_name    => 'ATTRIBUTE16'
      ,p_attribute16_value   => p_rec.ATTRIBUTE16
      ,p_attribute17_name    => 'ATTRIBUTE17'
      ,p_attribute17_value   => p_rec.ATTRIBUTE17
      ,p_attribute18_name    => 'ATTRIBUTE18'
      ,p_attribute18_value   => p_rec.ATTRIBUTE18
      ,p_attribute19_name    => 'ATTRIBUTE19'
      ,p_attribute19_value   => p_rec.ATTRIBUTE19
      ,p_attribute20_name    => 'ATTRIBUTE20'
      ,p_attribute20_value   => p_rec.ATTRIBUTE20
      );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Check that the Noa_Family Code is not null
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'Noa Family Code',
     p_argument_value => p_rec.noa_family_code);

  -- --  check person_id
  --

        chk_person_id(p_pa_request_id             => p_rec.pa_request_id,
                     p_object_version_number     => p_rec.object_version_number,
                     p_noa_family_code           => p_rec.noa_family_code,
                     p_person_id                 => p_rec.person_id,
                     p_first_noa_cancel_or_correct  => p_rec.first_noa_cancel_or_correct,
                     p_effective_date            => p_rec.effective_date
                                    );


  --  check additional_info_person_id
  --
       chk_additional_info_person_id(p_pa_request_id             => p_rec.pa_request_id,
                                     p_object_version_number     => p_rec.object_version_number,
                                     p_additional_info_person_id => p_rec.additional_info_person_id,
                                     p_effective_date            => p_rec.effective_date
                                    );


  --  check requested_by_person_id
  --
        chk_requested_by_person_id(p_pa_request_id => p_rec.pa_request_id,
                                     p_object_version_number =>p_rec.object_version_number,
                                     p_requested_by_person_id =>p_rec.requested_by_person_id,
                                     p_effective_date            =>p_rec.effective_date
                                   );

  --  check authorized_by_person_id
  --

        chk_authorized_by_person_id(p_pa_request_id => p_rec.pa_request_id,
                                     p_object_version_number =>p_rec.object_version_number,
                                     p_authorized_by_person_id => p_rec.authorized_by_person_id,
                                     p_effective_date            =>p_rec.effective_date
                                    );

 --  check employee_assignment_id
 --
       chk_employee_assignment_id(p_pa_request_id          => p_rec.pa_request_id,
                                  p_object_version_number  => p_rec.object_version_number,
                                  p_employee_assignment_id => p_rec.employee_assignment_id,
                                  p_effective_date         => p_rec.effective_date
                                 );

 -- check from_position_id
 --
      If p_rec.noa_family_code <> 'CONV_APP' and p_rec.noa_family_code <> 'CANCEL'
       and p_rec.noa_family_code <> 'CORRECT' then
        chk_from_position_id(p_pa_request_id          => p_rec.pa_request_id,
                             p_object_version_number  => p_rec.object_version_number,
                             p_employee_assignment_id => p_rec.employee_assignment_id,
                             p_from_position_id       => p_rec.from_position_id,
                             p_effective_date         => p_rec.effective_date
                             );
      End if;

  -- check nature_of_action_id

       chk_nature_of_action_id
      (p_first_nature_of_action_id   => p_rec.first_noa_id
      ,p_pa_request_id               => p_rec.pa_request_id
      ,p_noa_family_code             => p_rec.noa_family_code
      ,p_object_version_number       => p_rec.object_version_number
      ,p_effective_date              => p_rec.effective_date
      );

  -- check second_nature_of_action_id

      chk_second_nature_of_action_id
      (p_first_nature_of_action_id   => p_rec.first_noa_id
      ,p_second_nature_of_action_id  => p_rec.second_noa_id
     , p_first_noa_code              => p_rec.first_noa_code
      ,p_pa_request_id               => p_rec.pa_request_id
      ,p_object_version_number       => p_rec.object_version_number
      ,p_effective_date              => p_rec.effective_date
      );


  -- check first_action_la_code1

     chk_first_action_la_code1
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_first_action_la_code1        => p_rec.first_action_la_code1
    ,p_first_nature_of_action_id    => p_rec.first_noa_id
    ,p_effective_date               => p_rec.effective_date
    );

  -- check first_action_la_code2

     chk_first_action_la_code2
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_first_action_la_code2        => p_rec.first_action_la_code2
    ,p_first_nature_of_action_id    => p_rec.first_noa_id
    ,p_effective_date               => p_rec.effective_date
    );

 -- check second_action_la_code1
    chk_second_action_la_code1
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_second_action_la_code1       => p_rec.second_action_la_code1
    ,p_second_nature_of_action_id   => p_rec.second_noa_id
    ,p_effective_date               => p_rec.effective_date
    );


 -- check second_action_la_code2

     chk_second_action_la_code2
    (p_pa_request_id                => p_rec.pa_request_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_second_action_la_code2       => p_rec.second_action_la_code2
    ,p_second_nature_of_action_id   => p_rec.second_noa_id
    ,p_effective_date               => p_rec.effective_date
    );

 --  check duty_station_id
 --
       chk_duty_station_id(p_pa_request_id          => p_rec.pa_request_id,
                           p_object_version_number  => p_rec.object_version_number,
                           p_duty_station_id        => p_rec.duty_station_id,
                           p_effective_date         => p_rec.effective_date
                          );
  --

  --
  -- Call hr_dflex_utility.ins_or_upd_descflex_attribs procedure to validate Descritive Flex Fields

  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'GHR'
      ,p_descflex_name      => 'GHR_PA_REQUESTS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.ATTRIBUTE1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.ATTRIBUTE2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.ATTRIBUTE3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.ATTRIBUTE4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.ATTRIBUTE5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.ATTRIBUTE6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.ATTRIBUTE7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.ATTRIBUTE8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.ATTRIBUTE9
      ,p_attribute10_name    => 'ATTRIBUTE10'
      ,p_attribute10_value   => p_rec.ATTRIBUTE10
      ,p_attribute11_name    => 'ATTRIBUTE11'
      ,p_attribute11_value   => p_rec.ATTRIBUTE11
      ,p_attribute12_name    => 'ATTRIBUTE12'
      ,p_attribute12_value   => p_rec.ATTRIBUTE12
      ,p_attribute13_name    => 'ATTRIBUTE13'
      ,p_attribute13_value   => p_rec.ATTRIBUTE13
      ,p_attribute14_name    => 'ATTRIBUTE14'
      ,p_attribute14_value   => p_rec.ATTRIBUTE14
      ,p_attribute15_name    => 'ATTRIBUTE15'
      ,p_attribute15_value   => p_rec.ATTRIBUTE15
      ,p_attribute16_name    => 'ATTRIBUTE16'
      ,p_attribute16_value   => p_rec.ATTRIBUTE16
      ,p_attribute17_name    => 'ATTRIBUTE17'
      ,p_attribute17_value   => p_rec.ATTRIBUTE17
      ,p_attribute18_name    => 'ATTRIBUTE18'
      ,p_attribute18_value   => p_rec.ATTRIBUTE18
      ,p_attribute19_name    => 'ATTRIBUTE19'
      ,p_attribute19_value   => p_rec.ATTRIBUTE19
      ,p_attribute20_name    => 'ATTRIBUTE20'
      ,p_attribute20_value   => p_rec.ATTRIBUTE20
      );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_par_shd.g_rec_type) is
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
-- |---------------------------< convert_defaults>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defaults procedure is the same as the private procedure
--   convert_defs. This has been included here to make it publically callable
--   from the ghr_sf52_api business process
--
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defaults(p_rec in out nocopy  ghr_pa_requests%rowtype) is
--
  l_proc  varchar2(72) := g_package||'convert_defaults';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pa_notification_id = hr_api.g_number) then
    p_rec.pa_notification_id :=
    ghr_par_shd.g_old_rec.pa_notification_id;
  End If;
  If (p_rec.noa_family_code = hr_api.g_varchar2) then
    p_rec.noa_family_code :=
    ghr_par_shd.g_old_rec.noa_family_code;
  End If;
  If (p_rec.routing_group_id = hr_api.g_number) then
    p_rec.routing_group_id :=
    ghr_par_shd.g_old_rec.routing_group_id;
  End If;
  If (p_rec.proposed_effective_asap_flag = hr_api.g_varchar2) then
    p_rec.proposed_effective_asap_flag :=
    ghr_par_shd.g_old_rec.proposed_effective_asap_flag;
  End If;
  If (p_rec.academic_discipline = hr_api.g_varchar2) then
    p_rec.academic_discipline :=
    ghr_par_shd.g_old_rec.academic_discipline;
  End If;
  If (p_rec.additional_info_person_id = hr_api.g_number) then
    p_rec.additional_info_person_id :=
    ghr_par_shd.g_old_rec.additional_info_person_id;
  End If;
  If (p_rec.additional_info_tel_number = hr_api.g_varchar2) then
    p_rec.additional_info_tel_number :=
    ghr_par_shd.g_old_rec.additional_info_tel_number;
  End If;
  If (p_rec.agency_code = hr_api.g_varchar2) then
    p_rec.agency_code :=
    ghr_par_shd.g_old_rec.agency_code;
  End If;
  If (p_rec.altered_pa_request_id = hr_api.g_number) then
    p_rec.altered_pa_request_id :=
    ghr_par_shd.g_old_rec.altered_pa_request_id;
  End If;
  If (p_rec.annuitant_indicator = hr_api.g_varchar2) then
    p_rec.annuitant_indicator :=
    ghr_par_shd.g_old_rec.annuitant_indicator;
  End If;
  If (p_rec.annuitant_indicator_desc = hr_api.g_varchar2) then
    p_rec.annuitant_indicator_desc :=
    ghr_par_shd.g_old_rec.annuitant_indicator_desc;
  End If;
  If (p_rec.appropriation_code1 = hr_api.g_varchar2) then
    p_rec.appropriation_code1 :=
    ghr_par_shd.g_old_rec.appropriation_code1;
  End If;
  If (p_rec.appropriation_code2 = hr_api.g_varchar2) then
    p_rec.appropriation_code2 :=
    ghr_par_shd.g_old_rec.appropriation_code2;
  End If;
  If (p_rec.approval_date = hr_api.g_date) then
    p_rec.approval_date :=
    ghr_par_shd.g_old_rec.approval_date;
  End If;
  If (p_rec.approving_official_full_name = hr_api.g_varchar2) then
    p_rec.approving_official_full_name :=
    ghr_par_shd.g_old_rec.approving_official_full_name;
  End If;
  If (p_rec.approving_official_work_title = hr_api.g_varchar2) then
    p_rec.approving_official_work_title :=
    ghr_par_shd.g_old_rec.approving_official_work_title;
  End If;
  If (p_rec.sf50_approval_date = hr_api.g_date) then
    p_rec.sf50_approval_date :=
    ghr_par_shd.g_old_rec.sf50_approval_date;
  End If;
  If (p_rec.sf50_approving_ofcl_full_name = hr_api.g_varchar2) then
    p_rec.sf50_approving_ofcl_full_name :=
    ghr_par_shd.g_old_rec.sf50_approving_ofcl_full_name ;
  End If;
  If (p_rec.sf50_approving_ofcl_work_title  = hr_api.g_varchar2) then
    p_rec.sf50_approving_ofcl_work_title  :=
    ghr_par_shd.g_old_rec.sf50_approving_ofcl_work_title;
  End If;
  If (p_rec.authorized_by_person_id = hr_api.g_number) then
    p_rec.authorized_by_person_id :=
    ghr_par_shd.g_old_rec.authorized_by_person_id;
  End If;
  If (p_rec.authorized_by_title = hr_api.g_varchar2) then
    p_rec.authorized_by_title :=
    ghr_par_shd.g_old_rec.authorized_by_title;
  End If;
  If (p_rec.award_amount = hr_api.g_number) then
    p_rec.award_amount :=
    ghr_par_shd.g_old_rec.award_amount;
  End If;
  If (p_rec.award_uom = hr_api.g_varchar2) then
    p_rec.award_uom :=
    ghr_par_shd.g_old_rec.award_uom;
  End If;
  If (p_rec.bargaining_unit_status = hr_api.g_varchar2) then
    p_rec.bargaining_unit_status :=
    ghr_par_shd.g_old_rec.bargaining_unit_status;
  End If;
  If (p_rec.citizenship = hr_api.g_varchar2) then
    p_rec.citizenship :=
    ghr_par_shd.g_old_rec.citizenship;
  End If;
  If (p_rec.concurrence_date = hr_api.g_date) then
    p_rec.concurrence_date :=
    ghr_par_shd.g_old_rec.concurrence_date;
  End If;
  If (p_rec.custom_pay_calc_flag = hr_api.g_varchar2) then
    p_rec.custom_pay_calc_flag :=
    ghr_par_shd.g_old_rec.custom_pay_calc_flag;
  End If;
  If (p_rec.duty_station_code = hr_api.g_varchar2) then
    p_rec.duty_station_code :=
    ghr_par_shd.g_old_rec.duty_station_code;
  End If;
  If (p_rec.duty_station_desc = hr_api.g_varchar2) then
    p_rec.duty_station_desc :=
    ghr_par_shd.g_old_rec.duty_station_desc;
  End If;
  If (p_rec.duty_station_id = hr_api.g_number) then
    p_rec.duty_station_id :=
    ghr_par_shd.g_old_rec.duty_station_id;
  End If;
  If (p_rec.duty_station_location_id = hr_api.g_number) then
    p_rec.duty_station_location_id :=
    ghr_par_shd.g_old_rec.duty_station_location_id;
  End If;
  If (p_rec.education_level = hr_api.g_varchar2) then
    p_rec.education_level :=
    ghr_par_shd.g_old_rec.education_level;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    ghr_par_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.employee_assignment_id = hr_api.g_number) then
    p_rec.employee_assignment_id :=
    ghr_par_shd.g_old_rec.employee_assignment_id;
  End If;
  If (p_rec.employee_date_of_birth = hr_api.g_date) then
    p_rec.employee_date_of_birth :=
    ghr_par_shd.g_old_rec.employee_date_of_birth;
  End If;
  If (p_rec.employee_dept_or_agency = hr_api.g_varchar2) then
    p_rec.employee_dept_or_agency :=
    ghr_par_shd.g_old_rec.employee_dept_or_agency;
  End If;
  If (p_rec.employee_first_name = hr_api.g_varchar2) then
    p_rec.employee_first_name :=
    ghr_par_shd.g_old_rec.employee_first_name;
  End If;
  If (p_rec.employee_last_name = hr_api.g_varchar2) then
    p_rec.employee_last_name :=
    ghr_par_shd.g_old_rec.employee_last_name;
  End If;
  If (p_rec.employee_middle_names = hr_api.g_varchar2) then
    p_rec.employee_middle_names :=
    ghr_par_shd.g_old_rec.employee_middle_names;
  End If;
  If (p_rec.employee_national_identifier = hr_api.g_varchar2) then
    p_rec.employee_national_identifier :=
    ghr_par_shd.g_old_rec.employee_national_identifier;
  End If;
  If (p_rec.fegli = hr_api.g_varchar2) then
    p_rec.fegli :=
    ghr_par_shd.g_old_rec.fegli;
  End If;
  If (p_rec.fegli_desc = hr_api.g_varchar2) then
    p_rec.fegli_desc :=
    ghr_par_shd.g_old_rec.fegli_desc;
  End If;
  If (p_rec.first_action_la_code1 = hr_api.g_varchar2) then
    p_rec.first_action_la_code1 :=
    ghr_par_shd.g_old_rec.first_action_la_code1;
  End If;
  If (p_rec.first_action_la_code2 = hr_api.g_varchar2) then
    p_rec.first_action_la_code2 :=
    ghr_par_shd.g_old_rec.first_action_la_code2;
  End If;
  If (p_rec.first_action_la_desc1 = hr_api.g_varchar2) then
    p_rec.first_action_la_desc1 :=
    ghr_par_shd.g_old_rec.first_action_la_desc1;
  End If;
  If (p_rec.first_action_la_desc2 = hr_api.g_varchar2) then
    p_rec.first_action_la_desc2 :=
    ghr_par_shd.g_old_rec.first_action_la_desc2;
  End If;
  If (p_rec.first_noa_cancel_or_correct = hr_api.g_varchar2) then
    p_rec.first_noa_cancel_or_correct :=
    ghr_par_shd.g_old_rec.first_noa_cancel_or_correct;
  End If;
  If (p_rec.first_noa_code = hr_api.g_varchar2) then
    p_rec.first_noa_code :=
    ghr_par_shd.g_old_rec.first_noa_code;
  End If;
  If (p_rec.first_noa_desc = hr_api.g_varchar2) then
    p_rec.first_noa_desc :=
    ghr_par_shd.g_old_rec.first_noa_desc;
  End If;
  If (p_rec.first_noa_id = hr_api.g_number) then
    p_rec.first_noa_id :=
    ghr_par_shd.g_old_rec.first_noa_id;
  End If;
  If (p_rec.first_noa_pa_request_id = hr_api.g_number) then
    p_rec.first_noa_pa_request_id :=
    ghr_par_shd.g_old_rec.first_noa_pa_request_id;
  End If;
  If (p_rec.flsa_category = hr_api.g_varchar2) then
    p_rec.flsa_category :=
    ghr_par_shd.g_old_rec.flsa_category;
  End If;
  If (p_rec.forwarding_address_line1 = hr_api.g_varchar2) then
    p_rec.forwarding_address_line1 :=
    ghr_par_shd.g_old_rec.forwarding_address_line1;
  End If;
  If (p_rec.forwarding_address_line2 = hr_api.g_varchar2) then
    p_rec.forwarding_address_line2 :=
    ghr_par_shd.g_old_rec.forwarding_address_line2;
  End If;
  If (p_rec.forwarding_address_line3 = hr_api.g_varchar2) then
    p_rec.forwarding_address_line3 :=
    ghr_par_shd.g_old_rec.forwarding_address_line3;
  End If;
  If (p_rec.forwarding_country_short_name = hr_api.g_varchar2) then
    p_rec.forwarding_country_short_name :=
    ghr_par_shd.g_old_rec.forwarding_country_short_name;
  End If;
  If (p_rec.forwarding_country = hr_api.g_varchar2) then
    p_rec.forwarding_country :=
    ghr_par_shd.g_old_rec.forwarding_country;
  End If;
  If (p_rec.forwarding_postal_code = hr_api.g_varchar2) then
    p_rec.forwarding_postal_code :=
    ghr_par_shd.g_old_rec.forwarding_postal_code;
  End If;
  If (p_rec.forwarding_region_2 = hr_api.g_varchar2) then
    p_rec.forwarding_region_2 :=
    ghr_par_shd.g_old_rec.forwarding_region_2;
  End If;
  If (p_rec.forwarding_town_or_city = hr_api.g_varchar2) then
    p_rec.forwarding_town_or_city :=
    ghr_par_shd.g_old_rec.forwarding_town_or_city;
  End If;
  If (p_rec.from_adj_basic_pay = hr_api.g_number) then
    p_rec.from_adj_basic_pay :=
    ghr_par_shd.g_old_rec.from_adj_basic_pay;
  End If;
  If (p_rec.from_agency_code = hr_api.g_varchar2) then
    p_rec.from_agency_code :=
    ghr_par_shd.g_old_rec.from_agency_code;
  End If;
  If (p_rec.from_agency_desc = hr_api.g_varchar2) then
    p_rec.from_agency_desc :=
    ghr_par_shd.g_old_rec.from_agency_desc;
  End If;
  If (p_rec.from_basic_pay = hr_api.g_number) then
    p_rec.from_basic_pay :=
    ghr_par_shd.g_old_rec.from_basic_pay;
  End If;
  If (p_rec.from_grade_or_level = hr_api.g_varchar2) then
    p_rec.from_grade_or_level :=
    ghr_par_shd.g_old_rec.from_grade_or_level;
  End If;
  If (p_rec.from_locality_adj = hr_api.g_number) then
    p_rec.from_locality_adj :=
    ghr_par_shd.g_old_rec.from_locality_adj;
  End If;
  If (p_rec.from_occ_code = hr_api.g_varchar2) then
    p_rec.from_occ_code :=
    ghr_par_shd.g_old_rec.from_occ_code;
  End If;
  If (p_rec.from_office_symbol = hr_api.g_varchar2) then
    p_rec.from_office_symbol :=
    ghr_par_shd.g_old_rec.from_office_symbol;
  End If;
  If (p_rec.from_other_pay_amount = hr_api.g_number) then
    p_rec.from_other_pay_amount :=
    ghr_par_shd.g_old_rec.from_other_pay_amount;
  End If;
  If (p_rec.from_pay_basis = hr_api.g_varchar2) then
    p_rec.from_pay_basis :=
    ghr_par_shd.g_old_rec.from_pay_basis;
  End If;
  If (p_rec.from_pay_plan = hr_api.g_varchar2) then
    p_rec.from_pay_plan :=
    ghr_par_shd.g_old_rec.from_pay_plan;
  End If;
  -- FWFA Changes Bug#4444609
  If (p_rec.input_pay_rate_determinant = hr_api.g_varchar2) then
    p_rec.input_pay_rate_determinant :=
    ghr_par_shd.g_old_rec.input_pay_rate_determinant;
  End If;
  If (p_rec.from_pay_table_identifier  = hr_api.g_number) then
    p_rec.from_pay_table_identifier :=
    ghr_par_shd.g_old_rec.from_pay_table_identifier;
  End If;
  -- FWFA Changes
  If (p_rec.from_position_org_line1 = hr_api.g_varchar2) then
    p_rec.from_position_org_line1 :=
    ghr_par_shd.g_old_rec.from_position_org_line1;
  End If;
  If (p_rec.from_position_org_line2 = hr_api.g_varchar2) then
    p_rec.from_position_org_line2 :=
    ghr_par_shd.g_old_rec.from_position_org_line2;
  End If;
  If (p_rec.from_position_org_line3 = hr_api.g_varchar2) then
    p_rec.from_position_org_line3 :=
    ghr_par_shd.g_old_rec.from_position_org_line3;
  End If;
  If (p_rec.from_position_org_line4 = hr_api.g_varchar2) then
    p_rec.from_position_org_line4 :=
    ghr_par_shd.g_old_rec.from_position_org_line4;
  End If;
  If (p_rec.from_position_org_line5 = hr_api.g_varchar2) then
    p_rec.from_position_org_line5 :=
    ghr_par_shd.g_old_rec.from_position_org_line5;
  End If;
  If (p_rec.from_position_org_line6 = hr_api.g_varchar2) then
    p_rec.from_position_org_line6 :=
    ghr_par_shd.g_old_rec.from_position_org_line6;
  End If;
  If (p_rec.from_position_id = hr_api.g_number) then
    p_rec.from_position_id :=
    ghr_par_shd.g_old_rec.from_position_id;
  End If;
  If (p_rec.from_position_number = hr_api.g_varchar2) then
    p_rec.from_position_number :=
    ghr_par_shd.g_old_rec.from_position_number;
  End If;
  If (p_rec.from_position_seq_no = hr_api.g_number) then
    p_rec.from_position_seq_no :=
    ghr_par_shd.g_old_rec.from_position_seq_no;
  End If;
  If (p_rec.from_position_title = hr_api.g_varchar2) then
    p_rec.from_position_title :=
    ghr_par_shd.g_old_rec.from_position_title;
  End If;
  If (p_rec.from_step_or_rate = hr_api.g_varchar2) then
    p_rec.from_step_or_rate :=
    ghr_par_shd.g_old_rec.from_step_or_rate;
  End If;
  If (p_rec.from_total_salary = hr_api.g_number) then
    p_rec.from_total_salary :=
    ghr_par_shd.g_old_rec.from_total_salary;
  End If;
  If (p_rec.functional_class = hr_api.g_varchar2) then
    p_rec.functional_class :=
    ghr_par_shd.g_old_rec.functional_class;
  End If;
  If (p_rec.notepad = hr_api.g_varchar2) then
    p_rec.notepad :=
    ghr_par_shd.g_old_rec.notepad;
  End If;
  If (p_rec.part_time_hours = hr_api.g_number) then
    p_rec.part_time_hours :=
    ghr_par_shd.g_old_rec.part_time_hours;
  End If;
  If (p_rec.pay_rate_determinant = hr_api.g_varchar2) then
    p_rec.pay_rate_determinant :=
    ghr_par_shd.g_old_rec.pay_rate_determinant;
  End If;
  If (p_rec.personnel_office_id = hr_api.g_varchar2) then
    p_rec.personnel_office_id :=
    ghr_par_shd.g_old_rec.personnel_office_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ghr_par_shd.g_old_rec.person_id;
  End If;
  If (p_rec.position_occupied = hr_api.g_varchar2) then
    p_rec.position_occupied :=
    ghr_par_shd.g_old_rec.position_occupied;
  End If;
  If (p_rec.proposed_effective_date = hr_api.g_date) then
    p_rec.proposed_effective_date :=
    ghr_par_shd.g_old_rec.proposed_effective_date;
  End If;
  If (p_rec.proposed_effective_asap_flag = hr_api.g_varchar2) then
    p_rec.proposed_effective_asap_flag :=
    ghr_par_shd.g_old_rec.proposed_effective_asap_flag;
  End If;

  If (p_rec.requested_by_person_id = hr_api.g_number) then
    p_rec.requested_by_person_id :=
    ghr_par_shd.g_old_rec.requested_by_person_id;
  End If;
  If (p_rec.requested_by_title = hr_api.g_varchar2) then
    p_rec.requested_by_title :=
    ghr_par_shd.g_old_rec.requested_by_title;
  End If;
  If (p_rec.requested_date = hr_api.g_date) then
    p_rec.requested_date :=
    ghr_par_shd.g_old_rec.requested_date;
  End If;
  If (p_rec.requesting_office_remarks_desc = hr_api.g_varchar2) then
    p_rec.requesting_office_remarks_desc :=
    ghr_par_shd.g_old_rec.requesting_office_remarks_desc;
  End If;
  If (p_rec.requesting_office_remarks_flag = hr_api.g_varchar2) then
    p_rec.requesting_office_remarks_flag :=
    ghr_par_shd.g_old_rec.requesting_office_remarks_flag;
  End If;
  If (p_rec.request_number = hr_api.g_varchar2) then
    p_rec.request_number :=
    ghr_par_shd.g_old_rec.request_number;
  End If;
  If (p_rec.resign_and_retire_reason_desc = hr_api.g_varchar2) then
    p_rec.resign_and_retire_reason_desc :=
    ghr_par_shd.g_old_rec.resign_and_retire_reason_desc;
  End If;
  If (p_rec.retirement_plan = hr_api.g_varchar2) then
    p_rec.retirement_plan :=
    ghr_par_shd.g_old_rec.retirement_plan;
  End If;
  If (p_rec.retirement_plan_desc = hr_api.g_varchar2) then
    p_rec.retirement_plan_desc :=
    ghr_par_shd.g_old_rec.retirement_plan_desc;
  End If;
  If (p_rec.second_action_la_code1 = hr_api.g_varchar2) then
    p_rec.second_action_la_code1 :=
    ghr_par_shd.g_old_rec.second_action_la_code1;
  End If;
  If (p_rec.second_action_la_code2 = hr_api.g_varchar2) then
    p_rec.second_action_la_code2 :=
    ghr_par_shd.g_old_rec.second_action_la_code2;
  End If;
  If (p_rec.second_action_la_desc1 = hr_api.g_varchar2) then
    p_rec.second_action_la_desc1 :=
    ghr_par_shd.g_old_rec.second_action_la_desc1;
  End If;
  If (p_rec.second_action_la_desc2 = hr_api.g_varchar2) then
    p_rec.second_action_la_desc2 :=
    ghr_par_shd.g_old_rec.second_action_la_desc2;
  End If;
  If (p_rec.second_noa_cancel_or_correct = hr_api.g_varchar2) then
    p_rec.second_noa_cancel_or_correct :=
    ghr_par_shd.g_old_rec.second_noa_cancel_or_correct;
  End If;
  If (p_rec.second_noa_code = hr_api.g_varchar2) then
    p_rec.second_noa_code :=
    ghr_par_shd.g_old_rec.second_noa_code;
  End If;
  If (p_rec.second_noa_desc = hr_api.g_varchar2) then
    p_rec.second_noa_desc :=
    ghr_par_shd.g_old_rec.second_noa_desc;
  End If;
  If (p_rec.second_noa_id = hr_api.g_number) then
    p_rec.second_noa_id :=
    ghr_par_shd.g_old_rec.second_noa_id;
  End If;
  If (p_rec.second_noa_pa_request_id = hr_api.g_number) then
    p_rec.second_noa_pa_request_id :=
    ghr_par_shd.g_old_rec.second_noa_pa_request_id;
  End If;
  If (p_rec.service_comp_date = hr_api.g_date) then
    p_rec.service_comp_date :=
    ghr_par_shd.g_old_rec.service_comp_date;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    ghr_par_shd.g_old_rec.status;
  End If;
  If (p_rec.supervisory_status = hr_api.g_varchar2) then
    p_rec.supervisory_status :=
    ghr_par_shd.g_old_rec.supervisory_status;
  End If;
  If (p_rec.tenure = hr_api.g_varchar2) then
    p_rec.tenure :=
    ghr_par_shd.g_old_rec.tenure;
  End If;
  If (p_rec.to_adj_basic_pay = hr_api.g_number) then
    p_rec.to_adj_basic_pay :=
    ghr_par_shd.g_old_rec.to_adj_basic_pay;
  End If;
  If (p_rec.to_basic_pay = hr_api.g_number) then
    p_rec.to_basic_pay :=
    ghr_par_shd.g_old_rec.to_basic_pay;
  End If;
  If (p_rec.to_grade_id = hr_api.g_number) then
    p_rec.to_grade_id :=
    ghr_par_shd.g_old_rec.to_grade_id;
  End If;
  If (p_rec.to_grade_or_level = hr_api.g_varchar2) then
    p_rec.to_grade_or_level :=
    ghr_par_shd.g_old_rec.to_grade_or_level;
  End If;
  If (p_rec.to_job_id = hr_api.g_number) then
    p_rec.to_job_id :=
    ghr_par_shd.g_old_rec.to_job_id;
  End If;
  If (p_rec.to_locality_adj = hr_api.g_number) then
    p_rec.to_locality_adj :=
    ghr_par_shd.g_old_rec.to_locality_adj;
  End If;
  If (p_rec.to_occ_code = hr_api.g_varchar2) then
    p_rec.to_occ_code :=
    ghr_par_shd.g_old_rec.to_occ_code;
  End If;
  If (p_rec.to_office_symbol = hr_api.g_varchar2) then
    p_rec.to_office_symbol :=
    ghr_par_shd.g_old_rec.to_office_symbol;
  End If;
  If (p_rec.to_organization_id = hr_api.g_number) then
    p_rec.to_organization_id :=
    ghr_par_shd.g_old_rec.to_organization_id;
  End If;
  If (p_rec.to_other_pay_amount = hr_api.g_number) then
    p_rec.to_other_pay_amount :=
    ghr_par_shd.g_old_rec.to_other_pay_amount;
  End If;
  If (p_rec.to_pay_basis = hr_api.g_varchar2) then
    p_rec.to_pay_basis :=
    ghr_par_shd.g_old_rec.to_pay_basis;
  End If;
  If (p_rec.to_pay_plan = hr_api.g_varchar2) then
    p_rec.to_pay_plan :=
    ghr_par_shd.g_old_rec.to_pay_plan;
  End If;
  -- FWFA Changes Bug#4444609
  If (p_rec.to_pay_table_identifier  = hr_api.g_number) then
    p_rec.to_pay_table_identifier :=
    ghr_par_shd.g_old_rec.to_pay_table_identifier;
  End If;
  -- FWFA Changes
  If (p_rec.to_position_id = hr_api.g_number) then
    p_rec.to_position_id :=
    ghr_par_shd.g_old_rec.to_position_id;
  End If;
  If (p_rec.to_position_org_line1 = hr_api.g_varchar2) then
    p_rec.to_position_org_line1 :=
    ghr_par_shd.g_old_rec.to_position_org_line1;
  End If;
  If (p_rec.to_position_org_line2 = hr_api.g_varchar2) then
    p_rec.to_position_org_line2 :=
    ghr_par_shd.g_old_rec.to_position_org_line2;
  End If;
  If (p_rec.to_position_org_line3 = hr_api.g_varchar2) then
    p_rec.to_position_org_line3 :=
    ghr_par_shd.g_old_rec.to_position_org_line3;
  End If;
  If (p_rec.to_position_org_line4 = hr_api.g_varchar2) then
    p_rec.to_position_org_line4 :=
    ghr_par_shd.g_old_rec.to_position_org_line4;
  End If;
  If (p_rec.to_position_org_line5 = hr_api.g_varchar2) then
    p_rec.to_position_org_line5 :=
    ghr_par_shd.g_old_rec.to_position_org_line5;
  End If;
  If (p_rec.to_position_org_line6 = hr_api.g_varchar2) then
    p_rec.to_position_org_line6 :=
    ghr_par_shd.g_old_rec.to_position_org_line6;
  End If;

  If (p_rec.to_position_number = hr_api.g_varchar2) then
    p_rec.to_position_number :=
    ghr_par_shd.g_old_rec.to_position_number;
  End If;
  If (p_rec.to_position_seq_no = hr_api.g_number) then
    p_rec.to_position_seq_no :=
    ghr_par_shd.g_old_rec.to_position_seq_no;
  End If;
  If (p_rec.to_position_title = hr_api.g_varchar2) then
    p_rec.to_position_title :=
    ghr_par_shd.g_old_rec.to_position_title;
  End If;
  If (p_rec.to_step_or_rate = hr_api.g_varchar2) then
    p_rec.to_step_or_rate :=
    ghr_par_shd.g_old_rec.to_step_or_rate;
  End If;

  If (p_rec.to_ap_premium_pay_indicator = hr_api.g_varchar2) then
    p_rec.to_ap_premium_pay_indicator :=
    ghr_par_shd.g_old_rec.to_ap_premium_pay_indicator;
  End If;

  If (p_rec.to_auo_premium_pay_indicator = hr_api.g_varchar2) then
    p_rec.to_auo_premium_pay_indicator :=
    ghr_par_shd.g_old_rec.to_auo_premium_pay_indicator;
  End If;

  If (p_rec.to_au_overtime = hr_api.g_number) then
    p_rec.to_au_overtime  :=
    ghr_par_shd.g_old_rec.to_au_overtime  ;
  End If;

  If (p_rec.to_availability_pay = hr_api.g_number) then
    p_rec.to_availability_pay :=
    ghr_par_shd.g_old_rec.to_availability_pay ;
  End If;

  If (p_rec.to_retention_allowance  = hr_api.g_number) then
    p_rec.to_retention_allowance  :=
    ghr_par_shd.g_old_rec.to_retention_allowance;
  End If;

  If (p_rec.to_staffing_differential  = hr_api.g_number) then
    p_rec.to_staffing_differential   :=
    ghr_par_shd.g_old_rec.to_staffing_differential ;
  End If;

   If (p_rec.to_supervisory_differential  = hr_api.g_number) then
    p_rec.to_supervisory_differential   :=
    ghr_par_shd.g_old_rec.to_supervisory_differential ;
  End If;

  If (p_rec.to_total_salary = hr_api.g_number) then
    p_rec.to_total_salary :=
    ghr_par_shd.g_old_rec.to_total_salary;
  End If;
  If (p_rec.veterans_preference = hr_api.g_varchar2) then
    p_rec.veterans_preference :=
    ghr_par_shd.g_old_rec.veterans_preference;
  End If;
  If (p_rec.veterans_pref_for_rif = hr_api.g_varchar2) then
    p_rec.veterans_pref_for_rif :=
    ghr_par_shd.g_old_rec.veterans_pref_for_rif;
  End If;
  If (p_rec.veterans_status = hr_api.g_varchar2) then
    p_rec.veterans_status :=
    ghr_par_shd.g_old_rec.veterans_status;
  End If;
  If (p_rec.work_schedule = hr_api.g_varchar2) then
    p_rec.work_schedule :=
    ghr_par_shd.g_old_rec.work_schedule;
  End If;
  If (p_rec.work_schedule_desc = hr_api.g_varchar2) then
    p_rec.work_schedule_desc :=
    ghr_par_shd.g_old_rec.work_schedule_desc;
  End If;
  If (p_rec.year_degree_attained = hr_api.g_number) then
    p_rec.year_degree_attained :=
    ghr_par_shd.g_old_rec.year_degree_attained;
  End If;
  If (p_rec.first_noa_information1 = hr_api.g_varchar2) then
    p_rec.first_noa_information1 :=
    ghr_par_shd.g_old_rec.first_noa_information1;
  End If;
  If (p_rec.first_noa_information2 = hr_api.g_varchar2) then
    p_rec.first_noa_information2 :=
    ghr_par_shd.g_old_rec.first_noa_information2;
  End If;
  If (p_rec.first_noa_information3 = hr_api.g_varchar2) then
    p_rec.first_noa_information3 :=
    ghr_par_shd.g_old_rec.first_noa_information3;
  End If;
  If (p_rec.first_noa_information4 = hr_api.g_varchar2) then
    p_rec.first_noa_information4 :=
    ghr_par_shd.g_old_rec.first_noa_information4;
  End If;
  If (p_rec.first_noa_information5 = hr_api.g_varchar2) then
    p_rec.first_noa_information5 :=
    ghr_par_shd.g_old_rec.first_noa_information5;
  End If;
  If (p_rec.second_lac1_information1 = hr_api.g_varchar2) then
    p_rec.second_lac1_information1 :=
    ghr_par_shd.g_old_rec.second_lac1_information1;
  End If;
  If (p_rec.second_lac1_information2 = hr_api.g_varchar2) then
    p_rec.second_lac1_information2 :=
    ghr_par_shd.g_old_rec.second_lac1_information2;
  End If;
  If (p_rec.second_lac1_information3 = hr_api.g_varchar2) then
    p_rec.second_lac1_information3 :=
    ghr_par_shd.g_old_rec.second_lac1_information3;
  End If;
  If (p_rec.second_lac1_information4 = hr_api.g_varchar2) then
    p_rec.second_lac1_information4 :=
    ghr_par_shd.g_old_rec.second_lac1_information4;
  End If;
  If (p_rec.second_lac1_information5 = hr_api.g_varchar2) then
    p_rec.second_lac1_information5 :=
    ghr_par_shd.g_old_rec.second_lac1_information5;
  End If;
  If (p_rec.second_lac2_information1 = hr_api.g_varchar2) then
    p_rec.second_lac2_information1 :=
    ghr_par_shd.g_old_rec.second_lac2_information1;
  End If;
  If (p_rec.second_lac2_information2 = hr_api.g_varchar2) then
    p_rec.second_lac2_information2 :=
    ghr_par_shd.g_old_rec.second_lac2_information2;
  End If;
  If (p_rec.second_lac2_information3 = hr_api.g_varchar2) then
    p_rec.second_lac2_information3 :=
    ghr_par_shd.g_old_rec.second_lac2_information3;
  End If;
  If (p_rec.second_lac2_information4 = hr_api.g_varchar2) then
    p_rec.second_lac2_information4 :=
    ghr_par_shd.g_old_rec.second_lac2_information4;
  End If;
  If (p_rec.second_lac2_information5 = hr_api.g_varchar2) then
    p_rec.second_lac2_information5 :=
    ghr_par_shd.g_old_rec.second_lac2_information5;
  End If;
  If (p_rec.second_noa_information1 = hr_api.g_varchar2) then
    p_rec.second_noa_information1 :=
    ghr_par_shd.g_old_rec.second_noa_information1;
  End If;
  If (p_rec.second_noa_information2 = hr_api.g_varchar2) then
    p_rec.second_noa_information2 :=
    ghr_par_shd.g_old_rec.second_noa_information2;
  End If;
  If (p_rec.second_noa_information3 = hr_api.g_varchar2) then
    p_rec.second_noa_information3 :=
    ghr_par_shd.g_old_rec.second_noa_information3;
  End If;
  If (p_rec.second_noa_information4 = hr_api.g_varchar2) then
    p_rec.second_noa_information4 :=
    ghr_par_shd.g_old_rec.second_noa_information4;
  End If;
  If (p_rec.second_noa_information5 = hr_api.g_varchar2) then
    p_rec.second_noa_information5 :=
    ghr_par_shd.g_old_rec.second_noa_information5;
  End If;
  If (p_rec.first_lac1_information1 = hr_api.g_varchar2) then
    p_rec.first_lac1_information1 :=
    ghr_par_shd.g_old_rec.first_lac1_information1;
  End If;
  If (p_rec.first_lac1_information2 = hr_api.g_varchar2) then
    p_rec.first_lac1_information2 :=
    ghr_par_shd.g_old_rec.first_lac1_information2;
  End If;
  If (p_rec.first_lac1_information3 = hr_api.g_varchar2) then
    p_rec.first_lac1_information3 :=
    ghr_par_shd.g_old_rec.first_lac1_information3;
  End If;
  If (p_rec.first_lac1_information4 = hr_api.g_varchar2) then
    p_rec.first_lac1_information4 :=
    ghr_par_shd.g_old_rec.first_lac1_information4;
  End If;
  If (p_rec.first_lac1_information5 = hr_api.g_varchar2) then
    p_rec.first_lac1_information5 :=
    ghr_par_shd.g_old_rec.first_lac1_information5;
  End If;
  If (p_rec.first_lac2_information1 = hr_api.g_varchar2) then
    p_rec.first_lac2_information1 :=
    ghr_par_shd.g_old_rec.first_lac2_information1;
  End If;
  If (p_rec.first_lac2_information2 = hr_api.g_varchar2) then
    p_rec.first_lac2_information2 :=
    ghr_par_shd.g_old_rec.first_lac2_information2;
  End If;
  If (p_rec.first_lac2_information3 = hr_api.g_varchar2) then
    p_rec.first_lac2_information3 :=
    ghr_par_shd.g_old_rec.first_lac2_information3;
  End If;
  If (p_rec.first_lac2_information4 = hr_api.g_varchar2) then
    p_rec.first_lac2_information4 :=
    ghr_par_shd.g_old_rec.first_lac2_information4;
  End If;
  If (p_rec.first_lac2_information5 = hr_api.g_varchar2) then
    p_rec.first_lac2_information5 :=
    ghr_par_shd.g_old_rec.first_lac2_information5;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    ghr_par_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    ghr_par_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    ghr_par_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    ghr_par_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    ghr_par_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    ghr_par_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    ghr_par_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    ghr_par_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    ghr_par_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    ghr_par_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    ghr_par_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    ghr_par_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    ghr_par_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    ghr_par_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    ghr_par_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    ghr_par_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    ghr_par_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    ghr_par_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    ghr_par_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    ghr_par_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    ghr_par_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.first_noa_canc_pa_request_id = hr_api.g_number) then
    p_rec.first_noa_canc_pa_request_id :=
          ghr_par_shd.g_old_rec.first_noa_canc_pa_request_id;
  End If;
  If (p_rec.second_noa_canc_pa_request_id = hr_api.g_number) then
    p_rec.second_noa_canc_pa_request_id :=
          ghr_par_shd.g_old_rec.second_noa_canc_pa_request_id;
  End If;
  If (p_rec.to_retention_allow_percentage = hr_api.g_number) then
      p_rec.to_retention_allow_percentage :=
          ghr_par_shd.g_old_rec.to_retention_allow_percentage;
  End If;
  If (p_rec.to_supervisory_diff_percentage = hr_api.g_number) then
      p_rec.to_supervisory_diff_percentage :=
          ghr_par_shd.g_old_rec.to_supervisory_diff_percentage;
  End If;
  If (p_rec.to_staffing_diff_percentage = hr_api.g_number) then
      p_rec.to_staffing_diff_percentage :=
          ghr_par_shd.g_old_rec.to_staffing_diff_percentage;
  End If;
  If (p_rec.award_percentage = hr_api.g_number) then
      p_rec.award_percentage :=
          ghr_par_shd.g_old_rec.award_percentage;
  End If;
  If (p_rec.rpa_type    = hr_api.g_varchar2) then
    p_rec.rpa_type :=
    ghr_par_shd.g_old_rec.rpa_type;
  End If;
  If (p_rec.mass_action_id   = hr_api.g_number) then
      p_rec.mass_action_id   :=
          ghr_par_shd.g_old_rec.mass_action_id;
  End If;
  If (p_rec.mass_action_eligible_flag = hr_api.g_varchar2) then
    p_rec.mass_action_eligible_flag  :=
    ghr_par_shd.g_old_rec.mass_action_eligible_flag;
  End If;
  If (p_rec.mass_action_select_flag = hr_api.g_varchar2) then
    p_rec.mass_action_select_flag  :=
    ghr_par_shd.g_old_rec.mass_action_select_flag;
  End If;
  If (p_rec.mass_action_comments = hr_api.g_varchar2) then
    p_rec.mass_action_comments  :=
    ghr_par_shd.g_old_rec.mass_action_comments;
  End If;

  -- Bug#4486823 RRR Changes
  If (p_rec.pa_incentive_payment_option = hr_api.g_varchar2) then
    p_rec.pa_incentive_payment_option  :=
    ghr_par_shd.g_old_rec.payment_option;
  End If;
  If (p_rec.award_salary = hr_api.g_number) then
    p_rec.award_salary  :=
    ghr_par_shd.g_old_rec.award_salary;
  End If;
  -- Bug#    RRR Changes
 end convert_defaults;

end ghr_par_bus;

/
