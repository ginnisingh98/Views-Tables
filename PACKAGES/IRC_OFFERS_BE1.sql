--------------------------------------------------------
--  DDL for Package IRC_OFFERS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFERS_BE1" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:51
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_offer_a (
p_effective_date               date,
p_latest_offer                 varchar2,
p_offer_status                 varchar2,
p_discretionary_job_title      varchar2,
p_offer_extended_method        varchar2,
p_respondent_id                number,
p_expiry_date                  date,
p_proposed_start_date          date,
p_offer_letter_tracking_code   varchar2,
p_offer_postal_service         varchar2,
p_offer_shipping_date          date,
p_applicant_assignment_id      number,
p_offer_assignment_id          number,
p_address_id                   number,
p_template_id                  number,
p_offer_letter_file_type       varchar2,
p_offer_letter_file_name       varchar2,
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
p_offer_id                     number,
p_offer_version                number,
p_object_version_number        number);
end irc_offers_be1;

/
