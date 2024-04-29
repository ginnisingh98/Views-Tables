--------------------------------------------------------
--  DDL for Package PER_ESTAB_ATTENDANCES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ESTAB_ATTENDANCES_BK1" AUTHID CURRENT_USER as
/* $Header: peesaapi.pkh 120.1 2005/10/02 02:16:54 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_ATTENDED_ESTAB_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ATTENDED_ESTAB_b
  (p_effective_date                in     date
  ,p_fulltime                      in     varchar2
  ,p_attended_start_date           in     date
  ,p_attended_end_date             in     date
  ,p_establishment                 in     varchar2
  ,p_party_id                      in     number
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_establishment_id              in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_address			   in	  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_ATTENDED_ESTAB_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ATTENDED_ESTAB_a
  (p_effective_date                in     date
  ,p_fulltime                      in     varchar2
  ,p_attended_start_date           in     date
  ,p_attended_end_date             in     date
  ,p_establishment                 in     varchar2
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_party_id                      in     number
  ,p_establishment_id              in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_address			   in	  varchar2
  );
--
--
end PER_ESTAB_ATTENDANCES_BK1;

 

/
