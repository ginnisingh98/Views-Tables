--------------------------------------------------------
--  DDL for Package IRC_JOB_BASKET_ITEMS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JOB_BASKET_ITEMS_BK2" AUTHID CURRENT_USER as
/* $Header: irjbiapi.pkh 120.2 2008/02/21 14:31:22 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_job_basket_item_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_job_basket_item_b
  (p_object_version_number         in     number
  ,p_job_basket_item_id            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_job_basket_item_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_job_basket_item_a
  (p_object_version_number         in     number
  ,p_job_basket_item_id            in     number
  );
--
end irc_job_basket_items_bk2;

/
