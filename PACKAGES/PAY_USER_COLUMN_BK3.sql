--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_BK3" AUTHID CURRENT_USER as
/* $Header: pypucapi.pkh 120.1 2005/10/02 02:33:30 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_user_column_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_column_b
  (p_user_column_id                 in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_user_column_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_column_a
  (p_user_column_id                in     number
  ,p_object_version_number         in     number
  );
--
end pay_user_column_bk3;

 

/
