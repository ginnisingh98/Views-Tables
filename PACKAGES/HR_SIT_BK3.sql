--------------------------------------------------------
--  DDL for Package HR_SIT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SIT_BK3" AUTHID CURRENT_USER as
/* $Header: pesitapi.pkh 120.2.12010000.1 2008/07/28 05:57:54 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_sit_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_sit_b(
   p_person_analysis_id        in     number
  ,p_pea_object_version_number in     number);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_sit_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_sit_a(
   p_person_analysis_id        in     number
  ,p_pea_object_version_number in     number);
--
end hr_sit_bk3;

/
