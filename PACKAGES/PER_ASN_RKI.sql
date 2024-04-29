--------------------------------------------------------
--  DDL for Package PER_ASN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASN_RKI" AUTHID CURRENT_USER as
/* $Header: peasnrhi.pkh 120.0.12010000.2 2008/08/06 09:03:04 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert	(
	p_assessment_id                 in number,
	p_assessment_type_id            in number,
	p_business_group_id             in number,
	p_person_id                     in number,
	p_assessment_group_id           in number,
	p_assessment_period_start_date  in date,
	p_assessment_period_end_date    in date,
	p_assessment_date               in date,
	p_assessor_person_id            in number,
        p_appraisal_id                  in number,
	p_group_date                    in date,
	p_group_initiator_id            in number,
	p_comments                      in varchar2,
	p_total_score                   in number,
	p_status                        in varchar2,
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
	p_object_version_number         in number   );

end per_asn_rki;

/
