--------------------------------------------------------
--  DDL for Package PER_RSC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RSC_RKD" AUTHID CURRENT_USER as
/* $Header: perscrhi.pkh 120.0 2005/05/31 19:46:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete	(
	p_rating_scale_id               in number,
	p_business_group_id_o           in number,
	p_name_o                        in varchar2,
	p_type_o                        in varchar2,
	p_object_version_number_o       in number,
	p_description_o                 in varchar2,
	p_max_scale_step_o              in number,
	p_min_scale_step_o              in number,
      p_default_flag_o                in varchar2,
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

end per_rsc_rkd;

 

/
