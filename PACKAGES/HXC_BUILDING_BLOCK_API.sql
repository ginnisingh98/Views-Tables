--------------------------------------------------------
--  DDL for Package HXC_BUILDING_BLOCK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_BUILDING_BLOCK_API" AUTHID CURRENT_USER as
/* $Header: hxctbbapi.pkh 120.1 2005/07/14 17:18:24 arundell noship $ */

-- ---------------------------------------------------------------------------
-- |-------------------< create_building_block >-----------------------------|
-- ---------------------------------------------------------------------------
-- {start of comments}
--
-- description
--   inserts a record into hxc_time_building_blocks
--
-- prerequisites
--
-- in parameters
--   name                      reqd?  type     description
--   p_validate                  y    boolean  if true,leaves database unchanged
--   p_effective_date            y    date     effective date of insert
--   p_type                      y    varchar2 building block type
--   p_measure                   n    number   measure of time unit
--   p_unit_of_measure           n    varchar2 time unit
--   p_start_time                n    date     time in
--   p_stop_time                 n    date     time out
--   p_parent_building_block_id  n    number   id of parent building block
--   p_parent_building_block_ovn n    number   ovn of parent building block
--   p_scope                     y    varchar2 scope of building block
--   p_approval_style_id         y    number   approval style id
--   p_approval_status           y    varchar2 approval status
--   p_resource_id               y    number   resource id
--   p_resource_type             y    varchar2 resource type
--   p_comment_text              n    varchar2 comments
--   p_application_set_id        n    number   application set Id of the TBB
--   p_translation_display_key   n    varchar2 Self Service display key
--
-- out parameters
--   name                       type      description
--   p_time_building_block_id   number    primary key
--   p_object_version_number    number    ovn
--
-- access status
--   public
--
-- {end of comments}

procedure create_building_block
  (p_validate                  in     boolean default false
  ,p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_measure                   in     number
  ,p_unit_of_measure           in     varchar2
  ,p_start_time                in     date
  ,p_stop_time                 in     date
  ,p_parent_building_block_id  in     number
  ,p_parent_building_block_ovn in     number
  ,p_scope                     in     varchar2
  ,p_approval_style_id         in     number
  ,p_approval_status           in     varchar2
  ,p_resource_id               in     number
  ,p_resource_type             in     varchar2
  ,p_comment_text              in     varchar2
  ,p_application_set_id        in     number
  ,p_translation_display_key   in     varchar2
  ,p_time_building_block_id    in out nocopy number
  ,p_object_version_number     in out nocopy number
  );

-- 115.11
-- New proc create_reversing_entry to have the DATE_TO parameter
-- ---------------------------------------------------------------------------
-- |-------------------< create_reversing_entry >-----------------------------|
-- ---------------------------------------------------------------------------
-- {start of comments}
--
-- description
--   inserts a record into hxc_time_building_blocks
--
-- prerequisites
--
-- in parameters
--   name                      reqd?  type     description
--   p_validate                  y    boolean  if true,leaves database unchanged
--   p_effective_date            y    date     effective date of insert
--   p_type                      y    varchar2 building block type
--   p_measure                   n    number   measure of time unit
--   p_unit_of_measure           n    varchar2 time unit
--   p_start_time                n    date     time in
--   p_stop_time                 n    date     time out
--   p_parent_building_block_id  n    number   id of parent building block
--   p_parent_building_block_ovn n    number   ovn of parent building block
--   p_scope                     y    varchar2 scope of building block
--   p_approval_style_id         y    number   approval style id
--   p_approval_status           y    varchar2 approval status
--   p_resource_id               y    number   resource id
--   p_resource_type             y    varchar2 resource type
--   p_comment_text              n    varchar2 comments
--   p_application_set_id        n    number   application set Id of the TBB
--   p_date_to                   y    date     end date for TBB
--   p_translation_display_key   n    varchar2 self service display key
--
-- out parameters
--   name                       type      description
--   p_time_building_block_id   number    primary key
--   p_object_version_number    number    ovn
--
-- access status
--   public
--
-- {end of comments}

