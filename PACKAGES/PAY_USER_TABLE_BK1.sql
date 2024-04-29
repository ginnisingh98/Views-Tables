--------------------------------------------------------
--  DDL for Package PAY_USER_TABLE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_TABLE_BK1" AUTHID CURRENT_USER as
/* $Header: pyputapi.pkh 120.1 2005/10/02 02:33:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_user_table_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_table_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_range_or_match                in     varchar2
  ,p_user_key_units                in     varchar2
  ,p_user_table_name               in     varchar2
  ,p_user_row_title                in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_user_table_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_table_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_range_or_match                in     varchar2
  ,p_user_key_units                in     varchar2
  ,p_user_table_name               in     varchar2
  ,p_user_row_title                in     varchar2
  ,p_user_table_id                 in     number
  ,p_object_version_number         in     number
  );
--
end pay_user_table_bk1;

 

/
