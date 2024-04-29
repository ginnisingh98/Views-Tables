--------------------------------------------------------
--  DDL for Package HXC_SEEDDATA_BY_LEVEL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SEEDDATA_BY_LEVEL_API" AUTHID CURRENT_USER as
/* $Header: hxchsdapi.pkh 120.0 2005/05/29 05:40:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_seed_data_by_level >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates the Seed Data Levels.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No            If p_validate is true then
--                                                the database remains unchanged.
--                                                If false, then a seed data level
--                                                is created. Default is False.
--   p_object_type                  Yes           The object_type identifies the type
--                                                of seed data for which the level is
--                                                specified. The object_type must be
--                                                one of the lookup codes
--                                                corresponding to the lookup type
--                                                'HXC_SEED_DATA_REFERENCE'
--   p_object_id                    Yes           Object Type indirectly refers to the
--                                                table for whose seed data the level is
--                                                specified. Object_id refers to the
--                                                primary key for the seed data in that
--                                                table
--   p_hxc_required                 Yes           This parameter specifies the OTL Code
--                                                level for the seed data. This value
--                                                must be one of the lookup codes
--                                                corresponding to the lookup type
--                                                'HXC_REQUIRED'
--   p_owner_application_id         Yes           This parameter specifies the application
--                                                that owns the seed data
-- Post Success:
-- The seed data levels will be created and no error will be thrown.
--
--
-- Post Failure:
-- The seed data levels are not created and an application error will be raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_seed_data_by_level
  (p_validate                      in     boolean  default false
  ,p_object_id                     in    number
  ,p_object_type                   in    varchar2
  ,p_hxc_required                  in     varchar2
  ,p_owner_application_id          in   number
  );
--


-- ----------------------------------------------------------------------------
-- |-----------------------< update_seed_data_by_level >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This API updates the Level or Owning application of seed data.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No            If p_validate is true then
--                                                the database remains unchanged.
--                                                If false, then a seed data level
--                                                is created. Default is False.
--   p_object_type                  Yes           The object_type identifies the type
--                                                of seed data for which the level is
--                                                specified. The object_type must be
--                                                one of the lookup codes
--                                                corresponding to the lookup type
--                                                'HXC_SEED_DATA_REFERENCE'
--   p_object_id                    Yes           Object Type indirectly refers to the
--                                                table for whose seed data the level is
--                                                specified. Object_id refers to the
--                                                primary key for the seed data in that
--                                                table
--   p_hxc_required                 Yes           This parameter specifies the OTL Code
--                                                level for the seed data. This value
--                                                must be one of the lookup codes
--                                                corresponding to the lookup type
--                                                'HXC_REQUIRED'
--   p_owner_application_id         Yes           This parameter specifies the application
--                                                that owns the seed data
--
--
-- Post Success:
--   The seed data levels will be updated and no error will be thrown.
--
--
-- Post Failure:
--   The seed data levels will not be updated and an application error will be thrown.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_seed_data_by_level
  (p_validate                      in     boolean  default false
  ,p_object_id                     in    number
  ,p_object_type                   in    varchar2
  ,p_hxc_required                  in     varchar2
  ,p_owner_application_id          in   number
  );
--



-- ----------------------------------------------------------------------------
-- |-----------------------< delete_seed_data_by_level >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This API deletes the record corresponding to the given object_id and
--   object_type in the hxc_seeddata_by_level.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No            If p_validate is true then
--                                                the database remains unchanged.
--                                                If false, then a seed data level
--                                                is created. Default is False.
--   p_object_type                  Yes           The object_type identifies the type
--                                                of seed data for which the level is
--                                                specified. The object_type must be
--                                                one of the lookup codes
--                                                corresponding to the lookup type
--                                                'HXC_SEED_DATA_REFERENCE'
--   p_object_id                    Yes           Object Type indirectly refers to the
--                                                table for whose seed data the level is
--                                                specified. Object_id refers to the
--                                                primary key for the seed data in that
--                                                table
--
-- Post Success:
--   The seed data level record will be deleted and no error will be thrown.
--
--
-- Post Failure:
--   The seed data level record will not be deleted and an application error will be thrown.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_seed_data_by_level
  (p_validate                      in     boolean  default false
  ,p_object_id                     in    number
  ,p_object_type                   in    varchar2
  );
--
end hxc_seeddata_by_level_api;

 

/
