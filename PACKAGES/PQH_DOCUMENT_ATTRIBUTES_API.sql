--------------------------------------------------------
--  DDL for Package PQH_DOCUMENT_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENT_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: pqdoaapi.pkh 120.0 2005/05/29 01:48:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_DOCUMENT_ATTRIBUTE>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure CREATE_DOCUMENT_ATTRIBUTE
    (p_validate                       in     boolean  default false
    ,p_effective_date                 in     date
    ,p_document_id                    in     number
    ,p_attribute_id                   in     number
    ,p_tag_name                       in     varchar2
    ,p_document_attribute_id             out NOCOPY 	number
    ,p_object_version_number             out NOCOPY	number
    ,p_effective_start_date              out NOCOPY	date
    ,p_effective_end_date                out NOCOPY	date
    );
--
-- ----------------------------------------------------------------------------
-- |--------------------------<UPDATE_DOCUMENT_ATTRIBUTE>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_document_attribute
    (p_validate                     in     boolean  default false
    ,p_effective_date               in     date
    ,p_datetrack_mode               in     varchar2
    ,p_document_attribute_id        in     number
    ,p_object_version_number        in OUT NOCOPY number
    ,p_document_id                  in     number    default hr_api.g_number
    ,p_attribute_id                 in     number    default hr_api.g_number
    ,p_tag_name                     in     varchar2  default hr_api.g_varchar2
    ,p_effective_start_date            OUT NOCOPY date
    ,p_effective_end_date              OUT NOCOPY date
    );

-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_DOCUMENT_ATTRIBUTE>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_document_attribute
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_attribute_id          in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  );
--

end pqh_document_attributes_api;

 

/
