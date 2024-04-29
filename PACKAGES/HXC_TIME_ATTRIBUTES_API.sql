--------------------------------------------------------
--  DDL for Package HXC_TIME_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: hxctatapi.pkh 115.16 2003/11/20 09:11:53 arundell noship $ */

type time_attribute is record
  (attribute_name   varchar2(35)
  ,attribute_value  varchar2(150)
  ,information_type varchar2(80)
  ,column_name	    varchar2(80)
  ,info_mapping_type varchar2(150)
  );

type timecard is table of time_attribute index by binary_integer;

type info_type_table is table of varchar2(80) index by binary_integer;

-- ---------------------------------------------------------------------------
-- |---------------------< create_attributes >-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Inserts new rows into hxc_time_attributes.  This interface should be
-- used when more than one attribute is to be created.
--
-- Prerequisites:
--   The building blocks specified by the time_building_block_id component
-- of the timecard structure, must exist in the hxc_time_building_blocks
-- table, if this value is not null.
--
-- In Parameters:
--   Name                   Reqd?  Type      Description
--   p_validate               y    boolean   if true, leaves database unchanged
--   p_timecard               y    timecard  pl/sql table of attributes
--   p_process_id             n    number    deposit process id
--   p_time_building_block_id n    varchar2  id of parent time building block
--   p_tbb_ovn                n    number    ovn of parent time building block
--
-- Out Parameters:
--   Name                          Type      Description
--   p_time_attribute_id           number    primary key
--   p_object_version_number       number    object version number
--
-- Post Success:
--   The time attributes are created, and the API sets the
-- following out parameters:
--
--   Name                           Type     Description
--   p_time_attribute_id            number   Unique ID for the attribute
--                                           created.
--   p_object_version_number        number   The version of the attribute
--                                           record - always 1 using
--                                           this interface.
--
-- Post Failure:
--   The API does not create the time attribute, and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}

procedure create_attributes
  (p_validate               in     boolean default false
  ,p_timecard               in     timecard
  ,p_process_id             in     number
  ,p_time_building_block_id in     number
  ,p_tbb_ovn                in     number
  ,p_time_attribute_id      in out nocopy number
  ,p_object_version_number  in out nocopy number
  );

-- ---------------------------------------------------------------------------
-- |----------------------< create_attribute >-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Inserts a new row into the hxc_time_attributes table.  This interface
-- should be used when only one attribute will be created.
--
-- Prerequisites:
--   If not null, the building block specified by p_time_building_block_id
-- and p_tbb_ovn must exist in the hxc_time_building_blocks table.
--
-- In Parameters:
--   Name                   Reqd?  Type      Description
--   p_validate               y    boolean   if true, leaves database
--                                           unchanged
--   p_bld_blk_info_type_id   y    number    id of the building block
--                                           information type
--   p_attribute_category     n    varchar2  standard flex column
--   p_attribute1             n    varchar2  standard flex column
--   p_attribute2             n    varchar2  standard flex column
--   p_attribute3             n    varchar2  standard flex column
--   p_attribute4             n    varchar2  standard flex column
--   p_attribute5             n    varchar2  standard flex column
--   p_attribute6             n    varchar2  standard flex column
--   p_attribute7             n    varchar2  standard flex column
--   p_attribute8             n    varchar2  standard flex column
--   p_attribute9             n    varchar2  standard flex column
--   p_attribute10            n    varchar2  standard flex column
--   p_attribute11            n    varchar2  standard flex column
--   p_attribute12            n    varchar2  standard flex column
--   p_attribute13            n    varchar2  standard flex column
--   p_attribute14            n    varchar2  standard flex column
--   p_attribute15            n    varchar2  standard flex column
--   p_attribute16            n    varchar2  standard flex column
--   p_attribute17            n    varchar2  standard flex column
--   p_attribute18            n    varchar2  standard flex column
--   p_attribute19            n    varchar2  standard flex column
--   p_attribute20            n    varchar2  standard flex column
--   p_attribute21            n    varchar2  standard flex column
--   p_attribute22            n    varchar2  standard flex column
--   p_attribute23            n    varchar2  standard flex column
--   p_attribute24            n    varchar2  standard flex column
--   p_attribute25            n    varchar2  standard flex column
--   p_attribute26            n    varchar2  standard flex column
--   p_attribute27            n    varchar2  standard flex column
--   p_attribute28            n    varchar2  standard flex column
--   p_attribute29            n    varchar2  standard flex column
--   p_attribute30            n    varchar2  standard flex column
--   p_time_building_block_id n    varchar2  id of corresponding time
--                                           building block
--   p_tbb_ovn                n    number    ovn of coresponding time
--                                           building block
--
-- Out Parameters:
--   name                          type      description
--   p_time_attribute_id           number    primary key
--   p_object_version_number       number    object version number
--
-- Post Success:
--   The time attribute is created, and the API sets the
-- following out parameters:
--
--   Name                           Type     Description
--   p_time_attribute_id            number   Unique ID for the attribute
--                                           created.
--   p_object_version_number        number   The version of the attribute
--                                           record - always 1 using
--                                           this interface.
--
-- Post Failure:
--   The API does not create the time attribute, and raises an error.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End of Comments}

