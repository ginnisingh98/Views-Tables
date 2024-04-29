--------------------------------------------------------
--  DDL for Package HR_RATING_LEVELS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATING_LEVELS_BK2" AUTHID CURRENT_USER as
/* $Header: pertlapi.pkh 120.1 2005/11/28 03:22:49 dsaxby noship $ */
--
--
-- update_rating_level_b
--
Procedure update_rating_level_b	(
  p_language_code                in     varchar2 ,
  p_effective_date               in date      ,
  p_rating_level_id              in number    ,
  p_object_version_number        in number    ,
  p_name                         in varchar2  ,
  p_behavioural_indicator        in varchar2  ,
  p_attribute_category           in varchar2  ,
  p_attribute1                   in varchar2  ,
  p_attribute2                   in varchar2  ,
  p_attribute3                   in varchar2  ,
  p_attribute4                   in varchar2  ,
  p_attribute5                   in varchar2  ,
  p_attribute6                   in varchar2  ,
  p_attribute7                   in varchar2  ,
  p_attribute8                   in varchar2  ,
  p_attribute9                   in varchar2  ,
  p_attribute10                  in varchar2  ,
  p_attribute11                  in varchar2  ,
  p_attribute12                  in varchar2  ,
  p_attribute13                  in varchar2  ,
  p_attribute14                  in varchar2  ,
  p_attribute15                  in varchar2  ,
  p_attribute16                  in varchar2  ,
  p_attribute17                  in varchar2  ,
  p_attribute18                  in varchar2  ,
  p_attribute19                  in varchar2  ,
  p_attribute20                  in varchar2  );
--
--  update_rating_level_a
--
Procedure update_rating_level_a
	(
	p_language_code                in     varchar2 ,
  p_effective_date               in date      ,
  p_rating_level_id              in number    ,
  p_object_version_number        in number    ,
  p_name                         in varchar2  ,
  p_behavioural_indicator        in varchar2  ,
  p_attribute_category           in varchar2  ,
  p_attribute1                   in varchar2  ,
  p_attribute2                   in varchar2  ,
  p_attribute3                   in varchar2  ,
  p_attribute4                   in varchar2  ,
  p_attribute5                   in varchar2  ,
  p_attribute6                   in varchar2  ,
  p_attribute7                   in varchar2  ,
  p_attribute8                   in varchar2  ,
  p_attribute9                   in varchar2  ,
  p_attribute10                  in varchar2  ,
  p_attribute11                  in varchar2  ,
  p_attribute12                  in varchar2  ,
  p_attribute13                  in varchar2  ,
  p_attribute14                  in varchar2  ,
  p_attribute15                  in varchar2  ,
  p_attribute16                  in varchar2  ,
  p_attribute17                  in varchar2  ,
  p_attribute18                  in varchar2  ,
  p_attribute19                  in varchar2  ,
  p_attribute20                  in varchar2  );

end hr_rating_levels_bk2;

 

/
