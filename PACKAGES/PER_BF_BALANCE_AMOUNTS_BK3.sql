--------------------------------------------------------
--  DDL for Package PER_BF_BALANCE_AMOUNTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_BALANCE_AMOUNTS_BK3" AUTHID CURRENT_USER as
/* $Header: pebbaapi.pkh 120.1 2005/10/02 02:11:58 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_balance_amount_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_amount_b
  (
   p_balance_amount_id            in     number
  ,p_balance_amount_ovn           in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_balance_amount_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_amount_a
  (
   p_balance_amount_id             in     number
  ,p_balance_amount_ovn            in     number
  );
--
end PER_BF_BALANCE_AMOUNTS_BK3;

 

/