procedure create_attribute
  (p_validate               in     boolean default false
  ,p_bld_blk_info_type_id   in     number
  ,p_attribute_category     in     varchar2
  ,p_attribute1             in     varchar2
  ,p_attribute2             in     varchar2
  ,p_attribute3             in     varchar2
  ,p_attribute4             in     varchar2
  ,p_attribute5             in     varchar2
  ,p_attribute6             in     varchar2
  ,p_attribute7             in     varchar2
  ,p_attribute8             in     varchar2
  ,p_attribute9             in     varchar2
  ,p_attribute10            in     varchar2
  ,p_attribute11            in     varchar2
  ,p_attribute12            in     varchar2
  ,p_attribute13            in     varchar2
  ,p_attribute14            in     varchar2
  ,p_attribute15            in     varchar2
  ,p_attribute16            in     varchar2
  ,p_attribute17            in     varchar2
  ,p_attribute18            in     varchar2
  ,p_attribute19            in     varchar2
  ,p_attribute20            in     varchar2
  ,p_attribute21            in     varchar2
  ,p_attribute22            in     varchar2
  ,p_attribute23            in     varchar2
  ,p_attribute24            in     varchar2
  ,p_attribute25            in     varchar2
  ,p_attribute26            in     varchar2
  ,p_attribute27            in     varchar2
  ,p_attribute28            in     varchar2
  ,p_attribute29            in     varchar2
  ,p_attribute30            in     varchar2
  ,p_time_building_block_id in     number
  ,p_tbb_ovn                in     number
  ,p_time_attribute_id      in out nocopy number
  ,p_object_version_number  in out nocopy number
  );

-- ---------------------------------------------------------------------------
-- |---------------------< update_attributes >-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   updates attribute definitions related to a building_block
--
-- Prerequisites:
--
-- In Parameters:
--   Name                   Reqd?  Type      Description
--   p_validate               y    boolean   if true, leaves database unchanged
--   p_timecard               y    timecard  pl/sql table of attributes
--   p_process_id             y    number    deposit process id
--   p_time_building_block_id y    varchar2  id of parent time building block
--
-- Out Parameters:
--   name                          type      Description
--   p_object_version_number       number    object version number
--
-- Post Success:
--   The time attributes are updated, and the API sets the
-- following out parameter:
--
--   Name                           Type     Description
--   p_object_version_number        number   The new version number
--                                           of the attribute record
--
-- Post Failure:
--   The time attributes are not updated, and the API raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}

procedure update_attributes
  (p_validate               in     boolean default false
  ,p_timecard               in     timecard
  ,p_process_id             in     number
  ,p_time_building_block_id in     number
  ,p_time_attribute_id      in     number
  ,p_object_version_number  in out nocopy number
  );


-- ---------------------------------------------------------------------------
-- |---------------------< delete_attributes >-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   deletes attribute definitions related to a building_block
--
-- Prerequisites:
--
-- In Parameters:
--   Name                   Reqd?  Type      Description
--   p_validate               y    boolean   if true, leaves database unchanged
--   p_time_attribute_id      y    number    primary key of record
--
-- Out Parameters:
--   Name                          Type      Description
--
-- Post Success:
--   The time attribute specified by p_time_attribute_id is deleted.
--
-- Post Failure:
--   The time attribute is not deleted, and the API raises an error.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End of Comments}

procedure delete_attributes
  (p_validate              in boolean default false
  ,p_time_attribute_id     in number
  ,p_object_version_number in number
  );


end hxc_time_attributes_api;

 

/
