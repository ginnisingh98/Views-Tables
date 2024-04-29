--------------------------------------------------------
--  DDL for Package PER_ESTAB_ATTENDANCES_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ESTAB_ATTENDANCES_BE1" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:32:08
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure create_attended_estab_a (
p_effective_date               date,
p_fulltime                     varchar2,
p_attended_start_date          date,
p_attended_end_date            date,
p_establishment                varchar2,
p_business_group_id            number,
p_person_id                    number,
p_party_id                     number,
p_establishment_id             number,
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
p_address                      varchar2);
end per_estab_attendances_be1;

 

/
