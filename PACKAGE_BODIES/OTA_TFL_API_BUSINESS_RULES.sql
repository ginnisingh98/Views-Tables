--------------------------------------------------------
--  DDL for Package Body OTA_TFL_API_BUSINESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFL_API_BUSINESS_RULES" as
/* $Header: ottfl02t.pkb 115.4 2002/11/29 09:24:27 arkashya ship $ */
--
--
-- Global package name
--
g_package		varchar2(33)	:= '  ota_tfl_api_business_rules.';
g_standard		varchar2(40)    := 'STANDARD';
g_pre_payment		varchar2(40)    := 'PRE-PAYMENT';
g_pre_purchase_payment	varchar2(40)    := 'PRE-PURCHASE PAYMENT';
g_pre_purchase_use	varchar2(40)    := 'PRE-PURCHASE USE';
--
-- Global api dml status
--
g_api_dml		boolean;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_valid_header>-------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Check finance_header exists, check type and receivable type of the header,
--  Check it is not a cancellation header.
--
Procedure check_valid_header
  (
   p_tfh_type		 in varchar2
  ,p_tfh_receivable_type in varchar2
  ) Is
-----------------
  v_proc        varchar2(72) := g_package||'check_valid_header';
-----------------
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_tfh_type = 'C' then
        --
        --  Finance header of type Cancellation
        --
          fnd_message.set_name('OTA','OTA_13412_TFL_NO_HEADER');
          fnd_message.raise_error;
  --
  elsIf     p_tfh_type is null then
     fnd_message.set_name('OTA','OTA_13412_TFL_NO_HEADER');
     fnd_message.raise_error;
  --
  end if;
  --
End check_valid_header;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_line_type_domain >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   The attributee 'TYPE' must be in the domain of 'Finance Line Type'.
--
Procedure check_line_type_domain
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
    ota_general.check_domain_value( 'FINANCE_LINE_TYPE', p_type);
    --
  Else
     fnd_message.set_name('OTA','OTA_13459_TFL_TYPE_NOT_FOUND');
     fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
  --
End check_line_type_domain;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_line_type >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--    The type of header allowed to linked to a line must obey the
--    following rules:
--       Header of type cancelled  - NO LINES ALLOWED
--       Header of type payable    - Only vendor payment lines
--       Header of type receivable - Lines of type pre-purchase deal,
--                                   enrollment charge and resource
--                                   charge only.
--       Header of type cost transfer - Only vendor payment and
--                                      enrollment lines.
--
Procedure check_line_type
  (
   p_finance_line_type  	in  varchar2
  ,p_finance_header_type	in varchar2
  ,p_receivable_type		in varchar2
  ) is
-----------------
  v_proc                  varchar2(72) := g_package||'check_line_type';
-----------------
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  check_valid_header(p_finance_header_type,p_receivable_type);
  --
  check_line_type_domain(p_finance_line_type);
  --
  If (p_finance_line_type not in ('E','R','P','V') or
      p_finance_header_type  <> 'CT') then
     return;
  end if;
  --
  If p_finance_header_type <> 'CT' then
  If (p_finance_header_type  = 'P'  AND  p_finance_line_type <> 'V'
     )
    OR
     ( p_finance_line_type <> 'E' and
       (p_receivable_type = g_standard OR
        p_receivable_type = g_pre_payment OR
        p_receivable_type = g_pre_purchase_use)
     )
    OR
     ( p_receivable_type=g_pre_purchase_payment and
       p_finance_line_type <> 'P'
     )
     Then
        --
          fnd_message.set_name('OTA','OTA_13460_TFL_WRONG_LINE_TYPE');
          fnd_message.raise_error;
  End if;
  End if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
--
end check_line_type;
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
    ota_tfl_api_shd.constraint_error( 'OTA_TFL_TRANSFER_STATUS_CHK');
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_transfer_status;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_booking_deal_type > -----------------------|
-- ----------------------------------------------------------------------------
--
procedure check_booking_deal_type(
         p_booking_deal_type             in varchar2
        ,p_receivable_type 		 in varchar2)
is
---------------
  v_proc        varchar2(72) := g_package||'check_booking_deal_type';
---------------
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_receivable_type in (g_pre_purchase_payment,g_pre_purchase_use)
     and p_booking_deal_type <> 'P' then
          fnd_message.set_name('OTA','OTA_13456_TFL_WRONG_DEAL_TYPE');
          fnd_message.raise_error;
  --
  elsif p_receivable_type in (g_standard,g_pre_payment)
     and p_booking_deal_type <> 'D' then
          fnd_message.set_name('OTA','OTA_13456_TFL_WRONG_DEAL_TYPE');
          fnd_message.raise_error;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
end check_booking_deal_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_booking_deal>-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure check that:
--  	- the type of the booking deal is correct.
-- This procedure replaces former procedures check_deal_customer and
-- check_valid_discount_deal
--
procedure check_booking_deal (
	 p_finance_header_id		in number
	,p_booking_deal_id		in number
   ) is
