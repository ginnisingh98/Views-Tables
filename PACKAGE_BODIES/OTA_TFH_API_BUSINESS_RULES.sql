--------------------------------------------------------
--  DDL for Package Body OTA_TFH_API_BUSINESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFH_API_BUSINESS_RULES" as
/* $Header: ottfh02t.pkb 120.2 2006/02/13 01:51:18 sbhullar noship $ */
--
--
-- Global package name
--
g_package		varchar2(33)	:= '  ota_tfh_api_business_rules.';
--
-- Global api dml status
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< check_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   The attributee 'TYPE' must be in the domain of 'Finance Header Type'.
--
Procedure check_type
  (
   p_type  in  varchar2
  ) Is
  --
  v_proc 	varchar2(72) := g_package||'check_type';
  --
Begin
  --
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  If p_type is not null  Then
    --
    ota_general.check_domain_value( 'FINANCE_HEADER_TYPE', p_type);
    --
  Else
    -- column is a not null field **** change message later
    --
   ota_tfh_api_shd.constraint_error( 'OTA_TFH_TYPE_CHK');
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
  --
End check_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_transfer_status >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The attribute 'Transfer Status' must be in the domain of
--    'GL Transfer Status'.
--
Procedure check_transfer_status
  (
   p_transfer_status  in  varchar2
  ) is
  --
  v_proc                 varchar2(72) := g_package||'check_transfer_status';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_transfer_status is not null  Then
    --
    ota_general.check_domain_value( 'GL_TRANSFER_STATUS', p_transfer_status);
    --
  Else
    --
    ota_tfh_api_shd.constraint_error( 'OTA_TFH_TRANSFER_STATUS_CHK');
    --
  End If;
  --
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_transfer_status;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_transfer_rules  >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    The following changes to Transfer Status are allowed
--        NT -> AT
--        AT -> NT
--        UT -> NT
--        UT -> AT
--    When such a change takes place all the lines for the header that
--    have the same Transfer Status should also be changed.
--
--    In addition the following changes are allowed on headers
--        AT -> UT
--        AT -> ST
--        ST -> UT
--
Procedure check_transfer_rules
  (
   p_new_transfer_status     in  varchar2
  ,p_old_transfer_status     in varchar2
  ) is
  --
  v_proc                 varchar2(72) := g_package||'check_transfer_rules';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_new_transfer_status <> p_old_transfer_status and
      ((p_old_transfer_status = 'NT' and p_new_transfer_status = 'AT')
    or (p_old_transfer_status = 'AT' and p_new_transfer_status = 'NT')
    or (p_old_transfer_status = 'UT' and p_new_transfer_status = 'NT')
    or (p_old_transfer_status = 'UT' and p_new_transfer_status = 'AT')
    or (p_old_transfer_status = 'AT' and p_new_transfer_status = 'UT')
    or (p_old_transfer_status = 'ST' and p_new_transfer_status = 'UT')
    or (p_old_transfer_status = 'AT' and p_new_transfer_status = 'ST'))
    then null;
  else
    fnd_message.set_name('OTA','OTA_13414_TFH_TRANS_RULES');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_transfer_rules;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_status_unauthorized >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The transfer status must be 'NT' if the header is not authorised,
