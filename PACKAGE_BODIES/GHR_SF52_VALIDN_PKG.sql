--------------------------------------------------------
--  DDL for Package Body GHR_SF52_VALIDN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF52_VALIDN_PKG" AS
 /* $Header: ghvalidn.pkb 120.0 2005/05/29 03:40:47 appldev noship $ */

g_package varchar2(33) := 'ghr_sf52_validn_pkg. ';
--

/*===========================================================================*
 |               Copyright (c) 1997 Oracle Corporation                       |
 |                       All rights reserved.                                |
*============================================================================*/

--
/*
--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_requested_by_title>---------------------------|
--  ---------------------------------------------------------------------------
--

   procedure chk_requested_by_title
   (p_requested_by_person_id             in   ghr_pa_requests.requested_by_person_id%type
   ,p_requested_by_title                 in   ghr_pa_requests.requested_by_title%type
   ,p_effective_date                     in   date
   )
   is

    l_title          ghr_pa_requests.requested_by_title%type;
    l_proc           varchar2(72)  := g_package ||'chk_requested_by_title' ;

    begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      if p_requested_by_title is not null then
        l_title   :=  ghr_api.get_position_title
                      (p_person_id                  => p_requested_by_person_id
                      ,p_effective_date             => trunc(nvl(p_effective_date,sysdate))
                      );
        hr_utility.set_location(l_proc, 20);
        if nvl(l_title,hr_api.g_varchar2) <> p_requested_by_title  then
            hr_utility.set_message(8301,'GHR_38094_INV_REQ_TITLE');
            hr_utility.raise_error;
        end if;
        hr_utility.set_location(l_proc, 30);
      end if;
      hr_utility.set_location('leaving :' ||l_proc, 40);
    end chk_requested_by_title;
--

--
--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_authorized_by_title>---------------------------|
--  ---------------------------------------------------------------------------
--

   procedure chk_authorized_by_title
   (p_authorized_by_person_id             in   ghr_pa_requests.authorized_by_person_id%type
   ,p_authorized_by_title                 in   ghr_pa_requests.authorized_by_title%type
   ,p_effective_date                      in   date
   )
   is

    l_title          ghr_pa_requests.authorized_by_title%type;
    l_proc           varchar2(72)  := g_package ||'chk_authorized_by_title' ;

    begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      if p_authorized_by_title is not null then
        l_title   :=  ghr_api.get_position_title
                      (p_person_id                  => p_authorized_by_person_id
                      ,p_effective_date             => trunc(nvl(p_effective_date,sysdate))
                      );
        hr_utility.set_location(l_proc, 20);
        if nvl(l_title,hr_api.g_varchar2) <> p_authorized_by_title  then
            hr_utility.set_message(8301,'GHR_38095_INV_AUTH_TITLE');
            hr_utility.raise_error;
        end if;
        hr_utility.set_location(l_proc, 30);
      end if;
      hr_utility.set_location('leaving :' ||l_proc, 40);
    end chk_authorized_by_title;
--
*/


