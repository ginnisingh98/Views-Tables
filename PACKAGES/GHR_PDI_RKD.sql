--------------------------------------------------------
--  DDL for Package GHR_PDI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDI_RKD" AUTHID CURRENT_USER as
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
procedure after_delete	(
	p_position_description_id       in number,
	p_routing_group_id_o            in number,
	p_date_from_o                   in date,
	p_date_to_o                     in date,
	p_opm_cert_num_o                in varchar2,
	p_flsa_o                        in varchar2,
	p_financial_statement_o         in varchar2,
	p_subject_to_ia_action_o        in varchar2,
	p_position_status_o             in number,
	p_position_is_o                 in varchar2,
	p_position_sensitivity_o        in varchar2,
	p_competitive_level_o           in varchar2,
	p_pd_remarks_o                  in varchar2,
	p_position_class_std_o          in varchar2,
	p_category_o                    in varchar2,
	p_career_ladder_o               in varchar2,
      p_supervisor_name_o             in varchar2,
  	p_supervisor_title_o            in varchar2,
  	p_supervisor_date_o             in date,
  	p_manager_name_o                in varchar2,
  	p_manager_title_o               in varchar2,
  	p_manager_date_o                in date,
  	p_classifier_name_o             in varchar2,
  	p_classifier_title_o            in varchar2,
  	p_classifier_date_o             in date,
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
	p_attribute20_o                 in varchar2,
        p_business_group_id_o             in number,
	p_object_version_number_o       in number
      );

end ghr_pdi_rkd;

 

/
