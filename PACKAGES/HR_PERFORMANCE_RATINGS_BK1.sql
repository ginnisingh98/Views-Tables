--------------------------------------------------------
--  DDL for Package HR_PERFORMANCE_RATINGS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERFORMANCE_RATINGS_BK1" AUTHID CURRENT_USER as
/* $Header: peprtapi.pkh 120.2 2006/02/13 14:12:27 vbala noship $ */

-- ---------------------------------------------------------------------------+
-- |--------------------<<create_performance_rating_b>>------------------- |
-- ---------------------------------------------------------------------------+
Procedure create_performance_rating_b
  (p_effective_date                in     date
  ,p_appraisal_id                  in     number
  ,p_objective_id                  in     number
  ,p_performance_level_id          in     number
  ,p_person_id                     in     number
  ,p_comments                      in     varchar2
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
  ,p_appr_line_score               in     number);

-- ---------------------------------------------------------------------------+
-- |--------------------<<create_performance_rating_a>>------------------- |
-- ---------------------------------------------------------------------------+
Procedure create_performance_rating_a(
   p_performance_rating_id         in     number
  ,p_object_version_number         in     number
  ,p_effective_date                in     date
  ,p_appraisal_id                  in     number
  ,p_objective_id                  in     number
  ,p_performance_level_id          in     number
  ,p_person_id                     in     number
  ,p_comments                      in     varchar2
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
  ,p_appr_line_score               in     number);

end hr_performance_ratings_bk1;

 

/