--   ie: the authorised_by_person_id is null.
--
Procedure check_status_unauthorized
  (
   p_status                  in  varchar2
  ,p_authorized_person_id    in  number
  ) is
  --
  v_proc                varchar2(72) := g_package||'check_status_unauthorized';
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_authorized_person_id is null  Then
     If p_status <> 'NT'  Then
        fnd_message.set_name('OTA','OTA_13280_TFH_UNAUTHORIZED');
        fnd_message.raise_error;
    End if;
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_status_unauthorized;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_authorized_by >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The authorised_by attribute must be a valid FND_USER
--
Procedure check_authorized_by
  (
   p_person_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_authorized_by';
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_person_id is not null  Then
    If NOT ota_general.check_fnd_user( p_person_id) Then
        fnd_message.set_name('OTA','OTA_13281_TFH_AUTHORIZER');
        fnd_message.raise_error;
    End if;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_authorized_by;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< set_date_raised >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The date_raised attribute must be set to the session date upon
--   creation. This attribute may not be updated.
--
Procedure set_date_raised
  (
   p_date_raised    out nocopy date
  ,p_session_date   in   date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'set_date_raised';
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_session_date is null  Then
     fnd_message.set_name('OTA','OTA_13313_TFH_DATE_RAISED');
     fnd_message.raise_error;
  Else
    p_date_raised  :=  p_session_date;
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End set_date_raised;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_receivable_attributes >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the header is of type 'Receivable' then the following
--   attributes must be NOT NULL:
--   CUSTOMER_CONTACT_ID
--   CUSTOMER_ADDRESS_ID
--   CUSTOMER_ID
--   INVOICE_ADDRESS
--   INVOICE_CONTACT
--   RECEIVABLE_TYPE
--   The following attributes must be NULL:
--   VENDOR_ID
--   VENDOR_CONTACT_ID
--   VENDOR_ADDRESS_ID
--
--
Procedure check_receivable_attributes
  (
   p_type                 in  varchar2
  ,p_customer_id          in  number
  ,p_customer_contact_id  in  number
  ,p_customer_address_id  in  number
  ,p_invoice_address      in  varchar2
  ,p_invoice_contact      in  varchar2
  ,p_vendor_id            in  number
  ,p_vendor_contact_id    in  number
  ,p_vendor_address_id    in  number
  ,p_receivable_type      in  varchar2
  ) is
  --
  v_proc        varchar2(72) := g_package||'check_receivable_attributes';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_type = 'R'  Then
    --
    If p_customer_id         is     null  OR
       p_customer_contact_id is     null  OR
       p_customer_address_id is     null  OR
       p_invoice_address     is     null  OR
       p_invoice_contact     is     null  OR
       p_receivable_type     is     null  OR
       p_vendor_id           is NOT null  OR
       p_vendor_contact_id   is NOT null  OR
       p_vendor_address_id   is NOT null  Then
      --
      ota_tfh_api_shd.constraint_error( 'OTA_TFH_RECEIVABLE_ATTRIBUTES');
      --
    End if;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_receivable_attributes;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_customer_contact >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The customer_contact_id must be for the same customer as defined on the
--   header in the attribute customer_id, if the header is receivable .
--
Procedure check_customer_contact
  (
   p_customer_id  in  number
  ,p_contact_id   in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_customer_contact';
  --
  cursor sel_customer_contact is
    select 'Y'
      from ota_customer_contacts_v   con
     where con.customer_id           =    p_customer_id
       and con.contact_id            =    p_contact_id;
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_contact_id is NOT null  AND  p_customer_id is NOT null  Then
    Open  sel_customer_contact;
    fetch sel_customer_contact into v_exists;
    --
    if sel_customer_contact%notfound then
      close sel_customer_contact;
      fnd_message.set_name('OTA','OTA_13283_TFH_CUSTOMER_CONTACT');
      fnd_message.raise_error;
    end if;
    --
    close sel_customer_contact;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_customer_contact;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_customer_address >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The customer_address_id must be for the same customer as defined
--   on the header in the attribute customer_id, if the header is receivable.
--
Procedure check_customer_address
  (
   p_customer_id  in  number
  ,p_address_id   in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_customer_address';
  --
  cursor sel_customer_address is
    select 'Y'
      from ota_customer_addresses_v  adr
     where adr.customer_id           =    p_customer_id
       and adr.address_id            =    p_address_id;
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_address_id is NOT null  AND  p_customer_id is NOT null  Then
    Open  sel_customer_address;
    fetch sel_customer_address into v_exists;
    --
    if sel_customer_address%notfound then
      close sel_customer_address;
      fnd_message.set_name('OTA','OTA_13284_TFH_CUSTOMER_ADDRESS');
      fnd_message.raise_error;
    end if;
    --
    close sel_customer_address;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_customer_address;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_invoice_address >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Upon insert of a receivable header the address attributes must be
--   concatenated together in the invoice_address attribute. This must
--   be reset if the customer_address_id is changed. This changed must
--   then obey the change rules defined in the business rules. If the
--   header has been transfered, then a cancel and recreate would have
--   to be performed.
--
Procedure set_invoice_address
  (
   p_customer_id      in   number
  ,p_address_id       in   number
  ,p_invoice_address  out  nocopy varchar2
  ) is
  --
  v_address               varchar2(2000);
  v_proc                  varchar2(72) := g_package||'set_invoice_address';
  --
  cursor sel_invoice_address is
    select adr.address
      from ota_customer_addresses_v  adr
     where adr.customer_id           =    p_customer_id
       and adr.address_id            =    p_address_id;
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_address_id is NOT null  AND  p_customer_id is NOT null  Then
    Open  sel_invoice_address;
    fetch sel_invoice_address into v_address;
    --
    if sel_invoice_address%notfound then
      close sel_invoice_address;
      fnd_message.set_name('OTA','OTA_13284_TFH_CUSTOMER_ADDRESS');
      fnd_message.raise_error;
    end if;
    --
    p_invoice_address :=  v_address;
    --
    close sel_invoice_address;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End set_invoice_address;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_invoice_contact >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure set_invoice_contact
  (
   p_customer_id      in   number
  ,p_contact_id       in   number
  ,p_invoice_contact  out  nocopy varchar2
  ) is
  --
  v_contact               varchar2(2000);
  v_proc                  varchar2(72) := g_package||'set_invoice_contact';
  --
  cursor sel_invoice_contact is
    select con.full_name
      from ota_customer_contacts_v   con
     where con.customer_id           =    p_customer_id
       and con.contact_id            =    p_contact_id;
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_contact_id is NOT null  AND  p_customer_id is NOT null  Then
    Open  sel_invoice_contact;
    fetch sel_invoice_contact into v_contact;
    --
    if sel_invoice_contact%notfound then
      close sel_invoice_contact;
        fnd_message.set_name('OTA','OTA_13283_TFH_CUSTOMER_CONTACT');
        fnd_message.raise_error;
    end if;
    --
    p_invoice_contact :=  v_contact;
    --
    close sel_invoice_contact;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End set_invoice_contact;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_vendor_contact >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The vendor_contact must be a valid contact for the vendor defined in
--   vendor_id on the header, if the header is 'Payable'.
--
Procedure check_vendor_contact
  (
   p_vendor_id    in  number
  ,p_contact_id   in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_vendor_contact';
  --
  --Bug 4924448
  cursor sel_vendor_contact is
	select 'Y'
	from AP_SUPPLIERS PAV,
	     HZ_PARTIES HP,
	     AP_SUPPLIER_CONTACTS PVC
	where PAV.vendor_id              =    p_vendor_id
	      and PVC.VENDOR_CONTACT_ID  =    p_contact_id
	      and PAV.PARTY_ID = HP.PARTY_ID;

  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_contact_id is NOT null  AND  p_vendor_id is NOT null  Then
    Open  sel_vendor_contact;
    fetch sel_vendor_contact into v_exists;
    --
    if sel_vendor_contact%notfound then
      close sel_vendor_contact;
      fnd_message.set_name('OTA','OTA_13285_TFH_VENDOR_CONTACT');
      fnd_message.raise_error;
    end if;
    --
    close sel_vendor_contact;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_vendor_contact;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_vendor_address >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The vendor_address must be a valid address for the vendor defined
--   in VENDOR_ID on the header.
--
Procedure check_vendor_address
  (
   p_vendor_id    in  number
  ,p_address_id   in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_vendor_address';
  --
  cursor sel_vendor_address is
    select 'Y'
      from ota_vendor_addresses_v    adr
     where adr.vendor_id             =    p_vendor_id
       and adr.vendor_site_id        =    p_address_id;
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_address_id is NOT null  AND  p_vendor_id is NOT null  Then
    Open  sel_vendor_address;
    fetch sel_vendor_address into v_exists;
    --
    if sel_vendor_address%notfound then
      close sel_vendor_address;
      fnd_message.set_name('OTA','OTA_13286_TFH_VENDOR_ADDRESS');
      fnd_message.raise_error;
    end if;
    --
    close sel_vendor_address;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_vendor_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_payable_attributes >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the header is of type 'Payable' then the following
--   attributes must be NOT NULL:
--   VENDOR_CONTACT_ID
--   VENDOR_ADDRESS_ID
--   VENDOR_ID
--   The following attributes must be NULL:
--   CUSTOMER_CONTACT_ID
--   CUSTOMER_ADDRESS_ID
--   CUSTOMER_ID
--   RECEIVABLE_TYPE
--
--
Procedure check_payable_attributes
  (
   p_type                 in  varchar2
  ,p_vendor_id            in  number
  ,p_vendor_contact_id    in  number
  ,p_vendor_address_id    in  number
  ,p_invoice_contact      in  varchar2
  ,p_invoice_address      in  varchar2
  ,p_customer_id          in  number
  ,p_customer_contact_id  in  number
  ,p_customer_address_id  in  number
  ,p_receivable_type      in  varchar2
  ) is
  --
  v_proc        varchar2(72) := g_package||'check_payable_attributes';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_type like 'P'  Then
    --
    If p_vendor_id           is     null  OR
       p_vendor_contact_id   is     null  OR
       p_vendor_address_id   is     null  OR
       p_receivable_type     is NOT null  OR
       p_customer_id         is NOT null  OR
       p_customer_contact_id is NOT null  OR
       p_customer_address_id is NOT null  Then
      --
      ota_tfh_api_shd.constraint_error( 'OTA_TFH_PAYABLE_ATTRIBUTES');
      --
    End if;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_payable_attributes;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_cancelled_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The cancelled_flag attribute must be in the domain 'Yes No'.
--
Procedure check_cancelled_flag
  (
   p_flag  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_cancelled_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If NOT (p_flag in ('N', 'Y')) then
    --
    ota_tfh_api_shd.constraint_error( 'OTA_TFH_CANCELLED_FLAG_CHK');
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_cancelled_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< finance_lines_exist >---------------------------|
-- ----------------------------------------------------------------------------
-- PRIVATE
--   A private function to return true or false to indicate whether
--   finance lines exist for this header_id
--
Function finance_lines_exist
    (
     p_finance_header_id in number
    )
    return boolean
    is
    --
   cursor get_finance_line is
   select 'Exists'
   from   ota_finance_lines
   where  finance_header_id = p_finance_header_id;
   --
    v_finance_line_exists varchar2(30);
  v_proc                  varchar2(72) := g_package||'finance_lines_exist';
    --
Begin
  hr_utility.set_location(' Leaving:'|| v_proc, 5);
   --
   open get_finance_line;
   fetch get_finance_line into v_finance_line_exists;
   if get_finance_line%found then
      close get_finance_line;
      hr_utility.trace('Finance Lines Found');
      return TRUE;
   else
      close get_finance_line;
      hr_utility.trace('Finance Lines not Found');
      return FALSE;
   end if;
   --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End finance_lines_exist;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< cancel_header >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- OVERLOADING PROCEDURE
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to cancel. This sets the cancelled_flag
--   to 'Y' and creates a cancellation header with the old header_id on
--   the new cancellation header in the supersedes_header_id attribute.
--   The procedure 'CANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure cancel_header
  (
   p_rec_finance         in out   nocopy ota_tfh_api_shd.g_rec_type
  ,p_cancel_header_id       out   nocopy number
  ,p_date_raised         in       date
  ,p_validate            in       boolean
  ) is
  --
  l_rec_cancel           ota_tfh_api_shd.g_rec_type;
  v_proc                 varchar2(72) := g_package||'cancel_header';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- * Finance Header has already been cancelled
  --
  If p_rec_finance.cancelled_flag  = 'Y'  Then
    --
    fnd_message.set_name('OTA','OTA_13486_TFH_CANCEL_HEADER2');
    fnd_message.set_token('STEP','1');
    fnd_message.raise_error;
  --
  -- * Finance Header is type CANCELLATION
  --
  ElsIf  p_rec_finance.type   = 'C'  Then
    --
    fnd_message.set_name('OTA','OTA_13486_TFH_CANCEL_HEADER2');
    fnd_message.set_token('STEP','2');
    fnd_message.raise_error;
    --
  Else
    --
    -- * The Finance Line for cancelling has been transfered
    --
    If p_rec_finance.transfer_status = 'ST'  Then
      --
      l_rec_cancel.type                   :=  'C';
      l_rec_cancel.finance_header_id      :=  null;
      l_rec_cancel.superceding_header_id  :=  p_rec_finance.finance_header_id;
      l_rec_cancel.organization_id        :=  p_rec_finance.organization_id;
      l_rec_cancel.administrator          :=  p_rec_finance.administrator;
      l_rec_cancel.cancelled_flag         :=  'N';
      l_rec_cancel.currency_code          :=  p_rec_finance.currency_code;
      l_rec_cancel.payment_status_flag    :=  'N';
      l_rec_cancel.transfer_status        :=  'NT';
      l_rec_cancel.date_raised            :=  p_date_raised;
      l_rec_cancel.payment_method         :=  p_rec_finance.payment_method;
      l_rec_cancel.pym_attribute1         :=  p_rec_finance.pym_attribute1;
      l_rec_cancel.pym_attribute2         :=  p_rec_finance.pym_attribute2;
      l_rec_cancel.pym_attribute3         :=  p_rec_finance.pym_attribute3;
      l_rec_cancel.pym_attribute4         :=  p_rec_finance.pym_attribute4;
      l_rec_cancel.pym_attribute5         :=  p_rec_finance.pym_attribute5;
      l_rec_cancel.pym_attribute6         :=  p_rec_finance.pym_attribute6;
      l_rec_cancel.pym_attribute7         :=  p_rec_finance.pym_attribute7;
      l_rec_cancel.pym_attribute8         :=  p_rec_finance.pym_attribute8;
      l_rec_cancel.pym_attribute9         :=  p_rec_finance.pym_attribute9;
      l_rec_cancel.pym_attribute10        :=  p_rec_finance.pym_attribute10;
      l_rec_cancel.pym_attribute11        :=  p_rec_finance.pym_attribute11;
      l_rec_cancel.pym_attribute12        :=  p_rec_finance.pym_attribute12;
      l_rec_cancel.pym_attribute13        :=  p_rec_finance.pym_attribute13;
      l_rec_cancel.pym_attribute14        :=  p_rec_finance.pym_attribute14;
      l_rec_cancel.pym_attribute15        :=  p_rec_finance.pym_attribute15;
      l_rec_cancel.pym_attribute16        :=  p_rec_finance.pym_attribute16;
      l_rec_cancel.pym_attribute17        :=  p_rec_finance.pym_attribute17;
      l_rec_cancel.pym_attribute18        :=  p_rec_finance.pym_attribute18;
      l_rec_cancel.pym_attribute19        :=  p_rec_finance.pym_attribute19;
      l_rec_cancel.pym_attribute20        :=  p_rec_finance.pym_attribute20;
      l_rec_cancel.pym_information_category :=
                         p_rec_finance.pym_information_category;
 --
      -- * Create a new Finance Header of type Cancellation
      --
      ota_tfh_api_ins.ins
                     ( P_rec                 =>   l_rec_cancel
                     , P_validate            =>   false
                     , P_transaction_type    =>   'CREATE_CANCELLATION');
      --
      p_cancel_header_id := l_rec_cancel.finance_header_id;
      --
    Else
      --
      p_cancel_header_id := null;
      --
    End if;
    --
    -- * Set the cancel flag and update the original Finance Header
    --
    p_rec_finance.cancelled_flag        :=  'Y';
    --
    If p_validate = false  Then
      --
      ota_tfh_api_upd.upd
                     ( P_rec                 =>   p_rec_finance
                     , P_validate            =>   false
                     , P_transaction_type    =>   'CANCEL_HEADER');
      --
    End if;
    --
    -- * Cancellation of the Header Lines should only be called if
    --   finance lines exist for this header.
    --
    if finance_lines_exist(p_rec_finance.finance_header_id) then
          ota_tfl_api_business_rules2.set_cancel_flag_for_header
                    ( p_finance_header_id  => p_rec_finance.finance_header_id
                    , p_new_cancelled_flag => 'Y');
    end if;
    --
    p_cancel_header_id  :=  l_rec_cancel.finance_header_id;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End cancel_header;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< cancel_header >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- OVERLOADING PROCEDURE
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to cancel. This sets the cancelled_flag
--   to 'Y' and creates a cancellation header with the old header_id on
--   the new cancellation header in the supersedes_header_id attribute.
--   The procedure 'CANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure cancel_header
  (
   p_finance_header_id     in   number
  ,p_cancel_header_id      out  nocopy number
  ,p_date_raised           in   date
  ,p_validate              in   boolean
  ,p_commit                in   boolean default FALSE
  ) is
  --
  l_rec_cancel           ota_tfh_api_shd.g_rec_type;
  v_proc                 varchar2(72) := g_package||'cancel_header';
  --
  cursor sel_finance_header is
    select 	finance_header_id,
	superceding_header_id,
	authorizer_person_id,
	organization_id,
	administrator,
	cancelled_flag,
	currency_code,
	date_raised,
	object_version_number,
	payment_status_flag,
	transfer_status,
	type,
        receivable_type,
	comments,
	external_reference,
	invoice_address,
	invoice_contact,
	payment_method,
	pym_attribute1,
	pym_attribute10,
	pym_attribute11,
	pym_attribute12,
	pym_attribute13,
	pym_attribute14,
	pym_attribute15,
	pym_attribute16,
	pym_attribute17,
	pym_attribute18,
	pym_attribute19,
	pym_attribute2,
	pym_attribute20,
	pym_attribute3,
	pym_attribute4,
	pym_attribute5,
	pym_attribute6,
	pym_attribute7,
	pym_attribute8,
	pym_attribute9,
	pym_information_category,
	transfer_date,
	transfer_message,
	vendor_id,
	contact_id,
	address_id,
	customer_id,
	tfh_information_category,
	tfh_information1,
	tfh_information2,
	tfh_information3,
	tfh_information4,
	tfh_information5,
	tfh_information6,
	tfh_information7,
	tfh_information8,
	tfh_information9,
	tfh_information10,
	tfh_information11,
	tfh_information12,
	tfh_information13,
	tfh_information14,
	tfh_information15,
	tfh_information16,
	tfh_information17,
	tfh_information18,
	tfh_information19,
	tfh_information20,
      paying_cost_center,
      receiving_cost_center,
      transfer_from_set_of_books_id,
      transfer_to_set_of_books_id,
      from_segment1,
      from_segment2,
      from_segment3,
      from_segment4,
      from_segment5,
      from_segment6,
      from_segment7,
      from_segment8,
      from_segment9,
      from_segment10,
	from_segment11,
      from_segment12,
      from_segment13,
      from_segment14,
      from_segment15,
      from_segment16,
      from_segment17,
      from_segment18,
      from_segment19,
      from_segment20,
      from_segment21,
      from_segment22,
      from_segment23,
      from_segment24,
      from_segment25,
      from_segment26,
      from_segment27,
      from_segment28,
      from_segment29,
      from_segment30,
      to_segment1,
      to_segment2,
      to_segment3,
      to_segment4,
      to_segment5,
      to_segment6,
      to_segment7,
      to_segment8,
      to_segment9,
      to_segment10,
	to_segment11,
      to_segment12,
      to_segment13,
      to_segment14,
      to_segment15,
      to_segment16,
      to_segment17,
      to_segment18,
      to_segment19,
      to_segment20,
      to_segment21,
      to_segment22,
      to_segment23,
      to_segment24,
      to_segment25,
      to_segment26,
      to_segment27,
      to_segment28,
      to_segment29,
      to_segment30,
      transfer_from_cc_id,
      transfer_to_cc_id
    from	ota_finance_headers
    where	finance_header_id = p_finance_header_id ;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is NOT null  Then
    --
    Open  sel_finance_header;
    Fetch sel_finance_header into l_rec_cancel;
    --
    If sel_finance_header%notfound then
      Close sel_finance_header;
      fnd_message.set_name('OTA','OTA_13486_TFH_CANCEL_HEADER2');
      fnd_message.set_token('STEP','3');
      fnd_message.raise_error;
      --
    End if;
    --
    Close sel_finance_header;
   End if;
  --
  -- Call the overloaded procedure passing the Record Group
  --
  cancel_header(l_rec_cancel
               ,p_cancel_header_id
               ,p_date_raised
               ,p_validate);
  --
  if p_commit then
     commit;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End cancel_header;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_superceding >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
--   Checks whether a finance_header is used as a superceding header.
--
Procedure check_superceding
  (
   p_finance_header_id     in  number
  ) is
  --
  v_exists           varchar2(1);
  v_proc             varchar2(72) := g_package||'check_superceding';
  --
  cursor sel_for_deletion is
    select 'Y'
      from ota_finance_headers        tfh
     where tfh.superceding_header_id  =    p_finance_header_id;
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_for_deletion;
  Fetch sel_for_deletion into v_exists;
  --
  If sel_for_deletion%found then
    close sel_for_deletion;
    fnd_message.set_name('OTA','OTA_13323_TFH_DELETION');
    fnd_message.raise_error;
  End if;
  --
  close sel_for_deletion;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_superceding;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< recancel_header >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to cancel. This sets the cancelled_flag
--   to 'N' and creates a cancellation header with the old header_id on
--   the new cancellation header in the supersedes_header_id attribute.
--   The procedure 'RECANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure recancel_header
  (
   p_finance_header_id     in   number
  ,p_validate              in   boolean
  ,p_commit                in   boolean default FALSE
  ) is
  --
  v_rec_header           ota_finance_headers%rowtype;
  l_rec_cancel           ota_tfh_api_shd.g_rec_type;
  v_proc                 varchar2(72) := g_package||'recancel_header';
  --
  cursor sel_finance_header is
    select *
      from ota_finance_headers        tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is NOT null  Then
    Open  sel_finance_header;
    Fetch sel_finance_header into v_rec_header;
    --
    If sel_finance_header%notfound then
      Close sel_finance_header;
      fnd_message.set_name('OTA','OTA_13487_TFH_REINST_HEADER');
      fnd_message.set_token('STEP','3');
      fnd_message.raise_error;
    End if;
    --
    Close sel_finance_header;
    --
    -- * Finance Header has already been cancelled
    --
    If v_rec_header.cancelled_flag  = 'N'  Then
      fnd_message.set_name('OTA','OTA_13487_TFH_REINST_HEADER');
      fnd_message.set_token('STEP','1');
      fnd_message.raise_error;
    --
    -- * Finance Header of type CANCELLATION
    --
    ElsIf  v_rec_header.type   = 'C'  Then
      fnd_message.set_name('OTA','OTA_13487_TFH_REINST_HEADER');
      fnd_message.set_token('STEP','2');
      fnd_message.raise_error;
    Else
      --
      -- * Checks whether the Finance Header is superceded by another one
      --   or not
      --
      check_superceding( p_finance_header_id);
      --
      -- * Re-Set the cancel flag and update the original Finance Header
      --
      v_rec_header.cancelled_flag        :=  'N';
      --
      If p_validate = false  Then
        --
        ota_tfh_api_upd.upd
                ( p_finance_header_id => v_rec_header.finance_header_id
                , p_cancelled_flag    => v_rec_header.cancelled_flag
                , p_object_version_number => v_rec_header.object_version_number
                , P_validate            =>   false
                , P_transaction_type    =>   'REINSTATE_HEADER');
        --
      End if;
      --
      -- * Re-Cancellation of the Header Lines should only be attempted
      --   if finance lines exist
      --
      if finance_lines_exist(v_rec_header.finance_header_id) then
            ota_tfl_api_business_rules2.set_cancel_flag_for_header
                     ( p_finance_header_id  => v_rec_header.finance_header_id
                     , p_new_cancelled_flag => 'N'   );
      end if;
      --
    End if;
    --
  End if;
  --
  if p_commit then
     commit;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End recancel_header;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_cancellation_attributes >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the header is of type 'Cancellation' then the following
--   attributes must be NOT NULL:
--   SUPERSEDES_HEADER_ID
--   The following attributes must be NULL:
--   CUSTOMER_CONTACT_ID
--   CUSTOMER_ADDRESS_ID
--   CUSTOMER_ID
--   INVOICE_ADDRESS
--   INVOICE_CONTACT
--   VENDOR_ID
--   VENDOR_CONTACT_ID
--   VENDOR_ADDRESS_ID
--   PAYMENT_METHOD
--   RECEIVABLE_TYPE
--
--
Procedure check_cancellation_attributes
  (
   p_type                 in  varchar2
  ,p_supersedes_header_id in  number
  ,p_customer_id          in  number
  ,p_customer_contact_id  in  number
  ,p_customer_address_id  in  number
  ,p_invoice_address      in  varchar2
  ,p_invoice_contact      in  varchar2
  ,p_vendor_id            in  number
  ,p_vendor_contact_id    in  number
  ,p_vendor_address_id    in  number
  ,p_payment_method       in  varchar2
  ,p_receivable_type      in  varchar2
  ) is
  --
  v_proc        varchar2(72) := g_package||'check_cancellation_attributes';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_type = 'C' Then
    --
    If p_supersedes_header_id is     null   OR
       p_vendor_id            is NOT null   OR
       p_receivable_type      is NOT null   OR
       p_vendor_contact_id    is NOT null   OR
       p_vendor_address_id    is NOT null   OR
       p_customer_id          is NOT null   OR
       p_customer_contact_id  is NOT null   OR
       p_customer_address_id  is NOT null   OR
       p_invoice_address      is NOT null   OR
       p_invoice_contact      is NOT null   Then
      --
      ota_tfh_api_shd.constraint_error( 'OTA_TFH_CANCELLED_ATTRIBUTES');
      --
    End if;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_cancellation_attributes;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_superseded_header >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   For a cancellation header the superseded_header_id must be a valid
--   finance header.
--
Procedure check_superseded_header
  (
   p_finance_type             in  varchar2
  ,p_superseding_header_id    in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_superseded_header';
  --
  cursor sel_superseding_header is
    select 'Y'
      from ota_finance_headers       tfh
     where tfh.finance_header_id  =  p_superseding_header_id;
  --
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_type = 'C'  Then
    --
    If p_superseding_header_id is NOT null  Then
      Open  sel_superseding_header;
      fetch sel_superseding_header into v_exists;
      --
      if sel_superseding_header%notfound then
        close sel_superseding_header;
        fnd_message.set_name('OTA','OTA_13287_TFH_SUPERSEDED_HEAD');
        fnd_message.raise_error;
      end if;
      --
      close sel_superseding_header;
      --
    Else
        fnd_message.set_name('OTA','OTA_13287_TFH_SUPERSEDED_HEAD');
        fnd_message.raise_error;
    End if;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_superseded_header;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_update_customer_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Reference information check, if the customer_id is changed
--
Procedure check_update_customer_id
  (
   p_customer_id              in  number
  ,p_address_id               in  number
  ,p_contact_id               in  number
  ,p_vendor_id                in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_update_customer_id';
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_customer_id is NOT null  AND  p_vendor_id is NOT null  Then
     fnd_message.set_name('OTA','OTA_13324_TFH_CUSTOMER_VENDOR');
     fnd_message.raise_error;
    --
  ElsIf p_customer_id is NOT null  Then
    --
    -- Reference check Customer and Address
    --
    check_customer_address( p_customer_id
                          , p_address_id );
    --
    -- Reference check Customer and Contact
    --
    check_customer_contact( p_customer_id
                          , p_contact_id );
    --
  ElsIf p_vendor_id  is     null  AND
       (p_address_id is NOT null  OR  p_contact_id is NOT null)  Then
    --
    fnd_message.set_name('OTA','OTA_13321_TFH_CUSTOMER_NAME');
    fnd_message.raise_error;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_update_customer_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_update_vendor_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Reference information check, if the customer_id is changed
--
Procedure check_update_vendor_id
  (
   p_vendor_id                in  number
  ,p_address_id               in  number
  ,p_contact_id               in  number
  ,p_customer_id              in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_update_vendor_id';
  --
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_vendor_id is NOT null  AND  p_customer_id is NOT null  Then
    fnd_message.set_name('OTA','OTA_13324_TFH_CUSTOMER_VENDOR');
    fnd_message.raise_error;
  ElsIf p_vendor_id is NOT null  Then
    --
    -- Reference check Vendor and Address
    --
    check_vendor_address( p_vendor_id
                        , p_address_id );
    --
    -- Reference check Vendor and Contact
    --
    check_vendor_contact( p_vendor_id
                        , p_contact_id );
    --
  ElsIf p_customer_id  is     null  AND
       (p_address_id is NOT null  OR  p_contact_id is NOT null)  Then
    --
    fnd_message.set_name('OTA','OTA_13322_TFH_VENDOR_NAME');
    fnd_message.raise_error;
  End if;
  --
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_update_vendor_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_and_recreate >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   An API procedure is required to cancel a header and create a new
--   header in its place. This procedure will create a new header, which
--   supersedes the one which is to be cancelled. The procedure
--   'COPY_LINES_TO_NEW_HEADER', found in the lines API, will then be called.
--   The old finance header will then be cancelled by using the 'CANCEL_HEADER'
--   procedure. The TRANSFER_STATUS on the newly created header must be set to
--   'N' by default.
--
Procedure cancel_and_recreate
  (
   p_rec_finance         in out   nocopy ota_tfh_api_shd.g_rec_type
  ,p_date_raised         in       date
  ,p_validate            in       boolean
  ) is
  --
  l_rec_new              ota_tfh_api_shd.g_rec_type;
  l_cancel_header_id     number;
  v_proc                 varchar2(72) := g_package||'cancel_and_recreate';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- * Finance Header has already been cancelled
  --
  If p_rec_finance.cancelled_flag  = 'Y'  Then
    --
    fnd_message.set_name('OTA','OTA_13315_TFH_CANCEL_HEADER');
    fnd_message.set_token('STEP','1');
    fnd_message.raise_error;
  --
  -- * Finance Header is type CANCELLATION
  --
  ElsIf  p_rec_finance.type   = 'C'  Then
    --
    fnd_message.set_name('OTA','OTA_13315_TFH_CANCEL_HEADER');
    fnd_message.set_token('STEP','2');
    fnd_message.raise_error;
  --
  -- * The Finance Header for cancelling and recreating must be transfered
  --
  ElsIf  p_rec_finance.transfer_status   <> 'ST'  Then
    --
    fnd_message.set_name('OTA','OTA_13315_TFH_CANCEL_HEADER');
    fnd_message.set_token('STEP','3');
    fnd_message.raise_error;
    --
  Else
    --
    l_rec_new  :=  p_rec_finance;
    --
    l_rec_new.finance_header_id      :=  null;
    l_rec_new.transfer_status        :=  'NT';
    l_rec_new.transfer_date          :=  null;
    l_rec_new.transfer_message       :=  null;
    l_rec_new.external_reference     :=  null;
    l_rec_new.comments               :=  null;
    l_rec_new.date_raised            :=  p_date_raised;
    --
    l_cancel_header_id               :=  null;
    --
    -- * Create a new Finance Header for the original Finance Header
    --   which is a direct copy of the old. This new header, with
    --   copied lines too, will supersede the cancelled header.
    --
    l_rec_new.superceding_header_id  :=  p_rec_finance.finance_header_id;
    --
    ota_tfh_api_ins.ins
                   ( P_rec                 =>   l_rec_new
                   , P_validate            =>   false
                   , P_transaction_type    =>   'RECREATE_HEADER');
    --
    -- * Now copy all non-cancelled lines and link them to the new
    --   header
    --
    ota_tfl_api_business_rules2.copy_lines_to_new_header
                                    ( p_rec_finance.finance_header_id
                                    , l_rec_new.finance_header_id );
    --
    -- Cancel the original Finance Header and create a new Finance Header of
    -- type Cancellation with it's Finance Header Lines. Set the cancelled
    -- flag of the original Finance Header.
    --
    cancel_header( P_rec_finance       =>   p_rec_finance
                 , P_cancel_header_id  =>   l_cancel_header_id
                 , P_date_raised       =>   p_date_raised
                 , P_validate          =>   p_validate  );
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End cancel_and_recreate;
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_and_recreate >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   An API procedure is required to cancel a header and create a new
--   header in its place. This procedure will create a new header, which
--   supersedes the one which is to be cancelled. The procedure
--   'COPY_LINES_TO_NEW_HEADER', found in the lines API, will then be called.
--   The old finance header will then be cancelled by using the 'CANCEL_HEADER'
--   procedure. The TRANSFER_STATUS on the newly created header must be set to
--   'N' by default.
--
Procedure cancel_and_recreate
  (
   p_finance_header_id           in    number
  ,p_recreation_header_id        out  nocopy  number
  ,p_cancel_header_id            out  nocopy  number
  ,p_date_raised                 in    date
  ,p_validate                    in    boolean
  ,p_commit              in       boolean default FALSE
  ) is
  --
  v_rec_header               ota_tfh_api_shd.g_rec_type;
  v_cursor_boolean           boolean;
  v_validate                 boolean;
  v_date_raised              date;
  v_proc                     varchar2(72) := g_package||'cancel_and_recreate';
  --
  cursor sel_finance_header is
    select finance_header_id
    ,      superceding_header_id
    ,      authorizer_person_id
    ,      organization_id
    ,      administrator
    ,      cancelled_flag
    ,      currency_code
    ,      date_raised
    ,      object_version_number
    ,      payment_status_flag
    ,      transfer_status
    ,      type
    ,      receivable_type
    ,      comments
    ,      external_reference
    ,      invoice_address
    ,      invoice_contact
    ,      payment_method
    ,      pym_attribute1
    ,      pym_attribute10
    ,      pym_attribute11
    ,      pym_attribute12
    ,      pym_attribute13
    ,      pym_attribute14
    ,      pym_attribute15
    ,      pym_attribute16
    ,      pym_attribute17
    ,      pym_attribute18
    ,      pym_attribute19
    ,      pym_attribute2
    ,      pym_attribute20
    ,      pym_attribute3
    ,      pym_attribute4
    ,      pym_attribute5
    ,      pym_attribute6
    ,      pym_attribute7
    ,      pym_attribute8
    ,      pym_attribute9
    ,      pym_information_category
    ,      transfer_date
    ,      transfer_message
    ,      vendor_id
    ,      contact_id
    ,      address_id
    ,      customer_id
    ,      tfh_information_category
    ,      tfh_information1
    ,      tfh_information2
    ,      tfh_information3
    ,      tfh_information4
    ,      tfh_information5
    ,      tfh_information6
    ,      tfh_information7
    ,      tfh_information8
    ,      tfh_information9
    ,      tfh_information10
    ,      tfh_information11
    ,      tfh_information12
    ,      tfh_information13
    ,      tfh_information14
    ,      tfh_information15
    ,      tfh_information16
    ,      tfh_information17
    ,      tfh_information18
    ,      tfh_information19
    ,      tfh_information20
    ,      paying_cost_center
    ,      receiving_cost_center
    ,      transfer_from_set_of_books_id
    ,      transfer_to_set_of_books_id
    ,  from_segment1
    ,  from_segment2
    ,  from_segment3
    ,  from_segment4
    ,  from_segment5
    ,  from_segment6
    ,  from_segment7
    ,  from_segment8
    ,  from_segment9
    ,  from_segment10
    ,  from_segment11
    ,  from_segment12
    ,  from_segment13
    ,  from_segment14
    ,  from_segment15
    ,  from_segment16
    ,  from_segment17
    ,  from_segment18
    ,  from_segment19
    ,  from_segment20
    ,  from_segment21
    ,  from_segment22
    ,  from_segment23
    ,  from_segment24
    ,  from_segment25
    ,  from_segment26
    ,  from_segment27
    ,  from_segment28
    ,  from_segment29
    ,  from_segment30
    ,  to_segment1
    ,  to_segment2
    ,  to_segment3
    ,  to_segment4
    ,  to_segment5
    ,  to_segment6
    ,  to_segment7
    ,  to_segment8
    ,  to_segment9
    ,  to_segment10
    ,	 to_segment11
    ,  to_segment12
    ,  to_segment13
    ,  to_segment14
    ,  to_segment15
    ,  to_segment16
    ,  to_segment17
    ,  to_segment18
    ,  to_segment19
    ,  to_segment20
    ,  to_segment21
    ,  to_segment22
    ,  to_segment23
    ,  to_segment24
    ,  to_segment25
    ,  to_segment26
    ,  to_segment27
    ,  to_segment28
    ,  to_segment29
    ,  to_segment30
    ,  transfer_from_cc_id
    ,  transfer_to_cc_id
    from   ota_finance_headers tfh
    where  tfh.finance_header_id = p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is NOT null then
    --
    --Concert the HEADER_ID into a record by selecting the full
    --row into a record structure.
    --
    Open  sel_finance_header;
    Fetch sel_finance_header into v_rec_header;
    --
    v_validate := p_validate;
    v_date_raised := p_date_raised;
    --
    v_cursor_boolean := sel_finance_header%notfound;
    --
    close sel_finance_header;
    --
    If v_cursor_boolean then --the header_id was invalid and no rows returned
      --
      fnd_message.set_name('OTA','OTA_13315_TFH_CANCEL_HEADER');
      fnd_message.set_token('STEP','4');
      fnd_message.raise_error;
      --
    End if; --end check for cursor returning no rows.
    --
    ota_tfh_api_business_rules.cancel_and_recreate
    (p_rec_finance => v_rec_header
    ,p_date_raised => v_date_raised
    ,p_validate    => v_validate
    );
  --
  End if; --end check of null header_id
  --
  if p_commit then
     commit;
  end if;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End cancel_and_recreate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_payment_method >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The PAYMENT_METHOD attribute must be in the domain 'Payment Method'.
--
Procedure check_payment_method
  (
   p_payment_method  in  varchar2
  ) is
  --
  v_proc                 varchar2(72) := g_package||'check_payment_method';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_payment_method is not null  Then
    --
    ota_general.check_domain_value( 'PAYMENT_METHOD', p_payment_method);
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_payment_method;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_allow_transfer >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the TRANSFER_STATUS attribute is any other value than 'NT' the
--   PAYMENT_METHOD attribute must be NOT NULL.
--
Procedure check_allow_transfer
  (
   p_transfer_status in  varchar2
  ,p_payment_method  in  varchar2
  ) is
  --
  v_proc                 varchar2(72) := g_package||'check_allow_transfer';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_transfer_status <> 'NT' Then
    --
    If p_payment_method is null  Then
      --
      ota_tfh_api_shd.constraint_error( 'OTA_TFH_CHECK_TRANSFER_ATTRIBUTES');
      --
    End if;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_allow_transfer;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_update01_header >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Function check_update01_header
  (
   p_rec_old             in  ota_tfh_api_shd.g_rec_type
  ,p_rec_new             in  ota_tfh_api_shd.g_rec_type
  ) Return Boolean is
  --
  v_proc                 varchar2(72) := g_package||'check_update01_header';
  --
  l_super_header_id_changed   boolean
    := ota_general.value_changed( p_rec_old.superceding_header_id
                                , p_rec_new.superceding_header_id );
  --
  l_authorizer_person_id_changed   boolean
    := ota_general.value_changed( p_rec_old.authorizer_person_id
                                , p_rec_new.authorizer_person_id );
  --
  l_organization_id_changed   boolean
    := ota_general.value_changed( p_rec_old.organization_id
                                , p_rec_new.organization_id  );
  --
  l_administrator_changed   boolean
    := ota_general.value_changed( p_rec_old.administrator
                                , p_rec_new.administrator  );
  --
  l_cancelled_flag_changed   boolean
    := ota_general.value_changed( p_rec_old.cancelled_flag
                                , p_rec_new.cancelled_flag  );
  --
  l_currency_code_changed   boolean
    := ota_general.value_changed( p_rec_old.currency_code
                                , p_rec_new.currency_code  );
  --
  l_date_raised_changed   boolean
    := ota_general.value_changed( p_rec_old.date_raised
                                , p_rec_new.date_raised  );
  --
  l_transfer_status_changed   boolean
    := ota_general.value_changed( p_rec_old.transfer_status
                                , p_rec_new.transfer_status  );
  --
  l_type_changed   boolean
    := ota_general.value_changed( p_rec_old.type
                                , p_rec_new.type  );
  --
  l_comments_changed   boolean
    := ota_general.value_changed( p_rec_old.comments
                                , p_rec_new.comments  );
  --
  l_external_reference_changed   boolean
    := ota_general.value_changed( p_rec_old.external_reference
                                , p_rec_new.external_reference  );
  --
  l_invoice_address_changed   boolean
    := ota_general.value_changed( p_rec_old.invoice_address
                                , p_rec_new.invoice_address  );
  --
  l_invoice_contact_changed   boolean
    := ota_general.value_changed( p_rec_old.invoice_contact
                                , p_rec_new.invoice_contact  );
  --
  l_payment_method_changed   boolean
    := ota_general.value_changed( p_rec_old.payment_method
                                , p_rec_new.payment_method  );
  --
  l_transfer_date_changed   boolean
    := ota_general.value_changed( p_rec_old.transfer_date
                                , p_rec_new.transfer_date  );
  --
  l_transfer_message_changed   boolean
    := ota_general.value_changed( p_rec_old.transfer_message
                                , p_rec_new.transfer_message  );
  --
  l_vendor_id_changed   boolean
    := ota_general.value_changed( p_rec_old.vendor_id
                                , p_rec_new.vendor_id  );
  --
  l_contact_id_changed   boolean
    := ota_general.value_changed( p_rec_old.contact_id
                                , p_rec_new.contact_id  );
  --
  l_address_id_changed   boolean
    := ota_general.value_changed( p_rec_old.address_id
                                , p_rec_new.address_id  );
  --
  l_customer_id_changed   boolean
    := ota_general.value_changed( p_rec_old.customer_id
                                , p_rec_new.customer_id  );
  --
  l_payment_status_changed   boolean
    := ota_general.value_changed( p_rec_old.payment_status_flag
                                , p_rec_new.payment_status_flag  );
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
    If l_super_header_id_changed        OR
       l_authorizer_person_id_changed   OR
       l_organization_id_changed        OR
       l_administrator_changed          OR
       l_currency_code_changed          OR
       l_date_raised_changed            OR
       l_transfer_status_changed        OR
       l_type_changed                   OR
       l_comments_changed               OR
       l_external_reference_changed     OR
       l_invoice_address_changed        OR
       l_invoice_contact_changed        OR
       l_transfer_date_changed          OR
       l_transfer_message_changed       OR
       l_vendor_id_changed              OR
       l_contact_id_changed             OR
       l_address_id_changed             OR
       l_customer_id_changed            OR
       l_payment_method_changed         THEN
      --
--     l_payment_status                 OR
      --
      return true;
    Else
      return false;
      --
    End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_update01_header;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_update02_header >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Function check_update02_header
  (
   p_rec_old             in  ota_tfh_api_shd.g_rec_type
  ,p_rec_new             in  ota_tfh_api_shd.g_rec_type
  ) Return Boolean is
  --
  v_proc                 varchar2(72) := g_package||'check_update02_header';
  --
  l_pym_info_category_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_information_category
                                , p_rec_new.pym_information_category  );
  --
  l_pym_attribute1_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute1
                                , p_rec_new.pym_attribute1  );
  --
  l_pym_attribute2_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute2
                                , p_rec_new.pym_attribute2  );
  --
  l_pym_attribute3_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute3
                                , p_rec_new.pym_attribute3  );
  --
  l_pym_attribute4_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute4
                                , p_rec_new.pym_attribute4  );
  --
  l_pym_attribute5_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute5
                                , p_rec_new.pym_attribute5  );
  --
  l_pym_attribute6_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute6
                                , p_rec_new.pym_attribute6  );
  --
  l_pym_attribute7_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute7
                                , p_rec_new.pym_attribute7  );
  --
  l_pym_attribute8_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute8
                                , p_rec_new.pym_attribute8  );
  --
  l_pym_attribute9_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute9
                                , p_rec_new.pym_attribute9  );
  --
  l_pym_attribute10_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute10
                                , p_rec_new.pym_attribute10 );
  --
  l_pym_attribute11_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute11
                                , p_rec_new.pym_attribute11 );
  --
  l_pym_attribute12_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute12
                                , p_rec_new.pym_attribute12 );
  --
  l_pym_attribute13_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute13
                                , p_rec_new.pym_attribute13 );
  --
  l_pym_attribute14_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute14
                                , p_rec_new.pym_attribute14 );
  --
  l_pym_attribute15_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute15
                                , p_rec_new.pym_attribute15 );
  --
  l_pym_attribute16_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute16
                                , p_rec_new.pym_attribute16 );
  --
  l_pym_attribute17_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute17
                                , p_rec_new.pym_attribute17 );
  --
  l_pym_attribute18_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute18
                                , p_rec_new.pym_attribute18 );
  --
  l_pym_attribute19_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute19
                                , p_rec_new.pym_attribute19 );
  --
  l_pym_attribute20_changed   boolean
    := ota_general.value_changed( p_rec_old.pym_attribute20
                                , p_rec_new.pym_attribute20 );
  --
  l_tfh_info_category_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information_category
                                , p_rec_new.tfh_information_category  );
  --
  l_tfh_info1_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information1
                                , p_rec_new.tfh_information1  );
  --
  l_tfh_info2_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information2
                                , p_rec_new.tfh_information2  );
  --
  l_tfh_info3_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information3
                                , p_rec_new.tfh_information3  );
  --
  l_tfh_info4_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information4
                                , p_rec_new.tfh_information4  );
  --
  l_tfh_info5_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information5
                                , p_rec_new.tfh_information5  );
  --
  l_tfh_info6_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information6
                                , p_rec_new.tfh_information6  );
  --
  l_tfh_info7_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information7
                                , p_rec_new.tfh_information7  );
  --
  l_tfh_info8_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information8
                                , p_rec_new.tfh_information8  );
  --
  l_tfh_info9_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information9
                                , p_rec_new.tfh_information9  );
  --
  l_tfh_info10_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information10
                                , p_rec_new.tfh_information10 );
  --
  l_tfh_info11_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information11
                                , p_rec_new.tfh_information11 );
  --
  l_tfh_info12_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information12
                                , p_rec_new.tfh_information12 );
  --
  l_tfh_info13_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information13
                                , p_rec_new.tfh_information13 );
  --
  l_tfh_info14_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information14
                                , p_rec_new.tfh_information14 );
  --
  l_tfh_info15_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information15
                                , p_rec_new.tfh_information15 );
  --
  l_tfh_info16_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information16
                                , p_rec_new.tfh_information16 );
  --
  l_tfh_info17_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information17
                                , p_rec_new.tfh_information17 );
  --
  l_tfh_info18_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information18
                                , p_rec_new.tfh_information18 );
  --
  l_tfh_info19_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information19
                                , p_rec_new.tfh_information19 );
  --
  l_tfh_info20_changed   boolean
    := ota_general.value_changed( p_rec_old.tfh_information20
                                , p_rec_new.tfh_information20 );
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
    If l_pym_info_category_changed   OR
       l_pym_attribute1_changed      OR
       l_pym_attribute2_changed      OR
       l_pym_attribute3_changed      OR
       l_pym_attribute4_changed      OR
       l_pym_attribute5_changed      OR
       l_pym_attribute6_changed      OR
       l_pym_attribute7_changed      OR
       l_pym_attribute8_changed      OR
       l_pym_attribute9_changed      OR
       l_pym_attribute10_changed     OR
       l_pym_attribute11_changed     OR
       l_pym_attribute12_changed     OR
       l_pym_attribute13_changed     OR
       l_pym_attribute14_changed     OR
       l_pym_attribute15_changed     OR
       l_pym_attribute16_changed     OR
       l_pym_attribute17_changed     OR
       l_pym_attribute18_changed     OR
       l_pym_attribute19_changed     OR
       l_pym_attribute20_changed     OR
       l_tfh_info_category_changed   OR
       l_tfh_info1_changed           OR
       l_tfh_info2_changed           OR
       l_tfh_info3_changed           OR
       l_tfh_info4_changed           OR
       l_tfh_info5_changed           OR
       l_tfh_info6_changed           OR
       l_tfh_info7_changed           OR
       l_tfh_info8_changed           OR
       l_tfh_info9_changed           OR
       l_tfh_info10_changed          OR
       l_tfh_info11_changed          OR
       l_tfh_info12_changed          OR
       l_tfh_info13_changed          OR
       l_tfh_info14_changed          OR
       l_tfh_info15_changed          OR
       l_tfh_info16_changed          OR
       l_tfh_info17_changed          OR
       l_tfh_info18_changed          OR
       l_tfh_info19_changed          OR
       l_tfh_info20_changed          THEN
      --
      --
       return true;
    else
       return false;
      --
    End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_update02_header;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_update_header >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The details of a header may not be updated if the header has been
