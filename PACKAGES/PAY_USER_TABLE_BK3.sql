--------------------------------------------------------
--  DDL for Package PAY_USER_TABLE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_TABLE_BK3" AUTHID CURRENT_USER as
/* $Header: pyputapi.pkh 120.1 2005/10/02 02:33:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_user_table_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_table_b
  (p_user_table_id                 in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_user_table_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_table_a
  (p_user_table_id                 in     number
  ,p_object_version_number         in     number
  );
--
end pay_user_table_bk3;

 

/