---------------
  v_proc                 varchar2(72) := g_package||'check_booking_deal';
  v_book_deal_customer_id       OTA_BOOKING_DEALS.CUSTOMER_ID%type;
  v_finance_customer_id         OTA_FINANCE_HEADERS.CUSTOMER_ID%type;
  v_receivable_type		OTA_FINANCE_HEADERS.RECEIVABLE_TYPE%type;
  v_deal_type                   OTA_BOOKING_DEALS.TYPE%type;
  v_number_of_places            number;
  v_limit_each_event_flag       varchar2(1);
  --
  cursor csr_tfh is
    select customer_id,receivable_type
      from ota_finance_headers
     where finance_header_id     =    p_finance_header_id;
  --
  cursor csr_tbd is
    select customer_id,type,number_of_places,limit_each_event_flag
      from ota_booking_deals
     where booking_deal_id       =    p_booking_deal_id;
---------------
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  csr_tbd;
  Fetch csr_tbd into v_book_deal_customer_id
                    ,v_deal_type
                    ,v_number_of_places
                    ,v_limit_each_event_flag;
  Close csr_tbd;
  --
  If v_deal_type is null then
          fnd_message.set_name('OTA','OTA_13458_TFL_DEAL_NOT_FOUND');
          fnd_message.raise_error;
  end if;
  --
  If v_book_deal_customer_id is NOT null  Then
        Open  csr_tfh;
        Fetch csr_tfh into v_finance_customer_id,v_receivable_type;
        Close csr_tfh;
  End if;
  --
  check_booking_deal_type(v_deal_type,v_receivable_type);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
end check_booking_deal;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_vendor >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The vendor defined on the resource booking must be the same vendor
--   as entered on the header.
--
Procedure check_vendor
  (
   p_finance_header_id     in  number
  ,p_resource_booking_id   in  number
  ) is
  --
  v_resource_vendor_id   number;
  v_finance_vendor_id    number;
  v_proc                 varchar2(72) := g_package||'check_vendor';
  --
  cursor sel_resource_vendor is
    select tsr.vendor_id
      from ota_resource_bookings     trb
         , ota_suppliable_resources  tsr
     where trb.resource_booking_id   =    p_resource_booking_id
       and tsr.supplied_resource_id  =    trb.supplied_resource_id;
  --
  cursor sel_finance_vendor is
    select tfh.vendor_id
      from ota_finance_headers       tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_resource_booking_id   is NOT null   AND
     p_finance_header_id     is NOT null  Then
    --
    Open  sel_resource_vendor;
    Fetch sel_resource_vendor into v_resource_vendor_id;
    --
    If sel_resource_vendor%notfound Then
      --
      Close sel_resource_vendor;
      --
          fnd_message.set_name('OTA','OTA_13345_TFL_VENDOR');
          fnd_message.raise_error;
      --
    Else
      --
      Close sel_resource_vendor;
      Open  sel_finance_vendor;
      Fetch sel_finance_vendor into v_finance_vendor_id;
      --
      If sel_finance_vendor%notfound Then
        --
        Close sel_finance_vendor;
        --
          fnd_message.set_name('OTA','OTA_13345_TFL_VENDOR');
          fnd_message.raise_error;
        --
      Else
        --
        If v_resource_vendor_id  <>  v_finance_vendor_id  OR
           v_finance_vendor_id   is  null                 Then
          --
          Close sel_finance_vendor;
          --
          fnd_message.set_name('OTA','OTA_13345_TFL_VENDOR');
          fnd_message.raise_error;
          --
        End if;
        --
      End if;
      --
      Close sel_finance_vendor;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_vendor;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_resource_charge >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Only resource allocations for delegate bookings are allowed to be