--   transferred other than to set the 'PAYMENT_FLAG'.
--   Enforced by the constraint 'OTA_TFH_CHECK_UPDATE'
--
Procedure check_update_header
  (
   p_rec_old              in  ota_tfh_api_shd.g_rec_type
  ,p_rec_new              in  ota_tfh_api_shd.g_rec_type
  ,p_transaction_type     in  varchar2
  ) is
  --
  v_proc                 varchar2(72) := g_package||'check_update_header';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_transaction_type = 'CANCEL_HEADER' or
     p_transaction_type = 'REINSTATE_HEADER' then
     --
     if check_update01_header( p_rec_old, p_rec_new ) or
        check_update02_header( p_rec_old, p_rec_new ) or
        ota_general.value_changed( p_rec_old.payment_status_flag
                                 , p_rec_new.payment_status_flag) then
        --
        fnd_message.set_name('OTA','OTA_13290_TFH_UPDATE');
        fnd_message.set_token('STEP','1');
        fnd_message.raise_error;
     end if;

  else
       if p_rec_old.transfer_status = 'ST' then
          if check_update01_header( p_rec_old, p_rec_new ) or
             check_update02_header( p_rec_old, p_rec_new ) or
             ota_general.value_changed(p_rec_old.cancelled_flag
                                      ,p_rec_new.cancelled_flag) then
          --
             fnd_message.set_name('OTA','OTA_13290_TFH_UPDATE');
             fnd_message.set_token('STEP','2');
             fnd_message.raise_error;
         end if;
       end if;
       if p_rec_old.cancelled_flag = 'Y' then
          if check_update01_header( p_rec_old, p_rec_new ) or
             check_update02_header( p_rec_old, p_rec_new ) or
             ota_general.value_changed( p_rec_old.payment_status_flag
                                 , p_rec_new.payment_status_flag) or
             ota_general.value_changed(p_rec_old.cancelled_flag
                                      ,p_rec_new.cancelled_flag) then
             --
             fnd_message.set_name('OTA','OTA_13290_TFH_UPDATE');
             fnd_message.set_token('STEP','3');
             fnd_message.raise_error;
          --
          end if;
       end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_update_header;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_payment_status_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The attribute 'PAYMENT_STATUS_FLAG' must be in the domain 'Yes No'.
