--------------------------------------------------------
--  DDL for Package Body OTA_TFL_API_BUSINESS_RULES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFL_API_BUSINESS_RULES2" as
/* $Header: ottfl03t.pkb 115.6 2002/11/29 09:25:00 arkashya ship $ */
--
--
-- Global package name
--
g_package		varchar2(33)	:= '  ota_tfl_api_business_rules2.';
--
-- Global api dml status
--
g_api_dml		boolean;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_type_V_amounts >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type VENDOR-PAYMENT.
--
Procedure set_type_V_amounts
  (
   p_resource_booking_id     in       number
  ,p_standard_amount         in out  nocopy number
  ,p_unitary_amount          in out  nocopy  number
  ,p_money_amount            in out  nocopy  number
  ) is
  --
  v_absolute_price  number(11,2);
  v_proc            varchar2(72) := g_package||'set_type_V_amounts';
  --
  cursor sel_type_V_amounts is
    select trb.absolute_price
      from ota_resource_bookings     trb
     where trb.resource_booking_id   =    p_resource_booking_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_type_V_amounts;
  Fetch sel_type_V_amounts into v_absolute_price;
  --
  If sel_type_V_amounts%notfound then
    --
    Close sel_type_V_amounts;
    --
    fnd_message.set_name('OTA','OTA_13400_TFL_AMOUNT_V');
    fnd_message.raise_error;
    --
  Else
    --
    Close sel_type_V_amounts;
    --
    p_standard_amount  :=  null;
    p_unitary_amount   :=  null;
    --
    If p_money_amount is null  Then
    --
      p_money_amount     :=  v_absolute_price;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_type_V_amounts;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_type_R_amounts >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type RESOURCE CHARGE.
--
Procedure set_type_R_amounts
  (
   p_resource_allocation_id  in       number
  ,p_standard_amount         in out  nocopy  number
  ,p_unitary_amount          in out  nocopy  number
  ,p_money_amount            in out  nocopy  number
  ) is
  --
  v_absolute_price  number(11,2);
  v_proc            varchar2(72) := g_package||'set_type_R_amounts';
  --
  cursor sel_type_R_amounts is
    select trb.absolute_price
      from ota_resource_allocations     tra
         , ota_resource_bookings        trb
     where tra.resource_allocation_id   =    p_resource_allocation_id
       and tra.charge_delegate_flag     =    'Y'
       and trb.resource_booking_id      =    tra.equipment_resource_booking_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_type_R_amounts;
  Fetch sel_type_R_amounts into v_absolute_price;
  --
  If sel_type_R_amounts%notfound then
    --
    Close sel_type_R_amounts;
    --
    fnd_message.set_name('OTA','OTA_13401_TFL_AMOUNT_R');
    fnd_message.raise_error;
    --
  Else
    --
    Close sel_type_R_amounts;
    --
    p_standard_amount  :=  null;
    p_unitary_amount   :=  null;
    --
    If p_money_amount is null  Then
      --
      p_money_amount     :=  v_absolute_price;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_type_R_amounts;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_type_P_amounts >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type PRE-PURCHASE.
--
Procedure set_type_P_amounts
  (
   p_booking_deal_id         in       number
  ,p_currency_precision      in       number
  ,p_standard_amount         in out  nocopy  number
  ,p_unitary_amount          in out  nocopy  number
  ,p_money_amount            in out  nocopy  number
  ) is
  --
  v_discount_percentage  number(11,2);
  v_price_list_type      varchar2(30);
  v_single_unit_price    number(11,2);
  v_proc                 varchar2(72) := g_package||'set_type_P_amounts';
  --
  cursor sel_type_P_amounts is
    select nvl( tbd.discount_percentage, 0)
         , tpl.price_list_type
         , tpl.single_unit_price
      from ota_booking_deals         tbd
         , ota_price_lists           tpl
     where tbd.booking_deal_id       =    p_booking_deal_id
       and tbd.type                  =    'P'
       and tpl.price_list_id         =    tbd.price_list_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_type_P_amounts;
  Fetch sel_type_P_amounts into v_discount_percentage
                              , v_price_list_type
                              , v_single_unit_price;
  --
  If sel_type_P_amounts%notfound then
    --
    Close sel_type_P_amounts;
    --
    fnd_message.set_name('OTA','OTA_13402_TFL_AMOUNT_P');
    fnd_message.raise_error;
    --
  Else
    --
    Close sel_type_P_amounts;
    --
    If    v_price_list_type  =  'T'  Then
      --
      -- Pre-purchase deal arranged in training units
      --
      p_unitary_amount   :=  nvl( p_unitary_amount, 0);
      p_standard_amount  :=  null;
      --
      If p_money_amount is null  Then
        --
        p_money_amount   := round(v_single_unit_price*p_unitary_amount
                                 ,p_currency_precision);

        --
      End if;
      --
    ElsIf v_price_list_type  =  'M'  Then
      --
      -- Pre-purchase deal arranged in money
      --
      p_unitary_amount   :=  null;
      p_standard_amount  :=  null;
      p_money_amount     :=  p_money_amount;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_type_P_amounts;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_booking_deal_info >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Get the relevant existing booking deal informations.