--   referenced. The resource allocation must be for a delegate booking for the
--   customer defined on the header, or for a delegate booking with a
--   booking_source of 'R' for reseller. Or the header_id is null.
--
Procedure check_resource_charge
  (
   p_finance_header_id         in   number
  ,p_resource_allocation_id    in   number
  ) is
  --
  v_finance_customer_id      number;
  v_booking_customer_id      number;
  v_source_of_booking        varchar(30);
  v_proc                     varchar2(72) := g_package||'check_resource_charge';
  --
  cursor sel_booking_customer is
    select tdb.customer_id
         , tdb.source_of_booking
      from ota_resource_allocations    tra
         , ota_delegate_bookings       tdb
     where tra.resource_allocation_id  =  p_resource_allocation_id
       and tdb.booking_id              =  tra.booking_id;
  --
  cursor sel_finance_customer is
    select tfh.customer_id
      from ota_finance_headers         tfh
     where tfh.finance_header_id       =  p_finance_header_id;
  --
 Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_finance_header_id is not null and p_resource_allocation_id is not null
    then
      --
      Open  sel_booking_customer;
      Fetch sel_booking_customer into v_booking_customer_id
                                    , v_source_of_booking;
      --
      If sel_booking_customer%notfound then
        --
        Close sel_booking_customer;
        --
          fnd_message.set_name('OTA','OTA_13347_TFL_RES_CHARGE');
          fnd_message.raise_error;
        --
      Else
        --
        Close sel_booking_customer;
        Open  sel_finance_customer;
        Fetch sel_finance_customer into v_finance_customer_id;
        --
        If sel_finance_customer%notfound then
          --
          Close sel_finance_customer;
          --
          fnd_message.set_name('OTA','OTA_13347_TFL_RES_CHARGE');
          fnd_message.raise_error;
          --
        Else
          --
          Close sel_finance_customer;
          --
          -- Resource of booking is NOT a reseller
          --
          If v_source_of_booking  <>  'R'   OR
             v_source_of_booking  is  null  Then
            --
            If v_finance_customer_id  <>  v_booking_customer_id  OR
               ( v_finance_customer_id is     null  AND
                 v_booking_customer_id is NOT null     )         OR
               ( v_booking_customer_id is     null  AND
                 v_finance_customer_id is NOT null     )         Then
              --
          fnd_message.set_name('OTA','OTA_13347_TFL_RES_CHARGE');
          fnd_message.raise_error;
              --
            End if;
            --
          End if;
          --
        End if;
        --
      End if;
      --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_resource_charge;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_valid_delegate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The delegate booking must be for the customer defined on the header
--   or the header_id is null, or the delegate booking has the booking_source
--   set to 'R' for reseller.
--
Procedure check_valid_delegate
  (
   p_finance_header_id   in  number
  ,p_booking_id          in  number
  ) is
  --
  v_booking_customer_id      number;
  v_source_of_booking        varchar(30);
  v_finance_customer_id      number;
  v_proc                     varchar2(72) := g_package||'check_valid_delegate';
  --
  cursor sel_booking_customer is
    select tdb.customer_id
         , tdb.source_of_booking
      from ota_delegate_bookings     tdb
     where tdb.booking_id            =    p_booking_id;
  --
  cursor sel_finance_customer is
    select tfh.customer_id
      from ota_finance_headers       tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  null;
/**********************
 This procedure has been omitted until further clarification is received
  --
  If p_booking_id        is NOT null  AND
     p_finance_header_id is NOT null  Then
    --
    Open  sel_booking_customer;
    Fetch sel_booking_customer into v_booking_customer_id
                                  , v_source_of_booking;
    --
    If sel_booking_customer%notfound then
      --
      Close sel_booking_customer;
      --
          fnd_message.set_name('OTA','OTA_13346_TFL_DELEGATE');
          fnd_message.raise_error;
      --
    Else
      --
      Close sel_booking_customer;
      Open  sel_finance_customer;
      Fetch sel_finance_customer into v_finance_customer_id;
      --
      If sel_finance_customer%notfound then
        --
        Close sel_finance_customer;
        --
          fnd_message.set_name('OTA','OTA_13346_TFL_DELEGATE');
          fnd_message.raise_error;
        --
      Else
        --
        Close sel_finance_customer;
        --
        -- Resource of booking is NOT a reseller
        --
        If v_source_of_booking  <>  'R'   OR
           v_source_of_booking  is  null  Then

          --
          If   v_booking_customer_id <> v_finance_customer_id  OR
             ( v_finance_customer_id is     null  AND
               v_booking_customer_id is NOT null     )         OR
             ( v_booking_customer_id is     null  AND
               v_finance_customer_id is NOT null     )         Then
            --
          fnd_message.set_name('OTA','OTA_13346_TFL_DELEGATE');
          fnd_message.raise_error;
            --
          End if;
          --
        End if;
        --
      End if;
      --
    End if;
    --
  End if;
****************************/
end check_valid_delegate;
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_pre_purchase_units    >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    If the enrollment charge or pre-purchase charge is linked to a
--    pre-purchase deal then if the price list is in training units then
--    the units used must be entered, otherwise it must be null
--
Procedure check_pre_purchase_units
  (
   p_finance_line_type       in   varchar2
  ,p_standard_amount         in   number
  ,p_money_amount            in   number
  ,p_unitary_amount          in   number
  ,p_booking_deal_id         in   number
  ) is
  --
  v_price_list_type   varchar2(30);
  v_book_deal_type    varchar2(30);
  v_proc              varchar2(72) := g_package||'check_pre_purchase_units';
  --
  cursor sel_pricelist_type is
    select tbd.type
         , tpl.price_list_type
      from ota_booking_deals      tbd
         , ota_price_lists        tpl
     where tbd.booking_deal_id    =  p_booking_deal_id
       and tpl.price_list_id  (+) =  tbd.price_list_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
      Open  sel_pricelist_type;
      Fetch sel_pricelist_type into v_book_deal_type
                                  , v_price_list_type;
      --
      If sel_pricelist_type%notfound then
        --
        Close sel_pricelist_type;
        --
          fnd_message.set_name('OTA','OTA_13351_TFL_PRE_PURCH_UNIT');
          fnd_message.raise_error;
        --
      Else
        --
        Close sel_pricelist_type;
        --
        If v_book_deal_type  = 'P'  Then
          --
          --  It's a Pre-purchase deal
          --
          -- If the Price List used on the booking deal is in units then
          -- the number of units used must be recorded otherwise it
          -- must be null
          --
          If   (v_price_list_type  =  'T'  and
                p_unitary_amount  is     null
            OR (v_price_list_type =  'M'   and
                p_unitary_amount  is NOT null))  Then
            --
            fnd_message.set_name('OTA','OTA_13351_TFL_PRE_PURCH_UNIT');
            fnd_message.raise_error;
              --
          End if;
          --
        End if;
        --
      End if;
    --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_pre_purchase_units;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_tfl_foreign_keys >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_tfl_foreign_keys (
	 p_finance_header_id		in varchar2
	,p_finance_line_type    	in varchar2
	,p_receivable_type		in varchar2
	,p_booking_id			in number
	,p_booking_deal_id		in number
	,p_resource_booking_id  	in number
	,p_resource_allocation_id	in number
	) is
