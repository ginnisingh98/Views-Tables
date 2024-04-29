--------------------------------------------------------
--  DDL for Package PAY_RANGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RANGE_API" AUTHID CURRENT_USER as
/* $Header: pyranapi.pkh 120.0.12000000.2 2007/02/10 10:10:44 vetsrini noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_range >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure creates range for tax tables
--
-- Prerequisites:
-- p_RANGE_TABLE_ID,P_LOW_BAND,P_HIGH_BAND,P_AMOUNT1
-- must be passed
--
-- In Parameter:
--
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure create_range
(
 p_RANGE_TABLE_ID                          in NUMBER default NULL
,P_LOW_BAND                                in NUMBER default NULL
,P_HIGH_BAND                               in NUMBER default NULL
,P_AMOUNT1                                 in NUMBER default NULL
,P_AMOUNT2                                 in NUMBER default NULL
,P_AMOUNT3                                 in NUMBER default NULL
,P_AMOUNT4                                 in NUMBER default NULL
,P_AMOUNT5                                 in NUMBER default NULL
,P_AMOUNT6                                 in NUMBER default NULL
,P_AMOUNT7                                 in NUMBER default NULL
,P_AMOUNT8                                 in NUMBER default NULL
,p_EFFECTIVE_START_DATE                    in DATE default NULL
,p_EFFECTIVE_END_DATE                      in DATE default NULL
,p_object_version_number                   OUT  nocopy number
,p_range_id                                OUT nocopy number
);

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_range >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure updates the existing range
--
-- Prerequisites:
-- p_range_table_id,p_range_id,code
-- must be passed
--
-- In Parameter:
--
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure update_range
(  p_range_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_range_table_id               in     number    default hr_api.g_number
  ,p_low_band                     in     number    default hr_api.g_number
  ,p_high_band                    in     number    default hr_api.g_number
  ,p_amount1                      in     number    default hr_api.g_number
  ,p_amount2                      in     number    default hr_api.g_number
  ,p_amount3                      in     number    default hr_api.g_number
  ,p_amount4                      in     number    default hr_api.g_number
  ,p_amount5                      in     number    default hr_api.g_number
  ,p_amount6                      in     number    default hr_api.g_number
  ,p_amount7                      in     number    default hr_api.g_number
  ,p_amount8                      in     number    default hr_api.g_number
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_effective_end_date           in     date      default hr_api.g_date
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_range >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   The procedure will delete range for tax tables
--
-- Prerequisites:
-- p_range_id must be passed
--
--
-- In Parameter:
--
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure delete_range
 ( p_range_id                             in     number
  ,p_object_version_number                in     number
  );

end pay_range_api;

 

/
