--------------------------------------------------------
--  DDL for Package HR_CHANGE_START_DATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CHANGE_START_DATE_BK1" AUTHID CURRENT_USER as
/* $Header: pehirapi.pkh 120.1.12010000.1 2008/07/28 04:48:12 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_start_date_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_start_date_b
  (p_person_id                     in     number
  ,p_old_start_date                in     date
  ,p_new_start_date                in     date
  ,p_update_type                   in     varchar2
  ,p_applicant_number              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_start_date_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_start_date_a
  (p_person_id                     in     number
  ,p_old_start_date                in     date
  ,p_new_start_date                in     date
  ,p_update_type                   in     varchar2
  ,p_applicant_number              in     varchar2
  ,p_warn_ee                       in     varchar2
  );
--
end hr_change_start_date_bk1;

/
