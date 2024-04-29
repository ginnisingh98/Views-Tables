--------------------------------------------------------
--  DDL for Package PQH_DE_RESULT_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_RESULT_SETS_API" AUTHID CURRENT_USER as
/* $Header: pqrssapi.pkh 120.0 2005/05/29 02:37:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_RESULT_SETS_API> >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API Creates the the master definition of Tatikegt details
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

procedure Insert_RESULT_SETS
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_gradual_value_number_from     in     number
  ,p_gradual_value_number_to       in     number
  ,p_grade_id                      in     number
  ,p_result_set_id                 out nocopy    number
  ,p_object_version_number         out nocopy    number
  ) ;

Procedure Update_RESULT_SETS
 (p_validate                      in  boolean  default false
  , p_effective_date              in     date
  ,p_result_set_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_gradual_value_number_from    in     number    default hr_api.g_number
  ,p_gradual_value_number_to      in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ) ;

procedure delete_RESULT_SETS
   (p_validate                in     boolean  default false
   ,p_RESULT_SET_ID           In     Number
  ,p_object_version_number    In     number);

--
end  PQH_DE_RESULT_SETS_API;

 

/
