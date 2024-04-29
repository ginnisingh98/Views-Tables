--------------------------------------------------------
--  DDL for Package Body OTA_TPC_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPC_BUS1" as
/* $Header: ottpcrhi.pkb 115.5 2003/06/17 14:27:43 sfmorris noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tpc_bus1.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_tp_measurement_type_id>-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_tp_measurement_type_id
  (p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  )  is
--
 l_cost_level varchar2(30);
  l_proc  varchar2(72) :=      g_package|| 'chk_tp_measurement_type_id';
--
 cursor csr_tp_measurement_type is
        select cost_level
        from OTA_TP_MEASUREMENT_TYPES
        where tp_measurement_type_id = p_tp_measurement_type_id
        and   business_group_id   = p_business_group_id;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_type_id'
    ,p_argument_value =>  p_tp_measurement_type_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  open  csr_tp_measurement_type;
  fetch csr_tp_measurement_type into l_cost_level;
  if csr_tp_measurement_type%NOTFOUND then
    close csr_tp_measurement_type;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13826_TPC_NO_MEASURE_DEF');
    fnd_message.raise_error;
  elsif l_cost_level = 'NONE' then
    close csr_tp_measurement_type;
    hr_utility.set_location(' Step:'|| l_proc, 70);
    fnd_message.set_name('OTA', 'OTA_13827_TPC_BAD_COST_LEVEL');
    fnd_message.raise_error;
  else
    hr_utility.set_location(' Step:'|| l_proc, 80);
    close csr_tp_measurement_type;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_tp_measurement_type_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_training_plan_id>-------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_training_plan_id
  (p_training_plan_id          in     ota_training_plan_costs.training_plan_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  )  is
--
  l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package|| 'chk_training_plan_id';
--
 cursor csr_training_plan_id is
        select null
        from OTA_TRAINING_PLANS
        where training_plan_id    = p_training_plan_id
        and   business_group_id   = p_business_group_id;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  open  csr_training_plan_id;
  fetch csr_training_plan_id into l_exists;
  if csr_training_plan_id%NOTFOUND then
    close csr_training_plan_id;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13828_TPC_NO_TRAINING_PLAN');
    fnd_message.raise_error;
  else
    hr_utility.set_location(' Step:'|| l_proc, 80);
    close csr_training_plan_id;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_training_plan_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_booking_id>------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_booking_id
  (p_booking_id                in     ota_training_plan_costs.booking_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  )  is
--
  l_business_group_id  ota_training_plan_costs.business_group_id%TYPE;
  l_proc  varchar2(72) :=      g_package|| 'chk_booking_id';
--
 cursor csr_booking_id is
        select business_group_id
        from OTA_DELEGATE_BOOKINGS
        where booking_id          = p_booking_id;
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  if p_booking_id is not null then
    open  csr_booking_id;
    fetch csr_booking_id into l_business_group_id;
    if csr_booking_id%NOTFOUND then
      close csr_booking_id;
      hr_utility.set_location(' Step:'|| l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13829_TPC_NO_BOOKING');
      fnd_message.raise_error;
    else
      close csr_booking_id;
      hr_utility.set_location(' Step:'|| l_proc, 70);
      if l_business_group_id <> p_business_group_id then
        fnd_message.set_name('OTA', 'OTA_13830_TPC_BOOKING_BAD_BG');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_booking_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_booking_event>----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_booking_event
  (p_booking_id                in     ota_training_plan_costs.booking_id%TYPE
  ,p_event_id                  in     ota_training_plan_costs.event_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  ,p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  )  is
--
  l_cost_level                 ota_tp_measurement_types.cost_level%TYPE;
  l_proc  varchar2(72) :=      g_package|| 'chk_booking_event';
--
 cursor csr_booking_event is
        select cost_level
        from OTA_TP_MEASUREMENT_TYPES
        where tp_measurement_type_id = p_tp_measurement_type_id
        and   business_group_id   = p_business_group_id;
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
--
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_type_id'
    ,p_argument_value =>  p_tp_measurement_type_id
    );
  --
  -- One and only one of event_id, booking_id must be null;
  --
  If (p_booking_id is not null and p_event_id is not null) then
     fnd_message.set_name('OTA', 'OTA_13831_TPC_EVENT_OR_BOOKING');
     fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Step:'|| l_proc, 50);
  open  csr_booking_event;
  fetch csr_booking_event into l_cost_level;
  if csr_booking_event%NOTFOUND then
    close csr_booking_event;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13826_TPC_NO_MEASURE_DEF');
    fnd_message.raise_error;
  else
    close csr_booking_event;
    hr_utility.set_location(' Step:'|| l_proc, 70);
    if (p_event_id is not null and l_cost_level <> 'EVENT') then
      fnd_message.set_name('OTA', 'OTA_13842_TPC_NOT_EVENT_COSTS');
      fnd_message.raise_error;
    elsif
       (p_event_id is null and l_cost_level = 'EVENT') then
      fnd_message.set_name('OTA', 'OTA_13832_TPC_EVENT_COST_LEVEL');
      fnd_message.raise_error;
    elsif (p_booking_id is not null) and
            (l_cost_level = 'PLAN' OR l_cost_level = 'EVENT') then
    hr_utility.set_location(' Step:'|| l_proc, 80);
      fnd_message.set_name('OTA', 'OTA_13833_TPC_DELEGATE_COST');
      fnd_message.raise_error;
    elsif (p_booking_id is null) and
            (l_cost_level = 'DELEGATE') then
    hr_utility.set_location(' Step:'|| l_proc, 90);
      fnd_message.set_name('OTA', 'OTA_13841_TPC_SUPPLY_DELEGATE');
      fnd_message.raise_error;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end chk_booking_event;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_event_id>---------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_event_id
  (p_event_id                  in     ota_training_plan_costs.event_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  ,p_training_plan_id          in     ota_training_plans.training_plan_id%TYPE
  )  is
--
  l_business_group_id  ota_training_plan_costs.business_group_id%TYPE;
  l_plan_start_date    per_time_periods.start_date%TYPE;
  l_event_start_date   ota_events.course_start_date%TYPE;
  l_proc  varchar2(72) :=      g_package|| 'chk_event_id';
--
 cursor csr_event_id is
        select business_group_id, course_start_date
        from OTA_EVENTS
        where event_id         = p_event_id;

 cursor csr_event_id_dates is
        select ptp.start_date
        from   PER_TIME_PERIODS ptp
              ,OTA_TRAINING_PLANS tps
        where ptp.time_period_id = tps.time_period_id
        and   tps.training_plan_id = p_training_plan_id;

Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  if p_event_id is not null then
    open  csr_event_id;
    fetch csr_event_id into l_business_group_id, l_event_start_date;
    if csr_event_id%NOTFOUND then
      close csr_event_id;
      hr_utility.set_location(' Step:'|| l_proc, 70);
      fnd_message.set_name('OTA', 'OTA_13834_TPC_NO_EVENT');
      fnd_message.raise_error;
    else
      close csr_event_id;
      hr_utility.set_location(' Step:'|| l_proc, 80);
      if l_business_group_id <> p_business_group_id then
        fnd_message.set_name('OTA', 'OTA_13835_TPC_EVENT_BAD_BG');
        fnd_message.raise_error;
      end if;
    end if;
    --
    -- Check that the dates correspond, if there is a course start date
    --
    if l_event_start_date is not null then
      hr_utility.set_location(' Step:'|| l_proc, 90);
      open  csr_event_id_dates;
      fetch csr_event_id_dates into l_plan_start_date;
      close csr_event_id_dates;
      if l_plan_start_date > l_event_start_date then
        hr_utility.set_location(' Step:'|| l_proc, 100);
        fnd_message.set_name('OTA', 'OTA_13836_TPC_EVENT_DATE');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 110);
end chk_event_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_currency_value>---------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_currency_value
  (p_currency_code             in     ota_training_plan_costs.currency_code%TYPE
  ,p_training_plan_cost_id     in     ota_training_plan_costs.training_plan_cost_id%TYPE
  ,p_object_version_number     in     ota_training_plan_costs.object_version_number%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  ,p_amount                    in     ota_training_plan_costs.amount%TYPE
  ,p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  )is
--
  l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package|| 'chk_currency_value';
  l_api_updating  boolean;
  l_unit                       ota_tp_measurement_types.unit%TYPE;
--
 cursor csr_currency_code is
        select null
        from FND_CURRENCIES
        where currency_code = p_currency_code;
 cursor csr_unit is
        select unit
        from OTA_TP_MEASUREMENT_TYPES
        where tp_measurement_type_id = p_tp_measurement_type_id
        and business_group_id = p_business_group_id;
--
Begin
--
-- check mandatory parameters have been set. Currency code can
-- be null, so it is not mandatory.
--
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_amount'
    ,p_argument_value =>  p_amount
    );
 --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_type_id'
    ,p_argument_value =>  p_tp_measurement_type_id
    );
 --
 l_api_updating := ota_tpc_shd.api_updating
    (p_training_plan_cost_id   => p_training_plan_cost_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  if ((l_api_updating and
       nvl(ota_tpc_shd.g_old_rec.currency_code, hr_api.g_varchar2) <>
       nvl(p_currency_code, hr_api.g_varchar2)
       or
       nvl(ota_tpc_shd.g_old_rec.amount, hr_api.g_number) <>
       nvl(p_amount, hr_api.g_number))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(' Step:'|| l_proc, 50);
    if p_currency_code is not null then
      open  csr_currency_code;
      fetch csr_currency_code into l_exists;
      if csr_currency_code%NOTFOUND then
        close csr_currency_code;
        fnd_message.set_name('AOL', 'MC_INVALID_CURRENCY');
        fnd_message.set_token('CODE', p_currency_code);
        fnd_message.raise_error;
      else
        close csr_currency_code;
      end if;
    end if;
    --
    -- Get the measurement type UNIT, and perform validation
    --
    hr_utility.set_location(' Step:'|| l_proc, 60);
    open csr_unit;
    fetch csr_unit into l_unit;
    if csr_unit%NOTFOUND then
      close csr_unit;
      fnd_message.set_name('OTA', 'OTA_13826_TPC_NO_MEASURE_DEF');
      fnd_message.raise_error;
    else
      close csr_unit;
      if (l_unit = 'M' and p_currency_code is null)
         or (l_unit <> 'M' and p_currency_code is not null)  then
        fnd_message.set_name('OTA', 'OTA_13838_TPC_BAD_CURR_VALUE');
        fnd_message.raise_error;
      end if;
    end if;
    --
    -- validate the format of the value field
    --
    hr_utility.set_location(' Step:'|| l_proc, 70);
    if l_unit = 'M' then
      hr_dbchkfmt.is_db_format
        (p_value      => p_amount
        ,p_arg_name   => 'VALUE'
        ,p_format     => 'MONEY'
        ,p_curcode    => p_currency_code);
    else
      hr_dbchkfmt.is_db_format
        (p_value      => p_amount
        ,p_arg_name   => 'VALUE'
        ,p_format     => l_unit);
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_currency_value;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique>-----------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_unique
  (p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  ,p_event_id                  in     ota_training_plan_costs.event_id%TYPE
  ,p_booking_id                in     ota_training_plan_costs.booking_id%TYPE
  ,p_training_plan_id          in     ota_training_plan_costs.training_plan_id%TYPE
  ) is
--
  l_proc  varchar2(72) :=      g_package|| 'chk_unique';
  l_exists varchar2(1);
--
 cursor csr_unique is
        select null
        from OTA_TRAINING_PLAN_COSTS
        where tp_measurement_type_id = p_tp_measurement_type_id
        and   training_plan_id       = p_training_plan_id
        and((p_event_id is not null and event_id = p_event_id)
            or  p_event_id is null)
        and((p_booking_id is not null and booking_id = p_booking_id)
            or p_booking_id is null);
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_type_id'
    ,p_argument_value =>  p_tp_measurement_type_id
    );
  --
--
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
  --
  -- check the combination is unique
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  open  csr_unique;
  fetch csr_unique into l_exists;
  if csr_unique%FOUND then
    close csr_unique;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13837_TPC_BAD_UNIQUE_COST');
    fnd_message.raise_error;
  else
    close csr_unique;
    hr_utility.set_location(' Step:'|| l_proc, 70);
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_unique;
end ota_tpc_bus1;

/