--  ---------------------------------------------------------------------------
-- |-----------------------------< prelim_req_chk_for_update_hr >---------------------------|
--  ---------------------------------------------------------------------------
--

 Procedure prelim_req_chk_for_update_hr
 (p_pa_request_rec             in      ghr_pa_requests%rowtype
 ) is

  l_proc              varchar2(72)    :=  g_package || 'primary_reqd_chk_for_update_hr';
  l_notification_id  ghr_pa_requests.pa_notification_id%type;
  l_person_type       per_person_types.system_person_type%type;
  l_session           ghr_history_api.g_session_var_type;

  l_new_line  VARCHAR2(1) := substr('
  ',1,1);                                -- Bug 1844515 Anil
  l_null_list  VARCHAR2(120) ;            -- Bug 1844515 Anil

  Cursor c_sf50 is
    select pa_notification_id
    from   ghr_pa_requests par
    where  par.pa_request_id =  p_pa_request_rec.pa_request_id;

 Cursor c_per_type is
   Select ppt.system_person_type
   from   per_people_f per,
          per_person_types ppt
   where  per.person_id = p_pa_request_rec.person_id
   and    p_pa_request_rec.effective_date
   between per.effective_start_date and per.effective_end_date
   and    ppt.person_type_id = per.person_type_id;


begin

 hr_utility.set_location('Entering ' || l_proc,10);
 ghr_history_api.get_g_session_var(l_session);

-- Check to see if the SF52 is not already processe

  for sf50 in c_sf50 loop
    hr_utility.set_location(l_proc,15);
    l_notification_id :=  sf50.pa_notification_id;
  end loop;
  if l_notification_id is not null then
    hr_utility.set_message(8301,'GHR_38389_ALREADY_PROCESSED');
    hr_utility.raise_error;
  end if;

-- check to see if the approval_date is not null
-- commented for the time being until the codes are fixed to handle elec. auth.

   If p_pa_request_rec.approval_date is null then
     hr_utility.set_message(8301,'GHR_38522_APPROVAL_REQUIRED');
     hr_utility.raise_error;
   End if;


-- Check that an effective_date is entered
  If p_pa_request_rec.effective_date is null then
    hr_utility.set_message(8301,'GHR_38185_EFF_DATE_REQUIRED');
    ghr_upd_hr_validation.form_item_name := 'PAR.EFFECTIVE_DATE';
    hr_utility.raise_error;
  End if;


-- Note : What is the case of Position based Actions ??
-- Assuming that the following are the Position based families that will not require an assignmentid

  If p_pa_request_rec.noa_family_code not in ('POS_ABOLISH','POSN_CHG','POS_CHG','POS_ESTABLISH','POS_REVIEW') then
     If p_pa_request_rec.employee_assignment_id is null then
         If p_pa_request_rec.noa_family_code = 'APP' then
           for per_type in c_per_type loop
             l_person_type := per_type.system_person_type;
           end loop;
         End if;
         If p_pa_request_rec.noa_family_code = 'APP' and l_person_type = 'EX_EMP' then
           Null;
         Else
           hr_utility.set_message(8301,'GHR_38146_ASSIGNMENT_ID_NULL');
           ghr_upd_hr_validation.form_item_name :=  'PAR.EMPLOYEE_LAST_NAME';
           hr_utility.raise_error;
         End if;
     End if;
  End if;

-- Check to see if atleast one position is entered

  If p_pa_request_rec.from_position_id is null and
    p_pa_request_rec.to_position_id is null then
    hr_utility.set_message(8301,'GHR_38191_ATLEAST_ONE_POSITION');
    hr_utility.raise_error;
  End if;


-- Check to see if the To_position_id is entered , when the family being processed is APP
  If p_pa_request_rec.to_position_id is null then
    If p_pa_request_rec.noa_family_code = 'APP' then
      hr_utility.set_message(8301,'GHR_38182_POSN_NOT_BE_NULL');
      hr_utility.raise_error;
    End if;
  End if;

--Bug 1844515 Anil
--To check if second legal authority code is entered for a dual action request
  IF p_pa_request_rec.first_noa_code  NOT IN ( '001', '002') AND
     p_pa_request_rec.second_noa_code IS NOT NULL            THEN

-- Determines that the request is dual action.
        IF p_pa_request_rec.first_action_la_code1 IS NULL          AND
           p_pa_request_rec.second_action_la_code1 IS NULL         THEN

	       l_null_list := '5-C. Code ,' || l_new_line || '5-D. Legal Authority ,'
	                      || l_new_line ||
	                      '6-C. Code ,' || l_new_line || '6-D. Legal Authority.'   ;
               hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
               fnd_message.set_token('REQUIRED_LIST',l_null_list);
               hr_utility.raise_error;

	elsif  p_pa_request_rec.second_action_la_code1 IS NULL     THEN

	       l_null_list := '6-C. Code ,' || l_new_line || '6-D. Legal Authority.'   ;
               hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
               fnd_message.set_token('REQUIRED_LIST',l_null_list);
               hr_utility.raise_error;

         END IF;

  END IF;

--End Bug 1844515

End prelim_req_chk_for_update_hr;

------------------------------------------------------------------------------------------------------

--
--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_position_title_seq_desc>---------------------------|
--  ---------------------------------------------------------------------------
--

   procedure chk_position_title_seq_desc
    (p_to_position_id          in  per_positions.position_id%type
    ,p_to_position_title       in  ghr_pa_requests.to_position_title%type
    ,p_to_position_number      in  ghr_pa_requests.to_position_number%type
    ,p_to_position_seq_no      in  ghr_pa_requests.to_position_seq_no%type
    ,p_effective_date          in  date default sysdate
    )
   is
    l_bgp_id                  per_positions.business_group_id%type;
    l_title                   ghr_pa_requests.to_position_title%type;
    l_desc_no                 varchar2(150);
    l_seq_no                  number;
    l_proc           varchar2(72)  := g_package ||'chk_position_title_seq_desc' ;

    cursor c_bgp_id is
      select  pos.business_group_id
      from    hr_all_positions_f pos
      where   pos.position_id = p_to_position_id
      and     p_effective_date between pos.effective_start_date and pos.effective_end_date;


    begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      if p_to_position_id is not null then
        for bgp_id in c_bgp_id loop
          l_bgp_id   :=  bgp_id.business_group_id;
        end loop;
        l_title   :=  ghr_api.get_position_title_pos
                      (p_position_id                => p_to_position_id
                      ,p_business_group_id          => l_bgp_id
                      ,p_effective_date             => p_effective_date
                      );

        if p_to_position_title is not null then
          if nvl(l_title,hr_api.g_varchar2) <> p_to_position_title  then
            hr_utility.set_message(8301,'GHR_38072_INV_TO_POS_TITLE');
            hr_utility.raise_error;
          end if;
        end if;

        l_desc_no := ghr_api.get_position_desc_no_pos
                     (p_position_id                => p_to_position_id
                     ,p_business_group_id          => l_bgp_id
                     ,p_effective_date             => p_effective_date
                     );
        if p_to_position_number is not null then
          if nvl(l_desc_no ,hr_api.g_varchar2) <> p_to_position_number then
            hr_utility.set_message(8301,'GHR_38073_INV_TO_POS_NUMBER');
            hr_utility.raise_error;
          end if;
        end if;

        l_seq_no  := ghr_api.get_position_sequence_no_pos
                     (p_position_id                => p_to_position_id
                     ,p_business_group_id          => l_bgp_id
                     ,p_effective_date             => p_effective_date
                     );

        if p_to_position_seq_no is not null then
          if nvl(l_seq_no ,hr_api.g_number) <> p_to_position_seq_no then
            hr_utility.set_message(8301,'GHR_38267_INV_TO_POS_SEQ_NUMB');
            hr_utility.raise_error;
          end if;
        end if;

      end if;
  end chk_position_title_seq_desc;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_award_uom>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_award_uom
  (p_award_uom                      in ghr_pa_requests.award_uom%TYPE
  ,p_effective_date                 in date) is

  l_not_exists     boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_award_uom';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   -- Check if award_uom is valid
    --
    If p_award_uom is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_award_uom
       ,p_lookup_type          =>  'GHR_US_AWARD_UOM'
       );
       if l_not_exists then
         hr_utility.set_message(8301,'GHR_38170_INV_AWARD_UOM');
         hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   --
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_award_uom;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_appropriation_code1>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_appropriation_code1
  (p_appropriation_code1            in ghr_pa_requests.appropriation_code1%TYPE
  ,p_effective_date                 in date) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_appropriation_code1';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   -- Check if appropriation_code1 is valid
    --
    If p_appropriation_code1 is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_appropriation_code1
       ,p_lookup_type          =>  'GHR_US_APPROPRIATION_CODE1'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38074_INV_APP_CODE1');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_appropriation_code1;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_appropriation_code2>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_appropriation_code2
  (p_appropriation_code2            in ghr_pa_requests.appropriation_code2%TYPE
  ,p_effective_date                 in date) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_appropriation_code2';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   -- Check if appropriation_code2 is valid
    --
    If p_appropriation_code2 is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_appropriation_code2
       ,p_lookup_type          =>  'GHR_US_APPROPRIATION_CODE2'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38075_INV_APP_CODE2');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_appropriation_code2;