--
Procedure get_booking_deal_info
  (
   p_booking_deal_id         in      number
  ,p_event_id                in      number
  ,p_book_deal_type             out  nocopy varchar2
  ,p_discount_percentage        out  nocopy number
  ,p_price_list_id              out nocopy  number
  ,p_tbd_event_id                   out nocopy  number
  ,p_activity_version_id        out nocopy  number
  ,p_category                   out  nocopy varchar2
  ,p_price_list_type            out  nocopy varchar2
  ,p_single_unit_price          out  nocopy number
  ) is
  --
  v_proc            varchar2(72) := g_package||'get_booking_deal_info';
  --
  cursor sel_book_deal_info is
    select tbd.type
         , nvl( tbd.discount_percentage, 0)
         , tbd.price_list_id
         , tbd.event_id
         , tbd.activity_version_id
         , tbd.category
         , tpl.price_list_type
         , nvl( tpl.single_unit_price, 0)
      from ota_booking_deals         tbd
         , ota_price_lists           tpl
         , ota_events                evt
     where tbd.booking_deal_id       =    p_booking_deal_id
       and tpl.price_list_id   (+)   =    tbd.price_list_id
       and evt.event_id              =    p_event_id
       and evt.course_start_date between
           nvl(tbd.start_date,evt.course_start_date)
       and nvl(tbd.end_date,evt.course_start_date);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_book_deal_info;
  Fetch sel_book_deal_info into p_book_deal_type
                              , p_discount_percentage
                              , p_price_list_id
                              , p_tbd_event_id
                              , p_activity_version_id
                              , p_category
                              , p_price_list_type
                              , p_single_unit_price;
  --
  If sel_book_deal_info%notfound then
    --
    Close sel_book_deal_info;
    --
    fnd_message.set_name('OTA','OTA_13403_TFL_BOOK_DEAL');
    fnd_message.raise_error;
    --
  End if;
  --
  Close sel_book_deal_info;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End get_booking_deal_info;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_type_E_tpe_amounts >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type ENROLLMENT. A booking deal does exist
--    and applied to PRICE_LIST.
--    The price list entry vendor must be the same vendor as on the event,
--    or the price list entry vendor may be null.
--
Procedure set_type_E_tpe_amounts
  (
   p_price_list_type         in       varchar2
  ,p_price_list_id           in       number
  ,p_event_id                in       number
  ,p_activity_version_id     in       number
  ,p_price_basis             in       varchar2
  ,p_standard_amount         in out nocopy   number
  ,p_unitary_amount          in out  nocopy  number
  ,p_money_amount            in out  nocopy  number
  ,p_single_unit_price       in       number
  ,p_currency_code           in       varchar2
  ,p_currency_precision      in       number
  ,p_discount_percentage     in       number
  ,p_number_of_places        in       number
  ,p_cust_no_places          in       number
  ) is
  --
  v_tpe_price       number;
  v_evt_price       number;
  v_evt_vendor_id   number(9);
  v_tvs_vendor_id   number(9);
  v_event_id        number;
  v_proc            varchar2(72) := g_package||'set_type_E_tpe_amounts';
  --
  cursor sel_type_E_tpe_event  is
select decode(p_price_list_type,'T',tpe.price
             ,tpe.price)
,      evt.standard_price
from   ota_events evt
,      ota_price_list_entries tpe
,      ota_price_lists        tpl
where evt.event_id = p_event_id
and   evt.currency_code = p_currency_code
and   tpe.price_basis   = p_price_basis
and   tpe.price_list_id =  p_price_list_id
and   tpl.price_list_id =  p_price_list_id
and   tpl.currency_code =  p_currency_code
and     (tpe.price_basis = 'S'
     or (tpe.price_basis = 'C'
       and p_cust_no_places between
           tpe.minimum_attendees and tpe.maximum_attendees))
and   evt.course_start_date between
      tpe.start_date and nvl(tpe.end_date,evt.course_start_date)
and ((  evt.activity_version_id = tpe.activity_version_id
     and not exists
       (select null
        from   ota_vendor_supplies tvs
        ,      ota_price_list_entries tpe2
        where  tvs.vendor_id = evt.vendor_id
        and    tvs.activity_version_id = evt.activity_version_id
        and    tpe2.vendor_supply_id    = tvs.vendor_supply_id
        and    tpe2.price_list_id       = p_price_list_id
        and evt.course_start_date between
            tpe2.start_date and nvl(tpe2.end_date,evt.course_start_date)
       )
     )
    or
     ( exists
       (select null
        from   ota_vendor_supplies tvs
        where  tvs.vendor_id = evt.vendor_id
        and    tvs.activity_version_id = evt.activity_version_id
        and    tpe.vendor_supply_id    = tvs.vendor_supply_id)
     ));
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Values of parameters
  --
  hr_utility.trace(p_price_list_type);
  hr_utility.trace(p_price_list_id);
  hr_utility.trace(p_event_id);
  hr_utility.trace(p_activity_version_id);
  hr_utility.trace(p_price_basis);
  hr_utility.trace(p_standard_amount);
  hr_utility.trace(p_unitary_amount);
  hr_utility.trace(p_money_amount);
  hr_utility.trace(p_single_unit_price);
  hr_utility.trace(p_currency_code);
  hr_utility.trace(p_currency_precision);
  hr_utility.trace(p_discount_percentage);
  hr_utility.trace(p_number_of_places);
  hr_utility.trace(p_cust_no_places);
  --
  --
    Open  sel_type_E_tpe_event;
    Fetch sel_type_E_tpe_event into v_tpe_price, v_evt_price;
      --
      -- * v_price includes either the value of money or trainig_unit
      --
      If sel_type_E_tpe_event%notfound then
        --
        Close sel_type_E_tpe_event;
        --
        fnd_message.set_name('OTA','OTA_13404_TFL_AMOUNT_EP');
        fnd_message.raise_error;
        --
      Else
        --
        Close sel_type_E_tpe_event;
        --
        --
        if p_price_basis = 'C' then
           null;
        else
	   p_standard_amount  :=  v_evt_price;
        end if;
        --
        If    p_price_list_type  =  'T'  Then
          --
          -- * Pre-purchase deal arranged in training units
          --
          If p_unitary_amount is null  Then
            --
            p_unitary_amount  :=
               round(v_tpe_price*p_number_of_places*
                          (1 - p_discount_percentage/100) ,2);
            --
          End if;
          --
          -- If dealing with training units always recalculate the money
          -- amount, the units may vary
             --
             p_money_amount   := round(
                                 p_unitary_amount*
                                 p_single_unit_price
                                 ,p_currency_precision);
          --
        ElsIf p_price_list_type  =  'M'  Then
          --
          -- * Pre-purchase or Discount deal arranged in money
          --
          p_unitary_amount  :=  null;
          --
          If p_money_amount is null  Then
          --
	    --
	    -- GP Changed so that standard price taken from price list
	    --
	    p_standard_amount := v_tpe_price;
            p_money_amount  :=
                   round(p_standard_amount*p_number_of_places*
                          (1 - p_discount_percentage/100)
                                  ,p_currency_precision);
            --
          End if;
          --
        End if;
        --
      End if;
  --
  hr_utility.trace(p_price_list_type);
  hr_utility.trace(p_price_list_id);
  hr_utility.trace(p_event_id);
  hr_utility.trace(p_activity_version_id);
  hr_utility.trace(p_price_basis);
  hr_utility.trace(p_standard_amount);
  hr_utility.trace(p_unitary_amount);
  hr_utility.trace(p_money_amount);
  hr_utility.trace(p_single_unit_price);
  hr_utility.trace(p_currency_code);
  hr_utility.trace(p_currency_precision);
  hr_utility.trace(p_discount_percentage);
  hr_utility.trace(p_number_of_places);
  hr_utility.trace(p_cust_no_places);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_type_E_tpe_amounts;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_type_E_evt_amounts >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type ENROLLMENT. A booking deal does exist
