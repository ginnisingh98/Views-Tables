--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_BK2" AUTHID CURRENT_USER as
/* $Header: pypucapi.pkh 120.1 2005/10/02 02:33 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_column_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_column_b
  (p_user_column_id                in     number
  ,p_user_column_name              in     varchar2
  ,p_formula_id                    in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_column_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_column_a
  (p_user_column_id                in     number
  ,p_user_column_name              in     varchar2
  ,p_formula_id                    in     number
  ,p_object_version_number         in     number
  ,p_formula_warning               in     boolean
  );
--
end pay_user_column_bk2;

 

/
