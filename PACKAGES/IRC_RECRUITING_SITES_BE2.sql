--------------------------------------------------------
--  DDL for Package IRC_RECRUITING_SITES_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RECRUITING_SITES_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_recruiting_site_a (
p_recruiting_site_id           number,
p_effective_date               date,
p_language_code                varchar2,
p_site_name                    varchar2,
p_date_from                    date,
p_date_to                      date,
p_posting_username             varchar2,
p_posting_password             varchar2,
p_internal                     varchar2,
p_external                     varchar2,
p_third_party                  varchar2,
p_redirection_url              varchar2,
p_posting_url                  varchar2,
p_posting_cost                 number,
p_posting_cost_period          varchar2,
p_posting_cost_currency        varchar2,
p_stylesheet                   varchar2,
p_object_version_number        number,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_attribute21                  varchar2,
p_attribute22                  varchar2,
p_attribute23                  varchar2,
p_attribute24                  varchar2,
p_attribute25                  varchar2,
p_attribute26                  varchar2,
p_attribute27                  varchar2,
p_attribute28                  varchar2,
p_attribute29                  varchar2,
p_attribute30                  varchar2,
p_posting_impl_class           varchar2);
end irc_recruiting_sites_be2;

/
