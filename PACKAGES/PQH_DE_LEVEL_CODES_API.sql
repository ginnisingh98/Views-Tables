--------------------------------------------------------
--  DDL for Package PQH_DE_LEVEL_CODES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_LEVEL_CODES_API" AUTHID CURRENT_USER as
/* $Header: pqlcdapi.pkh 120.0 2005/05/29 02:10:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_LEVEL_CODES_API> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API Creates the the master definition of LEVEL CODES
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

procedure Insert_LEVEL_CODES
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_level_number_id               in  number
  ,p_level_code                    in  varchar2
  ,p_description                   in  varchar2
  ,p_gradual_value_number          in  number
  ,p_level_code_id                 out nocopy number
  ,p_object_version_number         out nocopy number
  );

procedure Update_LEVEL_CODES
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_level_code_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_level_number_id              in     number    default hr_api.g_number
  ,p_level_code                   in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_gradual_value_number         in     number    default hr_api.g_number
  );

procedure delete_LEVEL_CODES
  (p_validate                      in     boolean  default false
  ,p_level_code_id                 in     number
  ,p_object_version_number         in     number
  );
--
end  PQH_DE_LEVEL_CODES_API;

 

/