procedure create_reversing_entry
  (p_validate                  in     boolean default false
  ,p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_measure                   in     number
  ,p_unit_of_measure           in     varchar2
  ,p_start_time                in     date
  ,p_stop_time                 in     date
  ,p_parent_building_block_id  in     number
  ,p_parent_building_block_ovn in     number
  ,p_scope                     in     varchar2
  ,p_approval_style_id         in     number
  ,p_approval_status           in     varchar2
  ,p_resource_id               in     number
  ,p_resource_type             in     varchar2
  ,p_comment_text              in     varchar2
  ,p_application_set_id        in     number
  ,p_date_to                   in     date
  ,p_translation_display_key   in     varchar2
  ,p_time_building_block_id    in out nocopy number
  ,p_object_version_number     in out nocopy number
  );


-- ---------------------------------------------------------------------------
-- |-------------------< update_building_block >-----------------------------|
-- ---------------------------------------------------------------------------
-- {start of comments}
--
-- description
--   updates a record in hxc_time_building_blocks (date enabled)
--
-- prerequisites
--
-- in parameters
--   name                      reqd?  type     description
--   p_validate                  y    boolean  if true,leaves database unchanged
--   p_time_building_block_id    y    number   primary key of record
--   p_effective_date            y    date     effective date of update
--   p_type                      y    varchar2 building block type
--   p_measure                   n    number   measure of time unit
--   p_unit_of_measure           n    varchar2 time unit
--   p_start_time                n    date     time in
--   p_stop_time                 n    date     ime out
--   p_parent_building_block_id  n    number   id of parent building block
--   p_parent_building_block_ovn n    number   ovn of parent building block
--   p_scope                     y    varchar2 scope of building block
--   p_approval_style_id         y    number   approval style id
--   p_approval_status           y    varchar2 approval status
--   p_resource_id               y    number   resource id
--   p_resource_type             y    varchar2 resource type
--   p_comment_text              n    varchar2 comments
--   p_application_set_id        n    number   application set Id of the TBB
--   p_translation_display_key   n    varchar2 self service display key
--
-- out parameters
--   name                       type      description
--   p_object_version_number    number    ovn
--
-- access status
--   public
--
-- {end of comments}

procedure update_building_block
  (p_validate                  in     boolean default false
  ,p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_measure                   in     number
  ,p_unit_of_measure           in     varchar2
  ,p_start_time                in     date
  ,p_stop_time                 in     date
  ,p_parent_building_block_id  in     number
  ,p_parent_building_block_ovn in     number
  ,p_scope                     in     varchar2
  ,p_approval_style_id         in     number
  ,p_approval_status           in     varchar2
  ,p_resource_id               in     number
  ,p_resource_type             in     varchar2
  ,p_comment_text              in     varchar2
  ,p_time_building_block_id    in     number
  ,p_application_set_id        in     number
  ,p_translation_display_key   in     varchar2
  ,p_object_version_number     in out nocopy number
  );


-- ---------------------------------------------------------------------------
-- |-------------------< delete_building_block >-----------------------------|
-- ---------------------------------------------------------------------------
-- {start of comments}
--
-- description
--   deletes a record from hxc_time_building_blocks (date enabled)
--
-- prerequisites
--
-- in parameters
--   name                   reqd?   type     description
--   p_validate               y     boolean  if true, leaves database unchanged
--   p_object_version_number  y     number   object_version_number
--   p_time_building_block_id y     number   primary key of record
--   p_effective_date         y     date     effective date
--
-- out parameters
--   name                       type      description
--   p_object_version_number    number    ovn
--
-- access status
--   public
--
-- {end of comments}

procedure delete_building_block
  (p_validate               in     boolean default false
  ,p_object_version_number  in out nocopy number
  ,p_time_building_block_id in     number
  ,p_effective_date         in     date
  ,p_application_set_id     in     number default null
  );

end hxc_building_block_api;

 

/
