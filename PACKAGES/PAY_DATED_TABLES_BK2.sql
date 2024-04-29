--------------------------------------------------------
--  DDL for Package PAY_DATED_TABLES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATED_TABLES_BK2" AUTHID CURRENT_USER as
/* $Header: pyptaapi.pkh 120.0 2005/05/29 07:55:56 appldev noship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< update_dated_table_b  >------------------|
-- ---------------------------------------------------------------------
--
procedure update_dated_table_b
  (p_dated_table_id               in     number
  ,p_object_version_number        in     number
  ,p_table_name                   in     varchar2
  ,p_application_id               in     number
  ,p_surrogate_key_name           in     varchar2
  ,p_start_date_name              in     varchar2
  ,p_end_date_name                in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_dyn_trigger_type             in     varchar2
  ,p_dyn_trigger_package_name       in     varchar2
  ,p_dyn_trig_pkg_generated         in     varchar2
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< update_dated_table_a  >------------------|
-- ---------------------------------------------------------------------
--
procedure update_dated_table_a
  (p_dated_table_id               in     number
  ,p_object_version_number        in     number
  ,p_table_name                   in     varchar2
  ,p_application_id               in     number
  ,p_surrogate_key_name           in     varchar2
  ,p_start_date_name              in     varchar2
  ,p_end_date_name                in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_dyn_trigger_type             in     varchar2
  ,p_dyn_trigger_package_name       in     varchar2
  ,p_dyn_trig_pkg_generated         in     varchar2
  );
--
end pay_dated_tables_bk2;

 

/
