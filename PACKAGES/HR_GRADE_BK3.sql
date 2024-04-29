--------------------------------------------------------
--  DDL for Package HR_GRADE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_BK3" AUTHID CURRENT_USER as
/* $Header: pegrdapi.pkh 120.1.12010000.3 2008/12/05 08:02:39 sidsaxen ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_grade_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_b
  (p_validate                      in     boolean
  ,p_grade_id                      in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_grade_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_a
  (p_validate                      in     boolean
  ,p_grade_id                      in     number
  ,p_object_version_number         in     number
  );
end hr_grade_bk3;

/
