--------------------------------------------------------
--  DDL for Package HR_ASSESSMENT_TYPES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENT_TYPES_BK2" AUTHID CURRENT_USER as
/* $Header: peastapi.pkh 120.2 2006/02/09 07:43:16 sansingh noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <update_assessment_type_b> >-----------------------|
-- ----------------------------------------------------------------------------
Procedure update_assessment_type_b	(
     p_assessment_type_id           in number   ,
     p_object_version_number        in number   ,
     p_name                         in varchar2 ,
     p_description                  in varchar2 ,
     p_rating_scale_id              in number   ,
     p_weighting_scale_id           in number   ,
     p_rating_scale_comment         in varchar2 ,
     p_weighting_scale_comment      in varchar2 ,
     p_assessment_classification    in varchar2 ,
     p_display_assessment_comments  in varchar2 ,
     p_date_from                    in date     ,
     p_date_to                      in date     ,
     p_comments                     in varchar2 ,
     p_instructions                 in varchar2 ,
     p_weighting_classification     in varchar2 ,
     p_line_score_formula           in varchar2 ,
     p_total_score_formula          in varchar2 ,
     p_attribute_category           in varchar2 ,
     p_attribute1                   in varchar2 ,
     p_attribute2                   in varchar2 ,
     p_attribute3                   in varchar2 ,
     p_attribute4                   in varchar2 ,
     p_attribute5                   in varchar2 ,
     p_attribute6                   in varchar2 ,
     p_attribute7                   in varchar2 ,
     p_attribute8                   in varchar2 ,
     p_attribute9                   in varchar2 ,
     p_attribute10                  in varchar2 ,
     p_attribute11                  in varchar2 ,
     p_attribute12                  in varchar2 ,
     p_attribute13                  in varchar2 ,
     p_attribute14                  in varchar2 ,
     p_attribute15                  in varchar2 ,
     p_attribute16                  in varchar2 ,
     p_attribute17                  in varchar2 ,
     p_attribute18                  in varchar2 ,
     p_attribute19                  in varchar2 ,
     p_attribute20                  in varchar2 ,
     p_type                         in varchar2,
     p_line_score_formula_id        in number,
     p_default_job_competencies     in varchar2,
     p_available_flag		    in varchar2,
     p_effective_date               in date
);
-- ----------------------------------------------------------------------------
-- |-----------------------< <update_assessment_type_a> >-----------------------|
-- ----------------------------------------------------------------------------
Procedure update_assessment_type_a
	(
     p_assessment_type_id           in number   ,
     p_object_version_number        in number   ,
     p_name                         in varchar2 ,
     p_description                  in varchar2 ,
     p_rating_scale_id              in number   ,
     p_weighting_scale_id           in number   ,
     p_rating_scale_comment         in varchar2 ,
     p_weighting_scale_comment      in varchar2 ,
     p_assessment_classification    in varchar2 ,
     p_display_assessment_comments  in varchar2 ,
     p_date_from                    in date     ,
     p_date_to                      in date     ,
     p_comments                     in varchar2 ,
     p_instructions                 in varchar2 ,
     p_weighting_classification     in varchar2 ,
     p_line_score_formula           in varchar2 ,
     p_total_score_formula          in varchar2 ,
     p_attribute_category           in varchar2 ,
     p_attribute1                   in varchar2 ,
     p_attribute2                   in varchar2 ,
     p_attribute3                   in varchar2 ,
     p_attribute4                   in varchar2 ,
     p_attribute5                   in varchar2 ,
     p_attribute6                   in varchar2 ,
     p_attribute7                   in varchar2 ,
     p_attribute8                   in varchar2 ,
     p_attribute9                   in varchar2 ,
     p_attribute10                  in varchar2 ,
     p_attribute11                  in varchar2 ,
     p_attribute12                  in varchar2 ,
     p_attribute13                  in varchar2 ,
     p_attribute14                  in varchar2 ,
     p_attribute15                  in varchar2 ,
     p_attribute16                  in varchar2 ,
     p_attribute17                  in varchar2 ,
     p_attribute18                  in varchar2 ,
     p_attribute19                  in varchar2 ,
     p_attribute20                  in varchar2 ,
     p_type                         in varchar2,
     p_line_score_formula_id        in number,
     p_default_job_competencies     in varchar2,
     p_available_flag		    in varchar2,
     p_effective_date               in date );

end hr_assessment_types_bk2;

 

/
