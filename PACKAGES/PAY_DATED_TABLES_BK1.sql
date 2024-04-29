--------------------------------------------------------
--  DDL for Package PAY_DATED_TABLES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATED_TABLES_BK1" AUTHID CURRENT_USER as
/* $Header: pyptaapi.pkh 120.0 2005/05/29 07:55:56 appldev noship $ */
--
-- ---------------------------------------------------------------------
-- |-------------------< create_dated_table_b >------------------|
-- ---------------------------------------------------------------------
--
procedure create_dated_table_b
  (
   p_table_name                     in     varchar2
  ,p_application_id                 in     number
  ,p_surrogate_key_name             in     varchar2
  ,p_start_date_name                in     varchar2
  ,p_end_date_name                  in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_dyn_trigger_type               in     varchar2
  ,p_dyn_trigger_package_name       in     varchar2
  ,p_dyn_trig_pkg_generated         in     varchar2
  );
--
-- ---------------------------------------------------------------------
-- |-------------------< create_dated_table_a  >------------------|
-- ---------------------------------------------------------------------
--
procedure create_dated_table_a
  (
   p_table_name                     in     varchar2
  ,p_application_id                 in     number
  ,p_surrogate_key_name             in     varchar2
  ,p_start_date_name                in     varchar2
  ,p_end_date_name                  in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_dated_table_id                 in     number
  ,p_object_version_number          in     number
  ,p_dyn_trigger_type               in     varchar2
  ,p_dyn_trigger_package_name       in     varchar2
  ,p_dyn_trig_pkg_generated         in     varchar2
  );
end pay_dated_tables_bk1;

 

/
