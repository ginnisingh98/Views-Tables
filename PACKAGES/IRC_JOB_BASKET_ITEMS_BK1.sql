--------------------------------------------------------
--  DDL for Package IRC_JOB_BASKET_ITEMS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JOB_BASKET_ITEMS_BK1" AUTHID CURRENT_USER as
/* $Header: irjbiapi.pkh 120.2 2008/02/21 14:31:22 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_job_basket_item_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_job_basket_item_b
  (p_effective_date                in     date
  ,p_recruitment_activity_id       in     number
  ,p_person_id                     in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_job_basket_item_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_job_basket_item_a
  (p_effective_date                in     date
  ,p_object_version_number         in     number
  ,p_job_basket_item_id            in     number
  ,p_recruitment_activity_id       in     number
  ,p_person_id                     in     number
  );
end irc_job_basket_items_bk1;

/