--    and applied to EVENT.
--
Procedure set_type_E_evt_amounts
  (
   p_event_id                in       number
  ,p_tbd_event_id            in       number
  ,p_price_basis             in       varchar2
  ,p_standard_amount         in out  nocopy  number
  ,p_unitary_amount          in out  nocopy  number
  ,p_money_amount            in out   nocopy number
  ,p_currency_code           in       varchar2
  ,p_currency_precision      in       number
  ,p_discount_percentage     in       number
  ,p_number_of_places        in       number
  ) is
  --
  v_standard_price  number(11,2);
  v_proc            varchar2(72) := g_package||'set_type_E_evt_amounts';
  --
  cursor sel_type_E_evt_event  is
    select evt.standard_price
      from ota_events                evt
     where evt.event_id              =    p_event_id
     and   evt.event_id              =    p_tbd_event_id
     and   evt.currency_code         =    p_currency_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- * Take Event for searching
  --
  If p_event_id is NOT null  Then
    --
    Open  sel_type_E_evt_event;
    Fetch sel_type_E_evt_event into v_standard_price;
    --
    If sel_type_E_evt_event%notfound then
      --
      Close sel_type_E_evt_event;
      --
    fnd_message.set_name('OTA','OTA_13405_TFL_SET_AMOUNT_E');
    fnd_message.raise_error;
      --
    Else
      --
      Close sel_type_E_evt_event;
      --
      if p_price_basis = 'C' then
         null;
      else
        p_standard_amount  :=  v_standard_price;
      end if;
      p_unitary_amount   :=  null;
      --
      If p_money_amount is null  Then
        --
        p_money_amount  :=
                   round(p_standard_amount*p_number_of_places*
                          (1 - p_discount_percentage/100)
                                  ,p_currency_precision);
        --
      End if;
      --
    End if;
    --
  End if;
End set_type_E_evt_amounts;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_type_E_tav_amounts >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type ENROLLMENT. A booking deal does exist
--    and applied to ACTIVITY_VERSION.
--
Procedure set_type_E_tav_amounts
  (
   p_event_id                in       number
  ,p_activity_version_id     in       number
  ,p_price_basis             in       varchar2
  ,p_standard_amount         in out  nocopy  number
  ,p_unitary_amount          in out  nocopy number
  ,p_money_amount            in out  nocopy  number
  ,p_currency_code           in       varchar2
  ,p_currency_precision      in       number
  ,p_discount_percentage     in       number
  ,p_number_of_places        in       number
  ) is
  --
  v_standard_price  number(11,2);
  v_proc            varchar2(72) := g_package||'set_type_E_tav_amounts';
  --
  cursor sel_type_E_tav_event  is
    select evt.standard_price
      from ota_events                evt
     where evt.event_id              =    p_event_id
     and   evt.activity_version_id   =    p_activity_version_id
     and   evt.currency_code         =    p_currency_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
    --
    Open  sel_type_E_tav_event;
    Fetch sel_type_E_tav_event into v_standard_price;
    --
    If sel_type_E_tav_event%notfound then
      --
      Close sel_type_E_tav_event;
      --
    fnd_message.set_name('OTA','OTA_13406_TFL_SET_AMOUNT_A');
    fnd_message.raise_error;
      --
    Else
      --
      Close sel_type_E_tav_event;
      --
      if p_price_basis = 'C' then
         null;
      else
         p_standard_amount  :=  v_standard_price;
      end if;
      p_unitary_amount   :=  null;
      --
      If p_money_amount is null  Then
        --
        p_money_amount  :=
                   round(p_standard_amount*p_number_of_places*
                          (1 - p_discount_percentage/100)
                                  ,p_currency_precision);
        --
      End if;
      --
    End if;
    --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_type_E_tav_amounts;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_type_E_cat_amounts >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type ENROLLMENT. A booking deal does exist
