--------------------------------------------------------
--  DDL for Package PAY_BALANCE_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: pybltapi.pkh 120.1 2005/10/02 02:46:06 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_BAL_TYPE_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_type_b
  (p_balance_type_id               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_BAL_TYPE_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_type_a
  (p_balance_type_id               in     number
  ,p_object_version_number         in     number
  );
end PAY_BALANCE_TYPES_BK3;

 

/