--
  Cursor csr_type IS
    select type
    from   OTA_FINANCE_HEADERS
    where  finance_header_id = p_finance_header_id;
---------------------
   v_type varchar2(30);
begin
  --
  if p_finance_header_id is not null then
    open csr_type;
    fetch csr_type into v_type;
    close csr_type;
  end if;
  if p_finance_line_type = 'E' then
     if    p_booking_id is null
	or p_resource_booking_id is not null
	or p_resource_allocation_id is not null
	then
          fnd_message.set_name('OTA','OTA_13350_TFL_ENROLLMENT_ATTR');
          fnd_message.raise_error;
     end if;
     if p_receivable_type = g_pre_purchase_use
       and p_booking_deal_id is null then
          fnd_message.set_name('OTA','OTA_13350_TFL_ENROLLMENT_ATTR');
          fnd_message.raise_error;
     end if;

  --
  elsif p_finance_line_type = 'V' then
     if    p_resource_booking_id is null
        or p_booking_id is not null
	or p_booking_deal_id is not null
	or p_resource_allocation_id is not null
	then
          fnd_message.set_name('OTA','OTA_13353_TFL_VENDOR_PAY_ATTR');
          fnd_message.raise_error;
     end if;
  --
  elsif p_finance_line_type = 'P' then
     if	   p_booking_deal_id is null
	or p_booking_id is not null
	or p_resource_booking_id is not null
	or p_resource_allocation_id is not null
	then
          fnd_message.set_name('OTA','OTA_13349_TFL_PRE_PURCH_ATTR');
          fnd_message.raise_error;
     end if;
  --
  elsif p_finance_line_type = 'R' then
          fnd_message.set_name('OTA','OTA_13352_TFL_RES_CHARGE_ATTR');
          fnd_message.raise_error;
  --
  else
    if p_booking_deal_id is not null
    or p_booking_id is not null
    or p_resource_booking_id is not null
    or p_resource_allocation_id is not null then
         fnd_message.set_name('OTA','OTA_13590_USER_FIN_TYPE_KEY');
         fnd_message.raise_error;
    end if;
  end if;
  --
  --
  if (p_resource_booking_id is not null and
     v_type <> 'CT') then
	check_vendor(p_finance_header_id,p_resource_booking_id);
  end if;
  --
  if p_booking_deal_id is not null then
        check_booking_deal(p_finance_header_id,p_booking_deal_id);
        ota_tfl_api_business_rules3.check_customer_booking_deal
             (p_finance_header_id,p_booking_deal_id);
  end if;
  --
  if p_resource_allocation_id is not null then
	check_resource_charge(p_finance_header_id,p_resource_allocation_id);
  end if;
  --
