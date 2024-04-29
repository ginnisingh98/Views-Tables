--------------------------------------------------------
--  DDL for Package Body PQP_CAR_CLASS_1A_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_CAR_CLASS_1A_PKG" as
/* $Header: pqcmcpkg.pkb 120.0 2005/05/29 01:43:22 appldev noship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_car_class_1a_pkg.';
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_class_1a_entry >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_class_1a_entry(
                   p_assignment_id       number,
                   p_effective_date      date,
                   p_price               number,
                   p_registration_date   date,
                   p_registration_number varchar2,
                   p_mileage_band        varchar2,
                   p_fuel_scale          number,
                   p_payment             number,
                   p_fuel_type           varchar2,
                   p_engine_cc           number,
                   p_primary_car         varchar2,
                   p_co2_emissions       number
                   )
is

  cursor c_element(p_element_name varchar2) is
  select element_type_id
  from pay_element_types_f
  where element_name = p_element_name;

  cursor c_input_value(p_name            varchar2,
                       p_element_type_id number) is
  select input_value_id
  from pay_input_values_f
  where element_type_id = p_element_type_id
  and name = p_name;

  type inputs_table is table of varchar2(80)
  index by binary_integer;

  l_input_names_table inputs_table;
  l_input_values_table inputs_table;

  inp_value_id_tbl hr_entry.number_table;
  scr_valuetbl     hr_entry.varchar2_table;

  l_element_type_id  number;
  l_element_link_id  number;
  l_element_entry_id number;
  l_element_name     varchar2(80);
  l_start_date       date;
  l_end_date         date;

begin

  l_input_names_table(1) := 'Price';
  l_input_names_table(2) := 'Registration Date';
  l_input_names_table(3) := 'Registration Number';
  l_input_names_table(4) := 'Mileage Band';
  l_input_names_table(5) := 'Fuel Scale';
  l_input_names_table(6) := 'Payment';
  l_input_names_table(7) := 'Fuel Type';
  l_input_names_table(8) := 'Engine cc';
  l_input_names_table(9) := 'CO2 Emissions';

  l_input_values_table(1) := fnd_number.number_to_canonical(p_price);
  l_input_values_table(2) := fnd_date.date_to_displaydate(p_registration_date);
  l_input_values_table(3) := p_registration_number;
  l_input_values_table(4) := p_mileage_band;
  l_input_values_table(5) := fnd_number.number_to_canonical(p_fuel_scale);
  l_input_values_table(6) := fnd_number.number_to_canonical(p_payment);
  l_input_values_table(7) := p_fuel_type;
  l_input_values_table(8) := fnd_number.number_to_canonical(p_engine_cc);
  l_input_values_table(9) := fnd_number.number_to_canonical(p_co2_emissions);

  if p_primary_car = 'Y'  then
  --
    l_element_name := 'NI Car Primary';
  --
  else
  --
    l_element_name := 'NI Car Secondary';
  --
  end if;

  open c_element(l_element_name);

  fetch c_element into l_element_type_id;

  if c_element%notfound then
  --
    close c_element;

    fnd_message.set_name('PQP', 'PQP_230XXX_INVALID_CM_ELEMENT');
    fnd_message.raise_error;
  --
  end if;

  close c_element;

  l_element_link_id := hr_entry_api.get_link(
                         P_assignment_id   => p_assignment_id,
                         P_element_type_id => l_element_type_id,
                         P_session_date    => p_effective_date);

  for i in 1..9 loop
  --
    open c_input_value(l_input_names_table(i), l_element_type_id);
    fetch c_input_value into inp_value_id_tbl(i);

    if c_input_value%notfound then
    --
      close c_input_value;

      fnd_message.set_name('PQP', 'PQP_230XXX_INVALID_CM_ELEMENT');
      fnd_message.raise_error;
    --
    end if;

    close c_input_value;

    scr_valuetbl(i) := l_input_values_table(i);
  --
  end loop;

  l_start_date := p_effective_date;

  hr_entry_api.insert_element_entry(
           p_effective_start_date     => l_start_date,
           p_effective_end_date       => l_end_date,
           p_element_entry_id         => l_element_entry_id,
           p_assignment_id            => p_assignment_id,
           p_element_link_id          => l_element_link_id,
           p_creator_type             => 'F',
           p_entry_type               => 'E',
           p_num_entry_values         => 9,
           p_input_value_id_tbl       => inp_value_id_tbl,
           p_entry_value_tbl          => scr_valuetbl);


end create_class_1a_entry;

--
end pqp_car_class_1a_pkg;

/
