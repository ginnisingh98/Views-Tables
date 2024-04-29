--------------------------------------------------------
--  DDL for Package AME_ACTION_BK10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_BK10" AUTHID CURRENT_USER as
/* $Header: amatyapi.pkh 120.3 2006/09/28 14:03:56 avarri noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_req_attribute_b >-------------------|
-- ----------------------------------------------------------------------------
procedure delete_ame_req_attribute_b
  (p_action_type_id          in     number
  ,p_attribute_id            in     number
  ,p_object_version_number   in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_req_attribute_a >-------------------|
-- ----------------------------------------------------------------------------
procedure delete_ame_req_attribute_a
  (p_action_type_id          in     number
  ,p_attribute_id            in     number
  ,p_object_version_number   in     number
  ,p_start_date              in     date
  ,p_end_date                in     date
        );
end ame_action_bk10;

 

/