--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_annuitant_indicator>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_annuitant_indicator
  (p_annuitant_indicator            in ghr_pa_requests.annuitant_indicator%TYPE
  ,p_effective_date                 in date) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_annuitant_indicator';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   -- Check if annuitant_indicator is valid
    --
    If p_annuitant_indicator is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_annuitant_indicator
       ,p_lookup_type          =>  'GHR_US_ANNUITANT_INDICATOR'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38069_INV_ANN_INDICATOR');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_annuitant_indicator;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_bargaining_unit_status>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_bargaining_unit_status
  (p_bargaining_unit_status         in ghr_pa_requests.bargaining_unit_status%TYPE
  ,p_effective_date                 in date) is

  l_not_exists         boolean;
  l_proc           varchar2(72)  := g_package ||'chk_bargaining_unit_status';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   -- Check if bargaining_unit_status is valid
    --
    If p_bargaining_unit_status is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_bargaining_unit_status
       ,p_lookup_type          =>  'GHR_US_BARG_UNIT_STATUS'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38076_INV_BARG_UNIT_STATUS');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_bargaining_unit_status;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_supervisory_status>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_supervisory_status
  (p_supervisory_status             in ghr_pa_requests.supervisory_status%TYPE
  ,p_effective_date                 in date) is

  l_not_exists         boolean;
  l_proc           varchar2(72)  := g_package ||'chk_supervisory_status';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   If p_supervisory_status is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_supervisory_status
       ,p_lookup_type          =>  'GHR_US_SUPERVISORY_STATUS'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38077_INV_SUPERV_STATUS');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_supervisory_status;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_functional_class>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_functional_class
  (p_functional_class               in ghr_pa_requests.functional_class%TYPE
  ,p_effective_date                 in date) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_functional_class';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   If p_functional_class  is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_functional_class
       ,p_lookup_type          =>  'GHR_US_FUNCTIONAL_CLASS'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38078_INV_FUNC_CLASS');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_functional_class;