--    and applied to CATEGORY.
--
Procedure set_type_E_cat_amounts
  (
   p_event_id                in       number
  ,p_category                in       varchar2
  ,p_price_basis             in       varchar2
  ,p_standard_amount         in out  nocopy  number
  ,p_unitary_amount          in out  nocopy  number
  ,p_money_amount            in out  nocopy  number
  ,p_currency_code           in       varchar2
  ,p_currency_precision      in       number
  ,p_discount_percentage     in       number
  ,p_number_of_places        in       number
  ) is
  --
  v_standard_price  number(11,2);
  v_proc            varchar2(72) := g_package||'set_type_E_cat_amounts';
  --
  cursor sel_type_E_cat_event  is
    select evt.standard_price
      from ota_events                evt
         , ota_act_cat_inclusions    aci
     where evt.event_id              =    p_event_id
       and aci.activity_version_id   =    evt.activity_version_id
       and aci.activity_category     =    p_category
       and evt.currency_code         =    p_currency_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Take Event and Activity Version for searching
  --
    Open  sel_type_E_cat_event;
    Fetch sel_type_E_cat_event into v_standard_price;
    --
    If sel_type_E_cat_event%notfound then
      --
      Close sel_type_E_cat_event;
      --
    fnd_message.set_name('OTA','OTA_13407_TFL_SET_AMOUNT_C');
    fnd_message.raise_error;
      --
    Else
      --
      Close sel_type_E_cat_event;
      --
      if p_price_basis = 'C' then
         null;
      else
         p_standard_amount  :=  v_standard_price;
      end if;
      p_unitary_amount   :=  null;
      --
      If p_money_amount is null  Then
        --
        p_money_amount  :=
                   round(p_standard_amount*p_number_of_places*
                          (1 - p_discount_percentage/100)
                                  ,p_currency_precision);
        --
      End if;
      --
    End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_type_E_cat_amounts;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< set_no_deal_amounts >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    Set the amounts standard_amount, money_amount and unitary_amount
--    and finance_line is of type ENROLLMENT. A booking deal does NOT exist.
--
Procedure set_no_deal_amounts
  (
   p_event_id                in       number
  ,p_currency_code           in       varchar2
  ,p_price_basis             in       varchar2
  ,p_standard_amount         in out  nocopy  number
  ,p_unitary_amount          in out  nocopy number
  ,p_money_amount            in out  nocopy  number
  ,p_number_of_places        in       number
  ) is
  --
  v_standard_price  number;
  v_proc            varchar2(72) := g_package||'set_no_deal_amounts';
  --
  cursor sel_event_no_deal is
    select evt.standard_price
      from ota_events                evt
     where evt.event_id              =    p_event_id
     and   evt.currency_code         =    p_currency_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  --
    If p_event_id is not null then
    Open  sel_event_no_deal;
    Fetch sel_event_no_deal into v_standard_price;
    --
    If sel_event_no_deal%notfound then
      --
      Close sel_event_no_deal;
      --
    fnd_message.set_name('OTA','OTA_13408_TFL_SET_AMOUNT');
    fnd_message.raise_error;
      --
    Else
      --
      Close sel_event_no_deal;
      --
      if p_price_basis = 'C' then
         null;
      else
         p_standard_amount  :=  v_standard_price;
      end if;
      p_unitary_amount   :=  null;
      --
      If p_money_amount is null  Then
        --
        p_money_amount     :=  p_standard_amount*p_number_of_places;
        --
      End if;
      --
    End if;
    --
   End if;
--
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_no_deal_amounts;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< set_all_amounts >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--    Set the AMOUNTS standard_amount, money_amount and unitary_amount
--    depending on the finance_line type and the booking deal type.
--
Procedure set_all_amounts
  (
   p_finance_line_type        in      varchar2
  ,p_activity_version_id      in      number
  ,p_event_id                 in      number
  ,p_price_basis              in      varchar2 default null
  ,p_booking_id               in      number
  ,p_number_of_places         in      number default 1
  ,p_booking_deal_id          in      number
  ,p_resource_allocation_id   in      number
  ,p_resource_booking_id      in      number
  ,p_currency_code            in      varchar2
  ,p_standard_amount          in out  nocopy number
  ,p_money_amount             in out  nocopy number
  ,p_unitary_amount           in out  nocopy number
  ) is
  --
  v_book_deal_type       varchar2(30);
  v_discount_percentage  number;
  v_price_list_type      varchar(30);
  v_single_unit_price    number(11,2);
  v_price_list_id        number(9);
  v_event_id             number(9);
  v_tbd_event_id         number(9);
  v_activity_version_id  number(9);
  v_category             varchar2(30);
  v_currency_precision   number;
  v_number_of_places     number;
  v_cust_no_places       number;
  v_price_basis          varchar2(30);
  v_proc                 varchar2(72) := g_package||'set_all_amounts';
  --
  cursor get_currency_precision is
  select precision
  from   fnd_currencies
  where  currency_code = p_currency_code;
  --
  cursor get_booking is
  select tdb.event_id
  ,      tdb.number_of_places
  ,      nvl(evt.price_basis,'S')
  from   ota_delegate_bookings  tdb
  ,      ota_events             evt
  where  tdb.booking_id = p_booking_id
  and    tdb.event_id   = evt.event_id;

Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open get_currency_precision;
  fetch get_currency_precision into v_currency_precision;
  close get_currency_precision;
  --
   If   p_finance_line_type  =  'V' Then
    --
    --  * VENDOR PAYMENT
    --
     set_type_V_amounts( p_resource_booking_id
                      , p_standard_amount
                      , p_unitary_amount
                      , p_money_amount );
    --
   ElsIf p_finance_line_type  =  'R'  Then
    --
    --  * RESOURCE CHARGE
    --
     set_type_R_amounts( p_resource_allocation_id
                      , p_standard_amount
                      , p_unitary_amount
                      , p_money_amount );
    --
   ElsIf p_finance_line_type  =  'P'  Then
    --
    --  * PRE-PURCHASE
    --
     set_type_P_amounts( p_booking_deal_id
                      , v_currency_precision
                      , p_standard_amount
                      , p_unitary_amount
                      , p_money_amount );
    --
   ElsIf p_finance_line_type  =  'E' Then
    --
    --  * ENROLLMENT CHARGE
    --
     if p_event_id is null then
       open get_booking;
       fetch get_booking into v_event_id
                             ,v_number_of_places
                             ,v_price_basis;
       close get_booking;
     else
       v_event_id := p_event_id;
       v_number_of_places := p_number_of_places;
       v_price_basis := p_price_basis;
     end if;
    --
