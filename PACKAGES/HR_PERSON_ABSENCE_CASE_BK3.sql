--------------------------------------------------------
--  DDL for Package HR_PERSON_ABSENCE_CASE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ABSENCE_CASE_BK3" AUTHID CURRENT_USER as
/* $Header: peabcapi.pkh 120.3.12010000.2 2008/08/06 08:52:15 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence_case_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_absence_case_b
  (p_absence_case_id               in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence_case_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_absence_case_a
  (p_absence_case_id         in     number
  ,p_object_version_number         in     number
  );
--
end hr_person_absence_case_bk3;

/
