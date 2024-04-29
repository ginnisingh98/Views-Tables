--------------------------------------------------------
--  DDL for Package PER_CHECKLIST_ITEMS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CHECKLIST_ITEMS_BK1" AUTHID CURRENT_USER as
/* $Header: pechkapi.pkh 120.1 2005/10/02 02:13:06 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_checklist_items_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_checklist_items_b
  (
  p_effective_date                 in  date
  ,p_person_id                      in  number
  ,p_item_code                      in  varchar2
  ,p_date_due                       in  date
  ,p_date_done                      in  date
  ,p_status                         in  varchar2
  ,p_notes                          in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_checklist_items_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_checklist_items_a
  (
  p_effective_date                 in  date
  ,p_person_id                      in  number
  ,p_item_code                      in  varchar2
  ,p_date_due                       in  date
  ,p_date_done                      in  date
  ,p_status                         in  varchar2
  ,p_notes                          in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  ,p_checklist_item_id              in  number
  ,p_object_version_number          in  number
  );
--
end per_checklist_items_bk1;

 

/