/*
  Set the number of places to 1 if the Price Basis is 'Customer' because
  the standard price represents the price for the entire booking (not per place)
  --
  Store the actual number of places (used to derive price from Customer based
  price list)
*/
     if v_price_basis = 'C' then
       v_number_of_places := 1;
       v_cust_no_places   := p_number_of_places;
     end if;
    --
    --
     If p_booking_deal_id is NOT null Then
      --
       get_booking_deal_info( p_booking_deal_id
                           , v_event_id
                           , v_book_deal_type
                           , v_discount_percentage
                           , v_price_list_id
                           , v_tbd_event_id
                           , v_activity_version_id
                           , v_category
                           , v_price_list_type
                           , v_single_unit_price );
      --
/*
  If the Price Basis is 'C' then the Standard Amount is used to calculate
  the monetary and unitary amounts.

  However the SQL that is used to retrieve the Standard Price for Price Basis
  of 'S' is still used to establish that the Event and Booking Deals are
  compatible.
*/
       If    v_book_deal_type  =  'P'  Then
        --
        --  * PRE-PURCHASE DEAL
        --
         set_type_E_tpe_amounts( v_price_list_type
                            , v_price_list_id
                            , v_event_id
                            , p_activity_version_id
                            , v_price_basis
                            , p_standard_amount
                            , p_unitary_amount
                            , p_money_amount
                            , v_single_unit_price
                            , p_currency_code
                            , v_currency_precision
                            , v_discount_percentage
                            , v_number_of_places
                            , v_cust_no_places);
        --
       Elsif v_book_deal_type  =  'D'  Then
        --
        --  * DISCOUNT DEAL
