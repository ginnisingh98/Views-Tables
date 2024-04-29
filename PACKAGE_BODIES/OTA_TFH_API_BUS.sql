--------------------------------------------------------
--  DDL for Package Body OTA_TFH_API_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFH_API_BUS" as
/* $Header: ottfh01t.pkb 120.0 2005/05/29 07:40:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfh_api_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
                 (
                  p_rec              in out  nocopy ota_tfh_api_shd.g_rec_type
                 ,p_transaction_type in      varchar2
                 ) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.cancelled_flag = 'N' then
     null;
  else
     fnd_message.set_name('OTA','OTA_13489_TFH_CANCEL_FLAG');
     fnd_message.raise_error;
  end if;
  --
  ota_tfh_api_business_rules.check_receivable_attributes
                                         ( p_rec.type
                                         , p_rec.customer_id
                                         , p_rec.contact_id
                                         , p_rec.address_id
                                         , p_rec.invoice_address
                                         , p_rec.invoice_contact
                                         , p_rec.vendor_id
                                         , null
                                         , null
                                         , p_rec.receivable_type);
  --
  ota_tfh_api_business_rules.check_payable_attributes
                                      ( p_rec.type
                                      , p_rec.vendor_id
                                      , p_rec.contact_id
                                      , p_rec.address_id
                                      , p_rec.invoice_contact
                                      , p_rec.invoice_address
                                      , p_rec.customer_id
                                      , null
                                      , null
                                      , p_rec.receivable_type);
  --
  ota_tfh_api_business_rules.check_cancellation_attributes
                                           ( p_rec.type
                                           , p_rec.superceding_header_id
                                           , p_rec.customer_id
                                           , p_rec.contact_id
                                           , p_rec.address_id
                                           , p_rec.invoice_address
                                           , p_rec.invoice_contact
                                           , p_rec.vendor_id
                                           , null
                                           , null
                                           , p_rec.payment_method
                                           , p_rec.receivable_type);
  --
  ota_tfh_api_business_rules.check_status_unauthorized
                                       ( p_rec.transfer_status
                                       , p_rec.authorizer_person_id );
  --
  If p_rec.date_raised is null  Then
    --
    ota_tfh_api_business_rules.set_date_raised( p_rec.date_raised
                                              , sysdate );
    --
  End if;
  --
  ota_tfh_api_business_rules.check_authorized_by
                                 ( p_rec.authorizer_person_id);

  --
  ota_tfh_api_business_rules.check_customer_address
                                    ( p_rec.customer_id
                                    , p_rec.address_id );
  --
  if p_rec.invoice_address is null and
     p_rec.address_id is not null then
     ota_tfh_api_business_rules.set_invoice_address
                                 ( p_rec.customer_id
                                 , p_rec.address_id
                                 , p_rec.invoice_address );
  end if;
  --
  ota_tfh_api_business_rules.check_customer_contact
                                    ( p_rec.customer_id
                                    , p_rec.contact_id );
  --
  if p_rec.invoice_address is null and
     p_rec.address_id is not null then
     ota_tfh_api_business_rules.set_invoice_contact
                                 ( p_rec.customer_id
                                 , p_rec.contact_id
                                 , p_rec.invoice_contact );
  end if;
  --
  ota_tfh_api_business_rules.check_vendor_contact
                                  ( p_rec.vendor_id
                                  , p_rec.contact_id );
  --
  ota_tfh_api_business_rules.check_vendor_address
                                  ( p_rec.vendor_id
                                  , p_rec.address_id );
  --
  ota_tfh_api_business_rules.check_superseded_header
                                     ( p_rec.type
                                     , p_rec.superceding_header_id );
  --
  ota_tfh_api_business_rules.check_payment_method( p_rec.payment_method );
  --
  if p_rec.type <> 'CT' then
    ota_tfh_api_business_rules.check_allow_transfer
                                  ( p_rec.transfer_status
                                  , p_rec.payment_method );
  end if;
  --
  ota_tfh_api_business_rules.check_administrator( p_rec.administrator );

  --
  --
  -- check_transfer_status( p_rec.transfer_status);
  --
  -- check_cancelled_flag( p_rec.cancelled_flag );
  --
  -- check_payment_flag( p_rec.payment_flag );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec              in out nocopy  ota_tfh_api_shd.g_rec_type
                         ,p_transaction_type in      varchar2) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
  l_type_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.type
                                , p_rec.type );
--
  l_transfer_status_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.transfer_status
                                , p_rec.transfer_status );
--
  l_authorizer_person_id_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.authorizer_person_id
                                , p_rec.authorizer_person_id );
--
  l_address_id_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.address_id
                                , p_rec.address_id );
--
  l_contact_id_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.contact_id
                                , p_rec.contact_id );
--
  l_customer_id_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.customer_id
                                , p_rec.customer_id );
--
  l_vendor_id_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.vendor_id
                                , p_rec.vendor_id );
--
  l_cancelled_flag_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.cancelled_flag
                                , p_rec.cancelled_flag );
--
  l_supercedes_header_id_changed   boolean
   := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.superceding_header_id
                                , p_rec.superceding_header_id );
--
  l_payment_method_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.payment_method
                                , p_rec.payment_method );
--
  l_administrator_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.administrator
                                , p_rec.administrator );
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
     ota_tfh_api_business_rules.check_update_header
                                   ( ota_tfh_api_shd.g_old_rec
                                   , p_rec
                                   , p_transaction_type);
  --
  -- If cancelling the Header no further checks are required
  --
  if p_transaction_type = 'CANCEL_HEADER' then
     return;
  end if;
  --
  -- If finance header has been superseded then no changes allowed
  --
  ota_tfh_api_business_rules.check_superseded (p_rec.finance_header_id);
  --
  If l_type_changed         OR
     l_customer_id_changed  OR
     l_address_id_changed   OR
     l_contact_id_changed   OR
     l_vendor_id_changed    OR
     l_cancelled_flag_changed Then
    --
    ota_tfh_api_business_rules.check_receivable_attributes
                                           ( p_rec.type
                                           , p_rec.customer_id
                                           , p_rec.contact_id
                                           , p_rec.address_id
                                           , p_rec.invoice_address
                                           , p_rec.invoice_contact
                                           , p_rec.vendor_id
                                           , null
                                           , null
                                           , p_rec.receivable_type);
    --
    ota_tfh_api_business_rules.check_payable_attributes
                                        ( p_rec.type
                                        , p_rec.vendor_id
                                        , p_rec.contact_id
                                        , p_rec.address_id
                                        , p_rec.invoice_contact
                                        , p_rec.invoice_address
                                        , p_rec.customer_id
                                        , null
                                        , null
                                        , p_rec.receivable_type);
    --
  End if;
  --
  If l_type_changed                  OR
     l_supercedes_header_id_changed  OR
     l_customer_id_changed           OR
     l_address_id_changed            OR
     l_contact_id_changed            OR
     l_vendor_id_changed             Then
    --
    ota_tfh_api_business_rules.check_cancellation_attributes
                                             ( p_rec.type
                                             , p_rec.superceding_header_id
                                             , p_rec.customer_id
                                             , p_rec.contact_id
                                             , p_rec.address_id
                                             , p_rec.invoice_address
                                             , p_rec.invoice_contact
                                             , p_rec.vendor_id
                                             , null
                                             , null
                                             , p_rec.payment_method
                                             , p_rec.receivable_type);
    --
  End if;
  --
  If l_authorizer_person_id_changed or l_transfer_status_changed Then
    --
    ota_tfh_api_business_rules.check_status_unauthorized
                                         ( p_rec.transfer_status
                                         , p_rec.authorizer_person_id );
    --
    ota_tfh_api_business_rules.check_authorized_by
                                   ( p_rec.authorizer_person_id);
    --
  End if;
  --
  If l_customer_id_changed  Then
    --
    ota_tfh_api_business_rules.check_update_customer_id
                                        ( p_rec.customer_id
                                        , p_rec.address_id
                                        , p_rec.contact_id
                                        , p_rec.vendor_id );
    --
  End if;
  --
  If l_address_id_changed   Then
    --
  if p_rec.invoice_address is null and
     p_rec.address_id is not null then
    ota_tfh_api_business_rules.set_invoice_address
                                   ( p_rec.customer_id
                                   , p_rec.address_id
                                   , p_rec.invoice_address );
  end if;
    --
  End if;
  --
  If l_contact_id_changed   Then
    --
  if p_rec.invoice_address is null and
     p_rec.address_id is not null then
    ota_tfh_api_business_rules.set_invoice_contact
                                   ( p_rec.customer_id
                                   , p_rec.contact_id
                                   , p_rec.invoice_contact );
  end if;
    --
  End if;
  --
  If l_vendor_id_changed  Then
    --
    ota_tfh_api_business_rules.check_vendor_contact
                                    ( p_rec.vendor_id
                                    , p_rec.contact_id );
    --
    ota_tfh_api_business_rules.check_vendor_address
                                    ( p_rec.vendor_id
                                    , p_rec.address_id );
    --
  Else
    --
    If l_address_id_changed  Then
      --
      ota_tfh_api_business_rules.check_vendor_address
                                      ( p_rec.vendor_id
                                      , p_rec.address_id );
      --
    End if;
    --
    If l_contact_id_changed  Then
      --
      ota_tfh_api_business_rules.check_vendor_contact
                                      ( p_rec.vendor_id
                                      , p_rec.contact_id );
      --
    End if;
    --
  End if;
  --
  If l_type_changed                  OR
     l_supercedes_header_id_changed  Then
    --
    ota_tfh_api_business_rules.check_superseded_header
                                       ( p_rec.type
                                       , p_rec.superceding_header_id );
    --
  End if;
  --
  If l_payment_method_changed   Then
    --
    ota_tfh_api_business_rules.check_payment_method
                                     ( p_rec.payment_method );
    --
  End if;
  --
  If p_rec.type <> 'CT' Then
   If l_transfer_status_changed  OR
     l_payment_method_changed Then
    --
     ota_tfh_api_business_rules.check_allow_transfer
                                    ( p_rec.transfer_status
                                    , p_rec.payment_method );
   End if;
    --
  End if;
  --
  If l_transfer_status_changed then
     ota_tfh_api_business_rules.check_transfer_rules
         (p_rec.transfer_status
         ,ota_tfh_api_shd.g_old_rec.transfer_status);
  End if;
  --
  If l_administrator_changed  Then
    --
    ota_tfh_api_business_rules.check_administrator( p_rec.administrator );
    --
  End if;

  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tfh_api_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  ota_tfh_api_business_rules.check_deletion( p_rec.finance_header_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_finance_header_id                    in number
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
                 hr_all_organization_units org
          where  pbg.business_group_id    = org.business_group_id
            and  org.organization_id = tfh.organization_id
            and  tfh.finance_header_id = p_finance_header_id;

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
    ,p_argument           => 'finance_header_id'
    ,p_argument_value     => p_finance_header_id
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
        => nvl(p_associated_column1,'FINANCE_HEADER_ID')
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
--   p_finance_header_id
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
         ( p_finance_header_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups_perf pbg,
                 ota_finance_headers tfh,
                 hr_all_organization_units org
          where  pbg.business_group_id    = org.business_group_id
            and  org.organization_id = tfh.organization_id
            and  tfh.finance_header_id = p_finance_header_id;


   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'finance_header_id',
                              p_argument_value => p_finance_header_id);
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



end ota_tfh_api_bus;

/
