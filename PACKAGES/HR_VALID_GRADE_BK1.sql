--------------------------------------------------------
--  DDL for Package HR_VALID_GRADE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_VALID_GRADE_BK1" AUTHID CURRENT_USER as
/* $Header: pevgrapi.pkh 120.1 2005/10/02 02:24:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_valid_grade_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_valid_grade_b
  (p_business_group_id             in     number
  ,p_grade_id                      in     number
  ,p_date_from                     in     date
  ,p_effective_date		   in 	  date   --Added for bug# 1760707
  ,p_comments                      in     varchar2
  ,p_date_to                       in     date
  ,p_job_id                        in     number
  ,p_position_id                   in     number
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
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_valid_grade_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_valid_grade_a
  (p_business_group_id             in     number
  ,p_grade_id                      in     number
  ,p_date_from                     in     date
  ,p_effective_date		   in 	  date   --Added for bug# 1760707
  ,p_comments                      in     varchar2
  ,p_date_to                       in     date
  ,p_job_id                        in     number
  ,p_position_id                   in     number
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
  ,p_valid_grade_id                in	  number
  ,p_object_version_number         in     number
  );
end hr_valid_grade_bk1;

 

/
