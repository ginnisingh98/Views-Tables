--------------------------------------------------------
--  DDL for Package Body OTA_FINANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FINANCE" as
/* $Header: otfin01t.pkb 115.2 99/07/16 00:52:17 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_finance.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_finance_line >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_finance_line ( p_finance_header_id in number   default null,
                                p_booking_id        in number   default null,
                                p_currency_code     in varchar2 default null,
                                p_standard_amount   in number   default null,
                                p_unitary_amount    in number   default null,
                                p_money_amount      in number   default null,
                                p_booking_deal_id   in number   default null,
                                p_booking_deal_type in varchar2 default null,
                                p_resource_booking_id in number default null,
                                p_resource_allocation_id in number default null,
                                p_finance_line_id   out number) is
  --
  l_proc  varchar2(72) := g_package||'create_finance_line';
  --
  l_cancelled_flag       varchar2(1) := 'N';
  l_line_type            varchar2(30);
  l_transfer_status      varchar2(30) := 'NT';
  l_sequence_number      number;
  l_ovn                  number;
  l_date_raised          date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_resource_booking_id is not null then
     l_line_type := 'V';
  elsif p_resource_allocation_id is not null then
     l_line_type := 'R';
  elsif p_booking_id is not null then
     l_line_type := 'E';
  elsif p_booking_deal_id is not null then
     l_line_type := 'P';
  end if;
  --
  ota_tfl_api_ins.ins
                  (p_finance_line_id       => p_finance_line_id,
                   p_finance_header_id     => p_finance_header_id,
                   p_cancelled_flag        => l_cancelled_flag,
                   p_date_raised           => l_date_raised,
                   p_line_type             => l_line_type,
                   p_transfer_status       => l_transfer_status,
                   p_object_version_number => l_ovn,
                   p_sequence_number       => l_sequence_number,
                   p_currency_code         => p_currency_code,
                   p_standard_amount       => p_standard_amount,
                   p_unitary_amount        => p_unitary_amount,
                   p_money_amount          => p_money_amount,
                   p_booking_deal_id       => p_booking_deal_id,
                   p_booking_id            => p_booking_id,
                   p_resource_booking_id   => p_resource_booking_id,
                   p_resource_allocation_id => p_resource_allocation_id,
                   p_transaction_type      => 'INSERT');
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End create_finance_line;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_finance_line >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_finance_line ( p_finance_header_id     in number default null,
                                p_finance_line_id       in number,
                                p_object_version_number in out number,
                                p_standard_amount       in number default null,
                                p_unitary_amount        in number default null,
                                p_money_amount          in number default null,
                                p_booking_deal_id       in number default null
                              ) is
  --
  l_sequence_number number;
  l_date_raised     date;
  l_proc            varchar2(72) := g_package||'update_finance_line';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ota_tfl_api_upd.upd
                  (p_finance_line_id       => p_finance_line_id,
                   p_finance_header_id     => p_finance_header_id,
                   p_date_raised           => l_date_raised,
                   p_sequence_number       => l_sequence_number,
                   p_object_version_number => p_object_version_number,
                   p_standard_amount       => p_standard_amount,
                   p_unitary_amount        => p_unitary_amount,
                   p_money_amount          => p_money_amount,
                   p_booking_deal_id       => p_booking_deal_id,
                   p_transaction_type      => 'UPDATE');
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_finance_line;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< maintain_finance_line >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure maintain_finance_line
             (p_finance_header_id       in     number   default null,
              p_booking_id              in     number   default null,
              p_currency_code           in     varchar2 default null,
              p_object_version_number   in out number   ,
              p_standard_amount         in     number   default null,
              p_unitary_amount          in     number   default null,
              p_money_amount            in     number   default null,
              p_booking_deal_id         in     number   default null,
              p_booking_deal_type       in     varchar2 default null,
              p_resource_booking_id     in     number   default null,
              p_resource_allocation_id  in     number   default null,
              p_finance_line_id         in out number,
              p_cancel_finance_line     in     boolean  default false) is
  --
  l_proc            varchar2(72) := g_package||'maintain_finance_line';
  l_cancelled_flag  varchar2(1);
  l_dummy           varchar2(1);
  --
  cursor c_finance_header_type is
    select null
    from   ota_finance_headers
    where  finance_header_id = p_finance_header_id
    and    receivable_type = 'PRE-PURCHASE USE';
  --
begin
--
  hr_utility.set_location(' Entering : '||l_proc, 10);
  --
  -- Check that if we are dealing with a pre-purchase finance line
  -- that the agreement is also of type pre-purchase.
  --
  if p_booking_deal_type <> 'P' then
    --
    open c_finance_header_type;
      --
      fetch c_finance_header_type into l_dummy;
      --
      if c_finance_header_type%found then
        --
	close c_finance_header_type;
	fnd_message.set_name ('OTA','OTA_13588_NOT_PRE_PURCHASE');
	fnd_message.raise_error;
        --
      end if;
      --
    close c_finance_header_type;
    --
  end if;
  --
  if p_cancel_finance_line then
     --
     if (p_booking_id is not null and
	ota_tdb_bus.finance_line_exists(p_booking_id,'N')) or
	p_resource_booking_id is not null then
        --
        l_cancelled_flag := 'N';
	--
        ota_tfl_api_business_rules2.cancel_finance_line
           (p_finance_line_id       => p_finance_line_id
            ,p_cancelled_flag        => l_cancelled_flag
            ,p_transfer_status       => ''
            ,p_finance_header_id     => p_finance_header_id
            ,p_object_version_number => p_object_version_number
            ,p_validate              => FALSE);
     end if;
     --
  elsif p_finance_line_id is null then
    --
    create_finance_line ( p_finance_header_id      => p_finance_header_id,
                          p_booking_id             => p_booking_id,
                          p_currency_code          => p_currency_code,
                          p_standard_amount        => p_standard_amount,
                          p_unitary_amount         => p_unitary_amount,
                          p_money_amount           => p_money_amount,
                          p_booking_deal_id        => p_booking_deal_id,
                          p_booking_deal_type      => p_booking_deal_type,
                          p_resource_booking_id    => p_resource_booking_id,
                          p_resource_allocation_id => p_resource_allocation_id,
                          p_finance_line_id        => p_finance_line_id);
    --
    p_object_version_number := 1;
    --
  else
    --
    update_finance_line ( p_finance_header_id     => p_finance_header_id,
                          p_finance_line_id       => p_finance_line_id,
                          p_object_version_number => p_object_version_number,
                          p_standard_amount       => p_standard_amount,
                          p_unitary_amount        => p_unitary_amount,
                          p_money_amount          => p_money_amount,
                          p_booking_deal_id       => p_booking_deal_id);
    --
  end if;
  --
  hr_utility.set_location(' Leaving : '||l_proc, 10);
end;
--
function get_deal_unit_based(p_booking_deal_id in number) return boolean is
  --
  l_price_list_type varchar2(30);
  --
  cursor get_price_list is
    select tpl.price_list_type
    from   ota_price_lists tpl
           ,ota_booking_deals tbd
    where  tbd.booking_deal_id = p_booking_deal_id
    and    tpl.price_list_id (+) = tbd.price_list_id;
  --
begin
  open get_price_list;
    --
    fetch get_price_list into l_price_list_type;
    --
  close get_price_list;
  --
  return(l_price_list_type = 'T');
  --
end get_deal_unit_based;
--
end ota_finance;

/
