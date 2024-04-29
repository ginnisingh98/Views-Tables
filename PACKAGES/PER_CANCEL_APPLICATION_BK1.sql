--------------------------------------------------------
--  DDL for Package PER_CANCEL_APPLICATION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CANCEL_APPLICATION_BK1" AUTHID CURRENT_USER as
/* $Header: pecapapi.pkh 120.1 2005/10/02 02:12:39 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< cancel_application_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_application_b
  (p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_application_id                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< cancel_application_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_application_a
  (p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_application_id                in     number
  );
--
end per_cancel_application_bk1;

 

/
