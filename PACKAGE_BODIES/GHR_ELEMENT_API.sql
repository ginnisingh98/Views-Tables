--------------------------------------------------------
--  DDL for Package Body GHR_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_ELEMENT_API" AS
/* $Header: ghelepkg.pkb 120.10 2007/08/08 11:47:12 managarw ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< retrieve_element_info >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve element info
--
-- Prerequisites:
--
-- In Parameters:
--   p_element_name
--   p_input_value_name
--   p_assignment_id
--   p_effective_date
--   p_processing_type
--
-- Out Parameters:
--   p_element_link_id
--   p_input_value_id
--   p_element_entry_id
--   p_value
--   p_object_version_number
--   p_multiple_error_flag
--
-- Post Success:
--   Processing nulls.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--
-- Procedure modified for Payroll Integration
--
--   PROCESS_SF52_ELEMENT passes old element name to this proc and this uses
--   return_new_element_name to pick new element.
--   The FETCH_ELEMENT_INFO_COR (history package) is being sent p_element_name
--   (old_element_name) as it has calls to return_new_element_name already.
--
procedure retrieve_element_info
	(p_element_name      in     pay_element_types_f.element_name%type
	,p_input_value_name  in     pay_input_values_f.name%type
	,p_assignment_id     in     pay_element_entries_f.assignment_id%type
	,p_effective_date    in     date
	,p_processing_type   in     pay_element_types_f.processing_type%type
	,p_element_link_id      out nocopy pay_element_links_f.element_link_id%type
	,p_input_value_id       out nocopy pay_input_values_f.input_value_id%type
	,p_element_entry_id     out nocopy pay_element_entries_f.element_entry_id%type
	,p_value                out nocopy pay_element_entry_values_f.screen_entry_value%type
	,p_object_version_number
			 out nocopy pay_element_entries_f.object_version_number%type
	,p_multiple_error_flag  out nocopy varchar2
	) is
  --
  l_proc                  varchar2(72) := g_package||'retrieve_element_info';
  l_session               ghr_history_api.g_session_var_type;
  l_element_entry_id      pay_element_entries_f.element_entry_id%type;

  --


  cursor c_rec_ele_info (ele_name       in varchar2
			,input_name     in varchar2
			,asg_id         in number
			,eff_date       in date
			,bg_id          in number) is
	select elt.multiple_entries_allowed_flag,
             ipv.input_value_id,
             ipv.uom,
	       eli.element_link_id,
              ele.element_entry_id,
	       eev.screen_entry_value screen_entry_value,
	       ele.object_version_number
	  from pay_element_types_f elt,
	       pay_input_values_f ipv,
	       pay_element_links_f eli,
	       pay_element_entries_f ele,
	       pay_element_entry_values_f eev
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and trunc(eff_date) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and trunc(eff_date) between eli.effective_start_date
				   and eli.effective_end_date
	   and trunc(eff_date) between ele.effective_start_date
				   and ele.effective_end_date
	   and trunc(eff_date) between eev.effective_start_date
				   and eev.effective_end_date
	   and elt.element_type_id = ipv.element_type_id
	   and elt.element_type_id = eli.element_type_id + 0
	   and upper(elt.element_name) = upper(ele_name)
	   and ipv.input_value_id = eev.input_value_id
	   and ele.assignment_id = asg_id
	   and ele.element_entry_id + 0 = eev.element_entry_id
           and ele.element_link_id      = eli.element_link_id
	   and upper(ipv.name) = upper(input_name)
--	   and NVL(elt.business_group_id,0) = NVL(ipv.business_group_id,0)
           and (elt.business_group_id is null or elt.business_group_id = bg_id);
  --
  cursor c_nonrec_ele_info (ele_name    in varchar2
			   ,input_name  in varchar2
			   ,asg_id      in number
			   ,eff_date    in date
			   ,bg_id       in number) is
	select elt.multiple_entries_allowed_flag,
             ipv.input_value_id,
             ipv.uom,
	       eli.element_link_id,
	       ele.element_entry_id,
	       eev.screen_entry_value screen_entry_value,
	       ele.object_version_number
	  from pay_element_types_f elt,
	       pay_input_values_f ipv,
	       pay_element_links_f eli,
	       pay_element_entries_f ele,
	       pay_element_entry_values_f eev
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and trunc(eff_date) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and trunc(eff_date) between eli.effective_start_date
				   and eli.effective_end_date
	   and ele.effective_end_date =
			(select max(ele2.effective_end_date)
			   from pay_element_entries_f ele2
			  where ele2.element_entry_id = ele.element_entry_id)
	   and eev.effective_end_date =
			(select max(eev2.effective_end_date)
			   from pay_element_entries_f eev2
			  where eev2.element_entry_id = eev.element_entry_id)
	   and elt.element_type_id = ipv.element_type_id
	   and elt.element_type_id = eli.element_type_id + 0
         and upper(elt.element_name) = upper(ele_name)
	   and ipv.input_value_id = eev.input_value_id
	   and ele.assignment_id = asg_id
	   and ele.element_entry_id + 0 = eev.element_entry_id
         and ele.element_link_id      = eli.element_link_id
	 and upper(ipv.name) = upper(input_name)
--	 and NVL(elt.business_group_id,0) = NVL(ipv.business_group_id,0)
         and (elt.business_group_id is null or elt.business_group_id = bg_id);

-- Bug#4486823 RRR Changes
cursor c_nonrec_incntv_ele_info (ele_name    in varchar2
			   ,input_name  in varchar2
			   ,asg_id      in number
			   ,eff_date    in date
			   ,bg_id       in number) is
	select elt.multiple_entries_allowed_flag,
             ipv.input_value_id,
             ipv.uom,
	       eli.element_link_id,
	       ele.element_entry_id,
	       eev.screen_entry_value screen_entry_value,
	       ele.object_version_number
	  from pay_element_types_f elt,
	       pay_input_values_f ipv,
	       pay_element_links_f eli,
	       pay_element_entries_f ele,
	       pay_element_entry_values_f eev
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and trunc(eff_date) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and trunc(eff_date) between eli.effective_start_date
				   and eli.effective_end_date
       and trunc(eff_date) between ele.effective_start_date
				   and ele.effective_end_date
       and trunc(eff_date) between eev.effective_start_date
				   and eev.effective_end_date
	   and elt.element_type_id = ipv.element_type_id
	   and elt.element_type_id = eli.element_type_id + 0
         and upper(elt.element_name) = upper(ele_name)
	   and ipv.input_value_id = eev.input_value_id
	   and ele.assignment_id = asg_id
	   and ele.element_entry_id + 0 = eev.element_entry_id
         and ele.element_link_id      = eli.element_link_id
	 and upper(ipv.name) = upper(input_name)
--	 and NVL(elt.business_group_id,0) = NVL(ipv.business_group_id,0)
         and (elt.business_group_id is null or elt.business_group_id = bg_id);

   cursor    c_ele_ovn is
     select  object_version_number
     from    pay_element_entries_f
     where   element_entry_id = l_element_entry_id
     and     p_effective_date
     between effective_start_date and effective_end_date;

l_uom                  varchar2(4);
 Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and   p_eff_date between effective_start_date
             and effective_end_date;
--
-- to pick pay basis from PAR
 Cursor Cur_pay_basis is
       Select from_pay_basis,to_pay_basis
       From ghr_pa_requests
       Where pa_request_id=l_session.pa_request_id;
--       Where employee_assignment_id=p_assignment_id;
--       and effective_date=p_eff_date;
ll_bg_id           NUMBER;
ll_pay_basis       VARCHAR2(80);
ll_effective_Date  DATE;
l_new_element_name             VARCHAR2(80);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
   -- Initialization
   ghr_history_api.get_g_session_var(l_session);
   ll_effective_date := p_effective_date;

  -- Pick the business group id and also pay basis for later use
  For BG_rec in Cur_BG(p_assignment_id,p_effective_date)
  Loop
   ll_bg_id:=BG_rec.bg;
  End Loop;

--   Pick pay basis from PAR
IF (l_session.pa_request_id is NOT NULL) THEN
  For Pay_basis in Cur_Pay_basis
  Loop
         If (pay_basis.from_pay_basis is NULL and
               pay_basis.to_pay_basis is not NULL) then
           ll_pay_basis:=pay_basis.to_pay_basis;

         elsif (pay_basis.from_pay_basis is NOT NULL and
             pay_basis.to_pay_basis is NULL) then
           ll_pay_basis:=pay_basis.from_pay_basis;

         elsif (pay_basis.from_pay_basis is NOT NULL and
              pay_basis.to_pay_basis is NOT NULL) then
           ll_pay_basis:=pay_basis.to_pay_basis;

	 elsif (pay_basis.from_pay_basis is  NULL and
              pay_basis.to_pay_basis is NULL) then
         ll_pay_basis:='PA';

	 End If;
  End Loop;

  l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => ll_bg_id,
	                                   p_effective_date     => ll_effective_date,
	                                   p_pay_basis          => ll_pay_basis);

 ELSIF (l_session.pa_request_id is NULL) THEN

  IF (p_element_name = 'Basic Salary Rate'
    and (fnd_profile.value('HR_USER_TYPE')='INT')) THEN
           l_new_element_name :=
	           pqp_fedhr_uspay_int_utils.return_new_element_name(
                                           p_assignment_id      => p_assignment_id,
                                           p_business_group_id  => ll_bg_id,
	                                   p_effective_date     => ll_effective_date);
 ELSIF (fnd_profile.value('HR_USER_TYPE')<>'INT'
   or (p_element_name <> 'Basic Salary Rate' and (fnd_profile.value('HR_USER_TYPE')='INT'))) THEN
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => ll_bg_id,
	                                   p_effective_date     => ll_effective_date,
	                                   p_pay_basis          => NULL);

  END IF;
 END IF;

hr_utility.set_location(' New ELT in GHELEPKG'|| l_new_element_name,10);
--
-- the p_element_name is replaced with l_new_element_name
-- in further calls.
--

  -- If it is a correction action, then we have to read the
  -- element values from the history table to get the correct data
  -- This is definitely required for a non-recurring element,because
  -- the same element can repeat n number of times for the same pay period
  --
 If l_session.noa_id_correct is not null then
-- History package call fetch_element_entry_value picks new element name
-- again in its call so sending old element name.
   ghr_history_fetch.fetch_element_info_cor
   (p_element_name      		=>  p_element_name,
    p_input_value_name              =>  p_input_value_name,
    p_assignment_id     		=>  p_assignment_id,
    p_effective_date    		=>  p_effective_date,
    p_element_link_id      	      =>  p_element_link_id,
    p_input_value_id       	      =>  p_input_value_id,
    p_element_entry_id     	      =>  l_element_entry_id,
    p_value                	      =>  p_value,
    p_object_version_number         =>  p_object_version_number
   );
    p_element_entry_id  :=  l_element_entry_id;

  hr_utility.set_location('Find the uom ' ||l_proc, 2);
  if p_processing_type = 'R' then  -- Recurring element
    hr_utility.set_location('Find the uom -- Recurring' ||l_proc, 3);
    for c_rec_ele_info_rec in
		  c_rec_ele_info (l_new_element_name
				 ,p_input_value_name
				 ,p_assignment_id
				 ,p_effective_date
				 ,ll_bg_id) loop
      l_uom                     := c_rec_ele_info_rec.uom;
      if l_uom = 'D' then
         p_value := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_value));
      end if;
     exit;
    end loop;
  elsif p_processing_type = 'N' then  -- Recurring element
    hr_utility.set_location('Find the uom -- Non Recurring' ||l_proc, 4);
    for c_nonrec_ele_info_rec in
		  c_nonrec_ele_info (l_new_element_name
				    ,p_input_value_name
				    ,p_assignment_id
				    ,p_effective_date
				    ,ll_bg_id)
    loop
      l_uom                     := c_nonrec_ele_info_rec.uom;
      if l_uom = 'D' then
         p_value := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_value));
      end if;
     exit;
    end loop;
  end if;

Else
  hr_utility.set_location(' NOT CORRECTION IN ELEPKG; PROCESS TYPE '||p_processing_type,15);
  hr_utility.set_location(' Element Name ELEPKG ' ||l_new_element_name,1000);
  hr_utility.set_location(' BG ID ELEPKG'|| nvl(to_char(ll_bg_id),'NULL'),2000);
  hr_utility.set_location(' Eff date ELEPKG'|| p_effective_date ,3000);
  hr_utility.set_location(' ASSGID IN ELEPKG ' || to_char(p_assignment_id),3500);
  hr_utility.set_location(' INPUT VALUE name '|| p_input_value_name,4000);

  if p_processing_type = 'R' then  -- Recurring element
    p_input_value_id        := NULL;
    p_element_entry_id      := NULL;
    p_value                 := NULL;
    p_object_version_number := NULL;
    for c_rec_ele_info_rec in
		  c_rec_ele_info (l_new_element_name
				 ,p_input_value_name
				 ,p_assignment_id
				 ,p_effective_date
				 ,ll_bg_id)
    loop
     hr_utility.set_location(' INSIDE ELE RECURRING ',20);
      p_input_value_id          := c_rec_ele_info_rec.input_value_id;
      l_uom                     := c_rec_ele_info_rec.uom;
      p_element_link_id         := c_rec_ele_info_rec.element_link_id;
      p_element_entry_id        := c_rec_ele_info_rec.element_entry_id;
      p_value                   := c_rec_ele_info_rec.screen_entry_value;
      p_object_version_number   := c_rec_ele_info_rec.object_version_number;
      p_multiple_error_flag     := c_rec_ele_info_rec.multiple_entries_allowed_flag;
      if l_uom = 'D' then
         p_value := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_value));
      end if;
      exit;
    end loop;
  elsif p_processing_type = 'N' then  -- Nonrecurring element
    p_input_value_id            := NULL;
    p_element_entry_id          := NULL;
    p_value                     := NULL;
    p_object_version_number     := NULL;
    hr_utility.set_location('Element Name : '||l_new_element_name,0);
    IF l_new_element_name like '%Incentive%' AND
       l_new_element_name not like 'Separation Incentive%' THEN
       hr_utility.set_location('Inside Incentive Element',10);
        for c_nonrec_incntv_ele_info_rec in
		  c_nonrec_incntv_ele_info (l_new_element_name
				    ,p_input_value_name
				    ,p_assignment_id
				    ,p_effective_date
				    ,ll_bg_id)
        loop
          p_input_value_id          := c_nonrec_incntv_ele_info_rec.input_value_id;
          l_uom                     := c_nonrec_incntv_ele_info_rec.uom;
          p_element_link_id         := c_nonrec_incntv_ele_info_rec.element_link_id;
          p_element_entry_id        := c_nonrec_incntv_ele_info_rec.element_entry_id;
          p_value                   := c_nonrec_incntv_ele_info_rec.screen_entry_value;
          p_object_version_number   := c_nonrec_incntv_ele_info_rec.object_version_number;
          p_multiple_error_flag     := c_nonrec_incntv_ele_info_rec.multiple_entries_allowed_flag;
          if l_uom = 'D' then
             p_value := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_value));
          end if;
          hr_utility.set_location('Inside Incentive Element, Value:'||p_Value,10);
          exit;
        end loop;
    ELSE
        for c_nonrec_ele_info_rec in
              c_nonrec_ele_info (l_new_element_name
                        ,p_input_value_name
                        ,p_assignment_id
                        ,p_effective_date
                        ,ll_bg_id)
        loop
          p_input_value_id          := c_nonrec_ele_info_rec.input_value_id;
          l_uom                     := c_nonrec_ele_info_rec.uom;
          p_element_link_id         := c_nonrec_ele_info_rec.element_link_id;
          p_element_entry_id        := c_nonrec_ele_info_rec.element_entry_id;
          p_value                   := c_nonrec_ele_info_rec.screen_entry_value;
          p_object_version_number   := c_nonrec_ele_info_rec.object_version_number;
          p_multiple_error_flag     := c_nonrec_ele_info_rec.multiple_entries_allowed_flag;
          if l_uom = 'D' then
             p_value := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_value));
          end if;
          exit;
        end loop;
    END IF;
  else  -- Neither recurring nor nonrecurring element
    hr_utility.set_message (8301, 'GHR_38035_API_INV_PROC_TYPE');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 31);
 End if;
  --
  hr_utility.set_location(' Multiple Error Flag '||p_multiple_error_flag,3);
  hr_utility.set_location(' Leaving:'||l_proc, 4);
--
 exception when others then
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
           p_element_link_id        := NULL;
           p_input_value_id         := NULL;
           p_element_entry_id       := NULL;
           p_value                  := NULL;
           p_object_version_number  := NULL;
           p_multiple_error_flag    := NULL;
           raise;
end retrieve_element_info;
--
--
Function return_update_mode
  (p_id              in     pay_element_entries_f.element_entry_id%type,
   p_effective_date  in     date
   ) return varchar2 is

  l_proc     varchar2(72) := 'return_update_mode';
  l_eed      date;
  l_esd      date;
  l_mode     varchar2(20);
  l_exists  boolean := FALSE;


  cursor c_update_mode_e is
    select   ele.effective_start_date ,
             ele.effective_end_date
    from     pay_element_entries_f ele
    where    ele.element_entry_id = p_id
    and      p_effective_date
    between  ele.effective_start_date
    and      ele.effective_end_date;

   cursor     c_update_mode_e1 is
    select   ele.effective_start_date ,
             ele.effective_end_date
    from     pay_element_entries_f ele
    where    ele.element_entry_id = p_id
    and      p_effective_date  <  ele.effective_start_date
    order by 1 asc;

  Begin

    hr_utility.set_location('Entering  ' || l_proc,5);
-- get session variables

      for update_mode in c_update_mode_e loop
        hr_utility.set_location(l_proc,15);
        l_esd := update_mode.effective_start_date;
        l_eed := update_mode.effective_end_date;
      end loop;
      hr_utility.set_location(l_proc,20);
      If l_esd = p_effective_date then
         hr_utility.set_location(l_proc,25);
         l_mode := 'CORRECTION';
      Elsif l_esd < p_effective_date and
            to_char(l_eed,'YYYY/MM/DD') = '4712/12/31' then
         hr_utility.set_location(l_proc,30);
         l_mode := 'UPDATE';
      Elsif  l_esd <  p_effective_date  then
        hr_utility.set_location(l_proc,35);
        for update_mode1 in c_update_mode_e1 loop
          hr_utility.set_location(l_proc,40);
          l_exists := true;
          exit;
        end loop;
        If l_exists then
          hr_utility.set_location(l_proc,45);
          l_mode := 'UPDATE_CHANGE_INSERT';
        Else
          IF  to_char(l_eed,'YYYY/MM/DD') <> '4712/12/31' then
          -- This context comes when the separated employee has retro actions
          -- Separation action end dates the elements to the Separation effective date
            hr_utility.set_location(l_proc,48);
            l_mode := 'UPDATE';
          ELSE
            hr_utility.set_location(l_proc,50);
            l_mode := 'CORRECTION';
          END IF;
        End if;
        hr_utility.set_location(l_proc,55);
      End if;
      If l_mode is null then
       hr_utility.set_message(8301,'GHR_GET_DATE_TRACK_FAILED');
       hr_utility.set_message_token('TABLE_NAME','pay_element_entries_f');
       hr_utility.raise_error;
      End if;
      return l_mode;
   end return_update_mode;

-- ---------------------------------------------------------------------------
-- |-----------------------< get_input_value_id >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Return inpu value id
--
-- Prerequisites:
--
-- In Parameters:
--   p_element_name
--   p_input_value_name
--   p_effective_date
--
-- Out Parameters:
--   p_input_value_id
--
-- Post Success:
--   Processing nulls.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_input_value_id
	(p_element_name         in     pay_element_types_f.element_name%type
	,p_input_value_name     in     pay_input_values_f.name%type
	,p_effective_date       in     date
	) return pay_input_values_f.input_value_id%type is
  --
  l_input_value_id      pay_input_values_f.input_value_id%type;
  --
  cursor c_input_value (ele_name       in varchar2
		       ,input_name     in varchar2
		       ,eff_date       in date
		       ,bg_id          in NUMBER) is
	select ipv.input_value_id
	  from pay_element_types_f elt,
	       pay_input_values_f ipv
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and trunc(eff_date) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and elt.element_type_id = ipv.element_type_id
	   and upper(elt.element_name) = upper(ele_name)
	   and upper(ipv.name) = upper(input_name)
--	   and NVL(elt.business_group_id,0) = NVL(ipv.business_group_id,0)   --Ashley
	   and (elt.business_group_id is null or elt.business_group_id = bg_id);

ll_bg_id         NUMBER;
--
begin
--

-- get the business_group_id from profile
--
   fnd_profile.get('PER_BUSINESS_GROUP_ID',ll_bg_id);
   hr_utility.trace('Business Grp Id - Under get Inp val Id'||ll_bg_id);
--
  l_input_value_id      := NULL;
  for c_input_value_rec
      in c_input_value (p_element_name, p_input_value_name, p_effective_date,ll_bg_id)
   loop
    l_input_value_id    := c_input_value_rec.input_value_id;
    exit;
  end loop;
  return l_input_value_id;
  --
end get_input_value_id;
--
-- ---------------------------------------------------------------------------
-- |-----------------------< process_sf52_element >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Process SF52 element
--
-- Prerequisites:
--
-- In Parameters:
--   p_assignment_id
--   p_element_name
--   p_input_value_name1
--     The default is null.
--   p_value1
--     The default is null.
--   p_input_value_name2
--     The default is null.
--   p_value2
--     The default is null.
--   p_input_value_name3
--     The default is null.
--   p_value3
--     The default is null.
--   p_input_value_name4
--     The default is null.
--   p_value4
--     The default is null.
--   p_input_value_name5
--     The default is null.
--   p_value5
--     The default is null.
--   p_input_value_name6
--     The default is null.
--   p_value6
--     The default is null.
--   p_input_value_name7
--     The default is null.
--   p_value7
--     The default is null.
--   p_input_value_name8
--     The default is null.
--   p_value8
--     The default is null.
--   p_input_value_name9
--     The default is null.
--   p_value9
--     The default is null.
--   p_input_value_name10
--     The default is null.
--   p_value10
--     The default is null.
--   p_input_value_name11
--     The default is null.
--   p_value11
--     The default is null.
--   p_input_value_name12
--     The default is null.
--   p_value12
--     The default is null.
--   p_input_value_name13
--     The default is null.
--   p_value13
--     The default is null.
--   p_input_value_name14
--     The default is null.
--   p_value14
--     The default is null.
--   p_input_value_name15
--     The default is null.
--   p_value15
--     The default is null.
--   p_effective_date
--     The default is sysdate.
--
-- Out Parameters:
--   p_process_warning
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--
procedure process_sf52_element
	(p_assignment_id        in     per_assignments_f.assignment_id%type
	,p_element_name         in     pay_element_types_f.element_name%type
	,p_input_value_name1    in     pay_input_values_f.name%type
							default null
	,p_value1               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name2    in     pay_input_values_f.name%type
							default null
	,p_value2               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name3    in     pay_input_values_f.name%type
							default null
	,p_value3               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name4    in     pay_input_values_f.name%type
							default null
	,p_value4               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name5    in     pay_input_values_f.name%type
							default null
	,p_value5               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name6    in     pay_input_values_f.name%type
							default null
	,p_value6               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name7    in     pay_input_values_f.name%type
							default null
	,p_value7               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name8    in     pay_input_values_f.name%type
							default null
	,p_value8               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name9    in     pay_input_values_f.name%type
							default null
	,p_value9               in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name10   in     pay_input_values_f.name%type
							default null
	,p_value10              in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name11   in     pay_input_values_f.name%type
							default null
	,p_value11              in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name12   in     pay_input_values_f.name%type
							default null
	,p_value12              in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name13   in     pay_input_values_f.name%type
							default null
	,p_value13              in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name14   in     pay_input_values_f.name%type
							default null
	,p_value14              in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_input_value_name15   in     pay_input_values_f.name%type
							default null
	,p_value15              in     pay_element_entry_values_f.screen_entry_value%type
							default null
	,p_effective_date       in     date             default null
	,p_process_warning         out nocopy boolean
	) is
  --
  l_proc        varchar2(72) := g_package||'process_sf52_element';
  l_business_group_id   per_business_groups.business_group_id%type;
  l_element_type_id     pay_element_types_f.element_type_id%type;
  l_element_link_id     pay_element_links_f.element_link_id%type;
  l_entry_type          pay_element_entries_f.entry_type%type   default 'E';
  l_input_value_id1     pay_input_values_f.input_value_id%type;
  l_input_value_id2     pay_input_values_f.input_value_id%type;
  l_input_value_id3     pay_input_values_f.input_value_id%type;
  l_input_value_id4     pay_input_values_f.input_value_id%type;
  l_input_value_id5     pay_input_values_f.input_value_id%type;
  l_input_value_id6     pay_input_values_f.input_value_id%type;
  l_input_value_id7     pay_input_values_f.input_value_id%type;
  l_input_value_id8     pay_input_values_f.input_value_id%type;
  l_input_value_id9     pay_input_values_f.input_value_id%type;
  l_input_value_id10    pay_input_values_f.input_value_id%type;
  l_input_value_id11    pay_input_values_f.input_value_id%type;
  l_input_value_id12    pay_input_values_f.input_value_id%type;
  l_input_value_id13    pay_input_values_f.input_value_id%type;
  l_input_value_id14    pay_input_values_f.input_value_id%type;
  l_input_value_id15    pay_input_values_f.input_value_id%type;
  l_value1              pay_element_entry_values_f.screen_entry_value%type;
  l_value2              pay_element_entry_values_f.screen_entry_value%type;
  l_value3              pay_element_entry_values_f.screen_entry_value%type;
  l_value4              pay_element_entry_values_f.screen_entry_value%type;
  l_value5              pay_element_entry_values_f.screen_entry_value%type;
  l_value6              pay_element_entry_values_f.screen_entry_value%type;
  l_value7              pay_element_entry_values_f.screen_entry_value%type;
  l_value8              pay_element_entry_values_f.screen_entry_value%type;
  l_value9              pay_element_entry_values_f.screen_entry_value%type;
  l_value10             pay_element_entry_values_f.screen_entry_value%type;
  l_value11             pay_element_entry_values_f.screen_entry_value%type;
  l_value12             pay_element_entry_values_f.screen_entry_value%type;
  l_value13             pay_element_entry_values_f.screen_entry_value%type;
  l_value14             pay_element_entry_values_f.screen_entry_value%type;
  l_value15             pay_element_entry_values_f.screen_entry_value%type;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_processing_type       pay_element_types_f.processing_type%type;
  l_element_entry_id      pay_element_entries_f.element_entry_id%type;
  l_element_entry_id1      pay_element_entries_f.element_entry_id%type;
  l_object_version_number pay_element_entries_f.object_version_number%type;
  l_object_version_number1 pay_element_entries_f.object_version_number%type;
  l_multiple_error_flag   varchar2(1);
  l_create_warning        boolean;
  l_update_warning        boolean;
  l_delete_warning        boolean;
  l_create_element_entry  boolean := FALSE;
  l_update_element_entry  boolean := FALSE;
  l_business_group_found  boolean := FALSE;
  l_ele_proc_type_found   boolean := FALSE;
  l_input_value_found     boolean := FALSE;
  l_update_mode           varchar2(20);
  l_session               ghr_history_api.g_session_var_type;
  l_session_incentive     ghr_history_api.g_session_var_type;
  l_noa_id                ghr_nature_of_actions.nature_of_action_id%type;
  l_noa_code              ghr_nature_of_actions.code%type;
  l_noa_fam_code          ghr_noa_families.noa_family_code%type;

  --
  cursor c_business_group (asg_id number, eff_date date) is
	select asg.business_group_id
	  from per_all_assignments_f asg
	 where asg.assignment_id = asg_id
	   and eff_date between asg.effective_start_date
			    and asg.effective_end_date;
  --
  cursor c_ele_processing_type (bg_id		in number
			       ,ele_name        in varchar2
			       ,eff_date        in date) is
	select elt.element_type_id,
	       elt.processing_type
	  from pay_element_types_f elt
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and upper(elt.element_name) = upper(ele_name)
           and ( elt.business_group_id is NULL or
                 elt.business_group_id = bg_id );


  cursor c_noa_code is
    select noa.code
    from   ghr_nature_of_actions noa
    where  noa.nature_of_action_id = l_noa_id;

  --
  -- to pick pay basis from PAR
 Cursor Cur_pay_basis is
       Select from_pay_basis,to_pay_basis
       From   ghr_pa_requests
       Where pa_request_id=l_session.pa_request_id;
--       Where employee_assignment_id=p_assignment_id;
--       and   effective_date=p_eff_date;
--
-- Bug#5045806
CURSOR c_curr_incentive(l_asg_id NUMBER, l_effective_date DATE, l_element_name VARCHAR2) IS
    SELECT  count(*) cnt
    FROM    pay_element_entries_f ee, pay_element_types_f et
    WHERE   ee.assignment_id = l_asg_id
      AND   ee.element_type_id = et.element_type_id
      AND   et.element_name = l_element_name
      AND   l_effective_date between ee.effective_start_date
                                AND  ee.effective_end_date;
-- Bug35045806

ll_pay_basis        VARCHAR2(80);
ll_effective_date   DATE;
l_new_element_name  VARCHAR2(80);
l_biweekly_end_date DATE;
l_p_value15         pay_element_entry_values_f.screen_entry_value%type;
l_cnt               NUMBER;
--
begin

hr_utility.set_location('Entering:'||l_proc, 1);
hr_utility.set_location('element '||p_element_name,0);
hr_utility.trace('Input Value Name1:'||p_input_value_name1);
hr_utility.trace('VALUE1 :'||p_value1);
hr_utility.trace('L_VALUE1 :'||l_value1);
hr_utility.trace('Input Value Name2:'||p_input_value_name2);
hr_utility.trace('Value2 :'||p_value2);
hr_utility.trace('L_Value2 :'||l_value2);
If p_element_name like '%Incentive Biweekly%' AND
   p_element_name <> 'Separation Incentive Biweekly' THEN
    hr_utility.set_location('Inside biweekly element ',0);
    l_biweekly_end_date := p_value15;
    l_p_value15           := NULL;
ELSE
    l_p_value15    := p_value15;
END IF;

-- Bug#5045806 Verify whether an element entry already exists for this
IF p_element_name like '%Lump Sum%' THEN
   ghr_history_api.get_g_session_var(l_session_incentive);
   IF l_session_incentive.noa_id_correct is NULL THEN
        FOR curr_incentive_rec IN c_curr_incentive(p_assignment_id,p_effective_date,p_element_name)
        LOOP
            l_cnt := curr_incentive_rec.cnt;
        END LOOP;
        IF l_cnt > 0 and p_element_name <> 'Separation Incentive Lump Sum' THEN
            hr_utility.set_message(8301, 'GHR_38129_INCN_ELE_EXISTS');
            hr_utility.set_message_token('ELEMENT_NAME',p_element_name);
            hr_utility.set_message_token('EFF_DATE',p_effective_date);
            hr_utility.raise_error;
        END IF;
    END IF;
END IF;
-- End Bug#5045806
--
 for c_business_group_rec
	in c_business_group (p_assignment_id, p_effective_date) loop
    l_business_group_found := TRUE;
    l_business_group_id    := c_business_group_rec.business_group_id;
    exit;
  end loop;
--
  if not l_business_group_found then
    hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 2);
-- Pick pay basis from PAR
ll_effective_date := p_effective_Date;

IF (l_session.pa_request_id is NOT NULL) THEN
        For Pay_basis in Cur_Pay_basis
        Loop
         If (pay_basis.from_pay_basis is NULL and
               pay_basis.to_pay_basis is not NULL) then
           ll_pay_basis:=pay_basis.to_pay_basis;

         elsif (pay_basis.from_pay_basis is NOT NULL and
             pay_basis.to_pay_basis is NULL) then
           ll_pay_basis:=pay_basis.from_pay_basis;

         elsif (pay_basis.from_pay_basis is NOT NULL and
              pay_basis.to_pay_basis is NOT NULL) then
           ll_pay_basis:=pay_basis.to_pay_basis;

  	  elsif (pay_basis.from_pay_basis is  NULL and
                pay_basis.to_pay_basis is NULL) then
           ll_pay_basis:='PA';

          End If;
         End Loop;
--

  l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => l_business_group_id,
                                           p_effective_date     => ll_effective_date,
                                           p_pay_basis          => ll_pay_basis);

 ELSIF (l_session.pa_request_id is NULL) THEN
  IF (p_element_name = 'Basic Salary Rate'
    and (fnd_profile.value('HR_USER_TYPE')='INT')) THEN
           l_new_element_name :=
                   pqp_fedhr_uspay_int_utils.return_new_element_name(
                                           p_assignment_id      => p_assignment_id,
                                           p_business_group_id  => l_business_group_id,
                                           p_effective_date     => ll_effective_date);
 ELSIF (fnd_profile.value('HR_USER_TYPE')<>'INT'
   or (p_element_name <> 'Basic Salary Rate' and (fnd_profile.value('HR_USER_TYPE')='INT'))) THEN
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => l_business_group_id,
                                           p_effective_date     => ll_effective_date,
                                           p_pay_basis          => NULL);

  END IF;
 END IF;
--
--
hr_utility.trace('old Element Name : ' ||p_element_name);
hr_utility.trace('New Element Name : ' ||l_new_element_name);
   --
  -- ONLY THIS CURSOR and GET_INPUT_VALUE_ID procedure USE NEW ELEMENT NAME
  --
  for c_ele_processing_type_rec in
		c_ele_processing_type (l_business_group_id
			              ,l_new_element_name
				      ,p_effective_date) loop
    l_ele_proc_type_found := TRUE;
    l_element_type_id     := c_ele_processing_type_rec.element_type_id;
    l_processing_type     := c_ele_processing_type_rec.processing_type;
    exit;
  end loop;
  if not l_ele_proc_type_found then
    hr_utility.set_message(8301, 'GHR_38035_API_INV_PROC_TYPE');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 2);
  --

  --  Retrieve element information if input value name is not null
  -- Using this p_element_name to pick old ele name under retrieve_element_info
  -- anyways. So passing old ele name than new ele name to avoid error.
  hr_utility.set_location('l_value1: '||l_value1,10);
  hr_utility.set_location('l_value2: '||l_value2,10);
  hr_utility.set_location('l_value3: '||l_value3,10);
  hr_utility.set_location('l_value4: '||l_value4,10);
    hr_utility.set_location('l_multiple_error_flag: '||l_multiple_error_flag,10);
  if p_input_value_name1 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name1
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id1
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value1
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  hr_utility.set_location('after fetch l_value1: '||l_value1,20);
  --
  if p_input_value_name2 is not NULL then
    IF p_input_value_name2 = 'Capped Other Pay' THEN
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name2
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id2
			 ,p_element_entry_id    => l_element_entry_id1
			 ,p_value               => l_value2
			 ,p_object_version_number => l_object_version_number1
			 ,p_multiple_error_flag => l_multiple_error_flag);
    ELSE
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name2
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id2
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value2
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
    END IF;
  end if;
    hr_utility.set_location('after fetch l_value2: '||l_value2,20);
  --
  if p_input_value_name3 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name3
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id3
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value3
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
    hr_utility.set_location('after fetch l_value3: '||l_value3,20);
  --
  if p_input_value_name4 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name4
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id4
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value4
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
    hr_utility.set_location('after fetch l_value4: '||l_value4,20);
  --
  if p_input_value_name5 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name5
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id5
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value5
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name6 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name6
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id6
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value6
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name7 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name7
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id7
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value7
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name8 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name8
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id8
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value8
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name9 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name9
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id9
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value9
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name10 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name10
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id10
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value10
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name11 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name11
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id11
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value11
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name12 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name12
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id12
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value12
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name13 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name13
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id13
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value13
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name14 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name14
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id14
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value14
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  --
  if p_input_value_name15 is not NULL then
    retrieve_element_info(p_element_name        => p_element_name
			 ,p_input_value_name    => p_input_value_name15
			 ,p_assignment_id       => p_assignment_id
			 ,p_effective_date      => p_effective_date
			 ,p_processing_type     => l_processing_type
			 ,p_element_link_id     => l_element_link_id
			 ,p_input_value_id      => l_input_value_id15
			 ,p_element_entry_id    => l_element_entry_id
			 ,p_value               => l_value15
			 ,p_object_version_number => l_object_version_number
			 ,p_multiple_error_flag => l_multiple_error_flag);
  end if;
  hr_utility.set_location('l_element_entry_id after retrieve ' || to_char(l_element_entry_id),1);
  hr_utility.set_location('l_element_entry_id1 after retrieve ' || to_char(l_element_entry_id1),2);
  hr_utility.set_location('l_value1 '||l_value1,3);
  hr_utility.set_location('l_value2'||l_value2,4);
  hr_utility.set_location('l_inp_val_id1'||to_char(l_input_value_id1),5);
  hr_utility.set_location('l_inp_val_id1'||to_char(l_input_value_id2),6);
  hr_utility.set_location('l_multiple_error_flag: '||l_multiple_error_flag,7);
  hr_utility.set_location(l_proc, 3);
  --
  --  if employee does not have the element entry
  --
  if (l_value1  is NULL and l_input_value_id1  is null   and
      l_value2  is NULL and l_input_value_id2  is null   and
      l_value3  is NULL and l_input_value_id3  is null   and
      l_value4  is NULL and l_input_value_id4  is null   and
      l_value5  is NULL and l_input_value_id5  is null   and
      l_value6  is NULL and l_input_value_id6  is null   and
      l_value7  is NULL and l_input_value_id7  is null   and
      l_value8  is NULL and l_input_value_id8  is null   and
      l_value9  is NULL and l_input_value_id9  is null   and
      l_value10 is NULL and l_input_value_id10 is null   and
      l_value11 is NULL and l_input_value_id11 is null   and
      l_value12 is NULL and l_input_value_id12 is null   and
      l_value13 is NULL and l_input_value_id13 is null   and
      l_value14 is NULL and l_input_value_id14 is null   and
      l_value15 is NULL and l_input_value_id15 is null )then
    --
    --  Get assignment eligibility element link
    --
    l_element_link_id := hr_entry_api.get_link
				(p_assignment_id   => p_assignment_id
				,p_element_type_id => l_element_type_id
				,p_session_date    => p_effective_date);
    --
    --  Get input value id for all input values of the element
    --
-- Added the if with check on input_value_id for testing
  -- If l_input_value_id1 is null then
    if p_input_value_name1 is not NULL then
      l_input_value_id1 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name1
				,p_effective_date       => p_effective_date);
    end if;
  -- End if;
    --
    if p_input_value_name2 is not NULL then
      l_input_value_id2 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name2
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name3 is not NULL then
      l_input_value_id3 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name3
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name4 is not NULL then
      l_input_value_id4 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name4
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name5 is not NULL then
      l_input_value_id5 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name5
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name6 is not NULL then
      l_input_value_id6 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name6
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name7 is not NULL then
      l_input_value_id7 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name7
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name8 is not NULL then
      l_input_value_id8 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name8
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name9 is not NULL then
      l_input_value_id9 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name9
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name10 is not NULL then
      l_input_value_id10 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name10
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name11 is not NULL then
      l_input_value_id11 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name11
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name12 is not NULL then
      l_input_value_id12 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name12
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name13 is not NULL then
      l_input_value_id13 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name13
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name14 is not NULL then
      l_input_value_id14 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name14
				,p_effective_date       => p_effective_date);
    end if;
    --
    if p_input_value_name15 is not NULL then
      l_input_value_id15 := get_input_value_id
				(p_element_name         => l_new_element_name
				,p_input_value_name     => p_input_value_name15
				,p_effective_date       => p_effective_date);
    end if;
    hr_utility.set_location(l_proc, 4);
    --
    begin
     savepoint cr_ent;
    py_element_entry_api.create_element_entry
		(p_effective_date               => p_effective_date
		,p_business_group_id            => l_business_group_id
		,p_assignment_id                => p_assignment_id
		,p_element_link_id              => l_element_link_id
		,p_entry_type                   => l_entry_type
		,p_input_value_id1              => l_input_value_id1
		,p_entry_value1                 => p_value1
		,p_input_value_id2              => l_input_value_id2
		,p_entry_value2                 => p_value2
		,p_input_value_id3              => l_input_value_id3
		,p_entry_value3                 => p_value3
		,p_input_value_id4              => l_input_value_id4
		,p_entry_value4                 => p_value4
		,p_input_value_id5              => l_input_value_id5
		,p_entry_value5                 => p_value5
		,p_input_value_id6              => l_input_value_id6
		,p_entry_value6                 => p_value6
		,p_input_value_id7              => l_input_value_id7
		,p_entry_value7                 => p_value7
		,p_input_value_id8              => l_input_value_id8
		,p_entry_value8                 => p_value8
		,p_input_value_id9              => l_input_value_id9
		,p_entry_value9                 => p_value9
		,p_input_value_id10             => l_input_value_id10
		,p_entry_value10                => p_value10
		,p_input_value_id11             => l_input_value_id11
		,p_entry_value11                => p_value11
		,p_input_value_id12             => l_input_value_id12
		,p_entry_value12                => p_value12
		,p_input_value_id13             => l_input_value_id13
		,p_entry_value13                => p_value13
		,p_input_value_id14             => l_input_value_id14
		,p_entry_value14                => p_value14
		,p_input_value_id15             => l_input_value_id15
		,p_entry_value15                => l_p_value15
		,p_effective_start_date         => l_effective_start_date
		,p_effective_end_date           => l_effective_end_date
		,p_element_entry_id             => l_element_entry_id
		,p_object_version_number        => l_object_version_number
		,p_create_warning               => l_create_warning);
          Exception
           when others then
             rollback to cr_ent;
             raise;
         End;
    --
    --  The following logic does not work until the procedure
    --    py_element_entry_api.create_element_entry will return p_create_warning
    --    flag.
    --
/*
    if not l_create_warning then
      l_create_element_entry := TRUE;
    else
      l_create_element_entry := FALSE;
    end if;
*/
    hr_utility.set_location(l_proc||l_element_entry_id, 5);
 Else
  --
  -- if one of the element entry values changed
  --

  if nvl(p_value1,hr_api.g_varchar2)   <> nvl(l_value1,hr_api.g_varchar2) or
     nvl(p_value2,hr_api.g_varchar2)   <> nvl(l_value2,hr_api.g_varchar2) or
     nvl(p_value3,hr_api.g_varchar2)   <> nvl(l_value3,hr_api.g_varchar2) or
     nvl(p_value4,hr_api.g_varchar2)   <> nvl(l_value4,hr_api.g_varchar2) or
     nvl(p_value5,hr_api.g_varchar2)   <> nvl(l_value5,hr_api.g_varchar2) or
     nvl(p_value6,hr_api.g_varchar2)   <> nvl(l_value6,hr_api.g_varchar2) or
     nvl(p_value7,hr_api.g_varchar2)   <> nvl(l_value7,hr_api.g_varchar2) or
     nvl(p_value8,hr_api.g_varchar2)   <> nvl(l_value8,hr_api.g_varchar2) or
     nvl(p_value9,hr_api.g_varchar2)   <> nvl(l_value9,hr_api.g_varchar2) or
     nvl( p_value10,hr_api.g_varchar2) <> nvl(l_value10,hr_api.g_varchar2) or
     nvl( p_value11,hr_api.g_varchar2) <> nvl(l_value11,hr_api.g_varchar2) or
     nvl( p_value12,hr_api.g_varchar2) <> nvl(l_value12,hr_api.g_varchar2) or
     nvl( p_value13,hr_api.g_varchar2) <> nvl(l_value13,hr_api.g_varchar2) or
     nvl( p_value14,hr_api.g_varchar2) <> nvl(l_value14,hr_api.g_varchar2) or
     nvl( l_p_value15,hr_api.g_varchar2) <> nvl(l_value15,hr_api.g_varchar2) then
    -- get session variable to determine if it is a 'CORRECTION'

      ghr_history_api.get_g_session_var(l_session);

      If l_multiple_error_flag = 'Y'
       and l_session.noa_id_correct is null
        then
         begin
          savepoint cr_ent;
         py_element_entry_api.create_element_entry
		(p_effective_date               => p_effective_date
		,p_business_group_id            => l_business_group_id
		,p_assignment_id                => p_assignment_id
		,p_element_link_id              => l_element_link_id
		,p_entry_type                   => l_entry_type
		,p_input_value_id1              => l_input_value_id1
		,p_entry_value1                 => p_value1
		,p_input_value_id2              => l_input_value_id2
		,p_entry_value2                 => p_value2
		,p_input_value_id3              => l_input_value_id3
		,p_entry_value3                 => p_value3
		,p_input_value_id4              => l_input_value_id4
		,p_entry_value4                 => p_value4
		,p_input_value_id5              => l_input_value_id5
		,p_entry_value5                 => p_value5
		,p_input_value_id6              => l_input_value_id6
		,p_entry_value6                 => p_value6
		,p_input_value_id7              => l_input_value_id7
		,p_entry_value7                 => p_value7
		,p_input_value_id8              => l_input_value_id8
		,p_entry_value8                 => p_value8
		,p_input_value_id9              => l_input_value_id9
		,p_entry_value9                 => p_value9
		,p_input_value_id10             => l_input_value_id10
		,p_entry_value10                => p_value10
		,p_input_value_id11             => l_input_value_id11
		,p_entry_value11                => p_value11
		,p_input_value_id12             => l_input_value_id12
		,p_entry_value12                => p_value12
		,p_input_value_id13             => l_input_value_id13
		,p_entry_value13                => p_value13
		,p_input_value_id14             => l_input_value_id14
		,p_entry_value14                => p_value14
		,p_input_value_id15             => l_input_value_id15
		,p_entry_value15                => l_p_value15
		,p_effective_start_date         => l_effective_start_date
		,p_effective_end_date           => l_effective_end_date
		,p_element_entry_id             => l_element_entry_id
		,p_object_version_number        => l_object_version_number
		,p_create_warning               => l_create_warning);
        hr_utility.set_location('elt entry id : '||l_element_entry_id,10);
            Exception
               when others then
                 rollback to cr_ent;
                raise;
           End;
        Else
           if l_session.noa_id_correct is not null then
            -- l_update_mode  :=  'CORRECTION';
            -- Bug 2125660
            -- Update mode should be deteremined for each element based on the
            -- Current effective start date and effective end date rather than
            -- Setting directly to 'CORRECTION'
             l_update_mode := return_update_mode(p_id    => l_element_entry_id,
                                                 p_effective_date => p_effective_date
                                                 );
             l_noa_id       := l_session.noa_id_correct;
           else
             l_update_mode := return_update_mode(p_id             => l_element_entry_id,
                                               p_effective_date => p_effective_date
                                              );
             l_noa_id      := l_session.noa_id;
           end if;
         -- for Other pay Elements update nulls as nulls.
          for noa_code_rec in c_noa_code loop
            l_noa_code := noa_code_rec.code;
          end loop;
           -- Bug 3854447
           -- Get the NOA_FAMILCY_CODE by calling the function
           l_noa_fam_code := ghr_pa_requests_pkg.get_noa_pm_family(l_noa_id);
           --
           hr_utility.set_location('l_noa_id is ' || l_noa_id,2);
           hr_utility.set_location('l_noa_code is ' || l_noa_code,2);
           hr_utility.set_location('l_noa_fam_code is ' || l_noa_fam_code,2);
          If l_noa_code = '819' or l_noa_code = '818' or l_noa_code = '810' or
            l_noa_fam_code like 'GHR_SAL%' then
            l_value1   := p_value1;
            l_value2   := p_value2;
            l_value3   := p_value3;
            l_value4   := p_value4;
            l_value5   := p_value5;
            l_value6   := p_value6;
            l_value7   := p_value7;
            l_value8   := p_value8;
            l_value9   := p_value9;
            l_value10  := p_value10;
            l_value11  := p_value11;
            l_value12  := p_value12;
            l_value13  := p_value13;
            l_value14  := p_value14;
            l_value15  := l_p_value15;
          End if;