--
Procedure check_payment_status_flag
  (
   p_flag  in  varchar2
  ) is
  --
  v_proc                varchar2(72) := g_package||'check_payment_status_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If NOT (p_flag in ('N', 'Y')) then
    --
    ota_tfh_api_shd.constraint_error( 'OTA_TFH_PAYMENT_STATUS_FLA_CHK');
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_payment_status_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_administrator >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The ADMINISTRATOR attribute must be a valid AOL user.
--
Procedure check_administrator
  (
   p_administrator   in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_administrator';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_administrator is NOT null  Then
    --
    if not ota_general.check_fnd_user(p_administrator) then
        fnd_message.set_name('OTA','OTA_13291_TFH_ADMINISTRATOR');
        fnd_message.raise_error;
    end if;
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_administrator;
--
-- ----------------------------------------------------------------------------
-- |------------------< check_deletion_allowed_status >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
--   Checks whether a finance_header can be deleted.
--
Procedure check_deletion_allowed_status
  (
   p_finance_header_id     in  number
  ,p_superceding_header_id out nocopy number
  ,p_type                  out nocopy varchar2
  ) is
  --
  p_transfer_status  varchar2(30);
  v_proc             varchar2(72) := g_package||'check_deletion_allowed_status';
  --
  cursor sel_for_deletion is
    select tfh.transfer_status
         , tfh.superceding_header_id
         , tfh.type
      from ota_finance_headers      tfh
     where tfh.finance_header_id    =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is NOT null  Then
    --
    Open  sel_for_deletion;
    Fetch sel_for_deletion into p_transfer_status
                              , p_superceding_header_id
                              , p_type;
    --
    If sel_for_deletion%notfound then
      --
      close sel_for_deletion;
      --
        fnd_message.set_name('OTA','OTA_13323_TFH_DELETION');
        fnd_message.raise_error;
    End if;
    --
    close sel_for_deletion;
    --
    -- Only NOT TRANSFERED Finance Headers can be deleted
    --
    If p_transfer_status = 'ST'  then
      --
        fnd_message.set_name('OTA','OTA_13323_TFH_DELETION');
        fnd_message.raise_error;
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_deletion_allowed_status;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_deletion_childs >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
--   Checks whether a finance_header has finance_lines
--
Procedure check_deletion_childs
  (
   p_finance_header_id     in  number
  ) is
  --
  v_exists           varchar2(1);
  v_proc             varchar2(72) := g_package||'check_deletion_childs';
  --
  cursor sel_for_deletion is
    select 'Y'
      from ota_finance_lines          tfl
     where tfl.finance_header_id      =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_for_deletion;
  Fetch sel_for_deletion into v_exists;
  --
  If sel_for_deletion%found then
    --
    close sel_for_deletion;
    --
        fnd_message.set_name('OTA','OTA_443876_TFH_DELETE_CHK');
        fnd_message.raise_error;
      --
  End if;
  --
  close sel_for_deletion;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_deletion_childs;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_deletion >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Checks whether a finance_header can be deleted.
--
Procedure check_deletion
  (
   p_finance_header_id     in  number
  ) is
  --
  v_type                   varchar2(30);
  v_superceding_header_id  number( 9);
  v_proc                   varchar2(72) := g_package||'check_deletion';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is NOT null  Then
    --
    -- * Checks whether the Finance Header has Finance Lines
    --
    check_deletion_childs( p_finance_header_id);
    --
    -- * Checks whether the Finance Header is transfered or not
    --
    check_deletion_allowed_status( p_finance_header_id
                                 , v_superceding_header_id
                                 , v_type );
    --
    -- * Checks whether the Finance Header is superceded by another one
    --   or not
    --
    check_superceding( p_finance_header_id);
    --
    -- If a Cancellation Header should be deleted, then the superceding
    -- finance header Cancelled Flag is set to 'N'
    --
    If v_type = 'C'  Then
      --
      recancel_header( p_finance_header_id => v_superceding_header_id
                       ,p_validate         => FALSE);
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_deletion;
-- ----------------------------------------------------------------------------
-- |------------------------------< organization_name> -----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
-- Returns the organization name for the given id
--
function organization_name (p_organization_id in number) return varchar2 is
--
  cursor c_organization is
    select name
    from hr_organization_units
    where organization_id = p_organization_id;
--
  l_result hr_all_organization_units.name%TYPE; -- Bug 2256328
--
begin
--
  open c_organization;
  fetch c_organization into l_result;
  close c_organization;
  --
  return l_result;
--
end;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< initialize_finance_header ------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Get some default values for the Finance Header Form
--
procedure initialize_finance_header
   (
    p_business_group_id    in number
   ,p_fnd_user_id          in number
   ,p_deflt_currency_code  out nocopy varchar2
   ,p_deflt_trans_status_meaning out nocopy varchar2
   ,p_deflt_administrator  out nocopy varchar2
   ,p_deflt_organization   out nocopy varchar2
   ) is
cursor get_fnd_user is
select user_name
from   fnd_user
where  user_id = p_fnd_user_id;
--
begin
   -- get default currency code for the Business group
   --
   p_deflt_currency_code := hr_general.default_currency_code
                                         (p_business_group_id);

   --
   -- Get default Transfer Status
   --
   p_deflt_trans_status_meaning :=
             hr_general.decode_lookup('GL_TRANSFER_STATUS' ,'NT');
   --
   -- Get default Administrator
   --
   open get_fnd_user;
   fetch get_fnd_user into p_deflt_administrator;
   close get_fnd_user;
   --
   --
   -- Get default organization
   --
  p_deflt_organization := organization_name (p_business_group_id);

end;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_superseded >---------------------------
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Check whether the Finance Header has been superceded and prevent update
-- if it has
--
procedure check_superseded (p_finance_header_id in number) is
  v_proc                   varchar2(72) := g_package||'check_superseded';
  l_dummy varchar2(1);
--
cursor get_superseding_header is
select null
from ota_finance_headers
where superceding_header_id = p_finance_header_id;
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  hr_utility.trace('Header ID is '||to_char(p_finance_header_id));
  --
  open get_superseding_header;
  fetch get_superseding_header into l_dummy;
  if get_superseding_header%notfound then
     close get_superseding_header;
     return;
  else
     close get_superseding_header;
     fnd_message.set_name('OTA','OTA_13320_TFH_SUPERSEDED');
     fnd_message.raise_error;
  --
  end if;
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
end check_superseded;
--
end ota_tfh_api_business_rules;

/
