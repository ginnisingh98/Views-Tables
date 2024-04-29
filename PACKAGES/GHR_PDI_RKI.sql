--------------------------------------------------------
--  DDL for Package GHR_PDI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDI_RKI" AUTHID CURRENT_USER as
/* $Header: ghpdirhi.pkh 120.0 2005/05/29 03:28:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--    If the user(customer) has any packages to be executed, then those will be
--    called by this procedure. The body of this procedure will be generated.
--
procedure after_insert	(
	p_position_description_id       in number,
	p_routing_group_id              in number,
	p_date_from                     in date,
	p_date_to                       in date,
	p_opm_cert_num                  in varchar2,
	p_flsa                          in varchar2,
	p_financial_statement           in varchar2,
	p_subject_to_ia_action          in varchar2,
	p_position_status               in number,
	p_position_is                   in varchar2,
	p_position_sensitivity          in varchar2,
	p_competitive_level             in varchar2,
	p_pd_remarks                    in varchar2,
	p_position_class_std            in varchar2,
	p_category                      in varchar2,
	p_career_ladder                 in varchar2,
      p_supervisor_name               in varchar2,
  	p_supervisor_title              in varchar2,
  	p_supervisor_date               in date,
  	p_manager_name		        in varchar2,
  	p_manager_title                 in varchar2,
  	p_manager_date                  in date,
  	p_classifier_name               in varchar2,
  	p_classifier_title              in varchar2,
  	p_classifier_date               in date,
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
        p_business_group_id             in number,
	p_object_version_number         in number
      );

end ghr_pdi_rki;

 

/
