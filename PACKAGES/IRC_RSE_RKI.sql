--------------------------------------------------------
--  DDL for Package IRC_RSE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RSE_RKI" AUTHID CURRENT_USER as
/* $Header: irrserhi.pkh 120.0.12010000.2 2010/01/18 14:36:23 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_recruiting_site_id           in number
  ,p_date_from                    in date
  ,p_date_to                      in date
  ,p_posting_username             in varchar2
  ,p_posting_password             in varchar2
  ,p_internal                     in varchar2
  ,p_external                     in varchar2
  ,p_third_party                  in varchar2
  ,p_posting_cost                 in number
  ,p_posting_cost_period          in varchar2
  ,p_posting_cost_currency        in varchar2
  ,p_stylesheet          in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_object_version_number        in number
  ,p_internal_name                in varchar2
  ,p_posting_impl_class           in varchar2
  );
end irc_rse_rki;

/