--Bug 2835929
--Added Check to Ex-Emp awards,Date of Ex-Emp award earned can be nullified
--Bug 3531369 for 850 action amounts entered can be nullified.
	  IF l_noa_code IN('825','840','841','842','843','844','845','878','879','850') and p_value10 is NULL THEN
	    l_value10 :=p_value10;
	  END IF;

--Pradeep start of Bug  3209599
	  IF p_element_name = 'Recruitment Bonus' AND p_value3 IS NULL AND p_value2 IS NOT NULL THEN
		  l_value3 := p_value3;
	  END IF;
	  IF p_element_name = 'Relocation Bonus' AND p_value3 IS NULL AND p_value2 IS NOT NULL THEN
		  l_value3 := p_value3;
	  END IF;
--Pradeep end of Bug 3209599

--Bug 3257055
--During Correction to Award, if only amount is entered, update the percentage field with NULL
-- For element "Federal Awards", p_value3 stores 'Amount or Hours' and p_value4 stores 'Percentage'.

	  IF l_noa_fam_code LIKE 'AWARD%' AND
	     p_value3 is NOT NULL     AND
             p_value4 IS NULL THEN
 	       l_value4 := NULL;
	  END IF;
--Bug 3257055

	-- Bug 2709841 When Retention percentage is made null, then update the percentage field with null.
		IF p_element_name = 'Retention Allowance' AND p_value2 IS NULL AND p_value1 IS NOT NULL THEN
			l_value2 := p_value2;
		END IF;

           hr_utility.set_location('l_element_entry_id' || to_char(l_element_entry_id),2);
           hr_utility.set_location('p_value1 is ' || p_value1,2);
           hr_utility.set_location('l_value1 is ' || l_value1,2);
           hr_utility.set_location('p_value2 is ' || p_value2,2);
           hr_utility.set_location('l_value2 is ' || l_value2,2);
           hr_utility.set_location('p_value3 is ' || p_value3,2);
           hr_utility.set_location('l_value3 is ' || l_value3,2);
           hr_utility.set_location('p_value4 is ' || p_value4,2);
           hr_utility.set_location('l_value4 is ' || l_value4,2);
           hr_utility.set_location('p_value5 is ' || p_value5,2);
           hr_utility.set_location('l_value5 is ' || l_value5,2);

          -- Bug#2759379 Added this condition to facilitate user to make Eligibility Expiration to NULL
           IF p_element_name = 'FEGLI' and p_value2 is null  then
               l_value2 := null;
           END IF;
          -- Bug#2759379

	  --Bug 3531369
	  --Bug 3617295 Added Within Grade Increase to the If statement
	  IF  p_element_name IN('MDDDS Special Pay','Within Grade Increase',
	                         'Foreign Transfer Allowance') THEN
	        IF p_value1 IS NULL THEN l_value1 := NULL; END IF;
		IF p_value2 IS NULL THEN l_value2 := NULL; END IF;
		IF p_value3 IS NULL THEN l_value3 := NULL; END IF;
		IF p_value4 IS NULL THEN l_value4 := NULL; END IF;
		IF p_value5 IS NULL THEN l_value5 := NULL; END IF;
		IF p_value6 IS NULL THEN l_value6 := NULL; END IF;
		IF p_value7 IS NULL THEN l_value7 := NULL; END IF;
		IF p_value8 IS NULL THEN l_value8 := NULL; END IF;
		IF p_value9 IS NULL THEN l_value9 := NULL; END IF;
		IF p_value10 IS NULL THEN l_value10 := NULL; END IF;

	   END IF;
	   --Bug 3531369.


           begin
            savepoint upd_ent;
           py_element_entry_api.update_element_entry
		(p_datetrack_update_mode        => l_update_mode
		,p_effective_date               => p_effective_date
		,p_business_group_id            => l_business_group_id
		,p_element_entry_id             => l_element_entry_id
		,p_object_version_number        => l_object_version_number
		,p_input_value_id1              => l_input_value_id1
		,p_entry_value1                 => nvl(p_value1,l_value1)
		,p_input_value_id2              => l_input_value_id2
		,p_entry_value2                 => nvl(p_value2,l_value2)
		,p_input_value_id3              => l_input_value_id3
		,p_entry_value3                 => nvl(p_value3,l_value3)
		,p_input_value_id4              => l_input_value_id4
		,p_entry_value4                 => nvl(p_value4,l_value4)
		,p_input_value_id5              => l_input_value_id5
		,p_entry_value5                 => nvl(p_value5,l_value5)
		,p_input_value_id6              => l_input_value_id6
		,p_entry_value6                 => nvl(p_value6,l_value6)
		,p_input_value_id7              => l_input_value_id7
		,p_entry_value7                 => nvl(p_value7,l_value7)
		,p_input_value_id8              => l_input_value_id8
		,p_entry_value8                 => nvl(p_value8,l_value8)
		,p_input_value_id9              => l_input_value_id9
		,p_entry_value9                 => nvl(p_value9,l_value9)
		,p_input_value_id10             => l_input_value_id10
		,p_entry_value10                => nvl(p_value10,l_value10)
		,p_input_value_id11             => l_input_value_id11
		,p_entry_value11                => nvl(p_value11,l_value11)
		,p_input_value_id12             => l_input_value_id12
		,p_entry_value12                => nvl(p_value12,l_value12)
		,p_input_value_id13             => l_input_value_id13
		,p_entry_value13                => nvl(p_value13,l_value13)
		,p_input_value_id14             => l_input_value_id14
		,p_entry_value14                => nvl(p_value14,l_value14)
		,p_input_value_id15             => l_input_value_id15
		,p_entry_value15                => nvl(l_p_value15,l_value15)
		,p_effective_start_date         => l_effective_start_date
		,p_effective_end_date           => l_effective_end_date
		,p_update_warning               => l_update_warning);
             Exception
               when others then
                 rollback to upd_ent;
                 raise;
             End;
         End if;
    --
    --  The following logic does not work until the procedure
    --    py_element_entry_api.update_element_entry will return p_update_warning
    --    flag.
    --
 end if;
End if;

-- Bug#4486823 RRR Changes Added code to test RRR Technical Feasibility
IF p_element_name like '%Incentive Biweekly%' and l_biweekly_end_date IS NOT NULL THEN
   ghr_history_api.get_g_session_var(l_session);
   IF l_session.noa_id_correct is NULL THEN
        BEGIN
            SAVEPOINT del_ent;
            pay_element_entry_api.delete_element_entry
                  (p_validate               => false
                  ,p_datetrack_delete_mode  => 'DELETE'
                  ,p_effective_date         => l_biweekly_end_date
                  ,p_element_entry_id       => l_element_entry_id
                  ,p_object_version_number  => l_object_version_number
                  ,p_effective_start_date   => l_effective_start_date
                  ,p_effective_end_date     => l_effective_end_date
                  ,p_delete_warning         => l_delete_warning
                  );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK to del_ent;
                RAISE;
        END;
    END IF;
END IF;
-- END of code to test RRR Technical Feasibility
--

  hr_utility.set_location(' Leaving:'||l_proc, 20);
Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          p_process_warning := null;
          raise;
end process_sf52_element;
--
end ghr_element_api;

/
