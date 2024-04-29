--------------------------------------------------------
--  DDL for Package PAY_USER_TABLE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_TABLE_BK2" AUTHID CURRENT_USER as
/* $Header: pyputapi.pkh 120.1 2005/10/02 02:33:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_table_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_table_b
  (p_user_table_id                 in     number
  ,p_effective_date                in     date
  ,p_user_table_name               in     varchar2
  ,p_user_row_title                in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_table_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_table_a
  (p_user_table_id                 in     number
  ,p_effective_date                in     date
  ,p_user_table_name               in     varchar2
  ,p_user_row_title                in     varchar2
  ,p_object_version_number         in     number
  );
--
end pay_user_table_bk2;

 

/