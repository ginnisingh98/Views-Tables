--------------------------------------------------------
--  DDL for Package PQP_CAR_CLASS_1A_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_CAR_CLASS_1A_PKG" AUTHID CURRENT_USER as
/* $Header: pqcmcpkg.pkh 120.0 2005/05/29 01:43:27 appldev noship $ */

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
                   );

end pqp_car_class_1a_pkg;

 

/
