--------------------------------------------------------
--  DDL for Package Body OTA_TFL_API_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFL_API_BUS" as
/* $Header: ottfl01t.pkb 120.0 2005/05/29 07:41:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfl_api_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate( p_rec               in out nocopy ota_tfl_api_shd.g_rec_type
                         , p_transaction_type  in varchar2) is

--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
  l_tfh_type varchar2(30);
  l_tfh_customer_id number;
  l_tfh_vendor_id number;
  l_tfh_receivable_type varchar2(30);
  l_tfh_transfer_status varchar2(30);
  l_tfh_superseded_flag varchar2(30);
  l_tfh_cancelled_flag varchar2(30);
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  ota_tfl_api_business_rules.get_finance_header
  (p_rec.finance_header_id
  ,l_tfh_type
  ,l_tfh_customer_id
  ,l_tfh_vendor_id
  ,l_tfh_receivable_type
  ,l_tfh_transfer_status
  ,l_tfh_superseded_flag
  ,l_tfh_cancelled_flag);
  --
  -- General checks on the Finance Header
  ota_tfl_api_business_rules.check_finance_header
            (l_tfh_type
            ,l_tfh_superseded_flag
            ,l_tfh_transfer_status
            ,l_tfh_cancelled_flag
            ,TRUE
            ,TRUE);
  --
if p_transaction_type <> 'COPY' then
  ota_tfl_api_business_rules.check_unique_finance_line
                 (p_rec.finance_line_id
                 ,p_rec.line_type
                 ,p_rec.booking_id
                 ,p_rec.resource_booking_id
                 ,p_rec.resource_allocation_id);
end if;
  --
  ota_tfl_api_business_rules.check_type_constraints (
         p_finance_line_type           => p_rec.line_type
        ,p_finance_header_id           => p_rec.finance_header_id
        ,p_booking_id                  => p_rec.booking_id
        ,p_booking_deal_id             => p_rec.booking_deal_id
        ,p_resource_booking_id         => p_rec.resource_booking_id
        ,p_resource_allocation_id      => p_rec.resource_allocation_id
	);
  --
  ota_tfl_api_business_rules.Check_currency_code
  (
   p_finance_line_type       => p_rec.line_type
  ,p_finance_header_id       => p_rec.finance_header_id
  ,p_booking_id              => p_rec.booking_id
  ,p_booking_deal_id         => p_rec.booking_deal_id
  ,p_resource_allocation_id  => p_rec.resource_allocation_id
  ,p_resource_booking_id     => p_rec.resource_booking_id
  );
  --
  ota_tfl_api_business_rules2.set_all_amounts
 ( p_finance_line_type          => p_rec.line_type
 , p_activity_version_id        => null
 , p_event_id                   => null
 , p_booking_id                 => p_rec.booking_id
 , p_booking_deal_id            => p_rec.booking_deal_id
 , p_resource_allocation_id     => p_rec.resource_allocation_id
 , p_resource_booking_id        => p_rec.resource_booking_id
 , p_currency_code              => p_rec.currency_code
 , p_standard_amount            => p_rec.standard_amount
 , p_money_amount               => p_rec.money_amount
 , p_unitary_amount             => p_rec.unitary_amount );
  --
ota_tfl_api_business_rules.check_type_and_amounts
 ( p_finance_line_type          => p_rec.line_type
 , p_standard_amount            => p_rec.standard_amount
 , p_money_amount               => p_rec.money_amount
 , p_unitary_amount             => p_rec.unitary_amount
 , p_booking_deal_id            => p_rec.booking_deal_id
 , p_finance_header_id          => p_rec.finance_header_id
);
  --
hr_utility.trace('Date Raised '||to_char(p_rec.date_raised,'DD-MON-YYYY'));
  ota_tfl_api_business_rules.get_date_raised
                                 ( p_rec.finance_header_id
                                 , p_rec.date_raised );
  --
  ota_tfl_api_business_rules.get_next_sequence_number
                                 ( p_rec.finance_header_id
                                 , p_rec.sequence_number );
 --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate( p_rec               in out nocopy ota_tfl_api_shd.g_rec_type
                         , p_money_amount      in out nocopy number
                         , p_unitary_amount    in out nocopy number
                         , p_date_raised       in out nocopy date
                         , p_sequence_number   in out nocopy number
                         , p_transaction_type  in varchar2) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
  l_finance_header_id_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.finance_header_id
                                , p_rec.finance_header_id );
--
  l_line_type_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.line_type
                                , p_rec.line_type );
--
  l_cancelled_flag_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.cancelled_flag
                                , p_rec.cancelled_flag );
--
  l_date_raised_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.date_raised
                                , p_rec.date_raised );
--
  l_sequence_number_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.sequence_number
                                , p_rec.sequence_number );
--
  l_transfer_status_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.transfer_status
                                , p_rec.transfer_status );
--
  l_booking_deal_id_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.booking_deal_id
                                , p_rec.booking_deal_id );
--
  l_resource_booking_id_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.resource_booking_id
                                , p_rec.resource_booking_id );
--
  l_resource_alloc_id_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.resource_allocation_id
                                , p_rec.resource_allocation_id );
--
  l_booking_id_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.booking_id
                                , p_rec.booking_id );
--
  l_standard_amount_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.standard_amount
                                , p_rec.standard_amount );
--
  l_money_amount_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.money_amount
                                , p_rec.money_amount );
--
  l_unitary_amount_changed   boolean
    := ota_general.value_changed( ota_tfl_api_shd.g_old_rec.unitary_amount
                                , p_rec.unitary_amount );
--
  l_tfh_type varchar2(30);
  l_tfh_customer_id number;
  l_tfh_vendor_id number;
  l_tfh_receivable_type varchar2(30);
  l_tfh_transfer_status varchar2(30);
  l_tfh_superseded_flag varchar2(30);
  l_tfh_cancelled_flag varchar2(30);
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.trace(p_transaction_type);
  --
  -- Call all supporting business operations
  --
  -- p_rec can only be IN parameter !!
  --
  p_money_amount   :=  p_rec.money_amount;
  p_unitary_amount :=  p_rec.unitary_amount;
  p_date_raised    :=  p_rec.date_raised;
  p_sequence_number:=  p_rec.sequence_number;
  --
  ota_tfl_api_business_rules.get_finance_header
  (p_rec.finance_header_id
  ,l_tfh_type
  ,l_tfh_customer_id
  ,l_tfh_vendor_id
  ,l_tfh_receivable_type
  ,l_tfh_transfer_status
  ,l_tfh_superseded_flag
  ,l_tfh_cancelled_flag);
  --
  -- General checks on the Finance Header
  ota_tfl_api_business_rules.check_finance_header
            (l_tfh_type
            ,l_tfh_superseded_flag
            ,l_tfh_transfer_status
            ,l_tfh_cancelled_flag
            ,(p_transaction_type <> 'CANCEL_HEADER_LINE' and
              p_transaction_type <> 'REINSTATE_HEADER_LINE')
            ,(p_transaction_type <> 'CANCEL_HEADER_LINE'));
--
  if p_transaction_type = 'CANCEL_HEADER_LINE' then
     return;
  end if;
  --
  if p_transaction_type not in
     ('CANCEL_LINE','REINSTATE_LINE','REINSTATE_HEADER_LINE') then
     if l_cancelled_flag_changed then
        fnd_message.set_name('OTA','OTA_13356_TFL_CANCELLED_FLAG');
        fnd_message.raise_error;
     end if;
  end if;
/*
  ota_tfl_api_business_rules.check_update_cancelled_flag
                                     ( p_rec.cancelled_flag );
*/
  --
  ota_tfl_api_business_rules.check_update_attributes(p_rec.transfer_status);
    --
  if p_transaction_type = 'CANCEL_LINE' then
     return;
  end if;
  --
  if p_transaction_type not in
     ('REINSTATE_LINE','REINSTATE_HEADER_LINE') then
     if p_rec.cancelled_flag = 'Y' then
        fnd_message.set_name('OTA','OTA_13488_TFL_CANCELLED');
        fnd_message.raise_error;
     end if;
  end if;
  --
  if l_line_type_changed then
          fnd_message.set_name('OTA','OTA_13354_TFL_NO_TYPE_UPDATE');
          fnd_message.raise_error;
  end if;
  --
  if (l_cancelled_flag_changed and
      p_rec.cancelled_flag = 'N')
  or l_booking_id_changed
  or l_resource_booking_id_changed
  or l_resource_alloc_id_changed then
     ota_tfl_api_business_rules.check_unique_finance_line
                 (p_rec.finance_line_id
                 ,p_rec.line_type
                 ,p_rec.booking_id
                 ,p_rec.resource_booking_id
                 ,p_rec.resource_allocation_id);
  end if;

  ota_tfl_api_business_rules.check_type_constraints (
         p_finance_line_type           => p_rec.line_type
        ,p_finance_header_id           => p_rec.finance_header_id
        ,p_booking_id                  => p_rec.booking_id
        ,p_booking_deal_id             => p_rec.booking_deal_id
        ,p_resource_booking_id         => p_rec.resource_booking_id
        ,p_resource_allocation_id      => p_rec.resource_allocation_id
        );
  --
  ota_tfl_api_business_rules.Check_currency_code
  (
   p_finance_line_type       => p_rec.line_type
  ,p_finance_header_id       => p_rec.finance_header_id
  ,p_booking_id              => p_rec.booking_id
  ,p_booking_deal_id         => p_rec.booking_deal_id
  ,p_resource_allocation_id  => p_rec.resource_allocation_id
  ,p_resource_booking_id     => p_rec.resource_booking_id
  );
  --
  If p_date_raised is null  Then
    ota_tfl_api_business_rules.get_date_raised
                                   ( p_rec.finance_header_id
                                   , p_date_raised );
  End if;
  --
  IF p_sequence_number is null  Then
    ota_tfl_api_business_rules.get_next_sequence_number
                                   ( p_rec.finance_header_id
                                   , p_sequence_number );
  --
  Elsif l_sequence_number_changed  Then
    If l_finance_header_id_changed  Then
      ota_tfl_api_business_rules.get_next_sequence_number
                                     ( p_rec.finance_header_id
                                     , p_sequence_number );
    Else
      ota_tfl_api_business_rules.check_sequence_number
                                     ( p_rec.finance_header_id
                                     , p_sequence_number );
    End if;
  --
  Else
    If l_finance_header_id_changed  Then
      ota_tfl_api_business_rules.get_next_sequence_number
                                     ( p_rec.finance_header_id
                                     , p_sequence_number );
    End if;
  End if;
  --
  if l_booking_id_changed          OR
     l_booking_deal_id_changed     OR
     l_resource_alloc_id_changed   OR
     l_resource_booking_id_changed OR
     l_standard_amount_changed     OR
     p_money_amount is null     Then
      --
      ota_tfl_api_business_rules2.set_all_amounts (
	  p_finance_line_type          => p_rec.line_type
	, p_activity_version_id        => null
	, p_event_id                   => null
	, p_booking_id                 => p_rec.booking_id
	, p_booking_deal_id            => p_rec.booking_deal_id
	, p_resource_allocation_id     => p_rec.resource_allocation_id
	, p_resource_booking_id        => p_rec.resource_booking_id
	, p_currency_code              => p_rec.currency_code
	, p_standard_amount            => p_rec.standard_amount
	, p_money_amount               => p_rec.money_amount
	, p_unitary_amount             => p_rec.unitary_amount );
      --
  End if;
  --
  ota_tfl_api_business_rules.check_type_and_amounts
         ( p_finance_line_type          => p_rec.line_type
         , p_standard_amount            => p_rec.standard_amount
         , p_money_amount               => p_rec.money_amount
         , p_unitary_amount             => p_rec.unitary_amount
	 , p_booking_deal_id            => p_rec.booking_deal_id
         , p_finance_header_id          => p_rec.finance_header_id
);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tfl_api_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Do Not allow deletion if Finance Line Transfer_status = 'ST'
  --
     if ota_tfl_api_shd.g_old_rec.transfer_status = 'ST' then
        fnd_message.set_name('OTA','OTA_13610_TFL_DELETE_CHK');
        fnd_message.raise_error;
     end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_finance_line_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from   per_business_groups_perf pbg,
                 ota_finance_headers tfh,
                 ota_finance_lines tfl,
		 hr_all_organization_units org
          where  pbg.business_group_id    = org.business_group_id
            and  org.organization_id = tfh.organization_id
            and  tfh.finance_header_id = tfl.finance_header_id
	    and  tfl.finance_line_id = p_finance_line_id;

  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'finance_line_id'
    ,p_argument_value     => p_finance_line_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'FINANCE_LINE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;

-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This function will be used by the user hooks. This will be  used
--   of by the user hooks of ota_finance_header and
--   ota_finance_lines row handler user hook business process.
--
-- Pre Conditions:
--   This function will be called by the user hook packages.
--
-- In Arguments:
--   p_finance_line_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--------------------------------------------------------------------------------
--
Function return_legislation_code
         ( p_finance_line_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups_perf pbg,
                 ota_finance_headers tfh,
		 ota_finance_lines tfl,
                 hr_all_organization_units org
          where  pbg.business_group_id    = org.business_group_id
            and  org.organization_id = tfh.organization_id
            and  tfh.finance_header_id = tfl.finance_header_id
	    and  tfl.finance_line_id = p_finance_line_id;


   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'finance_line_id',
                              p_argument_value => p_finance_line_id);
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;


end ota_tfl_api_bus;

/
