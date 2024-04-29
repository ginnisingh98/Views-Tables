--------------------------------------------------------
--  DDL for Package Body HR_SCL_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SCL_FLEX" as
/* $Header: hrsclfli.pkb 115.7 1999/12/07 02:45:12 pkm ship    $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_scl_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment1 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment1 attribute for US legislation as follows :
--  A) Segment1 must exist as a tax_unit_id in the view HR_TAX_UNITS_V for the
--     business gruop id.
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment1 -->
--
-- Post Success:
--  If the p_segment1 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment1
	(p_segment1 in varchar2
        ,p_business_group_id in number) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment1';
  l_business_group_id number;
--
  cursor csr_chk_tu is
        select htu.business_group_id
        from   HR_TAX_UNITS_V htu
        where  htu.tax_unit_id = p_segment1;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  -- Check that segment1, if it is not null, is linked to a valid tax unit
  --
  if p_segment1 is not null then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
     open csr_chk_tu;
     fetch csr_chk_tu into l_business_group_id;
     if csr_chk_tu%notfound then
       close csr_chk_tu;
       hr_utility.set_message(800,'HR_50002_SCL_US_GOV_REPORTING');
       hr_utility.raise_error;
     end if;
     close csr_chk_tu;
     hr_utility.set_location(l_proc, 10);
     --
     if l_business_group_id <> p_business_group_id then
       hr_utility.set_message(800,'HR_50003_SCL_US_GOV_BUS_GRP');
       hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment1;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment2 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment2 attribute for US legislation as follows :
--  a) Segment2 must exist as a valid person_id for a current employee in the
--     business group
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment2 -->
--
-- Post Success:
--  If the p_segment2 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment2
--
        (p_segment2 		 in varchar2
        ,p_business_group_id 	 in number
        ,p_validation_start_date in date
        ,p_validation_end_date   in date) IS
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment2';
  l_business_group_id number;
--
-- Need to change this to standard datetrack validation or to use
-- p_effective_date when decision has been made re. correct validation
--
  cursor csr_chk_emp is
        select peo.business_group_id
        from   per_people_f peo
        ,      per_assignments_f asg
        where  peo.person_id = asg.person_id
        and    asg.assignment_type = 'E'
        and    peo.person_id = p_segment2
        and    p_validation_start_date between peo.effective_start_date
				  and peo.effective_end_date
        and    p_validation_start_date between asg.effective_start_date
				  and asg.effective_end_date;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  If p_segment2 is not null then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'validation_start_date'
    ,p_argument_value   => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'validation_end_date'
    ,p_argument_value   => p_validation_end_date
    );
  --
     open csr_chk_emp;
     fetch csr_chk_emp into l_business_group_id;
     if csr_chk_emp%notfound then
       close csr_chk_emp;
       hr_utility.set_message(800,'HR_50004_SCL_US_TIME_EMP');
       hr_utility.raise_error;
     end if;
     close csr_chk_emp;
     hr_utility.set_location(l_proc, 10);
     --
     if l_business_group_id <> p_business_group_id then
       hr_utility.set_message(800,'HR_50005_SCL_US_TIME_BUS_GRP');
       hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment3 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment3 attribute for US legislation as follows :
--  a) Segment3 must exist as a lookup_code in the table FND_COMMON_LOOKUPS
--     for the lookup_type = 'YES_NO'
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment3 -->
--
-- Post Success:
--  If the p_segment3 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment3
	(p_segment3 in varchar2 ) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment3';
  l_business_group_id number;
--
  cursor csr_chk_yes_no is
        select null
        from   FND_COMMON_LOOKUPS lu
        where  lu.lookup_type = 'YES_NO'
        and    lu.lookup_code = p_segment3;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  If p_segment3 is not null then
  --
     open csr_chk_yes_no;
     fetch csr_chk_yes_no into l_exists;
     if csr_chk_yes_no%notfound then
       close csr_chk_yes_no;
       hr_utility.set_message(800,'HR_50006_SCL_US_TIME_REQD');
       hr_utility.raise_error;
     end if;
     close csr_chk_yes_no;
     --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment3;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment4 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment4 attribute for US legislation as follows :
--  a) Segment4 must exist as a user_column_id for the work schedule table set
--     up for the assignment's organization.
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment4 -->
--
-- Post Success:
--  If the p_segment4 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment4
        (p_segment4 in varchar2
        ,p_organization_id number) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment4';
  l_organization_id number;
--
-- Must convert user_table_id to character, rather than org_information1 to number
-- as under CBO the execution plan is not guaranteed and org_information1 may contain
-- non-numeric data. May convert p_segment4 to number as it should be numeric, and
-- then the index on user_column_id is available.
--
  cursor csr_chk_work_schedule is
    select null
      from pay_user_columns puc
          ,hr_organization_information hoi
     where (  to_char(puc.user_table_id) = hoi.org_information1
           or hoi.org_information1 is null)
       and puc.user_column_id = to_number(p_segment4)
       and hoi.org_information_context = 'Work Schedule'
       and hoi.organization_id = p_organization_id;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  hr_utility.set_location(l_proc, 5);
  --
  If p_segment4 is not null then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'organization_id'
    ,p_argument_value   => p_organization_id
    );
  --
     open csr_chk_work_schedule;
     fetch csr_chk_work_schedule into l_exists;
     if csr_chk_work_schedule%notfound then
       close csr_chk_work_schedule;
       hr_utility.set_message(800,'HR_50007_SCL_US_INV_SCHEDULE');
       hr_utility.raise_error;
     end if;
     close csr_chk_work_schedule;
     --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment4;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment5 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment5 attribute for US legislation as follows :
--  a) Segment5 must exist as a lookup_code in the table FND_COMMON_LOOKUPS
--     for the lookup_type = 'US_SHIFTS'
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment5 -->
--
-- Post Success:
--  If the p_segment5 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment5
	(p_segment5 in varchar2 ) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment5';
--
  cursor csr_chk_shift is
        select null
        from   FND_COMMON_LOOKUPS lu
        where  lu.lookup_type = 'US_SHIFTS'
        and    lu.lookup_code = p_segment5
        and    lu.application_id = 800;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  If p_segment5 is not null then
  --
     open csr_chk_shift;
     fetch csr_chk_shift into l_exists;
     if csr_chk_shift%notfound then
       close csr_chk_shift;
       hr_utility.set_message(800,'PAY_7706_PDT_SHIFT_NOT_FOUND');
       hr_utility.raise_error;
     end if;
     close csr_chk_shift;
     --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment5;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment6 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment6 attribute for US legislation as follows :
--  a)
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment6 -->
--
-- Post Success:
--  If the p_segment6 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment6
	(p_segment6 in varchar2) is
--
  l_exists            varchar2(1);
  l_proc              varchar2(72) := g_package||'chk_us_segment6';
  l_business_group_id number(15);
  l_segment6          varchar2(60);
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  If p_segment6 is not null then
    --
    -- Ensure that the length is 11
    --
    if (length(p_segment6) > 11) then
      hr_utility.set_message(800,'HR_50008_SCL_US_SPOUSE_SALARY');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Ensure that p_segment6 is in numberic format with a precision of 2
    --
    l_segment6 := p_segment6;
    hr_dbchkfmt.is_db_format
	(p_value  => l_segment6,
	 p_arg_name => 'segment6',
	 p_format => 'H_DECIMAL2');
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- Ensure that p_segment6 is betwween 0 and 10000000.00
    --
    if (to_number(p_segment6) < 0) or (to_number(p_segment6) > 10000000.00) then
      hr_utility.set_message(800,'HR_50008_SCL_US_SPOUSE_SALARY');
      hr_utility.raise_error;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment6;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment7 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment7 attribute for US legislation as follows :
--  a) Segment7 must exist as a lookup_code in the table FND_COMMON_LOOKUPS
--     for the lookup_type = 'YES_NO'
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment7 -->
--
-- Post Success:
--  If the p_segment7 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment7
	(p_segment7 in varchar2) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment7';
  l_business_group_id number;
--
  cursor csr_chk_yes_no is
        select null
        from   FND_COMMON_LOOKUPS lu
        where  lu.lookup_type = 'YES_NO'
        and    lu.lookup_code = p_segment7;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  If p_segment7 is not null then
  --
     open csr_chk_yes_no;
     fetch csr_chk_yes_no into l_exists;
     if csr_chk_yes_no%notfound then
       close csr_chk_yes_no;
       hr_utility.set_message(800,'HR_50009_SCL_US_LEGAL_REP');
       hr_utility.raise_error;
     end if;
     close csr_chk_yes_no;
     --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment7;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment8 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment8 attribute for US legislation as follows :
--  a) Segment8 must exist as a wc code
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment4 -->
--
-- Post Success:
--  If the p_segment8 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment8
        (p_segment8 in varchar2
        ,p_segment1 in varchar2
        ,p_location_id number
        ,p_assignment_id number) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment8';
  l_assignment_id number;
  l_location_id number;
--
  cursor csr_chk_wc_override is
   Select null
   From PAY_WC_RATES wcr,
	PAY_WC_FUNDS wcf,
	HR_ORGANIZATION_INFORMATION org,
	PAY_EMP_FED_TAX_V1 ftr
   where wcr.fund_id = wcf.fund_id
   and
   (
     ( wcf.location_id is null
	and not exists
 	  (
	   select 1
	   from pay_wc_rates wcr1,
	        pay_wc_funds wcf1
	   where wcr1.wc_code = wcr.wc_code
	   and     wcr1.fund_id = wcf1.fund_id
	   and     wcf1.location_id = p_location_id
	   and     wcf1.state_code = ftr.sui_state_code
	   and     wcf1.carrier_id = org.org_information8 )
	  )
	OR
	  ( wcf.location_id is not null
	     AND wcf.location_id = p_location_id
	  )
	)
	AND wcf.carrier_id = org.org_information8
	AND  org.org_information1 = ftr.sui_state_code
	AND  org.org_information_context = 'State Tax Rules'
	AND  org.organization_id = p_segment1
	AND   wcf.state_code = ftr.sui_state_code
	AND   ftr.assignment_id = p_assignment_id
	AND   wcr.wc_code = p_segment8;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  If p_segment8 is not null then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'assignment_id'
    ,p_argument_value   => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'segment1'
    ,p_argument_value   => p_segment1
    );
  --
    open csr_chk_wc_override;
    fetch csr_chk_wc_override into l_exists;
    if csr_chk_wc_override%notfound then
      close csr_chk_wc_override;
      hr_utility.set_message(800,'HR_50010_SCL_US_WORKERS_COMP');
      hr_utility.raise_error;
    end if;
    close csr_chk_wc_override;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment8;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment9 >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segment9 attribute for US legislation as follows :
--  a) Segment9 must exist as a establishment_id in the view HR_ESTABLISHMENTs
--     for the business gruop id.
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment9 -->
--
-- Post Success:
--  If the p_segment9 is valid then processing continues.
--
-- Post Failure:
--  If any of the above rules are violated then an application error will be
--  raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment9
	(p_segment9 in varchar2
        ,p_business_group_id in number) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72) := g_package||'chk_us_segment9';
  l_business_group_id number;
--
  cursor csr_chk_est is
	select est.business_group_id
	from   HR_ESTABLISHMENTS_V est
        where  est.establishment_id = p_segment9;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  -- Check that segment9, if it is not null, is linked to a valid establishment
  --
  if p_segment9 is not null then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
     open csr_chk_est;
     fetch csr_chk_est into l_business_group_id;
     if csr_chk_est%notfound then
       close csr_chk_est;
       hr_utility.set_message(800,'HR_50011_SCL_US_INV_REP_EST');
       hr_utility.raise_error;
     end if;
     close csr_chk_est;
     hr_utility.set_location(l_proc, 10);
     --
     if l_business_group_id <> p_business_group_id then
       hr_utility.set_message(800,'HR_50012_SCL_US_INV_REP_BUS');
       hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_us_segment9;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_us_segment10_30 >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Validates the segments 10..30  for US legislation
--
-- Pre-Conditions
--  None
--
-- In Arguments:
--  p_segment10..p_segment30
--
-- Post Success:
--  If p_segment10 to p_segment30 are NULL then processing continues.
--
-- Post Failure:
--  If any of p_segment10 to p_segment30 are NOT NULL then an application
--  error will be raised.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment10_30
	(p_segment10 in varchar2
	,p_segment11 in varchar2
	,p_segment12 in varchar2
	,p_segment13 in varchar2
	,p_segment14 in varchar2
	,p_segment15 in varchar2
	,p_segment16 in varchar2
	,p_segment17 in varchar2
	,p_segment18 in varchar2
	,p_segment19 in varchar2
	,p_segment20 in varchar2
	,p_segment21 in varchar2
	,p_segment22 in varchar2
	,p_segment23 in varchar2
	,p_segment24 in varchar2
	,p_segment25 in varchar2
	,p_segment26 in varchar2
	,p_segment27 in varchar2
	,p_segment28 in varchar2
	,p_segment29 in varchar2
	,p_segment30 in varchar2
        ) is
--
  l_proc	varchar2(72) := g_package||'chk_us_segment10_30';
  l_err           exception;        -- local error exception
  l_n	            number;           -- arg in error number (10..30)
  l_v	varchar2(60); -- arg in error value (10..30)
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  if p_segment10 is not null then
    l_n := 10;
    l_v := p_segment10;
    raise l_err;
  end if;
  if p_segment11 is not null then
    l_n := 11;
    l_v := p_segment11;
    raise l_err;
  end if;
  if p_segment12 is not null then
    l_n := 12;
    l_v := p_segment12;
    raise l_err;
  end if;
  if p_segment13 is not null then
    l_n := 13;
    l_v := p_segment13;
    raise l_err;
  end if;
  if p_segment14 is not null then
    l_n := 14;
    l_v := p_segment14;
    raise l_err;
  end if;
  if p_segment15 is not null then
    l_n := 15;
    l_v := p_segment15;
    raise l_err;
  end if;
  if p_segment16 is not null then
    l_n := 16;
    l_v := p_segment16;
    raise l_err;
  end if;
  if p_segment17 is not null then
    l_n := 17;
    l_v := p_segment17;
    raise l_err;
  end if;
  if p_segment18 is not null then
    l_n := 18;
    l_v := p_segment18;
    raise l_err;
  end if;
  if p_segment19 is not null then
    l_n := 19;
    l_v := p_segment19;
    raise l_err;
  end if;
  if p_segment20 is not null then
    l_n := 20;
    l_v := p_segment20;
    raise l_err;
  end if;
  if p_segment21 is not null then
    l_n := 21;
    l_v := p_segment21;
    raise l_err;
  end if;
  if p_segment22 is not null then
    l_n := 22;
    l_v := p_segment22;
    raise l_err;
  end if;
  if p_segment23 is not null then
    l_n := 23;
    l_v := p_segment23;
    raise l_err;
  end if;
  if p_segment24 is not null then
    l_n := 24;
    l_v := p_segment24;
    raise l_err;
  end if;
  if p_segment25 is not null then
    l_n := 25;
    l_v := p_segment25;
    raise l_err;
  end if;
  if p_segment26 is not null then
    l_n := 26;
    l_v := p_segment26;
    raise l_err;
  end if;
  if p_segment27 is not null then
    l_n := 27;
    l_v := p_segment27;
    raise l_err;
  end if;
  if p_segment28 is not null then
    l_n := 28;
    l_v := p_segment28;
    raise l_err;
  end if;
  if p_segment29 is not null then
    l_n := 29;
    l_v := p_segment29;
    raise l_err;
  end if;
  if p_segment30 is not null then
    l_n := 30;
    l_v := p_segment30;
    raise l_err;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
  exception
    when l_err then
      hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
      hr_utility.set_message_token('ARG_NAME', 'p_segment'||to_char(l_n));
      hr_utility.set_message_token('ARG_VALUE', l_v);
      hr_utility.raise_error;
end chk_us_segment10_30;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< kf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure kf
  (p_rec                   in per_asg_shd.g_rec_type
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc             varchar2(72) := g_package||'kf';
  l_legislation_code per_business_groups.legislation_code%type;
  l_cagr_grade_def_id number;
  l_concat_segments_out varchar2(2000);
--
  --
  -- this cursor selects the legislation_code for the business group which
  -- will be used to switch the segment validation.
  --
  cursor lcsel is
    select  pbg.legislation_code
    from    per_business_groups   pbg
    where   pbg.business_group_id = p_rec.business_group_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- ensure that p_rec.business_group_id is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'business_group_id',
     p_argument_value => p_rec.business_group_id);
  --
  open lcsel;
  fetch lcsel into l_legislation_code;
  if lcsel%notfound then
    close lcsel;
    -- the business group id must be invalid
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close lcsel;
  --
  if (l_legislation_code = 'US') then
    --
    -- we need to populate the hr_scl_shd.g_rec_type for use by the validation
    -- processes.
    -- note: the hr_scl_shd.api_updating function will ensure the
    --       soft_coding_keyflex_id is valid and exists.
    --       if the function returns a false the soft_coding_keyflex_id must
    --       be null. therefore, no validation processing is required.
    --
    if hr_scl_shd.api_updating
         (p_soft_coding_keyflex_id => p_rec.soft_coding_keyflex_id) then
      --
      -- SEGMENT1
      --
      chk_us_segment1(p_segment1 => hr_scl_shd.g_old_rec.segment1
                     ,p_business_group_id => p_rec.business_group_id);
      --
      hr_utility.set_location(l_proc, 15);
      --
      -- SEGMENT2
      --
      chk_us_segment2(p_segment2 => hr_scl_shd.g_old_rec.segment2
                     ,p_business_group_id => p_rec.business_group_id
                     ,p_validation_start_date => p_validation_start_date
                     ,p_validation_end_date => p_validation_end_date );
       --
      hr_utility.set_location(l_proc, 20);
      --
      -- SEGMENT3
      --
      chk_us_segment3(p_segment3 => hr_scl_shd.g_old_rec.segment3);
      --
      hr_utility.set_location(l_proc, 25);
      --
      -- SEGMENT4
      --
      chk_us_segment4(p_segment4 => hr_scl_shd.g_old_rec.segment4
                     ,p_organization_id => p_rec.organization_id);
      --
      hr_utility.set_location(l_proc, 30);
      --
      -- SEGMENT5
      --
      chk_us_segment5(p_segment5 => hr_scl_shd.g_old_rec.segment5);
      --
      hr_utility.set_location(l_proc, 35);
      --
      -- SEGMENT6
      --
      chk_us_segment6(p_segment6 => hr_scl_shd.g_old_rec.segment6);
      --
      hr_utility.set_location(l_proc, 40);
      --
      -- SEGMENT7
      --
      chk_us_segment7(p_segment7 => hr_scl_shd.g_old_rec.segment7);
      --
      hr_utility.set_location(l_proc, 45);
      --
      -- SEGMENT8
      --
      -- Check if assignment is being upated, as segment8 is enterable
      -- only when an assignment is being updated, not when an assignment is
      -- being inserted.
      --
      If per_asg_shd.api_updating
        (p_assignment_id => p_rec.assignment_id
        ,p_effective_date => p_validation_start_date
        ,p_object_version_number => p_rec.object_version_number) then
        --
        chk_us_segment8(p_segment8      => hr_scl_shd.g_old_rec.segment8
                       ,p_segment1      => hr_scl_shd.g_old_rec.segment1
                       ,p_location_id   => p_rec.location_id
                       ,p_assignment_id => p_rec.assignment_id );
      else
        if hr_scl_shd.g_old_rec.segment8 is not null then
          hr_utility.set_message(801,'HR_50013_SCL_WORKERS_OVERRIDE');
          hr_utility.raise_error;
        end if;
      end if;
      --
      hr_utility.set_location(l_proc, 50);
      --
      -- SEGMENT9
      --
      chk_us_segment9(p_segment9 => hr_scl_shd.g_old_rec.segment9
		     ,p_business_group_id => p_rec.business_group_id);
      --
      hr_utility.set_location(l_proc, 55);
      --
      -- SEGMENT10 to 30
      --
      chk_us_segment10_30(p_segment10 => hr_scl_shd.g_old_rec.segment10
                         ,p_segment11 => hr_scl_shd.g_old_rec.segment11
                         ,p_segment12 => hr_scl_shd.g_old_rec.segment12
                         ,p_segment13 => hr_scl_shd.g_old_rec.segment13
                         ,p_segment14 => hr_scl_shd.g_old_rec.segment14
                         ,p_segment15 => hr_scl_shd.g_old_rec.segment15
                         ,p_segment16 => hr_scl_shd.g_old_rec.segment16
                         ,p_segment17 => hr_scl_shd.g_old_rec.segment17
                         ,p_segment18 => hr_scl_shd.g_old_rec.segment18
                         ,p_segment19 => hr_scl_shd.g_old_rec.segment19
                         ,p_segment20 => hr_scl_shd.g_old_rec.segment20
                         ,p_segment21 => hr_scl_shd.g_old_rec.segment21
                         ,p_segment22 => hr_scl_shd.g_old_rec.segment22
                         ,p_segment23 => hr_scl_shd.g_old_rec.segment23
                         ,p_segment24 => hr_scl_shd.g_old_rec.segment24
                         ,p_segment25 => hr_scl_shd.g_old_rec.segment25
                         ,p_segment26 => hr_scl_shd.g_old_rec.segment26
                         ,p_segment27 => hr_scl_shd.g_old_rec.segment27
                         ,p_segment28 => hr_scl_shd.g_old_rec.segment28
                         ,p_segment29 => hr_scl_shd.g_old_rec.segment29
                         ,p_segment30 => hr_scl_shd.g_old_rec.segment30 );
      --
      hr_utility.set_location(l_proc, 60);

    else
      --
      -- Call segment validation processes from here to check for any
      -- mandatory segments. Need to explicitly pass across null values
      -- because an all null segment combination is not inserted into
      -- hr_soft_coding_keyflex.
      -- e.g. chk_us_segment1(p_segment1 => null);
      --
      null;
    end if;
  elsif (l_legislation_code = 'BF') then
    null;
  elsif (l_legislation_code = 'FR') then
    --
    -- Call the server side AOL routines to validate the SCL segment entres
    -- Need to populate g_old_rec to access the data.
    -- (The record has previously been inserted by
    -- hr_scl_ins.insert_dml)
    --
    if hr_scl_shd.api_updating
      (p_soft_coding_keyflex_id => p_rec.soft_coding_keyflex_id) then
      --
       hr_kflex_utility.ins_or_sel_keyflex_comb
      (p_appl_short_name        => 'PER',
       p_flex_code              => 'SCL',
       p_flex_num               => hr_scl_shd.g_old_rec.id_flex_num,
       p_segment1               => hr_scl_shd.g_old_rec.segment1,
       p_segment2               => hr_scl_shd.g_old_rec.segment2,
       p_segment3               => hr_scl_shd.g_old_rec.segment3,
       p_segment4               => hr_scl_shd.g_old_rec.segment4,
       p_segment5               => hr_scl_shd.g_old_rec.segment5,
       p_segment6               => hr_scl_shd.g_old_rec.segment6,
       p_segment7               => hr_scl_shd.g_old_rec.segment7,
       p_segment8               => hr_scl_shd.g_old_rec.segment8,
       p_segment9               => hr_scl_shd.g_old_rec.segment9,
       p_segment10              => hr_scl_shd.g_old_rec.segment10,
       p_segment11              => hr_scl_shd.g_old_rec.segment11,
       p_segment12              => hr_scl_shd.g_old_rec.segment12,
       p_segment13              => hr_scl_shd.g_old_rec.segment13,
       p_segment14              => hr_scl_shd.g_old_rec.segment14,
       p_segment15              => hr_scl_shd.g_old_rec.segment15,
       p_segment16              => hr_scl_shd.g_old_rec.segment16,
       p_segment17              => hr_scl_shd.g_old_rec.segment17,
       p_segment18              => hr_scl_shd.g_old_rec.segment18,
       p_segment19              => hr_scl_shd.g_old_rec.segment19,
       p_segment20              => hr_scl_shd.g_old_rec.segment20,
       p_segment21              => hr_scl_shd.g_old_rec.segment21,
       p_segment22              => hr_scl_shd.g_old_rec.segment22,
       p_segment23              => hr_scl_shd.g_old_rec.segment23,
       p_segment24              => hr_scl_shd.g_old_rec.segment24,
       p_segment25              => hr_scl_shd.g_old_rec.segment25,
       p_segment26              => hr_scl_shd.g_old_rec.segment26,
       p_segment27              => hr_scl_shd.g_old_rec.segment27,
       p_segment28              => hr_scl_shd.g_old_rec.segment28,
       p_segment29              => hr_scl_shd.g_old_rec.segment29,
       p_segment30              => hr_scl_shd.g_old_rec.segment30,
       p_concat_segments_in     => null,
       p_ccid                   => l_cagr_grade_def_id,
       p_concat_segments_out    => l_concat_segments_out );
       --
       -- Ignore the out parameters as they have been set previously.
       --
    End if;
  elsif (l_legislation_code = 'GB') then
    --
    -- if a soft_coding_keyflex_id exists we must error because GB does not
    -- support SCL (i.e. segments have been specified)
    --
    if p_rec.soft_coding_keyflex_id is not null then
      hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
      hr_utility.set_message_token('ARG_NAME', 'soft_coding_keyflex_id');
      hr_utility.set_message_token('ARG_VALUE', p_rec.soft_coding_keyflex_id);
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end kf;
--
end hr_scl_flex;

/