--   The discount deal must be for either the event of the delegate booking,
--   the activity version on the event, or the activity must be within the
--   category defined on the discount deal, or the activity is included within
--   the price list for the referenced discont deal. When the discount deal
--   is for a price list, if the vendor supplier is entered on the
--   price list entry then the supplier of the event must match it.
--   The starting price for the discount comes from this price list
--   entry. When a discount is applied, the original value is placed in the
--   STANDARD_AMOUNT attribute.
        --
         If    v_price_list_id       is NOT null  Then
          --
           set_type_E_tpe_amounts( v_price_list_type
                              , v_price_list_id
                              , v_event_id
                              , p_activity_version_id
                              , v_price_basis
                              , p_standard_amount
                              , p_unitary_amount
                              , p_money_amount
                              , v_single_unit_price
                              , p_currency_code
                              , v_currency_precision
                              , v_discount_percentage
                              , v_number_of_places
                              , v_cust_no_places);
          --
         ElsIf v_tbd_event_id            is NOT null  Then
          --
           set_type_E_evt_amounts( v_event_id
                                , v_tbd_event_id
                                , v_price_basis
                                , p_standard_amount
                                , p_unitary_amount
                                , p_money_amount
                                , p_currency_code
                                , v_currency_precision
                                , v_discount_percentage
                                , v_number_of_places);
          --
         ElsIf v_activity_version_id is NOT null  Then
          --
           set_type_E_tav_amounts( v_event_id
                                , v_activity_version_id
                                , v_price_basis
                                , p_standard_amount
                                , p_unitary_amount
                                , p_money_amount
                                , p_currency_code
                                , v_currency_precision
                                , v_discount_percentage
                                , v_number_of_places);
          --
         ElsIf v_category            is NOT null  Then
          --
           set_type_E_cat_amounts( v_event_id
                                , v_category
                                , v_price_basis
                                , p_standard_amount
                                , p_unitary_amount
                                , p_money_amount
                                , p_currency_code
                                , v_currency_precision
                                , v_discount_percentage
                                , v_number_of_places);
          --
         End if;
        --
       End if;
      --
     Else
      --
      -- * NO DEAL for the booking is available
      --
         set_no_deal_amounts( v_event_id
                           , p_currency_code
                           , v_price_basis
                           , p_standard_amount
                           , p_unitary_amount
                           , p_money_amount
                           , v_number_of_places);
      --
     End if;
    --
   End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_all_amounts;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_finance_line >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure copy_finance_line
  (
   p_finance_header_id_to   in      number
  ,p_rec_finance_line       in out nocopy  ota_finance_lines%rowtype
  ,p_transaction_type       in      varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'copy_finance_line';
  l_finance_line_id       number := null;
  l_finance_header_id     number := p_finance_header_id_to;
  l_transfer_status       varchar2(2) := 'NT';
  --Bug 1664464
  l_transfer_date	  ota_finance_lines.transfer_date%TYPE := null;
  --Bug 1664464
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- For 7.3.2
  -- p_rec_finance_line.finance_header_id  :=  p_finance_header_id_to;
  -- p_rec_finance_line.finance_line_id    :=  null;
  -- p_rec_finance_line.transfer_status    :=  'NT';
  --
  ota_tfl_api_ins.ins
                 ( l_finance_line_id
                 , l_finance_header_id
                 , p_rec_finance_line.cancelled_flag
                 , p_rec_finance_line.date_raised
                 , p_rec_finance_line.line_type
                 , p_rec_finance_line.object_version_number
                 , p_rec_finance_line.sequence_number
                 , l_transfer_status
                 , p_rec_finance_line.comments
                 , p_rec_finance_line.currency_code
                 , p_rec_finance_line.money_amount
                 , p_rec_finance_line.standard_amount
                 , p_rec_finance_line.trans_information_category
                 , p_rec_finance_line.trans_information1
                 , p_rec_finance_line.trans_information10
                 , p_rec_finance_line.trans_information11
                 , p_rec_finance_line.trans_information12
                 , p_rec_finance_line.trans_information13
                 , p_rec_finance_line.trans_information14
                 , p_rec_finance_line.trans_information15
                 , p_rec_finance_line.trans_information16
                 , p_rec_finance_line.trans_information17
                 , p_rec_finance_line.trans_information18
                 , p_rec_finance_line.trans_information19
                 , p_rec_finance_line.trans_information2
                 , p_rec_finance_line.trans_information20
                 , p_rec_finance_line.trans_information3
                 , p_rec_finance_line.trans_information4
                 , p_rec_finance_line.trans_information5
                 , p_rec_finance_line.trans_information6
                 , p_rec_finance_line.trans_information7
                 , p_rec_finance_line.trans_information8
                 , p_rec_finance_line.trans_information9
                 , l_transfer_date -- p_rec_finance_line.transfer_date Bug 1664464
                 , p_rec_finance_line.transfer_message
                 , p_rec_finance_line.unitary_amount
                 , p_rec_finance_line.booking_deal_id
                 , p_rec_finance_line.booking_id
                 , p_rec_finance_line.resource_allocation_id
                 , p_rec_finance_line.resource_booking_id
                 , p_rec_finance_line.tfl_information_category
                 , p_rec_finance_line.tfl_information1
                 , p_rec_finance_line.tfl_information2
                 , p_rec_finance_line.tfl_information3
                 , p_rec_finance_line.tfl_information4
                 , p_rec_finance_line.tfl_information5
                 , p_rec_finance_line.tfl_information6
                 , p_rec_finance_line.tfl_information7
                 , p_rec_finance_line.tfl_information8
                 , p_rec_finance_line.tfl_information9
                 , p_rec_finance_line.tfl_information10
                 , p_rec_finance_line.tfl_information11
                 , p_rec_finance_line.tfl_information12
                 , p_rec_finance_line.tfl_information13
                 , p_rec_finance_line.tfl_information14
                 , p_rec_finance_line.tfl_information15
                 , p_rec_finance_line.tfl_information16
                 , p_rec_finance_line.tfl_information17
                 , p_rec_finance_line.tfl_information18
                 , p_rec_finance_line.tfl_information19
                 , p_rec_finance_line.tfl_information20
                 , p_validate           =>   false
                 , p_transaction_type => p_transaction_type);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End copy_finance_line;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_lines_to_new_header >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to copy all finance lines from one finance
--    header to another. Only those lines with a cancelled_flag = 'N'
--    will be copied.
--
Procedure copy_lines_to_new_header
  (
   p_finance_header_id_from       in   number
  ,p_finance_header_id_to         in   number
  ) is
  --
  l_rec_finance_line      ota_finance_lines%rowtype;
  v_proc                  varchar2(72) := g_package||'copy_lines_to_new_header';
  --
  cursor sel_finance_lines is
    select *
      from ota_finance_lines         tfl
     where tfl.finance_header_id     =    p_finance_header_id_from
     and   tfl.cancelled_flag        =    'N'
     order by sequence_number;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id_from  is NOT null  Then
    --
    If p_finance_header_id_to  is  null                      OR
       p_finance_header_id_to  =   p_finance_header_id_from  Then
      --
    fnd_message.set_name('OTA','OTA_13359_TFL_COPY_LINES');
    fnd_message.raise_error;
      --
    End if;
    --
    Open  sel_finance_lines;
    Fetch sel_finance_lines into l_rec_finance_line;
    --
    If sel_finance_lines%notfound then
      --
      Close sel_finance_lines;
      --
    Else
      --
      Loop
        --
        Exit when sel_finance_lines%notfound;
        --
        hr_utility.trace('Finance Line ID = '||to_char(l_rec_finance_line.finance_line_id)) ;
        copy_finance_line( p_finance_header_id_to
                         , l_rec_finance_line
                         ,p_transaction_type => 'COPY');
        --
        Fetch sel_finance_lines into l_rec_finance_line;
        --
      End Loop;
      --
      Close sel_finance_lines;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End copy_lines_to_new_header;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_cancel_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVAT
-- Description:
--
--    A procedure is required to set the attribute cancelled_flag
--    The new cancelled flag is passed in as a parameter
--
Procedure update_cancel_flag
  (
   p_rec_cancel     in out   nocopy    ota_finance_lines%rowtype
  ,p_new_cancelled_flag  in     varchar2
  ,p_transaction_type    in varchar2
  ,p_object_version_number in out nocopy  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'update_cancel_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_rec_cancel.finance_line_id is null  Then
    --
    fnd_message.set_name('OTA','OTA_13360_TFL_CANCEL_LINES');
    fnd_message.raise_error;
    --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  Else
    --
    -- Cancel the finance_lines record
    --
    p_rec_cancel.cancelled_flag  :=  p_new_cancelled_flag;
    --
  hr_utility.set_location('Entering:'|| v_proc, 15);
    ota_tfl_api_upd.upd
               ( p_finance_line_id => p_rec_cancel.finance_line_id
               , p_date_raised     => p_rec_cancel.date_raised
               , p_cancelled_flag => p_rec_cancel.cancelled_flag
               , p_object_version_number=>  p_rec_cancel.object_version_number
               , p_sequence_number  => p_rec_cancel.sequence_number
               , p_validate           =>   false
               ,p_transaction_type => p_transaction_type);
    --
    p_object_version_number := p_rec_cancel.object_version_number;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 15);
  --
End update_cancel_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< set_cancel_flag_for_header>-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to call the cancellation procedure for
--    each finance line defined for a given finance header.
--
Procedure set_cancel_flag_for_header
  (
   p_finance_header_id       in   number
  ,p_new_cancelled_flag      in   varchar2
  ) is
  --
  v_rec_finance_line      ota_finance_lines%rowtype;
  l_transaction_type    varchar2(30);
  v_proc                varchar2(72) := g_package||'set_cancel_flag_for_header';
  v_ovn number;
  --
  cursor sel_finance_lines is
    select *
      from ota_finance_lines         tfl
     where tfl.finance_header_id     =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_header_id is NOT null  Then
    --
    Open  sel_finance_lines;
    Fetch sel_finance_lines into v_rec_finance_line;
    --
    If sel_finance_lines%notfound then
      --
      Close sel_finance_lines;
      --
    fnd_message.set_name('OTA','OTA_13409_TFL_SET_CANCEL');
    fnd_message.raise_error;
      --
    Else
      --
      Loop
        --
        Exit when sel_finance_lines%notfound;
        --
        If v_rec_finance_line.cancelled_flag <> p_new_cancelled_flag  Then
          --
             if p_new_cancelled_flag = 'Y' then
                l_transaction_type := 'CANCEL_HEADER_LINE';
             else
                l_transaction_type := 'REINSTATE_HEADER_LINE';
             end if;
             --
             update_cancel_flag  ( v_rec_finance_line
                                 , p_new_cancelled_flag
                      ,p_transaction_type => l_transaction_type
                      ,p_object_version_number => v_ovn);
          --
        End if;
        --
        Fetch sel_finance_lines into v_rec_finance_line;
        --
      End Loop;
      --
      Close sel_finance_lines;
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_cancel_flag_for_header;
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_finance_line >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--    A procedure is required to set the attribute cancelled_flag to 'Y'.
--
Procedure cancel_finance_line
  (
   p_finance_line_id     in      number
  ,p_cancelled_flag      in out  nocopy varchar2
  ,p_transfer_status     in      varchar2
  ,p_finance_header_id   in      number
  ,p_object_version_number in out nocopy number
  ,p_validate            in      boolean
  ,p_commit              in      boolean default FALSE
  ) is
  --
  v_proc                   varchar2(72) := g_package||'cancel_finance_line';
  v_header_transfer_status varchar2(30);
  v_rec_finance_line       ota_finance_lines%rowtype;
  --
  cursor sel_finance_line is
    select *
      from ota_finance_lines         tfl
     where tfl.finance_line_id       =    p_finance_line_id;
  --
  cursor sel_finance_header is
    select tfh.transfer_status
      from ota_finance_headers       tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 1);
  --
  If p_finance_line_id is null  Then
  hr_utility.set_location('Entering:'|| v_proc, 2);
    --
    fnd_message.set_name('OTA','OTA_13410_TFL_CANCEL_LINES');
    fnd_message.set_token('STEP','1');
    fnd_message.raise_error;
    --
  ElsIf p_cancelled_flag  =  'Y'  Then
  hr_utility.set_location('Entering:'|| v_proc, 3);
    --
    -- * Line is cancelled
    --
    fnd_message.set_name('OTA','OTA_13410_TFL_CANCEL_LINES');
    fnd_message.set_token('STEP','2');
    fnd_message.raise_error;
    --
