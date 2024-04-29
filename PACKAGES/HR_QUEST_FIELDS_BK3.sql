--------------------------------------------------------
--  DDL for Package HR_QUEST_FIELDS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_FIELDS_BK3" AUTHID CURRENT_USER as
/* $Header: hrqsfapi.pkh 120.0 2005/05/31 02:27:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_fields_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_fields_b
  (p_field_id                             in     number
  ,p_object_version_number                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_fields_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_fields_a
  (p_field_id                             in     number
  ,p_object_version_number                in     number
  );
--
end hr_quest_fields_bk3;

 

/
