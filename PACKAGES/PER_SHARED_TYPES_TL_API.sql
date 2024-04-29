--------------------------------------------------------
--  DDL for Package PER_SHARED_TYPES_TL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SHARED_TYPES_TL_API" AUTHID CURRENT_USER as
/* $Header: pesttapi.pkh 115.2 2002/12/09 16:29:30 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_shared_types_tl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_source_lang                  Yes  varchar2
--   p_shared_type_name             Yes  varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_shared_type_id               Yes  number    PK of record
--   p_language                     Yes  varchar2  PK of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_shared_types_tl
(
   p_validate                       in boolean    default false
  ,p_shared_type_id                 out nocopy number
  ,p_language                       out nocopy varchar2
  ,p_source_lang                    in  varchar2  default null
  ,p_shared_type_name               in  varchar2  default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_shared_types_tl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_shared_type_id               Yes  number    PK of record
--   p_source_lang                  Yes  varchar2
--   p_shared_type_name             Yes  varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_language                     Yes  varchar2  PK of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_shared_types_tl
  (
   p_validate                       in boolean    default false
  ,p_shared_type_id                 in  number
  ,p_language                       out nocopy varchar2
  ,p_source_lang                    in  varchar2  default hr_api.g_varchar2
  ,p_shared_type_name               in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_shared_types_tl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_shared_type_id               Yes  number    PK of record
--
-- Post Success:
--
--   Name                           Type     Description
--   p_language                     Yes  varchar2  PK of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_shared_types_tl
  (
   p_validate                       in boolean        default false
  ,p_shared_type_id                 in  number
  ,p_language                       out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_shared_type_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_shared_type_id                 in number
   ,p_language                     in varchar2
  );
--
end per_shared_types_tl_api;

 

/
