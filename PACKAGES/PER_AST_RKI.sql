--------------------------------------------------------
--  DDL for Package PER_AST_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_AST_RKI" AUTHID CURRENT_USER as
/* $Header: peastrhi.pkh 120.2.12010000.1 2008/07/28 04:12:35 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert	(
	p_assessment_type_id            in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_description                   in varchar2,
	p_rating_scale_id               in number,
	p_weighting_scale_id            in number,
	p_rating_scale_comment          in varchar2,
	p_weighting_scale_comment       in varchar2,
	p_assessment_classification     in varchar2,
	p_display_assessment_comments   in varchar2,
	p_date_from                     in date,
     	p_date_to                       in date,
	p_comments                      in varchar2,
	p_instructions                  in varchar2,
	p_weighting_classification      in varchar2,
        p_line_score_formula            in varchar2,
        p_total_score_formula           in varchar2,
	p_object_version_number         in number,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_type                          in varchar2,
	p_line_score_formula_id         in number,
	p_default_job_competencies      in varchar2,
	p_available_flag                in varchar2);

end per_ast_rki;

/
