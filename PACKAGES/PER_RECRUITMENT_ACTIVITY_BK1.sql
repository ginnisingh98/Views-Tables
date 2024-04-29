--------------------------------------------------------
--  DDL for Package PER_RECRUITMENT_ACTIVITY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RECRUITMENT_ACTIVITY_BK1" AUTHID CURRENT_USER as
/* $Header: peraaapi.pkh 120.1 2005/10/02 02:23:28 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_recruitment_activity_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_recruitment_activity_b
  (p_business_group_id             in   number
  ,p_authorising_person_id         in   number
  ,p_run_by_organization_id        in   number
  ,p_internal_contact_person_id    in   number
  ,p_parent_recruitment_activity   in   number
  ,p_currency_code                 in   varchar2
  ,p_date_start                    in   date
  ,p_name                          in   varchar2
  ,p_actual_cost                   in   varchar2
  ,p_comments                      in   long
  ,p_contact_telephone_number      in   varchar2
  ,p_date_closing                  in   date
  ,p_date_end                      in   date
  ,p_external_contact              in   varchar2
  ,p_planned_cost                  in   varchar2
  ,p_recruiting_site_id            in   number
  ,p_recruiting_site_response      in   varchar2
  ,p_last_posted_date              in   date
  ,p_type                          in   varchar2
  ,p_attribute_category            in   varchar2
  ,p_attribute1                    in   varchar2
  ,p_attribute2                    in   varchar2
  ,p_attribute3                    in   varchar2
  ,p_attribute4                    in   varchar2
  ,p_attribute5                    in   varchar2
  ,p_attribute6                    in   varchar2
  ,p_attribute7                    in   varchar2
  ,p_attribute8                    in   varchar2
  ,p_attribute9                    in   varchar2
  ,p_attribute10                   in   varchar2
  ,p_attribute11                   in   varchar2
  ,p_attribute12                   in   varchar2
  ,p_attribute13                   in   varchar2
  ,p_attribute14                   in   varchar2
  ,p_attribute15                   in   varchar2
  ,p_attribute16                   in   varchar2
  ,p_attribute17                   in   varchar2
  ,p_attribute18                   in   varchar2
  ,p_attribute19                   in   varchar2
  ,p_attribute20                   in   varchar2
  ,p_posting_content_id            in   number
  ,p_status                        in   varchar2
  );
--
-- -----------------------------------------------------------------------------
-- |---------------------< create_recruitment_activity_a >---------------------|
-- -----------------------------------------------------------------------------
--
procedure create_recruitment_activity_a
  (p_business_group_id             in   number
  ,p_authorising_person_id         in   number
  ,p_run_by_organization_id        in   number
  ,p_internal_contact_person_id    in   number
  ,p_parent_recruitment_activity   in   number
  ,p_currency_code                 in   varchar2
  ,p_date_start                    in   date
  ,p_name                          in   varchar2
  ,p_actual_cost                   in   varchar2
  ,p_comments                      in   long
  ,p_contact_telephone_number      in   varchar2
  ,p_date_closing                  in   date
  ,p_date_end                      in   date
  ,p_external_contact              in   varchar2
  ,p_planned_cost                  in   varchar2
  ,p_recruiting_site_id            in   number
  ,p_recruiting_site_response      in   varchar2
  ,p_last_posted_date              in   date
  ,p_type                          in   varchar2
  ,p_attribute_category            in   varchar2
  ,p_attribute1                    in   varchar2
  ,p_attribute2                    in   varchar2
  ,p_attribute3                    in   varchar2
  ,p_attribute4                    in   varchar2
  ,p_attribute5                    in   varchar2
  ,p_attribute6                    in   varchar2
  ,p_attribute7                    in   varchar2
  ,p_attribute8                    in   varchar2
  ,p_attribute9                    in   varchar2
  ,p_attribute10                   in   varchar2
  ,p_attribute11                   in   varchar2
  ,p_attribute12                   in   varchar2
  ,p_attribute13                   in   varchar2
  ,p_attribute14                   in   varchar2
  ,p_attribute15                   in   varchar2
  ,p_attribute16                   in   varchar2
  ,p_attribute17                   in   varchar2
  ,p_attribute18                   in   varchar2
  ,p_attribute19                   in   varchar2
  ,p_attribute20                   in   varchar2
  ,p_posting_content_id            in   number
  ,p_status                        in   varchar2
  ,p_object_version_number         in   number
  ,p_recruitment_activity_id       in   number
  );
--
end PER_RECRUITMENT_ACTIVITY_BK1;

 

/
