--------------------------------------------------------
--  DDL for Package PER_BF_PAYMENT_DETAILS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PAYMENT_DETAILS_BK3" AUTHID CURRENT_USER AS
/* $Header: pebpdapi.pkh 120.1 2005/10/02 02:12:21 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_payment_detail_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_payment_detail_b
  (
   p_payment_detail_id            in   number
  ,p_payment_detail_ovn           in   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_payment_detail_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_payment_detail_a
  (
   p_payment_detail_id            in   number
  ,p_payment_detail_ovn           in   number
  );
--
end per_bf_payment_details_bk3;

 

/
