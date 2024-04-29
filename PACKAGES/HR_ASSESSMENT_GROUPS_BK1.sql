--------------------------------------------------------
--  DDL for Package HR_ASSESSMENT_GROUPS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENT_GROUPS_BK1" AUTHID CURRENT_USER as
/* $Header: peasrapi.pkh 115.3 99/10/05 09:44:03 porting ship $ */
--
--
-- create_assessment_group_b
--
Procedure create_assessment_group_b	(
     p_name                         in    varchar2 ,
     p_business_group_id            in    number   ,
     p_comments                     in    varchar2 ,
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
     p_attribute20                  in 	varchar2 ,
     p_effective_date               in    date     );
--
-- create_assessment_group_a
--
Procedure create_assessment_group_a	(
     p_assessment_group_id          in    number   ,
     p_object_version_number        in    number   ,
     p_name                         in    varchar2 ,
     p_business_group_id            in    number   ,
     p_comments                     in    varchar2 ,
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
     p_attribute20                  in 	varchar2 ,
     p_effective_date               in    date     );

end hr_assessment_groups_bk1;

 

/
