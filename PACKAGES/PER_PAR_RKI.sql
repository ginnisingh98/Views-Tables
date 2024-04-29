--------------------------------------------------------
--  DDL for Package PER_PAR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PAR_RKI" AUTHID CURRENT_USER as
/* $Header: peparrhi.pkh 120.1 2007/06/20 07:48:33 rapandi ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert	(
	p_participant_id                in number,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_questionnaire_template_id     in number,
	p_participation_in_table        in varchar2,
	p_participation_in_column       in varchar2,
	p_participation_in_id           in number,
	p_participation_status          in varchar2,
	p_participation_type            in varchar2,
	p_last_notified_date            in date,
	p_date_completed                in date,
	p_comments                      in varchar2,
	p_person_id                     in number,
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
  p_participant_usage_status		  in varchar2 );

end per_par_rki;

/