--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_position_occupied>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_position_occupied
  (p_position_occupied              in ghr_pa_requests.position_occupied%TYPE
  ,p_effective_date                 in date) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_position_occupied';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
    If p_position_occupied is not null then
    --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_position_occupied
       ,p_lookup_type          =>  'GHR_US_POSITION_OCCUPIED'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38079_INV_POS_OCCUPIED');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_position_occupied;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_fegli>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_fegli
  (p_fegli                       in ghr_pa_requests.fegli%TYPE
  ,p_effective_date              in date) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_fegli';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if fegli is valid
    --
    If p_fegli is not null then
  --
     l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_fegli
       ,p_lookup_type          =>  'GHR_US_FEGLI'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38070_INV_FEGLI');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_fegli;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_retirement_plan>---------------------------|
--  ---------------------------------------------------------------------------



procedure chk_retirement_plan
  (p_retirement_plan             in ghr_pa_requests.retirement_plan%TYPE
  ,p_effective_date              in date
 ) is

  l_not_exists         boolean;
  l_proc           varchar2(72)  := g_package ||'chk_retirement_plan';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if retirement_plan is valid
  --
  If p_retirement_plan is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_retirement_plan
       ,p_lookup_type          =>  'GHR_US_RETIREMENT_PLAN'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38071_INV_RET_PLAN');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_retirement_plan;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_tenure>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_tenure
