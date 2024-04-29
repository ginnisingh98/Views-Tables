--------------------------------------------------------
--  DDL for Package HR_STD_HOL_ABS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_STD_HOL_ABS_BK1" AUTHID CURRENT_USER as
/* $Header: peshaapi.pkh 120.1 2005/10/02 02:24:12 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_std_hol_abs_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_std_hol_abs_b
    (p_date_not_taken               in     date
    ,p_person_id                    in     number
    ,p_standard_holiday_id          in     number
    ,p_actual_date_taken            in     date
    ,p_reason                       in     varchar2
    ,p_expired                      in     varchar2
    ,p_attribute_category           in     varchar2
    ,p_attribute1                   in     varchar2
    ,p_attribute2                   in     varchar2
    ,p_attribute3                   in     varchar2
    ,p_attribute4                   in     varchar2
    ,p_attribute5                   in     varchar2
    ,p_attribute6                   in     varchar2
    ,p_attribute7                   in     varchar2
    ,p_attribute8                   in     varchar2
    ,p_attribute9                   in     varchar2
    ,p_attribute10                  in     varchar2
    ,p_attribute11                  in     varchar2
    ,p_attribute12                  in     varchar2
    ,p_attribute13                  in     varchar2
    ,p_attribute14                  in     varchar2
    ,p_attribute15                  in     varchar2
    ,p_attribute16                  in     varchar2
    ,p_attribute17                  in     varchar2
    ,p_attribute18                  in     varchar2
    ,p_attribute19                  in     varchar2
    ,p_attribute20                  in     varchar2
    ,p_effective_date               in     date
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_std_hol_abs_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_std_hol_abs_a
    (p_date_not_taken               in     date
    ,p_person_id                    in     number
    ,p_standard_holiday_id          in     number
    ,p_actual_date_taken            in     date
    ,p_reason                       in     varchar2
    ,p_expired                      in     varchar2
    ,p_attribute_category           in     varchar2
    ,p_attribute1                   in     varchar2
    ,p_attribute2                   in     varchar2
    ,p_attribute3                   in     varchar2
    ,p_attribute4                   in     varchar2
    ,p_attribute5                   in     varchar2
    ,p_attribute6                   in     varchar2
    ,p_attribute7                   in     varchar2
    ,p_attribute8                   in     varchar2
    ,p_attribute9                   in     varchar2
    ,p_attribute10                  in     varchar2
    ,p_attribute11                  in     varchar2
    ,p_attribute12                  in     varchar2
    ,p_attribute13                  in     varchar2
    ,p_attribute14                  in     varchar2
    ,p_attribute15                  in     varchar2
    ,p_attribute16                  in     varchar2
    ,p_attribute17                  in     varchar2
    ,p_attribute18                  in     varchar2
    ,p_attribute19                  in     varchar2
    ,p_attribute20                  in     varchar2
    ,p_effective_date               in     date
    ,p_object_version_number        in     number
    ,p_std_holiday_absences_id      in     number
    );
end hr_std_hol_abs_bk1;

 

/
