--------------------------------------------------------
--  DDL for Package HXC_ALIAS_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_TYPES_API" AUTHID CURRENT_USER as
/* $Header: hxchatapi.pkh 120.0 2005/05/29 05:34:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_alias_types> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--	Creates Alternate name type.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--  p_validate                      No   boolean  Creates new alias_type if
--						  the value is true.
--  p_alias_type		    Yes  varchar2 Indicates the Alias Type
--						  i.e either 'Static' or
--						  'Dynamic'.
--  p_reference_object              Yes  varchar2  Indicates the reference
--						   object on which the type
--						   is based.
-- Post Success:
-- When the alias type is created properly the following parameters are set.
--
-- Out Parameters:
--     Name                         Type            Description
--  p_alias_type_id                number          The alias type id for the
--						   type created.
--  p_object_version_number        number          The object version number
--						   of the type created.
--
-- Post Failure:
--     Alias type will not be created and raise an application error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_alias_types
  (p_validate                      in     boolean  default false,
   p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 out nocopy    number,
   p_object_version_number         out nocopy    number
  );
--

-- ----------------------------------------------------------------------------
-- |--------------------------< update_alias_types >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--	Updates Alternate name type.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--  p_validate                      No   boolean  Creates new alias_type if
--						  the value is true.
--  p_alias_type_id                  Yes  Number    Identifies the alias type.
--  p_alias_type		    Yes  varchar2 Indicates the Alias Type
--						  i.e either 'Static' or
--						  'Dynamic'.
--  p_reference_object              Yes  varchar2  Indicates the reference
--						   object on which the type
--						   is based.

--
-- Post Success:
--   When the alias type is updated properly the following parameters are set.
--
-- Out Parameters:
--     Name                         Type            Description
--  p_object_version_number        number          The object version number
--						   of the alias type updated.
--
--
-- Post Failure:
--     Alias type will not be updated and raise an application error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_alias_types
  (p_validate                      in     boolean  default false,
   p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 in     number,
   p_object_version_number         in out nocopy    number
  );
--

-- ----------------------------------------------------------------------------
-- |--------------------------< delete_alias_types >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--	Deletes Alternate name type.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the alias type
--                                                is deleted. Default is FALSE.
--  p_alias_type_id                 Yes  Number    Identifies the alias type.
--  p_object_version_number         Yes  Number    The object version number
--						   of the alias type to be
--						   deleted.

-- Post Success:
--   When the alias type is updated properly the following parameters are set.
--
--     Name                         Type            Description
--
--
-- Post Failure:
--     Alias type will not be deleted and raise an application error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_alias_types
  (p_validate                      in     boolean  default false,
   p_alias_type_id                 in     number,
   p_object_version_number         in     number
  );
--
end hxc_alias_types_api;

 

/
