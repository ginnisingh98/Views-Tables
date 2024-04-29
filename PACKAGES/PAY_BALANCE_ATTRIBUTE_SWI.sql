--------------------------------------------------------
--  DDL for Package PAY_BALANCE_ATTRIBUTE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_ATTRIBUTE_SWI" AUTHID CURRENT_USER As
/* $Header: pypbaswi.pkh 120.0 2005/05/29 07:18 appldev noship $ */
-- ---------------------------------------------------------------------------+
-- |-----------------------< create_balance_attribute >----------------------|+
-- ---------------------------------------------------------------------------+
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_balance_attribute_api.create_balance_attribute
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_balance_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_attribute_id                 in     number
  ,p_defined_balance_id           in     number
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_balance_attribute_id            out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_balance_attribute >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_balance_attribute_api.delete_balance_attribute
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_balance_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_balance_attribute_id         in     number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
 end pay_balance_attribute_swi;

 

/
