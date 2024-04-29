--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_BK1" AUTHID CURRENT_USER as
/* $Header: pypucapi.pkh 120.1 2005/10/02 02:33 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_user_column_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_column_b
  (p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_user_table_id                 in     number
  ,p_formula_id                    in     number
  ,p_user_column_name              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_user_column_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_column_a
  (p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_user_table_id                 in     number
  ,p_formula_id                    in     number
  ,p_user_column_name              in     varchar2
  ,p_user_column_id                in     number
  ,p_object_version_number         in     number
  );
--
end pay_user_column_bk1;

 

/
