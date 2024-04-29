--------------------------------------------------------
--  DDL for Package HR_RATING_LEVELS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATING_LEVELS_BK1" AUTHID CURRENT_USER as
/* $Header: pertlapi.pkh 120.1 2005/11/28 03:22:49 dsaxby noship $ */
--
--
-- create_rating_level_b
--
-- ngundura changes done for pa requirement { p_business_group_id made optional}
Procedure create_rating_level_b	(
  p_language_code                in     varchar2 ,
  p_effective_date               in	date     ,
  p_name                         in 	varchar2 ,
  p_business_group_id            in 	number   ,
  p_step_value                   in	number   ,
  p_behavioural_indicator        in 	varchar2 ,
  p_rating_scale_id              in	number   ,
  p_competence_id                in 	number   ,
  p_attribute_category           in 	varchar2 ,
  p_attribute1                   in 	varchar2 ,
  p_attribute2                   in 	varchar2 ,
  p_attribute3                   in 	varchar2 ,
  p_attribute4                   in 	varchar2 ,
  p_attribute5                   in 	varchar2 ,
  p_attribute6                   in 	varchar2 ,
  p_attribute7                   in 	varchar2 ,
  p_attribute8                   in 	varchar2 ,
  p_attribute9                   in 	varchar2 ,
  p_attribute10                  in 	varchar2 ,
  p_attribute11                  in 	varchar2 ,
  p_attribute12                  in 	varchar2 ,
  p_attribute13                  in 	varchar2 ,
  p_attribute14                  in 	varchar2 ,
  p_attribute15                  in 	varchar2 ,
  p_attribute16                  in 	varchar2 ,
  p_attribute17                  in 	varchar2 ,
  p_attribute18                  in 	varchar2 ,
  p_attribute19                  in 	varchar2 ,
  p_attribute20                  in 	varchar2 	);
--
-- create_rating_level_a
--
Procedure create_rating_level_a	(
  p_language_code                in     varchar2 ,
  p_rating_level_id              in     number   ,
  p_object_version_number        in     number   ,
  p_obj_ver_number_cpn_or_rsc    in     number   ,
  p_effective_date               in	date     ,
  p_name                         in 	varchar2 ,
  p_business_group_id            in 	number   ,
  p_step_value                   in	number   ,
  p_behavioural_indicator        in 	varchar2 ,
  p_rating_scale_id              in	number   ,
  p_competence_id                in 	number   ,
  p_attribute_category           in 	varchar2 ,
  p_attribute1                   in 	varchar2 ,
  p_attribute2                   in 	varchar2 ,
  p_attribute3                   in 	varchar2 ,
  p_attribute4                   in 	varchar2 ,
  p_attribute5                   in 	varchar2 ,
  p_attribute6                   in 	varchar2 ,
  p_attribute7                   in 	varchar2 ,
  p_attribute8                   in 	varchar2 ,
  p_attribute9                   in 	varchar2 ,
  p_attribute10                  in 	varchar2 ,
  p_attribute11                  in 	varchar2 ,
  p_attribute12                  in 	varchar2 ,
  p_attribute13                  in 	varchar2 ,
  p_attribute14                  in 	varchar2 ,
  p_attribute15                  in 	varchar2 ,
  p_attribute16                  in 	varchar2 ,
  p_attribute17                  in 	varchar2 ,
  p_attribute18                  in 	varchar2 ,
  p_attribute19                  in 	varchar2 ,
  p_attribute20                  in 	varchar2 	);

end hr_rating_levels_bk1;

 

/