(p_tenure                      in ghr_pa_requests.tenure%TYPE
,p_effective_date              in date) is

  l_not_exists         boolean;
  l_proc           varchar2(72)  := g_package ||'chk_tenure';
  l_api_updating   boolean;
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if tenure is valid
  --
  If p_tenure is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_tenure
       ,p_lookup_type          =>  'GHR_US_TENURE'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38080_INV_TENURE');
          hr_utility.raise_error;
       end if;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
   hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_tenure;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_pay_rate_determinant>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_pay_rate_determinant
  (p_pay_rate_determinant        in ghr_pa_requests.pay_rate_determinant%TYPE
  ,p_effective_date              in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_pay_rate_determinant';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if pay_rate_determinant is valid
  --
  If p_pay_rate_determinant is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_pay_rate_determinant
       ,p_lookup_type          =>  'GHR_US_PAY_RATE_DETERMINANT'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38081_INV_PAY_RATE_DET');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_pay_rate_determinant;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_pay_basis>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_pay_basis
  (p_pay_basis        in ghr_pa_requests.to_pay_basis%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_pay_basis';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if pay_basis is valid
  --
  If p_pay_basis is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_pay_basis
       ,p_lookup_type          =>  'GHR_US_PAY_BASIS'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38082_INV_TO_PAY_BASIS');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_pay_basis;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_pay_plan>---------------------------|
--  ---------------------------------------------------------------------------
-- Note  : This procedure is no longer reqd. as the col. from and to pay_plans
-- are foreign keys to the ghr_pay_plan table

procedure chk_pay_plan
  (p_pay_plan        in ghr_pa_requests.to_pay_plan%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_pay_plan';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if pay_plan is valid
  --
  If p_pay_plan is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_pay_plan
       ,p_lookup_type          =>  'GHR_US_PAY_PLAN'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38083_INV_TO_PAY_PLAN');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_pay_plan;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_grade_or_level>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_grade_or_level
  (p_grade_or_level        in ghr_pa_requests.to_grade_or_level%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_grade_or_level';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if grade_or_level is valid
  --
  If p_grade_or_level is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_grade_or_level
       ,p_lookup_type          =>  'GHR_US_GRADE_OR_LEVEL' -- check this
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38084_INV_TO_GRADE_OR_LEV');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_grade_or_level;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_to_occ_code>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_to_occ_code
  (p_to_occ_code        in ghr_pa_requests.to_occ_code%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_to_occ_code';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if to_occ_code is valid
  --
  If p_to_occ_code is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_to_occ_code
       ,p_lookup_type          =>  'GHR_US_OCC_SERIES'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38085_INV_TO_OCC_CODE');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_to_occ_code;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_step_or_rate>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_step_or_rate
  (p_step_or_rate        in ghr_pa_requests.to_step_or_rate%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_step_or_rate';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if step_or_rate is valid
  --
  If p_step_or_rate is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_step_or_rate
       ,p_lookup_type          =>  'GHR_US_STEP'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38086_INV_TO_STEP_OR_RATE');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_step_or_rate;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_citizenship>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_citizenship
  (p_citizenship        in ghr_pa_requests.citizenship%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_citizenship';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if citizenship is valid
  --
  If p_citizenship is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_citizenship
       ,p_lookup_type          =>  'GHR_US_CITIZENSHIP'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38384_INV_CITIZENSHIP');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_citizenship;


--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_vet_status>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_vet_status
  (p_veterans_status        in ghr_pa_requests.veterans_status%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_vet_status';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if vet_status is valid
  --
  If p_veterans_status is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_veterans_status
       ,p_lookup_type          =>  'GHR_US_VET_STATUS' -- check this
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38088_INV_VET_STATUS');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_vet_status;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_vet_pref>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_vet_pref
  (p_veterans_preference        in ghr_pa_requests.veterans_preference%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_vet_pref';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if vet_pref is valid
  --
  If p_veterans_preference is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_veterans_preference
       ,p_lookup_type          =>  'GHR_US_VETERANS_PREF' -- check this
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38089_INV_VET_PREF');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_vet_pref;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_work_schedule>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_work_schedule
  (p_work_schedule        in ghr_pa_requests.work_schedule%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_work_schedule';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if work_schedule is valid
  --
  If p_work_schedule is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_work_schedule
       ,p_lookup_type          =>  'GHR_US_WORK_SCHEDULE' -- check this
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38090_INV_WORK_SCHED');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_work_schedule;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_academic_discipline>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_academic_discipline
  (p_academic_discipline        in ghr_pa_requests.academic_discipline%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_academic_discipline';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if academic_discipline is valid
  --
  If p_academic_discipline is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_academic_discipline
       ,p_lookup_type          =>  'GHR_US_ACADEMIC_DISCIPLINE'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38091_INV_ACAD_DISC');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_academic_discipline;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_education_level>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_education_level
  (p_education_level        in ghr_pa_requests.education_level%TYPE
  ,p_effective_date   in date
 ) is

  l_not_exists         boolean ;
  l_proc           varchar2(72)  := g_package ||'chk_education_level';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if education_level is valid
  --
  If p_education_level is not null then
  --
    l_not_exists :=
       hr_api.not_exists_in_hr_lookups
       (p_effective_date       =>  trunc(nvl(p_effective_date,sysdate))
       ,p_lookup_code          =>  p_education_level
       ,p_lookup_type          =>  'GHR_US_EDUCATIONAL_LEVEL'
       );
       if l_not_exists then
          hr_utility.set_message(8301,'GHR_38092_INV_EDUC_LEVEL');
          hr_utility.raise_error;
       end if;
  end if;
    hr_utility.set_location(l_proc, 50);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_education_level;

--  ---------------------------------------------------------------------------
-- |-----------------------------< chk_year_degree_attained>---------------------------|
--  ---------------------------------------------------------------------------

procedure chk_year_degree_attained
  (p_year_degree_attained        in ghr_pa_requests.year_degree_attained%TYPE
 ) is

begin
  If p_year_degree_attained > to_number(to_char(sysdate,'yyyy')) then
     hr_utility.set_message(8301,'GHR_38093_INV_DEGR_ATT_YEAR');
     hr_utility.raise_error;
  end if;
end chk_year_degree_attained;


--  ---------------------------------------------------------------------------
-- |-----------------------------< perform_validation>---------------------------|
--  ---------------------------------------------------------------------------
procedure perform_validn
(p_rec               in        ghr_pa_requests%ROWTYPE
) is

begin

-- The following 2 procedures have been commented out as a fix for bug #555121
-- as per Jon's suggestion of removing the validation
  --
  -- Set up the CLIENT_INFO
  --
  ghr_utility.set_client_info;

/* chk_requested_by_title
   (p_requested_by_person_id    => p_rec.requested_by_person_id
   ,p_requested_by_title        => p_rec.requested_by_title
   ,p_effective_date            => p_rec.effective_date
   );

  chk_authorized_by_title
   (p_authorized_by_person_id    => p_rec.authorized_by_person_id
   ,p_authorized_by_title        => p_rec.authorized_by_title
   ,p_effective_date             => p_rec.effective_date
   );
*/

  chk_position_title_seq_desc
    (p_to_position_id        => p_rec.to_position_id
    ,p_to_position_title     => p_rec.to_position_title
    ,p_to_position_number    => p_rec.to_position_number
    ,p_to_position_seq_no    => p_rec.to_position_seq_no
    ,p_effective_date        => p_rec.effective_date
    );

  chk_to_occ_code
  (p_to_occ_code     => p_rec.to_occ_code
  ,p_effective_date     => p_rec.effective_date
  );

  chk_grade_or_level
  (p_grade_or_level     => p_rec.to_grade_or_level
  ,p_effective_date     => p_rec.effective_date
  );

  chk_step_or_rate
  (p_step_or_rate       => p_rec.to_step_or_rate
  ,p_effective_date     => p_rec.effective_date
  );

  chk_award_uom
  (p_award_uom               => p_rec.award_uom
  ,p_effective_date          => p_rec.effective_date
  );

  chk_pay_basis
  (p_pay_basis    		     => p_rec.to_pay_basis
  ,p_effective_date           => p_rec.effective_date
  );

  chk_vet_pref
  (p_veterans_preference => p_rec.veterans_preference
  ,p_effective_date      => p_rec.effective_date
  );

  chk_tenure
  (p_tenure                   => p_rec.tenure
  ,p_effective_date           => p_rec.effective_date
  );

  chk_fegli
  (p_fegli                    => p_rec.fegli
  ,p_effective_date           => p_rec.effective_date
  );

  chk_annuitant_indicator
  (p_annuitant_indicator      => p_rec.annuitant_indicator
  ,p_effective_date           => p_rec.effective_date
  );

  chk_pay_rate_determinant
  (p_pay_rate_determinant     => p_rec.pay_rate_determinant
  ,p_effective_date           => p_rec.effective_date
  );

  chk_retirement_plan
  (p_retirement_plan           => p_rec.retirement_plan
  ,p_effective_date           => p_rec.effective_date
  );

  chk_work_schedule
  (p_work_schedule       => p_rec.work_schedule
  ,p_effective_date      => p_rec.effective_date
  );

  chk_position_occupied
  (p_position_occupied        => p_rec.position_occupied
  ,p_effective_date           => p_rec.effective_date
  );


  chk_appropriation_code1
  (p_appropriation_code1      => p_rec.appropriation_code1
  ,p_effective_date           => p_rec.effective_date
  );

  chk_appropriation_code2
  (p_appropriation_code2      => p_rec.appropriation_code2
  ,p_effective_date           => p_rec.effective_date
  );


  chk_bargaining_unit_status
  (p_bargaining_unit_status   => p_rec.bargaining_unit_status
  ,p_effective_date           => p_rec.effective_date
  );

  chk_education_level
  (p_education_level     => p_rec.education_level
  ,p_effective_date      => p_rec.effective_date
  );

  chk_year_degree_attained
  (p_year_degree_attained  => p_rec.year_degree_attained);

  chk_academic_discipline
  (p_academic_discipline => p_rec.academic_discipline
  ,p_effective_date      => p_rec.effective_date
  );

  chk_functional_class
  (p_functional_class         => p_rec.functional_class
  ,p_effective_date           => p_rec.effective_date
  );

  chk_citizenship
  (p_citizenship        => p_rec.citizenship
  ,p_effective_date     => p_rec.effective_date
  );

  chk_vet_status
  (p_veterans_status    => p_rec.veterans_status
  ,p_effective_date     => p_rec.effective_date
  );

  chk_supervisory_status
  (p_supervisory_status       => p_rec.supervisory_status
  ,p_effective_date           => p_rec.effective_date
  );

end perform_validn;

end ghr_sf52_validn_pkg;

/
