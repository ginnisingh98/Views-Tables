--------------------------------------------------------
--  DDL for Package HR_STD_HOL_ABS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_STD_HOL_ABS_BK3" AUTHID CURRENT_USER as
/* $Header: peshaapi.pkh 120.1 2005/10/02 02:24:12 aroussel $ */
--
-- ----------------------------------------------------------------------
-- |----------------< delete_std_hol_abs_b >-----------------------|
-- ----------------------------------------------------------------------
--
procedure delete_std_hol_abs_b
  (p_std_holiday_absences_id        in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------
-- |----------------< delete_std_hol_abs_a >-----------------------|
-- ----------------------------------------------------------------------
--
procedure  delete_std_hol_abs_a
  (p_std_holiday_absences_id        in     number
  ,p_object_version_number          in     number
  );
end hr_std_hol_abs_bk3;

 

/