/*
  ElsIf p_transfer_status  =  'ST'  Then
  hr_utility.set_location('Entering:'|| v_proc, 4);
    --
    -- * Line has been successful transferred
    --
    fnd_message.set_name('OTA','OTA_13410_TFL_CANCEL_LINES');
    fnd_message.set_token('STEP','3');
    fnd_message.raise_error;
*/
  Else
    --
/*
    If p_finance_header_id is NOT null  Then
      --
      Open  sel_finance_header;
      Fetch sel_finance_header into v_header_transfer_status;
      --
      If sel_finance_header%notfound then
        hr_utility.set_location('Entering:'|| v_proc, 6);
        --
        Close sel_finance_header;
        --
        fnd_message.set_name('OTA','OTA_13410_TFL_CANCEL_LINES');
        fnd_message.set_token('STEP','4');
        fnd_message.raise_error;
        --
      ElsIf v_header_transfer_status = 'ST'  Then
        hr_utility.set_location('Entering:'|| v_proc, 7);
        --
        -- * Finance Header has been successfull transferred
        --
        fnd_message.set_name('OTA','OTA_13410_TFL_CANCEL_LINES');
      fnd_message.set_token('STEP','5');
        fnd_message.raise_error;
        --
      End if;
      --
    End if;
*/
    --
    Open  sel_finance_line;
    Fetch sel_finance_line into v_rec_finance_line;
    --
    If sel_finance_line%notfound then
      hr_utility.set_location('Entering:'|| v_proc, 8);
      --
      Close sel_finance_line;
      --
      fnd_message.set_name('OTA','OTA_13410_TFL_CANCEL_LINES');
      fnd_message.set_token('STEP','6');
      fnd_message.raise_error;
      --
    Else
      --
      Close sel_finance_line;
      --
      -- * Cancel the Finance Line record
      --
      If p_validate = false  Then
        --
        update_cancel_flag (p_rec_cancel  => v_rec_finance_line
                           ,p_new_cancelled_flag => 'Y'
                           ,p_transaction_type => 'CANCEL_LINE'
                           ,p_object_version_number => p_object_version_number);
        --
        p_cancelled_flag := 'Y';
        --
      End if;
      --
    End if;
    --
  End if;
  --
  if p_commit then
     commit;
  end if;
  hr_utility.set_location(' Leaving:'|| v_proc, 20);
  --
End cancel_finance_line;
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_finance_line >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--    Overloaded procedure to allow object version number to be ignored from
--    Finance Line Button
--
Procedure cancel_finance_line
  (
   p_finance_line_id     in      number
  ,p_cancelled_flag      in out  nocopy varchar2
  ,p_transfer_status     in      varchar2
  ,p_finance_header_id   in      number
  ,p_validate            in      boolean
  ,p_commit              in      boolean default FALSE
  ) is
  --
  v_proc                   varchar2(72) := g_package||'cancel_finance_line';
  l_ovn number;
  --
begin
   hr_utility.set_location('Entering:'|| v_proc, 5);
   --
   cancel_finance_line(p_finance_line_id
                      ,p_cancelled_flag
                      ,p_transfer_status
                      ,p_finance_header_id
                      ,l_ovn
                      ,p_validate
                      ,p_commit);
   --
   hr_utility.set_location('Entering:'|| v_proc, 10);
