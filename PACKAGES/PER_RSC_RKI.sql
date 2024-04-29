--------------------------------------------------------
--  DDL for Package PER_RSC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RSC_RKI" AUTHID CURRENT_USER as
/* $Header: perscrhi.pkh 120.0 2005/05/31 19:46:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert	(
	p_rating_scale_id               in number,
	p_business_group_id             in number,
	p_name                          in varchar2,
	p_type                          in varchar2,
	p_object_version_number         in number,
	p_description                   in varchar2,
	p_max_scale_step                in number,
	p_min_scale_step                in number,
      p_default_flag                  in varchar2,
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
      p_attribute20                   in varchar2 );

end per_rsc_rki;

 

/
