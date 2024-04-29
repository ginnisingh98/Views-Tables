--------------------------------------------------------
--  DDL for Package HR_DE_LIABILITY_PREMIUMS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_LIABILITY_PREMIUMS_BK2" AUTHID CURRENT_USER as
/* $Header: hrlipapi.pkh 120.1 2005/10/02 02:03:34 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_premium_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_premium_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_liability_premiums_id         in     number
  ,p_organization_link_id_o        in     number
  ,p_std_percentage                in     number
  ,p_calculation_method            in     varchar2
  ,p_std_working_hours_per_year    in     number
  ,p_max_remuneration              in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_premiums_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_premium_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_liability_premiums_id         in     number
  ,p_organization_link_id_o        in     number
  ,p_std_percentage                in     number
  ,p_calculation_method            in     varchar2
  ,p_std_working_hours_per_year    in     number
  ,p_max_remuneration              in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end hr_de_liability_premiums_bk2;

 

/
