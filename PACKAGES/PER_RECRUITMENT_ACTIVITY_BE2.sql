--------------------------------------------------------
--  DDL for Package PER_RECRUITMENT_ACTIVITY_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RECRUITMENT_ACTIVITY_BE2" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:33:06
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure update_recruitment_activity_a (
p_recruitment_activity_id      number,
p_authorising_person_id        number,
p_run_by_organization_id       number,
p_internal_contact_person_id   number,
p_parent_recruitment_activity  number,
p_currency_code                varchar2,
p_date_start                   date,
p_name                         varchar2,
p_actual_cost                  varchar2,
p_comments                     long,
p_contact_telephone_number     varchar2,
p_date_closing                 date,
p_date_end                     date,
p_external_contact             varchar2,
p_planned_cost                 varchar2,
p_recruiting_site_id           number,
p_recruiting_site_response     varchar2,
p_last_posted_date             date,
p_type                         varchar2,
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
p_posting_content_id           number,
p_status                       varchar2,
p_object_version_number        number);
end per_recruitment_activity_be2;

 

/
