--------------------------------------------------------
--  DDL for Package PAY_GROSSUP_BAL_EXCL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GROSSUP_BAL_EXCL_API" AUTHID CURRENT_USER as
/* $Header: pygbeapi.pkh 115.1 2003/01/28 11:14:07 dsaxby noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_grossup_bal >------------------------|
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
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_grossup_bal
(
   p_validate                       in            boolean default false
  ,p_start_date                     in            date
  ,p_end_date                       in            date
  ,p_source_id                      in            number
  ,p_source_type                    in            varchar2
  ,p_balance_type_id                in            number
  ,p_grossup_balances_id               out nocopy number
  ,p_object_version_number             out nocopy number
);
-- ----------------------------------------------------------------------------
-- |------------------------< update_grossup_bal >------------------------|
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
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_grossup_bal
(
   p_validate                     in     boolean default false
  ,p_grossup_balances_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_source_id                    in     number    default hr_api.g_number
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_balance_type_id              in     number    default hr_api.g_number
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_grossup_bal >------------------------|
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
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_grossup_bal
(
   p_validate                       in     boolean default false
  ,p_grossup_balances_id                  in     number
  ,p_object_version_number                in     number
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< lck_grossup_bal >------------------------|
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
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck_grossup_bal
(
   p_grossup_balances_id                  in     number
  ,p_object_version_number                in     number
);
--
end pay_grossup_bal_excl_api;

 

/