end check_tfl_foreign_keys;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_type_and_amounts >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
Procedure check_type_and_amounts
  (
   p_finance_line_type       in   varchar2
  ,p_standard_amount         in   number
  ,p_money_amount            in   number
  ,p_unitary_amount          in   number
  ,p_booking_deal_id         in   number
  ,p_finance_header_id       in   number
  ) is
  --
  CURSOR csr_header_type IS
    SELECT type
    FROM ota_finance_headers
    WHERE finance_header_id = p_finance_header_id;
  --
  v_proc              varchar2(72) := g_package||'check_enrollment_attributes';
  --
  v_finance_header_type varchar2(30);
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_finance_header_id is not null then
    open csr_header_type;
    fetch csr_header_type into v_finance_header_type;
    close csr_header_type;
  end if;
  --
  If p_finance_line_type in ('E','R') and p_standard_amount is null Then
          fnd_message.set_name('OTA','OTA_13454_TFL_ST_AMNT_REQ');
	  fnd_message.raise_error;
  elsif p_finance_line_type in ('V','P') and p_standard_amount is not null then
          fnd_message.set_name('OTA','OTA_13464_TFL_ST_AMNT_NULL');
	  fnd_message.raise_error;
  end if;
  --
  if p_money_amount is null then
          fnd_message.set_name('OTA','OTA_13455_TFL_MONEY_AMNT_REQ');
          fnd_message.raise_error;
  end if;
  --
  if p_finance_line_type in ('R','V') and p_unitary_amount is not null then
          fnd_message.set_name('OTA','OTA_13465_UNIT_AMNT_NULL');
          fnd_message.raise_error;
  end if;
  --
  if p_finance_line_type in ('E','P') and p_booking_deal_id is not null then
     check_pre_purchase_units(p_finance_line_type
                             ,p_standard_amount
                             ,p_money_amount
                             ,p_unitary_amount
                             ,p_booking_deal_id
                             );
  end if;
  --
  if p_finance_line_type is not null and
     v_finance_header_type <> 'CT' and
     p_finance_line_type not in ('E','P','R','V') and
     (   p_unitary_amount  is not null
      or p_standard_amount is not null
      or p_money_amount    is null) then
         fnd_message.set_name('OTA','OTA_13589_USER_FIN_TYPE_ERROR');
         fnd_message.raise_error;
  end if;

  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