end cancel_finance_line;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< recancel_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--    A procedure is required to set the attribute cancelled_flag to 'N'.
--
Procedure recancel_finance_line
  (
   p_finance_line_id     in      number
  ,p_cancelled_flag      in out nocopy  varchar2
  ,p_transfer_status     in      varchar2
  ,p_finance_header_id   in      number
  ,p_validate            in      boolean
  ,p_commit              in      boolean default FALSE
  ) is
  --
  v_proc                   varchar2(72) := g_package||'recancel_finance_line';
  v_header_transfer_status varchar2(30);
  v_rec_finance_line       ota_finance_lines%rowtype;
  v_ovn number;
  --
  cursor sel_finance_line is
    select *
      from ota_finance_lines         tfl
     where tfl.finance_line_id       =    p_finance_line_id;
  --
  cursor sel_finance_header is
    select tfh.transfer_status
      from ota_finance_headers       tfh
     where tfh.finance_header_id     =    p_finance_header_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_finance_line_id is null  Then
    --
    fnd_message.set_name('OTA','OTA_13361_TFL_RECANCEL_LINES');
      fnd_message.set_token('STEP','1');
    fnd_message.raise_error;
    --
  ElsIf p_cancelled_flag  =  'N'  Then
    --
    -- * Line is not cancelled
    --
    fnd_message.set_name('OTA','OTA_13361_TFL_RECANCEL_LINES');
      fnd_message.set_token('STEP','2');
    fnd_message.raise_error;
    --
/*
  ElsIf p_transfer_status  =  'ST'  Then
    --
    -- * Line has been successful transferred
    --
    fnd_message.set_name('OTA','OTA_13361_TFL_RECANCEL_LINES');
      fnd_message.set_token('STEP','3');
    fnd_message.raise_error;
    --
*/
  Else
    --
/*
    If p_finance_header_id is NOT null  Then
      --
      Open  sel_finance_header;
      Fetch sel_finance_header into v_header_transfer_status;
      --
      If sel_finance_header%notfound then
        --
        Close sel_finance_header;
        --
    fnd_message.set_name('OTA','OTA_13361_TFL_RECANCEL_LINES');
      fnd_message.set_token('STEP','4');
    fnd_message.raise_error;
        --
      ElsIf v_header_transfer_status = 'ST'  Then
        --
        -- * Finance Header has been successfull transferred
        --
    fnd_message.set_name('OTA','OTA_13361_TFL_RECANCEL_LINES');
      fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
        --
      End if;
      --
    End if;
*/
    --
    Open  sel_finance_line;
    Fetch sel_finance_line into v_rec_finance_line;
    --
    If sel_finance_line%notfound then
      --
      Close sel_finance_line;
      --
    fnd_message.set_name('OTA','OTA_13361_TFL_RECANCEL_LINES');
      fnd_message.set_token('STEP','6');
    fnd_message.raise_error;
      --
    Else
      --
      Close sel_finance_line;
      --
      -- * Re-Cancel the Finance Line record
      --
      If p_validate = false Then
        --
        update_cancel_flag ( p_rec_cancel  => v_rec_finance_line
                           , p_new_cancelled_flag => 'N'
                           ,p_transaction_type => 'REINSTATE_LINE'
                           ,p_object_version_number => v_ovn);
        --
        p_cancelled_flag := 'N';
        --
      End if;
      --
    End if;
    --
  End if;
  --
  if p_commit then
     commit;
  end if;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End recancel_finance_line;
--
-- ----------------------------------------------------------------------------
-- |------------------------< change_line_for_header >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- A procedure is required to update all the finance lines for a header
--
-- This can be used for a number of types of update
-- The ones used so far are
--
-- i. Update the transfer status of all the lines having the same transfer
--    as the header
--
Procedure change_line_for_header
  (
   p_finance_header_id      in      number
  ,p_new_transfer_status    in      varchar2
  ,p_old_transfer_status    in      varchar2
  ,p_include_cancelled      in      varchar2 default 'N'
  ) is
--
  v_proc           varchar2(72) := g_package||'change_line_for_header';
  l_finance_line_id  number;
  l_transfer_status  varchar2(30);
  l_date_raised      date;
  l_object_version_number number;
  l_sequence_number number;
  --
  cursor get_finance_line is
  select finance_line_id
  ,      date_raised
  ,      object_version_number
  ,      sequence_number
  ,      transfer_status
  from   ota_finance_lines
  where  finance_header_id = p_finance_header_id
  and   ((p_include_cancelled = 'N'
      and cancelled_flag = 'N')
      or (p_include_cancelled <> 'N'));
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open get_finance_line;
  fetch get_finance_line into l_finance_line_id
                       ,      l_date_raised
                       ,      l_object_version_number
                       ,      l_sequence_number
                       ,      l_transfer_status;
  --
  while get_finance_line%found loop
    if l_transfer_status = p_old_transfer_status then
       ota_tfl_api_upd.upd(p_finance_line_id       => l_finance_line_id
                      ,p_finance_header_id     => p_finance_header_id
                      ,p_date_raised           => l_date_raised
                      ,p_object_version_number => l_object_version_number
                      ,p_sequence_number       => l_sequence_number
                      ,p_transfer_status       => p_new_transfer_status
                      ,p_transaction_type => 'CHANGE_HEADER_LINE'
                       );
    end if;
    --
    fetch get_finance_line into l_finance_line_id
                       ,      l_date_raised
                       ,      l_object_version_number
                       ,      l_sequence_number
                       ,      l_transfer_status;
  end loop;
  --
  close get_finance_line;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End change_line_for_header;
--
--
-- ----------------------------------------------------------------------------
end ota_tfl_api_business_rules2;

/
