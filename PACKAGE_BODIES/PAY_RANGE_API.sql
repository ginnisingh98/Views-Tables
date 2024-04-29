--------------------------------------------------------
--  DDL for Package Body PAY_RANGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RANGE_API" as
/* $Header: pyranapi.pkb 120.0.12000000.2 2007/02/10 10:12:01 vetsrini noship $ */


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
)

IS

  l_object_version_number   number;
  l_range_id   number;

BEGIN

  l_object_version_number := 1;


pay_ran_ins.ins
(
 p_RANGE_TABLE_ID                      => p_RANGE_TABLE_ID
,P_LOW_BAND                            => P_LOW_BAND
,P_HIGH_BAND                           => P_HIGH_BAND
,P_AMOUNT1                             => P_AMOUNT1
,P_AMOUNT2                             => P_AMOUNT2
,P_AMOUNT3                             => P_AMOUNT3
,P_AMOUNT4                             => P_AMOUNT4
,P_AMOUNT5                             => P_AMOUNT5
,P_AMOUNT6                             => P_AMOUNT6
,P_AMOUNT7                             => P_AMOUNT7
,P_AMOUNT8                             => P_AMOUNT8
,p_EFFECTIVE_START_DATE                => p_EFFECTIVE_START_DATE
,p_EFFECTIVE_END_DATE                  => p_EFFECTIVE_END_DATE
,p_OBJECT_VERSION_NUMBER               => l_object_version_number
,p_range_id                            => l_range_id
);


  p_object_version_number   := l_object_version_number;
  p_range_id   := l_range_id;



end create_range;


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
)

IS

  l_object_version_number   number;


BEGIN

  l_object_version_number := p_object_version_number;


pay_ran_upd.upd
(
 p_range_id                            => p_range_id
,p_RANGE_TABLE_ID                      => p_RANGE_TABLE_ID
,P_LOW_BAND                            => P_LOW_BAND
,P_HIGH_BAND                           => P_HIGH_BAND
,P_AMOUNT1                             => P_AMOUNT1
,P_AMOUNT2                             => P_AMOUNT2
,P_AMOUNT3                             => P_AMOUNT3
,P_AMOUNT4                             => P_AMOUNT4
,P_AMOUNT5                             => P_AMOUNT5
,P_AMOUNT6                             => P_AMOUNT6
,P_AMOUNT7                             => P_AMOUNT7
,P_AMOUNT8                             => P_AMOUNT8
,p_EFFECTIVE_START_DATE                => p_EFFECTIVE_START_DATE
,p_EFFECTIVE_END_DATE                  => p_EFFECTIVE_END_DATE
,p_OBJECT_VERSION_NUMBER               => l_object_version_number
);


  p_object_version_number   := l_object_version_number;

end update_range;

procedure delete_range
 ( p_range_id                             in     number
  ,p_object_version_number                in     number
  )

IS


BEGIN


pay_ran_del.del
(
 p_range_id                            => p_range_id
,p_OBJECT_VERSION_NUMBER               => p_object_version_number
);


end delete_range;


END pay_range_api;

/