end check_type_and_amounts;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_update_attributes >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    If the line has been transferred then no attributes may be updated.
--
Procedure check_update_attributes
  (
   p_transfer_status      in   varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_update_attributes';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_transfer_status = 'ST'  Then
    --
          fnd_message.set_name('OTA','OTA_13355_TFL_UPDATE');
          fnd_message.raise_error;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_update_attributes;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_cancelled_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    The attribute CANCELLED_FLAG must be in the doamin 'Yes No'
--
Procedure check_cancelled_flag
  (
   p_cancelled_flag    in   varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_cancelled_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
     ota_general.check_domain_value('YES_NO',p_cancelled_flag);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_cancelled_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_sequence_number >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    The sequence_number for a finance line within a finance_header_id
--    MUST be unique.
--
Procedure check_sequence_number
  (
   p_finance_header_id       in   number
  ,p_sequence_number         in   number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_sequence_number';
  --
  cursor sel_sequence_number is
    select 'Y'
      from ota_finance_lines         tfl
     where tfl.finance_header_id     =    p_finance_header_id
       and tfl.sequence_number       =    p_sequence_number;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is not null  Then
    --
    If p_sequence_number <= 0     OR
       p_sequence_number is NULL  Then
      --
          fnd_message.set_name('OTA','OTA_13364_TFL_SEQUENCE');
          fnd_message.raise_error;
      --
    Else
      --
      Open  sel_sequence_number;
      Fetch sel_sequence_number into v_exists;
      --
      If sel_sequence_number%found then
        --
        Close sel_sequence_number;
        --
          fnd_message.set_name('OTA','OTA_13364_TFL_SEQUENCE');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_sequence_number;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_sequence_number;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_next_sequence_number >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Fetch the next valid sequence number for a finance line.
--
Procedure get_next_sequence_number
  (
   p_finance_header_id       in      number
  ,p_sequence_number         in out nocopy number
  ) is
  --
  v_last_sequence_number  number( 11);
  v_proc                  varchar2(72) := g_package||'get_next_sequence_number';
  --
  cursor get_sequence_number is
    select nvl( max( tfl.sequence_number), 0)
      from ota_finance_lines         tfl
     where tfl.finance_header_id     =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is not null  Then
    --
    Open  get_sequence_number;
    Fetch get_sequence_number into v_last_sequence_number;
    --
    If get_sequence_number%notfound then
      --
      Close get_sequence_number;
      --
      p_sequence_number :=  10;
      --
    Else
      --
      Close get_sequence_number;
      --
      p_sequence_number := v_last_sequence_number + 10;
      --
    End if;
    --
  Else
    --
    p_sequence_number :=  10;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End get_next_sequence_number;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_date_raised >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Get a valid date_raised for a finance line.
--
Procedure get_date_raised
  (
   p_finance_header_id       in      number
  ,p_date_raised             in out  nocopy date
  ) is
  --
  v_date_raised           date;
  v_proc                  varchar2(72) := g_package||'get_date_raised';
  --
  cursor sel_date_raised is
    select tfh.date_raised
      from ota_finance_headers       tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  if p_date_raised is null then
  --
  If p_finance_header_id is not null  Then
    --
    Open  sel_date_raised;
    Fetch sel_date_raised into v_date_raised;
    --
    If sel_date_raised%notfound then
      --
      Close sel_date_raised;
      --
          fnd_message.set_name('OTA','OTA_13365_TFL_DATE_RAISED');
          fnd_message.raise_error;
      --
    End if;
    --
    Close sel_date_raised;
    --
    p_date_raised  :=  v_date_raised;
    --
  Else
    --
    p_date_raised  :=  sysdate;
    --
  End if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End get_date_raised;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_delete_attempt >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    No finance lines may be deleted.
--
Procedure check_delete_attempt
  (
   p_finance_header_id       in   number
  ,p_finance_line_id         in   number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_delete_attempt';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
          fnd_message.set_name('OTA','OTA_13357_TFL_DELETE');
          fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_delete_attempt;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_currency_code >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure check_currency_code
  (
   p_finance_line_type       in   varchar2
  ,p_finance_header_id       in   number
  ,p_booking_id              in   number
  ,p_booking_deal_id         in   number
  ,p_resource_allocation_id  in   number
  ,p_resource_booking_id     in   number
  ) is
  --
  v_header_currency_code  ota_events.currency_code%type;
  v_line_currency_code    ota_events.currency_code%type;
  v_type                  ota_finance_headers.type%type;
  v_proc                  varchar2(72) := g_package||'check_currency_code';
  --
  cursor sel_finance_currency is
    select tfh.currency_code,tfh.type
      from ota_finance_headers       tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
  cursor sel_event_currency is
    select evt.currency_code
      from ota_delegate_bookings     tdb
         , ota_events                evt
     where tdb.booking_id            =    p_booking_id
       and evt.event_id              =    tdb.event_id;
  --
  cursor sel_price_list_currency is
    select tpl.currency_code
      from ota_booking_deals         tbd
         , ota_price_lists           tpl
     where tbd.booking_deal_id       =    p_booking_deal_id
       and tpl.price_list_id         =    tbd.price_list_id;
  --
  cursor sel_resource_alloc_currency is
    select evt.currency_code
      from ota_resource_allocations   tra
         , ota_delegate_bookings      tdb
         , ota_events                 evt
     where tra.resource_allocation_id =   p_resource_allocation_id
       and tdb.booking_id             =   tra.booking_id
       and evt.event_id               =   tdb.event_id;
  --
  cursor sel_resource_book_currency is
   select tsr.currency_code
    from ota_suppliable_resources tsr,
	 ota_resource_bookings trb
    where tsr.supplied_resource_id = trb.supplied_resource_id
    and trb.resource_booking_id = p_resource_booking_id;

   /* select decode(evt.event_id,'',v_header_currency_code
                              ,evt.currency_code)
      from ota_resource_bookings     trb
         , ota_events                evt
     where trb.resource_booking_id   =    p_resource_booking_id
       and evt.event_id(+)           =    trb.event_id;*/
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_finance_currency;
  Fetch sel_finance_currency into v_header_currency_code,v_type;
  --
  If sel_finance_currency%notfound then
      --
      Close sel_finance_currency;
      --
          fnd_message.set_name('OTA','OTA_13297_TFL_NO_CURRENCY');
          fnd_message.raise_error;
      --
  End if;
  --
  Close sel_finance_currency;
  --
  If v_type <> 'CT' Then
   If p_finance_line_type = 'V' Then
      --
      -- *  TYPE  Vendor Payment
      --
      Open  sel_resource_book_currency;
      Fetch sel_resource_book_currency into v_line_currency_code;
      --
      If sel_resource_book_currency%notfound               OR
         v_line_currency_code  <>  v_header_currency_code  OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_resource_book_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_resource_book_currency;
      --
      --
      --
  ElsIf p_finance_line_type = 'E' Then
      --
      --  TYPE  Enrollment Charge
      --
      Open  sel_event_currency;
      Fetch sel_event_currency into v_line_currency_code;
      --
      If sel_event_currency%notfound                       OR
         v_line_currency_code  <>  v_header_currency_code  OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_event_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_event_currency;
      --
  ElsIf p_finance_line_type = 'P'  Then
      --
      --  TYPE  Pre-purchase deal
      --
      Open  sel_price_list_currency;
      Fetch sel_price_list_currency into v_line_currency_code;
      --
      If sel_price_list_currency%notfound                  OR
         v_line_currency_code  <>  v_header_currency_code  OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_price_list_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_price_list_currency;
      --
      --
      --
  ElsIf p_finance_line_type = 'R'  Then
      --
      --  TYPE  Resource Charge
      --
      Open  sel_resource_alloc_currency;
      Fetch sel_resource_alloc_currency into v_line_currency_code;
      --
      If sel_resource_alloc_currency%notfound              OR
         v_line_currency_code  <>  v_header_currency_code  OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_resource_alloc_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_resource_alloc_currency;
      --
  End if;
  --
 End if;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_currency_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_currency_code >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure get_currency_code
  (
   p_finance_line_type       in   varchar2
  ,p_booking_id              in   number
  ,p_booking_deal_id         in   number
  ,p_resource_allocation_id  in   number
  ,p_resource_booking_id     in   number
  ,p_currency_code           out  nocopy varchar2
  ) is
  --
  v_line_currency_code    ota_events.currency_code%type;
  v_proc                  varchar2(72) := g_package||'get_currency_code';
  --
  cursor sel_event_currency is
    select evt.currency_code
      from ota_delegate_bookings     tdb
         , ota_events                evt
     where tdb.booking_id            =    p_booking_id
       and evt.event_id              =    tdb.event_id;
  --
  cursor sel_price_list_currency is
    select tpl.currency_code
      from ota_booking_deals         tbd
         , ota_price_lists           tpl
     where tbd.booking_deal_id       =    p_booking_deal_id
       and tpl.price_list_id         =    tbd.price_list_id;
  --
  cursor sel_resource_alloc_currency is
    select evt.currency_code
      from ota_resource_allocations   tra
         , ota_delegate_bookings      tdb
         , ota_events                 evt
     where tra.resource_allocation_id =   p_resource_allocation_id
       and tdb.booking_id             =   tra.booking_id
       and evt.event_id               =   tdb.event_id;
  --
  cursor sel_resource_book_currency is
    select evt.currency_code
      from ota_resource_bookings     trb
         , ota_events                evt
     where trb.resource_booking_id   =    p_resource_booking_id
       and evt.event_id              =    trb.event_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
    --
    If    p_finance_line_type = 'V' Then
      --
      --  * TYPE  Vendor Payment
      --
      Open  sel_resource_book_currency;
      Fetch sel_resource_book_currency into v_line_currency_code;
      --
      If sel_resource_book_currency%notfound               OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_resource_book_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_resource_book_currency;
      --
    ElsIf p_finance_line_type = 'E' Then
      --
      --  * TYPE  Enrollment Charge
      --
      Open  sel_event_currency;
      Fetch sel_event_currency into v_line_currency_code;
      --
      If sel_event_currency%notfound                       OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_event_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_event_currency;
      --
    ElsIf p_finance_line_type = 'P'  Then
      --
      --  * TYPE  Pre-purchase deal
      --
      Open  sel_price_list_currency;
      Fetch sel_price_list_currency into v_line_currency_code;
      --
      If sel_price_list_currency%notfound                  OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_price_list_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_price_list_currency;
      --
    ElsIf p_finance_line_type = 'R'  Then
      --
      --  * TYPE  Resource Charge
      --
      Open  sel_resource_alloc_currency;
      Fetch sel_resource_alloc_currency into v_line_currency_code;
      --
      If sel_resource_alloc_currency%notfound              OR
         v_line_currency_code  is  null                    Then
        --
        Close sel_resource_alloc_currency;
        --
          fnd_message.set_name('OTA','OTA_13358_TFL_CURRENCY');
          fnd_message.raise_error;
        --
      End if;
      --
      Close sel_resource_alloc_currency;
      --
   -- End if;
    --
    p_currency_code  :=  v_line_currency_code;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End get_currency_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_type_constraints >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
procedure check_type_constraints (
	 p_finance_line_type		in varchar2
	,p_finance_header_id		in number
	,p_booking_id			in number
	,p_booking_deal_id		in number
	,p_resource_booking_id		in number
	,p_resource_allocation_id	in number
   ) is
-----------------
  cursor csr_tfh is
    select tfh.type,tfh.receivable_type
      from ota_finance_headers       tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
  v_proc                  varchar2(72) := g_package||'check_line_type';
  --
  l_tfh_type            varchar2(30);
  l_tfh_receivable_type varchar2(30);
--------------
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  csr_tfh;
  Fetch csr_tfh into l_tfh_type,l_tfh_receivable_type;
  Close csr_tfh;
  --
  check_line_type (
	 p_finance_line_type		=> p_finance_line_type
	,p_finance_header_type		=> l_tfh_type
	,p_receivable_type		=> l_tfh_receivable_type
        );
  --
  check_tfl_foreign_keys (
	 p_finance_header_id		=> p_finance_header_id
	,p_receivable_type		=> l_tfh_receivable_type
	,p_finance_line_type		=> p_finance_line_type
	,p_booking_id			=> p_booking_id
	,p_booking_deal_id		=> p_booking_deal_id
	,p_resource_booking_id		=> p_resource_booking_id
	,p_resource_allocation_id	=> p_resource_allocation_id
	);
  --
end check_type_constraints;
--
-- ---------------------------------------------------------------------------
-- |--------------------< check_unique_finance_line >-----------------------|
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
procedure check_unique_finance_line
                 (p_finance_line_id        in number
                 ,p_line_type              in varchar2
                 ,p_booking_id             in number
                 ,p_resource_booking_id    in number
                 ,p_resource_allocation_id in number ) is
--
  v_proc            varchar2(72) := g_package||'check_unique_finance_line';
--
  l_finance_line_id number;
--
cursor find_other_lines is
select finance_line_id
from   ota_finance_lines
where  (p_finance_line_id is null
     or p_finance_line_id <> finance_line_id)
and    cancelled_flag = 'N'
and  ((p_line_type = 'E' and
       booking_id = p_booking_id)
  or  (p_line_type = 'R' and
       resource_allocation_id = p_resource_allocation_id)
  or  (p_line_type = 'V'   and
       resource_booking_id = p_resource_booking_id));
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_line_type in ('E','R','V','CT') then
     open find_other_lines;
     fetch find_other_lines into l_finance_line_id;
     if find_other_lines%found then
        close find_other_lines;
        --
        fnd_message.set_name('OTA','OTA_13384_TFL_NO_DUPLICATES');
        fnd_message.raise_error;
     end if;
     close find_other_lines;
  end if;
  --
  hr_utility.set_location('Leaving:'|| v_proc, 10);
end;

--
-- ---------------------------------------------------------------------------
-- |--------------------< get_finance_header >-----------------------------|
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
procedure get_finance_header
  (p_finance_header_id          in     number
  ,p_tfh_type                   in out nocopy varchar2
  ,p_customer_id                in out nocopy number
  ,p_vendor_id                  in out nocopy number
  ,p_tfh_receivable_type        in out nocopy varchar2
  ,p_tfh_transfer_status        in out nocopy varchar2
  ,p_tfh_superseded_flag        in out nocopy varchar2
  ,p_tfh_cancelled_flag         in out nocopy varchar2) is
--
  l_proc            varchar2(72) := g_package||'get_finance_header';
--
cursor get_finance_header is
select type
,      customer_id
,      vendor_id
,      receivable_type
,      transfer_status
,      cancelled_flag
from   ota_finance_headers
where finance_header_id = p_finance_header_id;
--
cursor get_superseding_header is
select 'Y'
from ota_finance_headers
where superceding_header_id = p_finance_header_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open get_finance_header;
  fetch get_finance_header into p_tfh_type,
                                p_customer_id,
                                p_vendor_id,
                                p_tfh_receivable_type,
                                p_tfh_transfer_status,
                                p_tfh_cancelled_flag;
  close get_finance_header;
  --
  open get_superseding_header;
  fetch get_superseding_header into p_tfh_superseded_flag;
  if get_superseding_header%notfound then
     p_tfh_superseded_flag := 'N';
     close get_superseding_header;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end get_finance_header;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------< check_finance_header >---------------------------|
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
procedure check_finance_header(p_type                      in varchar2
                              ,p_superseded_flag             in varchar2
                              ,p_transfer_status           in varchar2
                              ,p_cancelled_flag            in varchar2
                              ,p_check_cancelled_flag      in boolean
                              ,p_check_successful_transfer in boolean) is
  l_proc            varchar2(72) := g_package||'check_finance_header';
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_type = 'C' then
     fnd_message.set_name('OTA','OTA_13490_TFL_INVALID_TFH');
     fnd_message.set_token('STEP','1');
     fnd_message.raise_error;
  end if;
  --
/* N.B. p_check_successful_transfer indicates that the mode currently running
        is CANCEL_HEADER_LINE. When performing this process the Finance Header
        for the lines to be processed has already been updated with
        Cancelled_flag = 'Y' and Transfer Status = 'ST' and
        Superseded_flag = 'Y'. We therefore do not want to repeat checks on
        these attributes.
*/
if p_check_successful_transfer then
  hr_utility.trace('Superseded Flag = '||p_superseded_flag);
  if p_superseded_flag = 'Y' then
     fnd_message.set_name('OTA','OTA_13490_TFL_INVALID_TFH');
     fnd_message.set_token('STEP','2');
     fnd_message.raise_error;
  end if;
end if;
  --
  if p_check_successful_transfer then
   hr_utility.trace('Transfer Status = '||p_transfer_status);
     if p_transfer_status = 'ST' then
        fnd_message.set_name('OTA','OTA_13490_TFL_INVALID_TFH');
        fnd_message.set_token('STEP','3');
        fnd_message.raise_error;
     end if;
   hr_utility.trace('After Transfer Status Check');
  end if;
     --
  if p_check_cancelled_flag   then
   hr_utility.trace('Cancelled Flag = '||p_cancelled_flag);
     if p_cancelled_flag = 'Y' then
        fnd_message.set_name('OTA','OTA_13490_TFL_INVALID_TFH');
        fnd_message.set_token('STEP','4');
        fnd_message.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end check_finance_header;

end ota_tfl_api_business_rules;

/
