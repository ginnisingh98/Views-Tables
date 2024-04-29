--------------------------------------------------------
--  DDL for Package PER_PAR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PAR_RKD" AUTHID CURRENT_USER as
/* $Header: peparrhi.pkh 120.1 2007/06/20 07:48:33 rapandi ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete	(
	p_participant_id                in number,
	p_business_group_id_o           in number,
	p_object_version_number_o       in number,
	p_questionnaire_template_id_o   in number,
	p_participation_in_table_o      in varchar2,
	p_participation_in_column_o     in varchar2,
	p_participation_in_id_o         in number,
	p_participation_status_o        in varchar2,
        p_participation_type_o          in varchar2,
        p_last_notified_date_o          in date,
	p_date_completed_o              in date,
	p_comments_o                    in varchar2,
	p_person_id_o                   in number,
	p_attribute_category_o          in varchar2,
	p_attribute1_o                  in varchar2,
	p_attribute2_o                  in varchar2,
	p_attribute3_o                  in varchar2,
	p_attribute4_o                  in varchar2,
	p_attribute5_o                  in varchar2,
	p_attribute6_o                  in varchar2,
	p_attribute7_o                  in varchar2,
	p_attribute8_o                  in varchar2,
	p_attribute9_o                  in varchar2,
	p_attribute10_o                 in varchar2,
	p_attribute11_o                 in varchar2,
	p_attribute12_o                 in varchar2,
	p_attribute13_o                 in varchar2,
	p_attribute14_o                 in varchar2,
	p_attribute15_o                 in varchar2,
	p_attribute16_o                 in varchar2,
	p_attribute17_o                 in varchar2,
	p_attribute18_o                 in varchar2,
	p_attribute19_o                 in varchar2,
	p_attribute20_o                 in varchar2 );

end per_par_rkd;

/
