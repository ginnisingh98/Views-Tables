--------------------------------------------------------
--  DDL for Package IRC_RSE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RSE_RKD" AUTHID CURRENT_USER as
/* $Header: irrserhi.pkh 120.0.12010000.2 2010/01/18 14:36:23 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_recruiting_site_id           in number
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_posting_username_o           in varchar2
  ,p_posting_password_o           in varchar2
  ,p_internal_o                   in varchar2
  ,p_external_o                   in varchar2
  ,p_third_party_o                in varchar2
  ,p_posting_cost_o               in number
  ,p_posting_cost_period_o        in varchar2
  ,p_posting_cost_currency_o      in varchar2
  ,p_stylesheet_o        in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_object_version_number_o      in number
  ,p_internal_name_o              in varchar2
  ,p_posting_impl_class_o         in varchar2
  );
--
end irc_rse_rkd;

/
