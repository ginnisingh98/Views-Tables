--------------------------------------------------------
--  DDL for Package PER_EVENTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVENTS_BK1" AUTHID CURRENT_USER as
/* $Header: peevtapi.pkh 120.1 2005/10/02 02:17:00 aroussel $ */

Procedure create_event_b
(p_date_start                       in     DATE
,p_type                             in     VARCHAR2
,p_business_group_id                in     NUMBER
,p_location_id                      in     NUMBER
,p_internal_contact_person_id       in     NUMBER
,p_organization_run_by_id           in     NUMBER
,p_assignment_id                    in     NUMBER
,p_contact_telephone_number         in     VARCHAR2
,p_date_end                         in     DATE
,p_emp_or_apl                       in     VARCHAR2
,p_event_or_interview               in     VARCHAR2
,p_external_contact                 in     VARCHAR2
,p_time_end                         in     VARCHAR2
,p_time_start                       in     VARCHAR2
,p_attribute_category               in     VARCHAR2
,p_attribute1                       in     VARCHAR2
,p_attribute2                       in     VARCHAR2
,p_attribute3                       in     VARCHAR2
,p_attribute4                       in     VARCHAR2
,p_attribute5                       in     VARCHAR2
,p_attribute6                       in     VARCHAR2
,p_attribute7                       in     VARCHAR2
,p_attribute8                       in     VARCHAR2
,p_attribute9                       in     VARCHAR2
,p_attribute10                      in     VARCHAR2
,p_attribute11                      in     VARCHAR2
,p_attribute12                      in     VARCHAR2
,p_attribute13                      in     VARCHAR2
,p_attribute14                      in     VARCHAR2
,p_attribute15                      in     VARCHAR2
,p_attribute16                      in     VARCHAR2
,p_attribute17                      in     VARCHAR2
,p_attribute18                      in     VARCHAR2
,p_attribute19                      in     VARCHAR2
,p_attribute20                      in     VARCHAR2
,p_party_id                         in     NUMBER    -- HR/TCA merge
);


Procedure create_event_a
(p_date_start                       in     DATE
,p_type                             in     VARCHAR2
,p_business_group_id                in     NUMBER
,p_location_id                      in     NUMBER
,p_internal_contact_person_id       in     NUMBER
,p_organization_run_by_id           in     NUMBER
,p_assignment_id                    in     NUMBER
,p_contact_telephone_number         in     VARCHAR2
,p_date_end                         in     DATE
,p_emp_or_apl                       in     VARCHAR2
,p_event_or_interview               in     VARCHAR2
,p_external_contact                 in     VARCHAR2
,p_time_end                         in     VARCHAR2
,p_time_start                       in     VARCHAR2
,p_attribute_category               in     VARCHAR2
,p_attribute1                       in     VARCHAR2
,p_attribute2                       in     VARCHAR2
,p_attribute3                       in     VARCHAR2
,p_attribute4                       in     VARCHAR2
,p_attribute5                       in     VARCHAR2
,p_attribute6                       in     VARCHAR2
,p_attribute7                       in     VARCHAR2
,p_attribute8                       in     VARCHAR2
,p_attribute9                       in     VARCHAR2
,p_attribute10                      in     VARCHAR2
,p_attribute11                      in     VARCHAR2
,p_attribute12                      in     VARCHAR2
,p_attribute13                      in     VARCHAR2
,p_attribute14                      in     VARCHAR2
,p_attribute15                      in     VARCHAR2
,p_attribute16                      in     VARCHAR2
,p_attribute17                      in     VARCHAR2
,p_attribute18                      in     VARCHAR2
,p_attribute19                      in     VARCHAR2
,p_attribute20                      in     VARCHAR2
,p_party_id                         in     NUMBER    -- HR/TCA merge
);

end PER_EVENTS_BK1;

 

/
